#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
[[ -f .env ]] || { echo "[FAIL] .env missing; run: cp .env.example .env" >&2; exit 1; }
set -a; source .env; set +a
export AVATAR_SYSTEM_ROOT="$ROOT" PROJECT_ROOT="$ROOT"
MODE="${EMPAAVA_MODE:-mock}"
if [[ "$MODE" == "full" ]]; then
  python3 scripts/check_env.py
  exec bash scripts/avatar.sh service web start
fi
[[ -x .venv/bin/python ]] || { echo "[FAIL] Run bash scripts/setup.sh first." >&2; exit 1; }
mkdir -p runtime/logs runtime/pids
PIDFILE=runtime/pids/demo.pid
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then echo "[PASS] demo already running (PID $(cat "$PIDFILE"))"; exit 0; fi
nohup .venv/bin/python -m uvicorn apps.web.server:app --host "${HOST:-127.0.0.1}" --port "${PORT:-7861}" >runtime/logs/demo.log 2>&1 &
echo $! >"$PIDFILE"
for _ in {1..30}; do curl -fsS "http://${HOST:-127.0.0.1}:${PORT:-7861}/" >/dev/null 2>&1 && { echo "[PASS] mock demo: http://${HOST:-127.0.0.1}:${PORT:-7861}/ (not full inference)"; exit 0; }; sleep 1; done
echo "[FAIL] demo did not become ready; inspect runtime/logs/demo.log" >&2; exit 1
