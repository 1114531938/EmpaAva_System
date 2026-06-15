from __future__ import annotations

from pathlib import Path

from manifest_utils import load_json, save_json
from tools.task1_tool import Task1Tool


class DialogueAgent:
    """Generate reply content and a stable reply plan for rendering."""

    def __init__(self, config: dict):
        self.config = config
        self.task1_tool = Task1Tool(config)

    def _write_reply_plan(self, state) -> None:
        selected_avatar_id = getattr(state, "selected_avatar_id", None) or state.avatar_id
        selected_tts_speaker_id = (
            getattr(state, "selected_tts_speaker_id", None)
            or getattr(state, "tts_speaker_id", None)
        )
        task1_reply = load_json(getattr(state, "task1_reply_json", None)) or {}
        fallback_reason = task1_reply.get("fallback_reason") if isinstance(task1_reply, dict) else None
        plan = {
            "schema": 1,
            "agent": "DialogueAgent",
            "strategy": "explainable_coarse_tags",
            "reply_text": getattr(state, "reply_text", None),
            "reply_style": getattr(state, "reply_style", None),
            "selected_avatar_id": selected_avatar_id,
            "selected_tts_speaker_id": selected_tts_speaker_id,
            "background": getattr(state, "background", None),
            "perception_result_json": getattr(state, "perception_result_json", None),
            "perception_json": getattr(state, "perception_json", None),
            "task1_input_json": getattr(state, "task1_input_json", None),
            "task1_reply_json": getattr(state, "task1_reply_json", None),
            "fallback_reason": fallback_reason,
        }
        out_path = Path(state.run_dir) / "dialogue" / "reply_plan.json"
        save_json(out_path, plan)
        state.plan_json = str(out_path)
        state.reply_plan_json = str(out_path)
        state.selected_avatar_id = str(selected_avatar_id) if selected_avatar_id else None
        state.selected_tts_speaker_id = str(selected_tts_speaker_id) if selected_tts_speaker_id else None
        state.extra.setdefault("dialogue_agent", {}).update(plan)
        state.extra.setdefault("plan_agent", {}).update(plan)

    def run(self, state, run_stage) -> None:
        run_stage("task1", lambda: self.task1_tool.run(state))
        run_stage("dialogue_agent", lambda: self._write_reply_plan(state))
        run_stage("plan_agent", lambda: None)


class PlanAgent(DialogueAgent):
    """Backward-compatible alias for the older agent name."""
