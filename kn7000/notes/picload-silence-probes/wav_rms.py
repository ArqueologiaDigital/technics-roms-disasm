#!/usr/bin/env python3
"""wav_rms.py -- question: is the instrument audible in a time window of a MAME -wavwrite capture?

Prints, per window, the RMS and the peak of every channel of a 16-bit WAV (the KN7000 driver writes
3 channels at 48 kHz).  A window with no stimulus measures 0.0 / 0 in this driver
(kn7000_mame tools/rigs/README.md, money.lua), so a held key's window is audible when its RMS is
orders above that.

usage:  python3 -I wav_rms.py FILE.wav START-END [START-END ...]     (seconds, e.g. 33.5-34.5)
"""
import array
import math
import sys
import wave

w = wave.open(sys.argv[1])
ch, sw, rate = w.getnchannels(), w.getsampwidth(), w.getframerate()
assert sw == 2, "16-bit WAV expected"
for span in sys.argv[2:]:
    a, b = (float(x) for x in span.split("-"))
    w.setpos(int(a * rate))
    data = array.array("h", w.readframes(int((b - a) * rate)))
    out = []
    for c in range(ch):
        s = data[c::ch]
        rms = math.sqrt(sum(v * v for v in s) / len(s)) if s else 0.0
        out.append(f"ch{c} rms {rms:8.1f} peak {max((abs(v) for v in s), default=0):6d}")
    print(f"{span:>12}  " + "  ".join(out))
