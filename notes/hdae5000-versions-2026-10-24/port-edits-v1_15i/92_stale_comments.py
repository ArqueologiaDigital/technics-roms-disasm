"""Comments that still quote v2.x numbers.  First scripts/analysis/hdae5000_version_stale_comments.py
<ver> --base <source> --fix (byte dumps, operand / symbol / image-address quotes), then by
hand what it lists as LEFT: the image tail's description and the PC-link status strings'
v2.06i addresses."""
import os
import re
import subprocess
import sys
from _edit import ROOT, TREE, read, write

ver = TREE[len("hdae5000_"):]
base = "v2_01i" if ver == "v1_15i" else "v1_15i"
subprocess.run([sys.executable, os.path.join(ROOT, "scripts", "analysis", "hdae5000_version_stale_comments.py"),
                ver, "--base", base, "--fix"], cwd=ROOT, check=False, stdout=subprocess.DEVNULL)   # exits 1 while LEFT > 0
s = read("hdae5000_init_data.s")
s = re.sub(rb"; File/name editing scalars and buffers  \(RAM 0x[0-9a-f]+ onwards\)",
           b"; File/name editing buffers (v1.x has no file-format version words in front of them)", s)
# (since 2026-10-31 the v2.x text goes on: "ROM end.  The ROM header's second long / names
# HDAE5000_Init_Data_End.", which the v1 text below says too)
s, n = re.subn(rb"; Tail of the ROM \(0x[0-9a-f]+-0x2fffff\)\n(?:;[^\n]*\n)*?;   it is 0x00 fill up to the 0x300000 ROM end\."
               rb"(?:  The ROM header's second long\n;   names HDAE5000_Init_Data_End\.)?\n",
               b"; Tail of the ROM\n;   The .data image ends here: the boot copy loop copies it from HDAE5000_DataSegmentImage\n"
               b";   up to HDAE5000_Init_Data_End, which the ROM header's second long also names.  The\n"
               b";   0x000e word after it is the first thing past the copied window and is never\n"
               b";   transferred to RAM; everything after it is 0x00 fill up to the 0x300000 ROM end.\n", s)
s = re.sub(rb"; HDAE5000 initialised \.data image  \(ROM 0x[0-9a-f]+ - 0x[0-9a-f]+, 0x[0-9a-f]+ bytes\)",
           b"; HDAE5000 initialised .data image  (HDAE5000_DataSegmentImage .. HDAE5000_Init_Data_End)", s)
write("hdae5000_init_data.s", s)
u = read("hdae5000_ui_display.s")
u = re.sub(rb"(\(HDAE5000_PPORT_Cmd\w+_Str_\w+:24\));[^\n]*?(?:lda XBC, \(0x[0-9A-Fa-f]+\) - |0x[0-9A-Fa-f]+ - )status string",
           rb"\1; status string", u)
write("hdae5000_ui_display.s", u)
print("ok")
