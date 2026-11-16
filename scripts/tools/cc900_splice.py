#!/usr/bin/env python3
"""Put firmware C functions into the tree in place of their hand assembly (cc900 phase 6).

usage: python3 scripts/tools/cc900_splice.py TREE FILE.c [--symbols REF] [--sizes TSV] [--elf ELF] [--dry-run]
    TREE    v10/maincpu, v142/subcpu, hdae5000 ...
    FILE.c  TREE/cc900/<name>.c.  Its first comment names the hand source as "Functions of <path>.s" (relative to
            TREE; else the first <path>.s the comment names).  Every function FILE.c defines is spliced into it.
    ELF     the built image whose bytes measure the hand lines (default: the tree's rebuilt_ROMs/*.elf when it
            exists).  Without one, llvm-mc measures the lines on their own, which fails on symbolic displacements
            (`(xwa + WS_HamaFnTable)`), the tree's macros (ld_sril) and widths only the tree's .equ values decide.

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


DATA_UNIT = {b".byte": 1, b".short": 2, b".hword": 2, b".word": 2, b".2byte": 2, b".long": 4, b".int": 4, b".4byte": 4}


def data_size(c):
    """the bytes a data directive line emits (.byte / .short / .long ..., .zero N, .fill N[,S], .ascii / .asciz /
    .string "..."), None for any other directive (.set, .equ, .include, .balign, .if ...): those stop the splice,
    which cannot know their bytes or must not drop what they define"""
    p = c.split(None, 1)
    d, arg = p[0], (p[1] if len(p) > 1 else b"")
    if d in DATA_UNIT:
        return DATA_UNIT[d] * len([x for x in re.split(rb',(?![^"]*"[^"]*$)', arg) if x.strip()])
    if d in (b".zero", b".space", b".skip") and re.match(rb'^\s*(0x[0-9a-fA-F]+|\d+)\s*$', arg):
        return int(arg.strip(), 0)
    if d == b".fill":
        f = [x.strip() for x in arg.split(b",")]
        if all(re.match(rb'^(0x[0-9a-fA-F]+|\d+)$', x) for x in f[:2]):
            return int(f[0], 0) * (int(f[1], 0) if len(f) > 1 else 1)
    if d in (b".ascii", b".asciz", b".string"):
        try:
            import ast
            total = 0
            for s in re.findall(rb'"(?:[^"\\]|\\.)*"', arg):
                total += len(ast.literal_eval("b" + s.decode("latin-1"))) + (d != b".ascii")
            return total
        except (ValueError, SyntaxError):
            return None
    return None


def image_sizes(elf, addr, lines):
    """[(line, its size)] of the hand lines from addr on, measured in the built image: a data line by data_size(),
    an instruction by llvm-objdump's decoding at its address (re-decoded after data).  None when the image cannot be
    read there (no ELF, or llvm-objdump finds no instruction at an address)"""
    import subprocess
    import check_bytes
    if not elf or not os.path.exists(elf):
        return None
    decoded = {}

    def decode(at):
        out = subprocess.run([os.path.join(check_bytes.LLVM_BIN, "llvm-objdump"), "-d", "--start-address=0x%x" % at,
                              "--stop-address=0x%x" % (at + 0x400), elf], capture_output=True, text=True).stdout
        for l in out.splitlines():
            m = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(\S*)', l)
            if m:                                        # `<unknown>`: an encoding llvm-objdump does not decode
                decoded.setdefault(int(m.group(1), 16),  # (and (xde+hl), a): measured by llvm-mc below
                                   None if m.group(3) == "<unknown>" else len(m.group(2).split()))
    res = []
    for c in lines:
        n = data_size(c) if c.startswith(b".") else None
        if n is None:
            if addr not in decoded:
                decode(addr)
            if addr not in decoded:
                return None
            n = decoded[addr]
            if n is None:
                enc = encodings("\t" + c.decode("latin-1") + "\n")
                if len(enc) != 1:
                    return None
                n = enc[0][1]
        res.append((c, n))
        addr += n
    return res


ELF_OF_TREE = {"v142/subcpu": "kn5000_subprogram_v142.llvm.elf", "v141/subcpu": "kn5000_subprogram_v141.llvm.elf",
               "v140/subcpu": "kn5000_subprogram_v140.llvm.elf", "hdae5000": "hd-ae5000_v2_06i.llvm.elf",
               "hdae5000_v2_01i": "hd-ae5000_v2_01i.llvm.elf", "hdae5000_v1_15i": "hd-ae5000_v1_15i.llvm.elf",
               "hdae5000_v1_10i": "hd-ae5000_v1_10i.llvm.elf"}


def tree_elf(tree):
    """the built image of TREE (rebuilt_ROMs/...elf), or None"""
    t = os.path.relpath(os.path.abspath(tree), fw.REPO)
    name = ELF_OF_TREE.get(t) or ("kn5000_%s_program.llvm.elf" % t.split(os.sep)[0] if t.endswith("maincpu") else None)
    p = os.path.join(fw.REPO, "rebuilt_ROMs", name) if name else None
    return p if p and os.path.exists(p) else None


def c_functions(path):
    """the tree labels of the functions FILE.c defines, in order (the front end's names, through `cc900-name:`)"""
    if "--sizes" in sys.argv:                            # C the model may not compile: read the definitions
        labels = fw.label_map(path)
        return [labels.get(f, f) for f in fw.c_functions(path)]   # the generator's reader (comments out, K&R)
    sys.path.insert(0, fw.MODEL)
    import frontend
    _, _, adecl = fw.file_options(path)
    labels = fw.label_map(path)
    return [labels.get(f.name, f.name) for f in frontend.load(path, [], [], adecl=adecl).functions]


def main():
    a = [x for i, x in enumerate(sys.argv[1:], 1)
         if not x.startswith("--") and sys.argv[i - 1] not in ("--symbols", "--sizes", "--elf")]
    if len(a) != 2:
        sys.exit(__doc__)
    tree, src = a
    elf = sys.argv[sys.argv.index("--elf") + 1] if "--elf" in sys.argv else tree_elf(tree)
    dry = "--dry-run" in sys.argv
    text = open(src, "rb").read()
    m = re.search(rb'Functions of (\S+\.s)\b', text)
    if not m:                                            # lane_hd's headers: "The lyric-display module of X.s ..."
        first = re.match(rb'\s*/\*(.*?)\*/', text, re.S)
        m = re.search(rb'\b([\w./-]+\.s)\b', first.group(1)) if first else None
    named = os.path.join(tree, m.group(1).decode()) if m else None
    rel_c = os.path.relpath(src, tree)
    ref = sizes = None
    if "--symbols" in sys.argv:                          # functions with inner labels and several rets
        import check_bytes
        ref = check_bytes.load_reference(sys.argv[sys.argv.index("--symbols") + 1])
        if "--sizes" in sys.argv:
            # staged_v423.tsv names a tree by its version (v10, v142) or directory (hdae5000)
            tname = os.path.normpath(tree).split(os.sep)[-2] if os.path.normpath(tree).endswith(("maincpu", "subcpu")) \
                else os.path.basename(os.path.normpath(tree))
            sizes = {}
            # --sizes may repeat: a staged_v423.tsv (tree, file, sha, options, run, function, size, verdict), a
            # verdicts/<run>.tsv of lane_sub (function, ROM bytes, the probes that match or `-`), or name<TAB>size
            for k, x in enumerate(sys.argv):
                if x != "--sizes":
                    continue
                for row in open(sys.argv[k + 1]):
                    c = row.rstrip("\n").split("\t")
                    if len(c) >= 8 and c[0] == tname and c[6].isdigit():
                        sizes[c[5]] = int(c[6])
                    elif len(c) == 4 and c[1].isdigit():
                        if c[2].strip() not in ("", "-"):    # only a function some probe matches
                            sizes.setdefault(c[0], int(c[1]))
                    elif len(c) >= 2 and c[1].isdigit() and len(c) < 8:
                        sizes.setdefault(c[0], int(c[1]))
        else:
            funcs = fw.compile_c(src, fw.Names(fw.tree_values(tree), ref), spell=False)
            if fw.REFUSED:
                sys.exit("%s: the model refuses %s" % (src, ", ".join(fw.REFUSED)))
            sizes = {f: len(check_bytes.assemble("\t.text\n\t.globl %s\n%s:\n%s\n" % (f, f, "\n".join(l)))[f])
                     for f, l in funcs.items()}
    files = {}                                           # each hand source touched: its lines
    index = {}                                           # label -> the tree's .s files defining it (built on demand)

    def source_of(name):
        """the hand source defining NAME: the file the header names when it does, else the one file of the tree
        (os.walk, read as bytes) whose column-0 label it is -- the HD-AE5000 ports' headers name only the C file"""
        n = name.encode()
        if named and os.path.exists(named):
            files.setdefault(named, open(named, "rb").read().split(b"\n"))
            if any(re.match(rb'^' + re.escape(n) + rb':', l) for l in files[named]):
                return named
        if not index:
            for d, _, fs in os.walk(tree):
                for f in sorted(fs):
                    if f.endswith(".s") and "/includes/generated" not in d:
                        p = os.path.join(d, f)
                        for lab in re.findall(rb'^([A-Za-z_][\w.]*):', open(p, "rb").read(), re.M):
                            index.setdefault(lab, []).append(p)
        where = sorted(set(index.get(n, [])))
        if len(where) != 1:
            sys.exit("%s: %s is defined in %d .s files of %s%s" % (src, name, len(where), tree,
                     "" if named else " (and its header comment names no hand source)"))
        files.setdefault(where[0], open(where[0], "rb").read().split(b"\n"))
        return where[0]

    done = {}
    for name in c_functions(src):
        n = name.encode()
        asm = source_of(name)
        lines = files[asm]
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
            # the hand lines up to the next label of the symbols reference (an assembler-local `.L` label has no
            # symbol: it is inner when any branch up to that next label targets it, backwards or forwards --
            # SwapBytes32's `.LSwapBytes32__loop`, reached only by the `jr lt` after it)
            nxt = i + 1
            while nxt < len(lines) and not (LABEL_RE.match(lines[nxt]) and
                                            not LABEL_RE.match(lines[nxt]).group(1).startswith(b".L")):
                nxt += 1
            region = b"\n".join(l.split(b";")[0] for l in lines[i:nxt])
            while True:
                if j >= len(lines):
                    sys.exit("%s: %s runs past the end of the file" % (asm, name))
                lm = LABEL_RE.match(lines[j])
                if lm and lm.group(1).startswith(b".L"):
                    if re.search(rb'[\s,(]' + re.escape(lm.group(1)) + rb'\s*[),]?\s*$', region, re.M):
                        j += 1                                   # inner (and dropped: no symbol to keep)
                        continue
                    break                                        # it starts the next block
                if lm:
                    ln = lm.group(1).decode()
                    if ln not in ref:
                        sys.exit("%s:%d: %s is not in the symbols reference" % (asm, j + 1, ln))
                    if ref[ln] >= end:
                        break
                    inner.append((ln, ref[ln] - ref[name]))
                    if lines[j].split(b";")[0].strip()[len(lm.group(1)) + 1:].strip():
                        sys.exit("%s:%d: %s's line holds more than the label" % (asm, j + 1, ln))
                else:
                    c = lines[j].split(b";")[0].strip()
                    if c.startswith(b".") and data_size(c) is None:
                        sys.exit("%s:%d: inside %s's body, a directive that emits no measurable bytes or defines "
                                 "something (%s): splice it by hand" % (asm, j + 1, name, c.split()[0].decode()))
                j += 1
            while j > i + 1 and not lines[j - 1].split(b";")[0].strip():   # the blank and comment lines before
                j -= 1                                                    # the next label stay with it
            j -= 1
            # the hand lines up to the next outside label may run past the compiled body (a dead `ret`, code no
            # label marks): measure them and cut where their bytes reach the C body's size; the rest stays after
            # the include line.  The sizes come from the built image when there is one (each instruction as the
            # whole tree assembled it: symbolic displacements such as (xwa + WS_HamaFnTable), macros such as
            # ld_sril and operand widths only the tree's .equ values decide), else from llvm-mc on the lines alone
            ins = [k for k in range(i + 1, j + 1) if lines[k].split(b";")[0].strip() and not LABEL_RE.match(lines[k])]
            enc = image_sizes(elf, ref[name], [lines[k].split(b";")[0].strip() for k in ins]) if elf else None
            if enc is None:
                enc = encodings("\n".join("\t" + lines[k].split(b";")[0].strip().decode("latin-1") for k in ins) + "\n")
                if len(enc) != len(ins):
                    sys.exit("%s: %s: llvm-mc measured %d of %d hand instructions on their own (a symbolic "
                             "displacement, a macro or an unknown name stops it); build the image and pass --elf"
                             % (asm, name, len(enc), len(ins)))
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
        done.setdefault(asm, []).append(name)
    for asm, names in sorted(done.items()):
        if not dry:
            open(asm, "wb").write(b"\n".join(files[asm]))
        print("%s: %s %d function(s): %s" % (asm, "would splice" if dry else "spliced", len(names), " ".join(names)))
    if not done:
        print("%s: nothing to splice" % src)


if __name__ == "__main__":
    main()
