#!/usr/bin/env python3
"""Hand checks of interp.py: the oracle's code for simple functions must give the C-level answer.

usage: python3 -I -B test_interp.py      (needs the private oracle runs under ~/compartilhado/cc900-oracle/runs)

Each case names a corpus function, its arguments, and what C says the result is (return value, calls made, or bytes
written).  The oracle's listing is read at run time from ORACLE (default ~/compartilhado/cc900-oracle/runs) and run
at all four option sets (none, O3XS, Xr, O3XSXr).  A failure is an interpreter bug (or an ABI misunderstanding in
semcheck.py's argument set-up), never a model bug: the model is not involved.
"""
import os, sys, struct
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import semcheck, interp, listing, frontend

ORACLE = os.environ.get('ORACLE', os.path.expanduser('~/compartilhado/cc900-oracle/runs'))
CORPUS = os.path.join(os.path.dirname(HERE), 'corpus')
M16, M32 = 0xFFFF, 0xFFFFFFFF

def tdiv(a, b):
    q = abs(a) // abs(b)
    return -q if (a < 0) != (b < 0) else q

def tmod(a, b): return a - tdiv(a, b) * b

def s8(v): return interp.sext(v, 8)

# (run, file, function, args, check) -- check(outcome, world) returns None or a complaint.  Arguments are C values;
# a pointer argument is given as ('buf', [bytes]) and points at a buffer holding those bytes.
def ret(v, bits):
    return lambda o, w: None if o.get('ret') == v & ((1 << bits) - 1) else 'returned %s, want 0x%x' % (
        hex(o['ret']) if o.get('ret') is not None else None, v & ((1 << bits) - 1))

def calls(*want):
    def c(o, w):
        got = [(n[1:], a) for n, a, _ in o['calls']]
        exp = [(n, tuple(x & M16 for x in a)) for n, a in want]
        return None if got == exp else 'calls %s, want %s' % (got, exp)
    return c

R1 = '2026-11-08-7-micro'; RSW = '2026-11-09-4-micro-switch'
CASES = []
for a, b in ((3, 4), (100, -7), (-100, 7), (0x7fff, 2), (-32768, -1)):
    CASES += [(R1, 'binop_i', 'add_i_pp', (a, b), ret(a + b, 16)),
              (R1, 'binop_i', 'sub_i_pp', (a, b), ret(a - b, 16)),
              (R1, 'binop_i', 'mul_i_pp', (a, b), ret(a * b, 16)),
              (R1, 'binop_i', 'div_i_pp', (a, b), ret(tdiv(a, b), 16)),
              (R1, 'binop_i', 'mod_i_pp', (a, b), ret(tmod(a, b), 16)),
              (R1, 'binop_i', 'shl_i_pp', (a, b & 7), ret(a << (b & 7), 16)),
              (R1, 'binop_i', 'shr_i_pp', (a, b & 7), ret(a >> (b & 7), 16)),
              (R1, 'binop_ui', 'div_ui_pp', (a, b), ret((a & M16) // (b & M16), 16)),
              (R1, 'binop_ui', 'shr_ui_pp', (a, b & 15), ret((a & M16) >> (b & 15), 16)),
              (R1, 'binop_c', 'add_c_pp', (a, b), ret(s8(a) + s8(b), 8)),
              (R1, 'binop_c', 'div_c_pp', (a, b), ret(tdiv(s8(a), s8(b)) if s8(b) else 0, 8) if s8(b) else None),
              (R1, 'cmp_i', 'lt_i_val', (a, b), ret(int(a < b), 16)),
              (R1, 'cmp_i', 'ge_i_val', (a, b), ret(int(a >= b), 16)),
              (R1, 'unop_i', 'neg_i', (a,), ret(-a, 16)),
              (R1, 'unop_i', 'not_i', (a,), ret(~a, 16)),
              (R1, 'unop_i', 'lnot_i', (a,), ret(int(a == 0), 16))]
for a, b in ((3, 4), (100000, -7), (-100000, 7), (0x7fffffff, 3), (-5, 31)):
    ua, ub = a & M32, b & M32
    CASES += [(R1, 'binop_l', 'add_l_pp', (a, b), ret(a + b, 32)),
              (R1, 'binop_l', 'mul_l_pp', (a, b), ret(a * b, 32)),
              (R1, 'binop_l', 'div_l_pp', (a, b), ret(tdiv(a, b), 32)),
              (R1, 'binop_l', 'mod_l_pp', (a, b), ret(tmod(a, b), 32)),
              (R1, 'binop_l', 'shl_l_pp', (a, b & 31), ret(a << (b & 31), 32)),
              (R1, 'binop_l', 'shr_l_pp', (a, b & 31), ret(a >> (b & 31), 32)),
              (R1, 'binop_ul', 'div_ul_pp', (a, b), ret(ua // ub, 32)),
              (R1, 'binop_ul', 'mod_ul_pp', (a, b), ret(ua % ub, 32)),
              (R1, 'binop_ul', 'shr_ul_pp', (a, b & 31), ret(ua >> (b & 31), 32)),
              (R1, 'cmp_ul', 'lt_ul_val', (a, b), ret(int(ua < ub), 16)),
              (R1, 'cmp_ul', 'ge_ul_val', (a, b), ret(int(ua >= ub), 16))]
CASES += [(R1, 'ctrl', 'c_tern', (5, -3), ret(-3, 16)),
          (R1, 'ctrl', 'c_and', (5, 0), ret(0, 16)), (R1, 'ctrl', 'c_or', (0, 9), ret(1, 16)),
          (R1, 'ctrl', 'c_for', (4,), calls(('f1', (0,)), ('f1', (1,)), ('f1', (2,)), ('f1', (3,)))),
          (R1, 'ctrl', 'c_fordown', (3,), calls(('f1', (3,)), ('f1', (2,)), ('f1', (1,)))),
          (R1, 'ctrl', 'c_while', (2,), calls(('f0', ()), ('f0', ()))),
          (R1, 'ctrl', 'c_sum', (('buf', [5, 0, 0xfe, 0xff, 7, 0]), 3), ret(5 - 2 + 7, 16)),
          (R1, 'ctrl', 'c_find', (('buf', [5, 0, 9, 0, 7, 0]), 3, 7), ret(2, 16)),
          (R1, 'ctrl', 'c_cnt', (('buf', list(b'hello\0')),), ret(5, 16)),
          (RSW, 'switch', 'sw_jt6', (3,), calls(('f1', (13,)))),
          (RSW, 'switch', 'sw_jt6', (6,), calls()),
          (RSW, 'switch', 'sw_neg', (-2,), calls(('f1', (1,)))),
          (RSW, 'switch', 'sw_sparse', (1000,), calls(('f1', (3,)))),
          (RSW, 'switch', 'sw_jtl', (5,), calls(('f1', (15,)))),
          (RSW, 'switch', 'sw_local', (4,), ret(-1, 16)), (RSW, 'switch', 'sw_local', (3,), ret(4, 16))]

# Floating point (semcheck.py's FP helpers): the oracle's code calls `._f*`, which semcheck computes.  A double or
# float argument or global is given as ('d', x) / ('f', x); globals as a 6th element {name: value}.  Only the sets in
# the 7th element run (fp.c has no -Xr listing: thc1 refuses double results there).
def D(x): return struct.unpack('<Q', struct.pack('<d', x))[0]
def F(x): return struct.unpack('<I', struct.pack('<f', x))[0]
def f32(x): return struct.unpack('<f', struct.pack('<f', x))[0]

def memval(o, a, n):
    """bytes at a after the run (o['mem'] holds only the bytes that differ from the initial memory)"""
    mem = dict(o['mem'])
    return sum(mem.get(a + k, o['init'](a + k)) << (8 * k) for k in range(n))

def dret(x):
    """a double result, written through the hidden result pointer"""
    def c(o, w):
        v = memval(o, semcheck.RET_BUF + 0x8000, 8)
        return None if v == D(x) else 'result %s, want %r (0x%x)' % (hex(v) if v is not None else None, x, D(x))
    return c

def fret(x):
    return lambda o, w: None if o.get('ret') == F(x) else 'returned %s, want %r (0x%x)' % (
        hex(o['ret']) if o.get('ret') is not None else None, x, F(x))

def gmem(name, v, n):
    def c(o, w):
        got = memval(o, w.addr['_' + name], n)
        return None if got == v & ((1 << (8 * n)) - 1) else '%s = %s, want 0x%x' % (name, hex(got) if got is not None
                                                                                   else None, v & ((1 << (8 * n)) - 1))
    return c

def fcalls(name, *bits):
    def c(o, w):
        got = [(n, a[1:]) for n, a, _ in o['calls']]
        return None if got == [('_' + name, bits)] else 'calls %s, want %s(%s)' % (got, name, [hex(b) for b in bits])
    return c

RFP = '2026-11-09-9-micro-fp'; RAD = '2026-11-09-29-micro-adfp'; NO_XR = ('none', 'O3XS')
for a, b in ((2.5, 4.0), (-1.25, 3.5), (1e10, -3e-5), (7.0, 7.0), (0.0, -0.0)):
    G = {'gd': ('d', a), 'gd2': ('d', b)}; GF = {'gf': ('f', a), 'gf2': ('f', b)}
    CASES += [(RFP, 'fp', 'd_add_gg', (), dret(a + b), G, NO_XR),
              (RFP, 'fp', 'd_sub_pp', (('d', a), ('d', b)), dret(a - b), {}, NO_XR),
              (RFP, 'fp', 'd_mul_pk', (('d', a),), dret(a * 2.5), {}, NO_XR),
              (RFP, 'fp', 'd_div_pp', (('d', a), ('d', b)), dret(a / b) if b else None, {}, NO_XR),
              (RFP, 'fp', 'd_div_st', (), gmem('gd', D(a / b), 8) if b else None, {'gd2': ('d', a), 'gd3': ('d', b)},
               NO_XR),
              (RFP, 'fp', 'd_three', (), dret(a * b + 1.5), dict(G, gd3=('d', 1.5)), NO_XR),
              (RFP, 'fp', 'd_neg', (('d', a),), dret(-a), {}, NO_XR),
              (RFP, 'fp', 'd_copy', (), gmem('gd', D(b), 8), G, NO_XR),
              (RFP, 'fp', 'f_add_gg', (), fret(f32(f32(a) + f32(b))), GF, NO_XR),
              (RFP, 'fp', 'f_sub_gg', (), fret(f32(f32(a) - f32(b))), GF, NO_XR),
              (RFP, 'fp', 'f_mul_gg', (), fret(f32(f32(a) * f32(b))), GF, NO_XR),
              (RFP, 'fp', 'f_div_gg', (), fret(f32(f32(a) / f32(b))) if b else None, GF, NO_XR),
              (RFP, 'fp', 'f_clt', (), ret(int(f32(a) < f32(b)), 16), GF, NO_XR),
              (RFP, 'fp', 'd_ceq_gg', (), ret(int(a == b), 16), G, NO_XR),
              (RFP, 'fp', 'd_cne_gg', (), ret(int(a != b), 16), G, NO_XR),
              (RFP, 'fp', 'd_clt_gg', (), ret(int(a < b), 16), G, NO_XR),
              (RFP, 'fp', 'd_cle_gg', (), ret(int(a <= b), 16), G, NO_XR),
              (RFP, 'fp', 'd_cgt_gg', (), ret(int(a > b), 16), G, NO_XR),
              (RFP, 'fp', 'd_cge_gg', (), ret(int(a >= b), 16), G, NO_XR),
              (RFP, 'fp', 'd_blt_gg', (), ret(1 if a < b else 2, 16), G, NO_XR),
              (RFP, 'fp', 'd_bge_gg', (), ret(1 if a >= b else 2, 16), G, NO_XR),
              (RFP, 'fp', 'd_cond', (('d', a), ('d', b)), dret(a if a > b else b), {}, NO_XR),
              (RFP, 'fp', 'd_clt_z', (('d', a),), ret(int(a < 0), 16), {}, NO_XR),
              (RFP, 'fp', 'd_cge_z', (('d', b),), ret(int(b >= 0), 16), {}, NO_XR),
              (RFP, 'fp', 'd_beq_z', (('d', b),), ret(1 if b == 0 else 2, 16), {}, NO_XR),
              (RFP, 'fp', 'd_not', (('d', b),), ret(int(not b), 16), {}, NO_XR),
              (RFP, 'fp', 'd_from_f', (), dret(f32(a)), GF, NO_XR),
              (RFP, 'fp', 'f_from_d', (), fret(f32(a)), G, NO_XR),
              (RFP, 'fp', 'd_call_e', (('d', a),), fcalls('fd', D(a * 2.0)), {}, NO_XR),
              (RAD, 'probes/adfp', 'ad_d', (('d', a),), ret(int(a > 0), 16), {}, None),
              (RAD, 'probes/adfp', 'ad_di', (('d', a), 5), ret(5 + (a > 0), 16), {}, None),
              (RAD, 'probes/adfp', 'ad_iid', (3, -9, ('d', b)), ret(-6 + (b > 0), 16), {}, None),
              (RAD, 'probes/adfp', 'ad_fi', (('f', a), 5), ret(5 + (f32(a) > 0), 16), {}, None),
              (RAD, 'probes/adfp', 'ad_ifi', (2, ('f', b), 40), ret(42 + (f32(b) > 0), 16), {}, None)]
for x in (2.75, -2.75, 0.5, -32768.0, 32767.9):           # double -> integer truncates toward zero
    CASES += [(RFP, 'fp', 'd_to_i', (), ret(int(x), 16), {'gd': ('d', x)}, NO_XR),
              (RFP, 'fp', 'd_to_i_st', (), gmem('gi', int(x), 2), {'gd': ('d', x)}, NO_XR),
              (RFP, 'fp', 'd_to_l', (), ret(int(x * 1000), 32), {'gd': ('d', x * 1000)}, NO_XR),
              (RFP, 'fp', 'd_to_c_st', (), gmem('gc', int(x / 300), 1), {'gd': ('d', x / 300)}, NO_XR),
              (RFP, 'fp', 'd_to_ip', (('d', x),), ret(int(x), 16), {}, NO_XR)]
for x in (0.0, 3e9, 4294967295.0, 65535.5):
    CASES += [(RFP, 'fp', 'd_to_ul', (), ret(int(x), 32), {'gd': ('d', x)}, NO_XR),
              (RFP, 'fp', 'd_to_u_st', (), gmem('gu', int(x) & M16, 2) if x < 65536 else None, {'gd': ('d', x)}, NO_XR)]
for i in (0, 7, -3, 0x7fff, -0x8000):                     # integer -> double
    CASES += [(RFP, 'fp', 'd_from_i', (), dret(float(i)), {'gi': i}, NO_XR),
              (RFP, 'fp', 'd_from_ip', (i,), dret(float(i)), {}, NO_XR),
              (RFP, 'fp', 'd_from_l', (), dret(float(interp.sext(i * 100003, 32))), {'gl': i * 100003}, NO_XR),
              (RFP, 'fp', 'd_from_u', (), dret(float(i & M16)), {'gu': i}, NO_XR),
              (RFP, 'fp', 'd_from_c', (), dret(float(s8(i))), {'gc': i}, NO_XR),
              (RFP, 'fp', 'd_from_uc', (), dret(float(i & 0xff)), {'guc': i}, NO_XR),
              (RFP, 'fp', 'd_mix', (i,), dret(1.5 * i), {'gd': ('d', 1.5)}, NO_XR),
              (RFP, 'fp', 'd_st_ul', (), gmem('gd', D(float((i * 0x10001) & M32)), 8), {'gul': i * 0x10001}, NO_XR)]
CASES += [(RFP, 'fp', 'd_loop', (n,), dret(sum([1.5, -2.25, 1e3, 0.125][:n])),
           {'gda': [('d', 1.5), ('d', -2.25), ('d', 1e3), ('d', 0.125)]}, NO_XR) for n in range(5)]

CACHE = {}

def put(tr, a, t, v):
    """the C value v of type t into the trial's initial memory at a"""
    if isinstance(v, list):
        for k, x in enumerate(v): put(tr, a + k * t.base.size, t.base, x)
        return
    bits = (D(v[1]) if v[0] == 'd' else F(v[1])) if isinstance(v, tuple) else v & ((1 << (8 * t.size)) - 1)
    for k in range(t.size): tr.preset[a + k] = (bits >> (8 * k)) & 0xFF

def run_case(run, file, func, args, check, optset, globs=None):
    adecl = optset.endswith('Xr')
    sub, base = os.path.split(file) if '/' in file else ('micro', file)
    path = os.path.join(ORACLE, run, 'out', 'v423', optset, sub, base + '.asm')
    if path not in CACHE: CACHE[path] = listing.split(open(path, encoding='latin-1').read())
    want = CACHE[path]
    key = (file, adecl)
    if key not in CACHE: CACHE[key] = frontend.load(os.path.join(CORPUS, sub, base + '.c'), adecl=adecl)
    unit = CACHE[key]
    fn = [f for f in unit.functions if f.name == func][0]
    w = semcheck.World(unit, semcheck.data_blocks_of(want, unit))
    prog = interp.Program(want[('.' if adecl else '_') + func], w.symaddr)
    tr = semcheck.Trial(w, 7, 'small')
    for n, v in (globs or {}).items(): put(tr, w.addr['_' + n], unit.decls[n].ty, v)
    vals = []
    for p, a in zip(fn.params, args):
        if isinstance(a, tuple) and a[0] == 'buf':
            b = tr.new_buf()
            for k, x in enumerate(a[1]): tr.preset[b + k] = x
            vals.append(b)
        elif isinstance(a, tuple): vals.append(D(a[1]) if a[0] == 'd' else F(a[1]))
        else: vals.append(a & ((1 << (8 * p.ty.size)) - 1))
    o = semcheck.run_one(prog, tr, fn, adecl, vals, 100000); o['init'] = tr.init_byte
    if o['status'] != 'ok': return 'status %s' % o['status']
    return check(o, w)

def main():
    bad = n = 0
    for optset in ('none', 'O3XS', 'Xr', 'O3XSXr'):
        for case in CASES:
            run, file, func, args, check = case[:5]
            globs = case[5] if len(case) > 5 else None; sets = case[6] if len(case) > 6 else None
            if check is None or (sets is not None and optset not in sets): continue
            n += 1
            why = run_case(run, file, func, args, check, optset, globs)
            if why:
                bad += 1; print('FAIL %-7s %s:%s%s: %s' % (optset, file, func, args, why))
    print('%d / %d hand checks pass' % (n - bad, n))
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main()
