"""Drop the positional labels the removals left piled on another label (all code files).

When the passes delete code the target lacks (a TLX bit-8 test, a select-all case ...) the
labels of that code stay, collected in front of the next surviving instruction, where
another label already stands.  A label is dropped when it has no reference anywhere in the
tree, shares its address with another label, and is positional: a .L label or a name
ending in _Skip / _Join / _Loop / _Next / _Done / _bit<n> / _exit / _final and the like.
Byte-neutral; scripts/analysis/hdae5000_version_label_check.py lists the piles it leaves.
"""
import collections
import os
import re
import sys
from _edit import ROOT, TREE, read, write

sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

FILES = ["hd-ae5000_%s.s" % TREE[len("hdae5000_"):], "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
         "hdae5000_ui_display.s", "hdae5000_utilities.s", "hdae5000_data_tables.s", "hdae5000_init_data.s"]
POS = re.compile(r"^\.L|_(Skip|Join|Loop|Next|Done|Default|Epilogue|Exit|Return|Fail|Ok)\d*$|_bit\d+$|"
                 r"_(exit|final|done|continue|next|ret\d*|skip\d*)$|_[0-9a-f]$")
bld = P.do_build(TREE[len("hdae5000_"):])
assert bld.ok, bld.stderr[-1500:]
names_at = collections.defaultdict(list)
for f, n, s, e in bld.lines:
    m = re.match(rb"^((?:\.L)?[A-Za-z_]\w*):", bld.text(f, n))
    if m:
        names_at[s].append(m.group(1).decode())
texts = {f: read(f) for f in FILES}
refs = collections.Counter()
for s in texts.values():
    for ln in s.split(b"\n"):
        code = re.sub(rb"^(?:\.L)?[A-Za-z_]\w*:", b"", ln.split(b";", 1)[0])
        for t in re.findall(rb"(?<![\w@])(\.L[A-Za-z_]\w*|[A-Za-z_]\w*)", code):
            refs[t.decode()] += 1
drop = set()
for a, ns in names_at.items():
    if len(ns) < 2:
        continue
    cands = [x for x in ns if refs[x] == 0 and POS.search(x)]
    keep = [x for x in ns if x not in cands]
    if not keep:
        keep, cands = [cands[0]], cands[1:]
    drop.update(cands)
for f, s in texts.items():
    out = []
    for ln in s.split(b"\n"):
        m = re.match(rb"^((?:\.L)?[A-Za-z_]\w*):[ \t]*(.*)$", ln)
        if m and m.group(1).decode() in drop:
            rest = m.group(2)
            if rest.strip() and not rest.strip().startswith(b";"):
                out.append(b"\t" + rest)
            continue
        out.append(ln)
    write(f, b"\n".join(out))
print("%d piled positional labels dropped" % len(drop))
