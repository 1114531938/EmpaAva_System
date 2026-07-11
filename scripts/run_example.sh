#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
set -a; source .env; set +a
mkdir -p runtime/outputs/example
if [[ "${EMPAAVA_MODE:-mock}" == "mock" ]]; then
  cp examples/expected/mock_manifest.json runtime/outputs/example/manifest.json
  echo "[PASS] mock API/UI sample written to runtime/outputs/example/manifest.json"
  echo "[WARN] This is not EmpaAva model inference. Use full mode for the complete pipeline."
  exit 0
fi
export AVATAR_SYSTEM_ROOT="$ROOT" EMPAAVA_SEED="${EMPAAVA_SEED:-42}"
exec bash scripts/avatar.sh agent examples/inputs/sample.wav 306 --input_video examples/inputs/sample.mp4
