"""Three things the passes cannot place (hd-ae5000_v1_15i.s, hdae5000_ui_display.s).

  * The ROM header: bytes 4-7 after "XAPR" are a 32-bit pointer to the end of the .data
    image -- 0x002e198a in v1.15i, which is HDAE5000_DataSegmentImage + 0x9d4, the count of
    the boot copy loop; v2.01i 0x002f95e6, v2.06i 0x002fa134, v1.10i 0x002e17fa: each its
    own image's end.  Spelled `.long HDAE5000_Init_Data_End` (v2.x splits it as text).
  * HDAE5000_DATA_COPY_DEST, where the boot copy loop puts the image: `ld XDE,0x0023c914`
    right before `ld XHL,<image>` (v1.15i 0x28c1e2).  Every RAM pointer into the image (UI
    record variables, the class records' propname lists) follows from it.
  * The frame handler starts with `inc 1,(0x22b3da)` (0x28c103), a byte counter nothing in
    v1.15i reads; the passes left it after the previous routine's ret.
"""
import re
from _edit import read, write, replace

# Since 2026-10-31 the v2.x trees spell the header pointer the same way (lane hdae-ledgers), so a
# replay that starts from the current hdae5000_v2_01i/ already has it.
if b"\t.long HDAE5000_Init_Data_End\t; the end of the .data image" not in read("hd-ae5000_v1_15i.s"):
  replace("hd-ae5000_v1_15i.s", [
    (b'\t.ascii "XAPR\\212"\t; Magic identifier ("XAPR" checked by main CPU)\n'
     b'\t.byte 0x95\t; Version byte\n\t.byte 0x2f, 0x00\t; Unknown (possibly size/flags)\n',
     b'\t.ascii "XAPR"\t\t; magic identifier ("XAPR" checked by the main CPU)\n'
     b'\t.long HDAE5000_Init_Data_End\t; the end of the .data image (every version: its own image\'s end)\n'),
  ])
f = "hdae5000_ui_display.s"
s = read(f)
s, n = re.subn(rb"\.equ HDAE5000_DATA_COPY_DEST, 0x2394ce\t[^\n]*\n",
               b".equ HDAE5000_DATA_COPY_DEST, 0x23c914\t; Init data copy destination: the boot copy loop's `ld xde` (v1.15i 0x28c1e2)\n", s)
assert n == 1
s, n = re.subn(rb"(\tpop xiz\n\tret\n)\tinc\t1, \(0x22b3da:24\)\n", rb"\1", s)
assert n == 1
s, n = re.subn(rb"(HDAE5000_Frame_Handler:\n(?:\t;[^\n]*\n)*)(HDAE5000_Frame_Handler_Status:\n)",
               rb"\1\tinc\t1, (HDAE5000_RAM_FrameCount:24)\t; v1.x only: counts frames; read nowhere in this ROM\n\2", s)
assert n == 1
s = s.replace(b".equ HDAE5000_DATA_COPY_DEST,", b".equ HDAE5000_RAM_FrameCount, 0x22b3da\t; byte: HDAE5000_Frame_Handler adds 1 each frame (v1.x)\n.equ HDAE5000_DATA_COPY_DEST,", 1)
write(f, s)
print("ok")
