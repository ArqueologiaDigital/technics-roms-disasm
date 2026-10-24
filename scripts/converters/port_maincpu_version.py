#!/usr/bin/env python3
r"""Port a KN5000 main-program source tree onto another firmware version's dump.

QUESTION THIS ANSWERS
    v7/maincpu assembles byte-exact to the v7 ROM.  The v6 (and v5) dumps have no
    source.  How much of v7's text carries over to v6 unchanged, how much needs only
    its operands rewritten (a moved RAM variable, a constant), and which bytes of v6
    have no v7 line at all?  With --emit it writes the ported tree (v6/maincpu) whose
    every line is either v7's text, v7's text with operands taken from the v6 bytes, or
    -- where no v7 line maps -- the v6 bytes as `.byte` rows marked
    `; TODO(port): v6 bytes with no v7 line` (verbatim debt, counted by
    scripts/analysis/kn5000_source_coverage.py).  A later pass turns those rows
    into instructions.

HOW
  1. Address map of the SOURCE tree: every byte-emitting line -> address, with
     scripts/analysis/address_line_map.py's marker technique (the marked mirror is
     checked byte-identical to the source tree's own build).
  2. Byte alignment source ROM -> target ROM: unique 16-byte anchors chained
     monotonically and extended (scripts/analysis/kn5000_version_delta.py), then
     difflib inside every gap whose two sides differ in size.  Equal-size gaps
     between matched blocks map byte for byte (a substitution).  The alignment runs
     twice: the second time every ROM pointer of a source `.long` line is first
     replaced by the target address the first pass maps its target to, so a pointer
     table is matched by what it points at.  (Raw pointer values recur shifted: v7's
     SndParam_Registry values reappear 12 slots further on in v6's registry because
     the records moved by 252 B, and the first pass paired those.)  Result: a delta
     for every mapped source byte.  A size-changing gap whose source lines are mostly
     instructions is then re-aligned by instruction: both sides are decoded with
     llvm-mc and the two sequences matched by shape (numbers ignored); that mapping
     replaces the byte one when it pairs more lines.  A gap of data lines is matched
     again with its untranslated pointers masked.
  3. A source line whose bytes all map with ONE delta is PORTED to address+delta.
     Equal bytes: the text is kept.  Different bytes: every number / symbol
     operand whose source value sits little-endian in the line's bytes at an
     offset where the bytes differ takes the target value from the same offset;
     a relative branch keeps its label when the label lands on the target the
     displacement names.  The rewritten line is assembled in isolation, with every
     symbol replaced by its required value, and must reproduce the target bytes;
     else the line becomes `.byte`.
  4. Unmapped source lines and target bytes with no source line become `.byte`
     rows.  The labels of unmapped lines are placed by their uses (step 6), else by
     the bytes that follow them in the source found once inside the target gap.  A
     label that neither places names source bytes the target dropped or changed
     (Port.settle_tentative): its uses as a pointer anywhere in the image, the compiled
     C data included, are added to the votes; if that does not place it, it is DROPPED
     unless the target's assembly still has to spell it (an expression such as
     `.short Case - Base`, a `.set` line, a macro body).  A dropped label is not
     emitted -- a `; port:` comment marks where it was and DST/maincpu/
     port_dropped_labels.txt lists it -- and its uses are written with the label of
     the address their bytes name.  A dropped label whose uses agree on an address no
     label holds is placed there instead (Port.new_labels).  A label of dropped bytes
     that lands where another label stands is treated the same way, so two names never
     share one address.
  5. A symbol defined by `.equ`/`.set` to a number (a RAM variable), or to
     `Label +/- K`, whose uses require one new value gets it at its definition.  Uses
     that disagree get the number written at the use instead.  Two exceptions:
     a `Label + K` alias that no target line uses and that now resolves onto another
     label, its bytes not there, is dropped like a label;
     a `Label + K` name whose record is in the target unchanged where it now resolves,
     or whose uses point where another label stands, is not re-aimed (a use pointing
     elsewhere is written with the name of what it points to), and a numeric constant whose new value another constant of
     its family keeps -- confirmed by that constant's own uses -- is not re-valued (its
     uses are written with that constant).  An unconfirmed shared value is re-valued and
     its comment says so (Port.const_at gives the two readings).
  6. Labels go where their uses say: every mapped use votes for the target address
     its bytes name, and a label moves into the inserted bytes before its line when
     three fifths of the votes put it there.  A target address no label names gets a
     new one when it starts an emitted line or lies in a raw run (see Port.new_labels
     for the names).
  Afterwards scripts/converters/disassemble_port_todo.py turns the TODO(port) rows
  that are code into instructions, and scripts/tools/port_hand_edits.py redoes the
  edits a generated tree carries.  scripts/analysis/check_ported_labels.py checks the
  result: for every carried label, does the target hold its source bytes?

RUN
    python3 scripts/converters/port_maincpu_version.py --src v7 --dst v6 \
        --rom ~/compartilhado/technics_roms/roms/kn5000/kn5000_v6_program.rom   # stats only
    ... --emit                      # write v6/maincpu (overwrites it)
    --cache DIR keeps the address map and alignment between runs
    (default $TMPDIR/port-<src>-<dst>; delete it after the source tree changes).

INPUTS
    The source tree must be built (its includes/generated/*.bin exist): `make all`.
    The target ROM is read from --rom; it is the private dump and is never copied
    into the tree.
"""
import argparse
import bisect
import collections
import difflib
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import address_line_map as alm  # noqa: E402
import kn5000_version_delta as vd  # noqa: E402

BASE = 0xE00000
MC = alm.MC
NM = alm.NM
OBJCOPY = alm.OBJCOPY
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')


# ------------------------------------------------------------------ address map
def tree_map(tree):
    """-> (order, syms, rom).  order: every line of every included file in emission
    order, [addr or None, relpath, lineno, text]; syms: ELF symbol -> value; rom: the
    marked mirror's own image (it must equal the tree's build)."""
    srcdir = os.path.join(ROOT, tree, "maincpu")
    alm.SRCDIR = srcdir
    alm.ROOT_S = "kn5000_%s_program.s" % tree
    ent, tmp, elf = alm.build()
    raw = os.path.join(tmp, "m.bin")
    subprocess.run([OBJCOPY, "-O", "binary", elf, raw], check=True)
    rom = open(raw, "rb").read()
    pos = {}
    for a, src, line, text in ent:
        rel = os.path.relpath(os.path.join(ROOT, src), srcdir)
        pos[(rel, line)] = a
    order = []

    def walk(rel):
        lines = open(os.path.join(srcdir, rel), encoding="latin-1").read().split("\n")
        for i, ln in enumerate(lines):
            order.append([pos.get((rel, i + 1)), rel, i + 1, ln, (rel, i + 1) in pos])
            m = re.match(r'^\s*(?:[A-Za-z_.$][\w.$]*:\s*)*\.include\s+"([^"]+)"', ln.split(";")[0])
            if m:
                walk(m.group(1))
    walk(alm.ROOT_S)
    syms = {}
    out = subprocess.run([NM, "--defined-only", elf], capture_output=True, text=True).stdout
    for line in out.splitlines():
        p = line.split()
        if len(p) == 3 and not p[2].startswith(alm.MARK):
            syms[p[2]] = int(p[0], 16)
    shutil.rmtree(tmp, ignore_errors=True)
    return order, syms, rom


def fill_sizes(order):
    """Give every line an address (the next marked line's when unmarked) and a size
    (bytes up to the next marked line; 0 for lines that emit nothing)."""
    nxt = None
    for e in reversed(order):
        if e[0] is None:
            e[0] = nxt
        else:
            nxt = e[0]
    marked = [i for i, e in enumerate(order) if e[4] and is_marked(e[3])]
    size = [0] * len(order)
    for k, i in enumerate(marked):
        j = marked[k + 1] if k + 1 < len(marked) else None
        end = order[j][0] if j is not None else BASE + 0x200000
        size[i] = end - order[i][0]
    return size


def code_part(text):
    """the text before a `;` comment that is not inside a string literal"""
    q = False
    for k, ch in enumerate(text):
        if ch == '"':
            q = not q
        elif ch == ';' and not q:
            return text[:k]
    return text


def is_marked(text):
    """lines address_line_map marks (it marks every non-blank code line); only the
    ones that can emit bytes get a size -- labels, .set/.equ, .include and other
    pseudo-ops that emit nothing are 0 even when marked"""
    code = code_part(text).strip()
    while True:
        m = LABEL.match(code)
        if not m:
            break
        code = code[m.end():].strip()
    if not code:
        return False
    word = code.split(None, 1)[0].lower()
    if word in (".set", ".equ", ".include", ".macro", ".endm", ".ifndef", ".ifdef", ".if",
                ".else", ".endif", ".global", ".globl", ".text", ".section", ".type",
                ".size", ".local", ".weak", ".eqv", ".file", ".p2align", ".balign", ".align"):
        return word in (".p2align", ".balign", ".align")
    return True


# ------------------------------------------------------------------ alignment
def align(a, b, k=16, max_gap=24000):
    """-> dm, a list: dm[i] = delta (target offset - source offset) of source byte i,
    or None.  Blocks of identical bytes from unique k-gram anchors, equal-size gaps
    mapped byte for byte, and difflib inside the size-changing gaps."""
    vd.K = k
    bl = vd.blocks(a, b, vd.anchors(a, b))
    dm = [None] * len(a)

    def put(s, e, d):
        for i in range(s, e):
            dm[i] = d

    def refine(pa, ea, pb, eb, depth=0):
        la, lb = ea - pa, eb - pb
        if la <= 0 or lb <= 0:
            return
        if la == lb:
            put(pa, ea, pb - pa)
            return
        if la > max_gap or lb > max_gap:
            return
        sm = difflib.SequenceMatcher(None, a[pa:ea], b[pb:eb], autojunk=False)
        mb = [(i, j, n) for i, j, n in sm.get_matching_blocks() if n >= 4]
        qa, qb = pa, pb
        for i, j, n in mb:
            refine(qa, pa + i, qb, pb + j, depth + 1) if (pa + i - qa) == (pb + j - qb) else None
            put(pa + i, pa + i + n, pb + j - (pa + i))
            qa, qb = pa + i + n, pb + j + n
        if ea - qa == eb - qb:
            put(qa, ea, qb - qa)

    pa = pb = 0
    gaps = []
    for s, e, sb in bl + [(len(a), len(a), len(b))]:
        refine(pa, s, pb, sb)
        if s > pa or sb > pb:
            gaps.append((pa, s, pb, sb))
        put(s, e, sb - s)
        pa, pb = e, sb + (e - s)
    return dm, gaps


# ------------------------------------------------------------------ instruction decoding
UNIDASM = os.path.expanduser("~/compartilhado/tools/unidasm")
UNSPELLED = "=byte "    # text prefix: an instruction MAME decodes that llvm-mc cannot spell


def unidasm_region(bs):
    """MAME's linear decode of bs: {offset: (length, text)}"""
    d = tempfile.mkdtemp(prefix="port-unidasm-")
    f = os.path.join(d, "seg.bin")
    open(f, "wb").write(bs)
    out = subprocess.run([UNIDASM, f, "-arch", "tlcs900", "-basepc", "0"], capture_output=True,
                         text=True).stdout
    shutil.rmtree(d)
    res = {}
    for ln in out.splitlines():
        m = re.match(r'^([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)$', ln)
        if m:
            res[int(m.group(1), 16)] = (len(m.group(2).split()), m.group(3).strip())
    return res


def mame_spellings(text, off, n):
    """llvm-mc spellings to try for one MAME-decoded instruction at offset off"""
    t = text.lower()
    mn, _, ops = t.partition(" ")
    ops = ", ".join(x.strip() for x in ops.split(",")) if ops else ""
    if mn in REL and ops:
        parts = ops.split(", ")
        try:
            tgt = int(parts[-1], 16)
            parts[-1] = str(tgt - (off + n))
            ops = ", ".join(parts)
        except ValueError:
            pass
    m = re.match(r'^(0x[0-9a-f]+), (\w+)$', ops)
    if mn in ("sll", "srl", "sla", "sra", "rl", "rr", "rlc", "rrc") and m:
        ops = "%s, %d" % (m.group(2), int(m.group(1), 16) or 16)
    m = re.match(r'^(\w+), (x\w\w[+-].*)$', ops)
    if mn == "lda" and m:
        ops = "%s, (%s)" % (m.group(1), m.group(2))
    base = mn + (" " + ops if ops else "")
    cands = [base]
    if re.search(r'\((0x[0-9a-f]+)\)', base):
        for suf in (":8", ":16", ":24"):
            cands.append(re.sub(r'\((0x[0-9a-f]+)\)', r"(\1" + suf + ")", base))
    return cands


def decode_region(bs, limit=400):
    """-> [(offset, length, text)] for the instructions llvm-mc decodes from bs, each
    re-encoding to exactly its own bytes.  Where llvm-mc cannot decode, MAME's decode of
    that one instruction is tried in llvm-mc spellings; if none re-encodes, the item's
    text is UNSPELLED + MAME's text (a `.byte` row with that comment).  A byte that starts
    no instruction either decodes is an item (offset, 1, None)."""
    out = []
    pos = 0
    mame = None
    for _ in range(limit):
        if pos >= len(bs):
            break
        r = subprocess.run([MC, "-triple=tlcs900", "--disassemble", "-show-encoding"],
                           input=" ".join("0x%02x" % x for x in bs[pos:]), capture_output=True, text=True)
        for ln in r.stdout.splitlines():
            m = re.match(r'^\s*(.*?)\s*; encoding: \[(.*)\]\s*$', ln)
            if not m:
                continue
            enc = bytes(int(x, 16) for x in m.group(2).split(","))
            if bs[pos:pos + len(enc)] != enc:
                break
            out.append((pos, len(enc), re.sub(r'\s+', " ", m.group(1)).strip()))
            pos += len(enc)
        if pos >= len(bs):
            break
        if mame is None:
            mame = unidasm_region(bs)
        if pos in mame and pos + mame[pos][0] <= len(bs) and mame[pos][1].split(None, 1)[0] != "db":
            n, text = mame[pos]
            cands = mame_spellings(text, pos, n)
            enc = assemble_batch(cands, "v7", "")
            hit = next((c for c, e in zip(cands, enc) if e == bs[pos:pos + n]), None)
            out.append((pos, n, hit if hit else UNSPELLED + text))
            pos += n
        else:
            out.append((pos, 1, None))          # this byte does not start an instruction
            pos += 1
    while pos < len(bs):
        out.append((pos, 1, None))
        pos += 1
    return natural(out, bs)


# the disassembler prints some forms under a pseudo mnemonic that the sources spell naturally
NATURAL = [
    (re.compile(r'^ld_rr[bwl] (\w+), (\w+), (\w+)$'), r"ld \1, (\2+\3)"),
    (re.compile(r'^(push|pop)_a$'), r"\1 a"),
    (re.compile(r'^call_24 (.*)$'), r"call \1"),
    (re.compile(r'^jp_24 (.*)$'), r"jp \1"),
]


def natural(items, bs):
    """replace a pseudo-mnemonic text by its natural spelling when that encodes the same"""
    cands = []
    for k, (o, l, t) in enumerate(items):
        if t is None:
            continue
        for rx, sub in NATURAL:
            if rx.match(t):
                cands.append((k, rx.sub(sub, t)))
                break
    if not cands:
        return items
    enc = assemble_batch([c for k, c in cands], "v7", "")
    items = list(items)
    for (k, c), e in zip(cands, enc):
        o, l, t = items[k]
        if e == bs[o:o + l]:
            items[k] = (o, l, c)
    return items


def label_stem(name):
    """a label without the suffixes this tool and disassemble_port_todo.py add to make
    names for unnamed targets, so a new name is built on the routine, not on another
    generated name (Foo_Skip, not Foo_Skip_Skip2)"""
    return re.sub(r'(_(?:Skip|Loop|Entry|Data|Body)\d*)+$', "", name) or name


def skeleton(text):
    """an instruction's shape: its text with every number replaced by #"""
    if text is None:
        return None
    return re.sub(r'-?\b(0x[0-9a-f]+|\d+)\b', "#", text)


# ------------------------------------------------------------------ driver
def load(args):
    cache = args.cache or os.path.join(tempfile.gettempdir(), "port-%s-%s" % (args.src, args.dst))
    os.makedirs(cache, exist_ok=True)
    args.cache = cache
    # the map is cached under a hash of every source file, so an edited source tree is re-mapped
    h = hashlib.sha1()
    sdir = os.path.join(ROOT, args.src, "maincpu")
    for dp, dn, fn in sorted(os.walk(sdir)):
        dn.sort()
        for name in sorted(fn):
            if name.endswith((".s", ".c", ".h", ".ld", ".json")) or "/generated" in dp:
                h.update(name.encode())
                h.update(open(os.path.join(dp, name), "rb").read())
    tag = h.hexdigest()[:16]
    f = os.path.join(cache, "map_%s_%s.json" % (args.src, tag))
    if os.path.exists(f):
        d = json.load(open(f))
        order, syms = d["order"], d["syms"]
        rom = open(os.path.join(cache, "rom_%s_%s.bin" % (args.src, tag)), "rb").read()
    else:
        order, syms, rom = tree_map(args.src)
        json.dump({"order": order, "syms": syms}, open(f, "w"))
        open(os.path.join(cache, "rom_%s_%s.bin" % (args.src, tag)), "wb").write(rom)
    tgt = open(args.rom, "rb").read()
    key = hashlib.sha1(rom + tgt).hexdigest()[:16]
    g = os.path.join(cache, "dm2_%s.json" % key)
    if os.path.exists(g):
        d = json.load(open(g))
        dm, gaps = d["dm"], d["gaps"]
    else:
        dm, gaps = align(rom, tgt)
        json.dump({"dm": dm, "gaps": gaps}, open(g, "w"))
    # second pass: the source's `.long` pointers written as the target addresses the first
    # pass maps their targets to, so a pointer table is matched by what it points at and
    # not by its raw values (which can recur shifted: v7's SndParam_Registry values sit
    # 12 slots further on in v6's registry, because the records they name moved by 252 B)
    trom, args.tptr = translate_pointers(order, rom, dm)
    key3 = hashlib.sha1(trom + tgt).hexdigest()[:16]
    g3 = os.path.join(cache, "dm3_%s.json" % key3)
    if os.path.exists(g3):
        d = json.load(open(g3))
        dm, gaps = d["dm"], d["gaps"]
    else:
        dm, gaps = align(trom, tgt)
        json.dump({"dm": dm, "gaps": gaps}, open(g3, "w"))
    args.gaps = gaps
    args.trom = trom
    return order, syms, rom, tgt, dm


def translate_pointers(order, rom, dm):
    """the source image with every ROM pointer of a `.long` line replaced by the target
    address dm maps it to (left as it is where dm does not map it)"""
    order = [list(e) for e in order]
    size = fill_sizes(order)
    out = bytearray(rom)
    at = set()
    for i, e in enumerate(order):
        if not size[i] or e[0] is None:
            continue
        body = split_line(e[3])[1]
        if not body.lower().startswith(".long") or size[i] % 4:
            continue
        o = e[0] - BASE
        for k in range(o, o + size[i], 4):
            v = le(rom, k, 4)
            if BASE <= v < BASE + len(rom) and dm[v - BASE] is not None:
                out[k:k + 4] = (v + dm[v - BASE]).to_bytes(4, "little")
                at.add(k)
    print("pointers of .long lines translated for the second alignment pass:", len(at))
    return bytes(out), at


def classify(order, size, rom, tgt, dm):
    cls = []
    for i, e in enumerate(order):
        n = size[i]
        if n == 0:
            cls.append(("none", None))
            continue
        o = e[0] - BASE
        ds = set(dm[o:o + n])
        if len(ds) == 1 and None not in ds:
            d = ds.pop()
            same = rom[o:o + n] == tgt[o + d:o + d + n]
            cls.append(("same" if same else "diff", d))
        else:
            cls.append(("unmapped", None))
    return cls


# ------------------------------------------------------------------ line parsing
REL = {"jr", "jrl", "calr", "djnz", "djnz16", "djnz8"}
REL_W = {"jr": 1, "djnz": 1, "djnz8": 1, "jrl": 2, "calr": 2, "djnz16": 1}  # djnz16: 16-bit counter, 8-bit displacement
RESERVED = set("""a w b c d e h l wa bc de hl ix iy iz sp xwa xbc xde xhl xix xiy xiz xsp
    ixl ixh iyl iyh izl izh qa qw qb qc qd qe qh ql qwa qbc qde qhl qix qiy qiz qsp
    ra rw rb rc rd re rh rl t f z nz nc ov nov pl mi ge lt gt le uge ult ugt ule eq ne
    v nv m p sr pc opc i3 io""".split())
IDENT = re.compile(r'(?<![\w.$@\\])([A-Za-z_.$][\w.$]*)(?![\w$])')
NUM = re.compile(r'(?<![\w.$\\])(0x[0-9a-fA-F]+|\d+)(?![\w.$])')
EQU_EXPR = re.compile(r'^\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*([A-Za-z_.$][\w.$]*)\s*([+-])\s*'
                      r'(0x[0-9a-fA-F]+|\d+)\s*$')
DATA_W = {".byte": 1, ".short": 2, ".hword": 2, ".2byte": 2, ".long": 4, ".4byte": 4, ".int": 4}


def split_line(text):
    """-> (labels, body, comment-with-semicolon-or-'')"""
    code = code_part(text)
    com = text[len(code):]
    rest = code.strip()
    labels = []
    while True:
        m = LABEL.match(rest)
        if not m:
            break
        labels.append(m.group(1))
        rest = rest[m.end():].strip()
    return labels, rest, com.rstrip()


def quoted_spans(s):
    return [(m.start(), m.end()) for m in re.finditer(r'"(?:[^"\\]|\\.)*"', s)]


def tokens(ops):
    """symbol and number tokens of an operand string -> [(start, end, kind, text)]"""
    q = quoted_spans(ops)
    out = []
    for m in IDENT.finditer(ops):
        if any(a <= m.start() < b for a, b in q) or m.group(1).lower() in RESERVED:
            continue
        out.append((m.start(), m.end(), "sym", m.group(1)))
    for m in NUM.finditer(ops):
        if any(a <= m.start() < b for a, b in q):
            continue
        if m.start() > 0 and ops[m.start() - 1] == ":":
            continue                       # a size / form suffix such as :8, :24, :i3
        out.append((m.start(), m.end(), "num", m.group(1)))
    out.sort()
    return out


def split_commas(ops):
    parts, depth, cur, q = [], 0, "", False
    for ch in ops:
        if ch == '"':
            q = not q
        if not q and ch in "([":
            depth += 1
        if not q and ch in ")]":
            depth -= 1
        if ch == "," and depth == 0 and not q:
            parts.append(cur)
            cur = ""
        else:
            cur += ch
    parts.append(cur)
    return parts


def le(b, off, w):
    return int.from_bytes(b[off:off + w], "little")


def sval(v, w):
    return v - (1 << (8 * w)) if v >= 1 << (8 * w - 1) else v


def fmt_like(orig, v):
    """a number written the way `orig` was (hex lowercase, same digit count, or decimal)"""
    if orig.lower().startswith("0x"):
        return "0x%0*x" % (len(orig) - 2, v)
    return str(v)


def ascii_text(bs):
    out = []
    for x in bs:
        if x == 0x22:
            out.append('\\"')
        elif x == 0x5c:
            out.append('\\\\')
        elif 0x20 <= x < 0x7f:
            out.append(chr(x))
        else:
            out.append('\\%03o' % x)
    return '"' + "".join(out) + '"'


# ------------------------------------------------------------------ isolated assembly
def macro_prelude(tree):
    """shared/macros.s plus every other `.macro` block of the tree, so that a macro
    invocation can be assembled on its own"""
    srcdir = os.path.join(ROOT, tree, "maincpu")
    out = ['\t.include "shared/macros.s"']
    for dp, dn, fn in sorted(os.walk(srcdir)):
        for f in sorted(fn):
            if not f.endswith(".s") or os.path.join(dp, f).endswith("shared/macros.s"):
                continue
            inm = False
            for ln in open(os.path.join(dp, f), encoding="latin-1"):
                c = code_part(ln).strip()
                if re.match(r'^\.macro\b', c):
                    inm = True
                if inm:
                    out.append(ln.rstrip("\n"))
                if re.match(r'^\.endm\b', c):
                    inm = False
    return "\n".join(out)


def assemble_batch(texts, tree, prelude, chunk=4000):
    """assemble each text alone (llvm-mc runs of `chunk` texts); -> list of bytes,
    None where the text does not assemble"""
    if len(texts) > chunk:
        out = []
        for k in range(0, len(texts), chunk):
            out.extend(assemble_batch(texts[k:k + chunk], tree, prelude, chunk))
        return out
    res = [None] * len(texts)
    live = list(range(len(texts)))
    for _ in range(80):
        if not live:
            break
        d = tempfile.mkdtemp(prefix="port-asm-")
        src = prelude.split("\n") + ["\t.text"]
        lineof = {}
        for k, i in enumerate(live):
            src.append("__t%d:" % k)
            for ln in texts[i].split("\n"):      # `.set` lines, then the line under test
                src.append("\t" + ln)
                lineof[len(src)] = k
        src.append("__t%d:" % len(live))
        open(os.path.join(d, "t.s"), "w", encoding="latin-1").write("\n".join(src) + "\n")
        r = subprocess.run([MC, "-triple=tlcs900", "-filetype=obj", "-I", os.path.join(ROOT, tree, "maincpu"),
                            "-o", os.path.join(d, "t.o"), os.path.join(d, "t.s")], capture_output=True,
                           text=True, encoding="latin-1")
        if r.returncode != 0:
            bad = set()
            # an error inside a macro body is reported at <instantiation>, followed by
            # "t.s:N:M: note: while in macro instantiation" naming the invoking line
            for m in re.finditer(r't\.s:(\d+):\d+: (?:error|note: while in macro)', r.stderr):
                k = lineof.get(int(m.group(1)))
                if k is not None:
                    bad.add(k)
            shutil.rmtree(d)
            if not bad:
                # an error with no line ("<unknown>:0: error: expected relocatable
                # expression", raised while writing the object): split and retry
                if len(live) == 1:
                    break
                half = len(live) // 2
                for part in (live[:half], live[half:]):
                    sub = assemble_batch([texts[i] for i in part], tree, prelude, chunk)
                    for i, b in zip(part, sub):
                        res[i] = b
                return res
            live = [i for k, i in enumerate(live) if k not in bad]
            continue
        subprocess.run([OBJCOPY, "-O", "binary", "-j", ".text", os.path.join(d, "t.o"),
                        os.path.join(d, "t.bin")], check=True)
        blob = open(os.path.join(d, "t.bin"), "rb").read()
        off = {}
        out = subprocess.run([NM, os.path.join(d, "t.o")], capture_output=True, text=True).stdout
        for line in out.splitlines():
            p = line.split()
            if len(p) == 3 and p[2].startswith("__t"):
                off[int(p[2][3:])] = int(p[0], 16)
        shutil.rmtree(d)
        for k, i in enumerate(live):
            if k in off and k + 1 in off:
                res[i] = blob[off[k]:off[k + 1]]
        break
    return res


# ------------------------------------------------------------------ the port
class Port:
    def __init__(self, args):
        self.args = args
        self.order, self.syms, self.rom, self.tgt, self.dm = load(args)
        self.cache = args.cache
        self.size = fill_sizes(self.order)
        self.parsed = [split_line(e[3]) for e in self.order]
        self.realign_code_gaps(args.gaps)
        self.cls = classify(self.order, self.size, self.rom, self.tgt, self.dm)
        # source values: ELF symbols plus every label line (locals are not in the ELF)
        self.sv = dict(self.syms)
        for i, e in enumerate(self.order):
            for lab in self.parsed[i][0]:
                self.sv.setdefault(lab, e[0])
        self.labels_src = {}            # label -> order index of its line
        for i, (labs, body, com) in enumerate(self.parsed):
            for lab in labs:
                self.labels_src.setdefault(lab, i)
        self.equ_lines = {}             # numeric .equ/.set symbol -> order index
        for i, (labs, body, com) in enumerate(self.parsed):
            m = re.match(r'^\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*$', body)
            if m:
                self.equ_lines.setdefault(m.group(1), i)
        self.equ_expr = {}              # `.set NAME, BASE +/- K` -> (index, base, sign, K text)
        for i, (labs, body, com) in enumerate(self.parsed):
            m = EQU_EXPR.match(body)
            if m:
                self.equ_expr.setdefault(m.group(1), (i, m.group(2), m.group(3), m.group(4)))
        self.refcount = self._refcount()
        self.macros = set(re.findall(r'^\s*\.macro\s+([A-Za-z_.$][\w.$]*)', macro_prelude(args.src)
                                     + open(os.path.join(ROOT, args.src, "maincpu", "shared", "macros.s"),
                                            encoding="latin-1").read(), re.M))
        # the macros whose body branches relatively: only those are kept untested on equal bytes
        self.macros_lc = set()
        calls = {}
        cur = None
        for ln in (macro_prelude(args.src) + "\n" + open(os.path.join(
                ROOT, args.src, "maincpu", "shared", "macros.s"), encoding="latin-1").read()).split("\n"):
            c = code_part(ln).strip()
            m = re.match(r'^\.macro\s+([A-Za-z_.$][\w.$]*)', c)
            if m:
                cur = m.group(1).lower()
            elif c.startswith(".endm"):
                cur = None
            elif cur and c.split(None, 1) and c.split(None, 1)[0].lower() in REL:
                self.macros_lc.add(cur)
            elif cur and c.split(None, 1):
                calls.setdefault(cur, set()).add(c.split(None, 1)[0].lower())
        grew = True
        while grew:                     # a macro that invokes one that branches, branches
            grew = False
            for mac, inner in calls.items():
                if mac not in self.macros_lc and inner & self.macros_lc:
                    self.macros_lc.add(mac)
                    grew = True
        self.macro_rel = set()          # symbols a macro body branches to relatively
        self.newequ = {}
        self.newexpr = {}

    def realign_code_gaps(self, gaps):
        """Inside a gap between the anchor blocks, byte matching pairs lines badly where
        code was inserted or changed: it maps a few equal bytes and cuts instructions.
        Where the source lines of a gap are mostly instructions, decode both sides and match
        the two instruction sequences by shape (mnemonic and operands, numbers ignored);
        matched lines map to their instruction, the rest are unmapped.  The new mapping is
        kept when it pairs more lines than the byte mapping maps with equal bytes."""
        starts = sorted((e[0] - BASE, i) for i, e in enumerate(self.order) if self.size[i] > 0)
        keys = [a for a, i in starts]
        cache = os.path.join(self.cache, "realign4_%s.json" % hashlib.sha1(self.rom + self.tgt).hexdigest()[:16])
        memo = json.load(open(cache)) if os.path.exists(cache) else {}
        self.realigned = collections.Counter()
        for pa, ea, pb, eb in gaps:
            if ea - pa == eb - pb or ea - pa > 20000 or eb - pb > 20000:
                continue
            j0 = bisect.bisect_right(keys, pa) - 1
            j1 = bisect.bisect_left(keys, ea)
            if j0 < 0 or j1 <= j0:
                continue
            a0 = keys[j0]
            lines = [i for a, i in starts[j0:j1]]
            a1 = self.order[lines[-1]][0] - BASE + self.size[lines[-1]]
            b0, b1 = pb - (pa - a0), eb + (a1 - ea)
            if b0 < 0 or b1 > len(self.tgt) or b1 <= b0:
                continue
            bodies = [self.parsed[i][1] for i in lines]
            if sum(1 for b in bodies if b and not b.startswith(".")) * 2 < len(bodies):
                self._realign_data(lines, a0, a1, b0, b1)
                continue
            key = "%x-%x-%x-%x" % (a0, a1, b0, b1)
            if key not in memo:
                memo[key] = [decode_region(self.rom[a0:a1]), decode_region(self.tgt[b0:b1])]
            ds, dt = memo[key]
            at = {a0 + o: (l, t) for o, l, t in ds}
            sk_s = []
            for i in lines:
                a, n = self.order[i][0] - BASE, self.size[i]
                parts, x = [], a
                while x < a + n and x in at and at[x][1] is not None:
                    parts.append(skeleton(at[x][1]))
                    x += at[x][0]
                sk_s.append(";".join(parts) if x == a + n else "?%x" % a)
            sk_t = [skeleton(t) if t is not None else "?t%x" % (b0 + o) for o, l, t in dt]
            sm = difflib.SequenceMatcher(None, sk_s, sk_t, autojunk=False)
            pairs = []
            for bi, bj, bn in sm.get_matching_blocks():
                for k in range(bn):
                    i = lines[bi + k]
                    o, l, t = dt[bj + k]
                    if l == self.size[i]:
                        pairs.append((i, b0 + o))
            old = sum(1 for i in lines if self._maps_whole(i))
            if len(pairs) <= old:
                continue
            for i in lines:
                a, n = self.order[i][0] - BASE, self.size[i]
                for x in range(a, a + n):
                    self.dm[x] = None
            for i, t in pairs:
                a, n = self.order[i][0] - BASE, self.size[i]
                for x in range(a, a + n):
                    self.dm[x] = t - a
            self.realigned["gaps"] += 1
            self.realigned["lines matched"] += len(pairs)
        json.dump(memo, open(cache, "w"))

    def _realign_data(self, lines, a0, a1, b0, b1):
        """the data counterpart of the instruction re-alignment: match the two sides'
        bytes with every ROM pointer (a little-endian word at an even address whose value
        is a ROM address) masked, so that records which differ only in where they point
        line up; a line inside one matched run (or in an equal-size stretch between two)
        maps.  Kept when it maps more lines than the byte mapping did."""
        # a `.long` pointer the second alignment pass translated stays as its target value
        # (a table is matched by what it points at); every other pointer is masked, on
        # both sides, unless the target's value is one of those translated pointers
        tr, tp = self.args.trom, self.args.tptr
        keep = {le(tr, o, 4) for o in range(a0, a1 - 3) if o in tp}

        def masked(bs, base, src):
            m = bytearray(bs)
            for o in range(len(bs) - 3):
                if (base + o) % 2 == 0 and BASE <= le(bs, o, 4) < BASE + len(self.rom):
                    if src and base + o in tp:
                        m[o:o + 4] = tr[base + o:base + o + 4]
                    elif src or le(bs, o, 4) not in keep:
                        m[o:o + 4] = b"\xfe\xfe\xfe\xfe"
            return bytes(m)
        ms, mt = masked(self.rom[a0:a1], a0, True), masked(self.tgt[b0:b1], b0, False)
        sm = difflib.SequenceMatcher(None, ms, mt, autojunk=False)
        runs = []
        qi = qj = 0
        for i, j, n in sm.get_matching_blocks():
            if i - qi == j - qj and i > qi:
                runs.append((qi, qj, i - qi))           # equal-size stretch: a substitution
            if n >= 4:
                runs.append((i, j, n))
            if n >= 4 or (i - qi == j - qj):
                qi, qj = i + n, j + n
        pairs = []
        for i in lines:
            a, n = self.order[i][0] - BASE - a0, self.size[i]
            for ri, rj, rn in runs:
                if ri <= a and a + n <= ri + rn:
                    pairs.append((i, b0 + rj + (a - ri)))
                    break
        old = 0
        for i in lines:
            a, n = self.order[i][0] - BASE, self.size[i]
            ds = set(self.dm[a:a + n])
            old += len(ds) == 1 and None not in ds
        if len(pairs) <= old:
            return
        for i in lines:
            a, n = self.order[i][0] - BASE, self.size[i]
            for x in range(a, a + n):
                self.dm[x] = None
        for i, t in pairs:
            a, n = self.order[i][0] - BASE, self.size[i]
            for x in range(a, a + n):
                self.dm[x] = t - a
        self.realigned["data gaps"] += 1
        self.realigned["data lines matched"] += len(pairs)

    def _maps_whole(self, i):
        a, n = self.order[i][0] - BASE, self.size[i]
        ds = set(self.dm[a:a + n])
        if len(ds) != 1 or None in ds:
            return False
        d = ds.pop()
        return self.rom[a:a + n] == self.tgt[a + d:a + d + n]

    def _refcount(self):
        """how many lines name each symbol (C sources and link scripts included)"""
        cnt = collections.Counter()
        for labs, body, com in self.parsed:
            p = body.split(None, 1)
            if len(p) == 2:
                for t in tokens(p[1]):
                    if t[2] == "sym":
                        cnt[t[3]] += 1
        srcdir = os.path.join(ROOT, self.args.src, "maincpu")
        tok = re.compile(r'[A-Za-z_][\w]*')
        for dp, dn, fn in os.walk(srcdir):
            for f in fn:
                if f.endswith((".c", ".h", ".ld")):
                    for t in tok.findall(open(os.path.join(dp, f), encoding="latin-1").read()):
                        cnt[t] += 1
        return cnt

    # ---- skeleton: where every line goes in the target
    def label_votes(self):
        """target offsets every mapped use of a label requires (absolute operands found
        in the bytes, relative branch targets): where the target ROM says the label is;
        plus self.extra_votes (settle_tentative's pointer scan)"""
        if not hasattr(self, "_lvotes_lines"):
            lv = collections.defaultdict(collections.Counter)
            for i, (k, d) in enumerate(self.cls):
                if k not in ("same", "diff") or self.parsed[i][1].startswith((".incbin", ".org")):
                    continue
                t = self.order[i][0] - BASE + d
                mn, ops, reqs = self.line_requirements(i, t)
                for tk, req, v, w in reqs:
                    if tk[2] == "sym" and req is not None and tk[3] in self.labels_src:
                        lv[tk[3]][req - BASE] += 1
            self._lvotes_lines = lv
        self.lvotes = collections.defaultdict(collections.Counter)
        for lab, c in self._lvotes_lines.items():
            self.lvotes[lab].update(c)
        for lab, c in getattr(self, "extra_votes", {}).items():
            self.lvotes[lab].update(c)

    def pointer_votes(self, labs):
        """for each label in labs: the target values of every 32-bit little-endian word at an
        even, mapped source address that holds the label's source address -- its uses as a
        pointer anywhere, the compiled C data included, which line_requirements does not see"""
        want = collections.defaultdict(list)
        for lab in labs:
            v = self.sv.get(lab)
            if v is not None and BASE <= v < BASE + len(self.rom):
                want[v].append(lab)
        out = collections.defaultdict(collections.Counter)
        if not want:
            return out
        rom, tgt, dm = self.rom, self.tgt, self.dm
        keys = set(want)
        for o in range(0, len(rom) - 3, 2):
            if rom[o + 3] != 0 or rom[o + 2] < 0xE0:
                continue
            v = le(rom, o, 4)
            if v not in keys:
                continue
            d = dm[o]
            if d is None or dm[o + 3] != d:
                continue
            tv = le(tgt, o + d, 4)
            if BASE <= tv < BASE + len(tgt):
                for lab in want[v]:
                    out[lab][tv - BASE] += 1
        return out

    def voted(self, labs, lo, hi):
        """the target offset in [lo, hi] that the uses of `labs` agree on, or None"""
        c = collections.Counter()
        for lab in labs:
            c.update(self.lvotes.get(lab, {}))
        if not c:
            return None
        v, n = c.most_common(1)[0]
        if n * 5 >= sum(c.values()) * 3 and lo <= v <= hi:
            return v
        return None

    def skeleton(self):
        order, size, cls = self.order, self.size, self.cls
        ev = []
        self.place = {}                 # label -> target offset
        self.moved = {}                 # line index -> labels emitted apart from the line
        self.guessed = set()
        self.tentative = set()          # labels placed by no evidence (gap)
        self.names_dropped = set()      # labels of source bytes the target dropped
        self.label_votes()
        tc = 0
        pend = []
        for i, e in enumerate(order):
            n = size[i]
            if n == 0:
                pend.append(i)
                continue
            body = self.parsed[i][1]
            if body.startswith(".org"):
                end = e[0] - BASE + n
                self.gap(ev, pend, tc, self._content_end(tc, end))
                ev.append(("org", i, tc))
                tc = end
                pend = []
                continue
            k, d = cls[i]
            if k in ("same", "diff") and e[0] - BASE + d >= tc:
                t = e[0] - BASE + d
                labs = self.parsed[i][0]
                if labs and tc < t:
                    # target bytes were inserted just before this line: its labels go
                    # where their uses say, which may be the start of the insertion
                    v = self.voted(labs, tc, t - 1)
                    if v is not None:
                        self.moved[i] = list(labs)
                        pend.append(("L", i))
                self.gap(ev, pend, tc, t)
                ev.append(("line", i, t))
                for lab in labs:
                    if i not in self.moved:
                        self.place[lab] = t
                tc = t + n
                pend = []
            else:
                pend.append(i)
        self.gap(ev, pend, tc, len(self.tgt))
        self.events = ev
        # a label of source bytes the target dropped that lands where a label of something
        # the target kept also stands names nothing of its own there (a branch that went to
        # it now goes to that next thing): it is kept only where the tree needs it
        at = collections.defaultdict(list)
        for lab, p in self.place.items():
            at[p].append(lab)
        for p, labs in at.items():
            if len(labs) < 2:
                continue
            if any(lab not in self.names_dropped for lab in labs):
                self.tentative.update(lab for lab in labs if lab in self.names_dropped)
                continue
            # all of them name dropped bytes: the ones whose own bytes stand here keep it
            own = [lab for lab in labs if self.bytes_at(lab, p)]
            if own:
                self.tentative.update(lab for lab in labs if lab not in own)

    def settle_tentative(self):
        """Labels gap() placed by no evidence name source bytes the target dropped or
        changed.  One that nothing in the target tree needs is DROPPED: it is not emitted (a
        comment says where it was) and is listed in the tree's port_dropped_labels.txt.  A
        label is needed when the target tree's assembly will still spell it: a mapped line
        whose bytes do not hold its value (an expression such as `.short Case - Base`), a
        `.set` / `.equ` line, or a macro body.  A needed label keeps its placement
        and is listed in self.needed_tentative.

        First the tentative labels' uses as pointers anywhere in the image (pointer_votes)
        are added to the votes and the skeleton is laid out again, so a label the compiled
        C data points at is placed where the target's C data points."""
        self.extra_votes = self.pointer_votes(self.tentative)
        self.cvote = {}
        if self.extra_votes:
            self.skeleton()
        for lab, c in self.extra_votes.items():
            v, n = c.most_common(1)[0]
            if n * 5 >= sum(c.values()) * 3:
                self.cvote[lab] = v
        need = collections.Counter()
        for kind, i, t in self.events:
            if kind == "line" and not self.parsed[i][1].startswith((".incbin", ".org")):
                mn, ops, reqs = self.line_requirements(i, t)
                for tk, req, v, w in reqs:
                    if tk[2] == "sym" and req is None:
                        need[tk[3]] += 1
            elif kind == "zero":
                p = self.parsed[i][1].split(None, 1)
                if len(p) == 2:
                    for tk in tokens(p[1]):
                        if tk[2] == "sym":
                            need[tk[3]] += 1
        for m in IDENT.finditer(macro_prelude(self.args.src)):
            need[m.group(1)] += 1
        # the C sources do not need the assembly label: they are compiled against their own
        # link scripts, whose addresses emit() writes (self.cvote where the label is dropped)
        self.dropped = {lab for lab in self.tentative if not need.get(lab)}
        self.needed_tentative = sorted(self.tentative - self.dropped)
        for lab in self.dropped:
            self.place.pop(lab, None)
        for cached in ("_byaddr", "_exprat"):
            if hasattr(self, cached):
                delattr(self, cached)

    def bytes_at(self, lab, p):
        """does the target hold, at offset p, the source bytes at the label (at least 4)?"""
        v = self.sv.get(lab)
        if v is None or not (BASE <= v < BASE + len(self.rom)):
            return False
        n = self.record_len(v)
        return n >= 4 and self.rom[v - BASE:v - BASE + n] == self.tgt[p:p + n]

    def _content_end(self, tc, end):
        """target offset where the code before a `.org` stops: the start of the 0xff
        run that reaches `end`"""
        x = end
        while x > tc and self.tgt[x - 1] == 0xFF:
            x -= 1
        return x

    def gap(self, ev, pend, t0, t1):
        """events for the pending lines and the target bytes [t0, t1)"""
        order, size = self.order, self.size
        U = [i for i in pend if not isinstance(i, tuple) and size[i] > 0]
        if not U and t0 >= t1:
            for i in pend:
                if isinstance(i, tuple):
                    for lab in self.moved[i[1]]:
                        self.place[lab] = t0
                    ev.append(("label", i[1], t0))
                    continue
                for lab in self.parsed[i][0]:
                    self.place[lab] = t0
                ev.append(("zero", i, t0))
            return
        u0 = order[U[0]][0] - BASE if U else None
        u1 = (order[U[-1]][0] - BASE + size[U[-1]]) if U else None
        last = t0
        rows = []
        for i in pend:
            if isinstance(i, tuple):
                labs = self.moved[i[1]]
                a = order[i[1]][0] - BASE
            else:
                labs = self.parsed[i][0]
                a = order[i][0] - BASE
            if labs:
                p = self.voted(labs, last, t1)
                if p is None:
                    p = self._fingerprint(a, t0, t1)
                if p is None or p < last:
                    if U and a <= u0:
                        p = t0
                    elif U and a >= u1:
                        p = t1
                    elif not U:
                        p = t1
                    else:
                        p = max(last, min(t1, t0 + (a - u0)))
                    if U and a < u1 and not (p == t0 < t1 and self.rom[a:a + 4] == self.tgt[t0:t0 + 4]):
                        # the label names source bytes the target dropped or changed, and
                        # nothing places it: neither a use, nor its bytes, nor (at the start
                        # of the gap) the target's first bytes.  It is kept only where the
                        # target tree still needs the name (see settle_tentative)
                        if not isinstance(i, tuple):
                            self.tentative.update(labs)
                    if any(self.refcount.get(lb) for lb in labs):
                        self.guessed.update(labs)
                p = max(p, last)
                if U and a < u1 and not isinstance(i, tuple):
                    self.names_dropped.update(labs)     # see the end of skeleton()
                for lab in labs:
                    self.place[lab] = p
            else:
                p = last
            last = p
            rows.append((i, p))
        cur = t0
        for i, p in rows:
            if p > cur:
                ev.append(("raw", cur, p))
                cur = p
            if isinstance(i, tuple):
                ev.append(("label", i[1], p))
            else:
                ev.append(("drop" if size[i] > 0 else "zero", i, p))
        if t1 > cur:
            ev.append(("raw", cur, t1))

    def _fingerprint(self, a, t0, t1):
        """target offset in [t0, t1] where the source bytes at `a` occur once"""
        lo, hi = t0, min(len(self.tgt), t1 + 32)
        for L in (16, 12, 8, 6):
            fp = self.rom[a:a + L]
            if len(fp) < L or len(set(fp)) <= 1:
                continue
            hits = []
            x = self.tgt.find(fp, lo, hi)
            while x != -1 and len(hits) < 2:
                hits.append(x)
                x = self.tgt.find(fp, x + 1, hi)
            if len(hits) == 1 and t0 <= hits[0] <= t1:
                return hits[0]
        return None

    # ---- target value of a symbol
    def tval(self, sym):
        if sym in self.place:
            return BASE + self.place[sym]
        if sym in self.newequ:
            return self.newequ[sym]
        if sym in self.newexpr:
            return self.newexpr[sym]
        if sym in self.labels_src:
            return None                 # a label that did not survive the port
        if sym in self.equ_expr:
            i, base, sign, k = self.equ_expr[sym]
            b = self.tval(base) if base != sym else None
            if b is None:
                return None
            return b + int(k, 0) if sign == "+" else b - int(k, 0)
        v = self.sv.get(sym)
        if v is None:
            return None
        if BASE <= v < BASE + len(self.rom) and sym not in self.equ_lines:
            d = self.dm[v - BASE]
            return None if d is None else v + d
        return v

    # ---- per-line operand analysis
    def line_requirements(self, i, t):
        """-> (mnemonic, operands, [(token, required target value, source value, width)])
        for mapped line i at target offset t; required is None when the token's value
        was not found in the bytes; width 'rel' marks a relative branch target"""
        labs, body, com = self.parsed[i]
        n = self.size[i]
        a = self.order[i][0] - BASE
        bs, bt = self.rom[a:a + n], self.tgt[t:t + n]
        p = body.split(None, 1)
        mn, ops = p[0].lower(), (p[1] if len(p) > 1 else "")
        out = []
        if mn in DATA_W:
            w = DATA_W[mn]
            pos = 0
            for k, el in enumerate(split_commas(ops)):
                tk = tokens(el)
                if len(tk) == 1 and el.strip() == tk[0][3]:
                    s0, s1, kind, txt = tk[0]
                    out.append(((pos + s0, pos + s1, kind, txt), le(bt, k * w, w), le(bs, k * w, w), w))
                else:
                    # an expression (`Case - Base`): its symbols take their target values
                    for s0, s1, kind, txt in tk:
                        out.append(((pos + s0, pos + s1, kind, txt), None, None, 0))
                pos += len(el) + 1
            return mn, ops, out
        toks = tokens(ops)
        vals = []
        for k, (s0, s1, kind, txt) in enumerate(toks):
            v = int(txt, 0) if kind == "num" else self.sv.get(txt)
            vals.append(v if v is not None and v >= 0 else None)
        # locate the biggest values first, each in bytes no other token has claimed
        # (`ld (0x3910:16), 16`: the 0x10 of the address is not the immediate 16)
        claimed = set()
        found = {}
        for k in sorted(range(len(toks)), key=lambda k: -(vals[k] if vals[k] is not None else -1)):
            v = vals[k]
            if v is None or (mn in REL and k == len(toks) - 1):
                continue
            for w in (4, 3, 2, 1):
                if v >= 1 << (8 * w):
                    continue
                offs = [o for o in range(n - w + 1) if le(bs, o, w) == v
                        and not claimed.intersection(range(o, o + w))]
                dif = [o for o in offs if bs[o:o + w] != bt[o:o + w]]
                hit = dif[0] if len(dif) == 1 else (offs[0] if offs and not dif else None)
                if hit is not None:
                    found[k] = (hit, w)
                    claimed.update(range(hit, hit + w))
                    break
        for k, tk in enumerate(toks):
            if mn in REL and k == len(toks) - 1:
                w = REL_W.get(mn, 1)
                disp = sval(le(bt, n - w, w), w)
                out.append((tk, BASE + t + n + disp, None, "rel"))
            elif k in found:
                o, w = found[k]
                out.append((tk, le(bt, o, w), vals[k], w))
            else:
                out.append((tk, None, vals[k], 0))
        return mn, ops, out

    def votes(self):
        """required target values of every numeric .equ symbol, from every mapped use"""
        self.newequ = {}
        vt = collections.defaultdict(collections.Counter)
        for kind, i, t in self.events:
            if kind != "line" or self.parsed[i][1].startswith(".incbin"):
                continue
            mn, ops, reqs = self.line_requirements(i, t)
            for tk, req, v, w in reqs:
                if tk[2] != "sym" or req is None:
                    continue
                if tk[3] in self.equ_lines and w != "rel":
                    vt[tk[3]][req] += 1
                elif tk[3] in self.equ_expr:
                    vt[tk[3]][req] += 1
        self.equ_votes = vt
        self.newexpr = {}
        self.kept_on_record = []
        for sym, c in vt.items():
            best, nb = c.most_common(1)[0]
            if sym in self.equ_lines:
                if best != self.sv.get(sym):
                    self.newequ[sym] = best
            elif best != self.tval(sym):
                if self.unchanged_record(sym) or self.label_at(best):
                    # the record the name stood on is in the target unchanged, or its uses
                    # now point where another label stands: the name stays, and a use that
                    # points elsewhere is written with the name of what it points to
                    # (subst: expr_at, label_at)
                    self.kept_on_record.append(sym)
                    continue
                self.newexpr[sym] = best
        # a constant whose uses now hold the value another constant of its family keeps
        # (NAKA_VIEW_MPVersion's uses hold 0xef0004 = NAKA_VIEW_AllInitial in v6, which has no
        # MPVersion view) is not re-valued: its uses are written with that constant (subst)
        self.equ_redirect = {}
        for sym in list(self.newequ):
            o = self.const_at(self.newequ[sym], sym)
            if o:
                self.equ_redirect[sym] = o
                del self.newequ[sym]
        # re-valued constants whose new value another constant of the family still has
        fam = collections.defaultdict(list)
        for sym in self.equ_lines:
            if sym not in self.newequ:
                fam[(sym.split("_")[0], self.sv.get(sym))].append(sym)
        self.collisions = {}
        for sym, v in self.newequ.items():
            o = [x for x in fam.get((sym.split("_")[0], v), []) if x != sym]
            if o:
                self.collisions[sym] = sorted(o, key=lambda x: self.equ_lines[x])[0]
        for cached in ("_byaddr", "_exprat"):
            if hasattr(self, cached):
                delattr(self, cached)

    def const_at(self, value, like):
        """a numeric constant of `like`'s family (the same first name component) that has
        `value` and keeps it -- its own mapped uses in the target say so -- or None.  Without
        that confirmation a shared value proves nothing: an older firmware without an entry
        numbers the entries after it one lower (v5 has no MT_TrackMidiCall, so its
        EVT_GET_CUR_SONG_NAME takes v6's EVT_TRACK_MIDI_CALL value), or the use now names
        the other entry (v6 has no MPVersion view; its use holds NAKA_VIEW_AllInitial's
        value).  Those are re-valued and their comment says the value is shared
        (collisions)."""
        if not hasattr(self, "_constidx"):
            self._constidx = collections.defaultdict(list)
            for sym in sorted(self.equ_lines, key=lambda x: self.equ_lines[x]):
                self._constidx[self.sv.get(sym)].append(sym)
        fam = like.split("_")[0]
        for sym in self._constidx.get(value, ()):
            c = self.equ_votes.get(sym)
            if sym != like and sym not in self.newequ and sym.split("_")[0] == fam \
                    and c and c.most_common(1)[0][0] == value:
                return sym
        return None

    def record_len(self, v):
        """bytes from source address v to the next source symbol (labels and `.set` names),
        at most 16"""
        if not hasattr(self, "_symaddrs"):
            self._symaddrs = sorted({x for x in self.sv.values()
                                     if x is not None and BASE <= x < BASE + len(self.rom)})
        k = bisect.bisect_right(self._symaddrs, v)
        nxt = self._symaddrs[k] if k < len(self._symaddrs) else BASE + len(self.rom)
        return min(16, nxt - v)

    def unchanged_record(self, sym):
        """does the target hold, where the name now resolves, the bytes the source holds at
        the name (at least 4 of them)?"""
        v, t = self.sv.get(sym), self.tval(sym)
        if v is None or t is None or not (BASE <= v < BASE + len(self.rom)):
            return False
        n = self.record_len(v)
        if n < 4:
            return False
        return self.rom[v - BASE:v - BASE + n] == self.tgt[t - BASE:t - BASE + n]

    def new_labels(self):
        """labels for target addresses that mapped lines reach but no ported label names:
        a branch into code v6 has and v7 does not, a second entry point.  Only at the
        start of an emitted line or raw run (an instruction start); named after the
        label before them -- `_Skip`/`_Loop` for a branch target ahead of / behind every
        branch that reaches it, `_Body` where a source label whose uses moved it away
        stood, `_Entry` for a call or jump target, `_Data` otherwise.  A raw run may be
        labelled inside (emit() splits it there).

        First, a label settle_tentative dropped whose target uses agree on one address
        (three fifths of the votes) that no label holds and that starts a line or lies in a
        raw run is placed there under its own name: the thing it named moved out of its
        gap, and its uses say where (self.relocated)."""
        starts = {}
        raws = []
        for ev in self.events:
            if ev[0] == "line":
                starts.setdefault(ev[2], ev)
            elif ev[0] == "raw":
                starts.setdefault(ev[1], ev)
                raws.append((ev[1], ev[2]))
        raws.sort()
        rkeys = [a for a, b in raws]

        def labellable(off):
            if off in starts:
                return True
            j = bisect.bisect_right(rkeys, off) - 1
            return j >= 0 and raws[j][0] < off < raws[j][1]
        held = {p for p in self.place.values()}
        self.newlab = {}
        self.relocated = []
        for lab in sorted(self.dropped):
            c = self.lvotes.get(lab)
            if not c:
                continue
            v, n = c.most_common(1)[0]
            if n * 5 >= sum(c.values()) * 3 and v not in held and v not in self.newlab and labellable(v):
                self.newlab[v] = lab
                self.place[lab] = v
                held.add(v)
                self.relocated.append(lab)
        self.dropped -= set(self.relocated)
        want = collections.defaultdict(list)       # offset -> [(kind, site offset)]
        for kind, i, t in self.events:
            if kind != "line" or self.parsed[i][1].startswith((".incbin", ".org")):
                continue
            mn, ops, reqs = self.line_requirements(i, t)
            for tk, req, v, w in reqs:
                if req is None or not (BASE <= req < BASE + len(self.tgt)):
                    continue
                if w == "rel":
                    if tk[2] == "sym" and self.tval(tk[3]) == req:
                        continue
                    want[req - BASE].append(("rel", t))
                elif tk[2] == "sym" and (tk[3] in self.labels_src or tk[3] in self.equ_expr) \
                        and self.tval(tk[3]) != req:
                    want[req - BASE].append(("call" if mn in ("call", "jp") else "data", t))
        body_of = {}
        for i, labs in self.moved.items():
            ev_t = self.order[i][0] - BASE + self.cls[i][1]
            body_of[ev_t] = labs[0]
        placed = sorted((p, lab) for lab, p in self.place.items())
        keys = [p for p, lab in placed]
        used = set(self.sv) | set(self.place)
        for off in sorted(want):
            if off in held or not labellable(off):
                continue
            kinds = {k for k, t in want[off]}
            if off in body_of:
                base, suf = body_of[off], "_Body"
            else:
                j = bisect.bisect_right(keys, off) - 1
                base = label_stem(placed[j][1]) if j >= 0 else "Rom"
                if kinds == {"rel"}:
                    suf = "_Loop" if all(t > off for k, t in want[off]) else "_Skip"
                elif "call" in kinds:
                    suf = "_Entry"
                else:
                    suf = "_Data"
            name, n = base + suf, 2
            while name in used:
                name, n = "%s%s%d" % (base, suf, n), n + 1
            used.add(name)
            self.newlab[off] = name
            self.place[name] = off
        for cached in ("_byaddr", "_exprat"):
            if hasattr(self, cached):
                delattr(self, cached)

    def resolve(self):
        """final text of every mapped line; a line that cannot be shown to reproduce the
        target bytes gets None (raw rows)"""
        cands = []
        self.failed = []                 # lines that became raw rows, for --dump-failed
        self.text = {}
        self.cpatch = {}                 # generated bin -> {offset: target byte}
        st = collections.Counter()
        for kind, i, t in self.events:
            if kind != "line":
                continue
            labs, body, com = self.parsed[i]
            n = self.size[i]
            a = self.order[i][0] - BASE
            if body.startswith(".incbin"):
                m = re.match(r'^\.incbin\s+"([^"]+)"\s*(?:,\s*([^,]+?)\s*(?:,\s*(.+?)\s*)?)?$', body)
                if m and "generated/" in m.group(1):
                    off = int(m.group(2), 0) if m.group(2) else 0
                    d = self.cpatch.setdefault(os.path.basename(m.group(1)), {})
                    for k in range(n):
                        d[off + k] = self.tgt[t + k]
                    self.text[i] = body
                    st["incbin-generated"] += 1
                    continue
                if self.rom[a:a + n] == self.tgt[t:t + n]:
                    self.text[i] = body
                    st["incbin-same"] += 1
                    continue
                self.text[i] = None
                st["incbin-raw"] += 1
                continue
            mn, ops, reqs = self.line_requirements(i, t)
            if mn in self.macros_lc and self.rom[a:a + n] == self.tgt[t:t + n]:
                # a macro whose body branches relatively cannot be assembled on its own (its
                # target is a label in another place); equal bytes are kept and the full
                # build checks them like every other line
                self.text[i] = body
                st["kept-macro"] += 1
                continue
            test = self.subst(body, ops, reqs, t, n, rewrite=False)
            new = self.subst(body, ops, reqs, t, n, rewrite=True)
            cands.append((i, t, n, body, test, new))
        flat = []
        for i, t, n, body, test, new in cands:
            flat.append(test[0] if test else "nop")
            flat.append(new[0] if new else "nop")
        print("  isolated assembly of %d texts ..." % len(flat))
        enc = assemble_batch(flat, self.args.src, self.prelude())
        for k, (i, t, n, body, test, new) in enumerate(cands):
            want = self.tgt[t:t + n]
            if test and enc[2 * k] == want:
                self.text[i] = body
                st["kept"] += 1
            elif new and new[1] != body and enc[2 * k + 1] == want:
                self.text[i] = new[1]
                st["rewritten"] += 1
            elif body.split(None, 1)[0].lower() in (".ascii", ".asciz") and n:
                self.text[i] = ".ascii\t" + ascii_text(want)
                st["string"] += 1
            else:
                self.text[i] = None
                st["raw"] += 1
                self.failed.append((i, t, n, body, test, new, enc[2 * k], enc[2 * k + 1]))
        self.stats = st

    def subst(self, body, ops, reqs, t, n, rewrite):
        """-> (test text, final text) or None.  The final text is the body (rewrite=False)
        or the body with every operand taken from the target bytes; the test text is
        `.set` lines giving each symbol of the final text its target value, then the final
        text with a relative-branch target written as its displacement."""
        if not rewrite or not reqs:
            final = body
        else:
            out, pos = [], 0
            here = BASE + t + n
            for tk, req, v, w in reqs:
                s0, s1, kind, txt = tk
                out.append(ops[pos:s0])
                pos = s1
                if req is None:
                    out.append(txt)
                    continue
                if w == "rel":
                    if kind == "sym" and self.tval(txt) == req:
                        out.append(txt)
                    else:
                        nm = self.label_at(req)
                        out.append(nm if nm else str(req - here))
                    continue
                if kind == "num":
                    out.append(fmt_like(txt, req) if req != int(txt, 0) else txt)
                    continue
                if self.tval(txt) == req:
                    out.append(txt)
                elif txt in self.equ_expr and self.expr_at(req):
                    out.append(self.expr_at(req))     # a record pointer: the record's own name
                elif txt in self.equ_lines and self.const_at(req, txt):
                    out.append(self.const_at(req, txt))
                elif txt not in self.equ_lines and self.label_at(req):
                    out.append(self.label_at(req))
                else:
                    out.append(hex(req))
            out.append(ops[pos:])
            final = body.split(None, 1)[0] + "\t" + "".join(out).strip()
        test = self.test_text(final, t, n)
        return (test, final) if test is not None else None

    def test_text(self, final, t, n):
        p = final.split(None, 1)
        mn, ops = p[0], (p[1] if len(p) > 1 else "")
        toks = tokens(ops)
        defs, out, pos = [], [], 0
        here = BASE + t + n
        for k, (s0, s1, kind, txt) in enumerate(toks):
            if kind != "sym":
                continue
            if txt not in self.sv and txt not in self.labels_src and txt not in self.equ_expr \
                    and txt not in self.place:
                continue                     # not a symbol of the tree: a bank register (xbc3) or keyword
            v = self.tval(txt)
            if v is None:
                return None
            if mn.lower() in REL and k == len(toks) - 1:
                out.append(ops[pos:s0] + str(v - here))
                pos = s1
                continue
            defs.append(".set %s, %d" % (txt, v))
        out.append(ops[pos:])
        return "\n".join(defs + [mn + " " + "".join(out)])

    # ---- writing the target tree
    TODO = "; TODO(port): %s bytes with no %s line -- disassemble"

    def emit(self):
        src, dst = self.args.src, self.args.dst
        sdir = os.path.join(ROOT, src, "maincpu")
        ddir = os.path.join(ROOT, dst, "maincpu")
        root_s = "kn5000_%s_program.s" % src
        files = collections.OrderedDict()
        rawbuf = []                      # pending target byte ranges
        self.relinked = 0
        self.relink_unplaced = 0
        self.rawbytes = 0
        dropped_rows = []
        relocated = set(self.relocated)          # emitted where their uses point (newlab)
        # a `.set NAME, Label +/- K` alias that no line of the target uses, whose source bytes
        # are not where it resolves, and which resolves onto another label names nothing of
        # its own in the target: dropped like a label
        used = collections.Counter()
        for i, t in self.text.items():
            if t:
                p = t.split(None, 1)
                for tk in tokens(p[1]) if len(p) == 2 else ():
                    if tk[2] == "sym":
                        used[tk[3]] += 1
        for kind, i, t in self.events:
            if kind == "zero":
                b = self.parsed[i][1]
                p = b.split(None, 1)
                for tk in tokens(p[1]) if len(p) == 2 else ():
                    if tk[2] == "sym":
                        used[tk[3]] += 1
        for mm in IDENT.finditer(macro_prelude(self.args.src)):
            used[mm.group(1)] += 1
        stale_alias = set()
        for sym, (i, base, sign, k) in self.equ_expr.items():
            # its own `.set` line names it once
            v = self.tval(sym)
            if used[sym] <= 1 and v is not None and BASE <= self.sv.get(sym, 0) < BASE + len(self.rom) \
                    and not self.unchanged_record(sym) and self.label_at(v) not in (None, base):
                stale_alias.add(sym)
        self.stale_alias = stale_alias

        def out(rel, line):
            files.setdefault(rel, []).append(line)

        def flush(rel):
            if not rawbuf:
                return
            bs = b"".join(self.tgt[a:b] for a, b in rawbuf)
            self.rawbytes += len(bs)
            out(rel, self.TODO % (dst, src))
            for k in range(0, len(bs), 8):
                out(rel, "\t.byte\t" + ", ".join("0x%02x" % x for x in bs[k:k + 8]))
            rawbuf.clear()

        # a raw run with a label inside is split there
        cuts = sorted(self.newlab)
        events = []
        for ev in self.events:
            if ev[0] == "raw":
                a, b = ev[1], ev[2]
                for c in cuts[bisect.bisect_right(cuts, a):bisect.bisect_left(cuts, b)]:
                    events.append(("raw", a, c))
                    a = c
                events.append(("raw", a, b))
            else:
                events.append(ev)
        self.events = events
        nxtfile = [None] * len(self.events)          # file of the next event that is not raw
        f = self.order[-1][1]
        for k in range(len(self.events) - 1, -1, -1):
            if self.events[k][0] != "raw":
                f = self.order[self.events[k][1]][1]
            nxtfile[k] = f
        for k, (kind, *rest) in enumerate(self.events):
            if kind in ("raw", "line") and rest[0 if kind == "raw" else 1] in self.newlab:
                rel = nxtfile[k] if kind == "raw" else self.order[rest[0]][1]
                flush(rel)
                out(rel, self.newlab[rest[0 if kind == "raw" else 1]] + ":")
            if kind == "raw":
                rawbuf.append((rest[0], rest[1]))
                continue
            i, t = rest
            rel = self.order[i][1]
            text = self.order[i][3]
            labs, body, com = self.parsed[i]
            gone = [lab for lab in labs if lab in self.dropped] if kind in ("zero", "drop") else []
            away = [lab for lab in labs if lab in relocated] if kind in ("zero", "drop") else []
            if gone or away:
                flush(rel)
                for lab in gone:
                    out(rel, "; port: %s's label %s is not in %s -- no %s bytes correspond to what it named"
                        % (src, lab, dst, dst))
                    dropped_rows.append("%s\t0x%06x\t%s" % (lab, self.order[i][0], rel))
                labs = [lab for lab in labs if lab not in self.dropped and lab not in relocated]
                if kind == "zero":
                    if not body and not com:
                        continue
                    text = "".join(lab + ":" for lab in labs) + ("\t" + body if body else "") + \
                        ("\t" + com if com else "")
            if kind == "zero":
                m = re.match(r'^\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*$', body)
                if m and m.group(1) in self.newequ:
                    old = m.group(2)
                    nb = body[:m.start(2)] + fmt_like(old, self.newequ[m.group(1)]) + body[m.end(2):]
                    text = text.replace(body, nb, 1)
                    # the comment was written for the source tree's value: say whose value
                    # this is now and keep the old one
                    text = text.rstrip()
                    if com and text.endswith(com):
                        text = text[:len(text) - len(com)] + re.sub(
                            r"%s address(, (?:derived from|from the \w+ code's uses)[^;]*)?" % src,
                            "%s address, from the %s code's uses (port_maincpu_version.py)" % (dst, dst), com)
                    text += "\t; %s: %s" % (src, old)
                    if m.group(1) in self.collisions:
                        text += ("; %s's uses hold the value %s has here: an entry before it may be "
                                 "missing in %s, or the use names that entry -- unchecked"
                                 % (dst, self.collisions[m.group(1)], dst))
                m = EQU_EXPR.match(body)
                if m and m.group(1) in stale_alias:
                    out(rel, "; port: %s's alias %s (%s) is not in %s -- %s's bytes there are not "
                        "what it named, and no %s line uses it" % (src, m.group(1), body.split(",", 1)[1].strip(),
                                                                   dst, dst, dst))
                    dropped_rows.append("%s\t0x%06x\t%s" % (m.group(1), self.sv.get(m.group(1), 0), rel))
                    continue
                base = self.tval(m.group(2)) if m and m.group(1) in self.newexpr else None
                if m and m.group(1) in self.newexpr and base is None:
                    print("  cannot re-aim %s: %s has no target address" % (m.group(1), m.group(2)))
                elif m and m.group(1) in self.newexpr:
                    k = self.newexpr[m.group(1)] - base
                    sign, k = ("+", k) if k >= 0 else ("-", -k)
                    nb = body[:m.start(3)] + sign + " " + fmt_like(m.group(4), k)
                    text = text.replace(body, nb, 1)
                flush(rel) if (labs and rawbuf) else None
                out(rel, text)
                continue
            if kind == "drop":
                if labs:
                    flush(rel)
                    for lab in labs:
                        out(rel, lab + ":")
                continue
            if kind == "label":
                flush(rel)
                for lab in self.moved[i]:
                    out(rel, lab + ":")
                continue
            if i in self.moved:
                labs = [x for x in labs if x not in self.moved[i]]
                text = "".join(x + ":" for x in labs) + "\t" + body + ("\t" + com if com else "")
            if kind == "org":
                flush(rel)
                out(rel, text)
                continue
            new = self.text.get(i)
            n = self.size[i]
            if new is None:
                if labs:
                    flush(rel)
                    for lab in labs:
                        out(rel, lab + ":")
                rawbuf.append((t, t + n))
                continue
            flush(rel)
            out(rel, text if new == body else text.replace(body, new, 1) if body in text else "\t" + new)
            if new != body and labs and body not in text:
                files[rel][-1] = "".join(lab + ":" for lab in labs) + "\t" + new + ("\t" + com if com else "")
        flush(self.order[-1][1])
        # the tree: every file of the source tree, the root renamed
        used = set()                     # committed binaries the ported source still includes
        for rel, lines in files.items():
            for ln in lines:
                m = re.search(r'\.incbin\s+"([^"]+)"', code_part(ln))
                if m:
                    used.add(os.path.normpath(m.group(1)))
        readme = os.path.join(ddir, "README.md")
        keep = open(readme, encoding="utf-8").read() if os.path.exists(readme) else None
        if os.path.exists(ddir):
            # the tree is regenerated whole; refuse anything but ROOT/v<N>/maincpu
            real, root = os.path.realpath(ddir), os.path.realpath(ROOT)
            assert re.fullmatch(r'v\d+', dst), dst
            assert real == os.path.join(root, dst, "maincpu") and real.startswith(root + os.sep), real
            shutil.rmtree(real)
        for dp, dn, fn in os.walk(sdir):
            rel = os.path.relpath(dp, sdir)
            os.makedirs(os.path.join(ddir, rel), exist_ok=True)
            for f in fn:
                r = os.path.normpath(os.path.join(rel, f))
                if r.startswith("includes/generated/") or r.startswith("includes/%s_" % src):
                    continue
                if r.endswith(".s"):
                    continue                 # written below if the build includes it
                if r.endswith(".bin") and r not in used:
                    continue
                if r in ("transplant_manifest.txt", "README.md", "port_dropped_labels.txt"):
                    continue                 # describes the source tree's own history
                dr = r.replace(root_s, "kn5000_%s_program.s" % dst)
                if r.endswith("_link.ld"):
                    # the C data's link scripts give ROM labels absolute addresses: the
                    # target tree's, where the label has one, so the C compiles to the
                    # target's pointers and the divergence json does not have to move them
                    def relink(m):
                        v = self.tval(m.group(1))
                        old = int(m.group(2), 16)
                        if not (BASE <= old < BASE + len(self.rom)):
                            return m.group(0)
                        if v is None and m.group(1) in self.cvote:
                            v = BASE + self.cvote[m.group(1)]   # dropped: where the C data points
                        if v is None:
                            self.relink_unplaced += 1
                            return m.group(0) + " /* %s's address: nothing in %s places it */" % (src, dst)
                        self.relinked += v != old
                        return "%s = 0x%08X;" % (m.group(1), v)
                    txt = open(os.path.join(sdir, r), encoding="latin-1").read()
                    txt = re.sub(r'^([A-Za-z_][\w]*) = 0x([0-9A-Fa-f]+);', relink, txt, flags=re.M)
                    open(os.path.join(ddir, dr), "w", encoding="latin-1").write(txt)
                    continue
                shutil.copy2(os.path.join(sdir, r), os.path.join(ddir, dr))
        for rel, lines in files.items():
            dr = rel.replace(root_s, "kn5000_%s_program.s" % dst)
            with open(os.path.join(ddir, dr), "w", encoding="latin-1", newline="\n") as fh:
                fh.write("\n".join(lines))
        if keep is not None:
            open(readme, "w", encoding="utf-8").write(keep)
        with open(os.path.join(ddir, "port_dropped_labels.txt"), "w") as fh:
            fh.write("# %s labels that %s/maincpu does not define: the bytes they named have no\n"
                     "# counterpart in the %s ROM and no line of the %s tree needs the name\n"
                     "# (scripts/converters/port_maincpu_version.py, Port.settle_tentative).\n"
                     "# label\t%s address\t%s file\n" % (src, dst, dst, dst, src, src))
            fh.write("".join(r + "\n" for r in dropped_rows))
        self.dropped_rows = dropped_rows
        json.dump({k: {str(o): b for o, b in sorted(v.items())} for k, v in self.cpatch.items()},
                  open(os.path.join(self.cache, "c_target_%s.json" % dst), "w"))

    def prelude(self):
        """the macro definitions, and target values for the symbols their bodies name
        (`call RegisterTitle` inside RegTitle)"""
        text = macro_prelude(self.args.src)
        names = set()
        for ln in text.split("\n")[1:]:
            p = code_part(ln).split(None, 1)
            if len(p) == 2 and p[0].lower() in REL:
                self.macro_rel.update(m.group(1) for m in IDENT.finditer(p[1]))
            for m in IDENT.finditer(code_part(ln)):
                if m.group(1) in self.sv and m.group(1).lower() not in RESERVED:
                    names.add(m.group(1))
        defs = []
        for nm in sorted(names - self.macro_rel):
            v = self.tval(nm)
            if v is not None and not nm.startswith("."):
                defs.append(".set %s, %d" % (nm, v))
        return text + "\n" + "\n".join(defs)

    def expr_at(self, addr):
        """the `.set NAME, Label +/- K` name (first in source order) that resolves to addr"""
        if not hasattr(self, "_exprat"):
            self._exprat = {}
            for sym, (i, base, sign, k) in sorted(self.equ_expr.items(), key=lambda x: x[1][0]):
                v = self.tval(sym)
                if v is not None:
                    self._exprat.setdefault(v, sym)
        return self._exprat.get(addr)

    def label_at(self, addr):
        if not hasattr(self, "_byaddr"):
            self._byaddr = {}
            for lab, p in sorted(self.place.items()):
                self._byaddr.setdefault(BASE + p, lab)
        return self._byaddr.get(addr)


def c_divergence(args):
    """write DST/maincpu/includes/DST_c_divergence.json: where the bytes the ported source
    places at each `.incbin "includes/generated/..."` slice differ from the freshly
    compiled (unpatched) bins.  Run after `make DST-c-bins-raw` on an empty generated/."""
    cache = args.cache or os.path.join(tempfile.gettempdir(), "port-%s-%s" % (args.src, args.dst))
    want = json.load(open(os.path.join(cache, "c_target_%s.json" % args.dst)))
    gen = os.path.join(ROOT, args.dst, "maincpu", "includes", "generated")
    out = {}
    nrel = nraw = 0
    for name, d in sorted(want.items()):
        p = os.path.join(gen, name)
        if os.path.exists(p + ".patched"):
            sys.exit("%s is already patched: delete %s and run make %s-c-bins-raw" % (name, gen, args.dst))
        raw = open(p, "rb").read()
        need = bytearray(raw)
        top = max(int(o) for o in d) + 1
        if top > len(need):
            need.extend(b"\x00" * (top - len(need)))
        for o, b in d.items():
            need[int(o)] = b
        size = top                      # a whole-file .incbin uses exactly what the source placed
        src = bytearray(raw) + b"\x00" * (size - len(raw))
        reloc, rawd = [], {}
        o = 0
        while o < size:
            if src[o] == need[o]:
                o += 1
                continue
            # a moved pointer: a 4-byte aligned little-endian ROM address on both sides
            a4 = o - o % 4
            if a4 + 4 <= size:
                v0, v1 = le(src, a4, 4), le(need, a4, 4)
                if BASE <= v0 < BASE + 0x200000 and BASE <= v1 < BASE + 0x200000:
                    reloc.append([a4, v1 - v0])
                    o = a4 + 4
                    continue
            rawd[str(o)] = need[o]
            o += 1
        if reloc or rawd or size != len(raw):
            out[name] = {"size": size, "reloc": reloc, "raw": rawd}
            nrel += len(reloc)
            nraw += len(rawd)
    path = os.path.join(ROOT, args.dst, "maincpu", "includes", "%s_c_divergence.json" % args.dst)
    with open(path, "w") as fh:
        fh.write("{\n" + ",\n".join('  %s: %s' % (json.dumps(k), json.dumps(v, separators=(",", ":")))
                                    for k, v in sorted(out.items())) + "\n}\n")
    print("wrote %s: %d bins, %d pointer relocations, %d raw bytes" % (os.path.relpath(path, ROOT), len(out),
                                                                       nrel, nraw))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default="v7")
    ap.add_argument("--dst", default="v6", help="v<N>: writes ROOT/v<N>/maincpu")
    ap.add_argument("--rom", required=True)
    ap.add_argument("--cache")
    ap.add_argument("--emit", action="store_true")
    ap.add_argument("--cdiv", action="store_true", help="only write the C-data divergence json")
    ap.add_argument("--dump-failed", metavar="FILE", help="write the lines that became raw rows, with "
                    "their source and target bytes")
    args = ap.parse_args()
    if not re.fullmatch(r'v\d+', args.dst) or not re.fullmatch(r'v\d+', args.src):
        sys.exit("--src and --dst are tree names such as v7 and v6")
    if args.cdiv:
        return c_divergence(args)
    P = Port(args)
    print("code gaps re-aligned by instruction:", dict(P.realigned))
    rom, dm, size, cls = P.rom, P.dm, P.size, P.cls
    st = collections.Counter()
    sb = collections.Counter()
    for (k, d), n in zip(cls, size):
        if k != "none":
            st[k] += 1
            sb[k] += n
    mapped = sum(1 for x in dm if x is not None)
    print("source bytes mapped to the target: %d of %d" % (mapped, len(rom)))
    for k in ("same", "diff", "unmapped"):
        print("  %-9s lines %7d  bytes %8d" % (k, st[k], sb[k]))
    P.skeleton()
    ek = collections.Counter(e[0] for e in P.events)
    raw = sum(e[2] - e[1] for e in P.events if e[0] == "raw")
    print("events:", dict(ek), " raw target bytes:", raw, " guessed referenced labels:", len(P.guessed))
    P.settle_tentative()
    print("labels no evidence places: %d; dropped (nothing in the target needs them) %d, kept because needed %d"
          % (len(P.tentative), len(P.dropped), len(P.needed_tentative)))
    if P.needed_tentative:
        print("needed:", " ".join(P.needed_tentative))
    P.votes()
    print("`Label + K` names not re-aimed (record unchanged, or the uses point at another label):",
          len(P.kept_on_record))
    print("constants not re-valued, their uses written with the constant of that value:",
          " ".join("%s->%s" % kv for kv in sorted(P.equ_redirect.items())))
    print("re-valued constants sharing the new value with another of their family:",
          " ".join("%s=%s" % kv for kv in sorted(P.collisions.items())))
    P.new_labels()
    print("dropped labels placed where their uses point instead:", len(P.relocated))
    print("labels added at target addresses no ported label names:", len(P.newlab) - len(P.relocated))
    print("numeric symbols given a new value:", len(P.newequ),
          " with disagreeing uses:", sum(1 for c in P.equ_votes.values() if len(c) > 1))
    P.resolve()
    print("line resolution:", dict(P.stats))
    if args.dump_failed:
        with open(args.dump_failed, "w", encoding="latin-1") as fh:
            for i, t, n, body, test, new, e0, e1 in P.failed:
                a = P.order[i][0] - BASE
                fh.write("%06x %s:%d\t%s\n  src %s\n  tgt %s\n  test %s -> %s\n  new  %s -> %s\n" % (
                    BASE + t, P.order[i][1], P.order[i][2], body, P.rom[a:a + n].hex(" "),
                    P.tgt[t:t + n].hex(" "), test and repr(test[0]), e0 and e0.hex(" "), new and new[1],
                    e1 and e1.hex(" ")))
    if args.emit:
        P.emit()
        print("wrote %s/maincpu: %d raw target bytes in TODO(port) rows; %d link-script addresses moved"
              % (args.dst, P.rawbytes, P.relinked))
        print("labels dropped: %d, of them unused `Label + K` aliases %d (listed in %s/maincpu/"
              "port_dropped_labels.txt); link-script addresses nothing places: %d"
              % (len(P.dropped_rows), len(P.stale_alias), args.dst, P.relink_unplaced))


if __name__ == "__main__":
    main()
