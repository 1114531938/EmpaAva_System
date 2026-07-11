#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACCEPT=0
[[ "${1:-}" == "--accept-licenses" ]] && ACCEPT=1
if [[ "$ACCEPT" != 1 ]]; then
  echo "Model inventory: $ROOT/models/manifest.json"
  echo "[FAIL] Runtime bundle has mixed third-party terms. Read THIRD_PARTY_LICENSES.md, then rerun:" >&2
  echo "  bash scripts/download_models.sh --accept-licenses" >&2
  exit 2
fi
export AVATAR_RUNTIME_DOWNLOAD_DIR="${EMPAAVA_CACHE_DIR:-$ROOT/runtime/cache/downloads}/runtime-assets-2026-07-01"
export AVATAR_RUNTIME_REBUILD_VENVS="${AVATAR_RUNTIME_REBUILD_VENVS:-0}"
mkdir -p "$AVATAR_RUNTIME_DOWNLOAD_DIR"
# The underlying downloader validates checksums and reuses valid parts. curl -C -
# is used there after this repository's standardization patch.
exec bash "$ROOT/scripts/download_runtime_assets.sh"
