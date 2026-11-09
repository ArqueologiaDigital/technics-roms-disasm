"""cc900 reference model: the register allocator of cdecl -O3 -XS leaf functions (rule L2).

Fitted by research-scratch sessions/2026-11-09_cc900-leaf-o3xs (fit.py, b58b51b): 119 of 131 functions and 639 of
675 objects of leaf-o3xs.csv, all six target routines of the 1997 library (_atoi, _atol, _strupr, _strrev,
_strrchr, _itoa).  Each object is a dict: name, cls, w (8 / 16 / 32), decl (declaration index), pos (source position
of its first reference, for the early group B), excl (names of objects it does not interfere with).

Precoloured first: `ret` (a variable returned as it is) and `retv` take HL / XHL / L, `call` IZ / XIZ, `memret`
(a parameter returned as it is that stays in memory) none.  Then the classes are visited in ORDER and each object
takes the first free register at its width:
  32 bit: XWA XBC XDE XHL XIX XIY XIZ
  16 bit: WA BC DE HL IX IY IZ, then QWA QBC QDE QHL QIX QIY QIZ
   8 bit: A C E L (a free family), then W B D H (beside a byte), then QA QC QE QL
B = inv / iv / pinc / blk / body in source order; P = walk / out / rld / cnt; W = walkh; L = loc / arr / sum, all
three in reverse declaration order; `once` before the parameters unless a `ret` variable holds HL (then after
them); a `sum` term takes HL first if it is free; with a `memret` variable nothing may take the HL family and t1
goes last, where it takes L.
"""
from collections import defaultdict

FAM = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOWB = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGHB = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
QB = {'WA': 'QA', 'BC': 'QC', 'DE': 'QE', 'HL': 'QL'}
ORDER = ['t1', 'B', 'once_pre', 'ro', 'multi', 'P', 'once_post', 'held', 'W', 'L', 'ctr', 'hval', 'byte']
B_CLASSES = {'inv', 'iv', 'pinc', 'body', 'blk'}
PARAM_CLASSES = {'walk', 'out', 'rld', 'cnt'}
LOCAL_CLASSES = {'loc', 'arr', 'sum'}


class RegFile:
    def __init__(s): s.held = defaultdict(list)
    def busy(s, slot, o): return any(p['name'] not in o['excl'] for p in s.held[slot])
    def slots(s, reg):
        if reg.startswith('X'):
            f = reg[1:]; return [f + '.lo', f + '.q', f + '.b0', f + '.b1']
        if reg in FAM: return [reg + '.lo', reg + '.b0', reg + '.b1']
        if reg.startswith('Q') and reg[1:] in FAM: return [reg[1:] + '.q']
        for f in LOWB:
            if reg == LOWB[f]: return [f + '.lo', f + '.b0']
            if reg == HIGHB[f]: return [f + '.lo', f + '.b1']
            if reg == QB[f]: return [f + '.q']
        raise ValueError(reg)
    def take(s, reg, o):
        for sl in s.slots(reg): s.held[sl].append(o)
    def free(s, reg, o):
        if reg in HIGHB.values() or reg in LOWB.values():
            f = next(k for k in LOWB if reg in (LOWB[k], HIGHB[k]))
            b = '.b0' if reg == LOWB[f] else '.b1'
            if s.busy(f + b, o): return False
            return all(p['w'] == 8 or p['name'] in o['excl'] for p in s.held[f + '.lo'])
        return not any(s.busy(sl, o) for sl in s.slots(reg))
    def first(s, o, avoid=()):
        w = o['w']
        if w == 32: cands = ['X' + f for f in FAM]
        elif w == 16: cands = FAM + ['Q' + f for f in FAM]
        else:
            low = [LOWB[f] for f in LOWB if not s.busy(f + '.lo', o)]
            cands = low + list(HIGHB.values()) + list(QB.values())
        for c in cands:
            if c not in avoid and s.free(c, o): return c
        return None


def hl(w): return {32: 'XHL', 16: 'HL', 8: 'L'}[w]
def iz(w): return {32: 'XIZ', 16: 'IZ'}[w]


def group_of(o, has_ret):
    c = o['cls']
    if c in B_CLASSES: return 'B'
    if c in PARAM_CLASSES: return 'P'
    if c == 'walkh': return 'W'
    if c in LOCAL_CLASSES: return 'L'
    if c == 'once': return 'once_post' if has_ret else 'once_pre'
    return c


def allocate(objs):
    """{name: register} (or 'mem' / None)"""
    rf = RegFile(); got = {}
    for o in objs: o.setdefault('excl', set()); o.setdefault('decl', -1); o.setdefault('pos', 0)
    has_ret = any(o['cls'] == 'ret' for o in objs)
    memret = any(o['cls'] == 'memret' for o in objs)
    for o in objs:
        if o['cls'] in ('ret', 'retv'): r = hl(o['w']); rf.take(r, o); got[o['name']] = r
        elif o['cls'] == 'call': r = iz(o['w']); rf.take(r, o); got[o['name']] = r
        elif o['cls'] == 'memret': got[o['name']] = 'mem'
    order = list(ORDER)
    if memret: order.remove('t1'); order.append('t1')
    bycls = defaultdict(list)
    for o in objs:
        if o['name'] not in got: bycls[group_of(o, has_ret)].append(o)
    for cls in order:
        grp = bycls.pop(cls, [])
        if cls == 'B': grp.sort(key=lambda o: o['pos'])
        elif cls in ('P', 'W', 'L', 'ctr', 'ro'): grp.sort(key=lambda o: -o['decl'])
        if cls == 'L':
            for o in [o for o in grp if o['cls'] == 'sum']:
                r = hl(o['w'])
                if rf.free(r, o): rf.take(r, o); got[o['name']] = r; grp.remove(o)
        for o in grp:
            avoid = ('HL', 'L', 'H', 'XHL', 'QHL', 'QL') if memret and cls != 't1' else ()
            r = rf.first(o, avoid)
            if r is not None: rf.take(r, o)
            got[o['name']] = r
    for cls, grp in bycls.items():
        for o in grp: got[o['name']] = None
    return got
