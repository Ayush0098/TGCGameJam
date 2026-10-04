"""Import the Hinglish voice takes for pages 1-3 (design/voice_request_hinglish.md).

Drop the files in assets/audio/voice/p1_3/ (mp3, wav or ogg) and run:
    python assets/audio/import_p1_3_voice.py
Balloons (<page>_dialogue_<char>_<when>) go to characters/, everything else
(page narration, v_title, v_twist_stamp, v_act1, v_tut_1..4) to narrator/,
in both assets/ (masters) and src/assets/ (game copies). Same names replace the
current takes. Then re-import in Godot (or run the web export) to pick them up.
"""
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/audio/voice/p1_3"

if not SOURCE.is_dir():
    sys.exit(f"Put the new takes in {SOURCE} first.")
count = 0
for path in sorted(SOURCE.iterdir()):
    if path.suffix.lower() not in (".mp3", ".wav", ".ogg"):
        continue
    folder = "characters" if "_dialogue_" in path.stem else "narrator"
    for base in (ROOT / "assets/audio/voice", ROOT / "src/assets/audio/voice"):
        target = base / folder / path.name
        # One take per name: drop an older take in another format.
        for other in (".mp3", ".wav", ".ogg"):
            stale = target.with_suffix(other)
            if other != path.suffix.lower() and stale.exists():
                stale.unlink()
        shutil.copyfile(path, target)
    count += 1
    print(folder, path.name)
print(f"Imported {count} takes.")
