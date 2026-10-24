#!/usr/bin/env python3
"""issues_jsonl_update.py -- add comments to, and close, issues in .beads/issues.jsonl by script.

WHAT IT DOES
  Beads is decommissioned (CLAUDE.md); the tracker is a plain JSON-lines file edited directly.
  This applies a SPEC (a JSON list) to it:

      [{"id": "kn5000-3o6", "close": true,  "reason": "Obsolete: ...", "comment": "..."},
       {"id": "kn5000-3ei", "close": false, "comment": "..."}]

  For every entry it appends a comment ({id, issue_id, author, text, created_at}, the shape the
  existing comments have; id = highest comment id in the file + 1) and, when "close" is true,
  sets status "closed", updated_at, closed_at and close_reason.  New keys are inserted where
  closed issues already carry them (closed_at and close_reason right after updated_at,
  comments last).  Lines the spec does not name are written back BYTE-IDENTICAL; changed lines
  are re-serialised compactly with non-ASCII kept, like most of the file.  It refuses an id
  that is missing or already closed, so a spec cannot be applied twice by accident.

RUN
  python3 scripts/tools/issues_jsonl_update.py SPEC.json --author "Claude Code (lane)" [--dry-run]
"""
import argparse
import datetime
import json
import sys

PATH = ".beads/issues.jsonl"


def insert_after(d, after, key, value):
    out = {}
    for k, v in d.items():
        if k == key:
            continue
        out[k] = v
        if k == after:
            out[key] = value
    if key not in out:
        out[key] = value
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("spec")
    ap.add_argument("--author", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    spec = {e["id"]: e for e in json.load(open(a.spec, encoding="utf-8"))}
    raw = open(PATH, "rb").read().split(b"\n")
    assert raw[-1] == b"", "issues.jsonl does not end with a newline"
    lines = raw[:-1]
    objs = [json.loads(l) for l in lines]
    next_cid = 1 + max((c.get("id") or 0) for o in objs for c in (o.get("comments") or []))
    now_local = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    now_utc = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    seen = set()
    for i, o in enumerate(objs):
        e = spec.get(o["id"])
        if not e:
            continue
        if o.get("status") == "closed":
            sys.exit("%s is already closed" % o["id"])
        seen.add(o["id"])
        comments = list(o.get("comments") or [])
        comments.append({"id": next_cid, "issue_id": o["id"], "author": a.author,
                         "text": e["comment"], "created_at": now_utc})
        next_cid += 1
        o = {k: v for k, v in o.items() if k != "comments"}
        o["updated_at"] = now_local
        if e.get("close"):
            o["status"] = "closed"
            o = insert_after(o, "updated_at", "closed_at", now_local)
            o = insert_after(o, "closed_at", "close_reason", e["reason"])
        o["comments"] = comments
        lines[i] = json.dumps(o, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        print("%-12s %s" % (o["id"], "closed" if e.get("close") else "commented"))
    missing = set(spec) - seen
    if missing:
        sys.exit("not found: %s" % ", ".join(sorted(missing)))
    if not a.dry_run:
        open(PATH, "wb").write(b"\n".join(lines) + b"\n")


if __name__ == "__main__":
    main()
