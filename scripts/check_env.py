#!/usr/bin/env python3
"""Preflight checks for EmpaAva mock and full CUDA modes (stdlib only)."""
from __future__ import annotations

import importlib.util
import os
import platform
import shutil
import site
import socket
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
venv_site = ROOT / ".venv" / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages"
if venv_site.is_dir():
    site.addsitedir(str(venv_site))

def load_env() -> dict[str, str]:
    values = dict(os.environ)
    path = ROOT / ".env"
    if path.exists():
        for raw in path.read_text(encoding="utf-8").splitlines():
            line = raw.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                values.setdefault(k.strip(), v.strip().strip("'\""))
    return values

ENV = load_env()
MODE = ENV.get("EMPAAVA_MODE", "mock").lower()
failures = 0

def result(level: str, name: str, detail: str) -> None:
    global failures
    if level == "FAIL": failures += 1
    print(f"{level:<4} {name}: {detail}")

def command_output(args: list[str]) -> str | None:
    try:
        run = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=8, check=False)
        return run.stdout.strip() if run.returncode == 0 else None
    except (OSError, subprocess.TimeoutExpired):
        return None

result("PASS" if sys.version_info >= (3, 10) else "FAIL", "Python", f"{platform.python_version()} ({sys.executable}); >=3.10 required for web/mock")
result("PASS" if MODE in {"mock", "full"} else "FAIL", "Mode", f"EMPAAVA_MODE={MODE}; mock is UI/API smoke-test only")

ffmpeg = shutil.which("ffmpeg") or str(ROOT / "runtime/cache/bin/ffmpeg")
ffprobe = shutil.which("ffprobe") or str(ROOT / "runtime/cache/bin/ffprobe")
for label, path in (("FFmpeg", ffmpeg), ("FFprobe", ffprobe)):
    works = bool(Path(path).is_file() and os.access(path, os.X_OK) and command_output([path, "-version"]))
    result("PASS" if works else ("WARN" if MODE == "mock" else "FAIL"), label, path if works else "not runnable; install ffmpeg (required for media processing)")

smi = command_output(["nvidia-smi", "--query-gpu=name,memory.total,driver_version", "--format=csv,noheader"])
if smi:
    result("PASS", "GPU", smi.replace("\n", "; "))
    result("PASS", "CUDA driver", (command_output(["nvidia-smi"]) or "available").splitlines()[2] if len((command_output(["nvidia-smi"]) or "").splitlines()) > 2 else "reported by nvidia-smi")
else:
    result("WARN" if MODE == "mock" else "FAIL", "GPU/CUDA", "NVIDIA GPU unavailable; full Gaussian rendering cannot run on CPU")

required_env = ["AVATAR_SYSTEM_ROOT", "HOST", "PORT", "EMPAAVA_CACHE_DIR", "EMPAAVA_MODEL_DIR"]
for key in required_env:
    result("PASS" if ENV.get(key) else "FAIL", f"env {key}", ENV.get(key, "missing"))
if MODE == "full":
    result("PASS" if ENV.get("OPENAI_API_KEY") else "WARN", "env OPENAI_API_KEY", "set" if ENV.get("OPENAI_API_KEY") else "missing; required unless using an offline planner")

port = int(ENV.get("PORT", "7861"))
sock = socket.socket()
try:
    sock.bind((ENV.get("HOST", "127.0.0.1"), port)); result("PASS", "Port", f"{port} is available")
except OSError as exc:
    result("FAIL", "Port", f"{port} unavailable: {exc}; choose another PORT")
finally: sock.close()

for rel in ("runtime", "runtime/outputs", "runtime/cache"):
    path = ROOT / rel
    try:
        path.mkdir(parents=True, exist_ok=True)
        probe = path / ".write-test"; probe.write_text("ok"); probe.unlink()
        result("PASS", f"Write {rel}", str(path))
    except OSError as exc: result("FAIL", f"Write {rel}", str(exc))

for module in ("fastapi", "uvicorn", "multipart"):
    result("PASS" if importlib.util.find_spec(module) else "FAIL", f"module {module}", "installed" if importlib.util.find_spec(module) else "missing; run bash scripts/setup.sh")

checks = {
    "EmotiVoice generator": "integrations/emotivoice/outputs/prompt_tts_open_source_joint/ckpt/g_00140000",
    "DEEPTalk": "integrations/deeptalk/DEEPTalk/checkpoint/DEEPTalk/DEEPTalk.pth",
    "TH-VQVAE": "integrations/deeptalk/DEEPTalk/checkpoint/TH-VQVAE/TH-VQVAE.pth",
    "Gaussian point cloud": "integrations/gaussian_avatar/media/306/point_cloud.ply",
    "Gaussian FLAME": "integrations/gaussian_avatar/media/306/flame_param.npz",
    "Whisper": "runtime/cache/xdg/whisper/small.pt",
}
for name, rel in checks.items():
    exists = (ROOT / rel).exists()
    result("PASS" if exists else ("WARN" if MODE == "mock" else "FAIL"), f"checkpoint {name}", rel if exists else f"missing: {rel}")

model_dir = ROOT / ENV.get("EMPAAVA_MODEL_DIR", "runtime/models")
result("PASS" if model_dir.is_dir() else ("WARN" if MODE == "mock" else "FAIL"), "Model directory", str(model_dir))
print(f"\nSummary: {'PASS' if failures == 0 else 'FAIL'} ({failures} failure(s), mode={MODE})")
raise SystemExit(1 if failures else 0)
