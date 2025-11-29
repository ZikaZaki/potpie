# Docker Development Setup for Potpie

This guide explains how to run Potpie locally using Docker Compose. This setup containerizes all services (backend, frontend, databases) for easy deployment and development.

## Prerequisites

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later (included with Docker Desktop)
- **Git**: For cloning the repository
- **LLM API Key**: OpenAI, Anthropic, or another supported provider

## Quick Start

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/ZikaZaki/potpie.git
cd potpie
```

If you already cloned without submodules:
```bash
git submodule update --init --recursive
```

### 2. Configure Environment Variables

**Backend Configuration:**
```bash
cp .env.docker.example .env.docker
```

Edit `.env.docker` and set your LLM API key:
```env
OPENAI_API_KEY=sk-your-api-key-here
```

**Frontend Configuration:**
```bash
cp potpie-ui/.env.docker.example potpie-ui/.env.docker
```

The frontend defaults work for local development - no changes needed.

### 3. Start All Services

```bash
docker compose up -d
```

This will:
- Pull/build all necessary images
- Start PostgreSQL, Neo4j, and Redis
- Build and start the backend API
- Start the Celery worker for background tasks
- Build and start the frontend

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001
- **API Documentation**: http://localhost:8001/docs
- **Neo4j Browser**: http://localhost:7474 (user: neo4j, password: mysecretpassword)

## Service Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                           │
│                                                                 │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐       │
│  │  Frontend   │────▶│   Backend   │────▶│  PostgreSQL │       │
│  │  (Next.js)  │     │  (FastAPI)  │     │             │       │
│  │  :3000      │     │  :8001      │     │  :5432      │       │
│  └─────────────┘     └──────┬──────┘     └─────────────┘       │
│                             │                                   │
│                             │            ┌─────────────┐       │
│                             ├───────────▶│    Neo4j    │       │
│                             │            │  :7474/7687 │       │
│  ┌─────────────┐            │            └─────────────┘       │
│  │   Celery    │◀───────────┤                                  │
│  │   Worker    │            │            ┌─────────────┐       │
│  └─────────────┘            └───────────▶│    Redis    │       │
│                                          │  :6379      │       │
│                                          └─────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

## Common Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f celery-worker
docker compose logs -f frontend
```

### Rebuild After Code Changes
```bash
# Rebuild and restart all
docker compose up -d --build

# Rebuild specific service
docker compose up -d --build backend
```

### Stop Services
```bash
# Stop all services (preserves data)
docker compose down

# Stop and remove all data
docker compose down -v
```

### Shell Access
```bash
# Backend shell
docker compose exec backend bash

# Run migrations manually
docker compose exec backend alembic upgrade heads

# Access PostgreSQL
docker compose exec postgres psql -U postgres -d momentum
```

## Configuration Reference

### LLM Providers

The backend supports multiple LLM providers through LiteLLM:

**OpenAI:**
```env
OPENAI_API_KEY=sk-...
INFERENCE_MODEL=openai/gpt-4.1-mini
CHAT_MODEL=openai/gpt-4o
```

**Anthropic:**
```env
ANTHROPIC_API_KEY=sk-ant-...
INFERENCE_MODEL=anthropic/claude-3-sonnet-20240229
CHAT_MODEL=anthropic/claude-3-opus-20240229
```

**Local Ollama:**
```env
OLLAMA_API_KEY=ollama
LLM_API_BASE=http://host.docker.internal:11434
INFERENCE_MODEL=ollama_chat/qwen2.5-coder:7b
CHAT_MODEL=ollama_chat/qwen2.5-coder:7b
```

### GitHub Integration

For repository analysis:
```env
CODE_PROVIDER=github
GH_TOKEN_LIST=ghp_your_token_here
```

### Local Repository Analysis

To analyze local repositories:

1. Mount the repository in docker-compose.yml:
```yaml
backend:
  volumes:
    - /path/to/your/repos:/app/local-repos
```

2. Configure environment:
```env
CODE_PROVIDER=local
CODE_PROVIDER_BASE_URL=/app/local-repos/your-repo
```

## Troubleshooting

### Services Not Starting

Check if all services are healthy:
```bash
docker compose ps
```

View startup logs:
```bash
docker compose logs backend
```

### Database Connection Issues

Wait for databases to be ready:
```bash
# Check PostgreSQL
docker compose exec postgres pg_isready -U postgres

# Check Neo4j
curl http://localhost:7474
```

### Memory Issues

If containers are being killed, increase Docker memory limits in Docker Desktop settings.

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Changed from 3000:3000
```

## Development Workflow

### Hot Reload

- **Frontend**: Changes to `potpie-ui/` are automatically detected with hot reload
- **Backend**: For code changes, rebuild: `docker compose up -d --build backend`

### Database Migrations

After model changes:
```bash
# Generate new migration
docker compose exec backend alembic revision --autogenerate -m "description"

# Apply migrations
docker compose exec backend alembic upgrade heads
```

### Running Tests

```bash
# Backend tests
docker compose exec backend pytest tests/

# Frontend lint
docker compose exec frontend pnpm lint
```

## Production Deployment

For production deployments, consider:

1. Using managed database services (RDS, Cloud SQL)
2. Setting up proper SSL/TLS certificates
3. Configuring environment-specific variables
4. Using container orchestration (Kubernetes, ECS)
5. Setting up monitoring and logging

See the `deployment/` directory for production configuration examples.
