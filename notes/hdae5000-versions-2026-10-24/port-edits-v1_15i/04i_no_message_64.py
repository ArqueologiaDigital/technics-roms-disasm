"""Language message 64 ("Jump after Load", the lyric jump setting's label) is v2.x's.

v1.15i holds none of its three texts ("Jump after Load", "Springe nach laden", "Gumpéé après
ski"), and its HDAE5000_LangText_CaseTable (the message switch of AcLanguageText1Proc) is
one entry shorter: messages 1-63, then 200-212 (status showed the 2 bytes of v2.01i's
message-64 entry with nothing against them).  The case, its table entry and its texts go.
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
s = s.replace(b"; HDAE5000_LangText_CaseTable (77 x u16)", b"; HDAE5000_LangText_CaseTable (76 x u16)")
s = s.replace(b"; out of range, share the _NoMessage case.  v2.01i has no messages 65-67\n"
              b"; (v2.06i's table has 80 entries: 1-67 and 200-212).",
              b"; out of range, share the _NoMessage case.  v1.x has messages 1-63 and 200-212\n"
              b"; (v2.01i also 64, v2.06i 64-67).")
write(f, s)
print("ok")
