#!/usr/bin/env python3
"""Firmware C code to assembly, with our own tools only: the build step of cc900 phase 6.

QUESTION ANSWERED: which instructions does our C for a firmware function compile to, under the compiler the
firmware was built with?  The compiler here is the cc900 reference model (scripts/analysis/cc900/model/: clang's
front end, then the model's code generator), personality `kn5000`, at the options the C file names in a comment
`cc900-options: -Xr` (one of OPTION_SETS), by default -O3 -XS -Xr (`--opt O3XS --adecl`); model/to_llvm.py writes its listing in our llvm-mc syntax with asm900's encodings.  No
Toshiba program is involved.  `make gate` then proves the result: the tree includes it in place of the function's
hand-written instructions, and the image must stay byte-identical.

usage: python3 -B scripts/build/cc900_firmware_c.py TREE FILE.c OUT_DIR STAMP
    TREE    the source tree whose names the C uses (v10/maincpu)
    FILE.c  firmware C, one or more functions (TREE/cc900/*.c)
    OUT_DIR where each function's assembly goes, as OUT_DIR/<function>.s (TREE/includes/generated/cc900)
    STAMP   written last: the list of the functions this FILE.c produced.  Files a previous run listed that this
            run no longer produces are removed, so a function taken out of the C cannot linger.

Each OUT_DIR/<function>.s is the body only.  The tree keeps the function's label and header comment and includes
the body on the label's line:

    SetLswFilter:	.include "includes/generated/cc900/SetLswFilter.s"

Names.  The C names the tree's symbols by their own names (`extern long LSW_FILTER;`), and the generated assembly
spells them the same way, so the tree's `.equ` (or label) supplies the value.  The value is still read here, from
TREE's `.equ` / `.set` lines, because asm900 chooses an absolute operand's width from it: `(NAME:16)` below
0x10000, `(NAME:24)` above (model/to_llvm.py).  A RAM cell the tree has not named yet is written in the C as
`ram_<hex address>` (`extern unsigned char ram_8d3e;`) and comes out as the number, as the hand assembly had it.
A called function is spelled by name and needs no address.  Local labels become `.Lcc900_<function>_<label>`.

The environment variables the model reads (CC900_*) are cleared, so the build always runs the model's defaults;
CC900_MODEL_CLANG is kept (the Makefile sets it to its own clang).
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
MODEL = os.path.join(REPO, "scripts", "analysis", "cc900", "model")
LLVM_BIN = os.path.join(os.environ.get("PROJECTS_ROOT", os.path.expanduser("~/compartilhado")),
                        "llvm-project", "build", "bin")
OPTIONS = dict(opt="O3XS", adecl=True, personality="kn5000")   # the default: -O3 -XS -Xr
# A C file may name its own options in a comment, `cc900-options: -Xr` (the first such comment counts).  The sets the
# reference model compiles, as cc900 flags -> (model opt, adecl):
OPTION_SETS = {"-O3 -XS -Xr": ("O3XS", True), "-Xr": ("none", True), "-O3 -XS": ("O3XS", False), "": ("none", False)}
OPT_RE = re.compile(rb'cc900-options:([^*\n]*)')
# cc900 keeps the first 31 characters of an identifier (V4.23: THC1-Error-262 when two agree in them), so a C name
# may be shorter than the tree's label.  A comment `cc900-name: CNAME=LABEL` (one per pair, anywhere in the file)
# maps it; the generated file, the splice and the byte checks then use LABEL.
NAME_RE = re.compile(rb'cc900-name:\s*([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)')
C_NAME_LIMIT = 31
EQU_RE = re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_][\w.]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;|$)')
RAM_CELL_RE = re.compile(r'^ram_([0-9a-f]+)$')

for k in [k for k in os.environ if k.startswith("CC900_") and k != "CC900_MODEL_CLANG"]:
    del os.environ[k]
sys.path.insert(0, MODEL)


def tree_values(tree):
    """{name: value} of every numeric `.equ` / `.set` in TREE's .s files; a name set to two values maps to None"""
    vals = {}
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != "generated")
        for f in sorted(fn):
            if not f.endswith(".s"):
                continue
            for ln in open(os.path.join(dp, f), "rb").read().split(b"\n"):
                m = EQU_RE.match(ln)
                if m:
                    n, v = m.group(1).decode(), int(m.group(2), 0)
                    vals[n] = v if vals.get(n, v) == v else None
    return vals


class Names(dict):
    """to_llvm's SYMBOLS and SPELL in one: a C name resolves to the tree's value (spelled by its name), to a
    `ram_<hex>` cell (spelled as the number), or to a label of the symbols reference file (spelled by name)."""

    def __init__(self, values, labels=None):
        super().__init__()
        self.values, self.labels = values, labels or {}

    def resolve(self, n):
        m = RAM_CELL_RE.match(n)
        if m:
            return int(m.group(1), 16), None
        if self.values.get(n) is not None:
            return self.values[n], n
        if n in self.values:
            raise KeyError("%s has two values in the tree; cannot choose its operand width" % n)
        if n in self.labels:
            return self.labels[n], n
        return None, None

    def __contains__(self, n):
        return self.resolve(n)[0] is not None

    def __getitem__(self, n):
        a, _ = self.resolve(n)
        if a is None:
            raise KeyError(n)
        return a

    def get(self, n, default=None):          # SPELL.get: the spelling, None for a number
        return self.resolve(n)[1] if n in self else default


def file_options(path):
    """the options FILE.c asks for: (cc900 flags, model opt, adecl)"""
    m = OPT_RE.search(open(path, "rb").read())
    if not m:
        return "-O3 -XS -Xr", OPTIONS["opt"], OPTIONS["adecl"]
    flags = " ".join(m.group(1).decode().split())
    if flags not in OPTION_SETS:
        sys.exit("%s: cc900-options %r is not one the reference model compiles (%s)"
                 % (path, flags, ", ".join(repr(k) for k in OPTION_SETS)))
    return (flags,) + OPTION_SETS[flags]


REFUSED = {}                                             # compile_c: {function: the model's "unsupported" reason}


def label_map(path):
    """{C name: the tree's label} from FILE.c's `cc900-name:` comments"""
    return {m.group(1).decode(): m.group(2).decode() for m in NAME_RE.finditer(open(path, "rb").read())}


def check_c_names(path, cnames):
    """stop when two C names of FILE.c agree in their first 31 characters (V4.23 could not compile the file)"""
    seen = {}
    for n in cnames:
        k = n[:C_NAME_LIMIT]
        if k in seen and seen[k] != n:
            sys.exit("%s: %s and %s agree in their first %d characters, which cc900 keeps; give one a shorter C "
                     "name and a `cc900-name: CNAME=LABEL` comment" % (path, seen[k], n, C_NAME_LIMIT))
        seen[k] = n


def compile_c(path, names, spell=True):
    """FILE.c -> {function: [llvm-mc lines]} through the reference model and to_llvm (asm900's jr / jrl choice
    included).  spell=False writes every name as its address (scripts/analysis/cc900/model/fn_diff.py assembles a
    function on its own).  Raises SystemExit on a line to_llvm cannot translate."""
    import frontend
    import codegen
    import to_llvm
    _, opt, adecl = file_options(path)
    unit = frontend.load(path, [], [], adecl=adecl)
    out = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=OPTIONS["personality"])
    to_llvm.SPELL = names if spell else None
    check_c_names(path, [f.name for f in unit.functions])
    labels = label_map(path)
    funcs = {}
    REFUSED.clear()
    for name, lines in out.items():
        if lines and lines[0].startswith("; unsupported"):
            n = name.lstrip("_.")
            REFUSED[labels.get(n, n)] = lines[0][2:]       # the model declines this C (fn_diff.py reports it)
            continue
        if not lines or not lines[0].endswith(":") or lines[0][:-1] != name:
            continue                                       # data objects
        bare = labels.get(name.lstrip("_."), name.lstrip("_."))
        if bare != name.lstrip("_."):                      # a short C name: the body is the tree label's
            lines = [bare + ":" if l == name + ":" else l for l in lines]
            name = bare
        body = to_llvm.translate_function(name, lines, names)
        locals_ = {l[:-1] for l in lines if l.endswith(":") and not l.startswith("\t") and l[:-1] != name}
        text = []
        for l in body:
            if l in ("\t.globl %s" % bare, bare + ":"):
                continue
            for lab in locals_:
                l = re.sub(r'(?<![\w.])%s(?![\w])' % re.escape(lab), ".Lcc900_%s_%s" % (bare, lab), l)
            text.append(l)
        bad = [l for l in text if "untranslated" in l]
        if bad:
            sys.exit("%s: %s: to_llvm cannot translate:\n%s" % (path, bare, "\n".join(bad)))
        funcs[bare] = to_llvm.relax("\n".join(text), assembler_errors).split("\n")
    return funcs


def assembler_errors(text):
    r = subprocess.run([os.path.join(LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-o", os.devnull],
                       input=text, capture_output=True, text=True)
    return r.stderr


def tabbed(line):
    """`\tld (xwa), 0x0` -> `\tld\t(xwa), 0x0` (the tree's tab after the mnemonic)"""
    return re.sub(r'^\t([\w.]+) ', '\t\\1\t', line)


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    tree, src, outdir, stamp = sys.argv[1:]
    funcs = compile_c(src, Names(tree_values(tree)))
    if REFUSED:
        sys.exit("%s: the reference model does not compile: %s" % (
            src, "; ".join("%s (%s)" % kv for kv in sorted(REFUSED.items()))))
    if not funcs:
        sys.exit("%s: no function compiled" % src)
    os.makedirs(outdir, exist_ok=True)
    relsrc = os.path.relpath(src, tree)
    flags = file_options(src)[0] or "no options"
    for f, lines in funcs.items():
        hdr = ["; GENERATED by scripts/build/cc900_firmware_c.py -- do not edit.",
               "; %s, compiled from %s by the cc900 reference model (scripts/analysis/cc900/model/," % (f, relsrc),
               "; %s, personality kn5000) and model/to_llvm.py.  The label is on the including line." % flags]
        with open(os.path.join(outdir, f + ".s"), "w") as fh:
            fh.write("\n".join(hdr + [tabbed(l) for l in lines]) + "\n")
    if os.path.exists(stamp):
        out_abs = os.path.realpath(outdir)
        for old in open(stamp).read().split():
            if old in funcs:
                continue
            p = os.path.realpath(os.path.join(outdir, old + ".s"))
            assert os.path.dirname(p) == out_abs and p.endswith(".s"), p
            if os.path.exists(p):
                os.remove(p)
    with open(stamp, "w") as fh:
        fh.write("\n".join(sorted(funcs)) + "\n")
    print("%s: %d function(s): %s" % (src, len(funcs), " ".join(sorted(funcs))))


if __name__ == "__main__":
    main()
