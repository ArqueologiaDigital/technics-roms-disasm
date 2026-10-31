#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""hdsx3_entry_vectors.py -- the XAPR header's entry vectors and the host code that calls them.

QUESTION IT ANSWERS
  "Which KN6000 / KN6500 routine calls each word of the expansion board's XAPR header (0x97800000),
   and from where is that routine reached?"  For the plug-in it prints the 32 header words (+0x00
   the signature, +0x04 the trailer pointer, +0x08..+0x7C the vectors) with the label each names.
   For each host it finds every instruction that names 0x978000xx: the signature check
   (`mov 0x97800000, a0` + strncmp, `mov (0x97800004), a0` + strncmp, the flag it stores) and each
   vector load `mov (0x978000VV), aN` followed by `calls (aN)`.  For each it prints the instruction's
   address and text, the routine it is in (the routine start is the first instruction after a
   return), and how that routine is reached: `call` sites (address and calling routine), and every
   32-bit word of the host image equal to the routine's start (a def_int packet immediate, a hook
   table row).  Signal: a vector is "called" when its load is followed by `calls (aN)` with the same
   register within 6 instructions; the board is "present" when the flag byte is 1.

RUN (from the repository root; ../kn6000, ../kn6500 and ../hdsx3 reference images built):
  python3 kn7000/notes/mn10300-rest-probes/hdsx3_entry_vectors.py
"""
import bisect
import os
import re
import struct
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
from mn10300_insn_len import insn_len  # noqa: E402

RETS = ("ret", "retf", "rets", "rti")


def line_addrs(src, rom, base):
    """(lines, {line index: CPU address}, {label: CPU address}) for the code of src, walking the
    reference image with insn_len() in step with the source; stops at the data include."""
    lines = open(src, encoding="latin-1").read().split("\n")
    pc, addr, labels = base, {}, {}
    for i, ln in enumerate(lines):
        if ln.startswith((".include", ".mnbase", ".org")):
            if "data.s" in ln:
                break
            continue
        m = re.match(r"^(\w+):", ln)
        if m:
            labels[m.group(1)] = pc
            continue
        s = ln.split("#")[0].strip()
        if not s:
            continue
        op = s.split()[0]
        arg = s[len(op):].strip()
        addr[i] = pc
        if op in (".ascii", ".asciz"):
            pc += len(eval(arg)) + (op == ".asciz")
        elif op in (".long", ".word", ".byte"):
            pc += {".long": 4, ".word": 2, ".byte": 1}[op] * len(arg.split(","))
        elif op == ".space":
            pc += int(arg.split(",")[0], 0)
        elif op.startswith("."):
            raise SystemExit(f"{src}:{i + 1}: unhandled directive {ln!r}")
        else:
            pc += insn_len(rom[pc - base], rom[pc - base + 1])
    return lines, addr, labels


def mnem(ln):
    p = ln.strip().split("\t")
    return p[0] if p else ""


class Image:
    def __init__(self, model):
        self.model = model
        self.base = 0x4C000000
        self.rom = open(os.path.join(ROOT, model, "baserom", f"{model}_program.rom"), "rb").read()
        self.L, self.addr, self.labels = line_addrs(os.path.join(ROOT, model, "src", "program.s"),
                                                    self.rom, self.base)
        self.by_addr = {}
        for nm, a in self.labels.items():
            if not re.search(r"_L[0-9a-f]+$", nm):
                self.by_addr.setdefault(a, nm)
        self.code = sorted(self.addr)
        self.code_addrs = [self.addr[i] for i in self.code]

    def routine_start(self, i):
        """line index of the first instruction of the routine holding line i: the first
        instruction after a return, or the first routine label between that and line i
        (a routine entered by `call` has no prologue of its own; the bytes before it may be
        an unreachable `add -N, sp`)"""
        prev = None
        for j in range(i, -1, -1):
            if j in self.addr:
                if prev is not None and mnem(self.L[j]) in RETS:
                    break
                prev = j
        for j in range(prev, i + 1):
            m = re.match(r"^(\w+):", self.L[j])
            if m and not re.search(r"_L[0-9a-f]+$", m.group(1)):
                return min(k for k in self.code if k > j)
        return prev

    def insn_at(self, a):
        """the source line of the instruction holding CPU address a, or None"""
        k = bisect.bisect_right(self.code_addrs, a) - 1
        if k < 0 or k + 1 >= len(self.code) or self.code_addrs[k + 1] <= a:
            return None
        return self.code[k]

    def name(self, a):
        return self.by_addr.get(a) or f"<unlabelled {a:#010x}>"

    def refs(self, a):
        """call sites of the routine at a (or its _entry) and image words equal to a"""
        names = [n for n, v in self.labels.items() if v == a]
        names += [n + "_entry" for n in names if n + "_entry" in self.labels]
        out = []
        for i in self.code:
            ln = self.L[i]
            m = re.match(r"\t(call|calls|jmp)\t(\w+)", ln)
            if m and m.group(2) in names:
                out.append(f"{self.addr[i]:#010x} `{ln.strip()}` in {self.name(self.addr[self.routine_start(i)])}")
        p = struct.pack("<I", a)
        k = self.rom.find(p)
        while k >= 0:
            w = self.base + k
            i = self.insn_at(w)
            where = (f" (inside `{self.L[i].strip()}` at {self.addr[i]:#010x}, in "
                     f"{self.name(self.addr[self.routine_start(i)])})") if i is not None else " (data)"
            out.append(f"word {w:#010x} holds it{where}")
            k = self.rom.find(p, k + 1)
        return out


def plugin_header():
    rom = open(os.path.join(ROOT, "hdsx3", "baserom", "hdsx3_extapr.rom"), "rb").read()
    src = open(os.path.join(ROOT, "hdsx3", "src", "program.s"), encoding="latin-1").read().split("\n")
    rows = [ln.split("\t")[2] for ln in src if ln.startswith("\t.long\t")][:31]
    print(f"plug-in header (0x97800000): signature {rom[:4]!r}")
    for k in range(31):
        v = struct.unpack_from("<I", rom, 4 + 4 * k)[0]
        print(f"  +{4 + 4 * k:#04x}  {v:#010x}  {rows[k]}")


def host(model):
    im = Image(model)
    print(f"\n{model.upper()}:")
    for i in im.code:
        ln = im.L[i]
        m = re.search(r"(0x978000[0-9a-f]{2})", ln)
        if not m:
            continue
        a, val = im.addr[i], int(m.group(1), 16)
        rs = im.routine_start(i)
        start = im.addr[rs]
        nxt = [im.L[j].strip() for j in im.code if i < j <= i + 8][:7]
        reg = re.search(r", (a\d)$", ln)
        called = reg and any(t == f"calls\t({reg.group(1)})" for t in nxt[:6])
        what = "signature" if val == 0x97800000 else "trailer pointer" if val == 0x97800004 else \
            f"vector +{val - 0x97800000:#04x}" + (" -> calls" if called else "")
        print(f"  {a:#010x} `{ln.strip()}`  [{what}]  in {im.name(start)} (starts {start:#010x})")
        if val == 0x97800004:
            for t in nxt:
                if t.startswith("movbu\td1, ("):
                    print(f"      flag: `{t}`")
        for r in im.refs(start):
            print(f"      reached: {r}")


def main():
    plugin_header()
    for model in ("kn6000", "kn6500"):
        host(model)


if __name__ == "__main__":
    main()
