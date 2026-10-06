"""Generate Indian English page 1-3 candidate voices via the Svara TTS Space.

The source script is extracted once from the user's supplied narration brief.
Generation writes to an ignored candidate folder until the takes are reviewed.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/audio"))
import voice_audio_utils as pack

SCRIPT = ROOT / "assets/audio/voice/p1_3/natural_script.json"
OUTPUT = ROOT / ".codex/tools/voice/svara_candidates"
API = "https://kenpath-svara-tts.hf.space/gradio_api/call/generate_speech"


def extract(source: Path) -> list[dict[str, str]]:
    body = source.read_text(encoding="utf-8-sig")
    rows = []
    for section in ("## Prompt 2: narrator", "## Prompt 3: characters"):
        block = body.split(section, 1)[1].split("```", 2)[1]
        for raw in block.splitlines():
            match = re.match(r'^([^|]+) \| ([^|]+) \| (?:\[([^]]+)\] )?"(.*)"$', raw.strip())
            if match:
                filename, voice, direction, words = match.groups()
                if not filename.endswith(".mp3"):
                    continue
                rows.append({"file": filename, "voice": voice, "direction": direction or "", "text": words})
    if len(rows) != 54 or len({row["file"] for row in rows}) != 54:
        raise ValueError(f"Expected 54 unique voice lines, got {len(rows)}")
    return rows


def style(row: dict[str, str]) -> str:
    voice = row["voice"]
    key = row["file"]
    if voice == "NARRATOR":
        if key == "v_twist_stamp":
            return "surprise"
        if "_win" in key:
            return "surprise"
        if key.startswith("v_tut_"):
            return "chat"
        return "formal"
    if voice == "CHINTU":
        return "fear" if "SCARED" in key else "happy"
    if voice == "PROF":
        return "surprise" if "SCARED" in key else "formal"
    if voice == "DASSI":
        return "happy" if "_win" in key else "formal"
    if voice == "PROMPT BHAI":
        return "happy"
    if voice == "MESS AUNTY":
        return "chat"
    if voice == "KASSI":
        return "sad" if "_fail" in key else "chat"
    return "chat"


def voice_gender(voice: str) -> str:
    return "Female" if voice in ("DASSI", "MESS AUNTY") else "Male"


def request_audio(row: dict[str, str]) -> bytes:
    # Svara accepts an emotion tag in the text field; the tag is not spoken.
    spoken = row["text"].replace("…", "...")
    spoken += f" <{style(row)}>"
    payload = json.dumps({"data": ["English (Indian)", voice_gender(row["voice"]), spoken,
                                   0.7, 0.8, 1.1, 2048]}).encode("utf-8")
    request = urllib.request.Request(API, data=payload, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(request, timeout=60) as response:
        event_id = json.load(response)["event_id"]
    with urllib.request.urlopen(API + "/" + event_id, timeout=180) as response:
        events = response.read().decode("utf-8")
    completed = re.search(r"event: complete\s+data: (\[.*\])", events)
    if not completed:
        raise RuntimeError(f"Svara generation did not complete: {events[-500:]}")
    result = json.loads(completed.group(1))[0]
    with urllib.request.urlopen(result["url"], timeout=60) as response:
        return response.read()


def shape_chintu_rising(samples: np.ndarray) -> np.ndarray:
    """Make the three biryani calls climb in pitch and level as requested."""
    count = int(len(samples) / 1.04)
    phase = np.linspace(0.0, 1.0, count)
    speed = 0.93 + 0.22 * phase
    positions = np.cumsum(speed)
    positions *= (len(samples) - 1) / positions[-1]
    shaped = np.interp(positions, np.arange(len(samples)), samples)
    shaped *= 0.72 + 0.44 * phase
    shaped *= min(1.0, 0.89 / max(np.max(np.abs(shaped)), 1e-8))
    return shaped


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path)
    parser.add_argument("--ids", help="Comma-separated file stems; default all")
    args = parser.parse_args()
    if args.source:
        rows = extract(args.source)
        SCRIPT.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    else:
        rows = json.loads(SCRIPT.read_text(encoding="utf-8"))
    selected = set(args.ids.split(",")) if args.ids else None
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for row in rows:
        stem = Path(row["file"]).stem
        if selected is not None and stem not in selected:
            continue
        output = OUTPUT / row["file"]
        if output.exists():
            print(f"SKIP {stem}", flush=True)
            continue
        last_error = None
        for attempt in range(3):
            try:
                wav_bytes = request_audio(row)
                wav = OUTPUT / f"{stem}.wav"
                wav.write_bytes(wav_bytes)
                samples, rate = sf.read(wav)
                if samples.ndim != 1 or not np.isfinite(samples).all() or len(samples) < rate // 2:
                    raise ValueError(f"Invalid audio for {stem}")
                samples = pack.resample(samples, rate)
                samples = pack.finish(samples)
                if stem == "page_01_dialogue_dog_lit":
                    samples = shape_chintu_rising(samples)
                sf.write(output, samples, pack.SR, format="MP3", subtype="MPEG_LAYER_III")
                check = pack.metrics(output)
                print(f"OK {stem} {check['duration_seconds']:.2f}s {check['active_rms_dbfs']} dBFS", flush=True)
                break
            except (OSError, ValueError, RuntimeError, urllib.error.URLError) as error:
                last_error = error
                time.sleep(2 ** attempt)
        else:
            raise RuntimeError(f"Failed to generate {stem}: {last_error}")


if __name__ == "__main__":
    main()
