#!/usr/bin/env python3
"""Translate the model's Toshiba-syntax listing into our LLVM TLCS-900 syntax, choosing asm900's encodings.

usage: python3 -I -B to_llvm.py FILE.c SYMBOLS.txt [--opt O3XS] [--adecl] [--personality kn5000] [--only NAME,...]
Compiles FILE.c with the reference model, then rewrites each function for llvm-mc:
- mnemonics and operands in our syntax (`ld (xwa+), c`, `scc nz, wa`, `cp a, 0:i3`);
- the encodings asm900 picks by default: 3-bit immediates for `cp`/`ld` of 0..7 to a register (`:i3`),
  post-increment operands without an explicit step when it equals the data size, byte/word immediate stores
  written `ld` / `ldw` as our assembler expects;
- absolute addresses: a C global `_name` is looked up (without its `_`) in SYMBOLS.txt (`NAME 0xADDR` rows, e.g.
  symbols/maincpu_v10_symbols_reference.txt plus a map for RAM variables) and written `(ADDR:16)` below 0x10000,
  `(ADDR:24)` above (`(ADDR:8)` below 0x100), the forms the firmware shows asm900/tulink choosing.
Prints one assembly file on stdout; each function becomes a global label.  Covers the instructions the six
functions of corpus/firmware/tiny.c need; anything else is left as `; untranslated: ...` so the assembler stops.
"""
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import frontend, codegen

CC = {'eq': 'z', 'ne': 'nz'}

def load_symbols(path):
    out = {}
    for l in open(path):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            try: out[p[0]] = int(p[1], 16)
            except ValueError: pass
    return out

def addr(sym, syms):
    n = sym[1:] if sym.startswith(('_', '.')) else sym
    if n not in syms: raise KeyError('no address for %s' % sym)
    a = syms[n]
    return '(0x%x:%d)' % (a, 8 if a < 0x100 else 16 if a < 0x10000 else 24)

def operand(o, syms):
    o = o.strip()
    m = re.match(r'^\(([_.][A-Za-z0-9_]+)\)$', o)
    if m: return addr(m.group(1), syms)
    m = re.match(r'^\((X\w+)\+:(\d)\)$', o)
    if m: return '(%s+)' % m.group(1).lower()
    return o.lower()

def translate(line, syms):
    t = line.strip()
    if t.endswith(':'): return t.lstrip('_.') if t[0] in '_.' else t
    parts = t.split(None, 1); op = parts[0]; args = [a.strip() for a in parts[1].split(',')] if len(parts) > 1 else []
    if op == 'ret' and not args: return '\tret'
    if op == 'scc': return '\tscc %s, %s' % (CC.get(args[0], args[0]), args[1].lower())
    if op in ('cp', 'ld') and len(args) == 2 and re.match(r'^0x[0-7]$', args[1]) and re.match(r'^[A-Z]{1,3}$', args[0]):
        return '\t%s %s, %d:i3' % (op, args[0].lower(), int(args[1], 16))      # asm900's short immediate
    if op in ('ldb', 'ldw'):
        return '\t%s %s, %s' % ('ld' if op == 'ldb' else 'ldw', operand(args[0], syms), args[1])
    if op in ('ld', 'add', 'sub', 'and', 'or', 'xor', 'cp'):
        return '\t%s %s, %s' % (op, operand(args[0], syms), operand(args[1], syms))
    return '\t; untranslated: ' + t

def main():
    a = sys.argv[1:]
    src, symf = a[0], a[1]
    opt = a[a.index('--opt') + 1] if '--opt' in a else 'O3XS'
    pers = a[a.index('--personality') + 1] if '--personality' in a else 'kn5000'
    only = a[a.index('--only') + 1].split(',') if '--only' in a else None
    syms = load_symbols(symf)
    unit = frontend.load(src)
    out = codegen.compile_unit(unit, opt=opt, adecl='--adecl' in a, personality=pers)
    print('\t.text')
    for name, lines in out.items():
        bare = name.lstrip('_.')
        if only and bare not in only: continue
        print('\t.globl %s' % bare)
        for l in lines:
            if 'section' in l: continue
            print(translate(l, syms))

main()
