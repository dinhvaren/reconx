# RECONX Security and Build Report

Date: 2026-11-11

Project: `D:\RECONX`

Local image: `reconx:local`

## 1. Source and Repository

| Item | Value |
| --- | --- |
| Remote | `https://github.com/dinhvaren/reconx.git` |
| Branch | `main` |
| Upstream source baseline | `319c4fc43df1aecab16ec9a84c16224ebee2c486` |
| Local Git state before publication | Initialized repository with no prior commit; remote `main` was empty |
| Local release commit | Initial RECONX commit on `main`; upstream baseline recorded above |
| Commit/push performed | This report is included in the initial published RECONX history |
| Tracked compatibility names | Go module path, `cmd/artex`, `ARTEX_*`, database identifiers, JWT subject, and legacy storage keys |

The local Git metadata was initialized separately from the upstream clone, so
the upstream baseline SHA is retained here as provenance. A blind global rename
was not performed because persisted identifiers and database identifiers are
part of the compatibility boundary.

## 2. Audit Result

Result: **PASS** for the reported November 2026 Docker backdoor indicators and
the reviewed authentication boundary.

Evidence retained from the source and artifact audit:

- No `verifyCaptcha` routine, CAPTCHA command marker, or
  CAPTCHA-triggered shell execution was found in source or reviewed history.
- Login uses bcrypt password verification, rate limiting, and JWT validation.
- Unauthenticated `/api/tasks` access returned HTTP 401; authenticated access
  returned HTTP 200.
- Authentication exemptions are limited to the expected authentication and
  health routes; no hidden unauthenticated shell endpoint was identified.
- Shell execution sites are limited to the existing doctor, self-update smoke
  test, authenticated custom tools, and tests.
- No unauthenticated HTTP-to-shell data flow was found.
- `go mod verify` returned `all modules verified`.
- No hardcoded provider key was found in the reviewed source diff or image
  environment.
- Known indicators were absent from the reviewed source, local binary, and
  image filesystem content.
- Runtime Compose uses only `reconx:local` with `pull_policy: never` and a
  digest-pinned PostgreSQL image.
- No prebuilt V-ARTEX image is used for runtime.

This result is an audit of reviewed source and artifacts, not cryptographic
proof for every transitive dependency.

## 3. Backdoor Findings

No confirmed backdoor, authentication bypass, credential exfiltration, reverse
shell, or CAPTCHA command trigger was found.

Relevant non-runtime findings:

- `install.sh` contains a remote Docker installer pipeline and was not executed.
- `update.sh` contains `git pull` and a prebuilt-image pull path and was not
  executed.
- `docker-compose.bench.yml` uses host networking and is not the RECONX runtime
  deployment.
- Self-update code remains present. The local build has no release version
  injected, so release-binary replacement is not activated.

## 4. Documentation Reset

The inherited documentation set was removed, including:

- 22 upstream planning and design documents under `docs/superpowers/`.
- The inherited traffic-evidence feature page.
- Three legacy side-question documentation pages.
- The inherited long-form README and changelog content.

A current RECONX documentation set now covers:

- `README.md`: overview, build, 9Router configuration, operations, and license.
- `docs/README.md`: documentation index.
- `docs/ARCHITECTURE.md`: components, data flow, persistence, and LLM pool.
- `docs/OPERATIONS.md`: build, lifecycle, health, backup, and troubleshooting.
- `docs/SECURITY.md`: trust boundaries, secrets, controls, and residual risk.
- `docs/DEVELOPMENT.md`: layout, tests, build loop, and compatibility names.
- `README.md` and `docs/images/`: live-build and built-in mock-data screenshots
  covering the core workflow, task detail, findings, system configuration,
  dark mode, and responsive mobile views without exposing real assessment data
  or credentials.
- `THIRD_PARTY_NOTICES/Claude-BugHunter/`: pinned source, attribution, and
  dual-license notices for the installed 83-skill bundle.
- `CHANGELOG.md`: local RECONX release history.

`LICENSE`, functional skill documentation, the third-party shadcn license, and
required project attribution were retained.

## 5. Docker Image

| Item | Value |
| --- | --- |
| Image | `reconx:local` |
| Image ID | `sha256:da3adee6539158c6f0e097b8b1fa8b902af2dd61ef4cc1ab256f760cec7922d7` |
| Created | `2026-11-10T07:13:39.563265247Z` |
| Build source | Local `dist/amd64/reconx` copied by the audited Dockerfile |
| Runtime pull | Disabled with `pull_policy: never` |

Pinned base images:

- `node:20-bookworm-slim@sha256:2cf067cfed83d5ea958367df9f966191a942351a2df77d6f0193e162b5febfc0`
- `python:3.12-slim-bookworm@sha256:935c3c5b12357a7e10caa9c1e6ca5692344d97cf229832ef584be2cec9fc03df`
- `postgres:16-alpine@sha256:aa6cb33cf4c19c765cefcf48d96176258800870a9a1e930ad126200f9d825139`

## 6. Runtime Status

| Container | Status | Host publication | Image |
| --- | --- | --- | --- |
| `reconx-reconx-1` | Up, healthy | `127.0.0.1:18787 -> 8787/tcp` | `reconx:local` |
| `reconx-postgres-1` | Up, healthy | Not published | Pinned PostgreSQL digest |

Current container IDs:

- RECONX: `b0e09f0218e6e7ead1a133a144a245933dc68db068d9415e11a16a3c442ca701`
- PostgreSQL: `1d015de432ffa8b1c2c1d17b79c27b2fc84c7e6b7a27c9777f6e61ba4e2a5fc1`

Runtime constraints:

- Loopback-only publication.
- `privileged=false`.
- No Docker socket mount.
- No host network mode.
- No added runtime capabilities.
- `no-new-privileges=true`.
- PostgreSQL and JWT key volumes retained.

## 7. Application URL

Actual local URL: **http://localhost:18787**

`/api/health` returned HTTP 200 after Docker Desktop and both containers were
restarted. Port `18787` is used because this Windows host reserves
`8702-8801`, including the project default `8787`.

The default configuration remains `http://localhost:8787` for hosts without
that conflict.

## 8. LLM Configuration

Status: **CONNECTED**

All existing profiles use the 9Router OpenAI-compatible gateway:

```text
https://9router.dinhvaren.io.vn/v1
```

| Profile | Model ID | Default | Stored key |
| --- | --- | --- | --- |
| 9Router DeepSeek V4.1 Flash | `ocg/deepseek-v4.1-flash` | Yes | Yes |
| 9Router MiniMax M3.1 Flash | `ocg/minimax-m3.1-flash` | No | Yes |
| 9Router GLM 5.3 Flash | `ocg/glm-5.3-flash` | No | Yes |
| 9Router Kimi K3.1 Pro | `ocg/kimi-k3.1-pro` | No | Yes |

Verification results:

- Unauthenticated `/v1/models` returned HTTP 401.
- Authenticated `/v1/models` returned HTTP 200 and exposed all four profile IDs.
- Existing profile connection tests recorded HTTP 200 for all four models.
- The application started with `LLM configured from DB` and reported the
  DeepSeek profile as active.
- No bearer token or API key is included in this report, source, Dockerfile, or
  image environment.

The OpenAI-compatible provider strips a full `/chat/completions` suffix before
appending the endpoint, avoiding a duplicated `/v1`.

## 9. Build and Verification

| Check | Result |
| --- | --- |
| Local Next.js static build | PASS |
| Embedded UI copy | PASS |
| Linux amd64 Go build with embedded UI | PASS |
| Docker image `reconx:local` | PASS |
| Frontend tests | PASS, 94/94 |
| Relevant Go package tests | PASS |
| Full Go server suite | 6 Windows-specific failures; no rename regression identified |
| Compose startup and health after Docker restart | PASS |
| Setup/login and authenticated API | PASS |
| PostgreSQL healthy | PASS |
| 9Router model discovery | PASS |
| Profile connection tests | PASS, HTTP 200 |
| Known indicator scan | PASS, no reviewed match |
| Documentation presence and local links | PASS |
| Current UI screenshot capture and gallery | PASS, reviewed live and mock-data views |
| Claude-BugHunter skill installation | PASS, 83/83 expected skills visible through `/api/skills` |
| Tracked secret check | PASS; `.env` is ignored |

The six server-suite failures were Windows filesystem edge cases: five evidence
blob `sync` operations returned access denied under the temporary directory,
and one relative-path test crossed the project and temporary-directory volumes.

Documentation changes do not alter the embedded application artifact or
require another Docker rebuild.

## 10. Residual Risks

- Full CVE scanning, complete transitive provenance, and reproducible-build
  attestation are not established.
- The runtime container runs as root and has no capability drop list.
- Host `./skills` and `./data` are writable bind mounts and are trusted input.
- Legacy install/update scripts remain in the repository and must not be used
  for this distribution.
- Self-update and binary replacement code remains present.
- 9Router becomes a routing, availability, logging, and prompt-data boundary.
- The local `.env` contains secrets and must remain ignored and protected.
- Claude-BugHunter provides offensive-security payload examples intended only
  for authorized testing. Skills are not assigned automatically, and their
  scripts are not executed during installation.
- Port `8787` is not usable on this host because of the Windows reserved range;
  `18787` is the verified local URL.

## 11. Final Status

- REBRAND: **PASS**
- BACKDOOR AUDIT: **PASS** for reviewed indicators and boundaries
- DOCUMENTATION RESET: **PASS**
- DOCKER BUILD: **PASS**
- APPLICATION RUNNING: **YES**
- LLM VIA 9ROUTER: **CONNECTED**
- URL: **http://localhost:18787**
