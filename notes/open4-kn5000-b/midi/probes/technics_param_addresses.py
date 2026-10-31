#!/usr/bin/env python3
"""Which panel field does each Technics parameter-change / request address (F0 50 2C/2B 01 28 12 <adr3> <siz3>)
reach in the KN5000 v10 main CPU?

The receive trie (sysex_rx_catalogue.py) gives message id 27 (2C, change) / 29 (2B, request) with field 1 = the
address group (1, 3 or 7) and field 2 = an index.  SysEx_DispatchTechnicsParamChange / ..ParamRequest pick
MidiCtl_SelectTable{0,4,10} (change) or {1,5,11} (request) by group and take record [index]; this prints, for
every record those six tables reach, the 20-byte MIDI control record's fields as the readers use them
(layout comment at MidiCtl_NullRecord, ui_widgets/widget_dispatch.s):
  +0..+2 the SysEx address (checked against the trie path), +5 size, +6 panel-record tag, +7 byte offset,
  +8 mask, +9/+10 lower/upper bound, +12/+13 gate indices, +17 MidiCtl_FormatHandlers (change),
  +18 MidiCtl_AssSwbHandlers (request).  The tag's RAM record and known keys come from
  v10/maincpu/shared/ram_panel_records.s (PANEL_REC_<tag> comments).
Run:  python3 notes/open4-kn5000-b/midi/probes/technics_param_addresses.py [--md]
"""
import os, re, struct, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), *[".."] * 4))
B = 0xE00000
rom = open(os.path.join(ROOT, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
sym, name = {}, {}
for line in open(os.path.join(ROOT, "symbols/maincpu_v10_symbols_reference.txt")):
    p = line.split()
    if len(p) == 2 and not line.startswith("#"):
        sym[p[0]] = int(p[1], 16)
        name.setdefault(int(p[1], 16), p[0])
u32 = lambda a: struct.unpack_from("<I", rom, a - B)[0]
keys = {}
for line in open(os.path.join(ROOT, "v10/maincpu/shared/ram_panel_records.s"), "rb"):
    m = re.match(rb"\s*\.equ PANEL_REC_([0-9A-F]{2}),\s*(0x[0-9a-f]+)\s*;\s*tag 0x[0-9a-f]+, (\d+) bytes: (.*)", line)
    if m:
        keys[int(m.group(1), 16)] = "%s (RAM %s): %s" % ("PANEL_REC_" + m.group(1).decode(), m.group(2).decode(),
                                                     m.group(4).decode("latin-1").strip())
fmt = sym["MidiCtl_FormatHandlers"]
req = sym["MidiCtl_AssSwbHandlers"]
rows, seen = [], set()
for grp, (chg, rq) in ((1, (0, 1)), (3, (4, 5)), (7, (10, 11))):
    for kind, tnum in (("change", chg), ("request", rq)):
        t = sym["MidiCtl_SelectTable%d" % tnum]
        nxt = min(a for a in sym.values() if a > t)
        for i in range((nxt - t) // 4):
            r = u32(t + 4 * i)
            if r == sym["MidiCtl_NullRecord"] or r in seen:
                continue
            seen.add(r)
            f = rom[r - B:r - B + 20]
            rows.append([name.get(r, hex(r)), "%02X %02X %02X" % (f[0], f[1], f[2]), str(f[5]), "0x%02X" % f[6],
                         "+%d" % f[7], "0x%02X" % f[8], "%d..%d" % (f[9], f[10]),
                         name.get(u32(fmt + 4 * f[17]), "?"), name.get(u32(req + 4 * f[18]), "?"),
                         keys.get(f[6], "")])
hdr = ["record", "address", "size", "tag", "byte", "mask", "range", "change handler (+17)",
       "request handler (+18)", "panel record (ram_panel_records.s)"]
rows.sort(key=lambda r: r[1])
if "--md" in sys.argv:
    w = [max(len(r[c]) for r in rows + [hdr]) for c in range(len(hdr))]
    line = lambda r: "| " + " | ".join(r[c].ljust(w[c]) for c in range(len(r))) + " |"
    print(line(hdr))
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print(line(r))
else:
    for r in rows:
        print("  ".join(r))
