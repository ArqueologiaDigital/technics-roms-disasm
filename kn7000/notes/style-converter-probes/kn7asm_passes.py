#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# How many passes does tools/kn7asm.py need for a source, with its forward-label
# estimate (the previous pass's address plus the line's drift, commit 27284fcb8)
# and with the estimate it had before (the previous pass's address alone)?
# KORG's source needed 57 passes the old way when the fix was made, over the cap of
# 20 (commit 27284fcb8); for the source of aec05aa17 it prints 3 and 58.
#   python3 -I kn7asm_passes.py ../../src/cnv/korg.s
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import kn7asm                                         # noqa: E402


def old_forward(self, tok):
    self.assumed[tok] = self.known[tok]
    return self.known[tok]


def passes(src, forward, cap=100):
    A = kn7asm.Assembler(os.path.dirname(os.path.abspath(src)))
    A.forward = forward.__get__(A)
    for n in range(1, cap + 1):
        A.start_pass()
        A.assemble_file(src)
        if not A.guessed and all(A.symbols.get(k) == v for k, v in A.assumed.items()):
            return n, len(A.out)
        A.known = dict(A.symbols)
    return None, len(A.out)


for src in sys.argv[1:]:
    new = passes(src, kn7asm.Assembler.forward)
    old = passes(src, old_forward)
    print(f"{src}: drift estimate {new[0]} passes, previous-address estimate "
          f"{old[0] if old[0] else '>100'} passes (output 0x{new[1]:x} bytes)")
