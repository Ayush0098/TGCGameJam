"""Original deterministic, nonverbal cartoon animal vocals, synthesized with NumPy.

Production helper only: returns mono float32 PCM; never writes a file or needs a
speech model. These are stylized voiced performances, not recordings of animals.
"""

from __future__ import annotations

import hashlib
import numpy as np


def _envelope(n: int, rate: int, attack: float = .04, release: float = .10) -> np.ndarray:
    env = np.ones(n)
    a = min(n, max(2, round(attack * rate)))
    r = min(n, max(2, round(release * rate)))
    env[:a] *= np.sin(np.linspace(0, np.pi / 2, a)) ** 2
    env[-r:] *= np.cos(np.linspace(0, np.pi / 2, r)) ** 2
    return env


def _noise(n: int, rate: int, rng: np.random.Generator,
           low: float, high: float) -> np.ndarray:
    """Soft spectral slopes avoid hard band edges and ringing."""
    white = rng.normal(size=n)
    freqs = np.fft.rfftfreq(n, 1 / rate)
    response = (freqs / np.maximum(freqs + low, 1)) ** 2
    response *= np.exp(-(freqs / high) ** 2)
    filtered = np.fft.irfft(np.fft.rfft(white) * response, n=n)
    return filtered / max(np.sqrt(np.mean(filtered ** 2)), 1e-9)


def _voice(t: np.ndarray, rate: int, pitch: np.ndarray,
           formants: tuple[float, ...], widths: tuple[float, ...],
           rng: np.random.Generator) -> np.ndarray:
    # Slowly changing pitch and a little jitter keep the source from a pure tone.
    f0 = pitch * (1 + .003 * np.sin(2 * np.pi * 19 * t))
    phase = 2 * np.pi * np.cumsum(f0) / rate
    mean_pitch = float(np.mean(f0))
    result = np.zeros(len(t))
    for harmonic in range(1, min(72, int(rate / (2 * max(f0))))):
        freq = mean_pitch * harmonic
        resonance = .08 + sum(
            np.exp(-.5 * ((freq - formant) / width) ** 2)
            for formant, width in zip(formants, widths)
        )
        result += resonance / harmonic ** 1.15 * np.sin(
            harmonic * phase + rng.uniform(-.14, .14)
        )
    return result / max(np.sqrt(np.mean(result ** 2)), 1e-9)


def generate_vocal(cue_id: str, sample_rate: int = 44100) -> np.ndarray:
    """Return safe mono float32 PCM for a known cue.

    Main cues: dog_sleep, cat_sleep, cat_clash, mouse_sleep.
    Short variants: {dog,cat,mouse}_blip_{1..4}. Unknown IDs raise ValueError.
    """
    if not isinstance(sample_rate, int) or sample_rate < 8000:
        raise ValueError("sample_rate must be an integer of at least 8000 Hz")
    seed = int.from_bytes(hashlib.sha256(cue_id.encode()).digest()[:8], "little")
    rng = np.random.default_rng(seed)
    is_blip = "_blip_" in cue_id
    if is_blip:
        animal, number = cue_id.split("_blip_", 1)
        if animal not in ("dog", "cat", "mouse") or number not in ("1", "2", "3", "4"):
            raise ValueError(f"Unknown animal vocal cue: {cue_id}")
        variant = int(number) - 1
        duration = (.145, .165, .155, .175)[variant]
    else:
        durations = {"dog_sleep": 1.35, "cat_sleep": 1.25,
                     "cat_clash": .90, "mouse_sleep": .95}
        if cue_id not in durations:
            raise ValueError(f"Unknown animal vocal cue: {cue_id}")
        animal = cue_id.split("_")[0]
        variant = 0
        duration = durations[cue_id]
    n = round(duration * sample_rate)
    t = np.arange(n) / sample_rate
    breath = _noise(n, sample_rate, rng, 180, min(4200, sample_rate * .42))

    if is_blip:
        base = {"dog": 132, "cat": 208, "mouse": 405}[animal]
        # A brief closed-mouth grunt/murmur, with four distinct pitch gestures.
        bend = (1.10 - .25 * t / duration, .91 + .23 * t / duration,
                1 + .10 * np.sin(np.pi * t / duration),
                1.15 - .32 * t / duration)[variant]
        formants = {"dog": (350, 850, 1900), "cat": (430, 1200, 2400),
                    "mouse": (780, 1900, 3200)}[animal]
        voiced = _voice(t, sample_rate, base * bend, formants, (140, 240, 350), rng)
        signal = (.30 * voiced + .028 * breath) * _envelope(n, sample_rate, .018, .055)
    elif cue_id == "dog_sleep":
        voiced = _voice(t, sample_rate, 113 - 17 * t / duration,
                        (310, 740, 1700), (140, 240, 350), rng)
        # Relaxed exhale followed by a smaller, rough closed-mouth sleeping breath.
        sigh = np.exp(-((t - .30) / .21) ** 2)
        snore = np.exp(-((t - .97) / .23) ** 2)
        roughness = .73 + .27 * np.sin(2 * np.pi * 31 * t)
        signal = .10 * breath * sigh + .13 * voiced * sigh
        signal += (.23 * voiced * roughness + .035 * breath) * snore
        signal *= _envelope(n, sample_rate, .045, .13)
    elif cue_id == "cat_sleep":
        voiced = _voice(t, sample_rate, 111 + 3 * np.sin(2 * np.pi * .9 * t),
                        (290, 720, 1600), (130, 200, 280), rng)
        purr = .40 + .60 * (.5 + .5 * np.sin(2 * np.pi * 26 * t)) ** 2
        breathing = .65 + .35 * np.sin(np.pi * t / duration)
        signal = (.24 * voiced * purr + .017 * breath) * breathing
        signal *= _envelope(n, sample_rate, .13, .22)
    elif cue_id == "cat_clash":
        voiced = _voice(t, sample_rate, 162 - 53 * t / duration,
                        (460, 1100, 2300), (180, 320, 450), rng)
        growl = .68 + .32 * np.sin(2 * np.pi * 39 * t)
        hiss_rise = np.clip((t - .28) / .20, 0, 1)
        signal = .23 * voiced * growl * (1 - .82 * hiss_rise)
        signal += .17 * breath * hiss_rise
        signal *= _envelope(n, sample_rate, .035, .18)
    else:  # mouse_sleep: two miniature breathy snores, not an electronic squeak.
        voiced = _voice(t, sample_rate, 340 - 35 * t / duration,
                        (680, 1650, 2900), (230, 350, 450), rng)
        pulses = np.exp(-((t - .23) / .105) ** 2)
        pulses += .7 * np.exp(-((t - .67) / .12) ** 2)
        signal = (.18 * voiced * (.83 + .17 * np.sin(2 * np.pi * 46 * t))
                  + .035 * breath) * pulses
        signal *= _envelope(n, sample_rate, .035, .10)

    signal -= np.mean(signal)
    # Final short taper removes DC-correction edge steps. Leave ample mix headroom.
    signal *= _envelope(n, sample_rate, .004, .009)
    peak = float(np.max(np.abs(signal)))
    if peak > .78:
        signal *= .78 / peak
    return signal.astype(np.float32)
