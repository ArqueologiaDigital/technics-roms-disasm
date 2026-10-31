#!/usr/bin/env python3
"""sqt_event_census.py -- which song events occur on the KN5000 disks, and with what data?

Question: the firmware's SeqEvent_GetParamLength gives each song event's length; what do the events
look like on real songs?  Reads the committed typed SQT sources (floppy/kn5000/*/files/*.SQT.s,
whose sq_note / sq_ev / sq_beat lines are the events of every track chain) and prints, per status,
the count, the data length seen and the range of each data byte (byte 1 is the tick within the beat).

Run from the repository root:
    python3 notes/open4-kn5000-b/engine/probes/sqt_event_census.py
"""
import collections
import glob
import re

LINE = re.compile(r'^\t(sq_note|sq_ev|sq_beat)(?:\t(.*?))?\s*(?:;.*)?$')


def main():
    files = sorted(glob.glob('floppy/kn5000/*/files/*.SQT.s'))
    seen = collections.defaultdict(list)
    for p in files:
        for line in open(p, encoding='latin-1'):
            m = LINE.match(line.rstrip('\n'))
            if not m:
                continue
            kind, args = m.group(1), m.group(2)
            if kind == 'sq_beat':
                seen[0x81].append(())
                continue
            vals = [int(x, 0) for x in args.split(',')] if args else []
            if not vals:
                continue
            seen[vals[0]].append(tuple(vals[1:]))
    print('%d files' % len(files))
    print('status  count  data lengths    byte ranges (first = tick)')
    for st in sorted(seen):
        rows = seen[st]
        lens = collections.Counter(len(r) for r in rows)
        width = max(lens)
        ranges = []
        for i in range(min(width, 6)):
            col = [r[i] for r in rows if len(r) > i]
            ranges.append('%d..%d' % (min(col), max(col)))
        print('0x%02x  %6d  %-14s  %s' % (st, len(rows), ','.join('%d' % k for k in sorted(lens)),
                                         '  '.join(ranges)))


if __name__ == '__main__':
    main()
