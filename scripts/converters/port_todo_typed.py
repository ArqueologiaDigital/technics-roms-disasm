#!/usr/bin/env python3
r"""Spell the pointers and strings inside a ported KN5000 tree's `; TODO(port)` byte rows as such.

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py writes the target bytes no line of the source tree maps
    to as `.byte` rows under `; TODO(port): ...` (scripts/analysis/kn5000_source_coverage.py counts them
    as verbatim debt); scripts/converters/disassemble_port_todo.py has already decoded the rows that are
    code.  The rest are data, mostly NAKA widget records and their tables.  Which of their bytes are
    32-bit pointers to a label of the tree, or NUL-terminated text, and does the image stay
    byte-identical when they are written as `.long Label` and `.asciz "..."`?

WHAT IT DOES
    Every row of a block (the porter's form, `\t.byte\t0x..`, up to 8 values; labels, comments and
    blank lines inside a block are kept where they are) is read with its ROM address (the porter's
    tree_map).  Between two kept lines the bytes are scanned in order:
      * 4 bytes whose little-endian value is the address of a ROM label of the tree's ELF (a `t`
        symbol in 0xE00000-0xFFFFFF, not a `.L` or marker name; of several at one address the first
        in llvm-nm's order) -> `.long Name`;
      * 4 or more printable ASCII bytes (0x20-0x7e, no `"` or `\`) followed by a NUL -> `.asciz "..."`,
        or `aligned_string "..."` when the NUL ends on an odd address and a 0xff pad follows;
      * anything else stays a `.byte` row, under the block's `; TODO(port): ...` line repeated, so the
        bytes nothing explains are still counted as debt.
    The tree is rebuilt; if the image is not byte-identical every file is restored.

RUN (repository root; the tree built: rebuilt_ROMs/kn5000_TREE_program.llvm.elf matches its dump)
    python3 scripts/converters/port_todo_typed.py --tree v6 [--dry-run]
    Idempotent: rows already typed are not rows any more.
"""
import argparse
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_maincpu_version as P  # noqa: E402
import port_symbolize_pointers as S  # noqa: E402

TODO = re.compile(r"^;\s*TODO\(port\)")
ROW = re.compile(r"^\t\.byte\t(0x[0-9a-f]{2}(?:, 0x[0-9a-f]{2}){0,7})\s*$")
KEEP = re.compile(r"^\s*$|^\s*;|^\s*(?:[A-Za-z_.$][\w.$]*\s*:\s*)+$")


def spell(bs, addr, by_addr, mark):
    """bytes at ROM address addr -> (lines, typed byte count, left byte count)"""
    out, rows, typed, left = [], [], 0, 0

    def flush():
        nonlocal rows, left
        if rows:
            out.append(mark)
            for k in range(0, len(rows), 8):
                out.append("\t.byte\t" + ", ".join("0x%02x" % b for b in rows[k:k + 8]))
            left += len(rows)
            rows = []
    i = 0
    while i < len(bs):
        if i + 4 <= len(bs):
            v = int.from_bytes(bs[i:i + 4], "little")
            if v in by_addr:
                flush()
                out.append("\t.long\t%s" % by_addr[v])
                typed += 4
                i += 4
                continue
        j = i
        while j < len(bs) and 0x20 <= bs[j] < 0x7f and bs[j] not in (0x22, 0x5c):
            j += 1
        if j - i >= 4 and j < len(bs) and bs[j] == 0:
            flush()
            txt = bs[i:j].decode("ascii")
            if (addr + j + 1) & 1 and j + 1 < len(bs) and bs[j + 1] == 0xff:
                out.append('\taligned_string "%s"' % txt)     # .asciz + the 0xff pad to an even address
                typed += j + 2 - i
                i = j + 2
            else:
                out.append('\t.asciz\t"%s"' % txt)
                typed += j + 1 - i
                i = j + 1
            continue
        rows.append(bs[i])
        i += 1
    flush()
    return out, typed, left


def convert(tree):
    _, by_addr = S.elf_syms(tree)
    by_addr = {a: n for a, n in by_addr.items() if S.BASE <= a < S.END}
    order, _, _ = P.tree_map(tree)
    addr = {(e[1], e[2]): e[0] for e in order if e[0] is not None}
    files, total_t, total_l = {}, 0, 0
    for path in S.tree_files(tree):
        rel = os.path.relpath(path, os.path.join(ROOT, tree, "maincpu"))
        L = S.rd(path).split("\n")
        out, i, changed = [], 0, False
        while i < len(L):
            if not TODO.match(L[i]):
                out.append(L[i])
                i += 1
                continue
            # one block: rows, and the labels / comments / blank lines between them
            j = i + 1
            seg, block = [], []                        # seg: (start address, bytes) of a row run
            while j < len(L) and (ROW.match(L[j]) or KEEP.match(L[j]) and not TODO.match(L[j])):
                m = ROW.match(L[j])
                if m:
                    vals = bytes(int(x, 16) for x in m.group(1).split(", "))
                    a = addr.get((rel, j + 1))
                    if seg and a is not None and seg[-1][0] is not None and seg[-1][0] + len(seg[-1][1]) == a:
                        seg[-1] = (seg[-1][0], seg[-1][1] + vals)
                    else:
                        seg.append((a, vals))
                        block.append(("seg", len(seg) - 1))
                else:
                    block.append(("line", L[j]))
                    seg_break = True
                    if seg:
                        seg.append((None, b""))        # a kept line ends the run
                j += 1
            new = []
            if not any(k == "seg" for k, _ in block):
                new.append(L[i])
            for kind, x in block:
                if kind == "line":
                    new.append(x)
                    continue
                a, bs = seg[x]
                if a is None:
                    new += [L[i]] + ["\t.byte\t" + ", ".join("0x%02x" % b for b in bs[k:k + 8])
                                     for k in range(0, len(bs), 8)]
                    total_l += len(bs)
                    continue
                lines, t, l_ = spell(bs, a, by_addr, L[i])
                new += lines
                total_t += t
                total_l += l_
            # trailing kept lines that followed the last row stay after the block
            if new != L[i:j]:
                changed = True
            out += new
            i = j
        if changed:
            files[path] = "\n".join(out)
    return files, total_t, total_l


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=("v6", "v5"))
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    files, t, l_ = convert(a.tree)
    print("%s: %d bytes as .long / .asciz, %d left as TODO(port) rows, %d files" % (a.tree, t, l_, len(files)))
    if a.dry_run or not files:
        return
    backup = {p: S.rd(p) for p in files}
    for p, s in files.items():
        S.wr(p, s)
    ok, err = S.build_ok(a.tree)
    if not ok:
        for p, s in backup.items():
            S.wr(p, s)
        S.build_ok(a.tree)
        sys.exit("not byte-identical; files restored\n" + err)
    print("%s: byte-identical" % a.tree)


if __name__ == "__main__":
    main()
