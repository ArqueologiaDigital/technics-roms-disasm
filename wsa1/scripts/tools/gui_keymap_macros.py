#!/usr/bin/env python3
"""gui_keymap_macros.py -- respell the WSA1's 32-entry panel key maps as `on_key KEY_*, Handler` lines.

QUESTION IT ANSWERS
  "Which handler does each panel key run on each screen?"  A screen's Button method indexes a 32-entry table
  of handler pointers with the 5-bit panel key code (include/wsa1_gui.inc, PANEL KEY MAPS; the key behind each
  code: notes/FINDINGS-prom_a-panel-control-map.md).  Written as `.long Handler ; [ 15]`, the key is only an
  index in a comment; written as `on_key KEY_Exit, ExitKey_SongClear`, it is in the source, and the macros
  refuse a table that skips or repeats a code.

WHICH TABLES
  A label followed by a run of `.long` lines whose count is a multiple of 32, whose name says it is a key map
  (ButtonTable_*, *_ButtonTable, ScreenButtons_*, ScreenButtonHandlers_*, ScreenButtonRow_*,
  *_ButtonHandlers, and the disk-menu module's Dispatch_FF3xxx matrices, whose CONTROL LEGEND header ties
  them to the codes), and NOT a mask table (PanelButton_BitMask32 / _InterlockMask32 hold bit masks).
  The check that they are key maps is in the data: in every 32-entry block, slot 0x0F (EXIT) is the handler
  that leaves the screen -- --check lists each block's slot-0x0F target.
  A multiple of 32 is a matrix of key maps, one per page or row; each row is its own keymap_begin/_end.

RUN (inside wsa1/)
  python3 scripts/tools/gui_keymap_macros.py            # dry run: the tables it would respell
  python3 scripts/tools/gui_keymap_macros.py --check    # and every block's slot-0x0F handler
  python3 scripts/tools/gui_keymap_macros.py --apply    # rewrite, then: make gate-wsa1
"""
import argparse
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NAME = re.compile(r'^(ButtonTable_\w+|\w+_ButtonTable|ScreenButtons_\w+|ScreenButtonHandlers_\w+|ScreenButtonRow_\w+|'
                  r'\w+_ButtonHandlers|Dispatch_FF3[89A-D][0-9A-F]{2})$')
KEYS = (["KEY_SoftKeyCol%d" % (i + 1) for i in range(8)] + ["KEY_LcdRow%d" % (i + 1) for i in range(5)] +
        ["KEY_MinusPlus", "KEY_Code0E", "KEY_Exit", "KEY_Page"] + ["KEY_SoftKeyCol%dAlt" % (i + 1) for i in range(8)] +
        ["KEY_PageAlt", "KEY_Code1A"] +
        ["KEY_NumberPad", "KEY_Code1C", "KEY_Code1D", "KEY_Compare", "KEY_Code1F"])
assert len(KEYS) == 32
OPS = re.compile(r'^(PanelOpTable_\w+|ToneEditPage_\w+_OpTable)$')
LONG = re.compile(r'^\s*\.long\s+([^;]+?)\s*(;(.*))?$')
BOILER = re.compile(r'^\s*([0-9A-F]{6}\s*)?\[\s*\d+\]\s*$')


def tail_of(cmt, drop=None):
    """the entry comment, less the address and index the emitters wrote (and the `-> 0x...` they restate)"""
    if not cmt or BOILER.match(cmt):
        return ""
    c = re.sub(r'^\s*([0-9A-F]{6}\s*)?(\[\s*\d+\]\s*)?', '', cmt).strip()
    c = re.sub(r'^->\s*0x[0-9A-Fa-f]+\s*', '', c).strip()
    if drop and re.match(r'^(%s)$' % drop, c):
        c = ""
    return "\t; " + c if c else ""


def pad(key):
    """tabs after `\ton_key\t<key>,` up to column 40, where the handler starts"""
    col = 16 + len(key) + 1
    t = ""
    while col < 40:
        col = (col // 8 + 1) * 8
        t += "\t"
    return t or "\t"


def process(path, check):
    lines = open(path, "rb").read().decode("latin-1").split("\n")
    out, i, found = [], 0, []
    while i < len(lines):
        m = re.match(r'^([A-Za-z_]\w*):', lines[i])
        if not m:
            out.append(lines[i])
            i += 1
            continue
        j = i + 1
        ents = []
        while j < len(lines):
            lm = LONG.match(lines[j])
            if not lm:
                break
            ents.append((lm.group(1), lm.group(3)))
            j += 1
        name = m.group(1)
        # the comment block right above the label (back to the previous non-comment line)
        k = i - 1
        while k >= 0 and (lines[k].lstrip().startswith(";") or not lines[k].strip()):
            k -= 1
        header = "\n".join(lines[k + 1:i])
        keyed = bool(NAME.match(name)) or "BUTTON CODE" in header
        if ents and len(ents) == 18 and OPS.match(name) and re.match(r'^0x0+$', ents[17][0]):
            found.append((name, 0, [ents[15][0]]))
            out.append(lines[i])
            out.append("\tkeymap_begin")
            for k in range(17):
                tgt, cmt = ents[k]
                out.append("\ton_key\t%s,%s%s%s" % (KEYS[k], pad(KEYS[k]), tgt, tail_of(cmt)))
            out.append("\tfieldops_end" + tail_of(ents[17][1], drop=r'zero'))
            i = j
            continue
        if not ents or len(ents) % 32 or not keyed or "Mask" in name:
            out.append(lines[i])
            i += 1
            continue
        found.append((name, len(ents) // 32, [ents[r * 32 + 15][0] for r in range(len(ents) // 32)]))
        out.append(lines[i])
        for r in range(len(ents) // 32):
            if len(ents) > 32:
                out.append("; row %d of %d" % (r, len(ents) // 32))
            out.append("\tkeymap_begin")
            for k in range(32):
                tgt, cmt = ents[r * 32 + k]
                out.append("\ton_key\t%s,%s%s%s" % (KEYS[k], pad(KEYS[k]), tgt, tail_of(cmt)))
            out.append("\tkeymap_end")
        i = j
    return "\n".join(out), found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    n = nops = 0
    for path in sorted(glob.glob(os.path.join(ROOT, "prom_[ab]", "modules", "*.s"))):
        new, found = process(path, a.check)
        for name, rows, exits in found:
            n += rows
            nops += rows == 0
            print("%-48s %s  %s" % (name, "%d x 32" % rows if rows else "17 ops ", os.path.relpath(path, ROOT)))
            if a.check:
                for r, e in enumerate(exits):
                    print("      row %d  KEY_Exit -> %s" % (r, e))
        if a.apply and found:
            open(path, "wb").write(new.encode("latin-1"))
    print("respelled now: %d key-map rows of 32, %d field-operation tables of 17" % (n, nops))


if __name__ == "__main__":
    main()
