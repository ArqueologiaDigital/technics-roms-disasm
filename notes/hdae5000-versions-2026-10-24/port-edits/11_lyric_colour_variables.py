"""v2.01i has no lyric colour settings, so no HDAE5000_RAM_LyricForeColor / _LyricBackColor.

The `fix` pass of the porting tool, seeing HD_Init's stores line up with v2.06i's,
re-valued those two constants to the addresses v2.01i's HD_Init stores to there
(0x229dc6 = 0, 0x229dd7 = 1).  Those are the two unnamed bytes v2.06i writes as
(0x229DC8) and (0x229DD9), two bytes lower because the two colour bytes are missing;
they are spelled as v2.06i spells them, numerically, and the two constants go.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/11_lyric_colour_variables.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")


def rep(fn, old, new):
    p = os.path.join(T, fn)
    s = open(p, "rb").read()
    assert s.count(old) == 1, (fn, s.count(old), old)
    open(p, "wb").write(s.replace(old, new))


rep("hdae5000_ui_display.s",
    b"\tld\t(HDAE5000_RAM_LyricForeColor:24), 0\n\tld\t(HDAE5000_RAM_LyricBackColor:24), 1\n",
    b"\tld\t(0x229dc6:24), 0\n\tld\t(0x229dd7:24), 1\n")
p = os.path.join(T, "hd-ae5000_v2_01i.s")
s = open(p, "rb").read()
ls = [l for l in s.split(b"\n")
      if not l.lstrip().startswith((b".equ HDAE5000_RAM_LyricForeColor,", b".equ HDAE5000_RAM_LyricBackColor,"))]
assert len(ls) == s.count(b"\n") + 1 - 2
open(p, "wb").write(b"\n".join(ls))
rep("hd-ae5000_v2_01i.s",
    b";   0x229D99  HDAE5000_RAM_WriteProtect .. 0x229DAE HDAE5000_RAM_LyricBackColor -",
    b";   0x229D99  HDAE5000_RAM_WriteProtect .. 0x229DAC HDAE5000_RAM_LyricJump -")
print("ok")
