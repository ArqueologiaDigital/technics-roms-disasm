#!/usr/bin/env python3
"""hdae5000_routine_facts.py -- mechanical facts about one HD-AE5000 routine, as raw material for its header.

QUESTION IT ANSWERS
  For a routine in hdae5000/*.s (by name), what does the code itself show about its interface?
    - its span: from its label to the next label that is not one of its own (<name>_..., or a .L local);
    - callers: the call / calr / jp / jr sites that name it, grouped by the routine they sit in;
    - entry registers: the registers of XWA / XBC / XDE / XHL / XIX / XIY / XIZ (and their 16/8-bit parts)
      read before the code writes them, on the straight line from the entry up to the first branch;
    - stack arguments: (xsp+N) reads on that line whose offset, corrected for the pushes and xsp
      adjustments above them, is >= 4 (the return address is at (xsp+0) on entry), reported as
      arg+K = entry (xsp+K);
    - result: the instructions writing XHL / HL / L / XWA / WA / A on each path's last few lines before a ret;
    - RAM: named HDAE5000_RAM_* operands and numeric 0x200000-0x23ffff operands it reads or writes;
    - callees: direct call / calr targets, and the main-CPU function-table slots it calls through
      (the last RootFn_* / HamaFn_* named in the four instructions before `call (xRR)`).
  These are lower-level than a header and can be wrong where the code is not straight-line (an argument read
  only after a branch is missed); every header written from them is checked against the code by reading it.

RUN (repository root)
  python3 scripts/analysis/hdae5000_routine_facts.py HDAE5000_StrCpy [more names ...]
  python3 scripts/analysis/hdae5000_routine_facts.py --code HDAE5000_StrCpy     # also print the span
"""
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEF = re.compile(r'^([.A-Za-z_][\w$.]*):')
REGS32 = ["xwa", "xbc", "xde", "xhl", "xix", "xiy", "xiz"]
PARTS = {"xwa": ["xwa", "wa", "w", "a"], "xbc": ["xbc", "bc", "b", "c"], "xde": ["xde", "de", "d", "e"],
         "xhl": ["xhl", "hl", "h", "l"], "xix": ["xix", "ix"], "xiy": ["xiy", "iy"], "xiz": ["xiz", "iz"]}
REG_OF = {p: r for r, ps in PARTS.items() for p in ps}
RAMNUM = re.compile(r'0x2[0-3][0-9a-fA-F]{4}\b')
WRITES_FIRST = {"ld", "lda", "ldw", "ldb", "pop", "popw", "ldc", "extz", "exts", "ld_sril", "ldl"}


def strip_comment(line):
    out, q = [], None
    for ch in line:
        if q:
            out.append(ch)
            if ch == q:
                q = None
            continue
        if ch in "\"'":
            q = ch
        elif ch == ";":
            break
        out.append(ch)
    return "".join(out)


def load():
    src = {}
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        src[p] = open(p, "rb").read().decode("latin-1").split("\n")
    return src


def index(src):
    defs, owner_of = {}, {}
    for p, L in src.items():
        cur = None
        for i, x in enumerate(L):
            m = DEF.match(x)
            if m:
                n = m.group(1)
                defs[n] = (p, i)
                if not n.startswith(".L") and not (cur and n.startswith(cur + "_")):
                    cur = n
            owner_of[(p, i)] = cur
    return defs, owner_of


def span(src, defs, name):
    p, i = defs[name]
    L = src[p]
    out = []
    for k in range(i + 1, len(L)):
        m = DEF.match(L[k])
        if m and not m.group(1).startswith(".L") and not m.group(1).startswith(name + "_"):
            break
        out.append((k, L[k]))
    while out and not out[-1][1].strip():
        out.pop()
    return p, i, out


def operands(stmt):
    parts = stmt.split(None, 1)
    return parts[0].lower(), (parts[1] if len(parts) > 1 else "")


def facts(src, defs, owner_of, name):
    p, i, body = span(src, defs, name)
    code = []
    for k, x in body:
        m = DEF.match(x)
        c = strip_comment(x[m.end():] if m else x).strip()
        if m:
            code.append((k, "label", m.group(1)))
        if c and not c.startswith("."):
            code.append((k, "insn", c))
    # straight line from entry
    read_first, written, stackargs, depth = [], set(), set(), 0
    for k, kind, c in code:
        if kind == "label":
            break
        op, args = operands(c)
        al = args.lower()
        dst, src_ops = None, al
        if "," in al and op not in ("cp", "cpw", "bit", "push", "pushw", "or", "and", "xor", "add", "sub", "adc",
                                    "sbc", "inc", "dec", "incw", "decw", "mul", "muls", "div", "divs"):
            dst, src_ops = al.split(",", 1)
            dst = dst.strip()
        for t in ([] if op in ("push", "pushw") else re.findall(r'\b[a-z]+\b', src_ops if dst is not None else al)):
            r = REG_OF.get(t)
            if r and r not in written and r not in read_first and t not in ("xsp", "sp"):
                read_first.append(r)
        for m in re.finditer(r'\(\s*xsp\s*\+\s*(0x[0-9a-f]+|\d+)', src_ops if dst is not None else al):
            off = int(m.group(1), 0) - depth
            if off >= 4:
                stackargs.add(off)
        if dst is not None and op in WRITES_FIRST and dst in REG_OF and not dst.startswith("("):
            written.add(REG_OF[dst])
        if op in ("pop", "popw") and al.strip() in REG_OF:
            written.add(REG_OF[al.strip()])
        # stack depth
        if op == "push":
            depth += 4 if al.strip().startswith("x") else 2
        elif op == "pushw":
            depth += 2
        elif op in ("pop",):
            depth -= 4 if al.strip().startswith("x") else 2
        elif op == "popw":
            depth -= 2
        m = re.match(r'lda\s+xsp\s*,\s*\(\s*xsp\s*([+-])\s*(0x[0-9a-f]+|\d+)', c, re.I)
        if m:
            depth -= int(m.group(2), 0) * (1 if m.group(1) == "+" else -1)
        m = re.match(r'(inc|dec)\s+(\d+)\s*,\s*xsp\b', c, re.I)
        if m:
            depth += int(m.group(2)) * (1 if m.group(1).lower() == "dec" else -1)
        m = re.match(r'(add|sub)\s+xsp\s*,\s*(0x[0-9a-f]+|\d+)', c, re.I)
        if m:
            depth += int(m.group(2), 0) * (1 if m.group(1).lower() == "sub" else -1)
        if op in ("jr", "jrl", "jp", "call", "calr", "ret", "retd", "reti", "djnz"):
            break
    # results
    results = []
    for n, (k, kind, c) in enumerate(code):
        if kind == "insn" and re.match(r'^(ret|reti|retd)\b', c, re.I):
            tail = []
            for k2, kind2, c2 in reversed(code[max(0, n - 6):n]):
                if kind2 == "insn":
                    op, args = operands(c2)
                    d = args.split(",")[0].strip().lower()
                    if d in ("xhl", "hl", "l", "xwa", "wa", "a") and op not in ("cp", "push", "pushw", "pop", "popw"):
                        tail.append(c2)
                        break
            results.append((k + 1, c, tail[0] if tail else "?"))
    ram = collections.Counter()
    calls, fncalls = collections.Counter(), collections.Counter()
    prev = []
    for k, kind, c in code:
        if kind != "insn":
            continue
        for t in re.findall(r'HDAE5000_RAM_\w+', c):
            ram[t] += 1
        for t in RAMNUM.findall(c):
            ram[t.lower()] += 1
        op, args = operands(c)
        if op in ("call", "calr"):
            t = args.split(",")[-1].strip()
            if t.startswith("("):
                fn = re.findall(r'(RootFn_\w+|HamaFn_\w+)', " ".join(prev[-4:]))
                fn = fn[-1:] if fn else fn
                fncalls[fn[0] if fn else "indirect " + t] += 1
            else:
                calls[t] += 1
        prev.append(c)
    callers = collections.Counter()
    for q, L in src.items():
        for k, x in enumerate(L):
            c = strip_comment(x)
            if re.search(r'\b(call|calr|jp|jr|jrl)\b[^;]*\b%s\b' % re.escape(name), c, re.I):
                callers[owner_of[(q, k)]] += 1
    return dict(file=os.path.relpath(p, ROOT), line=i + 1, length=len(body), entry_regs=read_first,
                stack_args=sorted(stackargs), results=results, ram=ram, calls=calls, fncalls=fncalls,
                callers=callers, body=body)


def main():
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    src = load()
    defs, owner_of = index(src)
    for name in a:
        if name not in defs:
            print("%s: not defined in hdae5000/*.s" % name)
            continue
        f = facts(src, defs, owner_of, name)
        print("== %s  (%s:%d, %d lines)" % (name, f["file"], f["line"], f["length"]))
        print("   callers  : %s" % ", ".join("%s x%d" % kv for kv in f["callers"].most_common()))
        print("   entry regs read first: %s" % (", ".join(f["entry_regs"]) or "-"))
        print("   stack args (entry xsp+K): %s" % (", ".join("+%d" % s for s in f["stack_args"]) or "-"))
        for ln, r, w in f["results"][:6]:
            print("   ret @%d   last result write: %s" % (ln, w))
        print("   RAM      : %s" % (", ".join("%s x%d" % kv for kv in f["ram"].most_common()) or "-"))
        print("   calls    : %s" % (", ".join("%s x%d" % kv for kv in f["calls"].most_common()) or "-"))
        print("   fn tables: %s" % (", ".join("%s x%d" % kv for kv in f["fncalls"].most_common()) or "-"))
        if "--code" in sys.argv:
            p, i = defs[name]
            print("%6d %s" % (i + 1, src[p][i]))
            for k, x in f["body"]:
                print("%6d %s" % (k + 1, x))


if __name__ == "__main__":
    main()
