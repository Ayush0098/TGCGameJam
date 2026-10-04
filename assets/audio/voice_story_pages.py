"""Voice the IIIT-H story pages (narration, dialogue, act cards) with the local pack.

Run with .codex/tools/voice/env/Scripts/python.exe assets/audio/voice_story_pages.py
Keys follow design/build_p1_3/spec.md section 6: <voice slug>_<field>[_n] for the
narrator, <voice slug>_dialogue_<character>_<when> for balloons. Directions in
[brackets] are acted, never spoken. Files go to assets/audio/voice/ and are copied
into src/ for the game.
"""
from __future__ import annotations
import json, re, shutil, sys
from pathlib import Path
import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/audio"))
import generate_voice_pack as pack
import narrator_performance as perf

PAGES = ["page_01", "page_02", "page_03"]
NARRATOR = dict(pack.PROFILES["narr15"])
CHARACTER_PROFILES = {
    "cat": pack.PROFILES["cat"], "dog": pack.PROFILES["dog"], "kid": pack.PROFILES["kid"],
    "grandma": pack.PROFILES["grandma"], "boss": pack.PROFILES["boss"], "intern": pack.PROFILES["intern"],
    "mouse": pack.PROFILES["mouse"],
    "prompt": {"voice": "am_eric", "lang": "en-us", "speed": 1.08, "pitch": 1.05},
}
ACTS = {"story_act1": "Dear all, Greetings from the Office of the Official Narrator. This is to inform you that the Official Campus Comic has run for four thousand pages without a single twist, with the continuous support of the institute. Freshers are reminded of the 11 PM induction curfew. Nobody will follow it. P.S. The TAs of this comic (me) requested a salary hike. Management has replied: no. That's fine. I'm fine. What could possibly go wrong? Regards. Bonda!"}


def page_data(page_id: str) -> dict:
    text = (ROOT / "src/data/campaign" / (page_id + ".gd")).read_text(encoding="utf-8")
    return json.loads(text[text.index("return {") + 7:])


def spoken(line: str) -> str:
    # Emoji and directions are for the eye, not the voice.
    line = re.sub(r"\[[^\]]*\]", " ", line)
    line = line.replace("👌", "").replace("…", "...")
    return re.sub(r"\s+", " ", line).strip()


def narrator_lines(page: dict) -> dict:
    slug = page.get("voice", page["id"])
    n = page.get("narration", {})
    lines = {}
    for field in ["intro", "original", "twist", "win"]:
        if n.get(field):
            lines[f"{slug}_{field}"] = n[field]
    for i, line in enumerate(n.get("stars", []), 1):
        lines[f"{slug}_stars_{i}"] = line
    for i, line in enumerate(n.get("fails", []), 1):
        lines[f"{slug}_fails_{i}"] = line
    for i, entry in enumerate(n.get("hidden", []), 1):
        if isinstance(entry, dict) and entry.get("line"):
            lines[f"{slug}_hidden_{i}"] = entry["line"]
    return lines


def dialogue_lines(page: dict) -> dict:
    slug = page.get("voice", page["id"])
    lines = {}
    for entry in page.get("dialogue", []):
        key = f"{slug}_dialogue_{entry['character']}_{entry['when']}"
        lines[key] = (entry["character"], entry["line"])
    return lines


def finish_and_save(samples: np.ndarray, folder: str, key: str) -> dict:
    samples = pack.finish(samples)
    out = ROOT / "assets/audio/voice" / folder / (key + ".mp3")
    sf.write(out, samples, pack.SR, format="MP3", subtype="MPEG_LAYER_III")
    target = ROOT / "src/assets/audio/voice" / folder / (key + ".mp3")
    shutil.copyfile(out, target)
    return {"id": key, "audio": out.relative_to(ROOT).as_posix(), **pack.metrics(out)}


def main() -> None:
    only = set(sys.argv[1].split(",")) if len(sys.argv) > 1 else None
    model = Kokoro(str(ROOT / ".codex/tools/voice/kokoro-v1.0.onnx"), str(ROOT / ".codex/tools/voice/voices-v1.0.bin"))
    report = []
    narr = dict(ACTS)
    talk = {}
    for page_id in PAGES:
        page = page_data(page_id)
        narr.update(narrator_lines(page))
        talk.update(dialogue_lines(page))
    for key, line in narr.items():
        if only and key not in only:
            continue
        samples = perf.perform(model, spoken(line), NARRATOR, 1, "", pack.resample, pack.SR)
        record = finish_and_save(samples, "narrator", key)
        record["text"] = spoken(line)
        report.append(record)
        print(key, round(record["duration_seconds"], 2), flush=True)
    for key, (character, line) in talk.items():
        if only and key not in only:
            continue
        profile = CHARACTER_PROFILES.get(character, pack.PROFILES["intern"])
        text = pack.speakable(spoken(line))
        samples, rate = model.create(text, voice=profile["voice"], lang=profile["lang"], speed=profile["speed"])
        samples = pack.resample(np.asarray(samples, dtype=np.float64), rate, profile.get("pitch", 1.0))
        record = finish_and_save(samples, "characters", key)
        record["text"] = spoken(line)
        report.append(record)
        print(key, round(record["duration_seconds"], 2), flush=True)
    (ROOT / "assets/audio/voice/story_pages_manifest.json").write_text(json.dumps({"generator": "assets/audio/voice_story_pages.py", "cues": report}, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print("DONE", len(report))


if __name__ == "__main__":
    main()
