"""The v2.01i .data image's size, tail and copy-routine header, which no tool rewrites.

`hdae5000_version_stale_comments.py v2_01i --fix` (IMAGE, SYM, OPER, BYTES) rewrote the
addresses quoted in v2.01i's comments.  What it cannot rewrite is a quoted SIZE or OFFSET,
and the tail of the ROM, whose header it does not pair with v2.06i's.  The v2.01i values,
read from the copy routine's own operands (hdae5000_ui_display.s, HDAE5000_Clear_Work_Buffer):

    clear  0xf4ce bytes (62,670) from HDAE5000_RAM_NamingText = 0x22a000, i.e. up to
           0x2394ce, where the copied image starts       (v2.06i: 0xf52a, 62,762)
    copy   0x0c48 bytes (3,144) from ROM 0x2f899e to RAM 0x2394ce
                                                          (v2.06i: 0x0c82, 3,202 from
                                                           0x2f94b2 to 0x23952a)
    image  0x2f899e - 0x2f95e5; HDAE5000_Init_Data_End = 0x2f95e6 (llvm-nm of the
           v2.01i ELF), so the 0x00 fill after its `.short 14` is
           0x300000 - 0x2f95e8 = 0x6a18 = 27,160 bytes.

The fill is respelled `.zero 27160`, as v2.06i spells its own (`.zero 24266`), instead of
`.org 0x300000 - 0x280000, 0x00`: same bytes, and kn5000_source_coverage.py counts a
`.zero` as typed data (it counted the `.org` fill as instructions).

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/19_data_image_sizes.py
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")


def rep(fn, old, new):
    p = os.path.join(T, fn)
    s = open(p, "rb").read()
    assert s.count(old) == 1, (fn, s.count(old), old[:60])
    open(p, "wb").write(s.replace(old, new))


rep("hdae5000_init_data.s",
    b"; HDAE5000 initialised .data image  (ROM 0x2f899e - 0x2f95e5, 0x0c82 bytes)\n",
    b"; HDAE5000 initialised .data image  (ROM 0x2f899e - 0x2f95e5, 0x0c48 bytes)\n")
rep("hdae5000_init_data.s",
    b"\t; pinned independently of that parse: hd-ae5000_v2_06i.s:126 records that\n"
    b"\t; this image is copied to 0x2394ce, and 0x2f911c - 0x2f899e = 0x79a =\n",
    b"\t; pinned independently of that parse: HDAE5000_Clear_Work_Buffer copies\n"
    b"\t; this image to 0x2394ce, and 0x2f911c - 0x2f899e = 0x77e =\n")
rep("hdae5000_init_data.s",
    b"\t\t\t\t; the copied image is 0x23a115 = 0x2394ce + 0x0c82 - 1\n",
    b"\t\t\t\t; the copied image is 0x23a115 = 0x2394ce + 0x0c48 - 1\n")
rep("hdae5000_init_data.s",
    b"; Tail of the ROM (0x2fa134-0x2fffff)\n"
    b";   The .data image ends at 0x2f95e5 - HDAE5000_Clear_Work_Buffer copies\n"
    b";   exactly 0x0c82 bytes.  The 0x000e word at 0x2fa134 is the first thing\n",
    b"; Tail of the ROM (0x2f95e6-0x2fffff)\n"
    b";   The .data image ends at 0x2f95e5 - HDAE5000_Clear_Work_Buffer copies\n"
    b";   exactly 0x0c48 bytes.  The 0x000e word at 0x2f95e6 is the first thing\n")
rep("hdae5000_init_data.s",
    b"\t.short 14\n\t.org 0x300000 - 0x280000, 0x00\t; 0x00 fill to the end of the 512 KiB ROM\n",
    b"\t.short 14\n\t.zero 27160\n")
rep("hdae5000_ui_display.s",
    b"\t; Part 1: Clear 0xF52A bytes (62,762) at 0x22A000 using word operations\n"
    b"\t; Part 2: Copy 0x0C82 bytes (3,202) from ROM 0x2F94B2 to RAM 0x23952A\n",
    b"\t; Part 1: Clear 0xF4CE bytes (62,670) at 0x22A000 using word operations,\n"
    b"\t;         up to 0x2394CE where Part 2's image starts\n"
    b"\t; Part 2: Copy 0x0C48 bytes (3,144) from ROM 0x2F899E to RAM 0x2394CE\n")
print("ok")
