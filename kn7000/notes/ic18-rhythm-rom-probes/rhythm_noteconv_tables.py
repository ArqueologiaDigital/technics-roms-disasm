#!/usr/bin/env python3
"""rhythm_noteconv_tables: what does each NoteConvRules table of program 941 do to a key?
(N-c052c027, notes/ic18-rhythm-rom.md "Note conversion")

Signal read: program 941 (`../../baserom/kn7000_program.rom`, CPU 0x48400000):
  - NoteConvRules 0x48736104, 128 entries of 8 bytes {mode, alt_chord, flag2, flag3, u32 table};
  - each table: u32 name pointer, then signed offsets (NoteConvApply 0x48436229 reads them
    with `movbu (d0, a0)` + `extb`):
      mode 1 (`movbu (d0, a0)` of the entry != 0, 0x4843639E): 41 chord types x 12 written
        pitch classes, index (type - 1) * 12 + key % 12; the result is
        key + offset + (root - 1), folded an octave down when root - 1 > fold_root;
      mode 0 (0x484363E3): 41 types x 12 roots x 12 pitch classes, index
        (type - 1) * 0x90 + (root - 1) * 12 + key % 12; the result is key + offset (the
        offset carries the root shift itself, so fold_root is not used);
  - the chord type names: the 41 strings after 0x485A0D45 (AcChordBoxProc's chord names,
    markup <1 >2 ~a0 = flat ~9e = sharp removed); type t is string t - 1, which the probe
    checks against ChordTypeMinorTable 0x485B6EC8 (ChordTypeIsMinor): every type the table
    marks 1 must be named min / dim / m... or one of the two (#9) 13th types.
Written keys are C-based: the probe prints, per table, which written pitch classes move for
each chord type (mode 1), or the intervals above the root the results take and their range
for a written C4..B4 octave (mode 0).

Expected (2026-11-06): 21 tables (22 pointers with 0), 11 of mode 1 (496 bytes) and 10 of
mode 0 (5,908 bytes); "Root Shift Only" all 0; the minor-table check `13 of 13`; for mode 0,
"Basic Chord 100%" maps the written scale onto chord tones only (Maj {0, 4, 7}, 7 {4, 7, 10},
min {0, 3, 7}) within A3..C#5 over the 12 roots, "HardRock Chord" onto {0, 7} only, "Keep near C"
keeps all seven scale tones (Ab3..E5).

usage (from this directory):
  python3 -I rhythm_noteconv_tables.py [../../baserom/kn7000_program.rom]
"""
import struct
import sys

B = 0x48400000
d = open(sys.argv[1] if len(sys.argv) > 1 else "../../baserom/kn7000_program.rom", "rb").read()
RULES, MINOR, NAMES = 0x48736104, 0x485B6EC8, 0x485A0D45
PC = "C C# D Eb E F F# G Ab A Bb B".split()


def cstr(a):
    o = a - B
    return d[o:d.index(b"\0", o)].decode("latin-1")


names, o = [], NAMES - B
while len(names) < 41:
    e = d.index(b"\0", o)
    s = d[o:e].decode("latin-1")
    for a_, b_ in (("<1", ""), (">2", ""), ("~a0", "b"), ("~9e", "#")):
        s = s.replace(a_, b_)
    names.append(s.strip() or "Maj")
    o = e + 1
minor = d[MINOR - B:MINOR - B + 42]
flagged = [t for t in range(1, 42) if minor[t]]
ok = sum(1 for t in flagged if names[t - 1].startswith(("m", "dim")) or names[t - 1].startswith("#9"))
print(f"chord types 1..41 = AcChordBoxProc's names; ChordTypeMinorTable marks {len(flagged)}, "
      f"named m.. / dim / (#9)..: {ok} of {len(flagged)}")
print("types:", ", ".join(f"{t} {names[t - 1]}" for t in range(1, 42)))

tables = {}
for r in range(128):
    mode, alt, f2, f3, p = struct.unpack_from("<4BI", d, RULES - B + 8 * r)
    tables.setdefault(p, []).append((r, mode, alt, f2, f3))
print(f"\n{len(tables)} distinct table pointers (0 = no table) over 128 rules")
for p, rules in sorted(tables.items(), key=lambda kv: kv[1][0][0]):
    rs = [x[0] for x in rules]
    heads = sorted({x[1:] for x in rules})
    if not p:
        print(f"\n== no table: rules {rs[:12]}{' ...' if len(rs) > 12 else ''} ({len(rs)}); "
              f"{{mode, alt_chord, flag2, flag3}} {heads}: key unchanged")
        continue
    nm = cstr(struct.unpack_from("<I", d, p - B)[0]).strip()
    mode = heads[0][0]
    t = p - B + 4
    print(f"\n== 0x{p:08X} \"{nm}\": rules {rs[:12]}{' ...' if len(rs) > 12 else ''} ({len(rs)} rules), "
          f"{{mode, alt_chord, flag2, flag3}} {heads}, {'mode 1, per type' if mode else 'mode 0, per type and root'}")
    if mode:
        moved = 0
        for ty in range(1, 42):
            off = struct.unpack_from("12b", d, t + 12 * (ty - 1))
            if any(off):
                moved += 1
                print(f"   {ty:2d} {names[ty - 1]:10s}", " ".join(f"{PC[i]}{v:+d}" for i, v in enumerate(off) if v))
        print(f"   {moved} of 41 types move a written note; the rest only transpose by the root")
    else:
        for ty in (1, 2, 3, 5, 6):
            ivs, lo, hi = set(), 999, -1
            for root in range(1, 13):
                off = struct.unpack_from("12b", d, t + 0x90 * (ty - 1) + 12 * (root - 1))
                for k in (60, 62, 64, 65, 67, 69, 71):          # the written C major scale, C4..B4
                    n = k + off[k % 12]
                    ivs.add((n - (root - 1)) % 12)
                    lo, hi = min(lo, n), max(hi, n)
            nn = lambda k: f"{PC[k % 12]}{k // 12 - 1}"
            print(f"   type {ty:2d} {names[ty - 1]:6s}: C4..B4 scale tones land on intervals "
                  f"{sorted(ivs)} above the root, within {nn(lo)}..{nn(hi)} over the 12 roots")
