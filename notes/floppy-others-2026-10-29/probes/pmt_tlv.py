"""Does a KN6000 .PMT payload walk as KN5000-style tag/length records?  For each start offset 0..0x3F,
walk {tag, len, len bytes} until FF FF and print how far it gets.  Run in floppy/build after a gate:
  python3 -I pmt_tlv.py kn6000/ca6000s/09SUNSHN.pmt.p1.ref
Result 2026-10-29: every start converges on the same offset (0x3f30 of 0xa840) within a few records and
stops there, i.e. the walk is resynchronising on arbitrary bytes, not following a record list."""
import sys
p = open(sys.argv[1], 'rb').read()
for st in range(0x40):
    o, n = st, 0
    while o + 2 <= len(p) and n < 2000:
        t, l = p[o], p[o + 1]
        if t == 0xff and l == 0xff:
            o += 2
            break
        o += 2 + l
        n += 1
    print('start 0x%02x: %d records, stops at 0x%x of 0x%x' % (st, n, o, len(p)))
