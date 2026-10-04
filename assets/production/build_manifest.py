"""Catalogue produced reference assets separately from future production work."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "src" / "assets"


def build():
    characters = {}
    for name in ("boss", "dog"):
        rig_path = RUNTIME / "characters" / name / "rig.json"
        rig = json.loads(rig_path.read_text(encoding="utf-8"))
        resources = [part["texture"] for part in rig["parts"]]
        resources += list(rig["expressions"].values())
        for resource in resources:
            if not (ROOT / "src" / resource.removeprefix("res://")).is_file():
                raise ValueError(f"Missing rig texture: {resource}")
        characters[name] = {
            "rig": f"res://assets/characters/{name}/rig.json",
            "canvas": rig["canvas"], "anchor": rig["anchor"],
            "parts": rig["parts"], "expressions": rig["expressions"],
            "animations": ["idle", "walk", "startle", "run", "eat", "sit",
                           "sleep", "bonk", "ko", "exit", "celebrate"],
        }
    runtime = {
        "version": 1, "status": "production_reference",
        "background": "res://assets/backgrounds/living_room_reference.png",
        "characters": characters,
        "thoughts": {name: f"res://assets/thoughts/{name}.svg"
                     for name in ("hungry", "sleepy", "angry", "scared")},
        "dialogue": "res://assets/audio/reference/cues.json",
    }
    for resource in [runtime["background"], runtime["dialogue"], *runtime["thoughts"].values()]:
        if not (ROOT / "src" / resource.removeprefix("res://")).is_file():
            raise ValueError(f"Missing reference resource: {resource}")
    (RUNTIME / "reference_manifest.json").write_text(json.dumps(runtime, indent=2) + "\n", encoding="utf-8")
    catalogue = {
        "version": 1, "batch": 1, "runtime_manifest": "src/assets/reference_manifest.json",
        "produced": {
            "living_room": {"status": "reference", "method": "built-in imagegen",
                            "runtime": runtime["background"],
                            "master": "assets/art/backgrounds/living_room_reference.png"},
            "boss": {"status": "reference", "rig": characters["boss"]["rig"]},
            "dog": {"status": "reference", "rig": characters["dog"]["rig"]},
            "thoughts": {"status": "reference", "resources": runtime["thoughts"]},
            "voices": {"status": "audition", "cues": runtime["dialogue"]},
        },
        "planned": {
            "characters": ["grandma", "kid", "intern", "cat", "mouse", "editor_hand", "editor_portrait"],
            "backgrounds": ["kitchen", "office", "editor_desk"],
            "props": ["cake", "pie", "fish", "cookie", "broccoli", "chair", "armchair",
                      "dog_bed", "lantern", "pedal_off", "pedal_on", "lamp_off", "lamp_on",
                      "curtain_obstacle", "screen_obstacle"],
            "effects": ["ding", "chomp", "bonk", "zoom", "stars", "crumbs", "dust",
                        "ink_sweep", "twist_stamp", "border_reaction"],
            "interface": ["title", "level_cards", "goal_caption", "buttons", "settings",
                          "original_twist_tabs", "credits"],
            "audio": ["character_dialogue", "event_recaps", "level_conclusions", "epilogue",
                      "reveal_stingers", "footsteps", "switch", "impacts", "rewind", "music"],
        },
    }
    catalogue_path = ROOT / "assets/production/asset_manifest.json"
    if catalogue_path.exists():
        previous = json.loads(catalogue_path.read_text(encoding="utf-8"))
        # Rebuilding the gallery must preserve independently produced stage assets.
        for key, value in previous.get("produced", {}).items():
            if key not in catalogue["produced"]:
                catalogue["produced"][key] = value
        catalogue["planned"] = previous.get("planned", catalogue["planned"])
        if "integration_status" in previous:
            catalogue["integration_status"] = previous["integration_status"]
    catalogue_path.write_text(json.dumps(catalogue, indent=2) + "\n", encoding="utf-8")
    print("Reference manifests generated; future assets remain explicitly planned.")


if __name__ == "__main__":
    build()
