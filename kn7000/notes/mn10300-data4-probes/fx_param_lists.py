#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""fx_param_lists.py -- the SX-KN6000 / KN6500 effect DSP's parameter lists: do they parse, and which
opaque bytes of the typed data region are they?

QUESTION ANSWERED: "the blocks the per-DSP-type pointer table (KN6000 func_4C155072_Table at RAM
0x500060DC, KN6500 func_4C15562E_Table; 208 entries, in the initialised-RAM image) points at: does every
one parse as the walker reads it, how many bytes do they span, and how many of those are still declared
`census: opaque` in <model>/src/program/data/?"

The reader (KN6000 func_4C155072 0x4C155072, KN6500 func_4C15562E): a0 = Table[type]; for n parameter
numbers skip a group: 13-byte entries while the first byte is not 0xFF, then the 0xFF; a 0xFF where a
group starts answers -1 (no such parameter).  Its caller (KN6000 func_4C155C08) reads each entry as
{u8 kind (0xFF ends the group), u32 BE, u32 BE, u16 BE, u16 BE} (bytes shifted together, `asl 24` ..)
and hands all five to func_4C157DE2 with the parameter's value.  So a block is
    group*  0xFF          group = entry*  0xFF          entry = 13 bytes, entry[0] != 0xFF

RUN (from the repository root):  python3 kn7000/notes/mn10300-data4-probes/fx_param_lists.py [kn6000|kn6500]
"""
import os
import re
import struct
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TABLE = {"kn6000": "func_4C155072_Table", "kn6500": "func_4C15562E_Table"}
BASE = 0x4C000000


def labels(model):
    out = {}
    for ln in open(os.path.join(REPO, model, "src/program/data/labels.sym"), encoding="latin-1"):
        f = ln.split()
        if len(f) >= 2 and f[0].startswith("0x"):
            out[f[1]] = (int(f[0], 16), int(f[2]) if len(f) > 2 and f[2].isdigit() else None)
    return out


def raminit(model):
    s = open(os.path.join(REPO, model, "src/program.s"), encoding="latin-1").read()
    m = re.search(r"mov\s+(0x[0-9a-fA-F]+), d1\n\s+cmp\s+0, d1\n\s+ble\s+\S+\n\s+mov\s+(0x4[cC][0-9a-fA-F]{6}|\w+), a0\n"
                  r"\s+mov\s+(0x5000001[0-9a-fA-F]|\w+), a1\n", s)
    return m


def parse(rom, o):
    """[(group start, [entry offsets])], end offset (after the final 0xFF), or None."""
    groups, q = [], o
    while rom[q] != 0xFF:
        g, ents = q, []
        while rom[q] != 0xFF:
            ents.append(q)
            q += 13
            if q - o > 0x4000:
                return None, None
        q += 1
        groups.append((g, ents))
    return groups, q + 1


def opaque_ranges(model):
    rx = re.compile(rb'^\.incbin_range "baserom/[^"]+", (0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)')
    out, prev = [], b""
    import glob
    for f in sorted(glob.glob(os.path.join(REPO, model, "src/program/data/data_*.s"))):
        for ln in open(f, "rb"):
            m = rx.match(ln)
            if m and b"census: opaque" in prev:
                out.append((int(m.group(1), 16), int(m.group(2), 16)))
            prev = ln
    return out


def main(model):
    rom = open(os.path.join(REPO, model, "baserom", f"{model}_program.rom"), "rb").read()
    lab = labels(model)
    ta, tsize = lab[TABLE[model]]
    # the table is in the initialised-RAM image: its bytes are at the copy loop's source + (ta - dest)
    m = raminit(model)
    src = int(m.group(2), 16) if m.group(2).startswith("0x") else lab[m.group(2)][0]
    dst = int(m.group(3), 16) if m.group(3).startswith("0x") else lab.get(m.group(3), (0x50000010,))[0]
    to = ta - dst + src - BASE
    n = tsize // 4
    ptrs = struct.unpack_from(f"<{n}I", rom, to)
    blocks = {}
    for t, p in enumerate(ptrs):
        if p and BASE <= p < BASE + len(rom):
            blocks.setdefault(p, []).append(t)
    spans, bad = [], []
    for p in sorted(blocks):
        g, e = parse(rom, p - BASE)
        if g is None:
            bad.append(p)
            continue
        spans.append((p - BASE, e, len(g), sum(len(x[1]) for x in g)))
    lo, hi = min(s[0] for s in spans), max(s[1] for s in spans)
    covered = set()
    for a, e, _g, _n in spans:
        covered.update(range(a, e))
    op = [(a, e) for a, e in opaque_ranges(model) if lo <= a < hi + 0x100]
    op_bytes = sum(e - a for a, e in op)
    op_cov = sum(1 for a, e in op for x in range(a, e) if x in covered)
    gaps, pos = [], lo
    for a, e, _g, _n in sorted(spans):
        if a > pos:
            gaps.append((pos, a))
        pos = max(pos, e)
    print(f"{model}: {TABLE[model]} 0x{ta:08X} ({n} entries, ROM file 0x{to:06X}): {len(blocks)} distinct blocks, "
          f"{len(bad)} that do not parse")
    print(f"  blocks span file 0x{lo:06X}..0x{hi:06X} ({hi - lo} bytes; {len(covered)} bytes in blocks, "
          f"{sum(s[2] for s in spans)} groups, {sum(s[3] for s in spans)} entries)")
    print(f"  gaps between pointed blocks: {len(gaps)} ({sum(b - a for a, b in gaps)} bytes): "
          + ", ".join(f"0x{a:06X}+{b - a}" for a, b in gaps[:8]))
    print(f"  census-opaque ranges in that span: {len(op)} pieces / {op_bytes} bytes; in a parsed block: {op_cov} bytes")
    kinds = {}
    for a, e, _g, _n in spans:
        q = a
        while q < e - 1:
            if rom[q] == 0xFF:
                q += 1
                continue
            kinds[rom[q]] = kinds.get(rom[q], 0) + 1
            q += 13
    print("  entry kinds (byte 0): " + ", ".join(f"0x{k:02X} x{v}" for k, v in sorted(kinds.items())))
    for p in bad:
        print(f"  does not parse: 0x{p:08X} (types {blocks[p][:6]})")


if __name__ == "__main__":
    for mdl in (sys.argv[1:] or ["kn6000", "kn6500"]):
        main(mdl)
