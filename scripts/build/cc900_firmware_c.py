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
# Most probably UNNECESSARY (2026-11-16, later): V4.23 itself writes these moves when one side is a __near cell
# (run 2026-11-16-92-p6-r18, FDC_CMD_SEND / FDC_MC_EXIT_Code_Helper2); the firmware's moves are then V4.23 with
# __near declarations.  Kept as the no-op it is until the model work resumes.
FIRMWARE_RULES = ("KN_LOOP_INVERT", "KN_SHIFT_UNSIGNED_SLL", "KN_MEM_TO_MEM")
C_NAME_LIMIT = 31
EQU_RE = re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_][\w.]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;|$)')
RAM_CELL_RE = re.compile(r'^ram_([0-9a-f]+)$')

for k in [k for k in os.environ if k.startswith("CC900_") and k != "CC900_MODEL_CLANG"]:
    del os.environ[k]
sys.path.insert(0, MODEL)


LABEL_RE = re.compile(rb'^([A-Za-z_][\w]*):')
ROM_LABEL = 0xE00000          # a label of the tree's code or data: in the main CPU's ROM, so above 0x10000 (24-bit)

# The scan of a tree's .s files (its .equ values and its labels) took 0.7 s of each generator run's 1.1 s, and `make`
# runs one generator per C file (795 on 2026-11-16).  Its result is kept in build/cc900-names/, one file per tree
# state, keyed by a hash of the CONTENT of every .s file scanned (path and bytes), the two patterns and SCAN_VERSION:
# any edit to any scanned file, or to the rules here, is another key, so a kept result is never stale.  The key costs
# one read of the tree and one hash (about 60 ms).  Writers replace the file atomically; a cache that cannot be read
# or written is ignored and the tree is scanned.
SCAN_VERSION = b"cc900 tree scan 1"
SCAN_CACHE = os.path.join(REPO, "build", "cc900-names")
SCANNED = {}


def tree_scan(tree):
    """(values, labels) of TREE's .s files: {name: value} of every numeric `.equ` / `.set` (a name set to two values
    maps to None), and the column-0 labels in file order"""
    import hashlib
    import pickle
    tree = os.path.normpath(tree)
    if tree in SCANNED:
        return SCANNED[tree]
    blobs = []
    h = hashlib.blake2b(digest_size=20)
    h.update(SCAN_VERSION + b"\0" + EQU_RE.pattern + b"\0" + LABEL_RE.pattern)
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != "generated")
        for f in sorted(fn):
            if f.endswith(".s"):
                p = os.path.join(dp, f)
                b = open(p, "rb").read()
                h.update(b"\0%s\0%d\0" % (os.path.relpath(p, tree).encode(), len(b)))
                h.update(b)
                blobs.append(b)
    kept = os.path.join(SCAN_CACHE, h.hexdigest() + ".pickle")
    try:
        with open(kept, "rb") as fh:
            SCANNED[tree] = pickle.load(fh)
        return SCANNED[tree]
    except (OSError, EOFError, pickle.UnpicklingError, ValueError):
        pass
    vals, labs = {}, []
    for b in blobs:
        for ln in b.split(b"\n"):
            m = EQU_RE.match(ln)
            if m:
                n, v = m.group(1).decode(), int(m.group(2), 0)
                vals[n] = v if vals.get(n, v) == v else None
            m = LABEL_RE.match(ln)
            if m:
                labs.append(m.group(1).decode())
    SCANNED[tree] = (vals, labs)
    try:
        os.makedirs(SCAN_CACHE, exist_ok=True)
        tmp = "%s.%d.tmp" % (kept, os.getpid())
        with open(tmp, "wb") as fh:
            pickle.dump(SCANNED[tree], fh, protocol=pickle.HIGHEST_PROTOCOL)
        os.replace(tmp, kept)
    except OSError:
        pass
    return SCANNED[tree]


def tree_values(tree):
    """{name: value} of every numeric `.equ` / `.set` in TREE's .s files; a name set to two values maps to None"""
    return dict(tree_scan(tree)[0])


def tree_labels(tree):
    """{label: ROM_LABEL} for every column-0 label of TREE's .s files.  The value only tells to_llvm that the operand
    is 24-bit; the generated code names the label, and the tree's own definition gives the address."""
    return dict.fromkeys(tree_scan(tree)[1], ROM_LABEL)


# the trees a tree's sources include (its llvm-mc -I order after itself; Makefile): their names are the C's too
# (repository-relative): the older HD-AE5000 trees take hdae5000's sources; the main-CPU and sub-CPU programs take
# the shared kernel, wsa1/kernel/kernel.s (-I wsa1/kernel: Kernel_SemaWait, TaskEvent_Signal ...)
INCLUDE_TREES = {"hdae5000_v2_01i": ["hdae5000"], "hdae5000_v1_15i": ["hdae5000"],
                 "hdae5000_v1_10i": ["hdae5000_v1_15i", "hdae5000"],
                 "maincpu": ["wsa1/kernel"], "subcpu": ["wsa1/kernel"]}


def tree_chain(tree):
    """TREE and the trees it includes, nearest first"""
    t = os.path.normpath(tree)
    return [t] + [os.path.join(REPO, x) for x in INCLUDE_TREES.get(os.path.basename(t), [])]


def merged_values(tree):
    """tree_values over tree_chain(TREE): a name the tree itself defines wins over an included tree's"""
    out = {}
    for t in reversed(tree_chain(tree)):
        out.update(tree_values(t))
    return out


def merged_labels(tree):
    out = {}
    for t in reversed(tree_chain(tree)):
        out.update(tree_labels(t))
    return out


RUNTIME = {}        # main(): {runtime name without `_` / `.`: the tree's label}, runtime_names(tree)
RUNTIME_TSV = os.path.join(REPO, "scripts", "build", "cc900_runtime_names.tsv")
PAIRS_TSV = os.path.join(REPO, "scripts", "analysis", "cc900", "results", "pairs.tsv")


def runtime_names(tree):
    """{runtime name: tree label} for TREE (v10/maincpu): V4.23 calls Toshiba's runtime by its library names (C9H_mullu,
    ._fld_ful), which the trees name otherwise.  From scripts/build/cc900_runtime_names.tsv (`tree<TAB>name<TAB>label`;
    tree is a shell pattern matched against the tree's path, e.g. `*/maincpu`, `hdae5000*`, `v142/subcpu`; when several
    rows name one runtime name, the most specific pattern -- the one with the fewest wildcards, then the longest --
    wins, so a tree's own row beats a general one) and from results/pairs.tsv's `our_label` of the tree's image
    (every library public matched in the ROM).  A name is used only when the tree itself does not define it."""
    import fnmatch
    rel_tree = os.path.relpath(os.path.abspath(tree), REPO)
    parts = rel_tree.split(os.sep)
    if parts[0] == os.pardir:                            # a copy of a tree outside the repository (a lane's branch
        k = 2 if parts[-1] in ("maincpu", "subcpu") else 1   # extracted for a check): its own last components,
        parts = parts[-k:]                                   # v10/maincpu or hdae5000_v2_01i, name it
        rel_tree = os.sep.join(parts)
    v, cpu = (parts[-2], parts[-1]) if len(parts) >= 2 else (parts[-1], "")
    image = "%s %s" % (cpu, v)
    out = {}
    if os.path.exists(PAIRS_TSV):
        for l in open(PAIRS_TSV, encoding="utf-8"):
            c = l.rstrip("\n").split("\t")
            if len(c) >= 8 and c[0] == image and c[7] and " " not in c[2]:
                out.setdefault(c[2].lstrip("_."), c[7])
    rows = {}
    if os.path.exists(RUNTIME_TSV):
        for l in open(RUNTIME_TSV, encoding="utf-8"):
            c = l.rstrip("\n").split("\t")
            if len(c) >= 3 and not l.startswith("#") and c[0] != "tree" and fnmatch.fnmatchcase(rel_tree, c[0]):
                rank = (-sum(c[0].count(w) for w in "*?["), len(c[0]))
                n = c[1].lstrip("_.")
                if n not in rows or rank > rows[n][0]:
                    rows[n] = (rank, c[2])
    out.update({n: label for n, (rank, label) in rows.items()})
    return out


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

    # The one resolver, in this order: V4.23's `_` / `.` prefix stripped; a `ram_<hex>` cell (a number); the C file's
    # `cc900-name:` map (cmap, a short C name -> the tree's label, for callees and data as for definitions); the
    # tree's .equ values; the labels of the tree and of every tree it includes with -I (the shared kernel); a name
    # V4.23 cut to 31 characters; the tree-scoped runtime names (RUNTIME); the tree's symbols reference (addrs) as
    # the last resort.  A label is always given with its spelling: its value is only ROM_LABEL, a placeholder that
    # to_llvm refuses to compute with (to_llvm.PLACEHOLDER).  Anything unresolved is (None, None): the caller fails.
    cmap = {}
    addrs = None

    ccut = {}                                            # {31-character cut: the C file's own longer names}

    def resolve(self, n, depth=0):
        """V4.23's name first without its `_` / `.` prefix, then with only its first character dropped (a C name of
        its own that begins with `_`: `._findfirst` is the tree's _findfirst)"""
        a = self.resolve1(n.lstrip("_."), depth)
        if a[0] is None and n[:1] in "._" and n[1:] != n.lstrip("_.") and n[1:]:
            a = self.resolve1(n[1:], depth)
        return a

    def resolve1(self, n, depth):
        m = RAM_CELL_RE.match(n)
        if m:
            return int(m.group(1), 16), None
        if n in self.cmap and self.cmap[n] != n and depth < 4:
            t = self.cmap[n]
            if t[:1] in "._" and t in self.labels:   # `cc900-name: X=_Label` names the tree's `_Label` itself: resolve
                return self.labels[t], t              # it before resolve() strips the `_` (Write_VGA_Register is another
            return self.resolve(t, depth + 1)         # label than _Write_VGA_Register; lane_p6 helper L, 2026-11-19)
        if self.values.get(n) is not None:
            return self.values[n], n
        if n in self.values:
            raise KeyError("%s has two values in the tree; cannot choose its operand width" % n)
        if n in self.labels:
            return self.labels[n], n
        if len(n) == C_NAME_LIMIT and len(self.ccut.get(n, ())) == 1:   # a name V4.23 cut to 31 characters: the
            full = next(iter(self.ccut[n]))                             # C file's own longer name for it, first
            if full in self.labels or full in self.values or full in self.cmap:
                return self.resolve(full, depth + 1)
        if self.cut and len(self.cut.get(n, ())) == 1:     # else the tree's one label with that cut
            full = next(iter(self.cut[n]))
            return self.resolve(full, depth + 1)[0], full
        if self.cut and len(self.cut.get(n, ())) > 1 and len(n) == C_NAME_LIMIT:
            raise KeyError("%s is V4.23's 31-character cut of %d tree labels (%s): the C must declare the one it means, "
                           "or name it with a `cc900-name: SHORT=LABEL` line"
                           % (n, len(self.cut[n]), ", ".join(sorted(self.cut[n])[:4])
                              + (" ..." if len(self.cut[n]) > 4 else "")))
        alias = RUNTIME.get(n)                              # a runtime routine under the tree's name (C9H_mullu)
        if alias and alias != n and depth < 4:
            return self.resolve(alias, depth + 1)
        if self.addrs and n in self.addrs:                  # the symbols reference: a label the walk above misses
            return self.addrs[n], n
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
    check_markers(path)
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


LABEL_LIKE = re.compile(r'^(ram_[0-9a-fA-F]+|[A-Za-z_]\w*_\w*|[A-Za-z]\w*[a-z0-9][A-Z]\w*)$')
MARKER_CHECKED = set()


def check_markers(path):
    """stop when a `cc900-module:` / `-options:` / `-name:` / `-data:` marker wraps onto the next line of its comment.
    Each reader takes one line, so the wrapped part would be lost silently (lane_sub: a module list's callees on its
    second line became absolute calls, which only the gate caught).  A wrapped line is: for a module list, a line of
    label-like names only (an underscore or an inner capital in every one: never prose); for options, flags only; for
    a name or data marker, a marker whose own line does not hold the whole `C=LABEL` / `FUNCTION N = LABEL`."""
    if path in MARKER_CHECKED:
        return
    text = open(path, "rb").read().decode("latin-1")
    for c in re.finditer(r'/\*.*?\*/', text, re.S):
        lines = c.group(0).split("\n")
        for k, l in enumerate(lines):
            m = re.search(r'cc900-(module|options|name|data):(.*)', l)
            if not m:
                continue
            kind, rest = m.group(1), m.group(2).replace("*/", "").strip()
            nxt = lines[k + 1].replace("*/", "").strip(" \t*") if k + 1 < len(lines) else ""
            toks = [t for t in re.split(r'[\s,]+', nxt) if t]
            wrapped = None
            if kind == "name" and not re.match(r'^[A-Za-z_]\w*\s*=\s*[A-Za-z_]\w*', rest):
                wrapped = "its `C=LABEL` is not whole on this line"
            elif kind == "data" and not re.match(r'^[A-Za-z_]\w*\s+\d+\s*=\s*[A-Za-z_]\w*', rest):
                wrapped = "its `FUNCTION N = LABEL` is not whole on this line"
            elif toks and "cc900-" not in nxt:
                if kind == "module" and all(LABEL_LIKE.match(t) for t in toks):
                    wrapped = "the next line continues the list (%s ...)" % " ".join(toks[:3])
                elif kind == "options" and all(t.startswith("-") for t in toks):
                    wrapped = "the next line continues the flags (%s)" % " ".join(toks)
            if wrapped:
                sys.exit("%s:%d: a cc900-%s: marker wraps: %s.  Each marker is read from its own line only: repeat the "
                         "keyword on every line (`cc900-%s: ...`)" % (path, text[:c.start()].count("\n") + k + 1, kind,
                                                                       wrapped, kind))
    MARKER_CHECKED.add(path)


def c_long_names(path):
    """{31-character cut: the identifiers longer than 31 characters FILE.c writes outside comments}: the names
    V4.23 cuts, so a cut reference resolves to the one the C declares (SingleLoad_LoadPanelMemory_Str_ has five
    labels in v10; the C names one)"""
    src = re.sub(r'/\*.*?\*/', ' ', open(path, "rb").read().decode("latin-1"), flags=re.S)
    out = {}
    for n in set(re.findall(r'\b[A-Za-z_]\w{%d,}' % C_NAME_LIMIT, src)):
        out.setdefault(n[:C_NAME_LIMIT], set()).add(n)
    return out


def module_names(path):
    """the names FILE.c's `cc900-module:` comments list (blank- or comma-separated; any number of comments): tree
    labels that were in the same section of the firmware's original source module as this file's functions.  asm900
    saw them, so it assembled V4.23's CAL / J to them as calr / jr / jrl, which to_llvm.MODULE reproduces.  An entry
    is a claim about the original build, and `make gate` checks it: a wrong one changes the bytes.  The evidence for
    one is the ROM itself (the hand assembly's calr / jr / jrl to it)."""
    out = set()
    check_markers(path)
    for m in MODULE_RE.finditer(open(path, "rb").read()):
        out.update(n for n in re.split(r'[\s,]+', m.group(1).decode()) if n)
    # a listed label the C calls by a short `cc900-name:` (Voice_PerVoice_PortaPitchUpd = ..._PortamentoPitchUpdate):
    # V4.23's listing writes the short name, so it is module-local too, and either spelling may be listed
    for c, lab in label_map(path).items():
        if lab in out or c in out:
            out.update((c, lab))
    return out


def label_map(path):
    """{C name: the tree's label} from FILE.c's `cc900-name:` comments"""
    check_markers(path)
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
    try:                                                 # the qualifiers are read by c_widths
        unit = frontend.load(path, ["__near=", "__tiny="], [], adecl=adecl)
    except Exception as ex:                              # ANY front-end failure is the model's refusal: an anonymous
        detail = str(ex)                                 # union member (ValueError), clang -fsyntax-only refusing
        err = getattr(ex, "stderr", None)                # the file (CalledProcessError: hdae5000_ui_display.c) ...
        if err:
            detail += ": " + (err.decode("latin-1") if isinstance(err, bytes) else err).strip()[-300:]
        sys.exit("%s: the reference model's front end does not read it (%s: %s)%s"
                 % (path, type(ex).__name__, detail, MODEL_HINT))
    out = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=OPTIONS["personality"])
    to_llvm.SPELL = names if spell else None
    to_llvm.WIDTHS = c_widths(path, model=True)
    to_llvm.MODULE = module_names(path)                  # only the marking, never file membership
    check_c_names(path, [f.name for f in unit.functions])
    labels = label_map(path)
    if isinstance(names, Names):
        names.cmap = labels                              # cc900-name: for every reference, not only definitions
        names.ccut = c_long_names(path)
    to_llvm.PLACEHOLDER = ROM_LABEL if spell else None   # spell=False: real addresses (fn_diff.py, the coverage)
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
    out, cur, depth, knr = [], "", 0, False
    for ch in src:
        # a function body: drop its head and skip the body.  An old-style (K&R) definition declares its parameters
        # between `)` and `{` (`void f(a) unsigned char a; {`): after such a head the `{` opens the body too
        # (2026-12-07: Part_ValidateVoiceChannel, whose body statements were read as file-scope declarations)
        if depth == 0 and ch == "{" and (")" in cur or (knr and not cur.strip())):
            cur, depth, knr = "", 1, False
            continue
        if depth:
            depth += {"{": 1, "}": -1}.get(ch, 0)
            continue
        if ch == ";":
            s = " ".join(cur.split())
            if s and ("(" in s) == prototypes and not s.startswith("typedef"):
                out.append(s)
            if re.match(r'^[\w\s\*]*\b\w+\s*\([\w\s,]*\)\s*\w', s):     # `void f(a) unsigned char a`
                knr = True
            elif "(" in s or "=" in s:
                knr = False
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
    # a K&R definition declares its parameters between `)` and `{` (lane_hd's lyrics: `long f(pos) long pos; {`)
    # (each declaration of the list ends at its own `;`, so the pattern cannot backtrack exponentially)
    return [n for n in re.findall(r'^(?![ \t#])[\w \t*]*?\b([A-Za-z_]\w*)\s*\([^;{}]*\)(?:[^;{}()#=]*;)*\s*\{',
                                  src, re.M)
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
    names.cmap = labels                                  # cc900-name: for every reference, not only definitions
    names.ccut = c_long_names(path)
    to_llvm.PLACEHOLDER = ROM_LABEL
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
    check_markers(path)
    for m in DATA_RE.finditer(open(path, "rb").read()):
        out.setdefault(m.group(1).decode(), {})[int(m.group(2))] = m.group(3).decode()
    return out


ADDRS = {}          # main(): {label: address} of the tree's symbols reference, for far_fallback


def tree_addresses(tree):
    """{label: address} from the tree's symbols reference (symbols/maincpu_<v>_..., subcpu_..._, hdae5000[_<v>]_
    symbols_reference.txt), or {} when there is none"""
    parts = os.path.normpath(tree).split(os.sep)
    v, cpu = (parts[-2], parts[-1]) if len(parts) >= 2 else (parts[-1], "")
    name = {"maincpu": "maincpu_%s_symbols_reference.txt" % v,
            "subcpu": "subcpu_symbols_reference.txt" if v == "v142" else "subcpu_%s_symbols_reference.txt" % v,
            "": "%s_symbols_reference.txt" % v}.get(cpu)                  # hdae5000, hdae5000_v2_01i, ...
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
REL_RE = re.compile(r'^\t(calr|jr|jrl)\s+(?:(\w+),\s*)?([A-Za-z_]\w*)\s*$')    # (cc,) target


def far_fallback(fn, lines):
    """asm900's rule beyond reach (probe calrel-far2, run 2026-11-16-61-p6-calrel-far2): a module-local CAL / J whose
    target is more than 16 bits away is call / jp.  With the tree's addresses (ADDRS; the function sits at its
    ROM address), every calr / jr / jrl (conditional too) to a label is checked from the instruction's own offset and
    rewritten when out of reach: call / jp / jp cc,(F:24) beyond 16 bits, a jr beyond 8 bits as jrl (asm900 picks
    jrl itself; written here so the first layout pass is exact); repeated until nothing changes.  The sizes are llvm-mc's before relaxation (a jr counts 2 bytes), so a
    target within a few bytes of the limit is judged from a position a byte or so early.  Without ADDRS, or with
    data directives in the body, lines stay as they are (llvm-mc then stops on an out-of-range calr: a visible
    failure, never a wrong byte)."""
    if fn not in ADDRS or not any((REL_RE.match(l) or [0, 0, 0, ""])[3] in ADDRS for l in lines):
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
            if m and m.group(3) in ADDRS:
                d = ADDRS[m.group(3)] - (ADDRS[fn] + off + n)
                if not -0x8000 <= d <= 0x7fff:
                    lines[i] = ("\t%s\t%s" % ("call" if m.group(1) == "calr" else "jp", m.group(3)) if not m.group(2)
                                else "\tjp\t%s, (%s:24)" % (m.group(2), m.group(3)))   # J cc beyond reach: jp cc,#24
                    changed = True
                elif m.group(1) == "jr" and not -128 <= d <= 127:
                    # beyond jr's reach: jrl written here, as short_jr_out_of_reach() does for local labels (lane_p6,
                    # 188af8276), so the first layout pass counts the 3 bytes the jump will take
                    lines[i] = "\tjrl\t%s" % ("%s, %s" % (m.group(2), m.group(3)) if m.group(2) else m.group(3))
                    changed = True
            off += n
        if not changed:
            return lines
    return lines


MODEL = False                                              # main(): building with the reference model
MODEL_HINT = ("\nThe Python reference model (CC900_COMPILER=model) does not support this C; nothing was written.  The "
              "default build, Toshiba V4.23 in the oracle VM (`make`, CC900_COMPILER=v423), compiles it.")


JR_LOCAL_RE = re.compile(r'^\tjr[ \t]+(?:(\w+),\s*)?(\.L\w+)\s*$')
BYTE_RE = re.compile(r'^\t\.byte\s+([^;]*?)\s*(?:;.*)?$')


def assembler_errors(text):
    """llvm-mc's errors for to_llvm.relax(), plus one `N:1: error: out of range` per `jr` to a local label that does
    not reach it.  llvm-mc itself relaxes such a jr to jrl without a word, so the generated body used to keep `jr`
    and leave the choice to the layout; but a relaxable jr counts 2 bytes in the first layout pass, and the
    `.org` checks of the hand sources pad for it, so a hand `jr` that crosses an `.org` sees its target that much
    further away and is relaxed for good (r18 gate, lane_p6: v10/v9 `.org 0xf97d8d` one byte past, with the hand
    `jr nz` +116 at 0xf97d6b; the same source without that `.org` was byte-identical).  Writing jrl where it is
    needed keeps the first layout exact."""
    r = subprocess.run([os.path.join(LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-o", os.devnull],
                       input=text, capture_output=True, text=True)
    return r.stderr + short_jr_out_of_reach(text)


def short_jr_out_of_reach(text):
    lines = text.split("\n")
    # `.byte` lines are counted (2026-11-23: SetSepaOutMode's `ldiw`, written `.byte 0x95, 0x10`, made this check
    # give up, its four far `jr` stayed for llvm-mc to relax, and v10 / v9's `.org 0xf97d8d` overran by a byte);
    # any other directive still stops it
    byte_n = {i: len([x for x in BYTE_RE.match(l).group(1).split(",") if x.strip()])
              for i, l in enumerate(lines) if BYTE_RE.match(l)}
    if not any(JR_LOCAL_RE.match(l) for l in lines) or \
            any(l.startswith("\t.") and i not in byte_n for i, l in enumerate(lines)):
        return ""
    r = subprocess.run([os.path.join(LLVM_BIN, "llvm-mc"), "-triple=tlcs900", "-show-encoding"],
                       input=text + "\n", capture_output=True, text=True)
    sizes = [len(m.group(1).split(",")) for m in re.finditer(r'encoding: \[([^\]]*)\]', r.stdout)]
    insn = [i for i, l in enumerate(lines) if l.startswith("\t") and l.strip() and i not in byte_n]
    if r.returncode or len(sizes) != len(insn):
        return ""
    at, label, off, size = {}, {}, 0, dict(zip(insn, sizes))
    size.update(byte_n)
    for i, l in enumerate(lines):
        if not l.startswith("\t") and l.endswith(":"):
            label[l[:-1]] = off
        at[i] = off
        off += size.get(i, 0)
    out = ""
    for i in insn:
        m = JR_LOCAL_RE.match(lines[i])
        if m and m.group(2) in label and not -128 <= label[m.group(2)] - (at[i] + size[i]) <= 127:
            out += "<stdin>:%d:1: error: out of range (jr to a local label, written jrl)\n" % (i + 1)
    return out


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
    RUNTIME.update(runtime_names(tree))
    names = Names(merged_values(tree), merged_labels(tree), cut=bool(cache))
    names.addrs = ADDRS                                  # the symbols reference, the resolver's last resort
    if cache:
        funcs = compile_v423(src, names, cache)
    else:
        MODEL = True
        if file_flags(src) not in OPTION_SETS:
            sys.exit("%s: cc900-options %r is not one the reference model compiles (%s)%s"
                     % (src, file_flags(src), ", ".join(repr(k) for k in OPTION_SETS), MODEL_HINT))
        funcs = compile_c(src, names)
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
