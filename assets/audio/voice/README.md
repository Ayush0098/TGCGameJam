# LIGHTBULB MOMENT voice pack

## Pages 1–3 Indian English replacement (2026-10-05)

`p1_3/` contains 54 exact-name MP3s (34 narrator, 20 character balloons)
and their script/manifest. They are copied to the matching production and
runtime paths. The two Professor cues now use locally generated Chatterbox
takes with an Indian English reference; Ayush approved their delivery. Chintu's
page 1 lit cue uses three edited real puppy barks rising in pitch and intensity,
with “Biryani” conveyed by the game caption; listening feedback is pending.
The other 51 cues still use the earlier Windows Indian English Ravi/Heera takes
and remain under acting and pronunciation review. `p1_3/manifest.json` records decoded checks and hashes. The older
pack counts and voice profiles below describe the other cues.

To reproduce the earlier Windows voice batch on a machine with those voices: run
`assets/audio/synthesize_p1_3_windows.ps1` with `-Manifest` set to
`p1_3/script.json` and `-OutputDirectory` set to `.codex/tools/voice/p1_3_wav`;
then run `assets/audio/generate_p1_3_indian.py` using the existing offline voice
environment and `assets/audio/import_p1_3_voice.py`. That batch predates the
approved Professor takes and would overwrite them if copied into the game.

Updated 2026-10-04 through Parts F/G:222 named MP3 files, mono44.1kHz.
110 narrator lines in narrator/,84 reactions and28 blips in characters/.
Includes73 new narr15_* lines and28 hug/hugged/hide/jealous reactions.
Old121 files remain available as requested fallbacks.
Part E replaces narr_catmouse_twist and adds six Shadow Play/Power Cut lines.
Later sections override earlier duplicate IDs.114 unchanged MP3s were preserved.
All stems/names match the supplied request; bracketed directions are never read.
request.md preserves the supplied brief. manifest.json contains exact dialogue,
directions, profiles, paths, durations, hashes and per-file decoded metrics.

## Voices and delivery

Narrator af_heart and Boss bm_george retain the earlier voice direction.
New story narrator narr15_* uses distinct British bm_fable, starting at0.92
pace in Act1,0.98 in Act2 and1.04 in Act3, with per-line adjustments. Act cards
use their own act pacing. Clause/sentence pauses support the theatrical delivery.
The finale segments speech around nonverbal laughter generated with the same
profile; [snort]/[wheeze]/[laughing helplessly] are never spoken as words.
The [click] direction is omitted: no separate sound effects are baked into voice.
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

quality_report.json:222 files,783.703s total, active RMS −20.88 to−18.37dBFS,
maximum decoded peak0.90881, maximum edge silence0.0115s. These are measured
waveform properties, not perceptual loudness/acting or pronunciation approval.
voice_preview.wav samples the new narrator, character feelings and final laughter;
preview_order.json provides cue times. This preview is separate from game cues.

## Integration handoff

This request delivers production files under root assets/audio/voice/.
All222 runtime copies in src/assets/audio/voice/ match production hashes.
Narrator captions in lines.json contain110 lines matching recorded words;
new character reaction subtitles were added. Godot import/Web export succeeded.
This audio batch does not implement the new15-page story sequencing, act cards
or new gameplay feelings. The coding thread must select narr15_* keys, connect
new event cues, sequence twist_stamp/win, and use matching captions. Old narr_*
files remain intact. Existing10-page voice selection remains available.
Human listening and full browser timing/privacy/cancellation checks remain pending.
Keep preview/production tools out of the exported game. The Part E/table below
the older deferred-pages note in request.md supplies Shadow Play/Power Cut now.

Preserved supplied wording even where presentation needs reconciliation:
narr_nap_intro refers to a fire, narr_snack_intro to a fridge; neither fixture
appears in current empty-shell paintings. Check story context before integration.
narr_finale_end and narr15_finale_win are requested closing cues; this batch does
not establish a90–120s epilogue or complete campaign acceptance.

Actual external resources are inventoried in root THIRD_PARTY.md.
