#!/usr/bin/env python3
"""Image-wide census of every way a SINGLE display-list record is run (open-items N-8884e5fe).

Question: FINDINGS-prom_b-disk-and-file-menus.md sec. 1 found its one-record entry shapes from one
region's call sites and said it "does not claim to be a census of every entry shape in the image".
This script makes that census over BOTH CPU-1 images (prom_a + prom_b), which are fully converted
(0 .incbin of code), so a source census sees every direct reference.

Method.
  1. The handler set H: every target of DisplayList_HandlerTable (interpreter A, 36 slots) and
     DisplayListB_HandlerTable (interpreter B, 15 slots), read from the source tables.
  2. The one-record runners R0: DisplayListB_RunOne, DisplayList_RunOne_Stack,
     DisplayListB_RunOne_Stack (the interpreter-level "end = start + 1" entries).
  3. Thunks: every `T_x: jp S` line of prom_b's routine directory whose S is in H or R0.
  4. Every reference to a name in H u R0 u thunks, anywhere in prom_a/prom_b, OUTSIDE the two
     handler tables and the thunk lines themselves, is listed with its shape (mnemonic), the
     routine it sits in, and its address.  A routine that references one is a VENEER candidate;
     the veneers' own references are then followed one level (callers of the veneers).
  5. Numeric spellings: every hex literal in an operand equal to the address of a name in the set
     (llvm-nm of the linked ELFs) is reported too -- there must be none.

Run (from wsa1/, after `make gate-wsa1` built the ELFs):
    python3 notes/open4-d-probes/single_record_entry_census.py            # the census
    python3 notes/open4-d-probes/single_record_entry_census.py --selftest # asserts the figures
"""
EXPECT_THUNKS, EXPECT_REFS, EXPECT_HV, EXPECT_RV = 17, 328, 66, 71   # measured 2026-10-31 at 130735749
import glob, os, re, subprocess, sys
from collections import defaultdict, Counter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
INTERP = "prom_b/modules/f2d800_f327ff_messages_and_display_list_interpreter.s"
DIRECTORY = "prom_b/modules/f40000_f44017_routine_directory.s"

LABEL = re.compile(rb"^([A-Za-z_.$][\w.$]*):")
ADDR = re.compile(rb";\s*([0-9A-Fa-f]{6})\b")
IDENT = re.compile(rb"[A-Za-z_.$][\w.$]*")
LOCAL = re.compile(r"(_(Loop|Skip|Join|Return)\d*|__[0-9A-F]{6})$")
HEX = re.compile(rb"0x([0-9a-fA-F]{5,8})\b")


def sources():
    out = []
    for img in ("prom_a", "prom_b"):
        out += sorted(glob.glob(os.path.join(ROOT, img, "*.s")))
        out += sorted(glob.glob(os.path.join(ROOT, img, "modules", "*.s")))
    return out


def nm(img):
    elf = os.path.join(ROOT, "rebuilt_ROMs", "wsa1_%s.llvm.elf" % img)
    res = {}
    for ln in subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout.split("\n"):
        p = ln.split()
        if len(p) == 3 and p[1] in "tT":
            res.setdefault(p[2], int(p[0], 16))
    return res


def table_targets(lines, name):
    i = next(k for k, l in enumerate(lines) if l.startswith(name.encode() + b":"))
    tg = []
    for l in lines[i + 1:]:
        m = re.match(rb"\s*\.long\s+([\w.$]+)", l)
        if not m:
            break
        tg.append(m.group(1).decode())
    return tg


def code_part(l):
    return l.split(b";", 1)[0]


def census():
    interp = open(os.path.join(ROOT, INTERP), "rb").read().split(b"\n")
    ta = table_targets(interp, "DisplayList_HandlerTable")
    tb = table_targets(interp, "DisplayListB_HandlerTable")
    H = set(ta) | set(tb)
    R0 = {"DisplayListB_RunOne", "DisplayList_RunOne_Stack", "DisplayListB_RunOne_Stack"}
    base = H | R0
    thunks = {}
    for l in open(os.path.join(ROOT, DIRECTORY), "rb").read().split(b"\n"):
        m = re.match(rb"^(T_[\w]+):\s*jp\s+([\w.$]+)", l)
        if m and m.group(2).decode() in base:
            thunks[m.group(1).decode()] = m.group(2).decode()
    targets = base | set(thunks)
    refs = []          # (file, lineno, routine, mnemonic, target, addr)
    for f in sources():
        rel = os.path.relpath(f, ROOT)
        lines = open(f, "rb").read().split(b"\n")
        routine = "(file top)"
        in_table = False
        for n, l in enumerate(lines, 1):
            m = LABEL.match(l)
            if m:
                nmv = m.group(1).decode()
                if not nmv.startswith(".") and not LOCAL.search(nmv):
                    routine = nmv
                in_table = nmv in ("DisplayList_HandlerTable", "DisplayListB_HandlerTable")
                if nmv in thunks:
                    continue
            c = code_part(l)
            if LABEL.match(c):
                c = c.split(b":", 1)[1]
            toks = IDENT.findall(c)
            if not toks:
                continue
            mnem = toks[0].decode()
            if mnem in (".set", ".equ", ".equiv"):
                continue        # prom_a's absolute equates of the prom_b thunks: definitions, not uses
            for t in toks[1:]:
                t = t.decode()
                if t in targets:
                    if in_table and mnem == ".long":
                        continue
                    a = ADDR.search(l)
                    refs.append((rel, n, routine, mnem, t, a.group(1).decode().upper() if a else "?"))
    return ta, tb, H, R0, thunks, refs


def numeric_spellings(targets):
    addrs = {}
    for img in ("prom_a", "prom_b"):
        for k, v in nm(img).items():
            if k in targets:
                addrs[v] = k
    hits = []
    for f in sources():
        for n, l in enumerate(open(f, "rb").read().split(b"\n"), 1):
            c = code_part(l)
            if re.match(rb"\s*\.(set|equ)\b", c):
                continue        # the equates that DEFINE prom_a's view of the thunks
            for h in HEX.findall(c):
                v = int(h, 16)
                if v in addrs:
                    hits.append((os.path.relpath(f, ROOT), n, addrs[v]))
    return hits


def main():
    ta, tb, H, R0, thunks, refs = census()
    targets = H | R0 | set(thunks)
    resolve = lambda t: thunks.get(t, t)
    print("interpreter A handlers: %d distinct over %d slots; interpreter B: %d distinct over %d slots"
          % (len(set(ta)), len(ta), len(set(tb)), len(tb)))
    print("one-record runners R0:", ", ".join(sorted(R0)))
    print("thunks into H u R0: %d" % len(thunks))
    for t, s in sorted(thunks.items()):
        print("   %-34s -> %s" % (t, s))
    by_target = defaultdict(Counter)
    routines = defaultdict(set)
    for rel, n, r, m, t, a in refs:
        by_target[t][m] += 1
        routines[r].add(t)
    print("\nreferences outside the handler tables and thunk lines: %d" % len(refs))
    print("| target                             | resolves to                      | refs | shapes                        |")
    print("|------------------------------------|----------------------------------|------|-------------------------------|")
    for t in sorted(by_target):
        sh = ", ".join("%s %d" % kv for kv in sorted(by_target[t].items()))
        print("| %-34s | %-32s | %4d | %-29s |" % (t, resolve(t), sum(by_target[t].values()), sh))
    shape = Counter()
    for rel, n, r, m, t, a in refs:
        if r == "OldBuild_DLHandlerTables_Tail":
            k = "stale old-build copy of the two handler tables (.long)"
        elif resolve(t) in H:
            k = "%s %s: one handler, XIY = the record" % (m, "T_DLB_Handler_* / T_DLHandler_*")
        elif resolve(t) == "DisplayListB_RunOne":
            k = "%s T_DisplayListB_RunOne: XIY = the record" % m
        else:
            k = "%s %s: record pointer on the stack" % (m, "the RunOne_Stack veneers")
        shape[(rel.split("/")[0], k)] += 1
    print("\nsites by image and shape:")
    for (img, k), v in sorted(shape.items()):
        print("   %-6s %4d  %s" % (img, v, k))
    # routines that reference a handler (H, directly or through a thunk) without being the interpreter
    interp_internal = {"DisplayList_Run", "DisplayListB_Run", "DisplayListB_RunOne",
                       "OldBuild_DLHandlerTables_Tail"} | R0   # the last is data: a stale table copy
    hv = sorted(r for r, ts in routines.items()
                if any(resolve(t) in H for t in ts) and r not in interp_internal)
    print("\nroutines that run ONE handler directly (H, not through an interpreter): %d" % len(hv))
    for r in hv:
        print("   %-40s %s" % (r, ", ".join(sorted(routines[r]))))
    rv = sorted(r for r, ts in routines.items() if any(resolve(t) in R0 for t in ts) and r not in interp_internal)
    print("\nroutines that run ONE record through a RunOne runner: %d" % len(rv))
    for r in rv:
        print("   %-40s %s" % (r, ", ".join(sorted(routines[r]))))
    num = numeric_spellings(targets)
    print("\nnumeric spellings of any of these addresses: %d" % len(num))
    for x in num:
        print("   %s:%d %s" % x)
    return ta, tb, H, R0, thunks, refs, hv, rv, num


if __name__ == "__main__":
    selftest = "--selftest" in sys.argv
    if selftest:
        sys.stdout = open(os.devnull, "w")
    ta, tb, H, R0, thunks, refs, hv, rv, num = main()
    if selftest:
        sys.stdout = sys.__stdout__
        fails = 0
        def check(name, got, want):
            global fails
            ok = got == want
            fails += not ok
            print("%-4s %-60s got %r want %r" % ("ok" if ok else "FAIL", name, got, want))
        check("interpreter A table slots", len(ta), 36)
        check("interpreter B table slots", len(tb), 15)
        check("numeric spellings of the entry set", len(num), 0)
        check("thunks into handlers / runners", len(thunks), EXPECT_THUNKS)
        check("references outside tables/thunk lines", len(refs), EXPECT_REFS)
        check("routines running one handler directly", len(hv), EXPECT_HV)
        check("routines running one record through RunOne", len(rv), EXPECT_RV)
        print("FAILURES: %d" % fails)
        sys.exit(1 if fails else 0)
