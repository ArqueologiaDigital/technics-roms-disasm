#!/usr/bin/env python3
"""strip_hdae5000_unidasm_echo_comments.py -- drop the comments that only repeat an HD-AE5000 instruction.

QUESTION IT ANSWERS
  The conversion from unidasm left, on many hdae5000 instruction lines, a comment that is the same instruction
  in MAME's spelling and nothing else: `pushw iz ; push IZ`, `jp t, (xix+wa) ; jp T,XIX+WA`,
  `ld xhl, (xwa+4) ; ld XHL, (XWA + 0x04)`.  Such a comment says nothing the line does not (Comment Quality
  policy), and some are wrong: `inc 8, xsp ; inc 0,XSP` is MAME's raw count field (0 encodes 8), which
  contradicts the operand.  This script deletes a comment only when ALL of it is such an echo:
    - optional `[bytes]`, then a mnemonic of the same family as the line's own (pushw/push, ldw/ld, incw/inc,
      lda/lda ...), then operands made only of registers in capitals, condition codes, numbers and
      punctuation -- any lower-case word (`pop 12 bytes`, `ld WA, QBC (reload value)`) keeps the comment;
    - the line is an instruction (not a directive or a label) spelled with a plain mnemonic: on a raw-encoding
      pseudo (`cpib_sri 0x07, 0xE0, 0xFA, 0x30`, `ld8_src_ri xde, l`, any mnemonic with `_`) the MAME spelling
      is the only readable one, so it stays;
    - the echo holds no number of 5 or more hex digits: `cpw (2294838:24), 50 ; cp (0x230436), 0x32` keeps
      the only hex spelling of an address the code still writes as a decimal number.
  It prints the count per file, and how many echo-shaped comments it left because the mnemonic family differs
  (those are listed with -v, to read by hand).  A second run finds nothing.

  The .s files hold raw ROM bytes in .ascii literals, so they are read and written as bytes.
  Proof that no byte of any image moved: make -j3 gate.

RUN (repository root)
  python3 scripts/tools/strip_hdae5000_unidasm_echo_comments.py [-v]       # count only
  python3 scripts/tools/strip_hdae5000_unidasm_echo_comments.py --apply    # rewrite hdae5000/*.s
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INSN = re.compile(rb'^\s+([a-z][a-z0-9_]*)\b')
ECHO = re.compile(rb'^(?:\[[0-9a-fA-F]{2}(?: [0-9a-fA-F]{2})*\]\s*)?([a-z]+[0-9]?)(?:\s+([^;]*?))?\s*$')
TOKEN = re.compile(rb'[A-Za-z0-9]+')
NUMBER = re.compile(rb'^(?:0x[0-9a-fA-F]+|\d+|[0-9][0-9A-Fa-f]*h)$')
REGISTER = re.compile(rb'^[A-Z][A-Z0-9]{0,4}$')
MNEMONICS = {
    b"ld", b"lda", b"ldw", b"ldb", b"ldi", b"ldir", b"ldd", b"lddr", b"ldc", b"ldf", b"ldx", b"ldcf", b"stcf",
    b"push", b"pop", b"pushw", b"popw", b"ex", b"inc", b"dec", b"incw", b"decw", b"incf", b"decf",
    b"add", b"adc", b"sub", b"sbc", b"cp", b"cpw", b"and", b"or", b"xor", b"cpl", b"neg", b"extz", b"exts",
    b"mul", b"muls", b"div", b"divs", b"sll", b"srl", b"sla", b"sra", b"rl", b"rr", b"rlc", b"rrc",
    b"bit", b"set", b"res", b"chg", b"tset", b"jp", b"jr", b"jrl", b"call", b"calr", b"djnz", b"ret",
    b"reti", b"retd", b"link", b"unlk", b"scc", b"swi", b"nop", b"ei", b"di", b"halt", b"cpd", b"cpi",
    b"cpir", b"cpdr", b"rcf", b"scf", b"ccf", b"zcf", b"mirr", b"paa", b"daa", b"minc1", b"mdec1",
    b"bs1f", b"bs1b", b"andcf", b"orcf", b"xorcf", b"lddw", b"ldiw", b"ldirw", b"lddrw",
}


def split_comment(line):
    q = None
    for k, ch in enumerate(line):
        c = chr(ch)
        if q:
            if c == q:
                q = None
        elif c in "\"'":
            q = c
        elif c == ";":
            return line[:k], line[k:]
    return line, b""


def family(m):
    """pushw -> push, ldw -> ld, ld_sril -> ld, lda_24 -> lda, incw -> inc, ldirw -> ldir"""
    m = m.split(b"_")[0]
    if m.endswith(b"w") and m[:-1] in MNEMONICS:
        m = m[:-1]
    return m


def pure_echo(body):
    m = ECHO.match(body)
    if not m or m.group(1) not in MNEMONICS:
        return None
    ops = m.group(2) or b""
    if re.search(rb'[^A-Za-z0-9\s(),+\-:]', ops):
        return None
    for t in TOKEN.findall(ops):
        if not (NUMBER.match(t) or REGISTER.match(t)):
            return None
    return m.group(1)


def main():
    apply = "--apply" in sys.argv[1:]
    verbose = "-v" in sys.argv[1:]
    total = other = 0
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        lines = open(p, "rb").read().split(b"\n")
        n = 0
        for i, ln in enumerate(lines):
            code, com = split_comment(ln)
            mi = INSN.match(code)
            if not com or not mi or code.rstrip().endswith(b":") or b"_" in mi.group(1):
                continue
            if re.search(rb'0x[0-9a-fA-F]{5,}|\b[0-9][0-9a-fA-F]{4,}h\b', com):
                continue
            mn = pure_echo(com[1:].strip())
            if mn is None:
                continue
            if family(mn) != family(mi.group(1)):
                other += 1
                if verbose:
                    print("%s:%d: family differs: %s" % (os.path.relpath(p, ROOT), i + 1, ln.decode("latin-1").strip()))
                continue
            lines[i] = code.rstrip()
            n += 1
        if n:
            print("%-36s %d" % (os.path.relpath(p, ROOT), n))
            total += n
            if apply:
                with open(p + ".tmp", "wb") as fh:
                    fh.write(b"\n".join(lines))
                os.replace(p + ".tmp", p)
    print("total %d echo comments %s; %d echo-shaped comments left (mnemonic family differs)"
          % (total, "removed" if apply else "found (dry run)", other))


if __name__ == "__main__":
    main()
