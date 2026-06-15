from __future__ import annotations

from avatar_system.agents import DialogueAgent, EmbodimentAgent, InputAgent


class Orchestrator:
    def __init__(self, config: dict):
        self.config = config
        self.input_agent = InputAgent(config)
        self.dialogue_agent = DialogueAgent(config)
        self.embodiment_agent = EmbodimentAgent(config)
        self.stage_order = [
            "input_agent",
            "perception",
            "task1",
            "dialogue_agent",
            "plan_agent",
            "emotivoice_prepare",
            "render_agent",
            "emotivoice_tts",
            "deeptalk",
            "flame_merge",
            "viewer",
            "artifact_export",
            "embodiment_agent",
        ]

    def run(self, state, save_state=None):
        def _save():
            if save_state is not None:
                save_state(state)

        def run_stage(stage_name: str, action):
            if stage_name in state.finished_stages:
                return

            step_index = len([stage for stage in self.stage_order if stage in state.finished_stages]) + 1
            total_steps = len(self.stage_order)
            print(f"\n[{step_index}/{total_steps}] {stage_name} starting...", flush=True)
            state.current_stage = stage_name
            _save()

            action()

            state.finished_stages.append(stage_name)
            _save()
            print(f"[{step_index}/{total_steps}] {stage_name} done.", flush=True)

        try:
            self.input_agent.run(state, run_stage)
            self.dialogue_agent.run(state, run_stage)
            self.embodiment_agent.run(state, run_stage)

            state.current_stage = "done"
            _save()
            return state

        except Exception as exc:
            state.failed_stage = state.current_stage
            state.error = str(exc)
            _save()
            raise
