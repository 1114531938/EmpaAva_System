# Avatar System Full

`avatar_system_full` is the full-stack workspace for the 3D Emotional Phone
Booth avatar system. It combines a browser booth UI, a FastAPI/studio backend,
an agent-based multimodal pipeline, and local model workers for perception,
dialogue planning, speech, facial motion, and Gaussian avatar rendering.

## System Overview

```text
Browser UI
  |-- apps/web/static/           Main studio UI served on 7861
  `-- apps/booth/                3DEPB booth UI served on 7862

Backend services
  |-- apps/web/server.py         FastAPI server, job API, settings, studio/booth routes
  `-- apps/booth/server.py       Standalone booth adapter, auth, history, assets, jobs

Agent pipeline
  `-- src/avatar_system/
      |-- pipeline/              CLI, config loading, state, manifest, orchestration
      |-- agents/                InputAgent, DialogueAgent, EmbodimentAgent
      `-- tools/                 Perception, AvaMERG, EmotiVoice, DEEPTalk, Gaussian wrappers

Model integrations
  |-- integrations/perception/   ASR, emotion recognition, Task1 input builder
  |-- integrations/avamerg/      Dialogue/reply generation and EmotiVoice input conversion
  |-- integrations/emotivoice/   TTS frontend and worker
  |-- integrations/deeptalk/     Audio-to-FLAME motion
  |-- integrations/gaussian_avatar/
  `-- integrations/vhap/         FLAME/mesh utilities and dataset helpers

Runtime state
  `-- runtime/                   Local cache, outputs, containers, venvs, sqlite data
```

`runtime/` is machine-local and ignored by Git. Source code and committed UI
assets live under `apps/`, `src/avatar_system/`, `integrations/`, `scripts/`,
`config/`, and `docs/`.

## Quick Start

```bash
cd /scratch/e1554543/avatar_system_full

bash scripts/avatar.sh web
bash scripts/avatar.sh booth
bash scripts/avatar.sh 3depb
bash scripts/avatar.sh agent
```

Worker commands:

```bash
bash scripts/avatar.sh worker tts
bash scripts/avatar.sh worker avamerg
bash scripts/avatar.sh worker deeptalk
bash scripts/avatar.sh worker perception
bash scripts/avatar.sh worker gaussian
```

Managed service commands:

```bash
bash scripts/avatar.sh service booth start
bash scripts/avatar.sh service booth status
bash scripts/avatar.sh service booth logs
bash scripts/avatar.sh service booth stop
```

`scripts/avatar.sh booth` auto-starts the local workers by default. Set
`DEPB_AUTO_START_WORKERS=0` to manage workers manually.

## Services and Ports

```text
7861  Main FastAPI studio UI
7862  Booth / 3DEPB UI
8788  EmotiVoice TTS worker
8789  AvaMERG worker
8790  DEEPTalk worker
8791  Perception worker
8792  Gaussian render worker
```

Default URLs:

```text
http://localhost:7861/
http://localhost:7862/
```

See `docs/SERVICES_AND_PORTS.md` for additional service notes.

## Pipeline Architecture

The runnable pipeline is organized as three high-level agents:

```text
InputAgent -> DialogueAgent -> EmbodimentAgent
```

The CLI entrypoint is:

```bash
PYTHONPATH=src python -m avatar_system.pipeline.cli \
  --input_wav /path/to/input.wav \
  --input_video /path/to/optional_user_video.webm \
  --avatar_id 306 \
  --tts_speaker_id 6224 \
  --background study \
  --config src/avatar_system/pipeline_config.yaml
```

### InputAgent

`src/avatar_system/agents/input_agent.py`

- Accepts audio and optional Booth user video.
- Extracts lightweight video frames with ffmpeg when video is provided.
- Runs `PerceptionTool`, which calls the perception worker or local scripts.
- Produces ASR, SER/emotion data, Task1 input, and
  `runtime/outputs/<run_id>/input/perception_result.json`.

### DialogueAgent

`src/avatar_system/agents/dialogue_agent.py`

- Runs `Task1Tool`, which uses AvaMERG or fallback reply generation.
- Builds an explainable reply plan with reply text, style, selected avatar,
  selected TTS speaker, background, and perception references.
- Writes `runtime/outputs/<run_id>/dialogue/reply_plan.json`.
- Keeps the old `PlanAgent` name as a compatibility alias.

### EmbodimentAgent

`src/avatar_system/agents/embodiment_agent.py`

- Converts the reply plan into EmotiVoice text/input JSON.
- Runs EmotiVoice TTS to synthesize the reply WAV.
- Runs DEEPTalk to produce audio-driven facial motion.
- Merges motion into FLAME/Gaussian-compatible parameters.
- Prepares viewer assets and exports final artifacts/video.
- Keeps the old `RenderAgent` name as a compatibility alias.

The orchestrator stage order is:

```text
input_agent
perception
task1
dialogue_agent
plan_agent
emotivoice_prepare
render_agent
emotivoice_tts
deeptalk
flame_merge
viewer
artifact_export
embodiment_agent
```

State is persisted to `runtime/outputs/<run_id>/state.json` after each stage so
jobs can be inspected and resumed safely.

## Model and Stage Map

The system is not a single end-to-end model. It is a staged avatar pipeline
that passes JSON, WAV, NPY/NPZ motion, point-cloud assets, and MP4 artifacts
between several specialized models and wrappers.

Default model and runtime values are configured in
`src/avatar_system/pipeline_config.yaml`, with selected runtime overrides coming
from environment variables and Booth admin settings.

### End-to-End Logic

```text
Camera/mic input
  -> ffmpeg audio/video preparation
  -> ASR + speech emotion recognition
  -> Task1 empathy/dialogue JSON
  -> reply text and reply plan
  -> EmotiVoice phoneme/input preparation
  -> EmotiVoice speech synthesis
  -> DEEPTalk audio-to-face motion
  -> FLAME/Gaussian motion merge
  -> GaussianAvatar rendering
  -> optional background compositing
  -> Booth video playback, history, and export
```

### Models by Stage

| Stage | Code entry | Default model/tool | Purpose | Main output |
| --- | --- | --- | --- | --- |
| Capture and media prep | `apps/booth/server.py`, `InputAgent` | `ffmpeg` | Saves Booth audio/video, extracts WAV, samples lightweight video frames when present. | `input.wav`, optional `video_frames/` |
| ASR | `integrations/perception/scripts/run_asr.py` | OpenAI Whisper `small` by default (`perception.model: small`) | Transcribes user speech. Language defaults to English in `pipeline_config.yaml`, with script-level auto/detect support. | ASR JSON text |
| Speech emotion recognition | `integrations/perception/scripts/run_ser.py` | FunASR `AutoModel` with `iic/emotion2vec_plus_seed` | Predicts utterance-level acoustic emotion and normalizes it to task labels such as `neutral`, `happy`, `sad`, `angry`, or `anxious`. | SER JSON emotion |
| Perception merge | `integrations/perception/scripts/run_perception.py` | Script wrapper over Whisper + emotion2vec | Merges ASR and SER into one perception record. | `<utterance>_perception.json` |
| Task1 JSON builder | `integrations/perception/scripts/build_task1_input.py` | OpenAI-compatible chat API when enabled; default `LLM_MODEL=liquid/lfm-2.5-1.2b-instruct:free`; fallback rule-based JSON | Converts perception into Task1 empathy schema with speaker emotion, scenario, cause, response goal, and response profile. | Task1 input JSON |
| Reply generation | `src/avatar_system/tools/task1_tool.py` | LLM reply mode by default when `OPENAI_API_KEY` is set; AvaMERG/local fallback otherwise | Produces the spoken reply text and reply metadata from Task1 context and conversation history. | `reply_plan.json`, Task1 reply JSON |
| Voice input prep | `src/avatar_system/tools/emotivoice_prepare_tool.py` | EmotiVoice frontend plus `integrations/avamerg/json_to_emotivoice_input.py` | Converts reply JSON/text into EmotiVoice phoneme/content/prompt format. Default speaker id is `6224`. | EmotiVoice `.txt` input |
| TTS | `integrations/emotivoice/tts_worker.py`, `EmotiVoiceTTSTool` | EmotiVoice `JETSGenerator` checkpoint `g_00140000`; `StyleEncoder`; HiFi-GAN vocoder path inside EmotiVoice | Synthesizes reply speech with the selected speaker id and prompt/style embeddings. | `reply.wav` |
| Audio-to-motion | `integrations/deeptalk/DEEPTalk/deeptalk_worker.py`, `DEEPTalkTool` | DEEPTalk `DEMOTE_VQVAE_condition` with DEE audio emotion encoder and FLINT motion prior checkpoint | Converts reply WAV into facial-motion parameters. | `deeptalk.npy` |
| Motion merge | `FlameMergeTool` and `deeptalk_to_demo_flame_param.py` | FLAME template + avatar-specific GaussianAvatar media | Merges DEEPTalk motion into the selected avatar's FLAME/Gaussian parameter sequence; applies jaw/expression tuning from `merge:` config. | `flame_motion.npz` |
| Viewer prep | `ViewerTool` | GaussianAvatar local viewer assets | Prepares point cloud, motion, audio, and camera/viewer metadata for interactive 3D render mode. | Viewer assets/API payloads |
| Final video render | `src/avatar_system/export_gaussian_video.py`, `ArtifactExportTool` | GaussianAvatar renderer over selected avatar `point_cloud.ply` and motion NPZ | Renders frame sequence and muxes with reply audio. Runtime defaults: `25fps`, `550x802`. | `final_video.mp4` |
| Background compositing | `export_gaussian_video.py` with `--background_image` | Dual black/white Gaussian render alpha reconstruction + selected Booth background image | Reconstructs avatar alpha from black/white renders, composites over the selected room background, and preserves dark hair without front-end chroma keying. | Background-composited `final_video.mp4` |
| Playback/history | `apps/booth/app.js`, `apps/booth/server.py` | Browser video element, optional 3D render view | Plays the exported video, stores conversation rows, serves MP4 with byte-range support, and exports history clips. | Booth playback/history |

### Runtime Model Configuration

Important defaults:

```text
perception.model                 small
perception.language              en
perception.ser_model             iic/emotion2vec_plus_seed
env.OPENAI_BASE_URL              https://openrouter.ai/api/v1
env.LLM_MODEL                    liquid/lfm-2.5-1.2b-instruct:free
tts.speaker_id                   6224
tts.prompt_mode                  goal
runtime.video_fps                25
runtime.video_width              550
runtime.video_height             802
```

Useful overrides:

```text
OPENAI_API_KEY       Enables OpenAI-compatible Task1/reply generation.
OPENAI_BASE_URL      OpenAI-compatible API base URL.
LLM_MODEL            Default chat model for Task1/reply helpers.
TASK1_LLM_MODEL      Reply-generation model override.
TASK1_REPLY_MODE     Set to avamerg/local/off to avoid LLM reply mode.
DEPB_NO_LLM=1        Forces non-LLM Booth pipeline behavior.
DEPB_AVATAR_ID       Default Booth avatar id.
DEPB_FFMPEG          ffmpeg binary for Booth media handling.
```

If no API key is configured, the pipeline falls back to local/scripted reply
generation paths where available. Worker endpoints are enabled by default and
fall back to subprocess execution when the worker is unavailable.

## Runtime Artifacts

Each run writes a stable manifest:

```text
runtime/outputs/<run_id>/manifest.json
runtime/outputs/<run_id>/artifacts/manifest.json
```

Important manifest/state fields include:

```text
agent_pipeline_version
input_wav
input_video
video_frames_dir
perception_json
task1_input_json
perception_result_json
reply_plan_json
reply_text
reply_wav
deeptalk_npy
flame_motion_npz
point_cloud_path
output_video
output_white_model_video
video_export_error
finished_stages
```

Booth uploads, conversation history, recordings, generated video, TTS previews,
and service logs are stored under `runtime/outputs/` and `runtime/data/`.

## Booth Frontend

The Booth UI in `apps/booth/` provides:

- Guest and registered-user sessions.
- Avatar selection with configurable digital humans and voice speakers.
- Background selection and background image management.
- Automatic camera/microphone capture with silence-triggered submission.
- Conversation history, recording review, and history export.
- TTS voice preview caching.
- Video playback, 3D render view, point-cloud loading, frame rendering, and
  timeline controls.

Committed Booth configuration/assets:

```text
apps/booth/digital_humans.json
apps/booth/backgrounds.json
apps/booth/digital_human_images/
apps/booth/digital_human_backgrounds/
```

The generated avatar video is composited over the selected Booth background in
the browser. `apps/booth/app.js` draws the avatar video into a canvas and removes
the connected black backdrop while protecting the detected head/hair area. A
small alpha feather is applied at the matte boundary to reduce jagged edges.

## Backend APIs

`apps/web/server.py` is the main FastAPI service. It serves the studio, the
Booth route, settings, authentication, avatar metadata, TTS preview generation,
pipeline job creation, job status, viewer assets, and output files.

`apps/booth/server.py` is the standalone Booth adapter. It provides:

- `/api/auth/*` for login, registration, nickname, and logout.
- `/api/digital_humans` and `/api/backgrounds` for Booth configuration.
- `/api/tts_preview` for per-speaker preview audio.
- `/api/avatar/respond` and `/api/avatar/jobs/*` for async pipeline runs.
- `/api/avatar/runs/*/viewer_assets` and point-cloud routes for 3D preview.
- `/api/conversations`, `/api/history`, and `/api/recordings` for local history.

The standalone adapter stores its SQLite data and uploads under `runtime/`.

## Configuration

Primary pipeline configuration:

```text
src/avatar_system/pipeline_config.yaml
```

Important sections:

- `paths`: integration roots, venvs, output locations, container image.
- `env`: cache roots and LLM provider/model defaults.
- `perception`: ASR/SER model settings.
- `tts`: default EmotiVoice speaker and prompt mode.
- `*_worker`: worker URLs and timeouts.
- `merge`: FLAME jaw/expression tuning knobs.
- `runtime`: run root, viewer behavior, video export, fps, width, height.

Common environment variables:

```text
AVATAR_SYSTEM_ROOT
AVATAR_PYTHON
AGENT_PYTHON
AVATAR_CONTAINER
AVATAR_FFMPEG
AVATAR_FFPROBE
OPENAI_API_KEY
OPENAI_BASE_URL
LLM_MODEL
DEPB_AUTO_START_WORKERS
START_TTS_WORKER
START_AVAMERG_WORKER
START_DEEPTALK_WORKER
START_PERCEPTION_WORKER
START_GAUSSIAN_RENDER_WORKER
```

## Rendering Details

Final video export is handled by `src/avatar_system/export_gaussian_video.py`.
It loads the Gaussian avatar, applies merged FLAME motion, optionally overlays a
white mesh debug view, encodes a silent MP4, and muxes reply audio. Dimensions,
fps, and export mode are controlled by `runtime.video_width`,
`runtime.video_height`, `runtime.video_fps`, and related CLI flags.

The Gaussian render worker in `integrations/gaussian_avatar/` serves live render
requests for Booth viewer frames. The frontend can switch between video playback
and interactive 3D render assets for the same run.

## Development Notes

- Use `rg` to search the workspace; generated model/runtime data can be large.
- Keep model weights, caches, containers, virtual environments, and generated
  outputs under `runtime/` or integration-specific ignored directories.
- Do not add new source under removed compatibility paths.
- Prefer `scripts/avatar.sh` over ad hoc startup commands so cache paths,
  worker ports, thread limits, and container bindings remain consistent.
- Update this README when changing pipeline stages, ports, worker contracts,
  committed Booth assets, or runtime manifest fields.
