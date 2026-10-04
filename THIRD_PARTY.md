# Third-party resources

Record every third-party asset, library, font, sound, code sample, tool-provided resource, or other external material actually used in the game. Include enough detail to verify its source and permitted use.

For each item, record:

- Name and type.
- Creator or publisher.
- Source URL or package identifier and version, if applicable.
- License or usage terms, plus required attribution.
- Where and how it is used in the project.

Do not list planned resources as used. Recheck this inventory before release.

## Used resources

| Resource | Publisher / source | License / notices | Actual use |
|---|---|---|---|
| Godot Engine 4.7.2 stable, standard edition, and matching Web export templates | Godot contributors; [official release](https://godotengine.org/download/archive/4.7.2-stable/) | MIT. The license is stored in [GODOT-LICENSE.txt](src/licenses/GODOT-LICENSE.txt). Engine dependency notices are stored in [GODOT-COPYRIGHT.txt](src/licenses/GODOT-COPYRIGHT.txt). Both files are included in the game export. | Project editor, runtime and Web build. Local binary reports `4.7.2.stable.official.ed1daf0bf`. |
| Node.js v24.20.0, existing local installation | Node.js contributors; [source and license](https://github.com/nodejs/node/blob/v24.20.0/LICENSE) | MIT with bundled dependency notices in the linked LICENSE. | Development only: the local preview server uses built-in modules. Node.js and the server are not shipped in the game export. |

| OpenAI built-in image generation | OpenAI; [service terms](https://openai.com/policies/service-terms/) | Generated output; no stock image or third-party reference was supplied. No open-source license is asserted for this output. | Original reference room and new playable vintage living room in `assets/art/backgrounds/`, copied to runtime assets. Provenance: `assets/production/background_reference.json` and `assets/production/living_room_stage.json` (2026-10-04,1672×941). |
| Kokoro ONNX wrapper 0.6.1 | thewh1teagle; [source/license](https://github.com/thewh1teagle/kokoro-onnx) | MIT | Offline voice production only, `assets/audio/generate_reference.py`. |
| Kokoro v1.0 ONNX model and voices-v1.0 bank | hexgrad; [model/license](https://huggingface.co/hexgrad/Kokoro-82M); [ONNX release](https://github.com/thewh1teagle/kokoro-onnx/releases/tag/model-files-v1.1) | Apache-2.0 model; upstream voice production resources | Three audition clips from original scripts: af_heart narrator and bm_george Boss. Model/voice bank local only; checksums pinned in generator. |
| ONNX Runtime 1.30.0 | Microsoft; [source/license](https://github.com/microsoft/onnxruntime) | MIT with upstream dependency notices | Offline CPU inference only. |
| NumPy 2.5.3 | NumPy contributors; [source/license](https://github.com/numpy/numpy) | BSD-3-Clause plus bundled wheel notices | Offline waveform processing only. |
| SoundFile 0.13.1 / bundled libsndfile | [SoundFile](https://github.com/bastibe/python-soundfile); [libsndfile](https://github.com/libsndfile/libsndfile) | SoundFile BSD-3-Clause; libsndfile LGPL-2.1-or-later and bundled codec notices | Offline WAV masters, Vorbis encoding and waveform checks. |
| phonemizer 3.4.0 | [phonemizer contributors](https://github.com/bootphon/phonemizer) | GPL-3.0-or-later | Offline English phoneme conversion only. |
| espeakng-loader 0.2.4 / bundled eSpeak NG | [loader](https://github.com/thewh1teagle/espeakng-loader); [eSpeak NG](https://github.com/espeak-ng/espeak-ng) | Loader MIT; eSpeak NG GPL-3.0-or-later | Offline native Windows speech tokenizer. |

The complete pinned production package inventory is in
`assets/audio/requirements-reference.txt`; recorded upstream license metadata and
source links are in `assets/audio/production_dependencies.json`. Dependencies remain in the ignored
local environment with their upstream notices. No paid speech service, speech
model, voice bank or production runtime is shipped in the game export.
Generated dialogue uses original scripts, not recordings of teammates.

Boss/Dog SVG cutouts, thought icons, cake/consumed cake/dog bed/lantern/fixture SVGs,
rig code, greybox shapes, frame/binary lighting shaders, light masks, comic effects,
prototype DING and procedural action sounds are original project work. No external
sound library is used for those effects. No external character art, custom font
or music has been added. Godot's default font and dependencies are covered by the
included engine notices. The preview server has no npm dependencies.
