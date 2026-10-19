#!/usr/bin/env python3
# Question: is BASEEXT.XAP linked at 0x5029B000 (the address KssPluginLoad reads it to)?
# Signal: for a candidate base B, count the u32 words in the file that point inside the
# image AND land on a function prologue (movm / add imm,sp) or on a string start. The true
# base peaks on prologues; the nearby control bases (+-0x10) must not. Also shows why a
# pure string vote misleads: two BSS variables (0x502B403C/0x502B4044), read hundreds of
# times, land on strings under a wrong base.
# Run from the repo root:  python3 -I notes/sp7001-probes/xap_base_check.py baserom/sp7001_baseext.xap
import re, struct, sys, collections
X = open(sys.argv[1], "rb").read()
starts = {m.start() for m in re.finditer(rb"(?<=[\x00\xff])[\x20-\x7e]{3,}\x00", X)}
def prologue(o):
    return X[o] in (0xCF, 0xCE) or (X[o] in (0xF8, 0xFA, 0xFC) and o + 1 < len(X) and X[o + 1] == 0xFE)
words = [struct.unpack_from("<I", X, i)[0] for i in range(len(X) - 3)]
for B in (0x5029B000, 0x5029B010, 0x5029AFF0, 0x5029E8C0):
    inside = [w - B for w in words if 0 <= w - B < len(X)]
    print(f"base 0x{B:08X}: {sum(map(prologue, inside)):4d} pointers on function prologues, "
          f"{sum(o in starts for o in inside):5d} on string starts")
B = 0x5029E8C0
c = collections.Counter(w for w in words if (w - B) in starts)
print("most frequent 'string' pointers under 0x5029E8C0:",
      [(hex(w), n) for w, n in c.most_common(2)], "-- RAM variables in the 0xFF tail at 0x5029B000")
