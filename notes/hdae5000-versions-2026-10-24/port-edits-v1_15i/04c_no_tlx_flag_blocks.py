"""The ninth "show the part flag" block of HDAE5000_TypeSel_ShowSaveFlags and
HDAE5000_DelOpt_ShowFlags: v1.x has eight parts, so its last block (MD) is the tail call.

v1.15i's TypeSel_ShowSaveFlags (unidasm 0x284e9a-0x285010) posts eight flags, 0x22aa06 ..
0x22aa0d, to objects 0x7f0190 .. 0x7f0197 and ends `jp T,XHL` after the eighth; v2.01i's
posts a ninth, the TLX flag to RAM_EDIT_TLX.  DelOpt_ShowFlags likewise (DEL_EDIT_TLX).
Done by hand before any pass: the blocks are alike, so a shape alignment may as well drop
the first one as the last.
"""
import re
from _edit import read, write

for f, pat in (("hdae5000_hd_driver.s",
                rb"\tcall\t\(xhl\)\n\tld\ta, \(HDAE5000_RAM_SaveOptions\+10:24\)\n(?:.*\n)*?\tjp\t\(xhl\)\n"),
               ("hdae5000_filesystem.s",
                rb"\tcall \(xhl\)\n\t; Block 9: address 0x22ABF0[^\n]*\n(?:.*\n)*?\tjp \(xhl\)\n")):
    s = read(f)
    s, n = re.subn(pat, lambda m: b"\tjp\t(xhl)\n" if b"\tcall\t" in m.group(0)[:8] else b"\tjp (xhl)\n", s, count=1)
    assert n == 1, f
    write(f, s)
print("ok")
