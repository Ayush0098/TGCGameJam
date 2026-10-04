"""Generate original dialogue locally. Models/dependencies stay in ignored .codex/.

Windows setup (from repository root):
  python -m venv .codex/tools/voice/env
  .codex/tools/voice/env/Scripts/python -m pip install -r assets/audio/requirements-reference.txt
  .codex/tools/voice/env/Scripts/python assets/audio/generate_reference.py --download-models

The Kokoro wrapper's native eSpeak tokenizer is used; Misaki is optional upstream
and is not required by this workflow. No speech service or API key is involved.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODEL_RELEASE = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.1/"
MODELS = {
    "kokoro-v1.0.onnx": "beb0d1848dee9a49da392cc3df26958d46cfa35d321edf434f52949153f0df3a",
    "voices-v1.0.bin": "bca610b8308e8d99f32e6fe4197e7ec01679264efed0cac9140fe9c29f1fbf7d",
}


def digest(path: Path) -> str:
    sha = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            sha.update(block)
    return sha.hexdigest()


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def prepare_model(path: Path, expected: str | None, download: bool) -> str:
    if not path.exists():
        if not download or not expected:
            raise RuntimeError(f"Missing model: {path}; use --download-models for official defaults.")
        path.parent.mkdir(parents=True, exist_ok=True)
        temporary = path.with_suffix(path.suffix + ".download")
        print(f"Downloading {path.name}", flush=True)
        urllib.request.urlretrieve(MODEL_RELEASE + path.name, temporary)
        if digest(temporary) != expected:
            temporary.unlink()
            raise RuntimeError(f"Download checksum mismatch: {path.name}")
        temporary.replace(path)
    actual = digest(path)
    if expected and actual != expected:
        raise RuntimeError(f"Model checksum mismatch: {path}")
    return actual


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=ROOT / "assets/audio/reference_cues.json")
    parser.add_argument("--masters", type=Path, default=ROOT / "assets/audio/reference")
    parser.add_argument("--output", type=Path, default=ROOT / "src/assets/audio/reference")
    parser.add_argument("--resource-prefix", default="res://assets/audio/reference")
    parser.add_argument("--model", type=Path, default=ROOT / ".codex/tools/voice/kokoro-v1.0.onnx")
    parser.add_argument("--voices", type=Path, default=ROOT / ".codex/tools/voice/voices-v1.0.bin")
    parser.add_argument("--download-models", action="store_true")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    import numpy as np
    import soundfile as sf
    from kokoro_onnx import Kokoro

    source = json.loads(args.input.read_text(encoding="utf-8"))
    if source.get("version") != 1 or not isinstance(source.get("cues"), list):
        raise ValueError("Expected version 1 cue manifest.")
    seen = set()
    for cue in source["cues"]:
        if not re.fullmatch(r"[a-z][a-z0-9_]*", cue["id"]) or cue["id"] in seen:
            raise ValueError(f"Invalid or duplicate cue id: {cue['id']}")
        seen.add(cue["id"])
        if not cue["text"].strip() or not cue["speaker"].strip():
            raise ValueError("Every cue requires text and speaker.")
        if cue.get("lang", "en-us") not in ("en-us", "en-gb"):
            raise ValueError("This reference workflow supports US/British English only.")
        if not 0.5 <= float(cue.get("speed", 1.0)) <= 2.0:
            raise ValueError("Cue speed must be 0.5–2.0.")

    hashes = {}
    for path in (args.model, args.voices):
        default = ROOT / ".codex/tools/voice" / path.name
        expected = MODELS.get(path.name) if path.resolve() == default.resolve() else None
        hashes[path.name] = prepare_model(path, expected, args.download_models)
    versions = {name: importlib.metadata.version(name) for name in
                ("kokoro-onnx", "soundfile", "onnxruntime", "numpy", "phonemizer", "espeakng-loader")}
    local = ROOT / ".codex/tools/voice"
    write_json(local / "model_metadata.json", {"release": MODEL_RELEASE, "sha256": hashes, "dependencies": versions})
    cache_path = local / "generation_cache.json"
    cache = json.loads(cache_path.read_text()) if cache_path.exists() else {}
    args.masters.mkdir(parents=True, exist_ok=True)
    args.output.mkdir(parents=True, exist_ok=True)
    extension = "ogg" if "VORBIS" in sf.available_subtypes("OGG") else "wav"
    model = None
    results = []
    for cue in source["cues"]:
        key_data = {"cue": cue, "models": hashes, "versions": versions,
                    "generator_sha256": digest(Path(__file__)), "encoding": extension}
        key = hashlib.sha256(json.dumps(key_data, sort_keys=True).encode()).hexdigest()
        master = args.masters / f"{cue['id']}.wav"
        output = args.output / f"{cue['id']}.{extension}"
        entry = cache.get(cue["id"], {})
        cached = not args.force and entry.get("key") == key and master.exists() and output.exists()
        if cached:
            cached = digest(master) == entry.get("master_sha256") and digest(output) == entry.get("audio_sha256")
        if not cached:
            if model is None:
                model = Kokoro(str(args.model), str(args.voices))
            if cue["voice"] not in model.voices:
                raise ValueError(f"Unknown voice: {cue['voice']}")
            print(f"Generating {cue['id']} ({cue['voice']})", flush=True)
            samples, sample_rate = model.create(cue["text"], voice=cue["voice"],
                                                speed=float(cue.get("speed", 1.0)), lang=cue.get("lang", "en-us"))
            if not len(samples) or not np.isfinite(samples).all():
                raise RuntimeError(f"Invalid generated waveform: {cue['id']}")
            peak = float(np.max(np.abs(samples)))
            # Preserve at least 1 dB headroom, without amplifying quiet speech.
            if peak > 0.89:
                samples = samples * (0.89 / peak)
            sf.write(master, samples, sample_rate, subtype="PCM_16")
            sf.write(output, samples, sample_rate, format="OGG" if extension == "ogg" else "WAV",
                     subtype="VORBIS" if extension == "ogg" else "PCM_16")
        else:
            print(f"Cached {cue['id']}", flush=True)
        # Inspect decoded deliverables too, not just the inference output.
        samples, sample_rate = sf.read(output)
        peak = float(np.max(np.abs(samples))) if len(samples) else 0.0
        rms = float(np.sqrt(np.mean(samples ** 2))) if len(samples) else 0.0
        duration = len(samples) / sample_rate
        if not np.isfinite(samples).all() or duration < 0.5 or rms < 0.001 or peak >= 0.999:
            raise RuntimeError(f"Silent, clipped or invalid delivered waveform: {cue['id']}")
        result = {"id": cue["id"], "speaker": cue["speaker"], "text": cue["text"],
                  "voice": cue["voice"], "audio": f"{args.resource_prefix.rstrip('/')}/{output.name}",
                  "duration_seconds": round(duration, 4)}
        results.append(result)
        cache[cue["id"]] = {"key": key, "master_sha256": digest(master), "audio_sha256": digest(output),
                            "duration_seconds": duration, "peak": peak, "rms": rms, "sample_rate": sample_rate}
        write_json(cache_path, cache)
        print(f"{cue['id']}: {duration:.2f}s, peak {peak:.3f}, RMS {rms:.3f}", flush=True)
    write_json(args.output / "cues.json", {"version": 1, "cues": results})
    print(f"Produced {len(results)} cues. Waveform checks passed; human audition still required.")


if __name__ == "__main__":
    main()
