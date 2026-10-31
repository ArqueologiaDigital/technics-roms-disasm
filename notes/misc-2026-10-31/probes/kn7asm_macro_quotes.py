#!/usr/bin/env python3
"""kn7asm_macro_quotes.py -- does kn7asm pass quoted macro arguments the way GNU as and llvm-mc do?

QUESTION IT ANSWERS
  Assembles kn7asm_macro_quotes.s (beside this script: quoted positional, keyword, default and vararg
  arguments; a quoted argument passed on to a nested macro as "\\s"; an escaped quote inside an argument)
  with kn7000/tools/kn7asm.py, with GNU as (`as`, the host's) and with the pinned llvm-mc
  (-triple=tlcs900), and compares the bytes.  All three must give
      64 65 20 66 67 68 78 2c 79 61 22 62 78 79 78 79 7a 64 66 6c 74 6b 77   ("de fghx,ya"bxyxyzdfltkw")
  i.e. a quoted positional / keyword / default argument loses its quotes, a vararg keeps them.

RUN (repository root; writes only into $TMPDIR)
  python3 notes/misc-2026-10-31/probes/kn7asm_macro_quotes.py
"""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kn7asm_macro_quotes.s")
LLVM = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
WANT = b'de fghx,ya"bxyxyzdfltkw'


def text_section(obj, objdump):
    out = subprocess.run([objdump, "-s", "-j", ".text", obj], capture_output=True, text=True, check=True).stdout
    data = b""
    for l in out.splitlines():
        p = l.split()
        if len(p) > 1 and len(p[0]) == 4 and all(c in "0123456789abcdef" for c in p[0]):
            for w in p[1:5]:
                if all(c in "0123456789abcdef" for c in w):
                    data += bytes.fromhex(w)
    return data


def main():
    d = tempfile.mkdtemp(prefix="kn7asm-quotes-")
    got = {}
    subprocess.run([sys.executable, os.path.join(ROOT, "kn7000/tools/kn7asm.py"), SRC, "-o", os.path.join(d, "k.bin")],
                   check=True, capture_output=True)
    got["kn7asm"] = open(os.path.join(d, "k.bin"), "rb").read()
    if subprocess.run(["as", SRC, "-o", os.path.join(d, "g.o")], capture_output=True).returncode == 0:
        got["GNU as"] = text_section(os.path.join(d, "g.o"), "objdump")
    subprocess.run([os.path.join(LLVM, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", SRC, "-o",
                    os.path.join(d, "l.o")], check=True, capture_output=True)
    got["llvm-mc"] = text_section(os.path.join(d, "l.o"), os.path.join(LLVM, "llvm-objdump"))
    ok = True
    for k, v in got.items():
        print("%-7s %s %s" % (k, v, "OK" if v == WANT else "DIFFERS"))
        ok &= v == WANT
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
