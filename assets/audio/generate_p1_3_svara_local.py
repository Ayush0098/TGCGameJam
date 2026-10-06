"""Local Svara TTS candidate generation for the page 1-3 Indian English script.

Requires the Apache-2.0 Svara OpenVINO INT4 model and SNAC decoder under the
ignored .codex/tools/voice directory. Outputs remain candidates until reviewed.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path

import numpy as np
import soundfile as sf
import torch
from optimum.intel import OVModelForCausalLM
from snac import SNAC
from transformers import AutoTokenizer

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/audio"))
import voice_audio_utils as pack
from generate_p1_3_svara import SCRIPT, OUTPUT, shape_chintu_rising, style, voice_gender

MODEL_DIR = ROOT / ".codex/tools/voice/svara_model"
SNAC_DIR = ROOT / ".codex/tools/voice/snac_24khz"
START_HUMAN = 128259
END_HUMAN = 128260
END_TURN = 128009
START_SPEECH = 128257
END_SPEECH = 128258
AUDIO_BASE = 128266


def chunks(text: str, max_words: int = 16) -> list[str]:
    sentences = re.split(r"(?<=[.!?])\s+(?=[A-Z])", text.replace("…", "..."))
    result = []
    current = ""
    for sentence in sentences:
        if not sentence:
            continue
        pieces = re.split(r"(?<=[,;:])\s+", sentence) if len(sentence.split()) > max_words else [sentence]
        for piece in pieces:
            if len((current + " " + piece).split()) <= max_words:
                current = (current + " " + piece).strip()
            else:
                if current:
                    result.append(current)
                current = piece
    if current:
        result.append(current)
    return result


def pronounce(text: str) -> str:
    substitutions = {
        r"\bKassi\b": "Kussie", r"\bDassi\b": "Dussie",
        r"\bSaap\b": "Saanp", r"\bfacchi\b": "fuh-chee",
        r"\bOBH\b": "O B H", r"\bCGPA\b": "C G P A",
        r"\bTAs\b": "T A's", r"\bChatGPT\b": "Chat G P T",
        r"\b11 PM\b": "eleven P M", r"\bLaTeX\b": "Lay-teck",
    }
    for pattern, replacement in substitutions.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    return text


def directed_parts(row: dict[str, str]) -> list[tuple[str, str, float]]:
    """Act the professor's setup and punchline as separate beats."""
    stem = Path(row["file"]).stem
    if stem == "page_03_dialogue_boss_lit":
        return [
            ("Office hours. Nobody comes.", "formal", 0.92),
            ("More cake for me!", "happy", 1.24),
        ]
    if stem == "page_03_dialogue_boss_gets_SCARED":
        return [
            ("Wait...", "surprise", 0.93),
            ("Someone is ATTENDING my office hours?!", "fear", 1.20),
        ]
    return [(part, style(row), 1.0) for part in chunks(row["text"])]


class Svara:
    def __init__(self, device: str):
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_DIR, local_files_only=True)
        self.model = OVModelForCausalLM.from_pretrained(MODEL_DIR, device=device, local_files_only=True)
        self.snac = SNAC.from_pretrained(str(SNAC_DIR)).eval()

    def speak(self, text: str, gender: str, mood: str) -> np.ndarray:
        prompt = f"English ({gender}): {pronounce(text)} <{mood}>"
        tokens = self.tokenizer(prompt, return_tensors="pt").input_ids
        prefix = torch.tensor([[START_HUMAN]], dtype=torch.int64)
        suffix = torch.tensor([[END_TURN, END_HUMAN]], dtype=torch.int64)
        input_ids = torch.cat([prefix, tokens, suffix], dim=1)
        with torch.inference_mode():
            output = self.model.generate(
                input_ids=input_ids,
                attention_mask=torch.ones_like(input_ids),
                max_new_tokens=2048,
                do_sample=True,
                temperature=0.7,
                top_p=0.8,
                repetition_penalty=1.1,
                eos_token_id=END_SPEECH,
            )
        generated = output[0].tolist()
        if START_SPEECH not in generated:
            raise ValueError("No start-of-speech marker")
        generated = generated[len(generated) - generated[::-1].index(START_SPEECH):]
        generated = [token for token in generated if token != END_SPEECH]
        generated = generated[:len(generated) // 7 * 7]
        if not generated:
            raise ValueError("No audio tokens")
        levels = [[], [], []]
        for index in range(0, len(generated), 7):
            frame = generated[index:index + 7]
            values = [frame[i] - AUDIO_BASE - i * 4096 for i in range(7)]
            if any(v < 0 or v >= 4096 for v in values):
                raise ValueError("Audio code outside SNAC vocabulary")
            levels[0].append(values[0])
            levels[1].extend([values[1], values[4]])
            levels[2].extend([values[2], values[3], values[5], values[6]])
        codes = [torch.tensor(level, dtype=torch.long).unsqueeze(0) for level in levels]
        with torch.inference_mode():
            audio = self.snac.decode(codes).squeeze().cpu().numpy()
        return np.asarray(audio, dtype=np.float64)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ids", help="Comma-separated file stems; default all")
    parser.add_argument("--device", default="GPU", choices=["GPU", "CPU"])
    parser.add_argument("--redo", action="store_true")
    args = parser.parse_args()
    rows = json.loads(SCRIPT.read_text(encoding="utf-8"))
    selected = set(args.ids.split(",")) if args.ids else None
    OUTPUT.mkdir(parents=True, exist_ok=True)
    model = Svara(args.device)
    for row in rows:
        stem = Path(row["file"]).stem
        if selected is not None and stem not in selected:
            continue
        output = OUTPUT / row["file"]
        if output.exists() and not args.redo:
            print(f"SKIP {stem}", flush=True)
            continue
        segments = []
        for part, mood, gain in directed_parts(row):
            start = time.monotonic()
            audio = model.speak(part, voice_gender(row["voice"]), mood)
            print(f"PART {stem} {len(part.split())} words {len(audio)/24000:.2f}s generated in {time.monotonic()-start:.1f}s", flush=True)
            segments.append(audio * gain)
        gap = 4800 if stem.startswith("page_03_dialogue_boss_") else 2400
        samples = np.concatenate([value for part in segments for value in (part, np.zeros(gap))])
        samples = pack.finish(pack.resample(samples, 24000))
        if stem == "page_01_dialogue_dog_lit":
            samples = shape_chintu_rising(samples)
        sf.write(output, samples, pack.SR, format="MP3", subtype="MPEG_LAYER_III")
        print(f"OK {stem} {pack.metrics(output)['duration_seconds']:.2f}s", flush=True)


if __name__ == "__main__":
    main()
