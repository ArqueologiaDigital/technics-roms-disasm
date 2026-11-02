#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""rhythm_style_semantics.py -- the IC18 style fields that program 941's code gives a meaning to.

QUESTIONS ANSWERED (kn7000/notes/ic18-rhythm-rom.md; each section prints its own figures)
-----------------------------------------------------------------------------------------
1. SLOTS.  Bars per slot over the 169 styles.  The 941 handlers select slot 12 + 4k for
   INTRO k+1 (func_484437DA: `asl2 d2; add 0xc, d2`) and 14 + 4k for ENDING k+1
   (func_484439EB: `add d2, d2; inc d2; add d2, d2; add 0xc, d2`), so 12/13 and 16/17 are
   intros, 14/15 and 18/19 endings.
2. HALVES.  StyleRecordSlotSelect 0x48433643 adds its third argument (0x5003A46A) to an
   intro / ending slot; 0x5003A46A is func_484361BC(chord type) = table 0x485B6EC8, 1 for the
   minor-family chord types.  The pitch-class histogram of the non-drum notes (parts 1-6) of
   the A and B halves: if B is the minor version, pitch class 3 (Eb) replaces 4 (E) and 8 (Ab)
   replaces 9 (A).
3. NOTE BYTES.  A note is `9n key vel b3 b4 b5`.  func_484425FE reads b4 << 7 | b3 as the
   gate time in ticks; func_4843D558 passes b5 to NoteConvRules 0x48736104 (8-byte entries,
   +4 -> a table whose first word points at its name).  The b5 histogram with the rule names,
   and the gate range.
4. UNITS.  The two sound-unit keys (record +0x0D) decoded as func_484420C8 does
   (lo & 0x7F | (hi & 0x3F) << 8, bit 0x10000 when hi bit 6), named through the DSP preset
   table 0x48703558 (index lo << 6 | hi & 0x3F) as func_48412187 does; record +0x1C carries the
   preset's own key, compared here.
5. COUNT-INS.  The four COUNT INTRO patterns of StyleCountInRecordGet's program table
   0x48736078: their meter and notes.

Run from kn7000/ (read-only, deterministic):

    python3 -I notes/mn10300-names-probes/rhythm_style_semantics.py
"""
import collections
import os
import struct
import sys

KN7 = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(KN7, "tools"))
import gen_ic18_rhythm_s as R  # noqa: E402

B = 0x48400000
d = open(os.path.join(KN7, "baserom/kn7000_ic18.rom"), "rb").read()
P = open(os.path.join(KN7, "baserom/kn7000_program.rom"), "rb").read()
u24 = lambda o: (d[o] << 16) | (d[o + 1] << 8) | d[o + 2]  # noqa: E731
u16 = lambda o: (d[o] << 8) | d[o + 1]  # noqa: E731
pw = lambda a: struct.unpack_from("<I", P, a - B)[0]  # noqa: E731


def cstr(a):
    o = a - B
    return P[o:P.index(b"\0", o)].decode("latin-1")


def notes(img, v):
    """(part, key, vel, b3, b4, b5) of every note of the variation record at v."""
    ln = (img[v + 4] << 8) | img[v + 5]
    s = v + 9 + ln
    e = s + ((img[v + 6 + ln] << 16) | (img[v + 7 + ln] << 8) | img[v + 8 + ln])
    o, out = s, []
    while o < e:
        c = img[o]
        if c & 0xF0 == 0x90:
            out.append((c & 15,) + tuple(img[o + 1:o + 6]))
        o += R.ev_len(img, o) if c >= 0x80 else 1
    return out


def main():
    st, ci = 0x10000 + u24(0x10000 + 0x1E), 0x10000 + u24(0x10000 + 0x21)
    styles = [0x10000 + u24(st + 3 * i) for i in range((ci - st) // 3)]
    slot = lambda r, j: r + u24(r + 0x8A + 3 * j)  # noqa: E731

    print("== 1. bars per slot (bars: styles)")
    for j in range(20):
        c = collections.Counter(d[slot(r, j)] + 1 for r in styles)
        print(f"   slot {j:2d} {R.SLOT_NAMES[j]:12s}", dict(sorted(c.items())))

    print("== 2. pitch classes of parts 1-6, % per slot (0 = C ... 11 = B)")
    for j in (0, 12, 13, 14, 15, 16, 17, 18, 19):
        c = collections.Counter(k % 12 for r in styles for p, k, *_ in notes(d, slot(r, j)) if p not in (0, 7))
        t = sum(c.values())
        print(f"   slot {j:2d} " + " ".join(f"{x}:{100 * c[x] / t:4.1f}" for x in range(12)))
    mt = list(P[0x485B6EC8 - B:0x485B6EC8 - B + 42])
    names = [cstr(pw(0x485A0EA8 + 4 * k)) for k in range(42)]
    print("   chord types func_484361BC calls minor (0x485B6EC8 == 1):", [(k, names[k]) for k in range(42) if mt[k]])

    print("== 3. note byte 5: NoteConvRules 0x48736104 entry, notes, name; gate (b4 << 7 | b3) range")
    c5, gates = collections.Counter(), collections.Counter()
    for r in styles:
        for j in range(20):
            for p, k, vel, b3, b4, b5 in notes(d, slot(r, j)):
                c5[b5] += 1
                gates[b4 << 7 | b3] += 1
    for v, n in sorted(c5.items()):
        e = P[0x48736104 - B + 8 * v:0x48736104 - B + 8 * v + 8]
        t = struct.unpack_from("<I", e, 4)[0]
        print(f"   rule {v:3d}: {n:7d} notes, entry {e[:4].hex(' ')}, table {t:#010x}"
              f" {cstr(pw(t))!r}" if t else f"   rule {v:3d}: {n:7d} notes, entry {e[:4].hex(' ')}, no table")
    print(f"   gate ticks: min {min(gates)}, max {max(gates)}, most common {gates.most_common(5)}")

    print("== 4. sound-unit keys -> DSP preset (0x48703558)")
    keys = collections.Counter()
    bad = 0
    for r in styles:
        u = d[r + 13:r + 17]
        for pair in (u[0:2], u[2:4]):
            keys[(pair[0] & 0x7F) | ((pair[1] & 0x3F) << 8) | (0x10000 if pair[1] & 0x40 else 0)] += 1
    for k, n in keys.most_common():
        lo, hi = k & 0xFF, (k >> 8) & 0x3F
        rec = pw(0x48703558 + 4 * ((lo << 6) | hi))
        own = P[rec - B + 0x1C:rec - B + 0x1E]
        ok = own == bytes((lo, hi))
        bad += not ok
        print(f"   {k:#07x} x{n:3d}: {P[rec - B:rec - B + 16].decode('latin-1').strip()!r}, effect type "
              f"{struct.unpack_from('<H', P, rec - B + 0x12)[0]:#04x}, own key {own.hex(' ')} {'ok' if ok else 'DIFFERS'}")
    b7 = sum(1 for r in styles if d[r + 14] & 0x80)
    print(f"   {bad} keys whose preset carries another key; {b7} styles set bit 7 of +0x0E (-> key 0xB001, EFFECT DEBUG 'TOTAL MODE')")

    print("== 5. COUNT INTRO patterns, table 0x48736078")
    for k in range(8):
        a = pw(0x48736078 + 4 * k)
        if not a:
            print(f"   meter {k + 1}: none (IC18's count-in is used)")
            continue
        o = a - B
        print(f"   meter {k + 1}: record {a:#x}, {P[o] + 1} bar(s) of {P[o + 1] + 1} beats, notes",
              [(p, key, vel) for p, key, vel, *_ in notes(P, o)])


if __name__ == "__main__":
    main()
