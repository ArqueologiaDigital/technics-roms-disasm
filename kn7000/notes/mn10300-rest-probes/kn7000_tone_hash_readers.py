#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn7000_tone_hash_readers.py -- who reads the KN7000 'Tone' hash payload, and what it holds.

QUESTION IT ANSWERS: "which routines of program 941 look the table flash's 'Tone' hash (sound
directory +0x00 buckets / +0x18 descriptor) up, which payload byte does each read, and do the
KN6000 ToneKeyHash field names (tone, icon, switch groups, numbers) carry over?"  It prints:
  1. the routines that call ToneKeyFind (func_4856FC51_entry) and the payload loads in them
     (`movbu (N, aX)` / `movhu (aX)` after the call), from src/program/region1_*.s;
  2. per payload byte, its value range over the internal archive's 2,097 entries;
  3. the 'Dir1' hash (+0x04 / +0x1C; read by func_485703A5): its u16 key groups, which are the
     panel / explorer switch groups, with the names of sound directory +0x10 and the sizes of +0x14;
  4. the round trip Dir1 switch -> {MSB, LSB, program} -> 'Tone' payload group/number == switch,
     state 0: group + 0, 1: + 0x12, 2: + 0x40, 3: + 0x60 (func_485702CC).
Signal: "roundtrip ok 3323 bad 0".

RUN (from the repository root):  python3 -I kn7000/notes/mn10300-rest-probes/kn7000_tone_hash_readers.py
"""
import collections
import glob
import os
import re
import struct

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TABLE = os.path.join(ROOT, "kn7000", "baserom", "kn7000_table.rom")      # linked at 0x48000000
PROG = os.path.join(ROOT, "kn7000", "src", "program")
STATE = {0: (3, 5, 0x00), 1: (3, 6, 0x12), 2: (4, 7, 0x40), 3: (4, 8, 0x60)}
FIELDS = ["tone lo", "tone hi", "icon", "group +3", "group +4", "number +5", "number +6", "number +7",
          "number +8", "+9", "+10", "+11"]


def readers():
    for f in sorted(glob.glob(os.path.join(PROG, "region1_*.s"))):
        lines = open(f, "rb").read().decode("latin-1").split("\n")
        cur = None
        for i, ln in enumerate(lines):
            m = re.match(r"^(func_[0-9A-F]{8}):$", ln)
            if m:
                cur = m.group(1)
            if re.match(r"\s+call\s+func_4856FC51_entry,", ln) and cur != "func_4856FC51":
                regs, loads = {"a0"}, []          # ToneKeyFind answers the payload in a0
                for ln2 in lines[i + 1:]:
                    if re.match(r"^func_[0-9A-F]{8}:$", ln2):
                        break
                    m2 = re.match(r"\s+(movbu|movhu)\s+\((?:(\d+), )?(a\d)\), d\d", ln2)
                    if m2 and m2.group(3) in regs:
                        loads.append((int(m2.group(2) or 0), m2.group(1)))
                    m3 = re.match(r"\s+mov\s+a0, (a\d)$", ln2)
                    if m3:
                        regs.add(m3.group(1))
                    elif re.match(r"\s+mov\s+.*, a0$", ln2):
                        regs.discard("a0")
                print(f"  {cur} ({os.path.basename(f)}): payload " +
                      ", ".join(f"+{o} ({k})" for o, k in sorted(set(loads))))


def main():
    t = open(TABLE, "rb").read()
    u16 = lambda o: struct.unpack_from("<H", t, o)[0]  # noqa: E731
    u32 = lambda o: struct.unpack_from("<I", t, o)[0]  # noqa: E731
    arc = u32(0x18)                       # *(0x48000018): the internal 'JK' archive
    d = arc + u32(arc + 0x18)             # its sound directory

    def chain(bo, do):
        b, ds, out = arc + u32(d + bo), arc + u32(d + do), []
        for i in range(u16(ds + 2)):
            p = u32(b + 4 * i)
            while p:
                out.append(arc + p)
                p = u32(arc + p)
        return sorted(out)
    tone = {u32(p + 4): t[p + 8:p + 20] for p in chain(0x00, 0x18)}
    sw = {u16(p + 4): (tuple(t[p + 6:p + 9]), t[p + 9:p + 12]) for p in chain(0x04, 0x1C)}
    names, sizes = arc + u32(d + 0x10), arc + u32(d + 0x14)
    print(f"archive at table offset 0x{arc:x} ({t[arc:arc + 2].decode()}); 'Tone' {len(tone)} entries, "
          f"'Dir1' {len(sw)} entries")
    print("readers of the 'Tone' payload (callers of ToneKeyFind func_4856FC51):")
    readers()
    print("payload byte ranges:")
    for k, nm in enumerate(FIELDS):
        v = [p[k] for p in tone.values()]
        print(f"  +{k:<2d} {nm:10s} {min(v):3d}..{max(v):3d}, {len(set(v))} distinct")
    tv = [struct.unpack_from("<H", p)[0] for p in tone.values()]
    print(f"  u16 tone (+0): {min(tv)}..{max(tv)}")
    print(f"'Dir1' payload bytes +3..+5 always zero: {all(r == bytes(3) for _, r in sw.values())}")
    groups = collections.Counter(k >> 8 for k in sw)
    for g in sorted(groups):
        nm = t[names + 16 * g:names + 16 * g + 16].decode("latin-1").strip()
        print(f"  key group 0x{g:02x} {nm:17s} {groups[g]:4d} switches, size table +0x14 says {t[sizes + g]}")
    ok = bad = 0
    for k, ((msb, lsb, prog), _) in sw.items():
        g, n = k >> 8, k & 0xFF
        st = 0 if g < 0x12 else 1 if g < 0x24 else 2 if g < 0x60 else 3
        gb, nb, ko = STATE[st]
        p = tone.get(msb << 16 | lsb << 8 | prog)
        if p is not None and (p[gb] + ko, p[nb]) == (g, n):
            ok += 1
        else:
            bad += 1
    print(f"roundtrip ok {ok} bad {bad}")
    print(f"payload +5 != +6 in {sum(p[5] != p[6] for p in tone.values())} entries, "
          f"+7 != +8 in {sum(p[7] != p[8] for p in tone.values())}")


if __name__ == "__main__":
    main()
