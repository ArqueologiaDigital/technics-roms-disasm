#!/usr/bin/env python3
"""kn5000-rld: what became of the 100 "not reviewed (stopped early)" records of the 2026-10-07 generic batches?

QUESTION IT ANSWERS
  analysis/kn5000-naming/proposals-2026-10-07-generic-g{1,3,5}.json hold 100 records whose verdict is
  "refuse / not reviewed (stopped early at the owner's request)".  For each one this looks up the label's v10
  address in the symbol file of the commit that wrote the batches (88bc2005c, 2026-10-06) -- v7's file when v10's
  has no such label -- and prints the label(s) at that address in today's symbol file, and whether the old name
  is still defined in any of the v10 / v9 / v7 / v6 / v5 sources.  A record whose address now carries a
  descriptive name was renamed by a later lane; the others are the ones left to review.

RUN (repository root; needs git history):
  python3 notes/open6-kn5000-d/naming/probes/rld_record_status.py [--json OUT.json]
"""
import collections
import json
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
REV = "88bc2005c"


def load(text):
    by_addr, by_name = collections.defaultdict(list), {}
    for line in text.splitlines():
        p = line.split()
        if len(p) == 2 and not line.startswith("#"):
            by_addr[p[1]].append(p[0])
            by_name[p[0]] = p[1]
    return by_addr, by_name


def git_show(path):
    return subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (REV, path)], capture_output=True, text=True,
                          check=True).stdout


old10 = load(git_show("symbols/maincpu_v10_symbols_reference.txt"))
old7 = load(git_show("symbols/maincpu_v7_symbols_reference.txt"))
cur10 = load(open(os.path.join(REPO, "symbols/maincpu_v10_symbols_reference.txt")).read())
cur7 = load(open(os.path.join(REPO, "symbols/maincpu_v7_symbols_reference.txt")).read())
defs = collections.defaultdict(set)
rx = re.compile(rb"^([A-Za-z_]\w*):", re.M)
for tree in ("v10", "v9", "v7", "v6", "v5"):
    for dp, _, fs in os.walk(os.path.join(REPO, tree, "maincpu")):
        for f in fs:
            if f.endswith(".s"):
                for m in rx.finditer(open(os.path.join(dp, f), "rb").read()):
                    defs[m.group(1).decode()].add(tree)
rows = []
for g in (1, 3, 5):
    p = os.path.join(REPO, "analysis/kn5000-naming/proposals-2026-10-07-generic-g%d.json" % g)
    for r in json.load(open(p)):
        if r.get("verdict") != "refuse" or "stopped" not in (r.get("why_refused") or ""):
            continue
        old = r["old"]
        if old in old10[1]:
            tree, addr, now = "v10", old10[1][old], cur10[0].get(old10[1][old], [])
        elif old in old7[1]:
            tree, addr, now = "v7", old7[1][old], cur7[0].get(old7[1][old], [])
        else:
            tree, addr, now = "-", "-", []
        rows.append({"batch": "g%d" % g, "old": old, "tree": tree, "address": addr, "now": now,
                     "old_still_defined_in": sorted(defs.get(old, ()), key=lambda t: -int(t[1:]))})
for r in rows:
    print("%s %-46s %-4s %s now=%s defined=%s" % (r["batch"], r["old"], r["tree"], r["address"],
                                                  ",".join(r["now"]) or "-", ",".join(r["old_still_defined_in"]) or "-"))
if "--json" in sys.argv:
    json.dump(rows, open(sys.argv[sys.argv.index("--json") + 1], "w"), indent=1)
