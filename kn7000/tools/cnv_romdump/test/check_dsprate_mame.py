#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_dsprate_mame.py OUTDIR -- after run_test.sh --dsprate --fake-tm4: do the pass-8 probe's stamps (DSPRATE.BIN,
# romdump_dsprate.s) tell the time MAME knows? dsp_tap.lua logged the emulated time of every data-port read
# (OUTDIR/dsp_times.txt, "<seconds> <index>") and of every write of the kernel's millisecond counter
# (OUTDIR/dsp_ticks.txt, "<seconds> <value>"); with --fake-tm4 the tap answers TM4BC = 0x7D0 - (2 MHz counts since the
# last whole millisecond of emulated time), the driver's 1 kHz tick firing at each whole millisecond.
# So a stamp (ms - base) << 16 | BC stands for the emulated time  W(ms) + (0x7D0 - BC) / 2 MHz, W(ms) being the whole
# millisecond before the tick handler wrote ms. This script reads DSPRATE.BIN off the card image (OUTDIR/sd.img),
# turns every stamp into emulated time that way, and checks it against the reads the tap timed:
#   * the reads come in the probe's order: 2 x AT_N of MSGR2 (0x0A), then per phase sample 2 of CR0A (0x62) and 2 of
#     IIR0A (0x60), then 2 of MSGR2 per I3 sample;
#   * each stamp falls between the reads it was taken between (s1 < low half < s2 < high half < the next s1), to the
#     stamp's 0.5 us;
#   * how long after a read the next stamp comes, and how long a read takes from the stamp before it (MAME's
#     self-ack: no wait).
# Exit status 0 when every stamp is in its place.
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
from fatls import Fat  # noqa: E402
import check_dsp_probe as c  # noqa: E402

out = sys.argv[1]
fat = Fat(os.path.join(out, 'sd.img'))
ent = next(e for e in fat.entries(0) if e[0] == 'DSPRATE.BIN')     # the build writes to the root (no folder)
b = fat.read_file(ent[3], ent[4])
h = c.rate_parse(b)
times = [(float(t), int(i, 16)) for t, i in (ln.split() for ln in open(os.path.join(out, 'dsp_times.txt')) if ln.strip())]
ticks = [(float(t), int(v)) for t, v in (ln.split() for ln in open(os.path.join(out, 'dsp_ticks.txt')) if ln.strip())]
W = {}
for t, v in ticks:
    W.setdefault(v, int(t * 1000 + 1e-9) / 1000.0)        # the whole millisecond before the handler wrote v
m0, w0 = ticks[0][1], W[ticks[0][1]]
lat = sorted(t - W[v] for t, v in ticks)
print(f'{len(ticks)} ticks logged; the handler writes the counter {1e6 * lat[0]:.1f} to {1e6 * lat[-1]:.1f} us after the '
      f'whole millisecond (median {1e6 * lat[len(lat) // 2]:.1f})')


def emu(base, s):
    """a stamp -> emulated seconds"""
    ms = base + (s >> 16)
    w = W.get(ms, w0 + (ms - m0) / 1000.0)
    return w + (0x7D0 - (s & 0xFFFF)) / 2e6


want = [0x0A] * (2 * len(h['at'])) + [0x62, 0x62, 0x60, 0x60] * len(h['ph']) + \
    [0x0A] * (2 * sum(len(s['samples']) for s in h['seg']))
order = [i for t, i in times] == want
print(f'{len(times)} data-port reads timed, {len(want)} expected from the file: '
      + ('the same registers in the same order' if order else 'NOT the probe\'s order'))
bad = 0 if order else 1
Q = 0.5e-6 + 1e-9                                        # a stamp's quantum
rd = [t for t, i in times]
rows = []
# the access timing: s1 < lo < s2 < hi < next s1
st = [emu(h['ms0'], x) for s1, s2, lo, hi in h['at'] for x in (s1, s2)] + [emu(h['ms0'], h['s_end'])]
ev = rd[:2 * len(h['at'])]
viol = sum(1 for k in range(len(ev)) if not (st[k] - Q <= ev[k] <= st[k + 1] + Q))
after = sorted(st[k + 1] - ev[k] for k in range(len(ev)))
before = sorted(ev[k] - st[k] for k in range(len(ev)))
rows.append(('access timing', len(ev), viol, f'{1e6 * before[len(before) // 2]:.2f}', f'{1e6 * after[len(after) // 2]:.2f}'))
bad += viol > 0
# the phase check: s1 < CR0A (2 reads) < s2 < IIR0A (2 reads) < next s1
o = 2 * len(h['at'])
ph = h['ph']
viol = 0
for k, (s1, cr, s2, ii) in enumerate(ph):
    a, z = emu(h['ms0'], s1), emu(h['ms0'], s2)
    r = rd[o + 4 * k:o + 4 * k + 4]
    nxt = emu(h['ms0'], ph[k + 1][0]) if k + 1 < len(ph) else 1e9
    viol += not (a - Q <= r[0] <= r[1] <= z + Q <= r[2] + 2 * Q and r[3] <= nxt + Q)
rows.append(('phase check', 4 * len(ph), viol, '-', '-'))
bad += viol > 0
# the I3 series: s1 < two reads < s2
o += 4 * len(ph)
viol = n = 0
held = []
for sg in h['seg']:
    for s1, v, s2 in sg['samples']:
        a, z = emu(sg['ms0'], s1), emu(sg['ms0'], s2)
        r = rd[o + 2 * n:o + 2 * n + 2]
        viol += not (a - Q <= r[0] <= r[1] <= z + Q)
        held.append(z - a)
        n += 1
held.sort()
rows.append(('I3 series', 2 * n, viol, '-', f'{1e6 * held[len(held) // 2]:.2f} (whole read)'))
bad += viol > 0
c.table(('block', 'reads', 'stamps out of place', 'stamp to read, us', 'read to stamp, us'), rows)
print('every stamp is where the reads say' if not bad else f'{bad} problem(s)')
sys.exit(1 if bad else 0)
