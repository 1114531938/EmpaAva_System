#!/usr/bin/env bash
set -euo pipefail

ROOT="${AVATAR_SYSTEM_ROOT:-/scratch/e1554543/avatar_system_full}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-7861}"

export HF_HOME="${HF_HOME:-$ROOT/runtime/cache/hf}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$ROOT/runtime/cache/xdg}"
export MODELSCOPE_CACHE="${MODELSCOPE_CACHE:-$ROOT/runtime/cache/modelscope}"
export NLTK_DATA="${NLTK_DATA:-$ROOT/runtime/cache/nltk_data}"

mkdir -p "$HF_HOME" "$XDG_CACHE_HOME" "$MODELSCOPE_CACHE" "$NLTK_DATA" "$ROOT/runtime/outputs"

cd "$ROOT"
exec "$ROOT/web_app/.web_venv/bin/python" -m uvicorn apps.web.server:app --host "$HOST" --port "$PORT"
