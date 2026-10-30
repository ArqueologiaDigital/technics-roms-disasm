"""HDAE5000_FILE_LOAD_Screen's message switch: 13 cases in v1.x, keyed by v1.x's ids.

v1.x numbers MT_SelectDEL 0x01ea000b and MT_SelectDelFile 0x01ea000c (07): the switch over
0x01ea0000 + i has 13 entries (status showed v2.01i's 14th with nothing against it), and
its last two cases are those two.  v2.x's entry 9 (MT_SelectAll, a default case) goes, the
cases are renamed after v1.x's ids, and the header follows.
"""
import re
from _edit import read, write

d, h = "hdae5000_data_tables.s", "hdae5000_hd_driver.s"
s = read(d)
s, n = re.subn(rb"\t\.short\tHDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001\t; 0x01EA0009 \(default\)\n", b"", s)
assert n == 1
s = s.replace(b"; 0x01EA000A (default)\n\t.short\tHDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001\t; 0x01EA000B (default)",
              b"; 0x01EA0009 (default)\n\t.short\tHDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001\t; 0x01EA000A (default)")
s = s.replace(b"; 0x01EA000C\n", b"; 0x01EA000B, MT_SelectDEL in v1.x\n", 1)
s = s.replace(b"; 0x01EA000D\n", b"; 0x01EA000C, MT_SelectDelFile in v1.x\n", 1)
s = s.replace(b"; HDAE5000_FILE_LOAD_Screen_CaseTable (0x2E253A, 14 x u16)", b"; HDAE5000_FILE_LOAD_Screen_CaseTable (13 x u16)")
s = s.replace(b"bound `cp xwa,13`", b"bound `cp xwa,12`").replace(b"0x01EA0000+i; 14 entries, pinned by the bound",
                                                              b"0x01EA0000+i; 13 entries, pinned by the bound")
for f in (d, h):
    t = s if f == d else read(f)
    t = re.sub(rb"HDAE5000_FILE_LOAD_Screen_Ev01EA000C(?![\w])", b"HDAE5000_FILE_LOAD_Screen_Ev01EA000B", t)
    t = re.sub(rb"HDAE5000_FILE_LOAD_Screen_Ev01EA000D(?![\w])", b"HDAE5000_FILE_LOAD_Screen_Ev01EA000C", t)
    write(f, t)
print("ok")
