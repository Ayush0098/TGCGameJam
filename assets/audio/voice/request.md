# Voice line request for ChatGPT (narrator + characters)

How to use: paste **Part A** into ChatGPT first (it sets the voices and the file rules), then paste the scripts **one part at a time** (B, then C, then D), so each reply stays small. Ask it to make **one audio file per line** with the exact file names given.

Save the files in your game folder as:

- `assets/audio/voice/narrator/` for Part B
- `assets/audio/voice/characters/` for Parts C and D

Then tell me. I'll check each file (names, length, loudness, clipping), trim the silence, convert to the game's format, and wire them in. Any line that's missing just shows as text, so partial batches are fine.

Pages 5 (Musical Chairs) and 9 (Power Cut) aren't final yet. Their narrator lines will come as a short extra request once the level design is final. Everything below is safe to make now.

---

## Part A: paste this first

```
I'm making a short comic-strip puzzle game called "Lightbulb Moment". I need voice
lines as separate audio files, made with text-to-speech or your voice generation.

Rules for every file:
- One line per file, named exactly as I give (e.g. narr_title.mp3).
- Format: MP3 or WAV, mono, 44.1 kHz. No music, no sound effects, no room echo.
- Start speaking right away; no more than 0.1 s of silence before or after.
- All files at about the same loudness; nothing distorted or clipped.
- Speak only the words in quotes. Text in [brackets] is acting direction, not words.
- Use the same voice for a character in every file.

Voices:
- NARRATOR: warm, wry, slightly theatrical old-time newspaper/radio announcer.
  Medium pace, a little dry humour, smiles on the punchlines. Adult, any gender.
- BOSS: blustery, self-important middle-aged office boss. Loud, a bit pompous.
- GRANDMA: sweet, soft elderly lady who turns out to have a surprising bite.
- KID: bouncy, cheeky cartoon kid. Young-sounding, high energy.
- INTERN: nervous, polite young office worker. Slightly squeaky, stammers a little.
- DOG: a human doing a goofy cartoon dog: barks, growls, happy panting. Few words.
- CAT: a human doing a haughty cartoon cat: meows, purrs, hisses. Few words.
- MOUSE: a human doing a tiny, very high cartoon mouse: squeaks. Few words.

Please confirm the voices, then I'll send the scripts in parts.
```

---

## Part B: narrator (31 lines)

```
NARRATOR lines. One file per line, named as shown.

narr_title.mp3            "The Daily Bulb presents... Lightbulb Moment!"
narr_sunday.mp3           "Hot off the press! Pick a page, any page."
narr_fail_1.mp3           "The End...? Hmm. Not quite."
narr_fail_2.mp3           "Well. That's one way to end it."
narr_nearmiss.mp3         [excited, then deflating] "So close! One more step!"
narr_twist.mp3            [big, proud] "TWIST!"
narr_finale_end.mp3       [warm, slow] "And that, dear readers, is how everyone had a bright idea. The End. Really, this time."

narr_dinner_intro.mp3     "Dinner time. Two hungry mouths. One fish."
narr_dinner_original.mp3  [deadpan] "The Dog ate the fish. As usual."
narr_dinner_twist.mp3     "The CAT ate the fish! The Dog never saw it coming. Literally."

narr_nap_intro.mp3        "A lazy afternoon. The fire is warm, the cake is waiting, and the Boss has plans."
narr_nap_original.mp3     [deadpan] "The Boss ate the cake. Nobody was surprised."
narr_nap_twist.mp3        "The DOG ate the cake, and the Boss napped in the dog bed. Promotion denied."

narr_greens_intro.mp3     "The Kid has a choice: a cookie, or broccoli. Guess which."
narr_greens_original.mp3  [deadpan] "The Kid ate the cookie. Of course he did."
narr_greens_twist.mp3     [amazed] "The Kid ate the BROCCOLI! Stop the presses!"

narr_snack_intro.mp3      [hushed] "Midnight. One pie. The fridge hums. Everyone is definitely asleep."
narr_snack_original.mp3   "The Kid ate the pie, and the Cat ran clean out of the comic."
narr_snack_twist.mp3      "The DOG ate the pie! The Kid slept through the whole thing."

narr_catmouse_intro.mp3   "Cat. Mouse. You know how this one goes."
narr_catmouse_original.mp3 "The Cat chased the Mouse right out of the comic."
narr_catmouse_twist.mp3   "The MOUSE chased the CAT out of the comic, and the Dog got the cheese!"

narr_birthday_intro.mp3   "It's the Boss's birthday. There is cake. There is always cake."
narr_birthday_original.mp3 [deadpan] "The Boss ate his own birthday cake. Happy birthday, Boss."
narr_birthday_twist.mp3   "The DOG ate the Boss's cake! Best birthday ever. For the Dog."

narr_revenge_intro.mp3    [conspiratorial] "Grandma is in a mood. Nobody knows why. Nobody dares to ask."
narr_revenge_original.mp3 "Grandma bonked the Dog. Poor Dog."
narr_revenge_twist.mp3    "Grandma bonked the BOSS, and the Dog got the cake! Justice, served with frosting."

narr_finale_intro.mp3     "Late at the office. The lights are out, and so are the ideas."
narr_finale_original.mp3  [deadpan] "The Boss and the Intern had the same bad idea."
narr_finale_twist.mp3     [triumphant] "EVERYONE had a lightbulb moment!"
```

---

## Part C: character lines (56 lines)

These are short reactions, one per moment. Characters only speak when they're lit, and the "wake" line must sound the same whatever the character wants, so keep the wake lines neutral (just surprised, no hint of hunger, anger, sleepiness or fear).

```
CHARACTER lines. One file per line, named as shown.

Moments: wake = just noticed the light (neutral, curious) | eat = eating happily |
sleep = sitting down to nap | bonk = hitting someone | bonked = got hit |
flee = running away scared | clash = two grab the same thing | huh = confused,
can't find what they want.

BOSS
boss_wake.mp3      "Hm?"
boss_eat.mp3       "Mine! Mmm-hmm!"
boss_sleep.mp3     [settling down, yawning] "Five... minutes..."
boss_bonk.mp3      "Outta my way!"
boss_bonked.mp3    "OOF!"
boss_flee.mp3      [panicking] "This is NOT in my contract!"
boss_clash.mp3     "Hey! That's MINE!"
boss_huh.mp3       "Hmph. Where'd it go?"

GRANDMA
grandma_wake.mp3   "Oh? My my."
grandma_eat.mp3    "Ooh, lovely."
grandma_sleep.mp3  [sweetly] "Just resting my eyes, dear."
grandma_bonk.mp3   [fierce] "Take THAT!"
grandma_bonked.mp3 "Oh! My hip!"
grandma_flee.mp3   [flustered] "Oh, heavens! Heavens!"
grandma_clash.mp3  "Manners, please!"
grandma_huh.mp3    "Now where did I put it?"

KID
kid_wake.mp3       "Huh?"
kid_eat.mp3        "Yum!"
kid_sleep.mp3      [yawning] "I'm not tired... zzz."
kid_bonk.mp3       "Hi-YAH!"
kid_bonked.mp3     "Ow!"
kid_flee.mp3       "Moooom!"
kid_clash.mp3      "I saw it first!"
kid_huh.mp3        "Hey, where'd it go?"

INTERN
intern_wake.mp3    "Oh! Um... hello?"
intern_eat.mp3     [whispering] "Is this... free?"
intern_sleep.mp3   [relieved sigh] "Finally... a break."
intern_bonk.mp3    "S-sorry! Not sorry!"
intern_bonked.mp3  "Ack!"
intern_flee.mp3    "I quit! I QUIT!"
intern_clash.mp3   "Oh, no, after you... no, after ME!"
intern_huh.mp3     "Um... nobody told me where."

DOG
dog_wake.mp3       [curious] "Wuff?"
dog_eat.mp3        [happy chomping and a short bark] "Rrruff!"
dog_sleep.mp3      [big doggy sigh, then a soft snore]
dog_bonk.mp3       [loud bark] "GRRRUFF!"
dog_bonked.mp3     [yelp] "Yip!"
dog_flee.mp3       [frightened howl] "Awooo!"
dog_clash.mp3      [angry growl] "Grrrr!"
dog_huh.mp3        [puzzled whine] "Hrrm?"

CAT
cat_wake.mp3       [curious] "Mrrp?"
cat_eat.mp3        [smug] "Purrfect."
cat_sleep.mp3      [contented purring]
cat_bonk.mp3       [hiss] "HSSS!"
cat_bonked.mp3     [startled] "Mrow!"
cat_flee.mp3       [yowling] "Mrrraaow!"
cat_clash.mp3      [growling hiss]
cat_huh.mp3        [bored] "Meh."

MOUSE
mouse_wake.mp3     [tiny, curious] "Squeak?"
mouse_eat.mp3      [tiny nibbling] "Nom nom!"
mouse_sleep.mp3    [tiny snore]
mouse_bonk.mp3     [tiny battle cry] "Ha-CHA!"
mouse_bonked.mp3   "Eep!"
mouse_flee.mp3     "Eeeeeek!"
mouse_clash.mp3    "Mine-mine-mine!"
mouse_huh.mp3      [tiny] "Hmm?"
```

---

## Part D: gibberish blips (28 files)

The game plays these under every speech balloon, pitched up and down, like Animal Crossing babble.

```
GIBBERISH syllables. For each character, 4 separate files, each ONE short
nonsense syllable (about 0.15 seconds), in that character's voice and pitch.
Not real words. Example syllables: "ba", "bo", "mi", "pu".

boss_blip_1.mp3 ... boss_blip_4.mp3        (deep, blustery)
grandma_blip_1.mp3 ... grandma_blip_4.mp3  (soft, wobbly)
kid_blip_1.mp3 ... kid_blip_4.mp3          (high, bouncy)
intern_blip_1.mp3 ... intern_blip_4.mp3    (nervous, mid-high)
dog_blip_1.mp3 ... dog_blip_4.mp3          (short "ruf"/"wuf" sounds)
cat_blip_1.mp3 ... cat_blip_4.mp3          (short "mr"/"mew" sounds)
mouse_blip_1.mp3 ... mouse_blip_4.mp3      (very high "pip"/"squi" sounds)
```

---

## If ChatGPT can't make audio files

Some ChatGPT plans only give text, not audio. If it can't save audio files:
- Ask for the files through ChatGPT's code tool ("use Python text-to-speech to save each line as an MP3 and give me a zip"). The quality is plainer but usable.
- Or paste the same scripts into any free text-to-speech site and keep the file names.
- Tell me which way you went, and I'll match the loudness so they sit well together.

Rules the game enforces, whatever the voices sound like: characters in the dark say nothing, and every voiced line also appears as text in its balloon or caption box.
