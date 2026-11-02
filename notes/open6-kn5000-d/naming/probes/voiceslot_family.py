#!/usr/bin/env python3
"""The VoiceSlot_* labels of a KN5000 maincpu tree: where each is defined, how it is reached.

QUESTION IT ANSWERS
  kn5000-zc1: which VoiceSlot_* labels are routines (reached by call / calr / jp / a .long / from
  another file) and which are local branch targets (jr / jrl / djnz inside one file only), and in which
  file each is defined.  The routine list is what had to be read and named by hand; the locals follow
  their enclosing routine.

RUN (repository root):
  python3 notes/open6-kn5000-d/naming/probes/voiceslot_family.py [tree, default v10] [--prefix VoiceSlot_]
Output: one line per label: kind (ROUTINE / local), defining file:line, reference counts by mnemonic.
"""
import collections
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
args = [a for a in sys.argv[1:] if not a.startswith("--")]
tree = args[0] if args else "v10"
prefix = "VoiceSlot_"
if "--prefix" in sys.argv:
    prefix = sys.argv[sys.argv.index("--prefix") + 1]
root = os.path.join(REPO, tree, "maincpu")
defs, refs = {}, collections.defaultdict(collections.Counter)
rx_def = re.compile(r"^(%s\w*):" % re.escape(prefix))
rx_ref = re.compile(r"\b(%s\w*)\b" % re.escape(prefix))
for dp, _, fs in os.walk(root):
    for f in fs:
        if not f.endswith((".s", ".c", ".h", ".ld")):
            continue
        p = os.path.join(dp, f)
        rel = os.path.relpath(p, root)
        for n, line in enumerate(open(p, "rb").read().decode("latin-1").splitlines(), 1):
            m = rx_def.match(line)
            body = line
            if m:
                defs[m.group(1)] = (rel, n)
                body = line[m.end():]
            code = body.split(";", 1)[0] if f.endswith(".s") else body
            for r in rx_ref.finditer(code):
                mn = code.strip().split(None, 1)[0] if code.strip() else "?"
                refs[r.group(1)][(rel, mn.lower())] += 1
for name in sorted(defs, key=lambda k: defs[k]):
    rel, n = defs[name]
    kinds = refs.get(name, {})
    routine = any(mn in ("call", "calr", "jp", ".long", "jrl") and mn != "jrl" or r != rel or not f_ok
                  for (r, mn), _ in kinds.items() for f_ok in [True]) if kinds else True
    routine = (not kinds) or any(mn in ("call", "calr", "jp", ".long", ".set", ".short") or r != rel
                                 for (r, mn) in kinds)
    print("%-8s %-58s %s:%d  %s" % ("ROUTINE" if routine else "local", name, rel, n,
          " ".join("%s:%s=%d" % (r if r != rel else "", mn, c) for (r, mn), c in sorted(kinds.items()))))
