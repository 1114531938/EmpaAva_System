# Source Release Notes

This repository is the source-code release of the local avatar system workspace.
It intentionally does not contain downloaded models, licensed identity assets,
training data, generated media, Python environments, caches, or containers.

## Included

- Three-agent pipeline package under `src/avatar_system/`
- FastAPI web application and browser frontend under `apps/web/`
- Booth / 3DEPB frontend under `apps/booth/`
- Service, worker, and asset-building scripts under `scripts/`
- Perception integration code under `perception_layer/scripts/`
- Local integration changes and workers under `integrations/`
- Compatibility shims under `tools/avatar_agent/` and `web_app/`

## Excluded Assets

The following categories remain local and are ignored by Git:

- Model weights and checkpoints: `*.pth`, `*.pt`, `*.ckpt`, `*.safetensors`
- Trained avatars and motion assets: `*.ply`, `*.npz`, `media/`, datasets
- NeRSemble and other downloaded datasets
- Virtual environments, Apptainer containers, and model caches
- Runtime outputs, uploaded audio, exported videos, and service logs
- Downloaded `ffmpeg` binaries and large upstream vendor/submodule trees

These files are either too large for a normal GitHub repository, generated at
runtime, or subject to their upstream dataset/model licenses.

## Local Runtime Layout

Local runtime state belongs under:

```text
runtime/cache/
runtime/containers/
runtime/data/
runtime/outputs/
```

An available avatar normally provides:

```text
integrations/gaussian_avatar/media/<avatar_id>/
|-- point_cloud.ply
`-- flame_param.npz
```

For a fresh setup, obtain upstream model repositories and checkpoints under
their respective licenses, create the per-component Python environments, and
provide a CUDA-capable Apptainer runtime before starting the service.
