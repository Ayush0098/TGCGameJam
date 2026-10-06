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

Pages 1–3 voice replacement (2026-10-05): 51 current game MP3s were synthesized
offline with the installed Microsoft Windows Indian English Ravi and Heera
speech voices through Windows System.Speech. The two Professor cues use
[Resemble AI Chatterbox TTS](https://github.com/resemble-ai/chatterbox) and its
[model weights](https://huggingface.co/ResembleAI/chatterbox) (MIT license), with
a locally generated Indian English voice reference from
[Kenpath Svara TTS](https://huggingface.co/kenpath/svara-tts-v1-openvino-int4)
(Apache-2.0 license). The models and reference are local production tools, not
bundled with the game. NumPy/SoundFile processed and encoded the MP3s. Microsoft
is the publisher of the OS voices; redistribution/use terms for those 51
generated recordings have not yet been established, so confirm them before a
public release. Per-file provenance and hashes are in
`assets/audio/voice/p1_3/manifest.json`.

Chintu's page 1 lit cue uses three edited barks from [“Chihuahua Barks” by Mewsel](https://freesound.org/people/Mewsel/sounds/208030/), recorded from the creator's puppy and published under Creative Commons Zero (CC0 1.0). No attribution is required by the license; this record credits the creator. The high-quality Freesound preview was the source. The edited 1.47-second MP3 is shipped at `assets/audio/voice/characters/page_01_dialogue_dog_lit.mp3` and its matching runtime copy. The dialogue text appears as a caption only.

Campus room background batch (2026-10-05): eleven original PNG paintings in `src/assets/art/rooms/` were generated using OpenAI built-in image generation. The project's `ishaan_idle.png` and `postcard_goa.png` were style references; `room_amphi.png` was also the architectural reference for `room_amphi_wedding.png`. No new stock art or external reference was introduced. Prompts, page mapping and generated dimensions are recorded in `assets/production/campus_room_backgrounds.json`. These are delivered art files, not yet verified as loaded by the game.

Voice-file batch (2026-10-04, through Parts F/G):222 MP3s in assets/audio/voice/ generated
with the existing Kokoro/ONNX/SoundFile stack listed below, no new downloads or
dependencies. Additional profiles:bf_lily,af_sky,am_puck,am_santa,af_nicole;
af_heart/bm_george retained; bm_fable used for the new narr15_* storyteller and
phoneme-generated finale laughter. MP3 encoding uses existing SoundFile/libsndfile.
Exact model hashes/profiles/production metadata:assets/audio/voice/manifest.json.
Four nonverbal animal cues and12 animal blips are original NumPy synthesis,
not externally sourced recordings. Production files now have matching runtime
copies; revised narrator subtitles match the supplied Part E script.

Kitchen/office painting revision2 uses the project's original generated paintings
as edit inputs (2026-10-04), with exact prompts in their existing provenance files.
Initial masters are archived; no external reference art was introduced.

| Resource | Publisher / source | License / notices | Actual use |
|---|---|---|---|
| Godot Engine 4.7.2 stable, standard edition, and matching Web export templates | Godot contributors; [official release](https://godotengine.org/download/archive/4.7.2-stable/) | MIT. The license is stored in [GODOT-LICENSE.txt](src/licenses/GODOT-LICENSE.txt). Engine dependency notices are stored in [GODOT-COPYRIGHT.txt](src/licenses/GODOT-COPYRIGHT.txt). Both files are included in the game export. | Project editor, runtime and Web build. Local binary reports `4.7.2.stable.official.ed1daf0bf`. |
| Node.js v24.20.0, existing local installation | Node.js contributors; [source and license](https://github.com/nodejs/node/blob/v24.20.0/LICENSE) | MIT with bundled dependency notices in the linked LICENSE. | Development only: the local preview server uses built-in modules. Node.js and the server are not shipped in the game export. |

| OpenAI built-in image generation | OpenAI; [service terms](https://openai.com/policies/service-terms/) | Generated output; no stock image or third-party reference was supplied. Kitchen/office use the project's generated living room as style reference. No open-source license is asserted for this output. | Original reference room and playable living room, kitchen and office in `assets/art/backgrounds/`, copied to runtime assets. Provenance: `assets/production/background_reference.json`, `living_room_stage.json`, `kitchen_stage.json` and `office_stage.json` (stage paintings:2026-10-04,1672×941). |
| Bangers (font) | The Bangers Project Authors; [Google Fonts source](https://github.com/google/fonts/tree/main/ofl/bangers) | SIL Open Font License 1.1, stored in [Bangers-OFL.txt](src/licenses/Bangers-OFL.txt) | Title, stamps, onomatopoeia and comic headings. `src/assets/fonts/Bangers-Regular.ttf`, added 2026-10-04. |
| Comic Neue Bold (font) | The Comic Neue Project Authors; [Google Fonts source](https://github.com/google/fonts/tree/main/ofl/comicneue) | SIL Open Font License 1.1, stored in [ComicNeue-OFL.txt](src/licenses/ComicNeue-OFL.txt) | UI text, captions, bubbles. `src/assets/fonts/ComicNeue-Bold.ttf`, added 2026-10-04. |
| Kokoro ONNX wrapper 0.6.1 | thewh1teagle; [source/license](https://github.com/thewh1teagle/kokoro-onnx) | MIT | Offline voice production only, `assets/audio/generate_reference.py`. |
| Kokoro v1.0 ONNX model and voices-v1.0 bank | hexgrad; [model/license](https://huggingface.co/hexgrad/Kokoro-82M); [ONNX release](https://github.com/thewh1teagle/kokoro-onnx/releases/tag/model-files-v1.1) | Apache-2.0 model; upstream voice production resources | All game voices: 31 narrator lines and 56 character reactions from original scripts (assets/audio/voice, generated locally, see its README and manifest.json); also the three earlier auditions. Model/voice bank local only; checksums pinned in the generators. Animal noises and 12 babble syllables are original synthesis (assets/audio/animal_vocals.py). |
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

Boss/Dog/Grandma/Kid/Intern/Cat/Mouse SVG cutouts (`assets/art/build_reference.py`,
`assets/art/build_cast.py`), thought icons, all prop SVGs, Bulby,
rig code, greybox shapes, frame/binary lighting shaders, light masks, comic effects,
prototype DING and procedural action sounds are original project work. No external
sound library is used for those effects. Music and stingers are original procedural compositions (`assets/audio/generate_music.py`). No external character art or music has been
added. The only external fonts are Bangers and Comic Neue (OFL, listed above);
Godot's default font and dependencies are covered by the included engine notices. The preview server has no npm dependencies.

## Cast source drawing generation — 2026-10-06

OpenAI built-in imagegen produced 14 original source PNGs in assets/art/story/:
prof, kassi, saap, prompt, aunty, faccha and dassi masters and expression sheets.
Inputs were the project's existing original expression contact sheet and the new
Professor drawings, with each new master used for its own expression identity.
No external character reference, stock asset or new font was used. Generated output
is governed by the OpenAI service terms already linked above; no open-source license
is asserted. Base prompts: assets/production/cast_art_prompts.json. Validation and
resampling sizes: assets/production/cast_art_validation.json. Source art only,
not integrated into runtime rigs by this batch.

Cover/logo (2026-10-06): OpenAI built-in imagegen produced original promotional
art in assets/art/branding/, using only existing project Professor/Kassi masters
and campus canteen painting as references. Logo uses the generated cover as its
reference. Same service-term provenance as the generated art above; no external
stock image or font was supplied. Exact prompts: assets/production/branding_art.json.
Not integrated into the runtime by this asset-only delivery.
