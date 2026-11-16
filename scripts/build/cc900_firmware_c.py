#!/usr/bin/env python3
"""Firmware C code to assembly: the build step of cc900 phase 6.

QUESTION ANSWERED: which instructions does our C for a firmware function compile to, under the compiler the
firmware was built with?  Two compilers give the same bodies (`make gate` passes with either; the Makefile's
CC900_COMPILER chooses):

  --v423 CACHE  (CC900_COMPILER=v423, the default) Toshiba cc900 V4.23 itself.  scripts/build/cc900_v423.py has
                compiled FILE.c in the oracle VM and cached its listing in CACHE (git-ignored); this reads it.
  (no option)   (CC900_COMPILER=model) the cc900 reference model (scripts/analysis/cc900/model/: clang's front end,
                then the model's code generator, personality `kn5000`, with FIRMWARE_RULES switched on); our own tools
                only.  The model is paused and does not cover all the C V4.23 compiles: when it refuses a function,
                its options or a declaration, the step stops, names the file and the function or declaration, says
                the model does not support it and that the default V4.23 build does, and writes nothing.

Either way model/to_llvm.py writes the listing in our llvm-mc syntax with asm900's encodings, at the options the C
file names in a comment `cc900-options: -O3 -Xr` (any flag string for V4.23; the model compiles OPTION_SETS), by
default DEFAULT_FLAGS, -O3 -Xr.  `make gate` then proves the result: the tree includes it in place of the
function's hand-written instructions, and the image must stay byte-identical.

usage: python3 -B scripts/build/cc900_firmware_c.py [--v423 CACHE] TREE FILE.c OUT_DIR STAMP
    TREE    the source tree whose names the C uses (v10/maincpu)
    FILE.c  firmware C, one or more functions (TREE/cc900/*.c)
    OUT_DIR where each function's assembly goes, as OUT_DIR/<function>.s (TREE/includes/generated/cc900)
    STAMP   written last: the list of the functions this FILE.c produced.  Files a previous run listed that this
            run no longer produces are removed, so a function taken out of the C cannot linger.

Each OUT_DIR/<function>.s is the body only.  The tree keeps the function's label and header comment and includes
the body on the label's line:

    SetLswFilter:	.include "includes/generated/cc900/SetLswFilter.s"

Names.  The C names the tree's symbols by their own names (`extern long LSW_FILTER;`), and the generated assembly
spells them the same way, so the tree's `.equ` (or label) supplies the value.  A RAM cell the tree has not named yet
is written in the C as `ram_<hex address>` (`extern unsigned char __near ram_8d3e;`) and comes out as the number, as
the hand assembly had it.  A called function, and any other label of the tree (ROM data such as
`FileIO_DiskInfoInit`), is spelled by name.  V4.23 keeps 31 characters of a name; a cut name is mapped back to the
tree's full one.  Local labels become `.Lcc900_<function>_L<n>`, numbered in order of appearance.

Operand widths.  cc900 gives a symbol's absolute operand the width of its declaration, not of its address: `__tiny`
8-bit, `__near` 16-bit, plain (large) 24-bit (probe m16, run 2026-11-16-29-p6-m16).  V4.23's listing declares them
(`extern small|medium|large`, model/listing.attributes) and to_llvm.WIDTHS takes them from there, checked against
the C's own qualifiers (listing_widths); the model takes them from the C (c_widths).  A symbol without one stops
the step.  V4.23 qualifies only the first declarator of a declaration, so a qualified declaration names one object
(scripts/tools/cc900_near_qualifiers.py writes them).  Numeric absolute operands keep the address rule.

Calls.  V4.23 writes `cal` / `j`; asm900 makes them calr / jr (jrl when jr does not reach) for a function in the same
file and section, call / jp for an extern -- call16 / jp16 for a __near or __tiny one (probe calrel, run
2026-11-16-42-p6-calrel; scripts/analysis/cc900/calrel_check.py).  Our C files group functions by hand source, not
by the firmware's original module (lane_sub: functions of one C file that call each other with an absolute call), so
file membership says nothing: only a comment `cc900-module: Label1 Label2 ...` makes a callee module-local
(to_llvm.MODULE = module_names).  It names the tree labels that shared the caller's original module and section.  Each
entry is a claim about the original build that `make gate` checks; its evidence is the hand assembly's calr / jr /
jrl, and an inferred module map (calr joins, a near absolute call separates) can propose the list.

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
OPTIONS = dict(opt="O3XS", adecl=True, personality="kn5000")   # the model's default set (DEFAULT_FLAGS)
# A C file may name its own options in a comment, `cc900-options: -Xr` (the first such comment counts).  The sets the
# reference model compiles, as cc900 flags -> (model opt, adecl).  V4.23 (the default build) takes any flag string.
# -O3 -Xr (without -XS) is how the firmware's -O files were compiled (lane_p6, run 2026-11-16-32-p6-m18): V4.23 then
# copies a loop's test to its entry, which the model writes as its O3XS code plus the firmware rule KN_LOOP_INVERT.
OPTION_SETS = {"-O3 -XS -Xr": ("O3XS", True), "-O3 -Xr": ("O3XS", True), "-Xr": ("none", True),
               "-O3 -XS": ("O3XS", False), "": ("none", False)}
OPT_RE = re.compile(rb'cc900-options:([^*\n]*)')
# the flags of a file that names none: -O3 -Xr, how the firmware's own files were compiled (run 2026-11-16-32-p6-m18,
# coordinator 2026-11-16; until then -O3 -XS -Xr, which V4.23 compiles to the same bytes for every built file but
# TrimAndPadSmfFilename, lane_p6 run 2026-11-16-33)
DEFAULT_FLAGS = "-O3 -Xr"
# cc900 keeps the first 31 characters of an identifier (V4.23: THC1-Error-262 when two agree in them), so a C name
# may be shorter than the tree's label.  A comment `cc900-name: CNAME=LABEL` (one per pair, anywhere in the file)
# maps it; the generated file, the splice and the byte checks then use LABEL.
NAME_RE = re.compile(rb'cc900-name:\s*([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)')
# Rules of the Technics compiler seen in Matsushita's own code but not in the library it links (which Toshiba's tools
# built, and which the model's kn5000 ledger rows score): codegen flags that are off in the model and that this
# build switches on.  KN_LOOP_INVERT: rule loop-entry-copy (notes/cc900-compat-plan-2026-11-08/rules.md).
# KN_SHIFT_UNSIGNED_SLL: a shift left by a variable count of an unsigned value is sll, where V4.23 writes sla
# (coordinator decision 2026-11-16; file_demo_proc.s's FileIO_* bit functions, probe p6_m9c.c).
# KN_MEM_TO_MEM: with -O only, a copy of 8 / 16 bits with a 16-bit absolute side whose value is not used again is one
# memory-to-memory move (ld (#16),(mem) / ld (mem),(#16)); the model's rule must test -O itself, so that the firmware's
# -Xr files keep their register copies (notes/cc900-phase6-2026-11-16/README.md, the memory-to-memory census).
FIRMWARE_RULES = ("KN_LOOP_INVERT", "KN_SHIFT_UNSIGNED_SLL", "KN_MEM_TO_MEM")
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


LABEL_RE = re.compile(rb'^([A-Za-z_][\w]*):')
ROM_LABEL = 0xE00000          # a label of the tree's code or data: in the main CPU's ROM, so above 0x10000 (24-bit)


def tree_labels(tree):
    """{label: ROM_LABEL} for every column-0 label of TREE's .s files.  The value only tells to_llvm that the operand
    is 24-bit; the generated code names the label, and the tree's own definition gives the address."""
    labs = {}
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != "generated")
        for f in sorted(fn):
            if f.endswith(".s"):
                for ln in open(os.path.join(dp, f), "rb").read().split(b"\n"):
                    m = LABEL_RE.match(ln)
                    if m:
                        labs[m.group(1).decode()] = ROM_LABEL
    return labs


class Names(dict):
    """to_llvm's SYMBOLS and SPELL in one: a C name resolves to the tree's value (spelled by its name), to a
    `ram_<hex>` cell (spelled as the number), or to a label of the symbols reference file (spelled by name)."""

    def __init__(self, values, labels=None, cut=False):
        super().__init__()
        self.values, self.labels = values, labels or {}
        self.cut = None
        if cut:                                  # V4.23 keeps 31 characters of a name: {cut name: [full names]}
            self.cut = {}
            for n in set(labels or ()) | {k for k, v in values.items() if v is not None}:
                if len(n) > C_NAME_LIMIT:
                    self.cut.setdefault(n[:C_NAME_LIMIT], set()).add(n)

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
        if self.cut and len(self.cut.get(n, ())) == 1:     # a name V4.23 cut to 31 characters: the tree's full name
            full = next(iter(self.cut[n]))
            return self.resolve(full)[0], full
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


def file_flags(path):
    """the cc900 flags FILE.c asks for (`cc900-options:`, default DEFAULT_FLAGS), any flag string: V4.23 takes them as
    they are (scripts/build/cc900_v423.py); file_options() checks that the model compiles them"""
    m = OPT_RE.search(open(path, "rb").read())
    return " ".join(m.group(1).decode().split()) if m else DEFAULT_FLAGS


def file_options(path):
    """the options FILE.c asks for: (cc900 flags, model opt, adecl)"""
    flags = file_flags(path)
    if flags not in OPTION_SETS:
        sys.exit("%s: cc900-options %r is not one the reference model compiles (%s)"
                 % (path, flags, ", ".join(repr(k) for k in OPTION_SETS)))
    return (flags,) + OPTION_SETS[flags]


REFUSED = {}                                             # compile_c: {function: the model's "unsupported" reason}


MODULE_RE = re.compile(rb'cc900-module:([^*\n]*)')


def module_names(path):
    """the names FILE.c's `cc900-module:` comments list (blank- or comma-separated; any number of comments): tree
    labels that were in the same section of the firmware's original source module as this file's functions.  asm900
    saw them, so it assembled V4.23's CAL / J to them as calr / jr / jrl, which to_llvm.MODULE reproduces.  An entry
    is a claim about the original build, and `make gate` checks it: a wrong one changes the bytes.  The evidence for
    one is the ROM itself (the hand assembly's calr / jr / jrl to it)."""
    out = set()
    for m in MODULE_RE.finditer(open(path, "rb").read()):
        out.update(n for n in re.split(r'[\s,]+', m.group(1).decode()) if n)
    return out


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
    for flag in FIRMWARE_RULES:                          # rules of the firmware's own C, off in the model elsewhere
        if hasattr(codegen, flag):
            setattr(codegen, flag, True)
    unit = frontend.load(path, ["__near=", "__tiny="], [], adecl=adecl)   # the qualifiers are read by c_widths
    out = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=OPTIONS["personality"])
    to_llvm.SPELL = names if spell else None
    to_llvm.WIDTHS = c_widths(path, model=True)
    to_llvm.MODULE = module_names(path)                  # only the marking, never file membership
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
        funcs[bare] = finish(path, name, bare, lines, names)
    return funcs


QUALIFIER_WIDTH = {"__tiny": 8, "__near": 16}


def file_scope_declarations(path, prototypes=False):
    """FILE.c's file-scope declarations without a parameter list (objects), or with prototypes=True those with one
    (prototypes and function-pointer objects); comments removed"""
    src = open(path, "rb").read().decode("latin-1")
    src = re.sub(r'/\*.*?\*/', ' ', src, flags=re.S)
    src = re.sub(r'//[^\n]*', '', src)
    src = re.sub(r'^\s*#[^\n]*', '', src, flags=re.M)
    out, cur, depth = [], "", 0
    for ch in src:
        if depth == 0 and ch == "{" and ")" in cur:          # a function body: drop its head and skip the body
            cur, depth = "", 1
            continue
        if depth:
            depth += {"{": 1, "}": -1}.get(ch, 0)
            continue
        if ch == ";":
            s = " ".join(cur.split())
            if s and ("(" in s) == prototypes and not s.startswith("typedef"):
                out.append(s)
            cur = ""
        else:
            cur += ch
    return out


def c_widths(path, model=False):
    """{object name: 8, 16 or 24}: the absolute-operand width cc900 gives each file-scope object FILE.c declares --
    `__tiny` 8, `__near` 16, else 24 (probe m16).  V4.23 applies a qualifier to the first declarator only (run
    2026-11-16-30-p6-r1), so a qualified declaration must name one object; a qualifier before a `*` qualifies what
    the pointer points to, not the pointer.  model=True also refuses a qualified array: V4.23 indexes one with
    other code than a large array, which the reference model does not reproduce."""
    out = {}
    for s in file_scope_declarations(path):
        s = re.sub(r'=\s*\{.*\}', '', s)
        decls = [d.strip() for d in s.split(",")]
        quals = [q for q in QUALIFIER_WIDTH if re.search(r'\b%s\b' % q, s)]
        if quals and len(decls) > 1:
            sys.exit("%s: `%s;`: V4.23 applies %s to the first name only; declare one name per declaration"
                     % (path, s, quals[0]))
        for d in decls:
            d = d.split("=")[0].strip()
            m = re.search(r'([A-Za-z_]\w*)\s*(\[[^\]]*\]\s*)*$', d)
            if not m:
                continue
            w = 24
            for q in quals:
                at = re.search(r'\b%s\b' % q, d)
                if at and "*" not in d[at.end():]:              # the object itself is qualified
                    w = QUALIFIER_WIDTH[q]
                    if model and "[" in d:
                        sys.exit("%s: `%s;`: the reference model does not reproduce V4.23's indexing of a %s "
                                 "array.%s" % (path, s, q, MODEL_HINT))
            out[m.group(1)] = w
    for s in file_scope_declarations(path, prototypes=True):   # functions: CAL / J take call16 / jp16 for a
        m = re.search(r'\(\s*\*\s*([A-Za-z_]\w*)', s)           # __near or __tiny one (probe calrel)
        if m:                                                 # a function-pointer object: a large datum
            out.setdefault(m.group(1), 24)
            continue
        m = re.search(r'([A-Za-z_]\w*)\s*\(', s)
        if m:
            head = s[:m.start()]
            q = [q for q in QUALIFIER_WIDTH if re.search(r'\b%s\b' % q, head)]
            out[m.group(1)] = 16 if q else 24    # V4.23 declares a __tiny function `medium` too (probe calrel)
    for f in c_functions(path):                               # defined here: in the code section, large
        out.setdefault(f, 24)
    return out


C_KEYWORDS = {"if", "while", "for", "switch", "return", "sizeof", "do", "else"}


def c_functions(path):
    """the names of the functions FILE.c defines (definitions start in column 0, as in every firmware C file)"""
    src = open(path, "rb").read().decode("latin-1")
    src = re.sub(r'/\*.*?\*/', ' ', src, flags=re.S)
    src = re.sub(r'//[^\n]*', '', src)
    return [n for n in re.findall(r'^(?![ \t#])[\w \t*]*?\b([A-Za-z_]\w*)\s*\([^;{}]*\)\s*\{', src, re.M)
            if n not in C_KEYWORDS]


def listing_functions(text):
    """a cc900 listing (`.asm`) -> {function: [lines]} as model/listing.py's split gives them, with the section lines
    before each label dropped and a label that is not public kept inside the function before it"""
    import listing
    pubs = set(re.findall(r'(?im)^\s*public\s+([._\w]+)', text))
    fs = {}
    for k, v in listing.split(text).items():
        v = v[[i for i, l in enumerate(v) if l == k + ":"][0]:]
        if k not in pubs and fs:
            fs[list(fs)[-1]] += v
        else:
            fs[k] = v
    return fs


def listing_widths(path, text):
    """the operand widths V4.23's listing declares ({symbol: 8 / 16 / 24}, model/listing.attributes; a name it cut to
    31 characters stands for the C's full name), checked against FILE.c's own declarations (c_widths): a disagreement
    means the C does not say what the listing did, and stops the build"""
    import listing
    attrs = listing.attributes(text)
    cw = c_widths(path)
    uncut = {n[:C_NAME_LIMIT]: n for n in cw if len(n) > C_NAME_LIMIT}
    attrs.update({uncut[k]: v for k, v in list(attrs.items()) if k in uncut})     # both spellings
    bad = ["%s: C %d-bit, listing %d-bit" % (n, cw[n], attrs[n]) for n in sorted(cw) if n in attrs and attrs[n] != cw[n]]
    if bad:
        sys.exit("%s: the operand widths V4.23 declares differ from the C's qualifiers:\n    %s" % (path, "\n    ".join(bad)))
    return attrs


def compile_v423(path, names, cache):
    """FILE.c -> {function: [llvm-mc lines]} from Toshiba V4.23's listing of it, which scripts/build/cc900_v423.py
    fill has put in CACHE; the same to_llvm path as compile_c (finish)."""
    import cc900_v423
    import to_llvm
    status, lp, logs = cc900_v423.listing(cache, path)
    if status != "OK":
        sys.exit("%s: %s" % (path, "V4.23 does not compile it; see %s" % " ".join(logs) if status else
                             "no V4.23 listing of its current text in %s; `make` fills the cache first "
                             "(scripts/build/cc900_v423.py fill)" % cache))
    cdefs = c_functions(path)
    check_c_names(path, cdefs)
    labels = label_map(path)
    uncut = {n[:C_NAME_LIMIT]: n for n in cdefs}
    text = open(lp, encoding="latin-1").read()
    to_llvm.SPELL = names
    to_llvm.WIDTHS = listing_widths(path, text)
    to_llvm.MODULE = module_names(path)                  # only the marking, never file membership
    funcs = {}
    for name, lines in listing_functions(text).items():
        n = name.lstrip("_.")
        c = n if n in cdefs else uncut.get(n, n)          # V4.23 keeps 31 characters of a name
        bare = labels.get(c, c)
        funcs[bare] = finish(path, name, bare, lines, names)
    want = {labels.get(c, c) for c in cdefs}
    if set(funcs) != want:
        sys.exit("%s: V4.23's listing has functions %s, the C defines %s" % (path, sorted(funcs), sorted(want)))
    return funcs


def finish(path, name, bare, lines, names):
    """one function's listing lines (cc900 syntax, model or V4.23) -> its llvm-mc body for the tree label `bare`:
    model/to_llvm.py, local labels made `.Lcc900_<bare>_<label>`, asm900's jr / jrl choice.  Raises SystemExit on a
    line to_llvm cannot translate."""
    import to_llvm
    if bare != name.lstrip("_."):                          # a short (or cut) C name: the body is the tree label's
        lines = [bare + ":" if l == name + ":" else l for l in lines]
        name = bare
    consts, _ = to_llvm.split_consts(lines)                # the function's f_const objects, in listing order
    places = data_map(path).get(bare, {})
    to_llvm.DATA = {s: places[k] for k, s in enumerate(consts, 1) if k in places}
    to_llvm.DATA_REQUIRED = True
    try:
        body = to_llvm.translate_function(name, lines, names)
    except KeyError as ex:                                 # a name without a value or a declared width
        sys.exit("%s: %s: %s%s" % (path, bare, ex.args[0] if ex.args else ex, MODEL_HINT if MODEL else ""))
    # local labels renumbered in order of appearance (L1, L2 ..., S1 ...), so that the model's listing and V4.23's,
    # which number them differently, give the same text
    order = [l[:-1] for l in lines if l.endswith(":") and not l.startswith("\t") and l[:-1] != name]
    new, count = {}, {}
    for lab in order:
        k = lab[0] if lab[0].isalpha() else "L"
        count[k] = count.get(k, 0) + 1
        new[lab] = ".Lcc900_%s_%s%d" % (bare, k, count[k])
    text = []
    for l in body:
        if l in ("\t.globl %s" % bare, bare + ":"):
            continue
        for lab in order:
            l = re.sub(r'(?<![\w.])%s(?![\w])' % re.escape(lab), new[lab], l)
        text.append(l)
    for s, label in to_llvm.DATA.items():                  # the f_const objects, each for its place in the tree
        data = []
        for l in to_llvm.translate_data(consts[s], set(order)):
            for lab in order:
                l = re.sub(r'(?<![\w.])%s(?![\w])' % re.escape(lab), new[lab], l)
            data.append(l)
        text_bad = [l for l in data if "untranslated" in l]
        if text_bad:
            sys.exit("%s: %s: to_llvm cannot translate the data of %s:\n%s" % (path, bare, label, "\n".join(text_bad)))
        DATA_OUT[label] = (bare, data)
    bad = [l for l in text if "untranslated" in l]
    if bad:
        sys.exit("%s: %s: to_llvm cannot translate:\n%s%s" % (path, bare, "\n".join(bad), MODEL_HINT if MODEL else ""))
    return far_fallback(bare, to_llvm.relax("\n".join(text), assembler_errors).split("\n"))


DATA_OUT = {}       # finish(): {tree label: (function, llvm-mc data lines)} of the f_const objects placed by cc900-data:
DATA_RE = re.compile(rb'cc900-data:\s*([A-Za-z_]\w*)\s+(\d+)\s*=\s*([A-Za-z_]\w*)')


def data_map(path):
    """{function: {n: tree label}} from FILE.c's `cc900-data: FUNCTION N = LABEL` comments: V4.23 puts a function's
    constant data (a switch's jump table, an FP constant, an initialised local array) in the f_const section, which
    the linker places apart from the code; the comment names the tree's label of the function's N-th such object
    (in listing order, 1-based).  The build writes that object as includes/generated/cc900/LABEL.s, which the tree
    includes at LABEL, and the code's reference to it becomes LABEL."""
    out = {}
    for m in DATA_RE.finditer(open(path, "rb").read()):
        out.setdefault(m.group(1).decode(), {})[int(m.group(2))] = m.group(3).decode()
    return out


ADDRS = {}          # main(): {label: address} of the tree's symbols reference, for far_fallback


def tree_addresses(tree):
    """{label: address} from the tree's symbols reference (symbols/maincpu_<v>_..., subcpu_..._symbols_reference.txt),
    or {} when there is none"""
    parts = os.path.normpath(tree).split(os.sep)
    v, cpu = parts[-2], parts[-1]
    name = {"maincpu": "maincpu_%s_symbols_reference.txt" % v,
            "subcpu": "subcpu_symbols_reference.txt" if v == "v142" else "subcpu_%s_symbols_reference.txt" % v}.get(cpu)
    p = os.path.join(REPO, "symbols", name) if name else None
    out = {}
    if p and os.path.exists(p):
        for l in open(p):
            c = l.split()
            if len(c) == 2 and not l.startswith("#"):
                try:
                    out[c[0]] = int(c[1], 16)
                except ValueError:
                    pass
    return out
REL_RE = re.compile(r'^\t(calr|jr|jrl)\s+([A-Za-z_]\w*)\s*$')


def far_fallback(fn, lines):
    """asm900's rule beyond reach (probe calrel-far2, run 2026-11-16-61-p6-calrel-far2): a module-local CAL / J whose
    target is more than 16 bits away is call / jp.  With the tree's addresses (ADDRS; the function sits at its
    ROM address), every unconditional calr / jr / jrl to a label is checked from the instruction's own offset and
    rewritten when out of reach; repeated until nothing changes.  The sizes are llvm-mc's before relaxation (a jr counts 2 bytes), so a
    target within a few bytes of the limit is judged from a position a byte or so early.  Without ADDRS, or with
    data directives in the body, lines stay as they are (llvm-mc then stops on an out-of-range calr: a visible
    failure, never a wrong byte)."""
    if fn not in ADDRS or not any((REL_RE.match(l) or [0, 0, ""])[2] in ADDRS for l in lines):
        return lines                                      # nothing relative to a label of the image
    if any(l.startswith("\t.") for l in lines):
        return lines
    for _ in range(5):
        r = subprocess.run([os.path.join(LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-show-encoding"],
                           input="\n".join(lines) + "\n", capture_output=True, text=True)
        sizes = [len(m.group(1).split(",")) for m in re.finditer(r'encoding: \[([^\]]*)\]', r.stdout)]
        insn = [i for i, l in enumerate(lines) if l.startswith("\t") and l.strip()]
        if r.returncode or len(sizes) != len(insn):
            return lines
        changed, off = False, 0
        for i, n in zip(insn, sizes):
            m = REL_RE.match(lines[i])
            if m and m.group(2) in ADDRS:
                d = ADDRS[m.group(2)] - (ADDRS[fn] + off + n)
                if not -0x8000 <= d <= 0x7fff:
                    lines[i] = "\t%s\t%s" % ("call" if m.group(1) == "calr" else "jp", m.group(2))
                    changed = True
            off += n
        if not changed:
            return lines
    return lines


MODEL = False                                              # main(): building with the reference model
MODEL_HINT = ("\nThe Python reference model (CC900_COMPILER=model) does not support this C; nothing was written.  The "
              "default build, Toshiba V4.23 in the oracle VM (`make`, CC900_COMPILER=v423), compiles it.")


def assembler_errors(text):
    r = subprocess.run([os.path.join(LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-o", os.devnull],
                       input=text, capture_output=True, text=True)
    return r.stderr


def tabbed(line):
    """`\tld (xwa), 0x0` -> `\tld\t(xwa), 0x0` (the tree's tab after the mnemonic)"""
    return re.sub(r'^\t([\w.]+) ', '\t\\1\t', line)


def main():
    args = sys.argv[1:]
    cache = None
    if args[:1] == ["--v423"] and len(args) > 1:
        cache = args[1]
        args = args[2:]
    if len(args) != 4:
        sys.exit(__doc__)
    tree, src, outdir, stamp = args
    global MODEL
    ADDRS.update(tree_addresses(tree))
    if cache:
        funcs = compile_v423(src, Names(tree_values(tree), tree_labels(tree), cut=True), cache)
    else:
        MODEL = True
        if file_flags(src) not in OPTION_SETS:
            sys.exit("%s: cc900-options %r is not one the reference model compiles (%s)%s"
                     % (src, file_flags(src), ", ".join(repr(k) for k in OPTION_SETS), MODEL_HINT))
        funcs = compile_c(src, Names(tree_values(tree), tree_labels(tree)))
    if REFUSED:
        sys.exit("%s: the reference model does not compile: %s%s" % (
            src, "; ".join("%s (%s)" % kv for kv in sorted(REFUSED.items())), MODEL_HINT))
    if not funcs:
        sys.exit("%s: no function compiled" % src)
    os.makedirs(outdir, exist_ok=True)
    relsrc = os.path.relpath(src, tree)
    flags = file_flags(src) or "no options"
    for f, lines in funcs.items():
        hdr = ["; GENERATED by scripts/build/cc900_firmware_c.py -- do not edit.",
               "; %s, compiled from %s by the cc900 reference model (scripts/analysis/cc900/model/," % (f, relsrc),
               "; %s, personality kn5000) and model/to_llvm.py.  The label is on the including line." % flags]
        if cache:
            hdr[1:] = ["; %s, compiled from %s by Toshiba cc900 V4.23 (%s; its listing from the oracle VM, cached"
                       % (f, relsrc, flags),
                       "; by scripts/build/cc900_v423.py) and model/to_llvm.py.  The label is on the including line."]
        with open(os.path.join(outdir, f + ".s"), "w") as fh:
            fh.write("\n".join(hdr + [tabbed(l) for l in lines]) + "\n")
    for label, (f, lines) in DATA_OUT.items():             # f_const objects, each included at its tree label
        hdr = ["; GENERATED by scripts/build/cc900_firmware_c.py -- do not edit.",
               "; %s: constant data of %s (V4.23's f_const section), from %s by %s and model/to_llvm.py."
               % (label, f, relsrc, "Toshiba cc900 V4.23" if cache else "the cc900 reference model"),
               "; Placed by the file's `cc900-data:` comment; the label is on the including line."]
        with open(os.path.join(outdir, label + ".s"), "w") as fh:
            fh.write("\n".join(hdr + [tabbed(l) for l in lines]) + "\n")
    produced = set(funcs) | set(DATA_OUT)
    if os.path.exists(stamp):
        out_abs = os.path.realpath(outdir)
        for old in open(stamp).read().split():
            if old in produced:
                continue
            p = os.path.realpath(os.path.join(outdir, old + ".s"))
            assert os.path.dirname(p) == out_abs and p.endswith(".s"), p
            if os.path.exists(p):
                os.remove(p)
    with open(stamp, "w") as fh:
        fh.write("\n".join(sorted(produced)) + "\n")
    print("%s: %d function(s): %s" % (src, len(funcs), " ".join(sorted(funcs))))


if __name__ == "__main__":
    main()
