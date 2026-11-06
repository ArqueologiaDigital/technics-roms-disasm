#!/usr/bin/env python3
"""rhythm_part_eq_and_units: (N-e779328f, notes/ic18-rhythm-rom.md) two questions about a style's sound:
  A. which tone-generator register do the part EQ's coefficients (TgPartEqCoefCalc, lib 0x4C00807E)
     reach?
  B. what do a variation's bytes +2 / +3 select (func_48442164, key 0xB048)?

Signals read (program 941, ../../baserom/kn7000_program.rom; the library image is file 0x3B8FD1,
linked at 0x4C000000; IC18, ../../baserom/kn7000_ic18.rom):
  A1. TgPartEqCoefCalc's five `mov dN, (k, a0)` stores after `add 0x28, a0` (part record
      0x500B5340 + part * 0x54C): the coefficient words at +0x28 .. +0x38, then `movbu d0, (0x3c, a0)`;
  A2. func_4C0045E7 (run after TgPartEqCoefCalc on every voice of the part,
      TgVoiceListCollectPartAll) merges those five words, 20 bits each, into the voice record
      (TgVoiceRecordPtr) at +0x64 .. +0x74 and calls TgVoiceReg4000GroupWrite (lib 0x4C037BA8);
  A3. TgVoiceReg4000GroupWrite's five `mov imm32, d1` (bytes FC CD imm32): the register classes it
      hands TgVoiceRegWrite (lib 0x4C036F98) with +0x64 .. +0x74;
  A4. loads of a part record's +0x3C in the library source (a byte of TgPartEqCoefCalc's);
  A5. library functions that copy part +0x28 into a voice's +0x64 (`add 0x28, aX` just before
      `add 0x64, aY`): the note-on paths;
  B1. func_48442164's code (src/program/region1_02.s): the bytes it reads from the bound variation
      (*(0x50122DD4) = the variation's +2) and the keys it stores;
  B2. func_48435C29_Table (0x485B6DA8, u32 per style part, < 0x20): style part -> the TG part;
  B3. the parameter dump's records (func_48500C71_Records 0x48644F5C, {u32 parameter + 1, u32
      handler}) for parameters 0x0020005F and 0x00B0005F, and the format string the handler loads;
  B4. every literal 0xB0nn key in the region-1 source (`0x0000b0nn` / `0x7000b0nn`): 0xB048 is
      only the store in func_48442164;
  B5. the class-0x00 list of PutM3Em's special dispatch (M3HookDispatch, func_4C0216A3_Selected_0
      0x48731E44): does any {mask, value} triple match 0x7000B048?
  B6. the bytes +2 / +3 of all 3,380 IC18 variations.

Expected (2026-11-06): A1 offsets [0x0, 0x4, 0x8, 0xc, 0x10] from +0x28; A2 [0x64, 0x68, 0x6c,
0x70, 0x74]; A3 classes [0x40000000, 0x44000000, 0x48000000, 0x4c000000, 0x50000000]; A4 none;
A5 the note-on paths TgElemNoteOnStd, TgKitElemNoteOn (and others, printed);
B2 style parts 0..7 -> TG parts 0x19, 0x18, 0x13 .. 0x17, 0x1A; B3 0x0020005F
"%s SOUND DSP %s" with ON / OFF, 0x00B0005F "SOUND DSP DEPTH"; B4 0xB048 1 use; B5 no match; B6 (+2, +3) = (0xFF, 0xFF) 2,710 and
(0xFF, 2..7) the other 670.

usage (from this directory):
  python3 -I rhythm_part_eq_and_units.py
"""
import collections
import re
import struct

KN7 = "../.."
P = open(f"{KN7}/baserom/kn7000_program.rom", "rb").read()
B, LIB_FILE = 0x48400000, 0x3B8FD1


def lib(a):
    return a - 0x4C000000 + LIB_FILE


def src(path):
    return open(f"{KN7}/src/program/{path}", "rb").read().decode("latin-1").split("\n")


def body(lines, label):
    i = next(k for k, x in enumerate(lines) if x.startswith(label + ":"))
    out = []
    for x in lines[i + 1:]:
        if re.match(r"^[A-Za-z_]\w*:", x) and not x.startswith(("loc_", label)):
            break
        out.append(x.strip())
    return out


L0 = src("library_00.s")
print("== A. the part EQ's coefficients")
b = body(L0, "TgPartEqCoefCalc")
i = b.index("add     0x28, a0")
st = [int(m.group(1) or "0", 0) for x in b[i:] for m in [re.match(r"mov\s+d\d, \((?:(0x[0-9a-f]+|\d+), )?a0\)$", x)] if m]
print("   A1 TgPartEqCoefCalc stores after `add 0x28, a0` at +0x28 +", [hex(x) for x in st],
      "| then", [x for x in b[i:] if "(0x3c, a0)" in x])
b = body(L0, "func_4C0045E7")
print("   A2 func_4C0045E7: voice-record offsets", re.findall(r"mov\s+(0x[67][0-9a-f]), a1", "\n".join(b)),
      "| calls", sorted({x.split()[1].rstrip(",") for x in b if x.startswith("call")}))
lo, hi = lib(0x4C037BA8), lib(0x4C037C16)
cls = [struct.unpack("<I", m.group(1))[0] for m in re.finditer(rb"\xfc\xcd(....)", P[lo:hi], re.S)]
print("   A3 TgVoiceReg4000GroupWrite: TgVoiceRegWrite classes", [hex(x) for x in cls])

L1 = src("library_01.s")
rd3c, cp = [], []
for nm, LL in (("library_00.s", L0), ("library_01.s", L1)):
    fn = None
    for k, x in enumerate(LL):
        if re.match(r"^[A-Za-z_]\w*:", x) and not x.startswith("loc_"):
            fn = x[:-1]
        ctx = "\n".join(LL[max(0, k - 25):k])
        if re.search(r"\(0x3c, a\d\), d\d", x) and "0x54c" in ctx:
            rd3c.append(fn)
        if re.search(r"add\s+0x64, a\d", x) and re.search(r"add\s+0x28, a\d", "\n".join(LL[max(0, k - 3):k])):
            cp.append(fn)
print("   A4 loads of a part record's +0x3C (0x54C stride within 25 lines):", rd3c)
print("   A5 copies part +0x28 -> voice +0x64 (`add 0x28` then `add 0x64` within 3 lines):", sorted(set(cp)))

print("== B. a variation's bytes +2 / +3")
L2 = src("region1_02.s")
b = body(L2, "func_48442164")
print("   B1 reads", [x for x in b if re.match(r"movbu\s+\((?:1, )?a0\), d\d", x)],
      "| stores keys", re.findall(r"mov\s+(0x70[0-9a-f]{6}), d0", "\n".join(b)))
t = [struct.unpack_from("<i", P, 0x485B6DA8 - B + 4 * k)[0] for k in range(0x20)]
print("   B2 func_48435C29_Table, style part -> TG part:", {k: hex(v) for k, v in enumerate(t[:8])})
recs = {struct.unpack_from("<I", P, 0x48644F5C - B + 8 * k)[0]: struct.unpack_from("<I", P, 0x48644F5C - B + 8 * k + 4)[0]
        for k in range(128)}
L8 = src("region1_08.s")
for prm in (0x0020005F, 0x00B0005F):
    h = recs.get(prm + 1)
    lab = f"loc_{h:08X}:"
    k = next(j for j, x in enumerate(L8) if x.startswith(lab))
    strs = [m for x in L8[k:k + 20] for m in re.findall(r"Str_\w+", x)]
    print(f"   B3 parameter 0x{prm:08X}: dump handler 0x{h:08X}, strings {strs}")
cnt = collections.Counter()
for f in [f"region1_{n:02X}.s" for n in range(13)]:
    for x in src(f):
        for m in re.findall(r"0x[07]000b0[0-5][0-9a-f]\b", x):
            cnt[m[-4:]] += 1
print("   B4 literal 0xB0nn keys in region 1:", dict(sorted(cnt.items())))
o = 0x48731E44 - B
m, v, hnd = struct.unpack_from("<III", P, o)
trip = []
while hnd:
    trip.append((m, v, hnd))
    o += 12
    m, v, hnd = struct.unpack_from("<III", P, o)
print("   B5 class-0x00 special-dispatch triples", [tuple(hex(x) for x in t3) for t3 in trip],
      "| match 0x7000B048:", [t3 for t3 in trip if 0x7000B048 & t3[0] == t3[1]])
d = open(f"{KN7}/baserom/kn7000_ic18.rom", "rb").read()
u24 = lambda q: (d[q] << 16) | (d[q + 1] << 8) | d[q + 2]  # noqa: E731
st_, ci = 0x10000 + u24(0x10000 + 0x1E), 0x10000 + u24(0x10000 + 0x21)
h = collections.Counter()
for k in range((ci - st_) // 3):
    r = 0x10000 + u24(st_ + 3 * k)
    for j in range(20):
        vv = r + u24(r + 0x8A + 3 * j)
        h[(d[vv + 2], d[vv + 3])] += 1
print("   B6 IC18 variations by (+2, +3):", {f"({a:#04x}, {c:#04x})": n for (a, c), n in sorted(h.items())},
      "total", sum(h.values()))
