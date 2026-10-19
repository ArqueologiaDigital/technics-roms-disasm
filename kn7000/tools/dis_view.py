#!/usr/bin/env python3
"""Read-only helper: named linear disassembly of a CPU address range, using the
same F4-length-bug-aware decoding as gen_program_s.py (unidasm's mn10300 F4 page
consumes 1 byte instead of 2).  usage:
    python3 tools/dis_view.py 0x4C00FB1B 0x4C00FD4C [lib|r1]"""
import os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_program_s as G

def walk(d, a, b, delta):
    """Linear decode a..b (CPU addrs); yields (cpu, bytes, mnem, ops)."""
    cur = a - delta
    end = b - delta
    while cur < end:
        out = subprocess.run(
            [G.UNIDASM, G.ROM, "-arch", "mn10300", "-basepc", f"0x{delta + cur:x}",
             "-skip", f"0x{cur:x}", "-count", str(end - cur)],
            capture_output=True, text=True).stdout
        restart = False
        for line in out.splitlines():
            m = G.INSN.match(line)
            if not m:
                continue
            addr = int(m.group(1), 16) - delta
            if addr != cur:
                return
            by = bytes.fromhex(m.group(2).replace(" ", ""))
            if by == b"\xf4":          # F4 length bug
                yield delta + cur, d[cur:cur + 2], m.group(3), m.group(4).strip()
                cur += 2
                restart = True
                break
            yield delta + cur, by, m.group(3), m.group(4).strip()
            cur += len(by)
            if cur >= end:
                break
        if not restart:
            break

def main():
    a, b = int(sys.argv[1], 16), int(sys.argv[2], 16)
    mode = sys.argv[3] if len(sys.argv) > 3 else ("lib" if a >= 0x4C000000 else "r1")
    delta = G.LIB_DELTA if mode == "lib" else G.BASE
    d = open(G.ROM, "rb").read()
    names = {}
    for path in (G.SYM, G.MANUAL_SYM):
        if os.path.exists(path):
            for ln in open(path):
                p = ln.split()
                if len(p) >= 2 and p[0].startswith("0x"):
                    names[int(p[0], 16)] = p[1]
    for cpu, by, mn, ops in walk(d, a, b, delta):
        tgt = ""
        m = re.search(r"0x[0-9a-f]{6,8}", ops)
        if m and int(m.group(0), 16) in names:
            tgt = "  ; " + names[int(m.group(0), 16)]
        lbl = f"   <<< {names[cpu]}" if cpu in names else ""
        print(f"{cpu:08x}: {by.hex(' '):<18} {mn:<8}{ops}{tgt}{lbl}")

main()
