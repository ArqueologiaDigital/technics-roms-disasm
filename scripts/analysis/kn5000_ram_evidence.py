#!/usr/bin/env python3
"""kn5000_ram_evidence.py -- a reading dossier for each still-numeric KN5000 main-CPU RAM address.

QUESTION THIS ANSWERS
  What does the code do with RAM address A, so that a reviewer can give it a name it can defend?
  kn5000_ram_candidates.py ranks the addresses; this prints, per address, everything a name could rest
  on, read from the v10 tree (or --tree):
    * the access width each use implies (the register or the w/b/l suffix: byte / word / long),
    * the stores grouped by stored value, with the routines (nearest label that is not a _Skip / _Loop
      ... join label) that store it,
    * the other uses grouped by instruction shape, with their routines,
    * the routine labels and header lines (the `;` block right above the label) of up to --ctx routines,
      with two lines of code around each use,
    * comments anywhere in the tree that quote the address (0x2972, 0x02972, 2972h, decimal 10610 in an
      operand ...), and technics-docs pages that do,
    * the numeric neighbours A-8 .. A+8 still in use, a hint that A is a field of a larger record.
  Evidence only: it names nothing.  The names given from it are in shared/ram_variables.s.

USAGE
  python3 scripts/analysis/kn5000_ram_evidence.py [--tree v10] [--ctx 6] 0x2972 0x10fd ...
  python3 scripts/analysis/kn5000_ram_evidence.py --top 20 [--skip 40]   # the busiest numeric addresses
"""
import argparse
import collections
import glob
import os
import re
import subprocess

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                      text=True).stdout.strip() or "."
DOCS = os.path.join(os.path.dirname(os.path.realpath(REPO)), "technics-docs")
if not os.path.isdir(DOCS):
    DOCS = "/home/fsanches/compartilhado/technics-docs"
MEM = re.compile(r'\((0x[0-9a-fA-F]+|\d+)(:8|:16|:24)?\)')
COL0 = re.compile(r'^([A-Za-z_][\w$]*):')
JOIN = re.compile(r'_(Skip|Join|Loop|Return|Exit|Done|Next|Ret|Cont|Continue|End)\d*$')
R8 = {"a", "w", "b", "c", "d", "e", "h", "l", "qa", "qw", "qb", "qc", "qd", "qe", "qh", "ql"}
R16 = {"wa", "bc", "de", "hl", "ix", "iy", "iz", "sp", "qwa", "qbc", "qde", "qhl", "qix", "qiy", "qiz"}
R32 = {"xwa", "xbc", "xde", "xhl", "xix", "xiy", "xiz", "xsp"}


def width(code):
    m = re.match(r'^(\w+)\s*(.*)$', code)
    if not m:
        return "?"
    mn, ops = m.group(1).lower(), m.group(2)
    if mn.startswith("lda") or mn in ("call", "jp", "jr", "jrl", "calr"):
        return "addr"
    regs = [o.strip().lower() for o in re.split(r',', re.sub(r'\([^)]*\)', 'M', ops))]
    for r in regs:
        if r in R32:
            return "L"
        if r in R16:
            return "W"
        if r in R8:
            return "B"
    if mn.endswith("w") or mn in ("ldw", "cpw", "incw", "decw", "ldmw", "pushw", "popw"):
        return "W"
    if mn.endswith("l"):
        return "L"
    if mn in ("bit", "set", "res", "chg", "tset", "ldmm8", "inc", "dec", "cp", "ld", "and", "or", "xor"):
        return "B"
    return "?"


class Tree:
    def __init__(self, tree):
        self.lines = []          # (file, idx, routine, code, raw)
        self.headers = {}        # routine -> header comment lines
        self.files = {}
        for f in sorted(glob.glob(os.path.join(REPO, tree, "maincpu", "**", "*.s"), recursive=True)):
            L = open(f, "rb").read().decode("latin-1").split("\n")
            self.files[f] = L
            cur = "?"
            for i, l in enumerate(L):
                m = COL0.match(l)
                if m:
                    if not JOIN.search(m.group(1)):
                        cur = m.group(1)
                        h, j = [], i - 1
                        while j >= 0 and L[j].lstrip().startswith(";") and len(h) < 12:
                            h.insert(0, L[j].strip())
                            j -= 1
                        self.headers.setdefault(cur, h)
                    continue
                code = re.sub(r'\s+', ' ', l.split(";")[0]).strip()
                self.lines.append((f, i, cur, code, l))

    def uses(self):
        out = collections.defaultdict(list)
        for k, (f, i, cur, code, raw) in enumerate(self.lines):
            if not code or code.startswith("."):
                continue
            for g in MEM.finditer(code):
                v = int(g.group(1), 0)
                if 0x400 <= v < 0x100000:
                    out[v].append(k)
        return out


def spellings(a):
    return [r'0x0*%x\b' % a, r'\b0*%X[hH]\b' % a, r'\$0*%x\b' % a]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", default="v10")
    ap.add_argument("--ctx", type=int, default=6)
    ap.add_argument("--top", type=int, default=0)
    ap.add_argument("--skip", type=int, default=0)
    ap.add_argument("--no-docs", action="store_true")
    ap.add_argument("addrs", nargs="*")
    a = ap.parse_args()
    T = Tree(a.tree)
    U = T.uses()
    addrs = [int(x, 16) for x in a.addrs]
    if a.top:
        addrs += [v for v, _ in sorted(U.items(), key=lambda kv: -len(kv[1]))[a.skip:a.skip + a.top]]
    docs = {}
    if not a.no_docs and os.path.isdir(DOCS):
        for f in glob.glob(os.path.join(DOCS, "*.md")):
            docs[os.path.basename(f)] = open(f, "rb").read().decode("utf-8", "replace").split("\n")
    for A in addrs:
        ks = U.get(A, [])
        print("=" * 100)
        wc = collections.Counter(width(T.lines[k][3]) for k in ks)
        print("0x%05x  %d numeric uses  widths %s" % (A, len(ks), dict(wc)))
        stores, other = collections.defaultdict(set), collections.defaultdict(set)
        for k in ks:
            f, i, cur, code, raw = T.lines[k]
            g = re.match(r'^(ldw?|ldb|ldl)\s*\((?:0x[0-9a-fA-F]+|\d+)(?::\d+)?\),\s*(\S+)$', code, re.I)
            if g:
                stores[g.group(2)].add(cur)
            else:
                other[re.sub(r'(0x[0-9a-fA-F]+|\b\d+\b)', 'N', code)].add(cur)
        for v in sorted(stores, key=lambda x: (len(x), x)):
            r = sorted(stores[v])
            print("  store %-10s %3d: %s" % (v, len(r), " ".join(r[:7])))
        for s in sorted(other, key=lambda x: -len(other[x]))[:10]:
            r = sorted(other[s])
            print("  use  %-28s %3d: %s" % (s[:28], len(r), " ".join(r[:6])))
        seen = []
        for k in ks:
            cur = T.lines[k][2]
            if cur in seen:
                continue
            seen.append(cur)
            if len(seen) > a.ctx:
                break
            h = [x for x in T.headers.get(cur, []) if len(x) > 2][:4]
            print("  -- %s  %s" % (cur, os.path.relpath(T.lines[k][0], REPO)))
            for x in h:
                print("     |%s" % x[:150])
            for kk in range(max(0, k - 2), min(len(T.lines), k + 3)):
                c = T.lines[kk][3]
                if c:
                    print("     %s %s" % (">" if kk == k else " ", c[:110]))
        pat = re.compile("|".join(spellings(A)))
        hits = []
        for f, L in T.files.items():
            for i, l in enumerate(L):
                if ";" in l and pat.search(l.split(";", 1)[1]):
                    hits.append("%s:%d %s" % (os.path.relpath(f, REPO), i + 1, l.strip()[:160]))
        for h in hits[:8]:
            print("  cmt  %s" % h)
        if len(hits) > 8:
            print("  cmt  ... %d more" % (len(hits) - 8))
        dpat = re.compile(r'0x0*%x\b' % A, re.I)
        dh = ["%s:%d %s" % (n, i + 1, l.strip()[:160]) for n, L in docs.items() for i, l in enumerate(L) if dpat.search(l)]
        for h in dh[:6]:
            print("  doc  %s" % h)
        nb = ["%+d:%d" % (d, len(U[A + d])) for d in range(-8, 9) if d and A + d in U]
        print("  neighbours %s" % " ".join(nb))


if __name__ == "__main__":
    main()
