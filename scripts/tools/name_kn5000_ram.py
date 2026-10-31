#!/usr/bin/env python3
"""name_kn5000_ram.py -- KN5000 main-CPU RAM variables the tree already names (.equ) take their names in the code.

QUESTION THIS ANSWERS / JOB IT DOES
  The maincpu trees define RAM variables -- CPANEL_RX_READ_PTR, ENCODER_0_STATUS, MIDI_CC_MODWHEEL_VALUE,
  SYSTEM_TIMESTAMP ... (cpanel_constants.s, midi_encoder_constants.s, the program file; documented in
  technics-docs memory-map.md) -- but the code spells them by number: `ld (0x8d8c:16), a`.  This rewrites
  the numeric memory operands `(N)` / `(N:8|16|24)`, a pointer loaded into an index register
  (`ld xix, 0x8da1`), both operands of the memory-to-memory pseudos (`ldmm8 0x8d39, 0x8d38`), and a
  DRAM address (>= 0x10000) loaded into, added to or subtracted from a 32-bit register (`ld xbc,
  0x43c00`, `add xde, 0x69400`) as the name.  Not: RegObjTabl slot numbers, .incbin offsets, an
  immediate stored to memory -- equal values there are coincidences.

  v7 is NOT v10: its UI / panel variables sit elsewhere (v10's `(0x8ee0)` is v7's `(0x8e44)` in
  MidiChannel_ResetAndConfigure), yet v7's constants files carry v10's values -- harmless only because
  v7 code never used them.  So for v9 and v7 the address of each name is DERIVED: every v10 code line
  that uses the name's address is matched to the same routine (same label) in the other tree, whose
  body must have the same number of instructions with the same shape once numbers are blanked; the
  number in the matching position is a vote.  Positions are paired operand by operand, names included
  (addr_tokens): memory operands, pointer loads, both ldmm operands, and a 32-bit register immediate
  when v10's value is DRAM.  Pairing the bare numbers instead mis-aligned an instruction whose other
  operand was already named and gave v9 MIDI_MSG_DATA3 = 0x9131 (the gate caught it, 2026-10-03).  A name is applied only when all its votes agree, and the
  tree's `.equ` is corrected to that value (a comment says so).  Same bytes: make gate-all.

  THE BLOCK-DELTA FALLBACK IS OFF BY DEFAULT (review 2026-10-31, notes/misc-2026-10-31/README.md).  With
  --infer-block-delta, a name with no vote whose voted neighbours (within 0x100, at least five) ALL moved
  by one delta takes that delta -- v7's panel block moved -0x9C as one, the low variables (0x408, 0x409,
  0xC9A) not at all.  That is a guess from layout, not a vote: the gate cannot check it (a name nothing
  numeric uses changes no byte) and its `.equ` correction would carry the same "derived from v10's
  uses" comment as a voted one.  Without the flag the names it would place are only listed, with the
  address it would give them, and nothing of theirs is rewritten.

USAGE
  make all
  python3 scripts/tools/name_kn5000_ram.py --tree v10|v9|v7 [--apply] [--infer-block-delta]
  python3 scripts/tools/name_kn5000_ram.py --tree v10|v9|v7 --check-xhl   # named xhl loads the PTR rule would not make
"""
import argparse
import collections
import glob
import os
import re
import subprocess
import sys

REPO = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                      text=True).stdout.strip() or "."
CONST = ["midi_encoder_constants.s", "cpanel_constants.s", "gui_constants.s", "kn5000_%s_program.s",
         "shared/ram_variables.s", "shared/ram_variables_by_use.s",
         "shared/ram_panel_records.s"]
EQU = re.compile(r'^(\s*\.equ\s+)([A-Za-z_]\w*)(\s*,\s*)(0x[0-9a-fA-F]+)(.*)$')
MEM = re.compile(r'\((0x[0-9a-fA-F]+|\d+)(:8|:16|:24)?\)')
TOK = re.compile(r'\(([A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(?::8|:16|:24)?\)')
PTR = re.compile(r'^(\s*ld\s+x(?:ix|iy|iz|hl)\s*,\s*)(0x[0-9a-fA-F]+|\d+)(\s*)$', re.I)
COL0 = re.compile(r'^([A-Za-z_][\w$]*):')
# memory-to-memory pseudos: both operands are addresses (`ldmm8 0x8d39, 0x8d38`)
MM = re.compile(r'^(\s*ldmm(?:8|16)\s+)(0x[0-9a-fA-F]+|\d+)(\s*,\s*)(0x[0-9a-fA-F]+|\d+)(\s*)$', re.I)
# a DRAM address (>= 0x10000) loaded into, added to or subtracted from a 32-bit register is a pointer
WIDE = re.compile(r'^(\s*(?:ld|add|sub)\s+x(?:wa|bc|de|hl|ix|iy|iz)\s*,\s*)(0x[0-9a-fA-F]{5,}|\d{5,})(\s*)$', re.I)
LO, HI = 0x400, 0x100000      # internal RAM and the DRAM the code addresses (pattern buffers at 0x94800)
LEAD_LABEL = re.compile(r'^[A-Za-z_][\w$]*:\s*')
LEAVES = re.compile(r'^(?:(?:jr|jrl|jp)\s+(?:t\s*,\s*)?[A-Za-z_][\w$]*|reti?|retd\b.*|halt)$', re.I)
XHL_DEREF = re.compile(r'\(\s*-?\s*xhl\b|\b(?:ldir|ldirw|lddr|lddrw|ldi|ldiw|ldd|lddw|cpir|cpirw)\b', re.I)
XHL_LOST = re.compile(r'^(?:ld|lda|pop)\s+xhl\s*,|^pop\s+xhl$', re.I)


def xhl_is_pointer(L, i, window=10):
    """does the `ld xhl, N` on line i load a pointer?  XHL is also the C return register, so a number
    loaded into it may be a value (LswLocal_SubParam returns 0x400 as an LSW data number, not RAM
    0x400).  True only when one of the next `window` instructions dereferences XHL (`(xhl)`, `(xhl+..)`,
    a block move), pushes it, adds to it (or to HL / H / L) or reads it as a source -- before control
    leaves (an unconditional jump or return) or XHL is overwritten.  On the trees of 2026-10-24 this keeps
    all 44 named `ld xhl, NAME` pointer loads of v10 and rejects only LswLocal_SubParam's"""
    seen = 0
    for l in L[i + 1:]:
        code = LEAD_LABEL.sub("", l.split(";")[0].strip()).strip()
        if not code:
            continue
        if code.startswith("."):
            return False
        if XHL_DEREF.search(code):
            return True
        if XHL_LOST.match(code):
            return False
        if re.search(r'\bxhl\b', code, re.I) or re.match(r'(?:add|adc|sub|sbc|inc|dec)\s+(?:\d+\s*,\s*)?(?:hl|h|l)\b', code, re.I):
            return True     # push xhl, add xhl, .., ld (..), xhl, ld xde, xhl, ex .., add l, w (pointer arithmetic)
        if LEAVES.match(code):
            return False
        seen += 1
        if seen >= window:
            return False
    return False


def const_files(t):
    return [os.path.join(REPO, t, "maincpu", c % t if "%s" in c else c) for c in CONST]


def ram_names(t):
    out = {}
    for f in const_files(t):
        if not os.path.exists(f):
            continue
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            m = EQU.match(l)
            if m and LO <= int(m.group(4), 16) < HI and m.group(2) != "RHYTHM_ROM_BASE":
                out[m.group(2)] = int(m.group(4), 16)
    return out


def bodies(t):
    """label -> list of (line index, file, code) for each routine of the tree"""
    out = {}
    for f in sorted(glob.glob(os.path.join(REPO, t, "maincpu", "**", "*.s"), recursive=True)):
        L = open(f, "rb").read().decode("latin-1").split("\n")
        cur = None
        for i, l in enumerate(L):
            m = COL0.match(l)
            if m:
                cur = m.group(1)
                out.setdefault(cur, (f, []))
                continue
            code = l.split(";")[0].strip()
            if cur and code and not code.startswith("."):
                out[cur][1].append((i, code))
    return out


NAMED = {}      # filled by main(): v10's RAM names, which count as numbers when shapes are compared


_NAMED_RE = []   # the compiled form of NAMED's alternation, built once (it was rebuilt per line: minutes per tree)


def names_re(names):
    """one compiled `\b(NAME|NAME...)\b` for a set of names (None when empty)"""
    return re.compile(r'\b(%s)\b' % "|".join(map(re.escape, sorted(names, key=len, reverse=True)))) if names else None


def shape(code):
    if NAMED:
        if not _NAMED_RE:
            _NAMED_RE.append(names_re(NAMED))
        code = _NAMED_RE[0].sub("0", code)
    return re.sub(r'\s+', ' ', re.sub(r'(0x[0-9a-fA-F]+|\b\d+\b)', 'N', code.lower()))


def operands10(code):
    """v10's memory-operand values, numeric or already named"""
    out = []
    for m in re.finditer(r'\(([A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)(?::8|:16|:24)?\)', code):
        t = m.group(1)
        if t in NAMED:
            out.append(NAMED[t])
        elif re.match(r'^(0x|\d)', t):
            out.append(int(t, 0))
    return out


A = r'([A-Za-z_]\w*|0x[0-9a-fA-F]+|\d+)'
PTR_A = re.compile(r'^\s*ld\s+x(?:ix|iy|iz|hl)\s*,\s*%s\s*$' % A, re.I)
MM_A = re.compile(r'^\s*ldmm(?:8|16)\s+%s\s*,\s*%s\s*$' % (A, A), re.I)
WIDE_A = re.compile(r'^\s*(?:ld|add|sub)\s+x(?:wa|bc|de|hl|ix|iy|iz)\s*,\s*%s\s*$' % A, re.I)


def addr_tokens(code):
    """the address-valued operands of an instruction, in order, named or numeric -- the same forms the
    rewrite below handles: memory operands, a pointer into an index register, both ldmm operands, and
    a 32-bit register immediate (flagged `wide`: it votes only when v10's value is DRAM, >= 0x10000)"""
    out = [(m.group(1), False) for m in TOK.finditer(code)]
    m = MM_A.match(code)
    if m:
        return out + [(m.group(1), False), (m.group(2), False)]
    m = PTR_A.match(code)
    if m:
        return out + [(m.group(1), False)]
    m = WIDE_A.match(code)
    if m:
        return out + [(m.group(1), True)]
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=["v10", "v9", "v7"])
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--infer-block-delta", action="store_true",
                    help="also place unvoted names by their voted neighbours' common delta (a guess; off by default)")
    ap.add_argument("--check-xhl", action="store_true",
                    help="list the tree's `ld xhl, NAME` loads of a RAM name that xhl_is_pointer() rejects")
    a = ap.parse_args()
    if a.check_xhl:
        names, kept, rejected = ram_names(a.tree), 0, 0
        for f in sorted(glob.glob(os.path.join(REPO, a.tree, "maincpu", "**", "*.s"), recursive=True)):
            L = open(f, "rb").read().decode("latin-1").split("\n")
            for i, l in enumerate(L):
                m = re.match(r'^\s*ld\s+xhl\s*,\s*([A-Za-z_]\w*)\s*(;|$)', l)
                if m and m.group(1) in names:
                    if xhl_is_pointer(L, i):
                        kept += 1
                    else:
                        rejected += 1
                        print("  not a pointer load: %s:%d: %s" % (os.path.relpath(f, REPO), i + 1, l.strip()))
        print("%s: %d named `ld xhl, NAME` pointer loads pass xhl_is_pointer, %d do not" % (a.tree, kept, rejected))
        return 1 if rejected else 0
    ref = ram_names("v10")
    NAMED.update(ref)
    byaddr10 = {v: n for n, v in ref.items()}
    if a.tree == "v10":
        addr = dict(ref)
        report = {}
    else:
        B10, BT = bodies("v10"), bodies(a.tree)
        votes = collections.defaultdict(collections.Counter)
        for lab, (f, body) in B10.items():
            if lab not in BT:
                continue
            other = BT[lab][1]
            if len(other) != len(body) or any(shape(x[1]) != shape(y[1]) for x, y in zip(body, other)):
                continue
            for (_, c10), (_, ct) in zip(body, other):
                # pair memory operands by their FULL position -- names included.  Pairing the numbers
                # alone mis-aligned an instruction whose other operand the tree had already named
                # (v10's MIDI_MSG_DATA3 voted for v9's 0x9131: 2026-10-03, caught by the gate)
                t10, tt = addr_tokens(c10), addr_tokens(ct)
                if len(t10) != len(tt):
                    continue
                for (x, wide), (y, _) in zip(t10, tt):
                    v10 = NAMED.get(x, int(x, 0) if re.match(r'^(0x|\d)', x) else None)
                    if wide and (v10 is None or v10 < 0x10000):
                        continue
                    if v10 in byaddr10 and re.match(r'^(0x[0-9a-fA-F]+|\d+)$', y):
                        votes[byaddr10[v10]][int(y, 0)] += 1
        addr, report, inferred = {}, {}, {}
        for n in ref:
            v = votes.get(n)
            if v and len(v) == 1:
                addr[n] = next(iter(v))
            report[n] = dict(v) if v else None
        # a name the tree's code already USES was derived (and gated) on an earlier run: its .equ
        # value in this tree is trusted, so the forms added later (ldmm, DRAM pointers) reach it too
        own = ram_names(a.tree)
        used = set()
        own_re = names_re(own)
        for f in glob.glob(os.path.join(REPO, a.tree, "maincpu", "**", "*.s"), recursive=True):
            for l in open(f, "rb").read().decode("latin-1").split("\n"):
                if own_re and not l.lstrip().startswith(".equ"):
                    used |= set(own_re.findall(l.split(";")[0]))
        for n in used:
            if n in own:
                # a name the code already uses keeps its value: a later vote never overrides it
                addr[n] = own[n]
                report[n] = {own[n]: "already used"}
        # a name with no vote inside a block whose voted names ALL moved by the same delta takes that
        # delta (v7's panel / encoder / MIDI-CC block moved -0x9C as one: 40 of 40 voted names)
        for n in ref:
            if n in addr:
                continue
            near = {addr[m] - ref[m] for m in addr if abs(ref[m] - ref[n]) <= 0x100}
            if len(near) == 1 and sum(1 for m in addr if abs(ref[m] - ref[n]) <= 0x100) >= 5:
                inferred[n] = ref[n] + near.pop()
                report[n] = "inferred"
                if a.infer_block_delta:
                    addr[n] = inferred[n]       # as before 2026-10-31: a guess counts as a neighbour for the next
    byaddr = {v: n for n, v in addr.items()}
    files = sorted(glob.glob(os.path.join(REPO, a.tree, "maincpu", "**", "*.s"), recursive=True))
    st = collections.Counter()
    for f in files:
        L = open(f, "rb").read().decode("latin-1").split("\n")
        ch = False
        for i, l in enumerate(L):
            code, sep, cmt = l.partition(";")
            s = code.strip()
            if not s or s.startswith("."):
                continue

            def mem(m):
                v = int(m.group(1), 0)
                return "(%s%s)" % (byaddr[v], m.group(2) or "") if v in byaddr else m.group(0)

            new = MEM.sub(mem, code)
            ptr_done = 0
            p = PTR.match(new)
            if p and int(p.group(2), 0) in byaddr and (not re.match(r'\s*ld\s+xhl\b', new, re.I)
                                                       or xhl_is_pointer(L, i)):
                new = p.group(1) + byaddr[int(p.group(2), 0)] + p.group(3)
                ptr_done = 1
            q = MM.match(new)
            if q:
                x, y = int(q.group(2), 0), int(q.group(4), 0)
                new = q.group(1) + byaddr.get(x, q.group(2)) + q.group(3) + byaddr.get(y, q.group(4)) + q.group(5)
                st["ldmm operands"] += (x in byaddr) + (y in byaddr)
            w = WIDE.match(new)
            if w and int(w.group(2), 0) in byaddr and int(w.group(2), 0) >= 0x10000:
                new = w.group(1) + byaddr[int(w.group(2), 0)] + w.group(3)
                st["wide pointer operands"] += 1
            if new != code:
                st["operands"] += len([1 for m in MEM.finditer(code) if int(m.group(1), 0) in byaddr]) + \
                    ptr_done
                L[i] = new + sep + cmt
                ch = True
        if ch and a.apply:
            open(f, "wb").write("\n".join(L).encode("latin-1"))
    fixed = []
    if a.tree != "v10":
        for cf in const_files(a.tree):
            if not os.path.exists(cf):
                continue
            L = open(cf, "rb").read().decode("latin-1").split("\n")
            ch = False
            for i, l in enumerate(L):
                m = EQU.match(l)
                if m and m.group(2) in addr and int(m.group(4), 16) != addr[m.group(2)]:
                    fixed.append((m.group(2), m.group(4), "0x%04x" % addr[m.group(2)]))
                    rest = m.group(5)
                    L[i] = "%s%s%s0x%04x%s\t; %s address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's %s" % (
                        m.group(1), m.group(2), m.group(3), addr[m.group(2)], rest.rstrip(), a.tree, m.group(4))
                    ch = True
            if ch and a.apply:
                open(cf, "wb").write("\n".join(L).encode("latin-1"))
    print("%s: %d names applied; %s%s" % (a.tree, len(addr), dict(st), "" if a.apply else " (dry run)"))
    if report:
        used = set()
        ref_re = names_re(ref)
        for f in files:
            for l in open(f, "rb").read().decode("latin-1").split("\n"):
                if not l.lstrip().startswith(".equ"):
                    used |= set(ref_re.findall(l.split(";")[0]))
        # a name the tree's code already uses has nothing numeric left to vote with: not "unsure"
        unsure = {n: v for n, v in report.items() if v != "inferred" and (not v or len(v) != 1) and n not in used}
        print("  block-delta guesses (%s): %s" % (
            "applied, --infer-block-delta" if a.infer_block_delta else "NOT applied; --infer-block-delta applies them",
            {n: "0x%04x" % inferred[n] for n in sorted(inferred)}))
        print("  not applied (no vote, or votes disagree): %s" % unsure)
    for x in fixed:
        print("  .equ %s: %s -> %s" % x)
    return 0


if __name__ == "__main__":
    sys.exit(main())
