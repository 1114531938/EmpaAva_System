# Web App

`web_app/server.py` is the unified FastAPI backend for the avatar system. It
serves static frontend files, accepts uploads, starts pipeline jobs, manages
Booth sessions, and proxies interactive Gaussian render requests.

## Frontend Pages

```text
web_app/static/index.html             # Main research/studio UI
web_app/static/style_commercial.css
web_app/static/app.js

web_app/static/booth.html             # Booth/video-call UI
web_app/static/booth.css
web_app/static/booth.js

web_app/static/vendor/                # Browser-side 3D viewer dependencies
```

Routes:

```text
/          main studio by default, Booth if BOOTH_DEFAULT_ROUTE=1
/studio    always main studio
/booth     always built-in Booth page
/api/*     backend APIs
/outputs/* generated files exposed from outputs/
```

## Ports

- `7861`: main studio, via `scripts/run_web.sh` or `scripts/avatar_service.sh`
- `7862`: Booth/3DEPB path, via `scripts/avatar_booth_service.sh`

## Backend Responsibilities

- Auth and Booth session database under `outputs/booth/booth.sqlite3`
- Web uploads under `outputs/web_uploads/`
- Pipeline jobs under `outputs/web_<run_id>/`
- TTS preview files under `outputs/tts_previews/`
- Booth uploads and exports under `outputs/booth/`
- Interactive render frame API backed by the Gaussian render worker

## Development Notes

Frontend-only changes usually need a browser refresh. Backend, worker, or script
changes should use:

```bash
bash scripts/avatar_service.sh restart
```
