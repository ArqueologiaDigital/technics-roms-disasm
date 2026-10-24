#!/usr/bin/env python3
"""doc_quality_census.py -- the documentation-quality ledger: five debts per image, for every model in the tree.

QUESTION IT ANSWERS
  "Per image, how much of the disassembly is still unexplained or spelled as numbers -- and did a change make any
   of it worse?"  Byte identity says nothing about this, and the dispatch census (dispatch_table_census/) only
   covers entry points.  This census counts five debts in the committed sources of every image:

  KN5000   v10 v9 v7 v142 v141 subboot tabledata customdata hdae5000   (TLCS-900, llvm-mc dialect, `;` comments)
  SX-WSA1R prom_a prom_b prom_c prom_d                                  (TLCS-900, llvm-mc dialect, `;` comments)
  SX-KN7000 program table cnv program942                                (MN10300, kn7asm dialect, `#` / `;` comments)
  MN10300 siblings kn2400 kn6000 kn6500 hdsx3                           (MN10300, kn7asm dialect, `#` / `;` comments)

  program942 is the SP7001 PLUG-iN program flash (build 942, kn7000/src/sp7001/program.s).  The siblings are the
  SX-KN2400/2600, SX-KN6000 and SX-KN6500 program flashes and the HD-SX3 plug-in image, generated with the
  kn7000 tools (kn7000/tools/gen_image_s.py); model `mn10300-siblings`.  v141, program942 and the siblings were
  added on 2026-10-24 (wave2/metrics-2); a --compare against an older snapshot lists them as `new`, not as rises.

  An image's files are its root source(s) plus everything they `.include`, resolved the way the build resolves
  them (the including file's directory, then each -I directory, then the assembler's working directory).  Only
  git-tracked files are read; a generated include is listed as untracked and skipped.  cnv pools the seven Style
  Convert Disk converters (kn7000/src/cnv/*.s).  A file included by two images is counted in both.

RULES (each count is re-derivable from these definitions)
  statement   one source line with its comment removed (quotes respected), split into an optional column-0
              `name:` label and a body.  The body is an instruction, `.byte`, other data (.short .long .word .ascii
              .asciz .string .incbin .incbin_range .fill .space .zero .int .2byte .4byte, or a DATA macro), or a
              directive (anything else starting with `.`, `NAME = ...`).
              DATA macro: a `.macro` with no instruction line in its body.  Exception: the macros defined in
              wsa1/include/tlcs900_mem_ops.inc emit INSTRUCTIONS as bytes (WP11); they count as instructions for
              flow and are tallied on their own (f).  Macros with an instruction in the body are instructions.
  code label  a label whose next statement (labels, comments and blank lines skipped) is an instruction.
  scope       names are resolved per image; cnv's seven converters are independent programs that include nothing
              and reuse the same loc_<address> names, so there each root file is its own scope.
  reference   every use of a name in the image's scope, classified by where it stands:
                call    the target operand of TLCS `call` / `calr` (`call nz, (Name:24)` included) or MN10300
                        `call` / `calls`;
                jump    the target operand of any other branch (TLCS jp jr jrl djnz, the last operand; MN10300
                        jmp bra b<cc>, the first), recorded with the file it is in;
                offset  an operand of a data statement that is a difference of names, `.short Case - Base` (the
                        offset tables of compiled switches);
                address any other use: another operand of an instruction (`lda xhl, Name`, `ld (Name), a`), a data
                        operand (`.long Name`, `addr24 Name`), or the right-hand side of `.equ` / `.set` / `=`.
              A name inside a comment is not a reference.
  terminator  an instruction after which execution cannot fall through: TLCS `ret` / `reti` / `retd` with no
              condition, `jp` / `jr` / `jrl` with no condition or with `t,`; MN10300 `ret` / `retf` / `rets` /
              `rti` / `jmp` / `bra` / `lra`.
  boundary    the previous statement of a label is a terminator, data, a directive, or the start of the file.
  routine     a code label that is an entry point by its references, tested in this order:
                call          it is a call target (always a routine, whatever its name);
                (skipped)     it is not at a boundary and its address is not taken: execution falls into it;
                (declared)    its name is one of semantic_score.py's CONTINUATION names (_Skip/_Loop/_Done/...,
                              Parent__F9A123, Parent__loop): the source declares it a part of its parent routine,
                              tallied as blocks_declared;
                address       its address is taken (a table entry, a pushed or stored pointer);
                xfile_jump    it is at a boundary and some file other than its own branches to it (a tail call
                              into another module);
                (block)       it is at a boundary and every reference is a branch from its own file: a block of one
                              routine, tallied as blocks_jump;
                (case)        it is at a boundary and its only references are offsets: a compiled switch's case,
                              tallied as blocks_case;
                unreferenced  it is at a boundary and nothing in the source names it.  Dead code, or a routine
                              reached from compiled C or through a table spelled as numbers.
              The test reads references, not names, so renaming a label (an address-only `.L<hex>` or `loc_<hex>`
              to a semantic name, as (c) asks) cannot move it in or out of the routines; only a CONTINUATION name
              takes a non-called label out.  This replaced, on 2026-10-24 (snapshot -02), the rule of snapshot -01
              ("a call target, or any non-local label at a boundary", where `.L...`, `loc_<hex>` and CONTINUATION
              names were local): that rule counted every branch target after a `jr` as a routine (12,998 of v10's
              18,358, all but its 5,360 call targets, were reached by no call), and a `.L` label renamed to a semantic name became a new header-less
              routine.  kn7000 program.s also has routines with no label: a generator banner `# Name  (CPU 0x...)`
              followed by instructions (a converted function), reason banner.  A banner followed by `.incbin_range`
              is passthrough, not source, and is not counted in (a); a banner followed by a label is counted once,
              as that label.

  (a) header      a routine HAS a header when the comment block directly above its label (one blank line allowed
                  between them; for an unlabelled kn7000 banner, the comment block the banner is in) holds at least
                  one INFORMATIVE line.  Not informative: a line that is empty once comment marks and the
                  decoration characters - = * ~ _ : . are dropped; a line that only restates the routine's name
                  (`; ---- Foo ----`, `# Foo  (CPU 0x48404ff6)`); and the kn7000 generators' provenance lines
                  (`the same code is in ...`, `no caller: unreferenced code`, `byte-identical ... to the firmware's
                  routine of this name`).  A comment only on the label's own line is tallied as inline_only and is
                  not a header.  Reported: routines, with_header, no_header, inline_only, the same split for the
                  call-target subset, the routines per reason (by_reason), and the labels at a boundary that are
                  not routines (blocks_jump, blocks_case, blocks_declared).
  (b) numeric     in instruction statements: mem_abs_in_image = an absolute memory operand spelled as a number,
                  `(0x2c4f1a)` / `(0x23a1a2:24)` / `(0x50007578)`, that lies in this image's own address range;
                  mem_abs_other = the same outside it (RAM, I/O, another ROM); imm_in_image = an operand that is
                  only a hex number in the image's range, in a non-branch instruction (a pointer spelled as a
                  number: `lda xix, 0xe46312`, `mov 0x4858ea5c, a1`); branch_numeric = a call / jump / branch
                  whose target operand (TLCS the last, MN10300 the first) is only a number, in parentheses or not
                  (kn7000 `bne 0x48421d7e`, `jp nz, (15860660:24)`, `jr z, 0x34`); branch_label_offset = a target
                  spelled `Label + N` / `Label - N`, which names a neighbour instead of the target.  Register-
                  relative operands (`(xsp+4)`, `(0x14, sp)`, `jp t, (xix+wa)`) are not counted.
  (c) addr locals label DEFINITIONS named only by an address: dotL `.L<hex>` and `.L<abbrev>_<hex>` (abbrev at
                  most six letters: `.LUIH_e1f2a4`), except dotLc `.Lc_<hex>`, counted apart; loc `loc_<hex>`;
                  parent_hex `Parent__<hex>` (prom_c style).
  (d) byte runs   maximal runs of `.byte` statements (labels and comments inside a run ignored) whose previous and
                  next statements are both instructions.  after_fallthrough: the previous instruction can fall
                  into the run, so the run is most likely an instruction spelled as bytes.  after_terminator: it
                  cannot (inline data, padding or a dead stub).  Each reports runs, lines and bytes (values).
  (e) placeholder code labels named `sub_<hex>`, `func_<hex>`, `FUN_<hex>`, `LABEL_<hex>` or `T_<hex>` (4-8 hex
                  digits); for kn7000 program.s also the generator banners and the `.equ` call-target names of
                  that shape whose value lies in the image (functions known only by address).  Distinct names.
  (f) insn macros uses of the WSA1 instruction byte-emitter macros (see DATA macro above).

  The image address ranges used by (b) are in IMAGES below (from the linked ELFs' LOAD segments; kn7000 from
  `.mnbase` and the image size; kn2400 also has its work-RAM link window).  prom_d (data at 0x0) has no range,
  so its (b) in/other split is not computed.  imm_in_image is not computed for v142 / v141 either: their range
  starts at 0x400, so masks and counts such as 0xffff and 0x2710 would land in it.  kn7000 program and
  program942 use the flash range only: code linked for the library window at 0x4C000000 counts as elsewhere.

LIMITS
  A source-text census: it reads names, not the CPU.  A case of a `.long` jump table and a pushed return address
  are address references, so they count as routines unless their names declare them blocks; a routine reached only
  by jumps from its own file (a tail call within one module) counts as a block; a header that is wrong still
  counts.  (b) misses numeric operands
  inside WSA1 byte-emitter macro arguments.  It is a ratchet, not a proof.

RUN (repository root; reads sources only, needs no build)
  python3 scripts/analysis/doc_quality_census.py                     # print the table
  python3 scripts/analysis/doc_quality_census.py --json F.json       # also write every count as JSON
  python3 scripts/analysis/doc_quality_census.py --files v10         # per-file breakdown of one image
  python3 scripts/analysis/doc_quality_census.py --routines v10      # every routine: file:line, name, reason, header
  python3 scripts/analysis/doc_quality_census.py --compare           # vs the newest COMMITTED snapshot; exit 1 if
                                                                     # any debt count rose, or an image of the old
                                                                     # snapshot is missing from this run
  python3 scripts/analysis/doc_quality_census.py --snapshot docs/coverage   # write doc-quality-<date>-NN.{txt,json}
  make doc-quality              # = --compare --snapshot docs/coverage: compare, and write the snapshot only if
                                #   nothing rose (a rise exits 1; explain it in the commit, then run --snapshot)

  Snapshots follow the dispatch census's numbering: a committed snapshot is never rewritten, a later commit on
  the same day gets the next NN, and a re-run before committing reuses that day's uncommitted file.
"""
import collections
import datetime
import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# key: (model, dialect, assembler cwd, -I dirs, roots, (lo, hi) address range, a list of such ranges, or None)
IMAGES = collections.OrderedDict([
    ("v10", ("kn5000", "tlcs", ".", ["v10/maincpu"], ["v10/maincpu/kn5000_v10_program.s"], (0xE00000, 0x1000000))),
    ("v9", ("kn5000", "tlcs", ".", ["v9/maincpu"], ["v9/maincpu/kn5000_v9_program.s"], (0xE00000, 0x1000000))),
    ("v7", ("kn5000", "tlcs", ".", ["v7/maincpu"], ["v7/maincpu/kn5000_v7_program.s"], (0xE00000, 0x1000000))),
    ("v142", ("kn5000", "tlcs", ".", ["v142/subcpu"], ["v142/subcpu/kn5000_subprogram_v142.s"], (0x400, 0x3EF00))),
    ("v141", ("kn5000", "tlcs", ".", ["v141/subcpu"], ["v141/subcpu/kn5000_subprogram_v141.s"], (0x400, 0x3EF00))),
    ("subboot", ("kn5000", "tlcs", ".", ["subcpu/boot"], ["subcpu/boot/kn5000_subcpu_boot.s"], (0xFE0000, 0x1000000))),
    ("tabledata", ("kn5000", "tlcs", ".", ["table_data"], ["table_data/kn5000_table_data.s"], (0x800000, 0xA00000))),
    ("customdata", ("kn5000", "tlcs", ".", ["custom_data"], ["custom_data/kn5000_custom_data.s"], (0x300000, 0x400000))),
    ("hdae5000", ("kn5000", "tlcs", ".", ["hdae5000"], ["hdae5000/hd-ae5000_v2_06i.s"], (0x280000, 0x300000))),
    ("prom_a", ("wsa1", "tlcs", "wsa1", ["wsa1", "wsa1/prom_a"], ["wsa1/prom_a/wsa1_prom_a.s"], (0xF80000, 0x1000000))),
    ("prom_b", ("wsa1", "tlcs", "wsa1", ["wsa1", "wsa1/prom_b"], ["wsa1/prom_b/wsa1_prom_b.s"], (0xF00000, 0xF80000))),
    ("prom_c", ("wsa1", "tlcs", "wsa1", ["wsa1", "wsa1/prom_c"], ["wsa1/prom_c/wsa1_prom_c.s"], (0xF80000, 0x1000000))),
    ("prom_d", ("wsa1", "tlcs", "wsa1", ["wsa1", "wsa1/prom_d"], ["wsa1/prom_d/wsa1_prom_d.s"], None)),
    ("program", ("kn7000", "mn", "kn7000", ["kn7000"], ["kn7000/src/program.s"], (0x48400000, 0x48400000 + 0x3F6F01))),
    ("table", ("kn7000", "mn", "kn7000", ["kn7000"], ["kn7000/src/table.s"], (0x48000000, 0x48000000 + 0x3E94D4))),
    # load address + 0x28000: the largest converter (0x1A970 bytes) plus its .bss
    ("cnv", ("kn7000", "mn", "kn7000", ["kn7000"], "kn7000/src/cnv/*.s", (0x502B8000, 0x502E0000))),
    # the SP7001 PLUG-iN program flash, build 942 (4 MiB image)
    ("program942", ("kn7000", "mn", "kn7000", ["kn7000"], ["kn7000/src/sp7001/program.s"],
                    (0x48400000, 0x48400000 + 0x400000))),
    # MN10300 siblings, assembled from their own directory (`kn7asm.py src/program.s -I .`).  kn2400 links the
    # code from file 0x3285be to 0x3965bb for work RAM at 0x50120000 (kn2400/README.md, "Layout"), so its
    # image has that window as well as its flash addresses.
    ("kn2400", ("mn10300-siblings", "mn", "kn2400", ["kn2400"], ["kn2400/src/program.s"],
                [(0x48400000, 0x48400000 + 0x3965D3), (0x50120000, 0x50120000 + 0x3965BB - 0x3285BE)])),
    ("kn6000", ("mn10300-siblings", "mn", "kn6000", ["kn6000"], ["kn6000/src/program.s"],
                (0x4C000000, 0x4C000000 + 0x3F7A31))),
    ("kn6500", ("mn10300-siblings", "mn", "kn6500", ["kn6500"], ["kn6500/src/program.s"],
                (0x4C000000, 0x4C000000 + 0x381691))),
    ("hdsx3", ("mn10300-siblings", "mn", "hdsx3", ["hdsx3"], ["hdsx3/src/program.s"], (0x97800000, 0x978C0000))),
])


def in_ranges(rng, v):
    """True when v lies in the image's address range(s): rng is (lo, hi), a list of (lo, hi), or None."""
    if not rng:
        return False
    return any(lo <= v < hi for lo, hi in ([rng] if isinstance(rng[0], int) else rng))

INSN_MACRO_FILES = {"wsa1/include/tlcs900_mem_ops.inc"}

DATA_DIRS = {".short", ".long", ".word", ".ascii", ".asciz", ".string", ".incbin", ".incbin_range", ".fill",
             ".space", ".zero", ".int", ".2byte", ".4byte", ".quad", ".hword"}
LABEL_RE = re.compile(r'^([A-Za-z_.$][A-Za-z0-9_.$]*):(?!:)')
TLCS_CC = r'(?:f|lt|le|ule|ov|pe|mi|z|eq|c|ult|t|ge|gt|ugt|nov|po|pl|nz|ne|nc|uge)'
TLCS_CALL = re.compile(r'^(?:call|calr)\s+(?:' + TLCS_CC + r'\s*,\s*)?\(?\s*([A-Za-z_.$][\w.$]*)', re.I)
TLCS_TERM = re.compile(r'^(?:(?:ret|reti)\s*$|retd\b|(?:jp|jr|jrl)\s+(?!(?:f|lt|le|ule|ov|pe|mi|z|eq|c|ult|ge|gt|ugt'
                       r'|nov|po|pl|nz|ne|nc|uge)\s*,))', re.I)
TLCS_BRANCH = re.compile(r'^(?:call|calr|jp|jr|jrl|djnz)\b', re.I)
TLCS_REGS = set("xwa xbc xde xhl xix xiy xiz xsp wa bc de hl ix iy iz sp a w b c d e h l".split())
MN_CALL = re.compile(r'^(?:call|calls)\s+([A-Za-z_.$][\w.$]*)')
MN_TERM = re.compile(r'^(?:ret|retf|rets|rti|jmp|bra|lra)\b')
MN_BRANCH = re.compile(r'^(?:call|calls|jmp|bra|beq|bne|bgt|bge|ble|blt|bhi|bcc|bls|bcs|bvc|bvs|bnc|bns)\b')
CONTINUATION = re.compile(r'_(Skip|Join|Loop|Return|Epilogue|Done|Next|Exit|Cont|End|Default|Resume|Nop)\d*$'
                          r'|__[0-9A-Fa-f]{4,6}$|__[a-z]\w*$')     # = semantic_score.py's
IDENT = re.compile(r'(?<![\w.$@])([A-Za-z_.$][\w.$]*)')
MN_BANNER = re.compile(r'^#\s+([A-Za-z_][\w]*)\s+\(CPU 0x[0-9A-Fa-f]+\)\s*$')
ABS_MEM = re.compile(r'\(\s*(0x[0-9A-Fa-f]+|\d{3,})\s*(?::\s*(?:8|16|24|32))?\s*\)')
NUMERIC = re.compile(r'(?:0x[0-9A-Fa-f]+|\d+)(?:\s*:\s*(?:8|16|24|32))?')
HEXNUM = re.compile(r'0x[0-9A-Fa-f]+(?:\s*:\s*(?:8|16|24|32))?')
LABEL_OFFSET = re.compile(r'([A-Za-z_.$][\w.$]*)\s*[-+]\s*(?:0x[0-9A-Fa-f]+|\d+)(?:\s*:\s*(?:8|16|24|32))?')
PLACEHOLDER = re.compile(r'^(?:sub|func|FUN|LABEL|T)_[0-9A-Fa-f]{4,8}$')
DOTL_C = re.compile(r'^\.Lc_[0-9A-Fa-f]{4,8}$')
DOTL = re.compile(r'^\.L[A-Za-z]{0,6}_?[0-9A-Fa-f]{4,8}$')
LOC = re.compile(r'^loc_[0-9A-Fa-f]{4,8}$')
PARENT_HEX = re.compile(r'^[A-Za-z_]\w*__[0-9A-Fa-f]{4,8}$')
EQU = re.compile(r'^\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*(0x[0-9A-Fa-f]+)\s*$')
INCLUDE = re.compile(r'^\s*\.include\s+"([^"]+)"')
BOILERPLATE = re.compile(r"^(?:the same code is in\b|no caller: unreferenced code$|byte-identical\b.*"
                         r"firmware's routine)")
DECOR = " \t-=*~_:.#;"

DEBTS = [  # (json path, label) -- every one of these is a count that must not rise
    ("headers.no_header", "(a) routines without a header"),
    ("headers.call_no_header", "(a) call targets without a header"),
    ("numeric.mem_abs_in_image", "(b) (number) operand in the image"),
    ("numeric.mem_abs_other", "(b) (number) operand elsewhere"),
    ("numeric.imm_in_image", "(b) immediate pointer in the image"),
    ("numeric.branch_numeric", "(b) numeric branch target"),
    ("numeric.branch_label_offset", "(b) Label+N branch target"),
    ("addr_locals.dotL", "(c) .L<hex> locals"),
    ("addr_locals.dotLc", "(c) .Lc_<hex> locals"),
    ("addr_locals.loc", "(c) loc_<hex> locals"),
    ("addr_locals.parent_hex", "(c) Parent__<hex> locals"),
    ("byte_runs.after_fallthrough.runs", "(d) .byte runs after fall-through"),
    ("byte_runs.after_fallthrough.bytes", "(d) ... their bytes"),
    ("byte_runs.after_terminator.runs", "(d) .byte runs after a terminator"),
    ("byte_runs.after_terminator.bytes", "(d) ... their bytes"),
    ("placeholders.total", "(e) placeholder routine names"),
    ("insn_macros", "(f) byte-emitter macro uses"),
]


def git_tracked():
    out = subprocess.run(["git", "-C", ROOT, "ls-files", "-z"], capture_output=True).stdout
    return set(p.decode("utf-8", "surrogateescape") for p in out.split(b"\0") if p)


def strip_comment(line, mn):
    out, q = [], False
    for ch in line:
        if ch == '"':
            q = not q
        if not q and (ch == ';' or (mn and ch == '#')):
            break
        out.append(ch)
    return ''.join(out)


def is_comment(line):
    s = line.lstrip()
    return s.startswith(";") or s.startswith("#")


def resolve(inc, cur_dir, idirs, cwd):
    for d in [cur_dir] + idirs + [cwd]:
        p = os.path.normpath(os.path.join(d, inc))
        if os.path.isfile(os.path.join(ROOT, p)):
            return p
    return None


def image_files(key, tracked):
    model, dialect, cwd, idirs, roots, rng = IMAGES[key]
    if isinstance(roots, str):
        roots = sorted(os.path.relpath(p, ROOT) for p in glob.glob(os.path.join(ROOT, roots)))
    seen, order, untracked = set(), [], []
    stack = list(reversed(roots))
    while stack:
        p = stack.pop()
        if p in seen:
            continue
        seen.add(p)
        if p not in tracked:
            untracked.append(p)
            continue
        order.append(p)
        incs = []
        for raw in open(os.path.join(ROOT, p), "rb").read().split(b"\n"):
            m = INCLUDE.match(raw.decode("latin-1"))
            if m:
                r = resolve(m.group(1), os.path.dirname(p), idirs, cwd)
                if r:
                    incs.append(r)
                else:
                    untracked.append(m.group(1) + " (unresolved, from %s)" % p)
        stack.extend(reversed(incs))
    return order, untracked


class Parsed:
    """One file: raw lines and statements [(lineno, kind, label_or_None, body)]."""

    def __init__(self, path, mn):
        self.path = path
        self.lines = open(os.path.join(ROOT, path), "rb").read().decode("latin-1").split("\n")
        self.macros = {}                # name -> has_instruction
        stmts, cur, has_ins = [], None, False
        for i, ln in enumerate(self.lines):
            c = strip_comment(ln, mn).strip()
            m = re.match(r'^\.macro\s+([A-Za-z_]\w*)', c)
            if m:
                cur, has_ins = m.group(1), False
                continue
            if cur is not None:
                if re.match(r'^\.endm\b', c):
                    self.macros[cur] = has_ins
                    cur = None
                elif c and not c.startswith(".") and not c.startswith("\\") and not LABEL_RE.match(c):
                    has_ins = True
                continue
            if not c:
                continue
            m = LABEL_RE.match(c)
            if m and LABEL_RE.match(ln):
                stmts.append((i, "label", m.group(1), ""))
                c = c[len(m.group(0)):].strip()
                if not c:
                    continue
            stmts.append((i, None, None, c))
        self.stmts = stmts


def kind_of(body, data_macros, insn_macros):
    w = body.split()[0].rstrip(",")
    if w.startswith("."):
        if w == ".byte":
            return "byte"
        return "data" if w in DATA_DIRS else "dir"
    if w in insn_macros:
        return "imac"
    if w in data_macros:
        return "data"
    if re.match(r'^[A-Za-z_.$][\w.$]*\s*=', body):
        return "dir"
    return "ins"


def informative(text, names):
    t = re.sub(r'\(CPU 0x[0-9A-Fa-f]+\)', '', text.strip().lstrip("#;")).strip(DECOR)
    if not t:
        return False
    if t.lower() in names:
        return False
    return not BOILERPLATE.match(t)


def header_lines_above(lines, i):
    """The contiguous comment block directly above line i, one blank line allowed in between."""
    j, blanks = i - 1, 0
    while j >= 0 and not lines[j].strip() and blanks < 1:
        j -= 1
        blanks += 1
    block = []
    while j >= 0 and is_comment(lines[j]):
        block.append(lines[j])
        j -= 1
    return block


def split_operands(ops):
    """Split an operand list on the commas outside () and []."""
    out, depth, cur = [], 0, []
    for ch in ops:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        if ch == "," and depth == 0:
            out.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    if "".join(cur).strip():
        out.append("".join(cur))
    return out


def count_values(body):
    rest = body.split(None, 1)[1] if len(body.split(None, 1)) > 1 else ""
    return len([x for x in rest.split(",") if x.strip()])


def measure(key, cache, tracked, per_file=False):
    model, dialect, cwd, idirs, roots, rng = IMAGES[key]
    mn = dialect == "mn"
    # v142 / v141 (0x400..) overlap ordinary constants
    imm_rng = rng if rng and (rng[0] if isinstance(rng[0], int) else min(r[0] for r in rng)) >= 0x10000 else None
    files, untracked = image_files(key, tracked)
    parsed = []
    for f in files:
        if f not in cache:
            cache[f] = Parsed(f, mn)
        parsed.append(cache[f])
    macros = {}
    insn_macros = set()
    for p in parsed:
        for name, has_ins in p.macros.items():
            macros[name] = macros.get(name, False) or has_ins
            if p.path in INSN_MACRO_FILES:
                insn_macros.add(name)
    data_macros = {n for n, h in macros.items() if not h and n not in insn_macros}
    insn_macros |= {n for n, h in macros.items() if h}
    insn_macros_counted = {n for p in parsed if p.path in INSN_MACRO_FILES for n in p.macros}

    # Name scope: one per image, except for pooled independent programs (cnv's seven converters, which include
    # nothing and reuse the same loc_<address> names), where each root file is its own scope.
    unit_of = {p.path: (p.path if isinstance(roots, str) else 0) for p in parsed}

    # pass 1: statement kinds, call targets, references, kn7000 .equ placeholders.  All sets hold (scope, name).
    calltgts = set()
    equ_ph = set()
    kinds = {}
    addr_ref = set()                                # address taken: any use that is not a branch target
    offset_ref = set()                              # used in a difference, `.short Case - Base`
    jump_files = collections.defaultdict(set)       # branched to (call aside): the files that do it
    for p in parsed:
        u = unit_of[p.path]
        ks = []
        for (i, k, lab, body) in p.stmts:
            if k == "label":
                ks.append("label")
                continue
            kk = kind_of(body, data_macros, insn_macros)
            ks.append(kk)
            parts = body.split(None, 1)
            ops = parts[1] if len(parts) > 1 else ""
            if kk in ("ins", "imac"):
                if kk == "ins":
                    m = (MN_CALL if mn else TLCS_CALL).match(body)
                    if m and m.group(1).lower() not in TLCS_REGS:
                        calltgts.add((u, m.group(1)))
                oplist = split_operands(ops)
                if kk == "ins" and oplist and (MN_BRANCH if mn else TLCS_BRANCH).match(body):
                    ti = 0 if mn else len(oplist) - 1
                    is_call = bool((MN_CALL if mn else TLCS_CALL).match(body))
                    for j, o in enumerate(oplist):
                        for nm in IDENT.findall(o):
                            if j != ti:
                                addr_ref.add((u, nm))
                            elif not is_call:
                                jump_files[(u, nm)].add(p.path)
                else:
                    addr_ref.update((u, nm) for nm in IDENT.findall(ops))
            elif kk in ("data", "byte"):
                for o in split_operands(ops):
                    ids = IDENT.findall(o)
                    (offset_ref if "-" in o and len(ids) >= 2 else addr_ref).update((u, nm) for nm in ids)
            elif kk == "dir":
                m = re.match(r'^\.(?:equ|set)\s+[A-Za-z_.$][\w.$]*\s*,(.*)$', body) or \
                    re.match(r'^[A-Za-z_.$][\w.$]*\s*=(.*)$', body)
                if m:
                    addr_ref.update((u, nm) for nm in IDENT.findall(m.group(1)))
                if mn:
                    m = EQU.match(body)
                    if m and PLACEHOLDER.match(m.group(1)) and in_ranges(rng, int(m.group(2), 16)):
                        equ_ph.add(m.group(1))
        kinds[p.path] = ks

    tot = collections.Counter()
    pf = collections.defaultdict(collections.Counter)
    placeholders = set(equ_ph)
    ph_files = collections.Counter()
    rlist = []                      # (file, line, name, reason, has_header) for --routines
    for p in parsed:
        u = unit_of[p.path]
        ks, st, L = kinds[p.path], p.stmts, p.lines
        fc = pf[p.path]
        n = len(st)
        nxt = [None] * n          # index of the next non-label statement
        prv = [None] * n          # index of the previous non-label statement
        last = None
        for k in range(n):
            prv[k] = last
            if ks[k] != "label":
                last = k
        last = None
        for k in range(n - 1, -1, -1):
            nxt[k] = last
            if ks[k] != "label":
                last = k
        # labels: (a) routines, (c) address locals, (e) placeholders
        for k in range(n):
            if ks[k] != "label":
                continue
            i, _, name, _ = st[k]
            if DOTL_C.match(name):
                fc["addr_locals.dotLc"] += 1
            elif DOTL.match(name):
                fc["addr_locals.dotL"] += 1
            elif LOC.match(name):
                fc["addr_locals.loc"] += 1
            elif PARENT_HEX.match(name):
                fc["addr_locals.parent_hex"] += 1
            q = nxt[k]
            if q is None or ks[q] not in ("ins", "imac"):
                continue
            if PLACEHOLDER.match(name):
                placeholders.add(name)
                ph_files[p.path] += 1
            pp = prv[k]
            un = (u, name)
            is_call = un in calltgts
            after = pp is None or ks[pp] in ("data", "byte", "dir") or (
                ks[pp] == "ins" and (MN_TERM if mn else TLCS_TERM).match(st[pp][3]))
            if is_call:
                why = "call"
            elif not (after or un in addr_ref):
                continue                                # reached by falling into it
            elif CONTINUATION.search(name):
                fc["headers.blocks_declared"] += 1      # named as a part of its parent routine
                continue
            elif un in addr_ref:
                why = "address"
            elif jump_files[un] - {p.path}:
                why = "xfile_jump"
            elif jump_files[un]:
                fc["headers.blocks_jump"] += 1          # a branch target inside one routine
                continue
            elif un in offset_ref:
                fc["headers.blocks_case"] += 1          # a compiled switch's case
                continue
            else:
                why = "unreferenced"
            fc["headers.by_reason." + why] += 1
            block = header_lines_above(L, i)
            hdr = any(informative(b, {name.lower(), name.lower() + ":"}) for b in block)
            rlist.append((p.path, i + 1, name, why, hdr))
            fc["headers.routines"] += 1
            fc["headers.with_header"] += hdr
            fc["headers.no_header"] += not hdr
            if not hdr and (";" in L[i] or (mn and "#" in L[i])):
                fc["headers.inline_only"] += 1
            if is_call:
                fc["headers.call_targets"] += 1
                fc["headers.call_no_header"] += not hdr
        # kn7000 program.s generator banners
        if mn:
            for i, ln in enumerate(L):
                m = MN_BANNER.match(ln)
                if not m:
                    continue
                name = m.group(1)
                if PLACEHOLDER.match(name):
                    placeholders.add(name)
                    ph_files[p.path] += 1
                j = i + 1
                while j < len(L) and (is_comment(L[j]) or not L[j].strip()):
                    j += 1
                if j >= len(L):
                    continue
                c = strip_comment(L[j], True).strip()
                if LABEL_RE.match(L[j]) or not c or kind_of(c, data_macros, insn_macros) != "ins":
                    continue
                a = i
                while a > 0 and is_comment(L[a - 1]):
                    a -= 1
                block = [x for x in L[a:j] if is_comment(x)]
                hdr = any(informative(b, {name.lower()}) for b in block)
                fc["headers.by_reason.banner"] += 1
                rlist.append((p.path, i + 1, name, "banner", hdr))
                fc["headers.routines"] += 1
                fc["headers.with_header"] += hdr
                fc["headers.no_header"] += not hdr
                if (u, name) in calltgts:
                    fc["headers.call_targets"] += 1
                    fc["headers.call_no_header"] += not hdr
        # instructions: (b) numeric operands, (f) macro uses
        for k in range(n):
            kk = ks[k]
            if kk == "imac":
                if st[k][3].split()[0] in insn_macros_counted:
                    fc["insn_macros"] += 1
                continue
            if kk != "ins":
                continue
            body = st[k][3]
            parts = body.split(None, 1)
            ops = parts[1] if len(parts) > 1 else ""
            oplist = split_operands(ops)
            if (MN_BRANCH if mn else TLCS_BRANCH).match(body):
                if not oplist:
                    continue
                t = (oplist[0] if mn else oplist[-1]).strip()
                if t.startswith("(") and t.endswith(")"):
                    t = t[1:-1].strip()
                if NUMERIC.fullmatch(t):
                    fc["numeric.branch_numeric"] += 1
                else:
                    m = LABEL_OFFSET.fullmatch(t)
                    if m and m.group(1).lower() not in TLCS_REGS:
                        fc["numeric.branch_label_offset"] += 1
                continue
            for m in ABS_MEM.finditer(ops):
                v = int(m.group(1), 0)
                if in_ranges(rng, v):
                    fc["numeric.mem_abs_in_image"] += 1
                else:
                    fc["numeric.mem_abs_other"] += 1
            for o in oplist:
                o = o.strip()
                if imm_rng and HEXNUM.fullmatch(o) and in_ranges(imm_rng, int(o.split(":")[0], 16)):
                    fc["numeric.imm_in_image"] += 1
        # (d) .byte runs between instructions
        k = 0
        while k < n:
            if ks[k] != "byte":
                k += 1
                continue
            j, lines_, vals = k, 0, 0
            while j < n and ks[j] in ("byte", "label"):
                if ks[j] == "byte":
                    lines_ += 1
                    vals += count_values(st[j][3])
                j += 1
            pk = prv[k]
            while j < n and ks[j] == "label":
                j += 1
            if pk is not None and j < n and ks[pk] in ("ins", "imac") and ks[j] in ("ins", "imac"):
                term = ks[pk] == "ins" and (MN_TERM if mn else TLCS_TERM).match(st[pk][3])
                w = "byte_runs.after_terminator" if term else "byte_runs.after_fallthrough"
                fc[w + ".runs"] += 1
                fc[w + ".lines"] += lines_
                fc[w + ".bytes"] += vals
            k = j
        fc["files"] += 1
        fc["lines"] += len(L)
        tot.update(fc)
    for f, c in ph_files.items():
        pf[f]["placeholders.total"] = c
    res = dict(model=model, files=tot["files"], lines=tot["lines"], untracked=untracked,
               headers={k: tot["headers." + k] for k in ("routines", "with_header", "no_header", "inline_only",
                                                         "call_targets", "call_no_header", "blocks_jump",
                                                         "blocks_case", "blocks_declared")},
               numeric={k: tot["numeric." + k] for k in ("mem_abs_in_image", "mem_abs_other", "imm_in_image",
                                                         "branch_numeric", "branch_label_offset")},
               addr_locals={k: tot["addr_locals." + k] for k in ("dotL", "dotLc", "loc", "parent_hex")},
               byte_runs={w: {k: tot["byte_runs.%s.%s" % (w, k)] for k in ("runs", "lines", "bytes")}
                          for w in ("after_fallthrough", "after_terminator")},
               placeholders=dict(total=len(placeholders), by_prefix=dict(collections.Counter(
                   n.split("_")[0] + "_" for n in placeholders))),
               insn_macros=tot["insn_macros"])
    h = res["headers"]
    h["by_reason"] = {k: tot["headers.by_reason." + k] for k in ("call", "address", "xfile_jump", "unreferenced",
                                                                  "banner")}
    h["pct"] = round(100.0 * h["with_header"] / h["routines"], 2) if h["routines"] else None
    top = {}
    for path, _ in DEBTS:
        flat = path
        if path == "placeholders.total":
            ranked = sorted(pf, key=lambda f: -pf[f]["placeholders.total"])
        else:
            ranked = sorted(pf, key=lambda f: -pf[f][flat])
        top[path] = [[f, pf[f][flat]] for f in ranked[:5] if pf[f][flat]]
    res["top_files"] = top
    if per_file:
        res["per_file"] = {f: dict(c) for f, c in pf.items()}
        res["routine_list"] = rlist
    return res


def get(d, path):
    for part in path.split("."):
        d = d[part]
    return d


def report(res):
    cols = list(res)
    w = max(len(lab) for _, lab in DEBTS) + 2
    print("%-*s" % (w, "image") + "".join("%11s" % k for k in cols))
    print("%-*s" % (w, "files") + "".join("%11d" % res[k]["files"] for k in cols))
    print("%-*s" % (w, "routines") + "".join("%11d" % res[k]["headers"]["routines"] for k in cols))
    print("%-*s" % (w, "  with a header") + "".join("%11d" % res[k]["headers"]["with_header"] for k in cols))
    print("%-*s" % (w, "  header coverage %") + "".join(
        "%11s" % ("%.1f" % res[k]["headers"]["pct"] if res[k]["headers"]["pct"] is not None else "-") for k in cols))
    print("%-*s" % (w, "call targets") + "".join("%11d" % res[k]["headers"]["call_targets"] for k in cols))
    for why in ("address", "xfile_jump", "unreferenced", "banner"):
        print("%-*s" % (w, "  routines by reason: " + why) + "".join(
            "%11d" % res[k]["headers"]["by_reason"][why] for k in cols))
    for b in ("blocks_jump", "blocks_case", "blocks_declared"):
        print("%-*s" % (w, "  not routines: " + b) + "".join("%11d" % res[k]["headers"][b] for k in cols))
    for path, lab in DEBTS:
        print("%-*s" % (w, lab) + "".join("%11d" % get(res[k], path) for k in cols))
    for k in cols:
        if res[k]["untracked"]:
            print("  %s: not read (untracked or unresolved): %s" % (k, ", ".join(res[k]["untracked"])))


def top_report(res):
    print("worst files per debt (at most five per image)")
    for path, lab in DEBTS:
        rows = [(k, f, c) for k in res for f, c in res[k]["top_files"].get(path, [])[:3]]
        if not rows:
            continue
        print("  " + lab)
        for k, f, c in rows:
            print("    %-10s %7d  %s" % (k, c, f))


def run_all(per_file_key=None):
    tracked = git_tracked()
    cache = {}
    return collections.OrderedDict((k, measure(k, cache, tracked, per_file=(k == per_file_key))) for k in IMAGES)


def newest_committed(outdir):
    out = subprocess.run(["git", "-C", ROOT, "ls-files", os.path.join(outdir, "doc-quality-*.json")],
                         capture_output=True, text=True).stdout.split()
    return sorted(out)[-1] if out else None


def compare(res, old_path):
    old = json.load(open(os.path.join(ROOT, old_path)))["images"]
    rose = 0
    missing = [key for key in old if key not in res or (old[key].get("files") and not res[key]["files"])]
    for key in missing:
        print("GONE  %-10s (in %s, not measured now: a renamed image key, or a root file that is gone or "
              "untracked)" % (key, old_path))
    for key in res:
        if key in missing:
            continue
        if key not in old:
            print("new   %-10s (not in %s)" % (key, old_path))
            continue
        for path, lab in DEBTS:
            try:
                o = get(old[key], path)
            except KeyError:
                continue
            n = get(res[key], path)
            if n > o:
                rose += 1
                print("ROSE  %-10s %-40s %d -> %d" % (key, lab, o, n))
            elif n < o:
                print("fell  %-10s %-40s %d -> %d" % (key, lab, o, n))
    print("compared with %s: %s%s" % (old_path, "%d figure(s) ROSE" % rose if rose else "nothing rose",
                                      ", %d image(s) GONE" % len(missing) if missing else ""))
    if rose:
        print("  (a rise is a regression unless the commit message says why, e.g. converted passthrough adds routines)")
    return 1 if rose or missing else 0


def snapshot_number(outdir, day):
    nums = sorted(int(m.group(1)) for f in glob.glob(os.path.join(ROOT, outdir, "doc-quality-%s-[0-9][0-9].json" % day))
                  for m in [re.search(r"-(\d\d)\.json$", f)] if m)
    if not nums:
        return 1
    last = os.path.join(ROOT, outdir, "doc-quality-%s-%02d.json" % (day, nums[-1]))
    tracked = subprocess.run(["git", "-C", ROOT, "ls-files", "--error-unmatch", last], capture_output=True).returncode == 0
    return nums[-1] + 1 if tracked else nums[-1]


def snapshot(res, outdir):
    import contextlib
    import io
    day = datetime.date.today().isoformat()
    head = subprocess.run(["git", "-C", ROOT, "rev-parse", "--short=8", "HEAD"], capture_output=True,
                          text=True).stdout.strip()
    dirty = bool(subprocess.run(["git", "-C", ROOT, "status", "--porcelain", "--untracked-files=no"],
                                capture_output=True, text=True).stdout.strip())
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        print("doc-quality census, %s, measured at %s%s" % (day, head, " (+ uncommitted changes)" if dirty else ""))
        print("tool: scripts/analysis/doc_quality_census.py (rules in its docstring)\n")
        report(res)
        print()
        top_report(res)
    os.makedirs(os.path.join(ROOT, outdir), exist_ok=True)
    base = os.path.join(ROOT, outdir, "doc-quality-%s-%02d" % (day, snapshot_number(outdir, day)))
    open(base + ".txt", "w").write(buf.getvalue())
    json.dump(dict(date=day, head=head, dirty=dirty, images=res), open(base + ".json", "w"), indent=1)
    print("wrote %s.txt and %s.json" % (os.path.relpath(base, ROOT), os.path.relpath(base, ROOT)))


def main():
    args = sys.argv[1:]
    rk = args[args.index("--routines") + 1] if "--routines" in args else None
    pfk = args[args.index("--files") + 1] if "--files" in args else rk
    if pfk and pfk not in IMAGES:
        sys.exit("unknown image %s; one of %s" % (pfk, " ".join(IMAGES)))
    if rk:
        r = measure(rk, {}, git_tracked(), per_file=True)
        for f, ln, name, why, hdr in r["routine_list"]:
            print("%s:%d\t%s\t%s\t%s" % (f, ln, name, why, "header" if hdr else "NO-HEADER"))
        return
    res = run_all(pfk)
    if pfk:
        pf = res[pfk]["per_file"]
        keys = ["headers.routines", "headers.no_header"] + [p for p, _ in DEBTS if p not in ("headers.no_header",)]
        print("%-60s " % "file" + " ".join("%8s" % k.split(".")[-1][:8] for k in keys))
        for f in sorted(pf):
            print("%-60s " % f[-60:] + " ".join("%8d" % pf[f].get(k, 0) for k in keys))
        return
    if "--json" in args:
        json.dump(res, open(args[args.index("--json") + 1], "w"), indent=1)
    if "--compare" in args:
        i = args.index("--compare")
        old = args[i + 1] if i + 1 < len(args) and not args[i + 1].startswith("--") else newest_committed("docs/coverage")
        if not old:
            print("no committed doc-quality snapshot to compare with")
        elif compare(res, old):
            sys.exit(1)
        if "--snapshot" not in args:
            return
    if "--snapshot" in args:
        snapshot(res, args[args.index("--snapshot") + 1])
        return
    report(res)


if __name__ == "__main__":
    main()
