#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "[FAIL] setup stopped at line $1 while running: $2" >&2
  echo "Fix: review the error above, then rerun: bash scripts/setup.sh" >&2
}
trap 'fail "$LINENO" "$BASH_COMMAND"' ERR

PYTHON="${PYTHON:-python3}"
command -v "$PYTHON" >/dev/null || { echo "[FAIL] python3 not found. Ubuntu fix: sudo apt-get install -y python3 python3-venv python3-pip" >&2; exit 1; }
"$PYTHON" -c 'import sys; assert sys.version_info >= (3,10)' || { echo "[FAIL] Python >=3.10 is required for the web/mock environment." >&2; exit 1; }
if [[ ! -f .env ]]; then cp .env.example .env; echo "[INFO] created .env from .env.example"; fi
mkdir -p runtime/{cache/downloads,logs,pids,models,outputs}
if [[ ! -x .venv/bin/python ]]; then
  "$PYTHON" -m venv .venv || { echo "[FAIL] venv creation failed. Ubuntu fix: sudo apt-get install -y python3-venv" >&2; exit 1; }
fi
.venv/bin/python -m pip install --upgrade pip setuptools wheel
.venv/bin/python -m pip install -r requirements.txt || { echo "[FAIL] Python dependency installation failed. Check network/proxy, then run: .venv/bin/python -m pip install -r requirements.txt" >&2; exit 1; }
echo "[PASS] setup complete (idempotent). For full CUDA inference: bash scripts/download_models.sh --accept-licenses"
