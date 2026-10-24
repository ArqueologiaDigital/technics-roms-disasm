"""The v2.01i tree's banner, its main header, and its version string's name.

* A banner at the top of hd-ae5000_v2_01i.s says where the tree came from and that the
  addresses and object numbers quoted in its comments are v2.06i's (they came with the
  code), except in the regenerated UI object section.
* v2.06i's main header (ROM layout, routine addresses, RAM variables, the PC-link menu,
  all v2.06i addresses) is replaced by a short v2.01i header pointing to it.
* HDAE5000_Str_V206i holds "V2.01i" here: renamed HDAE5000_Str_V201i, with the two
  comments that quote the text.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/13_banner_and_version_string.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
BANNER = b"""; =============================================================================
; HD-AE5000 expansion ROM v2.01i  (IC4, 512 KiB at 0x280000)
; =============================================================================
; PORTED from the v2.06i tree (hdae5000/) by scripts/tools/port_hdae5000_version.py,
; then by hand: notes/hdae5000-versions-2026-10-24/README.md lists what differs and
; port-edits/ there holds every hand edit as a script.  Names and routine headers
; are v2.06i's wherever the code is the same.  `make gate` rebuilds this tree
; byte-identical to the v2.01i dump (SHA-1 0160c17baa7b026771872126d8146038a19ef53b).
;
; ADDRESSES AND OBJECT NUMBERS QUOTED IN COMMENTS ARE v2.06i'S unless a comment
;   says otherwise: the comments came with the code.  Most of the v2.01i image lies
;   0x7F2 or 0xB0A bytes below its v2.06i twin (scripts/analysis/hdae5000_version_delta.py),
;   the RAM variables from 0x229DAD up 2 to 0x96 bytes below.  Trust the labels:
;   rebuilt_ROMs/hd-ae5000_v2_01i.llvm.elf and symbols/hdae5000_v2_01i_symbols_reference.txt
;   give every name's v2.01i address.  The UI object section of hdae5000_data_tables.s
;   is the exception: it is generated from this ROM and numbers objects as v2.01i does.
;
; What this tree does not hold -- shared/event_codes.s and the pictures that did not
; change -- comes from hdae5000/ through the build's second -I.
; =============================================================================

"""
HEADER = b"""; HD-AE5000 Hard Disk Expansion ROM, v2.01i
;   Version string "V2.01i" (HDAE5000_Str_V201i).  The credits block
;   HDAE5000_Version_Info ("Technics Software section M. Kitajima 2.33J 2.21
;   TECHNICS KN5000 Juli-Oktober 1996") is the same in all four dumped versions.
;   Entry vectors at 0x280008 / 0x280010: jp HDAE5000_Boot_Init, jp
;   HDAE5000_Frame_Handler, as in v2.06i.
;   The ROM layout, the hardware it drives and the PC-link (PPORT) command menu are
;   described in the same place in hdae5000/hd-ae5000_v2_06i.s; this version has
;   the same parts in the same order, at the addresses the symbol file gives.
"""
p = os.path.join(T, "hd-ae5000_v2_01i.s")
s = open(p, "rb").read()
assert s.startswith(b"\n\t.text\n") or s.startswith(b"\t.text\n"), s[:40]
a = s.index(b"; HDAE5000 Hard Disk Expansion ROM Disassembly\n")
b = s.index(b";   Contains 17 handler addresses for commands 01-17+\n") + \
    len(b";   Contains 17 handler addresses for commands 01-17+\n")
s = BANNER + s[:a] + HEADER + s[b:]
open(p, "wb").write(s)
for fn in os.listdir(T):
    if not fn.endswith(".s"):
        continue
    q = os.path.join(T, fn)
    t = open(q, "rb").read()
    u = re.sub(rb"(?<![\w.@])HDAE5000_Str_V206i(?![\w])", b"HDAE5000_Str_V201i", t)
    u = u.replace(b'; Copy "V2.06i" with its NUL (7 bytes of HDAE5000_Str_V201i)',
                  b'; Copy "V2.01i" with its NUL (7 bytes of HDAE5000_Str_V201i)')
    u = u.replace(b'\tld xde, HDAE5000_Str_V201i\t\t; "V2.06i"', b'\tld xde, HDAE5000_Str_V201i\t\t; "V2.01i"')
    if u != t:
        open(q, "wb").write(u)
        print("rewrote", fn)
