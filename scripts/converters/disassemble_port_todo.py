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
BYTE_ROW = re.compile(r'^\s*\.byte\s+(.*)$')
DATA_MACROS = {"naka_header", "addr24", "aligned_string", "desc_entry", "naka_node",
               "sndparam_descriptor"}
REL = P.REL
BITOPS = {"and", "or", "xor", "andw", "orw", "xorw", "andcf", "orcf", "xorcf"}


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
        self.sorted_labels = sorted((a, sorted(ns)[0]) for a, ns in self.labels.items())
        self.keys = [a for a, n in self.sorted_labels]

    def blocks(self):
        """-> [(first order index, last order index, address, bytes, kind)]"""
        out = []
        n = len(self.order)
        self.todo_rows = set()            # every row of every block: context looks past them
        for i in range(n):
            if TODO.match(self.order[i][3]):
                j = i + 1
                while j < n and BYTE_ROW.match(P.code_part(self.order[j][3])):
                    self.todo_rows.add(j)
                    j += 1
        i = 0
        while i < n:
            if not TODO.match(self.order[i][3]):
                i += 1
                continue
            j = i + 1
            rows = []
            while j < n and BYTE_ROW.match(P.code_part(self.order[j][3])):
                rows.append(j)
                j += 1
            if rows:
                a = self.order[rows[0]][0]
                end = self.order[rows[-1]][0] + self.size[rows[-1]]
                out.append((i, rows[-1], a, self.rom[a - BASE:end - BASE], self.context(i, rows[-1])))
            i = j
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

    def new_name(self, addr, suffix):
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
    kinds = collections.Counter(b[4] for b in blocks)
    print("TODO(port) blocks: %d (%s), %d bytes" % (len(blocks), dict(kinds), sum(len(b[3]) for b in blocks)))
    # decode every code block; collect instruction starts first (for new labels)
    good = {}
    inst_starts = set()
    for k, (first, last, a, bs, kind) in enumerate(blocks):
        if kind != "code":
            continue
        items = P.decode_region(bs)
        if any(t is None for o, l, t in items):
            continue                        # a byte that starts no instruction: not clean code
        good[k] = [(a + o, l, t) for o, l, t in items]
        inst_starts.update(a + o for o, l, t in items)
    print("code blocks decoded and round-tripped: %d of %d (%d bytes)" % (
        len(good), kinds["code"], sum(len(blocks[k][3]) for k in good)))
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
        first, last, a, bs, kind = blocks[k]
        rel = T.order[first][1]
        for idx in range(first, last + 1):
            edits[rel][T.order[idx][2]] = None
        lines = []
        for ad, n, t in seq:
            for nm in [newlabels[ad]] if ad in newlabels else []:
                lines.append(nm + ":")
                block_of_addr[ad] = k
            lines.append("\t" + t)
        edits[rel][T.order[first][2]] = lines
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
