#!/usr/bin/env python3
"""loop_period_check.py -- does each derived rate put a whole number of waveform periods in the recording's loop?

QUESTION: kn7000/src/wave/root_rates.tsv gives a recording's read rate at a root key, rate = f(root) x T,
  where T = 2^(E - 9 + corr/3072) is the waveform period in samples that the TG law, the entry's pitch
  exponent and the zone correction imply (independent of the root).  A loop has to hold a whole number of
  periods of the sound or it clicks; so if T is right, loop length / T is close to an integer.  This is a
  check of the derivation against the recordings themselves, for every looped recording, not only the 556
  voices the emulator traced (kn7000_mame g13 pitchcheck.py did this per voice).
SIGNAL: for each recording with a smpl loop in kn7000/src/wave/{main,sub}_wav.tsv (loop end inclusive) and a
  rate from the tone database (basis "zone(s)"), m = loop length / T; pass when |m - round(m)| <= 0.05 and
  round(m) >= 1 (T and the loop agree to 5 % of a period).  NULL: the same with T scaled by 2^(k/12),
  k = 1..11 semitones off (a wrong pitch class), averaged; and with corr dropped (T = 2^(E - 9)).  Loops
  are whole numbers of granules (powers of two), so only recordings whose corr is not a multiple of 256
  test anything; the probe prints that subset separately.
  AUDIO: the loop length test cannot falsify a power-of-two T (it always fits), so the probe also reads the
  committed WAVs: in the first loop of each recording whose corr is not a whole number of semitones, is the
  loop's circular autocorrelation higher at the derived T than at 2^(E - 9)?
RUN  python3 notes/sound-probes/loop_period_check.py     (numpy; reads kn7000/wav/, committed)
Printed 2026-10-31: all loops 728 of 821 (null 82.2); corr not whole semitones: 611 of 702 (null mean 74.3,
  max 87); audio: the derived T wins in 682 of 702.
"""
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
rates = {}
for line in (ROOT / "kn7000/src/wave/root_rates.tsv").read_text().splitlines():
    r = line.split("\t")
    if line.startswith("#") or r[0] == "label" or r[1] == "-" or "zone(s)" not in r[8] or r[2] == "-":
        continue
    rates[r[0]] = (int(r[1]), int(r[2]))
loops = {}
for tg in ("main", "sub"):
    for line in (ROOT / f"kn7000/src/wave/{tg}_wav.tsv").read_text().splitlines()[1:]:
        f = line.split("\t")
        if f[7] != "-" and f[0] in rates:
            loops[f[0]] = [int(x.split(":")[2]) - int(x.split(":")[1]) + 1 for x in f[7].split(",")]


def score(tfun, nonzero=False):
    ok = n = 0
    for lab, ls in loops.items():
        E, corr = rates[lab]
        if nonzero and corr % 256 == 0:
            continue
        T = tfun(E, corr)
        for L in ls:
            m = L / T
            n += 1
            ok += round(m) >= 1 and abs(m - round(m)) <= 0.05
    return ok, n


ok, n = score(lambda E, c: 2 ** (E - 9 + c / 3072))
print(f"derived T = 2^(E - 9 + corr/3072): {ok} of {n} loops hold a whole number of periods (within 5 %)")
nulls = [score(lambda E, c, k=k: 2 ** (E - 9 + c / 3072 + k / 12))[0] for k in range(1, 12)]
print(f"null, T a wrong pitch class (k = 1..11 semitones): mean {sum(nulls) / len(nulls):.1f} of {n}, "
      f"max {max(nulls)}")
ok0, _ = score(lambda E, c: 2 ** (E - 9))
print(f"without the zone correction, T = 2^(E - 9): {ok0} of {n} (no test: a loop is a whole number of granules,\n"
      f"  2^(K + 4) samples, so a power-of-two T always fits; the same holds for corr = whole semitones x 12)")
print("the informative part, recordings whose correction is not a whole number of semitones (corr % 256 != 0):")
ok, n = score(lambda E, c: 2 ** (E - 9 + c / 3072), True)
nulls = [score(lambda E, c, k=k: 2 ** (E - 9 + c / 3072 + k / 12), True)[0] for k in range(1, 12)]
ok0, _ = score(lambda E, c: 2 ** (E - 9), True)
print(f"  derived T: {ok} of {n}; T a wrong pitch class: mean {sum(nulls) / len(nulls):.1f}, max {max(nulls)}; "
      f"T without corr: {ok0}")

# ---- the audio itself: is the loop periodic at the derived T, or at the uncorrected 2^(E - 9)? ----
import numpy as np  # noqa: E402
import struct  # noqa: E402


def wav_samples(path):
    b = path.read_bytes()
    pos, bits, data = 12, None, None
    while pos + 8 <= len(b):
        tag, size = b[pos:pos + 4], struct.unpack_from("<I", b, pos + 4)[0]
        if tag == b"fmt ":
            bits = struct.unpack_from("<H", b, pos + 22)[0]
        elif tag == b"data":
            data = b[pos + 8:pos + 8 + size]
        pos += 8 + size + (size & 1)
    return (np.frombuffer(data, "<i2") if bits == 16 else np.frombuffer(data, "u1").astype(np.int16) - 128).astype(float)


def circ_r(x, tau):
    """normalised circular autocorrelation of one loop period x at a fractional lag tau"""
    n = len(x)
    i = np.arange(n)
    y = np.interp((i + tau) % n, np.arange(n + 1), np.append(x, x[0]))
    x0, y0 = x - x.mean(), y - y.mean()
    d = math.sqrt((x0 * x0).sum() * (y0 * y0).sum())
    return (x0 * y0).sum() / d if d else 0.0


wavname = {}
for tg in ("main", "sub"):
    for line in (ROOT / f"kn7000/src/wave/{tg}_wav.tsv").read_text().splitlines()[1:]:
        f = line.split("\t")
        if f[0] in loops:
            wavname[f[0]] = (ROOT / f"kn7000/wav/{tg}" / f[5], [tuple(int(v) for v in x.split(":")[1:]) for x in f[7].split(",")])
better = worse = 0
for lab, (path, lps) in wavname.items():
    E, corr = rates[lab]
    if corr % 256 == 0:
        continue
    s = wav_samples(path)
    a, e = lps[0]
    x = s[a:e + 1]
    if len(x) < 64 or x.std() < 1:
        continue
    T, T0 = 2 ** (E - 9 + corr / 3072), 2 ** (E - 9)
    if T >= len(x) or T0 >= len(x):
        continue
    if circ_r(x, T) > circ_r(x, T0):
        better += 1
    else:
        worse += 1
print(f"audio: in the first loop of each such recording, the autocorrelation at the derived T is higher than at "
      f"2^(E - 9) in {better} of {better + worse}")
