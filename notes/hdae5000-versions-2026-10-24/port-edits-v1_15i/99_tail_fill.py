"""The zero fill after HDAE5000_Init_Data_End runs to the end of the ROM, 0x300000.

v1.15i: the word 0x000e at 0x2e198a, then zeros from 0x2e198c: 124,532 bytes (v2.01i's
image ends later, 27,160).  The count is set from the tree's own layout (the porting
tool's marker build), so that the image is 512 KiB once everything before it is in place;
while it is not, the count is left alone.
"""
import os
import re
import sys
from _edit import ROOT, TREE, read, write

sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

bld = P.do_build(TREE.replace("hdae5000_", ""))
if not bld.ok:
    sys.exit("tree does not build:\n" + bld.stderr[-1500:])
end = bld.symaddr["HDAE5000_Init_Data_End"] + 2
s = read("hdae5000_init_data.s")
m = re.search(rb"HDAE5000_Init_Data_End:\n\t\.short 14\n\t\.zero (\d+)\n", s)
assert m
want = 0x300000 - end
cur = int(m.group(1))
if want != cur and want > 0:
    s = s[:m.start(1)] + b"%d" % want + s[m.end(1):]
    write("hdae5000_init_data.s", s)
print("tail fill %d (was %d)" % (want, cur))
