from __future__ import annotations

from manifest_utils import write_manifest
from tools.artifact_export_tool import ArtifactExportTool
from tools.deeptalk_tool import DEEPTalkTool
from tools.emotivoice_prepare_tool import EmotiVoicePrepareTool
from tools.emotivoice_tts_tool import EmotiVoiceTTSTool
from tools.flame_merge_tool import FlameMergeTool
from tools.viewer_tool import ViewerTool


class EmbodimentAgent:
    """Turn the reply plan into speech, motion, viewer assets, and artifacts."""

    def __init__(self, config: dict):
        self.config = config
        self.emotivoice_prepare_tool = EmotiVoicePrepareTool(config)
        self.emotivoice_tts_tool = EmotiVoiceTTSTool(config)
        self.deeptalk_tool = DEEPTalkTool(config)
        self.flame_merge_tool = FlameMergeTool(config)
        self.viewer_tool = ViewerTool(config)
        self.artifact_export_tool = ArtifactExportTool(config)

    def _mark_started(self, state) -> None:
        state.extra.setdefault("embodiment_agent", {})["status"] = "running"
        state.extra.setdefault("render_agent", {})["status"] = "running"

    def _mark_done(self, state) -> None:
        state.extra.setdefault("embodiment_agent", {})["status"] = "done"
        state.extra["embodiment_agent"]["output_video"] = state.output_video
        state.extra.setdefault("render_agent", {})["status"] = "done"
        state.extra["render_agent"]["output_video"] = state.output_video

    def run(self, state, run_stage) -> None:
        run_stage("emotivoice_prepare", lambda: self.emotivoice_prepare_tool.run(state))
        run_stage("render_agent", lambda: self._mark_started(state))
        run_stage("emotivoice_tts", lambda: self.emotivoice_tts_tool.run(state))
        run_stage("deeptalk", lambda: self.deeptalk_tool.run(state))
        run_stage("flame_merge", lambda: self.flame_merge_tool.run(state))
        run_stage(
            "viewer",
            lambda: self.viewer_tool.run(
                state,
                launch=(not state.prepare_only and state.launch_viewer),
            ),
        )
        run_stage(
            "artifact_export",
            lambda: self.artifact_export_tool.run(
                state,
                export_video=bool(self.config.get("runtime", {}).get("export_video", True)),
            ),
        )
        run_stage("embodiment_agent", lambda: self._mark_done(state))
        write_manifest(state)


class RenderAgent(EmbodimentAgent):
    """Backward-compatible alias for the older agent name."""
