#!/usr/bin/env python3
"""fix_hdae5000_tail_loops.py -- correct the _Loop names localize_hdae5000_address_locals.py gave to shared tails.

QUESTION IT ANSWERS
  localize_hdae5000_address_locals.py (first run, commit fc17ceffe) called every label with a branch to it from
  BELOW a `_Loop`.  A backward branch to a block that other code also uses is not necessarily a loop:
  HDAE5000_Float_Unpack's zero case jumps back to the stores and `ret` above it, and three late arms of
  HDAE5000_SelectListProc jump back to its "send EVT_HDAE_CHANGE_SEL_NUM" block, which itself leaves through an
  unconditional jump before reaching them.  A `_Loop[N]` label is renamed here when
    (a) straight-line code from it (no branch or call) reaches an unconditional ret within six instructions
        -- named `_Return` / `_Epilogue` / `_Done` by the first run's shapes (tail_shape); or
    (b) none of the backward branches to it can be reached from it by falling through and branching forward
        inside the span up to them (reaches) -- named `_Skip` when the statement above it is an unconditional
        transfer, else `_Join`, as in the first run.
  N is the first free number.  The first run's classifier applies (a) itself now.

  Only labels on the right-hand side of scripts/renaming/localize_hdae5000_address_locals.sed are considered, so
  nothing named by hand is touched.  Applied through a generated sed script, like the first run.

RUN (repository root)
  python3 scripts/renaming/fix_hdae5000_tail_loops.py            # list
  python3 scripts/renaming/fix_hdae5000_tail_loops.py --apply    # write scripts/renaming/fix_hdae5000_tail_loops.sed
                                                                 # and run it (LC_ALL=C sed -i) on hdae5000/*.s
"""
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "renaming"))
import localize_hdae5000_address_locals as L  # noqa: E402

SED_IN = os.path.join(ROOT, "scripts/renaming/localize_hdae5000_address_locals.sed")
SED_OUT = os.path.join(ROOT, "scripts/renaming/fix_hdae5000_tail_loops.sed")


def main():
    ours = set(re.findall(r'/([A-Za-z_]\w*)/g$', open(SED_IN).read(), re.M))
    files = sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s")))
    src = {p: open(p, "rb").read().decode("latin-1").split("\n") for p in files}
    taken = set()
    for p in glob.glob(os.path.join(ROOT, "hdae5000", "**", "*.*"), recursive=True):
        if os.path.isfile(p) and p.rsplit(".", 1)[-1] in ("s", "c", "h", "ld", "inc"):
            taken |= set(re.findall(r'[A-Za-z_]\w*', open(p, "rb").read().decode("latin-1")))
    plan, why = {}, {}
    for p, lines in src.items():
        defs = {}
        for i, x in enumerate(lines):
            d = L.DEF.match(x)
            if d:
                defs[d.group(1)] = i
        back = {}
        for k, x in enumerate(lines):
            d = L.DEF.match(x)
            c = L.strip_comment(x[d.end():] if d else x).strip()
            if c and L.opcode(c) in ("jr", "jrl", "jp", "djnz"):
                t = re.findall(r'[.A-Za-z_][\w.]*', c)
                if t and t[-1] in defs and defs[t[-1]] < k:
                    back.setdefault(t[-1], []).append(k)
        for name, i in defs.items():
            m = re.match(r'^([A-Za-z_]\w*?)_Loop\d*$', name)
            if not m or name not in ours or name not in back:
                continue
            insns, prev = [], None
            for y in lines[i + 1:i + 40]:
                d = L.DEF.match(y)
                c = L.strip_comment(y[d.end():] if d else y).strip()
                if c and not c.startswith("."):
                    insns.append(c)
            for y in reversed(lines[:i]):
                d = L.DEF.match(y)
                c = L.strip_comment(y[d.end():] if d else y).strip()
                if c:
                    prev = c
                    break
            suf = L.tail_shape(insns)
            if suf:
                reason = "straight to ret"
            elif not L.reaches(lines, i, set(back[name]), defs):
                suf = "Skip" if prev and L.TRANSFER.match(prev) else "Join"
                reason = "back-branches not reachable from it"
            else:
                continue
            owner = m.group(1)
            new, num = "%s_%s" % (owner, suf), 1
            while new in taken:
                num += 1
                new = "%s_%s%d" % (owner, suf, num)
            taken.add(new)
            plan[name], why[name] = new, reason
    for o, n in plan.items():
        print("  %-52s -> %-52s (%s)" % (o, n, why[o]))
    print("%d _Loop labels are shared tails" % len(plan))
    if "--apply" not in sys.argv[1:] or not plan:
        return
    with open(SED_OUT, "w") as fh:
        fh.write("# written by scripts/renaming/fix_hdae5000_tail_loops.py --apply\n")
        fh.write("# run with: LC_ALL=C sed -i -f scripts/renaming/fix_hdae5000_tail_loops.sed hdae5000/*.s\n")
        for o, n in plan.items():
            fh.write("s/\\b%s\\b/%s/g\n" % (o, n))
    subprocess.run(["sed", "-i", "-f", SED_OUT] + files, check=True, env=dict(os.environ, LC_ALL="C"))
    print("wrote", os.path.relpath(SED_OUT, ROOT), "and applied it")


if __name__ == "__main__":
    main()
