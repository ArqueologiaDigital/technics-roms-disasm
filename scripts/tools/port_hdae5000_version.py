#!/usr/bin/env python3
r"""port_hdae5000_version.py -- port the HD-AE5000 source tree to another ROM version.

QUESTION ANSWERED / JOB IT DOES
    The v2.06i tree (hdae5000/) is symbolic: every ROM address is a label, so a
    copy of it re-assembles correctly for another version wherever the code is
    the same, even though everything has moved.  What a port has to change is
    (a) numbers that are not symbolic -- RAM addresses spelled as literals, the
    values of the HDAE5000_RAM_* / HDAE5000_OBJ_* constants, counts, stack
    offsets -- and (b) the places where the code or data really differ.

    This tool finds both, against the target ROM, by assembling the target tree
    with a marker label in front of every source line (so it knows which line
    emits every byte; llvm-mc --save-temp-labels keeps the .L labels) and
    aligning the result with the target image (blocks of identical bytes,
    kn5000_version_delta.anchors/blocks, refined inside each gap).  What is left
    between blocks is a HUNK.  The passes, each re-run until nothing changes:

      fix       same-size hunks whose differing bytes are a number the line
                spells as a literal, or as a constant whose name is in
                RETARGET_PREFIXES: the number is rewritten (a constant at its
                `.equ`, once, for the whole tree).  Once `uitables` has run,
                the HDAE5000_OBJ_* values come from the target's name table
                and are frozen: a line whose object id differs is respelled
                with the constant that has the target's value, or left alone
                (scripts/analysis/hdae5000_obj_constants_check.py checks them);
      code      code hunks: the source lines and the target's instructions are
                aligned by SHAPE (mnemonic and registers, numbers masked,
                difflib); an aligned line is retargeted as above, an unaligned
                target instruction is spelled from a template line of the same
                shape and length elsewhere in the tree, or failing that from
                MAME's text through llvm-mc round-trip candidates.  Branch and
                pointer targets become labels -- existing ones where the target
                maps onto one, otherwise new <routine>_Skip<n> / _Loop<n>
                labels; 32-bit pointers pushed as two halves become
                `pushw Label@hi16` / `@lo16`;
      strings   runs of .asciz / .balign lines, aligned by content; strings only
                in the target get a HDAE5000_Str_* / _Fmt_* label and a "; only
                in <version>" note, labels of strings it lacks are kept and
                marked PORT-ORPHAN;
      uitables  regenerates the whole UI object section of
                hdae5000_data_tables.s (descriptor pool, object and name
                tables, HDAE5000_OBJ_* ids, name pool) from the target ROM,
                with the record model of scripts/generators/gen_hdae5000_ui_pool.py
                (checked: run on a copy of hdae5000/ it reproduces v2.06i byte
                for byte).
    The rest (a few switch tables, deleted settings, the RAM-image layout) is
    edited by hand; `status` and `show N` list what is left.  The aligner gets
    the BYTES right; label placement it cannot verify where nothing references
    a label, so a ported tree needs a review of its unreferenced labels.

    It never edits hdae5000/.

RUN (from the repo root)
    python3 scripts/tools/port_hdae5000_version.py init     v2_01i  # copy hdae5000/ -> hdae5000_v2_01i/
    python3 scripts/tools/port_hdae5000_version.py status   v2_01i  # the hunks left
    python3 scripts/tools/port_hdae5000_version.py fix      v2_01i [--rounds N]
    python3 scripts/tools/port_hdae5000_version.py code     v2_01i [N ...] [--dry]
    python3 scripts/tools/port_hdae5000_version.py strings  v2_01i [N ...] [--dry]
    python3 scripts/tools/port_hdae5000_version.py uitables v2_01i
    python3 scripts/tools/port_hdae5000_version.py show     v2_01i N [--code]
    python3 scripts/tools/port_hdae5000_version.py tables   v2_06i v2_01i v1_15i v1_10i  # UI table locations
    The target image is original_ROMs/hd-ae5000_<ver>.ic4 (make copies it there)
    or $KN5000_ROMS_DIR/hd-ae5000_<ver>.ic4.  Scratch goes to
    $TMPDIR/port_hdae5000_<ver>/ (TMPDIR defaults to ~/compartilhado/tmp).
    notes/hdae5000-versions-2026-10-24/README.md records how v2.01i was ported.
"""
import bisect
import collections
import difflib
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import kn5000_version_delta as kvd  # noqa: E402

BIN = os.environ.get("LLVM_BIN", "/home/fsanches/compartilhado/llvm-project/build/bin")
UNIDASM = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/tools/unidasm")
ROMS_DIR = os.environ.get("KN5000_ROMS_DIR",
                          os.path.expanduser("~/compartilhado/technics_roms/roms/kn5000"))
SCRATCH = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
BASE = 0x280000
SRC_TREE = "hdae5000"
SRC_MAIN = "hd-ae5000_v2_06i.s"
RETARGET_PREFIXES = ("HDAE5000_RAM_", "HDAE5000_OBJ_")
CODE_END = 0x29b000     # below this every version's image is code: a pointer there may get a new label
INC_RE = re.compile(rb'^\s*\.include\s+"([^"]+)"')
NUM_RE = re.compile(rb'(?<![\w.])(-?)(0x[0-9a-fA-F]+|[0-9]+)(?![\w])')
SYM_RE = re.compile(rb'(?<![\w.@])(\.L[A-Za-z_]\w*|[A-Za-z_][A-Za-z0-9_]*)(?:\s*([+-])\s*(0x[0-9a-fA-F]+|[0-9]+))?')
DIRECTIVE_W = {b".byte": 1, b".short": 2, b".word": 2, b".hword": 2, b".2byte": 2,
               b".long": 4, b".int": 4, b".4byte": 4}


def tree_of(ver):
    return os.path.join(ROOT, "hdae5000_" + ver)


def main_of(ver):
    return "hd-ae5000_%s.s" % ver


def ref_image(ver):
    p = os.path.join(ROOT, "original_ROMs", "hd-ae5000_%s.ic4" % ver)
    if not os.path.exists(p):
        p = os.path.join(ROMS_DIR, "hd-ae5000_%s.ic4" % ver)
    return open(p, "rb").read()


def split_code(line):
    """(code, comment) of a source line; a ';' inside a string literal is code."""
    q = False
    for i, c in enumerate(line):
        if c == 0x22 and (i == 0 or line[i - 1] != 0x5C):
            q = not q
        elif c == 0x3B and not q:
            return line[:i], line[i:]
    return line, b""


# --------------------------------------------------------------------------- build

class Build:
    """The target tree assembled with a marker label before every line."""

    def __init__(self, tree, main, incs, work):
        self.tree, self.main = tree, main
        if os.path.isdir(work):
            assert work.startswith(SCRATCH) and os.path.basename(work).startswith("port_hdae5000_")
            shutil.rmtree(work)
        os.makedirs(work)
        files, texts = [], {}

        def collect(rel):
            if rel in files:
                return
            p = os.path.join(tree, rel)
            if not os.path.exists(p):
                return                      # resolved through an extra -I directory
            files.append(rel)
            texts[rel] = open(p, "rb").read().split(b"\n")
            for ln in texts[rel]:
                m = INC_RE.match(ln)
                if m:
                    collect(m.group(1).decode())
        collect(main)
        self.files, self.texts = files, texts
        for i, rel in enumerate(files):
            out = []
            for n, ln in enumerate(texts[rel], 1):
                out.append(b"__PM_%d_%d:" % (i, n))
                out.append(ln)
            os.makedirs(os.path.dirname(os.path.join(work, rel)) or work, exist_ok=True)
            open(os.path.join(work, rel), "wb").write(b"\n".join(out))
        obj, elf, rom = (os.path.join(work, "out" + e) for e in (".o", ".elf", ".rom"))
        cmd = [BIN + "/llvm-mc", "-triple=tlcs900", "-filetype=obj", "--save-temp-labels",
               "-I", work, "-I", tree]
        for d in incs:
            cmd += ["-I", d]
        r = subprocess.run(cmd + ["-o", obj, os.path.join(work, main)], capture_output=True)
        self.stderr = r.stderr.decode("latin-1")
        if r.returncode != 0:
            self.ok = False
            return
        r = subprocess.run([BIN + "/ld.lld", "-e", "0", "-T", os.path.join(tree, "hdae5000.ld"),
                            "-o", elf, obj], capture_output=True)
        if r.returncode != 0:
            self.stderr += r.stderr.decode("latin-1")
            self.ok = False
            return
        subprocess.run([BIN + "/llvm-objcopy", "-O", "binary", elf, rom], check=True)
        self.ok = True
        self.img = open(rom, "rb").read()
        nm = subprocess.run([BIN + "/llvm-nm", "--defined-only", elf], capture_output=True,
                            text=True, check=True).stdout
        mark, self.syms = {}, []
        for l in nm.split("\n"):
            p = l.split()
            if len(p) != 3:
                continue
            if p[2].startswith("__PM_"):
                fi, n = p[2][5:].split("_")
                mark[(int(fi), int(n))] = int(p[0], 16)
            elif p[1] in "tT":
                self.syms.append((int(p[0], 16), p[2]))
        self.syms.sort()
        self.symaddr = {n: a for a, n in self.syms}
        flat = []

        def walk(fi):
            for n in range(1, len(texts[files[fi]]) + 1):
                flat.append((fi, n))
                m = INC_RE.match(texts[files[fi]][n - 1])
                if m and m.group(1).decode() in files:
                    walk(files.index(m.group(1).decode()))
        walk(0)
        self.lines = []                     # (file, lineno, start, end)
        for j, (fi, n) in enumerate(flat):
            s = mark[(fi, n)]
            e = mark[flat[j + 1]] if j + 1 < len(flat) else s
            if INC_RE.match(texts[files[fi]][n - 1]):
                e = s
            self.lines.append((files[fi], n, s, e))
        self.emitting = {}
        self.byaddr = sorted((s, k) for k, (f, n, s, e) in enumerate(self.lines) if e > s)
        self.starts = [s for s, _ in self.byaddr]

    def text(self, f, n):
        return self.texts[f][n - 1]

    def lines_in(self, a0, a1):
        """indices into self.lines of the byte-emitting lines overlapping [a0, a1)."""
        k = bisect.bisect_right(self.starts, a0) - 1
        k = max(k, 0)
        out = []
        while k < len(self.byaddr) and self.byaddr[k][0] < a1:
            li = self.byaddr[k][1]
            if self.lines[li][3] > a0:
                out.append(li)
            k += 1
        return out


# --------------------------------------------------------------------------- align

def refine(w, b, w0, w1, b0, b1, k=8, depth=0):
    """Blocks inside one gap, anchored on k-grams unique within the gap."""
    if w1 - w0 < 2 * k or b1 - b0 < 2 * k or depth > 2:
        return []
    sw, sb = w[w0:w1], b[b0:b1]
    old = kvd.K
    kvd.K = k
    try:
        bl = kvd.blocks(sw, sb, kvd.anchors(sw, sb))
    finally:
        kvd.K = old
    return [(s + w0, e + w0, sb_ + b0) for s, e, sb_ in bl if e - s >= k]


def hunks(w, b):
    bl = kvd.blocks(w, b, kvd.anchors(w, b))
    full, pw, pb = [], 0, 0
    for s, e, sb in bl + [(len(w), len(w), len(b))]:
        if s > pw or sb > pb:
            full += refine(w, b, pw, s, pb, sb)
        if e > s:
            full.append((s, e, sb))
        pw, pb = e, sb + (e - s)
    full.sort()
    out, pw, pb = [], 0, 0
    for s, e, sb in full + [(len(w), len(w), len(b))]:
        if s > pw or sb > pb:
            out.append((pw + BASE, s + BASE, pb + BASE, sb + BASE))
        pw, pb = max(pw, e), max(pb, sb + (e - s))
    return out, full


# --------------------------------------------------------------------------- constants

def read_equs(build):
    """name -> (value, file, lineno) for `.equ NAME, <number>` lines of the tree."""
    out = {}
    pat = re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|[0-9]+)\s*(?:;|$)')
    for f in build.files:
        for n, ln in enumerate(build.texts[f], 1):
            m = pat.match(ln)
            if m:
                out[m.group(1).decode()] = (int(m.group(2), 0), f, n)
    return out


def fmt_like(tok, val):
    """Render val in the radix and width style of the literal tok."""
    t = tok.decode()
    neg = t.startswith("-")
    t = t.lstrip("-")
    if t.lower().startswith("0x"):
        digits = len(t) - 2
        return ("0x%0*x" % (digits, val)).encode()
    return str(val).encode()


# --------------------------------------------------------------------------- retarget

def clusters(diff):
    out = []
    for i in diff:
        if out and i - out[-1][-1] <= 3:
            out[-1].append(i)
        else:
            out.append([i])
    return [(c[0], c[-1]) for c in out]


def retarget(line, wb, bb, equs, symaddr):
    """Rewrite one source line so that it emits bb instead of wb (same length).

    Returns (new_line, {equ_name: new_value}) or None."""
    if len(wb) != len(bb):
        return None
    code, comment = split_code(line)
    st = code.strip()
    diff = [i for i in range(len(wb)) if wb[i] != bb[i]]
    if not diff:
        return line, {}
    m = re.match(rb'^(\s*(?:(?:\.L)?[A-Za-z_]\w*:\s*)?)(\.\w+)(\s+)(.*?)(\s*)$', code)
    if m and m.group(2) in DIRECTIVE_W:
        width = DIRECTIVE_W[m.group(2)]
        toks = [t for t in m.group(4).split(b",")]
        if len(toks) * width != len(wb):
            return None
        eq = {}
        new = []
        for j, t in enumerate(toks):
            va = int.from_bytes(wb[j * width:(j + 1) * width], "little")
            vb = int.from_bytes(bb[j * width:(j + 1) * width], "little")
            ts = t.strip()
            if va == vb:
                new.append(t)
                continue
            if NUM_RE.fullmatch(ts):
                new.append(t.replace(ts, fmt_like(ts, vb)))
                continue
            sm = SYM_RE.fullmatch(ts)
            if sm and sm.group(1).decode() in equs and \
                    sm.group(1).decode().startswith(RETARGET_PREFIXES):
                off = int(sm.group(3), 0) * (-1 if sm.group(2) == b"-" else 1) if sm.group(3) else 0
                eq[sm.group(1).decode()] = vb - off
                new.append(t)
                continue
            return None
        return m.group(1) + m.group(2) + m.group(3) + b",".join(new) + m.group(5) + comment, eq
    if m and m.group(2) in (b".ascii", b".asciz"):
        body = bb[:-1] if m.group(2) == b".asciz" else bb
        if m.group(2) == b".asciz" and bb[-1] != 0:
            return None
        if 0 in body:
            return None
        return m.group(1) + m.group(2) + m.group(3) + b'"' + esc(body) + b'"' + m.group(5) \
            + comment, {}
    if st.startswith(b"."):
        return None
    # an instruction: solve each cluster of differing bytes as one operand
    new_code, eq = code, {}
    for c0, c1 in clusters(diff):
        done = False
        for width in (4, 3, 2, 1):
            for s in range(max(0, c1 - width + 1), c0 + 1):
                if s + width > len(wb) or s > c0 or s + width - 1 < c1:
                    continue
                va = int.from_bytes(wb[s:s + width], "little")
                vb = int.from_bytes(bb[s:s + width], "little")
                mask = (1 << (8 * width)) - 1
                hits = []
                for tk in num_tokens(new_code):
                    if tk[2] & mask == va:
                        hits.append(("num", tk))
                for mm in SYM_RE.finditer(new_code):
                    name = mm.group(1).decode()
                    if name in equs and name.startswith(RETARGET_PREFIXES):
                        off = int(mm.group(3), 0) * (-1 if mm.group(2) == b"-" else 1) \
                            if mm.group(3) else 0
                        if (equs[name][0] + off) & mask == va:
                            hits.append(("sym", mm, name, off))
                if len(hits) != 1:
                    continue
                h = hits[0]
                if h[0] == "num":
                    tk = h[1]
                    new_code = new_code[:tk[0]] + render_num(tk, vb, width) + new_code[tk[1]:]
                else:
                    eq[h[2]] = vb - h[3]
                done = True
                break
            if done:
                break
        if not done:
            return None
    return new_code + comment, eq


NUMTOK_RE = re.compile(rb'(?<![\w.:@])(0x[0-9a-fA-F]+|[0-9]+)(?![\w])')


def num_tokens(code):
    """Numeric literals of a code part: (start, end, signed value, digits, operator text).
    A literal after a binary + or - (a displacement) carries that operator, so its value is
    signed and its replacement may flip the operator."""
    out = []
    for m in NUMTOK_RE.finditer(code):
        v = int(m.group(1), 0)
        j = m.start() - 1
        while j >= 0 and code[j] in b" \t":
            j -= 1
        st, op = m.start(), None
        if j >= 0 and code[j:j + 1] in (b"+", b"-"):
            k = j - 1
            while k >= 0 and code[k] in b" \t":
                k -= 1
            if k >= 0 and (chr(code[k]).isalnum() or code[k] in b"_)"):
                st, op = k + 1, code[k + 1:m.start()]
            elif code[j:j + 1] == b"-":
                st, op = j, b"-"
            if code[j:j + 1] == b"-":
                v = -v
        out.append((st, m.end(), v, m.group(1), op))
    return out


def render_num(tok, vb, width):
    """Spell vb (the field's raw unsigned value) the way token tok was spelled."""
    st, en, v, digits, op = tok
    if op is None:
        return fmt_like(digits, vb)
    sv = vb - (1 << (8 * width)) if vb >> (8 * width - 1) else vb
    if op.strip() in (b"+", b"-") and op != op.strip():      # binary, spaced: ' + ' / ' - '
        o = op.replace(b"-", b"+") if sv >= 0 else op.replace(b"+", b"-")
        return o + fmt_like(digits, abs(sv))
    if op in (b"+", b"-") and v != 0 and st > 0:
        pass
    o = (b"+" if sv >= 0 else b"-") if op in (b"+", b"-") else op
    if op == b"-" and len(op) == 1:
        o = b"+" if sv >= 0 else b"-"
    return o + fmt_like(digits, abs(sv))


def esc(bs):
    out = bytearray()
    for c in bs:
        if c == 0x22:
            out += b'\\"'
        elif c == 0x5C:
            out += b"\\\\"
        elif 0x20 <= c < 0x7F:
            out.append(c)
        else:
            out += b"\\%03o" % c
    return bytes(out)


# --------------------------------------------------------------------------- tree edits

class Edits:
    def __init__(self, tree):
        self.tree = tree
        self.cache = {}

    def lines(self, f):
        if f not in self.cache:
            self.cache[f] = open(os.path.join(self.tree, f), "rb").read().split(b"\n")
        return self.cache[f]

    def set(self, f, n, text):
        self.lines(f)[n - 1] = text

    def set_equ(self, f, n, value):
        ln = self.lines(f)[n - 1]
        m = re.match(rb'^(\s*\.(?:equ|set)\s+[A-Za-z_]\w*\s*,\s*)(0x[0-9a-fA-F]+|[0-9]+)(.*)$', ln)
        assert m, ln
        self.lines(f)[n - 1] = m.group(1) + fmt_like(m.group(2), value) + m.group(3)

    def write(self):
        for f, ls in self.cache.items():
            open(os.path.join(self.tree, f), "wb").write(b"\n".join(ls))
        self.cache = {}


# --------------------------------------------------------------------------- code hunks

SHAPE_NUM = re.compile(r'0x[0-9a-f]+|(?<![\w])\d+(?![\w])')
REL_OPS = ("jr", "jrl", "calr", "djnz")
ABS_RE = re.compile(r'0x([0-9a-f]{6})\b')


def shape(text):
    return SHAPE_NUM.sub("N", text.lower())


def unidasm(data, pc):
    p = os.path.join(SCRATCH, "port_hdae5000_unidasm_%d.bin" % os.getpid())
    open(p, "wb").write(data)
    out = subprocess.run([UNIDASM, p, "-arch", "tlcs900", "-basepc", "%x" % pc],
                         capture_output=True, text=True).stdout
    os.remove(p)
    res = []
    for l in out.split("\n"):
        m = re.match(r'^([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)$', l)
        if m:
            res.append((int(m.group(1), 16), bytes.fromhex(m.group(2)), m.group(3).strip()))
    return res


def is_insn(line):
    code, _ = split_code(line)
    code = re.sub(rb'^\s*(?:\.L)?[A-Za-z_]\w*:', b"", code).strip()
    return bool(code) and not code.startswith(b".")


def label_of(line):
    m = re.match(rb'^(\.L[A-Za-z_]\w*|[A-Za-z_]\w*):', line)
    return m.group(1).decode() if m else None


class Ctx:
    """What the code-hunk pass knows: W build, target image, B label map, constants."""

    def __init__(self, bld, ref, full_blocks):
        self.bld, self.ref = bld, ref
        self.equs = read_equs(bld)
        self.bmap = {}                          # B address -> label
        starts = [s for s, _, _ in full_blocks]
        for a, name in bld.syms:
            if name.startswith("__PM_"):
                continue
            k = bisect.bisect_right(starts, a - BASE) - 1
            if k >= 0:
                s, e, sb = full_blocks[k]
                if s <= a - BASE < e:
                    self.bmap.setdefault(sb + (a - BASE - s) + BASE, name)
        self.blocks = full_blocks
        self.bstarts = starts
        # a label at the first byte of a hunk names the first byte of its B side too
        pw = pb = 0
        for s_, e_, sb_ in full_blocks + [(len(bld.img), len(bld.img), len(ref))]:
            if s_ > pw or sb_ > pb:
                for a, name in bld.syms:
                    if a == pw + BASE and not name.startswith("__PM_"):
                        self.bmap.setdefault(pb + BASE, name)
            pw, pb = max(pw, e_), max(pb, sb_ + (e_ - s_))
        self.ram_names = {v: n for n, (v, f, l) in self.equs.items() if n.startswith("HDAE5000_RAM_")}
        self.obj_names = {v: n for n, (v, f, l) in self.equs.items() if n.startswith("HDAE5000_OBJ_")}
        self.new_labels = {}                    # B address -> name (created this round)
        self.used = set(bld.symaddr) | set(self.equs)

    def w_of_b(self, b):
        """W address of B address b when b lies in an identical block."""
        for s, e, sb in self.blocks:            # blocks are few hundred: linear is fine
            if sb <= b - BASE < sb + (e - s):
                return s + (b - BASE - sb) + BASE
        return None

    def label_at(self, b):
        return self.bmap.get(b) or self.new_labels.get(b)

    def routine_before(self, b):
        cands = [(a, n) for a, n in list(self.bmap.items()) + list(self.new_labels.items())
                 if a <= b and not n.startswith(".L")]
        if not cands:
            return "HDAE5000"
        a, n = max(cands)
        n = re.sub(r'_(Skip|Loop|Join)\d*$', "", n)
        return n

    def make_label(self, b, src):
        if self.label_at(b):
            return self.label_at(b)
        base = self.routine_before(b) + ("_Loop" if b <= src else "_Skip")
        k = 1
        while (base + ("" if k == 1 else str(k))) in self.used:
            k += 1
        name = base + ("" if k == 1 else str(k))
        self.used.add(name)
        self.new_labels[b] = name
        return name

    def render(self, v, width, tok, src):
        if BASE <= v < BASE + 0x80000 and width >= 3:
            lab = self.label_at(v) or (self.make_label(v, src) if v < CODE_END else None)
            if lab:
                return lab.encode()
            return None
        if 0x200000 <= v < 0x240000 and width >= 3 and v in self.ram_names:
            return self.ram_names[v].encode()
        if v >> 16 == 0x7f and width == 4 and v in self.obj_names:
            return self.obj_names[v].encode()
        return fmt_like(tok, v) if tok is not None else (b"0x%x" % v)


def transplant(line, wb, bb, btext, bpc, ctx, keep_comment=False):
    """Spell the B instruction (bytes bb, MAME text btext at bpc) on the pattern of a
    source line that emits wb (same shape, same length).  None when it cannot."""
    if len(wb) != len(bb):
        return None
    code, comment = split_code(line)
    code = re.sub(rb'^\s*(?:\.L)?[A-Za-z_]\w*:', b"", code)
    op = btext.split(None, 1)[0].lower()
    if op in REL_OPS:
        t = int(ABS_RE.findall(btext.lower())[-1], 16)
        lab = ctx.make_label(t, bpc)
        m = list(re.finditer(rb'[A-Za-z_]\w*', code))
        if not m:
            return None
        mm = m[-1]
        if mm.group(0).decode() not in ctx.bld.symaddr and mm.group(0).decode() not in ctx.used:
            return None
        new = code[:mm.start()] + lab.encode() + code[mm.end():]
        return new + (comment if keep_comment else b"")
    diff = [i for i in range(len(wb)) if wb[i] != bb[i]]
    new = code
    for c0, c1 in clusters(diff):
        done = False
        for width in (4, 3, 2, 1):
            for s in range(max(0, c1 - width + 1), c0 + 1):
                if s + width > len(wb) or s + width - 1 < c1:
                    continue
                va = int.from_bytes(wb[s:s + width], "little")
                vb = int.from_bytes(bb[s:s + width], "little")
                mask = (1 << (8 * width)) - 1
                hits = []
                for tk in num_tokens(new):
                    if tk[2] & mask == va:
                        hits.append(("num", tk))
                for mm in SYM_RE.finditer(new):
                    name = mm.group(1).decode()
                    val = ctx.equs[name][0] if name in ctx.equs else ctx.bld.symaddr.get(name)
                    if val is None or mm.group(2) or new[mm.end():mm.end() + 1] == b"@":
                        continue
                    if val & mask == va:
                        hits.append(("sym", (mm.start(), mm.end())))
                if len(hits) != 1:
                    continue
                kind, tk = hits[0]
                if kind == "num" and not (width >= 3 and (BASE <= vb < BASE + 0x80000 or
                                                         0x200000 <= vb < 0x240000 or vb >> 16 == 0x7f)):
                    rep = render_num(tk, vb, width)
                else:
                    rep = ctx.render(vb, width, None, bpc)
                if rep is None:
                    return None
                new = new[:tk[0]] + rep + new[tk[1]:]
                done = True
                break
            if done:
                break
        if not done:
            return None
    return new + (comment if keep_comment else b"")


def translate_candidates(btext, bb):
    """llvm-mc spellings to try for a MAME-syntax instruction (no ROM operands)."""
    t = btext.lower()
    parts = t.split(None, 1)
    op, args = parts[0], (parts[1] if len(parts) > 1 else "")
    ops = [a.strip() for a in args.split(",")] if args else []
    out = []

    def disp_forms(a):
        m = re.match(r'^\(?(x[a-z]+)\+0x([0-9a-f]+)\)?$', a)
        if not m:
            return [a]
        r, v = m.group(1), int(m.group(2), 16)
        forms = ["(%s+%d)" % (r, v)]
        if v >= 0x80 and v < 0x100:
            forms.append("(%s-%d)" % (r, 0x100 - v))
        if v >= 0x8000:
            forms.append("(%s-%d)" % (r, 0x10000 - v))
        forms.append("(%s+%d:8)" % (r, v if v < 0x80 else v - 0x100))
        return forms
    if op == "lda" and len(ops) == 2:
        for f in disp_forms(ops[1]):
            out.append("lda\t%s, %s" % (ops[0], f))
    if op == "call" and ops == ["t", "xhl"]:
        out.append("call\t(xhl)")
    erp = re.match(r'^q([a-z]+)$', ops[0]) if ops else None
    if op == "ld" and len(ops) == 2:
        a, b = ops
        for fa in disp_forms(a):
            for fb in disp_forms(b):
                out.append("ld\t%s, %s" % (fa, fb))
                out.append("ldw\t%s, %s" % (fa, fb))
                out.append("ldb\t%s, %s" % (fa, fb))
                if fb.isdigit() or fb.startswith("0x"):
                    out.append("ld\t%s, %s:opc" % (fa, fb))
                    out.append("ld\t%s, %s:i3" % (fa, fb))
        if len(bb) == 3 and bb[0] in (0xc7, 0xd7):
            reg = bb[1]
            sub = bb[2]
            r8 = ["w", "a", "b", "c", "d", "e", "h", "l"]
            r16 = ["wa", "bc", "de", "hl", "ix", "iy", "iz", "sp"]
            if bb[0] == 0xc7 and 0x88 <= sub <= 0x8f:
                out.append("ldto_berp\t%s, 0x%02x" % (r8[sub - 0x88], reg))
            if bb[0] == 0xc7 and 0x98 <= sub <= 0x9f:
                out.append("ldfr_berp\t%s, 0x%02x" % (r8[sub - 0x98], reg))
            if bb[0] == 0xd7 and 0x88 <= sub <= 0x8f:
                out.append("ldto_werp\t%s, 0x%02x" % (r16[sub - 0x88], reg))
            if bb[0] == 0xd7 and 0x98 <= sub <= 0x9f:
                out.append("ldfr_werp\t%s, 0x%02x" % (r16[sub - 0x98], reg))
    if op in ("push", "pop") and len(ops) == 1:
        out += ["%s\t%s" % (op, ops[0]), "%sw\t%s" % (op, ops[0])]
        if re.match(r'^0x[0-9a-f]+$', ops[0]):
            out.append("%sw\t%s" % (op, ops[0]))
    if op in ("inc", "dec") and len(ops) == 2:
        for f in disp_forms(ops[1]):
            out += ["%s\t%s, %s" % (op, ops[0], f), "%sw\t%s, %s" % (op, ops[0], f)]
    generic = op + ("\t" + ", ".join(ops) if ops else "")
    out.append(generic)
    if ops and len(ops) == 2:
        for fa in disp_forms(ops[0]):
            for fb in disp_forms(ops[1]):
                out.append("%s\t%s, %s" % (op, fa, fb))
                out.append("%sw\t%s, %s" % (op, fa, fb))
                if re.match(r'^(0x[0-9a-f]+|\d+)$', fb):
                    out.append("%s\t%s, %s:i3" % (op, fa, fb))
    if ops and len(ops) == 1:
        for fa in disp_forms(ops[0]):
            out.append("%s\t%s" % (op, fa))
    seen, res = set(), []
    for c in out:
        if c not in seen:
            seen.add(c)
            res.append(c)
    return res


def roundtrip_many(cands):
    """{index: encoding bytes} for a list of candidate lines (one llvm-mc run)."""
    src = []
    for i, c in enumerate(cands):
        src.append("__c%d:" % i)
        src.append("\t" + c)
    src.append("__end:")
    r = subprocess.run([BIN + "/llvm-mc", "-triple=tlcs900", "-show-encoding"],
                       input="\n".join(src) + "\n", capture_output=True, text=True)
    enc, cur = {}, None
    for l in r.stdout.split("\n"):
        m = re.match(r'^__c(\d+):', l)
        if m:
            cur = int(m.group(1))
            continue
        m = re.search(r'encoding: \[(.*?)\]', l)
        if m and cur is not None and cur not in enc:
            vals = m.group(1).split(",")
            if all(re.match(r'^0x[0-9a-f]{2}$', v) for v in vals):
                enc[cur] = bytes(int(v, 16) for v in vals)
    return enc


# --------------------------------------------------------------------------- commands

def do_build(ver):
    work = os.path.join(SCRATCH, "port_hdae5000_" + ver)
    return Build(tree_of(ver), main_of(ver), [os.path.join(ROOT, SRC_TREE)], work)


def expand(build, h):
    """Grow a hunk to whole source lines on the W side, moving the B side alike."""
    w0, w1, b0, b1 = h
    li = build.lines_in(w0, max(w1, w0 + 1))
    if not li:
        return h, li
    s = min(build.lines[k][2] for k in li)
    e = max(build.lines[k][3] for k in li)
    return (s, e, b0 - (w0 - s), b1 + (e - w1)), li


def cmd_status(ver, verbose=True, want_blocks=False):
    bld = do_build(ver)
    if not bld.ok:
        ls = bld.stderr.split("\n")
        errs = [i for i, l in enumerate(ls) if "error" in l]
        for i in errs[:20]:
            print("\n".join(ls[i:i + 3]))
        if not errs:
            print("\n".join(ls[-20:]))
        sys.exit(1)
    ref = ref_image(ver)
    hs, full = hunks(bld.img, ref)
    same = sum(1 for x, y in zip(bld.img, ref) if x == y)
    if verbose:
        print("%s: %d hunks; %d of %d bytes equal in place%s" % (
            ver, len(hs), same, len(ref), "  BYTE-IDENTICAL" if bld.img == ref else ""))
        for i, h in enumerate(hs):
            (w0, w1, b0, b1), li = expand(bld, h)
            f, n = (bld.lines[li[0]][0], bld.lines[li[0]][1]) if li else ("?", 0)
            k = bisect.bisect_right([a for a, _ in bld.syms], w0) - 1
            sym = "%s+%#x" % (bld.syms[k][1], w0 - bld.syms[k][0]) if k >= 0 else "?"
            print("%4d  W %06x+%-5d B %06x+%-5d %-8s %s:%d  %s" % (
                i, w0, w1 - w0, b0, b1 - b0, "same" if w1 - w0 == b1 - b0 else "RESIZED",
                f, n, sym))
    if want_blocks:
        return bld, ref, hs, full
    return bld, ref, hs


UITABLES_MARK = b"; Generated from the "


def obj_ids_frozen(tree):
    """True once `uitables` has written the UI object section of this tree: from then on
    each HDAE5000_OBJ_<NAME> is 0x007F0000 + the index of <NAME> in the target's own name
    table, and `fix` must not move it to make one use's bytes match (on 2026-10-24 that
    left two v2.01i constants naming the wrong objects)."""
    p = os.path.join(tree, "hdae5000_data_tables.s")
    return any(l.startswith(UITABLES_MARK) and b"uitables" in l
               for l in open(p, "rb").read().split(b"\n"))


def respell_frozen_obj(txt, eq, equs):
    """Replace each HDAE5000_OBJ_* name retarget() wanted to change by the constant that
    already has the wanted value.  Returns (txt, remaining eq) or None if one has no such
    constant."""
    rest = {}
    for name, v in eq.items():
        if not name.startswith("HDAE5000_OBJ_"):
            rest[name] = v
            continue
        cands = [n for n, e in equs.items() if n.startswith("HDAE5000_OBJ_") and e[0] == v]
        if len(cands) != 1:
            return None
        code, comment = split_code(txt)
        code = re.sub(rb'(?<![\w])' + re.escape(name.encode()) + rb'(?![\w])', cands[0].encode(), code)
        txt = code + comment
    return txt, rest


def cmd_fix(ver, rounds):
    frozen = obj_ids_frozen(tree_of(ver))
    for r in range(rounds):
        bld, ref, hs = cmd_status(ver, verbose=False)
        equs = read_equs(bld)
        ed = Edits(bld.tree)
        n_fix = n_eq = 0
        new_eq = {}
        for h in hs:
            (w0, w1, b0, b1), li = expand(bld, h)
            if w1 - w0 != b1 - b0:
                continue
            for k in li:
                f, n, s, e = bld.lines[k]
                wb = bld.img[s - BASE:e - BASE]
                bb = ref[s - w0 + b0 - BASE:e - w0 + b0 - BASE]
                if wb == bb:
                    continue
                res = retarget(bld.text(f, n), wb, bb, equs, bld.symaddr)
                if res is not None and frozen:
                    res = respell_frozen_obj(res[0], res[1], equs)
                if res is None:
                    continue
                txt, eq = res
                if txt != bld.text(f, n):
                    ed.set(f, n, txt)
                    n_fix += 1
                for name, v in eq.items():
                    if name in new_eq and new_eq[name] != v:
                        print("conflicting values for %s: %#x / %#x" % (name, new_eq[name], v))
                        continue
                    new_eq[name] = v
        for name, v in new_eq.items():
            if equs[name][0] != v:
                ed.set_equ(equs[name][1], equs[name][2], v)
                n_eq += 1
        ed.write()
        print("round %d: %d hunks, %d lines rewritten, %d constants changed" % (r, len(hs), n_fix, n_eq))
        if n_fix == 0 and n_eq == 0:
            break
    cmd_status(ver)


def norm_insn(code):
    """'\\tld (xsp + 4), xwa' -> '\\tld\\t(xsp + 4), xwa' (tab after the mnemonic)."""
    code = code.strip()
    p = code.split(None, 1)
    return b"\t" + p[0] + (b"\t" + p[1].strip() if len(p) > 1 else b"")


def translate(btext, bb, ba, ctx):
    t = btext.lower()
    op = t.split(None, 1)[0]
    if op in REL_OPS or (op in ("call", "jp") and ABS_RE.search(t)):
        tgt = int(ABS_RE.findall(t)[-1], 16)
        if not (BASE <= tgt < BASE + 0x80000):
            return None
        lab = ctx.make_label(tgt, ba) if tgt < CODE_END else ctx.label_at(tgt)
        if lab is None:
            return None
        args = t.split(None, 1)[1].split(",")
        cc = args[0].strip() if len(args) == 2 else None
        if op in ("jr", "jrl") and cc is None:
            cc = "t"
        if op == "jp" and cc == "t":
            cc = None
        return (b"\t%s\t%s%s" % (op.encode(), (cc + ", ").encode() if cc else b"", lab.encode()))
    cands = translate_candidates(btext, bb)
    enc = roundtrip_many(cands)
    for i, c in enumerate(cands):
        if enc.get(i) == bb:
            txt = c.encode()
            # symbolise ROM addresses
            for mm in reversed(list(re.finditer(rb'\b(0x[0-9a-f]+|\d+)\b', txt))):
                v = int(mm.group(1), 0)
                if BASE <= v < BASE + 0x80000:
                    lab = ctx.label_at(v)
                    if lab is None:
                        return None
                    txt = txt[:mm.start()] + lab.encode() + txt[mm.end():]
                elif 0x200000 <= v < 0x240000 and v in ctx.ram_names:
                    txt = txt[:mm.start()] + ctx.ram_names[v].encode() + txt[mm.end():]
                elif v >> 16 == 0x7f and v in ctx.obj_names:
                    txt = txt[:mm.start()] + ctx.obj_names[v].encode() + txt[mm.end():]
            return norm_insn(txt)
    return None


def widen_up(bld, f, n):
    """First line of the run of non-emitting lines (labels, comments) right above line n."""
    emitting = bld.emitting.setdefault(f, {ln for (ff, ln, s_, e_) in bld.lines if ff == f and e_ > s_})
    while n > 1 and (n - 1) not in emitting and not INC_RE.match(bld.text(f, n - 1)) \
            and not re.match(rb'^\s*\.(org|equ|set|section|text)\b', bld.text(f, n - 1)):
        n -= 1
    return n


PUSHW_RE = re.compile(rb'^\tpushw\t(0x[0-9a-fA-F]+|\d+)\s*$')


def lower_hex(t):
    code, comment = split_code(t)
    code = re.sub(rb'0x[0-9a-fA-F]+', lambda m: m.group(0).lower(), code)
    return code + comment


def farptr_pass(out, ctx):
    """Two `pushw` of a 32-bit pointer's halves (`0b lo hi`, high half first), as this
    tool wrote them -> `pushw Label@hi16` + `pushw Label@lo16`, read from the B bytes."""
    res = list(out)
    ref = ctx.ref
    u16 = lambda a: ref[a - BASE + 1] | (ref[a - BASE + 2] << 8)
    for k in range(len(res) - 1):
        a1, t1 = res[k]
        a2, t2 = res[k + 1]
        if a1 is None or a2 is None or a2 != a1 + 3:
            continue
        if ref[a1 - BASE] != 0x0b or ref[a2 - BASE] != 0x0b:
            continue
        if not (t1.strip().startswith(b"pushw") and t2.strip().startswith(b"pushw")):
            continue
        v = (u16(a1) << 16) | u16(a2)
        name = None
        if BASE <= v < BASE + 0x80000:
            name = ctx.label_at(v)
        elif 0x200000 <= v < 0x240000:
            name = ctx.ram_names.get(v)
        if name and (b"%s@lo16" % name.encode()) not in t2:
            res[k] = (a1, b"\tpushw\t%s@hi16" % name.encode())
            res[k + 1] = (a2, b"\tpushw\t%s@lo16\t\t; low half of %s" % (name.encode(), name.encode()))
    return [(a, lower_hex(t) if a is not None else t) for a, t in res]


def cmd_code(ver, only=None, dry=False):
    bld, ref, hs, full = cmd_status(ver, verbose=False, want_blocks=True)
    ctx = Ctx(bld, ref, full)
    wdec = {a: (bs, t) for a, bs, t in unidasm(bld.img, BASE)}
    templates = collections.defaultdict(list)
    for k, (f, n, s, e) in enumerate(bld.lines):
        if e > s and s in wdec and len(wdec[s][0]) == e - s and is_insn(bld.text(f, n)):
            key = shape(wdec[s][1]) + "/%d" % (e - s)
            if len(templates[key]) < 12:
                templates[key].append(k)
    plans, eqs, skipped, preps = [], {}, [], []
    # pass 1: align every code hunk, and learn where its existing labels land in B
    for idx, h in enumerate(hs):
        if only is not None and idx not in only:
            continue
        (w0, w1, b0, b1), li = expand(bld, h)
        if not li:
            continue
        files = {bld.lines[k][0] for k in li}
        if len(files) != 1 or not all(is_insn(bld.text(bld.lines[k][0], bld.lines[k][1])) for k in li):
            continue
        f = bld.lines[li[0]][0]
        bins = unidasm(ref[b0 - BASE:b1 - BASE], b0)
        if sum(len(x[1]) for x in bins) != b1 - b0 or any(x[2].startswith("db ") for x in bins):
            skipped.append((idx, "target does not decode"))
            continue
        wins, ok = [], True
        for k in li:
            _, n, s, e = bld.lines[k]
            d = wdec.get(s)
            if not d or len(d[0]) != e - s:
                ok = False
                break
            wins.append((n, s, bld.img[s - BASE:e - BASE], d[1]))
        if not ok:
            skipped.append((idx, "source line is not one instruction"))
            continue
        n_first, n_last = widen_up(bld, f, wins[0][0]), wins[-1][0]
        pre, cur, at = {}, [], {w[0]: i for i, w in enumerate(wins)}
        body = {}
        for n in range(n_first, n_last + 1):
            t = bld.text(f, n)
            if n in at:
                lab = label_of(t)
                if lab:
                    cur.append(lab.encode() + b":")
                    t = re.sub(rb'^(?:\.L)?[A-Za-z_]\w*:\s*', b"\t", t)
                pre[at[n]], cur = cur, []
                body[at[n]] = t
            else:
                cur.append(t)
        sm = difflib.SequenceMatcher(None, [shape(w[3]) for w in wins], [shape(b[2]) for b in bins],
                                     autojunk=False)
        opc = sm.get_opcodes()
        for tag, i1, i2, j1, j2 in opc:
            for i in range(i1, i2):
                j = j1 + (i - i1) if tag == "equal" else j1
                if j < len(bins):
                    for x in pre[i]:
                        lab = label_of(x)
                        if lab:
                            ctx.bmap.setdefault(bins[j][0], lab)
        preps.append((idx, f, b0, b1, bins, wins, pre, body, opc))
    # pass 2: spell the target instructions
    for idx, f, b0, b1, bins, wins, pre, body, opc in preps:
        out, ok, heq = [], True, {}
        n_first, n_last = widen_up(bld, f, wins[0][0]), wins[-1][0]

        def emit_b(j, self_i=None):
            ba, bb, bt = bins[j]
            if self_i is not None:
                line, wb = body[self_i], wins[self_i][2]
                r = retarget(line, wb, bb, ctx.equs, bld.symaddr)
                if r is not None:
                    heq.update(r[1])
                    return r[0]
                t = transplant(line, wb, bb, bt, ba, ctx, keep_comment=True)
                if t is not None:
                    return t
            for k in templates.get(shape(bt) + "/%d" % len(bb), []):
                tf, tn, ts, te = bld.lines[k]
                t = transplant(bld.text(tf, tn), bld.img[ts - BASE:te - BASE], bb, bt, ba, ctx)
                if t is not None:
                    return norm_insn(t)
            return translate(bt, bb, ba, ctx)
        for tag, i1, i2, j1, j2 in opc:
            if tag == "equal":
                for i, j in zip(range(i1, i2), range(j1, j2)):
                    out += [(None, x) for x in pre[i]]
                    if wins[i][2] == bins[j][1]:
                        out.append((bins[j][0], body[i]))
                        continue
                    t = emit_b(j, i)
                    if t is None:
                        ok = False
                        break
                    out.append((bins[j][0], t))
            else:
                for i in range(i1, i2):
                    out += [(None, x) for x in pre[i] if label_of(x) or x.strip().startswith(b";")]
                for j in range(j1, j2):
                    t = emit_b(j)
                    if t is None:
                        ok = False
                        break
                    out.append((bins[j][0], t))
            if not ok:
                break
        if not ok:
            skipped.append((idx, "an instruction could not be spelled: %s @%06x" % (bins[j][2], bins[j][0])))
            continue
        plans.append((f, n_first, n_last, out, idx, b0, b1))
        for name, v in heq.items():
            eqs[name] = v
    for p in plans:
        p[3][:] = farptr_pass(p[3], ctx)
    # place the labels created this round
    inserts = collections.defaultdict(list)      # (file, line) -> label lines to insert before
    unplaced = []
    for b, name in ctx.new_labels.items():
        placed = False
        for p in plans:
            for k, (ba, t) in enumerate(p[3]):
                if ba == b:
                    p[3].insert(k, (None, name.encode() + b":"))
                    placed = True
                    break
            if placed:
                break
        if placed:
            continue
        w = ctx.w_of_b(b)
        line = None
        if w is not None:
            k = bisect.bisect_left(bld.starts, w)
            if k < len(bld.starts) and bld.starts[k] == w:
                line = bld.lines[bld.byaddr[k][1]]
        if line is None:
            unplaced.append((b, name))
            continue
        inserts[(line[0], line[1])].append(name.encode() + b":")
    if unplaced:
        bad = {n for _, n in unplaced}
        print("labels with no place yet (their users are left for a later round): %s" %
              ", ".join("%s@%06x" % (n, b) for b, n in unplaced[:10]))
        plans = [p for p in plans if not any(any(x in t for x in (n.encode() for n in bad))
                                             for _, t in p[3])]
    print("code hunks: %d rewritten, %d skipped; %d labels created" %
          (len(plans), len(skipped), len(ctx.new_labels) - len(unplaced)))
    for idx, why in skipped[:40]:
        print("  skipped hunk %d: %s" % (idx, why))
    if dry:
        for p in plans:
            print("--- hunk %d %s:%d-%d" % (p[4], p[0], p[1], p[2]))
            for ba, t in p[3]:
                print("   %s %s" % ("%06x" % ba if ba else "      ", t.decode("latin-1")))
        return
    ed = Edits(bld.tree)
    for name, v in eqs.items():             # first: these keep every line number
        if name in ctx.equs and ctx.equs[name][0] != v:
            ed.set_equ(ctx.equs[name][1], ctx.equs[name][2], v)
    # then the replacements, bottom-up per file so line numbers stay valid
    ops = [(f, n0, n1, [t for _, t in out]) for f, n0, n1, out, *_ in plans]
    ops += [(f, n, n - 1, lbls) for (f, n), lbls in inserts.items()]
    for f, n0, n1, new in sorted(ops, key=lambda o: (o[0], -o[1], -(o[2] - o[1]))):
        ls = ed.lines(f)
        ls[n0 - 1:n1] = new
    ed.write()


# --------------------------------------------------------------------------- string hunks

STR_LINE = re.compile(rb'^\s*(?:(?:\.L)?[A-Za-z_]\w*:\s*)?\.(asciz|ascii)\s+"((?:[^"\\]|\\.)*)"')
PAD_LINE = re.compile(rb'^\s*\.balign\s+2\s*,\s*0x0*0\b')


def unesc(s):
    out, k = bytearray(), 0
    while k < len(s):
        c = s[k]
        if c == 0x5C:
            n = s[k + 1]
            if 0x30 <= n <= 0x37:
                j = k + 1
                while j < len(s) and j < k + 4 and 0x30 <= s[j] <= 0x37:
                    j += 1
                out.append(int(s[k + 1:j], 8) & 0xff)
                k = j
                continue
            out.append({0x6e: 10, 0x74: 9, 0x72: 13, 0x30: 0}.get(n, n))
            k += 2
        else:
            out.append(c)
            k += 1
    return bytes(out)


def str_sym(bs):
    """label fragment for a string (scripts/generators/gen_hdae5000_rodata.py's sym())"""
    ws = re.findall(r"[A-Za-z0-9]+", bs.decode("latin-1"))
    if ws:
        return "".join(w.capitalize() if not w.isupper() else w for w in ws)[:28]
    if not bs:
        return "Empty"
    if all(c in (0x20, 0x09) for c in bs):
        return "Blank%d" % bs.count(0x20) + ("Tab" if 0x09 in bs else "")
    return "Chr" + "".join("%02X" % c for c in bs[:6])


def string_label(bs, used):
    if re.search(rb"%[-+ #0-9.]*l?[sdiuxXcfeEgG]", bs):
        core = re.sub(r"[^A-Za-z0-9]+", "_", bs.decode("latin-1")).strip("_")
        base = "HDAE5000_Fmt_" + (core or "Pct")[:24]
    else:
        base = "HDAE5000_Str_" + str_sym(bs)
    n, k = base, 2
    while n in used:
        n = "%s_%d" % (base, k)
        k += 1
    used.add(n)
    return n


def cmd_strings(ver, only=None, dry=False, tag="v2.01i"):
    bld, ref, hs, full = cmd_status(ver, verbose=False, want_blocks=True)
    used = set(bld.symaddr) | set(read_equs(bld))
    plans = []
    for idx, h in enumerate(hs):
        if only is not None and idx not in only:
            continue
        (w0, w1, b0, b1), li = expand(bld, h)
        if not li or len({bld.lines[k][0] for k in li}) != 1:
            continue
        f = bld.lines[li[0]][0]
        n_first, n_last = widen_up(bld, f, bld.lines[li[0]][1]), bld.lines[li[-1]][1]
        items, ok = [], True
        emit = {bld.lines[k][1]: k for k in li}
        pre = []
        for n in range(n_first, n_last + 1):
            t = bld.text(f, n)
            if n in emit:
                m = STR_LINE.match(t)
                if m:
                    body = unesc(m.group(2)) + (b"\0" if m.group(1) == b"asciz" else b"")
                    _, _, s_, e_ = bld.lines[emit[n]]
                    if bld.img[s_ - BASE:e_ - BASE] != body:
                        ok = False
                        break
                    items.append(("s", body, pre, t))
                elif PAD_LINE.match(t):
                    items.append(("p", b"\0", pre, t))
                else:
                    ok = False
                    break
                pre = []
            else:
                pre.append(t)
        if not ok or not items:
            continue
        # target items
        bi, p = [], b0
        while p < b1:
            if ref[p - BASE] == 0 and p % 2 == 1 and (bi[-1][0] == "s" if bi else ref[p - BASE - 1] == 0):
                bi.append(("p", b"\0", p))
                p += 1
                continue
            z = ref.find(b"\0", p - BASE, b1 - BASE)
            if z < 0:
                ok = False
                break
            bi.append(("s", ref[p - BASE:z + 1], p))
            p = z + BASE + 1
        if not ok:
            continue
        sm = difflib.SequenceMatcher(None, [(k, c) for k, c, _, _ in items], [(k, c) for k, c, _ in bi],
                                     autojunk=False)
        out = []
        for op, i1, i2, j1, j2 in sm.get_opcodes():
            if op == "equal":
                for i in range(i1, i2):
                    out += items[i][2] + [items[i][3]]
                continue
            orphan = []
            for i in range(i1, i2):
                inl = label_of(items[i][3])
                if inl:
                    items[i][2].append(inl.encode() + b":")
                for x in items[i][2]:
                    if label_of(x):
                        orphan.append(x.split(b";")[0].rstrip() + b"\t; PORT-ORPHAN: its %s object is gone" % tag.encode())
                    elif x.strip().startswith(b"; read by") or x.strip().startswith(b"; caption"):
                        continue
                    else:
                        out.append(x)
            out += orphan
            for j in range(j1, j2):
                k, c, a = bi[j]
                if k == "p":
                    out.append(b"\t.balign 2, 0x00                       ; word-align pad")
                    continue
                name = string_label(c[:-1], used)
                out.append(name.encode() + b":")
                out.append(b"\t; only in %s" % tag.encode())
                out.append(b'\t.asciz "' + esc(c[:-1]) + b'"')
        plans.append((f, n_first, n_last, out, idx))
    print("string hunks: %d rewritten" % len(plans))
    if dry:
        for f, n0, n1, out, idx in plans:
            print("--- hunk %d %s:%d-%d" % (idx, f, n0, n1))
            for t in out:
                print("   " + t.decode("latin-1"))
        return
    ed = Edits(bld.tree)
    for f, n0, n1, new, idx in sorted(plans, key=lambda o: (o[0], -o[1])):
        ed.lines(f)[n0 - 1:n1] = new
    ed.write()


# --------------------------------------------------------------------------- UI object tables

# record length before the caption arena (22-byte header + class body) and the caption
# slots, per class: the v2.06i pool header's table (hdae5000/hdae5000_data_tables.s,
# scripts/generators/gen_hdae5000_ui_pool.py), which every version's pool must obey
UI_F = {(0x0160, 0x10): 22, (0x0160, 0x12): 36, (0x0160, 0x1B): 58, (0x0160, 0x1C): 42,
        (0x0160, 0x1F): 40, (0x0160, 0x20): 44, (0x0160, 0x22): 42, (0x0160, 0x26): 40,
        (0x0160, 0x28): 28, (0x0160, 0x29): 26, (0x0160, 0x2B): 32, (0x0160, 0x2D): 26,
        (0x0160, 0x2E): 26, (0x0160, 0x30): 40, (0x0160, 0x33): 34, (0x0160, 0x35): 36,
        (0x0160, 0x36): 40, (0x0160, 0x37): 38, (0x0160, 0x3D): 50, (0x0160, 0x3E): 44,
        (0x0160, 0x3F): 46, (0x0160, 0x41): 54, (0x0160, 0x46): 22, (0x0160, 0x49): 26,
        (0x0160, 0x4B): 36, (0x0160, 0x4C): 64, (0x0160, 0x4D): 26, (0x0160, 0x52): 26,
        (0x0160, 0x69): 26, (0x016A, 0x0): 60, (0x016A, 0x1): 26, (0x016A, 0x2): 42,
        (0x016A, 0x3): 36, (0x016A, 0x4): 26, (0x016A, 0x6): 42, (0x016A, 0x7): 42,
        (0x016A, 0x8): 36, (0x016A, 0x9): 34, (0x016A, 0xA): 42, (0x016A, 0xB): 46,
        (0x016A, 0xC): 32}
UI_CAP = {(0x0160, 0x1B): [0x1C], (0x0160, 0x26): [0x1E, 0x1A], (0x0160, 0x2B): [0x16],
          (0x0160, 0x30): [0x16], (0x0160, 0x36): [0x1A], (0x0160, 0x37): [0x1A],
          (0x0160, 0x3D): [0x2A], (0x0160, 0x3E): [0x28], (0x0160, 0x3F): [0x2A],
          (0x0160, 0x41): [0x2A], (0x016A, 0x2): [0x22], (0x016A, 0x6): [0x22],
          (0x016A, 0x7): [0x22]}
# strings the init image cites that live inside pool records (hdae5000_init_data.s)
UI_CITED = {b"! HD FORMAT !": "HDAE5000_Str_Alert_HDFormat"}
UI_CHARSET = ["HDAE5000_Str_CharSet_Upper_1", "HDAE5000_Str_CharSet_Upper_2",
              "HDAE5000_Str_CharSet_Lower_1", "HDAE5000_Str_CharSet_Lower_2",
              "HDAE5000_Str_CharSet_Symbol_1", "HDAE5000_Str_CharSet_Symbol_2"]


def ui_tables_of(R):
    """(ptrtab, nametab, nobj): the operands of the two RegisterObjectTable calls for
    tables 0x7F / 0x37F in HDAE5000_Handler_Registration (ldw (xsp+8),n ...
    lda xwa,(T:24) ... ld wa,0x7f / 0x37f)."""
    head = R[:0x400]
    out = {}
    for wa in (0x007f, 0x037f):
        k = head.find(bytes([0x30, wa & 0xff, wa >> 8]))
        j = head.rfind(b"\xf2", 0, k)
        while head[j + 4] != 0x30:
            j = head.rfind(b"\xf2", 0, j)
        t = int.from_bytes(head[j + 1:j + 4], "little")
        c = head.rfind(b"\xbf\x08\x02", 0, j)
        n = int.from_bytes(head[c + 3:c + 5], "little")
        out[wa] = (t, n)
    assert out[0x7f][1] == out[0x37f][1]
    return out[0x7f][0], out[0x37f][0], out[0x7f][1]


def ui_generate(R, classtab):
    u16 = lambda a: int.from_bytes(R[a - BASE:a - BASE + 2], "little")
    u32 = lambda a: int.from_bytes(R[a - BASE:a - BASE + 4], "little")

    def cstr(a):
        b = R[a - BASE:]
        return b[:b.index(0)]
    ptrtab, nametab, nobj = ui_tables_of(R)
    ptr = [u32(ptrtab + 4 * i) for i in range(nobj)]
    if u32(ptrtab + 4 * nobj) != 0:
        sys.exit("REFUSED: no NULL after %d object pointers" % nobj)
    nptr = [u32(nametab + 4 * i) for i in range(nobj + 1)]
    names = [cstr(a).decode("latin-1") if a else "" for a in nptr]
    idx = [i for i, p in enumerate(ptr) if BASE <= p < BASE + 0x80000]
    S = [ptr[i] for i in idx]
    if any(S[k] >= S[k + 1] for k in range(len(S) - 1)) or S[-1] >= ptrtab:
        sys.exit("REFUSED: pool pointers do not ascend below the pointer table")
    pool, pool_end = S[0], ptrtab
    E = S[1:] + [pool_end]
    cls = {}
    for k in range(13):
        a = u32(classtab + 4 * k)
        cls[k] = cstr(a).decode("latin-1") if BASE <= a < BASE + 0x80000 else ""
    recs = []
    for i, s_, e_ in zip(idx, S, E):
        c = (u16(s_ + 2), u16(s_))
        if c not in UI_F:
            sys.exit("REFUSED: record #%d class %04X:%04X not in the class table" % (i, c[0], c[1]))
        recs.append(dict(i=i, s=s_, e=e_, c=c))
    bycls = collections.defaultdict(list)
    for r in recs:
        bycls[r["c"]].append(r)
    ram = {}
    for c, L in bycls.items():
        f, slots, off = UI_F[c], [], 0x16
        while off + 4 <= f:
            if off in UI_CAP.get(c, []):
                off += 4
                continue
            if all(0x200000 <= u32(r["s"] + off) < 0x240000 for r in L):
                slots.append(off)
                off += 4
            else:
                off += 2
        ram[c] = slots
    out = []
    for r in recs:
        s_, e_, c, i = r["s"], r["e"], r["c"], r["i"]
        f = UI_F[c]
        lab = "HdaeUiObj_%03d" % i
        par = u16(s_ + 4)
        cname = ('ClassName_Table[%d] "%s"' % (c[1], cls.get(c[1], "?"))) if c[0] == 0x016A \
            else "KN5000 widget type 0x%02X" % c[1]
        nm = ('"%s"' % names[i]) if names[i] else "(unnamed)"
        pn = ("#%d%s" % (par, (" " + names[par]) if par < len(names) and names[par] else "")) \
            if par != 0xFFFF else "none (root)"
        out.append("\t; [#%d] %s  class %04X:%04X = %s, %d bytes, parent %s,"
                   % (i, nm, c[0], c[1], cname, e_ - s_, pn))
        out.append("\t; box %d,%d-%d,%d." % (u16(s_ + 0x0E), u16(s_ + 0x10), u16(s_ + 0x12), u16(s_ + 0x14)))
        out.append(lab + ":")
        out.append("\t.long\t0x%08x\t\t\t\t; +0x00 class id" % u32(s_))
        out.append("\t.short\t%s\t; +0x04 parent, first child, next, previous"
                   % ", ".join(("0xffff" if u16(s_ + o) == 0xFFFF else "%d" % u16(s_ + o))
                               for o in (4, 6, 8, 10)))
        out.append("\t.short\t0x%04x\t\t\t\t\t; +0x0C attribute word" % u16(s_ + 0x0C))
        out.append("\t.short\t%d, %d, %d, %d\t\t\t; +0x0E box x1, y1, x2, y2"
                   % tuple(u16(s_ + o) for o in (0x0E, 0x10, 0x12, 0x14)))
        caps = {}
        for off in UI_CAP.get(c, []):
            t = u32(s_ + off)
            if not (s_ + f <= t < e_):
                sys.exit("REFUSED: #%d caption slot +0x%02X points outside its record" % (i, off))
            caps[off] = t
        charset = None
        if c == (0x0160, 0x4C):
            charset = [R[s_ - BASE + o:s_ - BASE + o + 4] for o in range(0x28, 0x40, 4)]
            if not all(x[3] == 0 and all(0x20 < ch < 0x7f for ch in x[:3]) for x in charset):
                charset = None
        off, words = 0x16, []

        def flush():
            if words:
                out.append("\t.short\t%s\t; +0x%02X class body" % (", ".join(w[1] for w in words), words[0][0]))
                words.clear()
        while off < f:
            if off in caps:
                flush()
                out.append("\t.long\t%s_Cap%02X\t\t\t; +0x%02X caption pointer" % (lab, off, off))
                off += 4
            elif off in ram[c]:
                flush()
                out.append("\t.long\t0x%08x\t\t\t\t; +0x%02X RAM address (every %04X:%04X record)"
                           % (u32(s_ + off), off, c[0], c[1]))
                off += 4
            elif charset and 0x28 <= off < 0x40:
                flush()
                k = (off - 0x28) // 4
                out.append("%s:\t.ascii\t\"%s\"\t\t\t; +0x%02X caption of a RAM naming soft key"
                           % (UI_CHARSET[k], esc(charset[k]).decode("latin-1"), off))
                off += 4
            else:
                words.append((off, "0x%04x" % u16(s_ + off)))
                if len(words) == 8:
                    flush()
                off += 2
        flush()
        a = s_ + f
        targets = {t: o for o, t in caps.items()}
        while a < e_:
            if a % 2:
                if R[a - BASE] != 0:
                    sys.exit("REFUSED: #%d odd-address pad byte not 0" % i)
                out.append("\t.balign\t2, 0x00\t\t\t\t\t; word-align pad")
                a += 1
                continue
            z = R.index(0, a - BASE) + BASE
            if z >= e_:
                sys.exit("REFUSED: #%d caption arena not NUL-terminated" % i)
            txt = R[a - BASE:z - BASE]
            if a in targets:
                name = "%s_Cap%02X" % (lab, targets[a])
                out.append("\t; caption of %s: the record's +0x%02X caption pointer names this string"
                           % (lab, targets[a]))
            elif txt in UI_CITED:
                name = UI_CITED[txt]
                out.append("\t; not pointed at from this record: a RAM object's caption, cited by the init image")
            else:
                name = "%s_Str%02X" % (lab, a - s_)
                out.append("\t; not pointed at from this record")
            out.append("%s:\t.asciz\t\"%s\"" % (name, esc(txt).decode("latin-1")))
            a = z + 1
        out.append("")
    return dict(ptrtab=ptrtab, nametab=nametab, nobj=nobj, ptr=ptr, nptr=nptr, names=names,
                pool=pool, pool_end=pool_end, recs=recs, lines=out)


def ui_name_pool(R, g):
    """The object-name strings, in address order, labelled by object index."""
    by = collections.defaultdict(list)
    for i, a in enumerate(g["nptr"]):
        by[a].append(i)
    addrs = sorted(by)
    end = addrs[-1] + len(R[addrs[-1] - BASE:].split(b"\0")[0]) + 1
    out = []
    for k, a in enumerate(addrs):
        nxt = addrs[k + 1] if k + 1 < len(addrs) else end
        bs = R[a - BASE:nxt - BASE]
        labs = ["HdaeUiName_%03d" % i for i in sorted(by[a], reverse=True)]
        for extra in labs[:-1]:
            out.append(extra + ":")
        if not any(bs):
            body = ".zero\t%d" % len(bs)
        elif bs.index(0) == len(bs) - 1:
            body = '.asciz\t"%s"' % esc(bs[:-1]).decode("latin-1")
        else:
            body = '.ascii\t"%s"' % esc(bs).decode("latin-1").replace("\\000", "\\0")
        i = by[a][0]
        out.append("%s:\t%-32s; [%3d]%s" % (labs[-1], body, i, "" if g["names"][i] else " (unnamed)"))
    return out, end


def find_classtab(R):
    """The class-name table: its first entry points at "SelectListProc" and at least
    eight entries in a row point at NUL-terminated names ending in "Proc"."""
    t = R.find(b"SelectListProc\0")
    if t < 0:
        return None
    ptr = (t + BASE).to_bytes(4, "little")
    k = R.find(ptr)
    while k >= 0:
        n = 0
        while n < 13:
            a = int.from_bytes(R[k + 4 * n:k + 4 * n + 4], "little")
            if not (BASE <= a < BASE + 0x80000) or not R[a - BASE:].split(b"\0", 1)[0].endswith(b"Proc"):
                break
            n += 1
        if n >= 8:              # v2.x: 13 classes; older versions have fewer
            return k + BASE
        k = R.find(ptr, k + 1)
    return None


def cmd_uitables(ver, tag="v2.01i"):
    bld, ref, hs, full = cmd_status(ver, verbose=False, want_blocks=True)
    ctx = Ctx(bld, ref, full)
    inv = {n: b for b, n in ctx.bmap.items()}
    classtab = inv.get("HDAE5000_ClassName_Table") or find_classtab(ref)
    if classtab is None:
        sys.exit("HDAE5000_ClassName_Table not found in the target")
    g = ui_generate(ref, classtab)
    pool_text, name_end = ui_name_pool(ref, g)
    names = g["names"]
    A = open(os.path.join(ROOT, "original_ROMs", "hd-ae5000_v2_06i.ic4"), "rb").read()
    ga = ui_generate(A, 0x2F9832)

    def sig(G, R, i):
        p = G["ptr"][i]
        if not (BASE <= p < BASE + 0x80000):
            return (G["names"][i], b"ram")
        return (G["names"][i], R[p - BASE:p - BASE + 4] + R[p - BASE + 0x0C:p - BASE + 0x16])
    sm = difflib.SequenceMatcher(None, [sig(ga, A, i) for i in range(ga["nobj"])],
                                 [sig(g, ref, i) for i in range(g["nobj"])], autojunk=False)
    diffs = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op != "equal":
            diffs.append(";   v2.06i #%s -> %s #%s (%s)" % (
                ("%d-%d" % (i1, i2 - 1)) if i2 > i1 else "-", tag,
                ("%d-%d" % (j1, j2 - 1)) if j2 > j1 else "-", op))
    nram = sum(1 for p in g["ptr"] if not (BASE <= p < BASE + 0x80000))
    rule = "; " + "=" * 77
    hdr = [rule,
           "; HD-AE5000 UI OBJECT DESCRIPTOR POOL  (0x%06X - 0x%06X, %d bytes) -- %s" % (
               g["pool"], g["pool_end"] - 1, g["pool_end"] - g["pool"], tag),
           rule,
           "; %d variable-length records, one per HDAE5000_UiObject_PtrTable entry that" % len(g["recs"]),
           "; points into ROM, split exactly at those pointers; the other %d objects keep their" % nram,
           "; descriptor in RAM (HDAE5000_WindowGeometry_Init).  The record format is the one",
           "; documented, with its evidence, in the v2.06i tree's header of this block",
           "; (hdae5000/hdae5000_data_tables.s): +0x00 class id, +0x04 parent / first child /",
           "; next / previous object index, +0x0C attribute word, +0x0E bounding box, then a",
           "; class body of fixed length and an optional caption arena.  Labels and record",
           "; numbers here are %s object indices; the id the main CPU uses is 0x007F0000 + n." % tag,
           ";",
           "; Generated from the %s image by scripts/tools/port_hdae5000_version.py uitables." % tag,
           "; Against v2.06i, aligned by object name, class, attribute word and box",
           "; (link fields left out, since they hold indices):"] + diffs + [rule, ""]
    obj_rows = []
    for i, p in enumerate(g["ptr"]):
        nm = names[i] or "(unnamed)"
        if BASE <= p < BASE + 0x80000:
            obj_rows.append("\t.long\tHdaeUiObj_%03d        ; [%3d] %s" % (i, i, nm))
        else:
            obj_rows.append("\t.long\t0x%08x        ; [%3d] %s (descriptor in RAM)" % (p, i, nm))
    obj_rows.append("\t.long\t0x00000000        ; [%3d] end-of-table marker" % g["nobj"])
    equs = ["\t.equ HDAE5000_OBJ_%s, 0x007f%04x" % (nm, i) for i, nm in enumerate(names[:g["nobj"]]) if nm]
    name_rows = ['\t.long\tHdaeUiName_%03d                    ; [%3d] %s' % (
        i, i, ('"%s"' % names[i]) if names[i] else "(unnamed)") for i in range(g["nobj"] + 1)]
    tables = [rule,
              "; HD-AE5000 UI OBJECT TABLE (0x%06X - 0x%06X) -- %s" % (
                  g["ptrtab"], g["ptrtab"] + 4 * g["nobj"] + 3, tag),
              rule,
              "; %d pointers to UI object descriptors and a NULL: object table 0x7F, registered" % g["nobj"],
              "; by HDAE5000_Handler_Registration (class id 0x01600010, RootFn_ViewableProc,",
              "; entry count %d).  Index-parallel with HDAE5000_UiObjectName_PtrTable." % g["nobj"],
              rule, "",
              "HDAE5000_UiObject_PtrTable:"] + obj_rows + [
              "", ";",
              "; UI object ids: 0x007F0000 + n, n = the index above; one constant per named object.",
              ";"] + equs + [
              "", rule,
              "; HD-AE5000 UI OBJECT NAME TABLE (0x%06X - 0x%06X) -- %s" % (
                  g["nametab"], g["nametab"] + 4 * g["nobj"] + 3, tag),
              rule,
              "; %d pointers into HDAE5000_UiObjectName_Pool: object table 0x37F (class id" % (g["nobj"] + 1),
              "; 0x0160000F, RootFn_ResNameProc).  The last slot pairs with the NULL above.",
              rule, "",
              "HDAE5000_UiObjectName_PtrTable:"] + name_rows + [
              "", rule,
              "; HD-AE5000 UI OBJECT NAME POOL (0x%06X - 0x%06X) -- %s" % (min(g["nptr"]), name_end - 1, tag),
              rule,
              "; In ascending address order, i.e. descending object index (the toolchain",
              "; emitted the literals in reverse order).",
              rule, "",
              "HDAE5000_UiObjectName_Pool:"] + pool_text
    f = "hdae5000_data_tables.s"
    ed = Edits(bld.tree)
    L = ed.lines(f)
    k0 = next(k for k, l in enumerate(L) if l.startswith(b"; HD-AE5000 UI OBJECT DESCRIPTOR POOL"))
    k0 -= 1                                 # its '; ====' rule
    k1 = next(k for k, l in enumerate(L) if re.match(rb"^HdaeUiName_000:", l))
    new = [x.encode("latin-1") for x in hdr + g["lines"] + tables]
    L[k0:k1 + 1] = new
    f2 = "hdae5000_init_data.s"
    L2 = ed.lines(f2)
    a0 = next((k for k, l in enumerate(L2) if b"Strings cited by the run-time state block" in l), None)
    a1 = next((k for k, l in enumerate(L2) if l.lstrip().startswith(b".set HDAE5000_Str_CharSet_Symbol_2")), None)
    if a0 is not None and a1 is not None:
        L2[a0:a1 + 1] = [
            b"\t; HDAE5000_Str_Alert_HDFormat and the six HDAE5000_Str_CharSet_* strings this",
            b"\t; state block cites are labels inside UI object records of the descriptor pool",
            b"\t; (hdae5000_data_tables.s): the captions of the RAM objects SW_HD_FORMAT and",
            b"\t; HddNamingABC / abc / Symbol, stored in the records of their ROM neighbours."]
    ed.write()
    print("wrote %d records, %d objects (%d in RAM), %d named; %d lines replace %d" % (
        len(g["recs"]), g["nobj"], nram, len(equs), len(new), k1 + 1 - k0))
    for d in diffs:
        print(d)


# --------------------------------------------------------------------------- far pointers

FAR_HI = re.compile(rb'^(\s*)pushw(\s+)(\.?[A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(@hi16)?(.*)$')
FAR_LO = re.compile(rb'^(\s*)pushw(\s+)(\.?[A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(@lo16)?(.*)$')


def cmd_farptrs(ver, dry=False):
    """Every `pushw hi` + `pushw lo` pair whose 32 bits are a ROM address (or a named
    RAM variable) is spelled `pushw Label@hi16` / `pushw Label@lo16` with the label
    the build puts at that address.  Bytes cannot check this: the high half of any
    label in the same 64 KiB assembles alike, so a ported tree may name the wrong one."""
    bld = do_build(ver)
    assert bld.ok
    img = bld.img
    by = collections.defaultdict(list)
    for a, n in bld.syms:
        if not n.startswith("__PM_"):
            by[a].append(n)
    equs = read_equs(bld)
    ram = {v: n for n, (v, f, l) in equs.items() if n.startswith("HDAE5000_RAM_")}
    ed = Edits(bld.tree)
    changed = unresolved = 0
    for k, (f, n, s, e) in enumerate(bld.lines):
        if e - s != 3 or img[s - BASE] != 0x0b:
            continue
        nxt = k + 1
        while nxt < len(bld.lines) and bld.lines[nxt][3] == bld.lines[nxt][2]:
            nxt += 1
        if nxt >= len(bld.lines):
            continue
        f2, n2, s2, e2 = bld.lines[nxt]
        if f2 != f or s2 != e or e2 - s2 != 3 or img[s2 - BASE] != 0x0b:
            continue
        t1, t2 = ed.lines(f)[n - 1], ed.lines(f)[n2 - 1]
        m1, m2 = FAR_HI.match(t1), FAR_LO.match(t2)
        if not (m1 and m2):
            continue
        if not (m1.group(4) or m2.group(4)):
            # two plain word pushes: only a pair spelled as halves already, or a
            # numeric high half 0x0028-0x002f / 0x0020-0x0023, is a pointer
            # a plain pair is taken for a pointer only into ROM (high half 0x0028-0x002f):
            # a RAM-looking pair can as well be two small arguments (`pushw 0x20` =
            # a count of 32, `pushw 0` = a fill byte), and v2.06i spells RAM pointers
            # numerically anyway
            hi = int.from_bytes(img[s - BASE + 1:s - BASE + 3], "little")
            if not (re.fullmatch(rb'0x[0-9a-fA-F]+|\d+', m1.group(3)) and 0x28 <= hi <= 0x2f):
                continue
        v = (int.from_bytes(img[s - BASE + 1:s - BASE + 3], "little") << 16) | \
            int.from_bytes(img[s2 - BASE + 1:s2 - BASE + 3], "little")
        names = by.get(v) if BASE <= v < BASE + 0x80000 else ([ram[v]] if v in ram else None)
        if not names:
            unresolved += 1
            print("  no label at 0x%06x: %s:%d %s / %s" % (v, f, n, t1.decode("latin-1").strip(),
                                                         t2.decode("latin-1").strip()))
            continue
        cur = m1.group(3).decode()
        name = cur if cur in names else names[0]
        if name.startswith("__PM_"):
            continue
        new1 = m1.group(1) + b"pushw" + m1.group(2) + name.encode() + b"@hi16" + m1.group(5)
        c2 = m2.group(5)
        if b"low half of" in c2 or not c2.strip():
            c2 = b"\t\t; low half of " + name.encode()
        new2 = m2.group(1) + b"pushw" + m2.group(2) + name.encode() + b"@lo16" + c2
        if (new1, new2) != (t1, t2):
            changed += 1
            ed.set(f, n, new1)
            ed.set(f2, n2, new2)
    print("far pointers: %d pairs respelled, %d without a label" % (changed, unresolved))
    if not dry:
        ed.write()


def cmd_show(ver, idx, ctx=2):
    bld, ref, hs = cmd_status(ver, verbose=False)
    (w0, w1, b0, b1), li = expand(bld, hs[idx])
    print("hunk %d: W %06x-%06x (%d B)  B %06x-%06x (%d B)" % (idx, w0, w1, w1 - w0, b0, b1, b1 - b0))
    if li:
        f, n0 = bld.lines[li[0]][0], bld.lines[li[0]][1]
        n1 = bld.lines[li[-1]][1]
        print("--- source %s:%d-%d" % (f, n0, n1))
        rows = {bld.lines[k][1]: bld.lines[k] for k in li}
        for n in range(max(1, n0 - ctx), n1 + ctx + 1):
            if n > len(bld.texts[f]):
                break
            t = bld.text(f, n).decode("latin-1")
            if n in rows:
                _, _, s, e = rows[n]
                print("%5d %06x %-24s %s" % (n, s, bld.img[s - BASE:e - BASE].hex(" ")[:24], t))
            else:
                print("%5d %6s %-24s %s" % (n, "", "", t))
    print("--- target")
    code = li and all(is_insn(bld.text(bld.lines[k][0], bld.lines[k][1])) for k in li)
    if code or "--code" in sys.argv:
        for a, bs, t in unidasm(ref[b0 - BASE:b1 - BASE], b0):
            print("      %06x %-24s %s" % (a, bs.hex(" ")[:24], t))
    else:
        for a in range(b0, b1, 16):
            bs = ref[a - BASE:min(a + 16, b1) - BASE]
            print("      %06x %-48s %s" % (a, bs.hex(" "), "".join(
                chr(c) if 0x20 <= c < 0x7f else "." for c in bs)))


def cmd_init(ver):
    dst = tree_of(ver)
    if os.path.exists(dst):
        sys.exit("%s exists" % dst)
    src = os.path.join(ROOT, SRC_TREE)
    os.makedirs(dst)
    for f in sorted(os.listdir(src)):
        if f.endswith(".s") or f.endswith(".ld"):
            shutil.copy(os.path.join(src, f), os.path.join(dst, main_of(ver) if f == SRC_MAIN else f))
    print("copied %s -> %s" % (src, dst))


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    cmd, ver = a[0], a[1]
    if cmd == "init":
        cmd_init(ver)
    elif cmd == "status":
        cmd_status(ver)
    elif cmd == "fix":
        rounds = int(a[a.index("--rounds") + 1]) if "--rounds" in a else 20
        cmd_fix(ver, rounds)
    elif cmd == "code":
        only = [int(x) for x in a[2:] if x.isdigit()] or None
        cmd_code(ver, only, dry="--dry" in a)
    elif cmd == "strings":
        only = [int(x) for x in a[2:] if x.isdigit()] or None
        cmd_strings(ver, only, dry="--dry" in a)
    elif cmd == "uitables":
        cmd_uitables(ver)
    elif cmd == "tables":
        # where the UI object tables are in a version's image (no tree needed)
        for v in [ver] + a[2:]:
            R = ref_image(v)
            pt, nt, n = ui_tables_of(R)
            c = find_classtab(R)
            print("%-7s object table 0x%06x, name table 0x%06x, %d objects, class-name table %s"
                  % (v, pt, nt, n, "0x%06x" % c if c else "not found"))
    elif cmd == "farptrs":
        cmd_farptrs(ver, dry="--dry" in a)
    elif cmd == "show":
        cmd_show(ver, int(a[2]))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
