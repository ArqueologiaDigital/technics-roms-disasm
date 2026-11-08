#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "where in program 941 do the func_<ADDR> routines sit with the most evidence around
# them (named callers, named callees, strings, named RAM and I/O), and what does one routine's
# evidence look like?"
#
# It reads a tree's GENERATED program source (kn7000/src/program/*.s for 941) and its label
# addresses (build/kn7000_program.labels, written by `make build/kn7000_program.rom`), splits the
# code into routines (a routine starts at a func_<ADDR> label or at a label no local pattern
# matches: loc_<ADDR>, .L*, X_entry and the annotation labels inside a routine), and records per
# routine its calls (call / calls / jmp / bra to another routine; X_entry counts as X), the
# routines it hands over as operands (mov Func, d0), the data labels it names (strings resolved
# from the data sources), and the named constants it uses (I/O registers, RAM names, ids).
#
#     python3 -I kn7000/notes/kn7000-subsystems-probes/routine_graph.py --clusters [--window 0x10000]
#     python3 -I kn7000/notes/kn7000-subsystems-probes/routine_graph.py --rank [--top N]
#     python3 -I kn7000/notes/kn7000-subsystems-probes/routine_graph.py --show ADDR|NAME [...]
#     python3 -I kn7000/notes/kn7000-subsystems-probes/routine_graph.py --count
#
# (run from the repository root; --src / --labels select another tree).
import argparse
import collections
import glob
import os
import re
import sys

PLACE = re.compile(r"^func_[0-9A-F]{8}$")
LOCAL = re.compile(r"^(loc_[0-9A-F]{8}|\.L\w*|rodata_[0-9A-F]+)$")
LABEL = re.compile(r"^([A-Za-z_.][\w.]*):")
IDENT = re.compile(r"\b([A-Za-z_][\w]*)\b")
STR = re.compile(rb'^(Str_\w+):\s*\.asci[iz]\s+"((?:[^"\\]|\\.)*)"')
REGS = set("d0 d1 d2 d3 a0 a1 a2 a3 sp psw mdr lir lar".split())
BRANCH = {"call", "calls", "jmp", "bra", "beq", "bne", "bcc", "bcs", "bge", "blt", "bgt", "ble",
          "bhi", "bls", "bvc", "bvs", "bnc", "bns"}


def base_name(n):
    if n.endswith("_entry"):
        return n[: -len("_entry")]
    return n


def load_labels(path):
    lab = {}
    for line in open(path, encoding="latin-1"):
        p = line.split()
        if len(p) == 2:
            try:
                lab[p[0]] = int(p[1], 16)
            except ValueError:
                pass
    return lab


def load_strings(data_glob):
    s = {}
    for f in glob.glob(data_glob):
        with open(f, "rb") as fh:
            for line in fh:
                m = STR.match(line)
                if m:
                    s[m.group(1).decode()] = m.group(2).decode("latin-1")
    return s


class Routine:
    __slots__ = ("name", "addr", "file", "lines", "calls", "jumps", "ptrs", "data", "consts",
                 "callers", "header")

    def __init__(self, name, addr, f):
        self.name, self.addr, self.file = name, addr, f
        self.lines, self.calls, self.jumps, self.ptrs = [], [], [], []
        self.data, self.consts, self.callers, self.header = [], [], [], []


def is_routine_label(n, routine_names):
    if PLACE.match(n):
        return True
    if LOCAL.match(n) or n.endswith("_entry"):
        return False
    return n in routine_names


def load_routine_names(sym_files):
    names = set()
    for f in sym_files:
        if not os.path.exists(f):
            continue
        for line in open(f, encoding="latin-1"):
            line = line.split(";", 1)[0].strip()
            p = line.split()
            if len(p) >= 2 and p[0].startswith("0x"):
                names.add(p[1])
    return names


def parse(src_glob, labels, routine_names):
    routines = collections.OrderedDict()
    cur = None
    pend_hdr = []
    for f in sorted(glob.glob(src_glob)):
        for raw in open(f, encoding="latin-1"):
            line = raw.rstrip("\n")
            if line.startswith("#"):
                pend_hdr.append(line)
                continue
            m = LABEL.match(line)
            if m:
                n = m.group(1)
                if is_routine_label(n, routine_names) and n in labels:
                    cur = Routine(n, labels[n], os.path.basename(f))
                    cur.header = pend_hdr
                    routines[n] = cur
                pend_hdr = []
                if cur is not None and not (cur.name == n):
                    cur.lines.append(line)
                continue
            pend_hdr = [] if line.strip() else pend_hdr
            if cur is None or not line.strip():
                continue
            cur.lines.append(line)
    return routines


def analyse(routines, labels, strings):
    rset = set(routines)
    # a code address -> routine (for jumps into another routine's locals)
    for r in routines.values():
        for line in r.lines:
            code = line.split("#", 1)[0].strip()
            if not code or code.endswith(":"):
                continue
            parts = code.split(None, 1)
            op = parts[0]
            ops = parts[1] if len(parts) > 1 else ""
            ids = [i for i in IDENT.findall(ops) if i not in REGS and not re.match(r"^0x", i)]
            for i in ids:
                b = base_name(i)
                if op in BRANCH and b in rset and b != r.name:
                    (r.calls if op in ("call", "calls") else r.jumps).append(b)
                elif b in rset and b != r.name:
                    r.ptrs.append(b)
                elif i in strings or i in labels and i.startswith(("Str_",)):
                    r.data.append(i)
                elif i in labels and not LOCAL.match(i):
                    r.data.append(i)
                elif not LOCAL.match(i):
                    r.consts.append(i)
    for r in routines.values():
        for c in set(r.calls + r.jumps + r.ptrs):
            routines[c].callers.append(r.name)


def evidence(r, routines, strings):
    named_callers = [c for c in set(r.callers) if not PLACE.match(c)]
    named_callees = [c for c in set(r.calls + r.jumps) if not PLACE.match(c)]
    strs = [d for d in set(r.data) if d in strings]
    named_data = [d for d in set(r.data) if not re.search(r"func_[0-9A-F]{8}|^(data|ram)_", d)]
    return named_callers, named_callees, strs, named_data


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default="kn7000/src/program/*.s")
    ap.add_argument("--data", default="kn7000/src/program/data/*.s")
    ap.add_argument("--labels", default="kn7000/build/kn7000_program.labels")
    ap.add_argument("--sym", nargs="*", default=["kn7000/kn7000.sym", "kn7000/kn7000_manual.sym",
                                                 "kn7000/kn7000_exports_from_942.sym"])
    ap.add_argument("--clusters", action="store_true")
    ap.add_argument("--window", type=lambda s: int(s, 0), default=0x10000)
    ap.add_argument("--rank", action="store_true")
    ap.add_argument("--top", type=int, default=60)
    ap.add_argument("--range", help="LO:HI address range for --rank / --list")
    ap.add_argument("--list", action="store_true", help="one line per func_ routine with its evidence")
    ap.add_argument("--show", nargs="*")
    ap.add_argument("--count", action="store_true")
    ap.add_argument("--pairs", nargs="*", default=["kn6000/notes/routine-map-kn7000.tsv",
                    "kn6500/notes/routine-map-kn7000.tsv", "kn2400/notes/routine-map-kn7000.tsv"],
                    help="the siblings' routine maps: --list / --rank show which siblings pair a func_ by call sites")
    a = ap.parse_args()

    labels = load_labels(a.labels)
    strings = load_strings(a.data)
    rnames = load_routine_names(a.sym)
    routines = parse(a.src, labels, rnames)
    analyse(routines, labels, strings)
    by_addr = {r.addr: r for r in routines.values()}

    pairs = collections.defaultdict(set)
    for f in a.pairs:
        if os.path.exists(f):
            model = f.split("/")[0]
            for line in open(f):
                p = line.rstrip("\n").split("\t")
                if len(p) >= 5 and not line.startswith("#"):
                    pairs[int(p[1], 16)].add(model.replace("kn", ""))

    lo, hi = 0, 1 << 32
    if a.range:
        lo, hi = (int(x, 16) for x in a.range.split(":"))

    if a.count:
        n = sum(1 for r in routines.values() if PLACE.match(r.name))
        print(f"routines {len(routines)}  func_ {n}  named {len(routines) - n}")
        return

    if a.clusters:
        w = collections.defaultdict(lambda: [0, 0, 0, 0, 0])
        for r in routines.values():
            k = r.addr // a.window * a.window
            if PLACE.match(r.name):
                nc, ne, s, nd = evidence(r, routines, a and strings)
                w[k][0] += 1
                w[k][2] += bool(nc)
                w[k][3] += bool(s)
                w[k][4] += bool(nc) + bool(ne) + bool(s) + bool(nd) >= 2
            else:
                w[k][1] += 1
        print(f"{'window':10s} {'func_':>6s} {'named':>6s} {'fn+ncaller':>10s} {'fn+str':>7s} {'fn+2ev':>7s}")
        for k in sorted(w):
            v = w[k]
            print(f"0x{k:08X} {v[0]:6d} {v[1]:6d} {v[2]:10d} {v[3]:7d} {v[4]:7d}")
        return

    if a.rank or a.list:
        rows = []
        for r in routines.values():
            if not PLACE.match(r.name) or not lo <= r.addr < hi:
                continue
            nc, ne, s, nd = evidence(r, routines, strings)
            score = 3 * len(s) + 2 * len(nc) + len(ne) + len(nd)
            rows.append((score, r, nc, ne, s, nd))
        if a.rank:
            rows.sort(key=lambda t: -t[0])
            rows = rows[: a.top]
        else:
            rows.sort(key=lambda t: t[1].addr)
        for score, r, nc, ne, s, nd in rows:
            ins = sum(1 for l in r.lines if not l.rstrip().endswith(":"))
            sv = "; ".join(repr(strings[x])[:40] for x in sorted(s))[:120]
            sib = ",".join(sorted(pairs.get(r.addr, ()))) or "-"
            print(f"0x{r.addr:08X} {r.name:15s} sib={sib:14s} ins={ins:4d} sc={score:3d} callers={len(set(r.callers))}"
                  f"({len(nc)}n) callees={len(set(r.calls + r.jumps))}({len(ne)}n) "
                  f"NC=[{','.join(sorted(nc))[:80]}] NE=[{','.join(sorted(ne))[:80]}] "
                  f"D=[{','.join(sorted(nd))[:80]}] S=[{sv}]")
        return

    if a.show:
        for q in a.show:
            r = routines.get(q)
            if r is None:
                try:
                    r = by_addr.get(int(q, 16))
                except ValueError:
                    r = None
            if r is None:
                print(f"?? {q}")
                continue
            print(f"==== {r.name}  0x{r.addr:08X}  ({r.file})")
            for h in r.header:
                print(h)
            cs = collections.Counter(r.callers)
            print(f"  callers ({len(cs)}): " + ", ".join(f"{c}" + (f"x{n}" if n > 1 else "")
                                                       for c, n in sorted(cs.items())))
            for line in r.lines:
                code = line.split("#", 1)[0]
                extra = ""
                for i in IDENT.findall(code):
                    if i in strings:
                        extra += f"   ; {i} = {strings[i]!r}"
                print(line + extra)
        return


if __name__ == "__main__":
    main()
