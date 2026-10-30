"""Object ids the v1.15i code names that v1.10i's GUI does not have (all code files).

After `uitables` wrote v1.10i's own hdae5000_ui_tree.s, the code still names the objects
of v1.15i's.  Those v1.10i lacks (the overwrite query ATTEN_OVER_FILE ...) no longer link.  Each
use is spelled 0x007fffff with a "PORT: absent" note, so that the tree links and the
`code` pass can align the routine around it; every such line is gone or respelled by the
time the tree is byte-identical (03 leaves no 0x007fffff behind: grep for it).
"""
import re
from _edit import read, write

tree = read("hdae5000_ui_tree.s")
defined = set(re.findall(rb"^\t+(?:ui_ram_object\t|[A-Za-z0-9_]+\t)([A-Za-z_][A-Za-z0-9_]*)[,\n]", tree, re.M))
for f in ("hd-ae5000_v1_10i.s", "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
          "hdae5000_ui_display.s", "hdae5000_utilities.s", "hdae5000_data_tables.s",
          "hdae5000_init_data.s"):
    s = read(f)
    out = []
    for ln in s.split(b"\n"):
        code, sep, com = ln.partition(b";")
        names = set(re.findall(rb"HDAE5000_OBJ_([A-Za-z0-9_]+)", code))
        gone = [n for n in names if n not in defined]
        if gone and not code.lstrip().startswith(b".equ"):
            for n in gone:
                code = re.sub(rb"HDAE5000_OBJ_" + n + rb"(?![A-Za-z0-9_])", b"0x007fffff", code)
            ln = code.rstrip() + b"\t; PORT: absent in v1.10i: " + b", ".join(sorted(gone))
            print(f, ln.decode("latin-1").strip())
        out.append(ln)
    write(f, b"\n".join(out))
