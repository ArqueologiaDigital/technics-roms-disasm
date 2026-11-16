#!/usr/bin/env python3
"""Copy functions that V4.23 reproduced from a probe file into a tree's staging file, with the declarations they need.

(lane_p6's notes/cc900-phase6-2026-11-16/stage_probe.py, copied for the sub-CPU on 2026-11-16 with the sub-CPU's
staging header; stage_matches.py here calls it.)

QUESTION ANSWERED / WHY: probe files (scripts/analysis/cc900/corpus/firmware/sub_*.c) hold guesses for many hand
sources at once; a function that matches moves to v142/subcpu/cc900-staged/<file>.c, one C file per hand source
and option set.  This takes each named function's definition, its `cc900-name:` comment,
and every top-level declaration it uses (externs, structs, typedefs, transitively), and appends them to the staging
file, creating it with the staging header when new.  A declaration already in the file is not repeated.

usage: python3 notes/cc900-phase6-2026-11-16/stage_probe.py PROBE.c STAGED.c HAND_SOURCE OPTIONS FUNC [FUNC ...]
    HAND_SOURCE  the hand source the functions come from, e.g. sequencer/sequencer_engine.s (the header names it)
    OPTIONS      the file's cc900 options: "-O3 -XS -Xr" or "-Xr" (written as its `cc900-options:` comment)
"""
import os, re, sys

KEYWORDS = set('''auto break case char const continue default do double else enum extern float for goto if int long
register return short signed sizeof static struct switch typedef union unsigned void volatile while __near __tiny
__cdecl __adecl'''.split())
HEADER = ('/* Functions of %s.\n'
          '   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);\n'
          '   the build does not compile this directory yet.  Names are the tree\'s; ram_<hex> is a RAM cell the tree spells\n'
          '   as a number or as Payload_Bss_Start+offset.\n'
          '   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;\n'
          '   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the\n'
          '   qualifier to the first declarator only.%s\n*/\n')


def items(text):
    """top-level items: [(kind, text)], kind 'fn' (a function definition) or 'decl'; cc900-name comments are kept
    as their own 'name' items, other comments are dropped"""
    out, i, n, start, depth = [], 0, len(text), 0, 0
    buf = ''
    while i < n:
        if text.startswith('/*', i):
            j = text.index('*/', i) + 2
            c = text[i:j]
            if 'cc900-name:' in c and depth == 0:
                out.append(('name', c))
            i = j
            continue
        if text[i] == '#' and not buf.strip() and depth == 0:   # a preprocessor line (#define): its own item
            j = text.find('\n', i)
            j = len(text) if j < 0 else j
            out.append(('pp', text[i:j].strip()))
            i = j
            continue
        ch = text[i]
        buf += ch
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            head = buf[:buf.index('{')] if '{' in buf else buf   # a definition: a parameter list before its first {
            if depth == 0 and '(' in head and re.search(r'\)\s*$', head) and not re.match(r'\s*(typedef|extern)\b', buf):
                out.append(('fn', buf.strip())); buf = ''
        elif ch == ';' and depth == 0:
            if buf.strip() != ';':
                out.append(('decl', buf.strip()))
            buf = ''
        i += 1
    return out


def idents(s):
    return set(re.findall(r'\b[A-Za-z_]\w*\b', s)) - KEYWORDS


def defines(d):
    """names a declaration (or a #define) introduces"""
    m = re.match(r'#\s*define\s+(\w+)', d)
    if m:
        return {m.group(1)}
    m = re.match(r'(?:typedef\s+)?(struct|union|enum)\s+(\w+)\s*\{', d)
    if m and not d.startswith('typedef'):
        return {m.group(2)}
    body = re.sub(r'\{.*\}', ' ', d, flags=re.S)
    m = re.search(r'(\w+)\s*\([^()]*\)\s*;?\s*$', body)      # a function prototype (lane_sub fix: it was not
    if m and not d.startswith('typedef'):                       # picked, so the staged C called it undeclared)
        return {m.group(1)}
    if d.startswith('typedef'):
        tags = {m.group(2)} if m else set()
        return tags | {re.findall(r'(\w+)\s*(?:\[[^\]]*\])*\s*;?$', body.rstrip(';').strip())[-1]}
    names = set()
    for part in body.rstrip(';').split(','):
        f = re.findall(r'(\w+)\s*(?:\[[^\]]*\])*\s*(?:=.*)?$', part.strip())
        if f:
            names.add(f[-1])
    return names


def fn_name(f):
    return re.search(r'(\w+)\s*\([^)]*\)\s*\{', f).group(1)


def main():
    a = sys.argv[1:]
    if len(a) < 5:
        sys.exit(__doc__)
    probe, staged, src, opts, funcs = a[0], a[1], a[2], a[3], a[4:]
    it = items(open(probe, encoding='latin-1').read())
    decls = [d for k, d in it if k in ('decl', 'pp')]
    fns = {fn_name(d): d for k, d in it if k == 'fn'}
    names = [d for k, d in it if k == 'name']
    want, need = [], set()
    for f in funcs:
        if f not in fns:
            sys.exit('%s: no function %s' % (probe, f))
        want.append(fns[f]); need |= idents(fns[f])
    picked, changed = [], True
    while changed:
        changed = False
        for d in decls:
            if d not in picked and defines(d) & need:
                picked.append(d); need |= idents(d); changed = True
    picked = [d for d in decls if d in picked]                     # keep the probe's order
    # a callee DEFINED in the probe but not staged with it: give the staging file its prototype (lane_sub: without
    # it a __cdecl callee was called as a register-argument one, run 2026-11-16-62)
    for n, d in fns.items():
        if n in need and n not in funcs and not any(n in defines(x) for x in picked):
            picked.append(d[:d.index('{')].strip() + ';')
    nm = [c for c in names if any(re.search(r'cc900-name:\s*%s\s*=' % re.escape(f), c) for f in funcs)
          or any(re.search(r'cc900-name:\s*%s\s*=' % re.escape(n), c) for n in need)]   # a callee's short name too
    # A name the staging file already declares differently (another probe's type for it) would make V4.23 refuse
    # the whole file (THC1-Error-262): such functions go to a sibling file, <name>_b.c, _c.c, ... instead.
    base = staged[:-2]
    for suffix in [''] + ['_' + c for c in 'bcdefgh']:
        staged = base + suffix + '.c'
        if not os.path.exists(staged):
            break
        prev = {}
        for k, d in items(open(staged, encoding='latin-1').read()):
            if k in ('decl', 'pp'):
                for n in defines(d):
                    prev[n] = d
        if not any(n in prev and prev[n] != d for d in picked for n in defines(d)):
            break
    old = open(staged, encoding='latin-1').read() if os.path.exists(staged) else ''
    if not old:
        opt = '\n   cc900-options: %s' % opts
        old = HEADER % (src, opt)
    add = [d for d in picked if d not in old]
    # the probe's cc900-module: names that these functions call (lane_sub: a staged tail call lost its calr / jr)
    mod = set()
    for m in re.finditer(r'cc900-module:([^*\n]*)', open(probe, encoding='latin-1').read()):
        mod.update(n for n in re.split(r'[\s,]+', m.group(1)) if n)
    lmap = {mm.group(1): mm.group(2) for mm in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', ''.join(names))}
    usedmod = sorted(n for n in mod if n in need or any(lmap.get(k) == n for k in need))
    have = set()
    for m in re.finditer(r'cc900-module:([^*\n]*)', old):
        have.update(n for n in re.split(r'[\s,]+', m.group(1)) if n)
    usedmod = [n for n in usedmod if n not in have]
    if usedmod:
        nm = nm + ['/* cc900-module: %s */' % ' '.join(usedmod)]
    # prototypes of the staged functions first: one may call another defined after it (lane_sub: an implicit
    # declaration followed by a void definition is V4.23's THC1-Error-262)
    protos = [w[:w.index('{')].strip() + ';' for w in want if len(want) > 1]
    body = '\n'.join(add + protos + [''] + nm + [w + '\n' for w in want])
    os.makedirs(os.path.dirname(staged), exist_ok=True)
    open(staged, 'w', encoding='latin-1').write(old.rstrip('\n') + '\n\n' + body.strip('\n') + '\n')
    print('%s: +%d functions, +%d declarations' % (staged, len(want), len(add)))


if __name__ == '__main__':
    main()
