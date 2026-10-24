#!/usr/bin/env python3
"""prologue_census.py -- which labelled call entries sit right after an unlabelled
register-save prologue?

QUESTION IT ANSWERS
  On the MN10300 `call T, [regs], N` saves the registers and opens the frame itself,
  so a function that is also reached through `calls` (a pointer) begins with its own
  `movm [regs], (sp)` and/or `add -N, sp`, and the direct-call entry T lies right
  after that prologue.  The convention in src/program.s is: the function's label
  (X / func_<ADDR>) on the prologue, and X_entry on the call entry.  This counts,
  in the generated source, every label whose code is preceded by such a prologue
  (the prologue itself following a ret/jmp/bra/rets/rti/retf or 0xFF padding, so
  it is not reachable by falling through), split by whether the prologue carries
  a label of its own and by what kind of name the entry has, and whether a block
  header (`# Name  (CPU ...)`) sits between the prologue and its entry -- the
  layout that makes a prologue read as dead code after the previous `ret`.

  It also checks the frames: for each prologue + entry, every direct
  `call Entry, [regs], N` in the source must save the same register list as
  the prologue's movm and open the same frame, N = 4 * len(regs) + M for
  `add -M, sp` (a movm list holding `other` is reported apart: it saves more
  than one word for that item).  A match is the evidence that the prologue
  and the entry are one function.

RUN (from kn7000/)
  python3 notes/convert-probes/prologue_census.py [src/program/*.s ...]
"""
import glob
import re
import sys

UNCOND = re.compile(r"\s+(ret|retf|rets|rti|jmp|bra)\b|\s+\.space\s")
PRO = re.compile(r"\s+(movm\s+\[[^\]]*\],\s*\(sp\)|add\s+-0x[0-9a-f]+,\s*sp|add\s+-\d+,\s*sp)\s*(#.*)?$")
LABEL = re.compile(r"([A-Za-z_]\w*):\s*$")


CALL = re.compile(r"\s+call\s+([A-Za-z_]\w*)(?::32)?,\s*(\[[^\]]*\]|0),\s*(0x[0-9a-f]+|\d+)\s*(#.*)?$")
HEADER = re.compile(r"# \S+  \((?:lib )?CPU 0x")


def regs(text):
    return [] if text == "0" else [r.strip() for r in text.strip("[]").split(",") if r.strip()]


def census(paths):
    stats = {}
    examples = {}
    frames = {}                       # entry -> (movm regs, add M)
    calls = {}                        # entry -> [(regs, N)]
    for path in paths:
        lines = open(path, encoding="latin-1").read().split("\n")
        # (kind, text) items with blank/comment lines dropped; a block header
        # is kept as a "header" item
        items = []
        for ln in lines:
            m = CALL.match(ln)
            if m:
                calls.setdefault(m.group(1), []).append((regs(m.group(2)), int(m.group(3), 0)))
            if HEADER.match(ln):
                items.append(("header", ln))
                continue
            if not ln.strip() or ln.lstrip().startswith("#"):
                continue
            m = LABEL.match(ln)
            items.append(("label", m.group(1)) if m else ("insn", ln))
        for i, (k, t) in enumerate(items):
            if k != "label":
                continue
            # walk back over prologue instructions, then labels
            j = i - 1
            split = False             # a block header between prologue and entry
            if j >= 0 and items[j][0] == "header":
                split, j = True, j - 1
            npro, pro = 0, []
            while j >= 0 and items[j][0] == "insn" and PRO.match(items[j][1]) and npro < 2:
                pro.insert(0, items[j][1].split())
                npro += 1
                j -= 1
            if not npro:
                continue
            pro_label = None
            if j >= 0 and items[j][0] == "label":
                pro_label = items[j][1]
                j -= 1
                while j >= 0 and items[j][0] == "label":
                    j -= 1
            if j >= 0 and items[j][0] == "header":
                j -= 1
            if j >= 0 and not (items[j][0] == "insn" and UNCOND.match(items[j][1])):
                continue
            mv = next((" ".join(x[1:]) for x in pro if x[0] == "movm"), None)
            ad = next((int(x[1].rstrip(","), 0) for x in pro if x[0] == "add"), 0)
            frames[t] = (regs(mv.split("],")[0] + "]") if mv else [], -ad)
            kind = ("_entry" if t.endswith("_entry") else "func_" if t.startswith("func_")
                    else "loc_" if t.startswith("loc_") else "named")
            key = ("labelled" if pro_label else "UNLABELLED", kind,
                   "header BETWEEN" if split else "header before")
            stats[key] = stats.get(key, 0) + 1
            examples.setdefault(key, []).append(f"{path}: {pro_label or '-'} / {t}")
    fr = {"match": 0, "MISMATCH": 0, "other": 0, "no direct call": 0}
    bad = []
    for t, (rl, m) in frames.items():
        if any(r.startswith("other") for r in rl):
            fr["other"] += 1
        elif t not in calls:
            fr["no direct call"] += 1
        elif all(cr == rl and n == 4 * len(rl) + m for cr, n in calls[t]):
            fr["match"] += 1
        else:
            fr["MISMATCH"] += 1
            bad.append(f"{t}: prologue {rl} + {m:#x}, calls {sorted(set((tuple(c), n) for c, n in calls[t]))}")
    return stats, examples, fr, bad


def main():
    paths = sys.argv[1:] or sorted(glob.glob("src/program/*.s"))
    stats, ex, fr, bad = census(paths)
    print("prologue (movm and/or add -N,sp after a non-falling-through insn) before a label")
    for key in sorted(stats):
        print(f"  prologue {key[0]:10s}  entry {key[1]:7s}  {key[2]:14s}  {stats[key]:6d}   e.g. {ex[key][0]}")
    print(f"  total {sum(stats.values())}")
    print("frames (direct calls to the entry vs the prologue): "
          + ", ".join(f"{k} {v}" for k, v in fr.items()))
    for b in bad:
        print(f"  mismatch {b}")


if __name__ == "__main__":
    main()
