# Project Structure

This workspace keeps source code, local model repositories, runtime assets, and
generated outputs in one runnable tree. Several scripts still use absolute paths,
so the current cleanup is intentionally conservative: source and service entry
points are documented clearly without moving runtime-heavy directories.

## Top-Level Layout

```text
avatar_system_full/
|-- README.md                         # Main operating guide
|-- SOURCE_RELEASE.md                 # What is included/excluded in GitHub
|-- docs/                             # Architecture, ports, deployment notes
|-- config/                           # Example environment files
|-- scripts/                          # Start/stop/test/asset scripts
|-- web_app/                          # FastAPI backend + browser frontend
|-- tools/avatar_agent/               # End-to-end pipeline orchestrator
|-- perception_layer/                 # ASR/SER/Task1 input integration
|-- AvaMERG_runs/                     # AvaMERG local repo and worker
|-- EmotiVoice_runs/                  # EmotiVoice local repo and TTS worker
|-- wav_to_flame/                     # DEEPTalk and FLAME conversion helpers
|-- GSavatar_runs/                    # GaussianAvatars local repo and renderer
|-- VHAP_runs/                        # VHAP local repo and environment
|-- 3DEPB_runs/                       # 3DEPB booth/demo service, if restored
|-- data/                             # Local subject data, ignored by Git
|-- cache/                            # HF/XDG/ModelScope/NLTK caches, ignored
|-- containers/                       # Local Apptainer sandboxes, ignored
`-- outputs/                          # Logs, uploads, exports, ignored
```

## Source Areas

`web_app/`
: Unified FastAPI application. It serves both frontend pages and API routes.

`web_app/static/index.html`, `style_commercial.css`, `app.js`
: Main research/studio UI. Default route on port `7861`.

`web_app/static/booth.html`, `booth.css`, `booth.js`
: Booth/video-call UI. Served at `/booth`, or as `/` when
`BOOTH_DEFAULT_ROUTE=1`.

`scripts/`
: Shell entry points for services, workers, subject preparation, and tests.
See `scripts/README.md`.

`tools/avatar_agent/`
: Python orchestration layer that connects perception, AvaMERG, TTS,
DEEPTalk/FLAME, Gaussian rendering, and artifact export.

`perception_layer/scripts/`
: Perception worker and helper scripts for ASR/SER and Task1 input JSON.

## Local Runtime Repositories

The directories ending in `_runs` contain local copies of upstream projects plus
small integration changes. They are part of the runnable local layout, but large
weights, datasets, build products, and nested upstream vendor trees are ignored
by Git. Keep these paths stable unless all scripts and config files are updated
together.

## Ignored Runtime Areas

`cache/`, `containers/`, `data/`, and `outputs/` are machine-local. They should
not be pushed to GitHub. Restore or recreate them separately when deploying to a
new server.
