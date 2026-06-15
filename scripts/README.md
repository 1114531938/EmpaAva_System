# Scripts

This directory contains the stable shell entry points for running, testing, and
maintaining the local avatar system.

## Service Scripts

```text
avatar_service.sh              start/stop/restart/status/logs for 7861 + workers
avatar_booth_service.sh        start/stop/restart/status/logs for 7862 Booth/3DEPB
run_web.sh                     start FastAPI web server on PORT, default 7861
run_booth.sh                   start FastAPI web server with Booth as default route
run_3depb.sh                   start external 3DEPB server on PORT, default 7862
run_web_with_tts.sh            legacy helper for web + TTS worker
```

## Worker Scripts

```text
run_tts_worker.sh
run_avamerg_worker.sh
run_deeptalk_worker.sh
run_perception_worker.sh
run_gaussian_render_worker.sh
```

## Pipeline Scripts

```text
run_agent.sh                   command-line end-to-end pipeline
avatar_video_input_test.sh     web-only Booth video/audio capture test
test_avamerg_worker.sh
test_deeptalk_worker.sh
test_perception_worker.sh
```

## Avatar Build and Asset Scripts

```text
init_subject.sh
run_vhap_subject.sh
export_vhap_to_gaussian.sh
train_gaussian_subject.sh
register_avatar_asset.sh
inventory_nersemble_subjects.sh
materialize_nersemble_union10.sh
register_nersemble_batch.sh
train_nersemble_batch.sh
unpack_nersemble_release.sh
compare_micro_expression_video.sh
check_paths.sh
vhap_env.sh
```

## Common Commands

```bash
bash scripts/avatar_service.sh start
bash scripts/avatar_service.sh restart
bash scripts/avatar_service.sh status
bash scripts/avatar_service.sh logs

bash scripts/avatar_booth_service.sh start
bash scripts/avatar_booth_service.sh status
```
