# Question: which KN6000 / KN7000 .SQT stale runs that no event order explains are a song record's bytes, and how
# sure is that?  For every such run (>= kn_sqt.IMAGE_MIN bytes, not erased 0xFF), the best alignment against the
# part 1 (song records) of every .SQT on the same disk: equal bytes / run length, and the record offset.
# Signal: kn_sqt.record_image (the generator's rule, own part 1, >= 75 % equal) and the same count against the
# disk's other files.  Expected (2026-11-06): two KN6000 runs, ca6000s 03SMBMIX's free cell (215 B, +0x775, 186
# equal in its own song 1, 179..193 in the disk's nine other files) and ca6dim 08ENKADC (237 B, +0x57B, 220 in
# its own, 236 in 12HEITER's song 2); the 28 KN7000 runs reach at most 28 % (organs 01ORGANS), most below 10 %.
# Slow (a full alignment search per run and file): about ten minutes.
# Usage: cd notes/floppy-leftovers-2026-10-31/probes && python3 sqt_record_images.py ../../../floppy
import glob, os, sys
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'tools', 'kd')); import kn_sqt
from sqt_tails import chains


def best(r, p1):
    out = (0, 0)
    for a in range(0, len(p1) - len(r) + 1):
        eq = sum(1 for x, y in zip(r, p1[a:a + len(r)]) if x == y)
        if eq > out[0]:
            out = (eq, a)
    return out


for p2f in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*', '*.sqt.p2.ref'))):
    p1 = open(p2f.replace('.p2.ref', '.p1.ref'), 'rb').read(); p2 = open(p2f, 'rb').read()
    rl = kn_sqt.RECORD_LEN[p1[5:7]]
    ch, owner = chains(p1, p2)
    pieces = []
    for s, t, cells in ch:
        stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
        toks, why = kn_sqt.tokens(stream)
        if why: continue
        end = toks[-1][0] + toks[-1][1]; k = end // 251
        if k >= len(cells): continue
        rest = stream[end:251 * (k + 1)]
        if rest and len(set(rest)) > 1: pieces.append(rest)
    for c in range(1, len(p2) // 256 + 1):
        b = p2[(c - 1) * 256 + 5:c * 256]
        if c not in owner and len(set(b)) > 1: pieces.append(b)
    for r in pieces:
        for o, m, line in kn_sqt.stale_tokens(r):
            run = r[o:o + m]
            if line is not None or m < kn_sqt.IMAGE_MIN or kn_sqt._erased(run):
                continue
            eq, a = best(run, p1)
            rule = kn_sqt.record_image(run, p1)
            others = []
            for f in sorted(glob.glob(os.path.join(os.path.dirname(p2f), '*.sqt.p1.ref'))):
                if f != p2f.replace('.p2.ref', '.p1.ref'):
                    e2, a2 = best(run, open(f, 'rb').read())
                    others.append('%s %d +0x%X' % (os.path.basename(f)[:8], e2, a2 % rl))
            print('%s/%s %d B: own part 1 %d equal at +0x%X song %d (%.0f %%), rule %s' % (
                p2f.split(os.sep)[-2], os.path.basename(p2f)[:-11], m, eq, a % rl, a // rl + 1, 100 * eq / m,
                'image' if rule else 'no'))
            if rule:
                print('    other files:', '; '.join(others))
