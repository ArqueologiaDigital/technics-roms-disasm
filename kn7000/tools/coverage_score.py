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


def read_source(path):
    """The program source with every `.include`d .s file inlined (src/program.s
    includes its code-region parts from src/program/)."""
    out = []
    for line in open(path).read().split("\n"):
        m = re.match(r'\s*\.include\s+"([^"]+\.s)"', line)
        if m:
            out.append(read_source(os.path.join(REPO, m.group(1))))
        else:
            out.append(line)
    return "\n".join(out)


def measure():
    src = read_source(PROG_S)
    lines = src.split("\n")

    # Bytes handed back to the assembler verbatim, per source ROM.
    #
    # ⚠ Operands are EXPRESSIONS, not always bare hex. The earlier regex demanded
    # `0x...`, so `.incbin_range "...", 0x32573C + 0x800, 0x3B8000` silently did not
    # match and its 598,212 bytes were counted as SOURCE -- inflating KN7000 coverage
    # about 5x (18.03% reported vs 3.64% real). The assertion below makes that class
    # of miss impossible rather than relying on the regex being right.
    def _val(expr):
        """Evaluate a simple additive hex/decimal operand expression."""
        total, sign = 0, 1
        for tok in re.findall(r'[+-]|0x[0-9A-Fa-f]+|\d+', expr):
            if tok == '+':
                sign = 1
            elif tok == '-':
                sign = -1
            else:
                total += sign * int(tok, 16 if tok.lower().startswith('0x') else 10)
        return total

    raw = {}
    parsed = 0
    for f, a, b in re.findall(
        r'\.incbin_range\s+"([^"]+)",\s*([^,]+?),\s*([^\n]+?)\s*(?:;|$)', src, re.M
    ):
        name = f.split("/")[-1]
        raw[name] = raw.get(name, 0) + _val(b) - _val(a)
        parsed += 1

    # Only line-leading directives count; the file also *mentions* the name in a comment.
    occurrences = len(re.findall(r'^\s*\.incbin_range\b', src, re.M))
    if parsed != occurrences:
        raise SystemExit(
            "coverage_score: parsed %d .incbin_range directives but the file contains %d. "
            "An unparsed directive is counted as SOURCE and inflates the score -- fix the "
            "parser rather than the number." % (parsed, occurrences))

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
    # Escape hatches: instructions the encoder could NOT reproduce, kept as
    # .byte (tools/gen_program_s.py marks them `# not encodable:`). Should stay at
    # zero. Typed data lines (.byte/.word/.long: the palette, data islands, the
    # boot header's marker byte) are counted apart; they are not escapes.
    escapes = sum(1 for l in lines if re.match(r"^\s+\.byte\b.*#\s*not encodable:", l))
    data_lines = sum(1 for l in lines if re.match(r"^\s+\.(byte|word|long|short)\b", l)) - escapes

    # Sanity: MN10300 instructions encode in 1..7 bytes, so source bytes per
    # instruction line must land in that band. Outside it, one of the two numbers is
    # measuring something other than what its name says.
    if insn:
        bpi = prog_src / insn
        if not 1.0 <= bpi <= 7.0:
            raise SystemExit(
                "coverage_score: %.2f source bytes per instruction line (%d B / %d lines). "
                "MN10300 encodings are 1..7 bytes, so this score is wrong." % (bpi, prog_src, insn))

    # Converted functions, counted in the source itself: every function block
    # starts with a `# NAME  (CPU 0x..)` / `# NAME  (lib CPU 0x..)` header (which may
    # go on after a `;`: `(CPU 0x..; its register-save prologue starts at 0x..)`); it
    # is converted when the first line after its comments is not .incbin_range. A
    # library block that is only the prologue of the next one shares its header
    # with it (`(lib CPU 0x..; its `call` entry X at 0x..)`): one function, one block.
    nfuncs = nblocks = 0
    pending = False
    for l in lines:
        if re.match(r"# \S+  \((lib )?CPU 0x[0-9a-fA-F]+[);]", l):
            nblocks += 1
            pending = True
            continue
        if pending and l.strip() and not l.lstrip().startswith("#"):
            nfuncs += 0 if l.lstrip().startswith(".incbin_range") else 1
            pending = False

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
        nblocks=nblocks,
        data_lines=data_lines,
        named=named,
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--append", action="store_true", help="append a dated row to notes/coverage-history.tsv")
    args = ap.parse_args()

    m = measure()
    # The commit column is the HEAD the tree was measured on; a `+` after it says
    # the measured src/ or tools/ had changes not yet committed (a row is usually
    # appended in the commit that makes the change, so it is measured on its parent).
    try:
        commit = subprocess.check_output(
            ["git", "-C", REPO, "rev-parse", "--short", "HEAD"], text=True
        ).strip()
        if subprocess.check_output(["git", "-C", REPO, "status", "--porcelain", "--", "src", "tools"],
                                   text=True).strip():
            commit += "+"
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
    print(f"  instruction escapes (.byte): {m['escapes']}  (want 0)")
    print(f"  typed data lines           : {m['data_lines']:,}")
    print(f"  converted functions        : {m['nfuncs']:,} of {m['nblocks']:,} function blocks"
          f" ({m['named']:,} symbol-file entries)")
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
