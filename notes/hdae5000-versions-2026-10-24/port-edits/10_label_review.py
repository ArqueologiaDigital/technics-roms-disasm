"""Fixes from the label review (scripts/analysis/hdae5000_version_label_check.py v2_01i).

* Where v2.01i's code branches to the place a v2.06i label names, but the porting tool
  could not map that label and made a new one, the new label takes the old name and the
  old label, which nothing references any more, goes:
    HDAE5000_CopyFdSongToHd_Skip4         -> HDAE5000_CopyFdSongToHd_Join8
    HDAE5000_HD_Format_CompareLoop_Skip3  -> HDAE5000_HD_Format_Exit
* Two v2.06i branch-target labels of CopyFdSongToHd that nothing in v2.01i branches to
  (_Skip, _Join11) are deleted: they had been left in the middle of changed code.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/10_label_review.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
RENAME = {"HDAE5000_CopyFdSongToHd_Skip4": "HDAE5000_CopyFdSongToHd_Join8",
          "HDAE5000_HD_Format_CompareLoop_Skip3": "HDAE5000_HD_Format_Exit"}
DELETE = set(RENAME.values()) | {"HDAE5000_CopyFdSongToHd_Skip", "HDAE5000_CopyFdSongToHd_Join11"}
for fn in sorted(os.listdir(T)):
    if not fn.endswith(".s"):
        continue
    p = os.path.join(T, fn)
    s = open(p, "rb").read()
    ls = s.split(b"\n")
    out = []
    for ln in ls:
        m = re.match(rb"^([A-Za-z_]\w*):\s*$", ln)
        if m and m.group(1).decode() in DELETE:
            continue
        out.append(ln)
    t = b"\n".join(out)
    for o, n in RENAME.items():
        t = re.sub(rb"(?<![\w.@])" + o.encode() + rb"(?![\w])", n.encode(), t)
    if t != s:
        open(p, "wb").write(t)
        print("rewrote", fn)
