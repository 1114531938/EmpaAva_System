# Third-Party Licenses and Asset Terms

This notice identifies the principal third-party components used by EmpaAva. It
is a practical inventory, not a replacement for the complete upstream license
files or legal advice. When terms differ, the original license or access
agreement controls.

## Source integrations

| Component | Local license | Summary |
| --- | --- | --- |
| AvaMERG | [`integrations/avamerg/LICENSE`](integrations/avamerg/LICENSE) | MIT License. Preserve the copyright and license notice when redistributing the software. |
| DEEPTalk | [`integrations/deeptalk/LICENSE`](integrations/deeptalk/LICENSE) | MIT License. Separate dependencies, checkpoints, FLAME resources, and datasets retain their own terms. |
| EmotiVoice | [`integrations/emotivoice/LICENSE`](integrations/emotivoice/LICENSE) | Apache License 2.0. Use of the interactive service, speakers, inputs, and outputs is also subject to the bundled [EmotiVoice User Agreement](integrations/emotivoice/EmotiVoice_UserAgreement_%E6%98%93%E9%AD%94%E5%A3%B0%E7%94%A8%E6%88%B7%E5%8D%8F%E8%AE%AE.pdf). |
| GaussianAvatars | [`integrations/gaussian_avatar/LICENSE.md`](integrations/gaussian_avatar/LICENSE.md) | Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International. Commercial use is not granted. |
| Gaussian Splatting portions | [`integrations/gaussian_avatar/LICENSE_GS.md`](integrations/gaussian_avatar/LICENSE_GS.md) | Inria/MPII research and evaluation license. Commercial exploitation requires prior permission. |
| VHAP | [`integrations/vhap/LICENSE`](integrations/vhap/LICENSE) | Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International. The upstream notice additionally reserves Toyota Motor Europe rights and prohibits commercial use without an express agreement. |
| ImageBind portions in AvaMERG | [`integrations/avamerg/merg_code/model/ImageBind/LICENSE`](integrations/avamerg/merg_code/model/ImageBind/LICENSE) | Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International. |

Transitive Python, JavaScript, system, and container dependencies are governed
by the licenses shipped with those packages. Their presence in an environment
does not place them under the EmpaAva license.

## Models, checkpoints, and datasets

Downloaded checkpoints are not automatically covered by the source-code license.
Users must review the upstream model card, download page, and dataset agreement
for every artifact, including Whisper, emotion2vec/FunASR, AvaMERG/Vicuna,
ImageBind, EmotiVoice, DEEPTalk, FLAME, GaussianAvatars, and VHAP assets.

In particular:

- FLAME model files require acceptance of the FLAME/Max Planck Institute terms.
- NeRSemble and other identity-bearing datasets require their own access and
  data-use permissions.
- EmotiVoice uses LibriTTS, HiFiTTS, and provider training data; the engine is
  Apache-2.0, while the bundled User Agreement also governs service use and
  generated output responsibilities.
- A checkpoint or dataset may impose non-commercial, attribution, citation,
  geographic, or redistribution conditions beyond its surrounding code.

## Avatar and voice assets

Avatar point clouds, FLAME parameters, portraits, videos, names, and related
identity-bearing files are **research-demo assets only unless accompanied by an
explicit asset-specific written license**. The repository does not grant rights
of publicity, likeness, privacy, trademark, or endorsement. Do not redistribute,
commercialize, or use an avatar to impersonate a real person without documented
authorization from all relevant rights holders.

EmotiVoice speaker IDs and synthesized audio are governed by the EmotiVoice
Apache-2.0 license and User Agreement. Those terms do not remove a user's duty to
obtain permission for protected text, personal data, cloned voices, or intended
uses of generated speech. Do not present synthetic speech as a real person's
statement or use it for deception, fraud, harassment, or unauthorized cloning.

## Combined use

The root Apache-2.0 license applies only to EmpaAva-authored source code. Running
or redistributing the complete system requires compliance with every applicable
third-party license and asset agreement. Where one component is non-commercial
or research-only, that restriction may govern the combined deployment.
