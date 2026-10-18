#!/usr/bin/env python3
"""Linear decode of the KN7000 program ROM code regions with unidasm, with the
F4 length-bug fix used by tools/gen_program_s.py (F4 xx is 2 bytes; unidasm
consumes only 1).  Output: TSV  cpu \t hexbytes \t mnem \t ops  per instruction.
Regions: R1 = file 0x80..0x186000 at CPU 0x48400080;
         LIB = file 0x3B8FD1..0x3F6F01 at CPU 0x4C000000.
usage (from the kn7000_disassembly root):
  python3 decode_all.py OUT.tsv
"""
import os, re, subprocess, sys
sys.path.insert(0, "tools")
import gen_program_s as G

INSN = G.INSN
d = open(G.ROM, "rb").read()
CHUNK = 0x2000

def walk(fs, fe, delta):
    cur = fs
    while cur < fe:
        cnt = min(CHUNK, fe - cur)
        out = subprocess.run(
            [G.UNIDASM, G.ROM, "-arch", "mn10300", "-basepc", f"0x{delta + cur:x}",
             "-skip", f"0x{cur:x}", "-count", str(cnt)],
            capture_output=True, text=True).stdout
        progressed = False
        restart_at = None
        for line in out.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            addr = int(m.group(1), 16) - delta
            if addr != cur:
                break
            by = bytes.fromhex(m.group(2).replace(" ", ""))
            if cur + len(by) > fe:
                break
            mn, ops = m.group(3), m.group(4).strip()
            if by == b"\xf4":
                yield delta + cur, d[cur:cur + 2], mn, ops
                cur += 2
                restart_at = cur
                progressed = True
                break
            if len(by) == 4 and by[0] == 0xFA and 0x90 <= by[1] <= 0x9F:
                op = by[1] & 3
                mn = ("mov", "mov", "movbu", "movhu")[op]
                ops = re.sub(r"^d\d+", f"{'a' if op == 0 else 'd'}{(by[1] >> 2) & 3}", ops)
            # the last instruction of a chunk may be truncated by -count: only
            # accept instructions that end at or before the chunk end
            if cur + len(by) > fs + 0 and cur + len(by) > (cur - (cur - fs)) and cur + len(by) > fe:
                break
            yield delta + cur, by, mn, ops
            cur += len(by)
            progressed = True
        if not progressed:
            # undecodable byte: emit as .byte and move on
            yield delta + cur, d[cur:cur + 1], ".byte", f"0x{d[cur]:02x}"
            cur += 1

def main():
    out = open(sys.argv[1], "w")
    for name, fs, fe, delta in (("R1", 0x80, G.R1_END, G.BASE),
                                ("LIB", G.LIB_FILE_BASE, G.IMAGE_END, G.LIB_DELTA)):
        n = 0
        for cpu, by, mn, ops in walk(fs, fe, delta):
            out.write(f"{cpu:08x}\t{by.hex()}\t{mn}\t{ops}\n")
            n += 1
        print(name, n, "insns", file=sys.stderr)
main()
