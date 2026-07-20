#!/usr/bin/env python3
"""coverage_score.py -- how much of the KN7000 firmware is REAL source, not passthrough?

Felipe asked (2026-07-20) to track this score as the CONVERT work proceeds.

TWO NUMBERS, and only one of them means anything:

  * BYTE-MATCH is always 100% -- that is the repo's invariant (`make verify` rebuilds
    both ROMs byte-for-byte). It is achieved mostly by `.incbin_range` passthrough, so
    on its own it proves nothing about understanding.

  * SOURCE COVERAGE is the honest score: the share of the image emitted as real,
    re-assemblable MN10300 assembly instead of raw bytes. That is what this tool
    reports. "The parts we have explained are source; the parts we have not are
    still bytes."

Usage:
    python3 tools/coverage_score.py            # current score
    python3 tools/coverage_score.py --append   # also append a dated row to
                                               # notes/coverage-history.tsv
Run it at the end of a CONVERT pass; the history file makes the trend visible.
"""
import argparse
import datetime
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROG_S = os.path.join(REPO, "src", "program.s")
HISTORY = os.path.join(REPO, "notes", "coverage-history.tsv")
ROMS = {
    "kn7000_program.rom": os.path.join(REPO, "baserom", "kn7000_program.rom"),
    "kn7000_table.rom": os.path.join(REPO, "baserom", "kn7000_table.rom"),
}


def measure():
    src = open(PROG_S).read()
    lines = src.split("\n")

    # Bytes handed back to the assembler verbatim, per source ROM.
    raw = {}
    for f, a, b in re.findall(
        r'\.incbin_range\s+"([^"]+)",\s*(0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+)', src
    ):
        name = f.split("/")[-1]
        raw[name] = raw.get(name, 0) + int(b, 16) - int(a, 16)

    sizes = {n: os.path.getsize(p) for n, p in ROMS.items() if os.path.exists(p)}
    prog_total = sizes.get("kn7000_program.rom", 0)
    prog_raw = raw.get("kn7000_program.rom", 0)
    prog_src = prog_total - prog_raw

    # Instruction-bearing lines (a rough size-independent view of the same thing).
    insn = sum(
        1
        for l in lines
        if re.match(r"^\s+[a-z]{2,7}(\.[bwl])?\s", l) and not l.strip().startswith((".", "#"))
    )
    # Escape hatches: bytes we could NOT encode. Should stay near zero.
    escapes = sum(1 for l in lines if re.match(r"^\s+\.(byte|word|long|short)\b", l))

    # Converted-function count: gen_program_s.py's CONVERT (a set of names) +
    # LIB_CONVERT (name -> (start, end) for the 0x4C library window).
    gen = open(os.path.join(REPO, "tools", "gen_program_s.py")).read()
    m = re.search(r"^CONVERT\s*=\s*\{(.*?)^\}", gen, re.S | re.M)
    conv = set(re.findall(r'"([A-Za-z_][A-Za-z0-9_]*)"', m.group(1))) if m else set()
    m2 = re.search(r"^LIB_CONVERT\s*=\s*\{(.*?)^\}", gen, re.S | re.M)
    libconv = set(re.findall(r'"([A-Za-z_][A-Za-z0-9_]*)"\s*:', m2.group(1))) if m2 else set()
    nfuncs = len(conv) + len(libconv)

    # Denominator: distinct symbol entries (skip comments/blanks). kn7000.sym is
    # the firmware's own reflection-table names; kn7000_manual.sym is hand-RE'd
    # (it also holds data labels, so this denominator is an over-count -- the
    # honest headline number is the BYTE percentage above).
    named = 0
    for symfile in ("kn7000.sym", "kn7000_manual.sym"):
        sp = os.path.join(REPO, symfile)
        if os.path.exists(sp):
            named += sum(
                1 for l in open(sp) if l.strip() and not l.lstrip().startswith((";", "#"))
            )

    return dict(
        prog_total=prog_total,
        prog_raw=prog_raw,
        prog_src=prog_src,
        pct=100.0 * prog_src / prog_total if prog_total else 0.0,
        insn=insn,
        escapes=escapes,
        nfuncs=nfuncs,
        named=named,
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--append", action="store_true", help="append a dated row to notes/coverage-history.tsv")
    args = ap.parse_args()

    m = measure()
    try:
        commit = subprocess.check_output(
            ["git", "-C", REPO, "rev-parse", "--short", "HEAD"], text=True
        ).strip()
    except Exception:
        commit = "?"

    print("KN7000 firmware source coverage")
    print("-------------------------------")
    print(f"  byte-match                 : 100% by construction (make verify)")
    print(f"  program ROM                : {m['prog_total']:,} bytes")
    print(f"    .incbin passthrough      : {m['prog_raw']:,}")
    print(f"    REAL assembly source     : {m['prog_src']:,}")
    print(f"  >> SOURCE COVERAGE         : {m['pct']:.2f}%")
    print(f"  instruction lines          : {m['insn']:,}")
    print(f"  .byte escape hatches       : {m['escapes']}  (want ~0)")
    print(f"  converted functions        : {m['nfuncs']:,} of {m['named']:,} named")
    print(f"  commit                     : {commit}")

    if args.append:
        new = not os.path.exists(HISTORY)
        with open(HISTORY, "a") as fh:
            if new:
                fh.write(
                    "# KN7000 source-coverage history (append one row per CONVERT pass)\n"
                    "# byte-match is always 100%; this tracks REAL source vs .incbin passthrough\n"
                    "date\tcommit\tsrc_bytes\tprog_bytes\tpct\tinsn_lines\tescapes\tfuncs\n"
                )
            fh.write(
                "{date}\t{c}\t{s}\t{t}\t{p:.2f}\t{i}\t{e}\t{f}\n".format(
                    date=datetime.date.today().isoformat(),
                    c=commit,
                    s=m["prog_src"],
                    t=m["prog_total"],
                    p=m["pct"],
                    i=m["insn"],
                    e=m["escapes"],
                    f=m["nfuncs"],
                )
            )
        print(f"\nappended a row to {HISTORY}")


if __name__ == "__main__":
    sys.exit(main())
