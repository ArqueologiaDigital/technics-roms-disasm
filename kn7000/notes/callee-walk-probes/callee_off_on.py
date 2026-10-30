#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""callee_off_on.py -- does the callee walk lose typed bytes anywhere?

QUESTION IT ANSWERS
  "For one gen_data_s.py profile, how many bytes of the data region are typed items (any pass) with the
   callee walk off (`readers_callee` False: the walk and passes as before lane callee-walk) and on, and
   which bytes are typed in one run only, by item kind (with the first items of each)?"  A tree loses typed
   coverage where bytes typed with the walk off are untyped with it on.

HOW
  Runs tools/gen_data_s.py's Gen twice in separate processes, with P["readers_callee"] forced off / on,
  writing the generated sources into <scratch>/<profile>_<off|on>/ (never into the tree), and compares
  the byte ranges the two runs' items claim.  Needs what gen_data_s.py needs (the reference image, the
  converted code, the build's labels).

RUN (from the repository root; the scratch directory must be outside the repository)
  python3 kn7000/notes/callee-walk-probes/callee_off_on.py --profile 941 --scratch ~/compartilhado/tmp/x
"""
import argparse, collections, os, pickle, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.normpath(os.path.join(HERE, "..", "..", "tools"))


def run_one(profile, mode, scratch):
    sys.path.insert(0, TOOLS)
    import gen_data_s as G
    os.chdir(G.KN7_DIR)
    G.configure(profile)
    G.P["readers_callee"] = (mode == "on")
    g = G.Gen()
    out = os.path.join(scratch, f"{profile}_{mode}")
    os.makedirs(out, exist_ok=True)
    g.run(out)
    with open(out + ".pkl", "wb") as f:
        pickle.dump({o: (it.size, it.kind, it.label) for o, it in g.items.items()}, f)


def cover(items):
    m = {}
    for o, (n, k, lab) in items.items():
        for i in range(o, o + n):
            m[i] = (k, lab, o)
    return m


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--profile", required=True)
    ap.add_argument("--scratch", required=True)
    ap.add_argument("--one", choices=("off", "on"), help=argparse.SUPPRESS)
    a = ap.parse_args()
    scratch = os.path.abspath(os.path.expanduser(a.scratch))
    if a.one:
        run_one(a.profile, a.one, scratch)
        return 0
    procs = [subprocess.Popen([sys.executable, os.path.abspath(__file__), "--profile", a.profile, "--scratch",
                               scratch, "--one", m], stdout=subprocess.DEVNULL) for m in ("off", "on")]
    if any(p.wait() for p in procs):
        sys.exit("callee_off_on: a generator run failed")
    off, on = (pickle.load(open(os.path.join(scratch, f"{a.profile}_{m}.pkl"), "rb")) for m in ("off", "on"))
    co, cn = cover(off), cover(on)
    print(f"{a.profile}: typed bytes off {len(co):,}, on {len(cn):,} ({len(cn) - len(co):+,})")
    for name, x, y in (("lost", co, cn), ("gained", cn, co)):
        kinds, firsts = collections.Counter(), collections.defaultdict(set)
        for i, v in x.items():
            if i not in y:
                kinds[v[0]] += 1
                firsts[v[0]].add((v[2], v[1]))
        print(f"  {name}: " + (", ".join(f"{k} {n:,}" for k, n in kinds.most_common()) or "none"))
        for k in kinds:
            print(f"    {k}: " + ", ".join(lab for _o, lab in sorted(firsts[k])[:6])
                  + (f" (+{len(firsts[k]) - 6} more)" if len(firsts[k]) > 6 else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
