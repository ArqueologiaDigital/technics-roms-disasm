#!/usr/bin/env python3
"""harmonize_permuted_locals.py -- resolve the "name taken" rows of harmonize_version_labels.py that are a permutation.

QUESTION IT ANSWERS
  harmonize_version_labels.py copies v10's label names to v9 / v7 at byte-matched addresses, but it refuses a name
  that the target tree already uses at ANOTHER address.  When two runs of the local-label numbering
  (rename_orphan_locals.py, localize_internal_generic_labels.py) visit a routine's labels in a different order, the
  two trees end up with the same set of names on the same addresses, permuted: v10 SeWrtSnd_SetupNamingPage_Join3 is
  v9's _Join7 and so on.  The harmonizer reports each as "name taken" and leaves the cross-version diff noisy.
  This script reads the harmonizer's report, keeps only rows whose target-side names form a CLOSED set (every name
  the rows want is one of the names the rows replace, so nothing outside the set is touched), and renames them in
  two steps through temporary names, in every *.s of the target tree.  Labels move no bytes; the gate is the proof.

RUN (repository root, built tree)
  python3 scripts/renaming/harmonize_version_labels.py --to v9 --report R.json
  python3 scripts/renaming/harmonize_permuted_locals.py --to v9 R.json [--apply]
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main():
    a = sys.argv[1:]
    tree = a[a.index("--to") + 1]
    rep = [x for x in a if x.endswith(".json")][0]
    rows = [r for r in json.load(open(rep)) if r.get("result") == "name taken" and len(r.get("to_has", [])) == 1]
    want = {r["to_has"][0]: r["from"] for r in rows}          # current target name -> v10 name
    closed = {o: n for o, n in want.items() if n in want and o != n}
    # keep only whole cycles: follow o -> n -> ... until it returns to o
    keep = {}
    for o in closed:
        cyc, x = [o], closed[o]
        while x in closed and x != o and x not in cyc:
            cyc.append(x)
            x = closed[x]
        if x == o:
            for y in cyc:
                keep[y] = closed[y]
    print("%s: %d 'name taken' rows, %d in closed permutation cycles" % (tree, len(rows), len(keep)))
    for o, n in sorted(keep.items()):
        print("   %s -> %s" % (o, n))
    if "--apply" not in a or not keep:
        return
    tmp = {o: "__perm_tmp_%d__" % i for i, o in enumerate(sorted(keep))}
    rx1 = re.compile(r'\b(%s)\b' % "|".join(sorted(map(re.escape, keep), key=len, reverse=True)))
    rx2 = re.compile(r'\b(__perm_tmp_\d+__)\b')
    back = {tmp[o]: keep[o] for o in keep}
    for p in sorted(glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True)):
        t = open(p, "rb").read().decode("latin-1")
        t2 = rx2.sub(lambda m: back[m.group(1)], rx1.sub(lambda m: tmp[m.group(1)], t))
        if t2 != t:
            data = t2.encode("latin-1")
            with open(p + ".tmp", "wb") as fh:
                fh.write(data)
            os.replace(p + ".tmp", p)
    sedp = os.path.join(ROOT, "scripts/renaming/harmonize_permuted_locals_%s.txt" % tree)
    with open(sedp, "a") as fh:
        fh.writelines("%s -> %s\n" % (o, n) for o, n in sorted(keep.items()))
    print("recorded in", os.path.relpath(sedp, ROOT))


if __name__ == "__main__":
    main()
