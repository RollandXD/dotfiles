#!/usr/bin/env python3
"""合成马林巴风提示音：基频 + 4 倍频(马林巴第二振动模态) + 少量 10 倍频敲击感，指数衰减。

用法：synth.py <输出.wav> <音名@起始秒> ...   例：synth.py done.wav C5@0 G5@0.13
"""
import math, struct, sys, wave

RATE = 48000
NAMES = {"C": -9, "C#": -8, "D": -7, "D#": -6, "E": -5, "F": -4, "F#": -3,
         "G": -2, "G#": -1, "A": 0, "A#": 1, "B": 2}


def freq(name):
    pitch, octave = name[:-1], int(name[-1])
    return 440 * 2 ** ((NAMES[pitch] + 12 * (octave - 4)) / 12)


def marimba(f, length=0.9):
    out = []
    for i in range(int(RATE * length)):
        t = i / RATE
        attack = min(1.0, t / 0.004)          # 4ms 软起音，避免爆音
        body = math.sin(2 * math.pi * f * t) * math.exp(-t * 5.5)
        overtone = 0.35 * math.sin(2 * math.pi * f * 3.9 * t) * math.exp(-t * 18)
        click = 0.08 * math.sin(2 * math.pi * f * 9.8 * t) * math.exp(-t * 60)
        out.append(attack * (body + overtone + click))
    return out


def main():
    path, notes = sys.argv[1], sys.argv[2:]
    voices = []
    for spec in notes:
        name, start = spec.split("@")
        voices.append((int(float(start) * RATE), marimba(freq(name))))
    total = max(s + len(v) for s, v in voices)
    mix = [0.0] * total
    for start, v in voices:
        for i, x in enumerate(v):
            mix[start + i] += x
    peak = max(abs(x) for x in mix) or 1
    gain = 0.6 / peak                          # 留余量，最终音量交给 pw-play --volume
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(x * gain * 32767)) for x in mix))


if __name__ == "__main__":
    main()
