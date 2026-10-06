# Cast art request for ChatGPT (every character that needs new art)

**Update — 2026-10-06:** the ChatGPT art for all seven characters arrived and is in the game (`assets/production/slice_cast_art.py` cuts each master and faces sheet into the cutout rig). Everything below is kept as the record of the brief.

**Status — 2026-10-06 (earlier):** the whole cast was drawn as the old family / animal archetypes
(a dad, an office intern, a boy, a granny, a mouse, a cat). The story says otherwise, so every
character except **Chintu (stays a dog, no new art needed)** gets new art. Stand-ins are
already in the game: re-skins of the existing cutout rigs built by
`assets/production/make_cast_rigs.py` (Prof with grey hair and specs, Kassi with a
backpack and ID lanyard, Saap in a snake beanie, Prompt Bhai in a code tee and
headphones, Mess Aunty in a saree with a ladle, Faccha with a huge backpack and a
FRESHER card, Dassi as a topper with specs). Each has new human reaction sounds and an
idle in character. This request is for the real drawings. **Please check the looks
below (they are my reading of each name and role) and edit anything before pasting.**

How to use: open a **new** ChatGPT image chat for each character. Paste that
character's **Full body** request, then (same chat) its **Faces** request. If the style
drifts, add: "same style as the first image, thicker outline, flat colours only".

Save the images as, per character (the art ids are the file names):

- `assets/art/story/<art>_master.png` (full body)
- `assets/art/story/<art>_faces.png` (seven faces)

with art ids `prof`, `kassi`, `saap`, `prompt`, `aunty`, `faccha`, `dassi`. Then tell me. I
slice each master into the cutout parts (head, torso, arms, legs, hair), build the rig
with the same pivots as the others, put the faces on top, test every action (walk, eat,
sit, sleep, bonk, run, celebrate) and swap it in.

What I check before using a drawing:

- Same flat-colour, thick-outline cartoon style across the whole cast, so nobody looks
  like a different game.
- Plain flat pale-grey background; whole body inside the frame with a margin; arms a little
  away from the body so they can be cut out.
- Clearly a person with the described props, no animal features, no text or logos
  (the only text allowed is the small face labels), no watermark.

---

## Shared style line (already inside every request below)

```
flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).
```

## PROF (`prof`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: the Professor: a pompous, self-important middle-aged Indian professor, slow and proud, chest slightly puffed, chin lifted. Grey-white swept-back hair with grey sideburns, thick grey moustache, round gold-rimmed spectacles. Wears a pale sage-green full-sleeve shirt, a maroon tweed waistcoat with three buttons and a small gold bow tie, a gold watch chain, a blue pen clipped in the waistcoat pocket, dark trousers and polished black shoes. Medium-brown skin. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Calm, slightly smug half-smile.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, PROF, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of PROF, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Calm, slightly smug half-smile.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## KASSI (`kassi`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Kassi: an eager, nervous second-year student with very dark brown skin. Short black hair, round dark-blue spectacles, one small sweat drop at the temple. Wears a mustard-yellow shirt with a loose red tie, a green lanyard with a college ID card, two dark-navy backpack straps over the shoulders, khaki trousers and brown shoes. Slightly hunched, shoulders up, hands held nervously in front. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Worried, polite half-smile, brows slightly raised.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, KASSI, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of KASSI, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Worried, polite half-smile, brows slightly raised.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## SAAP (`saap`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Saap (the word means snake): the lazy, smug 'bro, I didn't even study' topper. Heavy half-closed eyelids, a lopsided smirk, relaxed slouch with a slight lean. Wears a snake-green beanie with two yellow slit-pupil snake eyes on the front, a green hoodie with a snake-scale pattern, dark-blue shorts and red sneakers. Warm brown skin, no hair showing. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Sleepy, smug, half-lidded eyes.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, SAAP, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of SAAP, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Sleepy, smug, half-lidded eyes.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## PROMPT BHAI (`prompt`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Prompt Bhai: the cheerful, fast-talking student who thinks ChatGPT will win every fest event. Spiky black hair, huge grin, wears an electric-blue T-shirt with a white code symbol </> on the chest, black over-ear headphones resting round his neck, dark-blue shorts and white sneakers. Bouncy energetic stance, one hand slightly raised. Warm brown skin. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Big excited grin, wide bright eyes.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, PROMPT BHAI, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of PROMPT BHAI, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Big excited grin, wide bright eyes.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## MESS AUNTY (`aunty`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Mess Aunty: the warm, motherly South Indian (Telugu) mess aunty with a hint of menace. Black hair with one grey streak in a round bun with white jasmine flowers, red bindi, small gold earrings, gold bangles. Wears a crimson saree with a gold border and a gold pallu across the chest, holds a big steel serving ladle in her right hand like a sceptre. Rounder, sturdier build, warm medium-brown skin. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Warm motherly smile with a tiny knowing twinkle.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, MESS AUNTY, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of MESS AUNTY, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Warm motherly smile with a tiny knowing twinkle.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## FACCHA (`faccha`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Faccha (a first-year fresher): a lost, wide-eyed, slightly squeaky boy, a little smaller than the others. Spiky black hair, huge worried eyes, brows tilted up in the middle. Wears a pale-yellow T-shirt, an enormous red backpack that is too big for him with two straps, a green lanyard with a white ID card that has a red FRESHER stripe, blue-grey trousers and blue sneakers. Holds a crumpled campus map in one hand. Warm brown skin. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Lost, wide-eyed, nervous.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, FACCHA, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of FACCHA, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Lost, wide-eyed, nervous.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

## DASSI (`dassi`)

### Full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: Dassi: the 10-CGPA topper, crisp, precise and a little haughty. Long straight black hair with a side parting and a small gold star hair clip, thin round dark-rose spectacles with small eyelashes, small gold earrings. Wears a teal T-shirt with cream stripes, dark-blue jeans and pink-and-white sneakers; chin slightly lifted, one hand holding a thick notebook against her chest. Warm brown skin. Clearly a girl student, nothing cat-like: no ears, whiskers, tail or fur. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Expression: Poised, slightly superior half-smile.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features of any kind, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

### Faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, DASSI, matching the full-body drawing exactly (same head shape, hair, spectacles/accessories, skin tone, colours and outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of DASSI, each drawn from the front at the same size, one row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL, PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and accessories are identical in every head so the faces can be swapped onto one body. NEUTRAL for this character: Poised, slightly superior half-smile.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. A chunky cutout-puppet look: simple shapes, clean outlines, about 3 heads tall, big round head, small body, short arms and legs. The same look as the existing cast of the game (the red-striped-shirt boy, Mess Aunty, the Prof).

Constraints: no animal features, no props, no text other than the seven small labels, no logos, no watermark.
```

---

## Sounds

Every character except Chintu now has short human blips and reactions in their own voice
(`<art>_blip_1..4`, `<art>_eat`, `<art>_bonk`, `<art>_hug`, `<art>_flee`, ... under
`src/assets/audio/voice/characters/`), generated with the local voice model from the
Indian English references (`.codex/tools/voice/generate_cast_sfx.py`, text in
`assets/audio/voice/cast_reactions.json`). Chintu's barks are unchanged.
