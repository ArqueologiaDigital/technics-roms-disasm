#!/usr/bin/env python3
r"""Turn the `; TODO(port)` byte rows of a ported main-program tree into instructions.

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py leaves the target bytes that no line of the
    source tree maps to as `.byte` rows under `; TODO(port): ...`.  Which of those rows are
    code, and what instructions are they?  A row block that sits between instructions is
    decoded here and rewritten as instructions with symbolic branch / call targets; a block
    that is not code, or does not decode cleanly, is left as it was.

HOW
  1. Address map of the tree (address_line_map.py's marker technique, through
     port_maincpu_version.tree_map): every line's address; the ELF symbols.
  2. A TODO(port) block is CODE when the nearest byte-emitting line before it and the
     nearest one after it (labels and comments skipped) are both instructions.  Its first
     byte is an instruction start: it follows an instruction, or a label.
  3. port_maincpu_version.decode_region decodes the block with llvm-mc; every instruction
     re-encodes to its own bytes.  Where llvm-mc cannot decode, MAME's unidasm decode of that
     instruction is tried in llvm-mc spellings; one that no spelling reproduces becomes a
     `.byte` row with MAME's text as its comment (a form the backend cannot write).  A block
     with a byte that starts no instruction in either decoder is left as it was.
  4. Operands: a relative branch, call or jump to an address that holds a label is written
     with that label; to an instruction start with no label, with a new label named after
     the label before it (`_Skip` / `_Loop` for a branch target ahead of / behind the
     branch, `_Entry` for a call or jump target); else the number stays.  A 24-bit memory
     operand or a 32-bit immediate equal to a label's address is written as the label.
     Memory addresses are written in hex.
  5. The tree is rebuilt and compared with the dump; if the image is not byte-identical the
     files are restored and the tool stops.

RUN
    python3 scripts/converters/disassemble_port_todo.py --tree v6 --rom PATH [--apply]
    (without --apply: report only)
"""
import argparse
import bisect
import collections
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import port_maincpu_version as P  # noqa: E402

BASE = P.BASE
MC = P.MC
TODO = re.compile(r'^\s*;\s*TODO\(port\)')
# a row in the porter's own form; a source tree's `.byte` data after a block is not one
BYTE_ROW = re.compile(r'^\t\.byte\t(0x[0-9a-f]{2}(?:, 0x[0-9a-f]{2}){0,7})\s*$')
DATA_MACROS = {"naka_header", "addr24", "aligned_string", "desc_entry", "naka_node",
               "sndparam_descriptor"}
REL = P.REL
BITOPS = {"and", "or", "xor", "andw", "orw", "xorw", "andcf", "orcf", "xorcf"}
SOURCE_TREE = {"v6": "v7", "v5": "v6"}


def is_instruction(body):
    if not body:
        return False
    w = body.split(None, 1)[0]
    return not w.startswith(".") and w.lower() not in DATA_MACROS


def mc_decode(bs):
    """-> list of instruction texts llvm-mc decodes from bs (None on a decode warning)"""
    r = subprocess.run([MC, "-triple=tlcs900", "--disassemble"], input=" ".join("0x%02x" % x for x in bs),
                       capture_output=True, text=True)
    if r.returncode != 0 or "warning" in r.stderr or "invalid" in r.stderr:
        return None
    out = []
    for ln in r.stdout.splitlines():
        ln = ln.strip()
        if not ln or ln.startswith(".text"):
            continue
        out.append(re.sub(r'\s+', " ", ln))
    return out


Block = collections.namedtuple("Block", "first last a e start bs kind inner comments")


class Tree:
    def __init__(self, tree, rom):
        self.tree = tree
        self.dir = os.path.join(ROOT, tree, "maincpu")
        self.order, self.syms, self.built = P.tree_map(tree)
        self.size = P.fill_sizes(self.order)
        self.rom = open(rom, "rb").read()
        if self.built != self.rom:
            sys.exit("the %s tree does not build byte-identical to %s; fix that first" % (tree, rom))
        self.parsed = [P.split_line(e[3]) for e in self.order]
        self.labels = collections.defaultdict(list)      # address -> names
        for nm, v in self.syms.items():
            if BASE <= v < BASE + len(self.rom) and not nm.startswith((".L", "__")):
                self.labels[v].append(nm)
        for i, (labs, body, com) in enumerate(self.parsed):
            for lab in labs:
                if self.order[i][0] is not None and lab not in self.labels[self.order[i][0]]:
                    self.labels[self.order[i][0]].append(lab)
        self.starts = {}                  # address -> order index of a byte line starting there
        for i, e in enumerate(self.order):
            if self.size[i] > 0 and e[0] is not None:
                self.starts.setdefault(e[0], i)
        self.used = set(self.syms) | {lab for labs, b, c in self.parsed for lab in labs}
        # the source tree's labels the porter dropped stay reserved: a new name must not
        # reuse one for another thing (the tree says where each one was)
        dl = os.path.join(self.dir, "port_dropped_labels.txt")
        if os.path.exists(dl):
            self.used |= {ln.split("\t")[0] for ln in open(dl) if ln.strip() and not ln.startswith("#")}
        self.sorted_labels = sorted((a, sorted(ns)[0]) for a, ns in self.labels.items())
        self.keys = [a for a, n in self.sorted_labels]
        # RAM .equ names the tree's instructions use as memory operands, by value (only values one
        # name spells)
        ram = collections.defaultdict(set)
        for labs, body, com in self.parsed:
            for nm in re.findall(r'\(([A-Za-z_]\w*)(?:\+\d+)?(?::(?:8|16|24))?\)', body or ""):
                v = self.syms.get(nm)
                if v is not None and v < BASE:
                    ram[v].add(nm)
        self.ram_names = {v: next(iter(ns)) for v, ns in ram.items() if len(ns) == 1}
        self._source_tree()

    def _inside(self, j):
        """a line a TODO(port) block runs on through: a `.byte` row, a line with only labels
        (a target named by an earlier run), a comment or a blank line"""
        labs, body, com = self.parsed[j]
        return bool(BYTE_ROW.match(self.order[j][3])) or not body

    def blocks(self):
        """-> [Block].  A TODO(port) block runs from its marker through `.byte` rows and the
        label-only, comment and blank lines between them, up to its last row."""
        out = []
        n = len(self.order)
        self.todo_rows = set()            # every row of every block: context looks past them
        spans = []
        i = 0
        while i < n:
            if not TODO.match(self.order[i][3]):
                i += 1
                continue
            j = i + 1
            # the porter starts a new marker after each `; port:` comment it writes inside a run of
            # rows; the rows on both sides are one block (an instruction can straddle the marker)
            while j < n and self._inside(j):
                j += 1
            while j > i + 1 and not BYTE_ROW.match(self.order[j - 1][3]):
                j -= 1                    # trailing labels and comments belong to what follows
            rows = [k for k in range(i + 1, j) if BYTE_ROW.match(self.order[k][3])]
            if rows:
                spans.append((i, j - 1, rows))
                self.todo_rows.update(rows)
            i = max(j, i + 1)
        targets = self.branch_targets()
        for first, last, rows in spans:
            a = self.order[rows[0]][0]
            e = self.order[rows[-1]][0] + self.size[rows[-1]]
            inner, comments = collections.defaultdict(list), []
            for k in range(first + 1, last + 1):
                labs, body, com = self.parsed[k]
                if k in self.todo_rows:
                    continue
                for lab in labs:
                    inner[self.order[k][0]].append(lab)
                    comments.append((self.order[k][0], None, k, lab))
                if not labs and self.order[k][3].strip() and not TODO.match(self.order[k][3]):
                    comments.append((self.order[k][0], self.order[k][3], k, None))
            ctx = self.context(first, last)
            start = a
            if ctx != "code":
                # reachable bytes are code whatever surrounds them: decode from the first
                # address the tree's code branches, calls or jumps to
                hit = sorted(t for t in targets if a <= t < e)
                if hit:
                    ctx, start = "code", hit[0]
            out.append(Block(first, last, a, e, start, self.rom[start - BASE:e - BASE], ctx, inner, comments))
        return out

    def branch_targets(self):
        """addresses the tree's instructions branch, call or jump to (a relative branch read
        from its bytes; call / jp through a symbol or a number)"""
        out = set()
        for i, (labs, body, com) in enumerate(self.parsed):
            if not body or self.size[i] <= 0 or i in self.todo_rows:
                continue
            p = body.split(None, 1)
            if len(p) != 2:
                continue
            mn, ops = p[0].lower(), p[1]
            a, n = self.order[i][0], self.size[i]
            if mn in REL:
                w = P.REL_W.get(mn, 1)
                bs = self.rom[a - BASE:a - BASE + n]
                out.add(a + n + P.sval(P.le(bs, n - w, w), w))
            elif mn in ("call", "jp"):
                last = P.split_commas(ops)[-1].strip()
                if re.fullmatch(r'0x[0-9a-f]+', last):
                    out.add(int(last, 16))
                elif re.fullmatch(r'[A-Za-z_.$][\w.$]*', last) and last in self.syms:
                    out.add(self.syms[last])
        return out

    def context(self, first, last):
        def scan(k, step):
            while 0 <= k < len(self.order):
                labs, body, com = self.parsed[k]
                if body and self.size[k] > 0 and k not in self.todo_rows:
                    return body
                k += step
            return None
        before, after = scan(first - 1, -1), scan(last + 1, 1)
        return "code" if is_instruction(before) and is_instruction(after) else "data"

    def label_for(self, addr):
        ns = self.labels.get(addr)
        return sorted(ns, key=lambda x: (x.startswith("."), len(x)))[0] if ns else None

    def enclosing(self, addr):
        j = bisect.bisect_right(self.keys, addr) - 1
        return P.label_stem(self.sorted_labels[j][1]) if j >= 0 else "Rom"

    def _source_tree(self):
        """the tree this one was ported from (v7 for v6, v6 for v5): its labels and image, to name a
        new label after the source tree's label for the same thing"""
        self.src_pairs = []
        src = SOURCE_TREE.get(self.tree)
        elf = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % src) if src else ""
        if not src or not os.path.exists(elf):
            return
        out = subprocess.run([P.NM, "--defined-only", elf], capture_output=True, text=True, check=True).stdout
        ss = {}
        for ln in out.splitlines():
            f = ln.split()
            if len(f) == 3 and f[1] in "tT" and not f[2].startswith((".L", "__")):
                v = int(f[0], 16)
                if BASE <= v < BASE + 0x200000:
                    ss.setdefault(f[2], v)
        self.src_rom = open(os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % src), "rb").read()
        self.src_by_addr = {}
        for nm, v in sorted(ss.items()):
            self.src_by_addr.setdefault(v, nm)
        self.src_pairs = sorted((self.syms[nm], v) for nm, v in ss.items()
                                if nm in self.syms and BASE <= self.syms[nm] < BASE + 0x200000)
        self.src_keys = [d for d, sv in self.src_pairs]
        self.src_addrs = sorted(self.src_by_addr)

    def source_name(self, addr):
        """the source tree's label for the thing at addr: at the address the nearest label both trees
        define puts it, with the same bytes there (up to 12, up to the source tree's next label, at
        least 4); None if there is none or the name is taken"""
        if not self.src_pairs:
            return None
        j = bisect.bisect_right(self.src_keys, addr) - 1
        if j < 0:
            return None
        d, sv = self.src_pairs[j]
        sa = addr - d + sv
        nm = self.src_by_addr.get(sa)
        if not nm or nm in self.used:
            return None
        k = bisect.bisect_right(self.src_addrs, sa)
        n = min(12, (self.src_addrs[k] - sa) if k < len(self.src_addrs) else 12)
        if n < 4 or self.src_rom[sa - BASE:sa - BASE + n] != self.rom[addr - BASE:addr - BASE + n]:
            return None
        return nm

    def new_name(self, addr, suffix):
        src = self.source_name(addr)
        if src:
            self.used.add(src)
            self.labels[addr].append(src)
            j = bisect.bisect_right(self.keys, addr)
            self.keys.insert(j, addr)
            self.sorted_labels.insert(j, (addr, src))
            return src
        base = self.enclosing(addr)
        name, k = base + suffix, 2
        while name in self.used:
            name, k = "%s%s%d" % (base, suffix, k), k + 1
        self.used.add(name)
        self.labels[addr].append(name)
        j = bisect.bisect_right(self.keys, addr)
        self.keys.insert(j, addr)
        self.sorted_labels.insert(j, (addr, name))
        return name


WIDEN_BACK, WIDEN_FWD = 3, 6


def widen(T, b):
    """A code block whose bytes do not decode on their own -- an instruction straddles its first or
    last byte, the porter having kept a source-tree line for the other part of it -- decoded together
    with up to WIDEN_BACK byte lines before it and WIDEN_FWD after it (instructions, or `.byte` lines
    of code the source tree spells as bytes; no other directive).  -> (Block, items) of the narrowest
    widening that decodes cleanly with every label inside on an instruction start, or None."""
    def byte_lines(k, step, limit):
        out = []
        while 0 <= k < len(T.order) and len(out) < limit:
            labs, body, com = T.parsed[k]
            if T.size[k] > 0 and k not in T.todo_rows:
                w = body.split(None, 1)[0] if body else ""
                if not (is_instruction(body) or w == ".byte"):
                    break
                out.append(k)
            elif body and T.size[k] == 0 and not is_instruction(body):
                break                       # a directive that emits nothing (.org, .equ ...)
            k += step
        return out
    back = byte_lines(b.first - 1, -1, WIDEN_BACK)
    fwd = byte_lines(b.last + 1, 1, WIDEN_FWD)
    for total in range(1, len(back) + len(fwd) + 1):
        for nb in range(0, min(total, len(back)) + 1):
            nf = total - nb
            if nf > len(fwd):
                continue
            first = back[nb - 1] if nb else b.first
            last = fwd[nf - 1] if nf else b.last
            a = T.order[first][0] if nb else b.start
            e = T.order[last][0] + T.size[last] if nf else b.e
            items = P.decode_region(T.rom[a - BASE:e - BASE])
            if any(t is None for o, l, t in items):
                continue
            starts = {a + o for o, l, t in items}
            inner = collections.defaultdict(list)
            for ad, labs in b.inner.items():
                inner[ad].extend(labs)
            comments = []
            for k in range(first, last + 1):
                if b.first <= k <= b.last:
                    continue
                labs, body, com = T.parsed[k]
                for lab in labs:
                    inner[T.order[k][0]].append(lab)
                    comments.append((T.order[k][0], None, k, lab))
                if k == first and nb:
                    continue
                if com and com.strip():
                    comments.append((T.order[k][0], "\t; " + com.strip().lstrip(";").strip(), k, None))
            if comments:
                comments = b.comments + comments
            else:
                comments = list(b.comments)
            if any(ad not in starts for ad in inner if a < ad < e) or any(
                    ad == e for ad in ()):
                continue
            nbk = Block(first, last, min(a, b.a), e, a, T.rom[a - BASE:e - BASE], "code", inner, comments)
            return nbk, [(a + o, l, t) for o, l, t in items]
    return None


def start_agrees(T, start):
    """Is `start` an instruction start when the bytes are decoded from the nearest label before
    it?  The porter's lines next to a TODO(port) block can be the source tree's own spelling of
    code as `.byte` rows or as faux instructions, so the block's first byte is not known to start
    an instruction just because a line ends there."""
    j = bisect.bisect_right(T.keys, start) - 1
    if j < 0:
        return False
    a = T.keys[j]
    if a == start:
        return True
    if start - a > 512:
        return False
    items = P.decode_region(T.rom[a - BASE:start - BASE])
    return all(t is not None for o, l, t in items) and sum(l for o, l, t in items) == start - a


def unspelled_row(T, text, addr, n):
    """an instruction MAME decodes and llvm-mc cannot spell: its bytes, MAME's text as comment"""
    bs = T.rom[addr - BASE:addr - BASE + n]
    return ".byte\t" + ", ".join("0x%02x" % x for x in bs) + "\t; " + text[len(P.UNSPELLED):]


def symbolize(T, text, addr, n, inst_starts, newlabels):
    """rewrite one decoded instruction's operands; -> text"""
    p = text.split(" ", 1)
    mn, ops = p[0], (p[1] if len(p) > 1 else "")

    def target_label(tgt, suffix):
        nm = T.label_for(tgt) or newlabels.get(tgt)
        if nm:
            return nm
        if tgt in T.starts or tgt in inst_starts:
            nm = T.new_name(tgt, suffix)
            newlabels[tgt] = nm
            return nm
        return None

    if mn in REL:
        m = re.search(r'(-?\d+)\s*$', ops)
        if m:
            d = int(m.group(1))
            w = P.REL_W.get(mn, 1)
            if d >= 1 << (8 * w - 1):
                d -= 1 << (8 * w)             # llvm-mc prints calr's displacement unsigned
            tgt = addr + n + d
            nm = target_label(tgt, "_Loop" if tgt <= addr else "_Skip")
            if nm:
                ops = ops[:m.start(1)] + nm
        return mn + "\t" + ops
    if mn in ("call", "jp"):
        m = re.search(r"(?<![\w.])(0x[0-9a-f]+|\d+)\s*$", ops)
        if m and BASE <= int(m.group(1), 0) < BASE + len(T.rom):
            nm = target_label(int(m.group(1), 0), "_Entry")
            ops = ops[:m.start(1)] + (nm if nm else "0x%06x" % int(m.group(1), 0))
        return mn + "\t" + ops

    def mem(m):
        v, suf = int(m.group(1)), m.group(2) or ""
        if BASE <= v < BASE + len(T.rom) and T.label_for(v):
            return "(" + T.label_for(v) + suf + ")"
        if v in T.ram_names:
            return "(" + T.ram_names[v] + suf + ")"
        return "(0x%x%s)" % (v, suf)
    ops = re.sub(r'\((\d+)(:(?:8|16|24))?\)', mem, ops)

    def imm(m):
        v = int(m.group(2))
        if BASE <= v < BASE + len(T.rom) and T.label_for(v):
            return m.group(1) + T.label_for(v)
        if v >= 256 or mn.lower() in BITOPS:
            return m.group(1) + "0x%x" % v
        return m.group(0)
    ops = re.sub(r'(,\s*|^)(\d+)(?=\s*$)', imm, ops)
    return mn + ("\t" + ops if ops else "")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True)
    ap.add_argument("--rom", required=True)
    ap.add_argument("--apply", action="store_true")
    args = ap.parse_args()
    T = Tree(args.tree, args.rom)
    blocks = T.blocks()
    kinds = collections.Counter(b.kind for b in blocks)
    reach = sum(1 for b in blocks if b.start > b.a)
    print("TODO(port) blocks: %d (%s; %d of the code ones only because code branches into them), %d bytes"
          % (len(blocks), dict(kinds), reach, sum(b.e - b.a for b in blocks)))
    # decode every code block; collect instruction starts first (for new labels)
    good = {}
    inst_starts = set()
    widened = 0
    for k, b in enumerate(blocks):
        if b.kind != "code":
            continue
        items = P.decode_region(b.bs)
        starts = {b.start + o for o, l, t in items}
        if any(t is None for o, l, t in items) or any(ad >= b.start and ad not in starts for ad in b.inner):
            # a byte that starts no instruction, or a label inside would split one: try the block
            # with its neighbour lines
            w = widen(T, b)
            if w is None or not start_agrees(T, w[0].start):
                continue
            blocks[k], seq = w
            widened += 1
            good[k] = seq
            inst_starts.update(ad for ad, l, t in seq)
            continue
        if not start_agrees(T, b.start):
            continue
        good[k] = [(b.start + o, l, t) for o, l, t in items]
        inst_starts.update(starts)
    print("code blocks decoded and round-tripped: %d of %d (%d bytes; %d of them with neighbour lines)" % (
        len(good), kinds["code"], sum(len(blocks[k].bs) for k in good), widened))
    newlabels = {}
    rewritten = {}
    for k, seq in good.items():
        rewritten[k] = [(ad, n, unspelled_row(T, t, ad, n) if t.startswith(P.UNSPELLED)
                         else symbolize(T, t, ad, n, inst_starts, newlabels)) for ad, n, t in seq]
    # numeric branch / call targets elsewhere in the tree (the porter writes a number when
    # no label stands at the target yet): name them now that the blocks have instruction starts
    fixups = {}
    for i, (labs, body, com) in enumerate(T.parsed):
        if not body or T.size[i] <= 0 or i in T.todo_rows:
            continue
        p = body.split(None, 1)
        if len(p) != 2:
            continue
        mn, ops = p[0].lower(), p[1]
        a, n = T.order[i][0], T.size[i]
        bs = T.rom[a - BASE:a - BASE + n]
        if mn in REL and re.search(r'(?<![\w.])-?\d+\s*$', ops):
            w = P.REL_W.get(mn, 1)
            tgt = a + n + P.sval(P.le(bs, n - w, w), w)
            suffix = "_Loop" if tgt <= a else "_Skip"
        elif mn in ("call", "jp") and re.search(r'(?<![\w.])0x[0-9a-f]+\s*$', ops):
            tgt = P.le(bs, n - 3, 3)
            suffix = "_Entry"
        else:
            continue
        nm = T.label_for(tgt) or newlabels.get(tgt)
        if not nm and (tgt in T.starts or tgt in inst_starts):
            nm = T.new_name(tgt, suffix)
            newlabels[tgt] = nm
        if nm:
            new = re.sub(r'(?<![\w.])(-?\d+|0x[0-9a-f]+)(\s*)$', nm + r"\2", ops)
            fixups[i] = T.order[i][3].replace(ops, new, 1) if ops in T.order[i][3] else None
    fixups = {i: t for i, t in fixups.items() if t is not None}
    print("new labels:", len(newlabels), " numeric targets named:", len(fixups))
    if not args.apply:
        return
    # write: per file, replace block lines; insert new labels before their lines
    edits = collections.defaultdict(dict)      # rel -> {line number: [replacement lines] or None}
    for i, t in fixups.items():
        edits[T.order[i][1]][T.order[i][2]] = [t]
    inserts = collections.defaultdict(lambda: collections.defaultdict(list))
    block_of_addr = {}
    for k, seq in rewritten.items():
        b = blocks[k]
        rel = T.order[b.first][1]
        for idx in range(b.first, b.last + 1):
            edits[rel][T.order[idx][2]] = None
        names = collections.defaultdict(list)          # address -> labels to write there
        for ad, labs in b.inner.items():
            names[ad].extend(labs)
        for ad, nm in newlabels.items():
            if b.a <= ad < b.e and nm not in names[ad]:
                names[ad].append(nm)
                block_of_addr[ad] = k
        # labels and comments stay before the instruction at their address, in their source order
        # (b.comments holds both, with their line index); new labels come after them
        starts_here = {ad for ad, n, t in seq}
        at = collections.defaultdict(list)
        # a header comment `; NAME: ...` (and the comment lines that continue it) stands before label
        # NAME, wherever the porter left it
        where = {lab: ad for ad, c, kk, lab in b.comments if lab}
        after = {lab for lab in T.parsed[b.last + 1][0]} if b.last + 1 < len(T.parsed) else set()
        cur = None
        placed = []
        for ad, c, kk, lab in sorted(b.comments, key=lambda x: x[2]):
            if lab is None:
                m = re.match(r'^;\s*([A-Za-z_]\w*):', c)
                if m and m.group(1) in where and where[m.group(1)] in starts_here:
                    cur = where[m.group(1)]
                elif m and m.group(1) in after:
                    cur = "end"                 # the label the block's next line carries
                elif not re.match(r'^;\s\s', c):
                    cur = None
                placed.append((cur if cur is not None else ad, c, None))
            else:
                cur = None
                placed.append((ad, None, lab))
        tail = [c for ad, c, lab in placed if ad == "end"]
        lines = [c for ad, c, lab in placed if lab is None and ad != "end" and ad not in starts_here]
        for ad, c, lab in placed:
            if ad in starts_here:
                if lab is None:
                    # before the labels already queued at ad that its own label follows
                    at[ad].append(c)
                else:
                    at[ad].append(lab + ":")
        for ad in list(names):
            names[ad] = [nm for nm in names[ad] if nm + ":" not in at.get(ad, [])]
        if b.start > b.a:
            # the bytes before the first reachable address stay rows, under the marker
            lines.append(T.order[b.first][3])
            cuts = sorted({b.a, b.start} | {ad for ad in names if b.a < ad < b.start})
            for x, y in zip(cuts, cuts[1:]):
                lines.extend(nm + ":" for nm in names.get(x, []))
                for z in range(x, y, 8):
                    lines.append("\t.byte\t" + ", ".join("0x%02x" % v for v in T.rom[z - BASE:min(y, z + 8) - BASE]))
        for ad, n, t in seq:
            lines.extend(at.get(ad, []))
            lines.extend(nm + ":" for nm in names.get(ad, []))
            lines.append("\t" + t)
        lines.extend(tail)
        edits[rel][T.order[b.first][2]] = lines
    for ad, nm in newlabels.items():
        if ad in block_of_addr:
            continue
        i = T.starts[ad]
        inserts[T.order[i][1]][T.order[i][2]].append(nm + ":")
    backup = tempfile.mkdtemp(prefix="port-todo-")
    touched = set(edits) | set(inserts)
    for rel in touched:
        src = os.path.join(T.dir, rel)
        os.makedirs(os.path.dirname(os.path.join(backup, rel)), exist_ok=True)
        shutil.copy2(src, os.path.join(backup, rel))
        lines = open(src, encoding="latin-1").read().split("\n")
        out = []
        for no, ln in enumerate(lines, 1):
            out.extend(inserts[rel].get(no, []))
            if no in edits[rel]:
                if edits[rel][no] is not None:
                    out.extend(edits[rel][no])
                continue
            out.append(ln)
        open(src, "w", encoding="latin-1", newline="\n").write("\n".join(out))
    r = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % args.tree], cwd=ROOT,
                       capture_output=True, text=True)
    built = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % args.tree)
    same = r.returncode == 0 and open(built, "rb").read() == T.rom
    if not same:
        for rel in touched:
            shutil.copy2(os.path.join(backup, rel), os.path.join(T.dir, rel))
        print(r.stderr[-2000:])
        sys.exit("NOT byte-identical after the rewrite: files restored (backup in %s)" % backup)
    shutil.rmtree(backup)
    print("rewrote %d blocks in %d files; %s is byte-identical" % (len(rewritten), len(touched), args.tree))


if __name__ == "__main__":
    main()
