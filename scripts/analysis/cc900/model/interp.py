"""cc900 reference model: an interpreter for TLCS-900/H2 assembly in the cc900 listing syntax.

It runs one function's lines, as `listing.split` gives them for an oracle listing or as `codegen.compile_unit`
gives them for the model, so that semcheck.py can compare what the two compute (semcheck.md).  It is not an
assembler: there are no encodings and no cycle counts; code addresses are CODE_BASE + 4 * instruction index, which
keeps `dw L2-L50000` switch tables and `j XIX+WA` consistent.  Data directives (`db`, `dw`, `dl`, `fdatad`,
`fdataf`, `dsb`, `align`) inside the lines, with or without `section` switches, are laid out from DATA_BASE.

Semantics follow MAME's tlcs900 core (src/devices/cpu/tlcs900/900tbl.hxx): flags of add/sub/logic/shifts, `inc` and
`dec` of a 16/32-bit register leave the flags alone, shift counts are `n & 15` with 0 meaning 16, `(XRR+R16)` and
`(XRR+R8)` sign-extend the index, `muls XWA,x` is 16x16->32 and `muls HL,x` 8x8->16, `divs XWA,x` leaves the
quotient in WA and the remainder in QWA, memory addresses are 24-bit.  Instructions the code generators do not use
are not implemented: they raise Unsupported, which semcheck reports as "not checked".

Program(lines, symaddr) parses; Machine holds registers, flags and memory; run(prog, m, hooks, limit) executes from
the function's first instruction until a `ret` pops RET_MAGIC.  hooks.call(m, target, tail) is called for every
call (or tail jump) to an address outside the program; it returns the number of stack bytes the callee pops.
"""
import re, struct

class Unsupported(Exception): pass
class StepLimit(Exception): pass
class Crash(Exception): pass

CODE_BASE = 0xC00000
DATA_BASE = 0x600000
RET_MAGIC = 0x00FFFFF0
AMASK = 0xFFFFFF

# ---------------------------------------------------------------- registers

R32 = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'XSP']
REGS = {}                                   # name -> (index, shift, bits)
for _i, _r in enumerate(R32):
    REGS[_r] = (_i, 0, 32)
    REGS[_r[1:]] = (_i, 0, 16)
    if _r != 'XSP': REGS['Q' + _r[1:]] = (_i, 16, 16)
for _i, (_lo, _hi) in enumerate([('A', 'W'), ('C', 'B'), ('E', 'D'), ('L', 'H')]):
    REGS[_lo] = (_i, 0, 8); REGS[_hi] = (_i, 8, 8); REGS['Q' + _lo] = (_i, 16, 8); REGS['Q' + _hi] = (_i, 24, 8)
for _i, _r in ((4, 'IX'), (5, 'IY'), (6, 'IZ')):
    REGS[_r + 'L'] = (_i, 0, 8); REGS[_r + 'H'] = (_i, 8, 8); REGS['Q' + _r + 'L'] = (_i, 16, 8); REGS['Q' + _r + 'H'] = (_i, 24, 8)
XSP = 7

CONDS = {
    'f': lambda m: False, 't': lambda m: True,
    'lt': lambda m: m.S != m.V, 'ge': lambda m: m.S == m.V,
    'le': lambda m: (m.S != m.V) or m.Z, 'gt': lambda m: not ((m.S != m.V) or m.Z),
    'ule': lambda m: m.C or m.Z, 'ugt': lambda m: not (m.C or m.Z),
    'ov': lambda m: m.V, 'pe': lambda m: m.V, 'nov': lambda m: not m.V, 'po': lambda m: not m.V,
    'mi': lambda m: m.S, 'm': lambda m: m.S, 'pl': lambda m: not m.S, 'p': lambda m: not m.S,
    'eq': lambda m: m.Z, 'z': lambda m: m.Z, 'ne': lambda m: not m.Z, 'nz': lambda m: not m.Z,
    'c': lambda m: m.C, 'ult': lambda m: m.C, 'nc': lambda m: not m.C, 'uge': lambda m: not m.C,
}

def sext(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v

def parity_even(v):
    return bin(v).count('1') % 2 == 0

# ---------------------------------------------------------------- machine

class Machine:
    def __init__(s, init_byte):
        s.r = [0] * 8
        s.S = s.Z = s.H = s.V = s.N = s.C = False
        s.mem = {}; s.written = set(); s.init_byte = init_byte; s.steps = 0

    def get(s, reg):
        i, sh, bits = reg
        return (s.r[i] >> sh) & ((1 << bits) - 1)

    def set(s, reg, v):
        i, sh, bits = reg
        mask = ((1 << bits) - 1) << sh
        s.r[i] = (s.r[i] & ~mask & 0xFFFFFFFF) | ((v << sh) & mask)

    def rd8(s, a):
        a &= AMASK
        v = s.mem.get(a)
        if v is None:
            v = s.mem[a] = s.init_byte(a) & 0xFF
        return v

    def wr8(s, a, v):
        a &= AMASK
        s.mem[a] = v & 0xFF; s.written.add(a)

    def rd(s, a, n):
        v = 0
        for k in range(n): v |= s.rd8(a + k) << (8 * k)
        return v

    def wr(s, a, n, v):
        for k in range(n): s.wr8(a + k, v >> (8 * k))

    def push(s, n, v):
        s.r[XSP] = (s.r[XSP] - n) & 0xFFFFFFFF
        s.wr(s.r[XSP], n, v)

    def pop(s, n):
        v = s.rd(s.r[XSP], n); s.r[XSP] = (s.r[XSP] + n) & 0xFFFFFFFF
        return v

    def flags_sz(s, r, bits):
        s.S = bool(r >> (bits - 1) & 1); s.Z = r == 0

# ---------------------------------------------------------------- expressions

TOK = re.compile(r'\s*(0x[0-9a-fA-F]+|[0-9][0-9A-Fa-f]*[Hh]\b|\d+|[A-Za-z_.$][\w.$]*|>>|<<|[-+*/&|()~^])')

def tokenize(s):
    out = []; pos = 0; s = s.rstrip()
    while pos < len(s):
        m = TOK.match(s, pos)
        if not m: raise Unsupported('cannot parse expression %r' % s)
        out.append(m.group(1)); pos = m.end()
    return out

PREC = {'|': 1, '^': 2, '&': 3, '<<': 4, '>>': 4, '+': 5, '-': 5, '*': 6, '/': 6}

def parse_expr(s):
    """-> tree: ('n', v) | ('s', name) | ('r', reg) | (op, a, b) | ('neg', a) | ('not', a)"""
    toks = tokenize(s); pos = [0]
    def atom():
        t = toks[pos[0]]; pos[0] += 1
        if t == '(':
            e = binop(0)
            if toks[pos[0]] != ')': raise Unsupported('unbalanced %r' % s)
            pos[0] += 1; return e
        if t == '-': return ('neg', atom())
        if t == '+': return atom()
        if t == '~': return ('not', atom())
        if t.startswith('0x'): return ('n', int(t, 16))
        if t[0].isdigit():
            return ('n', int(t[:-1], 16)) if t[-1] in 'hH' else ('n', int(t))
        if t in REGS: return ('r', REGS[t])
        return ('s', t)
    def binop(minp):
        a = atom()
        while pos[0] < len(toks) and toks[pos[0]] in PREC and PREC[toks[pos[0]]] > minp:
            op = toks[pos[0]]; pos[0] += 1
            b = binop(PREC[op])
            a = (op, a, b)
        return a
    e = binop(0)
    if pos[0] != len(toks): raise Unsupported('trailing tokens in %r' % s)
    return e

def resolve(e, symaddr):
    """replace symbols by numbers and fold constants; registers stay"""
    k = e[0]
    if k == 'n' or k == 'r': return e
    if k == 's': return ('n', symaddr(e[1]))
    if k in ('neg', 'not'):
        a = resolve(e[1], symaddr)
        if a[0] == 'n': return ('n', -a[1] if k == 'neg' else ~a[1])
        return (k, a)
    a, b = resolve(e[1], symaddr), resolve(e[2], symaddr)
    if a[0] == 'n' and b[0] == 'n': return ('n', binval(k, a[1], b[1]))
    return (k, a, b)

def binval(op, a, b):
    if op == '+': return a + b
    if op == '-': return a - b
    if op == '*': return a * b
    if op == '/': return int(a / b) if b else 0
    if op == '&': return a & b
    if op == '|': return a | b
    if op == '^': return a ^ b
    if op == '<<': return a << b
    if op == '>>': return a >> b
    raise Unsupported(op)

def evaluate(e, m):
    k = e[0]
    if k == 'n': return e[1]
    if k == 'r':
        v = m.get(e[1]); bits = e[1][2]
        return v if bits == 32 else sext(v, bits)     # an index register is sign-extended
    if k == 'neg': return -evaluate(e[1], m)
    if k == 'not': return ~evaluate(e[1], m)
    return binval(k, evaluate(e[1], m), evaluate(e[2], m))

def compile_expr(e):
    """-> f(m) computing evaluate(e, m), for the shapes address operands take"""
    k = e[0]
    if k == 'n':
        c = e[1]; return lambda m: c
    if k == 'r':
        i, sh, bits = e[1]
        if bits == 32: return lambda m: m.r[i]
        mask = (1 << bits) - 1; top = 1 << (bits - 1); full = 1 << bits
        def f(m):
            v = (m.r[i] >> sh) & mask
            return v - full if v & top else v
        return f
    if k == '+':
        a, b = compile_expr(e[1]), compile_expr(e[2])
        if e[2][0] == 'n':
            c = e[2][1]; return lambda m: a(m) + c
        return lambda m: a(m) + b(m)
    return lambda m: evaluate(e, m)

def has_regs(e):
    if e[0] == 'r': return True
    if e[0] in ('n', 's'): return False
    return any(has_regs(x) for x in e[1:])

# ---------------------------------------------------------------- operands

class Op:
    """kind: 'r' register, 'i' immediate/address expression, 'm' memory (mode '' / 'post' / 'pre'), 'c' condition"""
    __slots__ = ('kind', 'reg', 'expr', 'const', 'mode', 'step', 'text', 'fn')
    def __init__(s, kind, text, reg=None, expr=None, mode='', step=None):
        s.kind, s.text, s.reg, s.expr, s.mode, s.step = kind, text, reg, expr, mode, step
        s.const = None
    @property
    def bits(s): return s.reg[2] if s.kind == 'r' else None

def split_operands(s):
    out = []; depth = 0; cur = ''
    for ch in s:
        if ch == '(': depth += 1
        elif ch == ')': depth -= 1
        if ch == ',' and depth == 0: out.append(cur.strip()); cur = ''
        else: cur += ch
    if cur.strip(): out.append(cur.strip())
    return out

def parse_operand(t, symaddr):
    if t in REGS: return Op('r', t, reg=REGS[t])
    m = re.match(r'^(-?)(X[A-Z]+)(\+?):(\w+)$', t)          # lda XBC,XDE+:1 -- the (r+) / (-r) mode, unbracketed
    if m and m.group(2) in REGS and bool(m.group(1)) != bool(m.group(3)):
        return Op('m', t, reg=REGS[m.group(2)], mode='pre' if m.group(1) else 'post', step=int(m.group(4), 0))
    if t in CONDS: return Op('c', t)
    if t.startswith('(') and t.endswith(')'):
        inner = t[1:-1].strip()
        m = re.match(r'^(X[A-Z]+)\+(?::(\w+))?$', inner)
        if m and m.group(1) in REGS:
            return Op('m', t, reg=REGS[m.group(1)], mode='post', step=int(m.group(2), 0) if m.group(2) else None)
        m = re.match(r'^-(X[A-Z]+)(?::(\w+))?$', inner)
        if m and m.group(1) in REGS:
            return Op('m', t, reg=REGS[m.group(1)], mode='pre', step=int(m.group(2), 0) if m.group(2) else None)
        e = resolve(parse_expr(inner), symaddr)
        o = Op('m', t, expr=e)
        if e[0] == 'n': o.const = e[1]
        o.fn = compile_expr(e)
        return o
    e = resolve(parse_expr(t), symaddr)
    o = Op('i', t, expr=e)
    if e[0] == 'n': o.const = e[1]
    return o

# ---------------------------------------------------------------- program

DATA_DIRS = ('db', 'dw', 'dl', 'dd', 'fdatad', 'fdataf', 'fdata', 'ds', 'dsb', 'dsw', 'dsl', 'align')
DS_UNIT = {'ds': 1, 'dsb': 1, 'dsw': 2, 'dsl': 4}
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')

class Program:
    """one function's listing lines, parsed.  symaddr(name) gives the address of every symbol the lines do not define."""
    def __init__(s, lines, symaddr, data_base=DATA_BASE):
        s.labels = {}                # code label -> instruction index
        s.datalabels = {}            # data label -> address
        s.data = {}                  # address -> byte (the program's own constants: strings, switch tables)
        s.ext = symaddr
        raw = []                     # (kind, ...) after the first pass
        mode = 'code'
        lines = [l for l in lines if l.strip()]
        for i, l in enumerate(lines):
            st = l.strip()
            if st.startswith(';'):
                if 'unsupported' in st or 'model error' in st: raise Unsupported('model: ' + st[1:].strip()[:90])
                continue
            if ' section ' in ' ' + st + ' ' or st.split()[0:2][-1:] == ['section']:
                mode = 'code' if ' code' in st else 'data'; continue
            m = LABEL.match(st)
            if m and not l[0].isspace():
                rest = st[m.end():].strip()
                isdata = mode == 'data'
                if not isdata:              # a label followed (past labels and align) by data is a data label
                    for nl in lines[i + 1:]:
                        ns = nl.strip()
                        if LABEL.match(ns) and not nl[0].isspace(): continue
                        w = ns.split()[0] if ns.split() else ''
                        if w == 'align': continue
                        isdata = w in DATA_DIRS
                        break
                raw.append(('dlabel' if isdata else 'label', m.group(1)))
                if rest: raise Unsupported('label with text %r' % st)
                continue
            parts = st.split(None, 1)
            mn = parts[0]; args = parts[1] if len(parts) > 1 else ''
            if mn in DATA_DIRS or mode == 'data':
                raw.append(('data', mn, args)); continue
            raw.append(('ins', mn, args, st))
        # pass 2: addresses
        idx = 0; dp = data_base; pending_code = []
        for r in raw:
            if r[0] == 'label': s.labels[r[1]] = idx
            elif r[0] == 'dlabel': s.datalabels[r[1]] = dp
            elif r[0] == 'data':
                dp += s._data_size(r[1], r[2], dp)
            else: idx += 1
        s.ncode = idx
        # pass 3: data contents and instructions
        dp = data_base; s.code = []
        for r in raw:
            if r[0] == 'data': dp = s._emit_data(r[1], r[2], dp)
            elif r[0] == 'ins':
                s.code.append(compile_ins(r[1], r[2], r[3], s, len(s.code)))

    def symaddr(s, name):
        if name in s.labels: return CODE_BASE + 4 * s.labels[name]
        if name in s.datalabels: return s.datalabels[name]
        return s.ext(name)

    def _items(s, args):
        if args.lstrip().startswith('"') or '"' in args:
            out = []
            for m in re.finditer(r'"((?:[^"\\]|\\.)*)"|([^,]+)', args):
                if m.group(1) is not None: out.append(('str', m.group(1)))
                elif m.group(2).strip(): out.append(('e', m.group(2).strip()))
            return out
        return [('e', x) for x in split_operands(args)]

    def _data_size(s, mn, args, dp):
        if mn == 'align':
            a = int(args.split(',')[0], 0); return (-dp) % a
        if mn in DS_UNIT: return DS_UNIT[mn] * int(args, 0)
        if mn in ('fdatad',): return 8 * len(split_operands(args))
        if mn in ('fdata', 'fdataf'): return 4 * len(split_operands(args))
        w = {'db': 1, 'dw': 2, 'dl': 4, 'dd': 4}[mn]
        n = 0
        for k, v in s._items(args): n += len(v.encode('latin-1')) if k == 'str' else w
        return n

    def _emit_data(s, mn, args, dp):
        if mn == 'align': return dp + s._data_size(mn, args, dp)
        if mn in DS_UNIT:
            return dp + DS_UNIT[mn] * int(args, 0)
        if mn in ('fdatad', 'fdata', 'fdataf'):
            for x in split_operands(args):
                b = struct.pack('<d' if mn == 'fdatad' else '<f', float(x))
                for k, c in enumerate(b): s.data[dp + k] = c
                dp += len(b)
            return dp
        w = {'db': 1, 'dw': 2, 'dl': 4, 'dd': 4}[mn]
        for k, v in s._items(args):
            if k == 'str':
                for c in v.encode('latin-1'): s.data[dp] = c; dp += 1
            else:
                val = evaluate(resolve(parse_expr(v), s.symaddr), None)
                for j in range(w): s.data[dp + j] = (val >> (8 * j)) & 0xFF
                dp += w
        return dp

    def index_of(s, addr):
        """instruction index of a code address, or None"""
        addr &= 0xFFFFFFFF
        k, r = divmod(addr - CODE_BASE, 4)
        if r == 0 and 0 <= k <= s.ncode: return k
        return None

# ---------------------------------------------------------------- instructions

SIZED = {'ld', 'push', 'pop', 'add', 'adc', 'sub', 'sbc', 'cp', 'and', 'or', 'xor', 'inc', 'dec', 'neg', 'cpl',
         'sla', 'sra', 'sll', 'srl', 'rl', 'rr', 'rlc', 'rrc', 'ldir', 'ldi', 'lddr', 'ldd', 'ex', 'bit', 'set', 'res',
         'chg', 'tset', 'exts', 'extz', 'mul', 'muls', 'div', 'divs', 'scc'}
BARE = {'lda', 'j', 'jp', 'jr', 'jrl', 'cal', 'call', 'calr', 'ret', 'retd', 'djnz', 'nop', 'cpl', 'ldir', 'ldi',
        'lddr', 'ldd', 'scc'}

def split_mnemonic(mn, nops):
    if mn in SIZED or mn in BARE:
        if mn == 'cpl' and nops == 2: return 'cp', 4
        return mn, None
    if mn[-1] in 'bwl' and mn[:-1] in SIZED: return mn[:-1], {'b': 1, 'w': 2, 'l': 4}[mn[-1]]
    raise Unsupported('mnemonic %s' % mn)

def compile_ins(mn, args, text, prog, here):
    ops = [parse_operand(t, prog.symaddr) for t in split_operands(args)] if args else []
    base, sz = split_mnemonic(mn, len(ops))
    f = BUILD.get(base)
    if f is None: raise Unsupported('mnemonic %s' % mn)
    fn = f(ops, sz, prog, here, text)
    fn.text = text
    return fn

# operand access helpers (n = operand size in bytes)

def ea(o, m, n):
    """effective address of a memory operand; applies pre-decrement / post-increment"""
    if o.mode == 'post':
        a = m.get(o.reg); m.set(o.reg, a + (o.step or n)); return a
    if o.mode == 'pre':
        a = (m.get(o.reg) - (o.step or n)) & 0xFFFFFFFF; m.set(o.reg, a); return a
    if o.const is not None: return o.const
    return o.fn(m)

def reader(o, n):
    if o.kind == 'r':
        reg = o.reg
        return lambda m: m.get(reg)
    if o.kind == 'i':
        if o.const is not None:
            c = o.const & ((1 << (8 * n)) - 1); return lambda m: c
        fe = compile_expr(o.expr); mask = (1 << (8 * n)) - 1
        return lambda m: fe(m) & mask
    if o.kind == 'm':
        return lambda m: m.rd(ea(o, m, n), n)
    raise Unsupported('operand %s' % o.text)

def rmw(o, n):
    """-> (get(m) -> (value, put(v)))"""
    if o.kind == 'r':
        reg = o.reg
        def g(m): return m.get(reg), (lambda v: m.set(reg, v))
        return g
    if o.kind == 'm':
        def g(m):
            a = ea(o, m, n); return m.rd(a, n), (lambda v: m.wr(a, n, v))
        return g
    raise Unsupported('destination %s' % o.text)

def writer(o, n):
    if o.kind == 'r':
        reg = o.reg
        return lambda m, v: m.set(reg, v)
    if o.kind == 'm':
        return lambda m, v: m.wr(ea(o, m, n), n, v)
    raise Unsupported('destination %s' % o.text)

def size_of(ops, sz, text):
    if sz: return sz
    for o in ops:
        if o.kind == 'r': return o.reg[2] // 8
    raise Unsupported('operand size of %r' % text)

# ALU with MAME's flags

def alu(m, op, a, b, bits):
    mask = (1 << bits) - 1; sign = bits - 1
    if op in ('add', 'adc'):
        cy = int(m.C) if op == 'adc' else 0
        r = (a + b + cy) & mask
        m.S = bool(r >> sign & 1); m.Z = r == 0
        m.H = bool(((a ^ b ^ r) >> 4) & 1) if bits <= 16 else False
        m.V = bool(((r ^ a) & (r ^ b)) >> sign & 1); m.N = False
        m.C = (a + b + cy) > mask
        return r
    if op in ('sub', 'sbc', 'cp'):
        cy = int(m.C) if op == 'sbc' else 0
        r = (a - b - cy) & mask
        m.S = bool(r >> sign & 1); m.Z = r == 0
        m.H = bool(((a ^ b ^ r) >> 4) & 1) if bits <= 16 else False
        m.V = bool(((r ^ a) & (a ^ b)) >> sign & 1); m.N = True
        m.C = (a - b - cy) < 0
        return r
    if op in ('and', 'or', 'xor'):
        r = (a & b) if op == 'and' else (a | b) if op == 'or' else (a ^ b)
        r &= mask
        m.S = bool(r >> sign & 1); m.Z = r == 0; m.H = op == 'and'; m.N = False; m.C = False
        m.V = parity_even(r) if bits <= 16 else False
        return r
    raise Unsupported(op)

def shift(m, op, a, count, bits):
    mask = (1 << bits) - 1; sign = bits - 1
    count &= 15
    if count == 0: count = 16
    for _ in range(count):
        if op in ('sla', 'sll'):
            m.C = bool(a >> sign & 1); a = (a << 1) & mask
        elif op == 'srl':
            m.C = bool(a & 1); a >>= 1
        elif op == 'sra':
            m.C = bool(a & 1); a = (a >> 1) | (a & (1 << sign))
        elif op == 'rlc':
            a = ((a << 1) | (a >> sign)) & mask
        elif op == 'rrc':
            a = (a >> 1) | ((a & 1) << sign)
        elif op == 'rl':
            c = a >> sign & 1; a = ((a << 1) | int(m.C)) & mask; m.C = bool(c)
        elif op == 'rr':
            c = a & 1; a = (a >> 1) | (int(m.C) << sign); m.C = bool(c)
    if op == 'rlc': m.C = bool(a & 1)
    if op == 'rrc': m.C = bool(a >> sign & 1)
    m.S = bool(a >> sign & 1); m.Z = a == 0; m.H = False; m.N = False; m.V = parity_even(a)
    return a

BUILD = {}
def build(*names):
    def deco(f):
        for n in names: BUILD[n] = f
        return f
    return deco

@build('nop')
def b_nop(ops, sz, prog, here, text):
    return lambda m: None

@build('ld')
def b_ld(ops, sz, prog, here, text):
    if len(ops) != 2: raise Unsupported(text)
    n = size_of(ops, sz, text)
    rd, wr = reader(ops[1], n), writer(ops[0], n)
    if ops[0].kind == 'm' and ops[1].kind == 'm': raise Unsupported(text)
    def f(m): wr(m, rd(m))
    return f

@build('lda')
def b_lda(ops, sz, prog, here, text):
    if len(ops) == 2 and ops[0].kind == 'r' and ops[1].kind == 'm' and ops[1].mode:   # the address, then the step
        reg = ops[0].reg; src = ops[1]
        def f(m): m.set(reg, ea(src, m, src.step) & 0xFFFFFFFF)
        return f
    if len(ops) == 2 and ops[1].kind == 'r' and ops[1].reg[2] == 32:      # lda XWA,XSP: the address XSP+0
        ops = [ops[0], Op('i', ops[1].text, expr=('r', ops[1].reg))]
    if len(ops) != 2 or ops[0].kind != 'r' or ops[1].kind != 'i': raise Unsupported(text)
    reg = ops[0].reg; fe = compile_expr(ops[1].expr)
    def f(m): m.set(reg, fe(m) & 0xFFFFFFFF)
    return f

@build('push')
def b_push(ops, sz, prog, here, text):
    n = size_of(ops, sz, text); rd = reader(ops[0], n)
    def f(m): m.push(n, rd(m))
    return f

@build('pop')
def b_pop(ops, sz, prog, here, text):
    n = size_of(ops, sz, text); wr = writer(ops[0], n)
    def f(m): wr(m, m.pop(n))
    return f

@build('add', 'adc', 'sub', 'sbc', 'and', 'or', 'xor')
def b_alu(ops, sz, prog, here, text):
    base = text.split()[0]; base = base if base in BUILD else base[:-1]
    if len(ops) != 2: raise Unsupported(text)
    n = size_of(ops, sz, text); bits = 8 * n
    g = rmw(ops[0], n); rd = reader(ops[1], n)
    def f(m):
        b = rd(m); a, put = g(m)
        put(alu(m, base, a, b, bits))
    return f

@build('cp')
def b_cp(ops, sz, prog, here, text):
    if len(ops) != 2: raise Unsupported(text)
    n = size_of(ops, sz, text); bits = 8 * n
    ra, rb = reader(ops[0], n), reader(ops[1], n)
    def f(m): alu(m, 'cp', ra(m), rb(m), bits)
    return f

@build('inc', 'dec')
def b_incdec(ops, sz, prog, here, text):
    op = 'add' if text.startswith('inc') else 'sub'
    if len(ops) == 1: ops = [Op('i', '1', expr=('n', 1))] + ops; ops[0].const = 1
    if len(ops) != 2 or ops[0].const is None: raise Unsupported(text)
    k = ops[0].const or 8
    n = size_of(ops[1:], sz, text); bits = 8 * n
    g = rmw(ops[1], n)
    if ops[1].kind == 'r' and n > 1:              # word / long register: no flags
        reg = ops[1].reg; mask = (1 << bits) - 1
        d = k if op == 'add' else -k
        def f(m): m.set(reg, (m.get(reg) + d) & mask)
        return f
    def f(m):
        a, put = g(m); c = m.C
        put(alu(m, op, a, k, bits)); m.C = c
    return f

@build('neg')
def b_neg(ops, sz, prog, here, text):
    n = size_of(ops, sz, text); bits = 8 * n; g = rmw(ops[0], n)
    def f(m):
        a, put = g(m); put(alu(m, 'sub', 0, a, bits))
    return f

@build('cpl')
def b_cpl(ops, sz, prog, here, text):
    n = size_of(ops, sz, text); g = rmw(ops[0], n); mask = (1 << (8 * n)) - 1
    def f(m):
        a, put = g(m); put(~a & mask); m.H = m.N = True
    return f

@build('exts', 'extz')
def b_ext(ops, sz, prog, here, text):
    if len(ops) != 1 or ops[0].kind != 'r' or ops[0].reg[2] < 16: raise Unsupported(text)
    reg = ops[0].reg; bits = reg[2]; half = bits // 2; signed = text.startswith('exts')
    def f(m):
        v = m.get(reg) & ((1 << half) - 1)
        if signed and v >> (half - 1): v |= ((1 << half) - 1) << half
        m.set(reg, v)
    return f

@build('mul', 'muls')
def b_mul(ops, sz, prog, here, text):
    if len(ops) != 2 or ops[0].kind != 'r' or ops[0].reg[2] < 16: raise Unsupported(text)
    reg = ops[0].reg; bits = reg[2]; half = bits // 2; signed = text.startswith('muls')
    rd = reader(ops[1], half // 8)
    def f(m):
        a = m.get(reg) & ((1 << half) - 1); b = rd(m) & ((1 << half) - 1)
        if signed: a, b = sext(a, half), sext(b, half)
        m.set(reg, (a * b) & ((1 << bits) - 1))
    return f

@build('div', 'divs')
def b_div(ops, sz, prog, here, text):
    if len(ops) != 2 or ops[0].kind != 'r' or ops[0].reg[2] < 16: raise Unsupported(text)
    reg = ops[0].reg; bits = reg[2]; half = bits // 2; signed = text.startswith('divs')
    rd = reader(ops[1], half // 8); hmask = (1 << half) - 1; mask = (1 << bits) - 1
    def f(m):
        a = m.get(reg); b = rd(m) & hmask
        if signed: a, b = sext(a, bits), sext(b, half)
        if b == 0:                                       # MAME div16 / divs16 / div8 / divs8 on zero
            m.V = True; m.set(reg, ((a << half) | ((a >> half) ^ hmask)) & mask); return
        if not signed and half == 8 and a >= 0x200 * b:  # MAME div8's large-quotient path
            q, r = divmod(a - 0x200 * b, 0x100 - b); q = 0x1ff - q; r = r + b
        else:
            q = abs(a) // abs(b)
            if (a < 0) != (b < 0): q = -q
            r = a - q * b
        m.V = q > hmask if not signed else q > hmask
        m.set(reg, (q & hmask) | ((r & hmask) << half))
    return f

@build('sla', 'sra', 'sll', 'srl', 'rl', 'rr', 'rlc', 'rrc')
def b_shift(ops, sz, prog, here, text):
    op = text.split()[0]
    op = op if op in ('sla', 'sra', 'sll', 'srl', 'rl', 'rr', 'rlc', 'rrc') else op[:-1]
    if len(ops) == 1:                                    # memory form: one place
        if ops[0].kind != 'm' or not sz: raise Unsupported(text)
        n = sz; g = rmw(ops[0], n)
        def f(m):
            a, put = g(m); put(shift(m, op, a, 1, 8 * n))
        return f
    if len(ops) != 2 or ops[1].kind != 'r': raise Unsupported(text)
    reg = ops[1].reg; bits = reg[2]
    if ops[0].kind == 'i' and ops[0].const is not None:
        c = ops[0].const
        def f(m): m.set(reg, shift(m, op, m.get(reg), c, bits))
        return f
    if ops[0].kind == 'r' and ops[0].reg[2] == 8:
        creg = ops[0].reg
        def f(m): m.set(reg, shift(m, op, m.get(reg), m.get(creg), bits))
        return f
    raise Unsupported(text)

@build('bit', 'set', 'res', 'chg', 'tset')
def b_bit(ops, sz, prog, here, text):
    op = text.split()[0]
    op = op if op in ('bit', 'set', 'res', 'chg', 'tset') else op[:-1]
    if len(ops) != 2 or ops[0].const is None: raise Unsupported(text)
    n = 1 if ops[1].kind == 'm' else ops[1].reg[2] // 8
    k = ops[0].const & (7 if n == 1 else 15)
    g = rmw(ops[1], n)
    def f(m):
        a, put = g(m); b = (a >> k) & 1
        if op in ('bit', 'tset'):
            m.Z = b == 0; m.H = True; m.N = False
        if op in ('set', 'tset'): put(a | (1 << k))
        elif op == 'res': put(a & ~(1 << k))
        elif op == 'chg': put(a ^ (1 << k))
    return f

@build('scc')
def b_scc(ops, sz, prog, here, text):
    if len(ops) != 2 or ops[0].kind != 'c' or ops[1].kind != 'r': raise Unsupported(text)
    c = CONDS[ops[0].text]; reg = ops[1].reg
    def f(m): m.set(reg, 1 if c(m) else 0)
    return f

@build('ex')
def b_ex(ops, sz, prog, here, text):
    n = size_of(ops, sz, text)
    if ops[0].kind == 'm':
        ops = [ops[0], ops[1]]
    g1 = rmw(ops[0], n); g2 = rmw(ops[1], n)
    def f(m):
        a, pa = g1(m); b, pb = g2(m); pa(b); pb(a)
    return f

@build('ldir', 'ldi', 'lddr', 'ldd')
def b_ldir(ops, sz, prog, here, text):
    op = text.split()[0]
    rep = op.startswith(('ldir', 'lddr')); d = -1 if op.startswith('ldd') else 1
    n = sz or 1
    if ops:
        if len(ops) != 2 or ops[0].kind != 'm' or ops[1].kind != 'm': raise Unsupported(text)
        dreg, sreg = ops[0].reg, ops[1].reg
        if dreg is None or sreg is None: raise Unsupported(text)
    else:
        dreg, sreg = REGS['XDE'], REGS['XHL']
    BC = REGS['BC']
    def f(m):
        while True:
            m.wr(m.get(dreg), n, m.rd(m.get(sreg), n))
            m.set(dreg, m.get(dreg) + d * n); m.set(sreg, m.get(sreg) + d * n)
            m.set(BC, m.get(BC) - 1)
            m.H = m.N = False; m.V = m.get(BC) != 0
            m.steps += 1
            if not (rep and m.V): break
    return f

# control transfer: a function returns the next instruction index, or STOP

STOP = -1

def target_of(o, prog):
    """-> ('idx', index) for a label of the program, ('ext', address) otherwise, or ('dyn', expr)"""
    if o.kind == 'i' and o.const is not None:
        k = prog.index_of(o.const)
        return ('idx', k) if k is not None else ('ext', o.const)
    if o.kind in ('i', 'm') and o.expr is not None:
        return ('dyn', o.expr) if o.kind == 'i' else ('dynm', o.expr)
    if o.kind == 'r': return ('dyn', ('r', o.reg))
    raise Unsupported('jump target %s' % o.text)

def do_return(m, prog, extra=0):
    ra = m.pop(4)
    m.r[XSP] = (m.r[XSP] + extra) & 0xFFFFFFFF
    if ra == RET_MAGIC: return STOP
    k = prog.index_of(ra)
    if k is None: raise Crash('return to 0x%x' % ra)
    return k

def external_call(m, prog, hooks, addr, here, tail):
    """a call (or tail jump) leaving the program"""
    if tail:
        pop = hooks.call(m, addr, True)
        return do_return(m, prog, pop)
    m.push(4, CODE_BASE + 4 * (here + 1))
    pop = hooks.call(m, addr, False)
    return do_return(m, prog, pop)

@build('j', 'jp', 'jr', 'jrl')
def b_jump(ops, sz, prog, here, text):
    cond = None
    if len(ops) == 2:
        if ops[0].kind != 'c': raise Unsupported(text)
        cond = CONDS[ops[0].text]; ops = ops[1:]
    if len(ops) != 1: raise Unsupported(text)
    kind, v = target_of(ops[0], prog)
    def go(m):
        if kind == 'idx': return v
        a = v if kind == 'ext' else evaluate(v, m) & 0xFFFFFFFF
        if kind == 'dynm': a = m.rd(a, 4)
        k = prog.index_of(a)
        if k is not None: return k
        return external_call(m, prog, m.hooks, a, here, True)
    if cond is None: return go
    def f(m): return go(m) if cond(m) else None
    return f

@build('cal', 'call', 'calr')
def b_call(ops, sz, prog, here, text):
    cond = None
    if len(ops) == 2:
        if ops[0].kind != 'c': raise Unsupported(text)
        cond = CONDS[ops[0].text]; ops = ops[1:]
    if len(ops) != 1: raise Unsupported(text)
    o = ops[0]
    if o.kind == 'm' and o.reg is None and o.expr is not None and o.expr[0] == 'r':   # call (XWA)
        o = Op('r', o.text, reg=o.expr[1])
    kind, v = target_of(o, prog)
    def go(m):
        a = v if kind in ('ext', 'idx') else evaluate(v, m) & 0xFFFFFFFF
        if kind == 'idx': a = CODE_BASE + 4 * v
        if kind == 'dynm': a = m.rd(a, 4)
        k = prog.index_of(a)
        if k is not None:
            m.push(4, CODE_BASE + 4 * (here + 1)); return k
        return external_call(m, prog, m.hooks, a, here, False)
    if cond is None: return go
    def f(m): return go(m) if cond(m) else None
    return f

@build('ret')
def b_ret(ops, sz, prog, here, text):
    if not ops: return lambda m: do_return(m, prog)
    if len(ops) != 1 or ops[0].kind != 'c': raise Unsupported(text)
    c = CONDS[ops[0].text]
    return lambda m: do_return(m, prog) if c(m) else None

@build('retd')
def b_retd(ops, sz, prog, here, text):
    if len(ops) != 1 or ops[0].const is None: raise Unsupported(text)
    n = ops[0].const
    return lambda m: do_return(m, prog, n)

@build('djnz')
def b_djnz(ops, sz, prog, here, text):
    if len(ops) == 1: ops = [Op('r', 'B', reg=REGS['B'])] + ops
    if len(ops) != 2 or ops[0].kind != 'r': raise Unsupported(text)
    reg = ops[0].reg; mask = (1 << reg[2]) - 1
    kind, v = target_of(ops[1], prog)
    if kind != 'idx': raise Unsupported(text)
    def f(m):
        x = (m.get(reg) - 1) & mask; m.set(reg, x)
        return v if x else None
    return f

# ---------------------------------------------------------------- running

def run(prog, m, hooks, limit=20000):
    """execute from instruction 0 until the function returns to RET_MAGIC.  Raises StepLimit, Crash, Unsupported."""
    m.hooks = hooks
    for a, v in prog.data.items():
        m.mem[a & AMASK] = v
    pc = 0; code = prog.code; n = len(code)
    while True:
        if pc >= n: raise Crash('ran off the end of the function')
        m.steps += 1
        if m.steps > limit: raise StepLimit()
        r = code[pc](m)
        if r is None: pc += 1
        elif r == STOP: return
        else: pc = r
