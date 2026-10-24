#!/usr/bin/env python3
"""apply_text_patches_bytes.py -- exact search/replace edits on source files that must be handled as bytes.

QUESTION IT ANSWERS
  How to make small, reviewed, exact edits (a wrong comment, a stale remark) in .s files that hold raw ROM
  bytes in .ascii literals -- files an editor or Path.read_text() may silently re-encode -- without touching
  any other byte?  Each edit names the file, the exact old text and its replacement; the old text must occur
  exactly once.  All edits of a patch file apply, or none (the files are only written when every edit
  matched).

PATCH FILE FORMAT
  ### <path relative to the repository root>
  <<<
  old text (one or more lines)
  ===
  new text (may be empty)
  >>>
  (more <<< === >>> blocks for the same file, or another ### line)
  The text is treated as latin-1, so every byte maps to one character and back.

RUN (repository root)
  python3 scripts/tools/apply_text_patches_bytes.py PATCHFILE            # check only
  python3 scripts/tools/apply_text_patches_bytes.py PATCHFILE --apply    # write
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def parse(path):
    edits, cur_file, mode, old, new = [], None, None, [], []
    for line in open(path, encoding="utf-8").read().split("\n"):
        if mode is None and line.startswith("### "):
            cur_file = line[4:].strip()
        elif mode is None and line == "<<<":
            mode, old, new = "old", [], []
        elif mode == "old" and line == "===":
            mode = "new"
        elif mode == "new" and line == ">>>":
            edits.append((cur_file, "\n".join(old), "\n".join(new)))
            mode = None
        elif mode == "old":
            old.append(line)
        elif mode == "new":
            new.append(line)
        elif line.strip():
            sys.exit("unexpected line outside a block: %r" % line)
    if mode is not None:
        sys.exit("unterminated block")
    return edits


def main():
    edits = parse(sys.argv[1])
    texts = {}
    for f, old, new in edits:
        p = os.path.join(ROOT, f)
        if p not in texts:
            texts[p] = open(p, "rb").read().decode("latin-1")
        n = texts[p].count(old)
        if n != 1:
            sys.exit("%s: old text occurs %d times:\n%s" % (f, n, old))
        texts[p] = texts[p].replace(old, new)
    if "--apply" in sys.argv[2:]:
        for p, t in texts.items():
            with open(p + ".tmp", "wb") as fh:
                fh.write(t.encode("latin-1"))
            os.replace(p + ".tmp", p)
    print("%d edits in %d files %s" % (len(edits), len(texts), "applied" if "--apply" in sys.argv[2:] else "checked"))


if __name__ == "__main__":
    main()
