#!/usr/bin/env python3
r"""subcpu_bss_relative_refs.py -- spell the sub-CPU payload's absolute DRAM operands
relative to the start of its zero-initialised RAM, so that one source text serves every
payload revision.

QUESTION THIS ANSWERS
    Why does the same C variable sit at 0x04069A in v1.42 and at 0x040682 in v1.41?
    Because the payload's RAM (the C compiler's BSS) is linked directly after the program
    image: MemClear_DRAM_And_ExtRAM clears 0x66F2 bytes starting at the first even address
    after the code (v1.42: `ld xde, 0x3EE76`; v1.41: `ld xde, 0x3EE5E`), and v1.41's image
    is 0x18 bytes shorter.  Every absolute operand into that window therefore moves by the
    image-size difference.  Spelling those operands as `Payload_Bss_Start+0xOFFSET` makes
    the offset (which is the same in both revisions) the text, and lets the assembler
    supply the revision's base -- the same thing symbolic labels already do for ROM
    addresses, and what keeps the v141/v142 diff down to genuine firmware differences.

WHAT IT DOES (idempotent; operates on one tree, bytes in / bytes out)
    1. Rewrites every numeric literal OUTSIDE comments whose value lies in the v1.42 BSS
       window [0x03EE76, 0x03EE76 + 0x66F2) as `Payload_Bss_Start+0x<offset>`.  The
       literals in the tree are v1.42 values (the v141 tree is ported from v142), so the
       offset is taken against the v1.42 base for both trees.  EXCLUDE lists the literals in
       that range that are NOT addresses: six Q23 values in the DSP_FreqParamCurve_*
       coefficient ladders of subcpu_data_tables.s, which are identical in v1.41 and v1.42.
    2. Replaces the end-of-image fill (FP_Library_End_Pad, 139 explicit 0xFF bytes in
       v1.42) with `.balign 2` + the `Payload_Bss_Start` label + `.org` to the image end,
       so the fill length follows the code size.
    3. Spells MemClear_DRAM_And_ExtRAM's two operands as Payload_Bss_Start /
       Payload_Bss_Size and defines Payload_Bss_Size beside the other DRAM .equs.
    4. Respells IRAM_Unreferenced_F340's bytes 2..5, a little-endian u32 that reads
       0x0003ee9a in v1.42 and 0x0003ee82 in v1.41, as `.long Payload_Bss_Start+0x24`.
    5. Prefers names: wherever the tree defines `.equ NAME, Payload_Bss_Start+0x<offset>`
       (the named DRAM variables at the top of the main file), an operand that spells the
       same offset -- whether just converted by step 1 or already in that form -- is written
       NAME instead.  Two names for one offset are refused (canonical-label policy).

EVIDENCE THAT EVERY CONVERTED LITERAL IS AN ADDRESS
    The v141 tree is assembled after conversion and compared with
    original_ROMs/kn5000_subprogram_v141.rom: a literal that was a constant and not an
    address would now be 0x18 too low there, and the gate would fail.  It does not (make
    gate, the "subcpu payload v141" section).  For v142 the conversion is an identity
    (Payload_Bss_Start = 0x03EE76), checked by the v142 section of the same gate.

RUN
    python3 scripts/converters/subcpu_bss_relative_refs.py v141/subcpu
    python3 scripts/converters/subcpu_bss_relative_refs.py v142/subcpu
"""
import os
import re
import sys

BSS_V142 = 0x3EE76
BSS_SIZE = 0x66F2
LIT = re.compile(rb"(?<![\w.$])(0[xX][0-9A-Fa-f]+|\d+)(?![\w.$])")
# (file basename, literal text) pairs that are in range but are not addresses.
EXCLUDE = {("subcpu_data_tables.s", t) for t in (
    b"0x000409c2", b"0x000453b1", b"0x0003f67d", b"0x00041513", b"0x00043495", b"0x0004550b")}

FILES = None  # every .s in the tree

OLD_END_HEAD = (b"; --- 0x03EE75-0x03EEFF  FP_Library_End_Pad - end-of-library 0xFF fill\n"
                b"; 139 bytes of 0xFF. No code, no data; this is the tail padding of the sub-CPU program\n"
                b"; image and the end of the region.\n"
                b"FP_Library_End_Pad:\n")
NEW_END = (b"; FP_Library_End_Pad: the end of the program image.  `.balign` adds the one 0xFF byte\n"
           b"; that brings the next address to an even boundary (needed in v1.42 and v1.41 alike).\n"
           b"; That address is Payload_Bss_Start, where the payload's zero-initialised RAM begins:\n"
           b"; MemClear_DRAM_And_ExtRAM clears Payload_Bss_Size bytes from it at reset, and the\n"
           b"; absolute DRAM operands into that window are spelled Payload_Bss_Start+offset\n"
           b"; (scripts/converters/subcpu_bss_relative_refs.py says why).  The image file still\n"
           b"; runs on to 0x03eeff in 0xff fill, which that RAM overlays at run time.\n"
           b"FP_Library_End_Pad:\n"
           b"\t.balign\t2, 0xff\n"
           b"Payload_Bss_Start:\n"
           b"\t.org\t0x3ef00 - 0x400, 0xff\n")

OLD_CLEAR = b"MemClear_DRAM_And_ExtRAM:\n\tld xde, 0x3EE76\n\tld xbc, 0x66F2\n"
NEW_CLEAR = b"MemClear_DRAM_And_ExtRAM:\n\tld xde, Payload_Bss_Start\n\tld xbc, Payload_Bss_Size\n"

OLD_F340 = (b"; value in the image names an address in this range.  Purpose not established.\n"
            b"IRAM_Unreferenced_F340:\n"
            b"\t.byte 0x00, 0xff, 0x9a, 0xee, 0x03, 0x00, 0x00, 0x10\n")
NEW_F340 = (b"; value in the image names an address in this range.  Purpose not established.\n"
            b"; Bytes 2..5 are a u32 pointer into the zero-initialised RAM: 0x0003ee9a in v1.42,\n"
            b"; 0x0003ee82 in v1.41 -- the same offset from Payload_Bss_Start in both, so it moves\n"
            b"; with the BSS base the way the code's DRAM operands do.\n"
            b"IRAM_Unreferenced_F340:\n"
            b"\t.byte 0x00, 0xff\n"
            b"\t.long Payload_Bss_Start+0x24\n"
            b"\t.byte 0x00, 0x10\n")

EQU_ANCHOR = b"\t.equ\tVoice_GlobalFlags, 0x041343\n"
EQU_SIZE = (b"; Payload_Bss_Size: bytes of zero-initialised RAM that MemClear_DRAM_And_ExtRAM clears from\n"
            b";   Payload_Bss_Start (the first even address after the program image) at reset.\n"
            b"\t.equ\tPayload_Bss_Size, 0x66f2\n")
OLD_EQU_HEAD = (b"; --- DRAM variables named by the headers that use them (2026-09-25).  Only these five; the other\n"
                b"; RAM operands stay numeric until their meaning is pinned the same way. ---\n")
NEW_EQU_HEAD = (b"; --- DRAM variables named by the headers that use them (2026-09-25).  Only these five have names;\n"
                b"; the other RAM operands are spelled Payload_Bss_Start+offset until their meaning is pinned the\n"
                b"; same way (scripts/converters/subcpu_bss_relative_refs.py). ---\n")


EQU_DEF = re.compile(rb"^\s*\.equ\s+(\w+)\s*,\s*Payload_Bss_Start\+0x([0-9A-Fa-f]+)\s*$")
BSS_REF = re.compile(rb"(?<![\w.$])Payload_Bss_Start\+0x([0-9A-Fa-f]+)(?![\w.$])")


def bss_names(tree):
    """{offset: NAME} for every `.equ NAME, Payload_Bss_Start+0x<offset>` in the tree."""
    names = {}
    for fn in sorted(os.listdir(tree)):
        if not fn.endswith(".s"):
            continue
        for line in open(os.path.join(tree, fn), "rb").read().split(b"\n"):
            m = EQU_DEF.match(split_comment(line)[0])
            if m:
                off = int(m.group(2), 16)
                if off in names and names[off] != m.group(1):
                    sys.exit("two names for Payload_Bss_Start+0x%x: %s, %s"
                             % (off, names[off].decode(), m.group(1).decode()))
                names[off] = m.group(1)
    return names


def split_comment(line):
    q = False
    for i, ch in enumerate(line):
        if ch == 0x22:
            q = not q
        elif ch == 0x3B and not q:
            return line[:i], line[i:]
    return line, b""


def value(tok):
    return int(tok, 16) if tok[:2].lower() == b"0x" else int(tok, 10)


def convert_lines(name, data, names):
    out, n, k = [], 0, 0
    for line in data.split(b"\n"):
        code, comment = split_comment(line)
        if code.strip().startswith(b".org"):
            # image-layout arithmetic (the end-of-image .org), never a DRAM operand
            out.append(line)
            continue

        def sub(m):
            nonlocal n
            tok = m.group(1)
            v = value(tok)
            if BSS_V142 <= v < BSS_V142 + BSS_SIZE and (name, tok) not in EXCLUDE:
                n += 1
                return b"Payload_Bss_Start+0x%x" % (v - BSS_V142)
            return tok
        code = LIT.sub(sub, code)
        if not code.strip().startswith(b".equ"):
            before = len(BSS_REF.findall(code))
            code = BSS_REF.sub(lambda m: names.get(int(m.group(1), 16), m.group(0)), code)
            k += before - len(BSS_REF.findall(code))
        out.append(code + comment)
    return b"\n".join(out), n, k


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    tree = sys.argv[1]
    total = named = 0
    names = bss_names(tree)
    for name in sorted(os.listdir(tree)):
        if not name.endswith(".s"):
            continue
        p = os.path.join(tree, name)
        data = open(p, "rb").read()
        orig = data
        if OLD_END_HEAD in data:
            i = data.index(OLD_END_HEAD)
            j = data.index(b"\t.byte 0xff, 0xff, 0xff\n", i) + len(b"\t.byte 0xff, 0xff, 0xff\n")
            body = data[i + len(OLD_END_HEAD):j]
            assert set(body.split(b"\n")[:-1]) <= {b"\t.fill 8, 1, 0xff", b"\t.byte 0xff, 0xff, 0xff"}, body
            data = data[:i] + NEW_END + data[j:]
        if OLD_F340 in data:
            data = data.replace(OLD_F340, NEW_F340)
        if OLD_CLEAR in data:
            data = data.replace(OLD_CLEAR, NEW_CLEAR)
        if EQU_ANCHOR in data and b"Payload_Bss_Size," not in data:
            data = data.replace(EQU_ANCHOR, EQU_ANCHOR + EQU_SIZE, 1)
        if OLD_EQU_HEAD in data:
            data = data.replace(OLD_EQU_HEAD, NEW_EQU_HEAD)
        data, n, k = convert_lines(name, data, names)
        total += n
        named += k
        if data != orig:
            open(p, "wb").write(data)
        print("%-32s %4d literals converted, %4d operands named" % (name, n, k))
    print("total %d literals converted, %d operands named" % (total, named))


if __name__ == "__main__":
    main()
