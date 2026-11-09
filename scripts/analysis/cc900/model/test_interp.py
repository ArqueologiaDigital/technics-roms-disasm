#!/usr/bin/env python3
"""Hand checks of interp.py: the oracle's code for simple functions must give the C-level answer.

usage: python3 -I -B test_interp.py      (needs the private oracle runs under ~/compartilhado/cc900-oracle/runs)

Each case names a corpus function, its arguments, and what C says the result is (return value, calls made, or bytes
written).  The oracle's listing is read at run time from ORACLE (default ~/compartilhado/cc900-oracle/runs) and run
at all four option sets (none, O3XS, Xr, O3XSXr).  A failure is an interpreter bug (or an ABI misunderstanding in
semcheck.py's argument set-up), never a model bug: the model is not involved.
"""
import os, sys
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

CACHE = {}

def run_case(run, file, func, args, check, optset):
    adecl = optset.endswith('Xr')
    path = os.path.join(ORACLE, run, 'out', 'v423', optset, 'micro', file + '.asm')
    if path not in CACHE: CACHE[path] = listing.split(open(path, encoding='latin-1').read())
    want = CACHE[path]
    key = (file, adecl)
    if key not in CACHE: CACHE[key] = frontend.load(os.path.join(CORPUS, 'micro', file + '.c'), adecl=adecl)
    unit = CACHE[key]
    fn = [f for f in unit.functions if f.name == func][0]
    w = semcheck.World(unit, {})
    prog = interp.Program(want[('.' if adecl else '_') + func], w.symaddr)
    tr = semcheck.Trial(w, 7, 'small')
    vals = []
    for p, a in zip(fn.params, args):
        if isinstance(a, tuple):
            b = tr.new_buf()
            for k, x in enumerate(a[1]): tr.preset[b + k] = x
            vals.append(b)
        else: vals.append(a & ((1 << (8 * p.ty.size)) - 1))
    o = semcheck.run_one(prog, tr, fn, adecl, vals, 100000)
    if o['status'] != 'ok': return 'status %s' % o['status']
    return check(o, w)

def main():
    bad = n = 0
    for optset in ('none', 'O3XS', 'Xr', 'O3XSXr'):
        for run, file, func, args, check in CASES:
            if check is None: continue
            n += 1
            why = run_case(run, file, func, args, check, optset)
            if why:
                bad += 1; print('FAIL %-7s %s:%s%s: %s' % (optset, file, func, args, why))
    print('%d / %d hand checks pass' % (n - bad, n))
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main()
