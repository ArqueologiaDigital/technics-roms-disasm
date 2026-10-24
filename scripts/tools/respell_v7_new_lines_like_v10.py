#!/usr/bin/env python3
r"""Respell the v7 instruction lines one commit added so that they read like v10's.

QUESTION ANSWERED
    The converters of lane v7-harmonize (scripts/converters/v7_byte_region_to_insns.py,
    reframe_byte_runs_by_decode.py, reframe_v7_runs_crosscheck_v10.py) copy llvm-objdump's spelling:
    decimal RAM operands and masks (`and (13690:16), 254`), decimal 32-bit constants
    (`ld xde, 4294901762`), the `call_24 cc, (X)` pseudo, and a space after the mnemonic.  Where v10
    writes the same instructions, that is cross-version diff noise.  This script rewrites only the lines
    `git blame` attributes to --commit (default d89e64558, the lane's re-framing commit), and only
    their spelling: every rewrite keeps each number's value, so the build stays byte-identical
    (`make gate` proves it).

RULES, per line
    1. Tab after the mnemonic (`\tpush qiz` -> `\tpush\tqiz`).
    2. `call_24 cc, (X)` -> `call cc, (X:24)` (the spelling v10 uses for the same encoding).
    3. V10 MATCH.  The enclosing v7 label is looked up in v10/maincpu; the two label blocks' instruction
       lines are aligned on their number-masked text (difflib, equal runs only).  For an aligned line each
       number equal to the v10 number in the same position takes v10's token verbatim; a number that
       differs (RAM operands moved between the versions) keeps v7's value in v10's notation (hex or
       decimal).
    4. FALLBACK, for lines with no v10 counterpart: an absolute memory operand `(N)`, `(N:16)`,
       `(N:24)` of 256 or more, the immediate of and/or/xor of 10 or more, and a 32-bit register load
       `ld xrr, N` of 256 or more are written in lowercase hex (CLAUDE.md: hex for addresses, bitmasks
       and large constants).  Everything else is left as it is.

    --space-count REV (or `worktree`) only measures: how many v7 instruction lines are written
    `mnemonic<space>operand` (the form the tab rule forbids) at that revision.

RUN
    python3 scripts/tools/respell_v7_new_lines_like_v10.py --space-count 79e035417
    python3 scripts/tools/respell_v7_new_lines_like_v10.py [--commit d89e64558]          # dry run: counts
    python3 scripts/tools/respell_v7_new_lines_like_v10.py --apply [--show]
    make -j3 gate KN5000_V8_REF=...                                                      # must stay IDENTICAL
"""
import argparse
import collections
import difflib
import glob
import os
import re
import subprocess

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')
INSN = re.compile(r'^\t([a-z_][a-z0-9_]*)([ \t]+)(\S.*)?$')
NUM = re.compile(r'(?<![\w.:$])(-?)(0x[0-9a-fA-F]+|\d+)\b(?!:i3|:opc)')
CALL24 = re.compile(r'^call_24\t((?:[a-z]+, )?)\(([A-Za-z_.$][\w.$]*)\)$')
MEM = re.compile(r'(?<![\w+\-])\((0x[0-9a-fA-F]+|\d+)(:16|:24|)\)')
LOGIC = re.compile(r'^(and|or|xor)w?$')
LDX = re.compile(r'^ld\tx(wa|bc|de|hl|ix|iy|iz|sp), (\d+)$')


def split_code(line):
    """-> (code, comment) for an instruction line; the comment keeps its leading whitespace."""
    i = line.find(";")
    if i < 0:
        return line.rstrip(), line[len(line.rstrip()):]
    code = line[:i].rstrip()
    return code, line[len(code):]


def skeleton(code):
    return " ".join(NUM.sub("#", code).split())


def hexs(v):
    return "0x%x" % v


def blamed_lines(commit, rel):
    out = subprocess.run(["git", "-C", REPO, "blame", "-l", "-s", "HEAD", "--", rel], capture_output=True,
                         check=True).stdout.decode("latin-1")
    full = subprocess.run(["git", "-C", REPO, "rev-parse", commit], capture_output=True, text=True,
                          check=True).stdout.strip()
    keep = set()
    for ln in out.split("\n"):
        m = re.match(r'^\^?([0-9a-f]{40})\s+(\d+)\)', ln)
        if m and m.group(1) == full:
            keep.add(int(m.group(2)) - 1)
    return keep


def blocks(lines):
    """-> {label: (start, end)} for column-0 labels (end exclusive: next column-0 label)."""
    starts = [(i, LABEL.match(l).group(1)) for i, l in enumerate(lines) if LABEL.match(l)]
    res = {}
    for k, (i, name) in enumerate(starts):
        res[name] = (i, starts[k + 1][0] if k + 1 < len(starts) else len(lines))
    return res


def code_lines(lines, a, b):
    """-> [(index, code)] of the instruction lines in lines[a:b] (the label line itself skipped)."""
    res = []
    for i in range(a + 1, b):
        m = INSN.match(lines[i])
        if not m or lines[i].lstrip().startswith(";"):
            continue
        res.append((i, split_code(lines[i])[0]))
    return res


def norm_tab(code):
    m = INSN.match(code)
    if m and m.group(3) is not None:
        return "\t%s\t%s" % (m.group(1), m.group(3))
    return code


def copy_notation(v7code, v10code):
    t10 = list(NUM.finditer(v10code))
    t7 = list(NUM.finditer(v7code))
    if len(t10) != len(t7):
        return v7code
    out, pos = [], 0
    for a, b in zip(t7, t10):
        out.append(v7code[pos:a.start()])
        tok = a.group(0)
        if not a.group(1) and not b.group(1):
            v = int(a.group(2), 0)
            hex10 = b.group(2).lower().startswith("0x")
            if v == int(b.group(2), 0):
                tok = b.group(2)                 # same value: v10's token verbatim (keeps 0x00)
            elif hex10 != a.group(2).lower().startswith("0x"):
                tok = hexs(v) if hex10 else str(v)
        out.append(tok)
        pos = a.end()
    out.append(v7code[pos:])
    return "".join(out)


def fallback(code):
    m = INSN.match(code)
    if not m or m.group(3) is None:
        return code
    mn, ops = m.group(1), m.group(3)
    ops = MEM.sub(lambda mm: "(%s%s)" % (hexs(int(mm.group(1), 0)) if int(mm.group(1), 0) >= 256
                                         else mm.group(1), mm.group(2)), ops)
    if LOGIC.match(mn):
        ops = re.sub(r', (\d+)$', lambda mm: ", " + (hexs(int(mm.group(1))) if int(mm.group(1)) >= 10
                                                     else mm.group(1)), ops)
    new = "\t%s\t%s" % (mn, ops)
    lx = LDX.match(new.lstrip("\t"))
    if lx and int(lx.group(2)) >= 256:
        new = "\tld\tx%s, %s" % (lx.group(1), hexs(int(lx.group(2))))
    return new


SPACE_FORM = re.compile(rb'^\t[a-z_][a-z0-9_]* [^ ;]', re.M)


def space_count(rev):
    n = 0
    if rev == "worktree":
        for f in glob.glob(os.path.join(REPO, "v7", "**", "*.s"), recursive=True):
            n += len(SPACE_FORM.findall(open(f, "rb").read()))
        return n
    names = subprocess.run(["git", "-C", REPO, "ls-tree", "-r", "--name-only", rev, "v7"], capture_output=True,
                           text=True, check=True).stdout.split()
    for f in names:
        if f.endswith(".s"):
            n += len(SPACE_FORM.findall(subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (rev, f)],
                                                       capture_output=True, check=True).stdout))
    return n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--commit", default="d89e64558")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--show", action="store_true", help="print every changed line")
    ap.add_argument("--space-count", metavar="REV", help="only count v7 `mnemonic<space>operand` lines")
    a = ap.parse_args()
    if a.space_count:
        print("v7 mnemonic<space>operand lines at %s: %d" % (a.space_count, space_count(a.space_count)))
        return
    files = subprocess.run(["git", "-C", REPO, "show", "--name-only", "--format=", a.commit, "--", "v7/*.s"],
                           capture_output=True, text=True, check=True).stdout.split()
    files = [f for f in files if os.path.exists(os.path.join(REPO, f))]
    v10 = {}
    for f in sorted(glob.glob(os.path.join(REPO, "v10", "maincpu", "**", "*.s"), recursive=True)):
        L = open(f, "rb").read().decode("latin-1").split("\n")
        for name, span in blocks(L).items():
            v10.setdefault(name, (L, span))
    st = collections.Counter()
    for rel in files:
        p = os.path.join(REPO, rel)
        L = open(p, "rb").read().decode("latin-1").split("\n")
        mine = blamed_lines(a.commit, rel)
        bl = blocks(L)
        owner = {}
        for name, (s, e) in bl.items():
            for i in range(s, e):
                owner[i] = name
        new = {}
        for i in sorted(mine):
            if not INSN.match(L[i]) or L[i].lstrip().startswith(";"):
                continue
            code, comment = split_code(L[i])
            c = norm_tab(code)
            m = CALL24.match(c.lstrip("\t"))
            if m:
                c = "\tcall\t%s(%s:24)" % (m.group(1), m.group(2))
                st["call_24"] += 1
            new[i] = [c, comment, None]
        # v10 match per enclosing block
        for name in sorted({owner[i] for i in new if i in owner}):
            if name not in v10:
                continue
            L10, (s10, e10) = v10[name]
            s7, e7 = bl[name]
            c7 = [(i, new[i][0] if i in new else norm_tab(code)) for i, code in code_lines(L, s7, e7)]
            c10 = [(i, norm_tab(code)) for i, code in code_lines(L10, s10, e10)]
            sm = difflib.SequenceMatcher(None, [skeleton(c) for _, c in c7], [skeleton(c) for _, c in c10],
                                         autojunk=False)
            for tag, i1, i2, j1, j2 in sm.get_opcodes():
                if tag != "equal":
                    continue
                for k in range(i2 - i1):
                    i7 = c7[i1 + k][0]
                    if i7 in new:
                        new[i7][2] = c10[j1 + k][1]
        for i, (c, comment, ref) in new.items():
            if ref is not None:
                c2 = copy_notation(c, ref)
                st["v10-match"] += 1
            else:
                c2 = fallback(c)
                st["fallback"] += 1
            line = c2 + comment
            if line != L[i]:
                st["changed"] += 1
                if a.show:
                    print("%s:%d\n  - %s\n  + %s" % (rel, i + 1, L[i].strip(), line.strip()))
                L[i] = line
        if a.apply:
            data = "\n".join(L).encode("latin-1")
            if data != open(p, "rb").read():
                with open(p + ".tmp", "wb") as fh:
                    fh.write(data)
                os.replace(p + ".tmp", p)
    print("%s lines: %s%s" % (a.commit, dict(st), "" if a.apply else " (dry run)"))


if __name__ == "__main__":
    main()
