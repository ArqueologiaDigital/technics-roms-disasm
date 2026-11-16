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

With --sizes TSV (with --symbols), the sizes come from TSV instead of the reference model: rows `tree  c_file  sha
options  run  function  bytes  result` as notes/cc900-phase6-2026-11-16/staged_v423.tsv writes them (the tree is
taken from TREE), or `function  bytes ...` (probe_v423.py --tsv); and the functions are read from FILE.c's text, so
C that only V4.23 compiles can be spliced.

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


FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def encodings(text):
    """llvm-mc -show-encoding -> [(instruction, its length in bytes)] in order"""
    import subprocess
    import check_bytes
    r = subprocess.run([os.path.join(check_bytes.LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-show-encoding"],
                       input=text, capture_output=True, text=True)
    out = []
    for l in r.stdout.splitlines():
        m = re.match(r'^\s+(.*?)\s*; encoding: \[(.*)\]', l)
        if m:
            out.append((m.group(1), len([x for x in m.group(2).split(",") if x])))
    return out


def c_functions(path):
    """the tree labels of the functions FILE.c defines, in order (the front end's names, through `cc900-name:`)"""
    if "--sizes" in sys.argv:                            # C the model may not compile: read the definitions
        labels = fw.label_map(path)
        return [labels.get(f, f) for f in FN_RE.findall(open(path, encoding="latin-1").read())]
    sys.path.insert(0, fw.MODEL)
    import frontend
    _, _, adecl = fw.file_options(path)
    labels = fw.label_map(path)
    return [labels.get(f.name, f.name) for f in frontend.load(path, [], [], adecl=adecl).functions]


def main():
    a = [x for i, x in enumerate(sys.argv[1:], 1) if not x.startswith("--") and sys.argv[i - 1] not in ("--symbols", "--sizes")]
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
        if "--sizes" in sys.argv:
            tname = os.path.normpath(tree).split(os.sep)[-2] if os.path.normpath(tree).endswith("maincpu") else tree
            sizes = {}
            for row in open(sys.argv[sys.argv.index("--sizes") + 1]):
                c = row.rstrip("\n").split("\t")
                if len(c) >= 8 and c[0] == tname and c[6].isdigit():
                    sizes[c[5]] = int(c[6])
                elif len(c) >= 2 and c[1].isdigit() and len(c) < 8:
                    sizes.setdefault(c[0], int(c[1]))
        else:
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
            if name not in sizes:
                sys.exit("%s: no size for %s" % (src, name))
            end = ref[name] + sizes[name]                # inner labels, kept as offsets from NAME
            while True:
                if j >= len(lines):
                    sys.exit("%s: %s runs past the end of the file" % (asm, name))
                lm = LABEL_RE.match(lines[j])
                if lm and lm.group(1).startswith(b".L"):   # an assembler-local label has no symbol: inner (and
                    if re.search(rb'[\s,]' + re.escape(lm.group(1)) + rb'\s*(;|$)',   # dropped) when a branch of the
                                 b"\n".join(lines[i:j]), re.M):                     # body so far targets it, else
                        j += 1                                                       # it starts the next block
                        continue
                    break
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
            # the hand lines up to the next outside label may run past the compiled body (a dead `ret`, code no
            # label marks): measure them with llvm-mc and cut where their bytes reach the C body's size; the rest
            # stays after the include line
            ins = [k for k in range(i + 1, j + 1) if lines[k].split(b";")[0].strip() and not LABEL_RE.match(lines[k])]
            enc = encodings("\n".join("\t" + lines[k].split(b";")[0].strip().decode("latin-1") for k in ins) + "\n")
            if len(enc) != len(ins):
                sys.exit("%s: %s: llvm-mc measured %d of %d hand instructions" % (asm, name, len(enc), len(ins)))
            total, cut = 0, None
            for k, (_, n_) in zip(ins, enc):
                total += n_
                if total == sizes[name]:
                    cut = k
                    break
                if total > sizes[name]:
                    break
            if cut is None:
                sys.exit("%s: %s: no run of hand instructions from its label is %d bytes long (the compiled size)"
                         % (asm, name, sizes[name]))
            j = cut                                      # the lines after the cut stay where they are
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
