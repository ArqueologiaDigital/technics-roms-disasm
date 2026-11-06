#!/usr/bin/env python3
"""names_sd_frames: are program 941's .data bytes at 0x50007E94..0x50007EC5 (labelled
SdReadBlockCmd_Var_2 / SdReadBlockCmd_Table until 2026-11-06) the IC18 boot ROM's mode-2 SD
frames SdFrameR2Cmd0/5/3/6/7, and how do they split?

Reads the .data image (program file 0x3B0B78 is RAM 0x50000010: ResetEntry's copy,
notes/mn10300-names-probes/ramgui_reset_layout.py) and IC18's first 64 KB, looks the 50 bytes up
in IC18 and prints each 10-byte frame {u16 clock mode, u16 response type, 0x40|n, 4 argument
bytes (big-endian), CRC}.  Expected (2026-11-06): found once in IC18; frames n = 0, 5, 3, 6, 7
at 0x50007E94 + 10 k, arguments 0x00000F00, 0, 0x00000100, 0, 0; every CRC byte 0xFF (computed at
run time by SdCardRegRead / SdReadBlockCmd).

usage (from kn7000/):
  python3 -I notes/kn7000-names-probes/names_sd_frames.py
"""
import struct

P = open("baserom/kn7000_program.rom", "rb").read()
B = open("baserom/kn7000_ic18_boot.bin", "rb").read()
RAM0, FILE0 = 0x50000010, 0x3B0B78
lo, hi = 0x50007E94, 0x50007E94 + 50
blk = P[FILE0 + lo - RAM0:FILE0 + hi - RAM0]
hits = [i for i in range(len(B) - len(blk)) if B[i:i + len(blk)] == blk]
print(f"941 .data 0x{lo:08X}..0x{hi - 1:08X}: {blk.hex()}")
print(f"found in IC18's boot ROM at file offset(s): {[hex(h) for h in hits]}")
for k in range(5):
    f = blk[10 * k:10 * k + 10]
    clk, rsp = struct.unpack_from("<HH", f)
    print(f"  0x{lo + 10 * k:08X}: clock mode {clk}, response type {rsp}, cmd 0x{f[4]:02X} (n = {f[4] & 0x3F}), "
          f"argument 0x{struct.unpack_from('>I', f, 5)[0]:08X}, CRC 0x{f[9]:02X}")
