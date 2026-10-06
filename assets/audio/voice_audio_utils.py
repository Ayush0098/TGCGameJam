"""Small waveform helpers for the Indian English candidate voice pipeline."""
from __future__ import annotations

import hashlib
from pathlib import Path

import numpy as np
import soundfile as sf

SR = 44100


def resample(samples: np.ndarray, old_rate: int) -> np.ndarray:
    ratio = old_rate / SR
    positions = np.arange(int(len(samples) / ratio)) * ratio
    centres = positions.astype(np.int64)
    output = np.zeros(len(positions), dtype=np.float64)
    norm = np.zeros(len(positions), dtype=np.float64)
    cutoff = min(1.0, 1.0 / ratio)
    for offset in range(-16, 17):
        indices = centres + offset
        distance = positions - indices
        weight = cutoff * np.sinc(cutoff * distance) * np.where(
            abs(distance) < 17, 0.5 + 0.5 * np.cos(np.pi * distance / 17), 0
        )
        valid = (indices >= 0) & (indices < len(samples))
        output += samples[np.clip(indices, 0, len(samples) - 1)] * weight * valid
        norm += weight * valid
    return output / np.maximum(norm, 1e-8)


def finish(samples: np.ndarray) -> np.ndarray:
    x = np.asarray(samples, dtype=np.float64).copy()
    if not len(x) or not np.isfinite(x).all():
        raise ValueError("Invalid waveform")
    # Trim digital zero before DC removal so padding does not become audible.
    peak = np.max(np.abs(x))
    active = np.flatnonzero(np.abs(x) > max(0.0005, peak * 0.003))
    if not len(active):
        raise ValueError("Silent waveform")
    margin = int(SR * 0.015)
    x = x[max(0, int(active[0]) - margin):min(len(x), int(active[-1]) + margin + 1)]
    x -= np.mean(x)
    fade = min(int(SR * 0.004), len(x) // 4)
    x[:fade] *= np.linspace(0, 1, fade)
    x[-fade:] *= np.linspace(1, 0, fade)
    active_x = x[np.abs(x) > max(0.003, np.max(np.abs(x)) * 0.035)]
    gain = 10 ** (-19 / 20) / np.sqrt(np.mean(active_x * active_x))
    x *= min(gain, 0.9 / np.max(np.abs(x)))
    return x


def metrics(path: Path) -> dict:
    x, rate = sf.read(path, always_2d=True)
    if rate != SR or x.shape[1] != 1 or not np.isfinite(x).all():
        raise ValueError(f"Wrong output format: {path}")
    mono = x[:, 0]
    peak = float(np.max(np.abs(mono)))
    threshold = max(0.0008, peak * 0.008)
    active = np.flatnonzero(np.abs(mono) > threshold)
    if not len(active):
        raise ValueError(f"Silent output: {path}")
    return {
        "duration_seconds": round(len(mono) / rate, 4),
        "sample_rate": rate,
        "channels": 1,
        "peak": round(peak, 5),
        "leading_silence_seconds": round(active[0] / rate, 4),
        "trailing_silence_seconds": round((len(mono) - 1 - active[-1]) / rate, 4),
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
    }
