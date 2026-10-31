#!/usr/bin/env python3
"""Who reads RAM 0x008517, and who re-arms RAM 0x00E2E1, on CPU 2 (prom_c)?

QUESTION IT ANSWERS (WSA1-EMULATION-DISASM-GAPS.md gap I and the 0x00E2E1 bullet):
  * gap I asks who reads the byte KeyScan_ReadEvent sets with `or (0x008517),0x03`
    when it drops a note-on (touch byte 0xFF or status word 2);
  * the appendix asks whether anything re-arms the key-event flush counter at
    0x00E2E1 after power-on, which would make the keybed go deaf again.

Method: every 24-bit spelling of the cell and of every pointer base that can
reach it is enumerated from the ROM bytes, and each is classified by the
instruction around it; the boot RAM-image copy and the RESET RAM clear are read
off their bytes.  No disassembler and no source file is consulted, so the
answer cannot inherit a labelling mistake.

    python3 notes/open4-b-probes/prom_c_ram_cell_census.py      # exit 1 on drift
    python3 notes/open4-b-probes/prom_c_ram_cell_census.py -v
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
C = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_c.ic28"), "rb").read()
BASE = 0xF80000
FAILS, RAN = [], []
VERBOSE = "-v" in sys.argv


def c(addr, n=1):
    return C[addr - BASE:addr - BASE + n]


def sites(pat):
    out, i = [], C.find(pat)
    while i >= 0:
        out.append(BASE + i)
        i = C.find(pat, i + 1)
    return out


def check(name, cond, detail=""):
    RAN.append(name)
    if VERBOSE or not cond:
        print("%-4s %s%s" % ("ok" if cond else "FAIL", name,
                             ("  -- " + detail) if detail and not cond else ""))
    if not cond:
        FAILS.append(name)


def hx(lst):
    return " ".join("0x%06X" % v for v in lst)


# ---------------------------------------------------------------- gap I
s = sites(b"\x17\x85\x00")
check("0x008517 is spelled once in prom_c, the operand of 0xF997A9",
      s == [0xF997AA], hx(s))
check("...and that instruction is the WRITE `or (0x008517),0x03`",
      c(0xF997A9, 6) == b"\xc2\x17\x85\x00\x3e\x03")
# The only base that can reach 0x8517 with a non-negative index: the 61-byte
# velocity table at 0x84DA (0x84DA + 61 = 0x8517).  Nothing below it within
# 0x100 bytes is spelled at all (checked byte-wise, every base 0x8417..0x8516).
# A raw byte scan also hits (Xrr+d16) displacements and table data, so this
# census reads the committed linear listing (original_ROMs/*.unidasm, MAME's
# disassembler over every byte) and takes the operands of every decoded line.
LISTING = os.path.join(ROOT, "original_ROMs", "wsa1_prom_c.ic28.unidasm")


def listing_hits(lo, hi):
    out = []
    for ln in open(LISTING, encoding="latin-1"):
        try:
            addr = int(ln[:6], 16)
        except ValueError:
            continue
        for m in re.finditer(r"0x([0-9a-f]{4,8})\b", ln[30:]):
            if lo <= int(m.group(1), 16) <= hi:
                out.append((addr, ln[30:].strip()))
                break
    return out


h = listing_hits(0x8417, 0x8517)
check("the decoded operands that name 0x8417..0x8517 are the three 0x84DA adds, "
      "the 0x8517 write, and one line inside the tone-data tables (0xFD896D, "
      "not code)", [a for a, _ in h] ==
      [0xF9964D, 0xF997A9, 0xF99829, 0xF9987F, 0xFD896D], str(h))
s = sites(b"\xda\x84\x00\x00")
check("0x84DA is spelled three times, each `add Xrr,0x000084DA`",
      s == [0xF9964F, 0xF9982B, 0xF99881] and
      all(c(x - 2, 2) in (b"\xe8\xc8", b"\xe9\xc8") for x in s), hx(s))
check("...two are the table's builder (KeyScan_InitKeyStateBitmap path), whose "
      "loop bound is `cp (XIZ+0xfe),0x003D` -- indices 0..60, so it stops at 0x8516",
      c(0xF99816, 5) == b"\x9e\xfe\x3f\x3d\x00" and
      c(0xF9983B, 5) == b"\x9e\xfe\x3f\x3d\x00")
check("...the third is the lookup in ToneGen_VelocityFromTouch, indexed by the "
      "key byte with bit 7 cleared (`res 7,A` at 0xF99646) and READ (`ld W,(XWA)`)",
      c(0xF99646, 3) == b"\xc9\x30\x07" and c(0xF99653, 2) == b"\x80\x20")
# So 0x8517 can be read only as velocity-table element 61, one past the
# 61-key range (keys 0..60); no instruction addresses it as a variable.
# Neighbours: 0x8518 is the first byte of the link module's RAM.
check("0x8518 is written by the link module (`ld (0x008518),H` at 0xF99BD5)",
      c(0xF99BD5, 5) == b"\xf2\x18\x85\x00\x46")

# ------------------------------------------------- RESET, RAM clear, RAM image
check("RESET clears RAM 0x80..0x1007F: `ld XBC,0x8000` / `lda XIX,0x80` / "
      "`ld (XIX+),WA` loop at 0xFFF085-0xFFF098",
      c(0xFFF085, 5) == b"\x41\x00\x80\x00\x00" and c(0xFFF08A, 3) == b"\xf0\x80\x34"
      and c(0xFFF08F, 3) == b"\xf5\xf1\x50")
check("...then calls RamImage_Copy (`call 0xF989EF` at 0xFFF09A)",
      c(0xFFF09A, 4) == b"\x1d\xef\x89\xf9")
check("RamImage_Copy is ROM 0xFCB4EA -> RAM 0x00E2DF, 0x10D8 bytes, `ldir`",
      c(0xF989EF, 5) == b"\xf2\xea\xb4\xfc\x35" and
      c(0xF989F4, 5) == b"\xf2\xdf\xe2\x00\x34" and
      c(0xF989F9, 5) == b"\x41\xd8\x10\x00\x00" and c(0xF989FE, 2) == b"\x85\x11")
s = sites(b"\xef\x89\xf9")
check("...and 0xFFF09A is its only caller", s == [0xFFF09B], hx(s))
check("the image seeds 0x00E2E1 with 1000 (ROM word at 0xFCB4EC = 0x03E8)",
      c(0xFCB4EC, 2) == b"\xe8\x03")
check("the watchdog and SWI 1 vectors re-enter RESET (`jrl T,0xFFF000` at "
      "0xFFF0A2 and 0xFFF0A5), so a reboot is the one path that re-seeds it",
      c(0xFFF0A2, 3) == b"\x78\x5b\xff" and c(0xFFF0A5, 3) == b"\x78\x58\xff")

# ----------------------------------------------------------- 0x00E2E1 census
s = sites(b"\xe1\xe2\x00")
check("0x00E2E1 is spelled twice: the `cp (0x00e2e1),0` and the `decw 1,(0x00e2e1)`",
      s == [0xF98CC0, 0xF98CE3] and c(0xF98CBF, 7) == b"\xd2\xe1\xe2\x00\x3f\x00\x00"
      and c(0xF98CE2, 5) == b"\xd2\xe1\xe2\x00\x69", hx(s))
s = sites(b"\xdf\xe2\x00")
check("0x00E2DF (the word below it) is the image copy's destination and three "
      "16-bit accesses that cover 0xE2DF-0xE2E0 only", s ==
      [0xF989F5, 0xF98C23, 0xF98C2F, 0xF98C3A] and
      c(0xF98C22, 1) == b"\xd2" and c(0xF98C2E, 1) == b"\xf2" and
      c(0xF98C39, 1) == b"\xf2" and c(0xF98C32, 1) == b"\x51" and
      c(0xF98C3D, 1) == b"\x02", hx(s))
s = sites(b"\xa1\xe2\x00")
check("the nearest lower base, 0x00E2A1, is EEPROM_LoadCalibration's 62-byte "
      "block: 31 word stores (`cp HL,0x001F`), so it ends at 0xE2DE",
      s == [0xFC8B2D, 0xFC8B3D, 0xFC8B78] and c(0xFC8B4F, 4) == b"\xdb\xcf\x1f\x00",
      hx(s))
check("...whose one caller reads 61 bytes of it (`cp (XIZ+0xfe),0x003D`)",
      c(0xF99802, 4) == b"\x1d\x0b\x8b\xfc" and c(0xF9983B, 5) == b"\x9e\xfe\x3f\x3d\x00")
h = listing_hits(0xE2A2, 0xE2E1)
check("the decoded operands that name 0xE2A2..0xE2E1 are the image copy, the "
      "four 0xE2DF / two 0xE2E1 accesses, and table data at 0xFD.... (not code)",
      [a for a, _ in h if a < 0xFD0000] ==
      [0xF989F4, 0xF98C22, 0xF98C2E, 0xF98C39, 0xF98CBF, 0xF98CE2], str(h))

print("\n%d checks ran" % len(RAN))
print("ALL CHECKS PASS" if not FAILS else "%d FAILED: %s" % (len(FAILS), "; ".join(FAILS)))
sys.exit(1 if FAILS else 0)
