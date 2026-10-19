#!/usr/bin/env python3
"""sysex_desc.py -- question: which M3 parameter ids does the KN7000 (941) map to/from SysEx, and with
which message templates?  Reads the descriptor pointers returned by the TX lookup 0x484BFE64 (M3 id ->
descriptor) and dumps each descriptor: +0 id u32, +4 type u16, +6 subtype u16, +8 template ptr,
+0xC flags u16, +0xE min u16, +0x10 max u16; template bytes printed up to F7."""
import sys; sys.path.insert(0, '.')
from romread import *
TX = [(0x0,0x486153E8),(0x3,0x48615408),(0x4,0x4861625C),(0x8,0x4861559C),(0x80,0x48615FDC),(0xA0,0x48615F1C),
      (0x8001,0x486153C8),(0x8002,0x486154FC),(0x8010,0x4861561C),(0x8020,0x486155BC),(0x8033,0x48615EFC),
      (0x8080,0x48615FFC),(0x8081,0x4861601C),(0x8082,0x4861603C),(0xA000,0x486155DC),(0xA100,0x4861563C),
      (0xA200,0x4861567C),(0xC000,0x48615DBC),(0xC004,0x48615DDC),(0xC080,0x48615DFC),(0xC082,0x48615E1C),
      (0xC083,0x48615E3C),(0xD000,0x48615E7C),(0xD001,0x48615E9C),(0xD002,0x48615EBC),(0xD003,0x48615EDC),
      (0xD00A,0x48615E5C),(0xE000,0x48615F7C),(0x600014,0x48616060),(0x702023,0x48615EBC)]
def tmpl(p):
    out=[]
    for i in range(40):
        c=u8(p+i); out.append(c)
        if c==0xF7: break
    return " ".join(f"{c:02X}" for c in out)
for key,d in TX:
    print(f"M3 {key:06X} -> desc {d:08X}: id {u32(d):08X} type {u16(d+4)} sub {u16(d+6):#x} flags {u16(d+12):#06x} min {u16(d+14)} max {u16(d+16)}  tmpl@{u32(d+8):08X}: {tmpl(u32(d+8))}")
