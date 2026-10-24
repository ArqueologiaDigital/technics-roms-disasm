"""The four PORT-ORPHAN labels that code still named (07 left them for a person).

* HDAE5000_LangMsg_057_FR / _058_FR / _059_FR: in v2.01i the French texts of messages
  57-59 are empty strings (v2.06i fills them with the English text).  The strings pass
  labelled the empty strings HDAE5000_Str_Empty_6/7/8 and kept the message labels as
  orphans in front of them; the message labels belong on the empty strings.
* HDAE5000_Str_Adr_HDD_UTIL_PAGE_4: the porting tool spelled the "PCLK" pointer of the
  PC-data-link error-13 path with the orphan that shared PCLK's address; v2.06i (and
  the bytes) say HDAE5000_Str_PCLK.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/08_referenced_orphans.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")


def rep(fn, old, new):
    p = os.path.join(T, fn)
    s = open(p, "rb").read()
    assert s.count(old) == 1, (fn, s.count(old), old)
    open(p, "wb").write(s.replace(old, new))


for n, k in ((57, 6), (58, 7), (59, 8)):
    rep("hdae5000_data_tables.s",
        b"HDAE5000_LangMsg_%03d_FR:\t; PORT-ORPHAN: its v2.01i object is gone\n"
        b"HDAE5000_Str_Empty_%d:\n\t; only in v2.01i\n\t.asciz \"\"\n" % (n, k),
        b"HDAE5000_LangMsg_%03d_FR:\n\t; empty in v2.01i (v2.06i repeats the English text here)\n"
        b"\t.asciz \"\"\n" % n)
rep("hdae5000_data_tables.s",
    b"HDAE5000_Str_Adr_HDD_UTIL_PAGE_4:\t; PORT-ORPHAN: its v2.01i object is gone\n", b"")
rep("hdae5000_hd_driver.s",
    b"\tlda xwa, (HDAE5000_Str_Adr_HDD_UTIL_PAGE_4:24); 0x2E2708",
    b"\tlda xwa, (HDAE5000_Str_PCLK:24); 0x2E2708")
print("ok")
