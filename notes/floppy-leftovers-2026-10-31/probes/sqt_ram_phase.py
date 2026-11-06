# Question: are the KN7000 .SQT stale bytes that no event order explains RAM nothing wrote, rather than events?
# Signal: the mean number of set bits of a byte, by its position mod 8 in part 2 (the cell store, a copy of the
# song memory at 0x501AB9A0 on the KN7000, 0x501AB9A0 % 8 == 0, so this is the RAM address mod 8).  Events
# have variable lengths, so their bytes do not care where they sit mod 8; power-up DRAM content does.
# Expected (2026-11-06, kn_sqt at lane kn7000-names): KN7000 unexplained (runs >= 12 bytes) 5,045 bytes with
# 3.22 / 3.26 / 3.56 / 3.61 set bits at positions 0-3 and 4.75 / 4.78 / 4.48 / 4.59 at 4-7; the typed stale
# events (control) 2.4-2.5 at every position in both models (KN6000 30,178 bytes, KN7000 5,847).
# Usage: cd notes/floppy-leftovers-2026-10-31/probes && python3 sqt_ram_phase.py ../../../floppy
import collections, glob, os, sys
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'tools', 'kd')); import kn_sqt
from sqt_tails import chains
pc = collections.defaultdict(lambda: [0, 0])
for p2f in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*', '*.sqt.p2.ref'))):
    model = p2f.split(os.sep)[-3]
    p1 = open(p2f.replace('.p2.ref', '.p1.ref'), 'rb').read(); p2 = open(p2f, 'rb').read()
    ch, owner = chains(p1, p2)
    pieces = []
    for s, t, cells in ch:
        stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
        toks, why = kn_sqt.tokens(stream)
        if why: continue
        end = toks[-1][0] + toks[-1][1]; k = end // 251
        if k >= len(cells): continue
        rest = stream[end:251 * (k + 1)]
        if rest and len(set(rest)) > 1: pieces.append(((cells[k] - 1) * 256 + 5 + end - 251 * k, rest))
    for c in range(1, len(p2) // 256 + 1):
        b = p2[(c - 1) * 256 + 5:c * 256]
        if c not in owner and len(set(b)) > 1: pieces.append(((c - 1) * 256 + 5, b))
    for at, r in pieces:
        for o, m, line in kn_sqt.stale_tokens(r):
            if line is None and m >= 12 and not kn_sqt._erased(r[o:o + m]) and not kn_sqt.record_image(r[o:o + m], p1):
                kind = (model, 'unexplained')
            elif line is not None and not line.startswith(';'):
                kind = (model, 'typed events (control)')
            else:
                continue
            for q in range(o, o + m):
                v = pc[kind + ((at + q) % 8,)]
                v[0] += bin(r[q]).count('1'); v[1] += 1
for kind in sorted({k[:2] for k in pc}):
    n = sum(pc[kind + (i,)][1] for i in range(8))
    print(kind, n, 'bytes; set bits by position mod 8:',
          ' '.join('%.2f' % (pc[kind + (i,)][0] / pc[kind + (i,)][1]) for i in range(8)))
