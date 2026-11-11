# Development

## Repository layout

| Path | Purpose |
| --- | --- |
| `agent/` | Agent orchestration and provider behavior |
| `cmd/artex/` | Go command entry point and doctor command |
| `db/` | PostgreSQL schema and persistence |
| `server/` | HTTP API, authentication, settings, and embedded UI serving |
| `sidequestion/` | `/btw` context snapshots and bounded side-question service |
| `skills/` | Filesystem-backed agent skills |
| `web/` | Next.js frontend |
| `dist/` | Locally built binaries and ignored build output |
| `data/` | Ignored local runtime data |
| `docs/` | Current RECONX documentation |

## Development loop

Backend:

```powershell
go test ./config ./selfupdate ./notify
go test ./server
go run ./cmd/artex
```

Frontend:

```powershell
Set-Location web
npm ci --ignore-scripts
npm test
npm run check
npm run dev
```

Production-style embedded build:

```powershell
Set-Location D:\RECONX\web
$env:NEXT_EXPORT = "1"
npm run build

Set-Location D:\RECONX
New-Item -ItemType Directory -Force server\webui\dist | Out-Null
Copy-Item -Path web\out\* -Destination server\webui\dist -Recurse -Force
$env:CGO_ENABLED = "0"
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go build -tags embedui -trimpath -o dist\amd64\reconx ./cmd/artex
```

Run `npm ci` with lifecycle scripts disabled for the reviewed supply-chain
path. Do not update dependencies as part of a branding, documentation, or
unrelated bug-fix change.

## Compatibility identifiers

The user-visible product is RECONX. The following internal identifiers remain
for compatibility with existing databases, volumes, imports, and persisted
settings:

- Go module path and `cmd/artex` package path.
- `ARTEX_*` environment variables.
- `POSTGRES_USER`, `POSTGRES_DB`, and default database identifiers in the local
  Compose configuration.
- Stored JWT subject and legacy storage/cookie keys.
- Existing migration and serialized setting identifiers.

Do not perform a blind rename. A compatibility change requires a migration,
rollback plan, and persistence verification.

## Change discipline

- Keep changes within the requested product, security, or operational scope.
- Preserve planner, worker, MCP, traffic, evidence, and reporting behavior unless
  the task explicitly changes them.
- Update documentation in the same change when commands, defaults, model IDs,
  security boundaries, or persisted identifiers change.
- Build from local source and confirm `docker compose ps` remains healthy.
- Do not commit or push unless explicitly requested.
- Never add a real API key, database password, or setup token to a fixture.

## Validation checklist

```powershell
go mod verify
cd web
npm test
npm run check
cd ..
docker compose ps
Invoke-RestMethod http://localhost:8787/api/health
docker image inspect reconx:local --format '{{.Id}} {{.Created}}'
```

The security report is the authoritative record of audit limitations and
runtime evidence for the current local build.
