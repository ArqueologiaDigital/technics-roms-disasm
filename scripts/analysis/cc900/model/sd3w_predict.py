#!/usr/bin/env python3
"""stdiv3-predict.py -- predict the cc900 oracle's code for the stdiv3.c probe from the function name alone.

    predict('sd3_i_d_p_GXX', 'none') -> ['ld BC,(XSP+0x4)', 'ld WA,BC', ...]     (no function label)
    python3 stdiv3-predict.py --check --set SET [FILTER]    score against SET's listing, per family, list the wrong ones
    python3 stdiv3-predict.py NAME [--set SET]              print one prediction

SET: none (cdecl), O3XS (-O3 -XS, cdecl), Xr (-Xr), O3XSXr (-O3 -XS -Xr).  The name may carry the listing's prefix
(`_sd3_...` cdecl, `.sd3_...` -Xr) or none.  Labels are numbered as if the function were alone in the file
(the loop forms use L1 / L2); --check renumbers the listing's labels the same way.

Names: sd3_<t>_<op>_<I>_<L><A><B> (probe header): t i int, u unsigned, c char; op d `/`, m `%`; I the index:
p int parameter c, u unsigned parameter e, q char local kept across a call, r char local, l loop counter;
L destination G g, D gps->m, E ga[3], X ga[I], P *gp; A dividend G h, K 100, E ha[2], D hps->m, R parameter d,
X ha[I]; B divisor X ka[I] (or G k / K 7 when A = X).  Parameters: cdecl c (XSP+0x4), d (XSP+0x6), e (XSP+0x8);
-Xr c WA, d BC (char d in C), e DE.

Method.  The statement becomes virtual instructions over named temporaries; parameters (-Xr) are pre-coloured
temporaries live from the entry.  Temporaries are coloured by intervals in a fixed colouring ORDER, each taking its
PREFERRED register when that is free over its whole interval, else the lowest free one (WA BC DE HL IX IY IZ; bytes
A C E L, a char local C E L B D H QC QE QL).  A copy whose two sides got the same register is not emitted.  At -O a
retargeting pass then COALESCES listed copies (the source takes the destination's register when that is free over
the source's interval; nothing else moves).  The -O loop is strength-reduced to pointer induction variables and
has its own builder.  Nothing is looked up by name.  Rules and examples: stdiv3-FAMILIES.md.
"""
import collections
import re
import sys

ORACLE = '/home/fsanches/compartilhado/cc900-oracle/runs/2026-11-13-5-micro-stdiv3/out/v423/%s/probes/stdiv3.asm'
LISTING = '/home/fsanches/compartilhado/technics-roms-disasm/scripts/analysis/cc900/model'
SETS = {'none': (True, False), 'O3XS': (True, True), 'Xr': (False, False), 'O3XSXr': (False, True)}  # cdecl, -O

# =============================================================================================================
# the colouring engine

PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
BYTENAME = {
    'lo': {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'},
    'hi': {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'},
    'qlo': {'WA': 'QA', 'BC': 'QC', 'DE': 'QE', 'HL': 'QL'},
    'qhi': {'WA': 'QW', 'BC': 'QB', 'DE': 'QD', 'HL': 'QH', 'IZ': 'QIZH'},
}
LOWBYTES = [('WA', 'lo'), ('BC', 'lo'), ('DE', 'lo'), ('HL', 'lo')]
# byte registers a char local (I = r) may take, in preference order
IDX8_SLOTS = [('BC', 'lo'), ('DE', 'lo'), ('HL', 'lo'), ('BC', 'hi'), ('DE', 'hi'), ('HL', 'hi'),
              ('BC', 'qlo'), ('DE', 'qlo'), ('HL', 'qlo')]
QIZH = ('IZ', 'qhi')
A_ = ('WA', 'lo')
CPARAMS = {'pC': 'WA', 'pD': 'BC', 'pE': 'DE'}          # -Xr: c, d, e


class Reg:
    """a register: a pair ('BC') or a byte cell (('BC', 'lo')).  Spec for a pair: '' 16 bit, x 32 bit, b low byte,
    h high byte, q the Q-word.  A byte cell formats to its own name."""

    def __init__(self, r):
        self.r = r

    def __format__(self, spec):
        r = self.r
        if isinstance(r, tuple):
            return BYTENAME[r[1]][r[0]]
        return {'': r, 'x': 'X' + r, 'b': BYTENAME['lo'].get(r, '?'), 'h': BYTENAME['hi'].get(r, '?'),
                'q': 'Q' + r}[spec]


def cells(r, w):
    if isinstance(r, tuple):
        return {r}
    if w == 8:
        return {(r, 'lo')}
    c = {(r, 'lo'), (r, 'hi')}
    if w == 32:
        c |= {(r, 'qlo'), (r, 'qhi')}
    return c


class Ins:
    def __init__(self, text, copy=None):
        self.text, self.copy = text, copy        # copy = (dst, src): not emitted when both got the same register
        self.hoist = False                       # moved to the function entry after colouring
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text)


class Body:
    def __init__(self):
        self.seq = []
        self.loops = []          # (first, last) instruction index of a loop body

    def e(self, text, copy=None):
        self.seq.append(Ins(text, copy))
        return len(self.seq) - 1

    def intervals(self, params):
        iv = {}
        for i, ins in enumerate(self.seq):
            for n in ins.temps:
                iv.setdefault(n, [i, i])[1] = i
        for p in params:
            if p in iv:
                iv[p][0] = -1
        # a value live into a loop and read inside it lives to the loop's end (the back edge)
        for a, z in self.loops:
            for n, se in iv.items():
                if se[0] < a <= se[1] < z:
                    se[1] = z
        return iv

    def colour(self, order, width, pref, params=None, pools=None, coalesce=(), fixed=None):
        """order: colouring order; width(n) -> 8/16/32; pref: n -> register or temp name; params / fixed: n ->
        register (params live from the entry); pools: n -> candidate registers; coalesce: (src, dst[, cond])."""
        params, fixed, pools = params or {}, fixed or {}, pools or {}
        iv = self.intervals(params)
        reg = {p: r for p, r in params.items() if p in iv}
        reg.update({n: r for n, r in fixed.items() if n in iv})
        names = [n for n in order if n in iv] + [n for n in iv if n not in order]

        def busy_for(n, skip=()):
            s, e_ = iv[n]
            busy = set()
            for o, r in reg.items():
                if o == n or o in skip:
                    continue
                s2, e2 = iv[o]
                if s < e2 and s2 < e_:           # sharing an end point is not a conflict
                    busy |= cells(r, width(o))
            return busy

        for n in names:
            if n in reg:
                continue
            busy = busy_for(n)
            w = width(n)
            pool = pools.get(n) or (LOWBYTES if w == 8 else PAIRS)
            fr = [r for r in pool if not (cells(r, w) & busy)]
            want = pref.get(n)
            if isinstance(want, str) and want in reg:
                want = reg[want]
                if w == 8 and not isinstance(want, tuple):
                    want = (want, 'lo')
            reg[n] = want if want in fr else fr[0]
        # -O: retarget the source of a copy to the destination's register when that is free over its interval
        for c in coalesce:
            src, dst = c[0], c[1]
            if len(c) > 2 and not c[2](reg):
                continue
            if src not in reg or dst not in reg or src in params:
                continue
            r = reg[dst]
            if width(src) == 8 and not isinstance(r, tuple):
                r = (r, 'lo')
            if r != reg[src] and not (cells(r, width(src)) & busy_for(src, skip=(dst,))):
                reg[src] = r
        F = {n: Reg(r) for n, r in reg.items()}
        out, top = [], []
        for ins in self.seq:
            if ins.copy:
                d, s = ins.copy
                rd, rs = reg.get(d, d), reg.get(s, s)
                if rd == rs or rs == (rd, 'lo') or rd == (rs, 'lo'):
                    continue
            (top if ins.hoist else out).append(ins.text.format(**F))
        return post(top + out)


def post(lines):
    """a Q byte cannot be loaded from memory: `ld QC,(_jc)` goes through A, and A is then reused as it is"""
    out = []
    for l in lines:
        m = re.fullmatch(r'ld (Q[A-Z]+),\(_jc\)', l)
        if m:
            out += ['ld A,(_jc)', 'ld %s,A' % m.group(1)]
            continue
        if out and re.fullmatch(r'ld A,Q[A-Z]+', l) and out[-1] == 'ld %s,A' % l[5:]:
            continue
        out.append(l)
    return out


# =============================================================================================================
# int / unsigned int (no loop at -O)


def build_int(t, op, I, L, A, B, cdecl, O):
    s = 'i' if t == 'i' else 'u'
    ext, dv = ('exts', 'divs') if t == 'i' else ('extz', 'div')
    moff = 2 if t == 'i' else 4
    arr = lambda c: '_%s%sa' % (c, s)
    b = Body()
    e = b.e
    nusers = (A == 'X') + (B == 'X') + (L == 'X')
    cse = O and I != 'l'                 # -O: the doubled index is computed once
    # none: a parameter index read often enough is first loaded into a temporary IDX
    has_idx = cdecl and not cse and ((I == 'p' and nusers >= 2) or (I == 'u' and nusers >= 3))
    mem = {'p': '(XSP+0x4)', 'u': '(XSP+0x8)'}.get(I)
    params = {} if cdecl else dict(CPARAMS)
    fixed = {'QI': QIZH}
    width8 = set()
    qsave = I == 'q' and not cdecl and A == 'R'          # -Xr: d survives the call in IZ

    if I == 'q':
        if qsave:
            e('push XIZ')
            e('ld IZ,{pD}')
        else:
            e('push QIZ')
        e('ld A,(_jc)')
        e('ld QIZH,A')
        e('cal %s' % ('_f0' if cdecl else '.f0'))
    elif I == 'l':
        e('ld {IDX},0x0')
        e('cp {IDX},0x4')
        e('ret ge')
        loop0 = e('L2:')
    elif I == 'r':
        e('ld {IDX},(_jc)')
        width8.add('IDX')
    elif has_idx:
        e('ld {IDX},%s' % mem)
    lastcopy, accs, made = {}, [], []

    def elem(P, a):
        """the address of a[I] for operand P (A, B, D): emits its code, returns the operand"""
        o, bs = ('OFF' if cse else P + 'OFF'), P + 'BASE'
        first = not made
        made.append(P)
        compute = first or not cse
        if I in 'pl':                                  # 16-bit index: OFF = I + I, (BASE+OFF)
            if compute:
                if I == 'l' or has_idx:
                    e('ld {%s},{IDX}' % o, (o, 'IDX'))
                    lastcopy['IDX'] = o
                elif cdecl:
                    e('ld {%s},%s' % (o, mem))
                else:
                    e('ld {%s},{pC}' % o, (o, 'pC'))
                    # -O -Xr: the copy is coloured where it stands, then scheduled at the function entry
                    b.seq[-1].hoist = cse
                e('add {%s},{%s}' % (o, o))
            e('lda {%s:x},%s' % (bs, a))
            return '({%s:x}+{%s})' % (bs, o)
        if I == 'u':                                   # unsigned: zero-extend, double, add to the base
            if compute:
                if has_idx:
                    e('ld {%s},{IDX}' % o, (o, 'IDX'))
                    lastcopy['IDX'] = o
                elif cdecl:
                    e('ld {%s},%s' % (o, mem))
                else:
                    e('ld {%s},{pE}' % o, (o, 'pE'))
                e('extz {%s:x}' % o)
                e('add {%s:x},{%s:x}' % (o, o))
            e('ld {%s:x},%s' % (bs, a))
            e('add {%s:x},{%s:x}' % (bs, o))
            return '({%s:x})' % bs
        # char local (q in QIZH, r in a byte register): doubled in A, then moved to the offset byte
        src = '{QI}' if I == 'q' else '{IDX}'
        width8.add(o)
        if compute:
            acc = 'ACC' + P
            fixed[acc] = A_
            width8.add(acc)
            e('ld {%s},%s' % (acc, src))
            e('add {%s},%s' % (acc, src))
            e('ld {%s},{%s}' % (o, acc), (o, acc))
            accs.append(acc)
        e('lda {%s:x},%s' % (bs, a))
        return '({%s:x}+{%s})' % (bs, o)

    def dest_addr():
        if L == 'D':
            e('ld {DPTR:x},(_gps)')
            return '({DPTR:x}+0x%x)' % moff
        if L == 'P':
            e('ld {DPTR:x},(_g%sp)' % s)
            return '({DPTR:x})'
        if L == 'X':
            return elem('D', arr('g'))
        if L == 'G':
            return '(_g%s)' % s
        return '(%s + 0x6)' % arr('g')

    dest_first = B != 'X'                # a divisor that needs no register lets the destination go first
    dest = dest_addr() if dest_first else None
    if A == 'X':
        aop = elem('A', arr('h'))
    elif A == 'D':
        e('ld {APTR:x},(_hps)')
    bop = elem('B', arr('k')) if B == 'X' else ('(_k%s)' % s if B == 'G' else '0x7')
    if A == 'K':
        e('%s {AVAL:x},0x64' % ('lda' if O else 'ld'))
    else:
        if A == 'R':
            if cdecl:
                e('ld {AVAL},(XSP+0x%x)' % (8 if I == 'q' else 6))
            elif qsave:
                e('ld {AVAL},IZ')
            else:
                e('ld {AVAL},{pD}', ('AVAL', 'pD'))
        else:
            e('ld {AVAL},%s' % {'G': '(_h%s)' % s, 'E': '(%s + 0x4)' % arr('h'),
                                 'D': '({APTR:x}+0x%x)' % moff, 'X': A == 'X' and aop}[A])
        e('%s {AVAL:x}' % ext)
    e('%s {AVAL:x},%s' % (dv, bop))
    if op == 'd':
        e('ld {QUOT},{AVAL}', ('QUOT', 'AVAL'))
    else:
        e('ld {QUOT},{AVAL:q}')
    if not dest_first:
        dest = dest_addr()
    e('ld %s,{QUOT}' % dest)
    if I == 'q':
        e('pop XIZ' if qsave else 'pop QIZ')
    if I == 'l':
        e('inc 0x1,{IDX}')
        e('cp {IDX},0x4')
        loop1 = e('j lt,L2')
        e('L1:')
        b.loops.append((loop0, loop1))
    e('ret')

    # ---- colouring order
    o = ['ACCA', 'ACCB', 'ACCD']
    if dest_first:
        o += (['DPTR'] if L == 'D' else []) + ['AOFF', 'AVAL', 'ABASE', 'APTR', 'IDX', 'DOFF', 'DBASE', 'DPTR', 'QUOT']
    else:
        if I == 'u':
            o += ['APTR', 'AVAL', 'IDX', 'BOFF', 'BBASE', 'AOFF', 'ABASE']
        elif A == 'D':
            o += ['APTR', 'AVAL', 'BOFF', 'IDX', 'BBASE', 'AOFF', 'ABASE']
        else:
            o += ['APTR', 'AVAL', 'BOFF', 'BBASE', 'IDX', 'AOFF', 'ABASE']
        if L in 'DX':
            o += ['DPTR', 'DOFF', 'QUOT', 'DBASE'] if I == 'u' else ['DPTR', 'DOFF', 'DBASE', 'QUOT']
        else:
            o += ['QUOT', 'DPTR']
    if I in 'lr':                        # a loop counter / char local is a variable: coloured last
        o = [n for n in o if n != 'IDX'] + ['IDX']
    if cse:
        o.insert(o.index('AVAL') + 1, 'OFF')

    def width(n):
        if n in width8:
            return 8
        if n in ('IDX', 'QUOT', 'pC', 'pD', 'pE'):
            return 16
        if n.endswith('OFF'):
            return 32 if I == 'u' else 16
        return 32

    pref = {'AVAL': 'WA', 'QUOT': 'AVAL'}
    if not cdecl and I == 'p':
        pref.update(AOFF='pC', BOFF='pC', DOFF='pC', OFF='pC')
    if 'IDX' in lastcopy:
        pref['IDX'] = lastcopy['IDX']    # IDX takes the register of its last copy, which then disappears
    pools = {'IDX': IDX8_SLOTS} if I == 'r' else {}
    co = []
    if O:
        if op == 'd':
            co.append(('AVAL', 'QUOT'))                  # the dividend is built where the quotient is stored from
        if not cdecl and I == 'u':
            co.append(('OFF', 'pE'))                     # the unsigned index is extended in its own register
        if not cdecl and A == 'R' and not qsave:
            co.append(('AVAL', 'pD'))                    # the dividend is built in the parameter's register
            if op == 'd':
                co.append(('QUOT', 'AVAL'))
        # the doubled char index: A is retargeted to the offset's register, else the offset stays in A.
        # (fitted) a quotient copy that survived blocks the offset from staying in A (only r PRX at -O -Xr)
        kept = lambda r: not (op == 'd' and 'QUOT' in r and r['QUOT'] != r['AVAL'])
        co += [(a, 'OFF') for a in accs] + [('OFF', a, kept) for a in accs]
    return b.colour(order=o, width=width, pref=pref, params=params, pools=pools, fixed=fixed, coalesce=co)


# =============================================================================================================
# char (no loop at -O)


def build_char(op, I, L, A, B, cdecl, O):
    b = Body()
    e = b.e
    nusers = (A == 'X') + (B == 'X') + (L == 'X')
    cached = nusers == 3
    cse = O and I in 'pu' and nusers >= 2       # -O: an index read by two or more elements is read once
    # address form: 'sum' = base + zero-extended index added into one register, (XS); 'reg' = (XBASE+index)
    if I == 'u':
        form = 'sum'
    elif I == 'p':
        form = 'sum' if (cdecl and not cached and not cse) else 'reg'
    else:
        form = 'reg'
    pre = L in 'XDP' and A == 'X' and B in 'GK'      # destination address built before the division
    params = {} if cdecl else dict(CPARAMS)
    fixed = {'QI': QIZH, 'ACCR': A_, 'ACCB': A_, 'ACCD': A_}
    w8, w16 = {'RES8', 'ACCR', 'ACCB', 'ACCD'}, {'AVAL', 'pC', 'pD', 'pE'}
    pools = {}
    uidx = I == 'u' and cdecl and cached and not cse     # none, u, three users: the index loaded once into IDX
    # -Xr, q, A = R: the char parameter d must survive the call.  It is spilled to a stack slot; with an E or X
    # destination the local t goes to a slot too (no QIZ), and each use of t reloads it into A.
    qspill = I == 'q' and not cdecl and A == 'R'
    qslot = qspill and L in 'EX'
    ix = None
    if qslot:
        e('dec 0x4,XSP')
        e('ld (XSP+0x2),{pD:b}')
        e('ld A,(_jc)')
        e('ld (XSP),A')
        e('cal .f0')
        ix = 'SLOT'
    elif I == 'q':
        if qspill:
            e('dec 0x2,XSP')
        e('push QIZ')
        if qspill:
            e('ld (XSP+0x2),{pD:b}')
        e('ld A,(_jc)')
        e('ld QIZH,A')
        e('cal %s' % ('_f0' if cdecl else '.f0'))
        ix = '{QI}'
    elif I == 'l':
        e('ld {IDX},0x0')
        e('cp {IDX},0x4')
        e('ret ge')
        loop0 = e('L2:')
        ix = '{IDX}'
        w16.add('IDX')
    elif I == 'r':
        e('ld {IDX},(_jc)')
        ix = '{IDX}'
        w8.add('IDX')
        pools['IDX'] = IDX8_SLOTS
    elif I == 'p' and form == 'reg':
        if cdecl:
            if not cse:
                e('ld {IDX},(XSP+0x4)')
            ix = '{IDX}'
            w16.add('IDX')
        else:
            ix = '{pC}'
    elif uidx:
        e('ld {IDX},(XSP+0x8)')
        w16.add('IDX')
    made = []

    def elem(P, a):
        first = not made
        made.append(P)
        if form == 'reg':
            e('lda {%sBASE:x},%s' % (P, a))
            if cse and cdecl and first:
                e('ld {IDX},(XSP+0x4)')            # -O: c is loaded once, after the first base
            if ix == 'SLOT':
                # -O: t is reloaded once; the destination reuses the value the divisor loaded into A
                return '({%sBASE:x}+{ACC%s})' % (P, 'B' if (O and P == 'D') else P)
            return '({%sBASE:x}+%s)' % (P, ix)
        sb, si = P + 'SB', P + 'S'
        if I == 'p':                                # lda XWA,base / ld S,c / extz XS / add XS,XWA
            e('lda {%s:x},%s' % (sb, a))
            fixed[sb] = 'WA'
            e('ld {%s},(XSP+0x4)' % si)
            e('extz {%s:x}' % si)
            e('add {%s:x},{%s:x}' % (si, sb))
        else:                                       # ld WA,e / extz XWA / ld XS,base / add XS,XWA
            ui = 'UI' if cse else P + 'UI'
            if not cse:
                fixed[ui] = 'WA'
            if first or not cse:
                if uidx:
                    e('ld {%s},{IDX}' % ui)
                elif cdecl:
                    e('ld {%s},(XSP+0x8)' % ui)
                else:
                    e('ld {%s},{pE}' % ui, (ui, 'pE'))
                e('extz {%s:x}' % ui)
            e('ld {%s:x},%s' % (si, a))
            e('add {%s:x},{%s:x}' % (si, ui))
        return '({%s:x})' % si

    def dest():
        if L == 'G':
            return '(_gc)'
        if L == 'E':
            return '(_gca + 0x3)'
        if L in 'DP':
            e('ld {DPTR:x},(%s)' % ('_gps' if L == 'D' else '_gcp'))
            return '({DPTR:x})'
        return elem('D', '_gca')

    d = dest() if pre else None
    if A == 'X':
        amem = elem('A', '_hca')
    elif A == 'D':
        e('ld {APTR:x},(_hps)')
    bmem = elem('B', '_kca') if B == 'X' else {'G': '(_kc)', 'K': '0x7'}[B]
    if A == 'K':
        e('ld {AVAL},0x64')
    else:
        if A == 'R':
            if qspill:
                e('ld {ACCR},(XSP+0x2)')
                e('ld {AVAL:b},{ACCR}', ('AVAL', 'ACCR'))
            elif cdecl:
                e('ld {AVAL:b},(XSP+0x%x)' % (8 if I == 'q' else 6))
            else:
                e('ld {AVAL:b},{pD:b}', ('AVAL', 'pD'))
        else:
            e('ld {AVAL:b},%s' % {'G': '(_hc)', 'E': '(_hca + 0x2)', 'D': '({APTR:x})',
                                   'X': A == 'X' and amem}[A])
        e('exts {AVAL}')
    if ix == 'SLOT' and B == 'X':
        e('ld {ACCB},(XSP)')
    e('divs {AVAL},%s' % bmem)                      # 16 / 8: quotient in the low byte, remainder in the high
    src = '{AVAL:%s}' % ('b' if op == 'd' else 'h')
    if L == 'G':
        e('ld (_gc),%s' % src)
    else:
        if op == 'd':
            e('ld {RES8},{AVAL:b}', ('RES8', 'AVAL'))
        else:
            e('ld {RES8},{AVAL:h}')
        if not pre:
            d = dest()
        if ix == 'SLOT' and L == 'X' and not O:
            e('ld {ACCD},(XSP)')
        e('ld %s,{RES8}' % d)
    if qslot:
        e('inc 0x4,XSP')
    elif I == 'q':
        e('pop QIZ')
        if qspill:
            e('inc 0x2,XSP')
    if I == 'l':
        e('inc 0x1,{IDX}')
        e('cp {IDX},0x4')
        loop1 = e('j lt,L2')
        e('L1:')
        b.loops.append((loop0, loop1))
    e('ret')

    atemps, btemps = ['ABASE', 'AS', 'APTR'], ['BBASE', 'BS']
    order = ['AVAL'] + (['IDX'] if uidx else []) + ['UI']
    order += (btemps + atemps) if form == 'sum' else (atemps + btemps)
    if pre:
        order += ['RES8', 'DPTR', 'DBASE', 'DS']
    elif L == 'X':
        order += ['RES8', 'DS'] if form == 'sum' else ['DBASE', 'RES8']
    else:
        order += ['RES8', 'DPTR']
    if not uidx:
        order.append('IDX')

    def width(n):
        return 8 if n in w8 else 16 if n in w16 else 32

    pref = {'AVAL': 'WA', 'ABASE': 'WA', 'RES8': 'AVAL' if op == 'd' else None}
    co = []
    if O and not cdecl:
        co += [(n, 'pE') for n in ('UI', 'AUI', 'BUI', 'DUI')]     # the unsigned index extended in its own register
        if A == 'R' and not qspill:
            co.append(('AVAL', 'pD'))                                # the dividend built in the parameter's register
            if op == 'd':
                co.append(('RES8', 'AVAL'))
        if qspill:
            co.append(('ACCR', 'AVAL'))                              # the spilled d reloaded straight into place
    return b.colour(order=order, width=width, pref=pref, params=params, pools=pools, fixed=fixed, coalesce=co)


# =============================================================================================================
# -O loop: for (i = 0; i < 4; i++) L = A op B, strength-reduced to pointers


def build_loop(t, op, L, A, B, cdecl):
    char = t == 'c'
    size = 1 if char else 2
    moff = {'i': 2, 'u': 4, 'c': 0}[t]
    ext, dv = ('extz', 'div') if t == 'u' else ('exts', 'divs')
    arr = lambda c: '_%s%sa' % (c, t)
    b = Body()
    e = b.e
    params = {} if cdecl else dict(CPARAMS)
    w8, w16 = {'RES8'}, {'AVAL' if char else 'QUOT', 'pC', 'pD', 'pE'}
    pieces = ['L', 'A', 'B'] if B != 'X' else ['A', 'B', 'L']       # evaluation order (destination first or last)
    kind = {'L': L, 'A': A, 'B': B}
    ivs = [p for p in pieces if kind[p] == 'X']
    ctl = ivs[-1]                          # the last induction pointer evaluated controls the loop
    invs = []
    for p in pieces:                       # prelude: invariant addresses and induction pointers, evaluation order
        k = kind[p]
        c = {'L': 'g', 'A': 'h', 'B': 'k'}[p]
        if k == 'X':
            e('lda {%s:x},%s' % ('CBASE' if p == ctl else p + 'IV', arr(c)))
        elif k == 'E':
            e('lda {%sINV:x},%s + 0x%x' % (p, arr(c), (3 if p == 'L' else 2) * (1 if char else 2)))
            invs.append(p + 'INV')
        elif k == 'D':
            e('ld {%sINV:x},(_%sps)' % (p, c))
            if moff:
                e('inc 0x%x,{%sINV:x}' % (moff, p))
            invs.append(p + 'INV')
        elif k == 'P':
            e('ld {%sINV:x},(_g%sp)' % (p, t))
            invs.append(p + 'INV')
    e('ld {CIV:x},{CBASE:x}')
    e('lda {END:x},{CBASE:x}+0x%x' % (4 * size))
    loop0 = e('L1:')

    def opnd(p):
        k = kind[p]
        if k == 'X':
            return '({%s:x}+:%d)' % ('CIV' if p == ctl else p + 'IV', size)
        if k in 'EDP':
            return '({%sINV:x})' % p
        return '(_%s%s)' % ({'L': 'g', 'A': 'h', 'B': 'k'}[p], t)

    bsp = '' if char else ':x'
    if A == 'K':
        e('ld {AVAL},0x64' if char else 'lda {AVAL:x},0x64')
    else:
        lo = ':b' if char else ''
        if A == 'R':
            if cdecl:
                e('ld {AVAL%s},(XSP+0x6)' % lo)
            else:
                e('ld {AVAL%s},{pD%s}' % (lo, lo), ('AVAL', 'pD'))
        else:
            e('ld {AVAL%s},%s' % (lo, opnd('A')))
        e('%s {AVAL%s}' % (ext, bsp))
    bop = opnd('B') if B == 'X' else ('(_k%s)' % t if B == 'G' else '0x7')
    e('%s {AVAL%s},%s' % (dv, bsp, bop))
    if char:
        src = '{AVAL:%s}' % ('b' if op == 'd' else 'h')
        if L == 'G':
            e('ld (_gc),%s' % src)
        else:
            if op == 'd':
                e('ld {RES8},{AVAL:b}', ('RES8', 'AVAL'))
            else:
                e('ld {RES8},{AVAL:h}')
            e('ld %s,{RES8}' % opnd('L'))
    else:
        if op == 'd':
            e('ld {QUOT},{AVAL}', ('QUOT', 'AVAL'))
        else:
            e('ld {QUOT},{AVAL:q}')
        e('ld %s,{QUOT}' % opnd('L'))
    e('cp {CIV:x},{END:x}')
    loop1 = e('j ult,L1')
    b.loops.append((loop0, loop1))
    e('ret')

    others = [p + 'IV' for p in reversed(ivs) if p != ctl]
    order = ['AVAL', 'QUOT', 'RES8', 'CBASE', 'CIV'] + others + ['END'] + invs

    def width(n):
        return 8 if n in w8 else 16 if n in w16 else 32

    pref = {'AVAL': 'WA', 'QUOT': 'AVAL', 'RES8': 'AVAL' if op == 'd' else None}
    return b.colour(order=order, width=width, pref=pref, params=params)


# =============================================================================================================


def predict(name, set='none'):
    cdecl, O = SETS[set]
    m = re.fullmatch(r'[._]?sd3_([iuc])_([dm])_([puqrl])_([GDEXP])([GKEDRX])([XGK])', name)
    t, op, I, L, A, B = m.groups()
    if I == 'l' and O:
        return build_loop(t, op, L, A, B, cdecl)
    if t == 'c':
        return build_char(op, I, L, A, B, cdecl, O)
    return build_int(t, op, I, L, A, B, cdecl, O)


def load_oracle(set):
    """{name without prefix: instruction and label lines}, labels renumbered so the function's lowest is L1"""
    sys.path.insert(0, LISTING)
    import listing
    d = listing.split(open(ORACLE % set, encoding='latin-1').read())
    out = {}
    for n, ls in d.items():
        if 'sd3_' not in n:
            continue
        body = [re.sub(r'\s+', ' ', l.strip(), count=1) if l.startswith('\t') else l.strip() for l in ls[1:]]
        body = [l for l in body if not re.fullmatch(r'[._]sd3_\w+:', l)]
        labs = [int(x) for l in body for x in re.findall(r'\bL(\d+)\b', l)]
        if labs:
            base = min(labs) - 1
            body = [re.sub(r'\bL(\d+)\b', lambda mm: 'L%d' % (int(mm.group(1)) - base), l) for l in body]
        out[n[1:]] = body
    return out


def check(set, only=None):
    orc = load_oracle(set)
    fam = collections.OrderedDict(((t, I), [0, 0]) for t in 'iuc' for I in 'puqrl')
    wrong = []
    for n, exp in orc.items():
        t, op, I = n.split('_')[1:4]
        try:
            got = predict(n, set)
        except Exception as ex:          # noqa
            got = ['ERROR %r' % ex]
        f = fam[(t, I)]
        f[1] += 1
        f[0] += got == exp
        if got != exp:
            wrong.append((n, exp, got))
    print('set %s' % set)
    for t in 'iuc':
        print('  ' + '   '.join('%s%s %2d/%2d' % (t, I, *fam[(t, I)]) for I in 'puqrl'))
    print('TOTAL %d / %d' % (sum(a for a, z in fam.values()), sum(z for a, z in fam.values())))
    for n, exp, got in wrong:
        if only and only not in n:
            continue
        print('WRONG', n)
        print('   exp: ' + ' ; '.join(exp))
        print('   got: ' + ' ; '.join(got))
    return len(wrong)


if __name__ == '__main__':
    args = sys.argv[1:]
    set_ = 'none'
    if '--set' in args:
        i = args.index('--set')
        set_ = args[i + 1]
        del args[i:i + 2]
    if args and args[0] == '--check':
        sys.exit(1 if check(set_, args[1] if len(args) > 1 else None) else 0)
    elif len(args) == 1:
        print(' ; '.join(predict(args[0], set_)))
    else:
        print(__doc__)
