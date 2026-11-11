# syntax=docker/dockerfile:1
#
# RECONX runtime image. The Linux application binary and embedded frontend are
# built locally from this source tree before the image is assembled:
#
#   cd web && npm run build:static && cd ..
#   cp -r web/out server/webui/dist
#   CGO_ENABLED=0 GOARCH=amd64 go build -tags embedui -o dist/amd64/reconx ./cmd/artex
#   docker build --build-arg TARGETARCH=amd64 -t reconx:local .
#
# Base images are pinned by the multi-architecture index digest recorded during
# the security audit. Node is copied from its official Debian image rather than
# installed by piping a remote setup script into a shell.
FROM node:20-bookworm-slim@sha256:2cf067cfed83d5ea958367df9f966191a942351a2df77d6f0193e162b5febfc0 AS node
FROM python:3.12-slim-bookworm@sha256:935c3c5b12357a7e10caa9c1e6ca5692344d97cf229832ef584be2cec9fc03df AS runtime

ARG TARGETARCH

# Node.js runtime copied from the official Node image. Playwright requires Node >=20.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Common recon tooling retained from the upstream design. No remote setup script
# is downloaded or executed during this layer.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates ripgrep curl wget vim git jq unzip libstdc++6 \
      dnsutils iputils-ping netcat-openbsd inetutils-telnet whois nmap \
    && rm -rf /var/lib/apt/lists/*

# Pin every globally installed package. --ignore-scripts avoids package lifecycle
# scripts; Chromium is installed explicitly from the pinned Playwright release.
RUN npm install -g --ignore-scripts --no-audit --no-fund \
      @playwright/mcp@0.0.85 \
      @playwright/cli@0.1.24 \
      playwright@1.65.0 \
    && playwright-cli --help \
    && playwright install --with-deps chromium \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Built solely from the audited local source tree (dist/amd64/reconx or dist/arm64/reconx).
COPY dist/${TARGETARCH}/reconx /app/reconx

# The supervisor restarts the process based on its exit code and forwards SIGTERM.
COPY start.sh /app/start.sh
RUN chmod +x /app/reconx /app/start.sh
COPY skills/ /app/skills/

# Keep the persistent JWT key outside the browsable data workspace.
ENV ARTEX_JWT_KEY_DIR=/app/auth
VOLUME ["/app/data", "/app/auth"]
EXPOSE 8787
ENTRYPOINT ["/app/start.sh"]
CMD ["-addr", ":8787", "-proxy", "127.0.0.1:8788"]
