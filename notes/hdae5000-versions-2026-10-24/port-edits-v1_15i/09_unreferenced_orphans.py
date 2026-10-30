"""Drop the labels the `strings` pass marked PORT-ORPHAN (a string v1.15i lacks) that nothing
references any more once 04-06 removed their readers (all files).

A PORT-ORPHAN label has no string of its own: it sits in front of the next one, so left in
place it would name the wrong string.  One that is still referenced is kept and reported.
"""
import re
from _edit import read, write

FILES = ["hd-ae5000_v1_15i.s", "hdae5000_hd_driver.s", "hdae5000_filesystem.s", "hdae5000_ui_display.s",
         "hdae5000_utilities.s", "hdae5000_data_tables.s", "hdae5000_init_data.s", "hdae5000_ui_tree.s"]
texts = {f: read(f) for f in FILES}
orph = re.compile(rb"^([A-Za-z_]\w*):\t; PORT-ORPHAN[^\n]*\n", re.M)
names = {m.group(1) for s in texts.values() for m in orph.finditer(s)}
used = set()
for s in texts.values():
    for ln in s.split(b"\n"):
        if b"PORT-ORPHAN" in ln:
            continue
        code = ln.split(b";", 1)[0]
        for n in names:
            if re.search(rb"(?<![\w.])" + re.escape(n) + rb"(?![\w])", code):
                used.add(n)
for f, s in texts.items():
    s2 = orph.sub(lambda m: m.group(0) if m.group(1) in used else b"", s)
    if s2 != s:
        write(f, s2)
print("%d orphan labels dropped; still referenced: %s" % (len(names - used), sorted(x.decode() for x in used)))
