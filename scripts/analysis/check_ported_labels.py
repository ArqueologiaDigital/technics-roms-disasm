#!/usr/bin/env python3
r"""Do the labels a ported KN5000 main-program tree carried over still stand on their thing?

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py writes v6/maincpu from v7/maincpu (and
    v5 from v6), keeping the source tree's label names.  The byte gate proves the image,
    not the names: a label moved onto the wrong record, or a v7-only routine's label left
    sitting on unrelated code, assembles just as well.  For every label both builds
    define, does the target ROM hold, at the label's target address, the bytes the source
    ROM holds at its source address?

    Each label is read over L = min(12, distance to the next source label) bytes; labels
    with L < 4 are not judged.  A 32-bit or 24-bit little-endian value in those bytes that is
    the source address of a label both builds define is first replaced by that label's
    target address, so a record, a pointer table or an instruction is compared by what it
    points at.  A label is
      same       the L bytes are equal at the target address;
      misplaced  they are not, and they occur exactly once within 8 KB of the target
                 address -- somewhere else.  This is the signal of a wrong placement
                 (the review of 2026-10-24 counted 950 such labels in v6);
      changed    neither: the thing itself changed (rewritten operands, moved pointers
                 inside a record), which a port legitimately produces.
    "collapsed" counts labels whose distinct source addresses land on one target address
    (several v7 things named at one v6 place); "only-src" are source labels the target
    does not define (dropped by the porter), "only-dst" are new ones.

    A misplaced count is an upper bound on wrong placements: a short, repetitive item
    (a lone `ret`, a fill run) can also be found elsewhere.  Read the list.

RUN
    python3 scripts/analysis/check_ported_labels.py --src v7 --dst v6 [--list FILE]
    Needs both trees built (rebuilt_ROMs/kn5000_<tree>_program.llvm.{elf,rom}, `make all`).
    Exits 0; the counts are the answer.
"""
import argparse
import bisect
import collections
import os
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
BASE = 0xE00000
SIZE = 0x200000


def symbols(tree):
    """ROM-range symbols of the tree's ELF: name -> address"""
    elf = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % tree)
    out = subprocess.run([NM, "--defined-only", elf], capture_output=True, text=True, check=True).stdout
    syms = {}
    for line in out.splitlines():
        p = line.split()
        if len(p) == 3 and p[1] in "tT":       # labels; absolute .equ constants are not
            v = int(p[0], 16)
            if BASE <= v < BASE + SIZE:
                syms[p[2]] = v
    return syms


def rom(tree):
    return open(os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % tree), "rb").read()


def check(src, dst):
    ss, ds = symbols(src), symbols(dst)
    rs, rd = rom(src), rom(dst)
    addrs = sorted(set(ss.values()))
    # source address -> target address, by the labels both builds define (most common pairing)
    pair = collections.defaultdict(collections.Counter)
    for name in set(ss) & set(ds):
        pair[ss[name]][ds[name]] += 1
    move = {a: c.most_common(1)[0][0] for a, c in pair.items()}

    def translated(a, n):
        b = bytearray(rs[a:a + n])
        o = 0
        while o < n - 2:
            for w in (4, 3):
                if o + w <= n:
                    v = int.from_bytes(rs[a + o:a + o + w], "little")
                    if v in move and (w == 4 or rs[a + o + 2] >= 0xE0):
                        b[o:o + w] = move[v].to_bytes(w, "little")
                        o += w - 1
                        break
            o += 1
        return bytes(b)
    res = collections.Counter()
    rows = []
    for name in sorted(set(ss) & set(ds)):
        a, t = ss[name] - BASE, ds[name] - BASE
        k = bisect.bisect_right(addrs, ss[name])
        nxt = addrs[k] - BASE if k < len(addrs) else SIZE
        n = min(12, nxt - a)
        if n < 4:
            res["short"] += 1
            continue
        want = translated(a, n)
        if rd[t:t + n] == want:
            res["same"] += 1
            continue
        lo, hi = max(0, t - 8192), min(len(rd), t + 8192 + n)
        hits = []
        x = rd.find(want, lo, hi)
        while x != -1 and len(hits) < 2:
            hits.append(x)
            x = rd.find(want, x + 1, hi)
        if len(hits) == 1:
            res["misplaced"] += 1
            rows.append("misplaced %s %s 0x%06x %s 0x%06x  bytes found at 0x%06x (%+d)"
                        % (name, src, ss[name], dst, ds[name], BASE + hits[0], hits[0] - t))
        else:
            res["changed"] += 1
    by_t = collections.defaultdict(set)
    for name in set(ss) & set(ds):
        by_t[ds[name]].add(ss[name])
    collapsed = [name for name in set(ss) & set(ds) if len(by_t[ds[name]]) > 1]
    res["collapsed"] = len(collapsed)
    for name in sorted(collapsed, key=lambda x: (ds[x], ss[x])):
        rows.append("collapsed %s %s 0x%06x %s 0x%06x" % (name, src, ss[name], dst, ds[name]))
    res["only-src"] = len(set(ss) - set(ds))
    res["only-dst"] = len(set(ds) - set(ss))
    return res, rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default="v7")
    ap.add_argument("--dst", default="v6")
    ap.add_argument("--list", metavar="FILE", help="write every misplaced / collapsed label to FILE")
    a = ap.parse_args()
    res, rows = check(a.src, a.dst)
    print("%s -> %s labels: same %d, changed %d, misplaced %d, not judged (< 4 bytes) %d; "
          "collapsed %d; only in %s %d, only in %s %d"
          % (a.src, a.dst, res["same"], res["changed"], res["misplaced"], res["short"], res["collapsed"],
             a.src, res["only-src"], a.dst, res["only-dst"]))
    if a.list:
        with open(a.list, "w") as fh:
            fh.write("\n".join(rows) + "\n")


if __name__ == "__main__":
    main()
