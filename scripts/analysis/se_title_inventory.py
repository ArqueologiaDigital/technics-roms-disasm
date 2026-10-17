#!/usr/bin/env python3
"""se_title_inventory.py -- the sound editor's 32 titles: id, TT name, routines, and the captions each page draws.

QUESTION IT ANSWERS
  "What is each sound-editor title (screen), which routines draw it, and does the page each static-screen routine
   draws agree with the title it is filed under?"  For every title InitializeScoop registers (RegTitle 0x6 ...,
  ids 0x20-0x3F, display/scoop_display.s) it prints the TT_ name, the NAKA main function, the entries of the two
  per-title tables in audio/sound_editor_ui.s (SeTitle_StaticScreenTable, SeTitle_FieldDrawTable; index = id -
  0x20) and the text the static-screen routine draws: the sd_ctext / sd_ptext / sd_text strings of every record
  list it (or a routine it calls, two levels deep, SeGfx_* excepted) loads into XIY.  The captions are the check
  on scripts/renaming/name_se_title_methods.py: title 0x32 TT_SEFILL241's routine draws LOW PASS -24dB, 0x3E
  TT_SEWRTMEM's draws MEMORY WRITE, and so on.  A title whose captions come only through XIX bounds or data shows
  none.

RUN (repository root)
  python3 scripts/analysis/se_title_inventory.py [--tree v10]        # plain listing
  python3 scripts/analysis/se_title_inventory.py --markdown          # the technics-docs table
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LOCAL = re.compile(r'_(Skip|Join|Loop|Return|Epilogue|Done|Next|Exit|Cont|End|Default|Resume|Nop)\d*$')


def main():
    a = sys.argv[1:]
    tree = a[a.index("--tree") + 1] if "--tree" in a else "v10"
    src = open(os.path.join(ROOT, tree, "maincpu/display/scoop_display.s"), "rb").read().decode("latin-1")
    titles = {int(m.group(2), 16): (m.group(1), m.group(3)) for m in re.finditer(
        r'RegTitle 0x6, InitializeScoop_Str_(TT_SE\w+), (0x[0-9a-f]+), NAKA_MAINFUNC_(\w+)', src)}
    L = open(os.path.join(ROOT, tree, "maincpu/audio/sound_editor_ui.s"), "rb").read().decode("latin-1").split("\n")
    lab = {m.group(1): i for i, x in enumerate(L) for m in [re.match(r'^([A-Za-z_]\w*):', x)] if m}

    def table(name):
        i, out = lab[name] + 1, []
        while L[i].strip().startswith(".long"):
            out.append(L[i].split()[-1])
            i += 1
        return out

    def list_texts(start):
        if start not in lab:
            return []
        i, out = lab[start] + 1, []
        while i < len(L) and not re.match(r'^[A-Za-z_]\w*:', L[i]):
            if re.match(r'^\s+sd_(ctext|ptext|text)\b', L[i]):
                out += re.findall(r'"([^"]*)"', L[i])
            i += 1
        return out

    def routine_texts(name, depth=0, seen=None):
        seen = set() if seen is None else seen
        if name in seen or name not in lab or depth > 2:
            return []
        seen.add(name)
        i, out = lab[name] + 1, []
        while i < len(L):
            m = re.match(r'^([A-Za-z_]\w*):', L[i])
            if m and not LOCAL.search(m.group(1)):
                break
            m = re.match(r'^\s+ld\s+xiy,\s*(\w+)', L[i])
            if m:
                out += list_texts(m.group(1))
            m = re.match(r'^\s+call\s+(\w+)', L[i])
            if m and not m.group(1).startswith("SeGfx_"):
                out += routine_texts(m.group(1), depth + 1, seen)
            i += 1
        return out

    def clean(t):
        t = re.sub(r'\\\d{3}', '', t).strip()           # drop octal glyph escapes (arrows, marks)
        return t.replace("0", "O") if re.fullmatch(r'[A-Z0-9 /:.-]+', t) and re.search(r'[A-Z]0|0[A-Z]', t) else t

    st, fd = table("SeTitle_StaticScreenTable"), table("SeTitle_FieldDrawTable")
    rows = []
    for k in range(32):
        tid = 0x20 + k
        tt, func = titles[tid]
        caps = []
        for t in routine_texts(st[k]):
            c = clean(t)
            if 1 < len(c) <= 30 and c not in caps and not re.fullmatch(r'[\d ()_:~-]*', c) and len(caps) < 6:
                caps.append(c)
        rows.append(("0x%02X" % tid, tt, "`%s`" % st[k], "`%s`" % fd[k], " / ".join(caps)))
    if "--markdown" in a:
        head = ("id", "title", "static-screen routine", "field routine", "captions drawn")
        w = [max(len(r[i]) for r in rows + [head]) for i in range(5)]
        line = lambda r: "| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |"
        print(line(head))
        print("|" + "|".join("-" * (x + 2) for x in w) + "|")
        for r in rows:
            print(line(r))
    else:
        for r in rows:
            print("  ".join(r))


if __name__ == "__main__":
    main()
