#!/usr/bin/env bash
set -euo pipefail

ROOT="${AVATAR_SYSTEM_ROOT:-/scratch/e1554543/avatar_system_full}"
HOST="${AVAMERG_WORKER_HOST:-127.0.0.1}"
PORT="${AVAMERG_WORKER_PORT:-8789}"

export HF_HOME="${HF_HOME:-$ROOT/runtime/cache/hf}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$ROOT/runtime/cache/xdg}"
export MODELSCOPE_CACHE="${MODELSCOPE_CACHE:-$ROOT/runtime/cache/modelscope}"
export TOKENIZERS_PARALLELISM="${TOKENIZERS_PARALLELISM:-false}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-1}"
export NUMEXPR_NUM_THREADS="${NUMEXPR_NUM_THREADS:-1}"

mkdir -p "$HF_HOME" "$XDG_CACHE_HOME" "$MODELSCOPE_CACHE"

cmd="
export PYTHONPATH='$ROOT/integrations/avamerg/merg_code:$ROOT/integrations/avamerg':\$PYTHONPATH
cd '$ROOT/integrations/avamerg'
'$ROOT/integrations/avamerg/.avamerg38/bin/python' avamerg_worker.py \
  --host '$HOST' \
  --port '$PORT'
"

APPTAINER_FLAGS="${APPTAINER_FLAGS:---nv}"

exec apptainer exec $APPTAINER_FLAGS \
  -B /scratch:/scratch,/home/svu:/home/svu \
  "$ROOT/runtime/containers/gaussianav_jammy" \
  bash -lc "$cmd"
