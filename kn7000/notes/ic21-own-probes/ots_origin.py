# ots_origin.py -- why none of the 80 ONE TOUCH SETTINGs of Felipe's CUSTOM bank holds program 941's part
# tails at +0x8F, and which writer made them.
#
# Three things are compared:
#   1. the one-touch writer of programs 893 and 941 (library func_4C02A0B1 / func_4C02A0C4) and its field-map
#      tables (893 0x4858C6A4, 941 0x4858E19C, 0xB7 bytes with the tail table): are they the same?
#   2. func_48485B52 (941; AstLoadHandler and LoadCst call it, through func_48485E55 / func_48485E79, when the
#      loaded .AST / .CST file carries the KN6000 signature, func_4852B746 = 3) rebuilds a slot from a
#      KN6000 record: each 0x90-byte KN6000 setting is copied over the 0xA0-byte default
#      func_48485B52_Block, so +0x8E..+0x8F keep the KN6000 record's FF FF and +0x90..+0x9F are the default's.
#      Does every setting of the bank have exactly that shape?
#   3. the same test on the nine factory banks and on the KN6000 Initial Data Disk bank (its 0x90-byte
#      settings end FF FF at +0x8E).
# The writer comparison reads the two program images interleaved from the romset; the default block is
# found in program 941 by its first 16 bytes (data_03.s, func_48485B52_Block).
#
#     python3 -I kn7000/notes/ic21-own-probes/ots_origin.py
import os, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths

p893, p941 = _paths.program("893"), _paths.program("941")
t941 = p941[0x4858E19C - 0x48400000:][:0xB7]
t893 = p893[0x4858C6A4 - 0x48400000:][:0xB7]
print(f"field-map tables 893 0x4858c6a4 / 941 0x4858e19c (0xb7 bytes, tail table included): "
      f"{'identical' if t893 == t941 else 'DIFFER'}")
head = bytes([0, 1, 32, 127, 21, 2, 50, 80, 60, 40, 0, 108, 64, 28, 64, 64])
i = p941.find(head)
block = p941[i:i + 0xA0]
print(f"func_48485B52_Block at 0x{i + 0x48400000:08x}; its +0x8E..+0x9F: {block[0x8E:0xA0].hex(' ')}")


def settings(bank, size):
    for s in range(20):
        b = bank[bank[2 + 2 * s] * 0x8000:]
        off = struct.unpack_from("<I", b, 0x8C)[0]
        for k in range(4):
            yield s, k, b[off + k * size:off + (k + 1) * size]


def report(name, bank, size=0xA0):
    n = conv = tails = 0
    for s, k, r in settings(bank, size):
        n += 1
        if size == 0x90:
            conv += r[0x8E:0x90] == b"\xff\xff"
            continue
        conv += r[0x8E:0x90] == b"\xff\xff" and r[0x90:0xA0] == block[0x90:0xA0]
        tails += all(r[0x8F + 3 * j] <= 7 for j in range(4))
    if size == 0x90:
        print(f"{name}: {n} settings of 0x90 bytes; ending FF FF at +0x8E: {conv}")
    else:
        print(f"{name}: {n} settings; shape of func_48485B52's conversion (FF FF at +0x8E, default tail at "
              f"+0x90): {conv}; with 941 part tails (+0x8F, +0x92, +0x95, +0x98 <= 7): {tails}")


report("Felipe's IC21 CUSTOM bank", _paths.chip()[0x20000:])
for nm, bank in _paths.factory_sets().items():
    report(f"factory {nm}", bank)
k6 = os.path.join(_paths.REPO, "kn6000", "baserom", "01ctmini.ic18")
if os.path.exists(k6):
    report("KN6000 01ctmini (idd6000)", _paths.rd(k6), 0x90)
else:
    print(f"{k6}: missing (make -C kn6000 verify-customdata); KN6000 line skipped")
