"""Language message 64 ("Jump after Load", the lyric jump setting's label) is v2.x's.

v1.15i holds none of its three texts ("Jump after Load", "Springe nach laden", "Gumpéé après
ski"), and its HDAE5000_LangText_CaseTable (the message switch of AcLanguageText1Proc) is
two entries shorter: messages 1-62, then 200-212 -- v1.15i's dispatch is `cp WA,0x003d / jr
LE` (entries 0..61 for messages 1..62), `sub WA,0x0089 / cp WA,0x003e .. 0x004a` (0x28aa9d).
Message 63 was a _NoMessage entry in v2.x.  Message 64's case, both entries and the texts go.
"""
import re
from _edit import read, write, delete_routine, delete_block

delete_routine("hdae5000_ui_display.s", "HDAE5000_AcLanguageText1Proc_Msg064",
               "HDAE5000_AcLanguageText1Proc_Msg200", with_header=False)
for lab in ("HDAE5000_LangMsg_064_EN", "HDAE5000_LangMsg_064_DE", "HDAE5000_LangMsg_064_FR"):
    delete_block("hdae5000_data_tables.s", lab)
f = "hdae5000_data_tables.s"
s = read(f)
s, n = re.subn(rb"\t\.short\tHDAE5000_AcLanguageText1Proc_Msg064 - [^\n]*\n", b"", s)
assert n == 1
s, n = re.subn(rb"\t\.short\tHDAE5000_AcLanguageText1Proc_NoMessage - [^\n]*; message 63\n", b"", s)
assert n == 1
s, n = re.subn(rb"; HDAE5000_LangText_CaseTable \(77 x u16\):(?:[^\n]*\n)*?;\n(?=HDAE5000_LangText_CaseTable:)",
               b"; HDAE5000_LangText_CaseTable (75 x u16): the message switch of\n"
               b"; HDAE5000_AcLanguageText1Proc.  Entry i serves message i+1 (i <= 0x3d) or\n"
               b"; i+0x8a (0x3e <= i <= 0x4a, the `sub wa,0x89` range); each value is an offset\n"
               b"; from HDAE5000_AcLanguageText1Proc_Msg001, the first case, and the reader\n"
               b"; jumps there (`jp T,XIX+WA`).  Messages 204 and 205, and every number out of\n"
               b"; range, share the _NoMessage case.  v1.15i covers messages 1-62 and 200-212\n"
               b"; (v2.01i 1-64, v2.06i 1-67, message 63 a _NoMessage entry in both).\n;\n", s)
assert n == 1
write(f, s)
print("ok")
