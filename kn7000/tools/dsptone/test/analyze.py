#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# analyze.py OUT -- the verdict on one run_mame.sh run: OUT/run.wav (MAME's -wavwrite), OUT/tap.txt (tone_tap.lua) and
# OUT/cmd.txt.log (the remote rig: the emulated time of every press). Prints one line per check and a last line
# "analyze: N of M checks". What each check reads:
#   dead       tap: the firmware's "DSP dead" flag is 0 at every sample (it is set when a handshake wait times out)
#   hooked     tap: PM 0x8080 = 06BE04008200 (our program) while DSPTONE runs, and MSGR7 (its frame count) rises
#              at 44.1 kHz between samples
#   restored   tap: after STOP, PM 0x8080 is again what it was before the hook, and MSGR4-MSGR7 read 0
#   reverb     tap: DM 0xC003 (the reverb's per-frame store of I6) moves before the hook, stands still while ours
#              runs, and moves again after the restore: the firmware's effect program runs again
#   sine       wav: from the hook (+0.5 s) to the CHIRP press, the spectrum's peak is 440 Hz (+-3 Hz) and the level
#              is at least 30 dB over the 10 s before the first note (the instrument idle)
#   sdram      tap: SDRAM 0x70000 on, as the DSP holds it once the PCM plays, against dsp_prog.py's sweep: every
#              sample equal (each a 16-bit sample shifted to 24 bits)
#   chirp      wav: after the PCM starts (tap: MSGR6 = 2), the peak frequencies of the loud 40 ms frames span
#              300-3000 Hz and >= 90 % of them lie within 10 % of the sweep dsp_prog.py made, looped every second
#   mute       wav: after MUTE, the level is at least 30 dB under the sine's
#   screen     tap: while the sine plays, the firmware does not repaint over DSPTONE's screen (less than one full
#              repaint's worth of its LCD stores) and the converter calls come more than 10 times a second
#   note       wav: the note after the restore against the note before: the same level (+-3 dB) and the same
#              decay (the RMS envelopes over 3 s correlate >= 0.95)
import os
import re
import struct
import sys

import numpy as np

O = sys.argv[1]
checks = []


def check(name, ok, detail):
    checks.append(ok)
    print(f"{name:9} {'PASS' if ok else 'FAIL'}  {detail}")


def wav(path):
    d = open(path, "rb").read()
    assert d[:4] == b"RIFF" and d[8:12] == b"WAVE"
    p, fmt, data = 12, None, None
    while p < len(d):
        cid, n = d[p:p + 4], struct.unpack_from("<I", d, p + 4)[0]
        if cid == b"fmt ":
            fmt = struct.unpack_from("<HHIIHH", d, p + 8)
        elif cid == b"data":
            data = d[p + 8:p + 8 + n]
        p += 8 + n + (n & 1)
    _, ch, rate, _, _, bits = fmt
    assert bits == 16
    x = np.frombuffer(data[:len(data) // (2 * ch) * 2 * ch], dtype="<i2").reshape(-1, ch).astype(np.float64)
    return rate, x.mean(axis=1) / 32768.0


def presses():
    """the emulated time of each command line the rig carried out: [(t, line)]"""
    out = []
    for ln in open(os.path.join(O, "cmd.txt.log")):
        m = re.match(r"\[([\d.]+)\] OK \d+ (.*)", ln.strip())
        if m:
            out.append((float(m.group(1)), m.group(2)))
    return out


def tap():
    rows = []
    for ln in list(open(os.path.join(O, "tap.txt")))[1:]:
        v = ln.split()
        if len(v) == 16:
            rows.append(dict(t=float(v[0]), st=int(v[1]), dead=int(v[2]), slot=v[3], m4=int(v[4], 16),
                             m5=int(v[5], 16), m6=int(v[6], 16), m7=int(v[7]), c003=v[8], out=v[9],
                             rate=int(v[10]), pcm=int(v[11]), rest=int(v[12]), calls=int(v[13]),
                             lcdfw=int(v[14]), lcdours=int(v[15])))
    return rows


def rms_db(x):
    return 20 * np.log10(np.sqrt(np.mean(x * x)) + 1e-12)


def peak_hz(x, rate):
    w = np.hanning(len(x))
    s = np.abs(np.fft.rfft(x * w))
    k = int(np.argmax(s[1:])) + 1
    if 1 <= k < len(s) - 1:                   # parabolic interpolation
        a, b, c = np.log(s[k - 1] + 1e-12), np.log(s[k] + 1e-12), np.log(s[k + 1] + 1e-12)
        k = k + 0.5 * (a - c) / (a - 2 * b + c)
    return k * rate / len(x)


rate, x = wav(os.path.join(O, "run.wav"))
P = presses()
T = tap()
seg = lambda a, b: x[int(a * rate):int(b * rate)]  # noqa: E731
first = lambda pat: next(t for t, ln in P if re.search(pat, ln))  # noqa: E731
every = lambda pat: [t for t, ln in P if re.search(pat, ln)]  # noqa: E731
print(f"run.wav: {len(x) / rate:.1f} s at {rate} Hz; {len(P)} rig commands; {len(T)} tap samples "
      f"({T[0]['t']:.1f}-{T[-1]['t']:.1f} s)")

check("dead", all(r["dead"] == 0 for r in T), f"dead flag max {max(r['dead'] for r in T)} over {len(T)} samples")

hooked = [r for r in T if r["slot"] == "06BE04008200"]
before = [r for r in T if not hooked or r["t"] < hooked[0]["t"]]
after = [r for r in T if hooked and r["t"] > hooked[-1]["t"]]
ok = len(hooked) > 4
rates = []
for a, b in zip(hooked, hooked[1:]):
    if b["m7"] > a["m7"] > 0:
        rates.append((b["m7"] - a["m7"]) / (b["t"] - a["t"]))
med = float(np.median(rates)) if rates else 0
check("hooked", ok and 43000 < med < 45200,
      f"PM 8080 = 06BE04008200 from {hooked[0]['t'] if hooked else 0:.2f} to {hooked[-1]['t'] if hooked else 0:.2f} s; "
      f"MSGR7 rises {med:.0f} per s (median of {len(rates)})")

slot0 = before[-1]["slot"] if before else "?"
end = after[-1] if after else None
check("restored", bool(end) and end["slot"] == slot0 and slot0 == "06BE04008400" and
      (end["m4"], end["m5"], end["m6"], end["m7"]) == (0, 0, 0, 0) and any(r["rest"] == 1 for r in after),
      f"PM 8080 before {slot0}, at the end {end['slot'] if end else '?'}; MSGR4-7 at the end "
      f"{(end['m4'], end['m5'], end['m6'], end['m7']) if end else '?'}; V_RESTORED {end['rest'] if end else '?'}")


def moves(rows):
    return len({r["c003"] for r in rows})


mid = hooked[2:-2]
check("reverb", moves(before[-8:]) > 4 and moves(mid) == 1 and moves(after[-8:]) > 4,
      f"DM C003 distinct values: last 8 before the hook {moves(before[-8:])}, while hooked {moves(mid)}, "
      f"last 8 after {moves(after[-8:])}")

t_hook = hooked[0]["t"] if hooked else 0
t_chirp = every(r"press CPR_SEG5 20")[0]
quiet = seg(first(r"press KEYS1") - 10, first(r"press KEYS1") - 0.2)
sine = seg(t_hook + 0.5, t_chirp - 0.2)
f_sine, l_sine, l_quiet = peak_hz(sine, rate), rms_db(sine), rms_db(quiet)
n1 = first(r"press KEYS1")
l_note = rms_db(seg(n1, n1 + 1))
check("sine", abs(f_sine - 440) < 3 and l_sine - l_quiet > 30,
      f"{t_hook + 0.5:.2f}-{t_chirp - 0.2:.2f} s: peak {f_sine:.1f} Hz, {l_sine:.1f} dBFS; the 10 s before the first "
      f"note {l_quiet:.1f} dBFS; the first note's first second (C4, the firmware's reverb) {l_note:.1f} dBFS")

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import dsp_prog  # noqa: E402
want = dsp_prog.chirp()
sd = os.path.join(O, "sdram_pcm.bin")
if os.path.exists(sd):
    raw = open(sd, "rb").read()
    got = struct.unpack(f"<{len(raw) // 4}I", raw)
    diff = sum(1 for g, w in zip(got, want) if g != ((w << 8) & 0xFFFFFFFF))
    check("sdram", len(got) == len(want) and diff == 0, f"{len(got)} of {len(want)} samples read back from SDRAM "
          f"0x70000, {diff} differ from the sweep")
else:
    check("sdram", False, "no SDRAM dump (the PCM never started)")

pcm_on = [r["t"] for r in T if r["m6"] == 2]
t_mute = every(r"press CPR_SEG7 01")[0]
if pcm_on:
    # the sweep dsp_prog.py made: f(u) = 220 x 16^(u / 0.75) for u = t - t0 mod 1 s below 0.75 s, then silence. Its
    # start t0 is not known: the best one, in 1 ms steps, and how many loud 40 ms frames are within 10 % of it
    a, b = pcm_on[0] + 0.3, t_mute - 0.1
    ts = [a + k * 0.04 for k in range(int((b - a) / 0.04))]
    fr = [peak_hz(seg(t, t + 0.04), rate) for t in ts]
    lv = [rms_db(seg(t, t + 0.04)) for t in ts]
    loud = [(t + 0.02, f) for t, f, lvl in zip(ts, fr, lv) if lvl > l_sine - 12]
    best = (0, 0)
    for k in range(1000):
        n = 0
        for t, f in loud:
            u = (t - a - k / 1000) % 1.0
            if 0.02 < u < 0.73 and abs(f / (220 * 16 ** (u / 0.75)) - 1) < 0.10:
                n += 1
        best = max(best, (n, k))
    frac = best[0] / len(loud) if loud else 0
    span = (min(f for _, f in loud), max(f for _, f in loud)) if loud else (0, 0)
    check("chirp", frac >= 0.9 and span[0] < 300 and span[1] > 3000,
          f"{a:.2f}-{b:.2f} s: {len(loud)} loud 40 ms frames, peaks {span[0]:.0f}-{span[1]:.0f} Hz; {100 * frac:.0f} % "
          f"within 10 % of the sweep (its start at {a + best[1] / 1000:.3f} s mod 1 s)")
else:
    check("chirp", False, "MSGR6 never read 2 (the PCM never started)")

t_stop = every(r"press CPR_SEG5 01")[-1]
mute = seg(t_mute + 0.3, t_stop - 0.1)
check("mute", l_sine - rms_db(mute) > 30, f"{t_mute + 0.3:.2f}-{t_stop - 0.1:.2f} s: {rms_db(mute):.1f} dBFS "
      f"against the sine's {l_sine:.1f}")

# the screen: the firmware's full repaints (76,160 LCD stores each, 893 0x48414F92) and the converter call rate while
# the sine plays (from 2 s after the hook to the CHIRP press)
w = [r for r in T if t_hook + 2 <= r["t"] <= t_chirp]
if len(w) > 1:
    rep = (w[-1]["lcdfw"] - w[0]["lcdfw"]) / 76160
    cps = (w[-1]["calls"] - w[0]["calls"]) / (w[-1]["t"] - w[0]["t"])
    check("screen", rep < 1 and cps > 10, f"{w[0]['t']:.2f}-{w[-1]['t']:.2f} s: {rep:.1f} firmware repaints, "
          f"{cps:.1f} converter calls per second; whole run: {T[-1]['lcdfw'] / 76160:.1f} repaints' worth of firmware "
          f"LCD stores, {T[-1]['lcdours']} of ours")

notes = every(r"press KEYS1 0100")


def env(t0):
    return np.array([np.sqrt(np.mean(seg(t0 + k * 0.05, t0 + k * 0.05 + 0.05) ** 2)) for k in range(60)])


e1, e2 = env(notes[0]), env(notes[-1])
lvl = 20 * np.log10((e2.mean() + 1e-12) / (e1.mean() + 1e-12))
cor = float(np.corrcoef(e1, e2)[0, 1])
check("note", abs(lvl) < 3 and cor > 0.95, f"note at {notes[0]:.2f} s against {notes[-1]:.2f} s: level "
      f"{lvl:+.2f} dB, envelope correlation {cor:.3f}; tails (2.5-3 s) {20 * np.log10(e1[50:].mean() + 1e-12):.1f} / "
      f"{20 * np.log10(e2[50:].mean() + 1e-12):.1f} dBFS")
print(f"analyze: {sum(checks)} of {len(checks)} checks")
sys.exit(0 if all(checks) else 1)
