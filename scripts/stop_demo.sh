#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
if [[ -f .env ]]; then set -a; source .env; set +a; fi
if [[ "${EMPAAVA_MODE:-mock}" == "full" ]]; then exec bash scripts/avatar.sh service web stop; fi
PIDFILE=runtime/pids/demo.pid
if [[ ! -f "$PIDFILE" ]]; then echo "[PASS] demo already stopped"; exit 0; fi
PID="$(cat "$PIDFILE")"
kill "$PID" 2>/dev/null || true
for _ in {1..20}; do kill -0 "$PID" 2>/dev/null || { rm -f "$PIDFILE"; echo "[PASS] demo stopped"; exit 0; }; sleep .2; done
kill -9 "$PID" 2>/dev/null || true; rm -f "$PIDFILE"; echo "[WARN] demo required SIGKILL"
