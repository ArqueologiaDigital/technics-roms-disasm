"""The two empty FilePanel labels 00 kept until the code that read them was gone: nothing
names them now (04 deleted HDAE5000_Alloc_Memory_3 and TtlScreenR3Proc), and they sit on
HDAE5000_Palette_HddIcon."""
import re
from _edit import read, write

f = "hdae5000_data_tables.s"
s = read(f)
s, n = re.subn(rb"HDAE5000_Palette_FilePanel:\n(?:\t;[^\n]*\n)*\nHDAE5000_Bitmap_FilePanel:\n(?:\t;[^\n]*\n)*\n", b"", s)
assert n == 1
write(f, s)
print("ok")
