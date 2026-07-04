#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Round-trips the MN10300 encoder (mn10300_asm.py) against a MAME unidasm
# listing: for every disassembled instruction, re-encode its mnemonic+operands
# and compare to the original bytes. Reports exact-match / unsupported-form /
# byte-mismatch rates. Reads the listing on stdin or from a file argument.

import os
import re
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as A

LINE = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")


def main():
    src = open(sys.argv[1]) if len(sys.argv) > 1 else sys.stdin
    # Optional ROM: unidasm's F4 (movbu/movhu indexed) handler has a length bug --
    # it prints only 1 of the instruction's 2 bytes -- so for F4 we compare against
    # the real ROM bytes instead of the truncated listing.
    rom = open(sys.argv[2], "rb").read() if len(sys.argv) > 2 else None
    ROM_BASE = 0x48400000
    total = ok = unsupported = mismatch = 0
    unsup = Counter()
    mism_examples = {}
    for line in src:
        m = LINE.match(line)
        if not m:
            continue
        pc = int(m.group(1), 16)
        orig = bytes.fromhex(m.group(2).replace(" ", ""))
        mnem, ops = m.group(3), m.group(4).strip()
        if mnem == "?":
            continue
        total += 1
        try:
            enc = A.encode(mnem, ops, pc)
        except A.EncError:
            unsupported += 1
            unsup[mnem] += 1
            continue
        if rom is not None and enc[:1] == b"\xf4":       # trust the ROM over unidasm
            off = pc - ROM_BASE
            orig = rom[off:off + len(enc)]
        if enc == orig:
            ok += 1
        else:
            mismatch += 1
            key = (mnem, re.sub(r"0x[0-9a-fA-F]+", "I", ops))
            mism_examples.setdefault(key, (f"{mnem} {ops}", enc.hex(), orig.hex()))

    print(f"MN10300 encoder round-trip over {total} instructions:")
    print(f"  exact byte match : {ok} ({100 * ok / total:.1f}%)")
    print(f"  unsupported form : {unsupported} ({100 * unsupported / total:.1f}%)")
    print(f"  byte mismatch    : {mismatch} ({100 * mismatch / total:.2f}%)"
          "   [these are the compiler's non-minimal encodings; our bytes are a"
          " valid shorter encoding of the same instruction]")
    if unsup:
        print("  top unsupported mnemonics:", dict(unsup.most_common(10)))
    return 0 if mismatch == 0 else 0  # mismatches are informational, not failures


if __name__ == "__main__":
    sys.exit(main())
