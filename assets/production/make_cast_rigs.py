"""Build the cast's cutout rigs (src/assets/characters/<art>) as re-skins of existing rigs.

Every character must look like their name and role, not the old family / animal
archetype (Chintu stays a dog). Each rig keeps the parts, pivots and animations of
its source, so every action already works:

  prof    from boss    pompous professor: grey hair, gold specs, tweed vest, pen
  kassi   from intern  nervous 2nd-year: backpack straps, ID lanyard, round specs, sweat drop
  saap    from kid     lazy topper: green snake-scale hoodie, hood up, heavy eyelids
  prompt  from kid     ChatGPT-will-win bro: blue </> tee, headphones, black hair
  aunty   from grandma Telugu mess aunty: saree with gold pallu, bindi, jasmine bun, bangles, ladle
  faccha  from kid     lost first-year: huge backpack, FRESHER ID, wide worried eyes
  dassi   from kid     10-CGPA topper: long hair, gold clip, teal top, thin specs

Stand-ins until the ChatGPT art in docs/cast_art_request.md arrives.

    python assets/production/make_cast_rigs.py
"""
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CHARACTERS = ROOT / "src/assets/characters"
INK = "#453747"


def specs(colour: str, width: float = 3) -> str:
    """Round glasses over the eyes (the faces share one layout across the cast)."""
    return (
        f'<circle cx="137" cy="111" r="15" fill="#ffffff" fill-opacity=".12" stroke="{colour}" stroke-width="{width}" />'
        f'<circle cx="184" cy="111" r="15" fill="#ffffff" fill-opacity=".12" stroke="{colour}" stroke-width="{width}" />'
        f'<path d="M152 109 Q160.5 103 169 109 M122 107 L108 103 M199 107 L213 103" fill="none" stroke="{colour}" stroke-width="{width}" stroke-linecap="round" />'
    )


SWEAT = '<path d="M214 84 Q221 96 214 101 Q207 96 214 84 Z" fill="#9fd8ff" stroke="#453747" stroke-width="2" />'
LASHES = '<path d="M127 104 l-7 -4 M146 102 l2 -6 M174 102 l-2 -6 M194 104 l7 -4" fill="none" stroke="#453747" stroke-width="3" stroke-linecap="round" />'


def eyelids(skin: str) -> str:
    """Heavy half-closed lids over the top of both eyes."""
    return "".join(
        f'<path d="M{x - 10} 111 A10 12 0 0 1 {x + 10} 111 Z" fill="{skin}" stroke="#453747" stroke-width="3" stroke-linejoin="round" />'
        for x in (137, 184)
    )


def scales(colour: str) -> str:
    path = ""
    for row, y in enumerate((196, 224, 252)):
        start = 104 + (8 if row % 2 else 0)
        for x in range(start, 214, 16):
            path += f"M{x} {y} q8 9 16 0 "
    return f'<path d="{path}" fill="none" stroke="{colour}" stroke-width="3" stroke-linecap="round" />'


def diag(a, b, text: str, rep: str) -> str:
    return text.replace(a, rep)


def sub(text: str, pattern: str, replacement: str) -> str:
    result, count = re.subn(pattern, lambda _m: replacement, text, count=1)
    if not count:
        raise SystemExit(f"pattern not found: {pattern}")
    return result


def build(art: str, source: str, edit) -> None:
    src = CHARACTERS / source
    dst = CHARACTERS / art
    if dst.exists():
        shutil.rmtree(dst)
    dst.mkdir(parents=True)
    for path in sorted(src.iterdir()):
        if path.suffix == ".svg":
            text = path.read_text(encoding="utf-8")
            text = edit(path.stem, text)
            (dst / path.name).write_text(text, encoding="utf-8")
        elif path.name == "rig.json":
            rig = json.loads(path.read_text(encoding="utf-8"))
            rig["id"] = art
            rig["author"] = f"{art}: re-skin of the {source} cutout rig (stand-in until the ChatGPT art arrives)"
            raw = json.dumps(rig, indent=2).replace(f"characters/{source}/", f"characters/{art}/")
            (dst / "rig.json").write_text(raw, encoding="utf-8")
    print("built", art, "from", source)


# ------------------------------------------------------------------ Prof
def prof(part: str, text: str) -> str:
    if part == "head":
        text = text.replace("#64505c", "#d9d4de").replace("#8b727a", "#f4f1f7")
    if part.startswith("face_"):
        text = text.replace("</svg>", specs("#c9a227", 3.5) + "</svg>")
        # Bushier, greyer moustache.
        text = text.replace("#6c4e53", "#cfc9d6")
    if part == "body":
        # A pen clipped in the vest pocket and a gold watch chain.
        text = text.replace("</svg>", '<path d="M196 243 L202 224" stroke="#2a62b8" stroke-width="5" stroke-linecap="round" />'
                            '<path d="M170 228 Q150 246 138 256" fill="none" stroke="#d9a521" stroke-width="3" stroke-linecap="round" /></svg>')
    return text


# ------------------------------------------------------------------ Kassi
def kassi(part: str, text: str) -> str:
    # Mustard hoodie-ish shirt instead of the office oxford.
    text = text.replace("#dcebfb", "#ffe29a").replace("#8fb0d6", "#e8a93c").replace("#eef5fd", "#fff0c4").replace("#f6fbff", "#fff7dd").replace("#c4d8ee", "#e9c97a")
    if part == "body":
        # Backpack straps over both shoulders.
        text = text.replace("</svg>", '<path d="M128 172 Q122 224 132 268" fill="none" stroke="#2b3a55" stroke-width="13" stroke-linecap="round" />'
                            '<path d="M194 170 Q204 222 194 268" fill="none" stroke="#2b3a55" stroke-width="13" stroke-linecap="round" /></svg>')
    if part.startswith("face_"):
        text = text.replace("</svg>", specs("#2b3a55", 3.5) + SWEAT + "</svg>")
    return text


# ------------------------------------------------------------------ Saap
def saap(part: str, text: str) -> str:
    text = text.replace("#ef6a5d", "#8bd37a").replace("#bb3b3f", "#2f8f4e")
    if part == "body":
        text = sub(text, r'<path d="M104 206 Q160 214[^>]*/>', scales("#1d5e34"))
        text = text.replace("#ffd27a", "#f2e04a")
    if part == "arm_left" or part == "arm_right":
        pass
    if part == "head":
        # A green beanie with slit snake eyes instead of the hair (a hood read like a headscarf).
        cap = ('<path d="M102 104 Q96 30 161 26 Q226 30 220 104 Q200 76 161 78 Q122 76 102 104 Z" '
               'fill="#3a9a58" stroke="#453747" stroke-width="4" stroke-linejoin="round" />'
               '<path d="M100 108 Q161 80 222 108 L222 92 Q161 64 100 92 Z" fill="#2f8f4e" stroke="#453747" stroke-width="4" stroke-linejoin="round" />'
               '<path d="M118 100 Q161 76 204 100 M118 94 Q161 70 204 94" fill="none" stroke="#1d5e34" stroke-width="2" />'
               '<ellipse cx="140" cy="52" rx="7" ry="8" fill="#f2e04a" stroke="#453747" stroke-width="2.5" />'
               '<ellipse cx="182" cy="52" rx="7" ry="8" fill="#f2e04a" stroke="#453747" stroke-width="2.5" />'
               '<path d="M140 45 L140 59 M182 45 L182 59" stroke="#453747" stroke-width="2.5" stroke-linecap="round" />')
        text = sub(text, r'<path d="M104 106 Q96 62[^>]*/>', cap)
        text = re.sub(r'<ellipse cx="\d+" cy="132" rx="2" ry="2"[^>]*/>', "", text)
    if part in ("face_neutral", "face_pleased", "face_hungry"):
        text = text.replace("</svg>", eyelids("#dfae82") + "</svg>")
    return text


# ------------------------------------------------------------------ Prompt Bhai
def prompt(part: str, text: str) -> str:
    text = text.replace("#ef6a5d", "#4aa8ff").replace("#bb3b3f", "#1f5fbf").replace("#d9473f", "#f4f4f8")
    if part == "body":
        text = sub(text, r'<path d="M104 206 Q160 214[^>]*/>',
                   '<path d="M138 208 l-16 18 l16 18 M182 208 l16 18 l-16 18 M168 202 l-14 50" fill="none" stroke="#fbfdff" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" />')
        text = sub(text, r'<path d="M146 222 l14 -16[^>]*/>', '')
        # Headphones resting round the neck.
        text = text.replace("</svg>", '<path d="M122 170 Q160 206 198 170" fill="none" stroke="#22222e" stroke-width="9" stroke-linecap="round" />'
                            '<rect x="112" y="166" width="16" height="26" rx="7" fill="#22222e" stroke="#453747" stroke-width="3" />'
                            '<rect x="192" y="166" width="16" height="26" rx="7" fill="#22222e" stroke="#453747" stroke-width="3" /></svg>')
    if part == "head":
        text = text.replace("#7a4a2c", "#1d1d26")
        text = re.sub(r'<ellipse cx="\d+" cy="132" rx="2" ry="2"[^>]*/>', "", text)
    return text


# ------------------------------------------------------------------ Mess Aunty
def aunty(part: str, text: str) -> str:
    text = text.replace("#c7b1e0", "#e35a4a").replace("#7f68a8", "#9e2133").replace("#efe3f7", "#f6c453").replace("#efe3f7", "#f6c453")
    if part == "body":
        text = re.sub(r'<ellipse cx="150" cy="\d+" rx="4" ry="4"[^>]*/>', "", text)
        text = text.replace('<path d="M160 186 L160 306"', '<path d="M0 0"').replace("#5d4a80", "#7a1626").replace("#a48dc6", "#f2c14e")
        text = text.replace("#a993cc", "#f2c14e").replace("#fbf4ea", "#f6c453")
        # The saree's gold pallu across the chest and a gold border at the hem.
        text = text.replace("</svg>", '<path d="M126 172 Q172 214 226 250 L236 296 Q168 262 112 210 Z" fill="#f6c453" stroke="#453747" stroke-width="4" stroke-linejoin="round" />'
                            '<path d="M140 190 Q176 222 224 262" fill="none" stroke="#9e2133" stroke-width="4" stroke-linecap="round" />'
                            '<path d="M86 292 Q160 312 234 292" fill="none" stroke="#f6c453" stroke-width="7" stroke-linecap="round" /></svg>')
    if part == "head":
        # Black hair with a grey streak, jasmine in the bun, red bindi, gold earrings.
        text = text.replace("#d6d2dd", "#2a1c1e").replace("#dedae4", "#2a1c1e").replace("#a7a1b3", "#8d8794").replace("#f2e7ff", "#f6c453")
        text = text.replace("</svg>", '<circle cx="161" cy="86" r="4.5" fill="#d9262f" />'
                            '<circle cx="140" cy="30" r="5" fill="#ffffff" stroke="#453747" stroke-width="2" />'
                            '<circle cx="160" cy="22" r="5" fill="#ffffff" stroke="#453747" stroke-width="2" />'
                            '<circle cx="180" cy="30" r="5" fill="#ffffff" stroke="#453747" stroke-width="2" /></svg>')
    if part in ("arm_left", "arm_right"):
        text = text.replace("</svg>", '<path d="M224 251 L249 248 M226 258 L251 255" stroke="#f6c453" stroke-width="5" stroke-linecap="round" /></svg>' if part == "arm_right"
                            else '<path d="M71 247 L97 251 M70 254 L96 258" stroke="#f6c453" stroke-width="5" stroke-linecap="round" /></svg>')
    if part == "arm_right":
        ladle = ('<path d="M246 288 L284 224" stroke="#8a8f9c" stroke-width="7" stroke-linecap="round" />'
                 '<ellipse cx="292" cy="212" rx="16" ry="11" transform="rotate(-30 292 212)" fill="#c4c8d4" stroke="#453747" stroke-width="4" />')
        text = text.replace("</svg>", ladle + "</svg>")
    return text


# ------------------------------------------------------------------ Faccha
def faccha(part: str, text: str) -> str:
    text = text.replace("#ef6a5d", "#fff0a8").replace("#bb3b3f", "#e8c84a").replace("#d9473f", "#6aa7e0").replace("#3e6fb0", "#4a5a78")
    if part == "body":
        bag = ('<path d="M88 170 Q76 250 98 300 L224 300 Q246 250 232 170 Z" fill="#d94f3a" stroke="#453747" stroke-width="5" stroke-linejoin="round" />'
               '<path d="M110 270 L210 270" stroke="#8c2a1d" stroke-width="4" stroke-linecap="round" />')
        text = text.replace("</defs>", "</defs>" + bag, 1)
        text = sub(text, r'<path d="M104 206 Q160 214[^>]*/>', "")
        text = sub(text, r'<path d="M146 222 l14 -16[^>]*/>', "")
        text = text.replace("</svg>", '<path d="M126 170 Q122 224 132 270 M194 168 Q204 222 194 270" fill="none" stroke="#8c2a1d" stroke-width="9" stroke-linecap="round" />'
                            '<path d="M140 168 L160 222 L180 168" fill="none" stroke="#2f8f6a" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />'
                            '<path d="M144 222 L176 222 L176 262 L144 262 Z" fill="#ffffff" stroke="#453747" stroke-width="3" stroke-linejoin="round" />'
                            '<path d="M144 236 L176 236 L176 246 L144 246 Z" fill="#d9262f" />'
                            '<circle cx="160" cy="229" r="3.5" fill="#453747" /></svg>')
    if part == "head":
        text = text.replace("#7a4a2c", "#2a2024")
        text = re.sub(r'<ellipse cx="\d+" cy="132" rx="2" ry="2"[^>]*/>', "", text)
    if part.startswith("face_"):
        # Huge anxious eyes.
        text = text.replace('rx="9" ry="11"', 'rx="11" ry="13"').replace('rx="4" ry="5"', 'rx="3" ry="4"')
        if part == "face_neutral":
            text = text.replace("M126 94 q11 -5 22 -1 M173 93 q11 -4 22 1", "M124 90 q11 -3 22 -9 M175 81 q11 6 22 9")
    return text


# ------------------------------------------------------------------ Dassi
HAIR = "#2a1c1e"
BACK_HAIR = (
    f'<path d="M97 108 Q94 38 161 34 Q228 38 225 108 Q236 178 216 218 Q194 204 190 164 L132 164 '
    f'Q128 204 106 218 Q86 178 97 108 Z" fill="{HAIR}" stroke="{INK}" stroke-width="5" '
    f'stroke-linecap="round" stroke-linejoin="round" />'
)
FRINGE = (
    f'<path d="M106 108 Q103 54 161 48 Q219 54 216 108 Q200 74 172 80 Q156 64 134 84 Q116 90 106 108 Z" '
    f'fill="{HAIR}" stroke="{INK}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />'
    '<path d="M126 62 Q150 50 176 58" fill="none" stroke="#4a3236" stroke-width="4" stroke-linecap="round" />'
    '<path d="M194 66 l5 -9 l5 9 l-9 -5 l10 0 Z" fill="#ffd27a" stroke="#453747" stroke-width="2.5" '
    'stroke-linecap="round" stroke-linejoin="round" />'
    '<circle cx="105" cy="136" r="4" fill="#ffd27a" stroke="#453747" stroke-width="2" />'
    '<circle cx="215" cy="136" r="4" fill="#ffd27a" stroke="#453747" stroke-width="2" />'
)


def dassi(part: str, text: str) -> str:
    text = text.replace("#ef6a5d", "#43c4b2").replace("#bb3b3f", "#1f8a86").replace("#3e6fb0", "#2f4f86").replace("#d9473f", "#e0679a")
    if part == "head":
        text = text.replace('<ellipse cx="106" cy="116"', BACK_HAIR + '<ellipse cx="106" cy="116"', 1)
        text = sub(text, r'<path d="M104 106 Q96 62[^>]*/>', FRINGE)
        text = re.sub(r'<ellipse cx="\d+" cy="132" rx="2" ry="2"[^>]*/>', "", text)
    if part.startswith("face_"):
        text = text.replace("</svg>", (LASHES if "frightened" not in part else "") + specs("#7a2e50", 2.6) + "</svg>")
    return text


def main() -> None:
    build("prof", "boss", prof)
    build("kassi", "intern", kassi)
    build("saap", "kid", saap)
    build("prompt", "kid", prompt)
    build("aunty", "grandma", aunty)
    build("faccha", "kid", faccha)
    build("dassi", "kid", dassi)

    manifest = ROOT / "src/assets/stage_manifest.json"
    data = json.loads(manifest.read_text(encoding="utf-8"))
    scales = {"prof": 0.49, "kassi": 0.5, "saap": 0.38, "prompt": 0.38, "aunty": 0.45, "faccha": 0.31, "dassi": 0.44}
    for art, scale in scales.items():
        data["characters"][art] = {"rig": f"res://assets/characters/{art}/rig.json", "scale": scale}
    manifest.write_text(json.dumps(data, indent="\t") + "\n", encoding="utf-8")
    print("manifest updated")


if __name__ == "__main__":
    main()
