# Question: how many bytes of uniform random data does kn_sqt.stale_tokens type as events (its false-positive
# rate), and do the 2026-11-06 rules (layer cuts, erased 0xFF, song-record images) raise it?
# Signal: 300 runs of 200 bytes from random.Random(2026); a byte counts as typed when stale_tokens gives it a
# line (an event, or a cut event spelled .byte); with a part 1 of random bytes, record_image is tried too.
# Expected (2026-11-06, lane kn7000-names): typed 161 + cut 327 = 488 of 60,000 (0.81 %); 0 runs erased, 0
# record images.  The tool before the layer-cut options gave 133 + 294 = 427 (0.71 %) on the same bytes (the
# 2026-10-31 session's unseeded figure was 413).
# Usage: cd notes/floppy-leftovers-2026-10-31/probes && python3 sqt_random_types.py ../../../floppy
import os, random, sys
sys.path.insert(0, os.path.join(sys.argv[1], 'tools', 'kd')); import kn_sqt
R = random.Random(2026)
p1 = b'ZZZZ\x01\x01\x0a' + bytes(R.randrange(256) for _ in range(0x870 - 7))
typed = cut = img = er = 0
for _ in range(300):
    r = bytes(R.randrange(256) for _ in range(200))
    for o, m, line in kn_sqt.stale_tokens(r):
        if line is None:
            er += kn_sqt._erased(r[o:o + m])
            img += bool(kn_sqt.record_image(r[o:o + m], p1))
        elif line.startswith(';'):
            cut += m
        else:
            typed += m
print('random bytes 60000: typed as events %d, as cut events %d (%.2f %% together); runs erased %d, images %d'
      % (typed, cut, 100 * (typed + cut) / 60000, er, img))
