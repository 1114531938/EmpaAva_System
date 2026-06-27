from __future__ import annotations

import json
from pathlib import Path
from typing import Any


AGENT_PIPELINE_VERSION = 1


def save_json(path: str | Path, data: dict[str, Any]) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def load_json(path: str | Path | None) -> Any:
    if not path:
        return None
    path = Path(path)
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def find_first_value(obj: Any, keys: set[str]) -> str | None:
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key in keys and isinstance(value, (str, int, float)):
                return str(value)
        for value in obj.values():
            found = find_first_value(value, keys)
            if found is not None:
                return found
    elif isinstance(obj, list):
        for item in obj:
            found = find_first_value(item, keys)
            if found is not None:
                return found
    return None


def build_manifest(state) -> dict[str, Any]:
    return {
        "agent_pipeline_version": AGENT_PIPELINE_VERSION,
        "run_id": state.run_id,
        "input_wav": state.input_wav,
        "input_video": state.input_video,
        "video_frames_dir": state.video_frames_dir,
        "avatar_id": state.avatar_id,
        "perception_json": state.perception_json,
        "task1_input_json": state.task1_input_json,
        "perception_result_json": state.perception_result_json,
        "task1_reply_json": state.task1_reply_json,
        "plan_json": state.plan_json,
        "reply_plan_json": state.reply_plan_json,
        "selected_avatar_id": state.selected_avatar_id,
        "selected_tts_speaker_id": state.selected_tts_speaker_id,
        "background": state.background,
        "background_image": getattr(state, "background_image", None),
        "session_id": state.session_id,
        "turn_id": state.turn_id,
        "conversation_context_json": state.conversation_context_json,
        "reply_text": state.reply_text,
        "reply_style": state.reply_style,
        "tts_speaker_id": state.tts_speaker_id,
        "emotivoice_txt": state.emotivoice_txt,
        "reply_wav": state.reply_wav,
        "deeptalk_npy": state.deeptalk_npy,
        "flame_motion_npz": state.flame_motion_npz,
        "point_cloud_path": state.point_cloud_path,
        "template_npz": state.template_npz,
        "viewer_command": state.viewer_command,
        "viewer_started": state.viewer_started,
        "viewer_pid": state.viewer_pid,
        "artifact_dir": state.artifact_dir,
        "artifact_reply_wav": state.artifact_reply_wav,
        "artifact_enhanced_reply_wav": state.artifact_enhanced_reply_wav,
        "artifact_flame_motion_npz": state.artifact_flame_motion_npz,
        "output_video": state.output_video,
        "output_white_model_video": state.output_white_model_video,
        "video_export_command": state.video_export_command,
        "video_export_error": state.video_export_error,
        "finished_stages": state.finished_stages,
        "failed_stage": state.failed_stage,
        "error": state.error,
        "run_dir": state.run_dir,
        "log_dir": state.log_dir,
    }


def write_manifest(state) -> dict[str, Any]:
    manifest = build_manifest(state)
    save_json(Path(state.run_dir) / "manifest.json", manifest)
    if state.artifact_dir:
        save_json(Path(state.artifact_dir) / "manifest.json", manifest)
    return manifest
