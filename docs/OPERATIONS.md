# Operations

## Prerequisites

- Docker Desktop with Docker Compose.
- Go 1.26.3 or newer.
- Node.js 20 or newer.
- npm.
- A PostgreSQL password in `.env`.
- A 9Router key in the existing LLM profile store or `OPENAI_API_KEY`.

Do not use `install.sh`, `update.sh`, or a prebuilt V-ARTEX image for this
distribution.

## Initial configuration

```powershell
Set-Location D:\RECONX
Copy-Item .env.example .env
```

Set at least:

```dotenv
POSTGRES_PASSWORD=<local-database-password>
RECONX_BIND=127.0.0.1
RECONX_PORT=8787
```

For the environment-provided default profile:

```dotenv
OPENAI_API_KEY=<9router-key>
ARTEX_LLM_PROVIDER=openai
ARTEX_LLM_MODEL=ocg/deepseek-v4.1-flash
ARTEX_LLM_BASE_URL=https://9router.dinhvaren.io.vn/v1
```

The ignored `.env` can contain secrets. Never commit or copy it into the image.

## Build from source

```powershell
Set-Location D:\RECONX\web
npm ci --ignore-scripts
npm test
$env:NEXT_EXPORT = "1"
npm run build

Set-Location D:\RECONX
New-Item -ItemType Directory -Force server\webui\dist | Out-Null
Copy-Item -Path web\out\* -Destination server\webui\dist -Recurse -Force

$env:CGO_ENABLED = "0"
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go mod verify
go build -tags embedui -trimpath -o dist\amd64\reconx ./cmd/artex

docker build --build-arg TARGETARCH=amd64 -t reconx:local .
```

The build order is intentional: static UI, embedded Go binary, then Docker
image. Building only the image does not rebuild either source artifact.

## Normal lifecycle

```powershell
# Create or reconcile containers
docker compose up -d

# Status
docker compose ps
docker compose images

# Health
Invoke-RestMethod http://localhost:8787/api/health

# Follow logs
docker compose logs -f reconx

# Stop and resume without deleting data
docker compose stop
docker compose start
```

`restart: unless-stopped` allows the stack to return after Docker Desktop
restarts. `up -d` is safe to run repeatedly.

## Rebuild after source changes

1. Rebuild the static frontend.
2. Copy `web/out` into `server/webui/dist`.
3. Build the Linux `reconx` binary with `-tags embedui`.
4. Build `reconx:local`.
5. Run `docker compose up -d` so Compose recreates the application container.

Do not use `docker compose up --build` as a substitute: the audited Dockerfile
packages an already-built local binary.

## First-run setup

If authentication has not been initialized, retrieve the one-time setup token:

```powershell
docker compose logs reconx
```

Open `/setup`, enter the token, and create the administrator password. Do not
set a token or password in source or publish it in logs.

## LLM profiles and 9Router

Open `http://localhost:<port>/system/llm` and use the existing profile screen.

Current base URL:

```text
https://9router.dinhvaren.io.vn/v1
```

Current model IDs:

| Profile | Model ID |
| --- | --- |
| DeepSeek V4.1 Flash | `ocg/deepseek-v4.1-flash` |
| MiniMax M3.1 Flash | `ocg/minimax-m3.1-flash` |
| GLM 5.3 Flash | `ocg/glm-5.3-flash` |
| Kimi K3.1 Pro | `ocg/kimi-k3.1-pro` |

Use the model-refresh button after changing gateway credentials. Select only
IDs returned by `/v1/models`; do not add a guessed prefix. The current profile
names and IDs already match the gateway.

Test one profile with a minimal prompt, then save. The running service
hot-reloads the active configuration. Do not run an unbounded agent task as a
connection test.

Diagnostics without printing the key:

```powershell
docker compose logs --tail 100 reconx | Select-String 'llm-test|LLM configured|built provider'
docker exec reconx-postgres-1 psql -U artex -d artex -P pager=off `
  -c "select id,name,model,base_url,is_default,(api_key <> '') as has_key from llm_profiles order by id;"
```

Replace `artex` in the example if `POSTGRES_USER` was changed; the default
shipped in `.env.example` remains a legacy compatibility value. Avoid
displaying the secret itself.

## Port conflicts

The default host URL is `http://localhost:8787`. If Windows reserves that port,
set another loopback port in `.env`:

```dotenv
RECONX_PORT=18787
```

Then recreate the application container:

```powershell
docker compose up -d reconx
```

The current local deployment uses `18787` because the Windows host reserves
the `8702-8801` range.

## Backup

Back up all persistent state together:

- PostgreSQL logical dump or `pgdata` volume.
- `jwtkeys` volume.
- Host `./data` directory.
- Host `./skills` directory.
- Local `.env` with secrets stored securely and separately from source control.

Example logical PostgreSQL backup:

```powershell
docker compose exec -T postgres sh -lc 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f /tmp/reconx.dump'
docker cp reconx-postgres-1:/tmp/reconx.dump .\reconx-postgres.dump
docker compose exec -T postgres rm -f /tmp/reconx.dump
```

Stop the service before making filesystem-level backups of volumes or host
data. Do not remove volumes during restart, update, or troubleshooting.

## Troubleshooting

### Containers are not running

```powershell
docker desktop status
docker compose ps -a
docker compose logs --tail 200 postgres reconx
```

If PostgreSQL was still starting when RECONX launched, the application retries
startup. Confirm both services become healthy.

### UI is unreachable

- Confirm `docker compose ps` reports the application healthy.
- Verify `RECONX_BIND` remains `127.0.0.1`.
- Verify the actual published port from `docker compose ps`.
- Test `/api/health` directly.

### LLM shows no key or fails

- Confirm the profile has a stored key or `OPENAI_API_KEY` is available.
- Confirm profile-level keys take precedence over `.env`.
- Confirm the base URL ends in `/v1` and not `/chat/completions`.
- Confirm the model ID is returned by `/v1/models`.
- Inspect only sanitized connection status and latency; do not log the key or
  complete bearer header.
