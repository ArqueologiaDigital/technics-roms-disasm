#!/usr/bin/env python3
"""hdae5000_call_target_headers.py -- which HD-AE5000 call targets still lack a header comment?

QUESTION IT ANSWERS
  How many distinct labels in hdae5000/*.s are the target of a `call` / `calr` (direct, by name), and how many
  of them carry no header comment -- ranked by the number of call sites, so the most-used routines get
  documented first.

  A label HAS a header comment when a comment block sits directly above it -- the convention of the
  KN5000 maincpu trees (`; ===` / name / Entry / Exit block, then the label) -- with only blank lines between,
  and that block holds at least one line that is not a separator (`;`, `-`, `=`, spaces).  Comments AFTER
  the label line ("body notes": the conversion put its remarks there, often several contradicting ones)
  are counted separately, in the `notes` column, and do not make a header.

RUN (repository root)
  python3 scripts/analysis/hdae5000_call_target_headers.py            # summary + top 40 undocumented
  python3 scripts/analysis/hdae5000_call_target_headers.py --all      # every undocumented target
  python3 scripts/analysis/hdae5000_call_target_headers.py --rev REV  # the same, for a commit's tree
"""
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEF = re.compile(r'^([A-Za-z_][\w$]*):')
CALL = re.compile(r'^\s*(?:[A-Za-z_][\w$]*:)?\s*(call|calr)\s+(?:t\s*,\s*)?([A-Za-z_][\w$]*)\s*(?:;|$)', re.I)
SEPARATOR = re.compile(r'^\s*;[\s;=\-]*$')


def load(rev=None):
    src = {}
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        if rev:
            data = subprocess.run(["git", "-C", ROOT, "show", "%s:%s" % (rev, os.path.relpath(p, ROOT))],
                                  capture_output=True, check=True).stdout
        else:
            data = open(p, "rb").read()
        src[p] = data.decode("latin-1").split("\n")
    return src


def is_comment(line):
    s = line.strip()
    return s.startswith(";") and not SEPARATOR.match(line)


def has_header(L, i):
    k = i - 1
    while k >= 0 and not L[k].strip():
        k -= 1
    while k >= 0 and L[k].strip().startswith(";"):      # the contiguous comment block above
        if is_comment(L[k]):
            return True
        k -= 1
    return False


def body_notes(L, i):
    n, k = 0, i + 1
    while k < len(L) and (not L[k].strip() or L[k].strip().startswith(";")):
        n += is_comment(L[k])
        k += 1
    return n


def survey(rev=None):
    src = load(rev)
    defs, calls = {}, collections.Counter()
    for p, L in src.items():
        for i, x in enumerate(L):
            m = DEF.match(x)
            if m:
                defs[m.group(1)] = (p, i)
            c = CALL.match(x)
            if c:
                calls[c.group(2)] += 1
    rows = []
    for n, k in calls.items():
        if n not in defs:
            continue
        p, i = defs[n]
        rows.append((n, k, has_header(src[p], i), os.path.relpath(p, ROOT), i + 1, body_notes(src[p], i)))
    return rows


def main():
    a = sys.argv[1:]
    rows = survey(a[a.index("--rev") + 1] if "--rev" in a else None)
    lacking = sorted((r for r in rows if not r[2]), key=lambda r: (-r[1], r[0]))
    print("hdae5000 call targets: %d, with a header comment: %d, without: %d"
          % (len(rows), len(rows) - len(lacking), len(lacking)))
    print("  calls  notes  name")
    for n, k, _, f, ln, notes in (lacking if "--all" in sys.argv else lacking[:40]):
        print("  %5d  %5d  %-56s %s:%d" % (k, notes, n, f, ln))


if __name__ == "__main__":
    main()
