#!/usr/bin/env python3
"""cnv_calls.py -- does a style converter (.CNV) call anything outside itself?

Question it answers: is a .CNV a self-contained MN10300 routine (every call and jump lands
inside the file), so that it can only talk to the firmware through memory? Disassembles the
file with MAME's unidasm (-arch mn10300, base 0) and counts calls/jumps by target: inside the
file, outside it, or through a register (calls (an), jmp (an)).
usage: python3 -I cnv_calls.py UNIDASM FILE.CNV
"""
import collections
import os
import re
import subprocess
import sys

unidasm, path = sys.argv[1:3]
size = os.path.getsize(path)
out = subprocess.run([unidasm, path, "-arch", "mn10300", "-basepc", "0"],
                     capture_output=True, text=True).stdout
count = collections.Counter()
for line in out.splitlines():
    m = re.match(r"([0-9a-f]+): (?:[0-9a-f]{2} )+\s+(\S+)\s*(.*)", line)
    if not m or m.group(2) not in ("call", "calls", "jmp"):
        continue
    t = re.match(r"0x([0-9a-f]+)", m.group(3))
    if not t:
        count[f"{m.group(2)} through a register"] += 1
    else:
        count[f"{m.group(2)} {'inside' if int(t.group(1), 16) < size else 'OUTSIDE'} the file"] += 1
print(f"{os.path.basename(path)} ({size} bytes): {dict(count)}")
