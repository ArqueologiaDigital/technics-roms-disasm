#!/usr/bin/env python3
# Prints the ROM facts the ram-verify map rests on that are data, not code:
#  - .data image words (RAM addr -> initial value) for the Malloc control block, the four
#    task message-queue slots at 0x5000757C, and the pointer words 0x500058B8/0x50007A40/0x50007DC0;
#  - the RTOS configuration words at ROM 0x487B8B44..0x487B8B58;
#  - the JPEG 8x8 block pointer table at ROM 0x487390C0;
#  - signatures 'TCMP' (0x487312E8) and 'TPAD' (0x48729858), zlib version (0x48664864);
#  - the reset-time clear loops of program 941 and program 942 (SP7001).
# usage (any cwd): python3 rom_facts.py
import struct, re
R = "/home/fsanches/compartilhado/technics-roms-disasm/kn7000/baserom/"
d = open(R + "kn7000_program.rom", "rb").read()
B = 0x48400000
def rom(a, n=4): return d[a - B:a - B + n]
def w(a): return struct.unpack("<I", rom(a))[0]
def ram(a): return w(a - 0x50000010 + 0x487B0B78)
print("Malloc control  0x500006E0..E8:", [hex(ram(a)) for a in (0x500006E0, 0x500006E4, 0x500006E8)])
for s in range(4):
    b = 0x5000757C + s * 0x38
    print(f"msg slot {s} @{b:08X}: count1={ram(b+4):#x} bufA={ram(b+0x2C):#x} count2={ram(b+0x30)>>16:#x} bufB={ram(b+0x34):#x}")
for a in (0x500058B8, 0x50007A40, 0x50007DC0):
    print(f".data {a:08X} = {ram(a):#010x}")
print("RTOS config 0x487B8B44..58:", [hex(w(a)) for a in range(0x487B8B44, 0x487B8B5C, 4)])
print("JPEG block table 0x487390C0:", [hex(w(a)) for a in range(0x487390C0, 0x487390F0, 4)])
print("sig 0x487312E8:", rom(0x487312E8), " sig 0x48729858:", rom(0x48729858), " zlib:", rom(0x48664864, 6))
for name in ("kn7000_program.rom", "kn7000_program_sp7001.rom"):
    x = open(R + name, "rb").read()
    for m in re.finditer(rb'\xfc\xcd(....)\xa5\x00\xc3.\xfc\xdc(....)', x[0x10000:0x10100]):
        ln, st = struct.unpack("<I", m.group(1))[0], struct.unpack("<I", m.group(2))[0]
        print(f"{name}: clear at {0x48410000+m.start():#x}: {st:#010x}..{st+ln:#010x} (len {ln:#x})")
