#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Exact file-offset correspondence between two builds of the same KN7000 flash
# image (e.g. program build 941 -> 942, the SP7001 firmware).
#
# Question it answers: "where did every byte of the old build go, and which
# bytes are genuinely new?" -- so knowledge recovered for the old build
# (function boundaries, names, converted-to-asm ranges, docs) can be ported to
# the new one, and RE effort spent only on what actually changed.
#
# Method. Unique 24-byte anchors sampled every 0x100 bytes give
# piecewise-constant delta segments (a byte at old offset o sits at o+delta);
# between two segments, difflib aligns the gap exactly. Inside a segment the
# map is 1:1 even where bytes differ: those are same-length rewrites, nearly
# all of them relocated call displacements and absolute pointers.
#
# Usage:  offset_map.py <old.rom> <new.rom> [old.sym ...]
#   prints the delta segments and every genuine edit (insert/delete/resize),
#   labelled with the nearest preceding old-build symbol when .sym files given.
import bisect
import difflib
import re
import sys

STEP, N, WIN, MIN_ANCHORS = 0x100, 24, 0x40000, 3
MAX_GAP = 0x10000   # larger unanchored gaps are recorded as delete+insert, not aligned


def _trim(data):
    """Drop trailing erased flash (0xFF) so the image ends at its real end."""
    end = len(data)
    while end and data[end - 1] == 0xFF:
        end -= 1
    return data[:end]


def _segments(A, B):
    pts = []
    for off in range(0, len(A) - N, STEP):
        pat = A[off:off + N]
        if len(set(pat)) < 6:
            continue
        lo, hi = max(0, off - WIN), min(len(B), off + WIN + N)
        j = B.find(pat, lo, hi)
        if j < 0 or B.find(pat, j + 1, hi) >= 0:
            continue
        pts.append((off, j - off))
    segs = []                                   # [lo, hi_last_anchor, delta, count]
    for off, d in pts:
        if segs and segs[-1][2] == d:
            segs[-1][1] = off
            segs[-1][3] += 1
        else:
            segs.append([off, off, d, 1])
    segs = [s for s in segs if s[3] >= MIN_ANCHORS]
    merged = []
    for s in segs:
        if merged and merged[-1][2] == s[2]:
            merged[-1][1], merged[-1][3] = s[1], merged[-1][3] + s[3]
        else:
            merged.append(list(s))
    # a segment covers [first anchor, last anchor + N)
    return [(lo, hi + N, d) for lo, hi, d, _ in merged]


class OffsetMap:
    """blocks: sorted (old_lo, old_hi, new_lo) runs mapped 1:1.
    inserted: (new_lo, new_hi) bytes only in the new build.
    deleted:  (old_lo, old_hi) bytes only in the old build."""

    def __init__(self, old, new):
        A, B = _trim(old), _trim(new)
        self.old_len, self.new_len = len(A), len(B)
        segs = _segments(A, B)
        if not segs:
            raise ValueError("no common anchored content: these do not look like two "
                             "builds of the same image")
        # pin both image ends so the whole span is covered
        if segs[0][0] > 0:
            segs.insert(0, (0, 0, 0))
        blocks, ins, dele = [], [], []
        prev_hi, prev_d = 0, 0
        for lo, hi, d in segs + [(len(A), len(A), len(B) - len(A))]:
            # gap old[prev_hi:lo] vs new[prev_hi+prev_d : lo+d]
            a0, a1, b0, b1 = prev_hi, lo, prev_hi + prev_d, lo + d
            if (a1 - a0) > MAX_GAP or (b1 - b0) > MAX_GAP:
                # wholesale-different region (no anchors): unmapped on both sides
                if b1 > b0:
                    ins.append((b0, b1))
                if a1 > a0:
                    dele.append((a0, a1))
            elif a1 > a0 or b1 > b0:
                sm = difflib.SequenceMatcher(None, A[a0:a1], B[b0:b1], autojunk=False)
                for t, i1, i2, j1, j2 in sm.get_opcodes():
                    if t == "equal" or (t == "replace" and i2 - i1 == j2 - j1):
                        blocks.append((a0 + i1, a0 + i2, b0 + j1))
                    else:
                        if j2 > j1:
                            ins.append((b0 + j1, b0 + j2))
                        if i2 > i1:
                            dele.append((a0 + i1, a0 + i2))
            if hi > lo:
                blocks.append((lo, hi, lo + d))
            prev_hi, prev_d = hi, d
        blocks.sort()
        # coalesce adjacent runs with the same delta
        out = []
        for a0, a1, b0 in blocks:
            if out and out[-1][1] == a0 and out[-1][2] + (a0 - out[-1][0]) == b0:
                out[-1] = (out[-1][0], a1, out[-1][2])
            else:
                out.append((a0, a1, b0))
        self.blocks, self.inserted, self.deleted = out, ins, dele
        self._los = [b[0] for b in out]

    def map(self, off):
        """old offset -> new offset, or None if the byte was deleted."""
        i = bisect.bisect_right(self._los, off) - 1
        if i >= 0:
            a0, a1, b0 = self.blocks[i]
            if a0 <= off < a1:
                return b0 + (off - a0)
        return None

    def segments(self):
        """(old_lo, old_hi, delta) runs, coalescing equal deltas."""
        out = []
        for a0, a1, b0 in self.blocks:
            d = b0 - a0
            if out and out[-1][2] == d and out[-1][1] == a0:
                out[-1] = (out[-1][0], a1, d)
            else:
                out.append((a0, a1, d))
        return out


def load_sym(paths, base):
    syms = []
    for p in paths:
        for line in open(p):
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
            if m:
                a = int(m.group(1), 16) - base
                if 0 <= a < 0x400000:
                    syms.append((a, m.group(2)))
    return sorted(set(syms))


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    old = open(sys.argv[1], "rb").read()
    new = open(sys.argv[2], "rb").read()
    syms = load_sym(sys.argv[3:], 0x48400000)
    offs = [s[0] for s in syms]

    def where(o):
        i = bisect.bisect_right(offs, o) - 1
        return f"{syms[i][1]}+0x{o - syms[i][0]:X}" if i >= 0 else "?"

    m = OffsetMap(old, new)
    print(f"old image 0x{m.old_len:06X} bytes, new image 0x{m.new_len:06X} bytes")
    print(f"\ndelta segments ({len(m.segments())}, 1:1 runs incl. relocated bytes):")
    for a0, a1, d in m.segments():
        if a1 - a0 >= 0x100:
            print(f"  old 0x{a0:06X}..0x{a1:06X}  delta {d:+6d}")
    print(f"\ngenuine edits: {len(m.inserted)} insertions "
          f"({sum(b - a for a, b in m.inserted)} B), {len(m.deleted)} deletions "
          f"({sum(b - a for a, b in m.deleted)} B)")
    for a, b in m.inserted:
        print(f"  + new 0x{a:06X}..0x{b:06X} ({b - a:5d} B)")
    for a, b in m.deleted:
        print(f"  - old 0x{a:06X}..0x{b:06X} ({b - a:5d} B)  in {where(a)}")


if __name__ == "__main__":
    main()
