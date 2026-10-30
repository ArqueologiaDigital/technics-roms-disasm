"""v1.x has no MT_SelectAll: no "select all" soft button in the list, nor its handler.

  * HDAE5000_SelectListProc forwards soft buttons base+4 / +6 / +7 as MT_SelectSAVE /
    SelectOK2 / SelectDEL in both versions; v2.x also forwards base+8 as MT_SelectAll.
  * HDAE5000_CopyToHDScreen, v1.15i 0x288d10: `cp XBC,0x01ea0002 / jrl Z / cp XBC,
    0x01ea0008 / jr Z / cp XBC,0x01ea0006 / jrl NZ,<done>`, then the SelectOK case; it ends
    `ld XHL,0 / ret` (0x288dc9).  v2.x saves IZ, and on MT_SelectAll (0x01ea0009) marks
    every active entry of the floppy list with IZ as the counter.
"""
import re
from _edit import read, write, delete_between

delete_between("hd-ae5000_v1_15i.s", "HDAE5000_SelectListProc_Skip19", "HDAE5000_SelectListProc_Skip20")
f = "hdae5000_filesystem.s"
s = read(f)
s, n = re.subn(rb"(HDAE5000_CopyToHDScreen:\n[^\n]*\n)\tpushw iz[^\n]*\n", rb"\1", s)
assert n == 1, "push"
s, n = re.subn(rb"\tjr z, \.Lfbs_evt_0006[^\n]*\n\tcp xbc, EVT_HDAE_SELECT_ALL[^\n]*\n(?:.*\n)*?(?=\t; Event 0x01EA0006)",
               b"\tjrl nz, .Lfbs_evt_done\n\n", s)
assert n == 1, "select all"
s, n = re.subn(rb"(\.Lfbs_evt_done:\n(?:\t;[^\n]*\n)?[^\n]*\n)\tpopw iz[^\n]*\n", rb"\1", s)
assert n == 1, "pop"
write(f, s)
print("ok")
