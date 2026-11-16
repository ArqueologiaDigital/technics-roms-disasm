#!/usr/bin/env python3
"""Give the firmware C's externs the cc900 qualifier that matches the operand width the ROM uses for them.

QUESTION ANSWERED: which `__near` / `__tiny` qualifiers must the built firmware C (<tree>/cc900/*.c) carry so that
Toshiba V4.23 writes the ROM's operand widths?  V4.23 does not choose an absolute operand's width from the address:
its listing declares each extern `large` (24-bit, the default), `medium` (`__near`, 16-bit) or `small` (`__tiny`,
8-bit), and the access is that wide (probe m16, run 2026-11-16-29-p6-m16).  The functions built from C so far match
the ROM with the old address rule of model/to_llvm.py (8-bit below 0x100, 16-bit below 0x10000, else 24-bit), so
this script writes exactly that rule into the C: an extern whose value in the tree is below 0x100 becomes `__tiny`,
below 0x10000 `__near`, and the rest stays plain (large).  `make gate` then checks the result under V4.23.

usage: python3 -B scripts/tools/cc900_near_qualifiers.py [--check] TREE [TREE ...]     (TREE: v10/maincpu)
Rewrites each one-line `extern TYPE a, b, *c;` of TREE/cc900/*.c (not cc900/unbuilt/): the large names stay
together, each qualified one gets a declaration of its own, `extern TYPE __near a;`, `extern TYPE * __near c;`,
because V4.23 applies a qualifier to the first declarator only (run 2026-11-16-30-p6-r1).  A qualifier of a pointer
object goes after its `*` (before it, it would qualify what the pointer points to).  Prototypes
(declarations with a parameter list) and declarations that already carry a qualifier are left alone.  --check
changes nothing and exits 1 when a file would change.
"""
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "scripts", "build"))
import cc900_firmware_c as fw                     # noqa: E402

DECL = re.compile(r'^extern\s+([^;()]*?)\s*;\s*$')


def width_class(names, n):
    a = names[n] if n in names else None
    if a is None:
        sys.exit("no value for %s in the tree" % n)
    return "__tiny" if a < 0x100 else "__near" if a < 0x10000 else ""


def rewrite_line(line, names):
    m = DECL.match(line)
    if not m or "__near" in line or "__tiny" in line:
        return line
    body = m.group(1)
    parts = [p.strip() for p in body.split(",")]
    first = re.match(r'^(.*?)([\s*]*)([A-Za-z_]\w*)(\s*\[[^\]]*\])?$', parts[0])
    if not first:
        return line
    spec = first.group(1).strip()
    decls = [first.group(2).strip() + first.group(3) + (first.group(4) or "")] + parts[1:]
    groups = {}
    order = []
    for d in decls:
        dm = re.match(r'^(\**)\s*([A-Za-z_]\w*)(\s*\[[^\]]*\])?$', d)
        if not dm:
            return line
        stars, name, arr = dm.group(1), dm.group(2), dm.group(3) or ""
        q = width_class(names, name)
        key = (q, bool(stars))
        if key not in groups:
            groups[key] = []
            order.append(key)
        groups[key].append((stars, name, arr))
    out = []
    for q, ptr in order:
        ds = groups[(q, ptr)]
        if not q:   # large: as before, several names in one declaration
            out.append("extern %s %s;" % (spec, ", ".join(s + n + a for s, n, a in ds)))
        else:       # V4.23 qualifies the first declarator only: one declaration per name
            for s, n, a in ds:
                out.append("extern %s %s %s %s%s;" % (spec, s, q, n, a) if s else "extern %s %s %s%s;" % (spec, q, n, a))
    return "\n".join(out)


def main():
    a = sys.argv[1:]
    check = "--check" in a
    trees = [x for x in a if x != "--check"]
    if not trees:
        sys.exit(__doc__)
    changed = []
    for tree in trees:
        t = os.path.join(REPO, tree)
        names = fw.Names(fw.tree_values(t), fw.tree_labels(t))
        for path in sorted(glob.glob(os.path.join(t, "cc900", "*.c"))):
            text = open(path, encoding="latin-1").read()
            new = "\n".join(rewrite_line(l, names) for l in text.split("\n"))
            if new != text:
                changed.append(os.path.relpath(path, REPO))
                if not check:
                    open(path, "w", encoding="latin-1").write(new)
    print("%s %d file(s)%s" % ("would change" if check else "changed", len(changed),
                                "".join("\n    " + c for c in changed)))
    return 1 if check and changed else 0


if __name__ == "__main__":
    sys.exit(main())
