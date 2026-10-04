"""Original procedural music for LIGHTBULB MOMENT (no samples, no libraries).

Writes 16-bit mono WAVs to src/assets/audio/music/:
  plan_loop.wav    soft jazzy loop: walking bass, brushed drums, electric-piano chords
  action_loop.wav  same tempo and length, adds kick, horn stabs and a busier ride
  win_sting.wav    short rising brass flourish
  fail_sting.wav   sad "wah-wah" trombone slide
Both loops are exactly 8 bars at 112 bpm so the game can crossfade between
them on the same playback position. Deterministic: the same file every run.
"""
from pathlib import Path
import math
import random
import struct
import wave

RATE = 22050
BPM = 112
BEAT = 60.0 / BPM
BARS = 8
LOOP = BARS * 4 * BEAT
OUT = Path(__file__).resolve().parents[2] / "src/assets/audio/music"

# ii-V-I-VI in F, twice: Gm7 C7 Fmaj7 D7
CHORDS = [
    ("G", [55, 58, 62, 65]), ("C", [48, 52, 55, 58]), ("F", [53, 57, 60, 64]), ("D", [50, 54, 57, 60]),
] * 2
BASS_ROOT = {"G": 43, "C": 36, "F": 41, "D": 38}


def freq(note):
    return 440.0 * 2 ** ((note - 69) / 12.0)


def buffer(seconds):
    return [0.0] * int(seconds * RATE)


def add(buf, start, samples, gain=1.0):
    i0 = int(start * RATE)
    for i, value in enumerate(samples):
        j = i0 + i
        if j >= len(buf):
            j -= len(buf)  # wrap so the loop seam stays seamless
        buf[j] += value * gain


def tone(f, seconds, shape="sine", attack=0.01, decay=6.0, vibrato=0.0):
    out = []
    n = int(seconds * RATE)
    phase = 0.0
    for i in range(n):
        t = i / RATE
        fv = f * (1.0 + vibrato * math.sin(2 * math.pi * 5.5 * t))
        phase += 2 * math.pi * fv / RATE
        if shape == "sine":
            v = math.sin(phase)
        elif shape == "epiano":
            v = math.sin(phase) + 0.35 * math.sin(2 * phase) * math.exp(-t * 8) + 0.12 * math.sin(3 * phase)
        elif shape == "horn":
            v = sum(math.sin(k * phase) / k for k in range(1, 7)) * 0.6
        else:
            v = math.sin(phase)
        env = min(1.0, t / attack) * math.exp(-t * decay)
        out.append(v * env)
    return out


def noise(seconds, decay, seed, tone_hz=0.0):
    rng = random.Random(seed)
    out = []
    n = int(seconds * RATE)
    last = 0.0
    for i in range(n):
        t = i / RATE
        white = rng.uniform(-1, 1)
        last = 0.6 * last + 0.4 * white  # gentle low-pass for brushes
        body = math.sin(2 * math.pi * tone_hz * t) * 0.6 if tone_hz else 0.0
        out.append((last + body) * math.exp(-t * decay))
    return out


def swing(beat_index, half):
    # Swung eighths: the off-beat lands at 2/3 of the beat.
    return beat_index * BEAT + (BEAT * 2 / 3 if half else 0.0)


def plan_layer():
    buf = buffer(LOOP)
    rng = random.Random(7)
    for bar, (root, chord) in enumerate(CHORDS):
        b0 = bar * 4
        # Walking bass: root, third-ish, fifth, approach note.
        steps = [0, 4 if root in ("C", "D") else 3, 7, 10 if bar % 2 == 0 else 6]
        for k, step in enumerate(steps):
            add(buf, (b0 + k) * BEAT, tone(freq(BASS_ROOT[root] + step), BEAT * 0.95, "sine", 0.005, 3.0), 0.42)
        # Electric-piano comps on beat 1 and the "and" of 2.
        for when in (swing(b0, False), swing(b0 + 1, True)):
            for note in chord:
                add(buf, when, tone(freq(note), BEAT * 1.4, "epiano", 0.01, 2.2, 0.003), 0.07)
        # Brushes: swish on 2 and 4, soft ride swing pattern.
        for beat in (1, 3):
            add(buf, (b0 + beat) * BEAT, noise(0.25, 9.0, rng.randint(0, 9999)), 0.16)
        for beat in range(4):
            add(buf, swing(b0 + beat, False), noise(0.08, 40.0, rng.randint(0, 9999)), 0.05)
            if beat % 2 == 1:
                add(buf, swing(b0 + beat, True), noise(0.06, 50.0, rng.randint(0, 9999)), 0.04)
    return buf


def action_layer():
    buf = plan_layer()
    rng = random.Random(11)
    for bar, (root, chord) in enumerate(CHORDS):
        b0 = bar * 4
        for beat in (0, 2):
            add(buf, (b0 + beat) * BEAT, noise(0.18, 18.0, rng.randint(0, 9999), 60.0), 0.32)
        # Horn stabs on the "and" of 4 (anticipating the next chord) and beat 2.
        nxt = CHORDS[(bar + 1) % len(CHORDS)][1]
        for note in nxt[1:]:
            add(buf, swing(b0 + 3, True), tone(freq(note), BEAT * 0.5, "horn", 0.02, 7.0), 0.05)
        for note in chord[1:]:
            add(buf, (b0 + 1) * BEAT, tone(freq(note), BEAT * 0.35, "horn", 0.02, 9.0), 0.04)
        for beat in range(4):
            add(buf, swing(b0 + beat, True), noise(0.05, 60.0, rng.randint(0, 9999)), 0.05)
    return buf


def sting(notes, step, shape, gain, slide=0.0):
    total = step * len(notes) + 0.9
    buf = [0.0] * int(total * RATE)
    for i, note in enumerate(notes):
        f = freq(note)
        seconds = step * 1.6 if i < len(notes) - 1 else 0.9
        samples = []
        n = int(seconds * RATE)
        phase = 0.0
        for j in range(n):
            t = j / RATE
            fs = f * (1.0 - slide * t) if slide else f
            phase += 2 * math.pi * fs / RATE
            v = sum(math.sin(k * phase) / k for k in range(1, 6))
            samples.append(v * min(1.0, t / 0.02) * math.exp(-t * (2.5 if i == len(notes) - 1 else 6.0)))
        start = int(i * step * RATE)
        for j, v in enumerate(samples):
            if start + j < len(buf):
                buf[start + j] += v * gain
    return buf


def write(name, samples, peak=0.8):
    OUT.mkdir(parents=True, exist_ok=True)
    top = max(1e-6, max(abs(v) for v in samples))
    scale = peak / top
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, v * scale)) * 32000)) for v in samples))


if __name__ == "__main__":
    write("plan_loop.wav", plan_layer(), 0.55)
    write("action_loop.wav", action_layer(), 0.6)
    write("win_sting.wav", sting([65, 69, 72, 77], 0.11, "horn", 0.4))
    write("fail_sting.wav", sting([64, 63, 62, 61], 0.32, "horn", 0.4, slide=0.12))
    print("Wrote plan/action loops (%.2f s) and two stingers to %s" % (LOOP, OUT))
