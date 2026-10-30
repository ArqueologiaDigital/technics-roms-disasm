"""Every `.set HDAE5000_Str_X, <base label> + <offset>` alias becomes a label on its string.

hdae5000_init_data.s named about 100 strings of the class / message / parameter-name pools
as offsets from a nearby label (HDAE5000_RECORD_COUNT + 0x2, HDAE5000_UI_Config + 0x78,
HDAE5000_GFX_INIT_PARAMS + 0xc ...).  In a tree whose pools differ (v1.x lacks the lyric and
floppy-selector names) every offset after the first difference is wrong, so each alias is
placed as a label in front of the source line that emits its string -- found by assembling
the tree with a marker label per line (port_hdae5000_version.py's Build) -- and the .set
line goes.  An alias that does not fall on the first byte of a line is reported and kept.
It runs on the fresh copy of the v2.01i tree (replay.sh), before any pass moved a string.
"""
import os
import re
import sys
from _edit import ROOT, TREE, read, write

sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

ver = TREE.replace("hdae5000_", "")
bld = P.do_build(ver)
assert bld.ok, bld.stderr[-2000:]
start = {}
for f, n, s, e in bld.lines:
    if e > s:
        start.setdefault(s, (f, n))
SET = re.compile(rb"^\s*\.set\s+(HDAE5000_(?:Str|ParamStr)_\w+)\s*,\s*([A-Za-z_]\w*)\s*\+\s*(0x[0-9a-fA-F]+)\s*$")
inserts, dels, kept = {}, [], []
for f in bld.files:
    for n, ln in enumerate(bld.texts[f], 1):
        m = SET.match(ln)
        if not m:
            continue
        name, base, off = m.group(1).decode(), m.group(2).decode(), int(m.group(3), 16)
        a = bld.symaddr.get(base)
        if a is None:
            kept.append(name)
            continue
        where = start.get(a + off)
        if where is None:
            kept.append(name)
            continue
        inserts.setdefault(where, []).append(name)
        dels.append((f, n))
for f in bld.files:
    L = bld.texts[f][:]
    gone = {n for g, n in dels if g == f}
    out = []
    for n, ln in enumerate(L, 1):
        for name in inserts.get((f, n), []):
            out.append(name.encode() + b":")
        if n not in gone:
            out.append(ln)
    if gone or any(g == f for g, _ in inserts):
        write(f, b"\n".join(out))
print("%d aliases placed as labels; kept: %s" % (len(dels), kept))
