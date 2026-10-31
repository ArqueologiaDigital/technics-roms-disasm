# name_origin.py -- are the four ONE TOUCH SETTING names of each of the 20 slots of Felipe's CUSTOM bank the
# KN5000's MUSIC DATABASE titles of that style, in the KN5000 table's order?
#
# The KN5000 table-data ROM (original_ROMs/kn5000_table_data.rom, tracked) holds the KN5000's 1,000 MUSIC
# DATABASE records as text: a 16-character category, the 16-character style name, 01 00, a space, the title
# and the tempo in decimal, NUL (e.g. "Dance Pop       Straight Dance  \x01\x00 Metalic Dance   ...121\x00").
# For each slot this prints the KN5000 records whose style is the slot's style name, the slot's four
# setting names, and every name that differs.  Names are compared with spaces stripped; styles with
# spaces, '-' dropped and '.' read as ':' (Jazz At 3.00am).
#
#     python3 -I kn7000/notes/ic21-own-probes/name_origin.py
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
import gen_customdata_s as G  # noqa: E402

k5 = _paths.rd(os.path.join(_paths.REPO, "original_ROMs", "kn5000_table_data.rom"))
recs = [(m.start(), m.group(1).strip(), m.group(2).strip(), m.group(3).strip(), int(m.group(4)))
        for m in re.finditer(rb"([ -~]{16})([ -~]{16})\x01\x00 ([ -~]{20,32}?) *(\d{2,3})\x00", k5)]
print(f"KN5000 table data: {len(recs)} MUSIC DATABASE records")


def norm(x):
    return x.lower().replace(b" ", b"").replace(b"-", b"").replace(b".", b":")


bank = _paths.chip()[0x20000:]
same = diff = 0
for s in range(G.NSLOTS):
    r = bank[bank[2 + 2 * s] * G.BLOCK:]
    style = r[4:20].strip()
    ots = [r[0x14 + 16 * i:0x24 + 16 * i].strip() for i in range(4)]
    k = [x for x in recs if norm(x[2]) == norm(style)]
    titles = [x[3] for x in k]
    d = [(o.decode(), t.decode()) for o, t in zip(ots, titles) if o != t]
    same += 4 - len(d)
    diff += len(d)
    where = ", ".join(f"0x{x[0]:06x}" for x in k)
    print(f"slot {s:2d} {style.decode():17s} KN5000 records at {where}: "
          f"{'same 4 titles, same order' if not d and len(k) == 4 else f'{len(k)} records'}"
          + "".join(f"; here {a!r} for KN5000 {b!r}" for a, b in d))
print(f"setting names equal to the KN5000 title: {same}; spelled differently: {diff}")
