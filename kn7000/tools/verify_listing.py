#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# verify_listing.py -- byte-check a curated disasm/*.asm listing against the ROM,
# and (for instruction lines) round-trip the mnemonic column through the repo's
# MN10300 encoder.
#
# Two independent checks:
#   BYTE CHECK   every "addr: bb bb bb  ..." line must reproduce the exact ROM
#                bytes at that CPU address, and consecutive instruction lines
#                must be contiguous (no gap, no overlap) within each region.
#   RE-ENCODE    tools/mn10300_asm.py must turn the printed mnemonic back into
#                the same bytes.  Failures are reported, not hidden: the encoder
#                is known to be ~99.9% complete (see the repo README).
import re, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM = os.environ.get("KN7000_ROM",
                     os.path.join(ROOT, "baserom", "kn7000_program.rom"))
ASMDIR = os.path.join(ROOT, "disasm")
ENC = os.path.join(ROOT, "tools")
BASE = 0x48400000

sys.path.insert(0, ENC)
try:
    import mn10300_asm
except Exception as e:                                    # pragma: no cover
    mn10300_asm = None
    print("!! encoder unavailable:", e)

LINE = re.compile(r"^([0-9a-f]{8}): ((?:[0-9a-f]{2} )*[0-9a-f]{2})\s\s+(\S+)?\s*(.*?)\s*$")

d = open(ROM, "rb").read()

def main(path):
    bad = bytes_ok = 0
    gaps = []
    pad = []
    enc_ok = enc_bad = enc_unsup = 0
    enc_fail = []
    prev_end = None
    for n, line in enumerate(open(path), 1):
        if line.startswith(";"):
            prev_end = None
            continue
        m = LINE.match(line.rstrip("\n"))
        if not m:
            if line.strip() and not line.lstrip().startswith(";") and ":" in line \
               and not line.rstrip().endswith(":"):
                print(f"  line {n}: unparsed: {line.rstrip()}")
            prev_end = None
            continue
        addr = int(m.group(1), 16)
        b = bytes.fromhex(m.group(2).replace(" ", ""))
        off = addr - BASE
        if d[off:off + len(b)] != b:
            bad += 1
            print(f"  line {n}: BYTE MISMATCH at {addr:08x}: listing {b.hex(' ')} "
                  f"rom {d[off:off+len(b)].hex(' ')}")
        else:
            bytes_ok += len(b)
        if prev_end is not None and addr != prev_end:
            skipped = d[prev_end - BASE:addr - BASE]
            if addr < prev_end or set(skipped) - {0xFF, 0x00}:
                gaps.append((n, prev_end, addr))
            else:
                pad.append((prev_end, addr))
        prev_end = addr + len(b)
        mnem, ops = m.group(3), m.group(4)
        # instruction lines only (data lines use .short/.long/.asciz)
        if mnem and not mnem.startswith(".") and not mnem.startswith(";") and mn10300_asm:
            ops = ops.split(";")[0].strip()
            try:
                e = mn10300_asm.encode(mnem, ops, addr)
                if e == b:
                    enc_ok += 1
                else:
                    enc_bad += 1
                    enc_fail.append((addr, mnem, ops, b.hex(" "), e.hex(" ")))
            except Exception as ex:
                enc_unsup += 1
                enc_fail.append((addr, mnem, ops, b.hex(" "), f"unsupported: {ex}"))
    print(f"{os.path.basename(path)}")
    print(f"  BYTE CHECK : {bytes_ok} bytes verified against the ROM, "
          f"{bad} mismatches")
    print(f"  CONTIGUITY : {len(gaps)} unexplained gaps; {len(pad)} runs of "
          f"0xFF/0x00 inter-string padding skipped")
    for g in gaps:
        print(f"     line {g[0]}: {g[1]:08x} -> {g[2]:08x}")
    tot = enc_ok + enc_bad + enc_unsup
    if tot:
        print(f"  RE-ENCODE  : {enc_ok}/{tot} instructions re-encode byte-identically "
              f"({100.0*enc_ok/tot:.1f}%); {enc_bad} differ, {enc_unsup} unsupported "
              f"by tools/mn10300_asm.py")
        for f in enc_fail[:40]:
            print(f"     {f[0]:08x} {f[1]:8s}{f[2]:<32s} rom {f[3]:<20s} enc {f[4]}")
        if len(enc_fail) > 40:
            print(f"     ... {len(enc_fail)-40} more")
    return bad


if __name__ == "__main__":
    paths = sys.argv[1:] or [os.path.join(ASMDIR, "debugger_memdump.asm")]
    rc = 0
    for p in paths:
        rc |= main(p)
    sys.exit(1 if rc else 0)
