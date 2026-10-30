"""The banner of hd-ae5000_v1_15i.s says what this tree is (it came with v2.01i's)."""
import re
from _edit import TREE, read, write

f = "hd-ae5000_%s.s" % TREE[len("hdae5000_"):]
s = read(f)
new = b"""; =============================================================================
; HD-AE5000 expansion ROM v1.15i  (IC4, 512 KiB at 0x280000)
; =============================================================================
; PORTED from the v2.01i tree (hdae5000_v2_01i/) by scripts/tools/port_hdae5000_version.py:
; notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/replay.sh rebuilds this tree from it,
; running the tool's passes and the hand edits there in order; README.md in that folder's
; parent says what v1.x lacks against v2.x (no lyrics, no floppy lyric selector, no
; file-selection backdrop, no XAP flash service, eight parts instead of nine ...).  Names and
; routine headers are v2.x's wherever the code is the same.  `make gate` rebuilds this tree
; byte-identical to the v1.15i dump (SHA-1 581fa58e2cd6fe381cfc312c73771d25ff2e662c).
;
; ADDRESSES AND OBJECT NUMBERS QUOTED IN COMMENTS ARE v2.06i'S OR v2.01i'S unless a
;   comment says otherwise: the comments came with the code.  Trust the labels:
;   rebuilt_ROMs/hd-ae5000_v1_15i.llvm.elf and symbols/hdae5000_v1_15i_symbols_reference.txt
;   give every name's v1.15i address.  The UI object section (hdae5000_ui_tree.s) is the
;   exception: it is generated from this ROM and numbers objects as v1.15i does.
;
; shared/event_codes.s is this tree's own (v1.x numbers the HD-AE5000's messages
; differently); the rest of shared/ and the pictures that did not change come from
; hdae5000/ through the build's second -I.
; =============================================================================
"""
s, n = re.subn(rb"\A; =+\n; HD-AE5000 expansion ROM v2\.01i .*?\n; =+\n(?=\n)", new.replace(b"\\", b"\\\\"), s, flags=re.S)
assert n == 1
s = s.replace(b"; HD-AE5000 Hard Disk Expansion ROM, v2.01i\n", b"; HD-AE5000 Hard Disk Expansion ROM, v1.15i\n")
write(f, s)
print("ok")
