# section_map.py -- which part of the settings image at 0x96804000 is section n of func_4C024030 /
# func_4C024000, and which settings fields some routine reads.
#
# 1. func_4C024030(n) (program 941, library at CPU 0x4C000000 = program file 0x3B8FD1) jumps through
#    func_4C024030_Table (23 words at 0x4858D794); each case starts `mov RAM, a0` (FC DC imm32) and
#    `mov FLASH, a1` (FC DD imm32), then memcpy's.  The probe reads the 23 case addresses from the image
#    and prints, per n, the RAM and flash address of the case (or "none" for the cases that only return)
#    and the field names of user_settings.inc's USR_SETUP that the range covers.
# 2. For the 26 USR_SETUP halfwords (RAM 0x500D3584..), it counts the 32-bit constants equal to the
#    field's RAM address in programs 893, 935 and 941 (in 893 / 935 the RAM copy is at 0x500C4D24 /
#    0x500C4D48, found the same way from their section-5 case) outside the section code: a field
#    whose count is 0 has no reader that names its address.
# Inputs: the program images from the romset's EPROM halves (_paths.program), 935 from
# kn7000/baserom/kn7000_program_b935.rom when it is there.
#
#     python3 -I kn7000/notes/ic21-own-probes/section_map.py
import os, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths

FIELDS = ["language", "to_save_reminder", "to_completed", "to_are_you_sure", "to_error", "to_sound_rhythm",
          "to_easy_setting", "jump_insert", "file_priority", "para_load1", "para_load2", "para_load3",
          "para_load4", "wall_home1", "wall_home2", "wall_home3", "wall_home4", "contrast", "r_a94", "r_a96",
          "data_protect", "cus_mem_mode", "acc_reverb_mask", "rsp_select", "panel_sw1", "panel_sw2"]
LIB = 0x3B8FD1


def cases(img, table):
    out = []
    for n, cpu in enumerate(struct.unpack_from("<23I", img, table - 0x48400000)):
        o = cpu - 0x4C000000 + LIB
        if img[o:o + 2] == b"\xfc\xdc" and img[o + 6:o + 8] == b"\xfc\xdd":
            out.append((n, struct.unpack_from("<I", img, o + 2)[0], struct.unpack_from("<I", img, o + 8)[0]))
        else:
            out.append((n, None, None))
    return out


p941 = _paths.program("941")
cs = cases(p941, 0x4858D794)
ram0 = next(r for n, r, f in cs if f == 0x96804A70)
print("func_4C024030 sections, program 941:")
for n, ram, fl in cs:
    if ram is None:
        print(f"  n {n:2d}: none")
        continue
    nxt = sorted({f for _, r, f in cs if f and f > fl} | {0x96804AA4})[0]
    names = [FIELDS[i] for i in range(26) if fl <= 0x96804A70 + 2 * i < nxt] if fl >= 0x96804A70 else []
    print(f"  n {n:2d}: RAM 0x{ram:08x}  flash +0x{fl - 0x96804000:03x}" + (f"  {', '.join(names)}" if names else ""))

builds = {"941": (p941, ram0)}
p893 = _paths.program("893")
k = p893.find(struct.pack("<I", 0x96804A70))           # its section-5 case: mov RAM, a0 is the 6 bytes before
builds["893"] = (p893, struct.unpack_from("<I", p893, k - 6)[0] if p893[k - 8:k - 6] == b"\xfc\xdc" else None)
f935 = os.path.join(_paths.KN7, "baserom", "kn7000_program_b935.rom")
if os.path.exists(f935):
    p935 = open(f935, "rb").read()
    k = p935.find(struct.pack("<I", 0x96804A70))
    builds["935"] = (p935, struct.unpack_from("<I", p935, k - 6)[0] if p935[k - 8:k - 6] == b"\xfc\xdc" else None)
print("\n32-bit constants equal to a USR_SETUP field's RAM address (the section code of func_4C024030 /")
print("func_4C024263, library 0x4C024030..0x4C024600, holds the first field of each section twice: copy, compare; 893 has its library elsewhere, so its section code is not marked):")
for b, (img, base) in builds.items():
    if base is None:
        print(f"  {b}: RAM copy not found")
        continue
    row = []
    for i, f in enumerate(FIELDS):
        a = struct.pack("<I", base + 2 * i)
        cnt, j = 0, img.find(a)
        while j >= 0:
            cnt += 1
            j = img.find(a, j + 1)
        row.append(f"{f} {cnt}")
    print(f"  {b} (RAM 0x{base:08x}): " + ", ".join(row))
    for i, f in enumerate(FIELDS):
        if f in ("contrast", "r_a94", "r_a96", "acc_reverb_mask"):
            a, j, where = struct.pack("<I", base + 2 * i), img.find(struct.pack("<I", base + 2 * i)), []
            while j >= 0:
                cpu = j - LIB + 0x4C000000 if j >= LIB else j + 0x48400000
                where.append(f"0x{cpu:08x}" + (" (section code)" if 0x4C024030 <= cpu < 0x4C024600 else ""))
                j = img.find(a, j + 1)
            print(f"     {f}: " + ", ".join(where))
