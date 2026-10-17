#!/usr/bin/env python3
"""name_se_screen_lists_by_role.py -- sound-editor screen lists named from the role their drawing code gives them (v10).

QUESTION IT ANSWERS / WHAT IT DOES
  The SeScreenData_0x<offset> labels of audio/sound_editor_ui.s and storage/flash_floppy_handlers.s are record lists
  that the sound editor draws: a routine loads XIY (the first record; XIX, when loaded, is the exclusive END, which is
  usually the next list's start) and calls a SeGfx_* drawer.  name_se_screen_records.py named the lists every code
  reference of which comes from one routine; it counts an XIX end bound as a reader too, so a list that one routine
  draws and another merely ends at stayed positional.  This script uses the role instead:
    1. FIELD-RECORD TABLES.  `ld xiy, T` + `call SeGfx_DrawIndexedBoundRecord` (with A = the field index) makes T a
       table of LE32 pointers, entry i = the bound record of field i (SeGfx_DrawIndexedBoundRecord: XIY = table[A]).
       T is named <Owner>_FieldRecordPtrs and each positional entry <Owner>_Field<i>_Record, Owner = the field
       routine's title (<X>_DrawField -> X; one table shared by two titles' field routines -> both, joined).
    2. LISTS DRAWN FROM ONE OWNER.  Every routine that loads the list into XIY before a SeGfx_* call is a drawer.
       When all drawers belong to one title (its _DrawStaticScreen / _DrawField) or to one named helper, the list
       is <Owner>_Records<N>, N continuing after the owner's existing _Records labels.  Lists whose drawers belong
       to different titles, to a SeGfx_* op handler, or to a routine that still carries an old, wrong SeMenu_*
       name (CompareAndApply, FilterEdit, BankEdit, PresetInit, EqEdit, NameEdit, PresetBrowser, Utility) are left.
  Labels move no bytes.  Writes scripts/renaming/rename_se_screen_lists_by_role_v10.sed and the same pairs as
  reviewed proposals (analysis/kn5000-naming/proposals-2026-10-17-se-lists-by-role.json) for the version harmonizer.

RUN (repository root)
  python3 scripts/renaming/name_se_screen_lists_by_role.py            # dry run
  python3 scripts/renaming/name_se_screen_lists_by_role.py --write
"""
import collections
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = ["v10/maincpu/audio/sound_editor_ui.s", "v10/maincpu/storage/flash_floppy_handlers.s"]
LOCAL = re.compile(r'_(Skip|Join|Loop|Return|Epilogue|Done|Next|Exit|Cont|End|Default|Resume|Nop|SetupPath|DefaultPath'
                   r'|CallHelper)\d*$')
POSL = re.compile(r'^SeScreenData_0x[0-9A-F]+$')
STALE = re.compile(r'^SeMenu_(CompareAndApply|FilterEdit|BankEdit|PresetInit|EqEdit|NameEdit|PresetBrowser|Utility'
                   r'|WaveformSelect)_')
TITLE_METHOD = re.compile(r'^(Se\w+?)_(DrawStaticScreen|DrawField)$')


def owner_of(routines):
    """One owner name for a set of drawing routines, or None."""
    titles = set()
    for r in routines:
        if STALE.match(r) or r.startswith("SeGfx_"):
            return None
        m = TITLE_METHOD.match(r)
        titles.add(m.group(1) if m else r)
    if len(titles) == 1:
        return titles.pop()
    return None


def main():
    src = {f: open(os.path.join(ROOT, f), "rb").read().decode("latin-1").split("\n") for f in FILES}
    defined = set()
    xiy, idx = collections.defaultdict(set), collections.defaultdict(set)
    longs = {}
    for f, L in src.items():
        cur, curlab = None, None
        for i, line in enumerate(L):
            m = re.match(r'^([A-Za-z_]\w*):', line)
            if m:
                defined.add(m.group(1))
                curlab = m.group(1)
                if not LOCAL.search(curlab) and not curlab.startswith("SeScreenData_") \
                        and not re.search(r'_Records\d*$', curlab):
                    cur = curlab
            mm = re.match(r'^\s+\.long\s+(\w+)\s*$', line.split(";")[0])
            if mm and curlab:
                longs.setdefault(curlab, []).append(mm.group(1))
            mm = re.match(r'^\s+ld\s+xiy,\s*(\w+)\s*$', line.split(";")[0])
            if mm and cur:
                nxt = ""
                for j in range(i + 1, min(i + 5, len(L))):
                    c = re.match(r'^\s+call\s+(\w+)', L[j])
                    if c:
                        nxt = c.group(1)
                        break
                if nxt == "SeGfx_DrawIndexedBoundRecord":
                    idx[mm.group(1)].add(cur)
                elif nxt.startswith("SeGfx_"):
                    xiy[mm.group(1)].add(cur)
    plan, taken = {}, set(defined)

    def take(old, new):
        n, base = 2, new
        while new in taken:
            new = "%s%d" % (base, n)
            n += 1
        taken.add(new)
        plan[old] = new

    # 1. field-record tables and their entries
    for t in sorted(idx):
        if not POSL.match(t):
            continue
        titles = []
        for r in sorted(idx[t]):
            m = TITLE_METHOD.match(r)
            if not m or STALE.match(r):
                titles = None
                break
            titles.append(m.group(1))
        if not titles:
            continue
        owner = "_".join(sorted(set(titles)))
        take(t, owner + "_FieldRecordPtrs")
        for k, e in enumerate(longs.get(t, [])):
            if POSL.match(e) and e not in plan:
                take(e, "%s_Field%d_Record" % (owner, k))
    # 2. lists drawn from one owner
    counters = collections.Counter()
    for d in defined:
        m = re.match(r'^(\w+)_Records(\d*)$', d)
        if m:
            counters[m.group(1)] = max(counters[m.group(1)], int(m.group(2) or 1))
    for t in sorted(xiy):
        if not POSL.match(t) or t in plan:
            continue
        owner = owner_of(xiy[t])
        if not owner:
            continue
        counters[owner] += 1
        n = counters[owner]
        take(t, "%s_Records%s" % (owner, "" if n == 1 else n))
    for o, n in plan.items():
        print("%-22s -> %s" % (o, n))
    print("%d lists named" % len(plan))
    if "--write" in sys.argv:
        with open(os.path.join(ROOT, "scripts/renaming/rename_se_screen_lists_by_role_v10.sed"), "w") as f:
            f.write("# v10: sound-editor screen lists named from the role their drawing code gives them "
                    "(scripts/renaming/name_se_screen_lists_by_role.py).\n")
            for o, n in sorted(plan.items(), key=lambda x: -len(x[0])):
                f.write("s/\\b%s\\b/%s/g\n" % (o, n))
        recs = [dict(old=o, new=n, verdict="name", basis="drawing role (field-record table / XIY drawer)",
                     evidence=["scripts/renaming/name_se_screen_lists_by_role.py (rule in its docstring)"])
                for o, n in plan.items()]
        json.dump(recs, open(os.path.join(ROOT, "analysis/kn5000-naming/proposals-2026-10-17-se-lists-by-role.json"),
                             "w"), indent=1)


if __name__ == "__main__":
    main()
