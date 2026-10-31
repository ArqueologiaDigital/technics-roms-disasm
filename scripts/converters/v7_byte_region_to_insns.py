#!/usr/bin/env python3
r"""v7_byte_region_to_insns.py -- spell one labelled `.byte` region of a KN5000 maincpu tree as instructions.

QUESTION ANSWERED / JOB IT DOES
    Some v7 code is still held as `.byte` rows (former romslices inlined by
    inline_romslice_incbin.py, and runs the earlier toolchain could not encode).
    scripts/analysis/reframe_v7_runs_crosscheck_v10.py re-frames such runs only where the same label's
    v10 bytes give the same instruction sequence, and refuses any span the disassembler cannot decode
    (llvm-objdump prints `<unknown>` for the register-indexed ALU forms such as `add xbc, (xde+wa)`, which
    the assembler does accept).  This tool handles one region at a time, for a person who has read it:
      1. the region is the `.byte` rows after LABEL up to the next label (comments and blank lines inside
         are kept in front of the first instruction); its bytes must equal the dump at LABEL's address in
         the linked ELF;
      2. the bytes are decoded by llvm-objdump from LABEL's address.  Where it prints `<unknown>`, the
         reader supplies the instruction with `--fix ADDR=TEXT` (read off the same routine in v10, with the
         target build's operands); decoding resumes after the fix's encoded length;
      3. every instruction text is assembled on its own by llvm-mc and must give exactly the dump's bytes
         at its address (a fix that does not is refused, and so is the whole region);
      4. absolute call / jp targets and 24-bit memory or immediate operands that are exactly a label's
         address are written as that label (a descriptive name before a structural one); relative branch
         targets that are a label's address likewise.  Other branch targets stay numeric, for
         scripts/converters/symbolize_numeric_branches.py to name;
      5. the lines are written in the tree's form, not llvm-objdump's: scripts/tools/
         respell_v7_new_lines_like_v10.respell_lines (tab after the mnemonic, `call cc, (X:24)`, each
         number in v10's notation where the same label's v10 block has the same instruction, hex for RAM
         operands, masks and large constants elsewhere; v10 sources get the fallback rules only).  Until
         2026-10-31 that was a separate post-process (step 8 of analysis/v7-harmonize-2026-10-24).
    --apply rewrites the file (latin-1 in and out).  `make gate` is the proof that no byte moved.

RUN
    make all
    python3 scripts/converters/v7_byte_region_to_insns.py v7/maincpu/FILE.s LABEL [--fix 0xADDR='TEXT' ...] [--apply]
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BIN = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
STRUCT = re.compile(r'_(Skip|Join|Loop|Return|Helper|Epilogue|Entry|Tail|Next|Done|Exit|End|'
                    r'Code|Data|Block|Sub|Case|Default)\d*$|_0x[0-9A-Fa-f]+$|^LABEL_|^sub_|^loc_')
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):(.*)$')
BYTES = re.compile(r'^\s*\.byte\s+(.*?)\s*(;.*)?$')
REL = {"jr", "jrl", "calr", "djnz"}
sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
import respell_v7_new_lines_like_v10 as RS  # noqa: E402


def respell(L, idx, tree):
    """Write the instruction lines L[i], i in idx, in the tree's form (RS.respell_lines; v10 is not matched
    against itself)."""
    return RS.respell_lines(L, set(idx), RS.load_v10_blocks() if tree != "v10" else {})


def tree_of(path):
    m = re.match(r'^(v7|v9|v10)/maincpu/', os.path.relpath(path, REPO))
    if not m:
        sys.exit("not a KN5000 maincpu source: %s" % path)
    return m.group(1)


def syms(v):
    out = subprocess.run([os.path.join(BIN, "llvm-nm"), "--defined-only",
                          os.path.join(REPO, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % v)],
                         capture_output=True, text=True, check=True).stdout
    by, at = {}, {}
    for l in out.splitlines():
        a, t, n = l.split()
        if t.lower() != "t" or n.startswith(".L"):
            continue
        by[n] = int(a, 16)
        at.setdefault(int(a, 16), []).append(n)
    return by, at


def encode(text):
    r = subprocess.run([os.path.join(BIN, "llvm-mc"), "-triple=tlcs900", "-show-encoding"],
                       input="\t" + text + "\n", capture_output=True, text=True)
    if r.returncode or "error" in r.stderr:
        return None
    m = re.search(r'encoding: \[([^\]]*)\]', r.stdout)
    if not m:
        return None
    return bytes(int(x, 16) for x in m.group(1).split(",") if x.strip())


def objdump(v, lo, hi):
    out = subprocess.run([os.path.join(BIN, "llvm-objdump"), "-d", "--no-show-raw-insn",
                          "--start-address=0x%x" % lo, "--stop-address=0x%x" % hi,
                          os.path.join(REPO, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % v)],
                         capture_output=True, text=True, check=True).stdout
    res = []
    for line in out.splitlines():
        m = re.match(r'^\s*([0-9a-f]+):\s*\t(\S+)\s*(.*)$', line)
        if m:
            res.append((int(m.group(1), 16), (m.group(2) + " " + m.group(3).strip()).strip()))
    return res


R32 = {0xe0: "xwa", 0xe4: "xbc", 0xe8: "xde", 0xec: "xhl", 0xf0: "xix", 0xf4: "xiy", 0xf8: "xiz", 0xfc: "xsp"}
R16 = {0xe0: "wa", 0xe4: "bc", 0xe8: "de", 0xec: "hl", 0xf0: "ix", 0xf4: "iy", 0xf8: "iz", 0xfc: "sp"}


def indexed_candidate(b):
    """The disassembler cannot print the register-indexed operand (xrr+rr) (prefix c3/d3/e3/f3, mode byte 07)
    that the assembler accepts since TOOLCHAIN_VERSION UPDATE 21.  Try the ALU / load spellings on that operand
    and return the first one llvm-mc encodes as exactly these bytes (an encoding is unique, so the first match
    is the instruction)."""
    if len(b) < 5 or b[0] not in (0xc3, 0xd3, 0xe3, 0xf3) or b[1] != 0x07:
        return None
    base, idx = R32.get(b[2]), R16.get(b[3])
    if not base or not idx:
        return None
    m = "(%s+%s)" % (base, idx)
    regs = (["w", "a", "b", "c", "d", "e", "h", "l"] if b[0] in (0xc3, 0xf3)
            else list(R16.values()) if b[0] == 0xd3 else list(R32.values()))
    cands = []
    for op in ("ld", "add", "adc", "sub", "sbc", "and", "or", "xor", "cp"):
        for r in regs:
            cands += ["%s %s, %s" % (op, r, m), "%s %s, %s" % (op, m, r)]
        cands += ["%s %s, 0x%02x" % (op, m, b[5])] if len(b) > 5 else []
    for c in cands:
        e = encode(c)
        if e and b.startswith(e):
            return c
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("label")
    ap.add_argument("--fix", action="append", default=[], help="0xADDR=instruction text")
    ap.add_argument("--auto-indexed", action="store_true",
                    help="decode <unknown> register-indexed (xrr+rr) forms by trial encoding")
    ap.add_argument("--apply", action="store_true")
    a = ap.parse_args()
    v = tree_of(os.path.abspath(a.file))
    rom = open(os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % v), "rb").read()
    by, at = syms(v)
    if a.label not in by:
        sys.exit("%s is not defined in the %s ELF (make all?)" % (a.label, v))
    start = by[a.label]
    L = open(a.file, "rb").read().decode("latin-1").split("\n")
    li = next(i for i, l in enumerate(L) if LABEL.match(l) and LABEL.match(l).group(1) == a.label)
    first = li + 1
    rest = LABEL.match(L[li]).group(2).strip()
    if rest and not rest.startswith(";"):
        m = BYTES.match(rest)
        if not m:
            sys.exit("%s: the label line holds something other than .byte" % a.label)
        L[li:li + 1] = ["%s:" % a.label, "\t" + rest]
    data, kept, j = bytearray(), [], first
    while j < len(L):
        s = L[j]
        if LABEL.match(s):
            break
        m = BYTES.match(s)
        if m:
            data += bytes(int(x, 0) for x in m.group(1).split(","))
        elif s.strip() == "" or s.strip().startswith(";"):
            if s.strip():
                kept.append(s)
        else:
            break
        j += 1
    n = len(data)
    if not n:
        sys.exit("%s: no .byte rows after the label" % a.label)
    if rom[start - 0xE00000:start - 0xE00000 + n] != data:
        sys.exit("%s: the .byte rows are not the dump's bytes at 0x%06x" % (a.label, start))
    fixes = {int(k, 0): t for k, t in (f.split("=", 1) for f in a.fix)}
    end = start + n
    out, pos = [], start
    while pos < end:
        if pos in fixes:
            text = fixes[pos]
        else:
            dec = objdump(v, pos, end)
            if not dec or dec[0][0] != pos:
                sys.exit("no decode at 0x%06x" % pos)
            text = dec[0][1]
            if text.startswith("<unknown>") and a.auto_indexed:
                text = indexed_candidate(rom[pos - 0xE00000:pos - 0xE00000 + 8]) or text
                if not text.startswith("<unknown>"):
                    print("0x%06x: decoded as `%s` (register-indexed form)" % (pos, text), file=sys.stderr)
            if text.startswith("<unknown>"):
                sys.exit("0x%06x: undecodable (bytes %s); supply --fix 0x%06x='...'"
                         % (pos, rom[pos - 0xE00000:pos - 0xE00000 + 6].hex(" "), pos))
        enc = encode(text)
        if enc is None:
            sys.exit("0x%06x: `%s` does not assemble" % (pos, text))
        if rom[pos - 0xE00000:pos - 0xE00000 + len(enc)] != enc or pos + len(enc) > end:
            sys.exit("0x%06x: `%s` encodes %s, the dump has %s" % (pos, text, enc.hex(" "),
                     rom[pos - 0xE00000:pos - 0xE00000 + len(enc)].hex(" ")))
        out.append((pos, text, len(enc)))
        pos += len(enc)

    def name_at(x):
        ns = at.get(x)
        if not ns:
            return None
        return sorted(ns, key=lambda q: (bool(STRUCT.search(q)), len(q), q))[0]

    lines = []
    for pos, text, ln in out:
        mn, _, ops = text.partition(" ")
        if mn in REL:
            parts = ops.rsplit(",", 1) if "," in ops else ["", ops]
            disp = int(parts[-1].strip(), 0)
            if mn in ("jrl", "calr") and disp > 0x7FFF:
                disp -= 0x10000          # objdump prints the 16-bit displacement unsigned
            nm = name_at(pos + ln + disp)
            if nm:
                ops = (parts[0].strip() + ", " if parts[0].strip() else "") + nm
        else:
            def sub(m):
                val = int(m.group(1), 0)
                nm = name_at(val) if 0xE00000 <= val <= 0xFFFFFF else None
                return m.group(0).replace(m.group(1), nm) if nm else m.group(0)
            ops = re.sub(r'(?<![\w+-])(\d{8}|0x[0-9a-f]{6})(?=(:24)?\)|$|\s*,)', sub, ops)
        lines.append("\t%s\t%s" % (mn, ops) if ops else "\t%s" % mn)
    new = L[:first] + kept + lines + L[j:]
    at0 = first + len(kept)
    respell(new, range(at0, at0 + len(lines)), v)
    for l in new[at0:at0 + len(lines)]:
        print(l)
    if a.apply:
        open(a.file, "wb").write("\n".join(new).encode("latin-1"))
        print("%s: %d bytes as %d instructions" % (a.label, n, len(lines)), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
