#!/usr/bin/env python3
"""name_se_value_text_tables.py -- the sound editor's value-label string tables, named from their own entries (v10).

QUESTION IT ANSWERS / WHAT IT DOES
  Among the SeScreenData_0x<offset> labels of audio/sound_editor_ui.s and storage/flash_floppy_handlers.s are lists
  that hold nothing but fixed-width strings ("OFF", " ON"; "SIN", "TRI", "SQR", "SAW"; "NORM", " 1/2" ... " FIX"):
  the value labels a bound field record (sdb_str / op 0x02 and 0x07, whose `table` operand points here) prints for a
  parameter's value.  This script finds every SeScreenData label whose body is only .ascii (and .byte padding)
  lines and names it SeValText_<entries>: all entries CamelCased when there are at most four, else the first two,
  "To" and the last one.  The entries are the data itself, so the name restates what the table holds and nothing
  more.  Writes scripts/renaming/rename_se_value_text_tables_v10.sed; v9 / v7 follow through
  harmonize_version_labels.py (matched by address with a byte proof).

RUN (repository root)
  python3 scripts/renaming/name_se_value_text_tables.py           # dry run
  python3 scripts/renaming/name_se_value_text_tables.py --write   # the .sed for v10
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = ["v10/maincpu/audio/sound_editor_ui.s", "v10/maincpu/storage/flash_floppy_handlers.s"]
# long tables whose entries spell out one kind of value: named for that kind (the entries are the evidence)
OVERRIDES = {
    "SeScreenData_0x3E8C": "SeValText_CtrlDestinations",   # "PITCH BEND", "AMP ENV SUST", "FILTER CUTOFF", "PTCH LFO1 DEP" ...
    "SeScreenData_0x2F6C": "SeValText_NoteNames",          # "C-2", "D#-", "D-2" ... "G8"
    "SeScreenData_0x4EFB": "SeValText_DigEffTypes",        # "CELESTE 1", "CELESTE 2", "CHORUS 1" ... "SOLO EFFECT 2"
    "SeScreenData_0x213C": "SeValText_FilterTypes",        # "LPF+EQ", "HPF+EQ", "LPF24", "HPF24" ... "THRU"
}


NOTE = re.compile(r'^[A-G](\\\d{3}|#)?-?\d?$')


def camel(entry):
    e = re.sub(r'\\\d{3}', '', entry).strip()        # octal glyph escapes (sharp, arrows) carry no letters
    if not e:
        return "Blank"
    if e == "+":
        return "Plus"
    if e == "-":
        return "Minus"
    if re.fullmatch(r'-+', e):
        return "Dash"
    e = re.sub(r'(?<=[A-Za-z0-9])\+(?=[A-Za-z0-9])', ' And ', e)      # LPF+EQ -> Lpf And Eq
    e = re.sub(r'(\d)/(\d)', r'\1of\2', e)                          # 1/2 -> 1of2
    e = e.replace("+", " P").replace("-", " M").replace("/", " ").replace(".", "_").replace(":", "")
    parts = [p for p in re.split(r'[^A-Za-z0-9_]+', e) if p]
    out = "".join(p[:1].upper() + p[1:].lower() if p.isalpha() else p for p in parts)
    return out or "X"


def main():
    plan = {}
    for f in FILES:
        L = open(os.path.join(ROOT, f), "rb").read().decode("latin-1").split("\n")
        defined = {m.group(1) for x in L for m in [re.match(r'^([A-Za-z_]\w*):', x)] if m}
        i = 0
        while i < len(L):
            m = re.match(r'^(SeScreenData_0x[0-9A-F]+):\s*(.*)$', L[i])
            if not m:
                i += 1
                continue
            name, k, body = m.group(1), i + 1, ([m.group(2)] if m.group(2) else [])
            while k < len(L) and not re.match(r'^[A-Za-z_]\w*:', L[k]):
                if L[k].strip() and not L[k].startswith(";"):
                    body.append(L[k].split(";")[0].strip())
                k += 1
            i = k
            pad = lambda b: b.startswith(".byte") and all(v.strip().lower() in ("0xff", "0x00", "0", "255")
                                                          for v in b[5:].split(","))
            if not body or not all(b.startswith(".ascii") or pad(b) for b in body):
                continue                       # records spelled as .byte make it a screen list, not a value table
            entries = [e for b in body if b.startswith(".ascii") for e in re.findall(r'"((?:[^"\\]|\\.)*)"', b)]
            if len(entries) < 2:
                continue                       # one string is a caption, not a value table
            if all(NOTE.match(e.strip()) for e in entries):
                stem = "NoteNames"                     # C-2, D#-2 ... one name per key number
            else:
                words = [camel(e) for e in entries]
                stem = "_".join(words) if len(words) <= 4 else "%s_%s_To_%s" % (words[0], words[1], words[-1])
            new = OVERRIDES.get(name, "SeValText_" + stem)
            n = 2
            while new in defined or new in plan.values():
                new = "SeValText_%s_%d" % (stem, n)
                n += 1
            plan[name] = new
    for o, n in plan.items():
        print("%-22s -> %s" % (o, n))
    print("%d value-text tables" % len(plan))
    if "--write" in sys.argv:
        with open(os.path.join(ROOT, "scripts/renaming/rename_se_value_text_tables_v10.sed"), "w") as f:
            f.write("# v10: sound-editor value-label string tables named from their entries "
                    "(scripts/renaming/name_se_value_text_tables.py).\n")
            for o, n in sorted(plan.items(), key=lambda x: -len(x[0])):
                f.write("s/\\b%s\\b/%s/g\n" % (o, n))


if __name__ == "__main__":
    main()
