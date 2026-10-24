#!/usr/bin/env python3
"""Does every HDAE5000_OBJ_<NAME> constant hold the id of the UI object called NAME?

QUESTION ANSWERED
    Each HD-AE5000 tree defines one `.equ HDAE5000_OBJ_<NAME>, 0x007fNNNN` per named UI
    object (hdae5000_data_tables.s, after HDAE5000_UiObject_PtrTable).  The main CPU
    addresses object n of table 0x7F as 0x007F0000 + n, and object n's name is the
    string HDAE5000_UiObjectName_PtrTable slot n points to.  Byte-exactness does not
    pin these constants: a constant that is wrong in the same way at every use, or
    whose uses were respelled to fit it, still assembles to the right bytes.  On
    2026-10-24 the v2.01i tree had two such constants (SW_HD_FORMAT = #222 and
    CP_FD_HDSWSEL = #220, the id of CP_FD_HDSWTO), left by the porting tool's `fix`
    pass.  This check reads the name pointer table and the name pool from the source
    (not from comments) and fails when

      - a constant's value is not 0x007F0000 + the index whose name is <NAME>;
      - two constants share a value;
      - (counted, not a failure) a named object has no constant.  Both trees had
        one constant per named object on 2026-10-24.

RUN
    python3 scripts/analysis/hdae5000_obj_constants_check.py [TREE ...]
    TREE defaults to hdae5000 and every hdae5000_v* directory.  Exit status 1 on a
    mismatch or a shared value; `make gate` runs it.
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

EQU = re.compile(rb'^\s*\.equ\s+HDAE5000_OBJ_(\w+)\s*,\s*(0x[0-9a-fA-F]+|\d+)')
SLOT = re.compile(rb'^\s*\.long\s+(HdaeUiName_\w+)\s*;\s*\[\s*(\d+)\]')
POOL = re.compile(rb'^(HdaeUiName_\w+):\s*\.(asciz|ascii)\s+"((?:[^"\\]|\\.)*)"')


def unescape(b):
    return re.sub(rb'\\(\d{1,3}|.)', lambda m: bytes([int(m.group(1), 8)]) if m.group(1).isdigit()
                  else m.group(1), b)


def check(tree):
    text = open(os.path.join(tree, "hdae5000_data_tables.s"), "rb").read().split(b"\n")
    equs, slots, pool = {}, {}, {}
    in_names = False
    for ln in text:
        m = EQU.match(ln)
        if m:
            equs[m.group(1).decode()] = int(m.group(2), 0)
            continue
        if ln.startswith(b"HDAE5000_UiObjectName_PtrTable:"):
            in_names = True
            continue
        if in_names:
            m = SLOT.match(ln)
            if m:
                slots[int(m.group(2))] = m.group(1).decode()
            elif ln.strip() and not ln.lstrip().startswith(b";"):
                in_names = False
        m = POOL.match(ln)
        if m:
            s = unescape(m.group(3)).split(b"\0")[0]
            pool[m.group(1).decode()] = s.decode("latin-1")
    idx_of = {}
    for i, lab in slots.items():
        nm = pool.get(lab, "")
        if nm:
            idx_of.setdefault(nm, []).append(i)
    bad = []
    for nm, v in sorted(equs.items(), key=lambda kv: kv[1]):
        want = idx_of.get(nm)
        if not want:
            bad.append("%s: HDAE5000_OBJ_%s = %#010x, but no object is named %s" % (tree, nm, v, nm))
        elif v not in [0x007F0000 + i for i in want]:
            bad.append("%s: HDAE5000_OBJ_%s = %#010x (#%d), but %s is object #%s (%s)" % (
                os.path.basename(tree), nm, v, v & 0xFFFF, nm, "/".join(map(str, want)),
                ", ".join("%#010x" % (0x007F0000 + i) for i in want)))
    by_val = {}
    for nm, v in equs.items():
        by_val.setdefault(v, []).append(nm)
    for v, nms in sorted(by_val.items()):
        if len(nms) > 1:
            bad.append("%s: %#010x is the value of %s" % (os.path.basename(tree), v,
                                                           ", ".join("HDAE5000_OBJ_" + n for n in sorted(nms))))
    unnamed_const = sorted(set(idx_of) - set(equs))
    print("%-16s %4d name slots, %3d named objects, %3d constants, %3d named objects without one, %d errors" % (
        os.path.basename(tree), len(slots), len(idx_of), len(equs), len(unnamed_const), len(bad)))
    return bad


def main():
    trees = sys.argv[1:] or ([os.path.join(ROOT, "hdae5000")] +
                             sorted(glob.glob(os.path.join(ROOT, "hdae5000_v*"))))
    bad = []
    for t in trees:
        bad += check(t)
    for b in bad:
        print("FAIL  " + b)
    if bad:
        sys.exit(1)
    print("OK    every HDAE5000_OBJ_* constant is 0x007F0000 + the index of its name")


if __name__ == "__main__":
    main()
