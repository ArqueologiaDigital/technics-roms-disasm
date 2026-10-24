#!/usr/bin/env python3
"""entry_rename_map.py -- a sed script that respells stale func_<ADDR> names in prose.

QUESTION IT ANSWERS
  Which func_<ADDR> names quoted in notes / symbol-file comments no longer exist
  as labels in the generated source, and what is the address called now?  A
  func_<ADDR> name carries its address, so the current name is simply the label
  the last build put at that address (build/kn7000_program.labels, written by
  kn7asm).  Used when gen_program_s moved function labels onto register-save
  prologues: the old call-entry name func_<T> became func_<P>_entry (P = the
  prologue's address), or <Name>_entry when the prologue already had a name.

RUN (from kn7000/, after `make verify` so the labels file is current)
  python3 notes/convert-probes/entry_rename_map.py FILE... > SED
  sed -i -f SED FILE...
"""
import re
import sys

LABELS = "build/kn7000_program.labels"


def main():
    at, names = {}, set()
    for line in open(LABELS):
        nm, v = line.split()
        names.add(nm)
        a = int(v, 16)
        # several labels can share an address (a block name and a loc_):
        # prefer the function / entry name over a loc_
        if a not in at or at[a].startswith("loc_"):
            at[a] = nm
    stale = set()
    for path in sys.argv[1:]:
        text = open(path, "rb").read().decode("latin-1")
        stale |= {m for m in re.findall(r"\bfunc_[0-9A-F]{8}\b", text) if m not in names}
    for old in sorted(stale):
        new = at.get(int(old[5:], 16))
        if new is None:
            sys.stderr.write(f"entry_rename_map: no label at {old[5:]} for {old}\n")
            continue
        print(f"s/\\b{old}\\b/{new}/g")


if __name__ == "__main__":
    main()
