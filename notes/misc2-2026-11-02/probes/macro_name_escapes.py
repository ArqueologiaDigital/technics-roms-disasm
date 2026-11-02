#!/usr/bin/env python3
"""macro_name_escapes.py -- does a quoted name passed to a macro's `.ascii "\\name"` give the same bytes as
the `.ascii "<name>"` line it replaces, in llvm-mc and in kn7asm?

QUESTION IT ANSWERS (register row N-f67b155c): the name-carrying macros SOUND_NAME_HEAD / VOICE_HEAD /
PMR_NAME take the record's name as a quoted argument.  The callers' strings hold escapes: kn7000/tools write
\\" \\\\ and \\xNN (gen_table_voices.asc, gen_customdata_s.qstr; kn7asm has no octal escapes), the floppy
describers \\NNN octal (kn_formats / kn_panel s_esc, llvm-mc).  For each assembler and its escape set this
assembles a macro-call file and the plain `.ascii` file and compares the bytes.  PASS = equal, exit 0.
Measured 2026-11-02: both PASS (llvm-mc 6 names, kn7asm 3 names).

RUN (repository root)
  python3 notes/misc2-2026-11-02/probes/macro_name_escapes.py
"""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
LLVM = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
NAMES = {
    "llvm-mc": ['Plain name 16ch', r'q\"uo\\te\042\134', r'oct\301\377\000x', r'hex\xc1\xff\x00y',
                'comma, inside', '  lead/trail  '],
    "kn7asm": [r'q\"uo\\te', r'hex\xc1\xff\x00y', 'comma, inside'],
}


def files(names):
    mac = ['.macro N name, a, b', '.ascii "\\name"', '\t.byte \\a, \\b', '.endm']
    mac += ['N "%s", %d, %d' % (n, 2 * i, 2 * i + 1) for i, n in enumerate(names)]
    ref = []
    for i, n in enumerate(names):
        ref += ['.ascii "%s"' % n, '\t.byte %d, %d' % (2 * i, 2 * i + 1)]
    return "\n".join(mac) + "\n", "\n".join(ref) + "\n"


def build(tool, src, d, stem):
    s = os.path.join(d, stem + ".s")
    open(s, "w").write(src)
    out = os.path.join(d, stem + ".bin")
    if tool == "llvm-mc":
        o = os.path.join(d, stem + ".o")
        subprocess.run([os.path.join(LLVM, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-o", o, s], check=True)
        subprocess.run([os.path.join(LLVM, "llvm-objcopy"), "-O", "binary", o, out], check=True)
    else:
        subprocess.run([sys.executable, os.path.join(ROOT, "kn7000", "tools", "kn7asm.py"), "-o", out, s],
                       check=True, stdout=subprocess.DEVNULL)
    return open(out, "rb").read()


def main():
    bad = 0
    with tempfile.TemporaryDirectory() as d:          # TMPDIR is ~/compartilhado/tmp on this machine
        for tool, names in NAMES.items():
            mac, ref = files(names)
            a, b = build(tool, mac, d, tool + "_macro"), build(tool, ref, d, tool + "_ref")
            ok = a == b
            bad += not ok
            print("%-5s %-8s %d names, %d bytes" % ("PASS" if ok else "FAIL", tool, len(names), len(a)))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
