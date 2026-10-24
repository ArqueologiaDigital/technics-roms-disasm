"""Delete the PORT-ORPHAN labels nothing references.

The strings pass of scripts/tools/port_hdae5000_version.py keeps the label of every
v2.06i string the target lacks, marked `; PORT-ORPHAN`, in front of the next string
(so code that still names it keeps assembling until the code is ported).  Once the
tree is byte-identical, an orphan nothing references names nothing: delete it.  A
referenced one is listed for a person instead.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/07_orphan_labels.py
"""
import collections
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
files = sorted(f for f in os.listdir(T) if f.endswith(".s"))
text = {f: open(os.path.join(T, f), "rb").read().split(b"\n") for f in files}
ident = re.compile(rb'(?<![\w.@])(\.L[A-Za-z_]\w*|[A-Za-z_]\w*)')
lab = re.compile(rb'^(\.L[A-Za-z_]\w*|[A-Za-z_]\w*):')
refs = collections.Counter()
for L in text.values():
    for ln in L:
        code = ln.split(b";")[0] if b'"' not in ln else ln
        m = lab.match(code)
        if m:
            code = code[m.end():]
        for t in ident.findall(code):
            refs[t] += 1
gone = kept = 0
for f, L in text.items():
    out = []
    for ln in L:
        m = lab.match(ln)
        if m and b"PORT-ORPHAN" in ln:
            if refs[m.group(1)]:
                kept += 1
                print("referenced orphan, left for review: %s %s" % (f, m.group(1).decode()))
                out.append(ln)
            else:
                gone += 1
            continue
        out.append(ln)
    if out != L:
        open(os.path.join(T, f), "wb").write(b"\n".join(out))
print("deleted %d unreferenced orphan labels, %d referenced left" % (gone, kept))
