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
     between matched blocks map byte for byte (a substitution).  Result: a delta
     for every mapped source byte.
  3. A source line whose bytes all map with ONE delta is PORTED to address+delta.
     Equal bytes: the text is kept.  Different bytes: every number / symbol
     operand whose source value sits little-endian in the line's bytes at an
     offset where the bytes differ takes the target value from the same offset;
     a relative branch keeps its label when the label lands on the target the
     displacement names.  The rewritten line is assembled in isolation, with every
     symbol replaced by its required value, and must reproduce the target bytes;
     else the line becomes `.byte`.
  4. Unmapped source lines and target bytes with no source line become `.byte`
     rows.  Labels of unmapped lines are placed by finding the bytes that follow
     them in the source inside the target gap (unique match), else dropped when
     nothing references them; a referenced label that cannot be placed stops
     the tool.
  5. A symbol defined by `.equ`/`.set` to a number (a RAM variable) whose uses
     all require one new value gets that value in the target tree.  Uses that
     disagree get the number written at the use instead.

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
    for s, e, sb in bl + [(len(a), len(a), len(b))]:
        refine(pa, s, pb, sb)
        put(s, e, sb - s)
        pa, pb = e, sb + (e - s)
    return dm


# ------------------------------------------------------------------ driver
def load(args):
    cache = args.cache or os.path.join(tempfile.gettempdir(), "port-%s-%s" % (args.src, args.dst))
    os.makedirs(cache, exist_ok=True)
    args.cache = cache
    f = os.path.join(cache, "map_%s.json" % args.src)
    if os.path.exists(f):
        d = json.load(open(f))
        order, syms = d["order"], d["syms"]
        rom = open(os.path.join(cache, "rom_%s.bin" % args.src), "rb").read()
    else:
        order, syms, rom = tree_map(args.src)
        json.dump({"order": order, "syms": syms}, open(f, "w"))
        open(os.path.join(cache, "rom_%s.bin" % args.src), "wb").write(rom)
    tgt = open(args.rom, "rb").read()
    key = hashlib.sha1(rom + tgt).hexdigest()[:16]
    g = os.path.join(cache, "dm_%s.json" % key)
    if os.path.exists(g):
        dm = json.load(open(g))
    else:
        dm = align(rom, tgt)
        json.dump(dm, open(g, "w"))
    return order, syms, rom, tgt, dm


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
REL_W = {"jr": 1, "djnz": 1, "djnz8": 1, "jrl": 2, "calr": 2, "djnz16": 2}
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
                sys.stderr.write(r.stderr[-3000:])
                break
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
        self.cls = classify(self.order, self.size, self.rom, self.tgt, self.dm)
        self.parsed = [split_line(e[3]) for e in self.order]
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
        self.macros_lc = {x.lower() for x in self.macros}
        self.macro_rel = set()          # symbols a macro body branches to relatively
        self.newequ = {}
        self.newexpr = {}

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
    def skeleton(self):
        order, size, cls = self.order, self.size, self.cls
        ev = []
        self.place = {}                 # label -> target offset
        self.guessed = set()
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
                self.gap(ev, pend, tc, t)
                ev.append(("line", i, t))
                for lab in self.parsed[i][0]:
                    self.place[lab] = t
                tc = t + n
                pend = []
            else:
                pend.append(i)
        self.gap(ev, pend, tc, len(self.tgt))
        self.events = ev

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
        U = [i for i in pend if size[i] > 0]
        if not U and t0 >= t1:
            for i in pend:
                for lab in self.parsed[i][0]:
                    self.place[lab] = t0
                ev.append(("zero", i, t0))
            return
        u0 = order[U[0]][0] - BASE if U else None
        u1 = (order[U[-1]][0] - BASE + size[U[-1]]) if U else None
        last = t0
        rows = []
        for i in pend:
            labs = self.parsed[i][0]
            a = order[i][0] - BASE
            if labs:
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
                    if any(self.refcount.get(lb) for lb in labs):
                        self.guessed.update(labs)
                p = max(p, last)
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
        for sym, c in vt.items():
            best, nb = c.most_common(1)[0]
            if sym in self.equ_lines:
                if best != self.sv.get(sym):
                    self.newequ[sym] = best
            elif best != self.tval(sym):
                self.newexpr[sym] = best

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
            if txt not in self.sv and txt not in self.labels_src and txt not in self.equ_expr:
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
        self.rawbytes = 0

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

        for kind, *rest in self.events:
            if kind == "raw":
                rawbuf.append((rest[0], rest[1]))
                continue
            i, t = rest
            rel = self.order[i][1]
            text = self.order[i][3]
            labs, body, com = self.parsed[i]
            if kind == "zero":
                m = re.match(r'^\.(?:equ|set)\s+([A-Za-z_.$][\w.$]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*$', body)
                if m and m.group(1) in self.newequ:
                    old = m.group(2)
                    nb = body[:m.start(2)] + fmt_like(old, self.newequ[m.group(1)]) + body[m.end(2):]
                    text = text.replace(body, nb, 1)
                m = EQU_EXPR.match(body)
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
            shutil.rmtree(ddir)
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
                if r in ("transplant_manifest.txt",):
                    continue                 # describes the source tree's own history
                dr = r.replace(root_s, "kn5000_%s_program.s" % dst)
                shutil.copy2(os.path.join(sdir, r), os.path.join(ddir, dr))
        for rel, lines in files.items():
            dr = rel.replace(root_s, "kn5000_%s_program.s" % dst)
            with open(os.path.join(ddir, dr), "w", encoding="latin-1", newline="\n") as fh:
                fh.write("\n".join(lines))
        if keep is not None:
            open(readme, "w", encoding="utf-8").write(keep)
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
    ap.add_argument("--dst", default="v6")
    ap.add_argument("--rom", required=True)
    ap.add_argument("--cache")
    ap.add_argument("--emit", action="store_true")
    ap.add_argument("--cdiv", action="store_true", help="only write the C-data divergence json")
    ap.add_argument("--dump-failed", metavar="FILE", help="write the lines that became raw rows, with "
                    "their source and target bytes")
    args = ap.parse_args()
    if args.cdiv:
        return c_divergence(args)
    P = Port(args)
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
    P.votes()
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
        print("wrote %s/maincpu: %d raw target bytes in TODO(port) rows" % (args.dst, P.rawbytes))


if __name__ == "__main__":
    main()
