#!/usr/bin/env python3
"""add_kn5000_ram_names.py -- give KN5000 main-CPU RAM variables names read from their uses, in v10, v9 and v7.

JOB IT DOES
  Takes a list of `0xADDR NAME ; why` lines (v10 addresses; the reasons come from reading the code, see
  scripts/analysis/kn5000_ram_evidence.py) and
    1. adds each as `.equ NAME, 0xADDR ; why` to v10/maincpu/shared/ram_variables_by_use.s (kept sorted by
       address), refusing a name that is already a symbol anywhere in the tree, or an address that already
       has a name in one of the constants files name_kn5000_ram.py reads;
    2. adds the same lines to v9's and v7's copy of that file (with v10's value, for the moment);
    3. runs scripts/tools/name_kn5000_ram.py --apply for v10, v9 and v7: v10's numeric operands take the
       names; for v9 and v7 the address of each name is DERIVED from the same instructions in the same
       routines (all votes must agree), the .equ is corrected to it, and their operands take the name;
    4. drops from v9's / v7's file every name this run added that the tree's code does not use after
       step 3 -- a name whose address could not be derived for that tree is left out rather than kept
       with v10's value (the convention of shared/ram_variables.s).
  The ROM bytes cannot change by construction (a number becomes a name of the same value); `make gate`
  checks it anyway.

USAGE
  make all
  python3 scripts/tools/add_kn5000_ram_names.py NAMES.txt [--dry-run]
"""
import argparse
import glob
import os
import re
import subprocess
import sys

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                      text=True).stdout.strip() or "."
TREES = ("v10", "v9", "v7")
FILE = "shared/ram_variables_by_use.s"
HEADER = """\
; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17), one
; line per variable, sorted by address.  Each comment says what the uses show: who writes it, with what,
; and how it is read (scripts/analysis/kn5000_ram_evidence.py prints that evidence for an address).
; Added by scripts/tools/add_kn5000_ram_names.py, which also rewrites the numeric operands.
"""
HEADER_OTHER = """\
; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17).
; The names and reasons are v10's (v10/maincpu/shared/ram_variables_by_use.s); the values here are
; %s's own, derived by scripts/tools/name_kn5000_ram.py from the same instructions in the same routines
; (a corrected line says so).  Names it could not derive for %s are left out.
"""
LINE = re.compile(r'^\s*(0x[0-9a-fA-F]+)\s+([A-Za-z_]\w*)\s*(?:;\s*(.*))?$')
EQU = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)')


def path(t):
    return os.path.join(REPO, t, "maincpu", FILE)


def read(f):
    return open(f, "rb").read().decode("latin-1").split("\n") if os.path.exists(f) else []


def write(f, L):
    open(f, "wb").write("\n".join(L).encode("latin-1"))


def symbols(t):
    """every name defined in the tree: labels and .equ / .set"""
    out = set()
    for f in glob.glob(os.path.join(REPO, t, "maincpu", "**", "*.s"), recursive=True):
        for l in read(f):
            m = re.match(r'^([A-Za-z_][\w$]*):', l) or re.match(r'^\s*\.(?:equ|set)\s+([A-Za-z_]\w*)', l)
            if m:
                out.add(m.group(1))
    return out


def named_addresses(t):
    sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
    import name_kn5000_ram as N
    return {v: n for n, v in N.ram_names(t).items()}


EQU_FULL = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;\s?(.*))?$')


def aligned(rows):
    """`.equ` lines for (name, value, comment) rows, values tab-aligned to one column (the next tab stop
    after the longest `\t.equ NAME,`), comments one tab after the value"""
    target = max(8 + 5 + len(n) + 1 for n, _, _ in rows) // 8 * 8 + 8
    out = []
    for n, v, c in rows:
        cur = 8 + 5 + len(n) + 1          # the column after `\t.equ NAME,`
        tabs = 1 + (target - (cur // 8 + 1) * 8) // 8
        out.append("\t.equ %s,%s0x%04x%s" % (n, "\t" * tabs, v, ("\t; " + c) if c else ""))
    return out


def merge(t, new, header):
    """insert the new (value, name, why) lines into tree t's file, sorted by value and realigned; return
    the names added"""
    rows = []
    for l in read(path(t)):
        m = EQU_FULL.match(l)
        if m:
            rows.append((m.group(1), int(m.group(2), 0), (m.group(3) or "").rstrip()))
    have = {n for n, _, _ in rows}
    added = []
    for v, n, why in new:
        if n not in have:
            rows.append((n, v, why))
            added.append(n)
    rows.sort(key=lambda r: r[1])
    write(path(t), header.rstrip("\n").split("\n") + aligned(rows) + [""])
    return added


def realign(t):
    """realign a tree's file after name_kn5000_ram.py corrected values in it"""
    L = read(path(t))
    head = [l for l in L if l.startswith(";")]
    rows = [(m.group(1), int(m.group(2), 0), (m.group(3) or "").rstrip()) for m in map(EQU_FULL.match, L) if m]
    write(path(t), head + aligned(sorted(rows, key=lambda r: r[1])) + [""])


def ensure_include(t):
    rv = os.path.join(REPO, t, "maincpu", "shared", "ram_variables.s")
    L = read(rv)
    inc = '\t.include "shared/ram_variables_by_use.s"'
    if inc not in L:
        while L and L[-1] == "":
            L.pop()
        L += ["; variables named from their uses (audit WP17): one file, so that the naming lane owns it", inc, ""]
        write(rv, L)


def used_names(t, names):
    pat = re.compile(r'\b(%s)\b' % "|".join(map(re.escape, names))) if names else None
    used = set()
    if not pat:
        return used
    for f in glob.glob(os.path.join(REPO, t, "maincpu", "**", "*.s"), recursive=True):
        if f == path(t):
            continue
        for l in read(f):
            code = l.split(";")[0]
            if code.lstrip().startswith(".equ"):
                continue
            used |= set(pat.findall(code))
    return used


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("names")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    new, bad = [], []
    syms = symbols("v10")
    named = named_addresses("v10")
    seen_n, seen_v = set(), set()
    for l in open(a.names):
        if not l.strip() or l.lstrip().startswith("#"):
            continue
        m = LINE.match(l.rstrip("\n"))
        if not m:
            bad.append("unparsed: " + l.strip())
            continue
        v, n, why = int(m.group(1), 16), m.group(2), (m.group(3) or "").strip()
        if n in seen_n or v in seen_v:
            bad.append("duplicate in list: %s 0x%x" % (n, v))
        seen_n.add(n)
        seen_v.add(v)
        if v in named and named[v] != n:
            bad.append("0x%x is already %s" % (v, named[v]))
            continue
        if v in named:
            continue
        if n in syms:
            bad.append("%s is already a symbol of the tree" % n)
            continue
        if not (0x400 <= v < 0x100000):
            bad.append("0x%x is outside the RAM range name_kn5000_ram.py handles" % v)
            continue
        new.append((v, n, why))
    for b in bad:
        print("REFUSED", b)
    if bad:
        return 1
    print("%d new names" % len(new))
    if a.dry_run:
        return 0
    added = {}
    for t in TREES:
        ensure_include(t)
        added[t] = merge(t, new, HEADER if t == "v10" else HEADER_OTHER % (t, t))
    for t in TREES:
        r = subprocess.run([sys.executable, os.path.join(REPO, "scripts", "tools", "name_kn5000_ram.py"),
                            "--tree", t, "--apply"], capture_output=True, text=True, cwd=REPO)
        print(r.stdout.rstrip())
        if r.returncode:
            print(r.stderr)
            return 1
    for t in ("v9", "v7"):
        if not added[t]:
            continue
        used = used_names(t, added[t])
        drop = [n for n in added[t] if n not in used]
        if drop:
            L = [l for l in read(path(t)) if not (EQU.match(l) and EQU.match(l).group(1) in drop)]
            write(path(t), L)
        print("%s: %d of the %d names added are used, %d left out: %s" % (
            t, len(added[t]) - len(drop), len(added[t]), len(drop), " ".join(drop)))
    for t in TREES:
        realign(t)
    return 0


if __name__ == "__main__":
    sys.exit(main())
