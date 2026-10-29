#!/usr/bin/env python3
"""gui_readability_census.py -- how much of the SX-WSA1R's GUI data can be read at a glance, per image.

QUESTION IT ANSWERS
  "In the GUI tables of each image -- display-list records, panel key maps, the screen-object table -- how
   many fields are still raw numbers where a name exists or should exist?"  Set up 2026-10-29 for the owner's
   GUI goal (notes/data-semantics-2026-10-29/README.md): "one should be able to easily grasp all the menus,
   submenus, screens, GUI widgets, etc, just by glancing at the source code."

  The WSA1 has no widget classes, so the KN5000's "raw class id" and "numeric object link" columns have no
  counterpart here (a list is reached by a symbol in code, never by an index).  What it counts instead:

  records          display-list records: `macro` = one dl_* / dlb_* line of include/wsa1_gui.inc;
                   `raw` = a `.byte <op>, <len>` header (with its handler comment) and anonymous operand lines
  raw_fields       operand fields of raw records -- every one is a number with no name: a geometry word, a
                   pointer, a variable address, a service number, a digit count
  num_ptr          pointer fields (bitmap / table / buffer) spelled as a number, either form
  num_var          interpreter-B variable addresses spelled as a number (no `.equ` in include/wsa1_ram.inc)
  num_svc          interpreter-B service numbers spelled as a number (no LCDSVC_* name)
  odd_geom         macro records whose position decodes outside the 320 x 240 panel (x > 320 or y > 240):
                   not wrong bytes, but a field whose meaning is not the one the macro gives it -- TODO
  keymap_entries   panel key-map entries: `named` = `on_key KEY_*, Handler`; `indexed` = a `.long Handler`
                   line of a 32-entry key map or of a 17-entry tone-edit field-operation table (its key only an
                   index in a comment)
  keymap_numeric   key-map entries whose handler is a number
  screen_numeric   PanelScreen_VtableTable / _ViewB entries spelled as a number

RUN (inside wsa1/)
  python3 scripts/analysis/gui_readability_census.py            # the table
  python3 scripts/analysis/gui_readability_census.py --json     # the same as JSON
  python3 scripts/analysis/gui_readability_census.py --odd      # every odd_geom record
"""
import argparse
import collections
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import gui_display_list_macros as G  # noqa: E402  (the record parser and the layouts)

IMAGES = {
    "prom_a": ["prom_a/wsa1_prom_a.s"] + sorted(glob.glob(os.path.join(ROOT, "prom_a", "modules", "*.s"))),
    "prom_b": ["prom_b/wsa1_prom_b.s"] + sorted(glob.glob(os.path.join(ROOT, "prom_b", "modules", "*.s"))),
    "prom_c": sorted(glob.glob(os.path.join(ROOT, "prom_c", "**", "*.s"), recursive=True)),
    "prom_d": sorted(glob.glob(os.path.join(ROOT, "prom_d", "*.s"))),
}
MACRO = re.compile(r'^\s*(dlb?_\w+)\s+(.*?)\s*(;.*)?$')
OPTABLE_NAME = re.compile(r'^(PanelOpTable_\w+|ToneEditPage_\w+_OpTable)$')


def header(lines, i):
    """the comment block right above line i"""
    k = i - 1
    while k >= 0 and (lines[k].lstrip().startswith(";") or not lines[k].strip()):
        k -= 1
    return "\n".join(lines[k + 1:i])


KEYMAP_NAME = re.compile(r'(Button|ButtonTable|ButtonHandlers|ButtonRow|^Dispatch_FF3[89A-D])')

# operand fields of a raw record, by (interpreter, opcode): what the handler reads
A_FIELDS = {"rect": 4, "text": 2, "ptext": 3, "point": 2, "clear": 3, "blit": 4, "glyph": 2}
B_FIELDS = {0x00: 6, 0x06: 6, 0x05: 7, 0x09: 7, 0x0A: 7, 0x0B: 8, 0x02: 7, 0x07: 8, 0x03: 5, 0x08: 5,
            0x04: 5, 0x01: 6}


def text_of(path):
    p = path if os.path.isabs(path) else os.path.join(ROOT, path)
    return open(p, "rb").read().decode("latin-1").split("\n")


def census():
    rows = {}
    odd = []
    for image, files in IMAGES.items():
        c = collections.Counter()
        for path in files:
            lines = text_of(path)
            # raw records
            for i, j, rec, why in G.parse_records(lines):
                c["records_raw"] += 1
                if rec is None:
                    continue
                if rec.interp == 'A':
                    shape = G.A_KIND.get(rec.op, (None, None))[1]
                    c["raw_fields"] += A_FIELDS.get(shape, 1)
                    if shape == "blit":
                        try:
                            if isinstance(rec.field(2, 4), int):
                                c["num_ptr"] += 1
                        except ValueError:
                            pass
                else:
                    c["raw_fields"] += B_FIELDS.get(rec.op, 1)
                    try:
                        if isinstance(rec.field(2, 2), int):
                            c["num_var"] += 1
                        if rec.op != 0x01 and isinstance(rec.field(6, 1), int):
                            c["num_svc"] += 1
                        if rec.op in (0x02, 0x07, 0x03, 0x08, 0x04) and isinstance(rec.field(7, 4), int):
                            c["num_ptr"] += 1
                    except ValueError:
                        pass
            # macro records
            for n, l in enumerate(lines):
                m = MACRO.match(l)
                if not m or m.group(1).startswith("dl_") and m.group(1) not in MACROS_A or \
                        m.group(1).startswith("dlb_") and m.group(1) not in MACROS_B:
                    continue
                c["records_macro"] += 1
                args = dict(a.split("=", 1) for a in re.findall(r'\b\w+=(?:"(?:[^"\\]|\\.)*"|[^,]+)', m.group(2)))
                args = {k.strip(): v.strip() for k, v in args.items()}
                for k in ("bitmap", "table", "buffer"):
                    if k in args and re.match(r'^(0x[0-9a-fA-F]+|\d+)$', args[k]):
                        c["num_ptr"] += 1
                if "var" in args and re.match(r'^(0x[0-9a-fA-F]+|\d+)$', args["var"]):
                    c["num_var"] += 1
                if "svc" in args and re.match(r'^(0x[0-9a-fA-F]+|\d+)$', args["svc"]):
                    c["num_svc"] += 1
                for kx, ky in (("x", "y"), ("x0", "y0"), ("x1", "y1")):
                    try:
                        x, y = int(args.get(kx, "0"), 0), int(args.get(ky, "0"), 0)
                    except ValueError:
                        continue
                    if x > 320 or y > 240:
                        c["odd_geom"] += 1
                        odd.append((image, os.path.relpath(path if os.path.isabs(path) else os.path.join(ROOT, path),
                                                           ROOT), n + 1, l.strip()[:150]))
                        break
            # key maps and the screen table
            i = 0
            while i < len(lines):
                m = re.match(r'^([A-Za-z_]\w*):', lines[i])
                if not m:
                    i += 1
                    continue
                name = m.group(1)
                j = i + 1
                while j < len(lines) and re.match(r'^\s*;', lines[j]):
                    j += 1
                if j < len(lines) and re.match(r'^\s*keymap_begin\b', lines[j]):
                    while j < len(lines) and re.match(r'^\s*(keymap_begin|keymap_end|fieldops_end|on_key)\b|^\s*;', lines[j]):
                        mm = re.match(r'^\s*on_key\s+\w+\s*,\s*(\S+)', lines[j])
                        if mm:
                            c["keymap_named"] += 1
                            if re.match(r'^(0x[0-9a-fA-F]+|\d+)$', mm.group(1)):
                                c["keymap_numeric"] += 1
                        j += 1
                    i = j
                    continue
                longs = []
                while j < len(lines) and re.match(r'^\s*\.long\s', lines[j]):
                    longs.append(re.match(r'^\s*\.long\s+([^;\s]+)', lines[j]).group(1))
                    j += 1
                if name in ("PanelScreen_VtableTable", "PanelScreen_VtableTable_ViewB"):
                    c["screen_numeric"] += sum(1 for v in longs if re.match(r'^(0x[0-9a-fA-F]+|\d+)$', v))
                elif len(longs) == 18 and OPTABLE_NAME.match(name) and re.match(r'^0x0+$', longs[17]):
                    c["keymap_indexed"] += 17
                    c["keymap_numeric"] += sum(1 for v in longs[:17] if re.match(r'^(0x[0-9a-fA-F]+|\d+)$', v))
                elif longs and len(longs) % 32 == 0 and (KEYMAP_NAME.search(name) or "BUTTON CODE" in header(lines, i)) \
                        and "Mask" not in name:
                    c["keymap_indexed"] += len(longs)
                    c["keymap_numeric"] += sum(1 for v in longs if re.match(r'^(0x[0-9a-fA-F]+|\d+)$', v))
                i = j if j > i + 1 else i + 1
        rows[image] = c
    return rows, odd


MACROS_A = {v[0] for v in G.A_KIND.values()}
MACROS_B = set(G.B_KIND.values())
COLS = ["records_macro", "records_raw", "raw_fields", "num_ptr", "num_var", "num_svc", "odd_geom",
        "keymap_named", "keymap_indexed", "keymap_numeric", "screen_numeric"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--odd", action="store_true")
    a = ap.parse_args()
    rows, odd = census()
    if a.json:
        print(json.dumps({k: {c: v.get(c, 0) for c in COLS} for k, v in rows.items()}, indent=1))
        return
    table = [["image"] + COLS] + [[k] + ["{:,}".format(v.get(c, 0)) for c in COLS] for k, v in rows.items()]
    tot = ["total"] + ["{:,}".format(sum(v.get(c, 0) for v in rows.values())) for c in COLS]
    table.append(tot)
    w = [max(len(r[i]) for r in table) for i in range(len(table[0]))]
    for n, r in enumerate(table):
        print("| " + " | ".join(r[i].ljust(w[i]) for i in range(len(r))) + " |")
        if n == 0:
            print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    if a.odd:
        for o in odd:
            print("  odd %s %s:%d  %s" % o)


if __name__ == "__main__":
    main()
