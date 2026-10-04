# Runtime assets

Put assets referenced by Godot here: `res://assets/` resolves inside `src/`.
The repository's root `assets/` directory is available for source artwork and
production files; files outside `src/` are not imported into the Godot project.

`reference_manifest.json` maps stable art IDs to textures, cutout pivots,
expressions, animation sets and dialogue cue metadata. Both export presets
explicitly include raw JSON. Batch 1 contains the living room, Boss/Dog rigs,
four thoughts and three recorded voice auditions.

Boss/Dog faces have been revised for stronger feelings at smaller stage sizes;
the Boss moustache is part of each facial overlay. Rig pivots stay unchanged.
`backgrounds/living_room_stage.png` is the current playable painting:1672×941,
cropped20–84%, vintage cool storybook/fine paper grain. Original reference painting
remains gallery history. `props/` adds original cake/consumed cake, dog bed, lantern
and fixed-light fixture. Presentation applies shared background masks and binary
actor/prop grades; no pencil or halftone shader. Integration is checked; awaiting user visual review.
Current voice auditions are accepted provisionally and used for intro/conditional
Nap Time success; full scene/finale recordings remain future production.

Do not put speech models, Python environments or production scripts here.
