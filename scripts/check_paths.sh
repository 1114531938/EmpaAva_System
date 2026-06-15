#!/usr/bin/env bash
set -u

ROOT="${AVATAR_SYSTEM_ROOT:-/scratch/e1554543/avatar_system_full}"
missing=0

check_path() {
  local label="$1"
  local path="$2"
  if [ -e "$path" ] || [ -L "$path" ]; then
    if [ -L "$path" ]; then
      printf '[OK]   %s -> %s -> %s\n' "$label" "$path" "$(readlink "$path")"
    else
      printf '[OK]   %s -> %s\n' "$label" "$path"
    fi
  else
    printf '[MISS] %s -> %s\n' "$label" "$path"
    missing=1
  fi
}

check_path "root" "$ROOT"
check_path "agent" "$ROOT/src/avatar_system/pipeline/cli.py"
check_path "config" "$ROOT/src/avatar_system/pipeline_config.yaml"
check_path "input sample" "$ROOT/perception_layer/data/demo_wavs/sample_dialog_02.wav"

check_path "perception python" "$ROOT/perception_layer/.perception/bin/python"
check_path "avamerg python" "$ROOT/integrations/avamerg/.avamerg38/bin/python"
check_path "emotivoice python" "$ROOT/integrations/emotivoice/.EmotiVoice/bin/python"
check_path "deeptalk python" "$ROOT/wav_to_flame/DEEPTalk_runs/.deeptalk39/bin/python"
check_path "gsavatar python" "$ROOT/integrations/gaussian_avatar/.GSavatar_glibc/bin/python"

check_path "AvaMERG inference" "$ROOT/integrations/avamerg/run_task1_infer.py"
check_path "EmotiVoice inference" "$ROOT/integrations/emotivoice/inference_am_vocoder_joint.py"
check_path "DEEPTalk merge" "$ROOT/integrations/deeptalk/avatar_system_helpers/deeptalk_to_demo_flame_param.py"
check_path "GS viewer" "$ROOT/integrations/gaussian_avatar/local_viewer.py"
check_path "ffmpeg" "$ROOT/tools/ffmpeg-git-20240629-amd64-static/ffmpeg"
check_path "container" "$ROOT/runtime/containers/gaussianav_jammy"
check_path "HF cache" "$ROOT/runtime/cache/hf"
check_path "XDG cache" "$ROOT/runtime/cache/xdg"
check_path "ModelScope cache" "$ROOT/runtime/cache/modelscope"

if [ "$missing" -eq 0 ]; then
  printf '\nAll required paths are present under %s.\n' "$ROOT"
else
  printf '\nSome required paths are missing under %s.\n' "$ROOT"
fi

exit "$missing"
