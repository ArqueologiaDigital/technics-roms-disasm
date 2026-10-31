#!/usr/bin/env python3
"""Is anything on CPU 1 a writer of RAM 0x2742 or 0x272A?  (open-items T-wsa1-todo-drawn-by,
T-wsa1-todo-bit)

include/wsa1_ram.inc said of both "no writer under any spelling".  This probe widens the search to
the spellings that a grep of the sources cannot see, and says what the cells then hold.

CHECKS (exit 1 on any failure)
  W1  Every occurrence of the address's two little-endian bytes in prom_a and prom_b (the only
      images on CPU 1) is listed and classified: an operand of a display-list record (data), or
      a coincidence inside other operands.  None is the address operand of a store.
  W2  Every pointer register the linear listings load with an address in 0x2700..0x2747 (compiled C
      takes `&cell` with `lda XIX,0x27nn`, 44 sites) is followed to its next reload or return: no
      `(Xrr+d)` operand based on one of them reaches either cell.
  W3  Every block copy (ldi/ldir/ldd/lddr, byte and word, both register pairs) in the two
      listings is listed with its destination and count where they are immediates loaded in the
      16 instructions before it; none whose destination is known covers either cell.  Copies into
      a C local (`lda XIX,XIZ+d`) are separated out; the rest (computed destinations) are counted
      and listed with -v -- this probe does NOT exclude them, W1/W2 bound what they could be.
  W4  RESET (0xF826A9) zeroes 0x1460 longwords from 0x0080 (`RESET__clear_iram`), i.e.
      0x0080..0x51FF, which contains both cells -- so with no writer both read 0 after every
      reset.

RUN
  python3 notes/open4-c-probes/ram_cell_writer_census.py [-v]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
IMGS = (("wsa1_prom_a.ic12", 0xF80000), ("wsa1_prom_b.ic13", 0xF00000))
CELLS = (0x2742, 0x272A)
fails = []


def ck(name, cond, detail=""):
    print("%-3s %s %s" % (name, "ok  " if cond else "FAIL", detail))
    if not cond:
        fails.append(name)


def listing(name):
    out = []
    for line in open(os.path.join(ROOT, "original_ROMs", name + ".unidasm"), errors="replace"):
        m = re.match(r"([0-9a-f]{6}): ((?:[0-9a-f]{2} )+)\s+(.*)$", line.rstrip())
        if m:
            out.append((int(m.group(1), 16), bytes.fromhex(m.group(2)), m.group(3)))
    return out


LST = {n: listing(n) for n, _ in IMGS}

# W1 -----------------------------------------------------------------------------------------
# address -> why it is not a store; checked against the bytes below
EXPECTED = {
    0x2742: {0xF0D585: "prom_b DL record `dlb_rect_entry var=MidiOutPgm_..` (op 0x0B, var field)"},
    0x272A: {0xF589B4: "prom_b DL_F589B2 dlb_rect_entry var field",
             0xF589CF: "prom_b DL_F589CD dlb_area_entry var field",
             0xF5AC98: "prom_b `ld L,(0x2a80)` c1 80 2a 27 -- operand straddle",
             0xF5ACC0: "prom_b `ld L,(0x2a80)` c1 80 2a 27 -- operand straddle",
             0xFD4E64: "prom_a `ld H,0x2a / ld L,0x1e` 26 2a 27 1e -- two immediates"},
}
for v in CELLS:
    hits = []
    for name, base in IMGS:
        b = open(os.path.join(ROOT, "original_ROMs", name), "rb").read()
        pat = v.to_bytes(2, "little")
        i = b.find(pat)
        while i >= 0:
            hits.append(base + i)
            i = b.find(pat, i + 1)
    ck("W1", sorted(hits) == sorted(EXPECTED[v]),
       "0x%04X: %s" % (v, "; ".join("%06X %s" % (h, EXPECTED[v].get(h, "UNEXPECTED")) for h in sorted(hits))))

# W2 -----------------------------------------------------------------------------------------
# A pointer register loaded with an address in 0x2700..0x2747 (compiled C takes `&cell` as
# `lda XIX,0x27nn`): follow it until it is reloaded or the routine returns, and collect every
# `(Xrr+d)` / `(Xrr-d)` operand whose effective address is one of the cells.
hits_ptr, nptr = [], 0
for name, _ in IMGS:
    L = LST[name]
    for k, (a, by, t) in enumerate(L):
        m = re.match(r"(?:ld|lda) (X(?:IX|IY|IZ|HL|DE|BC|WA)),0x([0-9a-f]+)$", t)
        if not m or not 0x2700 <= int(m.group(2), 16) <= 0x2747:
            continue
        nptr += 1
        reg, base = m.group(1), int(m.group(2), 16)
        for a2, by2, t2 in L[k + 1:k + 400]:
            if re.match(r"(ret|reti|jp T,|jp 0x)", t2) or re.match(r"(?:ld|lda) %s," % reg, t2):
                break
            for mm in re.finditer(r"\(%s([+-])0x([0-9a-f]+)\)" % reg, t2):
                d = int(mm.group(2), 16)
                if d >= 0x80 and len(mm.group(2)) <= 2:
                    d -= 0x100                      # unidasm prints d8 as an unsigned byte
                ea = base + d if mm.group(1) == "+" else base - d
                if ea in CELLS:
                    hits_ptr.append("%06X %s (base 0x%04X from %06X)" % (a2, t2, base, a))
ck("W2", not hits_ptr, "%d pointer loads into 0x2700..0x2747 followed; operands reaching a cell: %s"
   % (nptr, hits_ptr or "none"))

# W3 -----------------------------------------------------------------------------------------
known, computed = [], []
for name, _ in IMGS:
    L = LST[name]
    for k, (a, by, t) in enumerate(L):
        if not re.match(r"(ldi|ldir|ldd|lddr)w?$", t):
            continue
        dst = "XDE" if by[0] in (0x83, 0x93) else "XIX"
        d = n = None
        for a2, by2, t2 in reversed(L[max(0, k - 16):k]):
            if d is None:
                m = re.match(r"ld %s,0x([0-9a-f]+)$" % dst, t2)
                if m:
                    d = int(m.group(1), 16)
                elif re.match(r"lda %s,X(IZ|SP)[+-]" % dst, t2):
                    d = "stack"                         # a C local: XIZ/XSP-relative
                elif re.match(r"(ld|lda|pop|add|sub|inc|dec) %s\b" % dst, t2):
                    d = "computed: " + t2
            if n is None:
                m = re.match(r"ld X?BC,0x([0-9a-f]+)$", t2)
                if m:
                    n = int(m.group(1), 16)
        unit = 2 if t.endswith("w") else 1
        if isinstance(d, int) and isinstance(n, int):
            known.append((a, d, n * unit))
        else:
            computed.append((a, t, dst, d))
cover = [k for k in known if any(k[1] <= c < k[1] + k[2] for c in CELLS)]
stack = [c for c in computed if c[3] == "stack"]
other = [c for c in computed if c[3] != "stack"]
ck("W3", not cover, "%d block copies with an immediate destination and count, %d covering a cell; "
   "%d into a C local (XIZ/XSP-relative); %d with a destination this window cannot resolve"
   % (len(known), len(cover), len(stack), len(other)))
if "-v" in sys.argv:
    for a, t, dst, d in other:
        print("      unresolved: %06X %-6s dst %s (%s)" % (a, t, dst, d))

# W4 -----------------------------------------------------------------------------------------
A = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_a.ic12"), "rb").read()
i = A.find(bytes.fromhex("3160144480000000"))   # ldw BC,0x1460 ; ld XIX,0x00000080
end = 0x80 + 0x1460 * 4
ck("W4", i >= 0 and 0xF80000 + i < 0xF82800 and all(0x80 <= c < end for c in CELLS),
   "RESET clear loop at %06X zeroes 0x0080..0x%04X" % (0xF80000 + i, end - 1))

print("\nFAILURES:", len(fails))
sys.exit(1 if fails else 0)
