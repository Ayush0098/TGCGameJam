"""Cut the ChatGPT cast art into cutout rigs (src/assets/characters/<art>/, PNG parts).

Input  assets/art/story/<art>_master.png  (full body)  and  <art>_faces.png  (7 heads).
Output a rig.json plus 320x400 transparent part textures per character, with the same
part names and animations as the SVG rigs (head, body, arm_left, arm_right, leg_left,
leg_right, seven face overlays), so every walk / eat / sit / bonk / celebrate works.

The master is split by the rectangles below (coordinates read off the 2000 px preview
of each 2048 px master). Heads and faces come from the faces sheet so the expression
swap is a whole-head swap and always matches the hair and glasses.

    python assets/production/slice_cast_art.py [art ...]
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "assets/art/story"
OUT = ROOT / "src/assets/characters"
K = 1.024  # preview px -> master px
CANVAS = (320, 400)
FIGURE_HEIGHT = 352.0  # master figure height on the canvas
FEET_Y = 380.0
FACES = ["neutral", "pleased", "hungry", "sleepy", "angry", "frightened", "surprised"]

# head_box: head incl. hair; neck_y: head/torso split; hip_y: torso/legs split;
# arm_l / arm_r: x0, y0, x1, y1; leg_x: split between the legs; pivots in preview px.
CAST = {
    "prof": dict(head_box=(655, 98, 1295, 757), neck_y=735, hip_y=1300, leg_x=962,
                 arm_l=(455, 740, 705, 1375), arm_r=(1175, 740, 1475, 1375),
                 shoulder_l=(700, 830), shoulder_r=(1190, 830)),
    "kassi": dict(head_box=(612, 92, 1280, 745), neck_y=722, hip_y=1290, leg_x=962,
                  arm_l=(470, 745, 700, 1375), arm_r=(1205, 745, 1430, 1375),
                  shoulder_l=(690, 850), shoulder_r=(1205, 850)),
    "saap": dict(head_box=(632, 60, 1290, 690), neck_y=685, hip_y=1275, leg_x=962,
                 arm_l=(470, 780, 715, 1400), arm_r=(1210, 780, 1445, 1400),
                 shoulder_l=(690, 850), shoulder_r=(1215, 850)),
    "prompt": dict(head_box=(625, 68, 1285, 750), neck_y=700, hip_y=1285, leg_x=962,
                   arm_l=(405, 790, 738, 1380), arm_r=(1180, 790, 1480, 1380),
                   shoulder_l=(700, 870), shoulder_r=(1200, 870)),
    "aunty": dict(head_box=(640, 98, 1320, 705), neck_y=685, hip_y=1640, leg_x=968, leg_half=420,
                  arm_l=(265, 390, 662, 1170), arm_r=(1255, 760, 1555, 1380),
                  shoulder_l=(660, 880), shoulder_r=(1280, 880)),
    "faccha": dict(head_box=(622, 115, 1285, 735), neck_y=715, hip_y=1290, leg_x=962,
                   arm_l=(375, 880, 720, 1500), arm_r=(1185, 880, 1400, 1360),
                   shoulder_l=(680, 930), shoulder_r=(1215, 930)),
    "dassi": dict(head_box=(640, 85, 1285, 705), neck_y=668, hip_y=1260, leg_x=962,
                  arm_l=(545, 870, 800, 1380), arm_r=(945, 800, 1330, 1140),
                  shoulder_l=(780, 930), shoulder_r=(1200, 900)),
}


def background(rgb: np.ndarray) -> np.ndarray:
    """True where the plain light-grey backdrop is (connected to the border)."""
    low = rgb.min(axis=2)
    spread = rgb.max(axis=2).astype(int) - low.astype(int)
    candidate = (low > 168) & (spread < 30)
    labels, _ = ndimage.label(candidate)
    border = set(np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))) - {0}
    mask = np.isin(labels, list(border))
    # Eat the soft grey fringe next to the outline, but never the dark outline itself.
    grown = ndimage.binary_dilation(mask, iterations=2)
    return mask | (grown & (rgb.max(axis=2) > 150))


def cut_out(path: Path) -> np.ndarray:
    rgb = np.asarray(Image.open(path).convert("RGB"))
    alpha = np.where(background(rgb), 0, 255).astype(np.uint8)
    alpha = ndimage.binary_opening(alpha > 0, iterations=1).astype(np.uint8) * 255
    return np.dstack([rgb, alpha])


def resize_premultiplied(array: np.ndarray, scale: float) -> Image.Image:
    image = Image.fromarray(array, "RGBA").convert("RGBa")
    size = (max(1, round(array.shape[1] * scale)), max(1, round(array.shape[0] * scale)))
    return image.resize(size, Image.LANCZOS).convert("RGBA")


def paste(canvas: Image.Image, layer: Image.Image, x: float, y: float) -> None:
    canvas.alpha_composite(layer, (round(x), round(y))) if 0 <= round(x) and 0 <= round(y) and round(x) + layer.width <= canvas.width and round(y) + layer.height <= canvas.height else _clipped(canvas, layer, round(x), round(y))


def _clipped(canvas: Image.Image, layer: Image.Image, x: int, y: int) -> None:
    left, top = max(0, -x), max(0, -y)
    right = min(layer.width, canvas.width - x)
    bottom = min(layer.height, canvas.height - y)
    if right > left and bottom > top:
        canvas.alpha_composite(layer.crop((left, top, right, bottom)), (x + left, y + top))


def save_png(image: Image.Image, path: Path) -> None:
    # Flat-colour art: a palette keeps the web build small.
    image.quantize(colors=160, method=Image.FASTOCTREE, dither=Image.NONE).save(path, optimize=True)


def head_components(sheet: np.ndarray) -> list:
    alpha = sheet[..., 3] > 0
    labels, count = ndimage.label(alpha)
    boxes = ndimage.find_objects(labels)
    items = []
    for index, box in enumerate(boxes, 1):
        area = int((labels[box] == index).sum())
        if area > 40000:
            items.append((box, index))
    items.sort(key=lambda item: (item[0][0].start // 400, item[0][1].start))
    return [(box, labels == index) for box, index in items]


def build(art: str) -> None:
    spec = CAST[art]
    master = cut_out(ART / f"{art}_master.png")
    sheet = cut_out(ART / f"{art}_faces.png")
    height, width = master.shape[:2]
    figure = master[..., 3] > 0
    rows = np.flatnonzero(figure.any(axis=1))
    top, bottom = rows[0], rows[-1]
    scale = FIGURE_HEIGHT / (bottom - top + 1)
    cx = (spec["head_box"][0] + spec["head_box"][2]) * 0.5 * K
    ox = CANVAS[0] * 0.5 - cx * scale
    oy = FEET_Y - (bottom + 1) * scale

    def px(value: float) -> float:
        return value * K

    yy, xx = np.mgrid[0:height, 0:width]
    # Margin so fingertips never spill into the legs region.
    arm_l = (xx >= px(spec["arm_l"][0] - 45)) & (xx < px(spec["arm_l"][2])) & (yy >= px(spec["arm_l"][1])) & (yy < px(spec["arm_l"][3]))
    arm_r = (xx >= px(spec["arm_r"][0])) & (xx < px(spec["arm_r"][2] + 45)) & (yy >= px(spec["arm_r"][1])) & (yy < px(spec["arm_r"][3]))
    arm_r &= ~arm_l
    legs = (yy >= px(spec["hip_y"])) & ~arm_l & ~arm_r & (np.abs(xx - px(spec["leg_x"])) < px(spec.get("leg_half", 310)))
    below_neck = (yy >= px(spec["neck_y"])) & ~arm_l & ~arm_r & ~legs
    regions = {
        "leg_left": legs & (xx < px(spec["leg_x"])),
        "leg_right": legs & (xx >= px(spec["leg_x"])),
        "arm_left": arm_l,
        "body": below_neck,
        "arm_right": arm_r,
    }

    def part_image(mask: np.ndarray) -> Image.Image:
        # Parts overlap their neighbours by a few pixels so no seam shows when they rotate.
        mask = ndimage.binary_dilation(mask, iterations=7) & figure
        layer = master.copy()
        layer[..., 3] = np.where(mask, layer[..., 3], 0)
        small = resize_premultiplied(layer, scale)
        canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
        paste(canvas, small, ox, oy)
        return canvas

    target = OUT / art
    target.mkdir(parents=True, exist_ok=True)
    for old in target.glob("*"):
        old.unlink()
    for name, mask in regions.items():
        save_png(part_image(mask), target / f"{name}.png")

    # Heads from the faces sheet, aligned to the master's head box (chin and centre).
    comps = head_components(sheet)
    if len(comps) < 7:
        raise SystemExit(f"{art}: found {len(comps)} heads in the faces sheet, expected 7")
    neutral_box = comps[0][0]
    neutral_width = neutral_box[1].stop - neutral_box[1].start
    head_w = (spec["head_box"][2] - spec["head_box"][0]) * K
    head_scale = head_w / neutral_width
    centre_x = (spec["head_box"][0] + spec["head_box"][2]) * 0.5 * K
    head_top = spec["head_box"][1] * K
    # Every head is cropped to its own box, then placed so its top-centre lands where
    # the neutral head's does: the hair never jumps when the expression changes.
    target_cx = ox + centre_x * scale
    target_top = oy + head_top * scale
    for name, (box, mask) in zip(FACES, comps):
        layer = sheet.copy()
        layer[..., 3] = np.where(mask, layer[..., 3], 0)
        y0, y1, x0, x1 = box[0].start, box[0].stop, box[1].start, box[1].stop
        cropped = layer[y0:y1, x0:x1]
        small = resize_premultiplied(cropped, head_scale * scale)
        canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
        paste(canvas, small, target_cx - small.width * 0.5, target_top)
        save_png(canvas, target / f"face_{name}.png")
    head_png = Image.open(target / "face_neutral.png")
    head_png.save(target / "head.png")

    def canvas_point(point: tuple) -> list:
        return [round(ox + px(point[0]) * scale), round(oy + px(point[1]) * scale)]

    hip_l = canvas_point((spec["leg_x"] - 130, spec["hip_y"]))
    hip_r = canvas_point((spec["leg_x"] + 130, spec["hip_y"]))
    neck = canvas_point((spec["head_box"][0] * 0.5 + spec["head_box"][2] * 0.5, spec["head_box"][3] - 25))
    body_pivot = canvas_point((spec["head_box"][0] * 0.5 + spec["head_box"][2] * 0.5, (spec["neck_y"] + spec["hip_y"]) * 0.5))
    parts = [
        {"name": "leg_left", "texture": f"res://assets/characters/{art}/leg_left.png", "pivot": hip_l, "z": -3},
        {"name": "leg_right", "texture": f"res://assets/characters/{art}/leg_right.png", "pivot": hip_r, "z": -2},
        {"name": "arm_left", "texture": f"res://assets/characters/{art}/arm_left.png", "pivot": canvas_point(spec["shoulder_l"]), "z": -1},
        {"name": "body", "texture": f"res://assets/characters/{art}/body.png", "pivot": body_pivot, "z": 0},
        {"name": "arm_right", "texture": f"res://assets/characters/{art}/arm_right.png", "pivot": canvas_point(spec["shoulder_r"]), "z": 1},
        {"name": "head", "texture": f"res://assets/characters/{art}/head.png", "pivot": neck, "z": 2},
    ]
    rig = {
        "id": art, "canvas": list(CANVAS), "anchor": [160, 380], "parts": parts,
        "expressions": {name: f"res://assets/characters/{art}/face_{name}.png" for name in FACES},
        "animations": ["idle", "walk", "startle", "run", "eat", "sit", "sleep", "bonk", "ko", "exit", "celebrate"],
        "author": f"{art}: cut from the ChatGPT cast art (assets/art/story/{art}_master.png and _faces.png)",
    }
    (target / "rig.json").write_text(json.dumps(rig, indent=2), encoding="utf-8")
    size = sum(f.stat().st_size for f in target.glob("*.png"))
    print(f"{art}: {len(list(target.glob('*.png')))} textures, {size // 1024} KB")


def main() -> None:
    for art in (sys.argv[1:] or list(CAST)):
        build(art)


if __name__ == "__main__":
    main()
