#!/usr/bin/env python3
"""localize_internal_generic_labels.py -- generic labels that are only branch targets inside one named routine
become that routine's local labels.

QUESTION IT ANSWERS
  The conversion left thousands of labels named X_Block3, X_Entry2, X_Part1, X_Body ... (semantic_score.py calls
  them GENERIC).  Many are not routines at all: nothing calls them, no table or pointer names them, and every
  reference is a jump from the code around them.  They are branch targets of the routine they sit in, which this
  tree spells <Routine>_Skip / _Join / _Loop / _Return / _Epilogue (rename_orphan_locals.py's LOC suffixes; the
  score does not rate such local labels, because "an internal branch target is not a documentation debt").  This
  script finds them and gives them that spelling.

  A label L is localized only when ALL of these hold (tree = every *.s under <tree>/maincpu):
    - L is GENERIC by semantic_score.py's rule, not positional, not already a local label, and not a sound-parameter
      descriptor alias (gen_sndparam_desc_names_r2.py's ALIAS) or a name listed in an --exclude batch file;
    - its OWNER, the nearest label above it in the same file whose name is semantic (not generic, positional or
      local), exists;
    - L is referenced at least once, and EVERY reference anywhere in the tree is a branch (jr / jrl / jp / djnz)
      in the same file whose own nearest semantic label above is the same OWNER -- so nothing outside the owner's
      span reaches L, and no call, table, pointer load or .set names it;
    - the first statement at L is an instruction (not a directive or a data macro);
    - the name occurs nowhere else: not in the tree's *.c / *.h / *.ld, not in scripts/ (*.py, *.sh, *.mk), not in
      the repository's Makefile, and not in the documentation site's *.md (a quoted name would go stale).
  The new name is <OWNER>_<Suffix><N> with the first free N (none, then 2, 3 ...):
    Loop      every reference is below L (backward jumps only);
    Return    the first instruction at L is ret / retd / reti;
    Epilogue  L starts with pops / `lda xsp, (xsp+N)` and reaches a ret within four instructions;
    Skip      the statement above L is an unconditional transfer (jr/jrl/jp without a condition, ret, retd, reti),
              so L is reached only by its jumps;
    Join      otherwise (the code above falls through into L, and jumps join it there).
  Labels move no bytes, so `make gate-all` is the proof that nothing else changed.  Afterwards
  rename_orphan_locals.py --tree <tree> --apply re-parents L's own locals (L_Skip ...), whose prefix is now gone.

RUN (repository root)
  python3 scripts/renaming/localize_internal_generic_labels.py --tree v10 [--exclude batch.json ...]           # plan
  python3 scripts/renaming/localize_internal_generic_labels.py --tree v10 [--exclude batch.json ...] --apply  # rename,
      and append the rules to scripts/renaming/localize_internal_generic_<tree>.sed
"""
import collections
import datetime
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts/analysis"))
import semantic_score as S  # noqa: E402

DOCS = os.path.join(os.path.dirname(ROOT), "technics-docs")
ALIAS = re.compile(r'^(ExtPartParam|SeqMixParam|MidiChParam|VoiceCtrlR1|PartParam|VoiceParamEx)_Entry_\d+$')
DEF = re.compile(r'^([A-Za-z_][\w$]*):')
SETDEF = re.compile(r'^\s*\.(?:set|equ)\s+([A-Za-z_][\w$]*)\s*,')
BRANCH = {"jr", "jrl", "jp", "djnz"}
UNCOND = re.compile(r'^\s*(?:(?:jr|jrl|jp)\s+(?!(?:t|f|z|nz|c|nc|eq|ne|ult|uge|ule|ugt|lt|ge|le|gt|mi|pl|ov|nov|pe|po|v|nv|s|ns|m|p)\s*,)\S'
                    r'|reti\b|retd\b|ret\s*$)', re.I)


def kind(n):
    if S.CONTINUATION.search(n):
        return "local"
    if any(p.search(n) for p in S.POSITIONAL):
        return "positional"
    if S.GENERIC.search(n):
        return "generic"
    return "semantic"


def strip_comment(line):
    out, q = [], None
    for ch in line:
        if q:
            out.append(ch)
            if ch == q:
                q = None
            continue
        if ch in "\"'":
            q = ch
        elif ch == ";":
            break
        out.append(ch)
    return "".join(out)


def words_in(paths):
    w = set()
    for p in paths:
        try:
            w |= set(re.findall(r'[A-Za-z_]\w*', open(p, "rb").read().decode("latin-1")))
        except OSError:
            pass
    return w


def plan_tree(tree, exclude):
    files = sorted(glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True))
    src = {p: open(p, "rb").read().decode("latin-1").split("\n") for p in files}
    taken = set()
    owner_at = {}                      # (file, line) -> nearest semantic label at or above
    defs = {}                          # name -> (file, line, owner)
    refs = collections.defaultdict(list)
    for p, L in src.items():
        owner = None
        for i, x in enumerate(L):
            m = DEF.match(x)
            code = strip_comment(x)
            if m:
                n = m.group(1)
                taken.add(n)
                if kind(n) == "semantic":
                    owner = n
                else:
                    defs[n] = (p, i, owner)
                code = code[m.end():]
            sm = SETDEF.match(x)
            if sm:
                taken.add(sm.group(1))
            owner_at[(p, i)] = owner
            c = code.strip()
            if not c:
                continue
            op = re.split(r'[\s,]', c, maxsplit=1)[0].lower()
            for t in re.findall(r'[A-Za-z_]\w*', c)[1:] if not c.startswith(".") else re.findall(r'[A-Za-z_]\w*', c):
                refs[t].append((p, i, op))
    others = [q for ext in ("c", "h", "ld") for q in glob.glob(os.path.join(ROOT, tree, "**", "*." + ext), recursive=True)]
    others += [q for ext in ("py", "sh", "mk") for q in glob.glob(os.path.join(ROOT, "scripts", "**", "*." + ext), recursive=True)]
    others += [os.path.join(ROOT, "Makefile")]
    others += glob.glob(os.path.join(DOCS, "*.md")) + glob.glob(os.path.join(DOCS, "**", "*.md"), recursive=True)
    elsewhere = words_in(others)
    taken |= elsewhere

    plan, why = {}, collections.Counter()
    for n, (p, i, owner) in sorted(defs.items(), key=lambda x: (x[1][0], x[1][1])):
        if kind(n) != "generic" or ALIAS.match(n) or n in exclude:
            continue
        if not owner:
            why["no semantic label above it"] += 1
            continue
        rs = refs.get(n, [])
        if not rs:
            why["unreferenced"] += 1
            continue
        if any(op not in BRANCH for _, _, op in rs):
            why["called, tabled or loaded"] += 1
            continue
        if any(q != p or owner_at[(q, k)] != owner for q, k, _ in rs):
            why["branched to from outside its owner"] += 1
            continue
        if n in elsewhere:
            why["named in C/ld/scripts/docs"] += 1
            continue
        L = src[p]
        body, k = [], i
        first = strip_comment(L[i])[len(n) + 1:].strip()
        if first:
            body.append(first)
        k = i + 1
        while len(body) < 5 and k < len(L):
            t = strip_comment(L[k]).strip()
            if DEF.match(L[k]):
                t = strip_comment(L[k])[DEF.match(L[k]).end():].strip()
            if t:
                body.append(t)
            k += 1
        if not body or body[0].startswith(".") or re.split(r'[\s,]', body[0])[0] in ("aligned_string",):
            why["first statement is not an instruction"] += 1
            continue
        prev = None
        k = i - 1
        while k >= 0:
            t = strip_comment(L[k])
            if DEF.match(L[k]):
                t = t[DEF.match(L[k]).end():]
            t = t.strip()
            if t:
                prev = t
                break
            k -= 1
        op0 = re.split(r'[\s,]', body[0])[0].lower()
        if all(k2 > i for _, k2, _ in rs):
            suf = "Loop"
        elif op0 in ("ret", "retd", "reti"):
            suf = "Return"
        elif op0 in ("pop", "popw", "lda") and any(re.match(r'^ret[di]?\b', b) for b in body[1:5]) and all(
                re.split(r'[\s,]', b)[0].lower() in ("pop", "popw", "lda", "ret", "retd", "reti") for b in body[:5]
                if not re.match(r'^ret', b)):
            suf = "Epilogue"
        elif prev and UNCOND.match(prev):
            suf = "Skip"
        else:
            suf = "Join"
        new, num = "%s_%s" % (owner, suf), 1
        while new in taken:
            num += 1
            new = "%s_%s%d" % (owner, suf, num)
        taken.add(new)
        plan[n] = new
        why["localized as _" + suf] += 1
    return plan, why, src


def main():
    a = sys.argv[1:]
    tree = a[a.index("--tree") + 1]
    exclude = set()
    for k, x in enumerate(a):
        if x == "--exclude":
            for r in json.load(open(a[k + 1])):
                exclude.add(r.get("name") or r.get("old"))
    plan, why, src = plan_tree(tree, exclude)
    print("%s: %d generic labels localized" % (tree, len(plan)))
    for k, v in sorted(why.items()):
        print("   %-40s %d" % (k, v))
    for o, n in list(plan.items())[:12]:
        print("   ", o, "->", n)
    if "--apply" not in a or not plan:
        return
    rx = re.compile(r'\b(%s)\b' % "|".join(sorted(map(re.escape, plan), key=len, reverse=True)))
    for p, L in src.items():
        t = "\n".join(L)
        t2 = rx.sub(lambda m: plan[m.group(1)], t)
        if t2 != t:
            data = t2.encode("latin-1")
            with open(p + ".tmp", "wb") as fh:
                fh.write(data)
            os.replace(p + ".tmp", p)
    sedp = os.path.join(ROOT, "scripts/renaming/localize_internal_generic_%s.sed" % tree)
    fresh = not os.path.exists(sedp)
    with open(sedp, "a") as fh:
        if fresh:
            fh.write("# written by scripts/renaming/localize_internal_generic_labels.py\n")
        fh.write("# run %s\n" % datetime.date.today().isoformat())
        fh.writelines("s/\\b%s\\b/%s/g\n" % (o, n) for o, n in plan.items())
    print("wrote", os.path.relpath(sedp, ROOT))


if __name__ == "__main__":
    main()
