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
       with v10's value (the convention of shared/ram_variables.s); a name that lies inside a record the
       tree has is kept at the same offset in that record instead (its operands there are RECORD+k already);
    5. for a name whose reason starts with `[N bytes]` -- a record or array the code shows to be N bytes
       long -- spells every numeric memory operand inside it that has no name of its own as NAME+offset
       (decimal), in each tree where the name exists, from that tree's own value of it.  A record that
       step 4 left out of v9 / v7 (no instruction uses its first byte) gets its address there from the
       uses of its fields instead: v10's NAME+k against the other tree's number n, in the same
       instruction of the same routine, votes for n - k, and all votes must agree.
  The ROM bytes cannot change by construction (a number becomes a name of the same value); `make gate`
  checks it anyway.

USAGE
  make all
  python3 scripts/tools/add_kn5000_ram_names.py NAMES.txt [--dry-run]
  python3 scripts/tools/add_kn5000_ram_names.py --realign      # realign the three files, hex in lowercase
"""
import argparse
import collections
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


def N_names(t):
    sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
    import name_kn5000_ram as N
    return N.ram_names(t)


def named_addresses(t):
    sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
    import name_kn5000_ram as N
    return {v: n for n, v in N.ram_names(t).items()}


EQU_FULL = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;\s?(.*))?$')


HEX = re.compile(r'\b0x[0-9a-fA-F]+\b')


def lower_hex(c):
    """a comment with every 0x literal in lowercase (cross-version policy 2); a reason is copied from
    the input list verbatim, so it is normalised here (`NAKA_TYPE_0x5D`-style names are untouched: no
    word boundary before their 0x)"""
    return HEX.sub(lambda m: m.group(0).lower(), c)


def aligned(rows):
    """`.equ` lines for (name, value, comment) rows, values tab-aligned to one column (the next tab stop
    after the longest `\t.equ NAME,`), comments one tab after the value, hex in lowercase"""
    target = max(8 + 5 + len(n) + 1 for n, _, _ in rows) // 8 * 8 + 8
    out = []
    for n, v, c in rows:
        cur = 8 + 5 + len(n) + 1          # the column after `\t.equ NAME,`
        tabs = 1 + (target - (cur // 8 + 1) * 8) // 8
        out.append("\t.equ %s,%s0x%04x%s" % (n, "\t" * tabs, v, ("\t; " + lower_hex(c)) if c else ""))
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
    head = [lower_hex(l) for l in L if l.startswith(";")]
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


SIZE = re.compile(r'^\[(0x[0-9a-fA-F]+|\d+) bytes\]')
MEMOP = re.compile(r'\((0x[0-9a-fA-F]+|\d+)(:8|:16|:24)?\)')
MMOP = re.compile(r'^(\s*ldmm(?:8|16)\s+)(0x[0-9a-fA-F]+|\d+)(\s*,\s*)(0x[0-9a-fA-F]+|\d+)(\s*)$', re.I)


def spell_structs(t):
    """step 5: operands inside a sized record become RECORD+offset; returns the count"""
    spans = []
    for l in read(path(t)):
        m = EQU_FULL.match(l)
        if m and m.group(3):
            z = SIZE.match(m.group(3))
            if z:
                spans.append((int(m.group(2), 0), int(m.group(2), 0) + int(z.group(1), 0), m.group(1)))
    spans.sort()
    for i, (s0, e0, n0) in enumerate(spans):
        for s1, e1, n1 in spans[i + 1:]:
            # a record may hold another (the song record holds the track table), never half of one
            assert s1 >= e0 or e1 <= e0, "%s and %s overlap" % (n0, n1)
    if not spans:
        return 0
    exact = set(named_addresses(t))

    def spell(v):
        if v in exact:
            return None
        inner = [(e0 - s0, s0, n0) for s0, e0, n0 in spans if s0 < v < e0]
        if inner:
            _, s0, n0 = min(inner)
            return "%s+%d" % (n0, v - s0)
        return None

    count = 0
    exact_name = {v: n for n, v in N_names(t).items()}
    base_of = {n0: s0 for s0, e0, n0 in spans}
    size_of = {n0: e0 - s0 for s0, e0, n0 in spans}
    recref = re.compile(r'\b(%s)\+(\d+)\b' % "|".join(map(re.escape, base_of)))

    def to_exact(m):
        """a REC+k written earlier whose address has since got a name of its own takes that name.
        Only a k INSIDE the record (k < its size) is a field; REC+size and beyond were written on purpose,
        as an end-of-array bound (`cp xhl, ACC_BASS_NOTES+72`, wave 10), and are left alone even though
        the next record starts there -- so a rerun of this tool is a no-op on them."""
        k = int(m.group(2))
        if k >= size_of[m.group(1)]:
            return m.group(0)
        v = base_of[m.group(1)] + k
        if v in exact_name:
            hit[0] += 1
            return exact_name[v]
        return m.group(0)

    for f in glob.glob(os.path.join(REPO, t, "maincpu", "**", "*.s"), recursive=True):
        L = read(f)
        ch = False
        for i, l in enumerate(L):
            code, sep, cmt = l.partition(";")
            st = code.strip()
            if not st or st.startswith("."):
                continue
            hit = [0]
            code = recref.sub(to_exact, code)

            def mem(m):
                x = spell(int(m.group(1), 0))
                if x:
                    hit[0] += 1
                    return "(%s%s)" % (x, m.group(2) or "")
                return m.group(0)

            new = MEMOP.sub(mem, code)
            q = MMOP.match(new)
            if q:
                x, y = spell(int(q.group(2), 0)), spell(int(q.group(4), 0))
                hit[0] += bool(x) + bool(y)
                new = q.group(1) + (x or q.group(2)) + q.group(3) + (y or q.group(4)) + q.group(5)
            if new != l.partition(";")[0]:
                L[i] = new + sep + cmt
                count += hit[0]
                ch = True
        if ch:
            write(f, L)
    return count


MEMTOK = re.compile(r'\(([A-Za-z_]\w*\+\d+|[A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(?::8|:16|:24)?\)')


def derive_records(t):
    """the v10 records ([N bytes]) missing from tree t, placed by the uses of their fields; returns the
    (name, value, reason) rows added to t's file"""
    v10rows = [(m.group(1), int(m.group(2), 0), (m.group(3) or "").rstrip())
               for m in map(EQU_FULL.match, read(path("v10"))) if m]
    have = {m.group(1) for m in map(EQU_FULL.match, read(path(t))) if m}
    records = {n: (v, int(SIZE.match(c).group(1), 0), c) for n, v, c in v10rows
               if c and SIZE.match(c) and n not in have}
    if not records:
        return []
    sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
    import name_kn5000_ram as N
    names10 = N.ram_names("v10")
    alt = re.compile(r'\b(%s)\b' % "|".join(map(re.escape, sorted(names10, key=len, reverse=True))))

    def shape(code):
        """the instruction with every number, RAM name and NAME+k blanked (registers are lower case)"""
        code = re.sub(r'\b[A-Z_][A-Z0-9_]*\+\d+\b', '#', code)
        code = alt.sub('#', code).lower()
        return re.sub(r'\s+', ' ', re.sub(r'(0x[0-9a-f]+|\b\d+\b)', '#', code))

    def value(tok):
        if '+' in tok:
            n, k = tok.split('+')
            return (n, int(k)) if n in records else None
        return None

    votes = collections.defaultdict(collections.Counter)
    B10, BT = N.bodies("v10"), N.bodies(t)
    for lab, (f, body) in B10.items():
        if lab not in BT or len(BT[lab][1]) != len(body):
            continue
        other = BT[lab][1]
        if any(shape(x[1]) != shape(y[1]) for x, y in zip(body, other)):
            continue
        for (_, c10), (_, ct) in zip(body, other):
            t10, tt = MEMTOK.findall(c10), MEMTOK.findall(ct)
            if len(t10) != len(tt):
                continue
            for x, y in zip(t10, tt):
                nk = value(x)
                if nk and re.match(r'^(0x[0-9a-fA-F]+|\d+)$', y):
                    votes[nk[0]][int(y, 0) - nk[1]] += 1
    out = []
    for n, (v, size, why) in records.items():
        if len(votes[n]) == 1:
            base = next(iter(votes[n]))
            note = "" if base == v else "\t; %s address, derived from the uses of its fields (add_kn5000_ram_names.py); v10 has 0x%x" % (t, v)
            out.append((n, base, why + note))
    if out:
        rows = [(m.group(1), int(m.group(2), 0), (m.group(3) or "").rstrip()) for m in map(EQU_FULL.match, read(path(t))) if m]
        head = [l for l in read(path(t)) if l.startswith(";")]
        write(path(t), head + aligned(sorted(rows + out, key=lambda r: r[1])) + [""])
    return out


def place_record_fields(t, names):
    """names of fields inside a v10 record that tree t also has: their address in t is t's record base plus
    the same offset (a record's layout does not move inside it).  Rewrites their lines in t's file and
    returns the names placed; spell_structs then respells t's RECORD+k operands with them."""
    rows10 = {m.group(1): (int(m.group(2), 0), (m.group(3) or "").rstrip())
              for m in map(EQU_FULL.match, read(path("v10"))) if m}
    rowst = {m.group(1): int(m.group(2), 0) for m in map(EQU_FULL.match, read(path(t))) if m}
    recs = [(v, v + int(SIZE.match(c).group(1), 0), n) for n, (v, c) in rows10.items()
            if c and SIZE.match(c) and n in rowst]
    placed = {}
    for n in names:
        v = rows10[n][0]
        inner = sorted((e0 - s0, s0, n0) for s0, e0, n0 in recs if s0 < v < e0 and n0 != n)
        if inner:
            _, s0, n0 = inner[0]
            placed[n] = rowst[n0] + (v - s0)
    if placed:
        L = read(path(t))
        for i, l in enumerate(L):
            m = EQU_FULL.match(l)
            if m and m.group(1) in placed:
                n, why = m.group(1), (m.group(3) or "").rstrip()
                if placed[n] != rows10[n][0]:
                    why += "\t; %s address: the same offset in its record (add_kn5000_ram_names.py); v10 has 0x%x" % (t, rows10[n][0])
                L[i] = "\t.equ %s, 0x%04x\t; %s" % (n, placed[n], why)
        write(path(t), L)
    return set(placed)


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
    ap.add_argument("names", nargs="?")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--realign", action="store_true",
                    help="only realign the three ram_variables_by_use.s files (and lowercase their hex)")
    a = ap.parse_args()
    if a.realign:
        for t in TREES:
            realign(t)
        return 0
    if not a.names:
        ap.error("NAMES.txt is required unless --realign is given")
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
        if 0xF9A0 <= v < 0xFFBE:
            bad.append("0x%x is inside the panel records (name_kn5000_panel_records.py spells it RECORD+N)" % v)
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
        kept = place_record_fields(t, drop)
        drop = [n for n in drop if n not in kept]
        if drop:
            L = [l for l in read(path(t)) if not (EQU.match(l) and EQU.match(l).group(1) in drop)]
            write(path(t), L)
        print("%s: %d of the %d names added are used, %d left out: %s" % (
            t, len(added[t]) - len(drop), len(added[t]), len(drop), " ".join(drop)))
    for t in ("v9", "v7"):
        for n, v, why in derive_records(t):
            print("%s: record %s at 0x%x, derived from the uses of its fields" % (t, n, v))
    for t in TREES:
        realign(t)
        n = spell_structs(t)
        if n:
            print("%s: %d operands inside sized records spelled RECORD+offset" % (t, n))
    return 0


if __name__ == "__main__":
    sys.exit(main())
