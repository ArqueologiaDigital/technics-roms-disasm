#!/usr/bin/env python3
"""stdiv2xr-predict.py -- predict the cc900 oracle's code for the stdiv2.c probe compiled with -Xr, from the name alone.

    predict('.sd2_i_d_XSD', set='Xr') -> ['ld DE,WA', 'add DE,DE', ...]      (no function label)
    python3 stdiv2xr-predict.py --check [FILTER] [--set Xr|O3XSXr|O3XS]   score against the oracle (per family)
    python3 stdiv2xr-predict.py NAME [--set ...]                           print one prediction

Sets: Xr = -Xr (default), O3XSXr = -O3 -XS -Xr, O3XS = -O3 -XS with cdecl (parameters on the stack, `_sd2_` names).
The -O rules (self-address, coalescing, the long XIZ priority list, cdecl stack parameters) are in
stdiv2xr-FAMILIES.md, sections "-O3 -XS -Xr" and "-O3 -XS (cdecl)".

Names: sd2_<t>_<op>_<L><A><B>, t = i int, n unsigned long, c char; op = d (/) m (%); L = P D X E M; A = S D M E R;
B = S G D M E R K (stdiv2.c header).  -Xr: c in WA, d and e in BC and DE (XBC / XDE for unsigned long, C / E for char).

Method: the machinery of stdivxr-predict.py (stdiv.c at -Xr, 750 / 750).  Each operand letter is first resolved into
an addressing KIND, S taking the kind of the destination:

    P  a pointer's target, offset 0          (*gip; S of L = P)
    D  a member through a pointer, offset m  (hps->i; S of L = D; m = 2 int, 4 long, 0 char)
    X  an element at the parameter c         (gia[c]; S of L = X)
    N  a named object at symbol + offset     (hs.i, hia[2]; S of L = E, M)
    G  a plain global                        (ki)
    R  a parameter register                  (d for A, e for B)
    K  the constant 7

int and char: the statement becomes virtual instructions over named temporaries, the parameters are pre-coloured
temporaries that die at their last read, temporaries are coloured in a fixed order with preferences (lowest free pair
of WA BC DE HL IX IY IZ otherwise).  unsigned long: a call to C9H_divlu / C9H_remlu built from fixed pieces in four
phases with a small frame, as in stdivxr.  Nothing is looked up by function name.
"""
import re
import sys

PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
PARAMS = {'pC': 'WA', 'pD': 'BC', 'pE': 'DE'}
LISTING = '/home/fsanches/compartilhado/technics-roms-disasm/scripts/analysis/cc900/model'


def hx(n):
    return '0x%x' % n


def sym(base, off):
    return '%s + %s' % (base, hx(off)) if off else base


class Reg:
    """a register pair formatted by spec: '' 16 bit, x 32 bit, b low byte, h high byte, q the Q-word name"""

    def __init__(self, p):
        self.p = p

    def __format__(self, spec):
        p = self.p
        return {'': p, 'x': 'X' + p, 'b': LOW.get(p, '?'), 'h': HIGH.get(p, '?'), 'q': 'Q' + p}[spec]


class Ins:
    def __init__(self, text, copy=None, when=None):
        self.text, self.copy = text, copy        # copy = (dst, src): dropped when both got the same pair
        self.when = when                         # (a, b, same): emitted only when (reg a == reg b) == same
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text)


class Body:
    """a statement as virtual instructions, coloured by colour(order, widths, prefs)"""

    def __init__(self):
        self.seq = []

    def e(self, text, copy=None, when=None):
        self.seq.append(Ins(text, copy, when))

    def colour(self, order, width, pref, avoid=None, coalesce=()):
        """avoid: {temp: param} -- the temp may not share the param's register even where their intervals only touch.
        coalesce (-O): (a, b, mode) after the colouring, in order: a takes b's register when it is free over a's
        whole interval and a has not been merged before; mode 'ab' lets b take a's register when a is fixed.
        Parameters never move; a merged pair is fixed."""
        avoid = avoid or {}
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
            return width(n)

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
            if n in avoid and avoid[n] in reg:
                busy |= cells(reg[avoid[n]], 16)
            fr = [p for p in pool if not (cells(p, w) & busy)]
            want = pref.get(n)
            if want in reg:
                want = reg[want]
            reg[n] = want if want in fr else fr[0]
        fixed = set(PARAMS)

        def free_for(n, r, other):
            s, e_ = iv[n]
            busy = set()
            for o, r2 in reg.items():
                if o in (n, other):
                    continue
                s2, e2 = iv[o]
                if s < e2 and s2 < e_:
                    busy |= cells(r2, wd(o))
            return not (cells(r, wd(n)) & busy)

        for a, b, mode in coalesce:
            if a not in reg or b not in reg:
                continue
            if reg[a] == reg[b]:
                fixed |= {a, b}
                continue
            if a not in fixed and free_for(a, reg[b], b):
                reg[a] = reg[b]
                fixed |= {a, b}
            elif mode == 'ab' and a in fixed and b not in fixed and free_for(b, reg[a], a):
                reg[b] = reg[a]
                fixed |= {a, b}
        self.reg = reg
        out = []
        F = {n: Reg(r) for n, r in reg.items()}
        for ins in self.seq:
            if ins.copy and ins.copy[1] in reg and reg[ins.copy[0]] == reg[ins.copy[1]]:
                continue
            if ins.when and (reg.get(ins.when[0]) == reg.get(ins.when[1])) != ins.when[2]:
                continue
            out.append(ins.text.format(**F))
        return out


# ---------------------------------------------------------------------------------------------------------------
# operand kinds


def kinds(t, L, A, B):
    """(kind, symbol, offset) for the destination and both operands"""
    moff = {'i': 2, 'n': 4, 'c': 0}[t]
    esz = {'i': 2, 'n': 4, 'c': 1}[t]
    dest = {'P': ('P', '_g%sp' % t, 0), 'D': ('D', '_gps', moff), 'X': ('X', '_g%sa' % t, 0),
            'E': ('N', '_g%sa' % t, 3 * esz), 'M': ('N', '_gs', moff)}[L]

    def op(letter, side):
        if letter == 'S':
            return dest
        h = 'h' if side == 'A' else 'k'
        return {'D': ('D', '_%sps' % h, moff), 'M': ('N', '_%ss' % h, moff),
                'E': ('N', '_%s%sa' % (h, t), (2 if side == 'A' else 5) * esz), 'G': ('G', '_k%s' % t, 0),
                'R': ('R', None, 0), 'K': ('K', None, 7)}[letter]
    return dest, op(A, 'A'), op(B, 'B')


def disp(k):
    """a pointer read with a displacement: coloured before everything else"""
    return k[0] == 'D' and k[2] != 0


# ---------------------------------------------------------------------------------------------------------------
# int (16-bit divs XRR,src: quotient in RR, remainder in QRR)


def build_int(op, L, A, B, opt=False, xr=True):
    b = Body()
    e = b.e
    dk, ak, bk = kinds('i', L, A, B)
    dest_first = bk[0] in 'GRK'          # RULE dest-first: a divisor needing no address and no symbol + offset
    reuse = dest_first and A == 'S' and dk[0] == 'P'     # *gp = *gp / x: the dividend read through the store pointer
    self_ = opt and 'S' in (A, B)        # -O RULE self-address: L = L op B / L = A op L builds L's address once

    def self_addr():
        """-O: the object's address in DADDR, built once, read and written through (DADDR)"""
        if dk[0] in 'PD':
            e('ld {DADDR:x},(%s)' % dk[1])
            if dk[2]:
                e('inc %s,{DADDR:x}' % hx(dk[2]))
        elif dk[0] == 'N':
            e('lda {DADDR:x},%s' % sym(dk[1], dk[2]))
        else:                            # -Xr: the copy of c is hoisted to the top when emitted (see below)
            e('ld {SOFF},{pC}' if xr else 'ld {SOFF},(XSP+0x4)')
            e('add {SOFF},{SOFF}')
            e('lda {SBASE:x},%s' % dk[1])
            e('exts {SOFF:x}', when=('DADDR', 'SOFF', True))
            e('add {SOFF:x},{SBASE:x}', when=('DADDR', 'SOFF', True))
            e('lda {DADDR:x},{SBASE:x}+{SOFF}', when=('DADDR', 'SOFF', False))
        return '({DADDR:x})'

    def dest():
        if self_:
            return '({DADDR:x})'
        if dk[0] == 'N':
            return '(%s)' % sym(dk[1], dk[2])
        if dk[0] in 'PD':
            e('ld {DPTR:x},(%s)' % dk[1])
            return '({DPTR:x}+%s)' % hx(dk[2]) if dk[2] else '({DPTR:x})'
        e('ld {DOFF},{pC}', ('DOFF', 'pC')) if xr else e('ld {DOFF},(XSP+0x4)')
        e('add {DOFF},{DOFF}')
        e('lda {DBASE:x},%s' % dk[1])
        return '({DBASE:x}+{DOFF})'

    def addr(k, P):
        """the address code of an operand; returns its memory operand"""
        if self_ and (A if P == 'A' else B) == 'S':
            return self_addr()
        if k[0] in 'PD':
            if P == 'A' and reuse:
                return '({DPTR:x})'
            e('ld {%sPTR:x},(%s)' % (P, k[1]))
            return '({%sPTR:x}+%s)' % (P, hx(k[2])) if k[2] else '({%sPTR:x})' % P
        if k[0] == 'X':
            e('ld {%sOFF},{pC}' % P, (P + 'OFF', 'pC'))
            e('add {%sOFF},{%sOFF}' % (P, P))
            e('lda {%sBASE:x},%s' % (P, k[1]))
            return '({%sBASE:x}+{%sOFF})' % (P, P)
        if k[0] in 'NG':
            return '(%s)' % sym(k[1], k[2])
        if k[0] == 'R':
            if not xr:
                return '(XSP+0x6)' if P == 'A' else '(XSP+0x8)'
            return '{pD}' if P == 'A' else '{pE}'
        return hx(k[2])

    d = dest() if dest_first else None
    aop = addr(ak, 'A')
    bop = addr(bk, 'B')
    if ak[0] == 'R' and xr:
        e('ld {AVAL},{pD}', ('AVAL', 'pD'))
    else:
        e('ld {AVAL},%s' % aop)
    e('exts {AVAL:x}')
    e('divs {AVAL:x},%s' % bop)
    if op == 'd':
        e('ld {QUOT},{AVAL}', ('QUOT', 'AVAL'))
    else:
        e('ld {QUOT},{AVAL:q}')
    if not dest_first:
        d = dest()
    e('ld %s,{QUOT}' % d)
    e('ret')

    if self_:
        order = [n for n, k in (('APTR', ak), ('BPTR', bk)) if disp(k)] + \
                ['AVAL', 'SBASE', 'APTR', 'SOFF', 'DADDR', 'BPTR', 'QUOT']
    else:
        first = []                           # RULE: pointers read with a displacement are coloured first
        if dest_first and disp(dk):
            first.append('DPTR')
        if disp(ak):
            first.append('APTR')
        if disp(bk):
            first.append('BPTR')
        if dest_first:
            order = first + ['AOFF', 'AVAL', 'DPTR', 'ABASE', 'APTR', 'DOFF', 'DBASE', 'QUOT']
        else:
            order = first + ['APTR', 'AVAL', 'BOFF', 'BBASE', 'AOFF', 'ABASE', 'BPTR'] + \
                    {'P': ['QUOT', 'DPTR'], 'D': ['DPTR', 'QUOT'], 'X': ['DOFF', 'DBASE', 'QUOT'], 'N': ['QUOT']}[dk[0]]

    def width(n):
        if n in PARAMS or n in ('AOFF', 'BOFF', 'QUOT', 'DOFF', 'SOFF'):
            return 16
        return 32

    pref = {'AVAL': 'WA', 'AOFF': 'pC', 'BOFF': 'pC', 'DOFF': 'pC'}
    if op == 'd':
        pref['QUOT'] = 'AVAL'                # a remainder (ld QUOT,QAVAL) takes the lowest free pair
    co = []
    if opt:                                  # -O coalescing: the dividend takes d's register, then the quotient's
        co = [('AVAL', 'pD', 'a'), ('AVAL', 'QUOT', 'ab')] if op == 'd' else [('AVAL', 'pD', 'a')]
    out = b.colour(order, width, pref, avoid={'SOFF': 'pC'}, coalesce=co)
    if self_ and dk[0] == 'X' and xr:        # -O -Xr: the copy of c is emitted first (coloured in place)
        cp = 'ld %s,WA' % b.reg['SOFF']
        out.remove(cp)
        out.insert(0, cp)
    return out


# ---------------------------------------------------------------------------------------------------------------
# char (16 / 8 divs RR,src: quotient in the low byte, remainder in the high byte)


def build_char(op, L, A, B, opt=False, xr=True):
    b = Body()
    e = b.e
    dk, ak, bk = kinds('c', L, A, B)
    dest_first = bk[0] in 'GRK'
    reuse = dest_first and A == 'S' and dk[0] in 'PD'    # the member c is at offset 0: a plain pointer
    self_ = opt and 'S' in (A, B)        # -O RULE self-address (as int)

    def self_addr():
        if dk[0] in 'PD':
            e('ld {DADDR:x},(%s)' % dk[1])
        elif dk[0] == 'N':
            e('lda {DADDR:x},%s' % sym(dk[1], dk[2]))
        elif xr:
            e('lda {SBASE:x},%s' % dk[1])
            e('lda {DADDR:x},{SBASE:x}+{pC}')
        else:                            # cdecl: c from its stack slot, zero-extended into the sum
            e('lda {SBASE:x},%s' % dk[1])
            e('ld {DADDR},(XSP+0x4)')
            e('extz {DADDR:x}')
            e('add {DADDR:x},{SBASE:x}')
        return '({DADDR:x})'

    def dest():
        if self_:
            return '({DADDR:x})'
        if dk[0] == 'N':
            return '(%s)' % sym(dk[1], dk[2])
        if dk[0] in 'PD':
            e('ld {DPTR:x},(%s)' % dk[1])
            return '({DPTR:x})'
        if not xr:                       # cdecl: the element's whole address is built
            e('lda {DBASE:x},%s' % dk[1])
            e('ld {DADDR},(XSP+0x4)')
            e('extz {DADDR:x}')
            e('add {DADDR:x},{DBASE:x}')
            return '({DADDR:x})'
        e('lda {DBASE:x},%s' % dk[1])
        return '({DBASE:x}+{pC})'

    def addr(k, P):
        if self_ and (A if P == 'A' else B) == 'S':
            return self_addr()
        if k[0] in 'PD':
            if P == 'A' and reuse:
                return '({DPTR:x})'
            e('ld {%sPTR:x},(%s)' % (P, k[1]))
            return '({%sPTR:x})' % P
        if k[0] == 'X':
            e('lda {%sBASE:x},%s' % (P, k[1]))
            return '({%sBASE:x}+{pC})' % P
        if k[0] in 'NG':
            return '(%s)' % sym(k[1], k[2])
        if k[0] == 'R':
            if not xr:
                return '(XSP+0x6)' if P == 'A' else '(XSP+0x8)'
            return '{pD:b}' if P == 'A' else '{pE:b}'
        return hx(k[2])

    d = dest() if dest_first else None
    aop = addr(ak, 'A')
    bop = addr(bk, 'B')
    if ak[0] == 'R' and xr:
        e('ld {AVAL:b},{pD:b}', ('AVAL', 'pD'))
    else:
        e('ld {AVAL:b},%s' % aop)
    e('exts {AVAL}')
    e('divs {AVAL},%s' % bop)
    hi_direct = opt and op == 'm' and A == 'S' and L != 'M'   # -O: the remainder byte stored from the high half
    if hi_direct:
        e('ld (DADDR),{AVAL:h}'.replace('(DADDR)', '({DADDR:x})'))
        e('ret')
    else:
        if op == 'd':
            e('ld {RES8:b},{AVAL:b}', ('RES8', 'AVAL'))
        else:
            e('ld {RES8:b},{AVAL:h}')
        if not dest_first:
            d = dest()
        e('ld %s,{RES8:b}' % d)
        e('ret')

    if self_:
        order = ['AVAL', 'DADDR', 'SBASE', 'APTR', 'BPTR', 'RES8']
    elif dest_first:
        order = ['AVAL', 'DPTR', 'DADDR', 'ABASE', 'APTR', 'DBASE', 'RES8']
    else:
        order = ['AVAL', 'ABASE', 'APTR', 'BBASE', 'BPTR'] + \
                {'P': ['RES8', 'DPTR'], 'D': ['RES8', 'DPTR'], 'X': ['DBASE', 'RES8', 'DADDR'], 'N': ['RES8']}[dk[0]]

    def width(n):
        if n == 'RES8':
            return 8
        if n in PARAMS or n == 'AVAL':
            return 16
        return 32

    pref = {'AVAL': 'WA', 'RES8': 'AVAL', 'SBASE': 'DADDR'}
    co = []
    if opt:                              # -O: the dividend takes d's register; a quotient byte follows the dividend
        co = [('AVAL', 'pD', 'a')] + ([('RES8', 'AVAL', 'a')] if op == 'd' else [])
    return b.colour(order, width, pref, coalesce=co)


# ---------------------------------------------------------------------------------------------------------------
# unsigned long: cal C9H_{div,rem}lu with the dividend in XWA, the divisor in XBC, the result in XHL


def build_long(op, L, A, B):
    dk, ak, bk = kinds('n', L, A, B)
    helper = 'C9H_%slu' % ('div' if op == 'd' else 'rem')
    dest_first = bk[0] in 'GRK'
    # who owns XIZ: an operand read through a pointer with a displacement (D) or at the index c (X); B wins
    b_xiz = bk[0] in 'DX'
    a_xiz = ak[0] in 'DX' and not b_xiz
    a_spill = ak[0] in 'DX' and b_xiz and bk[0] == 'D'      # A's address to a 4-byte slot T (B = D took XIZ)
    a_reg = ak[0] in 'DN' and bk[0] == 'X'                  # A's address in XDE (B = X took XIZ)
    xiz_operand = a_xiz or b_xiz
    c_later = 'X' in (ak[0], bk[0])                          # c is read by an operand's index

    # ---- the destination's plan ----------------------------------------------------------------------------------
    if dest_first:
        if dk[0] == 'P':
            dform = 'SLOT4' if a_xiz else 'XIZ'
        elif dk[0] == 'D':
            dform = 'SLOT4' if a_xiz else 'XIZ'
        elif dk[0] == 'X':
            if a_xiz:
                dform = 'SLOT4'
            elif ak[0] in 'GR' and bk[0] in 'GR':
                dform = 'IZBASE'         # ga[c] = d / kn: offset in IZ, base in a 4-byte slot
            else:
                dform = 'XIZIDX'         # with a constant or a symbol + offset: the index through a slot, base in XIZ
        else:                            # N: materialized only when the dividend may alias it (S) or is indirect (D)
            dform = ('SLOT4' if a_xiz else 'XIZ') if ak[0] in 'DN' and (A == 'S' or ak[0] == 'D') else 'DIRECT'
    else:
        dform = ('CSPILL' if xiz_operand else 'CIZ') if dk[0] == 'X' else 'AFTER'

    # ---- frame layout: [T 4-byte address slot] [S 2-byte index slot] [C 2-byte saved c] ------------------------------
    off = 0
    slotT = slotS = slotC = None
    if dform in ('SLOT4', 'IZBASE') or a_spill:
        slotT = off
        off += 4
    if 'X' in (ak[0], bk[0]) or dform == 'XIZIDX':
        slotS = off
        off += 2
    if dform == 'CSPILL':
        slotC = off
        off += 2
    frame = off
    use_xiz = xiz_operand or dform in ('XIZ', 'XIZIDX', 'SLOT4')
    use_iz = dform in ('IZBASE', 'CIZ')
    push = 4 if use_xiz else 2 if use_iz else 0
    S = lambda o: '(XSP+%s)' % hx(o + push)

    out = []
    if frame:
        out.append('dec %s,XSP' % hx(frame))
    if push:
        out.append('push %s' % ('XIZ' if use_xiz else 'IZ'))

    # ---- the destination before the operands -----------------------------------------------------------------------
    store = []
    c_src = 'WA'                                     # where c is read from by an index dance
    if dform == 'CIZ':
        out.append('ld IZ,WA')
    elif dform == 'CSPILL':
        out.append('ld %s,WA' % S(slotC))
        c_src = S(slotC)
    elif dform == 'XIZ':
        if dk[0] == 'P':
            out.append('ld XIZ,(%s)' % dk[1])
            store = ['ld (XIZ),XHL']
        elif dk[0] == 'D':
            out.append('ld XIZ,(%s)' % dk[1])
            store = ['ld (XIZ+%s),XHL' % hx(dk[2])]
        else:
            out.append('lda XIZ,%s' % sym(dk[1], dk[2]))
            store = ['ld (XIZ),XHL']
    elif dform == 'SLOT4':
        T = S(slotT)
        if dk[0] == 'P':
            out += ['ld XWA,(%s)' % dk[1], 'ld %s,XWA' % T]
        elif dk[0] == 'D':
            out += ['ld XWA,(%s)' % dk[1], 'inc %s,XWA' % hx(dk[2]), 'ld %s,XWA' % T]
        elif dk[0] == 'N':
            out += ['lda XWA,%s' % sym(dk[1], dk[2]), 'ld %s,XWA' % T]
        else:            # X: c*4 + base; the offset in WA unless c is still needed (then the lowest free pair)
            live = set()
            if ak[0] == 'R':
                live.add('BC')
            if bk[0] == 'R':
                live.add('DE')
            free = [p for p in ('BC', 'DE', 'HL', 'IX') if p not in live]
            o = free.pop(0) if c_later else 'WA'
            base = free[0]
            if o != 'WA':
                out.append('ld %s,WA' % o)
            out += ['sla 0x2,%s' % o, 'lda X%s,%s' % (base, dk[1]), 'exts X%s' % o, 'add X%s,X%s' % (o, base),
                    'ld %s,X%s' % (T, o)]
        store = ['ld XWA,%s' % T, 'ld (XWA),XHL']
    elif dform == 'IZBASE':
        T = S(slotT)
        out += ['ld IZ,WA', 'sla 0x2,IZ', 'lda XWA,%s' % dk[1], 'ld %s,XWA' % T]
        store = ['ld XWA,%s' % T, 'ld (XWA+IZ),XHL']
    elif dform == 'XIZIDX':
        T = S(slotS)
        out += ['ld %s,WA' % T, 'ld WA,%s' % T, 'sla 0x2,WA', 'ld %s,WA' % T, 'lda XIZ,%s' % dk[1]]
        store = ['ld WA,%s' % T, 'ld (XIZ+WA),XHL']

    # ---- the operands in four phases -------------------------------------------------------------------------------
    ph = {1: [], 2: [], 3: [], 4: []}
    idx = S(slotS) if slotS is not None else None

    def dance(sym_):
        pre = ['ld WA,%s' % c_src] if c_src != 'WA' else []
        return pre + ['ld %s,WA' % idx, 'ld WA,%s' % idx, 'sla 0x2,WA', 'ld %s,WA' % idx, 'lda XIZ,%s' % sym_]

    d_reg = 'XBC'
    if ak[0] == 'R' and bk[0] == 'P':            # d's register is the divisor's pointer: d moves to XDE first
        out.append('ld XDE,XBC')
        d_reg = 'XDE'
    # dividend
    if ak[0] == 'P':
        if dform == 'XIZ' and A == 'S':           # *gp = *gp / x: the store pointer copied
            ph[1].append('ld XWA,XIZ')
        else:
            ph[1].append('ld XWA,(%s)' % ak[1])
        ph[4].append('ld XWA,(XWA)')
    elif ak[0] == 'D':
        if a_spill:
            ph[1] += ['ld XWA,(%s)' % ak[1], 'ld %s,XWA' % S(slotT)]
            ph[4] += ['ld XWA,%s' % S(slotT), 'ld XWA,(XWA+%s)' % hx(ak[2])]
        elif a_reg:
            ph[1] += ['ld XWA,(%s)' % ak[1], 'lda XDE,XWA+%s' % hx(ak[2])]
            ph[4].append('ld XWA,(XDE)')
        else:
            ph[1].append('ld XIZ,(%s)' % ak[1])
            ph[4].append('ld XWA,(XIZ+%s)' % hx(ak[2]))
    elif ak[0] == 'X':
        if a_spill:
            ph[1] += dance(ak[1])[:-1] + ['lda XWA,%s' % ak[1], 'ld %s,XWA' % S(slotT)]
            ph[4] += ['ld XWA,%s' % S(slotT), 'ld DE,%s' % idx, 'ld XWA,(XWA+DE)']
        else:
            ph[1] += dance(ak[1])
            ph[3].append('ld WA,%s' % idx)
            ph[4].append('ld XWA,(XIZ+WA)')
    elif ak[0] == 'N':
        if a_reg:
            ph[1].append('lda XDE,%s' % sym(ak[1], ak[2]))
            ph[4].append('ld XWA,(XDE)')
        else:
            ph[4].append('ld XWA,(%s)' % sym(ak[1], ak[2]))
    elif ak[0] == 'R':
        ph[2].append('ld XWA,%s' % d_reg)
    # divisor
    if bk[0] == 'G':
        ph[2].append('ld XBC,(%s)' % bk[1])
    elif bk[0] == 'R':
        ph[2].append('ld XBC,XDE')
    elif bk[0] == 'K':
        ph[4].append('ld XBC,0x7')
    elif bk[0] == 'N':
        ph[4].append('ld XBC,(%s)' % sym(bk[1], bk[2]))
    elif bk[0] == 'P':
        ph[1].append('ld XBC,(%s)' % bk[1])
        ph[4].append('ld XBC,(XBC)')
    elif bk[0] == 'D':
        ph[1].append('ld XIZ,(%s)' % bk[1])
        ph[4].append('ld XBC,(XIZ+%s)' % hx(bk[2]))
    else:
        ph[1] += dance(bk[1])
        ph[3].append('ld BC,%s' % idx)
        ph[4].append('ld XBC,(XIZ+BC)')
    for k in (1, 2, 3, 4):
        out += ph[k]
    out.append('cal %s' % helper)

    # ---- the store -------------------------------------------------------------------------------------------------
    if dform == 'DIRECT' or (dform == 'AFTER' and dk[0] == 'N'):
        out.append('ld (%s),XHL' % sym(dk[1], dk[2]))
    elif dform == 'AFTER':
        if dk[0] == 'P':
            out += ['ld XWA,(%s)' % dk[1], 'ld (XWA),XHL']
        else:
            out += ['ld XWA,(%s)' % dk[1], 'ld (XWA+%s),XHL' % hx(dk[2])]
    elif dform in ('CIZ', 'CSPILL'):
        out.append('ld WA,IZ' if dform == 'CIZ' else 'ld WA,%s' % S(slotC))
        out += ['sla 0x2,WA', 'lda XBC,%s' % dk[1], 'ld (XBC+WA),XHL']
    else:
        out += store
    if push:
        out.append('pop %s' % ('XIZ' if use_xiz else 'IZ'))
    if frame:
        out.append('inc %s,XSP' % hx(frame))
    out.append('ret')
    return out


def frame_ops(frame):
    """dec / inc take 1..8; a larger frame is lda XSP,XSP-n"""
    if frame <= 8:
        return 'dec %s,XSP' % hx(frame), 'inc %s,XSP' % hx(frame)
    return 'lda XSP,XSP-%s' % hx(frame), 'lda XSP,XSP+%s' % hx(frame)


def build_long_opt(op, L, A, B, xr=True):
    """unsigned long at -O3 -XS -Xr: the values that live across the helper call compete for XIZ, by priority;
    the losers go to stack slots"""
    dk, ak, bk = kinds('n', L, A, B)
    helper = 'C9H_%slu' % ('div' if op == 'd' else 'rem')
    dest_first = bk[0] in 'GRK'
    self_ = 'S' in (A, B)
    sk = dk[0]
    # ---- XIZ claimants, highest priority first ---------------------------------------------------------------------
    claims = []
    if self_ and sk == 'D':
        claims.append('S')
    if bk[0] == 'D' and B != 'S':
        claims.append('BD')
    if self_ and sk != 'D':
        claims.append('S')
    if ak[0] == 'D' and A != 'S':
        claims.append('AD')
    has_r = 'R' in (A, B)
    if not self_ and sk == 'X' and (dest_first or xr):
        claims.append('DX' if dest_first else 'C')       # (cdecl: c stays in its stack slot)
    if A == 'R' and xr:
        claims.append('pd')
    if B == 'R' and xr:
        claims.append('pe')
    # a named destination is materialized only beside an indirect dividend (or, cdecl, a stack parameter)
    if not self_ and dest_first and (sk in 'PD' or (sk == 'N' and (ak[0] == 'D' or (has_r and not xr)))):
        claims.append('DP')
    full = not xr and has_r              # cdecl RULE: beside a stack parameter the store address is built whole
    win = claims[0] if claims else None
    lose = set(claims[1:])
    ad_xde = 'AD' in lose and B == 'S' and sk == 'X'      # A's member address kept in XDE beside an element S
    an_xde = ak[0] == 'N' and B == 'S' and sk == 'X'      # A's symbol + offset materialized in XDE likewise

    # ---- frame: T (4) / S (2) / e (4) / d (4) / C (2) --------------------------------------------------------------
    off = 0
    slots = {}
    t_users = [c for c in ('S', 'BD', 'AD', 'DP') if c in lose and not (c == 'AD' and ad_xde)]
    if 'DX' in lose:
        t_users.append('DX')
    if t_users:
        slots['T'] = off
        off += 4
    if win == 'DX' and not full:
        slots['S'] = off
        off += 2
    for p_ in ('pe', 'pd'):
        if p_ in lose:
            slots[p_] = off
            off += 4
    if 'C' in lose:
        slots['C'] = off
        off += 2
    frame = off
    push = 2 if win == 'C' else 4 if win else 0
    Sl = lambda k: '(XSP+%s)' % hx(slots[k] + push)
    par = lambda o: '(XSP+%s)' % hx(4 + frame + push + o)          # cdecl: c +0, d +2, e +6
    cmem = par(0)
    out = []
    dec, inc = frame_ops(frame)
    if frame:
        out.append(dec)
    if push:
        out.append('push %s' % ('IZ' if push == 2 else 'XIZ'))

    # ---- parameter homes, c ------------------------------------------------------------------------------------------
    for p_, r in (('pe', 'XDE'), ('pd', 'XBC')):
        if p_ in lose:
            out.append('ld %s,%s' % (Sl(p_), r))
    for p_, r in (('pe', 'XDE'), ('pd', 'XBC')):
        if win == p_:
            out.append('ld XIZ,%s' % r)
    if win == 'C':
        out.append('ld IZ,WA')
    elif 'C' in lose:
        out.append('ld %s,WA' % Sl('C'))

    # ---- the destination first ---------------------------------------------------------------------------------------
    store = []
    if not self_ and dest_first:
        if sk in 'PD':
            if win == 'DP' and full and dk[2]:
                out += ['ld XWA,(%s)' % dk[1], 'lda XIZ,XWA+%s' % hx(dk[2])]
                store = ['ld (XIZ),XHL']
            elif win == 'DP':
                out.append('ld XIZ,(%s)' % dk[1])
                store = ['ld (XIZ+%s),XHL' % hx(dk[2])] if dk[2] else ['ld (XIZ),XHL']
            elif sk == 'D' and win == 'AD':
                out += ['ld XWA,(%s)' % dk[1], 'inc %s,XWA' % hx(dk[2]), 'ld %s,XWA' % Sl('T')]
                store = ['ld XWA,%s' % Sl('T'), 'ld (XWA),XHL']
            else:
                out += ['ld XWA,(%s)' % dk[1], 'ld %s,XWA' % Sl('T')]
                store = ['ld XWA,%s' % Sl('T'), 'ld (XWA+%s),XHL' % hx(dk[2]) if dk[2] else 'ld (XWA),XHL']
        elif sk == 'X':
            if win == 'DX' and full:
                out += ['ld WA,%s' % cmem, 'sla 0x2,WA', 'lda XBC,%s' % dk[1], 'lda XIZ,XBC+WA']
                store = ['ld (XIZ),XHL']
            elif win == 'DX':
                S_ = Sl('S')
                out += ([] if xr else ['ld WA,%s' % cmem]) + ['ld %s,WA' % S_, 'ld WA,%s' % S_, 'sla 0x2,WA', 'ld %s,WA' % S_, 'lda XIZ,%s' % dk[1]]
                store = ['ld WA,%s' % S_, 'ld (XIZ+WA),XHL']
            else:
                out += ([] if xr else ['ld WA,%s' % cmem]) + ['sla 0x2,WA', 'lda XBC,%s' % dk[1], 'exts XWA', 'add XWA,XBC', 'ld %s,XWA' % Sl('T')]
                store = ['ld XWA,%s' % Sl('T'), 'ld (XWA),XHL']
        elif sk == 'N' and win == 'AD':
            out += ['lda XWA,%s' % sym(dk[1], dk[2]), 'ld %s,XWA' % Sl('T')]
            store = ['ld XWA,%s' % Sl('T'), 'ld (XWA),XHL']
        elif sk == 'N' and win == 'DP':
            out.append('lda XIZ,%s' % sym(dk[1], dk[2]))
            store = ['ld (XIZ),XHL']

    # ---- phase 1: addresses, A then B --------------------------------------------------------------------------------
    def self_code():
        w = win == 'S'
        if sk == 'P':
            return ['ld XIZ,(%s)' % dk[1]] if w else ['ld XWA,(%s)' % dk[1], 'ld %s,XWA' % Sl('T')]
        if sk == 'D':
            return ['ld XIZ,(%s)' % dk[1], 'inc %s,XIZ' % hx(dk[2])]
        if sk == 'N':
            return ['lda XIZ,%s' % sym(dk[1], dk[2])] if w else \
                   ['lda XWA,%s' % sym(dk[1], dk[2]), 'ld %s,XWA' % Sl('T')]
        an = ['lda XDE,%s' % sym(ak[1], ak[2])] if an_xde else []
        c = (['ld BC,WA'] + an if xr else an + ['ld BC,%s' % cmem]) + ['sla 0x2,BC', 'lda XWA,%s' % dk[1]]
        return c + (['lda XIZ,XWA+BC'] if w else ['lda XWA,XWA+BC', 'ld %s,XWA' % Sl('T')])

    if A == 'S':
        out += self_code()
    elif ak[0] == 'D':
        if win == 'AD':
            out.append('ld XIZ,(%s)' % ak[1])
        elif ad_xde:                     # (-Xr: c still in WA, so the pointer passes through XBC)
            t_ = 'XBC' if xr else 'XWA'
            out += ['ld %s,(%s)' % (t_, ak[1]), 'lda XDE,%s+%s' % (t_, hx(ak[2]))]
        else:
            out += ['ld XWA,(%s)' % ak[1], 'ld %s,XWA' % Sl('T')]
    if B == 'S':
        out += self_code()
    elif bk[0] == 'D':
        out += ['ld XIZ,(%s)' % bk[1]] if win == 'BD' else ['ld XWA,(%s)' % bk[1], 'ld %s,XWA' % Sl('T')]

    # ---- finals ------------------------------------------------------------------------------------------------------
    def param(p_, dst):
        if not xr:
            return 'ld %s,%s' % (dst, par(2 if p_ == 'pd' else 6))
        return 'ld %s,XIZ' % dst if win == p_ else 'ld %s,%s' % (dst, Sl(p_))

    if A == 'S':
        fa = ['ld XWA,(XIZ)'] if win == 'S' else ['ld XWA,%s' % Sl('T'), 'ld XWA,(XWA)']
    elif ak[0] == 'D':
        fa = ['ld XWA,(XIZ+%s)' % hx(ak[2])] if win == 'AD' else ['ld XWA,(XDE)'] if ad_xde else \
             ['ld XWA,%s' % Sl('T'), 'ld XWA,(XWA+%s)' % hx(ak[2])]
    elif ak[0] == 'N':
        fa = ['ld XWA,(XDE)'] if an_xde else ['ld XWA,(%s)' % sym(ak[1], ak[2])]
    else:
        fa = [param('pd', 'XWA')]
    if B == 'S':
        fb = ['ld XBC,(XIZ)']
    elif bk[0] == 'D':
        fb = ['ld XBC,(XIZ+%s)' % hx(bk[2])] if win == 'BD' else ['ld XBC,%s' % Sl('T'), 'ld XBC,(XBC+%s)' % hx(bk[2])]
    elif bk[0] == 'R':
        fb = [param('pe', 'XBC')]
    elif bk[0] == 'K':
        fb = ['ld XBC,0x7']
    else:
        fb = ['ld XBC,(%s)' % sym(bk[1], bk[2])]
    out += (fb + fa) if B == 'S' else (fa + fb)       # RULE: the object itself as divisor is read first
    out.append('cal %s' % helper)

    # ---- the store ---------------------------------------------------------------------------------------------------
    if self_:
        out += ['ld (XIZ),XHL'] if win == 'S' else ['ld XWA,%s' % Sl('T'), 'ld (XWA),XHL']
    elif store:
        out += store
    elif sk == 'N':
        out.append('ld (%s),XHL' % sym(dk[1], dk[2]))
    elif sk in 'PD':
        out += ['ld XWA,(%s)' % dk[1], 'ld (XWA+%s),XHL' % hx(dk[2]) if dk[2] else 'ld (XWA),XHL']
    else:
        src = cmem if not xr else 'IZ' if win == 'C' else Sl('C')
        if A == 'R' and xr:
            out += ['ld BC,%s' % src, 'sla 0x2,BC', 'lda XWA,%s' % dk[1], 'ld (XWA+BC),XHL']
        else:
            out += ['ld WA,%s' % src, 'sla 0x2,WA', 'lda XBC,%s' % dk[1], 'ld (XBC+WA),XHL']
    if push:
        out.append('pop %s' % ('IZ' if push == 2 else 'XIZ'))
    if frame:
        out.append(inc)
    out.append('ret')
    return out


def build_cdecl(t, op, L, A, B, opt):
    """cdecl (parameters on the stack: c at XSP+4, then d and e), only -O3 -XS is predicted"""
    if t == 'i':
        return build_int(op, L, A, B, opt, xr=False)
    if t == 'c':
        return build_char(op, L, A, B, opt, xr=False)
    return build_long_opt(op, L, A, B, xr=False)


SETS = {'Xr': (True, False), 'O3XSXr': (True, True), 'O3XS': (False, True)}     # set -> (register arguments, -O)
RUN = '/home/fsanches/compartilhado/cc900-oracle/runs/2026-11-13-1-micro-stdiv2/out/v423/%s/probes/stdiv2.asm'


def predict(name, set='Xr'):
    m = re.fullmatch(r'[._]?sd2_([inc])_([dm])_([PDXEM])([SDMER])([SGDMERK])', name)
    t, op, L, A, B = m.groups()
    xr, opt = SETS[set]
    if not xr:
        return build_cdecl(t, op, L, A, B, opt)
    if t == 'i':
        return build_int(op, L, A, B, opt)
    if t == 'c':
        return build_char(op, L, A, B, opt)
    return build_long_opt(op, L, A, B) if opt else build_long(op, L, A, B)


# ---------------------------------------------------------------------------------------------------------------


def load_oracle(set='Xr'):
    sys.path.insert(0, LISTING)
    import listing
    d = listing.split(open(RUN % set, encoding='latin-1').read())
    out = {}
    for n, ls in d.items():
        body = [l for l in ls if l.startswith('\t')]      # instruction lines (labels and sections dropped)
        out[n] = [re.sub(r'\s+', ' ', l.strip(), count=1) for l in body]
    return out


def check(only=None, set='Xr', quiet=False):
    orc = load_oracle(set)
    fam, wrong = {}, []
    for n, exp in orc.items():
        if 'sd2_' not in n:
            continue
        t, op, shape = n.lstrip('._').split('_')[1:4]
        try:
            got = predict(n, set)
        except Exception as ex:          # noqa
            got = ['ERROR %r' % ex]
        ok = got == exp
        f = fam.setdefault((t, op, shape[0]), [0, 0])
        f[1] += 1
        f[0] += ok
        if not ok:
            wrong.append((n, exp, got))
    tot = sum(a for a, b in fam.values())
    print('set', set)
    for t in 'inc':
        row = []
        for op in 'dm':
            for L in 'PDXEM':
                a, b_ = fam.get((t, op, L), (0, 0))
                row.append('%s%s%s %2d/%2d' % (t, op, L, a, b_))
        print('  '.join(row))
    print('TOTAL %d / %d' % (tot, sum(b_ for a, b_ in fam.values())))
    if not quiet:
        for n, exp, got in wrong:
            if only and only not in n:
                continue
            print('WRONG', n)
            print('   exp: ' + ' ; '.join(exp))
            print('   got: ' + ' ; '.join(got))
    return tot


if __name__ == '__main__':
    args = sys.argv[1:]
    st = 'Xr'
    if '--set' in args:
        i = args.index('--set')
        st = args[i + 1]
        del args[i:i + 2]
    if args and args[0] == '--check':
        check(args[1] if len(args) > 1 else None, st)
    elif len(args) == 1:
        print(' ; '.join(predict(args[0], st)))
    else:
        print(__doc__)
