"""The version string: "V1.15i", and it sits in front of the title logo's palette.

v1.15i holds "V1.15i" at 0x2a3d08, right after the class-name string "HDAETitleFunc" and
padded to 0x2a3d10, where HDAE5000_Palette_TitleLogo starts; v2.x keeps its "V2.0xi" at the
head of the program's read-only data, after the HDD icon.  The label is renamed through the
tree (HDAE5000_CopyVersionString pushes it).
"""
import re
from _edit import read, write

files = ["hd-ae5000_v1_15i.s", "hdae5000_ui_display.s", "hdae5000_data_tables.s", "hdae5000_hd_driver.s",
         "hdae5000_filesystem.s", "hdae5000_utilities.s", "hdae5000_init_data.s"]
for f in files:
    s = read(f)
    s = re.sub(rb"HDAE5000_Str_V201i(?![\w])", b"HDAE5000_Str_V115i", s)
    s = s.replace(b'"V2.01i"', b'"V1.15i"')
    write(f, s)
s = read("hdae5000_data_tables.s")
blk = re.search(rb"HDAE5000_Str_V115i:\n\t; read by CopyVersionString[^\n]*\n\t\.asciz \"V1\.15i\"\n"
                rb"\t\.balign 2, 0x00[^\n]*\n", s)
assert blk, "version string block"
s = s[:blk.start()] + s[blk.end():]
k = s.index(b"\nHDAE5000_Palette_TitleLogo:")
s = s[:k + 1] + blk.group(0).replace(b"; read by CopyVersionString", b"; the version, read by CopyVersionString") \
    + s[k + 1:]
write("hdae5000_data_tables.s", s)
print("ok")
