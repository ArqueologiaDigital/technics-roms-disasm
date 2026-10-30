"""RAM operands the passes spelled as numbers (all code files of the tree): an operand equal to one HDAE5000_RAM_*
    constant (only one has the value) is spelled with it; an operand inside the PC-link
    region table (HDAE5000_RAM_PportRegions .. +0x53) as PportRegions+offset.  Byte-neutral.
(v2.01i itself still has about 630 numeric RAM operands; this only undoes what the port
added where a named variable is certain.)
"""
import collections
import re
from _edit import TREE, read, write

FILES = ["hd-ae5000_%s.s" % TREE[len("hdae5000_"):], "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
         "hdae5000_ui_display.s", "hdae5000_utilities.s"]
main = read(FILES[0])
equ = collections.defaultdict(list)
for m in re.finditer(rb"^\s*\.equ\s+(HDAE5000_RAM_\w+)\s*,\s*(0x[0-9a-fA-F]+)", main, re.M):
    equ[int(m.group(2), 16)].append(m.group(1))
regions = [v for v, ns in equ.items() if b"HDAE5000_RAM_PportRegions" in ns][0]
NUM = re.compile(rb"(?<![\w.+-])0x(2[0-3][0-9a-fA-F]{4})(?![\w])")
n_num = 0
for f in FILES:
    out = []
    for ln in read(f).split(b"\n"):
        code, sep, com = ln.partition(b";")
        if code.lstrip().startswith((b".equ", b".set")) or not code.strip():
            out.append(ln)
            continue
        def rep(m):
            global n_num
            v = int(m.group(1), 16)
            if len(equ.get(v, [])) == 1:
                n_num += 1
                return equ[v][0]
            if regions < v < regions + 0x54:
                n_num += 1
                return b"HDAE5000_RAM_PportRegions+%d" % (v - regions)
            return m.group(0)
        out.append(NUM.sub(rep, code) + sep + com)
    write(f, b"\n".join(out))

print("%d RAM numbers spelled" % n_num)
