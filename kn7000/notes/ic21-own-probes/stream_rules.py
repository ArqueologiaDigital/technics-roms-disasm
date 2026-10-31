# stream_rules.py -- which rules do the firmware's own event streams keep?  The residue typer of
# kn7000/tools/gen_customdata_s.py (Cover.run_end, cut_stream_at) only takes stale bytes for events
# when they keep the same rules, so the rules are measured here on the live streams.
#
# For every TCMP and TPAD stream of the 20 slot records of the nine factory banks and of Felipe's
# IC21 bank it counts, within each beat (between F4 markers):
#   rise / equal / decrease   a position byte (0..95) against the previous one in the beat
#   pos after pos             a position byte followed by another position byte (never)
#   status w/o pos            a status event without its own position byte (it shares the last one)
# and the largest stream count (u24BE after the index).
#
#     python3 -I kn7000/notes/ic21-own-probes/stream_rules.py
import collections, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
import gen_customdata_s as G  # noqa: E402

C = collections.Counter()
biggest = 0
banks = list(_paths.factory_sets().items()) + [("own", _paths.chip()[0x20000:])]
for name, d in banks:
    for b in sorted({d[2 + 2 * s] for s in range(20) if d[2 + 2 * s]}):
        size, deps, secs = G.parse_record(d, b * G.BLOCK, "kn7000")
        rec = d[b * G.BLOCK:b * G.BLOCK + size]
        for (off, sz), heap in ((secs[1], 0x1270), (secs[2], 0x2E0)):
            c, p = rec[off:off + sz], heap
            while p < sz:
                n = G.u24(c, p + 1)
                biggest = max(biggest, n)
                q, last, prevpos = p + 4, -1, False
                while q < p + 4 + n:
                    x = c[q]
                    if x < 0x80:
                        C["pos after pos"] += prevpos
                        C["rise" if x > last else "equal" if x == last else "decrease"] += 1
                        last, prevpos = x, True
                    else:
                        if x == 0xF4:
                            last = -1
                        elif x != 0xF5 and not prevpos:
                            C["status w/o pos"] += 1
                        prevpos = False
                    q += G.ev_len(c, q)
                p += 4 + n
print(f"{len(banks)} banks: " + ", ".join(f"{k} {C[k]}" for k in ("rise", "equal", "decrease", "pos after pos",
                                                                  "status w/o pos")))
print(f"largest stream count: {biggest:#x}")
