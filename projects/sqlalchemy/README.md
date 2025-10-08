# SQLAlchemy example

This folder contains a minimal SQLAlchemy example used with Atlas. The README lists quick setup steps and the Atlas commands commonly used for generating migration files for different dialects.

Prerequisites
- Python.
- `atlas` CLI available on your PATH.

Quick setup

1. Create and activate a virtual environment inside the project:

```bash
python -m venv .venv
source .venv/bin/activate
```

2. Install Python dependencies from the provided `requirements.txt`:

```bash
pip install -r requirements.txt
```

Running Atlas migrate diffs

From this directory you can run Atlas to generate migration files for different dialects using the `atlas migrate diff` command. Examples:

```bash
# Migration for ClickHouse
atlas migrate diff --env sqlalchemy --var dialect=clickhouse

# Migration for PostgreSQL
atlas migrate diff --env sqlalchemy --var dialect=postgresql
```
