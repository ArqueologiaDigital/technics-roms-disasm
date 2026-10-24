"""Strip the v2.06i address that follows a label as its comment (`Label:\t; 0x2E2568`).

Those comments came over with the labels and are wrong for v2.01i, and inline address
comments are against the repo's policy anyway (CLAUDE.md, "No Inline Address
Comments").  Only the address goes: the rest of such a comment (`; 0x2E2A7C, 5 x .long
-> string`) stays.  hdae5000/ is not touched.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/14_label_address_comments.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
pat = re.compile(rb"^((?:\.L)?[A-Za-z_]\w*:)(\s*);\s*(?:0x[0-9A-Fa-f]{5,6}|[0-9A-Fa-f]{6}h)\b[,;:]?\s*(.*)$")
n = 0
for fn in sorted(os.listdir(T)):
    if not fn.endswith(".s"):
        continue
    p = os.path.join(T, fn)
    ls = open(p, "rb").read().split(b"\n")
    for i, l in enumerate(ls):
        m = pat.match(l)
        if m:
            rest = m.group(3).strip()
            ls[i] = m.group(1) + ((m.group(2) or b"\t") + b"; " + rest if rest else b"")
            n += 1
    open(p, "wb").write(b"\n".join(ls))
print("%d label address comments stripped" % n)
