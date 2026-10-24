"""CopyFdSongToHd_Tlx's error exit keeps v2.06i's name, .Lts92f_error.

The porting tool named the branch target anew (HDAE5000_CopyFdSongToHd_Tlx_Skip) right
next to the unreferenced .Lts92f_error on the same instruction (found by
scripts/analysis/hdae5000_version_label_check.py's rename suggestions).

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/16_tlx_error_label.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
p = os.path.join(ROOT, "hdae5000_v2_01i", "hdae5000_ui_display.s")
s = open(p, "rb").read()
old = b".Lts92f_error:\nHDAE5000_CopyFdSongToHd_Tlx_Skip:\n"
assert s.count(old) == 1 and s.count(b"HDAE5000_CopyFdSongToHd_Tlx_Skip") == 2
s = s.replace(old, b".Lts92f_error:\n").replace(b"HDAE5000_CopyFdSongToHd_Tlx_Skip", b".Lts92f_error")
open(p, "wb").write(s)
print("ok")
