# Security Model

## Scope

RECONX is a local security-testing console. Use it only within a scope where
the operator has explicit authorization. The application's own audit does not
authorize testing third-party systems.

## Trust boundaries

- Browser to RECONX: authenticated HTTP on a loopback-bound port by default.
- RECONX to PostgreSQL: project-internal Docker network with a local password.
- RECONX to 9Router: HTTPS using a gateway key.
- 9Router to upstream providers: controlled outside this repository.
- Host bind mounts: `./data` and `./skills` are trusted local configuration.

Prompts and model responses pass through 9Router and the configured upstream
provider. Do not process secrets or sensitive assessment evidence through a
gateway you do not trust.

## Supply-chain controls

- Build the frontend and Go binary from the checked-out local source.
- Package only the locally generated `dist/<arch>/reconx` binary.
- Never run `install.sh` or `update.sh` for this distribution.
- Never substitute a prebuilt V-ARTEX image.
- Pin Docker base images by digest.
- Pin and verify Go modules with `go mod verify`.
- Install frontend dependencies from `package-lock.json`.
- Use `npm ci --ignore-scripts` for the reviewed build path.
- Keep Compose on `reconx:local` with `pull_policy: never`.
- Review package and image changes before rebuilding.

## Runtime controls

The checked-in Compose runtime provides:

- Loopback-only publication by default.
- No Docker socket mount.
- No host network mode.
- No privileged container.
- `no-new-privileges:true`.
- Unpublished PostgreSQL port.
- Persistent JWT keys outside the browsable data mount.

## Secrets

- Keep `OPENAI_API_KEY`, database passwords, setup tokens, and administrator
  passwords out of source, docs, images, screenshots, and Git history.
- Store the 9Router key in the existing LLM profile secret field or ignored
  local `.env`.
- Do not print bearer headers, complete provider responses containing
  credentials, or raw environment dumps.
- Rotate any key accidentally exposed in chat, logs, or a public file.
- Protect the PostgreSQL volume and local `.env`; both can contain sensitive
  operational state.

## Authentication and command execution

The application retains its authenticated API boundary, bcrypt password
verification, JWT validation, rate-limited login, command interception, and
human approval controls. Security-sensitive shell actions remain restricted to
existing authenticated application paths.

Do not weaken authentication, disable interception, or expose the UI publicly
to work around a local connectivity or gateway issue.

## Audit status

The local audit evaluated the reported CAPTCHA command-execution backdoor
indicators, authentication paths, shell-execution sites, Docker configuration,
install/update scripts, dependencies, and the local runtime artifact.

Current result: no confirmed match for the reported backdoor in reviewed source,
binary, or image content. This is not a complete CVE scan or cryptographic proof
for every transitive dependency.

See the [security and build report](../SECURITY_BUILD_REPORT.md) for evidence,
limits, and residual risk.

## Known residual risks

- The container runs as root and does not define a capability drop list.
- `./data` and `./skills` are writable host bind mounts.
- Legacy install and update scripts remain in the repository and are unsafe to
  execute for this distribution.
- Self-update code remains present, although a local `dev` build does not
  activate a release replacement.
- Full dependency CVE scanning and reproducible-build attestation have not been
  established.
- A local gateway can introduce rate limits, availability, logging, and
  data-processing risks outside RECONX's control.
