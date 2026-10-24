#!/usr/bin/env python3
"""fix_hdae5000_dead_owners.py -- give the HD-AE5000's unreferenced library routines entry labels, and rename
the local labels inside them that carry another routine's name.

QUESTION IT ANSWERS
  The unreachable browser / name-history library in hdae5000_ui_display.s (see the section comment above
  HDAE5000_NameList5_Contains, and scripts/analysis/hdae5000_reachability.py) was left with its routine
  ENTRIES unlabelled; only the labels inside a routine got names, HDAE5000_DeadLib_<Routine>_<Shape>
  (rename_hdae5000_fat.sed).  So HDAE5000_DeadLib_FindFreeSlot32_Loop existed, HDAE5000_DeadLib_FindFreeSlot32
  did not, and the routine's .L locals, named by an earlier pass after the nearest label above the routine,
  read `.LHD_CheckVersionKey_Skip2` inside what is really DeadLib_FindFreeSlot32 (reviewer finding,
  2026-10-24).

  Step 1 (labels).  For every HDAE5000_DeadLib_<R> that is only implied -- a label <R>_<suffix> exists, <R>
  does not -- the entry is found by walking up from the first <R>_ label (through .L labels) to the nearest
  unconditional ret / jp that is followed by an instruction with no label in between: nothing can fall or
  branch into that instruction, so it is the entry; `HDAE5000_DeadLib_<R>:` is inserted there.  A routine whose
  entry cannot be found that way is reported and left alone.  Extra entries, written out in EXTRA: the
  decrement twin after HDAE5000_DirBrowser_IncRowByte (HDAE5000_DirBrowser_DecRowByte).

  Step 2 (owners).  Each remaining semantic .L local `.L<Stem>_<Suffix>` whose <Stem> names a routine that is
  not its owner is renamed `.L<Owner>_<Suffix>[N]`, the suffix re-derived from the branch shape by
  localize_hdae5000_address_locals.classify (Loop / Skip / Join / Done / Return / Next / Epilogue ...).  The
  owner is found the way localize_hdae5000_address_locals.py finds it: the nearest non-.L label above the
  label and all its branches, reduced to its routine -- a label <B>_<tail> with <B> a label defined earlier
  in the same file belongs to <B> (HDAE5000_DeadLib_RememberEntryName_Copy -> HDAE5000_DeadLib_RememberEntryName).
  The renames are written to scripts/renaming/fix_hdae5000_dead_owners.sed (the record; policy) and run with
  `LC_ALL=C sed -i -f` on hdae5000/*.s.

  Labels move no bytes: make -j3 gate (byte-identical images) is the proof.  New entry labels are ELF
  symbols, so symbols/hdae5000_symbols_reference.txt is regenerated afterwards
  (python3 scripts/analysis/l2_symbol_reference.py --regen).

RUN (repository root)
  python3 scripts/renaming/fix_hdae5000_dead_owners.py            # plan only
  python3 scripts/renaming/fix_hdae5000_dead_owners.py --apply    # step 1, then step 2
"""
import glob
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import localize_hdae5000_address_locals as L  # noqa: E402

ROOT = L.ROOT
TREE = L.TREE
SED = os.path.join(ROOT, "scripts/renaming/fix_hdae5000_dead_owners.sed")
DEF = re.compile(r'^([.A-Za-z_][\w$.]*):')
UNCOND = re.compile(r'^(?:ret|reti)\s*$|^retd\s|^(?:jp|jr|jrl)\s+(?:t\s*,\s*)?(?!(?:' + L.COND[3:-1] + r')\s*,)\S', re.I)
# label just above the entry -> name of the entry that follows it after its ret
EXTRA = {"HDAE5000_DirBrowser_IncRowByte": "HDAE5000_DirBrowser_DecRowByte"}


def load():
    files = sorted(glob.glob(os.path.join(TREE, "*.s")))
    return {p: open(p, "rb").read().decode("latin-1").split("\n") for p in files}


def labels_of(src):
    out = {}
    for p, lines in src.items():
        for i, x in enumerate(lines):
            m = DEF.match(x)
            if m:
                out[m.group(1)] = (p, i)
    return out


def code_of(x):
    m = DEF.match(x)
    return L.strip_comment(x[m.end():] if m else x).strip()


def entry_after(lines, k):
    """line of the first instruction after line k's code ends with an unconditional transfer, else None"""
    for j in range(k, len(lines)):
        c = code_of(lines[j])
        if DEF.match(lines[j]) and j > k:
            return None
        if c and not c.startswith("."):
            if UNCOND.match(c):
                for e in range(j + 1, len(lines)):
                    if DEF.match(lines[e]):
                        return None
                    ce = code_of(lines[e])
                    if ce:
                        return None if ce.startswith(".") else e
                return None
    return None


def find_entry(lines, first):
    """walk up from the first <R>_ label (through .L labels, which are inside the routine) to the first
    unconditional transfer that is followed by an instruction with no label in between: that instruction is
    only reachable as an entry.  A non-.L label on the way means the routine already starts there: None."""
    j = first - 1
    while j >= 0:
        m = DEF.match(lines[j])
        if m and not m.group(1).startswith(".L"):
            return None
        c = code_of(lines[j])
        if c and not c.startswith(".") and UNCOND.match(c):
            e = j + 1
            while e < first and not code_of(lines[e]) and not DEF.match(lines[e]):
                e += 1
            if not DEF.match(lines[e]):
                return e
        j -= 1
    return None


def step1(src, apply):
    labs = labels_of(src)
    implied = {}
    for n, (p, i) in labs.items():
        m = re.match(r'^(HDAE5000_DeadLib_[A-Za-z0-9]+)_\w+$', n)
        if m and m.group(1) not in labs:
            b = m.group(1)
            if b not in implied or (p, i) < implied[b]:
                implied[b] = (p, i)
    inserts, missing = [], []
    for b, (p, i) in sorted(implied.items(), key=lambda kv: kv[1]):
        e = find_entry(src[p], i)
        (inserts if e is not None else missing).append((p, e if e is not None else i, b))
    for anchor, name in EXTRA.items():
        if name in labs:
            continue
        p, i = labs[anchor]
        e = entry_after(src[p], i)
        (inserts if e is not None else missing).append((p, e if e is not None else i, name))
    for p, e, b in inserts:
        print("  entry  %-45s %s:%d  %s" % (b, os.path.basename(p), e + 1, src[p][e].strip()))
    for p, i, b in missing:
        print("  NO ENTRY FOUND for %s (first label at %s:%d)" % (b, os.path.basename(p), i + 1))
    print("step 1: %d entry labels%s, %d not found" % (len(inserts), "" if apply else " (plan)", len(missing)))
    if apply:
        for p in {q for q, _, _ in inserts}:
            lines = src[p]
            for _, e, b in sorted([t for t in inserts if t[0] == p], key=lambda t: -t[1]):
                lines.insert(e, b + ":")
            with open(p + ".tmp", "wb") as fh:
                fh.write("\n".join(lines).encode("latin-1"))
            os.replace(p + ".tmp", p)
    return len(inserts)


def step2(apply):
    src, stmts, defs, refs, taken = L.parse()
    glob_labels = {}
    for p, S in stmts.items():
        seen = set()
        out = []
        for s in S:
            if s[1] == "label" and not s[2].startswith(".L"):
                out.append((s[0], s[2], frozenset(seen)))
                seen.add(s[2])
        glob_labels[p] = out
    allg = {g for v in glob_labels.values() for _, g, _ in v}

    def routine(g, earlier):
        while True:
            parts = g.split("_")
            for k in range(len(parts) - 1, 0, -1):
                b = "_".join(parts[:k])
                if b in earlier:
                    g = b
                    break
            else:
                return g

    def short(g):
        return g[9:] if g.startswith("HDAE5000_") else g

    shorts = {}
    for g in allg:
        shorts.setdefault(short(g), g)
    rename = {}
    for n, (p, i, _) in sorted(defs.items(), key=lambda kv: (kv[1][0], kv[1][1])):
        if L.ADDR.match(n):
            continue
        parts = n[2:].split("_")
        stem = None
        for k in range(len(parts) - 1, 0, -1):
            if "_".join(parts[:k]) in shorts:
                stem = shorts["_".join(parts[:k])]
                break
        if stem is None:
            continue
        top = min([i] + [j for q, j, _ in refs.get(n, []) if q == p])
        above = [(g, e) for ln, g, e in glob_labels[p] if ln <= top]
        if not above:
            continue
        owner = routine(*above[-1])
        stem_entry = [(g, e) for ln, g, e in glob_labels[p] if g == stem]
        stem_r = routine(*stem_entry[0]) if stem_entry else stem
        if stem_r == owner:
            continue
        suf, _ = L.classify(n, p, i, stmts, refs, defs)
        if suf == "alias":
            continue
        base = ".L%s_%s" % (short(owner), suf)
        new, num = base, 1
        while new in taken or new in defs:
            num += 1
            new = "%s%d" % (base, num)
        taken.add(new)
        rename[n] = new
        print("  %-48s -> %s" % (n, new))
    print("step 2: %d locals renamed to their owner%s" % (len(rename), "" if apply else " (plan)"))
    if apply and rename:
        with open(SED, "w") as fh:
            fh.write("# written by scripts/renaming/fix_hdae5000_dead_owners.py --apply (step 2)\n")
            fh.write("# run with: LC_ALL=C sed -i -f scripts/renaming/fix_hdae5000_dead_owners.sed hdae5000/*.s\n")
            for o, nn in sorted(rename.items(), key=lambda kv: -len(kv[0])):
                fh.write("s/%s\\b/%s/g\n" % (o.replace(".", "\\."), nn))
        files = sorted(glob.glob(os.path.join(TREE, "*.s")))
        subprocess.run(["sed", "-i", "-f", SED] + files, check=True, env=dict(os.environ, LC_ALL="C"))
        print("wrote and applied", os.path.relpath(SED, ROOT))


def main():
    apply = "--apply" in sys.argv[1:]
    step1(load(), apply)
    if apply:
        step2(True)
    else:
        print("(step 2 is planned after step 1 is applied; run with --apply)")


if __name__ == "__main__":
    main()
