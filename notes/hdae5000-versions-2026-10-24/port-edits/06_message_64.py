"""v2.01i's message 64 is "Jump after Load", and it has no messages 65-67.

The strings pass labelled v2.01i's three message-64 strings as new strings
(HDAE5000_Str_JumpAfterLoad, _SpringeNachLaden, _GumpAprSSki) and kept v2.06i's
labels of messages 64-67 as PORT-ORPHAN labels in a pile in front of the next string.
This names the three strings as the other messages are named and deletes the pile
and the reader notes of the strings v2.01i does not have.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/06_message_64.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
f = os.path.join(T, "hdae5000_data_tables.s")
s = open(f, "rb").read()
a = s.index(b"\t; message 64, language 1 (English): read by HDAE5000_AcLanguageText1Proc\n"
            b"HDAE5000_LangMsg_064_EN:\t; PORT-ORPHAN")
b = s.index(b"HDAE5000_LangMsg_200_EN:\n", a)
old = s[a:b]
assert old.count(b".asciz") == 3, old
new = (b"\t; message 64, language 1 (English): read by HDAE5000_AcLanguageText1Proc.  v2.01i\n"
       b"\t; only: its message 64 is the jump-after-load setting; v2.06i's is \"LYRICS LOAD\n"
       b"\t; MODE\", and v2.06i adds messages 65-67 (lyric colour settings, overwrite query).\n"
       b"HDAE5000_LangMsg_064_EN:\n"
       b"\t.asciz \"Jump after Load\"\n"
       b"HDAE5000_LangMsg_064_DE:\n"
       b"\t; message 64, language 2 (German)\n"
       b"\t.asciz \"Springe nach laden\"\n"
       b"\t.balign 2, 0x00                       ; word-align pad\n"
       b"HDAE5000_LangMsg_064_FR:\n"
       b"\t; message 64, language 3 (French), as the ROM has it\n"
       b"\t.asciz \"Gump\\351\\351 apr\\350s ski\"\n"
       b"\t.balign 2, 0x00                       ; word-align pad\n")
s = s[:a] + new + s[b:]
open(f, "wb").write(s)
for fn in os.listdir(T):
    if not fn.endswith(".s"):
        continue
    p = os.path.join(T, fn)
    t = open(p, "rb").read()
    u = t
    for o, n in ((b"HDAE5000_Str_JumpAfterLoad", b"HDAE5000_LangMsg_064_EN"),
                 (b"HDAE5000_Str_SpringeNachLaden", b"HDAE5000_LangMsg_064_DE"),
                 (b"HDAE5000_Str_GumpAprSSki", b"HDAE5000_LangMsg_064_FR")):
        u = re.sub(rb"(?<![\w.@])" + re.escape(o) + rb"(?![\w])", n, u)
    if u != t:
        open(p, "wb").write(u)
        print("renamed in", fn)
