#!/usr/bin/env python3
"""stdivxr-predict.py -- predict the cc900 oracle's code for the stdiv.c probe compiled with -Xr, from the name alone.

    predict('.sd_i_d_XGX') -> ['add DE,DE', 'lda XHL,_wia', ...]      (no function label)
    python3 stdivxr-predict.py --check [FILTER]     score against the oracle listing (exact matches, per family)
    python3 stdivxr-predict.py NAME                 print one prediction

Names: sd_<t>_<op>_<L><A><B>, t = i u l n c, op = d (/) m (%), L = G P D X Q, A = G P X K, B = G P X K
(stdiv.c header).  -Xr: the parameters c, d, e arrive in WA, BC, DE.

Method (house style of stdiv3a-predict.py).  The statement L = A op B becomes a list of virtual instructions over
named temporaries; the three parameters are pre-coloured temporaries pC / pD / pE that live from the entry to their
last read.  Temporaries get registers by interval colouring in a fixed colouring order, each taking its preferred
register when that is free over its whole interval, else the lowest free one (WA BC DE HL IX IY IZ; byte
temporaries A C E L).  A copy whose source and destination got the same register is dropped.  The compiler's habits
live in (1) the order of the virtual instructions, (2) the colouring order, (3) the preferences.  Nothing is looked
up by name.  The long family (t = l, n) is a call to a C9H helper and is built from fixed pieces in four phases with
a small stack frame (see stdivxr-FAMILIES.md); its few free register choices also go through the colouring.
"""
import re
import sys

PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
PARAMS = {'pC': 'WA', 'pD': 'BC', 'pE': 'DE'}
ORACLE = '/home/fsanches/compartilhado/cc900-oracle/runs/2026-11-12-5-micro-stdiv/out/v423/Xr/probes/stdiv.asm'
LISTING = '/home/fsanches/compartilhado/technics-roms-disasm/scripts/analysis/cc900/model'


def hx(n):
    return '0x%x' % n


class Reg:
    """a register pair formatted by spec: '' 16 bit, x 32 bit, b low byte, h high byte, q the Q-word name"""

    def __init__(self, p):
        self.p = p

    def __format__(self, spec):
        p = self.p
        return {'': p, 'x': 'X' + p, 'b': LOW.get(p, '?'), 'h': HIGH.get(p, '?'), 'q': 'Q' + p}[spec]


class Ins:
    def __init__(self, text, copy=None):
        self.text, self.copy = text, copy        # copy = (dst, src): dropped when both got the same pair
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text)


class Body:
    """a statement as virtual instructions, coloured by colour(order, widths, prefs)"""

    def __init__(self):
        self.seq = []

    def e(self, text, copy=None):
        self.seq.append(Ins(text, copy))

    def colour(self, order, width, pref):
        iv = {}
        for i, ins in enumerate(self.seq):
            for n in ins.temps:
                iv.setdefault(n, [i, i])[1] = i
        for p in PARAMS:
            if p in iv:
                iv[p][0] = -1
        reg = {p: PARAMS[p] for p in PARAMS if p in iv}
        names = [n for n in order if n in iv] + [n for n in iv if n not in order and n not in PARAMS]

        def cells(r, w):
            if w == 8:
                return {(r, 'lo')}
            return {(r, 'lo'), (r, 'hi')} | ({(r, 'q')} if w == 32 else set())

        def wd(n):
            return 16 if n in PARAMS else width(n)

        for n in names:
            if n in reg:
                continue
            s, e_ = iv[n]
            busy = set()
            for o, r in reg.items():
                s2, e2 = iv[o]
                if s < e2 and s2 < e_:
                    busy |= cells(r, wd(o))
            w = wd(n)
            pool = PAIRS[:4] if w == 8 else PAIRS
            fr = [p for p in pool if not (cells(p, w) & busy)]
            want = pref.get(n)
            if want in reg:
                want = reg[want]
            reg[n] = want if want in fr else fr[0]
        self.reg = reg
        out = []
        F = {n: Reg(r) for n, r in reg.items()}
        for ins in self.seq:
            if ins.copy and reg[ins.copy[0]] == reg[ins.copy[1]]:
                continue
            out.append(ins.text.format(**F))
        return out


# ---------------------------------------------------------------------------------------------------------------
# int / unsigned int


def build_int(t, op, L, A, B):
    s = 'i' if t == 'i' else 'u'
    ext, dv = ('exts', 'divs') if t == 'i' else ('extz', 'div')
    b = Body()
    e = b.e
    dest_first = B in 'GK'       # RULE dest-first: a divisor that needs no register lets the destination go first

    def dest():
        if L == 'G':
            return '(_g%s)' % s
        if L == 'P':
            e('ld {DPTR:x},(_g%sp)' % s)
            return '({DPTR:x})'
        if L == 'D':
            e('ld {DPTR:x},(_gs%s)' % s)
            return '({DPTR:x}+0x2)'
        if L == 'X':
            e('ld {DOFF},{pC}', ('DOFF', 'pC'))
            e('add {DOFF},{DOFF}')
            e('lda {DBASE:x},_g%sa' % s)
            return '({DBASE:x}+{DOFF})'
        e('ld {DOFF},{pC}', ('DOFF', 'pC'))      # Q
        e('exts {DOFF:x}')
        e('add {DOFF:x},{DOFF:x}')
        e('ld {DADDR:x},{DOFF:x}', ('DADDR', 'DOFF'))
        e('add {DADDR:x},(_g%sp)' % s)
        return '({DADDR:x})'

    d = dest() if dest_first else None
    if A == 'P':
        e('ld {APTR:x},(_v%sp)' % s)
    elif A == 'X':
        e('ld {AOFF},{pD}', ('AOFF', 'pD'))
        e('add {AOFF},{AOFF}')
        e('lda {ABASE:x},_v%sa' % s)
    if B == 'P':
        e('ld {BPTR:x},(_w%sp)' % s)
        bop = '({BPTR:x})'
    elif B == 'X':
        e('ld {BOFF},{pE}', ('BOFF', 'pE'))
        e('add {BOFF},{BOFF}')
        e('lda {BBASE:x},_w%sa' % s)
        bop = '({BBASE:x}+{BOFF})'
    else:
        bop = '(_w%s)' % s if B == 'G' else '0x7'
    if A == 'K':
        e('ld {AVAL:x},0x64')
    else:
        e('ld {AVAL},%s' % {'G': '(_v%s)' % s, 'P': '({APTR:x})', 'X': '({ABASE:x}+{AOFF})'}[A])
        e('%s {AVAL:x}' % ext)
    e('%s {AVAL:x},%s' % (dv, bop))
    if op == 'd':
        e('ld {QUOT},{AVAL}', ('QUOT', 'AVAL'))
    else:
        e('ld {QUOT},{AVAL:q}')
    if not dest_first:
        d = dest()
    e('ld %s,{QUOT}' % d)
    e('ret')

    if dest_first:
        order = (['DPTR'] if L == 'D' else []) + ['AOFF', 'AVAL'] + (['DPTR'] if L == 'P' else []) + \
                ['ABASE', 'APTR', 'DOFF', 'DBASE', 'DADDR', 'QUOT']
    else:
        order = ['APTR', 'AVAL', 'BOFF', 'BBASE', 'AOFF', 'ABASE', 'BPTR'] + \
                {'G': ['QUOT'], 'P': ['QUOT', 'DPTR'], 'D': ['DPTR', 'QUOT'], 'X': ['DOFF', 'DBASE', 'QUOT'],
                 'Q': ['QUOT', 'DOFF', 'DADDR']}[L]

    def width(n):
        if n in ('AOFF', 'BOFF', 'QUOT') or (n == 'DOFF' and L == 'X'):
            return 16
        return 32

    pref = {'AVAL': 'WA', 'AOFF': 'pD', 'BOFF': 'pE', 'DOFF': 'pC', 'DADDR': 'DOFF', 'QUOT': 'AVAL'}
    return b.colour(order, width, pref)


# ---------------------------------------------------------------------------------------------------------------
# char (computed in int)


def build_char(op, L, A, B):
    b = Body()
    e = b.e
    byteform = B == 'G' or (A == 'K' and B in 'PX')       # divs WA,(mem8): quotient A, remainder W
    wordform = B in 'PX' and A != 'K'                       # divisor loaded and extended: divs XWA,BC
    dest_first = B == 'K'                                   # RULE: only a constant divisor lets the destination first

    def dest():
        if L == 'G':
            return '(_gc)'
        if L in 'PDQ':
            e('ld {DPTR:x},(%s)' % ('_gsi' if L == 'D' else '_gcp'))
            return '({DPTR:x}+{pC})' if L == 'Q' else '({DPTR:x})'
        e('lda {DBASE:x},_gca')
        return '({DBASE:x}+{pC})'

    d = dest() if dest_first else None
    if wordform:
        if B == 'P':
            e('ld {BPTR:x},(_wcp)')
            e('ld {BV8:b},({BPTR:x})')
        else:
            e('lda {BBASE:x},_wca')
            e('ld {BV8:b},({BBASE:x}+{pE})')
        e('ld {BEXT:b},{BV8:b}', ('BEXT', 'BV8'))
        e('exts {BEXT}')
        bop = '{BEXT}'
    elif B == 'P':
        e('ld {BPTR:x},(_wcp)')
        bop = '({BPTR:x})'
    elif B == 'X':
        e('lda {BBASE:x},_wca')
        bop = '({BBASE:x}+{pE})'
    else:
        bop = '(_wc)' if B == 'G' else '0x7'
    if A == 'P':
        e('ld {APTR:x},(_vcp)')
    elif A == 'X':
        e('lda {ABASE:x},_vca')
    if A == 'K':
        e('ld {AVAL},0x64')
    else:
        e('ld {AVAL:b},%s' % {'G': '(_vc)', 'P': '({APTR:x})', 'X': '({ABASE:x}+{pD})'}[A])
        e('exts {AVAL}')
    if byteform:
        e('divs {AVAL},%s' % bop)
    else:
        if A != 'K':
            e('exts {AVAL:x}')
        e('divs {AVAL:x},%s' % bop)
    # the byte result: quotient = low byte; remainder = high byte (16/8) or Q-word (32/16)
    if op == 'd':
        src, sname = '{AVAL:b}', 'AVAL'
    elif byteform:
        src, sname = '{AVAL:h}', None
    else:
        e('ld {QR},{AVAL:q}')
        src, sname = '{QR:b}', 'QR'
    if L == 'G':
        e('ld (_gc),%s' % src)
    else:
        e('ld {RES8:b},%s' % src, ('RES8', sname) if sname else None)     # the byte result, then the address
        if not dest_first:
            d = dest()
        e('ld %s,{RES8:b}' % d)
    e('ret')

    if dest_first:
        order = ['AVAL', 'DPTR', 'ABASE', 'APTR', 'DBASE', 'QR', 'RES8']
    else:
        order = ['AVAL', 'ABASE', 'APTR', 'BEXT', 'BBASE', 'BPTR', 'BV8'] + \
                {'G': ['QR'], 'P': ['QR', 'RES8', 'DPTR'], 'D': ['QR', 'RES8', 'DPTR'], 'X': ['DBASE', 'QR', 'RES8'],
                 'Q': ['DPTR', 'QR', 'RES8']}[L]

    def width(n):
        if n in ('BV8', 'RES8'):
            return 8
        if n in ('BEXT', 'QR') or (n == 'AVAL' and byteform):
            return 16
        return 32

    pref = {'AVAL': 'WA', 'QR': 'AVAL', 'RES8': sname or None}
    return b.colour(order, width, pref)


# ---------------------------------------------------------------------------------------------------------------
# long / unsigned long: a call to C9H_{div,rem}l{s,u} with the dividend in XWA, the divisor in XBC, the result in XHL


def build_long(t, op, L, A, B):
    s = 'l' if t == 'l' else 'n'
    st = '_gsi' if t == 'l' else '_gsu'
    helper = 'C9H_%sl%s' % ('div' if op == 'd' else 'rem', 's' if t == 'l' else 'u')
    dest_first = B in 'GK'
    xa_spill = A == 'X' and B != 'X'       # the X operand that takes XIZ (its index goes through a stack slot)
    xb_spill = B == 'X'
    xa_reg = A == 'X' and B == 'X'          # with two elements the dividend's address is computed in registers
    xiz_operand = xa_spill or xb_spill

    # ---- the destination's plan --------------------------------------------------------------------------------
    # dform: how the store address survives the call
    if dest_first:
        if L == 'G':
            dform = None
        elif L in 'PD':
            dform = 'SLOT4' if xa_spill else 'XIZ'
        elif L == 'Q':
            dform = 'SLOT4' if xa_spill else 'XIZ'
        else:                                                       # X
            if A == 'P':
                dform = 'XIZ'
            elif A == 'X':
                dform = 'SLOT4'
            elif 'K' not in (A, B):
                dform = 'IZBASE'          # ga[c] = vl op wl: offset in IZ, base in a 4-byte slot
            else:
                dform = 'XIZIDX'          # with a constant: the index through a 2-byte slot, base in XIZ
    else:
        dform = ('CSPILL' if xiz_operand else 'CIZ') if L in 'XQ' else 'AFTER'

    # ---- frame layout: [4-byte address slot] [2-byte index slot] [2-byte saved c] ------------------------------
    off = 0
    slot4 = slot_idx = slot_c = None
    if dform in ('SLOT4', 'IZBASE'):
        slot4 = off
        off += 4
    if xiz_operand or dform == 'XIZIDX':
        slot_idx = off
        off += 2
    if dform == 'CSPILL':
        slot_c = off
        off += 2
    frame = off
    use_xiz = xiz_operand or dform in ('XIZ', 'XIZIDX') or (dform == 'SLOT4')
    use_iz = dform in ('IZBASE', 'CIZ')
    push = 4 if use_xiz else 2 if use_iz else 0
    S = lambda o: '(XSP+%s)' % hx(o + push)

    out = []
    if frame:
        out.append('dec %s,XSP' % hx(frame))
    if push:
        out.append('push %s' % ('XIZ' if use_xiz else 'IZ'))

    # ---- the destination before the operands -------------------------------------------------------------------
    store = []
    if dform == 'CIZ':
        out.append('ld IZ,WA')
    elif dform == 'CSPILL':
        out.append('ld %s,WA' % S(slot_c))
    elif dform == 'XIZ':
        if L == 'P':
            out.append('ld XIZ,(_g%sp)' % s)
            store = ['ld (XIZ),XHL']
        elif L == 'D':
            if A == 'P':          # RULE: with a pointer dividend the member address is folded: lda XIZ,XWA+0x4
                out += ['ld XWA,(%s)' % st, 'lda XIZ,XWA+0x4']
                store = ['ld (XIZ),XHL']
            else:
                out.append('ld XIZ,(%s)' % st)
                store = ['ld (XIZ+0x4),XHL']
        elif L == 'Q':
            out += ['exts XWA', 'sll 0x2,XWA', 'ld XIZ,XWA', 'add XIZ,(_g%sp)' % s]
            store = ['ld (XIZ),XHL']
        else:
            out += ['sla 0x2,WA', 'lda XBC,_g%sa' % s, 'lda XIZ,XBC+WA']
            store = ['ld (XIZ),XHL']
    elif dform == 'SLOT4':
        T = S(slot4)
        if L == 'P':
            out += ['ld XWA,(_g%sp)' % s, 'ld %s,XWA' % T]
        elif L == 'D':
            out += ['ld XWA,(%s)' % st, 'inc 0x4,XWA', 'ld %s,XWA' % T]
        elif L == 'Q':
            out += ['exts XWA', 'sll 0x2,XWA', 'ld %s,XWA' % T, 'ld XWA,(_g%sp)' % s, 'add %s,XWA' % T]
        else:            # X with an element dividend: c*4 + base in XWA (base in the lowest pair free of d)
            out += ['sla 0x2,WA', 'lda XDE,_g%sa' % s, 'exts XWA', 'add XWA,XDE', 'ld %s,XWA' % T]
        store = ['ld XWA,%s' % T, 'ld (XWA),XHL']
    elif dform == 'IZBASE':
        T = S(slot4)
        out += ['ld IZ,WA', 'sla 0x2,IZ', 'lda XWA,_g%sa' % s, 'ld %s,XWA' % T]
        store = ['ld XWA,%s' % T, 'ld (XWA+IZ),XHL']
    elif dform == 'XIZIDX':
        T = S(slot_idx)
        out += ['ld %s,WA' % T, 'ld WA,%s' % T, 'sla 0x2,WA', 'ld %s,WA' % T, 'lda XIZ,_g%sa' % s]
        store = ['ld WA,%s' % T, 'ld (XIZ+WA),XHL']

    # ---- the operands in four phases ---------------------------------------------------------------------------
    ph = {1: [], 2: [], 3: [], 4: []}
    idx = S(slot_idx) if slot_idx is not None else None
    if dform == 'XIZIDX':
        idx = None          # (no X operand can share: B in G, K and A in G, K here)
    a_ptr = 'XHL' if B == 'X' else 'XWA'         # a pointer dividend held across the divisor's index code
    if A == 'G':
        ph[2].append('ld XWA,(_v%s)' % s)
    elif A == 'K':
        ph[4].append('ld XWA,0x64')
    elif A == 'P':
        ph[1].append('ld %s,(_v%sp)' % (a_ptr, s))
        ph[4].append('ld XWA,(%s)' % a_ptr)
    elif xa_reg:
        ph[1] += ['sla 0x2,BC', 'lda XWA,_v%sa' % s, 'lda XHL,XWA+BC']
        ph[4].append('ld XWA,(XHL)')
    else:
        ph[1] += ['ld %s,BC' % idx, 'ld WA,%s' % idx, 'sla 0x2,WA', 'ld %s,WA' % idx, 'lda XIZ,_v%sa' % s]
        ph[3].append('ld WA,%s' % idx)
        ph[4].append('ld XWA,(XIZ+WA)')
    if B == 'G':
        ph[2].append('ld XBC,(_w%s)' % s)
    elif B == 'K':
        ph[4].append('ld XBC,0x7')
    elif B == 'P':
        ph[1].append('ld XBC,(_w%sp)' % s)
        ph[4].append('ld XBC,(XBC)')
    else:
        ph[1] += ['ld %s,DE' % idx, 'ld WA,%s' % idx, 'sla 0x2,WA', 'ld %s,WA' % idx, 'lda XIZ,_w%sa' % s]
        ph[3].append('ld BC,%s' % idx)
        ph[4].append('ld XBC,(XIZ+BC)')
    for k in (1, 2, 3, 4):
        out += ph[k]
    out.append('cal %s' % helper)

    # ---- the store ---------------------------------------------------------------------------------------------
    if L == 'G':
        out.append('ld (_g%s),XHL' % s)
    elif dform == 'AFTER':
        if L == 'P':
            out += ['ld XWA,(_g%sp)' % s, 'ld (XWA),XHL']
        else:
            out += ['ld XWA,(%s)' % st, 'ld (XWA+0x4),XHL']
    elif dform in ('CIZ', 'CSPILL'):
        out.append('ld WA,IZ' if dform == 'CIZ' else 'ld WA,%s' % S(slot_c))
        if L == 'X':
            out += ['sla 0x2,WA', 'lda XBC,_g%sa' % s, 'ld (XBC+WA),XHL']
        else:
            out += ['exts XWA', 'sll 0x2,XWA', 'add XWA,(_g%sp)' % s, 'ld (XWA),XHL']
    else:
        out += store
    if push:
        out.append('pop %s' % ('XIZ' if use_xiz else 'IZ'))
    if frame:
        out.append('inc %s,XSP' % hx(frame))
    out.append('ret')
    return out


def predict(name):
    m = re.fullmatch(r'\.?sd_([iulnc])_([dm])_([GPDXQ])([GPXK])([GPXK])', name)
    t, op, L, A, B = m.groups()
    if t in 'iu':
        return build_int(t, op, L, A, B)
    if t == 'c':
        return build_char(op, L, A, B)
    return build_long(t, op, L, A, B)


# ---------------------------------------------------------------------------------------------------------------


def load_oracle():
    sys.path.insert(0, LISTING)
    import listing
    d = listing.split(open(ORACLE, encoding='latin-1').read())
    out = {}
    for n, ls in d.items():
        body = [l for l in ls if l.startswith('\t')]      # instruction lines (labels and sections dropped)
        out[n] = [re.sub(r'\s+', ' ', l.strip(), count=1) for l in body]
    return out


def check(only=None):
    orc = load_oracle()
    fam, wrong = {}, []
    for n, exp in orc.items():
        if not n.startswith('.sd_'):
            continue
        t, op, shape = n.split('_')[1:4]
        try:
            got = predict(n)
        except Exception as ex:          # noqa
            got = ['ERROR %r' % ex]
        ok = got == exp
        f = fam.setdefault((t, op, shape[0]), [0, 0])
        f[1] += 1
        f[0] += ok
        if not ok:
            wrong.append((n, exp, got))
    tot = sum(a for a, b in fam.values())
    for t in 'iunlc':
        row = []
        for op in 'dm':
            for L in 'GPDXQ':
                a, b_ = fam.get((t, op, L), (0, 0))
                row.append('%s%s%s %2d/%2d' % (t, op, L, a, b_))
        print('  '.join(row))
    print('TOTAL %d / %d' % (tot, sum(b_ for a, b_ in fam.values())))
    for n, exp, got in wrong:
        if only and only not in n:
            continue
        print('WRONG', n)
        print('   exp: ' + ' ; '.join(exp))
        print('   got: ' + ' ; '.join(got))
    return tot


if __name__ == '__main__':
    if len(sys.argv) >= 2 and sys.argv[1] == '--check':
        check(sys.argv[2] if len(sys.argv) > 2 else None)
    elif len(sys.argv) == 2:
        print(' ; '.join(predict(sys.argv[1])))
    else:
        print(__doc__)
