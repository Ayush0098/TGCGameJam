"""Make the 54 page 1-3 Indian English voice clips with installed Windows voices.

First use: --source <user request text> extracts the TTS-ready table to script.json.
Later runs use script.json. No cloud speech service or new model is required.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/audio"))
import generate_voice_pack as pack

DELIVERY = ROOT / "assets/audio/voice/p1_3"
SCRIPT = DELIVERY / "script.json"
MASTERS = ROOT / ".codex/tools/voice/p1_3_wav"
PITCH = {
    "NARRATOR": 1.0, "DASSI": 1.07, "CHINTU": 1.12,
    "SAAP": 0.95, "PROMPT BHAI": 1.04, "MESS AUNTY": 0.94,
    "PROF": 0.91, "KASSI": 1.07,
}


def extract(source: Path) -> list[dict[str, str]]:
    body = source.read_text(encoding="utf-8-sig")
    table = body.split("## TTS-ready table", 1)[1].split("```", 2)[1]
    rows = []
    for raw in table.splitlines():
        if " | " not in raw:
            continue
        filename, voice, words = raw.split(" | ", 2)
        filename = filename.strip()
        if not filename.endswith(".mp3"):
            continue
        rows.append({"file": filename, "voice": voice.strip(), "text": words.strip()})
    if len(rows) != 54 or len({row["file"] for row in rows}) != 54:
        raise ValueError(f"Expected 54 unique lines; got {len(rows)}")
    if sum(row["voice"] == "NARRATOR" for row in rows) != 34:
        raise ValueError("Expected 34 narrator and 20 character lines")
    if set(row["voice"] for row in rows) != set(PITCH):
        raise ValueError("Voice inventory does not match the supplied script")
    return rows


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, help="Original pasted request text")
    args = parser.parse_args()
    DELIVERY.mkdir(parents=True, exist_ok=True)
    if args.source:
        rows = extract(args.source)
        SCRIPT.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    else:
        rows = json.loads(SCRIPT.read_text(encoding="utf-8"))
    if len(rows) != 54:
        raise ValueError("Delivery script must contain 54 lines")

    MASTERS.mkdir(parents=True, exist_ok=True)
    missing = [row["file"] for row in rows if not (MASTERS / Path(row["file"]).with_suffix(".wav")).is_file()]
    if missing:
        raise FileNotFoundError(
            f"{len(missing)} WAV masters missing. Run synthesize_p1_3_windows.ps1 "
            f"with -Manifest {SCRIPT} -OutputDirectory {MASTERS} first."
        )
    report = []
    for row in rows:
        wav = MASTERS / Path(row["file"]).with_suffix(".wav")
        samples, rate = sf.read(wav)
        if rate != pack.SR or samples.ndim != 1:
            raise ValueError(f"Unexpected WAV format: {wav}")
        # SAPI appends digital zero padding. Remove it before the shared
        # normalizer subtracts DC, which would otherwise turn it into noise.
        edge = np.flatnonzero(np.abs(samples) > max(0.0005, np.max(np.abs(samples)) * 0.003))
        if not len(edge):
            raise ValueError(f"Silent WAV: {wav}")
        margin = int(rate * 0.015)
        samples = samples[max(0, int(edge[0]) - margin):min(len(samples), int(edge[-1]) + margin + 1)]
        if PITCH[row["voice"]] != 1.0:
            samples = pack.resample(samples, rate, PITCH[row["voice"]])
        samples = pack.finish(np.asarray(samples, dtype=np.float64))
        active = samples[np.abs(samples) > max(0.003, np.max(np.abs(samples)) * 0.035)]
        gain = 10 ** (-19 / 20) / np.sqrt(np.mean(active * active))
        samples *= min(gain, 0.92 / np.max(np.abs(samples)))
        output = DELIVERY / row["file"]
        sf.write(output, samples, pack.SR, format="MP3", subtype="MPEG_LAYER_III")
        report.append({**row, "engine_voice": "Microsoft Heera" if row["voice"] in ("DASSI", "MESS AUNTY") else "Microsoft Ravi", "pitch_ratio": PITCH[row["voice"]], **pack.metrics(output)})
    manifest = {
        "source_sha256": hashlib.sha256(SCRIPT.read_bytes()).hexdigest(),
        "method": "Windows System.Speech SAPI; installed en-IN Ravi and Heera; offline",
        "quality_note": "Two synthetic timbres with rate and pitch variation; human audition of acting and pronunciation required.",
        "cues": report,
    }
    (DELIVERY / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    story_path = ROOT / "assets/audio/voice/story_pages_manifest.json"
    if story_path.exists():
        story = json.loads(story_path.read_text(encoding="utf-8"))
        by_id = {Path(cue["file"]).stem: cue for cue in report}
        for cue in story["cues"]:
            replacement = by_id.get(cue["id"])
            if replacement:
                for field in ("duration_seconds", "sample_rate", "channels", "peak", "active_rms_dbfs", "leading_silence_seconds", "trailing_silence_seconds", "sha256", "engine_voice", "pitch_ratio"):
                    cue[field] = replacement[field]
                cue["tts_text"] = replacement["text"]
        story["replacement_note"] = "Page 1-3 cues with matching IDs use assets/audio/voice/p1_3/manifest.json and Microsoft en-IN voices; story_act1 is legacy, superseded in-game by v_act1."
        story_path.write_text(json.dumps(story, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"COMPLETE {len(report)} clips; {sum(c['duration_seconds'] for c in report):.1f}s")


if __name__ == "__main__":
    main()
