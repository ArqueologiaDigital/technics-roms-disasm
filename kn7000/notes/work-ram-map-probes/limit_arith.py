#!/usr/bin/env python3
"""Arithmetic behind the 0x4D800 picture-import limit (KN7000, func_485812EA).
Question answered: which candidate explanations of 0x4D800 fit exactly, and how much
slack each leaves.  No inputs; run: python3 limit_arith.py"""
L = 0x4D800
SCR = 0x502B8000
def bmp(w, h, bpp):
    row = ((w * bpp + 31) // 32) * 4
    pal = (1 << bpp) * 4 if bpp <= 8 else 0
    return 14 + 40 + pal + row * h
print(f"limit            = {L:#x} = {L} bytes = {L/1024} KiB = 640 x {L//640} bytes")
print(f"300 KiB + 10 KiB = {0x4B000 + 0x2800:#x}")
for w, h, b in [(640, 480, 8), (640, 480, 4), (640, 480, 1), (640, 480, 16), (640, 480, 24), (640, 240, 24), (640, 240, 8)]:
    s = bmp(w, h, b)
    print(f"BMP {w}x{h} {b:2d}bpp = {s:7d} ({s:#x})  {'fits, spare %d' % (L - s) if s <= L else 'too big'}")
rgb = 640 * 240 * 3
print(f"RGB 640x240x3    = {rgb:#x}; file+RGB = {L + rgb:#x}; end = {SCR + L + rgb:#x}")
print(f"0xC0000 window   -> max file {0xC0000 - rgb:#x}; slack above importer {0xC0000 - L - rgb:#x} (ends {SCR + 0xC0000:#x})")
print(f"0xC8000 scratch  -> max file {0xC8000 - rgb:#x}; slack above importer {0xC8000 - L - rgb:#x} (ends {SCR + 0xC8000:#x})")
print(f"song memory 0x501AB9A0 + {L:#x} = {0x501AB9A0 + L:#x}; /40000 notes = {L/40000:.2f} bytes/note")
full, small = 0x50297FFC - 0x502031A0, 0x50297FFC - 0x502031A0 - 0x40000
for n, s in (("full", full), ("small", small)):
    heap = s - 0xDF0
    print(f"pool {n}: size {s:#x}, heap {heap:#x}, max-size blocks ({L + 4:#x}) that fit: {heap // (L + 4)}")
print(f"decoder max offset = {3 * (0xEF * 0x280 + 0x27F) + 2:#x} -> last byte {SCR + L + 3 * (0xEF * 0x280 + 0x27F) + 2:#x}")
