#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn6000_swno_states.py -- the four "states" of SoundSwNoGet / SoundSwNoBankGet (KN6000 v7.1).

QUESTION IT ANSWERS: "what are states 0..3 of SoundSwNoGet (0x4C09AFB0), i.e. which panel switch
{group, number} does each pair of ToneKeyHash payload bytes (+3 / +4 group, +5..+8 number) give,
and who asks for which state?"  It prints:
  1. per state, the payload bytes SoundSwNoGet returns and their value ranges (ToneKeyHash 0x4C3E8680);
  2. per state, the ShortKeyHash (0x4C3E9850) key groups SoundSwNoBankGet builds (state 0: group,
     1: group + 0x10, 2: + 0x40, 3: + 0x60; the archives' states 4..7 are 2/3 + 2 x source) with the
     group names of data_4C3EB620 (128 x 16 characters, func_4C09B42E);
  3. the round trip ShortKeyHash -> sound -> ToneKeyHash field == key (every switch);
  4. the sounds that only one list of a pair holds (state 0 vs 1, 2 vs 3), by bank MSB;
  5. the routines of src/program.s that call the state users, and the state each one stores.
Signal: "roundtrip ok N bad 0"; the even states hold the bank-MSB-0x28 sounds the odd ones lack.

RUN (from the repository root):  python3 -I kn7000/notes/mn10300-rest-probes/kn6000_swno_states.py
"""
import collections
import os
import re
import struct

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
ROM = os.path.join(ROOT, "kn6000", "baserom", "kn6000_program.rom")
SRC = os.path.join(ROOT, "kn6000", "src", "program.s")
BASE = 0x4C000000
TONE, SHORT, NAMES = 0x4C3E8680, 0x4C3E9850, 0x4C3EB620
STATE = {0: (3, 5, 0x00), 1: (3, 6, 0x10), 2: (4, 7, 0x40), 3: (4, 8, 0x60)}  # payload group, number; key offset


def main():
    rom = open(ROM, "rb").read()
    u16 = lambda a: struct.unpack_from("<H", rom, a - BASE)[0]  # noqa: E731
    u32 = lambda a: struct.unpack_from("<I", rom, a - BASE)[0]  # noqa: E731

    def chain(da):
        out = []
        for i in range(u16(da + 2)):
            p = u32(da + 4 + 4 * i)
            while p:
                out.append(p)
                p = u32(p)
        return sorted(out)
    tk = {u32(p + 4): rom[p - BASE + 8:p - BASE + 20] for p in chain(TONE)}
    sk = {u16(p + 4): tuple(rom[p - BASE + 6:p - BASE + 9]) for p in chain(SHORT)}
    name = lambda g: rom[NAMES - BASE + 16 * g:NAMES - BASE + 16 * g + 16].decode("latin-1").strip()  # noqa: E731
    src = open(SRC, "rb").read().decode("latin-1")
    print(f"ToneKeyHash {len(tk)} entries, ShortKeyHash {len(sk)} entries")
    for st, (gb, nb, ko) in STATE.items():
        gs = [p[gb] for p in tk.values()]
        ns = [p[nb] for p in tk.values()]
        groups = collections.Counter(k >> 8 for k in sk if ko <= k >> 8 < ko + (0x10 if ko < 0x40 else 0x20))
        print(f"== state {st}: group = payload +{gb} ({min(gs)}..{max(gs)}), number = payload +{nb} "
              f"({min(ns)}..{max(ns)}); ShortKeyHash key group = group + 0x{ko:02x}")
        for g in sorted(groups):
            print(f"   key group 0x{g:02x} {name(g):17s} {groups[g]:4d} switches")
    ok = bad = 0
    for k, (msb, lsb, prog) in sk.items():
        g, n = k >> 8, k & 0xFF
        st = 0 if g < 0x10 else 1 if g < 0x20 else 2 if g < 0x60 else 3
        gb, nb, ko = STATE[st]
        p = tk.get(msb << 16 | lsb << 8 | prog)
        if p is not None and (p[gb] + ko, p[nb]) == (g, n):
            ok += 1
        else:
            bad += 1
    print(f"roundtrip ok {ok} bad {bad}")
    for a, b in ((0, 1), (2, 3)):
        sa = {v for k, v in sk.items() if STATE[a][2] <= k >> 8 < STATE[b][2]}
        sb = {v for k, v in sk.items() if STATE[b][2] <= k >> 8 < STATE[b][2] + (0x10 if a == 0 else 0x20)}
        oa = collections.Counter(f"0x{v[0]:02x}" for v in sa - sb)
        ob = collections.Counter(f"0x{v[0]:02x}" for v in sb - sa)
        print(f"state {a} only: {dict(sorted(oa.items()))}; state {b} only: {dict(sorted(ob.items()))}")
    print(f"payload +5 != +6 in {sum(p[5] != p[6] for p in tk.values())} entries, "
          f"+7 != +8 in {sum(p[7] != p[8] for p in tk.values())}")
    # callers: the routine label before each call, and the state byte stores nearby
    lines = src.split("\n")
    for callee in ("SoundSwNoGet_entry", "func_4C07C027_entry", "func_4C07C0DB_entry", "SoundSwNoBankGet_entry"):
        found = []
        for i, ln in enumerate(lines):
            if re.match(rf"\s+call\s+{callee},", ln):
                j = i
                while j > 0 and not re.match(r"^[A-Za-z_]\w*:$", lines[j]) or (j > 0 and "_L" in lines[j]):
                    j -= 1
                found.append(lines[j][:-1])
        print(f"callers of {callee}: {', '.join(sorted(set(found)))}")


if __name__ == "__main__":
    main()
