#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""mn10300_insn_len.py -- the length of an MN10300 instruction, and where instructions start.

QUESTION ANSWERED
-----------------
"Does CPU address v of a converted MN10300 image start an instruction, or does it land inside one?"
tools/gen_data_s.py asks it of every value it would type as a pointer into code: a word that lands
inside an instruction is no pointer (it is text or a number that happens to look like a code address:
"><SH" = 0x48533C3E, lane mn10300-typer 2026-10-31).

insn_len() is the decoder of the KN7000 MAME driver's CPU core, mn10300_insn_length.h (kn7000_mame,
src/devices/cpu/mn10300/), ported line for line: the length follows from the first byte, and from the
second for 0xFE.  That header was checked against MAME's unidasm over the KN7000 program, 550,328 of
550,328 legal instructions; kn7000/notes/mn10300-typer-probes/insn_starts_check.py checks this port
against what kn7asm assembles, in every MN10300 tree.

Starts decodes forward from an anchor (an address the converted code names as a function entry or a
branch target the generator placed on an instruction, never a `loc_<ADDR>` an `.equ` may have put inside
an instruction) to the address asked about.
"""

import bisect


def insn_len(op, op2=0):
    """Bytes in the MN10300 instruction whose first two bytes are op, op2."""
    if op < 0xF0:
        lo = op & 3
        hi = op & 0xF0
        if hi == 0x00:
            return 1 if lo == 0 else 3            # clr / store to (abs16)
        if hi == 0x10:
            return 1                              # ext*
        if hi == 0x20:                            # add imm8 / mov imm16
            return 2 if op < 0x24 else 3 if op < 0x28 else 2 if op < 0x2C else 3
        if hi == 0x30:
            return 3 if op < 0x3C else 1          # (abs16), dD / mov sp, aD
        if hi == 0x40:
            return 1 if lo < 2 else 2             # inc / mov (d8, sp)
        if hi == 0x50:
            return 1 if op < 0x58 else 2          # inc4, asl2 / mov (d8, sp)
        if hi in (0x60, 0x70):
            return 1                              # mov dD, (aM) / mov (aM), dD
        if hi in (0x80, 0x90, 0xA0, 0xB0):
            return 2 if ((op >> 2) & 3) == (op & 3) else 1   # the imm8 forms: src == dst
        if hi == 0xC0:
            if op <= 0xCA:
                return 2                          # bcc, bra
            return {0xCB: 1, 0xCC: 3, 0xCD: 5}.get(op, 2)    # nop, jmp d16, call d16, movm
        if hi == 0xD0:
            if op <= 0xDB:
                return 1                          # lcc, lra, setlb
            return {0xDC: 5, 0xDD: 7}.get(op, 3)  # jmp d32, call d32, retf / ret
        return 1                                  # 0xE0: add dS, dD
    if op <= 0xF6:
        return 2
    if op in (0xF8, 0xF9):
        return 3
    if op in (0xFA, 0xFB):
        return 4
    if op in (0xFC, 0xFD):
        return 6
    if op == 0xFE:
        if op2 <= 0x02:
            return 7                              # bset / bclr / btst imm8, (abs32)
        if 0x80 <= op2 <= 0x82:
            return 5                              # ... (abs16)
        return 2
    return 1                                      # 0xF7, 0xFF: illegal


class Starts:
    """Instruction starts of code decoded forward from anchors.

    rom: the image's bytes; anchors: CPU addresses known to start an instruction; off_of(cpu): the
    file offset of a code address (None outside the decodable code); span: how far past an anchor
    the decoder goes (an anchor further back than this is not trusted to reach)."""

    def __init__(self, rom, anchors, off_of, span=0x4000):
        self.rom, self.off_of, self.span = rom, off_of, span
        self.anchors = sorted(set(anchors))
        self._memo = {}

    def run(self, a):
        """The instruction starts from anchor a up to the next anchor (or a.span on)."""
        r = self._memo.get(a)
        if r is None:
            i = bisect.bisect_right(self.anchors, a)
            end = min(self.anchors[i] if i < len(self.anchors) else a + self.span, a + self.span)
            r, p = set(), a
            o = self.off_of(a)
            while p < end and o is not None and o + 1 < len(self.rom):
                r.add(p)
                n = insn_len(self.rom[o], self.rom[o + 1])
                p, o = p + n, o + n
            self._memo[a] = r
        return r

    def is_start(self, v):
        """True / False when v is / is not an instruction start of the decoded code; None when no
        anchor reaches it (v is not in the code this oracle knows)."""
        if self.off_of(v) is None:
            return None
        i = bisect.bisect_right(self.anchors, v) - 1
        if i < 0 or v - self.anchors[i] >= self.span:
            return None
        return v in self.run(self.anchors[i])


import re  # noqa: E402

# Names the generators put only on instruction starts: a function entry (func_<ADDR>, <name>_entry) and
# a sibling's branch target (<entry>_L<hex>, gen_image_s.py labels it only where it emitted an instruction).
# Not loc_<ADDR>: gen_program_s.py / gen_image_s.py declare one with an .equ when the typed data points
# inside an instruction.
ANCHOR_NAME = re.compile(r"^func_[0-9A-F]{8}$|_entry$|_L[0-9a-f]+_*$")
HEADER = re.compile(r"^# (\S+)\s+\((?:lib )?CPU (0x[0-9a-fA-F]+)\)", re.M)
MNBASE = re.compile(r"^\.mnbase\s+(0x[0-9a-fA-F]+)", re.M)


def oracle(rom, base, src_files, labels, span=0x10000):
    """Starts for a converted image: the function headers (`# Name  (CPU 0x...)`) of its code sources
    and the labels named as ANCHOR_NAME says are the anchors; a CPU address is read at the file offset
    that the image's base or one `.mnbase` of the sources gives it (None when no or several do).
    labels: (name, CPU address) pairs."""
    texts = [open(f, encoding="latin-1").read() for f in src_files]
    bases = {base} | {int(m.group(1), 16) for t in texts for m in MNBASE.finditer(t)}
    n = len(rom)

    def off_of(v):
        c = [v - b for b in bases if 0 <= v - b < n]
        return c[0] if len(c) == 1 else None

    anchors = {a for nm, a in labels if ANCHOR_NAME.search(nm)}
    anchors |= {int(m.group(2), 16) for t in texts for m in HEADER.finditer(t)}
    return Starts(rom, [a for a in anchors if off_of(a) is not None], off_of, span)
