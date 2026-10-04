# Production assets

Masters and authoring scripts live here. Godot imports only game-ready copies in
`src/assets/`. Models, environments and build outputs stay in ignored local folders.

## Current library

- `audio/voice/`:222 mono44.1kHz MP3s (110 narrator,84 reactions,28 blips),
  exact names, metadata/quality report and audition preview. Recorded production
  through Parts F/G, with new British narrator and old fallbacks retained.
  Runtime copies/subtitles updated; listening/story sequencing review pending. Four
  wordless animal reactions/12 animal blips are original synthesis. See its README.

- `art/backgrounds/kitchen_stage.png` and `office_stage.png`: companion playable
  paintings,1672×941 each, empty vintage architectural shells. Exact source prompts
  and living-room reference provenance: `production/kitchen_stage.json` and
  `production/office_stage.json`. Native crop/night lighting checked; user review
  pending. Runtime copies use existing page room assignments.

- `art/backgrounds/living_room_stage.png`: current playable room,1672×941; painted
  vintage cool interior/fine paper grain, no halftone/props/baked light pools.
  Source crop20–84%, actual seam near stage331. Original reference painting stays
  available for historical gallery comparison.
- `art/props/`: original cake/consumed cake, dog bed, lantern and fixed fixture SVGs.
- `art/characters/{boss,dog}/`: original layered SVG masters, expression overlays,
  assembled previews and fixed-pivot rig metadata. Seven revised feelings each.
- `art/thoughts/`: four established original thought icons.
- `audio/reference_cues.json`, `audio/reference/`: original audition scripts/WAVs.
  Current narrator/Boss voices accepted provisionally; full narration still pending.
- `production/asset_manifest.json`: produced reference versus planned library.
- `production/background_reference.json`: painted-room production provenance.
- `production/living_room_stage.json`: full new room prompt, crop and inspection.

## Authoring and runtime copies

- `art/build_reference.py` writes original SVG masters/runtime copies and rigs.
- `audio/generate_reference.py` documents isolated local Kokoro setup and writes
  WAV/Ogg/cue metadata. Lockfile/license inventory are beside it. Models/voice bank
  are hash-pinned; recordings alone enter the runtime export.
- `production/build_manifest.py` checks files and builds the runtime reference map.
- Production asset_manifest includes manual playable-integration entries. The old
  reference generator preserves independently produced stage entries and the
  current planned inventory. Runtime gallery map remains unchanged.
- Reimport in Godot after asset generation. Both export presets explicitly include
  raw JSON; production scripts remain outside the Godot resource root.
- Animation poses/tracks live in `src/presentation/character_actor.gd`; current
  reference gallery scales Boss to about 48% room height, Dog to about 60% Boss.

External resources actually used are inventoried in root `THIRD_PARTY.md`.
The ten-level campaign and remaining production library are not completed.
Current next action is playable Nap Time visual review, then pages4/6. Existing
voice cues used for intro/conditional success remain short auditions, not final
15–25s winning narration. No public release acceptance is implied.
