# Services and Ports

## Main UI: 7861

```bash
cd /scratch/e1554543/avatar_system_full
bash scripts/avatar_service.sh start
```

Default URL:

```text
http://localhost:7861/
```

This starts the unified FastAPI web server plus the worker services.

## Booth / 3DEPB UI: 7862

```bash
cd /scratch/e1554543/avatar_system_full
bash scripts/avatar_booth_service.sh start
```

Default URL:

```text
http://localhost:7862/
```

Current behavior:

- `avatar_booth_service.sh` reuses `avatar_service.sh` for worker lifecycle.
- It changes the web port to `7862`.
- It uses `scripts/run_3depb.sh` as the web start script.
- `run_3depb.sh` expects `3DEPB_runs/3DEPB/server.py` to exist.

If you want to serve the built-in Booth page from the FastAPI backend instead,
use:

```bash
PORT=7862 BOOTH_DEFAULT_ROUTE=1 WEB_SCRIPT=/scratch/e1554543/avatar_system_full/scripts/run_booth.sh \
  bash scripts/avatar_service.sh start
```

The built-in Booth page is always available from the FastAPI backend at:

```text
/booth
```

The research studio page is always available at:

```text
/studio
```

## Worker Ports

```text
7861  FastAPI main studio UI
7862  Booth / 3DEPB UI
8788  EmotiVoice TTS worker
8789  AvaMERG worker
8790  DEEPTalk worker
8791  perception worker
8792  Gaussian render worker
```

## Service Commands

```bash
bash scripts/avatar_service.sh start
bash scripts/avatar_service.sh stop
bash scripts/avatar_service.sh restart
bash scripts/avatar_service.sh status
bash scripts/avatar_service.sh logs
```

Single worker commands:

```bash
bash scripts/avatar_service.sh start-tts
bash scripts/avatar_service.sh stop-tts
bash scripts/avatar_service.sh start-avamerg
bash scripts/avatar_service.sh stop-avamerg
bash scripts/avatar_service.sh start-deeptalk
bash scripts/avatar_service.sh stop-deeptalk
bash scripts/avatar_service.sh start-perception
bash scripts/avatar_service.sh stop-perception
bash scripts/avatar_service.sh start-gaussian-render
bash scripts/avatar_service.sh stop-gaussian-render
```
