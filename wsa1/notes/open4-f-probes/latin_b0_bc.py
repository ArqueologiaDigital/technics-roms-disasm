#!/usr/bin/env python3
"""latin_b0_bc.py -- the readings of Font_Svc06_8x14 codes 0xB0, 0xB9, 0xBA, 0xBC, and of the
half-width katakana 0x15 and katakana 0x66 cells, checked byte by byte (N-b6d3c4c7, N-735e380b).

Each Latin reading is proved against the SAME face's ASCII cells, so nothing depends on an eye:
  0xB0 = '1' (0x31) shifted right 2 px, plus a 3-px bar on rows 4-5 at the left   -> "-1"
  0xBC = '2' (0x32) narrowed by one column, plus the same bar at columns 0-2      -> "-2"
  0xB9 = 0xB5 (o-acute) but the accent's top pixel at column 3, not 5              -> o-grave
  0xBA = '!' (0x21) upside down                                                     -> inverted !
The two kana cells are checked for the shape the note quotes (one S-stroke, one centred dot).

    python3 notes/open4-f-probes/latin_b0_bc.py      (exits 1 on any failed check)
"""
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
B = (ROOT / 'original_ROMs/wsa1_prom_b.ic13').read_bytes()
FAIL = []


def cell(base, size, code):
    o = base - 0xF00000 + size * code
    return B[o:o + size]


def check(ok, what):
    print(('ok    ' if ok else 'FAIL  ') + what)
    if not ok:
        FAIL.append(what)


L = lambda c: cell(0xF1B400, 14, c)
one, two, bang = L(0x31), L(0x32), L(0x21)
minus_rows = {4, 5}
b0 = L(0xB0)
check(all((b0[y] & 0x0F) == ((one[y] >> 2) & 0x0F) for y in range(14)) and
      all((b0[y] & 0x70) == (0x70 if y in minus_rows else (one[y] >> 2) & 0x70) for y in range(14)),
      "0xB0 = '1' >> 2 plus a bar at columns 1-3 of rows 4-5")
bc = L(0xBC)
check(all(bc[y] & 0xE0 == 0xE0 for y in minus_rows) and
      all(bc[y] == two[y] & 0x3F for y in range(6, 14)) and bc[3] == two[3],
      "0xBC = a '2' (0x32) narrowed to columns 2-7 (its rows 3 and 6-13 are '2' minus column 1) "
      "plus a bar at columns 0-2 of rows 4-5")
b5, b9 = L(0xB5), L(0xB9)
check(b5[1:] == b9[1:] and b5[0] == 0x04 and b9[0] == 0x10 and b5[1] == 0x08,
      '0xB9 = 0xB5 (o-acute) except the top accent pixel, column 5 -> column 3: the stroke '
      'slopes the other way, o-grave')
ba = L(0xBA)
check(ba[:10] == bang[:10][::-1] and not any(ba[10:]),
      "0xBA = '!' (0x21) rows 0-9 upside down: inverted exclamation mark")
h15 = cell(0xF212B0, 14, 0x15)
check(list(h15) == [0, 0, 0, 0, 0x30, 0x49, 0x06] + [0] * 7, 'half-width 0x15 = one S-stroke on rows 4-6 (wave dash)')
k66 = cell(0xF21940, 32, 0x66)
rows = [(k66[2 * y] << 8) | k66[2 * y + 1] for y in range(16)]
check(rows[7:11] == [0x0180, 0x03C0, 0x03C0, 0x0180] and not any(rows[:7] + rows[11:]),
      'katakana 0x66 = a 4x4 dot centred on rows 7-10 (middle dot)')
print('FAILURES: %d' % len(FAIL))
sys.exit(1 if FAIL else 0)
