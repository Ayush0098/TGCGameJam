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

---

## Part E: second request (new and changed pages), paste after A–D

The level plan changed after Part B: Cat & Mouse has a new twist, and there are two new pages, Shadow Play (7) and Power Cut (9). Paste Part A again if it's a new ChatGPT chat, then this. Save in `assets/audio/voice/narrator/` like Part B. `narr_catmouse_twist` **replaces** the old file of the same name.

```
More NARRATOR lines, same voice and rules as before. One file per line.

narr_catmouse_twist.mp3    "The MOUSE bonked the CAT, and the Dog got the cheese! Small, but furious."

narr_shadow_intro.mp3      "Grandma rules the living room. A tall bookshelf hides the cake, and its shadow hides more."
narr_shadow_original.mp3   [deadpan] "Grandma bonked the Kid. Again."
narr_shadow_twist.mp3      "The BOSS bonked GRANDMA! Grandma has met her match."

narr_powercut_intro.mp3    [hushed] "The power's out. Only your bulb, one lamp pedal and one spare bulb. The cake is somewhere in the dark."
narr_powercut_original.mp3 "The Mouse ran right out of the comic."
narr_powercut_twist.mp3    "The Mouse napped in the armchair, and the DOG ate the cake. Good Dog."
```

---

## For the coding thread: how voice maps to page text

The page files from the level thread (`levels_solver/pages/page_NN.gd`) have their own `narration` wording, written before the voices were recorded. **Where a line is voiced, the caption shows the voiced wording**, so text and voice always match:

| Page | Intro caption + voice | Original ending | Win caption + voice | Fail |
|---|---|---|---|---|
| 1 Dinner Time | `narr_dinner_intro` | `narr_dinner_original` | `narr_dinner_twist` | page `fail` text + `narr_fail_1/2` alternating |
| 2 Nap Time | `narr_nap_intro` | `narr_nap_original` | `narr_nap_twist` | same |
| 3 Eat Your Greens | `narr_greens_intro` | `narr_greens_original` | `narr_greens_twist` | same |
| 4 Midnight Snack | `narr_snack_intro` | `narr_snack_original` | `narr_snack_twist` | same |
| 5 Cat & Mouse | `narr_catmouse_intro` | `narr_catmouse_original` | `narr_catmouse_twist` (Part E) | same |
| 6 Boss's Birthday | `narr_birthday_intro` | `narr_birthday_original` | `narr_birthday_twist` | same |
| 7 Shadow Play | `narr_shadow_intro` (Part E) | `narr_shadow_original` | `narr_shadow_twist` | same |
| 8 Grandma's Revenge | `narr_revenge_intro` | `narr_revenge_original` | `narr_revenge_twist` | same |
| 9 Power Cut | `narr_powercut_intro` (Part E) | `narr_powercut_original` | `narr_powercut_twist` | same |
| 10 Lightbulb Moment | `narr_finale_intro` | `narr_finale_original` | `narr_finale_twist`, then `narr_finale_end` | same |

- The page file's `win` sentence can stay as a second, unvoiced line under the stamp if it fits; otherwise drop it.
- Fail: the page's own `fail` sentence is the caption (text); the voice plays `narr_fail_1` or `narr_fail_2`, or `narr_nearmiss` when the near-miss callout fires.
- Page-specific `dialogue` lines in the page files (lit / swap / win / fail) are **speech balloons with blips, not voiced**. The voiced character files (Part C) play on events (eat, sleep, bonk, bonked, flee, clash, huh) and on first wake. If both would play at once, the voiced event line wins and the balloon shows its text.
- Tutorial panel captions on page 1 are text only.
- Any missing file falls back to text silently.

---

## Part F: the NEW narrator (story thread, 2026-10-04)

The story was rewritten for 15 pages (`design/story.md`). The narrator is now a character: a **pompous storyteller who slowly loses his mind** as you wreck his comic. That's a different voice, so **all narrator lines are re-recorded** with new file names (`narr15_...`). Keep the old files until these arrive; the game falls back to text for anything missing.

Paste **F0** first in a new ChatGPT chat (or after Part A in the old one), then F1, F2, F3 one at a time. Save in `assets/audio/voice/narrator/`.

### F0: the new narrator voice (paste first)

```
New voice for the same game. Same file rules as before (one line per file, exact
file names, MP3 or WAV mono 44.1 kHz, no music/effects, <=0.1 s silence at the ends,
even loudness, [brackets] are acting directions, not words).

NARRATOR (new): a pompous, very posh, theatrical storyteller, like an old-fashioned
radio announcer who thinks he's a genius. Grand, slow, self-satisfied at first.
As the game goes on (Act 1 -> Act 2 -> Act 3) he gets more flustered, offended and
desperate, and in the very last line he finally collapses into helpless laughter.
Comic timing matters: tiny pause before the punchline of each line, deadpan on
words in CAPITALS (he is outraged by them). Adult, any gender.

Please confirm the voice, then I'll send the scripts in three parts.
```
### F1: Act 1, pages 1–5 (33 lines)

```
NARRATOR lines, new voice. One file per line, named as shown.

narr15_title.mp3                  "The Bulb Family Funnies! Narrated by me. Obviously."
narr15_twist_stamp.mp3            [outraged] "TWIST?!"
narr15_nearmiss.mp3               [relieved] "Ha! Almost! Almost ruined it. Not quite."
narr15_fail_1.mp3                 "Ah. My ending. Lovely."
narr15_fail_2.mp3                 [smug] "As written. As intended. As it should be."
narr15_fail_3.mp3                 "Nice try, lamp."
narr15_fail_4.mp3                 [relieved sigh] "Oh, thank goodness."
narr15_new_shy.mp3                "New feeling! SHY. Shine a light on them and they run for the nearest shadow."
narr15_new_love.mp3               "New feeling! IN LOVE. They hug the nearest person, and the love spreads. Disgusting."
narr15_new_jealous.mp3            "New feeling! JEALOUS. They want whatever the nearest person wants. Just like real people."
narr15_act1.mp3                   "Good evening. I am the Narrator. I have narrated four thousand comics, and not one of them has ever had a twist. Please keep your hands, paws and lamps inside the margins."
narr15_act2.mp3                   "Act Two. I have spoken to my lawyer. My lawyer says lamps cannot be sued. My lawyer is also a lamp now. I don't want to talk about it."
narr15_act3.mp3                   "Act Three. No more Mister Nice Narrator. I know where the fuse box is."

narr15_dinner_intro.mp3           "Dinner at the Bulb house. Every night for eleven years, the Dog has eaten the fish. It is a classic. It is tradition. It is, frankly, the only joke I have."
narr15_dinner_original.mp3        "The Dog ate the fish. Ha. Ha ha. Classic."
narr15_dinner_twist.mp3           "The CAT ate the fish."
narr15_dinner_win.mp3             "The CAT ate the... Who moved my lamp? Somebody MOVED my LAMP."

narr15_greens_intro.mp3           "Page two. A boy. A cookie. And a head of broccoli that has sat on that table, untouched, since 2009. The broccoli is decorative."
narr15_greens_original.mp3        "The Kid ate the cookie. Of course he did. He's a child, not a rabbit."
narr15_greens_twist.mp3           "The Kid ate the BROCCOLI."
narr15_greens_win.mp3             "A child. Ate broccoli. On purpose. Nobody is going to believe this. I'm not sure I believe this. Somebody check him for a fever."

narr15_nap_intro.mp3              "Sunday. The Boss has invited himself over, which is how the Boss gets invited anywhere. There is cake. Today, the Boss eats his first cake. Boss Cake Count: zero. For now."
narr15_nap_original.mp3           "The Boss ate the cake. Hard work pays off."
narr15_nap_twist.mp3              "The DOG ate the cake. The BOSS napped in the dog bed."
narr15_nap_win.mp3                "The Dog ate the Boss's cake, and the Boss is asleep in a dog bed, drooling on a squeaky bone. Boss Cake Count: still zero. The Dog has been promoted."

narr15_snack_intro.mp3            "Midnight. The Kid creeps towards the last slice of pie. Grandma is asleep. The Cat is terrified of the Kid, for reasons we do not discuss."
narr15_snack_original.mp3         "The Kid ate the pie, and the Cat ran clean out of the comic. Crime pays."
narr15_snack_twist.mp3            "The DOG ate the pie."
narr15_snack_win.mp3              "The Kid fell asleep in an armchair halfway through a crime, and the Dog ate the evidence. Best-organised heist this house has ever seen."

narr15_stage_intro.mp3            "The Bulb Family Talent Show! The Kid will sing. The Kid is shy, so the Kid will not sing. The Boss will do impressions of himself. There is a prize cake."
narr15_stage_original.mp3         "The Kid hid from the spotlight. The talent show was cancelled due to a lack of talent."
narr15_stage_twist.mp3            "The BOSS hid from the spotlight. The DOG ate the prize cake."
narr15_stage_win.mp3              "The Boss, a man who once gave a ninety-minute speech about his own parking space, hid from a lightbulb. The Dog won the talent show. His talent was cake. Boss Cake Count: still zero."
```
### F2: Act 2, pages 6–10 (20 lines)

```
NARRATOR lines, new voice. One file per line, named as shown.

narr15_birthday_intro.mp3         "It's the Boss's birthday. He planned the party himself, sent himself a card, and signed it 'from everyone'. This year he WILL eat the cake. Boss Cake Count: zero. That changes today."
narr15_birthday_original.mp3      "The Boss ate his birthday cake. Finally. Happy birthday, sir."
narr15_birthday_twist.mp3         "The DOG ate the birthday cake."
narr15_birthday_win.mp3           "Happy birthday, Boss. The Dog says thank you for the cake. Boss Cake Count: zero. Dog Cake Count: I've stopped counting. The Dog has his own accountant now."

narr15_revenge_intro.mp3          "Sweet, gentle Grandma. She knits. She bakes. She has bonked eleven people this week, and it's Tuesday. Tonight she is coming for the Dog."
narr15_revenge_original.mp3       "Grandma bonked the Dog. The Dog had it coming. Probably."
narr15_revenge_twist.mp3          "Grandma bonked the BOSS. The DOG ate the cake."
narr15_revenge_win.mp3            "Grandma bonked the Boss at his own leftover-birthday-cake party, and the Dog ate the leftovers. Boss Cake Count: still zero. I'm starting to think it's personal."

narr15_date_intro.mp3             "The office party. The Intern, Gary, is in love with the Boss. The Boss is furious about everything. The Cat is here for the free buffet. Nobody knows why Grandma is here."
narr15_date_original.mp3          "The Intern hugged the Boss. HR has been notified. HR has notified HR."
narr15_date_twist.mp3             "The Intern hugged the Boss. The Boss hugged GRANDMA."
narr15_date_win.mp3               "The Intern hugged the Boss. The Boss hugged Grandma. Grandma has booked a church. I wrote a workplace drama, and you have turned it into a romance. A horrible, beautiful romance."

narr15_shadow_intro.mp3           "Lamp, listen. Let's make a deal. You leave this page alone, and I'll write you a page of your own. You can be the hero. A lamp hero. Grandma bonks the Kid behind a bookshelf. Lovely. Nobody touch it."
narr15_shadow_original.mp3        "Grandma bonked the Kid. He knows what he did."
narr15_shadow_twist.mp3           "The BOSS bonked GRANDMA."
narr15_shadow_win.mp3             "The Boss bonked Grandma. GRANDMA. I'll have to phone Grandma's lawyer. Grandma IS Grandma's lawyer. We had a DEAL, lamp."

narr15_slice_intro.mp3            "The morning after the Boss's birthday. One slice of cake survived. One. And the Intern, Doug? Dave? Doug, is jealous of everyone. Which is fair. Nobody has ever invited him to anything."
narr15_slice_original.mp3         "Grandma ate the last slice. The Boss ran off screaming. The Dog slept through it. A quiet morning."
narr15_slice_twist.mp3            "Grandma and the Dog CLONKED heads over the armchair. The INTERN ate the last slice."
narr15_slice_win.mp3              "The Intern ate the last slice. The INTERN. He wasn't even invited to this PAGE. Meanwhile Grandma and the Dog knocked each other out over an armchair neither of them owns. Boss Cake Count: zero. Intern Cake Count: ONE. The Boss has asked HR to investigate."
```
### F3: Act 3, pages 11–15 (20 lines)

```
NARRATOR lines, new voice. One file per line, named as shown.

narr15_powercut_intro.mp3         "Right. If you're going to ruin my comic, you can ruin it in the DARK. [click] There. Power's off. Good luck twisting what you can't see, lamp. ...Is that a spare bulb? Where did you get a SPARE BULB?"
narr15_powercut_original.mp3      "The Mouse ran out of the comic. Smart Mouse."
narr15_powercut_twist.mp3         "The MOUSE napped in the armchair. The DOG ate the cake."
narr15_powercut_win.mp3           "I cut the power. You brought a spare bulb. Who carries a SPARE BULB? The Mouse is asleep in an armchair like a tiny retired accountant, and the Dog has eaten the cake in total darkness. By SMELL."

narr15_catmouse_intro.mp3         "I've hired a professional. One Cat, paid in advance, in fish. The Cat will chase the Mouse out of this comic, and then the Cat will chase YOU out of this comic. Get him, Cat."
narr15_catmouse_original.mp3      "The Cat chased the Mouse out of the comic. Money well spent."
narr15_catmouse_twist.mp3         "The MOUSE bonked the CAT. The DOG got the cheese."
narr15_catmouse_win.mp3           "The Mouse bonked the Cat. A MOUSE. Bonked. A CAT. I paid that cat in fish. I want my fish back. The Dog ate the cheese. The Dog doesn't even LIKE cheese."

narr15_haunted_intro.mp3          "New genre. HORROR. It was a dark and stormy night. The Bulb family entered the haunted house. There is a coffin. There is a cake, for some reason. Be afraid, lamp. BE VERY AFRAID."
narr15_haunted_original.mp3       "The Kid ran screaming from the haunted house, and the Mouse hid in the dark. Terrifying. I scared myself."
narr15_haunted_twist.mp3          "The BOSS took a nap in the COFFIN."
narr15_haunted_win.mp3            "The Intern bonked the Mouse in the dark, and the Boss climbed into a coffin for a nap. He says it's the best sleep he's had in years. He's ordered one for the office. This was a horror story. The scariest thing left in it is the Boss's snoring."

narr15_wedding_intro.mp3          "Grandma and the Boss are getting married. Yes. Because of one hug on page eight. I take no responsibility. The Cat has been asked not to object. The Cat has objected to everything since 2016."
narr15_wedding_original.mp3       "The Cat objected. Grandma was bonked at her own wedding. Lovely ceremony. Very moving."
narr15_wedding_twist.mp3          "The CAT hugged the MOUSE. The DOG ate the wedding cake."
narr15_wedding_win.mp3            "The bride hugged the Cat. The Cat hugged the Mouse. The groom is still looking for the cake, which the Dog ate. By the power vested in me by absolutely nobody, I now pronounce this... whatever this is. You may hug the Mouse."

narr15_finale_intro.mp3           "The last page. I have no tricks left. No power cuts, no cats, no ghosts. Just a nice, quiet ending where nothing happens. Please. I'm begging you. Let nothing happen."
narr15_finale_original.mp3        "The Boss and the Intern had the same bad idea. Nobody else had any idea at all. The End. Quietly."
narr15_finale_twist.mp3           "EVERYONE had a lightbulb moment!"
narr15_finale_win.mp3             "Everyone... everyone had a... [snort] The Dog has the cake AGAIN. Boss Cake Count: ZERO. [wheeze] Fifteen pages! ZERO! [laughing helplessly] Fine. FINE. It's funnier. Your version is funnier. You win, lamp. ...That was my lightbulb moment. THE END."
```

## Part G: character lines for the 3 new feelings (28 lines)

Same character voices as Parts A–C. Save in `assets/audio/voice/characters/`.

```
CHARACTER lines for new moments. One file per line, named as shown.
Moments: hug = hugging someone (in love) | hugged = just got hugged, surprised |
hide = shy, ducking out of the light | jealous = spotting something someone else wants.

boss_hug.mp3        "C'mere, you!"
boss_hugged.mp3     "Oh! Oh my. Is this... allowed?"
boss_hide.mp3       [panicked whisper] "Nobody look at me!"
boss_jealous.mp3    "Hey! That's MINE. Probably."
grandma_hug.mp3     "Come to Grandma!"
grandma_hugged.mp3  "Ooh, my bones!"
grandma_hide.mp3    [whisper] "Shh. I'm not here, dear."
grandma_jealous.mp3 "I want one of those."
kid_hug.mp3         "Group hug!"
kid_hugged.mp3      "Ew! ...Okay, fine."
kid_hide.mp3        "Don't look don't look don't look!"
kid_jealous.mp3     "No fair! I want it!"
intern_hug.mp3      "Is a hug okay? I'm hugging."
intern_hugged.mp3   "Me? Really? ME?"
intern_hide.mp3     "I'll just... be over here."
intern_jealous.mp3  "Why does everyone else get things?"
dog_hug.mp3         [happy panting] "Wuf! Wuf!"
dog_hugged.mp3      [delighted whine] "Awooo!"
dog_hide.mp3        [small whimper] "Wrrf..."
dog_jealous.mp3     [grumbly bark] "Rrruf!"
cat_hug.mp3         [loud purr] "Prrrrrr."
cat_hugged.mp3      [startled] "Mrrow?!"
cat_hide.mp3        [annoyed] "Mrrp."
cat_jealous.mp3     [hiss] "Hsssss!"
mouse_hug.mp3       [tiny squeak of joy] "Eee!"
mouse_hugged.mp3    [flustered squeaks] "Eep! Eep!"
mouse_hide.mp3      [whispered squeak] "Pip."
mouse_jealous.mp3   [indignant squeak] "Squee!"
```

## For the coding thread: the 15-page voice map

- **Per page** (slugs in play order: dinner, greens, nap, snack, stage, birthday, revenge, date, shadow, slice, powercut, catmouse, haunted, wedding, finale):
  - `narr15_<slug>_intro`: over the intro caption.
  - `narr15_<slug>_original`: when the Original's ending is printed.
  - `narr15_<slug>_twist`: when the red pen writes the goal.
  - `narr15_<slug>_win`: under the TWIST! stamp, after `narr15_twist_stamp`.
  - The caption text is the page's `narration` field. It's identical to the voiced words, minus the [directions].
- **Fail:** the caption shows the page's `fail` / `fail_alt` (rotating, text only). The voice plays `narr15_fail_1..4` in rotation, or `narr15_nearmiss` when the near-miss callout fires.
- **Act cards** before pages 1, 6 and 11: `narr15_act1..3`. NEW FEELING cards: `narr15_new_shy`, `narr15_new_love`, `narr15_new_jealous`.
- **Character events:**
  - HUG plays the hugger's `<char>_hug`, then the target's `<char>_hugged`.
  - A SHY character starting to run from the light plays `<char>_hide`.
  - A JEALOUS character first picking a target plays `<char>_jealous`.
- Old `narr_*` files remain the fallback until the `narr15_*` files exist.
