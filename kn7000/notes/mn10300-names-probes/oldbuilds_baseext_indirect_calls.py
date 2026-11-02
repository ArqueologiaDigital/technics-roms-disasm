#!/usr/bin/env python3
"""oldbuilds_baseext_indirect_calls.py -- where do BASEEXT.XAP's 1,340 indirect calls go?

Question: notes/sp7001-build-diff.md said 639 of the plug-in's `calls (aN)` go through
the framework object's +0x1C table and 701 "through other MILK objects".  The
"framework object" the loader hands over (a0 = 0x5011FABC, kept in XapFrameworkObj
0x502B4044) is program 942's MILK object-table registry: RegisterObjectTable
(0x4842A719) copies each table's 16-byte header {class, proc, count, table} to
0x5011FABC + 16 * slot, so *(XapFrameworkObj + 16 * slot + 0xC) is the table
registered in SLOT, and +0x1C is slot 1 (InitBlockTable), +0x2E1C slot 0x2E1
(PAPI_Functions, the plug-in export table), etc.

This probe decodes the .XAP's code (file 0x0..0x1321E, linked at 0x5029B000) with
unidasm, and for every `calls (aN)` evaluates the register backwards inside its
basic block (a call kills d0, d1, a0, a1, which the MN10300 C ABI does not
preserve), and through a block start into its predecessors when they all give the
same value, into an expression:
    REG[slot][k]   *(*(XapFrameworkObj + 16*slot + 0xC) + 4*k): a registered table entry
    OBJECT         *(*(X) + 4k) for a RAM word X the plug-in built as a PtrStrList or
                   StrList (it passed X to KssContext+0x118 / +0x11C): method k of that
                   class's vtable in the base plug-in's RAM image
    OWN(X)+...     a pointer chain rooted in one of the plug-in's own RAM words X
    ARG / ?        a register the block does not define (a parameter, a callee-saved
                   value set elsewhere) or an operation the evaluator does not model
    KssContext+N  *(*(XapContext 0x502B4048) + N): a word of the base (table-flash)
                   plug-in's service table at 0x502992E4 (loc_483EC486, ...: its initial
                   value, src/sp7001/plugin/data/data_00.s `ptr_502992E4`)
and prints the counts by class, the registry entries by name (942's symbol files,
the table slots from src/sp7001/program/data/*.s), and the own-object roots.

Measured 2026-11-02 at c240d1c0b (1,340 sites): registry 967 (InitBlockTable 643 / 30
methods, PAPI_Functions 324 / 62), context 329 (23 slots), object 20 (PtrStrList, 3 methods),
sp 11, unmodelled 6, arg 5, own 1, ret 1.

Run (from kn7000/, read-only on the baserom images):
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 -I notes/mn10300-names-probes/oldbuilds_baseext_indirect_calls.py [-v]
"""
import collections
import glob
import os
import re
import struct
import subprocess
import sys

UNIDASM = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
XAP = "baserom/sp7001_baseext.xap"
FW = "baserom/kn7000_program_sp7001.rom"
BASE, CODE_END = 0x5029B000, 0x1321E
FWOBJ = 0x502B4044                      # XapFrameworkObj: *this = 0x5011FABC, the registry
REGISTRY = 0x5011FABC
XAPCTX = 0x502B4048                     # XapContext: *this = 0x502992E4, the base plug-in's table
CTX = 0x502992E4
CTX_SRC = "src/sp7001/plugin/data/data_00.s"   # its initial words, typed by gen_data_s.py
TABLE_SYMS = ["kn7000_sp7001_table.sym", "kn7000_sp7001_table_manual.sym"]
SYMS = ["kn7000_sp7001.sym", "kn7000_sp7001_manual.sym", "kn7000_sp7001_new.sym",
        "kn7000_sp7001_exports.sym", "src/sp7001/program/data/labels.sym"]
INSN = re.compile(r"([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s+(\S+)\s*(.*)$")
BRANCH = {"bra", "beq", "bne", "bgt", "bge", "blt", "ble", "bhi", "bcc", "bcs", "bls",
          "bvc", "bvs", "bnc", "bns", "jmp", "lra", "leq", "lne", "lcc", "lcs", "lhi", "lls",
          "lge", "lgt", "lle", "llt"}
ENDS = {"ret", "retf", "rets", "rti", "jmp", "bra"}


def decode():
    d = open(XAP, "rb").read()
    out, cur = [], 0
    while cur < CODE_END:
        txt = subprocess.run([UNIDASM, XAP, "-arch", "mn10300", "-basepc", f"0x{BASE + cur:x}",
                              "-skip", f"0x{cur:x}", "-count", str(CODE_END - cur)],
                             capture_output=True, text=True).stdout
        restart = False
        for line in txt.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            a = int(m.group(1), 16)
            by = bytes.fromhex(m.group(2).replace(" ", ""))
            if by == b"\xf4":                       # unidasm's F4 length bug
                out.append((a, 2, m.group(3), m.group(4).strip()))
                cur = a + 2 - BASE
                restart = True
                break
            out.append((a, len(by), m.group(3), m.group(4).strip()))
            cur = a + len(by) - BASE
            if cur >= CODE_END:
                break
        if not restart:
            break
    return out


def load_names():
    names = {}
    for path in SYMS:
        for line in open(path):
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m:
                names.setdefault(int(m.group(1), 16), m.group(2))
    return names


def load_ctx():
    """the base plug-in's service table at 0x502992E4: its .long words, in order."""
    L = open(CTX_SRC, "rb").read().decode("latin1").split("\n")
    i = next(k for k, l in enumerate(L) if l.startswith(f"ptr_{CTX:08X}:"))
    out = []
    for l in L[i + 1:]:
        m = re.match(r"\s+\.long\s+(\S+)", l)
        if not m:
            break
        out.append(m.group(1))
    return out


CLASSES = {0x118: ("PtrStrList", "ptrs_502990C0"), 0x11C: ("StrList", "ptrs_502990F0")}


def load_words(label):
    """the .long words that follow `label:` in the base plug-in's typed RAM image."""
    L = open(CTX_SRC, "rb").read().decode("latin1").split("\n")
    i = next(k for k, l in enumerate(L) if l.startswith(label + ":"))
    out = []
    for l in L[i + 1:]:
        m = re.match(r"\s+\.long\s+(\S+)", l)
        if not m:
            break
        out.append(m.group(1))
    return out


def load_slots(names):
    """slot -> (table label, table address), from the data generator's comments."""
    byname = {v: k for k, v in names.items()}
    slots = {}
    for path in sorted(glob.glob("src/sp7001/program/data/data_*.s")):
        L = open(path, "rb").read().decode("latin1").split("\n")
        for i, l in enumerate(L):
            m = re.search(r"is \(0x([0-9a-f]+) << 16\) \| its index", l)
            if not m:
                continue
            for k in range(i + 1, min(i + 4, len(L))):
                mm = re.match(r"^([A-Za-z_]\w*):", L[k])
                if mm and mm.group(1) in byname:
                    slots[int(m.group(1), 16)] = (mm.group(1), byname[mm.group(1)])
                    break
    return slots


PREDS = {}         # instruction index -> the indices control can come from (set by main)


def evaluate(insns, i, reg, starts, depth=0, seen=None):
    """the value of `reg` just before insns[i], walking back; at a block start it
    follows the predecessors (a fall-through and/or branches) and keeps the value
    only when every predecessor gives the same one."""
    if depth > 24:
        return ("?",)
    seen = set() if seen is None else seen
    j = i - 1
    while j >= 0:
        a, n, mn, ops = insns[j]
        if insns[j + 1][0] in starts:           # the block starts at insns[j + 1]
            ps = PREDS.get(j + 1, [])
            if not ps or (j + 1) in seen or len(ps) > 4:
                return ("ARG", reg)
            seen = seen | {j + 1}
            vals = {evaluate(insns, p + 1, reg, starts, depth + 1, seen) for p in ps}
            return vals.pop() if len(vals) == 1 else ("ARG", reg)
        if mn in ENDS:
            return ("ARG", reg)
        if mn in ("call", "calls") and reg in ("d0", "d1", "a0", "a1"):
            return ("RET", reg)
        parts = [p.strip() for p in re.split(r",(?![^(]*\))", ops)]
        if len(parts) >= 2 and parts[-1] == reg:
            src = parts[0]
            if mn == "mov":
                m = re.fullmatch(r"\((0x[0-9a-f]+)\)", src)
                if m:
                    return ("MEM", int(m.group(1), 16))
                m = re.fullmatch(r"\((0x[0-9a-f]+|\d+), (a\d|sp)\)", src)
                if m:
                    return ("LOAD", evaluate(insns, j, m.group(2), starts, depth + 1, seen)
                            if m.group(2) != "sp" else ("SP",), int(m.group(1), 0))
                m = re.fullmatch(r"\((a\d)\)", src)
                if m:
                    return ("LOAD", evaluate(insns, j, m.group(1), starts, depth + 1, seen), 0)
                if re.fullmatch(r"-?(0x[0-9a-f]+|\d+)", src):
                    return ("CONST", int(src, 0) & 0xFFFFFFFF)
                if re.fullmatch(r"[ad]\d", src):
                    return evaluate(insns, j, src, starts, depth + 1, seen)
                return ("?", f"{mn} {ops}")
            if mn in ("add", "inc4", "inc") and len(parts) == 2:
                if re.fullmatch(r"-?(0x[0-9a-f]+|\d+)", parts[0]):
                    base = evaluate(insns, j, reg, starts, depth + 1, seen)
                    return ("ADD", base, int(parts[0], 0))
            return ("?", f"{mn} {ops}")
        if mn in ("inc4", "inc") and ops == reg:
            return ("ADD", evaluate(insns, j, reg, starts, depth + 1, seen), 4 if mn == "inc4" else 1)
        if mn == "movm" and ops.startswith("(sp)") and reg in ops:
            return ("ARG", reg)
        j -= 1
    return ("ARG", reg)


def classify(e, slots, names, fw, ctx, tnames, objs={}):
    """-> (class, detail)"""
    if e[0] == "LOAD" and e[1] == ("MEM", XAPCTX) and e[2] % 4 == 0 and e[2] // 4 < len(ctx):
        w = ctx[e[2] // 4]
        m = re.fullmatch(r"(?:loc|func)_([0-9A-F]{8})", w)
        nm = tnames.get(int(m.group(1), 16), w) if m else w
        return "context", f"KssContext+{e[2]:#05x} = {nm}"
    if e[0] == "LOAD" and e[1][0] == "LOAD" and e[1][1] == ("MEM", FWOBJ):
        off = e[1][2]
        if off % 16 == 12 and (off - 12) // 16 in slots:
            slot = (off - 12) // 16
            tname, taddr = slots[slot]
            k = e[2] // 4
            tgt = struct.unpack_from("<I", fw, taddr - 0x48400000 + 4 * k)[0] \
                if 0x48400000 <= taddr < 0x48800000 else None
            return "registry", f"{tname}[{k}] = {names.get(tgt, hex(tgt) if tgt else '?')}"
        return "registry?", f"XapFrameworkObj +{off:#x} +{e[2]:#x}"
    root = e
    chain = []
    while root[0] in ("LOAD", "ADD"):
        chain.append(root[2])
        root = root[1]
    if root[0] == "MEM" and root[1] in objs and len(chain) == 1 and chain[0] % 4 == 0:
        cls, vt = objs[root[1]]
        w = vt[chain[0] // 4] if chain[0] // 4 < len(vt) else "?"
        m = re.fullmatch(r"(?:loc|func)_([0-9A-F]{8})", w)
        return "object", f"{cls}@{root[1]:#010x} vtbl+{chain[0]:#04x} = {tnames.get(int(m.group(1), 16), w) if m else w}"
    if root[0] == "MEM" and root[1] != FWOBJ:
        return "own", f"*({root[1]:#010x})" + "".join(f"+{c:#x}" for c in reversed(chain))
    if root[0] == "MEM":
        return "framework-other", "".join(f"+{c:#x}" for c in reversed(chain))
    if root[0] == "CONST":
        return "const", f"{root[1]:#010x}" + "".join(f"+{c:#x}" for c in reversed(chain))
    if root[0] in ("ARG", "RET", "SP"):
        return root[0].lower(), "".join(f"+{c:#x}" for c in reversed(chain))
    return "unmodelled", str(root)


def main():
    insns = decode()
    names = load_names()
    slots = load_slots(names)
    fw = open(FW, "rb").read()
    ctx = load_ctx()
    tnames = {}
    for path in TABLE_SYMS:
        for line in open(path):
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m:
                tnames.setdefault(int(m.group(1), 16), m.group(2))
    assert slots.get(1, ("",))[0] == "InitBlockTable" and slots.get(0x2E1, ("",))[0] == "PAPI_Functions", slots.get(1)
    starts = set()
    for a, n, mn, ops in insns:
        if mn in BRANCH or mn in ("call", "calls"):
            m = re.search(r"0x([0-9a-f]{8})", ops)
            if m:
                starts.add(int(m.group(1), 16))
    for idx in range(1, len(insns)):        # the instruction after a branch / return
        if insns[idx - 1][2] in ENDS:
            starts.add(insns[idx][0])
    at = {a: k for k, (a, n, mn, ops) in enumerate(insns)}
    for k, (a, n, mn, ops) in enumerate(insns):
        if k + 1 < len(insns) and mn not in ENDS:
            PREDS.setdefault(k + 1, []).append(k)
        if mn in BRANCH:
            m = re.search(r"0x([0-9a-f]{8})", ops)
            if m and int(m.group(1), 16) in at:
                PREDS.setdefault(at[int(m.group(1), 16)], []).append(k)
    sites = [(i, re.fullmatch(r"\((a\d)\)", insns[i][3]).group(1))
             for i in range(len(insns)) if insns[i][2] == "calls" and re.fullmatch(r"\(a\d\)", insns[i][3])]
    # the plug-in's own objects: the RAM words it passes (a0) to the base plug-in's
    # constructors KssContext+0x118 (a PtrStrList, vtable ptrs_502990C0, magic 0xF34E32BB)
    # and +0x11C (a StrList over one, vtable ptrs_502990F0, magic 0x89426ACE)
    objs = {}
    for i, reg in sites:
        e = evaluate(insns, i, reg, starts)
        if e[0] == "LOAD" and e[1] == ("MEM", XAPCTX) and e[2] in CLASSES:
            a0 = evaluate(insns, i, "a0", starts)
            if a0[0] == "CONST":
                objs[a0[1]] = (CLASSES[e[2]][0], load_words(CLASSES[e[2]][1]))
    print(f"own objects built through KssContext+0x118/+0x11C: " +
          ", ".join(f"{a:#x} {c}" for a, (c, _) in sorted(objs.items())))
    by_class = collections.Counter()
    detail = collections.defaultdict(collections.Counter)
    where = collections.defaultdict(list)
    for i, reg in sites:
        c, dt = classify(evaluate(insns, i, reg, starts), slots, names, fw, ctx, tnames, objs)
        by_class[c] += 1
        detail[c][dt] += 1
        where[(c, dt)].append(insns[i][0])
    print(f"{len(insns)} instructions decoded, {len(sites)} `calls (aN)`")
    for c, n in by_class.most_common():
        print(f"  {n:5d}  {c}")
    for c in by_class:
        print(f"\n== {c}: {len(detail[c])} distinct")
        for dt, n in detail[c].most_common(None if "-v" in sys.argv else 25):
            sample = " ".join(f"{a:#x}" for a in where[(c, dt)][:None if "-v" in sys.argv and c not in ("registry", "context", "object") else 3])
            print(f"  {n:4d}  {dt:<60} {sample}")


main()
