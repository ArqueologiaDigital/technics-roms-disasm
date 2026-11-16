#!/usr/bin/env python3
"""Put firmware C functions into the tree in place of their hand assembly (cc900 phase 6).

usage: python3 scripts/tools/cc900_splice.py TREE FILE.c [--symbols REF] [--dry-run]
    TREE    v10/maincpu
    FILE.c  TREE/cc900/<name>.c.  Its first comment names the hand source as "Functions of <path>.s" (relative to
            TREE).  Every function FILE.c defines is spliced into that file.

For each function NAME: the line `NAME:` in the hand source, then its instruction lines up to and including the
first `ret`, with no other label, directive or `.include` in between (comments and blank lines are allowed and
dropped), become one line:

    NAME:	.include "includes/generated/cc900/NAME.s"	; C: cc900/<name>.c

With --symbols REF (the tree's symbols/maincpu_<v>_symbols_reference.txt), a function may have several `ret`s and
labels inside it (FormatMedleyNumber's FmtNum_*): its extent is the size of its compiled C (the reference model,
assembled), every label whose address lies inside it is an inner label, and each is kept by name after the include
as `.set INNER, NAME + offset`, its offset taken from REF; the blank and comment lines before the next label stay.

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
    a = [x for i, x in enumerate(sys.argv[1:], 1) if not x.startswith("--") and sys.argv[i - 1] != "--symbols"]
    if len(a) != 2:
        sys.exit(__doc__)
    tree, src = a
    dry = "--dry-run" in sys.argv
    m = re.search(rb'Functions of (\S+\.s)', open(src, "rb").read())
    if not m:
        sys.exit("%s: no 'Functions of <file>.s' in its header comment" % src)
    asm = os.path.join(tree, m.group(1).decode())
    rel_c = os.path.relpath(src, tree)
    ref = sizes = None
    if "--symbols" in sys.argv:                          # functions with inner labels and several rets
        import check_bytes
        ref = check_bytes.load_reference(sys.argv[sys.argv.index("--symbols") + 1])
        funcs = fw.compile_c(src, fw.Names(fw.tree_values(tree), ref), spell=False)
        if fw.REFUSED:
            sys.exit("%s: the model refuses %s" % (src, ", ".join(fw.REFUSED)))
        sizes = {f: len(check_bytes.assemble("\t.text\n\t.globl %s\n%s:\n%s\n" % (f, f, "\n".join(l)))[f])
                 for f, l in funcs.items()}
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
        inner = []
        if ref is not None:                              # the extent is the C function's size; labels inside it are
            end = ref[name] + sizes[name]                # inner labels, kept as offsets from NAME
            while True:
                if j >= len(lines):
                    sys.exit("%s: %s runs past the end of the file" % (asm, name))
                lm = LABEL_RE.match(lines[j])
                if lm:
                    ln = lm.group(1).decode()
                    if ln not in ref:
                        sys.exit("%s:%d: %s is not in the symbols reference" % (asm, j + 1, ln))
                    if ref[ln] >= end:
                        break
                    inner.append((ln, ref[ln] - ref[name]))
                    if lines[j].split(b";")[0].strip()[len(lm.group(1)) + 1:].strip():
                        sys.exit("%s:%d: %s's line holds more than the label" % (asm, j + 1, ln))
                elif lines[j].split(b";")[0].strip().startswith(b"."):
                    sys.exit("%s:%d: a directive inside %s's body" % (asm, j + 1, name))
                j += 1
            while j > i + 1 and not lines[j - 1].split(b";")[0].strip():   # the blank and comment lines before
                j -= 1                                                    # the next label stay with it
            j -= 1
        else:
            while True:
                if j >= len(lines):
                    sys.exit("%s: %s has no ret" % (asm, name))
                c = lines[j].split(b";")[0].strip()
                if LABEL_RE.match(lines[j]) or c.startswith(b"."):
                    sys.exit("%s:%d: a label or directive inside %s's body" % (asm, j + 1, name))
                if c.split()[:1] == [b"ret"] and len(c.split()) == 1:
                    break
                j += 1
        new = [n + b":\t" + inc + b"\t; C: " + rel_c.encode()]
        if inner:
            new.append(b"; the hand assembly's labels inside the compiled body, by their offsets")
            new += [b"\t.set\t%s, %s + %d" % (ln.encode(), n, off) for ln, off in inner]
        lines[i:j + 1] = new
        done.append(name)
    if done and not dry:
        open(asm, "wb").write(b"\n".join(lines))
    print("%s: %s %d function(s)%s" % (asm, "would splice" if dry else "spliced", len(done),
                                       (": " + " ".join(done)) if done else ""))


if __name__ == "__main__":
    main()
