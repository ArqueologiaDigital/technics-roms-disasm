#!/usr/bin/env python3
"""quote_macro_string_params.py -- respell `.ascii \\p` as `.ascii "\\p"` in the kn7asm trees' macro bodies.

QUESTION IT ANSWERS / JOB IT DOES
  kn7asm used to keep a quoted macro argument's quotes, so a macro body wrote `.ascii \\name` and the
  invocation `M "text"` produced `.ascii "text"`.  GNU as and llvm-mc strip the quotes, so the same body
  needs `.ascii "\\name"`; kn7asm does that too since 2026-10-31 (kn7000/tools/kn7asm.py, bind_args /
  macro_arg_text).  This rewrites every `.ascii` / `.asciz` operand inside a `.macro` body of a git-tracked
  .s / .inc file of the kn7asm trees (kn7000, kn2400, kn6000, kn6500, hdsx3) that is exactly one bare
  parameter reference `\\p` of that macro, to `"\\p"`.  Nothing else changes, so a tree assembles to the same
  bytes as before (its gate proves it).  The generated data_structs.inc files get the same text
  kn7000/tools/data_structs.py now writes.

RUN (repository root)
  python3 notes/misc-2026-10-31/probes/quote_macro_string_params.py            # dry run: counts per file
  python3 notes/misc-2026-10-31/probes/quote_macro_string_params.py --apply
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
TREES = ("kn7000", "kn2400", "kn6000", "kn6500", "hdsx3")
MACRO = re.compile(rb'^\s*\.macro\s+([A-Za-z_]\w*)\s*(.*)$')
ENDM = re.compile(rb'^\s*\.endm\b')
ASCII = re.compile(rb'^(\s*\.(?:ascii|asciz)\s+)(.*?)(\s*)$')


def params_of(rest):
    rest = re.split(rb'[#;]', rest)[0]
    return {p.split(b"=")[0].split(b":")[0].strip() for p in re.split(rb'[,\s]+', rest) if p.strip()}


def fix_operands(ops, params):
    out, n = [], 0
    for op in ops.split(b","):
        s = op.strip()
        m = re.match(rb'^\\(\w+)$', s)
        if m and m.group(1) in params:
            op = op.replace(s, b'"' + s + b'"')
            n += 1
        out.append(op)
    return b",".join(out), n


def main():
    apply = "--apply" in sys.argv
    files = subprocess.run(["git", "-C", ROOT, "ls-files", "--"] + ["%s/*.s" % t for t in TREES]
                           + ["%s/*.inc" % t for t in TREES], capture_output=True, text=True).stdout.split()
    total = 0
    for rel in files:
        p = os.path.join(ROOT, rel)
        data = open(p, "rb").read()
        if b".macro" not in data:
            continue
        lines = data.split(b"\n")
        params, n = None, 0
        for i, l in enumerate(lines):
            m = MACRO.match(l)
            if m:
                params = params_of(m.group(2))
                continue
            if params is not None and ENDM.match(l):
                params = None
                continue
            if params is None:
                continue
            code, sep, cmt = l.partition(b"#")
            a = ASCII.match(code)
            if not a or b'"' in a.group(2):
                continue
            new_ops, k = fix_operands(a.group(2), params)
            if k:
                lines[i] = a.group(1) + new_ops + a.group(3) + sep + cmt
                n += k
        if n:
            total += n
            print("%-60s %5d operand(s)" % (rel, n))
            if apply:
                open(p, "wb").write(b"\n".join(lines))
    print("total %d operand(s)%s" % (total, "" if apply else " (dry run)"))


if __name__ == "__main__":
    main()
