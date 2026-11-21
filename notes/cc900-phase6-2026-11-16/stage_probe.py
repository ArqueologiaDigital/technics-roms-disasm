#!/usr/bin/env python3
"""Copy functions that V4.23 reproduced from a probe file into a tree's staging file, with the declarations they need.

QUESTION ANSWERED / WHY: probe files (scripts/analysis/cc900/corpus/firmware/p6_*.c) hold guesses for many hand
sources at once; a function that matches moves to <tree>/maincpu/cc900-staged/<file>.c, one C file per hand source
and option set (the cc900 build's layout).  This takes each named function's definition, its `cc900-name:` comment,
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
HEADER = ('/* Functions of %s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions\' ROM bytes\n'
          '   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.\n'
          '   Names are the tree\'s; ram_<hex> is a RAM cell the tree has not named yet.\n'
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
            if ('cc900-name:' in c or 'cc900-data:' in c) and depth == 0:
                out.append(('name', c))     # a function's `cc900-data:` place goes with it as a cc900-name does
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
            if depth == 0 and '(' in head and (re.search(r'\)\s*$', head) or re.search(r'\)[^()]*;\s*$', head)) \
                    and not re.match(r'\s*(typedef|extern)\b', buf):
                out.append(('fn', buf.strip())); buf = ''
        elif ch == ';' and depth == 0:
            # an old-style definition's parameter declarations (`void f(c) unsigned char c; {`): keep reading
            if re.match(r'^\s*[\w\s\*]*\b\w+\s*\(\s*\w+(\s*,\s*\w+)*\s*\)\s*[^;()]*(;[^;()]*)*;$', buf) and \
                    not re.match(r'\s*(typedef|extern)\b', buf):
                i += 1
                continue
            if buf.strip() != ';':
                out.append(('decl', buf.strip()))
            buf = ''
        i += 1
    return out


def names_fn(c, f):
    """does the 'name' item c (a cc900-name or cc900-data comment) belong to function f?  2026-11-18: staging
    dropped `cc900-data:` comments, so run p6-r34-staged could not translate the switch tables of the ParaLoadOpt
    pair, DisplayMode_DispatchEvents and FDemoText_ByteData_VoiceProbeC."""
    return bool(re.search(r'cc900-name:\s*%s\s*=' % re.escape(f), c) or
                re.search(r'cc900-data:\s*%s\s+\d' % re.escape(f), c))


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
    if '(' in body and d.startswith('typedef') and not m:     # typedef of a function (pointer) type
        m2 = re.search(r'\(\s*\*\s*(\w+)\s*\)\s*\(', body) or re.search(r'(\w+)\s*\(', body)
        return {m2.group(1)} if m2 else set()
    if '(' in body and not d.startswith('typedef'):            # function prototypes (and pointers to functions)
        names, depth, i = set(), 0, 0
        flat = body.rstrip(';')
        while re.search(r'\(([^()]*)\)\s*\(([^()]*)\)', flat) is None and re.search(r'(\w+\s*\()[^()]*\([^()]*\)[^()]*\)', flat):
            flat = re.sub(r'(\w+\s*\()[^()]*\([^()]*\)[^()]*\)', r'\1)', flat, count=1)
        for part in re.split(r',(?![^()]*\))', flat):
            # `(*X)(` and, 2026-11-21, an array of function pointers `(*X[])(` (SeqStep_TimerDispatchC_PtrTable:
            # restage dropped its declaration and V4.23 stopped on "undefined", run p6-r60)
            m = re.search(r'\(\s*\*\s*(\w+)\s*(?:\[[^\]]*\]\s*)*\)\s*\(', part) or re.search(r'(\w+)\s*\(', part)
            if m:
                names.add(m.group(1))
            else:
                f = re.findall(r'(\w+)\s*(?:\[[^\]]*\])*\s*(?:=.*)?$', part.strip())
                if f:
                    names.add(f[-1])
        return names - KEYWORDS
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
    m = re.search(r'(\w+)\s*\([^)]*\)\s*\{', f) or re.search(r'(\w+)\s*\([\w\s,]*\)[^()]*;\s*\{', f)
    return m.group(1)


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
    nm = [c for c in names if any(names_fn(c, f) for f in funcs)]
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
    body = '\n'.join(add + [''] + nm + [w + '\n' for w in want])
    os.makedirs(os.path.dirname(staged), exist_ok=True)
    open(staged, 'w', encoding='latin-1').write(old.rstrip('\n') + '\n\n' + body.strip('\n') + '\n')
    print('%s: +%d functions, +%d declarations' % (staged, len(want), len(add)))


if __name__ == '__main__':
    main()
