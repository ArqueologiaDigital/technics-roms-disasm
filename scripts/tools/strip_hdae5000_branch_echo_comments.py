#!/usr/bin/env python3
"""strip_hdae5000_branch_echo_comments.py -- drop the unidasm echo comments on HD-AE5000 relative branches.

QUESTION IT ANSWERS
  The conversion left comments of the form `; [66 14] jr Z,0x280424` on the hdae5000 jr / jrl lines: the
  instruction's bytes, its MAME spelling and the absolute target address.  Every one restates the
  instruction on its own line (the target is a label), and the address is what the No Inline Address
  Comments policy forbids.  This script deletes such a comment only when it is the whole tail of a jr / jrl
  line and has exactly that shape, and puts a tab after the mnemonic (cross-version policy 3).  It prints
  how many it found per file; a second run finds none.

  The .s files hold raw ROM bytes in .ascii literals, so they are read and written as bytes.
  Proof that no byte of any image moved: make -j3 gate.

RUN (repository root)
  python3 scripts/tools/strip_hdae5000_branch_echo_comments.py            # count only
  python3 scripts/tools/strip_hdae5000_branch_echo_comments.py --apply    # rewrite hdae5000/*.s
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ECHO = re.compile(rb'^\t(jrl?)[ \t]+([^;\n]*[^; \t\n])[ \t]*; \[[0-9a-f]{2}(?: [0-9a-f]{2})*\] jrl? [A-Z]{1,3},'
                  rb'0x[0-9a-f]{6}[ \t]*$', re.M)


def main():
    apply = "--apply" in sys.argv[1:]
    total = 0
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        data = open(p, "rb").read()
        new, n = ECHO.subn(rb'\t\1\t\2', data)
        if n:
            print("%-36s %d" % (os.path.relpath(p, ROOT), n))
            total += n
            if apply:
                with open(p + ".tmp", "wb") as fh:
                    fh.write(new)
                os.replace(p + ".tmp", p)
    print("total %d%s" % (total, " (removed)" if apply else ""))


if __name__ == "__main__":
    main()
