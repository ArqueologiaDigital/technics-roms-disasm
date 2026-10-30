"""The tail of the .data image as v1.x has it (hdae5000_init_data.s).

v1.15i, image 0x2e0fb6-0x2e1989 (copied to RAM 0x23c914, 0x9d4 bytes: the boot copy loop):
right after HDAE5000_ScreenName_Table (its last entry at 0x2e1924) comes the column ruler
"1234...890" (0x2e1928) -- no FileFormat_VersionMajor / _Minor words; the browser state,
then 16, 16, 0 at 0x2e197a, then the main workspace pointer's slot (0x2e1980, RAM 0x23d2de,
HDAE5000_RAM_MainWorkspacePtr) and 6 zero bytes; the image ends there.  v2.x has two more
words (2, 0) before the 210-byte lyric lines and the lyric box id.  The word 0x000e at
0x2e198a follows, then zeros to the end of the ROM (99_tail_fill.py sizes them).
"""
import re
from _edit import read, write

f = "hdae5000_init_data.s"
s = read(f)
def sub(pat, rep):
    global s
    s, n = re.subn(pat, rep, s)
    assert n == 1, pat[:50]
sub(rb"HDAE5000_FileFormat_VersionMajor:\n[^\n]*\nHDAE5000_FileFormat_VersionMinor:\n[^\n]*\n", b"")
sub(rb"\t\.short 2\t+; RAM 0x23a02e\n\t\.short 0\t+; RAM 0x23a030\nHDAE5000_LyricLines_Init:\n(?:[^\n]*\n)*?"
    rb"HDAE5000_LyricBoxObj_Init:\n\t\.long 0xffffffff[^\n]*\n\t\.zero 10\t+; RAM 0x23a10c[^\n]*\n\t+;[^\n]*\n",
    b"\t.zero 10\t\t; HDAE5000_RAM_MainWorkspacePtr's slot + 6 bytes; the copied image ends here\n")
for name in (b"FileFormat_VersionMajor", b"FileFormat_VersionMinor", b"LyricLines_Init"):
    sub(rb"\t\.set\tHDAE5000_RAM_" + name + rb", [^\n]*\n", b"")
write(f, s)
print("ok")
