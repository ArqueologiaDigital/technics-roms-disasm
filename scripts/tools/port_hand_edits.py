#!/usr/bin/env python3
r"""Apply the edits a ported KN5000 main-program tree gets after generation.

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py regenerates v6/maincpu from v7 (and v5 from
    v6) wholesale, so an edit made by hand to a generated tree is lost on the next
    regeneration.  Which edits does each ported tree carry, and how are they redone?  This
    script is the list, and it redoes them; run it after the porter and before
    disassemble_port_todo.py (each tree's README gives the whole sequence).

THE EDITS
  1. FIRMWARE_VERSION is `.byte FW_VERSION_BYTE`, with the tree's own default value.  v7
     spells that byte `reti` (0x07 read as an instruction), so the porter can only write the
     target's byte as a TODO(port) row.
  2. AccTone_JumpTableData is code, not data: five `call <routine>` / `ret` thunks and,
     25 bytes in, `push xiz` / `call AccStyle_UseSecondarySource` / `pop xiz` / `ret`, which
     v6's AccVoice_BarCounterBytecodeData_Helper2 calls directly (`call 0xf5e33e` before this
     edit).  v7 holds it as `.byte` rows; v10 decodes it (v10/maincpu/sequencer/
     accompaniment_engine.s) and names the 25-byte entry AccTone_LookupByProgramWrapped_Join
     and the five called routines AccTone_InlineBytecodeData, AccTone_JumpTableData_Helper3,
     _Helper2, _Helper and _Data.  The rows are rewritten as those instructions; a call
     target with no label gets v10's name when it starts a line of the tree, and stays a
     number otherwise (reported).
  Each edit is skipped when the tree already has it, so the script can run on a tree that
  inherited an edit from the tree it was ported from (v5 from v6).

RUN
    python3 scripts/tools/port_hand_edits.py --tree v6 --fw 0x06
    python3 scripts/tools/port_hand_edits.py --tree v5 --fw 0x05
    The tree must build byte-identical to its dump (rebuilt_ROMs/, `make vN-progress`); the
    script rebuilds it afterwards and restores the files if the image changed.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import port_maincpu_version as P  # noqa: E402

BASE = P.BASE
THUNK_NAMES = ["AccTone_InlineBytecodeData", "AccTone_JumpTableData_Helper3", "AccTone_JumpTableData_Helper2",
               "AccTone_JumpTableData_Helper", "AccTone_JumpTableData_Data"]
JOIN = "AccTone_LookupByProgramWrapped_Join"


def read(path):
    return open(path, "rb").read().decode("latin-1")


def write(path, text):
    open(path, "wb").write(text.encode("latin-1"))


def fw_byte(tree, fw):
    p = os.path.join(ROOT, tree, "maincpu", "boot", "rom_end_structure.s")
    s = read(p)
    s2 = re.sub(r"(\.set\tFW_VERSION_BYTE, )0x0\d", r"\g<1>" + fw, s, count=1)
    s2 = re.sub(r"FIRMWARE_VERSION:\n(\n; RESERVED:\n); TODO\(port\)[^\n]*\n\t\.byte\t0x0\d\n",
                "FIRMWARE_VERSION:\n\t.byte\tFW_VERSION_BYTE\n\\1", s2, count=1)
    if "FIRMWARE_VERSION:\n\t.byte\tFW_VERSION_BYTE" not in s2:
        sys.exit("FIRMWARE_VERSION edit did not apply in %s" % p)
    if s2 != s:
        write(p, s2)
        return True
    return False


def thunks(tree):
    """-> list of (file, old text, new text) or [] when the tree has the edit already"""
    rel = os.path.join(tree, "maincpu", "sequencer", "accompaniment_engine.s")
    p = os.path.join(ROOT, rel)
    s = read(p)
    m = re.search(r"^AccTone_JumpTableData:\n((?:\t\.byte\t?[^\n]*\n)+)", s, re.M)
    if not m:
        return None
    order, syms, rom = P.tree_map(tree)
    size = P.fill_sizes(order)
    starts = {}
    for i, e in enumerate(order):
        if size[i] > 0 and e[0] is not None:
            starts.setdefault(e[0], i)
    labels = {}
    for nm, v in sorted(syms.items()):
        labels.setdefault(v, nm)
    a = syms["AccTone_JumpTableData"]
    n = sum(len(P.split_commas(x.split(None, 1)[1])) for x in m.group(1).strip("\n").split("\n"))
    items = P.decode_region(rom[a - BASE:a - BASE + n])
    texts = [t for o, l, t in items]
    pat = [r"call \S+", r"ret"] * 5 + [r"push xiz", r"call \S+", r"pop xiz", r"ret"]
    if len(texts) != len(pat) or not all(t and re.fullmatch(q, t) for t, q in zip(texts, pat)):
        sys.exit("AccTone_JumpTableData in %s does not decode as five call/ret thunks and a push/call/pop "
                 "thunk: %r" % (tree, texts))
    out = ["AccTone_JumpTableData:"]
    inserts = []                         # (address, name) labels to add at line starts
    unnamed = []
    callno = 0
    for o, l, t in items:
        ad = a + o
        if ad == a + 25:
            out.append(JOIN + ":")
        if t.startswith("call"):
            tgt = int(t.split()[-1], 0)
            nm = labels.get(tgt)
            if nm is None and callno < 5 and tgt in starts:
                nm = THUNK_NAMES[callno]
                if nm in syms:
                    nm = None                # v10's name is used elsewhere in this tree
                else:
                    inserts.append((tgt, nm))
                    labels[tgt] = nm
            if nm is None:
                unnamed.append(hex(tgt))
            out.append("\tcall\t%s" % (nm or "0x%06x" % tgt))
            callno += 1
        else:
            out.append("\t" + t.replace(" ", "\t", 1))
    edits = [(p, m.group(0), "\n".join(out) + "\n")]
    # labels for unnamed call targets, and the direct callers of the +25 entry
    for tgt, nm in inserts:
        i = starts[tgt]
        fp = os.path.join(ROOT, tree, "maincpu", order[i][1])
        edits.append((fp, ("line", order[i][2]), nm + ":"))
    return edits, unnamed, a + 25


def apply_thunks(tree):
    r = thunks(tree)
    if r is None:
        return None
    edits, unnamed, join = r
    files = {}
    for fp, old, new in edits:
        files.setdefault(fp, read(fp))
    # line insertions first (by line number, bottom up), then the block replacement
    by_file = {}
    for fp, old, new in edits:
        by_file.setdefault(fp, []).append((old, new))
    for fp, eds in by_file.items():
        lines = files[fp].split("\n")
        for old, new in sorted((e for e in eds if isinstance(e[0], tuple)), key=lambda e: -e[0][1]):
            lines.insert(old[1] - 1, new)
        txt = "\n".join(lines)
        for old, new in eds:
            if not isinstance(old, tuple):
                assert txt.count(old) == 1, fp
                txt = txt.replace(old, new)
        files[fp] = txt
    # a numeric call to the +25 entry anywhere in the tree takes its name
    for dp, dn, fn in os.walk(os.path.join(ROOT, tree, "maincpu")):
        for f in fn:
            if f.endswith(".s"):
                fp = os.path.join(dp, f)
                txt = files.get(fp) or read(fp)
                new = re.sub(r"^(\tcall\t)0x%06x$" % join, r"\g<1>" + JOIN, txt, flags=re.M)
                if new != txt:
                    files[fp] = new
    return files, unnamed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, help="v6 or v5")
    ap.add_argument("--fw", required=True, help="the tree's firmware version byte, e.g. 0x06")
    a = ap.parse_args()
    if not re.fullmatch(r"v\d+", a.tree) or not re.fullmatch(r"0x0\d", a.fw):
        sys.exit("--tree vN --fw 0x0N")
    rom = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % a.tree)
    r = apply_thunks(a.tree)
    backup = {}
    if r is not None:
        files, unnamed = r
        for fp, txt in files.items():
            backup[fp] = read(fp)
            write(fp, txt)
        print("AccTone_JumpTableData decoded as thunks in %s; call targets left numeric: %s"
              % (a.tree, " ".join(unnamed) or "none"))
    else:
        print("AccTone_JumpTableData: already code in %s" % a.tree)
    fp = os.path.join(ROOT, a.tree, "maincpu", "boot", "rom_end_structure.s")
    old = read(fp)
    if fw_byte(a.tree, a.fw):
        backup.setdefault(fp, old)
        print("FIRMWARE_VERSION is FW_VERSION_BYTE (%s) in %s" % (a.fw, a.tree))
    if not backup:
        return
    res = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % a.tree], cwd=ROOT,
                         capture_output=True, text=True)
    built = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % a.tree)
    if res.returncode != 0 or open(built, "rb").read() != open(rom, "rb").read():
        for fp, txt in backup.items():
            write(fp, txt)
        sys.exit("not byte-identical after the edits; files restored\n" + res.stderr[-2000:])
    print("%s is byte-identical" % a.tree)


if __name__ == "__main__":
    main()
