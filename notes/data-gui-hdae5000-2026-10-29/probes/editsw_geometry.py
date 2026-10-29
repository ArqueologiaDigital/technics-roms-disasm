#!/usr/bin/env python3
"""Does an HD-AE5000 object's `editsw` value name the LCD switch next to it?

QUESTION: the main CPU numbers the LCD switches 0-7 for the eight buttons under the
display (x = 20, 60 ... 300), 8-12 for the five side rows on the RIGHT and 0x88-0x8C for
the same rows on the LEFT (ui-framework.md, "GetEditSwPoint"; SeTitle_DecodeSwitch).
If `editsw` (propdata type 'e', in PsEditBox / PsMenuBox / PsEditSwBox / EditSw /
PsToggleBox) is that number, then every object whose editsw is a side-row switch sits
on that side, at that row's height, and every column switch sits above its column.
This reads the reference images through the converter's model (both versions) and
prints, per switch value, the x / y ranges of the objects that carry it.

RUN (repo root, built tree):
    python3 notes/data-gui-hdae5000-2026-10-29/probes/editsw_geometry.py
PASS when each side value has one side and one row band, and each column value one
column band; it prints the counter-examples.
"""
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import hdae5000_ui_tree as T  # noqa: E402

host = T.HostClasses()
for ver in T.VERSIONS:
    v = T.Version(ver, host)
    seen = collections.defaultdict(list)
    for o in v.objs:
        for off, fn, ch in o["fields"]:
            if ch == "e":
                e = v.u16(o["a"] + off)
                x1, y1, x2, y2 = (v.u16(o["a"] + k) for k in (14, 16, 18, 20))
                seen[e].append(((x1 + x2) // 2, (y1 + y2) // 2, o["name"], fn))
    print("== %s" % ver)
    for e in sorted(seen):
        xs = [c[0] for c in seen[e]]
        ys = [c[1] for c in seen[e]]
        kind = ("column %d" % (e + 1) if e < 8 else "RIGHT row %d" % (e - 7) if 8 <= e <= 12
                else "LEFT row %d" % (e - 0x87) if 0x88 <= e <= 0x8C else "other")
        print("  editsw 0x%02x %-12s n=%-3d centre x %3d..%3d  y %3d..%3d" % (
            e, kind, len(xs), min(xs), max(xs), min(ys), max(ys)))
