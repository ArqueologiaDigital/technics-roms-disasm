#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_rows.py -- the open-items register's O- rows of the MN10300 trees, before and after.

QUESTION IT ANSWERS
  "For every O-kn7000-* / O-kn6000-* / O-kn6500-* / O-kn2400-* / O-hdsx3-* row of
   notes/open-items/REGISTER.md: how many opaque pieces / bytes did the register count (BEFORE: the
   register as committed), and how many does the census count in this checkout now (AFTER)?"
  AFTER is notes/open-items/collect_open_items.py's own grouping (collect_opaque: one row per tree,
  kind and reason head, its id O-<tree>-<kind>-<sha1(head)[:6]>) applied to
  `scripts/analysis/data_incbin_census.py --list opaque`, re-implemented here so that nothing under
  notes/open-items/ is written.  Only the data-region rows (program / sp7001 / b935 / b893 and the
  siblings' trees) are printed; the floppy rows are another lane's.

RUN (from the repository root; read-only; about a minute)
  python3 -I kn7000/notes/mn10300-data2-probes/opaque_rows.py            # Markdown table
"""
import collections
import hashlib
import os
import re
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = re.compile(r"^(kn7000-(program|sp7001|b935|b893)|kn6000|kn6500|kn2400|hdsx3)$")


def after():
    p = subprocess.run([sys.executable, "scripts/analysis/data_incbin_census.py", "--list", "opaque"],
                       cwd=ROOT, capture_output=True, text=True, errors="replace")
    groups = collections.defaultdict(lambda: [0, 0])
    seen = set()
    for line in p.stdout.splitlines():
        f = line.split("\t")
        if len(f) < 5 or f[1] in seen:
            continue
        kind, _, why = f[4].partition(":")
        if kind not in ("unknown-dump", "code"):
            continue
        seen.add(f[1])
        reason = re.sub(r"0x[0-9a-fA-F]+", "ADDR", why.strip())
        reason = re.sub(r"\b\d[\d,]*\b", "N", reason)
        reason = re.sub(r"\([^)]*\)$", "", reason).strip()[:110]
        head = re.sub(r"^N bytes of ", "", reason).split(";")[0].strip()
        head = re.sub(r"\bN\b", "", head)
        head = re.sub(r"\s+", " ", head).strip(" ,.")
        g = groups[f"O-{f[0]}-{kind}-{hashlib.sha1(head.encode()).hexdigest()[:6]}"]
        g[0] += 1
        try:
            g[1] += int(f[2])
        except ValueError:
            pass
        g.append(head) if len(g) == 2 else None
    return groups


def before():
    out = {}
    for ln in open(os.path.join(ROOT, "notes", "open-items", "REGISTER.md"), encoding="utf-8"):
        m = re.match(r"\|\s*(O-\S+)\s*\|.*?(\d[\d,]*) opaque pieces / (\d[\d,]*) B, ([^|]*?)\s*\|", ln)
        if m and m.group(1) not in out:
            out[m.group(1)] = (int(m.group(2).replace(",", "")), int(m.group(3).replace(",", "")), m.group(4))
    return out


def main():
    b, a = before(), after()
    ids = sorted({i for i in set(b) | set(a) if TREES.match(i[2:].split("-unknown-dump")[0].split("-code-")[0])})
    rows = []
    for i in ids:
        nb, bb, what = b.get(i, (0, 0, ""))
        na, ba = a.get(i, [0, 0])[:2]
        if not what and i in a and len(a[i]) > 2:
            what = a[i][2]
        rows.append([i, what, f"{nb:,} / {bb:,}", f"{na:,} / {ba:,}", f"{ba - bb:+,}"])
    hdr = ["id", "class", "pieces / bytes before", "pieces / bytes after", "bytes"]
    w = [max(len(str(r[k])) for r in rows + [hdr]) for k in range(len(hdr))]
    print("| " + " | ".join(h.ljust(w[k]) for k, h in enumerate(hdr)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print("| " + " | ".join(str(c).ljust(w[k]) for k, c in enumerate(r)) + " |")
    tb = sum(b.get(i, (0, 0))[1] for i in ids)
    ta = sum(a.get(i, [0, 0])[1] for i in ids)
    print(f"\ntotal bytes: before {tb:,}, after {ta:,} ({ta - tb:+,})")


if __name__ == "__main__":
    main()
