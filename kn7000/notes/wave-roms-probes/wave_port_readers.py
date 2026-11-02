#!/usr/bin/env python3
"""wave_port_readers.py -- QUESTION: which code of program 941 can read the wave ROMs, i.e. which instructions
touch the tone generators' ports 0x98040000 / 0x98050000, and at which offset?

Background (notes/wave-rom-port.md): +0 / +2 are each TG's register address / data ports, +4 a control port,
and +6 / +8 / +A the wave-ROM read latches (bank, address, data) of the service-mode checksum.  If no other
instruction touches +6 / +8 / +A, then no firmware code reads a directory entry, a parameter record or a
sample: the P word (bit 12, bit 9), the split list and everything after a loop reach only the TG itself.

It scans every instruction line of kn7000/src/program/*.s (comments stripped) for an operand in
0x98040000..0x9805ffff, and also for any `mov 0x9804xxxx / 0x9805xxxx` into a register (a base for indexed
access).  It prints, per port offset, the routines (the nearest preceding label line) that use it.
Signal: offsets 6, 8 and 0xA are used by one routine only, the checksum core at 0x484839A1.

RUN (from anywhere):  python3 -I kn7000/notes/wave-roms-probes/wave_port_readers.py
"""
import collections
import glob
import os
import re

K = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))


def main():
    uses = collections.defaultdict(lambda: collections.Counter())
    bases = []
    for path in sorted(glob.glob(os.path.join(K, "src/program/*.s"))):
        label = "?"
        for ln in open(path, "rb"):
            code = ln.split(b"#")[0].decode("latin1")
            m = re.match(r"^([A-Za-z_.][\w.]*):", code)
            if m and not m.group(1).startswith(".L"):
                label = m.group(1)
            for a in re.findall(r"0x980[45][0-9a-fA-F]{4}\b", code):
                v = int(a, 16)
                if re.search(r"\bmov\s+" + a + r"\s*,\s*[ad]\d", code):
                    bases.append((os.path.basename(path), label, code.strip()))
                uses[(v >> 16, v & 0xFFFF)][f"{os.path.basename(path)}:{label}"] += 1
    for (port, off), who in sorted(uses.items()):
        print(f"0x{port:04x}{off:04x} (+{off:#x}): " + "; ".join(f"{k} x{n}" for k, n in sorted(who.items())))
    latch = [w.split(":")[1] for (port, off), who in uses.items() if off in (6, 8, 0xA) for w in who]
    addr = [int(x[4:], 16) for x in latch if x.startswith("loc_")]
    inside = sum(1 for a in addr if 0x484839A1 <= a < 0x48483B12)
    print(f"\n+6 / +8 / +A users: {len(latch)} label(s), {inside} of them inside the checksum core"
          f" 0x484839A1..0x48483B11 (notes/wave-rom-port.md), {len(latch) - inside} elsewhere")
    print(f"mov of a port address into a register (an indexed base): {len(bases)}")
    for b in bases:
        print("   ", *b)


if __name__ == "__main__":
    main()
