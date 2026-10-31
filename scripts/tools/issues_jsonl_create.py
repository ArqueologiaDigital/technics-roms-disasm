#!/usr/bin/env python3
"""issues_jsonl_create.py -- append new issues to .beads/issues.jsonl from the "new-issues" lists of
lane issue-comments.json files.

WHAT IT DOES
  Beads is decommissioned (CLAUDE.md); the tracker is a plain JSON-lines file edited directly.  A lane
  that splits an issue writes, in its notes/<lane>/issue-comments.json,

      {"kn5000-xxx": "comment ...", "new-issues": [{"title": ..., "description": ..., "parent": "kn5000-xxx"}]}

  This script reads one or more such files and appends one issue per "new-issues" entry, with a fresh
  id kn5000-<3 base-36 characters> (deterministic: derived from the title's SHA-1, re-drawn on a
  collision), status "open", priority from the entry or its parent's, issue_type "task".  No
  dependency is added: a split-off issue carries work its parent no longer claims, so it must not
  block the parent's closure; its description says "Split from <parent>" and the parent's comment
  (issues_jsonl_update.py) names the new id.  Existing lines are written back BYTE-IDENTICAL.  An entry whose title already
  exists in the file is skipped, so a run cannot be applied twice by accident.  It prints
  "<new id>  <parent>  <title>" per issue, which is what the lane report quotes.

RUN
  python3 scripts/tools/issues_jsonl_create.py notes/<lane>/*/issue-comments.json \
      --author "Claude Code (lane open4/kn5000-b)" [--dry-run]
"""
import argparse
import datetime
import hashlib
import json

PATH = ".beads/issues.jsonl"
ALPHA = "0123456789abcdefghijklmnopqrstuvwxyz"


def new_id(title, taken):
    h = int(hashlib.sha1(title.encode("utf-8")).hexdigest(), 16)
    while True:
        s = "".join(ALPHA[(h >> (6 * k)) % 36] for k in range(3))
        cand = "kn5000-" + s
        if cand not in taken:
            return cand
        h //= 7


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--author", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    raw = open(PATH, "rb").read()
    assert raw.endswith(b"\n"), "issues.jsonl does not end with a newline"
    lines = raw[:-1].split(b"\n")
    objs = [json.loads(l) for l in lines]
    byid = {o["id"]: i for i, o in enumerate(objs)}
    titles = {o["title"] for o in objs}
    taken = set(byid)
    now = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    out_new = []
    for f in a.files:
        spec = json.load(open(f, encoding="utf-8"))
        for e in spec.get("new-issues", []):
            if e["title"] in titles:
                print("skip (exists):", e["title"])
                continue
            parent = e.get("parent")
            desc = e.get("description", "")
            if parent and parent not in desc:
                desc = f"Split from {parent}. " + desc
            assert parent is None or parent in byid, f"{f}: unknown parent {parent}"
            nid = new_id(e["title"], taken)
            taken.add(nid)
            titles.add(e["title"])
            prio = e.get("priority", objs[byid[parent]].get("priority", 2) if parent else 2)
            d = {"id": nid, "title": e["title"], "description": desc,
                 "status": "open", "priority": prio, "issue_type": e.get("issue_type", "task"),
                 "created_at": now, "created_by": a.author, "updated_at": now}
            out_new.append(d)
            print(f"{nid}  {parent or '-'}  {e['title']}")
    for d in out_new:
        lines.append(json.dumps(d, ensure_ascii=False, separators=(",", ":")).encode("utf-8"))
    if not a.dry_run:
        open(PATH, "wb").write(b"\n".join(lines) + b"\n")


if __name__ == "__main__":
    main()
