# Question: are the bytes after 0x82 in a KN6000/KN7000 .SQT track's last cell the KN5000-format (status-first)
# original of that same track's last events?
import glob, os, sys, collections
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'tools', 'kd')); sys.path.insert(0, os.path.join(FL, 'kn5000'))
import kn_sqt, events
u16 = kn_sqt.u16
from sqt_tails import chains

def live_notes(toks, stream):
    out = []
    for o, m, line in toks:
        if 0x90 <= stream[o + 1] <= 0x9f if o + 1 < len(stream) and stream[o] < 0x80 else False:
            d = stream[o:o + 6]; out.append((d[1] & 15, d[0], d[2], d[3], d[4] | d[5] << 8))
    return out

stats = collections.Counter()
for p2f in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*', '*.sqt.p2.ref'))):
    p1 = open(p2f.replace('.p2.ref', '.p1.ref'), 'rb').read(); p2 = open(p2f, 'rb').read()
    ch, owner = chains(p1, p2)
    for s, t, cells in ch:
        stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
        toks, why = kn_sqt.tokens(stream)
        if why: continue
        end = toks[-1][0] + toks[-1][1]
        k = end // 251
        if k >= len(cells): continue
        rest = stream[end:251 * (k + 1)]
        if not rest or len(set(rest)) == 1: continue
        st = events.tokenize_seq(rest)
        notes = []
        for o, m, line, _ in st:
            if line.startswith('sq_note') or line.startswith('sq_run'):
                b = rest[o:o + m]
                if line.startswith('sq_note'): ch_, d = b[0] & 15, b[1:6]
                else: d = b
                notes.append((ch_, d[0], d[1], d[2], d[3] | d[4] << 8))
        ln = live_notes(toks, stream)
        # does the stale note list occur in the live list?  Where?
        pos = -1
        for i in range(len(ln) - len(notes) + 1):
            if notes and ln[i:i + len(notes)] == notes: pos = i; break
        # tolerate channel / partial: compare (note, vel, dur) only
        pos2 = -1
        key = lambda x: x[1:]
        for i in range(len(ln) - len(notes) + 1):
            if notes and [key(x) for x in ln[i:i + len(notes)]] == [key(x) for x in notes]: pos2 = i; break
        tag = 'exact' if pos >= 0 else ('ignoring channel' if pos2 >= 0 else ('no notes' if not notes else 'no match'))
        stats[tag] += 1
        stats['events' + str(sum(1 for x in st if x[2] == 'PAD'))] += 0
        print('%s s%d t%d len %d notes %d live %d: %s at %d (from end %d)' % (os.path.basename(p2f), s + 1, t + 1, len(rest), len(notes), len(ln), tag, max(pos, pos2), len(ln) - max(pos, pos2) - len(notes) if max(pos, pos2) >= 0 else -1))
print(stats)
