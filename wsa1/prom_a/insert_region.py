#!/usr/bin/env python3
"""Splice a converted region into prom_a/wsa1_prom_a.s, fixing the .incbin math.

QUESTION IT ANSWERS: "I have assembly for 0xF8xxxx..0xF8yyyy -- what do the
surrounding `.incbin` lines have to become so the image is still complete?"

The source is a single 512 KiB image described by a chain of
    .incbin "original_ROMs/wsa1_prom_a.ic12", <file offset>, <length>
lines interleaved with converted assembly.  Getting that arithmetic wrong is the
easiest way to break the byte gate, so it is done here instead of by hand.

    python3 prom_a/insert_region.py 0xF82CFF 0xF82EA2 region.s

`region.s` is inserted verbatim in place of the corresponding slice of whichever
.incbin currently covers it; a zero-length remainder emits no .incbin at all.
Run the gate afterwards -- this script does not.
"""
import re
import sys
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "prom_a", "wsa1_prom_a.s")
BASE = 0xF80000
INCBIN = re.compile(r'^\t\.incbin "original_ROMs/wsa1_prom_a\.ic12", '
                    r'(0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)\s*$')


def main():
    lo, hi, path = int(sys.argv[1], 16), int(sys.argv[2], 16), sys.argv[3]
    flo, fhi = lo - BASE, hi - BASE
    body = open(path).read().rstrip("\n")
    # ⚠ SRC is the image's ROOT file; since the module split the `.incbin` lines
    # live in the module files it .includes.  Each candidate file is spliced on
    # its own, and only the one holding the covering `.incbin` is written.
    sys.path.insert(0, os.path.join(ROOT, "notes"))
    from asm_source import image_writable_files
    for f in image_writable_files(ROOT, "prom_a/wsa1_prom_a.s"):
        if splice(f, flo, fhi, body):
            print("spliced 0x%06X-0x%06X (%d bytes) into %s"
                  % (lo, hi, hi - lo, os.path.relpath(f, ROOT)))
            return
    sys.exit("no .incbin covers 0x%06X-0x%06X" % (lo, hi))


def splice(src, flo, fhi, body):
    lines = open(src).read().split("\n")
    out, done = [], False
    for line in lines:
        m = INCBIN.match(line)
        if not m or done:
            out.append(line)
            continue
        off, ln = int(m.group(1), 16), int(m.group(2), 16)
        if not (off <= flo and fhi <= off + ln):
            out.append(line)
            continue
        if flo > off:
            out.append('\t.incbin "original_ROMs/wsa1_prom_a.ic12", '
                       '0x%06X, 0x%06X' % (off, flo - off))
        out.append(body)
        if off + ln > fhi:
            out.append('\t.incbin "original_ROMs/wsa1_prom_a.ic12", '
                       '0x%06X, 0x%06X' % (fhi, off + ln - fhi))
        done = True
    if done:
        open(src, "w").write("\n".join(out))
    return done


if __name__ == "__main__":
    main()
