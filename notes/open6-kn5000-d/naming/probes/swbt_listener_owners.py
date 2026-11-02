#!/usr/bin/env python3
"""Which SwbtWr bank-2 code (= panel TLV tag) registers each listener, per KN5000 maincpu tree.

QUESTION IT ANSWERS
  The HdaeRom_* / SwbtB2_* listener labels in audio/note_voice_mapping.s are reached only through the
  SwbtB2_Code<NN>_Listeners lists of ui_widgets/widget_dispatch.s.  This prints, for every tree, each label
  matching the pattern and the code(s) whose list holds it, so a rename by tag can be checked to mean the
  same thing in v10 / v9 / v7 / v6 / v5.

RUN (repository root):
  python3 notes/open6-kn5000-d/naming/probes/swbt_listener_owners.py [regex, default ^(HdaeRom_|SwbtB2_Code..?_(Nop)?Listener$)]
"""
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
PAT = re.compile(sys.argv[1] if len(sys.argv) > 1 else r"^(HdaeRom_|SwbtB2_Code.._(Nop)?Listener$)")
for tree in ("v10", "v9", "v7", "v6", "v5"):
    p = os.path.join(REPO, tree, "maincpu", "ui_widgets", "widget_dispatch.s")
    code, owners = None, {}
    for line in open(p, "rb").read().decode("latin-1").splitlines():
        m = re.match(r"^SwbtB2_Code([0-9A-F]{2})_Listeners:(.*)$", line)
        if m:
            code = m.group(1)
            line = m.group(2)
        elif re.match(r"^[A-Za-z_]\w*:", line):
            code = None
        m = re.search(r"\.long\s+([A-Za-z_]\w*)", line)
        if code and m and PAT.search(m.group(1)):
            owners.setdefault(m.group(1), []).append(code)
    print(tree)
    for k in sorted(owners):
        print("  %-36s %s" % (k, " ".join("0x" + c for c in owners[k])))
