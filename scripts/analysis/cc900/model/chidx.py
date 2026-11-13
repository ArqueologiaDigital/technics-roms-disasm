"""Char indexes: the element address or pointer sum whose index is a char (probes/chidx.c, run 2026-11-10-4-micro-chidx;
found by the random corpus r1_02_12, r1_03_19, r1_04_01).  V4.23 keeps a signed char index in the byte wherever the
addressing mode takes an 8-bit index register, and zero-extends it whole for a char array; an unsigned char is
widened to a word first and scaled there.  The forms (cdecl, no options; im = the char's memory operand, g a global):

  signed c                                     | unsigned u
  g char[]:   lda XBC,_g / ld XWA,0x0 / ld A,im / add XWA,XBC / (XWA)      | ld A,im / extz WA / lda XBC,_g / (XBC+WA)
  g int[N]:   ld A,im / add A,im / lda XBC,_g / (XBC+A)                    | ld A,im / extz WA / add WA,WA / lda XBC,_g / (XBC+WA)
  g long[N]:  ld A,im / sla 0x2,A / lda XBC,_g / (XBC+A)                   | ... sla 0x2,WA ...
  x int[]:    ld A,im / exts WA / add WA,WA / lda XBC,_x / (XBC+WA)        | as the sized one
  gs.a[c]:    as g int[N] with the member's offset in the symbol           | as g int[N]
  gps->a[c]:  ld A,im / add A,im / ld C,A / ld XWA,(_gps) / (XWA+C)        | ld A / extz WA / ld BC,WA / add BC,BC / ld XWA,(_gps) / (XWA+BC)
  gp[c]:      ld XBC,(_gp) / ld XWA,0x0 / ld A,im / add XWA,XBC / (XWA)    | (not probed)
  gpi[c]:     ld A,im / exts WA / ld BC,WA / add BC,BC / ld XWA,(_gpi) / (XWA+BC)   | extz WA ...
  p[c] param: ld A,im / exts WA / add WA,WA / extz XWA / add XWA,(p) / (XWA)        | extz WA ...
  p[c] char:  ld XWA,0x0 / ld A,im / add XWA,(p) / (XWA)
  s->a[c]:    ld A,im / add A,im / ld W,0x0 / extz XWA / add XWA,(s) / (XWA)        | ld A / extz WA / add WA,WA / ld W,0x0 / extz XWA / add XWA,(s)
  a store of a computed value into g int[N] / g long[N]: the byte index moves to C and the base to XDE
              ld A,im / add A,im / ld C,A / lda XDE,_g / <value in WA> / ld (XDE+C),WA
  the same for an unsigned u: ld A / extz WA / ld BC,WA / add BC,BC / lda XDE,_g / <value> / op (XDE+BC),WA
  pointer sums (gen_ptr_arith): gpi + c: ld A,im / exts WA / ld HL,WA / add HL,HL / ld XWA,(_gpi) / extz XHL / add XHL,XWA
              gp + c: ld XWA,(_gp) / ld XHL,0x0 / ld L,im / add XHL,XWA;  p + c: ... extz XHL / add XHL,(p)
              gpi - c: ld A,im / exts WA / add WA,WA / exts XWA / ld XHL,(_gpi) / sub XHL,XWA
              &gca[c]: lda XWA,_gca / ld XHL,0x0 / ld L,im / add XHL,XWA
              &gia[c]: ld L,im / add L,im / lda XWA,_gia / ld H,0x0 / extz XHL / add XHL,XWA
              &gia[u]: ld A,im / extz WA / ld HL,WA / add HL,HL / lda XWA,_gia / extz XHL / add XHL,XWA
  an index that is a char expression (c + 1, c + d, u * 2) is computed in the byte first (fc2: ld A,im / inc 0x1,A /
  ld C,A / add A,C; gc2: ld A,(c) / add A,(d) / ld C,A / add A,C; fu2: ld A / add A,(u) / extz WA / add WA,WA), so
  gia[u * 2] reads element (u * 2) & 0xff: V4.23's own wrong code, imitated (semcheck says SAME once both do it).

Where the char is (`source`): in memory (cdecl), in a register parameter's byte (-Xr: A, C or E), a narrowing of an int
((char)i: hi2), or an expression.  The two scalings:
  - the byte scale by 2 is always a copy and an add, `ld T,S / add T,S`.  Without -O a char in memory is re-read
    (ld A,im / add A,im); under -O3 -XS it is first loaded into the other scratch byte (ld C,im / ld A,C / add A,C;
    ec2, whose home is L: ld A,im / ld L,A / add L,A); a register variable (-Xr) is copied into the first free byte
    (rc2: ld C,A / add C,A, the base then goes to XWA; oc2 with s in XWA: ld E,C / add E,C); a temporary in A (an
    expression, (char)i) uses C as the scratch and keeps the result in A (fc2: inc 0x1,A / ld C,A / add A,C).
  - a widening (exts / extz) to a word register R: without -O the byte is loaded into A, widened in WA and copied
    (ld A,im / exts WA / ld BC,WA); under -O3 -XS it is loaded into R's low byte and widened there (ld C,im / exts BC);
    a register variable is widened in its own register and copied (-Xr pc2: exts WA / ld BC,WA; -O3 -XS -Xr: ld C,A /
    exts BC).  p + c with p a parameter scales in the index's own register first and copies after under -O
    (bc2 -O3 -XS: exts WA / add WA,WA / ld HL,WA; without -O: exts WA / ld HL,WA / add HL,HL).
  - a byte scale by 4 (sla 0x2) is in place: in the home register (-O3 -XS sc4: ld C,im / sla 0x2,C), in the dead
    register parameter (-Xr rc4: sla 0x2,A; sc4: sla 0x2,A / ld C,A).
Under -Xr the (XBC+A) forms take the parameter's byte directly (rc1: lda XBC,_gca / ld L,(XBC+A); qc1 with p in XWA
and c in C: ld L,(XWA+C); oc4: sla 0x2,C / add C,0x14 / ld XHL,(XWA+C)), and the base register is the first family
that does not hold the index (rc2: lda XWA,_gia / (XWA+C)).

element(F, lv, kind, fam) -> an operand string (the address built), or None when the shape is not one of these.
kind: 'load', 'storek' (a constant stored: ldw / ldb (op),K), 'rmw' (op= with a constant: incw / addw; ++ / --), 'store'
(a computed value follows: the operand must survive its evaluation in WA).
"""
import codegen as cg

CHIDX = True                                               # the whole module behind one flag

FAM = {'WA': {1: 'A', 2: 'WA', 4: 'XWA'}, 'BC': {1: 'C', 2: 'BC', 4: 'XBC'}, 'DE': {1: 'E', 2: 'DE', 4: 'XDE'},
       'HL': {1: 'L', 2: 'HL', 4: 'XHL'}}                   # (codegen's FAM is not built yet when this module loads)
BYTE_FAM = {'A': 'WA', 'C': 'BC', 'E': 'DE', 'L': 'HL'}


def strip(e): return cg.strip(e)


def char_load(x):
    """the load of a char variable under integral casts, or None"""
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
    if x.k == 'load' and strip(x.e).k == 'var' and x.ty is not None and x.ty.size == 1: return x
    return None


def char_index(idx):
    """(node, signed, how) when the index is a char in memory or a register, a narrowing of an int, or a byte
    expression of chars; how: 'load' | 'narrow' | 'expr' | 'mul2'"""
    x = strip(idx)
    while x.k == 'cast' and x.kind == 'IntegralCast' and x.ty.size >= 2: x = strip(x.e)
    if x.k == 'bin' and x.op == '*' and x.ty is not None and x.ty.size == 2 and cg.fold(x.r).k == 'const' and \
            cg.fold(x.r).value == 2 and char_load(x.l) is not None:
        return char_load(x.l), char_load(x.l).ty.signed, 'mul2'   # fu2: gia[u * 2], the product in the byte
    if x.ty is None or x.ty.size != 1: return None
    if x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty is not None and strip(x.e).ty.size == 2:
        return x, x.ty.signed, 'narrow'                    # hi2: gia[(char)i]
    if x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty is not None and strip(x.e).ty.size == 1 and \
            strip(x.e).k == 'load' and strip(strip(x.e).e).k == 'var':
        return strip(x.e), x.ty.signed, 'load'             # hc2: gia[(unsigned char)c]: the cast's signedness
    if x.k == 'load' and strip(x.e).k == 'var':
        return x, x.ty.signed, 'load'
    if x.k == 'bin' and x.op in ('+', '-', '*') and getattr(x, 'narrowed', False) or (x.k == 'bin' and x.op in ('+', '-')):
        return x, x.ty.signed, 'expr'
    return None


def source(F, x, how):
    """where the char is: ('mem', im) | ('reg', byte, variable?) | ('narrow', int operand) | ('expr', node); None
    when it cannot be named.  'mul2' (u * 2) is computed here: the byte scale of its char, left as a temporary."""
    if how in ('load', 'mul2'):
        d = strip(x.e).decl
        if getattr(d, 'reg', None) == 'QIZH': src = ('mem', 'QIZH')   # (r1_04_07: ld A,QIZH / extz WA / ...)
        elif getattr(d, 'reg', None):
            b = FAM.get(d.reg, {}).get(1)
            if b is None or d.reg == 'XIZ': return None
            src = ('reg', b, True)
        else:
            im = cg.mem_operand(F, x)
            if im is None or im in ('A', 'C', 'E', 'L') or im.startswith('0x'): return None
            src = ('mem', im)
        if how == 'load': return src
        r = scale2_byte(F, src, None, set())
        return ('reg', r, False)
    if how == 'narrow':
        inner = strip(x.e)
        m = cg.reg_or_mem(F, inner, 2)
        if m is None or m.startswith('0x'): return None
        return ('narrow', m)
    return ('expr', x)


def busy_bytes(F, base):
    """the byte registers of register parameters the base expression still needs (-Xr oc2: s in XWA keeps A)"""
    busy = set()
    def visit(n, dep):
        if n.k == 'var' and getattr(n.decl, 'reg', None) in BYTE_FAM.values(): busy.add(FAM[n.decl.reg][1])
    cg.walk(base, visit)
    return busy


def ld(F, dst, src):
    if dst != src: F.emit('ld', '%s,%s' % (dst, src))


def put_byte(F, src, dst):
    """the char into byte register dst (a load, a copy, or nothing when it is there already)"""
    k = src[0]
    if k == 'mem': F.emit('ld', '%s,%s' % (dst, src[1]))
    elif k == 'reg': ld(F, dst, src[1])
    elif k == 'narrow':                                    # hi2: ld WA,(i) (-O: ld BC,(i)), the low byte is the char
        want = BYTE_FAM[dst]
        if src[1] != want: F.emit('ld', '%s,%s' % (want, src[1]))
    else:
        f = cg.gen(F, cg.narrow(src[1], 1), BYTE_FAM[dst], 1)
        ld(F, dst, FAM[f][1])


def temp_byte(F, src):
    """an expression or a narrowing as a byte temporary: ('reg', b, False); -O3 -XS cdecl computes it in C
    (fc2: ld C,(c) / inc 0x1,C; hi2: ld BC,(i)), the rest in A"""
    o, xr = bool(F.opt), bool(F.adecl)
    if src[0] == 'narrow':
        if xr and src[1] == 'WA' and not o: return ('reg', 'A', False)   # -Xr hi2: (char)i with i in WA: A as it is
        R = 'BC' if o else 'WA'
        F.emit('ld', '%s,%s' % (R, src[1])); return ('reg', FAM[R][1], False)
    if src[0] == 'expr':
        fam = 'BC' if o and not xr else 'WA'
        f = cg.gen(F, cg.narrow(src[1], 1), fam, 1)
        return ('reg', FAM[f][1], False)
    return src


def scale2_byte(F, src, home, busy):
    """the char doubled in a byte (an int element's index): ld T,S / add T,S; returns the register holding it, moved
    to `home` when one is asked (vc2: ld C,A)"""
    o, xr = bool(F.opt), bool(F.adecl)
    src = temp_byte(F, src)
    k = src[0]
    if k == 'mem':
        if not o:
            T = 'L' if home == 'L' else 'A'                # rc2: ld A,im / add A,im; ec2: ld L,im / add L,im
            F.emit('ld', '%s,%s' % (T, src[1])); F.emit('add', '%s,%s' % (T, src[1])); r = T
        else:
            S, T = ('A', 'L') if home == 'L' else ('C', 'A')   # -O3 -XS rc2: ld C,im / ld A,C / add A,C
            F.emit('ld', '%s,%s' % (S, src[1])); F.emit('ld', '%s,%s' % (T, S)); F.emit('add', '%s,%s' % (T, S)); r = T
    elif src[2]:                                           # a register variable: copied into the first free byte
        b = src[1]
        if home == 'L': T = 'L'
        else:
            T = next((t for t in ('A', 'C', 'E') if t != b and t not in busy), None)
            if T is None: raise cg.Unsupported('char index: no free byte')
        F.emit('ld', '%s,%s' % (T, b)); F.emit('add', '%s,%s' % (T, b)); r = T
    else:                                                  # a temporary: the scratch is the other byte, the result
        b = src[1]                                         # stays (fc2: ld C,A / add A,C; -O3 -XS: ld A,C / add A,C)
        if b == 'A': F.emit('ld', 'C,A'); F.emit('add', 'A,C'); r = 'A'
        else: F.emit('ld', 'A,%s' % b); F.emit('add', 'A,%s' % b); r = 'A'
    if home is not None and r != home: F.emit('ld', '%s,%s' % (home, r)); r = home
    return r


def idx_byte(F, src, esz, home, busy, off=0):
    """the signed char index scaled by esz (1, 2, 4) in a byte register, plus a member offset; returns the register.
    home: 'A' for the (XBC+A) loads, 'C' for stores and (XWA+C), 'L' for pointer sums, None for wherever it lands"""
    o, xr = bool(F.opt), bool(F.adecl)
    if esz == 2:
        r = scale2_byte(F, src, home, busy)
    else:
        src = temp_byte(F, src)
        k = src[0]
        if k == 'mem':
            r = home or 'A'
            if not o and r == 'C': r = 'A'                 # sc4: ld A,im / sla 0x2,A / ld C,A
            F.emit('ld', '%s,%s' % (r, src[1]))
        else: r = src[1]                                   # -Xr rc4: sla 0x2,A in the dead parameter
        if esz == 4: F.emit('sla', '0x2,%s' % r)
    if off: F.emit('add', '%s,%s' % (r, cg.hx(off)))      # oc4: add A,0x14
    if home is not None and r != home: F.emit('ld', '%s,%s' % (home, r)); r = home
    return r


def scale_word(F, R, esz):
    if esz == 2: F.emit('add', '%s,%s' % (R, R))
    elif esz == 4: F.emit('sla', '0x2,%s' % R)
    elif esz == 8: F.emit('sla', '0x3,%s' % R)


def own_fam(F, src):
    """the word register a register variable is widened in; WA for the rest"""
    return BYTE_FAM[src[1]] if src[0] == 'reg' and src[2] else 'WA'


def widen(F, src, R, signed, esz, scale=True):
    """the char sign- or zero-extended into word register R and scaled by esz"""
    o = bool(F.opt)
    src = temp_byte(F, src)
    ext = 'exts' if signed else 'extz'
    if o:
        put_byte(F, src, FAM[R][1]); F.emit(ext, R)       # -O3 -XS pc2: ld C,im / exts BC
    else:
        own = own_fam(F, src)
        if own == 'WA': put_byte(F, src, 'A')
        F.emit(ext, own)
        if own != R: F.emit('ld', '%s,%s' % (R, own))     # pc2: exts WA / ld BC,WA
    if scale: scale_word(F, R, esz)
    return R


CHIDX_ONCE = True                                         # see element

def uses_in_function(F, d):
    u = []
    cg.walk(F.f.body, lambda n, dd: u.append(n) if n.k == 'var' and n.decl is d else None)
    return len({id(x) for x in u})

def single_use(d):
    u = getattr(d, 'uses', None)
    return not isinstance(u, int) or u <= 1


def base_kind(F, b):
    """('garr', decl, sized, 0) | ('gmem', name, offset) | ('gpmem', decl, off) | ('pmem', decl, off) | ('rmem', decl,
    off) | ('gptr', decl) | ('pptr', decl) | ('rptr', decl) | None.  r* = a register parameter (-Xr)."""
    b = strip(b)
    while b.k in ('decay', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
        return ('garr', b.decl, bool(getattr(b.decl.ty, 'count', 0)), 0)
    if b.k == 'member' and b.ty.kind == 'array':
        bb = strip(b.base)
        if not b.arrow and bb.k == 'var' and bb.decl.kind == 'global':
            return ('gmem', bb.decl.name, cg.member_offset(b))
        if b.arrow and bb.k == 'load' and strip(bb.e).k == 'var':
            d = strip(bb.e).decl
            if d.kind == 'global': return ('gpmem', d, cg.member_offset(b))
            if d.kind == 'param' and getattr(d, 'reg', None) in BYTE_FAM.values(): return ('rmem', d, cg.member_offset(b))
            if d.kind == 'param' and not getattr(d, 'reg', None): return ('pmem', d, cg.member_offset(b))
    if b.k == 'load' and b.ty.is_ptr() and strip(b.e).k == 'var':
        d = strip(b.e).decl
        if d.kind == 'global': return ('gptr', d)
        if d.kind == 'param' and getattr(d, 'reg', None) in BYTE_FAM.values(): return ('rptr', d)
        if d.kind == 'param' and not getattr(d, 'reg', None): return ('pptr', d)
        if d.kind == 'local' and not getattr(d, 'reg', None) and getattr(d, 'slot', None) is not None:
            return ('lptr', d)                           # r3_07_16: a pointer local in its slot
    return None


def is_elem(F, lv):
    """is lv a global array's element with a char index (the (XBC+A) / (XBC+WA) forms)?"""
    lv = strip(lv)
    if not CHIDX or lv.k != 'index' or char_index(lv.idx) is None: return False
    bk = base_kind(F, lv.base)
    return bk is not None and bk[0] in ('garr', 'gmem')


def store_byte_shape(F, lv):
    """the symbol when lv is a signed-char-indexed element of a global char array (the (XBC+A) store form of
    r2_05_07), else None"""
    lv = strip(lv)
    if not CHIDX or lv.k != 'index' or lv.ty.size != 1: return None
    ci = char_index(lv.idx); bk = base_kind(F, lv.base)
    if ci is None or ci[2] != 'load' or not ci[1] or bk is None or bk[0] != 'garr': return None
    return '_' + bk[1].name


def element(F, lv, kind, fam='WA'):
    if not CHIDX: return None
    lv = strip(lv)
    if lv.k != 'index': return None
    ci = char_index(lv.idx)
    if ci is None: return None
    x, signed, how = ci
    bk = base_kind(F, lv.base)
    if bk is None: return None
    esz = lv.ty.size
    if esz not in (1, 2, 4): return None
    if how != 'load' and esz == 1: return None             # (byte expressions were probed on int arrays only)
    o, xr = bool(F.opt), bool(F.adecl)
    hx = cg.hx
    busy = busy_bytes(F, lv.base)
    src = source(F, x, how)
    if src is None: return None
    if how == 'load' and src[0] == 'reg' and not single_use(strip(x.e).decl):
        if kind == 'load' and esz == 1:
            T = next((t for t in ('C', 'E', 'L') if t != src[1] and t not in busy and BYTE_FAM[t] not in cg.live_regs(F)), None)
            if T is None: return None                      # -Xr r1_06_01: guca[a] with a read again: ld E,A /
            F.emit('ld', '%s,%s' % (T, src[1])); busy = busy | {src[1]}; src = ('reg', T, True)   # extz DE / lda XHL,_guca
        elif esz == 2 and kind in ('rmw', 'store', 'storek'): busy = busy | {src[1]}   # (the doubling copies: r2_06_13)
        else: return None
    reg_var = src[0] == 'reg' and src[2]
    if bk[0] in ('garr', 'gmem'):
        if bk[0] == 'garr': sym = '_' + bk[1].name; sized = bk[2]; off = 0
        else: sym = '_' + bk[1]; sized = True; off = bk[2]
        gsym = sym if not off else '%s + %s' % (sym, hx(off))
        if signed and esz == 1 and bk[0] == 'garr' and kind == 'storeb':   # r2_05_07: the value in E, then (XBC+A)
            if reg_var: return '(XBC+%s)' % src[1]
            if src[0] != 'mem': return None
            F.emit('ld', 'A,%s' % src[1]); return '(XBC+A)'
        if signed and esz == 1 and bk[0] == 'garr':         # rc1 / xc1 / sc1 / lc1: the byte zero-extended whole
            if kind in ('store', 'storeb'): return None
            if reg_var:                                    # -Xr: lda XBC,_gca / ld L,(XBC+A)
                X = 'XBC' if src[1] == 'A' else 'XWA'
                F.emit('lda', '%s,%s' % (X, gsym)); return '(%s+%s)' % (X, src[1])
            if src[0] != 'mem': return None
            if CHIDX_ONCE and how == 'load' and strip(x.e).k == 'var' and uses_in_function(F, strip(x.e).decl) > 1 and \
                    src[1] not in ('QIZH', 'QIZL'):
                raise cg.Unsupported('a char index read twice')   # a char parameter read twice is kept in a register and indexes
                                                           # signed (rstmt rs_2_08_01_2: ld C,(b) / .. / ld A,(XWA+C)); the
                                                           # zero-extended form is for one read only
            if src[1] in ('QIZH', 'QIZL'):                 # a char local in QIZ: the register indexes, signed
                if kind != 'load': return None             # (stdiv3.c sd3_c_d_q_GXG: lda XWA,_hca / ld A,(XWA+QIZH))
                F.emit('lda', 'XWA,%s' % gsym); return '(XWA+%s)' % src[1]
            F.emit('lda', 'XBC,%s' % gsym); F.emit('ld', 'XWA,0x0'); F.emit('ld', 'A,%s' % src[1])
            F.emit('add', 'XWA,XBC'); return '(XWA)'
        if signed and (sized or esz == 1):                 # rc2 / rc4 / mc1 / mc2 / fc2 / gc2 / hi2 / kc2: (XBC+A)
            if kind == 'rmw' and esz == 2:                 # r2_06_13: gia[a] <<= 4 -> ld C,A / add C,A / ld E,C /
                if xr:                                     # lda XHL,_gia / ld BC,(XHL+E) / sla 0x4,BC / ld (XHL+E),BC
                    live = {BYTE_FAM[b] for b in busy} | set(cg.live_regs(F))
                    home = next((t for t in ('E', 'C', 'L') if t != src[1] and BYTE_FAM[t] not in live), None)
                    if home is None: return None
                else: home = 'C'
                idx_byte(F, src, esz, home, busy); F.emit('lda', 'XHL,%s' % gsym); return '(XHL+%s)' % home
            if kind == 'store' or (kind == 'storek' and esz == 4):   # vc2 / sc4: the index to C, the base to XDE
                idx_byte(F, src, esz, 'C', busy); F.emit('lda', 'XDE,%s' % gsym); return '(XDE+C)'
            r = idx_byte(F, src, esz, None if xr else 'A', busy)
            X = 'XBC' if r == 'A' else 'XWA'               # -Xr rc2: ld C,A / add C,A / lda XWA,_gia / (XWA+C)
            F.emit('lda', '%s,%s' % (X, gsym)); return '(%s+%s)' % (X, r)
        # unsigned, or a signed char on an unsized int array (xc2): widened to a word and scaled there
        if kind == 'store' or (kind == 'storek' and esz == 4):   # ku2: ld BC,WA / add BC,BC / lda XDE,_gia / op (XDE+BC),WA
            widen(F, src, 'BC', signed, esz); F.emit('lda', 'XDE,%s' % gsym); return '(XDE+BC)'
        R = own_fam(F, src) if xr else 'WA'
        widen(F, src, R, signed, esz)
        X = 'XBC' if R == 'WA' else 'XWA'
        if xr:                                             # the first family that holds nothing (r1_06_01: XHL)
            live = {'X' + f for f in cg.live_regs(F) if f in BYTE_FAM.values()} | {'X' + BYTE_FAM[b] for b in busy} | {'X' + R}
            X = next((x for x in ('XWA', 'XBC', 'XDE', 'XHL') if x not in live), X)
        F.emit('lda', '%s,%s' % (X, gsym)); return '(%s+%s)' % (X, R)
    if how not in ('load', 'mul2') and bk[0] not in ('rmem', 'rptr'): return None
    if bk[0] == 'gpmem':                                   # nc2 / nu2: through a global struct pointer
        if bk[2] or kind != 'load': return None
        if signed: idx_byte(F, src, esz, 'C', busy); F.emit('ld', 'XWA,(_%s)' % bk[1].name); return '(XWA+C)'
        widen(F, src, 'BC', signed, esz); F.emit('ld', 'XWA,(_%s)' % bk[1].name); return '(XWA+BC)'
    if bk[0] == 'pmem':                                    # oc2 / ou2 / oc4: through a struct pointer parameter
        if kind != 'load' or not hasattr(bk[1], 'off'): return None   # (-Xr: a register parameter without a stack
        pm = '(XSP+%s)' % hx(bk[1].off + F.push)        #  slot; random r3_08_13 crashed here)
        if signed:
            idx_byte(F, src, esz, 'A', busy, bk[2]); F.emit('ld', 'W,0x0')   # oc4: sla 0x2,A / add A,0x14
        else:
            widen(F, src, 'WA', signed, esz)
            if bk[2]: F.emit('add', 'WA,%s' % hx(bk[2]))
            if not o or bk[2]: F.emit('ld', 'W,0x0')       # (-O knows W is zero after extz WA; the offset's add may
                                                           # carry: r1_03_19 a->a[b] keeps the ld W,0x0)
        F.emit('extz', 'XWA'); F.emit('add', 'XWA,%s' % pm); return '(XWA)'
    if bk[0] == 'rmem':                                    # -Xr oc2: ld E,C / add E,C / ld HL,(XWA+E)
        if kind != 'load': return None
        X = FAM[bk[1].reg][4]
        if signed: r = idx_byte(F, src, esz, None, busy, bk[2])
        else:
            r = widen(F, src, own_fam(F, src), signed, esz)
            if bk[2]:                                      # the offset's sum is used as a byte (rstmt -Xr
                F.emit('add', '%s,%s' % (r, hx(bk[2])))    # rs_1_03_19_1: a->a[b] -> extz BC / add BC,BC / add BC,0xe /
                if len(r) == 2 and r in ('WA', 'BC', 'DE', 'HL'): r = r[1]   # ld WA,(XWA+C))
        return '(%s+%s)' % (X, r)
    if bk[0] == 'gptr':
        if kind != 'load': return None
        if esz == 1 and signed:                            # pc1: ld XBC,(_gp) / ld XWA,0x0 / ld A,im / add XWA,XBC
            F.emit('ld', 'XBC,(_%s)' % bk[1].name)
            if reg_var: return '(XBC+%s)' % src[1]         # -Xr: ld XBC,(_gp) / ld L,(XBC+A)
            if src[0] != 'mem': return None
            F.emit('ld', 'XWA,0x0'); F.emit('ld', 'A,%s' % src[1]); F.emit('add', 'XWA,XBC'); return '(XWA)'
        if esz == 1: return None
        widen(F, src, 'BC', signed, esz); F.emit('ld', 'XWA,(_%s)' % bk[1].name); return '(XWA+BC)'
    if bk[0] == 'pptr':
        if not hasattr(bk[1], 'off'): return None   # (-Xr: a register parameter without a stack slot)
        pm = '(XSP+%s)' % hx(bk[1].off + F.push)
        if kind == 'store': return None
        if esz == 1 and signed:                            # qc1: ld XWA,0x0 / ld A,im / add XWA,(p)
            if src[0] != 'mem': return None
            F.emit('ld', 'XWA,0x0'); F.emit('ld', 'A,%s' % src[1]); F.emit('add', 'XWA,%s' % pm); return '(XWA)'
        if esz == 1: return None
        widen(F, src, 'WA', signed, esz)
        F.emit('extz', 'XWA'); F.emit('add', 'XWA,%s' % pm); return '(XWA)'   # qc2 / qu2 / tc2 / tu2
    if bk[0] == 'rptr':                                    # -Xr qc1: ld L,(XWA+C); qc2: exts BC / add BC,BC / (XWA+BC)
        if kind == 'store': return None
        X = FAM[bk[1].reg][4]
        if esz == 1 and signed:
            if not reg_var: return None
            return '(%s+%s)' % (X, src[1])
        R = widen(F, src, own_fam(F, src), signed, esz)
        return '(%s+%s)' % (X, R)
    return None


def ptr_sum(F, e, fam):
    """p + c / p - c / &g[c] with a char c: the result in fam (ac2, ac1, au2, bc2, dc2, ec1, ec2, eu2), or None"""
    if not CHIDX: return None
    hx = cg.hx
    o, xr = bool(F.opt), bool(F.adecl)
    e = strip(e)
    if fam == 'WA' or fam not in ('HL', 'BC', 'DE'): return None
    R = FAM[fam][4]; R2 = FAM[fam][2]; R1 = FAM[fam][1]; RH = cg.HIGHB8.get(fam)
    if e.k == 'addr':
        x = strip(e.e)
        if x.k != 'index': return None
        ci = char_index(x.idx); bk = base_kind(F, x.base)
        if ci is None or ci[2] != 'load' or bk is None or bk[0] != 'garr': return None
        c, signed, _ = ci; esz = x.ty.size
        if esz not in (1, 2, 4): return None
        if getattr(strip(c.e).decl, 'reg', None) not in (None, 'QIZH') and not single_use(strip(c.e).decl): return None
        src = source(F, c, 'load')
        if src is None: return None
        g = '_' + bk[1].name
        if esz == 1: return byte_sum(F, src, fam, ('lda', g))   # ec1
        if signed:                                         # ec2: ld L,im / add L,im / lda XWA,_gia / ld H,0x0 / extz XHL
            idx_byte(F, src, esz, R1, set())
            F.emit('lda', 'XWA,%s' % g); F.emit('ld', '%s,0x0' % RH); F.emit('extz', R); F.emit('add', '%s,XWA' % R)
            return fam
        widen(F, src, R2, signed, esz)                     # eu2: ld A,im / extz WA / ld HL,WA / add HL,HL / lda XWA,_gia
        F.emit('lda', 'XWA,%s' % g); F.emit('extz', R); F.emit('add', '%s,XWA' % R); return fam
    if e.k != 'bin' or e.op not in ('+', '-'): return None
    l, r = strip(e.l), strip(e.r)
    if not (l.ty is not None and l.ty.is_ptr()) or r.ty is None or r.ty.is_ptr(): return None
    ci = char_index(r)
    if ci is None or ci[2] != 'load': return None
    c, signed, _ = ci
    if getattr(strip(c.e).decl, 'reg', None) not in (None, 'QIZH') and not single_use(strip(c.e).decl): return None
    esz = l.ty.base.size if l.ty.base is not None else 1   # (r3_07_16: u in QIZH reads like memory)
    if esz not in (1, 2, 4): return None
    pb = base_kind(F, l)
    if pb is None or pb[0] not in ('gptr', 'pptr', 'rptr', 'lptr'): return None
    src = source(F, c, 'load')
    if src is None: return None
    pm = '(_%s)' % pb[1].name if pb[0] == 'gptr' else '(XSP+%s)' % hx(pb[1].off + F.push) if pb[0] == 'pptr' \
        else '(XSP+%s)' % hx(pb[1].slot + F.push) if pb[0] == 'lptr' else FAM[pb[1].reg][4]
    if e.op == '-':                                        # dc2: ld A / exts WA / add WA,WA / exts XWA / ld XHL,(_gpi) / sub XHL,XWA
        if esz == 1 or not signed or pb[0] != 'gptr': return None
        widen(F, src, 'WA', signed, esz); F.emit('exts', 'XWA')
        F.emit('ld', '%s,%s' % (R, pm)); F.emit('sub', '%s,XWA' % R); return fam
    if esz == 1:                                           # ac1: ld XWA,(_gp) / ld XHL,0x0 / ld L,im / add XHL,XWA
        if not signed or pb[0] != 'gptr': return None
        if src[0] == 'mem' and xr:                         # -Xr r1_04_19: a char in memory: ld XBC,(_gp) / ld A,(b) /
            F.emit('ld', 'XBC,%s' % pm); F.emit('ld', 'A,%s' % src[1]); F.emit('lda', '%s,XBC+A' % R); return fam
        if src[0] == 'reg' and xr and src[1] == 'A' and getattr(getattr(F, 'cur_stmt', None), 'k', None) != 'return':
            F.emit('ld', 'XBC,%s' % pm); F.emit('lda', '%s,XBC+A' % R); return fam   # -Xr r3_03_11: char *t = gp + a
                                                           # -> ld XBC,(_gp) / lda XBC,XBC+A, sign-extended (chidx ac1,
                                                           # a return, zero-extends through byte_sum below)
        return byte_sum(F, src, fam, ('ld', pm))           # lda XWA,XBC+A (-O3 -XS ac1 into XHL zero-extends, codegen's
                                                           # lda form is for a result in XWA there: r1_04_19 -O3 -XS)
    if pb[0] == 'lptr' and pb[1].ty.base.size == 1 and not o: return None   # (unprobed: a char pointer local)
    if pb[0] == 'gptr':                                    # ac2 / au2: ... ld HL,WA / add HL,HL / ld XWA,(_gpi) /
        widen(F, src, R2, signed, esz)                     # extz XHL / add XHL,XWA
        F.emit('ld', 'XWA,%s' % pm); F.emit('extz', R); F.emit('add', '%s,XWA' % R); return fam
    if o:                                                  # bc2 -O3 -XS: exts WA / add WA,WA / ld HL,WA / extz XHL / add XHL,(p)
        own = widen(F, src, own_fam(F, src), signed, esz)
        if own != R2: F.emit('ld', '%s,%s' % (R2, own))
    else: widen(F, src, R2, signed, esz)                   # bc2: exts WA / ld HL,WA / add HL,HL / extz XHL / add XHL,(p)
    F.emit('extz', R); F.emit('add', '%s,%s' % (R, pm)); return fam


def byte_sum(F, src, fam, base):
    """a char array's / char pointer's element address as a pointer sum: the char zero-extended whole in the result
    register and the base added (ec1: lda XWA,_gca / ld XHL,0x0 / ld L,im / add XHL,XWA; -Xr: lda XBC,_gca / ld XHL,0x0 /
    ld L,A / add XHL,XBC; -O3 -XS -Xr: ld L,A / lda XBC,_gca / ld H,0x0 / extz XHL / add XHL,XBC)"""
    o, xr = bool(F.opt), bool(F.adecl)
    R = FAM[fam][4]; R1 = FAM[fam][1]; RH = cg.HIGHB8.get(fam)
    op, where = base
    if src[0] == 'mem':
        F.emit(op, 'XWA,%s' % where); F.emit('ld', '%s,0x0' % R); F.emit('ld', '%s,%s' % (R1, src[1]))
        F.emit('add', '%s,XWA' % R); return fam
    if src[0] != 'reg': return None
    X = 'XBC' if src[1] == 'A' else 'XWA'
    if o:
        F.emit('ld', '%s,%s' % (R1, src[1])); F.emit(op, '%s,%s' % (X, where)); F.emit('ld', '%s,0x0' % RH)
        F.emit('extz', R); F.emit('add', '%s,%s' % (R, X)); return fam
    F.emit(op, '%s,%s' % (X, where)); F.emit('ld', '%s,0x0' % R); F.emit('ld', '%s,%s' % (R1, src[1]))
    F.emit('add', '%s,%s' % (R, X)); return fam
