#!/usr/bin/env python3
r"""hdae5000_ram_image_refs.py -- code addresses into the copied .data image, by label.

QUESTION ANSWERED / JOB IT DOES
-------------------------------
HDAE5000_Clear_Work_Buffer copies the initialised .data image (HDAE5000_DataSegmentImage ..
HDAE5000_Init_Data_End, hdae5000_init_data.s) to RAM HDAE5000_DATA_COPY_DEST (0x23952A in
v2.06i, 0x2394CE in v2.01i).  The code then reaches those tables and variables at their RAM
addresses, which the source spelled as numbers: HDAE5000_Handler_Registration's eleven
RegisterObjectTable operands (`lda xwa, (0x2397ea:24)` ...), the file-format version bytes, the
name-edit buffers.  Some numbers also carried wrong names that nothing used
(HDAE5000_RAM_DATA_A_SIZE = 0x239822 is the ResEvent table's count, HDAE5000_SERIAL_DATA_1 =
0x239872 the Function table; in v2.01i those .equs even kept v2.06i's values).

This tool, per tree:
  * defines HDAE5000_RAM_<name> = HDAE5000_<name> - HDAE5000_DataSegmentImage +
    HDAE5000_DATA_COPY_DEST for every image label the code reaches (a block at the end of
    hdae5000_init_data.s), so each RAM address follows its label;
  * respells every `(0x23xxxx:24)` operand and `ld xRR, 0x23xxxx` immediate of the code that
    lands in the copied image as HDAE5000_RAM_<label>, or HDAE5000_RAM_<label> + N for an
    address inside a labelled block (the nearest label at or below it);
  * removes the unused, misnamed .equs of hdae5000_ui_display.s's registration block.
It refuses unless every respelled number equals the value its new spelling computes from the
built ELF; `make gate` (byte identity) is the final word.

RUN (repo root, built tree):
    python3 scripts/converters/hdae5000_ram_image_refs.py            # report
    python3 scripts/converters/hdae5000_ram_image_refs.py --write
"""
import bisect
import collections
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
TREES = {"hdae5000": ("hd-ae5000_v2_06i", "hd-ae5000_v2_06i.s"),
         "hdae5000_v2_01i": ("hd-ae5000_v2_01i", "hd-ae5000_v2_01i.s")}
CODE = ["hdae5000_ui_display.s", "hdae5000_utilities.s", "hdae5000_filesystem.s", "hdae5000_hd_driver.s"]
MISNAMED = ("HDAE5000_RAM_DATA_A_SIZE", "HDAE5000_RAM_DATA_A", "HDAE5000_RAM_DATA_B_SIZE",
            "HDAE5000_RAM_DATA_B", "HDAE5000_INIT_DATA_2", "HDAE5000_SERIAL_DATA_1",
            "HDAE5000_SERIAL_DATA_2", "HDAE5000_PARALLEL_DATA_1", "HDAE5000_PARALLEL_DATA_2")
# the image's first label is the ApFunction table itself: name it so
PREFER = {"HDAE5000_DataSegmentImage": "HDAE5000_ObjHandler_Table"}
OPERAND = re.compile(r"\((0x23[0-9a-fA-F]{4})(:24)\)|(\bld\s+x[a-z]{2},\s*)(0x23[0-9a-fA-F]{4})\b")


def fail(msg):
    sys.exit("REFUSED: " + msg)


def symbols(elf):
    out = subprocess.run([NM, "--defined-only", os.path.join(ROOT, "rebuilt_ROMs", elf + ".llvm.elf")],
                         capture_output=True, text=True, check=True).stdout
    by, at = {}, collections.defaultdict(list)
    for l in out.split("\n"):
        f = l.split()
        if len(f) == 3:
            by[f[2]] = int(f[0], 16)
            if f[1] in "tT" and not f[2].startswith(".L"):
                at[int(f[0], 16)].append(f[2])
    return by, at


def run(tree, write):
    elf, main = TREES[tree]
    by, at = symbols(elf)
    img, end, dest = by["HDAE5000_DataSegmentImage"], by["HDAE5000_Init_Data_End"], by["HDAE5000_DATA_COPY_DEST"]
    labs = sorted(a for a in at if img <= a < end)
    used = {}

    def spell(v):
        rom = v - dest + img
        k = bisect.bisect_right(labs, rom) - 1
        base = labs[k]
        names = sorted(at[base], key=lambda n: (not n.startswith("HDAE5000_"), n))
        n = PREFER.get(names[0], names[0])
        if not n.startswith("HDAE5000_"):
            fail("0x%06x: label %s has no HDAE5000_ prefix" % (v, n))
        ram = "HDAE5000_RAM_" + n[len("HDAE5000_"):]
        if ram in by and ram not in used:
            fail("%s already exists" % ram)
        used[ram] = n
        if (by[n] - img + dest) + (rom - base) != v:
            fail("0x%06x: %s + %d does not compute it" % (v, ram, rom - base))
        return ram if rom == base else "%s+%d" % (ram, rom - base)

    edits = 0
    for f in [main] + CODE:
        p = os.path.join(ROOT, tree, f)
        L = open(p, "rb").read().split(b"\n")
        for i, raw in enumerate(L):
            ln = raw.decode("latin-1")
            code, sep, com = ln.partition(";")
            if code.strip().startswith(".equ"):
                if any(re.match(r"^\s*\.equ\s+%s\s*," % n, code) for n in MISNAMED):
                    L[i] = None
                    edits += 1
                continue

            def rep(m):
                if m.group(1):
                    v = int(m.group(1), 16)
                    if not dest <= v < dest + (end - img):
                        return m.group(0)
                    return "(%s:24)" % spell(v)
                v = int(m.group(4), 16)
                if not dest <= v < dest + (end - img):
                    return m.group(0)
                return m.group(3) + spell(v)
            new = OPERAND.sub(rep, code)
            if new != code:
                edits += 1
                L[i] = (new + sep + com).encode("latin-1")
        L = [x for x in L if x is not None]
        if write:
            open(p, "wb").write(b"\n".join(L))
    block = ["",
             "; ----------------------------------------------------------------------------",
             "; RAM addresses of the image labels the code reaches: the image is copied to",
             "; HDAE5000_DATA_COPY_DEST, so HDAE5000_RAM_<name> follows HDAE5000_<name>.  The",
             "; code spells its RAM operands with these (scripts/converters/hdae5000_ram_image_refs.py).",
             "; ----------------------------------------------------------------------------"]
    for ram, n in sorted(used.items(), key=lambda kv: by[kv[1]]):
        block.append("\t.set\t%s, %s - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST" % (ram, n))
    print("%s: %d lines respelled or removed, %d RAM names" % (tree, edits, len(used)))
    if write:
        p = os.path.join(ROOT, tree, "hdae5000_init_data.s")
        t = open(p, "rb").read()
        if b"hdae5000_ram_image_refs.py" not in t:
            t = t.rstrip(b"\n") + b"\n" + "\n".join(block).encode() + b"\n"
            open(p, "wb").write(t)


if __name__ == "__main__":
    for t in TREES:
        run(t, "--write" in sys.argv)
