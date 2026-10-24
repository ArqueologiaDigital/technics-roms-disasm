#!/usr/bin/env python3
r"""localize_hdae5000_address_locals.py -- give the HD-AE5000's address-named local labels (.LRF_0424,
.LFS_720d, .LUIH_babf ...) names derived from the routine they sit in and the shape of the branches that
reach them.

QUESTION IT ANSWERS
  hdae5000/*.s held 1,165 assembler-local labels named only by their address: the conversion turned every
  branch target into .L<file-or-routine prefix>_<low address digits>.  Such a name says neither which routine
  the label belongs to nor why the code branches there, and .L names never reach the ELF, so a debugger or
  the symbol file shows nothing at those addresses.  This script names each one
  <OWNER>_<Suffix>[N], OWNER being the nearest non-.L label above both the label and every branch to it, in
  the same file (every such label is already a semantic name; a tail shared by the arms of a switch thus takes
  the routine's name, not the name of the last arm above it; when the branches come from several arms named
  <Routine>_<Arm>, OWNER is <Routine> itself), using the vocabulary the KN5000 maincpu trees use for
  routine-internal labels (semantic_score.py's CONTINUATION set, which the score does not rate):

    alias     the label sits at the same address as the label just above it (no instruction between):
              its branches are redirected to that label and the definition is dropped (one name per address,
              cross-version policy 5);
    Loop      a back-edge target: at least one branch to it lies below it -- unless straight-line code
              from it reaches a ret within six instructions (a shared tail; named as below; corrected after
              the first run by fix_hdae5000_tail_loops.py);
    Return    the first instruction at the label is ret / retd / reti;
    Epilogue  the label starts with stack releases (pop / popw / lda xsp,(xsp+N) / inc N,xsp) that reach a ret;
    Done      straight-line code (no branch, call or store to memory) reaches a ret within six instructions:
              the routine sets its result and leaves;
    Next      reached only from above, and the code from it runs (with no other label or unconditional
              transfer in between) into a branch back above it: the loop's step / test, where `continue` goes;
    Skip      the statement above it is an unconditional transfer, so only its branches reach it;
    Join      otherwise: the code above falls into it and branches join it there.
  Two better names, where the code spells the purpose out:
    On<Event> a label reached only by its branches (the statement above is an unconditional transfer), every
              one of which is `jr/jrl/jp z, L` right after `cp <reg>, EVT_<NAME>` for the same event: it is
              the proc's arm for that event (EVT_GET_STR_PTR -> <OWNER>_OnGetStrPtr);
    Lang<LL>  in the language-text procs, a label whose first instruction is `cpw (xsp+4), N` followed by
              the push of HDAE5000_LangMsg_<id>_<LL> is that message's <LL>-language arm
              (HDAE5000_AcLanguageText1Proc_Msg014_LangDE).
  These two are ordinary names to semantic_score.py (rated, as semantic); they are as specific as the code.
  N is the first free number (none, then 2, 3 ...), counted in address order per OWNER+suffix.

  Labels move no bytes: `make -j3 gate` (byte-identical images) is the proof that nothing else changed.

RECORD AND PLAN (2026-10-24, reviewer finding)
  scripts/renaming/localize_hdae5000_address_locals.sed is the record of the FIRST run (commit fc17ceffe) and
  is not rewritten.  Five of its _Loop names were shared tails, corrected afterwards by
  fix_hdae5000_tail_loops.sed, and two families were then put back in address order by
  renumber_hdae5000_tail_fix.sed.  This script now applies both tail rules itself (tail_shape, and reaches()
  for a label whose backward branches cannot be reached from it), so run on the pre-rename tree
  (`git archive fc17ceffe~1 hdae5000`) its --list prints the CORRECTED plan, which equals
  localize_hdae5000_address_locals.sed, then fix_hdae5000_tail_loops.sed, then renumber_hdae5000_tail_fix.sed,
  for all 1,165 labels -- not the first-run .sed by itself.  Checked 2026-10-24 with ($T a scratch directory):
      git archive fc17ceffe~1 hdae5000 | tar -x -C $T; mkdir -p $T/scripts/renaming
      cp scripts/renaming/localize_hdae5000_address_locals.py $T/scripts/renaming/
      (cd $T && python3 scripts/renaming/localize_hdae5000_address_locals.py --list) \
        | sed -nE 's/^\s+(\.L\S+)\s+->\s+(\S+).*/\1 \2/p' | sort > $T/plan.txt
      grep '^s/' scripts/renaming/localize_hdae5000_address_locals.sed \
        | sed -E 's#^s/(.*)\\b/(.*)/g$#\1 \2#; s#\\\.#.#' > $T/first.txt
      cut -d' ' -f2 $T/first.txt | LC_ALL=C sed -f scripts/renaming/fix_hdae5000_tail_loops.sed \
        | LC_ALL=C sed -f scripts/renaming/renumber_hdae5000_tail_fix.sed > $T/final.txt
      paste -d' ' <(cut -d' ' -f1 $T/first.txt) $T/final.txt | sort | diff - $T/plan.txt   # no output

RUN (repository root)
  python3 scripts/renaming/localize_hdae5000_address_locals.py            # plan: counts and a sample
  python3 scripts/renaming/localize_hdae5000_address_locals.py --list     # plan: every old -> new
  python3 scripts/renaming/localize_hdae5000_address_locals.py --apply    # write
      scripts/renaming/localize_hdae5000_address_locals.sed, then run it with `LC_ALL=C sed -i -f` on
      hdae5000/*.s (the sed script is the record of the rename; the .s files are byte data, so sed runs
      in the C locale)
"""
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREE = os.path.join(ROOT, "hdae5000")
SED = os.path.join(ROOT, "scripts/renaming/localize_hdae5000_address_locals.sed")
ADDR = re.compile(r'^\.L[A-Za-z]+_[0-9a-fA-F]+$')
DEF = re.compile(r'^([.A-Za-z_][\w$.]*):')
SETDEF = re.compile(r'^\s*\.(?:set|equ)\s+([A-Za-z_][\w$]*)\s*,')
COND = r'(?:t|f|z|nz|c|nc|eq|ne|ult|uge|ule|ugt|lt|ge|le|gt|mi|pl|ov|nov|pe|po|v|nv|s|ns|m|p)'
BRANCH = {"jr", "jrl", "jp", "djnz", "calr", "call"}
TRANSFER = re.compile(r'^(?:jr|jrl|jp)\s+(?:t\s*,\s*)?(?!' + COND + r'\s*,)\S|^(?:jr|jrl|jp)\s+t\s*,|^(?:ret|reti)\s*$|^retd\s',
                      re.I)
RET = re.compile(r'^(?:ret|reti)\s*$|^retd\s', re.I)        # unconditional only: `ret z` falls through
RELEASE = re.compile(r'^(?:popw?\s|lda\s+xsp\s*,\s*\(\s*xsp\s*\+|inc\s+\d+\s*,\s*xsp\b|add\s+xsp\s*,)', re.I)
LANG = re.compile(r'^cpw\s+\(xsp\s*\+\s*4\)\s*,\s*0x[0-9a-f]+$', re.I)
LANGMSG = re.compile(r'HDAE5000_LangMsg_\w+?_([A-Z]{2})@hi16')
EVTCMP = re.compile(r'^cp\s+x?[a-z]+\s*,\s*EVT_(\w+)$', re.I)


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


def opcode(stmt):
    return re.split(r'[\s,]', stmt, maxsplit=1)[0].lower()


def parse():
    files = sorted(glob.glob(os.path.join(TREE, "*.s")))
    src = {p: open(p, "rb").read().decode("latin-1").split("\n") for p in files}
    taken = set()
    for p in glob.glob(os.path.join(TREE, "**", "*.*"), recursive=True):
        if os.path.isfile(p) and p.rsplit(".", 1)[-1] in ("s", "c", "h", "ld", "inc"):
            taken |= set(re.findall(r'[A-Za-z_]\w*', open(p, "rb").read().decode("latin-1")))
    # stmts[p] = [(line, 'label', name) | (line, 'insn', text)] in file order
    stmts, defs, refs = {}, {}, collections.defaultdict(list)
    for p, L in src.items():
        owner, out = None, []
        for i, x in enumerate(L):
            c = strip_comment(x)
            m = DEF.match(x)
            if m:
                n = m.group(1)
                out.append((i, "label", n))
                if n.startswith(".L"):
                    defs[n] = (p, i, owner)
                else:
                    owner = n
                c = c[m.end():]
            c = c.strip()
            if not c:
                continue
            out.append((i, "insn", c))
            if not c.startswith("."):
                for t in re.findall(r'\.L[A-Za-z]+_\w+', c):
                    refs[t].append((p, i, opcode(c)))
            elif SETDEF.match(c):
                pass
        stmts[p] = out
    return src, stmts, defs, refs, taken


def reaches(lines, start, goals, defs_in_file):
    """True when a goal line is reachable from line `start` by falling through and by branching FORWARD
    to labels inside [start, max(goals)] -- the test for whether a backward branch closes a loop through
    the label at `start` (a shared tail reached only from code after an unconditional exit is no loop)."""
    hi = max(goals)
    seen, todo = set(), [start]
    while todo:
        k = todo.pop()
        while start <= k <= hi and k not in seen:
            seen.add(k)
            if k in goals:
                return True
            d = DEF.match(lines[k])
            c = strip_comment(lines[k][d.end():] if d else lines[k]).strip()
            if c and opcode(c) in ("jr", "jrl", "jp", "djnz"):
                t = re.findall(r'[.A-Za-z_][\w.]*', c)
                if t and t[-1] in defs_in_file and start <= defs_in_file[t[-1]] <= hi:
                    todo.append(defs_in_file[t[-1]])
            if c and TRANSFER.match(c):
                break
            k += 1
    return False


def tail_shape(insns):
    """Return / Epilogue / Done when straight-line code (stores allowed; no branch or call) reaches an
    unconditional ret within six instructions, else None (fix_hdae5000_tail_loops.py uses it too)."""
    if not insns:
        return None
    if RET.match(insns[0]):
        return "Return"
    if RELEASE.match(insns[0]):
        for t in insns[:6]:
            if RET.match(t):
                return "Epilogue"
            if not RELEASE.match(t):
                break
    for t in insns[:6]:
        if RET.match(t):
            return "Done"
        op = opcode(t)
        if op in BRANCH or op.startswith("ret") or op in ("djnz", "swi", "halt"):
            return None
    return None


def classify(n, p, i, stmts, refs, defs, src=None):
    S = stmts[p]
    k = next(j for j, s in enumerate(S) if s[0] == i and s[1] == "label" and s[2] == n)
    prev = S[k - 1] if k > 0 else None
    if prev and prev[1] == "label":
        return "alias", prev[2]
    rs = refs.get(n, [])
    after = [s for s in S[k + 1:k + 40]]
    insns = [s[2] for s in after if s[1] == "insn"]
    first = insns[0] if insns else ""
    if LANG.match(first):
        for t in insns[1:4]:
            m = LANGMSG.search(t)
            if m:
                return "Lang" + m.group(1), None
    back = [j for q, j, _ in rs if q == p and j > i]
    if back:
        # a backward branch to a block that runs straight into a ret is a shared tail, not a loop
        shape = tail_shape(insns)
        if shape:
            return shape, None
        # nor is one whose backward branches cannot be reached from it (fix_hdae5000_tail_loops.py rule b)
        if src is not None:
            lines = src[p]
            here = {m.group(1): k for k, x in enumerate(lines) for m in [DEF.match(x)] if m}
            if not reaches(lines, i, set(back), here):
                return ("Skip" if prev and prev[1] == "insn" and TRANSFER.match(prev[2]) else "Join"), None
        return "Loop", None
    if prev and prev[1] == "insn" and TRANSFER.match(prev[2]) and rs:
        evts = set()
        for q, j, _ in rs:
            kq = next(x for x, s in enumerate(stmts[q]) if s[0] == j and s[1] == "insn")
            br, before = stmts[q][kq][2], stmts[q][kq - 1]
            m = EVTCMP.match(before[2]) if before[1] == "insn" else None
            if not (re.match(r'^(?:jr|jrl|jp)\s+(?:z|eq)\s*,', br, re.I) and m):
                evts = None
                break
            evts.add(m.group(1))
        if evts and len(evts) == 1:
            return "On" + "".join(w.capitalize() for w in evts.pop().split("_")), None
    if RET.match(first):
        return "Return", None
    if RELEASE.match(first):
        for t in insns[:6]:
            if RET.match(t):
                return "Epilogue", None
            if not RELEASE.match(t):
                break
    for t in insns[:6]:
        if RET.match(t):
            return "Done", None
        op = opcode(t)
        if op in BRANCH or op.startswith("ret") or op in ("djnz", "swi", "halt") or re.match(r'^ld\w*\s+\(', t):
            break
    # Next: straight run from L into a branch back above L
    for s in after:
        if s[1] == "label":
            break
        t = s[2]
        op = opcode(t)
        if op in ("jr", "jrl", "jp", "djnz"):
            tgt = re.findall(r'(\.L[A-Za-z]+_\w+|[A-Za-z_]\w*)\s*$', t)
            back = tgt and tgt[0] in defs and defs[tgt[0]][0] == p and defs[tgt[0]][1] < i
            if back and not TRANSFER.match(t):      # a conditional back-edge (or djnz): the loop's test
                return "Next", None
            if TRANSFER.match(t):
                break
        elif RET.match(t):
            break
    if prev and prev[1] == "insn" and TRANSFER.match(prev[2]):
        return "Skip", None
    return "Join", None


def plan():
    src, stmts, defs, refs, taken = parse()
    targets = sorted((d for n, d in defs.items() if ADDR.match(n)), key=lambda d: (d[0], d[1]))
    names = {(p, i): n for n, (p, i, _) in defs.items()}
    rename, alias_of, why = {}, {}, collections.Counter()
    globs = {q: [(s[0], s[2]) for s in S if s[1] == "label" and not s[2].startswith(".L")] for q, S in stmts.items()}
    for p, i, owner in targets:
        n = names[(p, i)]
        # a target shared by several sub-entries (switch arms, case labels) belongs to the label above ALL of
        # its branches, not to the arm it happens to follow
        top = min([i] + [j for q, j, _ in refs.get(n, []) if q == p])
        above = [g for ln, g in globs[p] if ln <= top]
        owner = above[-1]
        involved = {[g for ln, g in globs[p] if ln <= j][-1] for j in [i] + [j for q, j, _ in refs.get(n, [])]}
        if len(involved) > 1:
            # arms named <Routine>_<Arm> (HDAE5000_AcLanguageText1Proc_Msg001 ...): prefer the routine itself
            fam = [g for g in reversed(above) if all(o == g or o.startswith(g + "_") for o in involved)]
            if fam:
                owner = fam[0]
        suf, other = classify(n, p, i, stmts, refs, defs, src)
        if suf == "alias":
            alias_of[n] = other
            why["alias of the label above (definition dropped)"] += 1
            continue
        new, num = "%s_%s" % (owner, suf), 1
        while new in taken:
            num += 1
            new = "%s_%s%d" % (owner, suf, num)
        taken.add(new)
        rename[n] = new
        why["_Lang<LL>" if suf.startswith("Lang") else "_On<Event>" if suf.startswith("On") else "_" + suf] += 1

    def final(n):
        seen = set()
        while n in alias_of and n not in seen:
            seen.add(n)
            n = alias_of[n]
        return rename.get(n, n)
    for n in alias_of:
        rename[n] = final(n)
    return rename, alias_of, why, defs


def main():
    a = sys.argv[1:]
    rename, alias_of, why, defs = plan()
    print("hdae5000: %d address-named local labels" % len(rename))
    for k, v in sorted(why.items()):
        print("   %-48s %d" % (k, v))
    items = sorted(rename.items(), key=lambda kv: (defs[kv[0]][0], defs[kv[0]][1]))
    for o, n in (items if "--list" in a else items[:15]):
        print("   %-14s -> %s%s" % (o, n, "   (alias)" if o in alias_of else ""))
    if "--apply" not in a or not rename:
        return
    with open(SED, "w") as fh:
        fh.write("# written by scripts/renaming/localize_hdae5000_address_locals.py --apply\n")
        fh.write("# run with: LC_ALL=C sed -i -f scripts/renaming/localize_hdae5000_address_locals.sed hdae5000/*.s\n")
        for o in sorted(alias_of, key=lambda o: (defs[o][0], defs[o][1])):
            fh.write("/^%s:/d\n" % re.escape(o).replace("\\_", "_"))
        for o, n in items:
            fh.write("s/%s\\b/%s/g\n" % (o.replace(".", "\\."), n))
    print("wrote", os.path.relpath(SED, ROOT))
    files = sorted(glob.glob(os.path.join(TREE, "*.s")))
    subprocess.run(["sed", "-i", "-f", SED] + files, check=True, env=dict(os.environ, LC_ALL="C"))
    print("applied to %d files" % len(files))


if __name__ == "__main__":
    main()
