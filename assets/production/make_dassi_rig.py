"""Build the Dassi cutout rig (src/assets/characters/dassi) as a re-skin of the kid rig.

Dassi is a campus student, not a cat: long dark hair with a clip, a teal kurti
top, jeans and pink sneakers. This is the stand-in used until the ChatGPT art in
docs/dassi_art_request.md is delivered; same parts, pivots and animations as
`kid`, so every action (walk, eat, sit, bonk, celebrate...) already works.

    python assets/production/make_dassi_rig.py
"""
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "src/assets/characters/kid"
TARGET = ROOT / "src/assets/characters/dassi"

HAIR = "#2a1c1e"
HAIR_SHINE = "#4a3236"

# Hair that falls behind the head to the shoulders (drawn before ears and face).
BACK_HAIR = (
    f'<path d="M97 108 Q94 38 161 34 Q228 38 225 108 Q236 178 216 218 Q194 204 190 164 L132 164 '
    f'Q128 204 106 218 Q86 178 97 108 Z" fill="{HAIR}" stroke="#453747" stroke-width="5" '
    f'stroke-linecap="round" stroke-linejoin="round" />'
)
# Side-parted fringe in place of the kid's spiky hair, plus a clip and earrings.
FRINGE = (
    f'<path d="M106 108 Q103 54 161 48 Q219 54 216 108 Q200 74 172 80 Q156 64 134 84 Q116 90 106 108 Z" '
    f'fill="{HAIR}" stroke="#453747" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />'
    f'<path d="M126 62 Q150 50 176 58" fill="none" stroke="{HAIR_SHINE}" stroke-width="4" stroke-linecap="round" />'
    '<path d="M194 66 l5 -9 l5 9 l-9 -5 l10 0 Z" fill="#ffd27a" stroke="#453747" stroke-width="2.5" '
    'stroke-linecap="round" stroke-linejoin="round" />'
    '<circle cx="105" cy="136" r="4" fill="#ffd27a" stroke="#453747" stroke-width="2" />'
    '<circle cx="215" cy="136" r="4" fill="#ffd27a" stroke="#453747" stroke-width="2" />'
)
LASHES = '<path d="M127 104 l-7 -4 M146 102 l2 -6 M174 102 l-2 -6 M194 104 l7 -4" fill="none" stroke="#453747" stroke-width="3" stroke-linecap="round" />'


def main() -> None:
    if TARGET.exists():
        shutil.rmtree(TARGET)
    TARGET.mkdir(parents=True)
    for path in SOURCE.iterdir():
        if path.suffix == ".svg":
            text = path.read_text(encoding="utf-8")
            # Teal kurti instead of the red striped tee.
            text = text.replace("#ef6a5d", "#43c4b2").replace("#bb3b3f", "#1f8a86")
            # Jeans and pink sneakers.
            text = text.replace("#3e6fb0", "#2f4f86").replace("#d9473f", "#e0679a")
            if path.name == "head.svg":
                text = text.replace("<ellipse cx=\"106\" cy=\"116\"", BACK_HAIR + "<ellipse cx=\"106\" cy=\"116\"", 1)
                text = re.sub(r'<path d="M104 106 Q96 62[^>]*/>', FRINGE, text, count=1)
                # No freckles.
                text = re.sub(r'<ellipse cx="\d+" cy="132" rx="2" ry="2"[^>]*/>', "", text)
            if path.name.startswith("face_") and "frightened" not in path.name:
                text = text.replace("</svg>", LASHES + "</svg>")
            (TARGET / path.name).write_text(text, encoding="utf-8")
        elif path.name == "rig.json":
            rig = json.loads(path.read_text(encoding="utf-8"))
            rig["id"] = "dassi"
            rig["author"] = "Dassi: re-skin of the kid cutout rig (stand-in until the ChatGPT art arrives)"
            raw = json.dumps(rig, indent=2).replace("characters/kid/", "characters/dassi/")
            (TARGET / "rig.json").write_text(raw, encoding="utf-8")
    print("Wrote", TARGET)


if __name__ == "__main__":
    main()
