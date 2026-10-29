"""Per-offset value ranges of the KN5000 sound-RAM byte clamp (v10 0xFEEC48, Param_SignExtendReturn_Helper3,
and its kit twin at 0xFEEE10).  Reads ParamSx_* case maps / switch tables from the v10 ROM and decodes each case
body with unidasm to recover (pushw max, pushw min, ld bc mask).  Output: JSON dict region -> {offset: [min,max,mask]}."""
import struct, subprocess, sys, json, re, os
ROM = sys.argv[1]; UNI = sys.argv[2]; TMP = sys.argv[3]
d = open(ROM, 'rb').read()
B = 0xE00000
def u8(a): return d[a - B]
def s16(a): return struct.unpack_from('<h', d, a - B)[0]
def case(a):
    p = os.path.join(TMP, 'case.bin'); open(p, 'wb').write(d[a - B:a - B + 24])
    out = subprocess.run([UNI, p, '-arch', 'tlcs900', '-basepc', hex(a)], capture_output=True, text=True).stdout
    first = out.split('\n')[0]
    if 'push' not in out.split('\n')[0] + out.split('\n')[2] + out.split('\n')[1]: return 'unlimited@%x' % a
    pushes = re.findall(r'push 0x([0-9a-f]{4})', out); m = re.search(r'ld BC,0x([0-9a-f]+)', out)
    sx = lambda v: v - 0x10000 if v >= 0x8000 else v
    return [sx(int(pushes[1], 16)), sx(int(pushes[0], 16)), int(m.group(1), 16)]
def table(cmap, ncmap, sw, nsw, base, first):
    res = {}
    for i in range(ncmap):
        k = u8(cmap + i) if cmap else i
        if k >= nsw: res[first + i] = None; continue
        res[first + i] = case(base + s16(sw + 2 * k))
    return res
R = {}
R['rec_head_common'] = table(0xEED3EE, 77, 0xEED43B, 7, 0xFEED91, 16)     # rec offsets 16..92
R['rec_partial'] = table(0xEED449, 77, 0xEED496, 7, 0xFEECDA, 0)          # partial block offsets 0..76
R['rec_vsel'] = table(None, 10, 0xEED4A4, 10, 0xFEEC84, 0)                # vsel offsets 0..9
R['kit_head'] = table(0xEED4B8, 23, 0xEED4CF, 3, 0xFEEFAA, 16)           # kit offsets 16..38
R['kit_entry'] = table(0xEED4D5, 41, 0xEED4FE, 7, 0xFEEEEB, 13)          # entry offsets 13..53
R['kit_vsel'] = table(None, 10, 0xEED50C, 10, 0xFEEE7F, 0)               # entry vsel offsets 0..9
json.dump(R, sys.stdout, indent=0)
