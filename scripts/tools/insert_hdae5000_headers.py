#!/usr/bin/env python3
"""insert_hdae5000_headers.py -- put routine header comments above HD-AE5000 labels, from a batch file.

QUESTION IT ANSWERS
  How do hand-written routine headers get into hdae5000/*.s without hand-editing 26,000-line files that hold
  raw ROM bytes in .ascii literals?  A batch file lists, per routine, the header text; this script places it
  directly above the routine's label (the KN5000 maincpu convention, which
  scripts/analysis/hdae5000_call_target_headers.py counts), framed by separator lines, and optionally drops
  the comment lines the conversion left right after the label ("body notes") when the header supersedes them.
  It also drops a pure address comment on the label line (`HDAE5000_X:<tab>; 0x29AF45`, optionally followed
  by a `(N bytes)` region size), which the No
  Inline Address Comments policy forbids.  Comments only: no byte of any image can move (make -j3 gate).

BATCH FILE FORMAT
  @@ <label> [drop-notes]
  <header lines, each starting with ';'>
  @@ <next label> ...
  `drop-notes` removes the comment lines between the label line and the routine's first instruction or
  directive (blank lines there go too).  Without it they stay.  `strip-line-comments` removes the trailing
  comment of every code line of the routine (up to the next label that is neither a .L local nor
  <label>_...), for routines whose line comments come from a discarded reading; whole-line comments stay.
  Lines of the batch file starting with '#' outside a block are ignored.

RUN (repository root)
  python3 scripts/tools/insert_hdae5000_headers.py BATCH            # check: every label found, none has a header
  python3 scripts/tools/insert_hdae5000_headers.py BATCH --apply    # write hdae5000/*.s (bytes in, bytes out)
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SEP = "; " + "-" * 75
ADDRCOMMENT = re.compile(rb'[ \t]*;[ \t]*(?:0x[0-9a-fA-F]{6}|[0-9a-fA-F]{6}h)(?:[ \t]*\(\d[\d,]* bytes[^)]*\))?[ \t]*$')


def parse_batch(path):
    blocks, cur = [], None
    for raw in open(path, encoding="latin-1").read().split("\n"):
        if raw.startswith("@@"):
            f = raw[2:].split()
            cur = {"name": f[0], "drop": "drop-notes" in f[1:], "strip": "strip-line-comments" in f[1:],
                   "text": []}
            blocks.append(cur)
        elif cur is not None and raw.strip():
            if not raw.startswith(";"):
                sys.exit("%s: header line does not start with ';': %r" % (cur["name"], raw))
            cur["text"].append(raw.rstrip())
        elif raw.strip() and not raw.startswith("#"):
            sys.exit("text outside a block: %r" % raw)
    return blocks


def main():
    a = sys.argv[1:]
    blocks = parse_batch(a[0])
    files = sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s")))
    src = {p: open(p, "rb").read().split(b"\n") for p in files}
    where = {}
    for p, L in src.items():
        for i, x in enumerate(L):
            m = re.match(rb'^([A-Za-z_][\w$]*):', x)
            if m:
                where[m.group(1).decode()] = p
    edits = {}
    for b in blocks:
        n = b["name"]
        if n not in where:
            sys.exit("%s: no such label in hdae5000/*.s" % n)
        if not b["text"]:
            sys.exit("%s: empty header" % n)
        edits.setdefault(where[n], []).append(b)
    changed = 0
    for p, bs in edits.items():
        L = src[p]
        for b in bs:
            key = (b["name"] + ":").encode()
            i = next(k for k, x in enumerate(L) if x.startswith(key))
            k = i - 1
            while k >= 0 and not L[k].strip():
                k -= 1
            if k >= 0 and L[k].lstrip().startswith(b";") and L[k].strip().strip(b";-= \t"):
                sys.exit("%s: already has a comment block above it" % b["name"])
            L[i] = ADDRCOMMENT.sub(b"", L[i])
            if b["drop"]:
                j = i + 1
                while j < len(L) and (not L[j].strip() or L[j].lstrip().startswith(b";")):
                    j += 1
                del L[i + 1:j]
            if b["strip"]:
                # trailing comments of every instruction line of the routine (up to the next label that is
                # neither a .L local nor <name>_...); whole-line comments stay
                own = b["name"].encode() + b"_"
                j = i + 1
                while j < len(L):
                    m = re.match(rb'^([.A-Za-z_][\w$.]*):', L[j])
                    if m and not m.group(1).startswith((b".L", own)):
                        break
                    if not L[j].lstrip().startswith(b";") and b";" in L[j] and b'"' not in L[j]:
                        L[j] = L[j][:L[j].index(b";")].rstrip()
                    j += 1
            head = [SEP.encode()] + [t.encode("latin-1") for t in b["text"]] + [SEP.encode()]
            if i > 0 and L[i - 1].strip():
                head = [b""] + head
            L[i:i] = head
            changed += 1
        if "--apply" in a:
            with open(p + ".tmp", "wb") as fh:
                fh.write(b"\n".join(L))
            os.replace(p + ".tmp", p)
    print("%d headers %s" % (changed, "inserted" if "--apply" in a else "checked (dry run)"))


if __name__ == "__main__":
    main()
