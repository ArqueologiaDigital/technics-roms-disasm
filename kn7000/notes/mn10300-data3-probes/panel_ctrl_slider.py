#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""panel_ctrl_slider.py -- which latched panel control the one-touch volume pair 0x008006 / 0x008008 reads.

QUESTION ANSWERED (N-4b34dd8b): "941 func_48454E3A's setters (KN6000 func_4C114234 / func_4C114253) call
PanelCtrlValueGet with control 0xC2 (KN6000 0xC6); which handler latches the byte that returns, and which
wire byte reaches that handler?"  PanelCtrlValueGet indexes PanelCtrlValueGet_Table with
((c & 0xC0) >> 3) | (c & 7); the TYPE-2 frame dispatch PanelCtrlDispatch indexes PanelCtrlDispatch_Table
the same way (the TYPE bits 3..5 dropped), so wire 0xD2 / 0xD6 and control 0xC2 / 0xC6 meet at one index.
The script reads both tables from the reference image (addresses from the tree's labels.sym), prints
the value pointer and the dispatch handler of the index, and checks that the handler's code stores to
that pointer (`movbu d0, (PTR)`).  Expected: 941 index 26 -> 0x5006BEAD, handler PanelCtrlLatch32;
KN6000 index 30 -> 0x50022787, handler func_4C047993 (the same `not` / `asr 1` / remap code).

Which slider: the KN7000 service manual's CPL schematic wires VR1102 "APC/SEQUENCER" to the panel CPU's
AD2, the SX-KN6500 one (the KN6000 / KN6500 panel) VR1 "APC/SEQUENCER VOLUME" to AD6; kn7000_mame's
notes/slider-cp-protocol.md identified wire 0xD2 as the KN7000's APC/SEQ slider at run time.

RUN (from the repository root, after `make -C kn7000 baserom/kn7000_program.rom` and `make -C kn6000`):
    python3 kn7000/notes/mn10300-data3-probes/panel_ctrl_slider.py
"""
import glob
import os
import re
import struct
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = [  # (name, labels.sym, reference image, its CPU base, code glob, control)
    ("941", "kn7000/src/program/data/labels.sym", "kn7000/baserom/kn7000_program.rom", 0x48400000,
     "kn7000/src/program/*.s", 0xC2),
    ("kn6000", "kn6000/src/program/data/labels.sym", "kn6000/baserom/kn6000_program.rom", 0x4C000000,
     "kn6000/src/program.s", 0xC6),
]


def labels(path):
    out = {}
    for ln in open(os.path.join(REPO, path)):
        if not ln.startswith(";"):
            a, n, _s = ln.split()
            out[n] = int(a, 16)
    return out


def main():
    ok = True
    for name, sym, rom, base, code, ctl in TREES:
        lab = labels(sym)
        img = open(os.path.join(REPO, rom), "rb").read()
        ix = ((ctl & 0xC0) >> 3) | (ctl & 7)
        vt, dt = lab["PanelCtrlValueGet_Table"], lab["PanelCtrlDispatch_Table"]
        ptr = struct.unpack_from("<I", img, vt - base + 4 * ix)[0]
        h = struct.unpack_from("<I", img, dt - base + 4 * ix)[0]
        src = "\n".join(open(f, encoding="latin-1").read() for f in sorted(glob.glob(os.path.join(REPO, code))))
        # the handler's label: the code's function header `# Name  (CPU 0x...)` or a label of that address
        cand = re.findall(r"^# (\w+)\s+\(CPU 0x%x\)" % h, src, re.M | re.I)
        hname = cand[0] if cand else None
        if hname is None:
            # (the siblings' program.s has no headers) the labels the symbol files give
            for f in glob.glob(os.path.join(REPO, os.path.dirname(sym), "..", "..", "..", "*.sym")):
                for ln in open(f, encoding="latin-1"):
                    m = re.match(r"\s*0x%08X\s+(\w+)" % h, ln, re.I)
                    if m:
                        hname = m.group(1)
        hname = hname or f"func_{h:08X}"
        body = re.search(r"^%s:\n(.*?)\n\s*retf" % re.escape(hname), src, re.M | re.S)
        stores = body is not None and re.search(r"movbu\s+d0, \(0x%08x\)" % ptr, body.group(1)) is not None
        ok &= stores
        print(f"{name}: control 0x{ctl:02X} -> index {ix} (wire 0x{ctl | 0x10:02X}); value pointer 0x{ptr:08X};"
              f" dispatch handler {hname} 0x{h:08X}; handler stores to the pointer: {'yes' if stores else 'NO'}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
