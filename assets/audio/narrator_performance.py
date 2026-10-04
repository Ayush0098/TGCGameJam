"""Phrase-by-phrase delivery for the narr15 storyteller.

Kokoro reads a whole line in one even tone. This splits a line into phrases and
gives each its own tempo, pitch, loudness and pause, so the narrator sounds
pompous, outraged or deflated where the script asks for it:

- CAPITALISED words are his outrage: that phrase is slower, higher and louder.
- "!" lines are punchier; "?" lines lift at the end.
- "..." trails off and leaves a real pause.
- A short last sentence is the punchline: a beat of silence, then deadpan.
- [directions] (outraged, smug, relieved, panicked) colour the whole line.
- Acts 2 and 3 get faster and more strained as he loses his mind.

Pitch shifts use the pack's own resampler with the tempo compensated, so a
higher phrase is not also a faster one.
"""
from __future__ import annotations
import re
import numpy as np

KEEP_CAPS = {"HR"}
DIRECTION_MOODS = {
    "outraged": (1.06, 1.08, 2.5),
    "smug": (0.92, 0.97, 0.0),
    "relieved": (0.94, 0.98, 0.0),
    "relieved sigh": (0.9, 0.96, -1.0),
    "panicked": (1.12, 1.1, 2.0),
}


def _speakable(text: str) -> str:
    return re.sub(r"\b[A-Z][A-Z']+\b", lambda m: m[0] if m[0] in KEEP_CAPS else m[0].capitalize(), text)


def _trim(audio: np.ndarray, sr: int) -> np.ndarray:
    # Kokoro pads every chunk with silence; keep 20 ms so consonants survive.
    level = np.abs(audio)
    loud = np.flatnonzero(level > max(1e-4, level.max() * 0.02))
    if not len(loud):
        return audio
    pad = int(sr * 0.02)
    return audio[max(0, loud[0] - pad):min(len(audio), loud[-1] + pad)]


def phrases(text: str) -> list[dict]:
    """Split into phrases with their delivery marks."""
    parts = re.findall(r"[^.!?,;:]+(?:\.\.\.|[.!?]+|[,;:])?", text)
    out = []
    for part in parts:
        body = part.strip()
        if not body:
            continue
        words = re.findall(r"[A-Za-z']+", body)
        caps = [w for w in words if len(w) >= 2 and w.isupper() and w not in KEEP_CAPS]
        out.append({
            "text": body,
            "caps": bool(caps),
            "exclaim": body.endswith("!") or body.endswith("?!"),
            "question": body.endswith("?") and not body.endswith("?!"),
            "trail": body.endswith("...") or body.startswith("..."),
            "clause": body[-1:] in ",;:",
            "words": len(words),
        })
    # The punchline: a short final sentence after a longer set-up.
    sentences = [p for p in out if not p["clause"]]
    if len(sentences) >= 2 and sentences[-1]["words"] <= 5 and len(out) >= 3:
        sentences[-1]["punchline"] = True
    return out


def perform(model, text: str, profile: dict, act: int, direction: str, resample, sr: int) -> np.ndarray:
    base_speed = profile["speed"]
    base_pitch = profile.get("pitch", 1.0)
    mood = DIRECTION_MOODS.get(direction.strip().lower(), (1.0, 1.0, 0.0))
    strain = {1: 1.0, 2: 1.02, 3: 1.05}.get(act, 1.0)
    pieces: list[np.ndarray] = []
    for i, ph in enumerate(phrases(text)):
        tempo, pitch, gain_db = mood[0], mood[1] * strain, mood[2]
        if ph["caps"]:
            tempo *= 0.9
            pitch *= 1.07
            gain_db += 2.5
        if ph["exclaim"]:
            tempo *= 1.06
            pitch *= 1.05
            gain_db += 1.5
        if ph["question"]:
            pitch *= 1.04
        if ph["trail"]:
            tempo *= 0.9
            pitch *= 0.97
            gain_db -= 1.5
        if ph.get("punchline"):
            # A beat of silence, then deadpan (or, if it's a CAPITAL word, a burst).
            pieces.append(np.zeros(int(sr * 0.3)))
            if not ph["caps"]:
                tempo *= 0.88
                pitch *= 0.96
        speak_pitch = base_pitch * pitch
        # Kokoro tempo is divided by the pitch factor so resampling restores it.
        speed = float(np.clip(base_speed * tempo / speak_pitch, 0.5, 2.0))
        audio, rate = model.create(_speakable(ph["text"]), voice=profile["voice"], lang=profile["lang"], speed=speed)
        audio = resample(np.asarray(audio, dtype=np.float64), rate, speak_pitch)
        audio = _trim(audio, sr)
        audio *= 10 ** (gain_db / 20)
        pieces.append(audio)
        gap = 0.38 if ph["trail"] else (0.08 if ph["clause"] else 0.2)
        pieces.append(np.zeros(int(sr * gap)))
    return np.concatenate(pieces) if pieces else np.zeros(1)
