# EmpaAva

## 项目介绍

EmpaAva 是面向共情对话的 agentic 3D Avatar 系统：从语音和可选视频感知用户状态，经回复规划、情感语音、音频驱动 FLAME 动作与 3D Gaussian 渲染生成数字人回复。完整推理仅支持 Linux + NVIDIA CUDA GPU；CPU 不支持完整 Gaussian 渲染。

![EmpaAva](docs/assets/readme/hero.png)

## 在线 Demo / Demo Video / Project Page

公开链接尚未发布。仓库当前提供可复现的本地 Demo；在线地址、演示视频和项目页确定后将在此更新，避免放置不可验证的占位 URL。

## 系统架构

```text
音频 + 可选视频 → PerceptionAgent → ResponseAgent
                  → 情感 TTS → DEEPTalk → FLAME/AvaMERG
                  → CUDA Gaussian Renderer → MP4 / 3D Viewer
```

各阶段使用 JSON 状态与统一 `manifest.json` 交接。详见 [Agent Architecture](docs/AGENT_ARCHITECTURE.md)。

## 硬件要求

| 模式 | 硬件 | 说明 |
| --- | --- | --- |
| Full | H200 | 明确支持并推荐；显存充足 |
| Full | A100 40/80GB | 明确支持，需匹配 PyTorch/CUDA 驱动 |
| Full | RTX 4090 24GB | 明确支持推理；高分辨率/并发时需降低配置 |
| Full | 其他 NVIDIA GPU | 建议 Compute Capability ≥ 8.0、显存 ≥ 24GB |
| Mock | CPU 或任意 GPU | 仅 UI/API 冒烟测试，不加载模型，不是 EmpaAva 推理 |

要求 Ubuntu 20.04/22.04、Python 3.10+、FFmpeg、Git、curl；Full 模式还需要 NVIDIA 驱动/CUDA、Apptainer/Singularity，部分历史 worker 需要 Python 3.8。模型和环境建议预留至少 140GB。

## Quick Start

以下命令可从全新目录执行，不含作者服务器路径：

```bash
git clone https://github.com/1114531938/EmpaAva_System.git
cd EmpaAva_System
cp .env.example .env
bash scripts/setup.sh
python scripts/check_env.py
bash scripts/start_demo.sh
```

浏览器打开 `http://127.0.0.1:7861`。默认 `EMPAAVA_MODE=mock`，仅验证界面与 API。停止：

```bash
bash scripts/stop_demo.sh
```

## 完整安装

```bash
sudo apt-get update
sudo apt-get install -y git git-lfs curl build-essential ffmpeg zstd python3 python3-dev python3-venv python3-pip
git lfs install
bash scripts/download_models.sh --accept-licenses
bash scripts/rebuild_runtime_venvs.sh
sed -i 's/^EMPAAVA_MODE=.*/EMPAAVA_MODE=full/' .env
python scripts/check_env.py
```

须另行安装适配 GPU 的 NVIDIA 驱动、CUDA 和 Apptainer。`check_env.py` 的 FAIL 必须全部解决；WARN 表示可选能力或 mock 模式缺少完整模型。安装脚本可重复运行。pip 失败可重试 `.venv/bin/python -m pip install -r requirements.txt`；缺 FFmpeg 时执行上面的 apt 命令。

## 模型下载

```bash
bash scripts/download_models.sh
bash scripts/download_models.sh --accept-licenses
```

第一条命令只显示许可阻断。下载支持断点续传、SHA-256 校验、缓存和重复运行。设置 `EMPAAVA_CACHE_DIR=/data/empaava-cache` 可更换缓存。名称、来源、版本、许可证和空间需求见 [models/manifest.json](models/manifest.json)；许可证不明的模型不会自动下载。完整声明见 [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)。

## 启动前端和后端

```bash
bash scripts/start_demo.sh
bash scripts/avatar.sh service web status
bash scripts/stop_demo.sh
```

Full 模式会启动 web 和所需 worker；日志在 `runtime/logs/`。默认 web 端口 7861、worker 8788–8792，均可在 `.env` 修改。详见 [Services and Ports](docs/SERVICES_AND_PORTS.md)。

## 运行一个示例

仓库自带无需摄像头的 `examples/inputs/sample.wav` 和 `sample.mp4`：

```bash
bash scripts/run_example.sh
```

Mock 预期输出为 `runtime/outputs/example/manifest.json`，参考 [mock_manifest.json](examples/expected/mock_manifest.json)，不产生数字人视频。Full 模式会将同一输入送入完整流水线，最终 MP4 和所有产物路径记录在 run manifest 中。

## API 使用

```bash
curl -fsS http://127.0.0.1:7861/
curl -fsS http://127.0.0.1:7861/openapi.json -o /tmp/empaava-openapi.json
```

交互式文档位于 `http://127.0.0.1:7861/docs`。上传与会话接口以 OpenAPI 页面中的当前 schema 为准。

## Run manifest

每次完整运行写出统一 `manifest.json`，包含 schema/pipeline 版本、模型版本、配置、输入输出、总耗时与分阶段耗时、fallback、随机种子和异常信息，同时保留原有阶段产物字段，便于复现和审计。

## 常见错误

- `GPU/CUDA FAIL`：Full 模式必须能运行 `nvidia-smi`；CPU 只能使用 mock。
- `checkpoint ... missing`：阅读许可证后运行 `bash scripts/download_models.sh --accept-licenses`。
- 端口占用：修改 `.env` 中 `PORT`，或执行 `bash scripts/stop_demo.sh`。
- `No module named ...`：重跑 `bash scripts/setup.sh`；Full worker 再跑 `bash scripts/rebuild_runtime_venvs.sh`。
- Apptainer 看不到 GPU：先验证 `apptainer exec --nv <image> nvidia-smi` 并检查宿主机驱动。

## 许可证和第三方声明

第一方代码采用 [Apache-2.0](LICENSE)。第三方代码、模型和数据适用各自原始条款，详见 [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md)、[NOTICE](NOTICE) 和各 `integrations/*/LICENSE*`。使用前亦请阅读 [RESPONSIBLE_USE.md](RESPONSIBLE_USE.md)。
