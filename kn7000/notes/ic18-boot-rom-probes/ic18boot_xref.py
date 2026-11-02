#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Who reads or writes a RAM address, in the boot ROM and in program 941?
#
# For each ADDR (a boot-ROM address; `ADDR=FWADDR` also names the firmware's
# copy of the same variable) it lists every instruction or data word of
# src/ic18/boot.s whose operand resolves to an address A with
#   - A == ADDR, or a memory access of width w with A <= ADDR < A + w  ("access"), or
#   - an address load `mov SYM, rN` with ADDR - 0x100 <= A <= ADDR      ("base?", to review
#     by hand: a register-relative access may follow)
# and the same for FWADDR over the 941 sources (src/program/*.s, where RAM is
# spelled as numbers). Symbols of boot.s are resolved through the assembler's
# label map (tools/kn7asm.py --labels, built into a temporary directory under
# $TMPDIR) and its .equ lines. Reads the sources only; writes nothing in the tree.
#
#   cd kn7000 && python3 -I notes/ic18-boot-rom-probes/ic18boot_xref.py \
#       0x500102EF=0x5006BDA3 0x50010192 ...
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
BOOT = os.path.join(KN7, "src", "ic18", "boot.s")
FW = os.path.join(KN7, "src", "program")
WIDTH = {"movbu": 1, "movb": 1, "bset": 1, "bclr": 1, "btst": 1, "movhu": 2, "movh": 2, "mov": 4}
INS = re.compile(r"^\s+([a-z][a-z0-9]*)\s+(.*?)\s*(#.*)?$")
DATA = re.compile(r"^\s*(?:[A-Za-z_]\w*:)?\s*\.(long|word|byte)\s+(.*?)\s*(#.*)?$")


def boot_symbols():
    syms = {}
    with tempfile.TemporaryDirectory() as td:
        lab = os.path.join(td, "boot.labels")
        subprocess.run([sys.executable, os.path.join(KN7, "tools", "kn7asm.py"), BOOT, "-I", KN7,
                        "-o", os.path.join(td, "boot.bin"), "--labels", lab],
                       check=True, stdout=subprocess.DEVNULL)
        for line in open(lab):
            n, a = line.split()
            syms[n] = int(a, 16)
    for line in open(BOOT, encoding="latin1"):
        m = re.match(r"\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+)", line)
        if m:
            syms[m.group(1)] = int(m.group(2), 16)
    return syms


def operands(text, syms):
    """(address, is_memory_operand, register-destination) for each address-like operand."""
    out = []
    for m in re.finditer(r"(\()?\s*([A-Za-z_]\w*|0x[0-9A-Fa-f]+)\s*([+-]\s*(?:0x[0-9A-Fa-f]+|\d+))?\s*(\))?", text):
        tok = m.group(2)
        if tok.startswith("0x"):
            a = int(tok, 16)
        elif tok in syms:
            a = syms[tok]
        else:
            continue
        if m.group(3):
            a += int(m.group(3).replace(" ", ""), 0)
        out.append((a, bool(m.group(1) and m.group(4))))
    return out


def scan(path, target, syms, label):
    hits = []
    for ln, line in enumerate(open(path, encoding="latin1"), 1):
        m = INS.match(line)
        if m and not m.group(1).startswith("."):
            mn, ops = m.group(1), m.group(2)
            for a, mem in operands(ops, syms):
                w = WIDTH.get(mn, 4)
                if mem and a <= target < a + w:
                    hits.append(("access", path, ln, line.strip()))
                elif not mem and a == target:
                    hits.append(("address", path, ln, line.strip()))
                elif not mem and mn == "mov" and target - 0x100 <= a <= target \
                        and re.search(r",\s*[ad][0-3]\s*$", ops):
                    hits.append(("base?", path, ln, line.strip()))
            continue
        m = DATA.match(line)
        if m and m.group(1) == "long":
            for a, _ in operands(m.group(2), syms):
                if a == target:
                    hits.append(("pointer", path, ln, line.strip()))
    return hits


def show(label, target, hits):
    print(f"  {label} 0x{target:08X}: {len(hits)} reference(s)")
    for kind, path, ln, text in hits:
        print(f"    {kind:8} {os.path.relpath(path, KN7)}:{ln}: {text}")


def main():
    syms = boot_symbols()
    fw_files = sorted(os.path.join(FW, f) for f in os.listdir(FW) if f.endswith(".s"))
    for arg in sys.argv[1:]:
        boot, _, fw = arg.partition("=")
        b = int(boot, 16)
        names = [n for n, a in syms.items() if a == b]
        print(f"== 0x{b:08X} {' '.join(names)}")
        show("boot", b, scan(BOOT, b, syms, "boot"))
        if fw:
            f = int(fw, 16)
            show("941 ", f, [h for p in fw_files for h in scan(p, f, {}, "941")])


if __name__ == "__main__":
    main()
