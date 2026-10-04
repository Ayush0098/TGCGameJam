# LIGHTBULB MOMENT voice pack

Delivered 2026-10-04:115 individually named MP3 files, mono44.1kHz.
31 narrator lines in narrator/,56 reactions and28 blips in characters/.
All stems/names match the supplied request; bracketed directions are never read.
request.md preserves the supplied brief. manifest.json contains exact dialogue,
directions, profiles, paths, durations, hashes and per-file decoded metrics.

## Voices and delivery

Narrator af_heart and Boss bm_george retain the earlier voice direction.
Grandma bf_lily; Kid af_sky; Intern am_puck; Dog am_santa; Cat af_nicole;
Mouse af_sky with distinct cartoon pitch. Character profiles are consistent.
Per-cue pace follows slow/fierce/panicked directions where supported.
Local Kokoro is speech synthesis: it does not guarantee directed acting, yawns,
stammers, exact emphasis or convincing bark/hiss performances. Human listening
review remains required, especially the very short interjections/animal words.

Four cues without spoken words (dog_sleep,cat_sleep,cat_clash,mouse_sleep) and
12 animal blips use original harmonic/breath synthesis in animal_vocals.py.
They are stylized synthetic vocalizations, not recordings of animal performers.
All28 blips are approximately0.15s. Spoken animal lines retain the quoted text.

## Production and checks

Existing offline environment only; no new dependency/model installation or paid
speech service. generate_voice_pack.py reproduces the pack from request.md.
Windowed-sinc resampling, small cartoon pitch shifts, silence trim, short fades,
gentle compression and active-speech RMS matching. No music, echo or added FX.
Lossless masters and cache stay under ignored .codex/tools/voice/production_masters/.
MP3s are decoded and checked, rather than only inspecting inference samples.

quality_report.json:115 files,180.676s total, active RMS −20.88 to−18.37dBFS,
maximum decoded peak0.79947, maximum edge silence0.0115s. These are measured
waveform properties, not perceptual loudness/acting or pronunciation approval.
voice_preview.wav samples all eight voices plus synthesized dog/cat sleep;
preview_order.json provides cue times. This preview is separate from game cues.

## Integration handoff

This request delivers production files under root assets/audio/voice/.
They have not been copied to src/assets/audio/voice/ or wired into gameplay by
this batch. The existing optional runtime loader can consume matching names.
Integrate with correct subtitles, dark-character silence, event timing and
skip/rewind cancellation; test after integration. Keep preview/production tools
out of the exported game. Pages5/9 scripts are deferred as requested.

Preserved supplied wording even where presentation needs reconciliation:
narr_nap_intro refers to a fire, narr_snack_intro to a fridge; neither fixture
appears in current empty-shell paintings. Check story context before integration.
narr_finale_end is a short requested closing line, not the approved90–120s epilogue.

Actual external resources are inventoried in root THIRD_PARTY.md.
