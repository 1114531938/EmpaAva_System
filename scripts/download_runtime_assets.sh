#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${AVATAR_SYSTEM_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

REPO="${AVATAR_RUNTIME_REPO:-1114531938/EmpaAva_System}"
TAG="${AVATAR_RUNTIME_RELEASE_TAG:-runtime-assets-2026-07-01}"
PREFIX="${AVATAR_RUNTIME_ASSET_PREFIX:-EmpaAva_System-runtime-assets}"
PREFIXES="${AVATAR_RUNTIME_ASSET_PREFIXES:-$PREFIX EmpaAva_System-runtime-assets-patch1}"
DOWNLOAD_DIR="${AVATAR_RUNTIME_DOWNLOAD_DIR:-$ROOT/runtime/release_assets/downloads/$TAG}"
BASE_URL="${AVATAR_RUNTIME_BASE_URL:-https://github.com/$REPO/releases/download/$TAG}"
SHA_FILE_NAME="${AVATAR_RUNTIME_SHA_FILE:-sha256sums.patch1.txt}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need_cmd curl
need_cmd sha256sum
need_cmd tar
need_cmd zstd

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

download() {
  local name="$1"
  local url="$BASE_URL/$name"
  if [[ -s "$name" ]]; then
    echo "Using existing $name"
    return
  fi
  echo "Downloading $url"
  curl -fL --retry 5 --retry-delay 5 -C - -o "$name" "$url"
}

if ! download "$SHA_FILE_NAME"; then
  if [[ "$SHA_FILE_NAME" != "sha256sums.txt" ]]; then
    echo "No $SHA_FILE_NAME found in release; falling back to sha256sums.txt"
    SHA_FILE_NAME="sha256sums.txt"
    download "$SHA_FILE_NAME"
  fi
fi
if [[ "$SHA_FILE_NAME" != "sha256sums.txt" ]]; then
  ln -sf "$SHA_FILE_NAME" sha256sums.txt
fi

if curl -fL --retry 3 --retry-delay 3 -o "runtime_assets_manifest.txt" \
  "$BASE_URL/runtime_assets_manifest.patch1.txt"; then
  echo "Downloaded runtime_assets_manifest.patch1.txt"
elif curl -fL --retry 3 --retry-delay 3 -o "runtime_assets_manifest.txt" \
  "$BASE_URL/runtime_assets_manifest.txt"; then
  echo "Downloaded runtime_assets_manifest.txt"
else
  echo "No runtime_assets_manifest found in release; continuing with sha256sums.txt"
  rm -f runtime_assets_manifest.txt
fi

archives_found=0
for archive_prefix in $PREFIXES; do
  mapfile -t PARTS < <(awk -v p="$archive_prefix.tar.zst.part-" 'index($2, p) == 1 {print $2}' sha256sums.txt | sort)
  if [[ "${#PARTS[@]}" -eq 0 ]]; then
    echo "No archive parts named $archive_prefix.tar.zst.part-* found in sha256sums.txt; skipping"
    continue
  fi
  archives_found=1

  for part in "${PARTS[@]}"; do
    if [[ -s "$part" ]] && grep -F "  $part" sha256sums.txt | sha256sum -c - >/dev/null 2>&1; then
      echo "Checksum already OK: $part"
    else
      rm -f "$part"
      download "$part"
    fi
  done

  echo "Verifying downloaded runtime asset parts for $archive_prefix"
  grep -F "$archive_prefix.tar.zst.part-" sha256sums.txt | sha256sum -c -

  echo "Extracting $archive_prefix into $ROOT"
  cat "${PARTS[@]}" | zstd -d --stdout | tar -xpf - -C "$ROOT"
done

if [[ "$archives_found" -eq 0 ]]; then
  echo "No runtime archive parts found in sha256sums.txt for prefixes: $PREFIXES" >&2
  exit 1
fi

chmod +x "$ROOT/runtime/cache/bin/ffmpeg" "$ROOT/runtime/cache/bin/ffprobe" 2>/dev/null || true

REQUIRED_PATHS=(
  "runtime/containers/gaussianav_jammy"
  "runtime/cache/bin/ffmpeg"
  "runtime/cache/bin/ffprobe"
  "runtime/cache/xdg/whisper/small.pt"
  "runtime/cache/modelscope/models/iic/emotion2vec_plus_seed"
  "runtime/cache/modelscope/iic/emotion2vec_base_finetuned/emotion2vec_base.pt"
  "integrations/deeptalk/DEE/models/emo2vec/checkpoint/emotion2vec_base.pt"
  "integrations/deeptalk/DEE/models/emo2vec/emotion2vec_base.pt"
  "integrations/avamerg/ckpt/pretrained_ckpt/imagebind_ckpt/huge/imagebind_huge.pth"
  "integrations/avamerg/ckpt/pretrained_ckpt/vicuna_ckpt/7b_v0"
  "integrations/emotivoice/outputs/prompt_tts_open_source_joint/ckpt/g_00140000"
  "integrations/emotivoice/outputs/prompt_tts_open_source_joint/ckpt/do_00140000"
  "integrations/emotivoice/outputs/style_encoder/ckpt/checkpoint_163431"
  "integrations/emotivoice/data/youdao/text/README.md"
  "integrations/emotivoice/data/youdao/text/emotion"
  "integrations/emotivoice/data/youdao/text/energy"
  "integrations/emotivoice/data/youdao/text/pitch"
  "integrations/emotivoice/data/youdao/text/speaker2"
  "integrations/emotivoice/data/youdao/text/speed"
  "integrations/emotivoice/data/youdao/text/tokenlist"
  "integrations/emotivoice/WangZeJun/simbert-base-chinese/model.safetensors"
  "integrations/emotivoice/WangZeJun/simbert-base-chinese/pytorch_model.bin"
  "integrations/deeptalk/DEE/checkpoint/DEE.pt"
  "integrations/deeptalk/DEEPTalk/checkpoint/DEEPTalk/DEEPTalk.pth"
  "integrations/deeptalk/DEEPTalk/checkpoint/TH-VQVAE/TH-VQVAE.pth"
  "integrations/deeptalk/FER/checkpoint/FER.pth"
  "integrations/gaussian_avatar/media/306/point_cloud.ply"
  "integrations/gaussian_avatar/media/306/flame_param.npz"
  "integrations/gaussian_avatar/flame_model/assets"
  "integrations/gaussian_avatar/submodules/diff-gaussian-rasterization"
  "integrations/gaussian_avatar/submodules/diff-gaussian-rasterization/cuda_rasterizer/rasterizer_impl.h"
  "integrations/gaussian_avatar/submodules/simple-knn"
  "integrations/vhap/asset/flame/flame2023.pkl"
  "integrations/vhap/asset/flame/FLAME_masks.pkl"
  "integrations/vhap/asset/flame/landmark_embedding_with_eyes.npy"
  "integrations/vhap/asset/flame/tex_mean_painted.png"
  "integrations/vhap/asset/flame/uv_masks.npz"
)

missing=0
for rel in "${REQUIRED_PATHS[@]}"; do
  if [[ ! -e "$ROOT/$rel" ]]; then
    echo "Missing after extraction: $rel" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Runtime asset restore finished, but required files are still missing." >&2
  exit 1
fi

REBUILD_VENVS="${AVATAR_RUNTIME_REBUILD_VENVS:-auto}"
VENV_PATHS=(
  "runtime/cache/venvs/web/bin/python"
  "runtime/cache/venvs/perception/bin/python"
  "runtime/cache/venvs/deeptalk/bin/python"
  "integrations/avamerg/.avamerg38/bin/python"
  "integrations/emotivoice/.EmotiVoice/bin/python"
  "integrations/gaussian_avatar/.GSavatar_glibc/bin/python"
)

venv_missing=0
for rel in "${VENV_PATHS[@]}"; do
  if [[ ! -x "$ROOT/$rel" ]]; then
    venv_missing=1
  fi
done

if [[ "$REBUILD_VENVS" == "1" || "$REBUILD_VENVS" == "true" || "$REBUILD_VENVS" == "yes" ||
      ( "$REBUILD_VENVS" == "auto" && "$venv_missing" -ne 0 ) ]]; then
  echo "Rebuilding missing runtime Python environments"
  bash "$ROOT/scripts/rebuild_runtime_venvs.sh"
elif [[ "$venv_missing" -ne 0 ]]; then
  echo "Runtime assets are restored, but one or more Python venvs are missing." >&2
  echo "Run scripts/rebuild_runtime_venvs.sh before starting the workers." >&2
fi

if ! command -v apptainer >/dev/null 2>&1 && ! command -v singularity >/dev/null 2>&1; then
  echo "Runtime assets are restored, but apptainer/singularity is not on PATH." >&2
  echo "Install Apptainer or load the site module before starting the Gaussian worker." >&2
fi

echo "Runtime assets restored successfully."
