#!/usr/bin/env python3
"""Which display-list records did gui_display_list_macros.py read as interpreter B although their emitter's
comment said interpreter A -- and on what evidence?

Run it INSIDE a wsa1/ tree that still has the record headers (the tree before the respelling, 9dbc03088), with
the converter copied in and the tree built:

    git worktree add --detach "$TMPDIR/wsa1-base" 9dbc03088
    cp wsa1/scripts/tools/gui_display_list_macros.py "$TMPDIR/wsa1-base/wsa1/scripts/tools/"
    make -C "$TMPDIR/wsa1-base/wsa1" all
    cd "$TMPDIR/wsa1-base/wsa1" && python3 <this file>  > reattributed-to-interpreter-B.txt

Output: per enclosing label, how many records and by which rule (the converter's docstring and process()):
audit = notes/prom_b_dl_length_audit.py's call-site walk says B; length = the A reading is impossible and the
length is B's own; adjacent = a neighbour is B and the record reads as B; geometry = the A reading lies off
the 320 x 240 panel and B's does not.
"""
import collections
import glob
import os
import re
import sys

sys.path.insert(0, os.path.join(os.getcwd(), "scripts", "tools"))
import gui_display_list_macros as g  # noqa: E402

addrs = g.probe_addresses(("prom_a", "prom_b"))
audit = g.audit_attribution()
LBL = re.compile(r'^([A-Za-z_]\w*):')
rows = collections.defaultdict(collections.Counter)
for image in ("prom_a", "prom_b"):
    ctx = g.Ctx(image)
    for path in sorted(glob.glob(os.path.join(g.ROOT, image, "modules", "*.s"))):
        g.REATTRIBUTED.clear()
        g.process(path, ctx, collections.Counter(), [], addrs, audit)
        lines = open(path, 'rb').read().decode('latin-1').split('\n')
        for p, l, op, how in g.REATTRIBUTED:
            k = l - 1
            while k >= 0 and not LBL.match(lines[k]):
                k -= 1
            rows[(os.path.relpath(path, g.ROOT), LBL.match(lines[k]).group(1) if k >= 0 else '?')][how] += 1
print("# records whose emitter comment said interpreter A and which gui_display_list_macros.py reads as interpreter B")
print("# measured at 9dbc03088 (the tree before the respelling); columns: file, enclosing label, how decided (count)")
tot = collections.Counter()
for (p, lab), c in sorted(rows.items()):
    tot.update(c)
    print("%-62s %-58s %s" % (p, lab, ", ".join("%s %d" % kv for kv in sorted(c.items()))))
print("# total:", sum(tot.values()), dict(tot))
