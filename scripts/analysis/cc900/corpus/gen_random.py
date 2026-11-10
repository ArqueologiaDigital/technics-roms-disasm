#!/usr/bin/env python3
"""Generate random C89 programs for the cc900 model (phase 3's "random programs at >= 95 %").

usage: python3 -I -B gen_random.py [--seed N] [--count K] [--funcs F] [--size small|medium] [--out DIR]
       (defaults: seed 1, 10 files, 20 functions each, size small, DIR = <this dir>/random; also writes
        <DIR>/../<DIR name>-sources.txt listing the files it wrote, relative to the corpus root, for run_oracle.sh)

Each file is a translation unit of F distinct functions drawn, seeded, from the constructs the micro corpus
(gen_micro.py, micro/*.c) and the probes (probes/*.c) exercise one at a time, so that a listing of it shows how
V4.23 handles their *interactions*.  What a function may contain:
- parameters, locals and extern globals of char, unsigned char, int, unsigned int, long, unsigned long, double,
  pointers to char / int / long / struct; extern global arrays indexed by a loop counter, a variable or a constant;
  struct members through a global, a global pointer or a pointer parameter;
- + - * & | ^ at every integer type, / % by a non-zero constant or by a variable under an `if (v != 0)` guard,
  << >> by a constant below the width or by a masked variable, unary - ~ !, casts between the integer types and
  int-to-double, double + - * and / by a constant, ?:, comparisons as values and as conditions, && and ||,
  `x & mask` conditions;
- assignment to locals, globals, array elements, members and through pointers, compound assignments, ++ / --,
  assignment chains (`gi = t = ...`) and assignment as a value;
- if / else, counted for / while / do loops over a dedicated counter (never written in the body), a few pointer-walk
  idioms, break / continue, switch on int / char / long / unsigned (dense and sparse cases, fallthrough, default),
  early returns;
- calls to extern functions with 0-2 arguments of each type, as statements, as operands and as conditions.
What it avoids, so that the oracle and the model can only differ in code shape: every local is initialised where it
is declared and every loop counter before its loop; no division or remainder by a value that may be zero; shift
counts are constants below the width or masked; no double-to-integer conversion; loop bounds are constants (<= 16)
or an int parameter; array indexes outside a loop are a small constant or an int parameter / local whose range is
the caller's contract.  Signed overflow is not sought (multiplications use constants <= 12 or char operands) but is
not excluded for arbitrary inputs.
The output is deterministic for a given seed, ours, and C89 (declarations first, no // comments).
"""
import os, random, re, sys

CT = {'c': 'char', 'uc': 'unsigned char', 'i': 'int', 'ui': 'unsigned int', 'l': 'long', 'ul': 'unsigned long',
      'd': 'double', 'pc': 'char *', 'pi': 'int *', 'pl': 'long *', 'ps': 'struct st *'}
INT = ['c', 'uc', 'i', 'ui', 'l', 'ul']
WIDTH = {'c': 8, 'uc': 8, 'i': 16, 'ui': 16, 'l': 32, 'ul': 32}
SUFFIX = {'l': 'L', 'ul': 'UL'}
ELEM = {'pc': 'c', 'pi': 'i', 'pl': 'l'}
CMP = ['<', '<=', '>', '>=', '==', '!=']

PRELUDE = [
    'struct st { char c; int i; long l; unsigned int u; char *p; int a[8]; double d; };',
    'extern char gc, gc2; extern unsigned char guc; extern int gi, gi2, gi3; extern unsigned int gu, gu2;',
    'extern long gl, gl2; extern unsigned long gul; extern double gd, gd2;',
    'extern char *gp; extern int *gpi; extern long *gpl; extern struct st gs, *gps;',
    'extern char gca[16]; extern unsigned char guca[16]; extern int gia[16]; extern unsigned int gua[16];',
    'extern long gla[16]; extern unsigned long gula[16]; extern double gda[4];',
    'extern void v0(void); extern void v1(int); extern void v2(int, int); extern void vl(long); extern void vc(char);',
    'extern void vu(unsigned int); extern void vp(char *); extern void vd(double); extern void vs(struct st *);',
    'extern int r0(void); extern int r1(int); extern int r2(int, int); extern long rl(long); extern char rc(int);',
    'extern unsigned int ru(unsigned int); extern unsigned long rul(unsigned long);',
    'extern char *rp(void); extern int *rpi(int);']
GLOBALS = [('gc', 'c'), ('gc2', 'c'), ('guc', 'uc'), ('gi', 'i'), ('gi2', 'i'), ('gi3', 'i'), ('gu', 'ui'),
           ('gu2', 'ui'), ('gl', 'l'), ('gl2', 'l'), ('gul', 'ul'), ('gd', 'd'), ('gd2', 'd'),
           ('gp', 'pc'), ('gpi', 'pi'), ('gpl', 'pl'), ('gps', 'ps')]
ARRAYS = [('gca', 'c', 16), ('guca', 'uc', 16), ('gia', 'i', 16), ('gua', 'ui', 16), ('gla', 'l', 16),
          ('gula', 'ul', 16), ('gda', 'd', 4)]
MEMBERS = [('c', 'c'), ('i', 'i'), ('l', 'l'), ('u', 'ui'), ('p', 'pc'), ('d', 'd')]   # a[8] handled apart
VOID_CALLS = {'i': ['v1(%s)', 'v2(%s, gi)', 'v2(gi2, %s)'], 'l': ['vl(%s)'], 'c': ['vc(%s)'], 'ui': ['vu(%s)'],
              'pc': ['vp(%s)'], 'd': ['vd(%s)'], 'ps': ['vs(%s)']}
VAL_CALLS = {'i': [('r0()', None), ('r1(%s)', 'i'), ('r2(%s, gi)', 'i'), ('r2(gi2, %s)', 'i')],
             'l': [('rl(%s)', 'l')], 'c': [('rc(%s)', 'i')], 'ui': [('ru(%s)', 'ui')], 'ul': [('rul(%s)', 'ul')],
             'pc': [('rp()', None)], 'pi': [('rpi(%s)', 'i')]}

SINKS = {'c': ['vc(%s);', 'gc = %s;'], 'uc': ['v1(%s);', 'guc = %s;'], 'i': ['v1(%s);', 'gi = %s;'],
         'ui': ['vu(%s);', 'gu = %s;'], 'l': ['vl(%s);', 'gl = %s;'], 'ul': ['vl((long)%s);', 'gul = %s;'],
         'd': ['vd(%s);', 'gd = %s;'], 'pc': ['vp(%s);', 'gp = %s;'], 'pi': ['v1(*%s);', 'gpi = %s;']}

SIZES = {'small': dict(params=(0, 3), locals=(0, 2), stmts=(2, 5), depth=2, nest=1),
         'medium': dict(params=(0, 4), locals=(1, 3), stmts=(4, 9), depth=3, nest=2)}


def paren(e):
    """e as an operand: wrapped unless it is a single token, a call, or already one parenthesised group"""
    if ' ' not in e: return e
    k = e.find('(')
    if k >= 0 and (k == 0 or e[:k].replace('_', 'a').isalnum()):
        d = 0
        for i in range(k, len(e)):
            d += (e[i] == '(') - (e[i] == ')')
            if d == 0: return e if i == len(e) - 1 else '(%s)' % e
    return '(%s)' % e


class Fn:
    """one function's context: its variables, the counters being stepped and the budget for calls in expressions"""
    def __init__(s, rng, size, name):
        s.rng, s.size, s.name = rng, size, name
        s.vars = []                 # (name, type, kind): kind param | local
        s.protected = []            # loop counters being stepped (read-only inside their loops)
        s.counters_used = []
        s.calls = 0
        s.ret = None

    def ch(s, seq): return s.rng.choice(seq)
    def p(s, prob): return s.rng.random() < prob

    # ------------------------------------------------------------ operands
    def int_vars(s):
        return [n for n, t, k in s.vars if t in ('i', 'ui', 'c', 'uc')] + list(s.protected)

    def index(s):
        """an array index: the innermost counter (bounded by its loop), a small constant, or an int variable"""
        if s.protected and s.p(0.7): return s.protected[-1]
        if s.p(0.5): return str(s.rng.randint(0, 7))
        v = s.int_vars()
        return s.ch(v) if v else str(s.rng.randint(0, 7))

    def places(s, t):
        """expressions of type t that name a place: variables, array elements, members, derefs"""
        out = [n for n, ty, k in s.vars if ty == t] + [n for n, ty, k in s.vars if ty == t and k == 'local'] * 2
        if t == 'i': out += list(s.protected)
        out += [n for n, ty in GLOBALS if ty == t]
        for n, ty, cnt in ARRAYS:
            if ty == t: out.append('%s[%s]' % (n, s.index() if cnt > 7 else str(s.rng.randint(0, cnt - 1))))
        sbases = ['gs.', 'gps->'] + ['%s->' % n for n, ty, k in s.vars if ty == 'ps']
        for m, ty in MEMBERS:
            if ty == t: out.append((s.ch(sbases) if t != 'd' else 'gs.') + m)   # fp member: through gs only
        if t == 'i': out.append(s.ch(sbases) + 'a[%s]' % s.index())
        for n, ty, k in s.vars:
            if ty in ELEM and ELEM[ty] == t:
                out.append(s.ch(['*%s' % n, '%s[%d]' % (n, s.rng.randint(0, 3)), '%s[%s]' % (n, s.index())]))
        for n, ty in GLOBALS:
            if ty in ELEM and ELEM[ty] == t: out.append(s.ch(['*%s' % n, '%s[%d]' % (n, s.rng.randint(0, 3))]))
        return out

    def lvalues(s, t):
        return [x for x in s.places(t) if x not in s.protected]

    def const(s, t):
        r = s.rng
        if t == 'c': return s.ch([str(r.randint(-100, 100)), "'%s'" % s.ch('aAz09 '), str(r.randint(0, 9))])
        if t == 'uc': return str(s.ch([r.randint(0, 255), r.randint(0, 9), 0x80, 0xff]))
        if t == 'i': return str(s.ch([r.randint(-1000, 1000), r.randint(0, 9), 1, 2, 8, 16, 100, 255, 256, 0x7f]))
        if t == 'ui': return str(s.ch([r.randint(0, 30000), r.randint(0, 9), 1, 0xff, 0x100, 0x7fff]))
        if t == 'l': return s.ch([str(r.randint(-100000, 100000)) + 'L', str(r.randint(0, 9)) + 'L', '65536L'])
        if t == 'ul': return s.ch([str(r.randint(0, 100000)) + 'UL', str(r.randint(0, 9)) + 'UL', '0x10000UL'])
        if t == 'd': return s.ch(['0.5', '1.0', '2.5', '10.0', '100.0', '0.25', '3.0'])
        raise ValueError(t)

    def small_const(s, t):
        return str(s.rng.randint(2, 12)) + SUFFIX.get(t, '')

    def leaf(s, t):
        r = s.rng.random()
        pl = s.places(t)
        if t in ELEM:                                          # a pointer value
            if pl and r < 0.6: return s.ch(pl)
            if pl and r < 0.85: return '%s + %s' % (s.ch(pl), s.ch(s.int_vars() or ['1']))
            arr = [n for n, ty, cnt in ARRAYS if ty == ELEM[t]]
            return '&%s[%s]' % (s.ch(arr), s.index())
        if t == 'ps': return s.ch(pl)
        if pl and r < 0.6: return s.ch(pl)
        if r < 0.85 or not pl:
            if t in INT and s.p(0.25):                         # a cast of another integer place
                o = s.ch([x for x in INT if x != t]); opl = s.places(o)
                if opl: return '(%s)%s' % (CT[t], s.ch(opl))
            if t == 'd' and s.p(0.3):
                opl = s.places(s.ch(['i', 'l', 'ui', 'c']))
                if opl: return '(double)%s' % s.ch(opl)
            return s.const(t)
        return s.ch(pl)

    def call(s, t, depth):
        """a call whose value has type t, or None"""
        if t not in VAL_CALLS or s.calls >= 2: return None
        s.calls += 1
        form, at = s.ch(VAL_CALLS[t])
        return form % s.expr(at, depth - 1) if at else form

    def shift_count(s, t):
        if s.p(0.75): return str(s.rng.randint(1, WIDTH[t] - 1))
        v = s.int_vars()
        return '(%s & %d)' % (s.ch(v), 7 if WIDTH[t] == 8 else 15) if v else '3'

    def neg(s, op, e):
        return '%s%s' % (op, '(%s)' % e if e[0] in '-~!' else e)

    def sub(s, t, depth): return paren(s.expr(t, depth - 1))

    def expr(s, t, depth):
        if t in ('pc', 'pi', 'pl', 'ps'):
            c = s.call(t, depth) if s.p(0.15) else None
            return c or s.leaf(t)
        if depth <= 0 or s.p(0.3): return s.leaf(t)
        if s.p(0.1):
            c = s.call(t, depth)
            if c: return c
        if t == 'd':
            k = s.ch(['+', '-', '*', '/', 'neg', 'tern'])
            if k == '/': return '%s / %s' % (s.sub(t, depth), s.const(t))
            if k == 'neg': return s.neg('-', s.sub(t, depth))
            if k == 'tern': return '(%s ? %s : %s)' % (s.cond(depth - 1), s.sub(t, depth), s.sub(t, depth))
            return '%s %s %s' % (s.sub(t, depth), k, s.sub(t, depth))
        k = s.ch(['+', '+', '-', '-', '&', '|', '^', '*', '/', '%', '<<', '>>', 'neg', '~', 'not', 'cmp', 'tern',
                  'cast'])
        if k in ('+', '-', '&', '|', '^'): return s.binop(t, k, depth)
        if k == '*':
            m = s.small_const(t) if t in ('i', 'ui', 'l', 'ul') and s.p(0.6) else s.sub(t, depth)
            return '%s * %s' % (s.sub(t, depth), m)
        if k in ('/', '%'):
            return '%s %s %s' % (s.sub(t, depth), k, s.ch(['2', '3', '4', '7', '10', '16', '100']) + SUFFIX.get(t, ''))
        if k in ('<<', '>>'):
            l = s.sub(t, depth)
            if l.startswith('-'): l = s.leaf(t).lstrip('-')     # no negative constant shifted left
            return '%s %s %s' % (l, k, s.shift_count(t))
        if k == 'neg': return s.neg('-', s.sub(t, depth))
        if k == '~': return s.neg('~', s.sub(t, depth))
        if k == 'not':
            e = s.neg('!', s.sub(s.ch(INT), depth))
            return e if t == 'i' else '(%s)%s' % (CT[t], e)
        if k == 'cmp':
            o = s.ch(INT + ['d'])
            c = '(%s)' % s.compare(o, depth)
            return c if t == 'i' else '(%s)%s' % (CT[t], c)
        if k == 'tern': return '(%s ? %s : %s)' % (s.cond(depth - 1), s.sub(t, depth), s.sub(t, depth))
        if k == 'cast':
            o = s.ch([x for x in INT if x != t])
            return '(%s)%s' % (CT[t], paren(s.expr(o, depth - 1)))
        return s.leaf(t)

    def binop(s, t, k, depth):
        a = s.sub(t, depth); b = s.sub(t, depth)
        if a == b: b = s.const(t)                              # not x - x
        return '%s %s %s' % (a, k, b)

    def assigned(s, t, depth):
        """an assignment as a value, `(lv = e)`, whose lv nothing else in the enclosing expression reads"""
        lv = s.lvalues(t)
        if not lv: return None
        x = s.ch(lv); e = s.sub(t, depth)
        return '(%s = %s)' % (x, e if e != x else s.const(t))

    def compare(s, o, depth):
        a = s.sub(o, depth); b = s.sub(o, depth)
        if a == b: b = s.const(o)
        return '%s %s %s' % (a, s.ch(CMP), b)

    def cond(s, depth):
        r = s.rng.random()
        if r < 0.35:
            o = s.ch(INT + INT + ['d'])
            return s.compare(o, depth)
        if r < 0.4:
            o = s.ch(INT); e = s.assigned(o, depth)
            if e: return s.ch(['%s %s %s' % (e, s.ch(CMP), s.const(o)), e])
        if r < 0.55:
            v = s.places(s.ch(INT))
            return s.ch(v) if v else 'gi'
        if r < 0.65:
            v = s.places(s.ch(INT)); m = s.ch(['1', '2', '4', '0x8', '0x10', '0x80', '0x7'])
            return '%s & %s' % (s.ch(v), m) if v else 'gi & 1'
        if r < 0.72:
            v = s.places(s.ch(INT))
            return '!%s' % s.ch(v) if v else '!gi'
        if r < 0.8:
            c = s.call('i', depth)
            if c: return c
        if depth > 0 and r < 0.95:
            return '%s %s %s' % (s.cond(depth - 1), s.ch(['&&', '||']), s.cond(depth - 1))
        o = s.ch(INT)
        return '%s %s %s' % (s.sub(o, depth), s.ch(['<', '>', '==', '!=']), s.const(o))

    # ------------------------------------------------------------ statements
    def stmt(s, nest):
        r = s.rng.random()
        d = s.size['depth']
        if r < 0.28: return s.assign(d)
        if r < 0.42: return s.opassign(d)
        if r < 0.50: return s.incdec()
        if r < 0.62: return s.callstmt(d)
        if r < 0.74 and nest > 0: return s.ifstmt(nest)
        if r < 0.84 and nest > 0: return s.loop(nest)
        if r < 0.88 and nest > 0: return s.switch(nest)
        if r < 0.92: return s.guarded_div(d)
        if r < 0.95 and s.ret is not None and nest > 0: return 'if (%s) return %s;' % (s.cond(1), s.expr(s.ret, 1))
        return s.assign(d)

    def assign(s, d):
        t = s.ch(INT + INT + ['d', 'pc', 'pi'])
        lv = s.lvalues(t)
        if not lv: return s.callstmt(d)
        if t in INT and len(set(lv)) > 1 and s.p(0.15):
            a, b = s.rng.sample(sorted(set(lv), key=lv.index), 2)
            e = s.expr(t, d)
            return '%s = %s = %s;' % (a, b, e if e not in (a, b) else s.const(t))
        x = s.ch(lv)
        if not x.replace('_', 'a').isalnum() and s.p(0.7): d = 1
        for _ in range(5):
            e = s.expr(t, d)
            if e != x: break
        else: e = s.const(t) if t in INT or t == 'd' else '&%s[0]' % ('gca' if t == 'pc' else 'gia')
        return '%s = %s;' % (x, e)

    def opassign(s, d):
        t = s.ch(INT + ['d'])
        lv = s.lvalues(t)
        if not lv: return s.callstmt(d)
        if t == 'd': return '%s %s %s;' % (s.ch(lv), s.ch(['+=', '-=', '*=']), s.expr(t, d - 1))
        op = s.ch(['+=', '-=', '+=', '-=', '&=', '|=', '^=', '<<=', '>>=', '*=', '/=', '%='])
        if op in ('<<=', '>>='): rhs = s.shift_count(t)
        elif op == '*=': rhs = s.small_const(t)
        elif op in ('/=', '%='): rhs = s.ch(['2', '3', '7', '10', '16']) + SUFFIX.get(t, '')
        else: rhs = s.expr(t, d - 1)
        x = s.ch(lv)
        return '%s %s %s;' % (x, op, rhs if rhs != x else s.const(t))

    def incdec(s):
        lv = [x for x in s.lvalues(s.ch(INT + ['pc', 'pi'])) if x.replace('_', 'a').isalnum()]
        if not lv: return 'gi++;'
        return s.ch(['%s++;', '%s--;', '++%s;', '--%s;']) % s.ch(lv)

    def callstmt(s, d):
        t = s.ch(['i', 'i', 'l', 'c', 'ui', 'pc', 'd', 'ps', 'v0'])
        if t == 'v0': return 'v0();'
        return s.ch(VOID_CALLS[t]) % s.expr(t, d - 1) + ';'

    def guarded_div(s, d):
        t = s.ch(['i', 'ui', 'l', 'ul', 'c'])
        lv = s.lvalues(t); dv = s.places(t)
        if not lv or not dv: return s.assign(d)
        v = s.ch(dv)
        return 'if (%s != 0) %s = %s %s %s;' % (v, s.ch(lv), s.sub(t, 1), s.ch(['/', '%']), v)

    def block(s, nest, n=None):
        return [s.stmt(nest - 1) for _ in range(n or s.rng.randint(1, 3))]

    def ifstmt(s, nest):
        c = s.cond(1 if s.size['depth'] < 3 else 2)
        if s.p(0.4): return 'if (%s) %s' % (c, s.stmt(nest - 1))
        body = s.block(nest)
        if s.p(0.5): return 'if (%s) { %s }' % (c, ' '.join(body))
        els = s.block(nest)
        if len(els) == 1 and s.p(0.3): els = ['if (%s) %s' % (s.cond(1), els[0])]
        return 'if (%s) { %s } else { %s }' % (c, ' '.join(body), ' '.join(els))

    def loop(s, nest):
        kind = s.ch(['for', 'for', 'while', 'do', 'down', 'walk'])
        if kind == 'walk' and not s.protected: return s.walk()
        free = [n for n in ('i', 'j', 'k') if n not in s.protected]
        if not free: return s.assign(s.size['depth'])
        n = free[0]
        if n not in s.counters_used: s.counters_used.append(n)
        ipar = [x for x, t, k in s.vars if t == 'i' and k == 'param']
        K = str(s.rng.randint(2, 16)) if not ipar or s.p(0.6) else s.ch(ipar)
        s.protected.append(n)
        body = s.block(nest, s.rng.randint(1, 3))
        if nest > 1 and s.p(0.25): body.append(s.ch(['if (%s) break;', 'if (%s) continue;']) % s.cond(0))
        s.protected.pop()
        b = ' '.join(body)
        if kind == 'for': return 'for (%s = 0; %s < %s; %s++) { %s }' % (n, n, K, n, b)
        if kind == 'down': return 'for (%s = %s; %s > 0; %s--) { %s }' % (n, K, n, n, b)
        if kind == 'while': return '%s = 0; while (%s < %s) { %s %s++; }' % (n, n, K, b, n)
        return '%s = %s; do { %s } while (--%s > 0);' % (n, K, b, n)

    def walk(s):
        """a pointer-walk idiom over a pointer parameter or global and a count"""
        ptrs = [(x, t) for x, t, k in s.vars if t in ELEM and k == 'param'] or [('gp', 'pc'), ('gpi', 'pi')]
        pn, pt = s.ch(ptrs)
        c = s.ch([x for x, t, k in s.vars if t == 'i' and k == 'param'] or ['gi'])
        e = ELEM[pt]
        return s.ch(['while (%s-- > 0) *%s++ = %s;' % (c, pn, s.const(e)),
                     'while (%s > 0) { %s += *%s++; %s--; }' % (c, s.ch([g for g, t in GLOBALS if t == e]), pn, c),
                     'while (%s-- > 0) { if (*%s == %s) break; %s++; }' % (c, pn, s.const(e), pn)])

    def switch(s, nest):
        t = s.ch(['i', 'i', 'c', 'l', 'ui'])
        v = [x for x in s.places(t) if '[' not in x and '*' not in x]
        if not v: return s.ifstmt(nest)
        n = s.rng.randint(2, 6)
        sparse = [1, 2, 3, 5, 8, 10, 16, 20, 100] + ([] if t == 'c' else [200, 1000])
        cases = list(range(n)) if s.p(0.6) else sorted(s.rng.sample(sparse, n))
        out = []
        for k in cases:
            lbl = 'case %d%s:' % (k, SUFFIX.get(t, ''))
            if s.p(0.15) and k != cases[-1]: out.append(lbl); continue   # falls into the next case's body
            st = s.ch([s.assign(1), s.callstmt(1), s.opassign(1)])
            out.append('%s %s%s' % (lbl, st, ' break;' if s.p(0.85) else ''))
        if s.p(0.5): out.append('default: %s break;' % s.ch([s.assign(1), s.callstmt(1)]))
        return 'switch (%s) { %s }' % (s.ch(v), ' '.join(out))

    # ------------------------------------------------------------ the function
    def generate(s):
        rng = s.rng; z = s.size
        s.ret = s.ch([None, 'i', 'i', 'i', 'c', 'ui', 'l', 'ul', 'pc', 'pi'])   # no double: see the docstring
        for k in range(rng.randint(*z['params'])):
            s.vars.append(('abce'[k], s.ch(INT + INT + ['i', 'i', 'pc', 'pi', 'pl', 'ps', 'd']), 'param'))
        decls = []
        for k in range(rng.randint(*z['locals'])):
            t = s.ch(INT + ['i', 'd', 'pc', 'pi'])
            decls.append('%s = %s;' % (declare(t, 'tuv'[k]), s.expr(t, 1)))
            s.vars.append(('tuv'[k], t, 'local'))
        body = [s.stmt(z['nest']) for _ in range(rng.randint(*z['stmts']))]
        for n, t, k in s.vars:
            if k == 'local' and not any(re.search(r'\b%s\b' % n, b) for b in body):
                body.insert(rng.randint(0, len(body)), s.ch(SINKS[t]) % n)
        if s.ret is not None:
            e = (s.assigned(s.ret, 1) if s.ret in INT and s.p(0.1) else None) or s.expr(s.ret, z['depth'])
            body.append('return %s;' % e)
        if s.counters_used: decls.insert(0, 'int %s;' % ', '.join(s.counters_used))
        params = ', '.join(declare(t, n) for n, t, k in s.vars if k == 'param') or 'void'
        return '%s %s(%s)' % (CT.get(s.ret, 'void'), s.name, params), decls + body


def declare(t, n):
    return CT[t] + ('' if CT[t].endswith('*') else ' ') + n


def render(head, lines):
    return '\n'.join([head + ' {'] + ['\t' + l for l in lines] + ['}'])


def main():
    a = sys.argv[1:]
    def opt(k, d): return a[a.index(k) + 1] if k in a else d
    seed = int(opt('--seed', '1')); count = int(opt('--count', '10')); funcs = int(opt('--funcs', '20'))
    size = opt('--size', 'small'); here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.abspath(opt('--out', os.path.join(here, 'random')))
    if size not in SIZES: sys.exit('unknown size %s' % size)
    os.makedirs(out, exist_ok=True)
    written = []
    for f in range(count):
        rng = random.Random(seed * 1000003 + f * 7919 + {'small': 0, 'medium': 1}[size])
        seen = []; fns = []
        while len(fns) < funcs:
            head, lines = Fn(rng, SIZES[size], 'r%d_%02d_%02d' % (seed, f, len(fns))).generate()
            key = (head.split('(', 1)[1], tuple(lines))
            if key in seen: continue
            seen.append(key); fns.append(render(head, lines))
        fname = 'r%d_%s_%02d.c' % (seed, size[0], f)
        text = ['/* Random C89 program %s: gen_random.py --seed %d --count %d --funcs %d --size %s (file %d).'
                % (fname, seed, count, funcs, size, f),
                '   Ours, deterministic; the docstring of gen_random.py says what it may contain and what it avoids. */']
        text += PRELUDE + [''] + fns
        with open(os.path.join(out, fname), 'w') as fh: fh.write('\n'.join(text) + '\n')
        written.append('%s/%s' % (os.path.basename(out), fname))
    lst = os.path.join(os.path.dirname(out), '%s-sources.txt' % os.path.basename(out))
    with open(lst, 'w') as fh: fh.write('\n'.join(written) + '\n')
    print('wrote %d files, %d functions each, to %s; list %s' % (count, funcs, out, lst))


if __name__ == '__main__':
    main()
