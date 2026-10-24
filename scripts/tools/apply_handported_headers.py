#!/usr/bin/env python3
r"""Apply the hand-ported v10 headers recorded in analysis/header-propagation/handport-*.txt.

QUESTION ANSWERED / JOB IT DOES
    scripts/tools/propagate_v10_headers.py copies a v10 header to v9 / v7 only when it can
    prove the comment true there; the rest go to its review list.  A person (or an agent)
    then reads a review-list entry, decides, and records the decision in a handport file:

        @@ v7 SqSngName_ApplyNameAndExit
        # note: v7 keeps the song-name buffer ... (why the text below is true for v7)
        ; SqSngName_ApplyNameAndExit: ...      <- the header as it should read in v7
        ;   ...

    An entry with no `;` lines records a decision NOT to port (the note says why).  This
    script inserts each header above the target label -- only when the target has no header
    there yet; a target already carrying exactly that header is skipped, so it is idempotent --
    and copies the note into the review list's `handport` column ("hand-ported: ..." or
    "not ported: ...").  Comments only: `propagate_v10_headers.py --verify HEAD` and
    `make gate` must stay green.

RUN
    python3 scripts/tools/apply_handported_headers.py analysis/header-propagation/handport-2026-10-24.txt \
        [--review analysis/header-propagation/review-2026-10-24.tsv] [--dry-run]
"""
import argparse
import csv
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
import propagate_v10_headers as P  # noqa: E402


def parse(path):
    entries, cur = [], None
    for line in open(path, encoding="latin-1").read().split("\n"):
        if line.startswith("@@ "):
            tgt, label = line[3:].split()
            cur = {"target": tgt, "label": label, "note": "", "header": []}
            entries.append(cur)
        elif cur is None or not line.strip():
            continue
        elif line.startswith("# note:"):
            cur["note"] = line[len("# note:"):].strip()
        elif line.startswith("#"):
            continue
        elif line.lstrip().startswith(";"):
            cur["header"].append(line)
        else:
            raise SystemExit("%s: not a header line in entry %s: %r" % (path, cur["label"], line))
    for e in entries:
        if not e["note"]:
            raise SystemExit("%s: entry %s %s has no note" % (path, e["target"], e["label"]))
    return entries


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("handport")
    ap.add_argument("--review", default=os.path.join(REPO, "analysis", "header-propagation",
                                                     "review-2026-10-24.tsv"))
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    entries = parse(a.handport)
    trees = {}
    edits = {}
    stats = {"inserted": 0, "already": 0, "not-ported": 0}
    for e in entries:
        t = trees.setdefault(e["target"], P.Tree(e["target"]))
        if e["label"] not in t.labels:
            raise SystemExit("%s has no label %s" % (e["target"], e["label"]))
        if not e["header"]:
            stats["not-ported"] += 1
            continue
        rel, i = t.labels[e["label"]]
        h0 = t.header(rel, i)
        have = t.files[rel][h0:i]
        if have == e["header"]:
            stats["already"] += 1
            continue
        if have:
            raise SystemExit("%s %s already has a different header; not overwriting" %
                             (e["target"], e["label"]))
        edits.setdefault((e["target"], rel), []).append((i, e["header"]))
        stats["inserted"] += 1
    if not a.dry_run:
        for (tgt, rel), ops in edits.items():
            lines = trees[tgt].files[rel]
            for i, hdr in sorted(ops, reverse=True):
                lines[i:i] = hdr
            with open(os.path.join(REPO, rel), "wb") as f:
                f.write("\n".join(lines).encode("latin-1"))
        rows = list(csv.reader(open(a.review, newline="", encoding="utf-8"), delimiter="\t"))
        col = rows[0].index("handport")
        notes = {(e["target"], e["label"]): ("hand-ported: " if e["header"] else "not ported: ")
                 + e["note"] for e in entries}
        missing = set(notes)
        for r in rows[1:]:
            k = (r[0], r[1])
            if k in notes:
                r[col] = notes[k]
                missing.discard(k)
        if missing:
            raise SystemExit("not in the review list: %s" % sorted(missing))
        with open(a.review, "w", newline="", encoding="utf-8") as f:
            csv.writer(f, delimiter="\t", lineterminator="\n").writerows(rows)
    print("%d entries: %d headers inserted, %d already in place, %d recorded as not ported" %
          (len(entries), stats["inserted"], stats["already"], stats["not-ported"]))


if __name__ == "__main__":
    main()
