"""Drop the HDAE5000_RAM_* / HDAE5000_IO_* constants whose every user went with the removals
(hd-ae5000_v1_15i.s, hdae5000_ui_display.s): a constant v2.01i's code names and nothing in
this tree names any more (the lyric buffer and position, the floppy lyric list, the save
options' TLX flag ...).  A constant v2.01i does not name either stays: it documents RAM.
"""
import os
import re
from _edit import ROOT, TREE, read, write

FILES = ["hd-ae5000_%s.s" % TREE[len("hdae5000_"):], "hdae5000_hd_driver.s", "hdae5000_filesystem.s", "hdae5000_ui_display.s",
         "hdae5000_utilities.s", "hdae5000_data_tables.s", "hdae5000_init_data.s", "hdae5000_ui_tree.s"]
EQU = re.compile(rb"^\s*\.(?:equ|set)\s+(HDAE5000_(?:RAM|IO)_\w+)\s*,", re.M)


def uses(texts):
    out = {}
    for s in texts:
        for ln in s.split(b"\n"):
            code = ln.split(b";", 1)[0]
            if EQU.match(code):
                continue
            for m in re.finditer(rb"HDAE5000_(?:RAM|IO)_\w+", code):
                out[m.group(0)] = out.get(m.group(0), 0) + 1
    return out


# the tree this one was ported from: v1.15i from v2.01i, v1.10i from v1.15i
src = "v2_01i" if TREE == "hdae5000_v1_15i" else "v1_15i"
v2 = os.path.join(ROOT, "hdae5000_" + src)
v2t = [open(os.path.join(v2, f.replace(TREE[len("hdae5000_"):], src)), "rb").read() for f in FILES]
mine = {f: read(f) for f in FILES}
u2, u1 = uses(v2t), uses(mine.values())
gone = []
for f, s in mine.items():
    out = []
    for ln in s.split(b"\n"):
        m = EQU.match(ln)
        if m and m.group(1) in u2 and m.group(1) not in u1:
            gone.append(m.group(1).decode())
            continue
        out.append(ln)
    write(f, b"\n".join(out))
print("%d constants dropped: %s" % (len(gone), " ".join(sorted(gone))))
