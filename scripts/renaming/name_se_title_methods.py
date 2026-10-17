#!/usr/bin/env python3
"""name_se_title_methods.py -- the sound editor's two per-title method tables, named from the title registry.

QUESTION IT ANSWERS / WHAT IT DOES
  The sound editor (SE) has 32 titles (screens), ids 0x20-0x3F, registered by `RegTitle 0x6, <TT_ name>, <id>,
  NAKA_MAINFUNC_<X>TitleFunc` in InitializeScoop (display/scoop_display.s): TT_SEMENU, TT_SEEASY, TT_SETONTON1 ...
  TT_SEWRTSND.  Two 48-entry tables in audio/sound_editor_ui.s are indexed by `title id - 0x20`:
    - the static-screen table (was SeMenu_ShowPopupDialog_Draw; now SeTitle_StaticScreenTable), read by its
      dispatcher (was SeMenu_ShowPopupDialog; now SeTitle_DrawStaticScreen): `hl = (xiz+8) - 0x20; sla hl,2;
      xiy = (table+hl); call (xiy)` -- each entry draws the title's fixed captions and frames;
    - the field table (was SeMenu_ShowConfirmDialog_Data; now SeTitle_FieldDrawTable), read by its dispatcher
      (was SeMenu_ShowConfirmDialog; now SeTitle_DrawField) the same way with A = the field index -- each entry
      redraws one bound parameter field (SeGfx_DrawIndexedBoundRecord ...).  Its callers pass the title id
      and the field after a value changed (e.g. SeAmpAmp2_OnColumn4: `pushw 1; pushw 44; call ...`).
  Seven static-screen entries had been named <X>_DrawStaticScreen from this index already (entry 17 = title 0x31
  = SeFilHpq1 ...); the rest carried guessed names that the bodies contradict (SeMenu_Utility_CompareBlock draws
  the LOW PASS -12dB page; SeMenu_Utility_FormatNumber is a label inside a frame-drawing helper).  This script
  names every entry from the title registry: static-screen entry i -> <X>_DrawStaticScreen, field entry i ->
  <X>_DrawField, X from NAKA_MAINFUNC_<X>TitleFunc of title 0x20 + i (title 0x20 keeps SeMenuTitle).  A field
  routine shared by several titles is named after all of them: titles whose names differ only in the
  three-letter group (SePitLfo1 / SeAmpLfo1 / SeFilLfo1) give Se<groups><tail> (SePitAmpFilLfo1), others are
  joined with '_'.  Entries that are the shared bare `ret` (codes no title handles) keep their name.
  It writes scripts/renaming/rename_se_title_methods_<tree>.sed and prints the header comment each renamed
  routine gets.

RUN (repository root)
  python3 scripts/renaming/name_se_title_methods.py            # dry run, all three trees
  python3 scripts/renaming/name_se_title_methods.py --write    # writes the .sed files
  python3 scripts/renaming/name_se_title_methods.py --headers  # inserts the header comments (after the sed)
"""
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TABLES = {  # old table name -> (new table name, old dispatcher, new dispatcher, method)
    "SeMenu_ShowPopupDialog_Draw": ("SeTitle_StaticScreenTable", "SeMenu_ShowPopupDialog", "SeTitle_DrawStaticScreen",
                                    "DrawStaticScreen"),
    "SeMenu_ShowConfirmDialog_Data": ("SeTitle_FieldDrawTable", "SeMenu_ShowConfirmDialog", "SeTitle_DrawField",
                                      "DrawField"),
}
RET_ENTRY = "SeMenu_WaveformSelect_End"


def titles(tree):
    src = open(os.path.join(ROOT, tree, "maincpu/display/scoop_display.s"), "rb").read().decode("latin-1")
    t = {}
    for m in re.finditer(r'RegTitle 0x6, InitializeScoop_Str_(TT_SE\w+), (0x[0-9a-f]+), NAKA_MAINFUNC_(\w+)TitleFunc',
                         src):
        t[int(m.group(2), 16)] = (m.group(1), m.group(3))
    assert sorted(t) == list(range(0x20, 0x40)), (tree, sorted(t))
    t[0x20] = (t[0x20][0], "SeMenuTitle")
    return t


def table_entries(lines, label, alt=None):
    i = next(k for k, x in enumerate(lines) if x.startswith(label + ":") or (alt and x.startswith(alt + ":")))
    out = []
    for x in lines[i + 1:]:
        m = re.match(r'^\s+\.long\s+(\w+)', x)
        if not m:
            break
        out.append(m.group(1))
    assert len(out) == 48, (label, len(out))
    return out


def shared_name(xs):
    xs = sorted(xs, key=lambda x: ["Pit", "Amp", "Fil"].index(x[2:5]) if x[2:5] in ("Pit", "Amp", "Fil") else 9)
    tails = {x[5:] for x in xs}
    if len(tails) == 1 and all(x[2:5] in ("Pit", "Amp", "Fil") for x in xs):
        return "Se" + "".join(x[2:5] for x in xs) + tails.pop()
    return "_".join(xs)


def plan(tree, check=True):
    path = os.path.join(ROOT, tree, "maincpu/audio/sound_editor_ui.s")
    lines = open(path, "rb").read().decode("latin-1").split("\n")
    tt = titles(tree)
    rules, headers = {}, {}
    for old_table, (new_table, old_disp, new_disp, method) in TABLES.items():
        ent = table_entries(lines, old_table, new_table)
        users = collections.defaultdict(list)
        for i, lab in enumerate(ent[:32]):
            if lab not in (RET_ENTRY,):
                users[lab].append(0x20 + i)
        for i, lab in enumerate(ent[32:]):
            assert lab == RET_ENTRY, (tree, old_table, 32 + i, lab)
        for lab, ids in users.items():
            xs = [tt[t][1] for t in ids]
            new = "%s_%s" % (xs[0] if len(xs) == 1 else shared_name(xs), method)
            if lab != new:
                assert lab not in rules, (tree, lab)
                rules[lab] = new
            headers[new] = (method, ids, [tt[t][0] for t in ids], new_table)
        rules[old_table] = new_table
        rules[old_disp] = new_disp
    # a new name must not exist yet (unless it is the label being renamed to itself)
    defined = {m.group(1) for x in lines for m in [re.match(r'^([A-Za-z_]\w*):', x)] if m}
    for o, n in rules.items():
        assert not check or n not in defined or n == o, (tree, o, n, "new name already defined")
    assert len(set(rules.values())) == len(rules), (tree, "two labels get the same name")
    return rules, headers


def header_text(new, info):
    method, ids, tts, table = info
    what = ("draws the page's fixed captions and frames" if method == "DrawStaticScreen" else
            "redraws one parameter field, A = the field index")
    who = ", ".join("0x%02X %s" % (i, t) for i, t in zip(ids, tts))
    ent = ", ".join(str(i - 0x20) for i in ids)
    head = "; %s: %s routine of sound-editor title%s %s (entr%s %s of %s, indexed by title id - 0x20): %s." % (
        new, "Static-screen" if method == "DrawStaticScreen" else "Field-redraw", "s" if len(ids) > 1 else "", who,
        "ies" if len(ids) > 1 else "y", ent, table, what)
    words, out, cur = head.split(" "), [], ""
    for w in words + ["Basis:", "the", "table", "index", "and", "RegTitle", "(scripts/renaming/name_se_title_methods.py)."]:
        if len(cur) + len(w) + 1 > 118:
            out.append(cur)
            cur = ";  "
        cur = (cur + " " + w) if cur not in ("", ";  ") else (cur + w if cur else w)
    out.append(cur)
    return out


def main():
    a = sys.argv[1:]
    for tree in ("v10", "v9", "v7"):
        rules, headers = plan(tree, check="--headers" not in a)
        n = sum(1 for o in rules if o not in TABLES and o not in [v[1] for v in TABLES.values()])
        print("%s: %d entry renames (+ 2 tables, 2 dispatchers)" % (tree, n))
        if "--write" in a:
            out = os.path.join(ROOT, "scripts/renaming/rename_se_title_methods_%s.sed" % tree)
            with open(out, "w") as f:
                f.write("# %s: the sound editor's per-title static-screen and field-redraw tables and their entries,\n"
                        "# named from the title registry (scripts/renaming/name_se_title_methods.py).\n" % tree)
                for o, nn in sorted(rules.items(), key=lambda x: -len(x[0])):
                    f.write("s/\\b%s\\b/%s/g\n" % (o, nn))
            print("   -> %s" % os.path.relpath(out, ROOT))
        elif "--headers" not in a:
            for o, nn in sorted(rules.items()):
                print("   %-40s -> %s" % (o, nn))
        if "--headers" in a:
            path = os.path.join(ROOT, tree, "maincpu/audio/sound_editor_ui.s")
            lines = open(path, "rb").read().decode("latin-1").split("\n")
            added = 0
            for new, info in headers.items():
                idx = [k for k, x in enumerate(lines) if x.startswith(new + ":")]
                if len(idx) != 1:
                    print("   no single definition of", new)
                    continue
                k = idx[0]
                if lines[k - 1].startswith(";"):
                    continue                   # keeps an existing header
                lines[k:k] = header_text(new, info)
                added += 1
            data = "\n".join(lines).encode("latin-1")
            with open(path + ".tmp", "wb") as f:
                f.write(data)
            os.replace(path + ".tmp", path)
            print("   %d headers added" % added)


if __name__ == "__main__":
    main()
