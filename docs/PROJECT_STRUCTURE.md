# Project Structure

The repository now follows an open-source style layout while keeping local
runtime assets separate from source code.

## Top-Level Layout

```text
avatar_system_full/
|-- apps/
|   |-- web/                         # FastAPI backend + 7861 frontend
|   `-- booth/                       # 7862 Booth / 3DEPB frontend
|-- src/avatar_system/
|   |-- agents/                      # InputAgent, DialogueAgent, EmbodimentAgent
|   |-- tools/                       # TTS/AvaMERG/DEEPTalk/Gaussian wrappers
|   `-- pipeline/                    # CLI, orchestrator, state, config
|-- integrations/
|   |-- avamerg/
|   |-- emotivoice/
|   |-- deeptalk/
|   |-- gaussian_avatar/
|   `-- vhap/
|-- perception_layer/                # ASR/SER integration
|-- scripts/                         # Unified service and worker entrypoints
|-- config/                          # Example runtime env files
|-- docs/                            # Architecture and deployment notes
|-- runtime/                         # Local cache/data/outputs/containers, ignored
|-- tools/avatar_agent/              # Compatibility shims for old entrypoints
`-- web_app/                         # Compatibility shim for apps.web.server
```

## Source Areas

`src/avatar_system/`
: First-party Python package for the three-agent pipeline.

`apps/web/`
: Unified FastAPI application and browser frontend. `web_app/server.py` remains
as a compatibility import shim.

`apps/booth/`
: 3DEPB / Booth service used by the 7862 entrypoint.

`integrations/`
: Local copies of upstream components with small worker/integration changes.
Large weights, datasets, generated outputs, and nested upstream metadata remain
ignored by Git.

`runtime/`
: Machine-local state: caches, containers, data workspaces, uploads, generated
videos, manifests, service logs, and historical outputs.

## Compatibility Paths

Older paths such as `tools/avatar_agent/`, `web_app/`, `AvaMERG_runs/`,
`EmotiVoice_runs/`, `GSavatar_runs/`, `VHAP_runs/`, `wav_to_flame/`,
`3DEPB_runs/`, `cache/`, `data/`, `containers/`, and `outputs/` are kept as
thin shims or local symlinks during the migration. Do not add new source code to
those locations.
