#!/usr/bin/env python3
"""Compare a hd_v423.py --show dump with the ROM's function, instruction by instruction.

Question it answers: where does V4.23's code for a C form differ from HDAE5000_SelectListProc in the ROM, ignoring
branch distances and jr/jrl, call/calr lengths?  Both sides go through MAME's unidasm so the text is comparable.
Usage: cmp.py SHOWFILE OUTDIR TAG   (writes OUTDIR/gen_TAG.bin, prints a unified diff ROM -> generated)
       cmp.py SHOWFILE OUTDIR TAG LABEL   (any other v2.06i function: address from the symbols reference, size
                                           from survey.tsv)
       cmp.py SHOWFILE OUTDIR TAG LABEL SIZE   (SIZE bytes from LABEL: a procedure the survey split into pieces)
"""
import difflib
import re
import subprocess
import sys

ROM = "original_ROMs/hd-ae5000_v2_06i.ic4"
UNIDASM = "../../tools/unidasm"
OFS, SIZE = 0x7D9, 2641


def dis(path, skip, count):
    out = subprocess.run([UNIDASM, path, "-arch", "tlcs900", "-basepc", "0", "-skip", str(skip), "-count",
                          str(count)], capture_output=True, text=True).stdout
    res = []
    for line in out.splitlines():
        m = re.match(r"\s*([0-9a-fA-F]+):\s+(.*)", line)
        if not m:
            continue
        t = re.sub(r"\s+", " ", m.group(2).strip())
        t = re.sub(r"^((?:[0-9a-f]{2} )+)", "", t)
        mn = t.split(" ")[0].lower()
        if mn in ("jr", "jrl", "calr", "call", "jp") and "(" not in t:
            cc = ""
            mm = re.match(r"\S+ (\w+),", t)
            if mm:
                cc = mm.group(1)
            t = "BR %s" % cc if mn in ("jr", "jrl", "jp") else "CALL"
        res.append(t)
    return res


def label_range(label):
    """(ROM offset, size) of a v2.06i function: its address from the symbols reference, its size from survey.tsv"""
    global OFS, SIZE
    for l in open("symbols/hdae5000_symbols_reference.txt"):
        c = l.split()
        if len(c) == 2 and c[0] == label:
            OFS = int(c[1], 16) - 0x280000
    for l in open("notes/cc900-c-hdae5000-2026-11-16/survey.tsv"):
        c = l.split("\t")
        if len(c) > 3 and c[1] == label:
            SIZE = int(c[3])


def main():
    show, outdir, tag = sys.argv[1:4]
    if len(sys.argv) > 4:          # another function than SelectListProc: cmp.py SHOW OUTDIR TAG LABEL [SIZE]
        label_range(sys.argv[4])
    if len(sys.argv) > 5:          # a procedure the survey split into pieces: its whole size
        global SIZE
        SIZE = int(sys.argv[5], 0)
    data = bytearray()
    for line in open(show, encoding="latin-1"):
        if line.startswith("=="):
            continue
        m = re.match(r"(.{40})\s*([0-9a-f]+)\s+[=!]", line)
        if not m:
            continue
        data += bytes.fromhex(m.group(2))
    gen = "%s/gen_%s.bin" % (outdir, tag)
    open(gen, "wb").write(data)
    a = dis(ROM, OFS, SIZE)
    b = dis(gen, 0, len(data))
    print("ROM %d instr, gen %d instr (%d bytes)" % (len(a), len(b), len(data)))
    for l in difflib.unified_diff(a, b, "rom", tag, n=4, lineterm=""):
        print(l)


main()
