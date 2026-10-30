#!/usr/bin/env python3
"""Does every HDAE5000_OBJ_<NAME> constant hold the id of the UI object called NAME?

QUESTION ANSWERED
    Each HD-AE5000 tree defines one HDAE5000_OBJ_<NAME> constant per UI object: since
    2026-10-29 the class macros of hdae5000/shared/naka_ui_macros.s set it, from the
    object's position in <tree>/hdae5000_ui_tree.s, to 0x007F0000 + n (object n of
    table 0x7F).  The firmware's own name for object n is the string slot n of
    HDAE5000_UiObjectName_PtrTable points at.  Byte-exactness does not pin these
    constants: a constant that is wrong in the same way at every use still assembles
    to the right bytes (on 2026-10-24 the v2.01i tree had two such, SW_HD_FORMAT and
    CP_FD_HDSWSEL, left by the porting tool).  This check reads the constants from the
    linked ELF (llvm-nm, absolute symbols) and the names from the REFERENCE image, and
    fails when

      - an object the firmware names NAME has no HDAE5000_OBJ_NAME, or a different value;
      - a constant names an object the firmware names otherwise (a symbol made up for an
        object the firmware left unnamed is fine: the tree has to call it something);
      - two constants share a value, or an object has no constant.

RUN
    python3 scripts/analysis/hdae5000_obj_constants_check.py [TREE ...]
    TREE defaults to hdae5000 and every hdae5000_v* directory.  Needs the built
    rebuilt_ROMs/<image>.llvm.elf and original_ROMs/<image>.ic4.  Exit status 1 on a
    mismatch; `make gate` runs it.
"""
import glob
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
BASE = 0x280000
IMAGE = {"hdae5000": "hd-ae5000_v2_06i", "hdae5000_v2_01i": "hd-ae5000_v2_01i",
         "hdae5000_v1_15i": "hd-ae5000_v1_15i", "hdae5000_v1_10i": "hd-ae5000_v1_10i"}


def check(tree):
    t = os.path.basename(os.path.normpath(tree))
    img = IMAGE[t]
    out = subprocess.run([NM, "--defined-only", os.path.join(ROOT, "rebuilt_ROMs", img + ".llvm.elf")],
                         capture_output=True, text=True, check=True).stdout
    const, sym = {}, {}
    for ln in out.split("\n"):
        f = ln.split()
        if len(f) == 3:
            if f[2].startswith("HDAE5000_OBJ_") and f[1] in "aA":
                const[f[2][len("HDAE5000_OBJ_"):]] = int(f[0], 16)
            sym[f[2]] = int(f[0], 16)
    rom = open(os.path.join(ROOT, "original_ROMs", img + ".ic4"), "rb").read()
    u32 = lambda a: int.from_bytes(rom[a - BASE:a - BASE + 4], "little")
    pt, nt = sym["HDAE5000_UiObjectName_PtrTable"], sym["HDAE5000_UiObject_PtrTable"]
    n = 0
    while u32(nt + 4 * n):
        n += 1
    names = []
    for i in range(n):
        a = u32(pt + 4 * i) - BASE
        names.append(rom[a:rom.index(b"\0", a)].decode("latin-1"))
    bad = []
    for i, nm in enumerate(names):
        if nm and const.get(nm) != 0x007F0000 + i:
            bad.append("%s: object #%d is %s, HDAE5000_OBJ_%s = %s" % (
                t, i, nm, nm, "%#010x" % const[nm] if nm in const else "undefined"))
    by_val = {}
    for nm, v in const.items():
        by_val.setdefault(v, []).append(nm)
        i = v - 0x007F0000
        if not 0 <= i < n:
            bad.append("%s: HDAE5000_OBJ_%s = %#010x is no object of the table" % (t, nm, v))
        elif names[i] and names[i] != nm:
            bad.append("%s: HDAE5000_OBJ_%s = %#010x, but the firmware calls #%d %s" % (t, nm, v, i, names[i]))
    for v, nms in sorted(by_val.items()):
        if len(nms) > 1:
            bad.append("%s: %#010x is the value of %s" % (t, v, ", ".join(sorted(nms))))
    missing = n - len(by_val)
    if missing:
        bad.append("%s: %d objects have no HDAE5000_OBJ_ constant" % (t, missing))
    print("%-16s %4d objects, %3d named by the firmware, %4d constants, %d errors" % (
        t, n, sum(1 for x in names if x), len(const), len(bad)))
    return bad


def main():
    trees = sys.argv[1:] or ([os.path.join(ROOT, "hdae5000")] +
                             sorted(glob.glob(os.path.join(ROOT, "hdae5000_v*"))))
    bad = []
    for t in trees:
        img = IMAGE.get(os.path.basename(os.path.normpath(t)))
        if img is None or not os.path.exists(os.path.join(ROOT, "rebuilt_ROMs", img + ".llvm.elf")):
            print("%-17s not built (no ELF in rebuilt_ROMs/): skipped" % os.path.basename(os.path.normpath(t)))
            continue
        bad += check(t)
    for b in bad:
        print("FAIL  " + b)
    if bad:
        sys.exit(1)
    print("OK    every HDAE5000_OBJ_* constant is 0x007F0000 + the index of its object, and the "
          "firmware's names agree")


if __name__ == "__main__":
    main()
