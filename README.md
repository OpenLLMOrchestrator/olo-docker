# OLO Docker Stack

This repository provides Docker Compose setups to bring up the OLO stack in three environments: **dev**, **prod**, and **demo**. Each environment has its own folder with a `docker-compose.yml` and install scripts. You can bring up a stack from the repository root (with an optional folder argument) or from inside each folder.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [Bringing Up the Stack](#bringing-up-the-stack)
- [Environment Details](#environment-details)
- [Production Setup (.env)](#production-setup-env)
- [Manual Docker Compose Commands](#manual-docker-compose-commands)
- [Ports and Services](#ports-and-services)
- [Dev stack — Web UIs and URLs](#dev-stack--web-uis-and-urls)
- [Dev stack — Internal hostnames and URLs (worker/config)](#dev-stack--internal-hostnames-and-urls-workerconfig)
- [Stopping the Stack](#stopping-the-stack)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before bringing up any stack, ensure you have:

1. **Docker Engine**  
   - Install [Docker Desktop](https://docs.docker.com/get-docker/) (Windows/macOS) or [Docker Engine](https://docs.docker.com/engine/install/) (Linux).  
   - Verify: `docker --version`

2. **Docker Compose**  
   - Usually included with Docker Desktop. For Linux, install the [Compose plugin](https://docs.docker.com/compose/install/).  
   - Verify: `docker compose version`

3. **App image (optional for first run)**  
   - Compose files use `your-app:latest` for the app service. Build or pull your app image, or update the `image` in each `docker-compose.yml` to match your image name.

---

## Repository Structure

```
olo-docker/
├── README.md                 # This file
├── install.sh                # Root install script (default: demo)
├── install.bat               # Root install script for Windows (default: demo)
├── dev/
│   ├── docker-compose.yml    # Development stack
│   ├── install.sh            # Bring up dev stack (Unix/macOS)
│   └── install.bat           # Bring up dev stack (Windows)
├── prod/
│   ├── docker-compose.yml    # Production stack
│   ├── .env.example          # Template for production .env
│   ├── install.sh            # Bring up prod stack (Unix/macOS)
│   └── install.bat           # Bring up prod stack (Windows)
└── demo/
    ├── docker-compose.yml    # Demo stack
    ├── install.sh            # Bring up demo stack (Unix/macOS)
    └── install.bat           # Bring up demo stack (Windows)
```

---

## Quick Start

**From the repository root (default is demo):**

- **Linux/macOS:**  
  `./install.sh`  
  Or with a folder: `./install.sh dev` | `./install.sh prod` | `./install.sh demo`

- **Windows (Command Prompt or PowerShell):**  
  `install.bat`  
  Or: `install.bat dev` | `install.bat prod` | `install.bat demo`

**From inside a folder:**

- **Linux/macOS:**  
  `cd dev` (or `prod` or `demo`), then `./install.sh`

- **Windows:**  
  `cd dev` (or `prod` or `demo`), then `install.bat`

**Production:** Before running prod, create `prod/.env` from `prod/.env.example` and set at least `POSTGRES_PASSWORD`. See [Production Setup (.env)](#production-setup-env).

---

## Bringing Up the Stack

### Step 1: Clone or open the repository

```bash
cd /path/to/olo-docker
```

### Step 2: Choose how to run the install

You can either use the **root install scripts** (recommended) or the **per-folder** scripts.

#### Option A — From root (recommended)

- **Default stack (demo):**  
  - Unix/macOS: `./install.sh` (make executable once: `chmod +x install.sh`)  
  - Windows: `install.bat`

- **Specific stack:**  
  - Unix/macOS: `./install.sh dev` or `./install.sh prod` or `./install.sh demo`  
  - Windows: `install.bat dev` or `install.bat prod` or `install.bat demo`

The root script checks that the argument is `dev`, `prod`, or `demo`; if you omit the argument, it uses **demo**.

#### Option B — From inside each folder

1. **Dev:**  
   - `cd dev`  
   - Unix/macOS: `./install.sh`  
   - Windows: `install.bat`

2. **Prod:**  
   - Ensure `prod/.env` exists (see [Production Setup (.env)](#production-setup-env)).  
   - `cd prod`  
   - Unix/macOS: `./install.sh`  
   - Windows: `install.bat`

3. **Demo:**  
   - `cd demo`  
   - Unix/macOS: `./install.sh`  
   - Windows: `install.bat`

### Step 3: What the install scripts do

Each folder’s install script:

1. Changes into its own directory (so paths in `docker-compose.yml` resolve correctly).
2. Runs `docker compose up -d` to start the stack in detached mode.

The **prod** scripts additionally check for the presence of `prod/.env`; if it is missing, they print a warning and exit without starting the stack.

### Step 4: Verify

- Run `docker ps` and confirm containers for the chosen environment (e.g. `olo-app-demo`, `olo-db-demo` for demo).
- App: typically http://localhost:3000 (see [Ports and Services](#ports-and-services)).
- For dev/demo, the database is exposed on the host; for prod it is internal only.

---

## Environment Details

| Aspect        | dev                          | prod                                    | demo                          |
|---------------|------------------------------|-----------------------------------------|-------------------------------|
| **Purpose**   | Local development            | Production deployment                   | Demos / staging               |
| **App env**   | `NODE_ENV=development`       | `NODE_ENV=production`                   | `NODE_ENV=demo`, `DEMO_MODE=true` |
| **Debug**     | `DEBUG=true`, `LOG_LEVEL=debug` | `DEBUG=false`, `LOG_LEVEL=info`      | `DEBUG=false`, `LOG_LEVEL=info` |
| **Restart**   | `unless-stopped`             | `always`                                | `unless-stopped`              |
| **App volume**| `../src` mounted into app    | None                                    | None                          |
| **DB on host**| Yes (5432)                   | No (internal only)                      | Yes (5433)                    |
| **DB credentials** | Fixed (dev/dev)         | From `.env`                             | Fixed (demo/demo)             |

- **dev:** Best for day-to-day coding; app can use the mounted `../src` for live reload. Database is on port 5432.
- **prod:** Uses `.env` for secrets; database is not exposed on the host. Set a strong `POSTGRES_PASSWORD` in `prod/.env`.
- **demo:** Fixed credentials and DB on port 5433 so it can run alongside dev without port conflicts.

---

## Production Setup (.env)

The **prod** stack reads database credentials from environment variables. The install scripts expect a `.env` file in the `prod` folder.

### Steps for production

1. Go to the `prod` folder:
   ```bash
   cd prod
   ```

2. Copy the example file:
   ```bash
   cp .env.example .env
   ```
   (Windows: `copy .env.example .env`)

3. Edit `.env` and set at least:
   - `POSTGRES_PASSWORD` — use a strong, unique password.  
   You can also override:
   - `POSTGRES_USER` (default: `prod`)
   - `POSTGRES_DB` (default: `olo_prod`)

4. Do not commit `.env` to version control. Ensure `.env` is in `.gitignore`.

5. Run the prod install from root or from `prod`:
   - Root: `./install.sh prod` or `install.bat prod`
   - From `prod`: `./install.sh` or `install.bat`

---

## Manual Docker Compose Commands

If you prefer not to use the install scripts:

**Dev:**
```bash
cd dev
docker compose up -d
```

**Prod (from repo root, with .env in prod/):**
```bash
cd prod
docker compose --env-file .env up -d
```

**Demo:**
```bash
cd demo
docker compose up -d
```

Or from the repository root without changing directory:

```bash
docker compose -f dev/docker-compose.yml up -d
docker compose -f prod/docker-compose.yml --env-file prod/.env up -d
docker compose -f demo/docker-compose.yml up -d
```

---

## Ports and Services

| Service | dev    | prod   | demo   |
|---------|--------|--------|--------|
| **App** | 3000   | 3000   | 3000   |
| **DB**  | 5432   | (none) | 5433   |

- Only one of dev/demo should use the app port 3000 at a time if you run them on the same machine (or change the host port in the corresponding `docker-compose.yml`).
- Dev and demo use different DB host ports (5432 vs 5433) so they can run simultaneously.
- Prod does not publish the database port; the app connects via the internal Docker network.

---

## Dev stack — Web UIs and URLs

When you bring up the **full dev stack** from `dev/` (e.g. `install.bat dev` or `./install.sh dev`), these web UIs and APIs are available on the host:

| Service | URL | Description |
|---------|-----|-------------|
| **Qdrant** | http://localhost:6333/dashboard | Vector DB UI (e.g. http://localhost:6333/dashboard#/welcome) |
| **Temporal UI** | http://localhost:8092 | Workflow UI |
| **pgAdmin** | http://localhost:8081 | PostgreSQL admin (default login from `database.env`, e.g. admin@admin.com / admin) |
| **Kibana** | http://localhost:5601 | Elasticsearch UI |
| **Redis Insight** | http://localhost:5540 | Redis UI |
| **Elasticsearch** | http://localhost:9200 | Elasticsearch REST API |
| **App** | http://localhost:3000 | Dev app (when run with `--profile app`) |
| **AI Text (LocalAI)** | http://localhost:8090 | OpenAI-compatible API (text) |
| **AI Text (Ollama)** | http://localhost:11434 | Ollama API |
| **AI Audio (LocalAI)** | http://localhost:8082 | TTS/STT API |
| **Stable Diffusion** | http://localhost:7860 | Image generation UI |
| **InvokeAI** | http://localhost:9090 | Image generation UI |
| **ComfyUI (image)** | http://localhost:8188 | ComfyUI image workflows |
| **ComfyUI (video)** | http://localhost:8189 | ComfyUI video workflows |

- **Redis** is available at `localhost:6379` (no web UI; use Redis Insight above).
- **PostgreSQL** is at `localhost:5432` (use pgAdmin or any client; credentials from `dev/configuration/envirinment/database.env`).

---

## Dev stack — Internal hostnames and URLs (worker/config)

Use these **internal** hostnames and URLs when configuring services that run inside the same Docker network (e.g. **olo-worker**, olo API, or custom containers). On `olo-net`, containers resolve each other by **service name** (Compose service key), not by container name.

| Container name           | Service name (hostname) | Internal URL / endpoint        | Use in config (e.g. worker)      |
|--------------------------|-------------------------|---------------------------------|-----------------------------------|
| olo-api                  | **olo**                 | http://olo:7080                 | OLO API base URL, callbacks       |
| olo-worker               | olo-worker              | —                               | Consumer (uses others below)      |
| olo-ui                   | olo-ui                  | http://olo-ui:80                | UI (if another service links)     |
| olo-chat                 | olo-chat                | http://olo-chat:80              | Chat UI (e.g. VITE_API_BASE)     |
| olo-redis                | **redis**               | redis:6379                      | OLO_CACHE_HOST, OLO_CACHE_PORT    |
| olo-db                   | **db**                  | db:5432                         | OLO_DB_HOST, POSTGRES_SEEDS       |
| olo-elasticsearch        | **elasticsearch**       | http://elasticsearch:9200       | ES_SEEDS, Kibana backend          |
| olo-kibana               | kibana                  | http://kibana:5601              | —                                 |
| olo-temporal             | **temporal**            | temporal:7233                   | TEMPORAL_HOST, OLO_TEMPORAL_TARGET |
| olo-temporal-ui          | temporal-ui             | http://temporal-ui:8080         | —                                 |
| olo-qdrant               | **qdrant**              | http://qdrant:6333              | QDRANT_BASE_URL                   |
| olo-openai-oss           | openai-oss              | http://openai-oss:8080          | OpenAI-compatible text (host 8090)|
| olo-ollama               | **ollama**              | http://ollama:11434             | OLLAMA_BASE_URL                   |
| olo-stable-diffusion      | stable-diffusion         | http://stable-diffusion:7860    | Image generation                  |
| olo-invokeai             | invokeai                | http://invokeai:9090            | Image generation                  |
| olo-comfyui              | comfyui                 | http://comfyui:8188             | ComfyUI image (host 8188)         |
| olo-comfyui-video        | comfyui                 | http://comfyui:8188             | ComfyUI video (host 8189)         |
| olo-openai-oss-audio     | openai-oss              | http://openai-oss:8080          | LocalAI audio (host 8082)         |
| olo-ollama-audio         | ollama                  | http://ollama:11434             | Ollama audio                      |
| olo-pgadmin              | pgadmin                 | http://pgadmin:80               | —                                 |
| olo-redisinsight         | redisinsight            | http://redisinsight:5540        | —                                 |

**Notes:**

- **Bold** service names are the ones commonly referenced in worker/API env (e.g. `OLO_CACHE_HOST=redis`, `OLO_TEMPORAL_TARGET=temporal:7233`, `OLO_DB_HOST=db`, `OLLAMA_BASE_URL=http://ollama:11434`, `QDRANT_BASE_URL=http://qdrant:6333`, `VITE_API_BASE=http://olo:7080` for chat).
- When multiple compose files define the same service name (e.g. **ollama**, **openai-oss**, **comfyui**), the last-loaded file wins; use the hostname for the instance you need (e.g. text vs audio).
- Pipeline config (Temporal target) should use `temporal:7233`; Redis key prefix and tenant IDs are unchanged.

---

## Stopping the Stack

From the same folder you used to start the stack:

```bash
cd dev   # or prod or demo
docker compose down
```

To remove volumes as well (deletes database data for that environment):

```bash
docker compose down -v
```

---

## Customization

- **App image:** Replace `your-app:latest` in each `docker-compose.yml` with your real image name and tag (e.g. `myregistry/olo-app:v1.0`).
- **Dev source path:** The dev compose mounts `../src` into the app. Adjust the volume path if your source code lives elsewhere (e.g. `../myapp/src:/app/src`).
- **Ports:** Change the left side of port mappings (e.g. `"8080:3000"`) if 3000 or 5432/5433 conflict with other services.
- **Resource limits:** In `prod/docker-compose.yml`, uncomment the `deploy.resources` section under the app service to set CPU/memory limits.

---

## Troubleshooting

- **"no such image: your-app:latest"**  
  Build your app image (e.g. `docker build -t your-app:latest .` from your app repo) or change the `image` in the compose file to an image you have.

- **Prod install exits immediately**  
  Create `prod/.env` from `prod/.env.example` and set `POSTGRES_PASSWORD`. The prod install scripts refuse to run without `.env`.

- **Port already in use**  
  Stop the other stack using that port or change the host port in the compose file (e.g. `"3001:3000"` for the app).

- **Permission denied (install.sh)**  
  Run: `chmod +x install.sh` (and `chmod +x dev/install.sh prod/install.sh demo/install.sh` if you use them directly).

- **Containers not starting**  
  Run `docker compose up` without `-d` in the relevant folder to see logs:  
  `cd dev && docker compose up` (then Ctrl+C to stop).

---

## Summary

| Goal                    | Command (root)              | Or from folder   |
|-------------------------|-----------------------------|------------------|
| Bring up demo (default) | `./install.sh` or `install.bat` | `cd demo` → `./install.sh` or `install.bat` |
| Bring up dev            | `./install.sh dev` or `install.bat dev` | `cd dev` → run install |
| Bring up prod           | `./install.sh prod` or `install.bat prod` | Create `prod/.env`, then `cd prod` → run install |

Ensure Docker is installed and running, and for production always set a strong `POSTGRES_PASSWORD` in `prod/.env`.
