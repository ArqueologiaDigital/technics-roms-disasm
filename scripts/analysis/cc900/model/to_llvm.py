#!/usr/bin/env python3
"""Translate the model's Toshiba-syntax listing into our LLVM TLCS-900 syntax, choosing asm900's encodings.

usage: python3 -I -B to_llvm.py FILE.c SYMBOLS.txt [--opt O3XS] [--adecl] [--personality kn5000] [--only NAME,...]
                                [-D...] [-I...]
Compiles FILE.c with the reference model and prints one llvm-mc source on stdout; each function becomes a global
label (its name without the `_` / `.` prefix).  As a module, translate_function(name, lines, syms) does the same for
one function and returns its lines; relax() turns out-of-reach jr into jrl.

The encodings asm900 picks, read from the firmware (v10 String_Compare, Strcat, the phase 6 functions):
- `ld r8,n` is the 2-byte compact form (`ld l, 0x0:opc`); `ld r16/r32,n` and `cp r,n` with n in 0..7 the 3-bit
  form (`ld hl, 0:i3`, `cp bc, 0:i3`); a larger `ld r16,n` the 3-byte compact form (`ldw hl, 0xffff`, _strlen);
- `j cc,L` / `j L` are `jr` when the target is in reach and `jrl` otherwise; `cal _f` is `call` with a 24-bit
  address; a 16-bit push / pop of WA..IZ is the 1-byte form;
- an absolute operand is `(ADDR:8)` below 0x100, `(ADDR:16)` below 0x10000, `(ADDR:24)` above.
SYMBOLS.txt rows are `NAME 0xADDR`; a C name is looked up with and without its `_` / `.` prefix.  An instruction the
translator does not know is written as `; untranslated: ...`, so that the assembler stops on it.
"""
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

CC = {'eq': 'z', 'ne': 'nz', 'lt': 'lt', 'le': 'le', 'gt': 'gt', 'ge': 'ge', 'ult': 'c', 'uge': 'nc', 'ugt': 'ugt',
      'ule': 'ule', 'm': 'mi', 'p': 'pl', 'z': 'z', 'nz': 'nz', 'c': 'c', 'nc': 'nc', 'ov': 'ov', 'nov': 'nov', 't': 't'}
R8 = {'A', 'W', 'B', 'C', 'D', 'E', 'H', 'L'}
REGS = re.compile(r'^(Q?[WABCDEHL]|Q?(WA|BC|DE|HL|IX|IY|IZ|SP)|X(WA|BC|DE|HL|IX|IY|IZ|SP)|Q?I[XYZ][LH])$')
NUM = re.compile(r'^-?(0x[0-9a-fA-F]+|\d+)$')

def load_symbols(path):
    out = {}
    for l in open(path):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            try: out[p[0]] = int(p[1], 16)
            except ValueError: pass
    return out

def lookup(sym, syms):
    for n in (sym, sym.lstrip('_.')):
        if n in syms: return syms[n]
    raise KeyError('no address for %s' % sym)

def absaddr(a):
    return '(0x%x:%d)' % (a, 8 if a < 0x100 else 16 if a < 0x10000 else 24)

def num(s):
    s = s.strip(); neg = s.startswith('-'); s = s.lstrip('-')
    v = int(s, 16) if s.lower().startswith('0x') else int(s)
    return -v if neg else v

def operand(o, syms, locals_):
    """one Toshiba operand in our syntax, or None"""
    o = o.strip()
    if REGS.match(o): return o.lower()
    m = re.match(r'^\(([_.][A-Za-z0-9_]+)(?:\s*\+\s*(0x[0-9a-fA-F]+|\d+))?\)$', o)
    if m: return absaddr(lookup(m.group(1), syms) + (num(m.group(2)) if m.group(2) else 0))
    m = re.match(r'^\((X\w+)\+:(\d)\)$', o)                     # post-increment
    if m: return '(%s+:%s)' % (m.group(1).lower(), m.group(2))
    m = re.match(r'^\(-(X\w+):(\d)\)$', o)                       # pre-decrement
    if m: return '(-%s:%s)' % (m.group(1).lower(), m.group(2))
    m = re.match(r'^\((X\w+)\+(0x[0-9a-fA-F]+|\d+)\)$', o)       # (xsp+4)
    if m: return '(%s+%d)' % (m.group(1).lower(), num(m.group(2)))
    m = re.match(r'^\((X\w+)-(0x[0-9a-fA-F]+|\d+)\)$', o)
    if m: return '(%s-%d)' % (m.group(1).lower(), num(m.group(2)))
    m = re.match(r'^\((X\w+)\+(\w+)\)$', o)                     # (xix+hl)
    if m: return '(%s+%s)' % (m.group(1).lower(), m.group(2).lower())
    m = re.match(r'^\((X\w+)\)$', o)
    if m: return '(%s)' % m.group(1).lower()
    if NUM.match(o): return o.lower()
    if o in locals_: return o
    m = re.match(r'^\((X\w+)\+\)$', o)                         # inline assembly: (XIX+), (-XIX)
    if m: return '(%s+)' % m.group(1).lower()
    m = re.match(r'^\(-(X\w+)\)$', o)
    if m: return '(-%s)' % m.group(1).lower()
    if re.match(r'^[_.][A-Za-z0-9_]+$', o): return '0x%x' % lookup(o, syms)
    return None

def size_suffix(op):
    """cpb / ldb ... -> cp / ld (the operand decides the size in our syntax); the word forms keep their w"""
    if op in ('ldw', 'cpw', 'addw', 'subw', 'andw', 'orw', 'xorw', 'incw', 'decw'): return op[:-1], 'w'
    if op.endswith('b') and op[:-1] in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor', 'inc', 'dec'): return op[:-1], 'b'
    return op, ''

def translate_line(t, syms, locals_):
    if t.endswith(':') and not t.startswith('\t'): return t
    parts = t.strip().split(None, 1); op = parts[0]
    raw = [a.strip() for a in re.split(r',(?![^()]*\))', parts[1])] if len(parts) > 1 else []
    if op == 'align': return '\t.balign %s' % raw[0]
    if op in ('db', 'dw', 'dl'):
        out = []
        for a in raw:
            if a.startswith('"'): out.append('\t.ascii %s' % a); continue
            if '-' in a and not a.startswith('-') and all(x.strip() in locals_ for x in a.split('-')): v = a
            else: v = operand(a, syms, locals_) or a
            out.append('\t%s %s' % ({'db': '.byte', 'dw': '.short', 'dl': '.long'}[op], v))
        return '\n'.join(out)
    if op == 'ret': return '\tret' if not raw else '\tret %s' % CC[raw[0]]
    if op == 'retd': return '\tretd %d' % num(raw[0])
    if op == 'cal': return '\tcall 0x%x' % lookup(raw[0], syms)
    if op == 'j':
        if len(raw) == 1:
            if raw[0] in locals_: return '\tjr %s' % raw[0]
            m = re.match(r'^(X\w+)\+(\w+)$', raw[0])
            if m: return '\tjp t, (%s+%s)' % (m.group(1).lower(), m.group(2).lower())
            return '\tjp 0x%x' % lookup(raw[0], syms)
        return '\tjr %s, %s' % (CC[raw[0]], raw[1])
    if op == 'djnz': return '\tdjnz %s, %s' % (raw[0].lower(), raw[1])
    m = re.match(r'^([_.]\w+|S\d+) (>> 16|& 0xffff)$', ' '.join(raw)) if op == 'pushw' else None
    if m:                                                # an address pushed as two words (abi returns.c use_d,
        a = syms[m.group(1)] if m.group(1) in syms else lookup(m.group(1), syms)   # _sprintf: pushw __strOut >> 16)
        return '\tpushw 0x%x' % ((a >> 16) & 0xffff if m.group(2) == '>> 16' else a & 0xffff)
    if op == 'call' and len(raw) == 1 and re.match(r'^X(WA|BC|DE|HL|IX|IY|IZ)$', raw[0]):
        return '\tcall (%s)' % raw[0].lower()                    # an indirect call: call XWA (abi fptr.c fp_call)
    if op in ('jr', 'jrl'):                                # inline assembly writes jr / jrl itself (_MEMSET.C)
        return '\t%s %s' % (op, raw[0]) if len(raw) == 1 else '\t%s %s, %s' % (op, CC[raw[0].lower()], raw[1])
    if op in ('sll', 'srl', 'sla', 'sra', 'rlc', 'rrc', 'rl', 'rr') and len(raw) == 2 and NUM.match(raw[0]):
        return '\t%s %s, %d' % (op, raw[1].lower(), num(raw[0]))   # Toshiba: count first (srl 2,BC)
    if op in ('cpir', 'cpirw', 'cpdr', 'cpdrw', 'cpi', 'cpiw', 'cpd', 'cpdw') and len(raw) == 2:
        m = re.match(r'^\((X(WA|BC|DE|HL|IX|IY|IZ|SP))[+-]\)$', raw[1])
        if m:                                              # llvm-mc knows only the operand-less form: the bytes
            r = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'XSP'].index(m.group(1))
            sub = {'cpi': 0x14, 'cpir': 0x15, 'cpd': 0x16, 'cpdr': 0x17}[op.rstrip('w')]
            return '\t.byte 0x%02x, 0x%02x\t; %s' % ((0x90 if op.endswith('w') else 0x80) + r, sub, t.strip())
    bop = {'ldib': 'ldi', 'ldirb': 'ldir', 'lddb': 'ldd', 'lddrb': 'lddr'}.get(op, op)
    if bop in ('ldir', 'ldirw', 'ldi', 'ldiw', 'lddr', 'lddrw', 'ldd', 'lddw'):
        # block transfers as their bytes: 0x80 (byte) / 0x90 (word) + 3 for (XDE+),(XHL+) or 5 for (XIX+),(XIY+), then
        # 0x10 ldi, 0x11 ldir, 0x12 ldd, 0x13 lddr (_memcpy: ldib (XIX+),(XIY+) = 85 10; llvm-mc's bare ldi is 80 10)
        r = 5 if raw[:1] in (['(XIX+)'], ['(XIX-)']) else 3 if raw[:1] in (['(XDE+)'], ['(XDE-)']) else 5 if not raw else None
        if r is not None:
            sub = {'ldi': 0x10, 'ldir': 0x11, 'ldd': 0x12, 'lddr': 0x13}[bop.rstrip('w') if bop not in ('ldd',) else 'ldd']
            word = bop.endswith('w') and bop not in ('ldd',)
            return '\t.byte 0x%02x, 0x%02x\t; %s' % ((0x90 if word else 0x80) + r, sub, t.strip())
    if op == 'scc': return '\tscc %s, %s' % (CC[raw[0]], raw[1].lower())
    if op in ('push', 'pop') and raw[0] in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ'):
        return '\t%sw %s' % (op, raw[0].lower())                      # the 1-byte 16-bit forms
    if op == 'lda':
        dst = raw[0].lower(); src = raw[1]
        m = re.match(r'^(X\w+)\+:(\d)$', src)
        if m: return '\tlda %s, (%s+:%s)' % (dst, m.group(1).lower(), m.group(2))
        m = re.match(r'^(X\w+)([+-])(0x[0-9a-fA-F]+|\d+)$', src)
        if m: return '\tlda %s, (%s%s%d)' % (dst, m.group(1).lower(), m.group(2), num(m.group(3)))
        m = re.match(r'^(X\w+)\+(\w+)$', src)
        if m: return '\tlda %s, (%s+%s)' % (dst, m.group(1).lower(), m.group(2).lower())
        # lda of a symbol takes the 24-bit address whatever its value (sub CPU _exp: lda XBC,_g_mathtbl at 0xf420 is
        # f2 20 f4 00 31, not the 16-bit form)
        m = re.match(r'^([_.]\w+) \+ (0x[0-9a-fA-F]+|\d+)$', src)
        if m: return '\tlda %s, (0x%x:24)' % (dst, lookup(m.group(1), syms) + num(m.group(2)))   # _cos: _g_dbltbl + 0x10
        if src.startswith(('_', '.')): return '\tlda %s, (0x%x:24)' % (dst, lookup(src, syms))
        if src in syms: return '\tlda %s, (0x%x:24)' % (dst, syms[src])      # an FP constant placed by the linker
        if re.match(r'^X(WA|BC|DE|HL|IX|IY|IZ|SP)$', src): return '\tlda %s, (%s)' % (dst, src.lower())   # lda XWA,XSP
        if src in locals_: return '\tlda %s, (%s:24)' % (dst, src)
        if NUM.match(src): return '\tlda %s, %s' % (dst, absaddr(num(src)))
        return '\t; untranslated: ' + t.strip()
    base, sz = size_suffix(op)
    args = [operand(a, syms, locals_) for a in raw]
    if any(a is None for a in args): return '\t; untranslated: ' + t.strip()
    if base in ('inc', 'dec') and len(args) == 2:
        return '\t%s%s %d, %s' % (base, 'w' if sz == 'w' else '', num(args[0]), args[1])
    if base == 'ld' and len(args) == 2 and raw[0] in R8 and NUM.match(raw[1]):
        return '\tld %s, 0x%x:opc' % (args[0], num(raw[1]) & 0xff)            # String_Compare: ld l, 0x0:opc
    if base in ('ld', 'cp') and len(args) == 2 and REGS.match(raw[0]) and re.match(r'^(0x[0-7]|[0-7])$', raw[1]) \
            and (raw[0] not in R8 or base == 'cp') and not (base == 'cp' and raw[0].startswith('X')):
        # ld hl, 0:i3 / cp bc, 0:i3; a 32-bit cp takes the long immediate (firmware _ltoa: cp XDE,0x0 is
        # ea cf 00 00 00 00, not ea d8)
        return '\t%s %s, %d:i3' % (base, args[0], num(raw[1]))
    if base == 'ld' and len(args) == 2 and raw[0] in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'SP') and NUM.match(raw[1]):
        return '\tldw %s, 0x%x' % (args[0], num(raw[1]) & 0xffff)            # _strlen: ld HL,0xffff -> 33 ff ff
    if sz == 'w' and base in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor'):
        return '\t%sw %s' % (base, ', '.join(args))
    return '\t%s %s' % (base, ', '.join(args)) if args else '\t' + base

CONSTS = {}

def split_consts(lines):
    """the f_const block of FP constants (fpgen.py): {label: (directive, value text)} and the lines without it"""
    consts = {}; out = []; inconst = False; lab = None
    for l in lines:
        if l.startswith('f_const'): inconst = True; continue
        if l.startswith('f_code'): inconst = False; continue
        if inconst:
            if l.endswith(':'): lab = l[:-1]
            elif l.startswith('\tfdata'): consts[lab] = tuple(l.strip().split('\t'))
            continue
        out.append(l)
    return consts, out

def translate_function(name, lines, syms):
    consts, lines = split_consts(lines)
    CONSTS.clear(); CONSTS.update(consts)
    locals_ = {l[:-1] for l in lines if l.endswith(':') and not l.startswith('\t')}
    out = []
    for l in lines:
        if 'section' in l: continue
        if l.endswith(':') and not l.startswith('\t') and l[:-1] == name:
            bare = name.lstrip('_.')
            out += ['\t.globl %s' % bare, bare + ':']; continue
        out.append(translate_line(l, syms, locals_))
    return out

def relax(text, assemble):
    """asm900's j: jr when the target is in reach, else jrl.  `assemble(text)` returns llvm-mc's stderr; each line
    it reports out of range becomes jrl, until none is."""
    lines = text.split('\n')
    for _ in range(20):
        err = assemble('\n'.join(lines))
        bad = sorted({int(m.group(1)) for m in re.finditer(r':(\d+):\d+: error: [^\n]*(out of range|too far|range)', err)})
        if not bad: return '\n'.join(lines)
        changed = False
        for n in bad:
            l = lines[n - 1]
            if '\tjr ' in l: lines[n - 1] = l.replace('\tjr ', '\tjrl '); changed = True
        if not changed: return '\n'.join(lines)
    return '\n'.join(lines)

def main():
    import frontend, codegen
    a = sys.argv[1:]
    src, symf = a[0], a[1]
    opt = a[a.index('--opt') + 1] if '--opt' in a else 'O3XS'
    pers = a[a.index('--personality') + 1] if '--personality' in a else 'kn5000'
    only = a[a.index('--only') + 1].split(',') if '--only' in a else None
    defines = [x[2:] for x in a if x.startswith('-D')]; incs = [x[2:] for x in a if x.startswith('-I')]
    syms = load_symbols(symf)
    unit = frontend.load(src, defines, incs, adecl='--adecl' in a)
    out = codegen.compile_unit(unit, opt=opt, adecl='--adecl' in a, personality=pers)
    print('\t.text')
    for name, lines in out.items():
        if only and name.lstrip('_.') not in only: continue
        if not lines or not lines[0].endswith(':') or lines[0][:-1] != name: continue   # data objects, unsupported
        print('\n'.join(translate_function(name, lines, syms)))

if __name__ == '__main__':
    main()
