# TradingAgents-CN — Agent Guide

Multi-agent stock analysis platform (A-share/HK/US markets). Fork of
[TauricResearch/TradingAgents](https://github.com/TauricResearch/TradingAgents) with
Chinese-market enhancements, FastAPI + Vue 3 frontend, and Docker deployment.

**Version**: v1.0.1  **Python**: >=3.10  **Node**: >=18

---

## Repository map

```
main.py                     # Minimal CLI demo: TradingAgentsGraph("NVDA", "2024-05-10")
app/                        # 【PROPRIETARY】FastAPI backend (port 8000)
  main.py                   #   App entry: FastAPI app, CORS, all routers
  routers/                  #   37 route files (auth, analysis, stocks, config, sync, etc.)
  services/                 #   Business logic (data sources, sync, scheduler)
  worker/                   #   Background sync workers (Tushare, AKShare, Baostock)
  core/                     #   Config, database init, logging setup
tradingagents/              # 【APACHE 2.0】Core multi-agent framework
  graph/                    #   LangGraph pipeline: TradingAgentsGraph
  agents/                   #   Agent definitions (analysts, researchers, managers, trader)
  llm_clients/              #   LLM provider adapters (OpenAI, Google, Anthropic, Dashscope, ...)
  dataflows/                #   Data sources (AKShare, Tushare, Baostock, FinnHub, yfinance, cache)
  tools/                    #   Analysis tool implementations
frontend/                   # 【PROPRIETARY】Vue 3 + Element Plus SPA (port 3000)
cli/                        # Typer + Rich interactive CLI for stock analysis
web/                        # Streamlit web UI (legacy, port 8501)
config/                     # Logging config (logging.toml, logging_docker.toml)
tests/                      # pytest suite
```

## Entry points

| Mode | Command | Notes |
|------|---------|-------|
| FastAPI backend | `uvicorn app.main:app` or `python -m app` | Port 8000 |
| Frontend dev | `cd frontend && npm run dev` | Port 3000 |
| Frontend build | `cd frontend && npm run build` | Builds to `dist/`, skipped in Docker build |
| Streamlit UI | `streamlit run web/app.py` | Port 8501, legacy |
| CLI | `python -m cli.main` or `tradingagents` | Typer-based interactive analysis |
| Core graph demo | `python main.py` | Runs TradingAgentsGraph with hardcoded symbols |

## Environment

Copy `.env.example` → `.env`. At minimum set:
- One LLM API key (recommended: `DEEPSEEK_API_KEY` or `DASHSCOPE_API_KEY`)
- `MONGODB_*` and `REDIS_*` connection strings

For Docker: use `.env.docker` and `docker-compose.yml`.

## Database

MongoDB + Redis are **required** for the FastAPI backend. The core
`TradingAgentsGraph` (from `tradingagents/`) can function without them in
standalone CLI mode.

## Commands

### Python
```bash
# Install the package in dev mode (required for imports)
pip install -e .

# Install from lockfile
pip install -r requirements-lock.txt

# Run tests (pytest, skips integration by default)
pytest

# Run integration tests
pytest -m integration

# Run a single test file
python -m pytest tests/unit/test_stocks_kline_news_api.py -v

# Run as script (tests/ dir is in sys.path via conftest.py)
cd tests && python test_chinese_output.py
```

### Docker
```bash
# Full stack (backend + frontend + MongoDB + Redis)
docker compose up -d

# Hub + nginx variant
docker compose -f docker-compose.hub.nginx.yml up -d
```

Multi-arch images (amd64 + arm64) are built on tag-push via CI.

### Frontend
```bash
cd frontend
npm install
npm run dev        # development server
npm run build      # production build (runs vue-tsc + vite build)
npm run lint       # ESLint fix
npm run format     # Prettier format
npm run type-check # TypeScript type check only
```

## Testing

- **Framework**: pytest (no config in pyproject.toml — uses `tests/pytest.ini`)
- **Default**: `pytest` skips integration tests (`-m "not integration"`)
- **Unit tests**: `tests/unit/` — use `FastAPI.TestClient` with `unittest.mock.patch`
- **Integration tests**: `tests/integration/` — require live API keys
- **No tox/nox, no coverage config** found

### Test pattern (unit)
Tests build a minimal FastAPI app with only the router under test and override
auth dependency, avoiding the full app lifespan. See
`tests/unit/test_stocks_kline_news_api.py`:

```python
def create_test_app():
    app = FastAPI()
    app.include_router(stocks_router.router, prefix="/api")
    app.dependency_overrides[get_current_user] = lambda: {...}
    return app

@pytest.fixture()
def client():
    with TestClient(create_test_app()) as c:
        yield c
```

## Key architecture facts

1. **Dual-license**: `app/` and `frontend/` are proprietary (need commercial
   license). Everything else is Apache 2.0.
2. **Multi-agent pipeline**: `TradingAgentsGraph` (LangGraph) orchestrates
   analysts → researchers → risk debators → trader.
3. **LLM providers**: 9+ supported (OpenAI, Google, Anthropic, Dashscope,
   DeepSeek, SiliconFlow, OpenRouter, AiHubMix, Qianfan, custom endpoints).
   Adapters in `tradingagents/llm_clients/`.
4. **Data sources**: AKShare (default), Tushare, Baostock for A-shares;
   FinnHub, yfinance for US/HK. Configured via `DEFAULT_CHINA_DATA_SOURCE` env.
5. **Logging**: TOML-driven (`config/logging.toml`). Logs go to `./logs/`.
   Docker env auto-detected (stdout-only).
6. **3-way user interface**: FastAPI backend + Vue 3 frontend (new), Streamlit
   (legacy), Typer CLI.
7. **CI**: Docker publish on tag push (no test step in CI). Weekly upstream
   sync check from TauricResearch/TradingAgents.

## Gotchas

- `pip install -e .` is **required** before running any module — the package
  structure expects `tradingagents` installed.
- Tests use `conftest.py` to add project root to `sys.path` — run `pytest`
  from root.
- `.env` must be at project root for local dev; `.env.docker` for containers.
- Windows: file watcher issue — `.streamlit/config.toml` sets
  `fileWatcherType = "none"`.
- LLM provider normalization is handled by
  `tradingagents/llm_clients/provider_keys.py` — when adding a new provider,
  register it there.
- `requirements-lock.txt` is a pip freeze snapshot (Python 3.10.8,
  2025-10-21) — use `pip install -e .` for actual dependency resolution.
- The `config/` directory is Docker-volume-mounted — runtime changes persist
  across container restarts.
- `reports/` directory contains analysis logs/notes, not generated reports.
- `utils/` has standalone scripts for version checks and data config — not a
  package.
