"""Tighten voice takes: trim edge silence and shorten long pauses inside a line.

Run with .codex/tools/voice/env/Scripts/python.exe assets/audio/tighten_voice.py <folder>
Reads every .mp3 in <folder> (default assets/audio/voice/p1_3), keeps the words
untouched, caps silences inside a line at MAX_GAP seconds and edge silence at
EDGE seconds, and writes the result into src/assets/audio/voice/{narrator,characters}.
Masters in <folder> are not changed.
"""
import sys
from pathlib import Path
import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
MAX_GAP = 0.32
EDGE = 0.05
BLOCK = 0.01


def tighten(x: np.ndarray, sr: int) -> np.ndarray:
    block = int(sr * BLOCK)
    frames = [x[i:i + block] for i in range(0, len(x), block)]
    level = np.array([np.sqrt(np.mean(f * f)) if len(f) else 0.0 for f in frames])
    quiet = level < max(1e-4, level.max() * 0.03)
    loud = np.flatnonzero(~quiet)
    if not len(loud):
        return x
    keep = []
    gap = 0
    max_gap = int(MAX_GAP / BLOCK)
    for i in range(loud[0], loud[-1] + 1):
        if quiet[i]:
            gap += 1
            if gap > max_gap:
                continue
        else:
            gap = 0
        keep.append(frames[i])
    pad = np.zeros(int(sr * EDGE))
    out = np.concatenate([pad] + keep + [pad])
    fade = min(int(sr * 0.004), len(out) // 4)
    out[:fade] *= np.linspace(0, 1, fade)
    out[-fade:] *= np.linspace(1, 0, fade)
    return out


def main() -> None:
    source = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "assets/audio/voice/p1_3"
    for path in sorted(source.glob("*.mp3")):
        x, sr = sf.read(path)
        if x.ndim > 1:
            x = x.mean(1)
        y = tighten(x, sr)
        folder = "characters" if "_dialogue_" in path.stem else "narrator"
        out = ROOT / "src/assets/audio/voice" / folder / path.name
        sf.write(out, y, sr, format="MP3", subtype="MPEG_LAYER_III")
        print(f"{path.name}: {len(x) / sr:.1f}s -> {len(y) / sr:.1f}s")


if __name__ == "__main__":
    main()
