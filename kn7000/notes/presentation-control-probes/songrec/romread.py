#!/usr/bin/env python3
"""romread.py -- helpers to read KN7000 941 program ROM by CPU address (program 0x484..., lib 0x4C0...)."""
import struct, sys
ROMP = "/home/fsanches/compartilhado/kn7000_disassembly/baserom/kn7000_program.rom"
rom = open(ROMP, "rb").read()
BASE = 0x48400000; LIBFILE = 0x3B8FD1
def off(a):
    if a >= 0x4C000000: return LIBFILE + (a - 0x4C000000)
    return a - BASE
def b(a, n=1): return rom[off(a):off(a)+n]
def u8(a): return rom[off(a)]
def s8(a): return struct.unpack_from("<b", rom, off(a))[0]
def u16(a): return struct.unpack_from("<H", rom, off(a))[0]
def u32(a): return struct.unpack_from("<I", rom, off(a))[0]
