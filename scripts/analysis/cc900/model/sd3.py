"""L = A / B and L = A % B with an array element at a VARIABLE index, cdecl without -O (corpus/probes/stdiv3.c, run
2026-11-13-5-micro-stdiv3; the random corpora's guarded divisions, if (gua[t] != 0) gps->u = gua[4] / gua[t]).

The rules are the two predictors that reproduce the probe's 1,200 rows at none from the function name alone
(research-scratch sessions/2026-11-10_cc900-refusals/tabulation/stdiv3a-predict.py, int and unsigned int, and
stdiv3c-predict.py, char), here taking the real operands instead of the probe's names:

  - the statement is a fixed sequence of steps over temporaries (index copy, offsets, array bases, pointers, the
    dividend / quotient); each temporary takes the lowest register that no overlapping, already coloured temporary
    holds, in a fixed colouring order (colour_order for int, PRIO for char);
  - the index: an int parameter in memory is copied and doubled (ld BC,(c) / add BC,BC / lda XDE,_kia -> (XDE+BC)),
    an unsigned one is zero-extended into the base's sum (ld WA,(e) / extz XWA / add XWA,XWA / ld XBC,_kua /
    add XBC,XWA -> (XBC)); a char local doubles in A and moves to a byte register (ld A,QIZH / add A,QIZH / ld C,A /
    lda XDE,_kia -> (XDE+C)); a loop counter is copied and doubled like the int parameter; char arrays take the char
    or the counter as the register index directly ((XWA+QIZH), (XBC+HL)) and build sums for parameters;
  - a divisor that is plain memory or a constant: the destination's address first; an element divisor: the division
    first, the quotient waiting in a copy (ld DE,WA, the remainder ld DE,QWA) while the destination is addressed.

The index variable's home is the function's (QIZH, a byte register, a 16-bit register): it is reserved for the whole
statement when the variable is read again later, and for its own uses otherwise, which is what colouring it last
amounts to in the probe.  Anything outside the probe's shapes is declined (None) and left to the older paths.

stmt(F, lv, rv) -> True when it emitted the statement."""
import re
import codegen as cg

SD3 = True                                                 # the whole module behind one flag
WHY = [None]                                               # why classify declined last (for dbg_sd3.py)

PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
BYTE_HOME = {'C': ('BC', 'lo'), 'E': ('DE', 'lo'), 'L': ('HL', 'lo'), 'B': ('BC', 'hi'), 'D': ('DE', 'hi'), 'H': ('HL', 'hi')}


def hx(n): return '0x%x' % n


class Reg:
    """a register formatted by width: {t} 16 bit, {t:x} 32 bit, {t:b} 8 bit"""
    def __init__(self, p): self.p = p

    def __format__(self, spec):
        p = self.p
        if isinstance(p, str) and p.startswith('QIZ'): return p
        if isinstance(p, tuple): return {'lo': LOW[p[0]], 'hi': HIGH[p[0]]}[p[1]]
        return {'': p, 'x': 'X' + p, 'b': LOW.get(p), 'q': 'Q' + p}[spec]


class Ins:
    def __init__(self, text, tag='', men=()):
        self.text, self.tag = text, tag
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text) + list(men)


def off_op(reg, off): return '(%s+%s)' % (reg, hx(off)) if off else '(%s)' % reg


def clobber(sp):
    """a temporary took the index variable's home while the variable is live: not this home"""
    d = sp.get('decl'); msg = 'sd3: a temporary over the index home %s' % sp['idx']
    if d is not None and getattr(d, 'regtemp', False): raise cg.LiveClobber(msg, d)
    raise cg.Unsupported(msg)


# ---------------------------------------------------------------------------------------------- int / unsigned int
def plan_int(sp):
    """the statement's instructions for t = i / u, or None"""
    signed = sp['t'] == 'i'; op, I, L, A, B = sp['op'], sp['I'], sp['L'], sp['A'], sp['B']
    ext, dv = ('exts', 'divs') if signed else ('extz', 'div')
    seq = []
    def e(text, tag='', men=()): seq.append(Ins(text, tag, men))
    users = [u for u, f in (('A', A[0] == 'X'), ('B', B[0] == 'X'), ('L', L[0] == 'X')) if f]
    has_idx = {'p': len(users) >= 2, 'u': len(users) >= 3}.get(I, True)   # a parameter in memory is copied to a
    mem = sp['idx'] if I in 'pu' else None                                # temporary when it is read often enough
    if I in 'pu' and has_idx: e('ld {IDX},%s' % mem)

    def elem(P, a):
        o, b = P + 'OFF', P + 'BASE'
        src = '{IDX}' if has_idx else mem
        if I in ('p', 'l'):
            e('ld {%s},%s' % (o, src if I == 'p' else '{IDX}'), 'copy:' + o)
            e('add {%s},{%s}' % (o, o)); e('lda {%s:x},%s' % (b, a))
            return '({%s:x}+{%s})' % (b, o)
        if I == 'u':
            e('ld {%s},%s' % (o, src), 'copy:' + o); e('extz {%s:x}' % o); e('add {%s:x},{%s:x}' % (o, o))
            e('ld {%s:x},%s' % (b, a)); e('add {%s:x},{%s:x}' % (b, o))
            return '({%s:x})' % b
        s = sp['idx'] if I == 'q' else '{IDX:b}'           # a char index: doubled in A, then moved
        acc = 'ACC' + P
        e('ld A,%s' % s, men=[acc]); e('add A,%s' % s, men=[acc]); e('ld {%s:b},A' % o, 'moveA:' + o, men=[acc])
        e('lda {%s:x},%s' % (b, a))
        return '({%s:x}+{%s:b})' % (b, o)

    def dest_addr():
        if L[0] in ('D', 'P'):
            e('ld {DPTR:x},%s' % L[1]); return off_op('{DPTR:x}', L[2] if L[0] == 'D' else 0)
        if L[0] == 'X': return elem('D', L[1])
        return L[1]

    dest_first = B[0] != 'X'
    dest = dest_addr() if dest_first else None
    if A[0] == 'X': aop = elem('A', A[1])
    elif A[0] == 'D': e('ld {APTR:x},%s' % A[1])
    bop = elem('B', B[1]) if B[0] == 'X' else (B[1] if B[0] != 'K' else hx(B[1]))
    if A[0] == 'K': e('ld {AVAL:x},%s' % hx(A[1]))
    elif A[0] == 'D': e('ld {AVAL},%s' % off_op('{APTR:x}', A[2]))
    elif A[0] == 'X': e('ld {AVAL},%s' % aop)
    else: e('ld {AVAL},%s' % A[1])
    if A[0] != 'K': e('%s {AVAL:x}' % ext)
    e('%s {AVAL:x},%s' % (dv, bop))
    e('QMOVE', 'qmove')
    if not dest_first: dest = dest_addr()
    e('ld %s,{QUOT}' % dest)
    info = dict(I=I, L=L[0], A=A[0], dest_first=dest_first, op=op)
    # ---- intervals
    iv = {}
    for i, ins in enumerate(seq):
        for n in ins.temps: iv.setdefault(n, [i, i])[1] = i
        if ins.tag == 'qmove':
            iv.setdefault('AVAL', [i, i])[1] = i; iv.setdefault('QUOT', [i, i])[0] = i
    names = list(iv)
    # ---- the colouring order
    o = [n for n in names if n.startswith('ACC')]
    if dest_first:
        if L[0] == 'D': o += ['DPTR']
        o += ['AOFF', 'AVAL', 'ABASE', 'IDX', 'DOFF', 'DBASE', 'DPTR', 'QUOT']
    else:
        if I == 'u': o += ['APTR', 'AVAL', 'IDX', 'BOFF', 'BBASE', 'AOFF', 'ABASE']
        elif A[0] == 'D': o += ['APTR', 'AVAL', 'BOFF', 'IDX', 'BBASE', 'AOFF', 'ABASE']
        else: o += ['APTR', 'AVAL', 'BOFF', 'BBASE', 'IDX', 'AOFF', 'ABASE']
        if L[0] in ('D', 'X'): o += ['DPTR', 'DOFF', 'QUOT', 'DBASE'] if I == 'u' else ['DPTR', 'DOFF', 'DBASE', 'QUOT']
        else: o += ['QUOT', 'DPTR']
    order = []
    for n in o + names:
        if n in names and n not in order: order.append(n)

    def width(n):
        if n.startswith('ACC'): return 8
        if n == 'IDX': return 8 if I in ('r', 'q') else 16
        if n.endswith('OFF'): return 8 if I in ('r', 'q') else (32 if I == 'u' else 16)
        return 16 if n == 'QUOT' else 32

    def atoms(p, w):
        if isinstance(p, tuple): return {p}
        if isinstance(p, str) and p.startswith('QIZ'): return set()
        cells = {(p, 'lo'), (p, 'hi')}
        if w == 32: cells.add((p, 'q'))
        return cells

    reg = {}; home = None
    if I in ('r', 'l', 'q') and 'IDX' in iv:               # the variable's home is the function's: the temporaries are
        home = sp['idx'] if I == 'q' else (BYTE_HOME[sp['idx']] if I == 'r' else sp['idx'])   # coloured without it (the
        order = [n for n in order if n != 'IDX']           # compiler colours variables last); a temporary that lands
        idx_iv = [-1, len(seq)] if sp.get('idx_live', True) else iv['IDX']   # on the live home makes the function's
        del iv['IDX']                                      # allocator try its next candidate (clobber, below)

    def free(n):
        s, e_ = iv[n]; busy = set()
        for o2, r in reg.items():
            s2, e2 = iv[o2]
            if s < e2 and s2 < e_: busy |= atoms(r, width(o2))
        w = width(n)
        if w == 8: return [(p, 'lo') for p in PAIRS[:4] if (p, 'lo') not in busy]
        return [p for p in PAIRS if not (atoms(p, w) & busy)]

    for n in order:
        fr = free(n)
        if n.startswith('ACC'): pick = ('WA', 'lo')
        elif not fr: return None
        elif n == 'AVAL': pick = 'WA' if 'WA' in fr else fr[0]
        elif n == 'QUOT':
            pick = reg['AVAL'] if dest_first else fr[0]
            if dest_first and pick not in fr: pick = fr[0]
        elif n == 'IDX':
            last = [i for i, ins in enumerate(seq) if ins.tag.startswith('copy:') and '{IDX' in ins.text]
            pref = seq[last[-1]].tag[5:] if last else None
            pick = reg[pref] if pref in reg and reg[pref] in fr else fr[0]
        else: pick = fr[0]
        reg[n] = pick
    if home is not None:
        hc = atoms(home, 16 if I == 'l' else 8)
        for n, r in reg.items():
            if (atoms(r, width(n)) & hc) and iv[n][0] < idx_iv[1] and idx_iv[0] < iv[n][1]: clobber(sp)
        reg['IDX'] = home
    R = {n: Reg(r) for n, r in reg.items()}
    out = []
    for ins in seq:
        txt = ins.text
        if ins.tag.startswith('copy:') and 'IDX' in ins.temps and reg.get(ins.tag[5:]) == reg.get('IDX'): continue
        if ins.tag.startswith('moveA:') and reg[ins.tag[6:]] == ('WA', 'lo'): continue
        if ins.tag == 'qmove':
            r0, r1 = reg['AVAL'], reg['QUOT']
            if op == 'd':
                if r0 == r1: continue
                txt = 'ld %s,%s' % (r1, r0)
            else: txt = 'ld %s,Q%s' % (r1, r0)
        else: txt = txt.format(**R)
        out.append(txt)
    return out


# --------------------------------------------------------------------------------------------------------- char
POOL = ['BC', 'DE', 'HL']


def plan_char(sp):
    """the statement's instructions for signed chars (promoted implicitly: the 16 / 8 division), or None"""
    op, I, L, A, B = sp['op'], sp['I'], sp['L'], sp['A'], sp['B']
    form = 'sum' if I in 'pu' else 'reg'
    cached = L[0] == 'X' and A[0] == 'X' and B[0] == 'X'   # an index read three times is loaded once
    if I == 'p' and cached: form = 'reg'
    pre = L[0] in 'XDP' and A[0] == 'X' and B[0] in 'GK'   # the destination's address before the division
    has = {'A': A[0] in 'XD', 'B': B[0] == 'X', 'D': L[0] in 'XDP', 'Q': L[0] == 'X' and not pre}
    T = {}                                                 # positions: 0 dest-pre, 1 A, 2 B, 3 load A, 4 divs,
    if has['A']: T['A'] = (1, 3, ['WA'] if form == 'reg' else POOL)   # 5 move, 6 dest, 7 store
    if has['B']: T['B'] = (2, 4, POOL)
    if has['D']:
        if pre: T['D'] = (0, 7, POOL)
        elif L[0] == 'X' and form == 'reg': T['D'] = (6, 7, ['WA'])
        else: T['D'] = (6, 7, POOL)
    if has['Q']: T['Q'] = (4, 7, POOL)
    reg = {}
    if I not in 'rlq' and cached: T['I'] = (0, 6 if I == 'u' else 7, POOL)   # (r, l: the variable's home is the
                                                           # function's; the temporaries are coloured without it)
    prio = ['I', 'B', 'A', 'Q', 'D'] if (I == 'u' and cached) else ['B', 'A', 'Q', 'D', 'I']
    for n in prio:
        if n not in T or n in reg: continue
        s, e_, pool = T[n]
        busy = {reg[o] for o in reg if s < T[o][1] and T[o][0] < e_}
        fr = [r for r in pool if r not in busy]
        if not fr: return None
        reg[n] = fr[0]
    if I in 'rl':
        hf = sp['idx'] if I == 'l' else BYTE_HOME[sp['idx']][0]
        if hf in reg.values(): clobber(sp)                 # (conservative: any temporary in the home's family)
        if hf == 'WA': clobber(sp)
    X = lambda n: 'X' + reg[n]
    lo = lambda n: LOW[reg[n]]
    idx = sp['idx'] if I in 'qrl' else (reg.get('I') if I == 'p' else None)
    out = []

    def addr_temp(n, sym):
        if form == 'reg': out.append('lda %s,%s' % (X(n), sym))
        elif I == 'p':
            out.append('lda XWA,%s' % sym)
            out.append('ld %s,%s' % (reg[n], sp['idx'])); out.append('extz %s' % X(n)); out.append('add %s,XWA' % X(n))
        else:
            out.append('ld WA,%s' % (reg['I'] if cached else sp['idx']))
            out.append('extz XWA'); out.append('ld %s,%s' % (X(n), sym)); out.append('add %s,XWA' % X(n))

    def ref(n): return '(%s+%s)' % (X(n), idx) if form == 'reg' else '(%s)' % X(n)

    def dest_create():
        if L[0] == 'X': addr_temp('D', L[1])
        else: out.append('ld %s,%s' % (X('D'), L[1]))

    if I in 'pu' and cached: out.append('ld %s,%s' % (reg['I'], sp['idx']))
    if pre: dest_create()
    AP = 'XWA' if form == 'reg' else (X('A') if has['A'] else None)
    if A[0] == 'X': addr_temp('A', A[1])
    elif A[0] == 'D': out.append('ld %s,%s' % (AP, A[1]))
    if B[0] == 'X': addr_temp('B', B[1])
    if A[0] == 'K': out.append('ld WA,%s' % hx(A[1] & 0xffff))
    else:
        if A[0] == 'D': src = off_op(AP, A[2])
        elif A[0] == 'X': src = ref('A') if form == 'sum' else '(XWA+%s)' % idx
        else: src = A[1]
        out += ['ld A,%s' % src, 'exts WA']
    out.append('divs WA,%s' % (ref('B') if B[0] == 'X' else (B[1] if B[0] != 'K' else hx(B[1] & 0xffff))))
    res = 'A' if op == 'd' else 'W'
    if L[0] == 'G': out.append('ld %s,%s' % (L[1], res))
    elif L[0] == 'X' and not pre:
        out.append('ld %s,%s' % (lo('Q'), res)); dest_create()
        out.append('ld %s,%s' % (ref('D') if form == 'reg' else '(%s)' % X('D'), lo('Q')))
    else:
        if res == 'W': out.append('ld A,W')
        if L[0] == 'E': out.append('ld %s,A' % L[1])
        else:
            if not pre: dest_create()
            if L[0] == 'X': out.append('ld %s,A' % (ref('D') if form == 'reg' else '(%s)' % X('D')))
            else: out.append('ld %s,A' % off_op(X('D'), L[2] if L[0] == 'D' else 0))
    return out


# ------------------------------------------------------------------------------------------- the statement's shape
def classify(F, lv, rv):
    """the probe's letters for `lv = rv`, with the real operands; None when the statement is not one of its shapes"""
    x = cg.strip(rv)
    while x.k == 'cast' and x.kind == 'IntegralCast':
        if getattr(x, 'explicit', False): return None
        x = cg.strip(x.e)
    if x.k != 'bin' or x.op not in ('/', '%') or x.ty is None or x.ty.size != 2: return None
    lv = cg.strip(lv)
    if lv.ty is None or lv.ty.kind != 'int': return None
    if lv.ty.size == 1 and lv.ty.signed and x.ty.signed: t = 'c'
    elif lv.ty.size == 2: t = 'i' if lv.ty.signed else 'u'
    else: return None
    if t != 'c' and x.ty.signed != lv.ty.signed: return None
    esz = 1 if t == 'c' else 2
    idxs = []

    def same_ty(n): return n.ty is not None and n.ty.kind == 'int' and n.ty.size == esz and (n.ty.signed == (t != 'u'))

    def lkind(n, value):
        """the kind of the lvalue node n"""
        if not same_ty(n): return None
        if n.k == 'var':
            d = n.decl
            if getattr(d, 'reg', None): return None
            if d.kind == 'global': return ('G', '(_%s)' % d.name)
            if d.kind == 'param' and value and not getattr(d, 'homed', False) and not getattr(F, 'lazy_homes', None):
                return None                                # (a parameter operand: its load node is needed, see okind)
            return None
        if n.k == 'deref':
            pm = cg.sp_plain_ptr(F, n.e)
            return ('P', pm, 0) if pm is not None and pm.startswith('(_') else None
        if n.k == 'member' and n.arrow:
            pm = cg.sp_plain_ptr(F, n.base)
            return ('D', pm, cg.member_offset(n)) if pm is not None and pm.startswith('(_') else None
        if n.k == 'index' and cg.fold(n.idx).k != 'const':
            b = cg.strip(n.base)
            if b.k == 'member' and not b.arrow and cg.strip(b.base).k == 'var' and cg.strip(b.base).decl.kind == 'global' \
                    and b.ty is not None and b.ty.kind == 'array':   # gs.a[t]: the array's address is _gs + offset
                off = cg.member_offset(b); idxs.append(n.idx)
                return ('X', '_%s + %s' % (cg.strip(b.base).decl.name, hx(off)) if off else '_' + cg.strip(b.base).decl.name)
            if b.k != 'var' or b.decl.kind != 'global' or b.decl.ty.kind != 'array': return None
            idxs.append(n.idx); return ('X', '_' + b.decl.name)
        k = cg.sp_lvalue_kind(F, n)
        if k is not None and k[0] == 'S' and isinstance(k[1], str) and k[1].startswith('(_'): return ('E', k[1])
        return None

    def okind(y):
        y0 = cg.strip(y)
        while y0.k == 'cast' and y0.kind == 'IntegralCast':
            if getattr(y0, 'explicit', False): return None
            y0 = cg.strip(y0.e)
        c = cg.fold(y0)
        if c.k == 'const' and c.value is not None:
            return ('K', c.value) if 0 < c.value < 0x8000 else None
        if y0.k != 'load': return None
        n = cg.strip(y0.e)
        if n.k == 'var' and n.decl.kind == 'param' and not getattr(n.decl, 'reg', None) and same_ty(n):
            m = cg.mem_operand(F, y0)
            return ('R', m) if isinstance(m, str) and m.startswith('(XSP+') else None
        return lkind(n, True)

    L = lkind(lv, False)
    A, B = okind(x.l), okind(x.r)
    if L is None or A is None or B is None: WHY[0] = 'kinds %s %s %s' % (L, A, B); return None
    if A[0] == 'R' and getattr(F, 'lazy_homes', None): return None
    if B[0] == 'X':
        if A[0] == 'P': return None                        # (not probed: A is G, K, E, D, R or X)
    elif A[0] == 'X':
        if B[0] not in ('G', 'K'): return None             # (a static member / constant element divisor divides first:
                                                           #  stdiv2.c sd2_i_d_XSM, the older paths)
    else: return None
    if B[0] == 'K' and (B[1] & (B[1] - 1)) == 0: return None   # (a power of two: shifts, the older paths)
    if A[0] == 'K' and B[0] == 'K': return None
    if L[0] == 'P' and t == 'c' and A[0] != 'X' and B[0] != 'X': return None
    # ---- one index variable for every element
    decls = set(); node = None
    for ix in idxs:
        u = cg.unpromote(ix)
        if u.k != 'load' or cg.strip(u.e).k != 'var': return None
        decls.add(cg.strip(u.e).decl); node = u
    if len(decls) != 1: return None
    d = decls.pop()
    if d.ty.kind != 'int': return None
    m = cg.mem_operand(F, node)
    if not isinstance(m, str): return None
    home_fam = None
    if m.startswith('(XSP+') and d.ty.size == 2 and d.kind == 'param' and not getattr(d, 'reg', None):
        I = 'p' if d.ty.signed else 'u'; idx = m
    elif m in ('QIZH', 'QIZL') and d.ty.size == 1 and d.ty.signed: I = 'q'; idx = m
    elif m in BYTE_HOME and d.ty.size == 1 and d.ty.signed: I = 'r'; idx = m; home_fam = BYTE_HOME[m][0]
    elif m in ('BC', 'DE', 'HL', 'IX', 'IY', 'IZ') and d.ty.size == 2 and d.ty.signed: I = 'l'; idx = m; home_fam = m
    else: WHY[0] = 'index %s' % m; return None
    if any(r_ in ('WA', 'BC', 'DE', 'HL') and r_ != home_fam for r_ in cg.live_regs(F)): WHY[0] = 'live %s' % cg.live_regs(F); return None
    live = bool(getattr(F, 'loops', None)) or any(cg.uses_decl(s_, d) for s_ in (getattr(F, 'cur_rest', None) or []))
    if A[0] == 'E': A = ('G', A[1])                        # a constant element / static member reads as a global does
    if t != 'c' and L[0] == 'E': L = ('G', L[1])
    return dict(t=t, op='d' if x.op == '/' else 'm', I=I, L=L, A=A, B=B, idx=idx, idx_live=live, decl=d)


def stmt(F, lv, rv):
    if not SD3 or F.opt or F.adecl: return False
    sp = classify(F, lv, rv)
    if sp is None: return False
    lines = plan_char(sp) if sp['t'] == 'c' else plan_int(sp)
    if lines is None: return False
    for l in lines:
        op, _, args = l.partition(' ')
        F.emit(op, args or None)
    return True
