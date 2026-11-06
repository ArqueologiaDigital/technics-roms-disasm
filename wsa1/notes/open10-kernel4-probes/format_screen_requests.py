#!/usr/bin/env python3
r"""format_screen_requests.py -- what the two loose ends of the FLOPPY DISK FORMAT screens are.

QUESTIONS THIS ANSWERS (register items N-1e4a337c and N-813b5071, lane open10/kernel4, 2026-11-06;
source: notes/open6-kn5000-d/wsa1/README.md "Open questions")

  Q1 (N-1e4a337c).  HiddenKey_FloppyDiskFormatSelectType (was sub_FF657B), the handler of two keys on
      screen 0x50, counts presses in DiskScreen_RowOption while (0x21E8) bit 2 is set and, on the press
      after eight, posts UI_Request 0x8052.  What is screen 0x52, and what sets (0x21E8) bit 2?
  Q2 (N-813b5071).  YES on the format confirmation (LcdKeyRow3_FloppyDiskFormatAreYouSure) posts
      UI_Request 0x0201 after DiskFormat_Execute_Entry.  What does that request select?

  Every answer below is read off the EPROM bytes of prom_a / prom_b (wsa1/original_ROMs), not off the
  source's comments, and the script exits 1 if any of them stops holding.

RUN (from the repo root; needs only the two EPROM images, no build)
    python3 wsa1/notes/open10-kernel4-probes/format_screen_requests.py

WHAT IT CHECKS (the signal read, and what a pass means)
  A1  the bytes of HiddenKey_FloppyDiskFormatSelectType at 0xFF657B: `ld C,(0x21e8)` / `and C,0x04` /
      `jr z` (the bit-2 gate), `cp C,0x08` / `jr nc` (eight presses counted), `ld (0x2070),0x52` /
      `ld (0x2071),0x80` (the request) -- byte-exact.
  A2  the screen object for id 0x52: PanelScreen_VtableTable_ViewB (0xF86F41) + 4 * 0x52 holds
      0xF872C1 = PanelScreen_NullVtable, four `jr` to one `ret` (68 06 68 04 68 02 68 00 0e), so its
      Enter, Leave and Button slots do nothing (81 of the 256 table entries hold it).  So screen 0x52 is an EMPTY screen in this build.
  A3  every instruction in prom_a and prom_b whose memory operand is 0x21E8 (8-, 16- or 24-bit address
      forms, any operand size) and every 16/32-bit operand at 0x21E5-0x21E7 that would overlap it:
      none of them can set bit 2 (each is listed with what it does to the byte), and the two places
      that load a POINTER to the cell (`lda XIX,0x21e8` at 0xFE2E97, `lda XIX,0x21e7` sites) are
      listed for the reader; the bit-6 pair at 0xFE2E9B / 0xFE2EAA is the only write through the
      first, and the 0x21E7 pointers are used only as (XIX) (checked by hand, see the README).
      ⚠ A lower bound: a block move or a computed address could still reach the cell; none was found.
  B1  the consumer of (0x2071) bit 1: PanelScreen_ApplyModeChange at 0xF86318 tests `bit 1,A` and
      PanelMode_Normalise at 0xF86344 turns a requested mode 1 into 1 or 2 by (0x7F02) & 0xF0 == 0x10
      -- byte-exact.
  B2  PanelMode_ToScreenIdMap (0xF86EA1) entries 1 and 2 are screen ids 0x01 and 0x02, and ViewB's
      entries 1 and 2 are the SOUND MODE and COMBINATION MODE painters' objects (0xF41520, 0xF41530).
  B3  every `ld (0x2070),0x01` immediately followed by `ld (0x2071),0x02` in prom_a (the 0x0201
      request) -- the format YES is one of six; EXIT on the DISK menu is another.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
WSA1 = os.path.dirname(os.path.dirname(HERE))
ROMS = os.path.join(WSA1, "original_ROMs")
A = open(os.path.join(ROMS, "wsa1_prom_a.ic12"), "rb").read()
B = open(os.path.join(ROMS, "wsa1_prom_b.ic13"), "rb").read()
A_BASE, B_BASE = 0xF80000, 0xF00000
ok = True


def at(img, base, addr, n):
    return img[addr - base:addr - base + n]


def le32(img, base, addr):
    return int.from_bytes(at(img, base, addr, 4), "little")


def check(tag, cond, text):
    global ok
    ok = ok and cond
    print("  %s %-3s %s" % ("ok  " if cond else "FAIL", tag, text))


# ---- Q1 -------------------------------------------------------------------------------------------
print("Q1: screen 0x52 and (0x21E8) bit 2 behind HiddenKey_FloppyDiskFormatSelectType (0xFF657B)")
want = bytes.fromhex("ee0c0000 3c f1302734 c1e82123 cbcc04 6621 9e0821 d9cc8000 6618 8423 cbcf08 6f04"
                     " 8461 680d f1702000 52 f1712000 80 b40000 5c ee0d 0e".replace(" ", ""))
check("A1", at(A, A_BASE, 0xFF657B, len(want)) == want,
      "0xFF657B-0x%06X: bit-2 gate on (0x21E8), count to 8 in (XIX) = DiskScreen_RowOption, then "
      "UI_Request := 0x8052 and the count := 0" % (0xFF657B + len(want) - 1))
VIEWB, NULLVT = 0xF86F41, 0xF872C1
ent = le32(A, A_BASE, VIEWB + 4 * 0x52)
nulls = sum(1 for i in range(256) if le32(A, A_BASE, 0xF86EC1 + 4 * i) == NULLVT)
check("A2", ent == NULLVT and at(A, A_BASE, NULLVT, 9) == bytes.fromhex("680668046802680" "00e"),
      "ViewB[0x52] = 0x%06X = PanelScreen_NullVtable (four `jr` to one `ret`, so Enter / Leave / Button "
      "do nothing; %d of the 256 entries hold it)" % (ent, nulls))

def effect(img, i):
    """(text, can_set_bit2) for the (#16) instruction at img[i] whose operand covers 0x21E8."""
    pfx, op = img[i], img[i + 3]
    kind = pfx >> 4
    if kind == 0xF:                                   # destination group
        for lo, name in ((0xB0, "res"), (0xB8, "set"), (0xC8, "bit"), (0xA8, "tset"), (0xC0, "chg")):
            if lo <= op < lo + 8:
                b = op - lo
                return "%s %d" % (name, b), name in ("set", "tset", "chg") and b == 2
        if 0x30 <= op <= 0x37:
            return "lda (pointer)", False
        if op == 0x00:
            return "ld (mem),#0x%02X" % img[i + 4], bool(img[i + 4] & 4)
        return "store / dst op 0x%02X" % op, True          # any other store: assume it could
    if kind == 0xC:                                   # byte source group
        if 0x20 <= op <= 0x27:
            return "ld r8,(mem) -- read", False
        if op in (0x3C, 0x3D, 0x3E):
            imm = img[i + 4]
            name = {0x3C: "and", 0x3D: "xor", 0x3E: "or"}[op]
            return "%s (mem),0x%02X" % (name, imm), name != "and" and bool(imm & 4)
        if op == 0x3F:
            return "cp (mem),0x%02X -- read" % img[i + 4], False
        return "byte op 0x%02X" % op, True
    return "%s-size op 0x%02X" % ({0xD: "word", 0xE: "long"}[kind], op), True


sites, pointers = [], []
for img, base, tag in ((A, A_BASE, "prom_a"), (B, B_BASE, "prom_b")):
    for i in range(len(img) - 6):
        p = img[i]
        if p not in (0xC1, 0xD1, 0xE1, 0xF1):          # the (#16) address forms
            continue
        addr = img[i + 1] | img[i + 2] << 8
        width = {0xC1: 1, 0xD1: 2, 0xE1: 4, 0xF1: 1}[p]
        if p == 0xF1 and 0x50 <= img[i + 3] <= 0x57:   # ld (mem),r16
            width = 2
        if p == 0xF1 and 0x60 <= img[i + 3] <= 0x67:   # ld (mem),r32
            width = 4
        if p == 0xF1 and 0x30 <= img[i + 3] <= 0x37 and addr in (0x21E7, 0x21E8):
            pointers.append((tag, base + i, addr))
            continue
        if not (addr <= 0x21E8 < addr + width):
            continue
        text, can = effect(img, i)
        sites.append((tag, base + i, img[i:i + 5].hex(), text, can))
for img, base, tag in ((A, A_BASE, "prom_a"), (B, B_BASE, "prom_b")):   # (#24) forms
    for i in range(len(img) - 6):
        if img[i] in (0xC2, 0xD2, 0xE2, 0xF2) and img[i + 1:i + 4] == b"\xe8\x21\x00":
            sites.append((tag, base + i, img[i:i + 6].hex(), "(#24) form", True))
setters = [s for s in sites if s[4]]
for s in sites:
    print("       %s 0x%06X  %-12s %s%s" % (s[:4] + ("   <- CAN SET BIT 2" if s[4] else "",)))
for t, a, addr in pointers:
    print("       %s 0x%06X  lda XIX,0x%04X (pointer; its uses are listed in the README)" % (t, a, addr))
check("A3", not setters and pointers,
      "%d instructions name (0x21E8) directly and none can set bit 2 (%d pointer loads to 0x21E7/0x21E8)"
      % (len(sites), len(pointers)))

# ---- Q2 -------------------------------------------------------------------------------------------
print("Q2: UI_Request 0x0201, posted by YES on the FLOPPY DISK FORMAT confirmation (0xFF66EB)")
check("B1", at(A, A_BASE, 0xF86318, 10) == bytes.fromhex("c1712021c933016622c9") and
      at(A, A_BASE, 0xF86344, 0x44) == bytes.fromhex(
          "c1027f20c8ccf0c1762021c1702025cdd96e092501c8cf106e022502cd8cc9cc3fcdcc3fcdd1cd896e15"
          "cc33076610" "2101c1027f20c8ccf0c8cf106e022102f1782041" "0e"),
      "(0x2071) bit 1 = PanelScreen_ApplyModeChange; PanelMode_Normalise maps mode request 1 to 1, or "
      "to 2 when (0x7F02) & 0xF0 == 0x10")
m1, m2 = at(A, A_BASE, 0xF86EA1 + 1, 2)
v1, v2 = le32(A, A_BASE, VIEWB + 4), le32(A, A_BASE, VIEWB + 8)
check("B2", (m1, m2) == (1, 2) and (v1, v2) == (0xF41520, 0xF41530),
      "PanelMode_ToScreenIdMap[1,2] = screens 0x%02X, 0x%02X; ViewB[1,2] = 0x%06X "
      "(T_InstallPainter_SoundMode_Entry), 0x%06X (T_InstallPainter_CombinationMode_Entry)" % (m1, m2, v1, v2))
pat = bytes.fromhex("f170200001f171200002")
hits = [A_BASE + i for i in range(len(A)) if A[i:i + len(pat)] == pat]
check("B3", 0xFF66EB in hits and 0xFF43FA in hits,
      "`UI_Request := 0x0201` at %s (format YES 0xFF66EB, DISK menu EXIT 0xFF43FA)"
      % ", ".join("0x%06X" % h for h in hits))
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
