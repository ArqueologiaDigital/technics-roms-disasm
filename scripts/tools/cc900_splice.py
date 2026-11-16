#!/usr/bin/env python3
"""Put firmware C functions into the tree in place of their hand assembly (cc900 phase 6).

usage: python3 scripts/tools/cc900_splice.py TREE FILE.c [--dry-run]
    TREE    v10/maincpu
    FILE.c  TREE/cc900/<name>.c.  Its first comment names the hand source as "Functions of <path>.s" (relative to
            TREE).  Every function FILE.c defines is spliced into that file.

For each function NAME: the line `NAME:` in the hand source, then its instruction lines up to and including the
first `ret`, with no other label, directive or `.include` in between (comments and blank lines are allowed and
dropped), become one line:

    NAME:	.include "includes/generated/cc900/NAME.s"	; C: cc900/<name>.c

The header comment above the label stays.  A function whose label line already includes its body is left alone.
Anything else (no such label, a label inside the body, no `ret`) stops the run before any file is written.  The
splice proves nothing by itself: `make gate` must still find the image byte-identical.  The files are read and
written as bytes, because many .s files hold non-UTF-8 bytes.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "build"))
import cc900_firmware_c as fw  # noqa: E402

LABEL_RE = re.compile(rb'^\s*([A-Za-z_.$][\w.$]*):')


def c_functions(path):
    """the tree labels of the functions FILE.c defines, in order (the front end's names, through `cc900-name:`)"""
    sys.path.insert(0, fw.MODEL)
    import frontend
    _, _, adecl = fw.file_options(path)
    labels = fw.label_map(path)
    return [labels.get(f.name, f.name) for f in frontend.load(path, [], [], adecl=adecl).functions]


def main():
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    if len(a) != 2:
        sys.exit(__doc__)
    tree, src = a
    dry = "--dry-run" in sys.argv
    m = re.search(rb'Functions of (\S+\.s)', open(src, "rb").read())
    if not m:
        sys.exit("%s: no 'Functions of <file>.s' in its header comment" % src)
    asm = os.path.join(tree, m.group(1).decode())
    rel_c = os.path.relpath(src, tree)
    lines = open(asm, "rb").read().split(b"\n")
    done = []
    for name in c_functions(src):
        n = name.encode()
        idx = [i for i, l in enumerate(lines) if re.match(rb'^' + re.escape(n) + rb':', l)]
        if len(idx) != 1:
            sys.exit("%s: %d lines define %s" % (asm, len(idx), name))
        i = idx[0]
        inc = b'.include "includes/generated/cc900/' + n + b'.s"'
        if inc in lines[i]:
            continue
        if lines[i].split(b";")[0].strip() != n + b":":
            sys.exit("%s:%d: %s's label line holds more than the label" % (asm, i + 1, name))
        j = i + 1
        while True:
            if j >= len(lines):
                sys.exit("%s: %s has no ret" % (asm, name))
            c = lines[j].split(b";")[0].strip()
            if LABEL_RE.match(lines[j]) or c.startswith(b"."):
                sys.exit("%s:%d: a label or directive inside %s's body" % (asm, j + 1, name))
            if c.split()[:1] == [b"ret"] and len(c.split()) == 1:
                break
            j += 1
        new = n + b":\t" + inc + b"\t; C: " + rel_c.encode()
        lines[i:j + 1] = [new]
        done.append(name)
    if done and not dry:
        open(asm, "wb").write(b"\n".join(lines))
    print("%s: %s %d function(s)%s" % (asm, "would splice" if dry else "spliced", len(done),
                                       (": " + " ".join(done)) if done else ""))


if __name__ == "__main__":
    main()
