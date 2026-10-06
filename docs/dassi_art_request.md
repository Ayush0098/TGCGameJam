# Dassi character art request for ChatGPT

**Status — 2026-10-06:** Dassi used to be drawn as an orange cat. She is a campus
student (a girl; the story says "she", and she talks and hugs like a person), so the
cat art and the cat meow sounds are being replaced. A stand-in is already in the game:
a re-skin of the Saap/kid cutout rig (long dark hair with a gold clip, teal striped
top, jeans, pink sneakers; `assets/production/make_dassi_rig.py`), with new human
sounds (`dassi_*` files). This request is for the real art. **Please confirm the
look below with a quick yes or edit it before pasting.**

Paste each request into ChatGPT's image generator as written. They match the brief
style of the existing cast and room requests, so Dassi sits in the same storybook
world as Saap, Prompt Bhai, Mess Aunty and the Prof.

When you have them, save the images as:

- `assets/art/story/dassi_master.png`
- `assets/art/story/dassi_faces.png`

Then tell me. I'll slice the master into the cutout parts (head, torso, two arms,
two legs, hair), build the rig with the same pivots as the other humans, drop the
faces on top, check every action (walk, eat, sit, sleep, bonk, run, celebrate), and
switch Dassi over.

What I check before using a drawing:

- Same flat-colour, thick dark-outline cartoon style as the existing cast (round
  head, small body, about 3 heads tall), so she does not look like a different game.
- Plain transparent or flat pale-grey background, nothing behind her.
- Whole body inside the frame with room around it; arms slightly away from the body.
- Clearly a student, clearly not a cat: no ears, whiskers, tail or fur.
- No text, logos or watermark.

If a result breaks one of these, ask ChatGPT for a short follow-up, e.g. "same
drawing, but give her arms a little more space from the body".

---

## Request 1: Dassi, full body

```
Use case: illustration-story.
Asset type: production character art for a 2D side-on storybook puzzle game, LIGHTBULB MOMENT (an IIIT Hyderabad campus comic). One full-body character on a plain flat pale-grey background, square canvas 2048 by 2048 pixels.

Primary request: DASSI, an Indian engineering-college student, a cheerful, slightly dramatic girl, drawn as a chunky cartoon character about 3 heads tall: big round head, small body, short arms and legs. Long straight black hair with a side parting and a small gold star hair clip, small gold earrings, warm brown skin with rosy cheeks. She wears a teal striped T-shirt (cream stripes), dark blue jeans and pink-and-white sneakers, and carries nothing. Neutral standing pose facing the viewer, feet apart, both arms hanging a little away from the body so the arms and legs can be cut out cleanly. Friendly closed-mouth smile, big eyes with small eyelashes.

Style: flat storybook cartoon colour with a thick dark-plum outline (about 5 percent of the head width), two-tone cel shading (one light tone and one shadow tone per colour), no gradients, no texture, no soft shadows. Same look as a cutout puppet: simple shapes, clean outlines. Match the existing cast of the game (Saap: a boy with spiky brown hair and a red striped T-shirt; Prompt Bhai; Mess Aunty; the Prof).

Constraints: no cat features of any kind (no ears, whiskers, tail, fur, paws), no props, no bag, no phone, no text, no logos, no watermark, no cast shadow, no background scenery. Keep the whole figure, including shoes, inside the frame with a margin.
```

## Request 2: Dassi, faces

```
Use case: illustration-story.
Asset type: expression sheet for the same character, DASSI, matching the full-body drawing from Request 1 exactly (same head shape, hair, eyes, eyelashes, earrings, colours, outline thickness). One image, 2048 by 1152 pixels, plain flat pale-grey background.

Primary request: seven heads of DASSI, each drawn from the front at the same size and in a single row of 4 plus a row of 3, evenly spaced, no overlaps, each labelled in small neat caps underneath: NEUTRAL (calm half-smile), PLEASED (big happy smile, eyes curved shut), HUNGRY (eyes wide, tongue licking lips), SLEEPY (heavy half-closed eyes, small yawn), ANGRY (furrowed brows, gritted teeth), FRIGHTENED (wide eyes, small pupils, wobbly mouth, one sweat drop), SURPRISED (round eyes, small round open mouth). Hair and ears are identical in every head so the faces can be swapped onto one body.

Style: flat storybook cartoon colour with a thick dark-plum outline, two-tone cel shading, no gradients, no texture, no soft shadows.

Constraints: no cat features, no props, no text other than the seven small labels, no logos, no watermark.
```

---

## Sound

Dassi's blips and reactions (`dassi_blip_1..4`, `dassi_eat`, `dassi_bonk`, `dassi_hug`,
`dassi_flee`, ...) are short human sounds generated with her Indian English voice
(`.codex/tools/voice/generate_dassi_sfx.py`). They replace the cat meows in the game.
