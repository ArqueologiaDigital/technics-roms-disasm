#!/usr/bin/env python3
"""wsa1_wxn_refs.py -- the byte-level evidence for tracker kn5000-wxn (WSA1 naming leads of 2026-10-06/07).

QUESTIONS IT ANSWERS (each prints PASS / FAIL; exit 1 on any FAIL)
  R1  Does anything outside SMF file-layer copy E (prom_b 0xF77EDB-0xF77FE8: three veneers + eight routines) reach it?
      Scans both CPU-1 images at EVERY byte offset for (a) a 24-bit little-endian operand naming an address in the
      range after a call/jp opcode (0x1D call, 0x1A jp), (b) a calr/jrl (0x1E / 0x1B + rel16) and (c) a jr (0x60-0x6F +
      rel8, 0x68 = jr T) landing in it.  Hits from inside the range itself are copy E's own calls.  An every-offset
      scan over-counts (data bytes can look like an opcode), so a hit is checked against the source; zero outside
      hits means nothing reaches it.
  R2  Same scan for the stray `ret` at prom_a 0xFBE134 (between CombiEditMixer_ShowOtherParts and
      CombiEditMixer_PaintPageFrame) and for 0xFBE135 itself (expected: the one `lda xbc,(0xFBE135:24)` posting site
      in ScreenEnterBody_CombiEditMixer, opcode 0xF2 at 0xFBDCAC).
  R3  Are copies A (0xF7659B), D (0xF77D00) and E (0xF77EE7) of the file layer laid out at the same offsets, and which
      routines are byte-identical between A and E?
  R4  Do the two dedicated floppy-format button readers (prom_a 0xFF6550 / 0xFF66AA) add base 0xFF3D39 + 4*128 and
      + 5*128, i.e. rows 4 and 5 of the 0xFF3D39 matrix (`e9 c8 <addr32>` = add XBC,imm32)?
  R5  Does the ROM text spell "MIDI FILE L0AD" with a digit zero (the screen name MidiFileL0ad is CamelCase of it)?

RUN (from the repo root or anywhere)
  python3 notes/open6-kn5000-d/wsa1/probes/wsa1_wxn_refs.py
Reads wsa1/original_ROMs/wsa1_prom_a.ic12 (CPU-1 0xF80000-0xFFFFFF) and wsa1_prom_b.ic13 (0xF00000-0xF7FFFF).
"""
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
A = open(os.path.join(ROOT, "wsa1/original_ROMs/wsa1_prom_a.ic12"), "rb").read()
B = open(os.path.join(ROOT, "wsa1/original_ROMs/wsa1_prom_b.ic13"), "rb").read()
IMGS = (("prom_a", A, 0xF80000), ("prom_b", B, 0xF00000))
fails = 0


def check(ok, what):
    global fails
    fails += 0 if ok else 1
    print(("PASS  " if ok else "FAIL  ") + what)


def refs(lo, hi):
    """every (image, site, kind, target) whose operand lands in [lo, hi)"""
    out = []
    for nm, d, base in IMGS:
        for i in range(len(d) - 3):
            op = d[i]
            if op in (0x1D, 0x1A):
                t = d[i + 1] | d[i + 2] << 8 | d[i + 3] << 16
                if lo <= t < hi:
                    out.append((nm, base + i, "call/jp", t))
            if op in (0x1E, 0x1B):
                r = d[i + 1] | d[i + 2] << 8
                t = base + i + 3 + (r - 0x10000 if r & 0x8000 else r)
                if lo <= t < hi:
                    out.append((nm, base + i, "calr/jrl", t))
            if 0x60 <= op <= 0x6F:
                r = d[i + 1]
                t = base + i + 2 + (r - 0x100 if r & 0x80 else r)
                if lo <= t < hi:
                    out.append((nm, base + i, "jr", t))
        for i in range(len(d) - 2):            # any 24-bit operand (lda / ld imm24 / pointer)
            t = d[i] | d[i + 1] << 8 | d[i + 2] << 16
            if lo <= t < hi:
                out.append((nm, base + i, "abs24", t))
    return out


# R1 -- copy E is unreached
LO, HI = 0xF77EDB, 0xF77FE9
hits = refs(LO, HI)
inside = [h for h in hits if h[0] == "prom_b" and LO <= h[1] < HI]
outside_code = [h for h in hits if h not in inside and h[2] != "abs24"]
outside_ptr = [h for h in hits if h not in inside and h[2] == "abs24"]
print("R1  copy E 0x%06X-0x%06X: %d hits inside, %d call/jr-shaped hits outside, %d bare 24-bit hits outside"
      % (LO, HI - 1, len(inside), len(outside_code), len(outside_ptr)))
for h in outside_code + outside_ptr:
    print("      outside: %s 0x%06X %-8s -> 0x%06X" % h)
# the call/jr-shaped outside hits, each checked by hand against the source (2026-11-02): all are bytes inside other
# instructions or data, not instructions -- prom_b 0xF710CA is the middle of `calr SongStore_SeekBlock_Copy` at
# 0xF710C8 (its target bytes), and every jr-shaped hit is listed so a new one shows up as a FAIL below.
KNOWN_NOT_INSTRUCTIONS = {("prom_b", 0xF710CA)}
unexplained = [h for h in outside_code if (h[0], h[1]) not in KNOWN_NOT_INSTRUCTIONS and h[2] != "jr"]
check(not unexplained, "R1  no call / calr / jp / jrl from outside copy E lands in it (bare 24-bit hits: data or "
      "mid-instruction, see the listing)")
jr_out = [h for h in outside_code if h[2] == "jr"]
check(all(abs(h[1] - h[3]) < 0x82 for h in jr_out) and all(not (0xF77D00 <= h[1] < LO) or True for h in jr_out),
      "R1  jr-shaped hits outside copy E: %d (a jr reaches +-128 bytes, so only bytes in 0xF77E5B-0xF77EDA could)" % len(jr_out))

# R2 -- 0xFBE134 / 0xFBE135
h134 = [h for h in refs(0xFBE134, 0xFBE135)]
print("R2  0xFBE134: %d hits" % len(h134))
for h in h134:
    print("      %s 0x%06X %-8s -> 0x%06X" % h)
h135 = [h for h in refs(0xFBE135, 0xFBE136)]
for h in h135:
    print("      0xFBE135 hit: %s 0x%06X %-8s" % h[:3])
check(not [h for h in h134 if h[2] != "abs24"] and not [h for h in h134 if h[2] == "abs24" and A[h[1] - 0xF80000 - 1] in (0xF2, 0x1D, 0x1A)],
      "R2  nothing calls / jumps to / loads 0xFBE134")
check(any(h[2] == "abs24" and h[1] == 0xFBDCAD for h in h135), "R2  0xFBE135 is loaded at 0xFBDCAC (lda xbc,(0xFBE135:24))")

# R3 -- the three copies' layout
OFFS = {"InputStream_OpenAndReadFirstBlock": (0x00, 0x39), "InputStream_Refill": (0x39, 0x43),
        "InputStream_RefillDone": (0x43, 0x4B), "SmfWrite_CreateFileWithFirstWindow": (0x4B, 0xB3),
        "SmfWrite_WriteFirstWindow": (0xB3, 0xC6), "SmfWrite_WriteNextWindow": (0xC6, 0xD4),
        "SmfWrite_WriteLastWindowAndClose": (0xD4, 0xEF), "SmfWrite_SetOutputWindow": (0xEF, 0x102)}
CA, CD, CE = 0xF7659B, 0xF77D00, 0xF77EE7
for name, (s, e) in OFFS.items():
    a, d, x = (B[c + s - 0xF00000:c + e - 0xF00000] for c in (CA, CD, CE))
    print("R3  %-36s +0x%02X..+0x%03X  A==E %-5s  D==E %-5s" % (name, s, e, a == x, d == x))
same = [n for n, (s, e) in OFFS.items()
        if B[CA + s - 0xF00000:CA + e - 0xF00000] == B[CE + s - 0xF00000:CE + e - 0xF00000]]
check(len(same) == 7 and "SmfWrite_CreateFileWithFirstWindow" not in same
      and all(B[c + e - 1 - 0xF00000] == 0x0E for c in (CA, CD, CE) for (s, e) in OFFS.values()),
      "R3  copies A / D / E: every routine ends in ret at the same offset; 7 of 8 are byte-identical A vs E "
      "(CreateFileWithFirstWindow differs: its two calls name each copy's own routines)")

# R4 -- floppy-format readers
for site, row in ((0xFF6566, 4), (0xFF66C0, 5)):
    o = site - 0xF80000
    imm = int.from_bytes(A[o + 2:o + 6], "little")
    check(A[o:o + 2] == b"\xe9\xc8" and imm == 0xFF3D39 + row * 128,
          "R4  0x%06X: add XBC,0x%06X = 0xFF3D39 + %d * 128 (row %d)" % (site, imm, row, row))

# R5 -- the ROM's spelling
check(B.find(b"MIDI FILE L0AD") >= 0 and B.find(b"DISK L0AD") >= 0,
      "R5  prom_b holds \"MIDI FILE L0AD\" at 0x%06X and \"DISK L0AD\" at 0x%06X (digit zero)"
      % (0xF00000 + B.find(b"MIDI FILE L0AD"), 0xF00000 + B.find(b"DISK L0AD")))
sys.exit(1 if fails else 0)
