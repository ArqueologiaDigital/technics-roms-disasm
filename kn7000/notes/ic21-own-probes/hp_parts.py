# hp_parts.py -- what the parts of the HOME PAGE record are: kind, name, x, y, for Felipe's chip
# (0x11000), the Initial Data Disk's 04HPGINI.HMP and program 941's template HpFlashWriteDefaults_Table.
#
# A part is {u16 kind, s16 x, s16 y} (HP_PART, src/include/user_settings.inc).  The kind indexes
# TtNormal_Table (49 HomePagePart records of 12 bytes: view id, part number, name; func_48496956 and
# AcHpPreviewProc read it), whose names are the 49 strings of Text_TITLE_BAR_NORM; kind 49 (0x31) is the
# table's end record (view -1), "none" (AcHpPartsListProc).  The names are read here from the program image
# by content (the string table starts with "TITLE BAR NORM  ").  The probe also prints how many used parts
# have a negative coordinate, and their kinds: the preset layouts TtNormal_Records_p0_0..3 put their title
# bar (kinds 0-5) at y = -1, the row above the grid.
#
#     python3 -I kn7000/notes/ic21-own-probes/hp_parts.py
import os, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths

p941 = _paths.program("941")
t = p941.find(b"TITLE BAR NORM  \x00")
names = [p941[t + 17 * i:t + 17 * i + 16].decode().rstrip() for i in range(49)] + ["(none)"]
tmpl = p941.find(struct.pack("<II", 0x204B4A, 0xFF))   # HpFlashWriteDefaults_Table: "JK ", stamp 0xFF


def show(what, rec):
    sig, stamp, typ = struct.unpack_from("<4sII", rec, 0)
    parts = [struct.unpack_from("<Hhh", rec, 0x0C + 6 * i) for i in range(64)]
    used = [(i, k, x, y) for i, (k, x, y) in enumerate(parts) if k != 0x31]
    print(f"== {what}: signature {sig!r}, stamp 0x{stamp:x}, type {typ}, {len(used)} parts used")
    for i, k, x, y in used:
        print(f"   part {i:2d}  kind {k:2d} {names[k] if k < len(names) else '?':18s} x {x:3d}  y {y:3d}")
    neg = [(k, x, y) for _, k, x, y in used if x < 0 or y < 0]
    print(f"   negative coordinates: {len(neg)}, kinds {sorted({k for k, _, _ in neg})}")


show("Felipe's IC21 0x11000", _paths.chip()[0x11000:0x1118C])
show("idd7000 04HPGINI.HMP", _paths.initial_data("04HPGINI.HMP")[:0x18C])
show(f"program 941 template HpFlashWriteDefaults_Table at 0x{tmpl + 0x48400000:08x} (0x63 words, HpFlashWriteDefaults)",
     p941[tmpl:tmpl + 0x18C])
