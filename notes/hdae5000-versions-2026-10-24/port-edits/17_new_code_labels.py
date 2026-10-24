"""Names for the code labels the porting tool created in v2.01i (the last ones left).

* HDAE5000_HDD_UTIL_PAGE: the hard-disk utility page's switch handler.  v2.01i has a
  switch 9 that formats the drive from this page (v2.06i's handler has none); its
  error path and the switch-11 drive-info path get names, and the routine a header.
* HDAE5000_FDFileSelectProc_Skip / _Skip2 were second names of .Lsc_epilogue /
  .Lsc_ret0 (one name per address, CLAUDE.md "Canonical Label Names").

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/17_new_code_labels.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")


def sub_all(old, new):
    for fn in os.listdir(T):
        if fn.endswith(".s"):
            p = os.path.join(T, fn)
            s = open(p, "rb").read()
            t = re.sub(rb"(?<![\w.@])" + re.escape(old) + rb"(?![\w])", new, s)
            if t != s:
                open(p, "wb").write(t)


def rep(fn, old, new):
    p = os.path.join(T, fn)
    s = open(p, "rb").read()
    assert s.count(old) == 1, (fn, s.count(old), old[:60])
    open(p, "wb").write(s.replace(old, new))


rep("hdae5000_hd_driver.s",
    b"HDAE5000_HDD_UTIL_PAGE:\n\t; registered as \"HDD_UTIL_PAGE\" in HDAE5000_ObjHandler_Table\n",
    b"; ---------------------------------------------------------------------------\n"
    b"; The hard-disk utility page.  Switch 11 prints the drive's identity and the\n"
    b"; panel's resource information (HDAE5000_HardTest_HddIdRead, HamaFn_GetResouceInfo:\n"
    b"; v2.01i lists LSW, SDA, PMT and SQF; v2.06i also SEQ, CMP, TM, MSP, RCM and MD).\n"
    b"; Switch 9, which v2.06i's handler does not have, formats the drive from here:\n"
    b"; \"FORMAT TRY !!!\", HDAE5000_HD_FormatDrive, then \"FORMAT FINISHED !!!\" or\n"
    b"; \"FORMAT ERROR !!!\" and the error number (HD_FormatDrive's result in L, kept in QIZH).\n"
    b"; ---------------------------------------------------------------------------\n"
    b"HDAE5000_HDD_UTIL_PAGE:\n\t; registered as \"HDD_UTIL_PAGE\" in HDAE5000_ObjHandler_Table\n")
sub_all(b"HDAE5000_HDD_UTIL_PAGE_OnSwIn_Skip2", b"HDAE5000_HDD_UTIL_PAGE_OnSwIn_FormatError")
sub_all(b"HDAE5000_HDD_UTIL_PAGE_OnSwIn_Skip", b"HDAE5000_HDD_UTIL_PAGE_OnSwIn_DriveInfo")
rep("hdae5000_hd_driver.s",
    b"\tcp\txwa, 0x00000009\n\tjrl\tnz, HDAE5000_HDD_UTIL_PAGE_Join\n",
    b"\tcp\txwa, 0x00000009\n\tjrl\tnz, HDAE5000_HDD_UTIL_PAGE_Join\n"
    b"\t; switch 9: format the drive (v2.01i only)\n")
rep("hdae5000_ui_display.s", b".Lsc_ret0:\nHDAE5000_FDFileSelectProc_Skip2:\n", b".Lsc_ret0:\n")
rep("hdae5000_ui_display.s", b".Lsc_epilogue:\nHDAE5000_FDFileSelectProc_Skip:\n", b".Lsc_epilogue:\n")
sub_all(b"HDAE5000_FDFileSelectProc_Skip2", b".Lsc_ret0")
print("ok")
