"""Language message 62 (the evaluation date: "Evaluation 07-07-98" in v1.15i) is not in v1.10i.

v1.10i's AcLanguageText1Proc dispatch (0x28aa9d): `cp WA,0x003c / jr LE` (entries 0..60 for
messages 1..61), `sub WA,0x008a / cp WA,0x003d .. 0x0049` (200..212): 74 entries; none of
the three texts is in the image.  Its case, entry and texts go.
"""
import re
from _edit import read, write, delete_routine, delete_block

delete_routine("hdae5000_ui_display.s", "HDAE5000_AcLanguageText1Proc_Msg062",
               "HDAE5000_AcLanguageText1Proc_Msg200", with_header=False)
for lab in ("HDAE5000_LangMsg_062_EN", "HDAE5000_LangMsg_062_DE", "HDAE5000_LangMsg_062_FR"):
    delete_block("hdae5000_data_tables.s", lab)
f = "hdae5000_data_tables.s"
s = read(f)
s, n = re.subn(rb"\t\.short\tHDAE5000_AcLanguageText1Proc_Msg062 - [^\n]*\n", b"", s)
assert n == 1
s = s.replace(b"; HDAE5000_LangText_CaseTable (75 x u16)", b"; HDAE5000_LangText_CaseTable (74 x u16)")
s = s.replace(b"Entry i serves message i+1 (i <= 0x3d) or\n; i+0x8a (0x3e <= i <= 0x4a, the `sub wa,0x89` range)",
              b"Entry i serves message i+1 (i <= 0x3c) or\n; i+0x8b (0x3d <= i <= 0x49, the `sub wa,0x8a` range)")
s = s.replace(b"v1.15i covers messages 1-62 and 200-212\n; (v2.01i 1-64",
              b"v1.10i covers messages 1-61 and 200-212\n; (v1.15i 1-62, v2.01i 1-64")
write(f, s)
print("ok")
