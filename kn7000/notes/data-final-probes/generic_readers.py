#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""generic_readers.py -- who reads each generic piece of a program build's typed data region.

QUESTION IT ANSWERS
  "For every .incbin_range of src/<build>/program/data/ that carries no census marker (a generic
   piece), which label precedes it, what are its first bytes, and which instructions of the converted
   code (tools/data_readers.py) load, store, take as a base or pass to a call an address inside it?"
  This is the work list of lane kn7000-final: each piece's readers say what pass could type it.

RUN (from kn7000/, after a build):
  python3 notes/data-final-probes/generic_readers.py [--profile 941] [--min 0] [--opaque]
  --opaque lists the pieces declared `census: opaque` instead (biggest first), with the same reader search.
"""
import argparse, bisect, collections, glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(KN7, "tools"))


def pieces(d, want_opaque):
    out = []
    for f in sorted(glob.glob(os.path.join(d, "data*.s"))):
        lines = open(f, encoding="latin-1").read().split("\n")
        lab = None
        for i, ln in enumerate(lines):
            m = re.match(r"^([A-Za-z_]\w*):", ln)
            if m:
                lab = m.group(1)
            m = re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)', ln)
            if not m:
                continue
            marked = "census:" in ln or (i and "census:" in lines[i - 1])
            if marked != want_opaque:
                continue
            out.append((int(m.group(1), 16), int(m.group(2), 16), lab, os.path.basename(f), i + 1))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="941")
    ap.add_argument("--min", type=int, default=0)
    ap.add_argument("--opaque", action="store_true")
    ap.add_argument("--top", type=int, default=100000)
    a = ap.parse_args()
    os.chdir(KN7)
    import data_readers as DR
    import gen_data_s as G
    r = DR.load(a.profile)
    base = G.BASE
    rom = open(G.P["rom"], "rb").read()
    ps = pieces(G.OUTDIR, a.opaque)
    ps.sort(key=lambda p: -(p[1] - p[0]))
    hits = collections.defaultdict(list)
    starts = sorted((p[0], p[1]) for p in ps)
    ks = [s for s, _ in starts]

    def find(o):
        i = bisect.bisect_right(ks, o) - 1
        if i >= 0 and starts[i][0] <= o < starts[i][1]:
            return starts[i][0]
        return None
    for x in r.accesses:
        k = x.key
        if k[0] in ("abs", "base", "step"):
            o = k[1] - base
        elif k[0] == "rec":
            o = k[1] + x.off - base
        elif k[0] == "ptr" and k[1][0] == "tgt":
            # (data_readers ext) one of several records a switch, a slot or a return selects
            for t in k[1][1]:
                s = find(t + x.off - base)
                if s is not None:
                    hits[s].append(x)
            continue
        else:
            continue
        s = find(o)
        if s is not None:
            hits[s].append(x)
    tot = 0
    for lo, hi, lab, f, ln in ps[:a.top]:
        if hi - lo < a.min:
            continue
        tot += hi - lo
        print(f"{hi - lo:6d} {base + lo:08X}-{base + hi:08X} {f}:{ln} after {lab}: {rom[lo:lo + 16].hex(' ')}")
        seen = set()
        for x in hits.get(lo, [])[:8]:
            kk = (x.func, x.insn, x.rw)
            if kk in seen:
                continue
            seen.add(kk)
            k = x.key
            where = (f"{k[1]:08X}+{x.off}" if k[0] == "rec" else
                     f"one of {len(k[1][1])}+{x.off}" if k[0] == "ptr" else f"{k[1]:08X}")
            print(f"         {k[0]:4s} {where} s={k[2] if k[0] == 'rec' else ''} w{x.width} {x.rw:6s} {x.func} "
                  f"@{x.cpu or 0:08X} `{x.insn}` {x.extra or ''}")
    print(f"total {tot} bytes in {len(ps)} pieces")


if __name__ == "__main__":
    main()
