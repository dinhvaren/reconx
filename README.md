<div align="center">

# RECONX

Local-first autonomous security testing console for authorized environments.

Built with Go, Next.js, PostgreSQL, and Docker.

</div>

RECONX provides a browser-based workspace for orchestrating authorized security
assessments. It combines planner and worker agents, an exploration graph,
traffic and evidence capture, findings, reports, and configurable LLM routing.

> Use RECONX only against systems you own or are explicitly authorized to test.

## Interface

The gallery is captured at 1440 x 900. Core workflow views use RECONX's
built-in Acme demo dataset (`NEXT_PUBLIC_MOCK=1`); login, notifications, and
current model configuration are captured from the local deployment.

The demo data is static and intentionally fictional. It contains no real user,
target, credential, or assessment data.

### Core workspace

| Login | Dashboard |
| :---: | :---: |
| ![RECONX login](docs/images/login.png) | ![RECONX dashboard](docs/images/demo/dashboard.png) |

| Dashboard in dark mode | Task list |
| :---: | :---: |
| ![Dashboard in dark mode](docs/images/demo/dashboard-dark.png) | ![Task list](docs/images/demo/tasks.png) |

| Task sessions | Agent chat |
| :---: | :---: |
| ![Task sessions](docs/images/demo/task-sessions.png) | ![Agent chat](docs/images/demo/chat.png) |

| Human-in-the-loop conversation | Task overview |
| :---: | :---: |
| ![Human-in-the-loop conversation](docs/images/demo/chat-conversation.png) | ![Task overview](docs/images/demo/task-overview.png) |

### Task execution

| Exploration graph | Generated report |
| :---: | :---: |
| ![Exploration graph](docs/images/demo/task-graph.png) | ![Generated report](docs/images/demo/task-report.png) |

| Findings | Finding detail |
| :---: | :---: |
| ![Findings](docs/images/demo/findings.png) | ![Finding detail](docs/images/demo/finding-detail.png) |

| Captured traffic | Tool runs |
| :---: | :---: |
| ![Captured traffic](docs/images/demo/traffic.png) | ![Tool runs](docs/images/demo/tool-runs.png) |

| LLM records | Asset inventory |
| :---: | :---: |
| ![LLM records](docs/images/demo/llm-records.png) | ![Asset inventory](docs/images/demo/assets.png) |

### Assets and workspace

| Asset synchronization | Workspace files |
| :---: | :---: |
| ![Asset synchronization](docs/images/demo/asset-sync.png) | ![Workspace files](docs/images/demo/workspace.png) |

### Agents and tools

| Current 9Router profiles | Agents |
| :---: | :---: |
| ![Current 9Router profiles](docs/images/llm.png) | ![Agents](docs/images/demo/agents.png) |

| MCP servers | Skill library |
| :---: | :---: |
| ![MCP servers](docs/images/demo/mcp.png) | ![Skill library](docs/images/skills-library-live.png) |

| Tools | Command interception |
| :---: | :---: |
| ![Tools](docs/images/demo/tools.png) | ![Command interception](docs/images/demo/intercept-rules.png) |

### Safety and operations

| Asset interception | Approval records |
| :---: | :---: |
| ![Asset interception](docs/images/demo/asset-interception.png) | ![Approval records](docs/images/demo/approvals.png) |

| System logs | Notifications |
| :---: | :---: |
| ![System logs](docs/images/demo/logs.png) | ![Notifications](docs/images/notifications-live.png) |

| System settings | Mobile login |
| :---: | :---: |
| ![System settings](docs/images/demo/settings.png) | ![Mobile login](docs/images/demo/mobile/login.png) |

### Mobile

The mobile views use a 390 x 844 viewport and demonstrate the responsive
sidebar, metrics cards, findings list, and model cards.

| Mobile dashboard | Mobile findings |
| :---: | :---: |
| ![Mobile dashboard](docs/images/demo/mobile/dashboard.png) | ![Mobile findings](docs/images/demo/mobile/findings.png) |

| Mobile LLM profiles | |
| :---: | :---: |
| ![Mobile LLM profiles](docs/images/demo/mobile/llm.png) | |

The notifications view is from the live local deployment and currently has no
configured delivery channels.

## What is included

- Go backend with an embedded Next.js user interface.
- PostgreSQL-backed tasks, agents, assets, findings, evidence, and settings.
- Planner/worker orchestration with persisted exploration state.
- Traffic capture and evidence binding for findings and reports.
- Human approval and command-interception controls.
- OpenAI-compatible LLM profiles with model selection and failover.
- 83 pinned Claude-BugHunter skills for web, API, cloud, identity, mobile,
  enterprise, validation, OSINT, and reporting workflows.
- Local source builds packaged as `reconx:local`.
- Loopback-only Docker publishing by default.

## Quick start

Prerequisites:

- Docker Desktop with Docker Compose.
- Go 1.26.3 or newer.
- Node.js 20 or newer.
- npm.

From PowerShell:

```powershell
Set-Location D:\RECONX

Copy-Item .env.example .env
# Edit .env: set POSTGRES_PASSWORD and, unless using the UI profiles, OPENAI_API_KEY.

Set-Location web
npm ci --ignore-scripts
npm test
$env:NEXT_EXPORT = "1"
npm run build
Set-Location ..

New-Item -ItemType Directory -Force server\webui\dist | Out-Null
Copy-Item -Path web\out\* -Destination server\webui\dist -Recurse -Force

$env:CGO_ENABLED = "0"
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go mod verify
go build -tags embedui -trimpath -o dist\amd64\reconx ./cmd/artex

docker build --build-arg TARGETARCH=amd64 -t reconx:local .
docker compose up -d
docker compose ps
```

Open `http://localhost:8787` unless `RECONX_PORT` changes the published port.
First-run setup requires the setup token printed by:

```powershell
docker compose logs reconx
```

Do not run `install.sh` or `update.sh` for this local distribution.

## Skill library

RECONX includes the complete skill set from
[`elementalsouls/Claude-BugHunter`](https://github.com/elementalsouls/Claude-BugHunter),
pinned to commit `d5dcc5347675ed431488e0a0e46749e4918aa194`.

The bundle contributes 83 skills across bug-hunting methodology, recon,
vulnerability classes, cloud and identity platforms, external red-team
workflows, evidence hygiene, validation, and reporting. RECONX currently shows
86 total skills, including its three pre-existing skills and the identical APK
red-team skill already present in the workspace.

The files are mounted from `./skills` and are loaded without rebuilding the
Docker image. Visibility remains explicit per agent: open
`System -> Skill` and enable the relevant skills for each agent. The bundle is
not assigned automatically because loading all 83 into every planner, worker,
reporting, and retest agent would add unnecessary context and broaden behavior.

License and source details are in
[`THIRD_PARTY_NOTICES/Claude-BugHunter/SOURCE.md`](THIRD_PARTY_NOTICES/Claude-BugHunter/SOURCE.md).

## LLM gateway

RECONX uses its existing OpenAI-compatible profile system. The local profiles
are configured for 9Router at:

```text
https://9router.dinhvaren.io.vn/v1
```

| Profile | Model ID |
| --- | --- |
| DeepSeek V4.1 Flash (default) | `ocg/deepseek-v4.1-flash` |
| MiniMax M3.1 Flash | `ocg/minimax-m3.1-flash` |
| GLM 5.3 Flash | `ocg/glm-5.3-flash` |
| Kimi K3.1 Pro | `ocg/kimi-k3.1-pro` |

The application appends `/chat/completions`; do not include that suffix in the
base URL. Configure the 9Router key either in `System -> LLM Profiles` or as
`OPENAI_API_KEY` in the ignored local `.env`. Profile-level keys take
precedence when present.

Never commit `.env`, place a key in source, or publish it in an issue or chat.
9Router and its upstream providers can see prompts and responses, so avoid
sending sensitive data to an untrusted gateway or provider.

See [Operations](docs/OPERATIONS.md) for gateway diagnostics and model reloads.

## Daily operations

```powershell
# Start or reconcile the stack
docker compose up -d

# Status and health
docker compose ps
Invoke-RestMethod http://localhost:8787/api/health

# Logs
docker compose logs -f reconx

# Stop without deleting data
docker compose stop

# Start stopped containers
docker compose start
```

`docker compose up -d` is idempotent. Source changes require rebuilding the
frontend, Go binary, and `reconx:local` image before recreating the container.

## Documentation

- [Documentation index](docs/README.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Operations](docs/OPERATIONS.md)
- [Security model](docs/SECURITY.md)
- [Development](docs/DEVELOPMENT.md)
- [Security and build report](SECURITY_BUILD_REPORT.md)
- [Changelog](CHANGELOG.md)

## Security

The runtime image is assembled from the local source tree. The checked-in
Compose configuration uses `pull_policy: never`, publishes the UI on loopback,
does not mount the Docker socket, does not use host networking, and does not
enable privileged mode.

The security audit covers the reported Docker backdoor indicators and the
reviewed authentication boundary. It is not a cryptographic proof for every
transitive dependency. Read [docs/SECURITY.md](docs/SECURITY.md) and the
[security and build report](SECURITY_BUILD_REPORT.md) before deployment.

## Project lineage and license

RECONX is a local derivative of the open-source V-ARTEX project created by
hypnguyen1209 and its contributors. Original copyright and attribution are
retained. RECONX is distributed under the GNU Affero General Public License
v3.0; see [LICENSE](LICENSE).

Some internal paths, environment variables, database names, and serialized
keys intentionally retain legacy names for compatibility. They are documented
in [Development](docs/DEVELOPMENT.md) and must not be renamed without a
separate migration.
