"""Two word-align pads of the registered-object name pool, mistaken for empty strings.

The strings pass of scripts/tools/port_hdae5000_version.py (since fixed) read a 0x00 at
an odd address as an empty string when its hunk began on it, and labelled the two pads
after "LyricJumpEditCheck" and "BitmapButt01" HDAE5000_Str_Empty_9 / _10.  They are pads.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/09_name_pool_pads.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
p = os.path.join(ROOT, "hdae5000_v2_01i", "hdae5000_utilities.s")
s = open(p, "rb").read()
pad = b"\t.balign 2, 0x00                       ; word-align pad\n"
for k in (9, 10):
    old = b"HDAE5000_Str_Empty_%d:\n\t; only in v2.01i\n\t.asciz \"\"\n" % k
    assert s.count(old) == 1, k
    s = s.replace(old, pad)
s = s.replace(pad + b"\t.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)\n",
              b"\t.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)\n")
open(p, "wb").write(s)
print("ok")
