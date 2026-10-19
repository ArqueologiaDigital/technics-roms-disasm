#!/usr/bin/env python3
"""refs.py -- who calls, calls-s, jumps, branches to, or points into [LO, HI)?

Brute force over every byte offset of a KN7000 program image (build 941 layout:
region 1 at CPU 0x48400000 = file 0, library at file offset LIB_FILE = CPU
0x4C000000). Decodes, at every offset, the PC-relative control transfers
    cc d16 (jmp), dc d32 (jmp), cd d16 (call), dd d32 (call),
    fa ff d16 (calls), fc ff d32 (calls),
    c0..ca d8 (Bcc/bra), f8 e8..eb d8 (bvc/bvs/bnc/bns)
and reports each one whose target lies in [LO, HI) while its own address does
not; plus every 32-bit little-endian word (any alignment) whose value lies in
[LO, HI). Byte-level brute force over-reports (false positives inside other
instructions' operands); each hit has to be checked against a listing.

Usage: python3 refs.py ROM LO HI [LIB_FILE]
  e.g. python3 refs.py baserom/kn7000_program.rom 0x4842829F 0x484284B4
"""
import struct
import sys

rom = open(sys.argv[1], 'rb').read()
lo = int(sys.argv[2], 0)
hi = int(sys.argv[3], 0)
lib_file = int(sys.argv[4], 0) if len(sys.argv) > 4 else 0x3B8FD1


def cpu(off):
    return 0x48400000 + off if off < lib_file else 0x4C000000 + off - lib_file


def s8(b):
    return b - 256 if b >= 128 else b


hits = []
n = len(rom)
for off in range(n):
    pc = cpu(off)
    b0 = rom[off]
    tgt = None
    kind = None
    if b0 in (0xCC, 0xCD) and off + 3 <= n:
        tgt = pc + struct.unpack_from('<h', rom, off + 1)[0]
        kind = 'jmp16' if b0 == 0xCC else 'call16'
    elif b0 in (0xDC, 0xDD) and off + 5 <= n:
        tgt = (pc + struct.unpack_from('<i', rom, off + 1)[0]) & 0xFFFFFFFF
        kind = 'jmp32' if b0 == 0xDC else 'call32'
    elif b0 == 0xFA and off + 4 <= n and rom[off + 1] == 0xFF:
        tgt = pc + struct.unpack_from('<h', rom, off + 2)[0]
        kind = 'calls16'
    elif b0 == 0xFC and off + 6 <= n and rom[off + 1] == 0xFF:
        tgt = (pc + struct.unpack_from('<i', rom, off + 2)[0]) & 0xFFFFFFFF
        kind = 'calls32'
    elif 0xC0 <= b0 <= 0xCA and off + 2 <= n:
        tgt = pc + s8(rom[off + 1])
        kind = 'b8'
    elif b0 == 0xF8 and off + 3 <= n and 0xE8 <= rom[off + 1] <= 0xEB:
        tgt = pc + s8(rom[off + 2])
        kind = 'bf8'
    if tgt is not None and lo <= tgt < hi and not (lo <= pc < hi):
        hits.append((pc, kind, tgt))
    if off + 4 <= n:
        w = struct.unpack_from('<I', rom, off)[0]
        if lo <= w < hi:
            hits.append((pc, 'word', w))

for pc, kind, tgt in hits:
    print('%08X  %-7s -> %08X' % (pc, kind, tgt))
