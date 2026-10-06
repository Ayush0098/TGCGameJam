"""Import the pages 4-15 voice takes and check each length against its target window.

Takes (ogg) sit in assets/audio/voice/p4_15/ (the masters). Run:
    python assets/audio/import_p4_15_voice.py
Windows come from assets/audio/voice/voice_lines_p4_15.md. Balloons
(<page>_dialogue_<char>_<when>) go to characters/, everything else (narration,
page cards, act cards, postcard) to narrator/, in src/assets/ (game copies).
Chintu's barks are already in the game and are left alone. Exit code 1 if any
take is missing or outside its window.
"""
import re
import shutil
import sys
from pathlib import Path

import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/audio/voice/p4_15"
LINES = ROOT / "assets/audio/voice/voice_lines_p4_15.md"
GAME = ROOT / "src/assets/audio/voice"
ROW = re.compile(r"^(\S+\.ogg) \| ([A-Z ]+) \| ([\d.]+)[–-]([\d.]+) \|")

bad = []
count = 0
for line in LINES.read_text(encoding="utf-8").splitlines():
    m = ROW.match(line)
    if not m:
        continue
    name, voice, low, high = m[1], m[2].strip(), float(m[3]), float(m[4])
    if voice == "CHINTU":
        continue
    path = SOURCE / name
    if not path.exists():
        bad.append(f"MISSING {name}")
        continue
    info = sf.info(path)
    seconds = info.frames / info.samplerate
    if not (low - 0.05 <= seconds <= high + 0.05):
        bad.append(f"LENGTH {name} {seconds:.2f}s not in {low}-{high}")
    folder = "characters" if "_dialogue_" in name else "narrator"
    shutil.copyfile(path, GAME / folder / name)
    count += 1
print(f"Imported {count} takes.")
for item in bad:
    print(item)
sys.exit(1 if bad else 0)
