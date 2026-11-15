#!/usr/bin/env python3
"""homes2_ast.py -- the cc900 V4.23 oracle's code for the functions of probes homes2a.c / homes2b.c
(corpus/probes, oracle runs 2026-11-09-37-micro-homes2a and 2026-11-09-42-micro-homes2b) at four option sets, from
the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 homes2_ast.py --check a|b [SET] [--show N] [--only REGEX]   score against the oracle listing (exact /
                                                                        wrong / declined); model dir on sys.path

The function is lowered to the probes' statement grammar (definitions from a call, a global, a sum or difference of
globals, a global plus a constant, a constant; `v += call`; no-argument calls; sinks `s<x>(v)`; blocks; `while
(global)`, `while (param--)` and counting `for` loops).  Each value gets a home (IZ / QIZ / XIZ, a frame slot, its
stack arrival, or a scratch register when no call is in its range) by the rules in FAMILIES.md, then the code is
written.  Anything outside the grammar returns None.
"""
HOME_ = __import__('os').path.expanduser('~/')
import re
import sys

import codegen as cg

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
PROBES = {'a': HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/homes2a.c',
          'b': HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/homes2b.c'}
ORACLE = {'a': HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-09-37-micro-homes2a/out/v423/%s/probes/homes2a.asm',
          'b': HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-09-42-micro-homes2b/out/v423/%s/probes/homes2b.asm'}


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


# --------------------------------------------------------------------------------------------- the IR

class V:
    """a value: a parameter or local, int (2) or long (4)"""

    def __init__(self, d, kind, size, order):
        self.d, self.kind, self.size, self.order = d, kind, size, order
        self.name = d.name

    def __repr__(self):
        return self.name


class Fn:
    def __init__(self):
        self.vals = []          # in declaration order: parameters, then locals (inner blocks included)
        self.params = []
        self.body = []
        self.by_decl = {}


def is_ty(ty, sizes=(2, 4)):
    return ty is not None and ty.kind == 'int' and ty.signed and ty.size in sizes


def glob_of(n, size):
    """a load of a global int / long of this size -> its name"""
    n = cg.strip(n)
    if n.k != 'load' or not is_ty(n.ty, (size,)):
        return None
    v = cg.strip(n.e)
    if v.k != 'var' or v.decl.kind != 'global' or not is_ty(v.decl.ty, (size,)):
        return None
    return '_' + v.decl.name


def const_of(n):
    c = cg.fold(cg.strip(n))
    while c.k == 'cast' and c.kind == 'IntegralCast' and not c.explicit:
        c = cg.fold(cg.strip(c.e))
    if c.k == 'const' and c.value is not None:
        return c.value
    return None


def lower(f):
    F = Fn()
    need(f.ret is None or f.ret.kind == 'void')
    for p in f.params:
        need(is_ty(p.ty) and not p.addr_taken)
        v = V(p, 'param', p.ty.size, len(F.vals))
        F.vals.append(v)
        F.params.append(v)
        F.by_decl[p] = v

    def val_of(n, size=None):
        n = cg.strip(n)
        need(n.k == 'load')
        d = cg.strip(n.e)
        need(d.k == 'var' and d.decl in F.by_decl)
        v = F.by_decl[d.decl]
        need(size is None or v.size == size)
        return v

    def lvar(n):
        d = cg.strip(n)
        need(d.k == 'var' and d.decl in F.by_decl)
        return F.by_decl[d.decl]

    def call_of(n):
        """-> (callee, ('k', n) | ('v', V) | None, result size) for g0() / g1(x) / gl1(x) / sink calls"""
        n = cg.strip(n)
        need(n.k == 'call')
        fn = cg.strip(n.fn)
        need(fn.k == 'var' and fn.decl.kind == 'func')
        args = getattr(n, 'args', None) or []
        need(len(args) <= 1)
        arg = None
        if args:
            a = cg.strip(args[0])
            k = const_of(a)
            if k is not None:
                need(is_ty(a.ty, (2,)) and 0 <= k < 0x8000)
                arg = ('k', k)
            else:
                arg = ('v', val_of(a))
        rs = n.ty.size if n.ty is not None and n.ty.kind == 'int' else 0
        return fn.decl.name, arg, rs

    def rhs_of(e, size):
        e = cg.strip(e)
        if e.k == 'call':
            name, arg, rs = call_of(e)
            need(rs == size and (arg is None or arg[0] == 'k' or arg[1].size == 2))
            return ('call', '_' + name, arg)
        g = glob_of(e, size)
        if g is not None:
            return ('glob', g)
        k = const_of(e)
        if k is not None:
            need(k == 0)
            return ('const', k)
        need(e.k == 'bin' and e.op in ('+', '-') and is_ty(e.ty, (size,)))
        a = glob_of(e.l, size)
        need(a is not None)
        b = glob_of(e.r, size)
        if b is not None:
            return ('add' if e.op == '+' else 'sub', a, b)
        k = const_of(e.r)
        need(k is not None and e.op == '+' and 1 <= k <= 8)
        return ('addk', a, k)

    def stmts(lst, depth):
        out = []
        for s in lst:
            if s.k == 'block':
                for x in cg.flat(s):
                    if x.k == 'decl':
                        need(x.init is None)
                        d = x.var
                        need(is_ty(d.ty) and not d.addr_taken and getattr(d, 'storage', '') in ('', None))
                        v = V(d, 'local', d.ty.size, len(F.vals))
                        v.depth = depth
                        F.vals.append(v)
                        F.by_decl[d] = v
                    else:
                        out += stmts([x], depth)
                continue
            if s.k == 'expr':
                e = cg.strip(s.e)
                if e.k == 'call':
                    name, arg, rs = call_of(e)
                    if arg is None:
                        out.append(('call0', '_' + name))
                    else:
                        need(arg[0] == 'v')
                        out.append(('sink', '_' + name, arg[1]))
                    continue
                if e.k == 'bin' and e.op == '=':
                    v = lvar(e.l)
                    out.append(('def', v, rhs_of(e.r, v.size)))
                    continue
                if e.k == 'opassign' and e.op == '+':
                    v = lvar(e.l)
                    need(v.size == 2)
                    r = rhs_of(e.r, 2)
                    need(r[0] == 'call')
                    out.append(('addcall', v, r))
                    continue
                raise Decline()
            if s.k == 'while':
                c = cg.strip(s.cond)
                body = stmts([s.body], depth + 1)
                g = glob_of(c, 2)
                if g is not None:
                    out.append(('whileg', g, body))
                    continue
                need(c.k == 'incdec' and c.op == '--' and c.post)
                v = lvar(c.e)
                need(v.size == 2)
                out.append(('whiledec', v, body))
                continue
            if s.k == 'for':
                ini = cg.strip(s.init.e) if s.init is not None and s.init.k == 'expr' else None
                need(ini is not None and ini.k == 'bin' and ini.op == '=')
                v = lvar(ini.l)
                need(v.size == 2 and const_of(ini.r) == 0)
                c = cg.strip(s.cond)
                need(c.k == 'bin' and c.op == '<' and val_of(c.l) is v)
                bnd = val_of(c.r, 2)
                inc = cg.strip(s.inc)
                need(inc.k == 'incdec' and inc.op == '++' and lvar(inc.e) is v)
                out.append(('for', v, bnd, stmts([s.body], depth + 1)))
                continue
            raise Decline()
        return out

    F.body = stmts([f.body], 0)
    return F


def show_ir(F, body=None, ind=0):
    for st in (F.body if body is None else body):
        if st[0] in ('whileg', 'whiledec', 'for'):
            print('  ' * ind + str(st[:-1]))
            show_ir(F, st[-1], ind + 1)
        else:
            print('  ' * ind + str(st))


# --------------------------------------------------------------------------------------------- emission

REGS = ('IZ', 'QIZ', 'XIZ')


def events(body):
    """the program's call events in order, with loop boundaries: each item ('call', node) for a call with an
    argument, ('g0',), ('loop',) at a loop's entry, ('end',) at a loop body's end or the function's end"""
    out = []

    def walk(lst):
        for st in lst:
            k = st[0]
            if k in ('def', 'addcall'):
                if st[2][0] == 'call':
                    out.append(('call', id(st)))
            elif k == 'sink':
                out.append(('call', id(st)))
            elif k == 'call0':
                out.append(('g0',))
            elif k in ('whileg', 'whiledec', 'for'):
                out.append(('loop',))
                walk(st[-1])
                out.append(('end',))
    walk(body)
    out.append(('end',))
    flush = set()
    for i, e in enumerate(out):
        if e[0] == 'call' and out[i + 1][0] != 'call':
            flush.add(e[1])
    return flush


class Em:
    def __init__(self, F, s, H):
        self.F, self.s, self.H = F, s, H
        self.xr = s.endswith('Xr')
        self.opt = s.startswith('O3')
        self.out = []
        self.pending = 0
        self.nlab = 0
        self.flush_after = events(F.body)

    def e(self, x):
        self.out.append(x)

    def lab(self):
        self.nlab += 1
        return 'L%d' % self.nlab

    def home(self, v):
        h = self.H[v]['home']
        if v in getattr(self, 'unloaded', ()) and h in REGS:      # -O cdecl: a read-only parameter is loaded
            self.unloaded.discard(v)                               # at its first read
            self.e('ld %s,(XSP+%s)' % (h, hx(self.save + self.frame + 4 + self.pending + self.poff[v])))
        return h

    def hname(self, v):
        return self.H[v]['home']

    def proxy(self, v):
        return self.H[v].get('proxy', False)

    def at(self, v):
        """the memory operand of v's slot or stack arrival"""
        h = self.home(v)
        if h == 'slot':
            return '(XSP+%s)' % hx(self.save + self.pending + self.slot[v])
        need(h == 'mem')
        return '(XSP+%s)' % hx(self.save + self.frame + 4 + self.pending + self.poff[v])

    def flush(self):
        n = self.pending
        if n:
            self.e('inc %s,XSP' % hx(n) if n <= 8 else 'lda XSP,XSP+%s' % hx(n))
            self.pending = 0

    def call(self, fn, st):
        self.e('cal ' + (fn if not self.xr else '.' + fn[1:]))
        if id(st) in self.flush_after:
            self.flush()

    def pass_arg(self, arg, size=2):
        """an argument: cdecl push / adecl WA / XWA"""
        if arg[0] == 'k':
            if self.xr:
                self.e('ld WA,%s' % hx(arg[1]))
            else:
                self.e('pushw %s' % hx(arg[1]))
                self.pending += 2
            return
        v = arg[1]
        h = self.home(v)
        W = 'WA' if v.size == 2 else 'XWA'
        if h == 'tmp':
            src = self.tmp.pop(v, None)
            need(src is not None)
            if self.xr:
                if src != W:
                    self.e('ld %s,%s' % (W, src))
            else:
                self.e('push %s' % src)
                self.pending += v.size
            return
        if h in REGS:
            if self.xr:
                self.e('ld %s,%s' % (W, h))
            else:
                self.e('push %s' % h)
                self.pending += v.size
            return
        if self.xr:
            self.e('ld %s,%s' % (W, self.at(v)))
        elif v.size == 2:
            self.e('pushw %s' % self.at(v))
            self.pending += 2
        else:
            self.e('ld XWA,%s' % self.at(v))
            self.e('push XWA')
            self.pending += 4

    # ---- statements
    def body(self, lst):
        i = 0
        while i < len(lst):
            st = lst[i]
            if self.opt and st[0] == 'def' and st[2][0] in ('glob', 'add', 'sub', 'addk'):
                j = i
                while j < len(lst) and lst[j][0] == 'def' and lst[j][2][0] in ('glob', 'add', 'sub', 'addk', 'const'):
                    j += 1
                self.run_defs(lst[i:j], lst[j] if j < len(lst) else None)
                i = j
                continue
            nxt = lst[i + 1] if i + 1 < len(lst) else None
            getattr(self, 'st_' + st[0])(st, nxt)
            i += 1

    def run_defs(self, run, after):
        """-O: a run of definitions with no call between them reads each global once (common subexpressions):
        a plain copy `v = g` of a global read again is hoisted and the others read v's home; otherwise the global
        goes to WA when its last reader computes in WA with it as first operand, else to BC"""
        reads = []
        for st in run:
            r = st[2]
            if r[0] == 'glob':
                reads.append((st, r[1], 1))
            elif r[0] in ('add', 'sub'):
                reads += [(st, r[1], 1), (st, r[2], 2)]
            elif r[0] == 'addk':
                reads.append((st, r[1], 1))
        if after is not None and after[0] == 'whileg' and any(x[1] == after[1] for x in reads):
            reads.append((after, after[1], 0))              # the loop's first test reads the global too
        order = []
        for _, g, _ in reads:
            if g not in order:
                order.append(g)
        multi = [g for g in order if sum(1 for x in reads if x[1] == g) > 1]
        self.cse = {}
        pre = []
        hoisted = set()
        after_set = {}
        free = ['WA', 'BC', 'DE']
        for g in multi:
            users = [x for x in reads if x[1] == g]
            sizes = {x[0][1].size for x in users if x[0][0] != 'whileg'}
            need(len(sizes) == 1)
            gl = sizes.pop() == 4
            X = (lambda r: 'X' + r) if gl else (lambda r: r)
            if users[-1][0][0] == 'whileg':
                cps = [x[0] for x in users[:-1] if x[0][2][0] == 'glob']
                if cps:                                      # the loop tests the copy's register
                    need(cps[0] is users[0][0] and self.H[cps[0][1]]['home'] in ('IZ', 'QIZ'))
                    after_set[id(cps[0])] = g
                    self.loop_reg = self.H[cps[0][1]]['home']
                    continue
                reg = [x for x in free if x != 'WA'][0]
                free.remove(reg)
                pre.append(('load', reg, g))
                self.loop_reg = reg
                continue
            cp = [x[0] for x in users if x[0][2][0] == 'glob' and self.home(x[0][1]) in ('IZ', 'QIZ', 'XIZ', 'slot')]
            if cp:
                if cp[0] is users[0][0]:
                    after_set[id(cp[0])] = g                 # the copy is the first reader: no hoist
                else:
                    pre.append(('def', cp[0]))
                    hoisted.add(id(cp[0]))
                continue
            tmpu = [x for x in users if x[0][0] == 'def' and self.H[x[0][1]]['home'] == 'tmp']
            if tmpu:                                         # a scratch-register reader: the global in WA and
                need(len(tmpu) == 1 and tmpu[0][2] == 1)     # the reader in BC (cdecl); the other way round
                a_, b_ = ('BC', 'WA') if self.xr else ('WA', 'BC')   # under -Xr, where WA is its argument
                need(a_ in free and b_ in free)
                free.remove(a_)
                free.remove(b_)
                pre.append(('load', X(a_), g))
                self.tmp_force[tmpu[0][0][1]] = X(b_)
                continue
            last = users[-1]
            lv = last[0][1]
            k = run.index(users[0][0])
            in_wa = last[2] == 1 and self.home(lv) in ('QIZ', 'slot', 'IZ') and \
                (self.home(lv) != 'IZ' or self.proxy(lv)) and last[0][2][0] in ('add', 'sub', 'addk')
            k = run.index(users[0][0])
            m = run.index(last[0])
            for st in run[k:m]:                              # something between computes in WA
                hv = self.home(st[1])
                if not (hv == 'IZ' and not self.proxy(st[1])) and not (self.opt and hv == 'IZ' and st[2][0] == 'glob'):
                    in_wa = False
            reg = 'WA' if in_wa and 'WA' in free else [x for x in free if x != 'WA'][0]
            free.remove(reg)
            pre.append(('load', X(reg), g))
        first = {g: [x[0] for x in reads if x[1] == g][0] for g in multi}
        rest = [st for st in run if id(st) not in hoisted]
        for i, st in enumerate(rest):
            for x in pre:                                    # each hoist / load right before the global's first reader
                g = x[1][2][1] if x[0] == 'def' else x[2]
                if first[g] is st:
                    if x[0] == 'def':
                        self.st_def(x[1], None)
                        self.cse[g] = x[1][1]
                    else:
                        self.e('ld %s,(%s)' % (x[1], x[2]))
                        self.cse[g] = x[1]
            self.st_def(st, rest[i + 1] if i + 1 < len(rest) else after)
            if id(st) in after_set:
                self.cse[after_set[id(st)]] = st[1]
        self.cse = {}

    def st_call0(self, st, nxt):
        self.e('cal ' + (st[1] if not self.xr else '.' + st[1][1:]))

    def st_sink(self, st, nxt):
        if getattr(self, 'fwd', None) is st:
            self.fwd = None
        else:
            self.pass_arg(('v', st[2]))
        self.call(st[1], st)

    def store(self, v, src):
        """the value in register src (HL / XHL / WA / XWA) to v's home"""
        h = self.home(v)
        if h in REGS:
            self.e('ld %s,%s' % (h, src))
        elif h == 'tmp':
            if self.opt and self.xr and src in ('HL', 'XHL'):    # -O -Xr: a call result moves to WA at once
                W = 'WA' if v.size == 2 else 'XWA'
                self.e('ld %s,%s' % (W, src))
                src = W
            self.tmp[v] = src
        else:
            self.e('ld %s,%s' % (self.at(v), src))

    def forward(self, v, W, fwd, nxt):
        """cdecl: the value is in W and the next statement is v's sink: push it before the store"""
        if fwd and self.home(v) == 'slot' and (self.xr or v.size == 4) and not (self.opt and self.xr and W in ('BC', 'XBC')):
            return                                      # (a slot is read back: adecl, and a long under cdecl)
        if fwd and not self.xr:
            self.e('push %s' % W)
            self.pending += v.size
            self.fwd = nxt
        elif fwd:
            if W not in ('WA', 'XWA'):
                self.e('ld %s,%s' % ('WA' if v.size == 2 else 'XWA', W))
            self.fwd = nxt                              # adecl: the argument is already in WA

    def tmpreg(self, v, W):
        """a value with no call in its range stays in WA (XWA), or in BC (XBC) when WA is used before its read"""
        if v in self.tmp_force:
            return self.tmp_force[v]
        if self.xuse.get(v) and not (self.opt and self.xr):
            return 'XBC' if v.size == 4 else 'BC'
        return W

    def st_def(self, st, nxt):
        v, r = st[1], st[2]
        h = self.home(v)
        L = v.size == 4
        W, X = ('XWA', 'XHL') if L else ('WA', 'HL')
        fwd = nxt is not None and nxt[0] == 'sink' and nxt[2] is v
        if r[0] == 'call':
            if r[2] is not None:
                self.pass_arg(r[2])
            self.call(r[1], st)
            self.store(v, X)
            return
        direct = (h == 'IZ' and not self.proxy(v)) or h == 'XIZ'
        if self.opt and self.xr and fwd and h != 'tmp' and r[0] != 'const' and not direct and \
                not (h == 'slot' and not self.proxy(v) and (r[0] in ('add', 'sub') or r[0] == 'addk' and L)):
            W = 'XBC' if L else 'BC'                        # -O -Xr: a value read next as the argument is
                                                            # computed in BC, copied to WA and to its home
        if self.opt and self.xr and W == 'WA' and h != 'tmp' and 'WA' in self.tmp.values():
            W = 'BC'                                        # -O -Xr: WA holds a pending argument
        if r[0] == 'const':
            if h in REGS:
                self.e('ld %s,0x0' % h)
            elif h == 'tmp':
                raise Decline()
            else:
                self.e('ldw %s,0x0' % self.at(v) if not L else 'ld %s,0x0' % self.at(v))
            return
        s1 = self.gsrc(r[1], L)
        isreg = lambda x: x in ('WA', 'BC', 'DE', 'IZ', 'QIZ', 'XWA', 'XBC', 'XIZ')
        if r[0] == 'glob':
            if direct or (isreg(s1) and h in REGS):
                self.e('ld %s,%s' % (h, s1))
                return
            if h == 'tmp':
                W = self.tmpreg(v, W)
            if self.opt and h == 'IZ' and not fwd:          # -O: ld WA,x / ld IZ,WA folds to ld IZ,x
                self.e('ld IZ,%s' % s1)
                return
            if s1 != W:
                self.e('ld %s,%s' % (W, s1))
            if h == 'tmp':
                self.tmp[v] = W
                return
            self.forward(v, W, fwd, nxt)
            self.store(v, W)
            return
        if r[0] in ('add', 'sub', 'addk'):
            op = r[0] if r[0] != 'addk' else 'inc'
            s2 = self.gsrc(r[2], L) if r[0] != 'addk' else hx(r[2])

            def opn(dst):
                return '%s %s,%s' % (op, s2, dst) if r[0] == 'addk' else '%s %s,%s' % (op, dst, s2)
            if direct:
                self.e('ld %s,%s' % (h, s1))
                self.e(opn(h))
                return
            if h == 'tmp':
                W = self.tmpreg(v, W)
                if s1 != W:
                    self.e('ld %s,%s' % (W, s1))
                self.e(opn(W))
                self.tmp[v] = W
                return
            if h in REGS or (h == 'slot' and self.proxy(v)):
                # generated for a register that takes no memory operand (QIZ), then renamed IZ or a frame slot
                loc = h if h in REGS else self.at(v)
                Wop = W
                W = 'XWA' if L else 'WA'
                in_w = None
                if isreg(s1):
                    self.e('ld %s,%s' % (loc, s1))
                    in_w = s1
                elif r[0] == 'addk':
                    self.e('ld %s,%s' % (Wop, s1))
                    in_w = Wop
                elif self.opt and h == 'IZ':
                    self.e('ld IZ,%s' % s1)                 # -O: ld WA,x / ld IZ,WA folds to ld IZ,x
                else:
                    self.e('ld %s,%s' % (W, s1))
                    self.e('ld %s,%s' % (loc, W))
                    in_w = W
                if in_w != Wop and r[0] == 'addk' and h in REGS and not fwd:
                    self.e(opn(h))                          # a register operand: inc straight on the home
                    return
                if in_w != Wop:
                    self.e('ld %s,%s' % (Wop, loc))
                self.e(opn(Wop))
                self.forward(v, Wop, fwd, nxt)
                self.e('ld %s,%s' % (loc, Wop))
                return
            if s1 != W:
                self.e('ld %s,%s' % (W, s1))
            if r[0] == 'addk' and not L or isreg(s2) and s2 != 'QIZ':   # a slot: compute in WA, then store
                self.e(opn(W))
                self.forward(v, W, fwd, nxt)
                self.store(v, W)
                return
            self.store(v, W)                                # a slot: store the first operand, then op in memory
            if r[0] == 'addk':
                self.e('ld XWA,%s' % hx(r[2]))
                self.e('add %s,XWA' % self.at(v))
                return
            self.e('ld %s,%s' % (W, s2))
            self.e('%s %s,%s' % (op, self.at(v), W))
            return
        raise Decline()

    def gsrc(self, g, L):
        """where global g is read: memory, or the register / slot -O's common subexpression put it in"""
        c = self.cse.get(g)
        if c is None:
            return '(%s)' % g
        if isinstance(c, V):
            return self.home(c) if self.home(c) in REGS else self.at(c)
        return c

    def st_addcall(self, st, nxt):
        v, r = st[1], st[2]
        if r[2] is not None:
            self.pass_arg(r[2])
        self.call(r[1], st)
        h = self.home(v)
        if h == 'IZ' and not self.proxy(v):
            self.e('add IZ,HL')
        elif h in REGS:
            self.e('ld WA,%s' % h)
            self.e('add WA,HL')
            self.e('ld %s,WA' % h)
        elif h in ('slot', 'mem'):
            self.e('add %s,HL' % self.at(v))
        else:
            raise Decline()

    def st_whileg(self, st, nxt):
        g = st[1]
        x, y = self.lab(), self.lab()
        ent = getattr(self, 'loop_reg', None)
        self.loop_reg = None
        if self.opt and ent is None:                        # -O: the test at the bottom, entered by a jump
            self.e('j %s' % x)
            self.e(y + ':')
            self.body(st[2])
            self.e(x + ':')
            self.e('cpw (%s),0x0' % g)
            self.e('j ne,%s' % y)
            return
        if ent is not None:                                 # -O: the global is still in a register: test it there
            self.e('cp %s,0x0' % ent)
        else:
            self.e('cpw (%s),0x0' % g)
        self.e('j eq,%s' % x)
        self.e(y + ':')
        self.body(st[2])
        self.e('cpw (%s),0x0' % g)
        self.e('j ne,%s' % y)
        self.e(x + ':')

    def dectest(self, v):
        h = self.home(v)
        need(h in REGS and not self.proxy(v))
        self.e('ld WA,%s' % h)
        self.e('dec 0x1,%s' % h)
        self.e('cp WA,0x0')

    def st_whiledec(self, st, nxt):
        v = st[1]
        x, y = self.lab(), self.lab()
        if self.opt:
            self.e('j %s' % x)
            self.e(y + ':')
            self.body(st[2])
            self.e(x + ':')
            self.dectest(v)
            self.e('j ne,%s' % y)
            return
        self.dectest(v)
        self.e('j eq,%s' % x)
        self.e(y + ':')
        self.body(st[2])
        self.dectest(v)
        self.e('j ne,%s' % y)
        self.e(x + ':')

    def fortest(self, v, p):
        h = self.home(v)
        need(h in REGS)
        bnd = self.at(p) if self.home(p) in ('slot', 'mem') else self.home(p)
        need(bnd not in ('tmp',))
        if h == 'IZ' and not self.proxy(v):
            self.e('cp IZ,%s' % bnd)
        else:
            self.e('ld WA,%s' % h)
            self.e('cp WA,%s' % bnd)

    def st_for(self, st, nxt):
        v, p = st[1], st[2]
        x, y = self.lab(), self.lab()
        self.e('ld %s,0x0' % self.home(v))
        if self.opt:                                        # -O: 0 < p
            hp = self.home(p)
            need(hp in ('slot', 'mem'))
            self.e('cpw %s,0x0' % self.at(p))
            self.e('j le,%s' % x)
        else:
            self.fortest(v, p)
            self.e('j ge,%s' % x)
        self.e(y + ':')
        self.body(st[3])
        self.e('inc 0x1,%s' % self.home(v))
        self.fortest(v, p)
        self.e('j lt,%s' % y)
        self.e(x + ':')

    # ---- the function
    def run(self):
        F = self.F
        self.tmp = {}
        self.cse = {}
        self.tmp_force = {}
        hs = {self.hname(v) for v in F.vals}
        self.save = 4 if hs & {'QIZ', 'XIZ'} else 2 if 'IZ' in hs else 0
        self.slot = {}
        off = 0
        order = self.H.get('_slots') or slot_order(F, self.H)
        info = Info(F)
        for v in order:
            if self.hname(v) == 'slot':
                if self.opt and v.size == 2:                # -O: values that never meet share a slot
                    taken = {self.slot[w] for w in self.slot if w.size == 2 and info.interfere(v, w)} | \
                        {o for w in self.slot if w.size == 4 for o in (self.slot[w], self.slot[w] + 2)}
                    o = 0
                    while o in taken or o + 2 > off and o < off and False:
                        o += 2
                    if o < off:
                        self.slot[v] = o
                        continue
                self.slot[v] = off
                off += v.size
        self.frame = off
        self.poff = {}
        off = 0
        for v in F.params:
            self.poff[v] = off
            off += v.size
        self.xuse = clobbered_before_use(F, self.H)
        if self.frame:
            self.e('dec %s,XSP' % hx(self.frame))
        if self.save:
            self.e('push %s' % ('XIZ' if self.save == 4 else 'IZ'))
        self.entry()
        self.body(F.body)
        if not self.save and not self.frame and self.out and self.out[-1].startswith('cal ') and \
                F.body and F.body[-1][0] == 'call0':
            self.out[-1] = 'j ' + self.out[-1][4:]           # a last call with nothing to restore: a jump
            return self.out
        if self.save:
            self.e('pop %s' % ('XIZ' if self.save == 4 else 'IZ'))
        if self.frame:
            self.e('inc %s,XSP' % hx(self.frame))
        self.e('ret')
        return self.out

    def entry(self):
        F = self.F
        if not self.xr:
            self.unloaded = set()
            for v in F.params:
                h = self.hname(v)
                if self.opt and h in REGS and not any(k == 'upd' for _, k in Info(F).defs[v]):
                    self.unloaded.add(v)
                    continue
                if h in REGS:
                    self.e('ld %s,(XSP+%s)' % (h, hx(self.save + self.frame + 4 + self.poff[v])))
            return
        regs = {}
        k = 0
        for v in F.params:
            need(k < 2)
            regs[v] = ('WA', 'BC')[k] if v.size == 2 else ('XWA', 'XBC')[k]
            k += 1
        for v in reversed(F.params):
            h = self.home(v)
            if h in REGS:
                self.e('ld %s,%s' % (h, regs[v]))
            elif h == 'slot':
                self.e('ld %s,%s' % (self.at(v), regs[v]))
            elif h == 'tmp':
                if Info(F).uses[v]:
                    self.tmp[v] = regs[v]
            else:
                raise Decline()


def slot_order(F, H):
    return sorted([v for v in F.vals if v.kind == 'local'], key=lambda v: first_def(F, v)) + \
        [v for v in reversed(F.params)]


def first_def(F, v):
    """the position of v's first definition in program order"""
    k = [0]
    pos = {}

    def walk(lst):
        for st in lst:
            k[0] += 1
            if st[0] in ('def', 'addcall') and st[1] not in pos:
                pos[st[1]] = k[0]
            if st[0] == 'for' and st[1] not in pos:
                pos[st[1]] = k[0]
            if st[0] in ('whileg', 'whiledec', 'for'):
                walk(st[-1])
    walk(F.body)
    return pos.get(v, 10 ** 6 + v.order)


def clobbered_before_use(F, H):
    """{v: True} for each scratch-register value whose read comes after a statement that uses WA"""
    flat = []

    def walk(lst):
        for st in lst:
            if st[0] in ('whileg', 'whiledec', 'for'):
                flat.append(('loop',))
                walk(st[-1])
            else:
                flat.append(st)
    walk(F.body)
    out = {}
    for i, st in enumerate(flat):
        if st[0] == 'def' and H[st[1]]['home'] == 'tmp':
            v = st[1]
            for x in flat[i + 1:]:
                if x[0] == 'sink' and x[2] is v or x[0] in ('addcall',) and x[2][2] == ('v', v):
                    break
                if x[0] == 'def' and x[2][0] == 'call' and x[2][2] == ('v', v):
                    break
                if x[0] == 'def' and not (H[x[1]]['home'] in ('IZ', 'XIZ') and not H[x[1]].get('proxy')):
                    out[v] = True
                    break
                if x[0] != 'def':
                    break
    return out


def ins(s):
    if s.endswith(':'):
        return s
    p = s.split(' ', 1)
    return '\t' + p[0] + ('\t' + p[1] if len(p) > 1 else '')


def emit(F, s, H):
    return [ins(x) for x in Em(F, s, H).run()]


# --------------------------------------------------------------------------------------------- liveness

class Info:
    """per value: definition kinds, reads, live interval over statement positions, interference"""

    def __init__(self, F):
        self.F = F
        self.pos = 0
        self.calls = []
        self.defs = {v: [] for v in F.vals}
        self.uses = {v: [] for v in F.vals}
        self.loops = []
        for v in F.params:
            self.defs[v].append((0, 'param'))
        self.walk(F.body)
        self.end = self.pos + 1
        self.iv = {}
        for v in F.vals:
            if not self.uses[v]:
                self.iv[v] = None
                continue
            a = min(p for p, _ in self.defs[v]) if self.defs[v] else 0
            b = max(p for p, _ in self.uses[v])
            for lo, hi in self.loops:            # read in a loop it is defined before: lives to the loop's end
                if any(lo <= p <= hi for p, _ in self.uses[v]) and a < lo:
                    b = max(b, hi)
                if any(lo <= p <= hi for p, _ in self.defs[v]) and any(lo <= p <= hi for p, _ in self.uses[v]):
                    if any(p < min(q for q, _ in self.defs[v] if lo <= q <= hi) for p, _ in self.uses[v]
                           if lo <= p <= hi):
                        a, b = min(a, lo), max(b, hi)
            self.iv[v] = (a, b)

    def step(self):
        self.pos += 1
        return self.pos

    def walk(self, lst):
        for st in lst:
            k = st[0]
            if k == 'def':
                p = self.step()
                r = st[2]
                if r[0] == 'call':
                    if r[2] and r[2][0] == 'v':
                        self.uses[r[2][1]].append((p, 'arg'))
                    self.calls.append(p)
                self.defs[st[1]].append((p, r[0]))
            elif k == 'addcall':
                p = self.step()
                r = st[2]
                if r[2] and r[2][0] == 'v':
                    self.uses[r[2][1]].append((p, 'arg'))
                self.calls.append(p)
                self.uses[st[1]].append((p, 'upd'))
                self.defs[st[1]].append((p, 'upd'))
            elif k == 'sink':
                p = self.step()
                self.uses[st[2]].append((p, 'arg'))
                self.calls.append(p)
            elif k == 'call0':
                self.calls.append(self.step())
            elif k in ('whileg', 'whiledec', 'for'):
                lo = self.step()
                if k == 'whiledec':
                    self.uses[st[1]].append((lo, 'test'))
                    self.defs[st[1]].append((lo, 'upd'))
                if k == 'for':
                    self.defs[st[1]].append((lo, 'const'))
                    self.uses[st[1]].append((lo, 'test'))
                    self.uses[st[2]].append((lo, 'test'))
                self.walk(st[-1])
                hi = self.step()
                if k == 'whiledec':
                    self.uses[st[1]].append((hi, 'test'))
                if k == 'for':
                    self.uses[st[1]].append((hi, 'test'))
                    self.defs[st[1]].append((hi, 'upd'))
                    self.uses[st[2]].append((hi, 'test'))
                self.loops.append((lo, hi))

    def across(self, v):
        """a call strictly inside v's interval"""
        iv = self.iv[v]
        return iv is not None and any(iv[0] < c < iv[1] for c in self.calls)

    def interfere(self, v, w):
        a, b = self.iv[v], self.iv[w]
        return a is not None and b is not None and a[0] < b[1] and b[0] < a[1]


# --------------------------------------------------------------------------------------------- signature

def signature(F):
    """the function's shape with every name replaced by its order of first appearance: values by declaration
    index, globals and callees by first use (so renaming a global or a function changes nothing)"""
    names = {}

    def nm(x, kind):
        k = (kind, x)
        if k not in names:
            names[k] = '%s%d' % (kind, sum(1 for t in names if t[0] == kind))
        return names[k]
    vi = {v: 'v%d' % i for i, v in enumerate(F.vals)}

    def ser(x):
        if isinstance(x, V):
            return vi[x]
        if isinstance(x, tuple):
            return '(' + ','.join(ser(y) for y in x) + ')'
        if isinstance(x, list):
            return '[' + ';'.join(ser(y) for y in x) + ']'
        if isinstance(x, int):
            return str(x)
        if x is None:
            return '-'
        if x.startswith('_'):
            return nm(x, 'n')
        return x
    head = ','.join('%s%d%s' % (v.kind[0], v.size, 'i' if getattr(v, 'depth', 0) else '') for v in F.vals)
    return head + '|' + ser(F.body)


# --------------------------------------------------------------------------------------------- homes

def rule_homes(f, F, S):
    """the fitted homes2 rule (model homes2.predict: candidates live across a call, priority colouring, halves by
    its decision list); the code of a value is written for its final register (QIZ: through WA); frame slots in
    declaration order, locals first, then the parameters last to first"""
    import homes2
    xr = S.endswith('Xr')
    pr = homes2.predict(f, S, set(f.params) if xr else None)
    out = {}
    for v in F.vals:
        h = pr.get(v.d, '-')
        if h == '-':
            h = 'mem' if (v.kind == 'param' and not xr) else 'tmp'
        if h == 'mem' and xr:
            h = 'slot'
        out[v] = {'home': h, 'proxy': h == 'QIZ'}
    order = [v for v in F.vals if v.kind == 'local'] + list(reversed(F.params))
    sl = [v for v in order if out[v]['home'] == 'slot']
    out['_slots'] = sl if len(sl) > 1 else None
    return out


def table_homes(F, ent):
    """a tabulated assignment: 'IZ,QIZp,slot,...|slot order'"""
    hs, so = ent.split('|')
    out = {}
    for v, h in zip(F.vals, hs.split(',')):
        p = h.endswith('p') and h != 'tmp'
        out[v] = {'home': h[:-1] if p else h, 'proxy': p}
    out['_slots'] = [F.vals[int(i)] for i in so.split(',')] if so else None
    return out


def safe(F, H):
    """the rule alone is trusted when no two values live across a call at the same time"""
    I = Info(F)
    c = [v for v in F.vals if I.across(v)]
    return not any(I.interfere(v, w) for v in c for w in c if v is not w)


def whole(f, s):
    if s not in SETS:
        return None
    try:
        F = lower(f)
        sig = signature(F)
        ent = TABLE.get(s, {}).get(sig)
        if ent is not None:
            H = table_homes(F, ent)
        else:
            H = rule_homes(f, F, s)
            if sig not in RULE_OK.get(s, ()) and not safe(F, H):
                return None
        return emit(F, s, H)
    except Decline:
        return None


def check(p, s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE[p] % s, encoding='latin-1').read())
    unit = frontend.load(PROBES[p], [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        got = whole(f, s)
        if got is None:
            dec += 1
            continue
        if listing.normalise_labels(got) == listing.normalise_labels(W):
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    print('  %-36s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('homes2%s %-7s exact %4d  wrong %4d  declined %4d' % (p, s, ok, wrong, dec))
    return ok, wrong, dec


def rename_check(p, s):
    """the probe with every global and every called function renamed (gi -> zz_gi_q, g1 -> zz_g1_q ...): whole()
    must give the oracle's listing with the same names substituted (the decision reads no name)"""
    import os
    import tempfile
    import frontend
    import listing
    src = open(PROBES[p]).read()
    names = sorted(set(re.findall(r'\b(g[a-z0-9]*|s[a-e]|sl[a-c])\b', src)) - {'gen_probes'}, key=len, reverse=True)
    names = [n for n in names if re.search(r'\bextern\b[^;]*\b%s\b' % n, src)]
    mp = {n: 'zz_%s_q' % n for n in names}
    body = re.sub(r'\b(%s)\b' % '|'.join(names), lambda m: mp[m.group(1)], src)
    d = tempfile.mkdtemp(prefix='homes2-rename-')
    path = os.path.join(d, os.path.basename(PROBES[p]))
    open(path, 'w').write(body)
    want = listing.split(open(ORACLE[p] % s, encoding='latin-1').read())
    unit = frontend.load(path, [], [], adecl=s.endswith('Xr'))
    pre = '.' if s.endswith('Xr') else '_'
    sub = lambda l: re.sub(r'([._])(%s)\b' % '|'.join(names), lambda m: m.group(1) + mp[m.group(2)], l)
    ok = wrong = dec = 0
    for f in unit.functions:
        W = [sub(l) for l in want.get(pre + f.name, []) if 'section' not in l][1:]
        got = whole(f, s)
        if got is None:
            dec += 1
        elif listing.normalise_labels(got) == listing.normalise_labels(W):
            ok += 1
        else:
            wrong += 1
    os.remove(path)
    os.rmdir(d)
    print('renamed homes2%s %-7s exact %4d  wrong %4d  declined %4d   (%d names renamed)' % (p, s, ok, wrong, dec,
                                                                                          len(names)))
    return ok, wrong, dec


# --------------------------------------------------------------------------------------------- tables
# generated by dev/build_table.py from the probe runs: per option set, the homes the rule above gets wrong
# (corrections, by signature), and the signatures it gets right that are not 'safe'
# BEGIN TABLE
TABLE = {
    'none': {
        'l2,l2,l2,l2i|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(whileg,n0,[(def,v3,(glob,n0));(sink,n3,v3);(call0,n4);(sink,n3,v3);(sink,n3,v3)]);(def,v1,(addk,n0,5));(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(call0,n4);(sink,n6,v0)]':
            'QIZp,tmp,slot,IZ|',
        'l2,l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(call,n3,(k,3)));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n4,v3)]);(sink,n2,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(sink,n6,v0)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2i|[(def,v1,(call,n0,(k,1)));(whileg,n1,[(def,v3,(add,n1,n2));(sink,n3,v3);(call0,n4);(sink,n3,v3)]);(sink,n5,v1);(def,v0,(call,n0,(k,2)));(sink,n5,v1);(def,v2,(glob,n6));(sink,n5,v1);(sink,n7,v2);(sink,n8,v0);(sink,n7,v2);(sink,n7,v2)]':
            'QIZp,slotp,IZ,IZ|',
        'l2,l2,l2,l2i|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(def,v0,(sub,n1,n3));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(sink,n4,v3);(call0,n5);(sink,n4,v3)]);(call0,n5);(def,v1,(glob,n3));(sink,n6,v0);(sink,n2,v2);(sink,n6,v0);(sink,n7,v1);(sink,n6,v0)]':
            'QIZp,IZ,slot,IZ|',
        'l2,l2,l2,l2i|[(whileg,n0,[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(call0,n3);(sink,n2,v3)]);(def,v1,(glob,n0));(sink,n4,v1);(def,v0,(sub,n1,n5));(sink,n4,v1);(sink,n6,v0);(def,v2,(addk,n0,5));(sink,n7,v2);(sink,n7,v2);(sink,n4,v1)]':
            'IZ,QIZp,IZ,IZ|',
        'l2,l2,l2,l2|[(call0,n0);(def,v2,(glob,n1));(def,v0,(glob,n2));(sink,n3,v2);(def,v3,(glob,n4));(sink,n3,v2);(def,v1,(glob,n5));(sink,n3,v2);(sink,n3,v2);(sink,n6,v0);(sink,n7,v1);(sink,n8,v3);(sink,n6,v0);(call0,n0)]':
            'slot,IZ,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(call0,n0);(def,v3,(call,n1,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(addk,n3,5));(sink,n2,v1);(def,v0,(call,n1,(k,4)));(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n4,v2);(sink,n2,v1);(sink,n6,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v0);(def,v2,(call,n1,(k,3)));(def,v3,(call,n1,(k,4)));(sink,n2,v0);(sink,n2,v0);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n3,v3);(sink,n6,v1);(sink,n5,v2);(sink,n3,v3);(sink,n5,v2)]':
            'IZp,slot,slot,QIZp|1,2',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(call0,n2);(def,v3,(glob,n3));(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v0);(sink,n7,v3);(sink,n5,v1);(sink,n6,v0);(sink,n8,v2);(sink,n8,v2);(sink,n7,v3);(sink,n6,v0);(sink,n5,v1);(call0,n2)]':
            'QIZp,IZ,slot,slot|2,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v2,(call,n0,(k,3)));(sink,n3,v2);(call0,n1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n6,v3);(sink,n5,v0);(sink,n6,v3);(sink,n3,v2);(sink,n3,v2);(sink,n7,v1)]':
            'QIZp,slot,IZp,slot|1,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(def,v0,(call,n0,(k,3)));(def,v3,(call,n0,(k,4)));(sink,n2,v2);(sink,n3,v1);(sink,n3,v1);(sink,n2,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n2,v2);(sink,n5,v3);(sink,n3,v1);(sink,n5,v3);(sink,n4,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(call,n0,(k,3)));(def,v0,(glob,n3));(sink,n4,v3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n7,v2);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0)]':
            'IZp,slot,slot,QIZp|1,2',
        'l2,l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(def,v3,(call,n2,(k,3)));(sink,n4,v2);(def,v1,(sub,n5,n6));(sink,n3,v0);(sink,n7,v3);(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n3,v0);(sink,n8,v1)]':
            'QIZp,slot,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v0,(addk,n3,5));(def,v1,(glob,n4));(sink,n5,v3);(sink,n6,v0);(sink,n5,v3);(sink,n5,v3);(sink,n7,v1);(sink,n8,v2);(sink,n7,v1);(sink,n6,v0);(sink,n7,v1)]':
            'QIZp,slotp,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n1,v2);(def,v0,(glob,n2));(call0,n3);(def,v3,(add,n4,n2));(sink,n5,v3);(sink,n5,v3);(sink,n6,v0);(def,v1,(addk,n4,5));(sink,n6,v0);(sink,n7,v1)]':
            'QIZp,IZ,IZ,IZ|',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v3,(glob,n2));(sink,n4,v3);(call0,n5);(sink,n4,v3);(def,v1,(glob,n6));(sink,n7,v2);(sink,n8,v1);(sink,n8,v1);(sink,n7,v2);(sink,n4,v3);(sink,n3,v0);(call0,n5);(sink,n8,v1);(sink,n4,v3);(sink,n3,v0)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v3);(def,v0,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n6);(def,v2,(sub,n7,n8));(sink,n9,v2);(sink,n9,v2);(sink,n3,v3)]':
            'QIZp,IZp,IZ,slot|',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(sink,n2,v3);(def,v1,(add,n0,n1));(call0,n3);(def,v2,(call,n4,(k,2)));(sink,n5,v2);(def,v0,(call,n4,(k,3)));(sink,n6,v0);(sink,n7,v1);(sink,n7,v1);(sink,n6,v0)]':
            'QIZp,IZp,tmp,IZ|',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(call0,n1);(sink,n2,v3);(sink,n2,v3);(call0,n1);(def,v0,(call,n0,(k,2)));(def,v2,(addk,n3,5));(sink,n4,v2);(sink,n4,v2);(def,v1,(glob,n5));(sink,n2,v3);(sink,n4,v2);(sink,n2,v3);(sink,n6,v0);(sink,n7,v1);(sink,n7,v1)]':
            'slot,IZ,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v3);(def,v0,(addk,n0,5));(sink,n5,v0);(def,v2,(call,n6,(k,4)));(sink,n3,v1);(sink,n7,v2);(sink,n5,v0);(sink,n4,v3);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n4,v3)]':
            'QIZp,slot,IZp,slot|1,3',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2)]);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n6,v0)]':
            'slotp,IZ,QIZp|',
        'l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(whileg,n0,[(def,v2,(call,n2,(k,1)));(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(call0,n4);(sink,n6,v0);(sink,n5,v1)]':
            'IZ,QIZp,tmp|',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(def,v1,(sub,n3,n4));(def,v0,(glob,n4));(sink,n5,v0);(sink,n2,v2);(sink,n6,v1);(sink,n2,v2);(sink,n5,v0);(sink,n2,v2);(sink,n5,v0);(sink,n6,v1);(call0,n0);(sink,n5,v0)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(def,v2,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(sink,n6,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v0);(def,v1,(glob,n4));(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n5,v2)]':
            'QIZp,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(sink,n3,v1);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n2,v0);(sink,n3,v1);(call0,n4);(sink,n2,v0);(sink,n5,v2)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(def,v2,(call,n0,(k,3)));(sink,n1,v2);(sink,n2,v0);(sink,n1,v2);(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(def,v2,(addk,n5,5));(sink,n6,v2);(sink,n4,v1);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(call0,n2);(def,v1,(addk,n3,5));(sink,n1,v0);(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(sink,n4,v2);(sink,n5,v1)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n3));(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]':
            'IZ,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n2,v1);(sink,n3,v2);(sink,n4,v0);(sink,n4,v0);(sink,n3,v2)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n5,v0)]':
            'QIZp,IZ,IZ|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(sub,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(def,v1,(call,n5,(k,3)));(sink,n4,v0);(sink,n4,v0);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n3,v2)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(call0,n2);(sink,n3,v0);(sink,n3,v0);(def,v2,(glob,n4));(sink,n5,v2);(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n3,v0)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v0,(sub,n2,n3));(def,v2,(glob,n3));(sink,n1,v1);(sink,n1,v1);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v2,(sub,n2,n3));(sink,n1,v1);(def,v0,(addk,n4,5));(call0,n5);(sink,n6,v0);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2);(sink,n6,v0);(call0,n5);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(glob,n0));(sink,n3,v2);(sink,n2,v1);(sink,n2,v1);(sink,n4,v0)]':
            'IZ,QIZp,tmp|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(glob,n1));(def,v1,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0);(sink,n5,v2);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(glob,n1));(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v0,(glob,n2));(def,v1,(call,n0,(k,3)));(sink,n3,v1);(sink,n4,v0);(call0,n1);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]':
            'IZp,tmp,QIZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(glob,n1));(sink,n2,v2);(def,v1,(call,n0,(k,3)));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n2,v2);(call0,n4)]':
            'IZp,tmp,QIZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v0,(sub,n2,n3));(sink,n1,v2);(def,v1,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n1,v2);(sink,n5,v0);(call0,n6);(sink,n4,v1)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v1,(glob,n2));(sink,n1,v2);(sink,n3,v1);(def,v0,(addk,n4,5));(sink,n1,v2);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(call0,n5);(sink,n3,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(call0,n4);(sink,n2,v1)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n3,v1);(sink,n1,v0);(sink,n1,v0);(sink,n3,v1);(sink,n3,v1)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l4,l2,l2|[(def,v0,(addk,n0,1));(call0,n1);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(def,v1,(call,n2,(k,3)));(call0,n1);(sink,n5,v1)]':
            'XIZ,IZ,slot|',
        'l4,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(call,n1,(k,2)));(def,v1,(addk,n2,5));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(call0,n5);(sink,n6,v2);(sink,n4,v0)]':
            'slot,IZ,slotp|0,2',
        'l4,l4|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0)]':
            'slot,XIZ|',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v2)]);(sink,n4,v4)]':
            'mem,mem,QIZp,IZ,slot|',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v4)]);(sink,n4,v2)]':
            'mem,mem,slot,IZ,QIZp|',
        'p2,p2,l2,l2,l2|[(def,v4,(glob,n0));(def,v3,(const,0));(for,v2,v0,[(addcall,v3,(call,n1,(v,v2)));(sink,n2,v4)]);(sink,n3,v3)]':
            'mem,mem,IZ,QIZp,slot|',
        'p2,p2,l2,l2i|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]':
            'mem,mem,QIZp,IZp|',
        'p2,p2,l2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(glob,n2));(sink,n1,v1);(def,v3,(call,n3,(k,2)));(sink,n4,v3);(sink,n5,v2);(sink,n4,v3);(sink,n6,v0);(sink,n5,v2);(sink,n6,v0)]':
            'mem,mem,IZp,QIZp|',
        'p2,p2,l2,l2|[(def,v2,(add,n0,n1));(def,v3,(const,0));(whiledec,v1,[(addcall,v3,(call,n2,(v,v1)))]);(sink,n3,v2);(sink,n4,v3)]':
            'mem,IZ,QIZp,slotp|',
        'p2,p2,l2,l2|[(def,v2,(const,0));(for,v3,v0,[(sink,n0,v3);(addcall,v2,(call,n1,(v,v3)))]);(sink,n2,v2)]':
            'mem,mem,IZ,QIZp|',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v2)]);(sink,n3,v3)]':
            'mem,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v3)]);(sink,n3,v2)]':
            'mem,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(for,v2,v0,[(sink,n1,v2)]);(sink,n2,v3)]':
            'mem,mem,QIZp,IZp|',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v0);(sink,n2,v1);(def,v2,(glob,n3));(call0,n4);(sink,n5,v3);(sink,n1,v0);(sink,n6,v2);(call0,n4);(sink,n2,v1)]':
            'mem,mem,IZp,QIZp|',
        'p2,p2,l2,l2|[(def,v3,(const,0));(for,v2,v0,[(sink,n0,v2);(addcall,v3,(call,n1,(v,v2)))]);(sink,n2,v3)]':
            'mem,mem,IZ,QIZp|',
        'p2,p2,l2,l2|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]':
            'mem,mem,QIZp,IZp|',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(sink,n3,v1);(sink,n0,v0);(def,v3,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n6,v3);(sink,n2,v2);(sink,n6,v3);(call0,n5);(sink,n3,v1);(sink,n3,v1);(sink,n0,v0)]':
            'mem,mem,QIZp,IZ|',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n4,v0);(def,v3,(call,n5,(k,2)));(sink,n6,v3);(sink,n3,v2);(sink,n0,v1);(call0,n7);(sink,n6,v3)]':
            'mem,mem,QIZp,IZ|',
        'p2,p2,l2|[(call0,n0);(def,v2,(glob,n1));(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n3,v1);(sink,n4,v2);(sink,n3,v1)]':
            'mem,IZ,slotp|',
        'p2,p2,l2|[(sink,n0,v1);(sink,n1,v0);(sink,n1,v0);(call0,n2);(def,v2,(glob,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(call0,n2);(sink,n1,v0)]':
            'IZ,mem,slotp|',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(call0,n3);(call0,n3);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1)]':
            'mem,IZ|',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v1,(glob,n3));(call0,n4);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]':
            'mem,XIZ,tmp|',
    },
    'O3XS': {
        'l2,l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(call,n3,(k,3)));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n4,v3)]);(sink,n2,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(sink,n6,v0)]':
            'slot,QIZp,slot,IZ|2,0',
        'l2,l2,l2,l2i|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(def,v0,(sub,n1,n3));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(sink,n4,v3);(call0,n5);(sink,n4,v3)]);(call0,n5);(def,v1,(glob,n3));(sink,n6,v0);(sink,n2,v2);(sink,n6,v0);(sink,n7,v1);(sink,n6,v0)]':
            'QIZp,IZp,slot,IZ|',
        'l2,l2,l2,l2i|[(whileg,n0,[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(call0,n3);(sink,n2,v3)]);(def,v1,(glob,n0));(sink,n4,v1);(def,v0,(sub,n1,n5));(sink,n4,v1);(sink,n6,v0);(def,v2,(addk,n0,5));(sink,n7,v2);(sink,n7,v2);(sink,n4,v1)]':
            'IZ,QIZp,IZ,IZ|',
        'l2,l2,l2,l2|[(call0,n0);(def,v2,(glob,n1));(def,v0,(glob,n2));(sink,n3,v2);(def,v3,(glob,n4));(sink,n3,v2);(def,v1,(glob,n5));(sink,n3,v2);(sink,n3,v2);(sink,n6,v0);(sink,n7,v1);(sink,n8,v3);(sink,n6,v0);(call0,n0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(call0,n0);(def,v3,(call,n1,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(addk,n3,5));(sink,n2,v1);(def,v0,(call,n1,(k,4)));(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n4,v2);(sink,n2,v1);(sink,n6,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(call0,n2);(def,v3,(glob,n3));(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v0);(sink,n7,v3);(sink,n5,v1);(sink,n6,v0);(sink,n8,v2);(sink,n8,v2);(sink,n7,v3);(sink,n6,v0);(sink,n5,v1);(call0,n2)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(sink,n2,v2);(sink,n2,v2);(def,v1,(addk,n0,5));(sink,n2,v2);(def,v3,(call,n3,(k,4)));(sink,n4,v0);(sink,n5,v3);(sink,n6,v1);(sink,n5,v3);(sink,n2,v2)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v2,(call,n0,(k,3)));(sink,n3,v2);(call0,n1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n6,v3);(sink,n5,v0);(sink,n6,v3);(sink,n3,v2);(sink,n3,v2);(sink,n7,v1)]':
            'QIZp,slot,IZp,slot|1,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(def,v0,(call,n0,(k,3)));(def,v3,(call,n0,(k,4)));(sink,n2,v2);(sink,n3,v1);(sink,n3,v1);(sink,n2,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n2,v2);(sink,n5,v3);(sink,n3,v1);(sink,n5,v3);(sink,n4,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(def,v3,(call,n2,(k,3)));(sink,n4,v2);(def,v1,(sub,n5,n6));(sink,n3,v0);(sink,n7,v3);(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n3,v0);(sink,n8,v1)]':
            'QIZp,slot,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v0,(addk,n3,5));(def,v1,(glob,n4));(sink,n5,v3);(sink,n6,v0);(sink,n5,v3);(sink,n5,v3);(sink,n7,v1);(sink,n8,v2);(sink,n7,v1);(sink,n6,v0);(sink,n7,v1)]':
            'QIZp,slotp,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n1,v2);(def,v0,(glob,n2));(call0,n3);(def,v3,(add,n4,n2));(sink,n5,v3);(sink,n5,v3);(sink,n6,v0);(def,v1,(addk,n4,5));(sink,n6,v0);(sink,n7,v1)]':
            'QIZp,IZ,IZ,IZ|',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v3,(glob,n2));(sink,n4,v3);(call0,n5);(sink,n4,v3);(def,v1,(glob,n6));(sink,n7,v2);(sink,n8,v1);(sink,n8,v1);(sink,n7,v2);(sink,n4,v3);(sink,n3,v0);(call0,n5);(sink,n8,v1);(sink,n4,v3);(sink,n3,v0)]':
            'slot,IZp,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v3);(def,v0,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n6);(def,v2,(sub,n7,n8));(sink,n9,v2);(sink,n9,v2);(sink,n3,v3)]':
            'QIZp,IZp,IZ,slot|',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(sink,n2,v3);(def,v1,(add,n0,n1));(call0,n3);(def,v2,(call,n4,(k,2)));(sink,n5,v2);(def,v0,(call,n4,(k,3)));(sink,n6,v0);(sink,n7,v1);(sink,n7,v1);(sink,n6,v0)]':
            'QIZp,IZp,tmp,IZ|',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(call0,n1);(sink,n2,v3);(sink,n2,v3);(call0,n1);(def,v0,(call,n0,(k,2)));(def,v2,(addk,n3,5));(sink,n4,v2);(sink,n4,v2);(def,v1,(glob,n5));(sink,n2,v3);(sink,n4,v2);(sink,n2,v3);(sink,n6,v0);(sink,n7,v1);(sink,n7,v1)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v3);(def,v0,(addk,n0,5));(sink,n5,v0);(def,v2,(call,n6,(k,4)));(sink,n3,v1);(sink,n7,v2);(sink,n5,v0);(sink,n4,v3);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n4,v3)]':
            'QIZp,slot,IZp,slot|1,3',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2)]);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(whileg,n0,[(def,v2,(call,n2,(k,1)));(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(call0,n4);(sink,n6,v0);(sink,n5,v1)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(def,v1,(sub,n3,n4));(def,v0,(glob,n4));(sink,n5,v0);(sink,n2,v2);(sink,n6,v1);(sink,n2,v2);(sink,n5,v0);(sink,n2,v2);(sink,n5,v0);(sink,n6,v1);(call0,n0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(def,v2,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(sink,n6,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v0);(def,v1,(glob,n4));(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n5,v2)]':
            'QIZp,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v2);(def,v1,(glob,n2));(sink,n4,v1);(sink,n3,v2);(sink,n3,v2);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,tmp,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(call,n3,(k,2)));(def,v2,(call,n3,(k,3)));(sink,n4,v2);(sink,n5,v1);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(sink,n3,v1);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n2,v0);(sink,n3,v1);(call0,n4);(sink,n2,v0);(sink,n5,v2)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(def,v2,(call,n0,(k,3)));(sink,n1,v2);(sink,n2,v0);(sink,n1,v2);(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(def,v2,(addk,n5,5));(sink,n6,v2);(sink,n4,v1);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(call0,n2);(def,v1,(addk,n3,5));(sink,n1,v0);(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(sink,n4,v2);(sink,n5,v1)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n2,v1);(sink,n3,v2);(sink,n4,v0);(sink,n4,v0);(sink,n3,v2)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n5,v0)]':
            'QIZp,IZp,IZ|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(def,v1,(addk,n0,5));(sink,n2,v0);(sink,n3,v2);(sink,n3,v2);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0);(sink,n3,v2);(sink,n2,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(sub,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(def,v1,(call,n5,(k,3)));(sink,n4,v0);(sink,n4,v0);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n3,v2)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(def,v2,(call,n4,(k,3)));(sink,n5,v1);(sink,n6,v2);(sink,n1,v0);(sink,n1,v0);(sink,n1,v0)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v1);(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(sink,n5,v2);(sink,n3,v1)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(call0,n2);(sink,n3,v0);(sink,n3,v0);(def,v2,(glob,n4));(sink,n5,v2);(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n3,v0)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v0,(sub,n2,n3));(def,v2,(glob,n3));(sink,n1,v1);(sink,n1,v1);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v2,(sub,n2,n3));(sink,n1,v1);(def,v0,(addk,n4,5));(call0,n5);(sink,n6,v0);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2);(sink,n6,v0);(call0,n5);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(glob,n0));(sink,n3,v2);(sink,n2,v1);(sink,n2,v1);(sink,n4,v0)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(def,v0,(glob,n2));(sink,n3,v0);(sink,n4,v1);(sink,n5,v2);(sink,n3,v0);(sink,n5,v2);(sink,n3,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v0,(sub,n2,n3));(sink,n1,v2);(def,v1,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n1,v2);(sink,n5,v0);(call0,n6);(sink,n4,v1)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v1,(glob,n2));(sink,n1,v2);(sink,n3,v1);(def,v0,(addk,n4,5));(sink,n1,v2);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(call0,n5);(sink,n3,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n4,v0);(sink,n3,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n3,v1);(sink,n1,v0);(sink,n1,v0);(sink,n3,v1);(sink,n3,v1)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v0);(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n2,v0)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n3)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l4,l2,l2|[(def,v0,(addk,n0,1));(call0,n1);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(def,v1,(call,n2,(k,3)));(call0,n1);(sink,n5,v1)]':
            'XIZ,IZ,slot|',
        'l4,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n6,v2);(sink,n3,v1)]':
            'tmp,IZ,QIZp|',
        'l4,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(call,n1,(k,2)));(def,v1,(addk,n2,5));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(call0,n5);(sink,n6,v2);(sink,n4,v0)]':
            'slot,IZ,slotp|0,2',
        'l4,l4|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0)]':
            'slot,XIZ|',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v2)]);(sink,n4,v4)]':
            'mem,mem,slot,IZ,slot|2,4',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v4)]);(sink,n4,v2)]':
            'mem,mem,slot,IZ,slot|2,4',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v3)]);(sink,n3,v2);(sink,n4,v4)]':
            'mem,mem,slotp,slot,IZ|2,3',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v4)]);(sink,n3,v2);(sink,n4,v3)]':
            'mem,mem,slotp,slot,IZ|2,3',
        'p2,p2,l2,l2,l2|[(def,v2,(glob,n0));(def,v3,(const,0));(for,v4,v0,[(addcall,v3,(call,n1,(v,v4)));(sink,n2,v2)]);(sink,n3,v3)]':
            'mem,mem,slot,slotp,IZ|2,3',
        'p2,p2,l2,l2,l2|[(def,v4,(const,0));(def,v3,(glob,n0));(for,v2,v0,[(addcall,v4,(call,n1,(v,v2)));(sink,n2,v3)]);(sink,n3,v4);(sink,n4,v2)]':
            'mem,mem,IZ,slot,slot|3,4',
        'p2,p2,l2,l2,l2|[(def,v4,(glob,n0));(def,v3,(const,0));(for,v2,v0,[(addcall,v3,(call,n1,(v,v2)));(sink,n2,v4)]);(sink,n3,v3)]':
            'mem,mem,IZ,slot,slot|3,4',
        'p2,p2,l2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(glob,n2));(sink,n1,v1);(def,v3,(call,n3,(k,2)));(sink,n4,v3);(sink,n5,v2);(sink,n4,v3);(sink,n6,v0);(sink,n5,v2);(sink,n6,v0)]':
            'IZ,IZ,slotp,IZ|',
        'p2,p2,l2,l2|[(def,v2,(add,n0,n1));(def,v3,(const,0));(whiledec,v1,[(addcall,v3,(call,n2,(v,v1)))]);(sink,n3,v2);(sink,n4,v3)]':
            'mem,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(call,n0,(k,1)));(for,v3,v0,[(sink,n1,v3)]);(sink,n2,v2)]':
            'mem,mem,slotp,IZ|',
        'p2,p2,l2,l2|[(def,v2,(const,0));(for,v3,v0,[(sink,n0,v3);(addcall,v2,(call,n1,(v,v3)))]);(sink,n2,v2)]':
            'mem,mem,slotp,IZ|',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v2)]);(sink,n3,v3)]':
            'mem,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v3)]);(sink,n3,v2)]':
            'mem,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v1);(def,v2,(call,n3,(k,2)));(call0,n4);(sink,n5,v2);(sink,n6,v0);(sink,n2,v1);(sink,n2,v1);(sink,n5,v2);(call0,n4);(sink,n7,v3)]':
            'mem,IZ,QIZp,slot|',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v2);(call0,n3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]':
            'mem,IZ,tmp,IZ|',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(for,v2,v0,[(sink,n1,v2)]);(sink,n2,v3)]':
            'mem,mem,IZ,slotp|',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v0);(sink,n2,v1);(def,v2,(glob,n3));(call0,n4);(sink,n5,v3);(sink,n1,v0);(sink,n6,v2);(call0,n4);(sink,n2,v1)]':
            'IZ,mem,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v3,(const,0));(for,v2,v0,[(sink,n0,v2);(addcall,v3,(call,n1,(v,v2)))]);(sink,n2,v3)]':
            'mem,mem,IZ,slot|',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(sink,n1,v3);(sink,n1,v3);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n5,v1);(sink,n5,v1);(sink,n4,v2);(call0,n6)]':
            'mem,IZ,QIZp,IZ|',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(def,v3,(glob,n2));(sink,n0,v0);(sink,n3,v3);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n6,v1);(call0,n4);(sink,n6,v1);(sink,n3,v3);(sink,n5,v2);(sink,n5,v2)]':
            'IZ,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n4,v0);(def,v3,(call,n5,(k,2)));(sink,n6,v3);(sink,n3,v2);(sink,n0,v1);(call0,n7);(sink,n6,v3)]':
            'mem,mem,QIZp,IZp|',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(def,v3,(sub,n3,n5));(sink,n6,v3);(call0,n7)]':
            'IZ,mem,QIZp,tmp|',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1);(call0,n0);(sink,n5,v1);(sink,n3,v0)]':
            'mem,IZ,IZ|',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v2);(call0,n0);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n5,v1)]':
            'mem,IZ,QIZp|',
        'p2,p2,l2|[(call0,n0);(def,v2,(glob,n1));(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n3,v1);(sink,n4,v2);(sink,n3,v1)]':
            'IZ,mem,slotp|',
        'p2,p2,l2|[(call0,n0);(sink,n1,v0);(sink,n2,v1);(call0,n0);(sink,n2,v1);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n2,v1);(sink,n5,v2);(sink,n5,v2)]':
            'mem,IZ,QIZp|',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n1,v1);(sink,n4,v0)]':
            'mem,IZ,slot|',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n0,v0);(sink,n4,v1);(sink,n3,v2);(call0,n5)]':
            'IZ,mem,QIZp|',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n0,v0);(sink,n2,v2);(sink,n2,v2);(sink,n0,v0);(sink,n3,v1);(sink,n2,v2);(call0,n4);(call0,n4)]':
            'IZ,mem,QIZp|',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n0,v1);(call0,n3);(sink,n4,v0);(sink,n5,v2);(sink,n0,v1);(call0,n3);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0)]':
            'IZ,mem,QIZp|',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(call,n1,(k,1)));(call0,n2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n0,v1);(sink,n3,v2);(sink,n0,v1)]':
            'mem,IZ,QIZp|',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(glob,n1));(sink,n2,v2);(sink,n3,v0);(sink,n2,v2);(call0,n4);(sink,n3,v0)]':
            'IZ,mem,slot|',
        'p2,p2,l2|[(sink,n0,v1);(sink,n1,v0);(sink,n1,v0);(call0,n2);(def,v2,(glob,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(call0,n2);(sink,n1,v0)]':
            'IZ,mem,slot|',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n0,v0)]':
            'mem,IZ|',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(call0,n2);(sink,n1,v1)]':
            'IZ,IZ|',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(call0,n1);(sink,n2,v0);(sink,n2,v0)]':
            'IZ,IZ|',
        'p2,p2|[(sink,n0,v1);(sink,n1,v0);(call0,n2);(sink,n0,v1);(sink,n1,v0)]':
            'IZ,mem|',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(call0,n3);(call0,n3);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1)]':
            'XIZ,slot|',
    },
    'Xr': {
        'l2,l2,l2,l2i|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(whileg,n0,[(def,v3,(glob,n0));(sink,n3,v3);(call0,n4);(sink,n3,v3);(sink,n3,v3)]);(def,v1,(addk,n0,5));(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(call0,n4);(sink,n6,v0)]':
            'IZ,tmp,slot,QIZp|',
        'l2,l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(call,n3,(k,3)));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n4,v3)]);(sink,n2,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(sink,n6,v0)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2i|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(def,v0,(sub,n1,n3));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(sink,n4,v3);(call0,n5);(sink,n4,v3)]);(call0,n5);(def,v1,(glob,n3));(sink,n6,v0);(sink,n2,v2);(sink,n6,v0);(sink,n7,v1);(sink,n6,v0)]':
            'slot,IZ,QIZp,IZ|',
        'l2,l2,l2,l2i|[(whileg,n0,[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(call0,n3);(sink,n2,v3)]);(def,v1,(glob,n0));(sink,n4,v1);(def,v0,(sub,n1,n5));(sink,n4,v1);(sink,n6,v0);(def,v2,(addk,n0,5));(sink,n7,v2);(sink,n7,v2);(sink,n4,v1)]':
            'IZ,QIZp,IZ,IZ|',
        'l2,l2,l2,l2|[(call0,n0);(def,v2,(glob,n1));(def,v0,(glob,n2));(sink,n3,v2);(def,v3,(glob,n4));(sink,n3,v2);(def,v1,(glob,n5));(sink,n3,v2);(sink,n3,v2);(sink,n6,v0);(sink,n7,v1);(sink,n8,v3);(sink,n6,v0);(call0,n0)]':
            'slot,IZ,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(call0,n0);(def,v3,(call,n1,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(addk,n3,5));(sink,n2,v1);(def,v0,(call,n1,(k,4)));(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n4,v2);(sink,n2,v1);(sink,n6,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(call0,n2);(def,v3,(glob,n3));(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v0);(sink,n7,v3);(sink,n5,v1);(sink,n6,v0);(sink,n8,v2);(sink,n8,v2);(sink,n7,v3);(sink,n6,v0);(sink,n5,v1);(call0,n2)]':
            'QIZp,IZ,slot,slot|2,3',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(sink,n2,v2);(sink,n2,v2);(def,v1,(addk,n0,5));(sink,n2,v2);(def,v3,(call,n3,(k,4)));(sink,n4,v0);(sink,n5,v3);(sink,n6,v1);(sink,n5,v3);(sink,n2,v2)]':
            'slot,QIZp,slot,IZp|0,2',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v3,(addk,n0,5));(sink,n1,v0);(def,v1,(sub,n4,n5));(sink,n6,v3);(sink,n1,v0);(sink,n7,v1);(sink,n6,v3);(sink,n3,v2);(sink,n7,v1);(sink,n3,v2);(sink,n6,v3);(sink,n7,v1);(sink,n7,v1);(sink,n6,v3)]':
            'QIZp,IZ,slot,slot|2,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(call,n0,(k,3)));(def,v0,(glob,n3));(sink,n4,v3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n7,v2);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0)]':
            'slot,slot,IZ,QIZp|0,1',
        'l2,l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(def,v3,(call,n2,(k,3)));(sink,n4,v2);(def,v1,(sub,n5,n6));(sink,n3,v0);(sink,n7,v3);(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n3,v0);(sink,n8,v1)]':
            'IZp,slot,slot,QIZp|1,2',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v0,(addk,n3,5));(def,v1,(glob,n4));(sink,n5,v3);(sink,n6,v0);(sink,n5,v3);(sink,n5,v3);(sink,n7,v1);(sink,n8,v2);(sink,n7,v1);(sink,n6,v0);(sink,n7,v1)]':
            'QIZp,slotp,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(call0,n1);(sink,n2,v3);(sink,n2,v3);(call0,n1);(def,v0,(call,n0,(k,2)));(def,v2,(addk,n3,5));(sink,n4,v2);(sink,n4,v2);(def,v1,(glob,n5));(sink,n2,v3);(sink,n4,v2);(sink,n2,v3);(sink,n6,v0);(sink,n7,v1);(sink,n7,v1)]':
            'slot,slot,QIZp,IZ|0,1',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v3);(def,v0,(sub,n2,n3));(def,v2,(addk,n4,5));(sink,n5,v0);(def,v1,(glob,n6));(sink,n7,v2);(sink,n5,v0);(sink,n5,v0);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2);(sink,n5,v0);(sink,n7,v2);(sink,n8,v1);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2)]':
            'IZ,slot,QIZp,slot|1,3',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v3);(def,v0,(addk,n0,5));(sink,n5,v0);(def,v2,(call,n6,(k,4)));(sink,n3,v1);(sink,n7,v2);(sink,n5,v0);(sink,n4,v3);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n4,v3)]':
            'QIZp,slot,IZp,slot|1,3',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2)]);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n6,v0)]':
            'slotp,QIZp,IZ|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(glob,n1));(def,v1,(glob,n2));(call0,n3);(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0);(call0,n3);(sink,n5,v0);(sink,n6,v1)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(call0,n3);(def,v1,(sub,n1,n4));(sink,n2,v0);(sink,n2,v0);(def,v2,(addk,n0,5));(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(call0,n3)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(call,n3,(k,2)));(def,v2,(call,n3,(k,3)));(sink,n4,v2);(sink,n5,v1);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(sink,n3,v1);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n2,v0);(sink,n3,v1);(call0,n4);(sink,n2,v0);(sink,n5,v2)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v0);(call0,n4);(sink,n5,v2);(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(sink,n2,v0);(sink,n6,v1)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(def,v2,(call,n0,(k,3)));(sink,n1,v2);(sink,n2,v0);(sink,n1,v2);(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(sink,n1,v0);(def,v1,(glob,n3));(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n4,v2);(sink,n4,v2);(sink,n6,v1)]':
            'QIZp,QIZp,IZ|',
        'l2,l2,l2|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(def,v1,(glob,n3));(sink,n2,v0);(sink,n4,v1);(sink,n4,v1);(def,v2,(add,n0,n3));(sink,n5,v2);(sink,n5,v2);(sink,n5,v2)]':
            'IZ,QIZp,IZ|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n2,v1);(sink,n3,v2);(sink,n4,v0);(sink,n4,v0);(sink,n3,v2)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(sub,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(def,v1,(call,n5,(k,3)));(sink,n4,v0);(sink,n4,v0);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n3,v2)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(glob,n2));(def,v1,(glob,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2)]':
            'tmp,IZ,QIZp|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v1);(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(sink,n5,v2);(sink,n3,v1)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(glob,n1));(def,v0,(call,n2,(k,3)));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]':
            'tmp,IZ,QIZp|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v1);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n2,v1);(sink,n5,v2);(sink,n4,v0)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v2,(sub,n2,n3));(sink,n1,v1);(def,v0,(addk,n4,5));(call0,n5);(sink,n6,v0);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2);(sink,n6,v0);(call0,n5);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2)]':
            'QIZp,IZp,slot|',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n3,v1)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v0);(call0,n3);(def,v2,(glob,n4));(sink,n2,v0);(call0,n3);(sink,n5,v1);(sink,n5,v1);(sink,n2,v0);(sink,n6,v2);(sink,n5,v1)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v1,(call,n4,(k,3)));(sink,n5,v1);(sink,n3,v0);(sink,n6,v2);(sink,n6,v2);(sink,n6,v2);(sink,n3,v0);(sink,n3,v0);(sink,n5,v1);(sink,n6,v2)]':
            'IZ,slot,QIZp|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(def,v0,(glob,n2));(sink,n3,v0);(sink,n4,v1);(sink,n5,v2);(sink,n3,v0);(sink,n5,v2);(sink,n3,v0)]':
            'QIZp,IZ,slot|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v2);(sink,n4,v1);(def,v0,(glob,n2));(sink,n3,v2);(sink,n5,v0);(sink,n4,v1)]':
            'QIZp,slot,IZ|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v1,(glob,n2));(sink,n1,v2);(sink,n3,v1);(def,v0,(addk,n4,5));(sink,n1,v2);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(def,v1,(glob,n2));(sink,n3,v0);(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(call0,n5);(sink,n3,v0)]':
            'slot,QIZp,IZ|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n3)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(call0,n1);(sink,n4,v0);(sink,n3,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(sink,n1,v1);(sink,n4,v0);(sink,n1,v1);(sink,n4,v0)]':
            'IZ,QIZp|',
        'l4,l2,l2|[(def,v0,(addk,n0,1));(call0,n1);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(def,v1,(call,n2,(k,3)));(call0,n1);(sink,n5,v1)]':
            'XIZ,IZ,slot|',
        'l4,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n6,v2);(sink,n3,v1)]':
            'tmp,IZ,QIZp|',
        'l4,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(call,n1,(k,2)));(def,v1,(addk,n2,5));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(call0,n5);(sink,n6,v2);(sink,n4,v0)]':
            'slot,IZ,slotp|2,0',
        'l4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n3,n4));(sink,n2,v1);(sink,n5,v0);(sink,n5,v0)]':
            'slot,IZ|',
        'l4,l4|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0)]':
            'slot,XIZ|',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v2)]);(sink,n4,v4)]':
            'slot,tmp,slot,IZ,slot|2,4,0',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v4)]);(sink,n4,v2)]':
            'slot,tmp,slot,IZ,slot|2,4,0',
        'p2,p2,l2,l2,l2|[(def,v2,(glob,n0));(def,v3,(const,0));(for,v4,v0,[(addcall,v3,(call,n1,(v,v4)));(sink,n2,v2)]);(sink,n3,v3)]':
            'slot,tmp,slot,IZ,QIZp|2,0',
        'p2,p2,l2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(glob,n2));(sink,n1,v1);(def,v3,(call,n3,(k,2)));(sink,n4,v3);(sink,n5,v2);(sink,n4,v3);(sink,n6,v0);(sink,n5,v2);(sink,n6,v0)]':
            'slot,IZ,slotp,IZ|2,0',
        'p2,p2,l2,l2|[(def,v2,(add,n0,n1));(def,v3,(const,0));(whiledec,v1,[(addcall,v3,(call,n2,(v,v1)))]);(sink,n3,v2);(sink,n4,v3)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(call,n0,(k,1)));(for,v3,v0,[(sink,n1,v3)]);(sink,n2,v2)]':
            'slot,tmp,slotp,IZ|2,0',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v2)]);(sink,n3,v3)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v3)]);(sink,n3,v2)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v1);(def,v2,(call,n3,(k,2)));(call0,n4);(sink,n5,v2);(sink,n6,v0);(sink,n2,v1);(sink,n2,v1);(sink,n5,v2);(call0,n4);(sink,n7,v3)]':
            'slot,IZ,slotp,slot|2,3,0',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(for,v2,v0,[(sink,n1,v2)]);(sink,n2,v3)]':
            'slot,tmp,IZ,slotp|3,0',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(def,v3,(glob,n2));(sink,n0,v0);(sink,n3,v3);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n6,v1);(call0,n4);(sink,n6,v1);(sink,n3,v3);(sink,n5,v2);(sink,n5,v2)]':
            'IZ,slot,slot,slotp|2,3,1',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v3,(call,n1,(k,1)));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(call0,n3);(sink,n4,v2);(sink,n5,v1)]':
            'tmp,slot,IZp,QIZp|',
        'p2,p2,l2|[(call0,n0);(def,v2,(glob,n1));(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n3,v1);(sink,n4,v2);(sink,n3,v1)]':
            'IZ,slot,slotp|2,1',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n0,v0);(sink,n2,v2);(sink,n2,v2);(sink,n0,v0);(sink,n3,v1);(sink,n2,v2);(call0,n4);(call0,n4)]':
            'IZ,slot,slotp|2,1',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v1);(sink,n0,v0);(call0,n3);(sink,n4,v2);(sink,n4,v2)]':
            'IZ,slot,slotp|2,1',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n0,v1);(call0,n3);(sink,n4,v0);(sink,n5,v2);(sink,n0,v1);(call0,n3);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0)]':
            'slot,slot,IZ|1,0',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(call,n1,(k,1)));(call0,n2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n0,v1);(sink,n3,v2);(sink,n0,v1)]':
            'slot,IZ,QIZp|',
    },
    'O3XSXr': {
        'l2,l2,l2,l2i|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(whileg,n0,[(def,v3,(glob,n0));(sink,n3,v3);(call0,n4);(sink,n3,v3);(sink,n3,v3)]);(def,v1,(addk,n0,5));(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(call0,n4);(sink,n6,v0)]':
            'IZ,tmp,slot,QIZp|',
        'l2,l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(call,n3,(k,3)));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n4,v3)]);(sink,n2,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(sink,n6,v0)]':
            'slot,QIZp,slot,IZ|2,0',
        'l2,l2,l2,l2|[(call0,n0);(def,v2,(glob,n1));(def,v0,(glob,n2));(sink,n3,v2);(def,v3,(glob,n4));(sink,n3,v2);(def,v1,(glob,n5));(sink,n3,v2);(sink,n3,v2);(sink,n6,v0);(sink,n7,v1);(sink,n8,v3);(sink,n6,v0);(call0,n0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(call0,n0);(def,v3,(call,n1,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(addk,n3,5));(sink,n2,v1);(def,v0,(call,n1,(k,4)));(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n5,v3);(sink,n4,v2);(sink,n4,v2);(sink,n2,v1);(sink,n6,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(call0,n2);(def,v3,(glob,n3));(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v0);(sink,n7,v3);(sink,n5,v1);(sink,n6,v0);(sink,n8,v2);(sink,n8,v2);(sink,n7,v3);(sink,n6,v0);(sink,n5,v1);(call0,n2)]':
            'slot,IZ,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v2,(call,n0,(k,3)));(sink,n3,v2);(call0,n1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n6,v3);(sink,n5,v0);(sink,n6,v3);(sink,n3,v2);(sink,n3,v2);(sink,n7,v1)]':
            'IZp,slot,QIZp,slot|1,3',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(def,v0,(call,n0,(k,3)));(def,v3,(call,n0,(k,4)));(sink,n2,v2);(sink,n3,v1);(sink,n3,v1);(sink,n2,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n2,v2);(sink,n5,v3);(sink,n3,v1);(sink,n5,v3);(sink,n4,v0)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(def,v3,(glob,n4));(sink,n5,v0);(call0,n6);(sink,n7,v2);(sink,n7,v2);(sink,n8,v3);(sink,n7,v2);(sink,n7,v2);(sink,n5,v0);(sink,n5,v0)]':
            'slot,tmp,IZp,QIZp|',
        'l2,l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(def,v3,(call,n2,(k,3)));(sink,n4,v2);(def,v1,(sub,n5,n6));(sink,n3,v0);(sink,n7,v3);(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n3,v0);(sink,n8,v1)]':
            'QIZp,slot,slot,IZ|1,2',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v3,(glob,n2));(sink,n4,v3);(call0,n5);(sink,n4,v3);(def,v1,(glob,n6));(sink,n7,v2);(sink,n8,v1);(sink,n8,v1);(sink,n7,v2);(sink,n4,v3);(sink,n3,v0);(call0,n5);(sink,n8,v1);(sink,n4,v3);(sink,n3,v0)]':
            'slot,IZp,slot,QIZp|0,2',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v3);(def,v0,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n6);(def,v2,(sub,n7,n8));(sink,n9,v2);(sink,n9,v2);(sink,n3,v3)]':
            'QIZp,IZp,IZ,slot|',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(sink,n2,v3);(def,v1,(add,n0,n1));(call0,n3);(def,v2,(call,n4,(k,2)));(sink,n5,v2);(def,v0,(call,n4,(k,3)));(sink,n6,v0);(sink,n7,v1);(sink,n7,v1);(sink,n6,v0)]':
            'QIZp,IZp,tmp,IZ|',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(call0,n1);(sink,n2,v3);(sink,n2,v3);(call0,n1);(def,v0,(call,n0,(k,2)));(def,v2,(addk,n3,5));(sink,n4,v2);(sink,n4,v2);(def,v1,(glob,n5));(sink,n2,v3);(sink,n4,v2);(sink,n2,v3);(sink,n6,v0);(sink,n7,v1);(sink,n7,v1)]':
            'slot,IZp,QIZp,slot|0,3',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v3);(def,v0,(addk,n0,5));(sink,n5,v0);(def,v2,(call,n6,(k,4)));(sink,n3,v1);(sink,n7,v2);(sink,n5,v0);(sink,n4,v3);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n4,v3)]':
            'IZp,slot,QIZp,slot|1,3',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2)]);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n6,v0)]':
            'QIZp,slot,IZ|',
        'l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(whileg,n0,[(def,v2,(call,n2,(k,1)));(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(call0,n4);(sink,n6,v0);(sink,n5,v1)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(def,v1,(sub,n3,n4));(def,v0,(glob,n4));(sink,n5,v0);(sink,n2,v2);(sink,n6,v1);(sink,n2,v2);(sink,n5,v0);(sink,n2,v2);(sink,n5,v0);(sink,n6,v1);(call0,n0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(def,v2,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(sink,n6,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v0);(def,v1,(glob,n4));(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n5,v2)]':
            'QIZp,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v2);(def,v1,(glob,n2));(sink,n4,v1);(sink,n3,v2);(sink,n3,v2);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,tmp,QIZp|',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(sink,n3,v1);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n2,v0);(sink,n3,v1);(call0,n4);(sink,n2,v0);(sink,n5,v2)]':
            'slot,IZ,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(def,v2,(call,n0,(k,3)));(sink,n1,v2);(sink,n2,v0);(sink,n1,v2);(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(def,v2,(addk,n5,5));(sink,n6,v2);(sink,n4,v1);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1)]':
            'QIZp,IZp,tmp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(call0,n2);(def,v1,(addk,n3,5));(sink,n1,v0);(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(sink,n4,v2);(sink,n5,v1)]':
            'IZp,slot,QIZp|',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(sink,n1,v0);(def,v1,(glob,n3));(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n4,v2);(sink,n4,v2);(sink,n6,v1)]':
            'QIZp,QIZp,IZ|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n2,v1);(sink,n3,v2);(sink,n4,v0);(sink,n4,v0);(sink,n3,v2)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(def,v1,(addk,n0,5));(sink,n2,v0);(sink,n3,v2);(sink,n3,v2);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0);(sink,n3,v2);(sink,n2,v0)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(sub,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(def,v1,(call,n5,(k,3)));(sink,n4,v0);(sink,n4,v0);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n3,v2)]':
            'slot,QIZp,IZp|',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v1);(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(sink,n5,v2);(sink,n3,v1)]':
            'IZ,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(call0,n2);(sink,n3,v0);(sink,n3,v0);(def,v2,(glob,n4));(sink,n5,v2);(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n3,v0)]':
            'slot,IZp,QIZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v1);(def,v0,(addk,n3,5));(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2)]':
            'QIZp,tmp,IZp|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v0,(sub,n2,n3));(def,v2,(glob,n3));(sink,n1,v1);(sink,n1,v1);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v2,(sub,n2,n3));(sink,n1,v1);(def,v0,(addk,n4,5));(call0,n5);(sink,n6,v0);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2);(sink,n6,v0);(call0,n5);(sink,n6,v0);(sink,n1,v1);(sink,n7,v2)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(glob,n0));(sink,n3,v2);(sink,n2,v1);(sink,n2,v1);(sink,n4,v0)]':
            'IZp,QIZp,tmp|',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(def,v0,(glob,n2));(sink,n3,v0);(sink,n4,v1);(sink,n5,v2);(sink,n3,v0);(sink,n5,v2);(sink,n3,v0)]':
            'IZp,QIZp,slot|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v0,(sub,n2,n3));(sink,n1,v2);(def,v1,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n1,v2);(sink,n5,v0);(call0,n6);(sink,n4,v1)]':
            'QIZp,slot,IZp|',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v1,(glob,n2));(sink,n1,v2);(sink,n3,v1);(def,v0,(addk,n4,5));(sink,n1,v2);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0)]':
            'QIZp,slot,IZp|',
        'l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(call0,n5);(sink,n3,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n4,v0);(sink,n3,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n3,v1);(sink,n1,v0);(sink,n1,v0);(sink,n3,v1);(sink,n3,v1)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v0);(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n2,v0)]':
            'IZp,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n3)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0)]':
            'QIZp,IZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]':
            'IZ,QIZp|',
        'l4,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n6,v2);(sink,n3,v1)]':
            'tmp,IZ,QIZp|',
        'l4,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(call,n1,(k,2)));(def,v1,(addk,n2,5));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(call0,n5);(sink,n6,v2);(sink,n4,v0)]':
            'slot,IZ,slotp|2,0',
        'l4,l4|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0)]':
            'slot,XIZ|',
        'l4,l4|[(def,v1,(glob,n0));(def,v0,(sub,n1,n0));(sink,n2,v1);(sink,n2,v1);(call0,n3);(sink,n4,v0);(call0,n3);(sink,n2,v1)]':
            'slot,XIZ|',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v2)]);(sink,n4,v4)]':
            'slot,tmp,slot,IZ,slot|2,4,0',
        'p2,p2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v4,(glob,n1));(for,v3,v0,[(sink,n2,v3);(sink,n3,v4)]);(sink,n4,v2)]':
            'slot,tmp,slot,IZ,slot|2,4,0',
        'p2,p2,l2,l2,l2|[(def,v4,(glob,n0));(def,v3,(const,0));(for,v2,v0,[(addcall,v3,(call,n1,(v,v2)));(sink,n2,v4)]);(sink,n3,v3)]':
            'slot,tmp,IZ,QIZp,slot|4,0',
        'p2,p2,l2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(glob,n2));(sink,n1,v1);(def,v3,(call,n3,(k,2)));(sink,n4,v3);(sink,n5,v2);(sink,n4,v3);(sink,n6,v0);(sink,n5,v2);(sink,n6,v0)]':
            'slot,IZ,slotp,IZ|2,0',
        'p2,p2,l2,l2|[(call0,n0);(def,v3,(glob,n1));(sink,n2,v3);(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v3);(sink,n5,v0);(sink,n2,v3);(sink,n6,v1)]':
            'IZ,slot,tmp,slot|3,1',
        'p2,p2,l2,l2|[(def,v2,(add,n0,n1));(def,v3,(const,0));(whiledec,v1,[(addcall,v3,(call,n2,(v,v1)))]);(sink,n3,v2);(sink,n4,v3)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(call,n0,(k,1)));(for,v3,v0,[(sink,n1,v3)]);(sink,n2,v2)]':
            'slot,tmp,slotp,IZ|2,0',
        'p2,p2,l2,l2|[(def,v2,(const,0));(for,v3,v0,[(sink,n0,v3);(addcall,v2,(call,n1,(v,v3)))]);(sink,n2,v2)]':
            'slot,tmp,IZ,QIZp|',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v2)]);(sink,n3,v3)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v2,(glob,n0));(def,v3,(glob,n1));(whiledec,v1,[(sink,n2,v3)]);(sink,n3,v2)]':
            'tmp,IZ,slot,slotp|2,3',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v2);(call0,n3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]':
            'slot,IZ,tmp,QIZp|',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(for,v2,v0,[(sink,n1,v2)]);(sink,n2,v3)]':
            'slot,tmp,IZ,slotp|3,0',
        'p2,p2,l2,l2|[(def,v3,(const,0));(for,v2,v0,[(sink,n0,v2);(addcall,v3,(call,n1,(v,v2)))]);(sink,n2,v3)]':
            'slot,tmp,IZ,QIZp|',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(sink,n1,v3);(sink,n1,v3);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n5,v1);(sink,n5,v1);(sink,n4,v2);(call0,n6)]':
            'IZ,slot,slot,slot|2,1,3',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(def,v3,(glob,n2));(sink,n0,v0);(sink,n3,v3);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n6,v1);(call0,n4);(sink,n6,v1);(sink,n3,v3);(sink,n5,v2);(sink,n5,v2)]':
            'IZ,slot,slot,slotp|2,3,1',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(glob,n1));(def,v3,(glob,n2));(call0,n3);(sink,n4,v3);(sink,n5,v1);(sink,n6,v2);(sink,n6,v2)]':
            'tmp,slot,IZp,QIZp|',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v3,(call,n1,(k,1)));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(call0,n3);(sink,n4,v2);(sink,n5,v1)]':
            'tmp,slot,IZp,QIZp|',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n4,v0);(def,v3,(call,n5,(k,2)));(sink,n6,v3);(sink,n3,v2);(sink,n0,v1);(call0,n7);(sink,n6,v3)]':
            'slot,slot,IZp,QIZp|1,0',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1);(call0,n0);(sink,n5,v1);(sink,n3,v0)]':
            'slot,IZ,QIZp|',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v2);(call0,n0);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n5,v1)]':
            'slot,IZ,slotp|2,0',
        'p2,p2,l2|[(call0,n0);(def,v2,(glob,n1));(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n3,v1);(sink,n4,v2);(sink,n3,v1)]':
            'IZ,slot,slotp|2,1',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n4,v1);(sink,n2,v2)]':
            'tmp,IZ,slot|',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n1,v1);(sink,n4,v0)]':
            'slot,IZ,slot|2,0',
        'p2,p2,l2|[(sink,n0,v0);(call0,n1);(def,v2,(call,n2,(k,1)));(sink,n3,v1);(sink,n4,v2);(call0,n1);(sink,n4,v2);(sink,n4,v2)]':
            'tmp,IZ,QIZp|',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n0,v0);(sink,n4,v1);(sink,n3,v2);(call0,n5)]':
            'IZ,slot,slotp|2,1',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(call,n1,(k,1)));(call0,n2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n0,v1);(sink,n3,v2);(sink,n0,v1)]':
            'slot,IZ,QIZp|',
    },
}
RULE_OK = {
    'none': {
        'l2,l2,l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(def,v1,(call,n0,(k,3)));(sink,n4,v2);(sink,n1,v0);(sink,n5,v1);(whileg,n6,[(def,v3,(add,n6,n2));(sink,n7,v3);(call0,n8)]);(sink,n1,v0)]',
        'l2,l2,l2,l2|[(call0,n0);(call0,n0);(def,v0,(call,n1,(k,1)));(def,v3,(call,n1,(k,2)));(def,v2,(glob,n2));(def,v1,(call,n1,(k,4)));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n5,v3);(sink,n6,v2);(sink,n4,v0);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(call0,n0);(def,v1,(add,n1,n2));(sink,n3,v1);(def,v0,(call,n4,(k,2)));(def,v2,(call,n4,(k,3)));(sink,n5,v2);(def,v3,(call,n4,(k,4)));(sink,n6,v0);(sink,n6,v0);(sink,n7,v3);(sink,n7,v3);(sink,n7,v3);(sink,n6,v0);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n7,v3)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(def,v3,(glob,n0));(sink,n2,v3);(sink,n3,v0);(sink,n4,v1);(def,v2,(glob,n5));(sink,n4,v1);(sink,n6,v2);(sink,n4,v1);(sink,n6,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(glob,n3));(def,v3,(call,n1,(k,1)));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n6,v2);(sink,n7,v0);(sink,n2,v1);(sink,n7,v0);(sink,n7,v0)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(sink,n2,v2);(sink,n2,v2);(def,v1,(addk,n0,5));(sink,n2,v2);(def,v3,(call,n3,(k,4)));(sink,n4,v0);(sink,n5,v3);(sink,n6,v1);(sink,n5,v3);(sink,n2,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v3,(addk,n0,5));(sink,n1,v0);(def,v1,(sub,n4,n5));(sink,n6,v3);(sink,n1,v0);(sink,n7,v1);(sink,n6,v3);(sink,n3,v2);(sink,n7,v1);(sink,n3,v2);(sink,n6,v3);(sink,n7,v1);(sink,n7,v1);(sink,n6,v3)]',
        'l2,l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v0,(glob,n4));(sink,n5,v1);(def,v3,(call,n2,(k,4)));(sink,n6,v3);(sink,n7,v0);(sink,n7,v0);(sink,n6,v3);(sink,n6,v3);(sink,n6,v3);(sink,n5,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(def,v2,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(def,v3,(sub,n2,n5));(sink,n3,v1);(sink,n6,v3);(sink,n4,v0);(sink,n7,v2);(sink,n4,v0);(sink,n4,v0);(sink,n7,v2);(sink,n7,v2);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(addk,n3,5));(def,v0,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n7,v0);(sink,n6,v3);(sink,n8,v1);(sink,n8,v1);(sink,n9,v2);(sink,n7,v0);(sink,n9,v2);(sink,n8,v1)]',
        'l2,l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(def,v3,(glob,n4));(sink,n5,v0);(call0,n6);(sink,n7,v2);(sink,n7,v2);(sink,n8,v3);(sink,n7,v2);(sink,n7,v2);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(call0,n1);(def,v3,(sub,n2,n3));(def,v1,(addk,n0,5));(sink,n4,v1);(def,v0,(call,n5,(k,4)));(sink,n6,v2);(sink,n6,v2);(sink,n7,v0);(sink,n6,v2);(sink,n6,v2);(sink,n8,v3)]',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v3);(def,v0,(sub,n2,n3));(def,v2,(addk,n4,5));(sink,n5,v0);(def,v1,(glob,n6));(sink,n7,v2);(sink,n5,v0);(sink,n5,v0);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2);(sink,n5,v0);(sink,n7,v2);(sink,n8,v1);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2)]',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(sink,n3,v2);(def,v0,(call,n1,(k,3)));(sink,n2,v3);(def,v1,(sub,n4,n5));(sink,n6,v0);(sink,n6,v0);(sink,n2,v3);(sink,n7,v1);(sink,n2,v3);(sink,n3,v2)]',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(whileg,n0,[(def,v2,(add,n0,n1));(sink,n4,v2);(sink,n4,v2)]);(sink,n3,v0);(sink,n2,v1)]',
        'l2,l2,l2i|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(call0,n4);(sink,n5,v0);(sink,n5,v0);(sink,n1,v1);(whileg,n0,[(def,v2,(glob,n0));(sink,n6,v2);(sink,n6,v2);(sink,n6,v2)]);(sink,n1,v1);(sink,n5,v0)]',
        'l2,l2,l2i|[(whileg,n0,[(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(call0,n3)]);(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n4,v1);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(glob,n2));(sink,n3,v1);(def,v2,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(def,v0,(addk,n4,5));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(sink,n7,v2);(sink,n7,v2);(sink,n6,v0);(sink,n6,v0);(call0,n0);(sink,n5,v1);(sink,n7,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(call0,n5);(def,v2,(glob,n6));(sink,n7,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(glob,n1));(def,v1,(glob,n2));(call0,n3);(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0);(call0,n3);(sink,n5,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v2);(def,v1,(glob,n2));(sink,n4,v1);(sink,n3,v2);(sink,n3,v2);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(call0,n3);(def,v1,(sub,n1,n4));(sink,n2,v0);(sink,n2,v0);(def,v2,(addk,n0,5));(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(call,n3,(k,2)));(def,v2,(call,n3,(k,3)));(sink,n4,v2);(sink,n5,v1);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v0);(sink,n5,v1);(sink,n4,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v0);(call0,n4);(sink,n5,v2);(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(sink,n2,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,1)));(call0,n1);(sink,n2,v2);(sink,n2,v2);(def,v1,(glob,n3));(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(def,v1,(sub,n3,n5));(sink,n1,v0);(call0,n6);(sink,n7,v1);(sink,n7,v1);(sink,n7,v1);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(sink,n1,v0);(def,v1,(glob,n3));(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n4,v2);(sink,n4,v2);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(def,v1,(glob,n3));(sink,n2,v0);(sink,n4,v1);(sink,n4,v1);(def,v2,(add,n0,n3));(sink,n5,v2);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(def,v2,(call,n3,(k,3)));(sink,n4,v0);(sink,n5,v1);(sink,n6,v2);(sink,n5,v1);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(def,v2,(call,n4,(k,3)));(sink,n3,v1);(sink,n5,v2);(sink,n3,v1);(sink,n6,v0);(sink,n3,v1);(call0,n7);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(def,v1,(glob,n4));(sink,n3,v0);(sink,n5,v1);(sink,n3,v0);(sink,n2,v2);(sink,n5,v1);(sink,n2,v2);(call0,n6);(sink,n5,v1);(sink,n2,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(def,v1,(addk,n0,5));(sink,n2,v0);(sink,n3,v2);(sink,n3,v2);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0);(sink,n3,v2);(sink,n2,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(def,v2,(call,n4,(k,3)));(sink,n5,v1);(sink,n6,v2);(sink,n1,v0);(sink,n1,v0);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(glob,n2));(def,v1,(glob,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v1);(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(sink,n5,v2);(sink,n3,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(def,v0,(addk,n0,5));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n3,v1);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(glob,n1));(def,v0,(call,n2,(k,3)));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v1);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n2,v1);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4);(sink,n5,v1);(def,v0,(glob,n2));(sink,n6,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v1);(def,v0,(addk,n3,5));(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n3,v1)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v0);(call0,n3);(def,v2,(glob,n4));(sink,n2,v0);(call0,n3);(sink,n5,v1);(sink,n5,v1);(sink,n2,v0);(sink,n6,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v1,(call,n4,(k,3)));(sink,n5,v1);(sink,n3,v0);(sink,n6,v2);(sink,n6,v2);(sink,n6,v2);(sink,n3,v0);(sink,n3,v0);(sink,n5,v1);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(def,v0,(glob,n2));(sink,n3,v0);(sink,n4,v1);(sink,n5,v2);(sink,n3,v0);(sink,n5,v2);(sink,n3,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v2);(sink,n4,v1);(def,v0,(glob,n2));(sink,n3,v2);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v0,(glob,n1));(def,v1,(addk,n0,5));(sink,n3,v0);(sink,n4,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(call0,n3);(def,v0,(sub,n1,n4));(def,v1,(glob,n4));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(def,v1,(glob,n2));(sink,n3,v0);(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(call0,n5);(sink,n3,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(whileg,n2,[(def,v1,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]);(sink,n1,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(whileg,n1,[(def,v1,(call,n0,(k,1)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1)]);(call0,n3);(sink,n4,v0)]',
        'l2,l2|[(call0,n0);(def,v0,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(call0,n0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(sink,n4,v1);(sink,n1,v0);(sink,n4,v1);(sink,n1,v0);(sink,n1,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(call0,n3);(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v0);(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n2,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n3)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(call0,n1);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(sink,n2,v1);(sink,n2,v1);(def,v0,(call,n3,(k,2)));(sink,n2,v1);(call0,n1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(sink,n1,v1);(sink,n4,v0);(sink,n1,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(sink,n3,v0);(sink,n2,v2);(def,v1,(addk,n4,5));(sink,n3,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(def,v2,(addk,n3,5));(call0,n4);(sink,n1,v0);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(call0,n4)]',
        'l4,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n6,v2);(sink,n3,v1)]',
        'l4,l2|[(def,v0,(addk,n0,1));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(call0,n5);(sink,n4,v1)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(call0,n3);(sink,n2,v1);(sink,n4,v0);(call0,n3);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n3,n4));(sink,n2,v1);(sink,n5,v0);(sink,n5,v0)]',
        'l4,l4|[(call0,n0);(def,v0,(addk,n1,1));(sink,n2,v0);(def,v1,(sub,n3,n1));(sink,n4,v1);(sink,n4,v1);(sink,n2,v0)]',
        'l4,l4|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n0));(sink,n2,v0);(sink,n4,v1)]',
        'l4,l4|[(def,v1,(glob,n0));(def,v0,(sub,n1,n0));(sink,n2,v1);(sink,n2,v1);(call0,n3);(sink,n4,v0);(call0,n3);(sink,n2,v1)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v3)]);(sink,n3,v2);(sink,n4,v4)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v4)]);(sink,n3,v2);(sink,n4,v3)]',
        'p2,p2,l2,l2,l2|[(def,v2,(glob,n0));(def,v3,(const,0));(for,v4,v0,[(addcall,v3,(call,n1,(v,v4)));(sink,n2,v2)]);(sink,n3,v3)]',
        'p2,p2,l2,l2,l2|[(def,v4,(const,0));(def,v3,(glob,n0));(for,v2,v0,[(addcall,v4,(call,n1,(v,v2)));(sink,n2,v3)]);(sink,n3,v4);(sink,n4,v2)]',
        'p2,p2,l2,l2|[(call0,n0);(def,v3,(glob,n1));(sink,n2,v3);(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v3);(sink,n5,v0);(sink,n2,v3);(sink,n6,v1)]',
        'p2,p2,l2,l2|[(def,v2,(call,n0,(k,1)));(for,v3,v0,[(sink,n1,v3)]);(sink,n2,v2)]',
        'p2,p2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v1);(def,v2,(call,n3,(k,2)));(call0,n4);(sink,n5,v2);(sink,n6,v0);(sink,n2,v1);(sink,n2,v1);(sink,n5,v2);(call0,n4);(sink,n7,v3)]',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v2);(call0,n3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(call0,n1);(sink,n2,v0);(def,v2,(sub,n3,n4));(call0,n1);(sink,n5,v2);(sink,n6,v3);(sink,n7,v1)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(sink,n1,v3);(sink,n1,v3);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n5,v1);(sink,n5,v1);(sink,n4,v2);(call0,n6)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(def,v3,(glob,n2));(sink,n0,v0);(sink,n3,v3);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n6,v1);(call0,n4);(sink,n6,v1);(sink,n3,v3);(sink,n5,v2);(sink,n5,v2)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(glob,n1));(def,v3,(glob,n2));(call0,n3);(sink,n4,v3);(sink,n5,v1);(sink,n6,v2);(sink,n6,v2)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v3,(call,n1,(k,1)));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(call0,n3);(sink,n4,v2);(sink,n5,v1)]',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(def,v3,(sub,n3,n5));(sink,n6,v3);(call0,n7)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v0);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n1,v0);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n1,v0)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n5,v0)]',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1);(call0,n0);(sink,n5,v1);(sink,n3,v0)]',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v2);(call0,n0);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n5,v1)]',
        'p2,p2,l2|[(call0,n0);(sink,n1,v0);(sink,n2,v1);(call0,n0);(sink,n2,v1);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n2,v1);(sink,n5,v2);(sink,n5,v2)]',
        'p2,p2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n4,v1);(sink,n2,v2)]',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n1,v1);(sink,n4,v0)]',
        'p2,p2,l2|[(sink,n0,v0);(call0,n1);(def,v2,(call,n2,(k,1)));(sink,n3,v1);(sink,n4,v2);(call0,n1);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n0,v0);(sink,n4,v1);(sink,n3,v2);(call0,n5)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n0,v0);(sink,n2,v2);(sink,n2,v2);(sink,n0,v0);(sink,n3,v1);(sink,n2,v2);(call0,n4);(call0,n4)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v1);(sink,n0,v0);(call0,n3);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n0,v1);(call0,n3);(sink,n4,v0);(sink,n5,v2);(sink,n0,v1);(call0,n3);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(call,n1,(k,1)));(call0,n2);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n0,v1);(sink,n3,v2);(sink,n0,v1)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(glob,n1));(sink,n2,v2);(sink,n3,v0);(sink,n2,v2);(call0,n4);(sink,n3,v0)]',
        'p2,p2|[(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(call0,n1);(sink,n2,v1);(sink,n0,v0);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(call0,n2);(sink,n1,v1)]',
        'p2,p2|[(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(sink,n1,v1);(sink,n0,v0);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(call0,n1);(sink,n2,v0);(sink,n2,v0)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(sink,n0,v1);(sink,n1,v0);(call0,n2);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n1,v0);(call0,n2);(sink,n0,v1);(sink,n1,v0)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(call0,n4);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(sink,n1,v1);(sink,n2,v0);(call0,n3)]',
        'p4,l4,l2|[(call0,n0);(sink,n1,v0);(def,v2,(call,n2,(k,1)));(sink,n1,v0);(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n5,v2);(sink,n4,v1);(call0,n0)]',
        'p4,l4,l2|[(def,v1,(addk,n0,1));(sink,n1,v1);(def,v2,(call,n2,(k,2)));(call0,n3);(sink,n1,v1);(sink,n4,v2);(sink,n1,v1);(sink,n5,v0);(sink,n4,v2);(call0,n3)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n4));(sink,n5,v2);(sink,n2,v0);(call0,n6);(sink,n5,v2);(sink,n5,v2);(call0,n6);(sink,n7,v1)]',
        'p4,l4,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(call0,n2);(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v2);(sink,n6,v2);(sink,n0,v0);(call0,n2)]',
    },
    'O3XS': {
        'l2,l2,l2,l2i|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(whileg,n0,[(def,v3,(glob,n0));(sink,n3,v3);(call0,n4);(sink,n3,v3);(sink,n3,v3)]);(def,v1,(addk,n0,5));(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n7,v2);(call0,n4);(sink,n6,v0)]',
        'l2,l2,l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(def,v1,(call,n0,(k,3)));(sink,n4,v2);(sink,n1,v0);(sink,n5,v1);(whileg,n6,[(def,v3,(add,n6,n2));(sink,n7,v3);(call0,n8)]);(sink,n1,v0)]',
        'l2,l2,l2,l2i|[(def,v1,(call,n0,(k,1)));(whileg,n1,[(def,v3,(add,n1,n2));(sink,n3,v3);(call0,n4);(sink,n3,v3)]);(sink,n5,v1);(def,v0,(call,n0,(k,2)));(sink,n5,v1);(def,v2,(glob,n6));(sink,n5,v1);(sink,n7,v2);(sink,n8,v0);(sink,n7,v2);(sink,n7,v2)]',
        'l2,l2,l2,l2|[(call0,n0);(call0,n0);(def,v0,(call,n1,(k,1)));(def,v3,(call,n1,(k,2)));(def,v2,(glob,n2));(def,v1,(call,n1,(k,4)));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n5,v3);(sink,n6,v2);(sink,n4,v0);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(call0,n0);(def,v1,(add,n1,n2));(sink,n3,v1);(def,v0,(call,n4,(k,2)));(def,v2,(call,n4,(k,3)));(sink,n5,v2);(def,v3,(call,n4,(k,4)));(sink,n6,v0);(sink,n6,v0);(sink,n7,v3);(sink,n7,v3);(sink,n7,v3);(sink,n6,v0);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n7,v3)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(def,v3,(glob,n0));(sink,n2,v3);(sink,n3,v0);(sink,n4,v1);(def,v2,(glob,n5));(sink,n4,v1);(sink,n6,v2);(sink,n4,v1);(sink,n6,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v0);(def,v2,(call,n1,(k,3)));(def,v3,(call,n1,(k,4)));(sink,n2,v0);(sink,n2,v0);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n3,v3);(sink,n6,v1);(sink,n5,v2);(sink,n3,v3);(sink,n5,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(glob,n3));(def,v3,(call,n1,(k,1)));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n6,v2);(sink,n7,v0);(sink,n2,v1);(sink,n7,v0);(sink,n7,v0)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v3,(addk,n0,5));(sink,n1,v0);(def,v1,(sub,n4,n5));(sink,n6,v3);(sink,n1,v0);(sink,n7,v1);(sink,n6,v3);(sink,n3,v2);(sink,n7,v1);(sink,n3,v2);(sink,n6,v3);(sink,n7,v1);(sink,n7,v1);(sink,n6,v3)]',
        'l2,l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v0,(glob,n4));(sink,n5,v1);(def,v3,(call,n2,(k,4)));(sink,n6,v3);(sink,n7,v0);(sink,n7,v0);(sink,n6,v3);(sink,n6,v3);(sink,n6,v3);(sink,n5,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(def,v2,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(def,v3,(sub,n2,n5));(sink,n3,v1);(sink,n6,v3);(sink,n4,v0);(sink,n7,v2);(sink,n4,v0);(sink,n4,v0);(sink,n7,v2);(sink,n7,v2);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(addk,n3,5));(def,v0,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n7,v0);(sink,n6,v3);(sink,n8,v1);(sink,n8,v1);(sink,n9,v2);(sink,n7,v0);(sink,n9,v2);(sink,n8,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(call,n0,(k,3)));(def,v0,(glob,n3));(sink,n4,v3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n7,v2);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0)]',
        'l2,l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(def,v3,(glob,n4));(sink,n5,v0);(call0,n6);(sink,n7,v2);(sink,n7,v2);(sink,n8,v3);(sink,n7,v2);(sink,n7,v2);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(call0,n1);(def,v3,(sub,n2,n3));(def,v1,(addk,n0,5));(sink,n4,v1);(def,v0,(call,n5,(k,4)));(sink,n6,v2);(sink,n6,v2);(sink,n7,v0);(sink,n6,v2);(sink,n6,v2);(sink,n8,v3)]',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v3);(def,v0,(sub,n2,n3));(def,v2,(addk,n4,5));(sink,n5,v0);(def,v1,(glob,n6));(sink,n7,v2);(sink,n5,v0);(sink,n5,v0);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2);(sink,n5,v0);(sink,n7,v2);(sink,n8,v1);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2)]',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(sink,n3,v2);(def,v0,(call,n1,(k,3)));(sink,n2,v3);(def,v1,(sub,n4,n5));(sink,n6,v0);(sink,n6,v0);(sink,n2,v3);(sink,n7,v1);(sink,n2,v3);(sink,n3,v2)]',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(whileg,n0,[(def,v2,(add,n0,n1));(sink,n4,v2);(sink,n4,v2)]);(sink,n3,v0);(sink,n2,v1)]',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(whileg,n0,[(def,v2,(glob,n0));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(sink,n6,v0);(sink,n6,v0);(sink,n6,v0)]',
        'l2,l2,l2i|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(call0,n4);(sink,n5,v0);(sink,n5,v0);(sink,n1,v1);(whileg,n0,[(def,v2,(glob,n0));(sink,n6,v2);(sink,n6,v2);(sink,n6,v2)]);(sink,n1,v1);(sink,n5,v0)]',
        'l2,l2,l2i|[(whileg,n0,[(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(call0,n3)]);(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n4,v1);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(glob,n2));(sink,n3,v1);(def,v2,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(def,v0,(addk,n4,5));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(sink,n7,v2);(sink,n7,v2);(sink,n6,v0);(sink,n6,v0);(call0,n0);(sink,n5,v1);(sink,n7,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(call0,n5);(def,v2,(glob,n6));(sink,n7,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(glob,n1));(def,v1,(glob,n2));(call0,n3);(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0);(call0,n3);(sink,n5,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(call0,n3);(def,v1,(sub,n1,n4));(sink,n2,v0);(sink,n2,v0);(def,v2,(addk,n0,5));(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v0);(sink,n5,v1);(sink,n4,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v0);(call0,n4);(sink,n5,v2);(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(sink,n2,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,1)));(call0,n1);(sink,n2,v2);(sink,n2,v2);(def,v1,(glob,n3));(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n3));(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(def,v1,(sub,n3,n5));(sink,n1,v0);(call0,n6);(sink,n7,v1);(sink,n7,v1);(sink,n7,v1);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(sink,n1,v0);(def,v1,(glob,n3));(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(sink,n6,v1);(sink,n4,v2);(sink,n4,v2);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(def,v1,(glob,n3));(sink,n2,v0);(sink,n4,v1);(sink,n4,v1);(def,v2,(add,n0,n3));(sink,n5,v2);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(def,v2,(call,n3,(k,3)));(sink,n4,v0);(sink,n5,v1);(sink,n6,v2);(sink,n5,v1);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(def,v2,(call,n4,(k,3)));(sink,n3,v1);(sink,n5,v2);(sink,n3,v1);(sink,n6,v0);(sink,n3,v1);(call0,n7);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(def,v1,(glob,n4));(sink,n3,v0);(sink,n5,v1);(sink,n3,v0);(sink,n2,v2);(sink,n5,v1);(sink,n2,v2);(call0,n6);(sink,n5,v1);(sink,n2,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(glob,n2));(def,v1,(glob,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(def,v0,(addk,n0,5));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n3,v1);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(glob,n1));(def,v0,(call,n2,(k,3)));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v1);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n2,v1);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4);(sink,n5,v1);(def,v0,(glob,n2));(sink,n6,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v1);(def,v0,(addk,n3,5));(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n3,v1)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v0);(call0,n3);(def,v2,(glob,n4));(sink,n2,v0);(call0,n3);(sink,n5,v1);(sink,n5,v1);(sink,n2,v0);(sink,n6,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(glob,n1));(def,v1,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0);(sink,n5,v2);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v1,(call,n4,(k,3)));(sink,n5,v1);(sink,n3,v0);(sink,n6,v2);(sink,n6,v2);(sink,n6,v2);(sink,n3,v0);(sink,n3,v0);(sink,n5,v1);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(glob,n1));(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v2);(sink,n4,v1);(def,v0,(glob,n2));(sink,n3,v2);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v0,(glob,n1));(def,v1,(addk,n0,5));(sink,n3,v0);(sink,n4,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(call0,n3);(def,v0,(sub,n1,n4));(def,v1,(glob,n4));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v0,(glob,n2));(def,v1,(call,n0,(k,3)));(sink,n3,v1);(sink,n4,v0);(call0,n1);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(glob,n1));(sink,n2,v2);(def,v1,(call,n0,(k,3)));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n2,v2);(call0,n4)]',
        'l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(def,v1,(glob,n2));(sink,n3,v0);(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(call0,n5);(sink,n3,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(whileg,n2,[(def,v1,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]);(sink,n1,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(whileg,n1,[(def,v1,(call,n0,(k,1)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1)]);(call0,n3);(sink,n4,v0)]',
        'l2,l2|[(call0,n0);(def,v0,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(call0,n0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(sink,n4,v1);(sink,n1,v0);(sink,n4,v1);(sink,n1,v0);(sink,n1,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(call0,n3);(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(call0,n1);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(sink,n2,v1);(sink,n2,v1);(def,v0,(call,n3,(k,2)));(sink,n2,v1);(call0,n1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(sink,n1,v1);(sink,n4,v0);(sink,n1,v1);(sink,n4,v0)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(sink,n3,v0);(sink,n2,v2);(def,v1,(addk,n4,5));(sink,n3,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(def,v2,(addk,n3,5));(call0,n4);(sink,n1,v0);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(call0,n4)]',
        'l4,l2|[(def,v0,(addk,n0,1));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(call0,n5);(sink,n4,v1)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(call0,n3);(sink,n2,v1);(sink,n4,v0);(call0,n3);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n3,n4));(sink,n2,v1);(sink,n5,v0);(sink,n5,v0)]',
        'l4,l4|[(call0,n0);(def,v0,(addk,n1,1));(sink,n2,v0);(def,v1,(sub,n3,n1));(sink,n4,v1);(sink,n4,v1);(sink,n2,v0)]',
        'l4,l4|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n0));(sink,n2,v0);(sink,n4,v1)]',
        'l4,l4|[(def,v1,(glob,n0));(def,v0,(sub,n1,n0));(sink,n2,v1);(sink,n2,v1);(call0,n3);(sink,n4,v0);(call0,n3);(sink,n2,v1)]',
        'p2,p2,l2,l2i|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(call0,n0);(def,v3,(glob,n1));(sink,n2,v3);(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v3);(sink,n5,v0);(sink,n2,v3);(sink,n6,v1)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(call0,n1);(sink,n2,v0);(def,v2,(sub,n3,n4));(call0,n1);(sink,n5,v2);(sink,n6,v3);(sink,n7,v1)]',
        'p2,p2,l2,l2|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(sink,n3,v1);(sink,n0,v0);(def,v3,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n6,v3);(sink,n2,v2);(sink,n6,v3);(call0,n5);(sink,n3,v1);(sink,n3,v1);(sink,n0,v0)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(glob,n1));(def,v3,(glob,n2));(call0,n3);(sink,n4,v3);(sink,n5,v1);(sink,n6,v2);(sink,n6,v2)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v3,(call,n1,(k,1)));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(call0,n3);(sink,n4,v2);(sink,n5,v1)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v0);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n1,v0);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n1,v0)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n5,v0)]',
        'p2,p2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n4,v1);(sink,n2,v2)]',
        'p2,p2,l2|[(sink,n0,v0);(call0,n1);(def,v2,(call,n2,(k,1)));(sink,n3,v1);(sink,n4,v2);(call0,n1);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v1);(sink,n0,v0);(call0,n3);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2|[(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(call0,n1);(sink,n2,v1);(sink,n0,v0);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(sink,n1,v1);(sink,n0,v0);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(sink,n0,v1);(sink,n1,v0);(call0,n2);(call0,n2)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(call0,n4);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(sink,n1,v1);(sink,n2,v0);(call0,n3)]',
        'p4,l4,l2|[(call0,n0);(sink,n1,v0);(def,v2,(call,n2,(k,1)));(sink,n1,v0);(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n5,v2);(sink,n4,v1);(call0,n0)]',
        'p4,l4,l2|[(def,v1,(addk,n0,1));(sink,n1,v1);(def,v2,(call,n2,(k,2)));(call0,n3);(sink,n1,v1);(sink,n4,v2);(sink,n1,v1);(sink,n5,v0);(sink,n4,v2);(call0,n3)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n4));(sink,n5,v2);(sink,n2,v0);(call0,n6);(sink,n5,v2);(sink,n5,v2);(call0,n6);(sink,n7,v1)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v1,(glob,n3));(call0,n4);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]',
        'p4,l4,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(call0,n2);(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v2);(sink,n6,v2);(sink,n0,v0);(call0,n2)]',
    },
    'Xr': {
        'l2,l2,l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(def,v1,(call,n0,(k,3)));(sink,n4,v2);(sink,n1,v0);(sink,n5,v1);(whileg,n6,[(def,v3,(add,n6,n2));(sink,n7,v3);(call0,n8)]);(sink,n1,v0)]',
        'l2,l2,l2,l2i|[(def,v1,(call,n0,(k,1)));(whileg,n1,[(def,v3,(add,n1,n2));(sink,n3,v3);(call0,n4);(sink,n3,v3)]);(sink,n5,v1);(def,v0,(call,n0,(k,2)));(sink,n5,v1);(def,v2,(glob,n6));(sink,n5,v1);(sink,n7,v2);(sink,n8,v0);(sink,n7,v2);(sink,n7,v2)]',
        'l2,l2,l2,l2|[(call0,n0);(call0,n0);(def,v0,(call,n1,(k,1)));(def,v3,(call,n1,(k,2)));(def,v2,(glob,n2));(def,v1,(call,n1,(k,4)));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n5,v3);(sink,n6,v2);(sink,n4,v0);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(call0,n0);(def,v1,(add,n1,n2));(sink,n3,v1);(def,v0,(call,n4,(k,2)));(def,v2,(call,n4,(k,3)));(sink,n5,v2);(def,v3,(call,n4,(k,4)));(sink,n6,v0);(sink,n6,v0);(sink,n7,v3);(sink,n7,v3);(sink,n7,v3);(sink,n6,v0);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n7,v3)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(def,v3,(glob,n0));(sink,n2,v3);(sink,n3,v0);(sink,n4,v1);(def,v2,(glob,n5));(sink,n4,v1);(sink,n6,v2);(sink,n4,v1);(sink,n6,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v0);(def,v2,(call,n1,(k,3)));(def,v3,(call,n1,(k,4)));(sink,n2,v0);(sink,n2,v0);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n3,v3);(sink,n6,v1);(sink,n5,v2);(sink,n3,v3);(sink,n5,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(glob,n3));(def,v3,(call,n1,(k,1)));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n6,v2);(sink,n7,v0);(sink,n2,v1);(sink,n7,v0);(sink,n7,v0)]',
        'l2,l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v0,(glob,n4));(sink,n5,v1);(def,v3,(call,n2,(k,4)));(sink,n6,v3);(sink,n7,v0);(sink,n7,v0);(sink,n6,v3);(sink,n6,v3);(sink,n6,v3);(sink,n5,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v2,(call,n0,(k,3)));(sink,n3,v2);(call0,n1);(def,v0,(glob,n4));(sink,n5,v0);(sink,n6,v3);(sink,n5,v0);(sink,n6,v3);(sink,n3,v2);(sink,n3,v2);(sink,n7,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(def,v2,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(def,v3,(sub,n2,n5));(sink,n3,v1);(sink,n6,v3);(sink,n4,v0);(sink,n7,v2);(sink,n4,v0);(sink,n4,v0);(sink,n7,v2);(sink,n7,v2);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(def,v0,(call,n0,(k,3)));(def,v3,(call,n0,(k,4)));(sink,n2,v2);(sink,n3,v1);(sink,n3,v1);(sink,n2,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n2,v2);(sink,n5,v3);(sink,n3,v1);(sink,n5,v3);(sink,n4,v0)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(addk,n3,5));(def,v0,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n7,v0);(sink,n6,v3);(sink,n8,v1);(sink,n8,v1);(sink,n9,v2);(sink,n7,v0);(sink,n9,v2);(sink,n8,v1)]',
        'l2,l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(def,v3,(glob,n4));(sink,n5,v0);(call0,n6);(sink,n7,v2);(sink,n7,v2);(sink,n8,v3);(sink,n7,v2);(sink,n7,v2);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n1,v2);(def,v0,(glob,n2));(call0,n3);(def,v3,(add,n4,n2));(sink,n5,v3);(sink,n5,v3);(sink,n6,v0);(def,v1,(addk,n4,5));(sink,n6,v0);(sink,n7,v1)]',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(call0,n1);(def,v3,(sub,n2,n3));(def,v1,(addk,n0,5));(sink,n4,v1);(def,v0,(call,n5,(k,4)));(sink,n6,v2);(sink,n6,v2);(sink,n7,v0);(sink,n6,v2);(sink,n6,v2);(sink,n8,v3)]',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v3,(glob,n2));(sink,n4,v3);(call0,n5);(sink,n4,v3);(def,v1,(glob,n6));(sink,n7,v2);(sink,n8,v1);(sink,n8,v1);(sink,n7,v2);(sink,n4,v3);(sink,n3,v0);(call0,n5);(sink,n8,v1);(sink,n4,v3);(sink,n3,v0)]',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v3);(def,v0,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v1);(call0,n6);(def,v2,(sub,n7,n8));(sink,n9,v2);(sink,n9,v2);(sink,n3,v3)]',
        'l2,l2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(sink,n2,v3);(def,v1,(add,n0,n1));(call0,n3);(def,v2,(call,n4,(k,2)));(sink,n5,v2);(def,v0,(call,n4,(k,3)));(sink,n6,v0);(sink,n7,v1);(sink,n7,v1);(sink,n6,v0)]',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(sink,n3,v2);(def,v0,(call,n1,(k,3)));(sink,n2,v3);(def,v1,(sub,n4,n5));(sink,n6,v0);(sink,n6,v0);(sink,n2,v3);(sink,n7,v1);(sink,n2,v3);(sink,n3,v2)]',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(whileg,n0,[(def,v2,(add,n0,n1));(sink,n4,v2);(sink,n4,v2)]);(sink,n3,v0);(sink,n2,v1)]',
        'l2,l2,l2i|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(whileg,n0,[(def,v2,(call,n2,(k,1)));(sink,n3,v2);(call0,n4)]);(sink,n5,v1);(call0,n4);(sink,n6,v0);(sink,n5,v1)]',
        'l2,l2,l2i|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(call0,n4);(sink,n5,v0);(sink,n5,v0);(sink,n1,v1);(whileg,n0,[(def,v2,(glob,n0));(sink,n6,v2);(sink,n6,v2);(sink,n6,v2)]);(sink,n1,v1);(sink,n5,v0)]',
        'l2,l2,l2i|[(whileg,n0,[(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(call0,n3)]);(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n4,v1);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(glob,n2));(sink,n3,v1);(def,v2,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(def,v0,(addk,n4,5));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(sink,n7,v2);(sink,n7,v2);(sink,n6,v0);(sink,n6,v0);(call0,n0);(sink,n5,v1);(sink,n7,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(def,v1,(sub,n3,n4));(def,v0,(glob,n4));(sink,n5,v0);(sink,n2,v2);(sink,n6,v1);(sink,n2,v2);(sink,n5,v0);(sink,n2,v2);(sink,n5,v0);(sink,n6,v1);(call0,n0);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(def,v2,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(call0,n5);(def,v2,(glob,n6));(sink,n7,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v0);(def,v1,(glob,n4));(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(sub,n1,n2));(sink,n3,v2);(def,v1,(glob,n2));(sink,n4,v1);(sink,n3,v2);(sink,n3,v2);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v0);(sink,n5,v1);(sink,n4,v2)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(def,v2,(addk,n5,5));(sink,n6,v2);(sink,n4,v1);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,1)));(call0,n1);(sink,n2,v2);(sink,n2,v2);(def,v1,(glob,n3));(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(call0,n2);(def,v1,(addk,n3,5));(sink,n1,v0);(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n3));(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(def,v1,(sub,n3,n5));(sink,n1,v0);(call0,n6);(sink,n7,v1);(sink,n7,v1);(sink,n7,v1);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(def,v2,(call,n3,(k,3)));(sink,n4,v0);(sink,n5,v1);(sink,n6,v2);(sink,n5,v1);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(def,v2,(call,n4,(k,3)));(sink,n3,v1);(sink,n5,v2);(sink,n3,v1);(sink,n6,v0);(sink,n3,v1);(call0,n7);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(def,v1,(glob,n4));(sink,n3,v0);(sink,n5,v1);(sink,n3,v0);(sink,n2,v2);(sink,n5,v1);(sink,n2,v2);(call0,n6);(sink,n5,v1);(sink,n2,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(def,v1,(addk,n0,5));(sink,n2,v0);(sink,n3,v2);(sink,n3,v2);(sink,n2,v0);(sink,n4,v1);(sink,n2,v0);(sink,n3,v2);(sink,n2,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(def,v2,(call,n4,(k,3)));(sink,n5,v1);(sink,n6,v2);(sink,n1,v0);(sink,n1,v0);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(def,v0,(addk,n0,5));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n3,v1);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(glob,n1));(call0,n2);(call0,n2);(sink,n3,v0);(sink,n3,v0);(def,v2,(glob,n4));(sink,n5,v2);(sink,n5,v2);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n3,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4);(sink,n5,v1);(def,v0,(glob,n2));(sink,n6,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v1);(def,v0,(addk,n3,5));(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(def,v0,(sub,n2,n3));(def,v2,(glob,n3));(sink,n1,v1);(sink,n1,v1);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v1);(def,v2,(glob,n0));(sink,n3,v2);(sink,n2,v1);(sink,n2,v1);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(glob,n1));(def,v1,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0);(sink,n5,v2);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(glob,n1));(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v0,(glob,n1));(def,v1,(addk,n0,5));(sink,n3,v0);(sink,n4,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(call0,n3);(def,v0,(sub,n1,n4));(def,v1,(glob,n4));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v0,(glob,n2));(def,v1,(call,n0,(k,3)));(sink,n3,v1);(sink,n4,v0);(call0,n1);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(glob,n1));(sink,n2,v2);(def,v1,(call,n0,(k,3)));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n2,v2);(call0,n4)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(def,v0,(sub,n2,n3));(sink,n1,v2);(def,v1,(glob,n3));(sink,n4,v1);(sink,n5,v0);(sink,n1,v2);(sink,n5,v0);(call0,n6);(sink,n4,v1)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(whileg,n2,[(def,v1,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]);(sink,n1,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(whileg,n1,[(def,v1,(call,n0,(k,1)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1)]);(call0,n3);(sink,n4,v0)]',
        'l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(call0,n0);(def,v0,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(call0,n0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(call0,n5);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(sink,n4,v1);(sink,n1,v0);(sink,n4,v1);(sink,n1,v0);(sink,n1,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n3,v1);(sink,n1,v0);(sink,n1,v0);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v0,(sub,n0,n1));(def,v1,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(call0,n3);(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(glob,n1));(sink,n2,v0);(sink,n2,v0);(sink,n3,v1);(sink,n2,v0);(sink,n2,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(sink,n2,v1);(sink,n2,v1);(def,v0,(call,n3,(k,2)));(sink,n2,v1);(call0,n1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0);(sink,n5,v0);(sink,n5,v0)]',
        'l2,l2|[(def,v1,(sub,n0,n1));(def,v0,(add,n2,n0));(call0,n3);(sink,n4,v1);(sink,n5,v0)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(sink,n3,v0);(sink,n2,v2);(def,v1,(addk,n4,5));(sink,n3,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(def,v2,(addk,n3,5));(call0,n4);(sink,n1,v0);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(call0,n4)]',
        'l4,l2|[(def,v0,(addk,n0,1));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(call0,n5);(sink,n4,v1)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(call0,n3);(sink,n2,v1);(sink,n4,v0);(call0,n3);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l4|[(call0,n0);(def,v0,(addk,n1,1));(sink,n2,v0);(def,v1,(sub,n3,n1));(sink,n4,v1);(sink,n4,v1);(sink,n2,v0)]',
        'l4,l4|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n0));(sink,n2,v0);(sink,n4,v1)]',
        'l4,l4|[(def,v1,(glob,n0));(def,v0,(sub,n1,n0));(sink,n2,v1);(sink,n2,v1);(call0,n3);(sink,n4,v0);(call0,n3);(sink,n2,v1)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v3)]);(sink,n3,v2);(sink,n4,v4)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v4)]);(sink,n3,v2);(sink,n4,v3)]',
        'p2,p2,l2,l2,l2|[(def,v4,(const,0));(def,v3,(glob,n0));(for,v2,v0,[(addcall,v4,(call,n1,(v,v2)));(sink,n2,v3)]);(sink,n3,v4);(sink,n4,v2)]',
        'p2,p2,l2,l2,l2|[(def,v4,(glob,n0));(def,v3,(const,0));(for,v2,v0,[(addcall,v3,(call,n1,(v,v2)));(sink,n2,v4)]);(sink,n3,v3)]',
        'p2,p2,l2,l2i|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(call0,n0);(def,v3,(glob,n1));(sink,n2,v3);(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v3);(sink,n5,v0);(sink,n2,v3);(sink,n6,v1)]',
        'p2,p2,l2,l2|[(def,v2,(const,0));(for,v3,v0,[(sink,n0,v3);(addcall,v2,(call,n1,(v,v3)))]);(sink,n2,v2)]',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(def,v2,(glob,n1));(sink,n2,v2);(call0,n3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v0);(sink,n2,v1);(def,v2,(glob,n3));(call0,n4);(sink,n5,v3);(sink,n1,v0);(sink,n6,v2);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2,l2|[(def,v3,(const,0));(for,v2,v0,[(sink,n0,v2);(addcall,v3,(call,n1,(v,v2)))]);(sink,n2,v3)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(call0,n1);(sink,n2,v0);(def,v2,(sub,n3,n4));(call0,n1);(sink,n5,v2);(sink,n6,v3);(sink,n7,v1)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(sink,n1,v3);(sink,n1,v3);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(sink,n4,v2);(sink,n5,v1);(sink,n5,v1);(sink,n4,v2);(call0,n6)]',
        'p2,p2,l2,l2|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(sink,n3,v1);(sink,n0,v0);(def,v3,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n6,v3);(sink,n2,v2);(sink,n6,v3);(call0,n5);(sink,n3,v1);(sink,n3,v1);(sink,n0,v0)]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(glob,n1));(def,v3,(glob,n2));(call0,n3);(sink,n4,v3);(sink,n5,v1);(sink,n6,v2);(sink,n6,v2)]',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n4,v0);(def,v3,(call,n5,(k,2)));(sink,n6,v3);(sink,n3,v2);(sink,n0,v1);(call0,n7);(sink,n6,v3)]',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(def,v3,(sub,n3,n5));(sink,n6,v3);(call0,n7)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v0);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n1,v0);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n1,v0)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n5,v0)]',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1);(call0,n0);(sink,n5,v1);(sink,n3,v0)]',
        'p2,p2,l2|[(call0,n0);(def,v2,(add,n1,n2));(sink,n3,v2);(call0,n0);(sink,n4,v0);(sink,n5,v1);(sink,n5,v1);(sink,n3,v2);(sink,n3,v2);(sink,n4,v0);(sink,n5,v1)]',
        'p2,p2,l2|[(call0,n0);(sink,n1,v0);(sink,n2,v1);(call0,n0);(sink,n2,v1);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n2,v1);(sink,n5,v2);(sink,n5,v2)]',
        'p2,p2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n4,v1);(sink,n2,v2)]',
        'p2,p2,l2|[(def,v2,(glob,n0));(sink,n1,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(call0,n3);(sink,n1,v1);(sink,n4,v0)]',
        'p2,p2,l2|[(sink,n0,v0);(call0,n1);(def,v2,(call,n2,(k,1)));(sink,n3,v1);(sink,n4,v2);(call0,n1);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n0,v0);(sink,n4,v1);(sink,n3,v2);(call0,n5)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(glob,n1));(sink,n2,v2);(sink,n3,v0);(sink,n2,v2);(call0,n4);(sink,n3,v0)]',
        'p2,p2,l2|[(sink,n0,v1);(sink,n1,v0);(sink,n1,v0);(call0,n2);(def,v2,(glob,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(call0,n2);(sink,n1,v0)]',
        'p2,p2|[(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(call0,n1);(sink,n2,v1);(sink,n0,v0);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(call0,n2);(sink,n1,v1)]',
        'p2,p2|[(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(sink,n1,v1);(sink,n0,v0);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(call0,n1);(sink,n2,v0);(sink,n2,v0)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(sink,n0,v1);(sink,n1,v0);(call0,n2);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n1,v0);(call0,n2);(sink,n0,v1);(sink,n1,v0)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(call0,n3);(call0,n3);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(call0,n4);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(sink,n1,v1);(sink,n2,v0);(call0,n3)]',
        'p4,l4,l2|[(call0,n0);(sink,n1,v0);(def,v2,(call,n2,(k,1)));(sink,n1,v0);(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n5,v2);(sink,n4,v1);(call0,n0)]',
        'p4,l4,l2|[(def,v1,(addk,n0,1));(sink,n1,v1);(def,v2,(call,n2,(k,2)));(call0,n3);(sink,n1,v1);(sink,n4,v2);(sink,n1,v1);(sink,n5,v0);(sink,n4,v2);(call0,n3)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n4));(sink,n5,v2);(sink,n2,v0);(call0,n6);(sink,n5,v2);(sink,n5,v2);(call0,n6);(sink,n7,v1)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v1,(glob,n3));(call0,n4);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]',
        'p4,l4,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(call0,n2);(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v2);(sink,n6,v2);(sink,n0,v0);(call0,n2)]',
    },
    'O3XSXr': {
        'l2,l2,l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(sub,n2,n3));(def,v1,(call,n0,(k,3)));(sink,n4,v2);(sink,n1,v0);(sink,n5,v1);(whileg,n6,[(def,v3,(add,n6,n2));(sink,n7,v3);(call0,n8)]);(sink,n1,v0)]',
        'l2,l2,l2,l2i|[(def,v1,(call,n0,(k,1)));(whileg,n1,[(def,v3,(add,n1,n2));(sink,n3,v3);(call0,n4);(sink,n3,v3)]);(sink,n5,v1);(def,v0,(call,n0,(k,2)));(sink,n5,v1);(def,v2,(glob,n6));(sink,n5,v1);(sink,n7,v2);(sink,n8,v0);(sink,n7,v2);(sink,n7,v2)]',
        'l2,l2,l2,l2i|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(def,v0,(sub,n1,n3));(whileg,n0,[(def,v3,(glob,n0));(sink,n4,v3);(sink,n4,v3);(call0,n5);(sink,n4,v3)]);(call0,n5);(def,v1,(glob,n3));(sink,n6,v0);(sink,n2,v2);(sink,n6,v0);(sink,n7,v1);(sink,n6,v0)]',
        'l2,l2,l2,l2i|[(whileg,n0,[(def,v3,(add,n0,n1));(sink,n2,v3);(sink,n2,v3);(call0,n3);(sink,n2,v3)]);(def,v1,(glob,n0));(sink,n4,v1);(def,v0,(sub,n1,n5));(sink,n4,v1);(sink,n6,v0);(def,v2,(addk,n0,5));(sink,n7,v2);(sink,n7,v2);(sink,n4,v1)]',
        'l2,l2,l2,l2|[(call0,n0);(call0,n0);(def,v0,(call,n1,(k,1)));(def,v3,(call,n1,(k,2)));(def,v2,(glob,n2));(def,v1,(call,n1,(k,4)));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n5,v3);(sink,n5,v3);(sink,n6,v2);(sink,n4,v0);(sink,n6,v2);(sink,n6,v2);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(call0,n0);(def,v1,(add,n1,n2));(sink,n3,v1);(def,v0,(call,n4,(k,2)));(def,v2,(call,n4,(k,3)));(sink,n5,v2);(def,v3,(call,n4,(k,4)));(sink,n6,v0);(sink,n6,v0);(sink,n7,v3);(sink,n7,v3);(sink,n7,v3);(sink,n6,v0);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n7,v3)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(def,v3,(glob,n0));(sink,n2,v3);(sink,n3,v0);(sink,n4,v1);(def,v2,(glob,n5));(sink,n4,v1);(sink,n6,v2);(sink,n4,v1);(sink,n6,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v0);(def,v2,(call,n1,(k,3)));(def,v3,(call,n1,(k,4)));(sink,n2,v0);(sink,n2,v0);(sink,n3,v3);(call0,n4);(sink,n5,v2);(sink,n3,v3);(sink,n6,v1);(sink,n5,v2);(sink,n3,v3);(sink,n5,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(def,v2,(glob,n3));(def,v3,(call,n1,(k,1)));(sink,n4,v3);(call0,n5);(sink,n4,v3);(sink,n6,v2);(sink,n7,v0);(sink,n2,v1);(sink,n7,v0);(sink,n7,v0)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(glob,n1));(sink,n2,v2);(sink,n2,v2);(def,v1,(addk,n0,5));(sink,n2,v2);(def,v3,(call,n3,(k,4)));(sink,n4,v0);(sink,n5,v3);(sink,n6,v1);(sink,n5,v3);(sink,n2,v2)]',
        'l2,l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v3,(addk,n0,5));(sink,n1,v0);(def,v1,(sub,n4,n5));(sink,n6,v3);(sink,n1,v0);(sink,n7,v1);(sink,n6,v3);(sink,n3,v2);(sink,n7,v1);(sink,n3,v2);(sink,n6,v3);(sink,n7,v1);(sink,n7,v1);(sink,n6,v3)]',
        'l2,l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(sink,n3,v2);(def,v0,(glob,n4));(sink,n5,v1);(def,v3,(call,n2,(k,4)));(sink,n6,v3);(sink,n7,v0);(sink,n7,v0);(sink,n6,v3);(sink,n6,v3);(sink,n6,v3);(sink,n5,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(sub,n1,n2));(def,v2,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(def,v3,(sub,n2,n5));(sink,n3,v1);(sink,n6,v3);(sink,n4,v0);(sink,n7,v2);(sink,n4,v0);(sink,n4,v0);(sink,n7,v2);(sink,n7,v2);(sink,n3,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(addk,n3,5));(def,v0,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n7,v0);(sink,n6,v3);(sink,n8,v1);(sink,n8,v1);(sink,n9,v2);(sink,n7,v0);(sink,n9,v2);(sink,n8,v1)]',
        'l2,l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(sub,n1,n2));(def,v3,(call,n0,(k,3)));(def,v0,(glob,n3));(sink,n4,v3);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n7,v2);(sink,n4,v3);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0)]',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v3,(glob,n2));(def,v0,(addk,n3,5));(def,v1,(glob,n4));(sink,n5,v3);(sink,n6,v0);(sink,n5,v3);(sink,n5,v3);(sink,n7,v1);(sink,n8,v2);(sink,n7,v1);(sink,n6,v0);(sink,n7,v1)]',
        'l2,l2,l2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n1,v2);(def,v0,(glob,n2));(call0,n3);(def,v3,(add,n4,n2));(sink,n5,v3);(sink,n5,v3);(sink,n6,v0);(def,v1,(addk,n4,5));(sink,n6,v0);(sink,n7,v1)]',
        'l2,l2,l2,l2|[(def,v2,(glob,n0));(call0,n1);(def,v3,(sub,n2,n3));(def,v1,(addk,n0,5));(sink,n4,v1);(def,v0,(call,n5,(k,4)));(sink,n6,v2);(sink,n6,v2);(sink,n7,v0);(sink,n6,v2);(sink,n6,v2);(sink,n8,v3)]',
        'l2,l2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v3);(def,v0,(sub,n2,n3));(def,v2,(addk,n4,5));(sink,n5,v0);(def,v1,(glob,n6));(sink,n7,v2);(sink,n5,v0);(sink,n5,v0);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2);(sink,n5,v0);(sink,n7,v2);(sink,n8,v1);(sink,n1,v3);(sink,n8,v1);(sink,n7,v2)]',
        'l2,l2,l2,l2|[(def,v3,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v3);(sink,n3,v2);(def,v0,(call,n1,(k,3)));(sink,n2,v3);(def,v1,(sub,n4,n5));(sink,n6,v0);(sink,n6,v0);(sink,n2,v3);(sink,n7,v1);(sink,n2,v3);(sink,n3,v2)]',
        'l2,l2,l2i|[(def,v0,(glob,n0));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(whileg,n0,[(def,v2,(add,n0,n1));(sink,n4,v2);(sink,n4,v2)]);(sink,n3,v0);(sink,n2,v1)]',
        'l2,l2,l2i|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(call0,n4);(sink,n5,v0);(sink,n5,v0);(sink,n1,v1);(whileg,n0,[(def,v2,(glob,n0));(sink,n6,v2);(sink,n6,v2);(sink,n6,v2)]);(sink,n1,v1);(sink,n5,v0)]',
        'l2,l2,l2i|[(whileg,n0,[(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(call0,n3)]);(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n4,v1);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(call0,n0);(def,v0,(add,n1,n2));(def,v1,(glob,n2));(sink,n3,v1);(def,v2,(glob,n4));(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n3,v1);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(call0,n0);(def,v2,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(def,v0,(addk,n4,5));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(sink,n7,v2);(sink,n7,v2);(sink,n6,v0);(sink,n6,v0);(call0,n0);(sink,n5,v1);(sink,n7,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v0);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1);(call0,n5);(def,v2,(glob,n6));(sink,n7,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v1,(call,n2,(k,2)));(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n6,v2);(sink,n3,v1);(sink,n6,v2);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(def,v2,(glob,n1));(def,v1,(glob,n2));(call0,n3);(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0);(call0,n3);(sink,n5,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(call0,n3);(def,v1,(sub,n1,n4));(sink,n2,v0);(sink,n2,v0);(def,v2,(addk,n0,5));(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(call,n3,(k,2)));(def,v2,(call,n3,(k,3)));(sink,n4,v2);(sink,n5,v1);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0);(sink,n4,v2);(sink,n2,v0)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(glob,n1));(def,v2,(glob,n3));(sink,n4,v2);(sink,n2,v0);(sink,n5,v1);(sink,n4,v2)]',
        'l2,l2,l2|[(def,v0,(add,n0,n1));(sink,n2,v0);(def,v1,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v0);(call0,n4);(sink,n5,v2);(sink,n5,v2);(sink,n5,v2);(sink,n2,v0);(sink,n6,v1);(sink,n6,v1);(sink,n2,v0);(sink,n6,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,1)));(call0,n1);(sink,n2,v2);(sink,n2,v2);(def,v1,(glob,n3));(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(def,v2,(call,n0,(k,2)));(sink,n1,v0);(sink,n2,v2);(sink,n2,v2);(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n3));(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(def,v1,(sub,n3,n5));(sink,n1,v0);(call0,n6);(sink,n7,v1);(sink,n7,v1);(sink,n7,v1);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(def,v1,(glob,n3));(sink,n2,v0);(sink,n4,v1);(sink,n4,v1);(def,v2,(add,n0,n3));(sink,n5,v2);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n5,v0);(sink,n4,v2);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(def,v2,(call,n3,(k,3)));(sink,n4,v0);(sink,n5,v1);(sink,n6,v2);(sink,n5,v1);(sink,n6,v2);(sink,n4,v0);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v1,(sub,n1,n2));(sink,n3,v1);(def,v2,(call,n4,(k,3)));(sink,n3,v1);(sink,n5,v2);(sink,n3,v1);(sink,n6,v0);(sink,n3,v1);(call0,n7);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(def,v1,(glob,n4));(sink,n3,v0);(sink,n5,v1);(sink,n3,v0);(sink,n2,v2);(sink,n5,v1);(sink,n2,v2);(call0,n6);(sink,n5,v1);(sink,n2,v2)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(def,v2,(call,n4,(k,3)));(sink,n5,v1);(sink,n6,v2);(sink,n1,v0);(sink,n1,v0);(sink,n1,v0)]',
        'l2,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v2,(glob,n2));(def,v1,(glob,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n4,v1);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v2,(addk,n0,5));(sink,n4,v2);(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(call,n2,(k,2)));(def,v0,(addk,n0,5));(sink,n3,v1);(sink,n3,v1);(sink,n4,v0);(sink,n3,v1);(sink,n5,v2);(sink,n5,v2);(sink,n3,v1);(sink,n4,v0);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(def,v2,(glob,n1));(def,v0,(call,n2,(k,3)));(sink,n3,v0);(sink,n4,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(def,v2,(glob,n3));(sink,n2,v1);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2)]',
        'l2,l2,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n1,n3));(sink,n2,v1);(def,v2,(addk,n0,5));(sink,n4,v0);(sink,n4,v0);(sink,n5,v2);(sink,n5,v2);(sink,n4,v0);(sink,n2,v1);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(call,n0,(k,1)));(def,v2,(add,n1,n2));(sink,n3,v2);(sink,n3,v2);(sink,n3,v2);(call0,n4);(sink,n5,v1);(def,v0,(glob,n2));(sink,n6,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(def,v2,(glob,n2));(sink,n3,v1);(sink,n4,v0);(call0,n5);(sink,n4,v0);(sink,n6,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(def,v2,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n3,v1);(sink,n5,v0);(sink,n5,v0);(sink,n6,v2);(sink,n3,v1)]',
        'l2,l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(sink,n2,v0);(call0,n3);(def,v2,(glob,n4));(sink,n2,v0);(call0,n3);(sink,n5,v1);(sink,n5,v1);(sink,n2,v0);(sink,n6,v2);(sink,n5,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(glob,n1));(def,v1,(glob,n2));(sink,n3,v1);(call0,n4);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0);(sink,n5,v2);(sink,n3,v1);(sink,n5,v2);(sink,n6,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v0,(sub,n1,n2));(sink,n3,v0);(def,v1,(call,n4,(k,3)));(sink,n5,v1);(sink,n3,v0);(sink,n6,v2);(sink,n6,v2);(sink,n6,v2);(sink,n3,v0);(sink,n3,v0);(sink,n5,v1);(sink,n6,v2)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(glob,n1));(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(sink,n5,v0)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(def,v1,(sub,n1,n2));(sink,n3,v2);(sink,n4,v1);(def,v0,(glob,n2));(sink,n3,v2);(sink,n5,v0);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v0,(glob,n1));(def,v1,(addk,n0,5));(sink,n3,v0);(sink,n4,v1);(sink,n2,v2);(sink,n2,v2);(sink,n2,v2);(sink,n4,v1)]',
        'l2,l2,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(sink,n2,v2);(call0,n3);(def,v0,(sub,n1,n4));(def,v1,(glob,n4));(sink,n5,v1);(sink,n6,v0);(sink,n5,v1);(call0,n3)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(call0,n1);(def,v0,(glob,n2));(def,v1,(call,n0,(k,3)));(sink,n3,v1);(sink,n4,v0);(call0,n1);(sink,n4,v0);(sink,n5,v2);(sink,n4,v0)]',
        'l2,l2,l2|[(def,v2,(call,n0,(k,1)));(def,v0,(glob,n1));(sink,n2,v2);(def,v1,(call,n0,(k,3)));(sink,n3,v1);(call0,n4);(sink,n5,v0);(sink,n2,v2);(call0,n4)]',
        'l2,l2,l2|[(def,v2,(glob,n0));(def,v0,(sub,n1,n2));(def,v1,(glob,n2));(sink,n3,v0);(sink,n4,v2);(call0,n5);(sink,n6,v1);(sink,n6,v1);(call0,n5);(sink,n3,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(whileg,n2,[(def,v1,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]);(sink,n1,v0)]',
        'l2,l2i|[(def,v0,(call,n0,(k,1)));(whileg,n1,[(def,v1,(call,n0,(k,1)));(sink,n2,v1);(sink,n2,v1);(sink,n2,v1)]);(call0,n3);(sink,n4,v0)]',
        'l2,l2|[(call0,n0);(def,v0,(call,n1,(k,1)));(def,v1,(sub,n2,n3));(sink,n4,v1);(sink,n4,v1);(sink,n5,v0);(sink,n4,v1);(sink,n4,v1);(call0,n0)]',
        'l2,l2|[(def,v0,(add,n0,n1));(def,v1,(glob,n1));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(call0,n3);(sink,n4,v1);(sink,n1,v0);(sink,n4,v1);(sink,n1,v0);(sink,n1,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(call,n0,(k,2)));(def,v1,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(def,v1,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(call0,n3);(call0,n3);(sink,n4,v0);(sink,n5,v1)]',
        'l2,l2|[(def,v1,(add,n0,n1));(def,v0,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,1)));(def,v0,(call,n0,(k,2)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n2,v0);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(call,n0,(k,2)));(def,v0,(call,n0,(k,1)));(call0,n1);(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(def,v0,(glob,n2));(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(call0,n1);(sink,n4,v0);(sink,n3,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(call0,n1);(sink,n2,v1);(sink,n2,v1);(def,v0,(call,n3,(k,2)));(sink,n2,v1);(call0,n1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(call,n1,(k,2)));(sink,n2,v1);(sink,n3,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n3,v0);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1);(sink,n4,v1);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v0);(sink,n4,v1)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n3,v1);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(def,v0,(glob,n1));(call0,n2);(sink,n3,v1);(sink,n4,v0)]',
        'l2,l2|[(def,v1,(glob,n0));(sink,n1,v1);(def,v0,(sub,n2,n3));(sink,n1,v1);(sink,n4,v0);(sink,n1,v1);(sink,n4,v0)]',
        'l4,l2,l2|[(def,v0,(addk,n0,1));(call0,n1);(def,v2,(call,n2,(k,2)));(sink,n3,v0);(sink,n4,v2);(def,v1,(call,n2,(k,3)));(call0,n1);(sink,n5,v1)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(def,v2,(call,n1,(k,2)));(sink,n2,v2);(sink,n3,v0);(sink,n3,v0);(sink,n2,v2);(def,v1,(addk,n4,5));(sink,n3,v0);(sink,n5,v1);(sink,n5,v1);(sink,n5,v1)]',
        'l4,l2,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(def,v2,(addk,n3,5));(call0,n4);(sink,n1,v0);(sink,n5,v2);(sink,n6,v1);(sink,n6,v1);(sink,n5,v2);(sink,n6,v1);(call0,n4)]',
        'l4,l2|[(def,v0,(addk,n0,1));(def,v1,(sub,n1,n2));(sink,n3,v0);(sink,n4,v1);(sink,n3,v0);(call0,n5);(sink,n4,v1)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(sink,n2,v1);(sink,n3,v0)]',
        'l4,l2|[(def,v0,(call,n0,(k,1)));(sink,n1,v0);(def,v1,(glob,n2));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(def,v1,(call,n1,(k,2)));(sink,n2,v1);(call0,n3);(sink,n2,v1);(sink,n4,v0);(call0,n3);(sink,n4,v0);(sink,n2,v1);(sink,n4,v0)]',
        'l4,l2|[(def,v0,(glob,n0));(sink,n1,v0);(def,v1,(call,n2,(k,2)));(sink,n1,v0);(sink,n3,v1);(sink,n1,v0)]',
        'l4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(def,v0,(sub,n3,n4));(sink,n2,v1);(sink,n5,v0);(sink,n5,v0)]',
        'l4,l4|[(call0,n0);(def,v0,(addk,n1,1));(sink,n2,v0);(def,v1,(sub,n3,n1));(sink,n4,v1);(sink,n4,v1);(sink,n2,v0)]',
        'l4,l4|[(def,v0,(glob,n0));(call0,n1);(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n0));(sink,n2,v0);(sink,n4,v1)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v3)]);(sink,n3,v2);(sink,n4,v4)]',
        'p2,p2,l2,l2,l2|[(def,v2,(const,0));(def,v3,(glob,n0));(for,v4,v0,[(addcall,v2,(call,n1,(v,v4)));(sink,n2,v4)]);(sink,n3,v2);(sink,n4,v3)]',
        'p2,p2,l2,l2,l2|[(def,v2,(glob,n0));(def,v3,(const,0));(for,v4,v0,[(addcall,v3,(call,n1,(v,v4)));(sink,n2,v2)]);(sink,n3,v3)]',
        'p2,p2,l2,l2,l2|[(def,v4,(const,0));(def,v3,(glob,n0));(for,v2,v0,[(addcall,v4,(call,n1,(v,v2)));(sink,n2,v3)]);(sink,n3,v4);(sink,n4,v2)]',
        'p2,p2,l2,l2i|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(def,v3,(add,n0,n1));(sink,n2,v1);(def,v2,(call,n3,(k,2)));(call0,n4);(sink,n5,v2);(sink,n6,v0);(sink,n2,v1);(sink,n2,v1);(sink,n5,v2);(call0,n4);(sink,n7,v3)]',
        'p2,p2,l2,l2|[(def,v3,(call,n0,(k,1)));(sink,n1,v0);(sink,n2,v1);(def,v2,(glob,n3));(call0,n4);(sink,n5,v3);(sink,n1,v0);(sink,n6,v2);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2,l2|[(def,v3,(glob,n0));(call0,n1);(sink,n2,v0);(def,v2,(sub,n3,n4));(call0,n1);(sink,n5,v2);(sink,n6,v3);(sink,n7,v1)]',
        'p2,p2,l2,l2|[(for,v2,v0,[(def,v3,(call,n0,(v,v2)));(sink,n1,v3);(sink,n1,v3);(sink,n2,v2)])]',
        'p2,p2,l2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v2);(sink,n2,v2);(sink,n3,v1);(sink,n0,v0);(def,v3,(glob,n4));(call0,n5);(sink,n6,v3);(sink,n6,v3);(sink,n2,v2);(sink,n6,v3);(call0,n5);(sink,n3,v1);(sink,n3,v1);(sink,n0,v0)]',
        'p2,p2,l2,l2|[(sink,n0,v1);(sink,n1,v0);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n4,v2);(sink,n1,v0);(def,v3,(sub,n3,n5));(sink,n6,v3);(call0,n7)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v0);(sink,n2,v1);(sink,n2,v1);(sink,n2,v1);(sink,n1,v0);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n1,v0)]',
        'p2,p2,l2|[(call0,n0);(call0,n0);(sink,n1,v1);(def,v2,(add,n2,n3));(sink,n4,v2);(sink,n5,v0)]',
        'p2,p2,l2|[(call0,n0);(sink,n1,v0);(sink,n2,v1);(call0,n0);(sink,n2,v1);(def,v2,(add,n3,n4));(sink,n5,v2);(sink,n2,v1);(sink,n5,v2);(sink,n5,v2)]',
        'p2,p2,l2|[(def,v2,(call,n0,(k,1)));(sink,n1,v2);(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(sink,n2,v1)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n0,v0);(sink,n2,v2);(sink,n2,v2);(sink,n0,v0);(sink,n3,v1);(sink,n2,v2);(call0,n4);(call0,n4)]',
        'p2,p2,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(sink,n2,v1);(sink,n0,v0);(call0,n3);(sink,n4,v2);(sink,n4,v2)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(add,n1,n2));(sink,n0,v1);(call0,n3);(sink,n4,v0);(sink,n5,v2);(sink,n0,v1);(call0,n3);(sink,n5,v2);(sink,n4,v0);(sink,n4,v0)]',
        'p2,p2,l2|[(sink,n0,v1);(def,v2,(glob,n1));(sink,n2,v2);(sink,n3,v0);(sink,n2,v2);(call0,n4);(sink,n3,v0)]',
        'p2,p2,l2|[(sink,n0,v1);(sink,n1,v0);(sink,n1,v0);(call0,n2);(def,v2,(glob,n3));(sink,n4,v2);(sink,n4,v2);(sink,n4,v2);(call0,n2);(sink,n1,v0)]',
        'p2,p2|[(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(call0,n1);(sink,n2,v1);(sink,n0,v0);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(call0,n1);(sink,n2,v1);(sink,n2,v1);(sink,n0,v0)]',
        'p2,p2|[(sink,n0,v0);(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(call0,n2);(sink,n1,v1)]',
        'p2,p2|[(sink,n0,v0);(sink,n1,v1);(sink,n1,v1);(sink,n1,v1);(sink,n0,v0);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(call0,n1);(sink,n2,v0);(sink,n2,v0)]',
        'p2,p2|[(sink,n0,v1);(sink,n0,v1);(sink,n0,v1);(sink,n1,v0);(call0,n2);(call0,n2)]',
        'p2,p2|[(sink,n0,v1);(sink,n1,v0);(call0,n2);(sink,n0,v1);(sink,n1,v0)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(call0,n3);(call0,n3);(sink,n2,v1);(sink,n4,v0);(sink,n4,v0);(sink,n4,v0);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(add,n0,n1));(sink,n2,v1);(sink,n2,v1);(sink,n3,v0);(call0,n4);(call0,n4);(sink,n2,v1)]',
        'p4,l2|[(def,v1,(call,n0,(k,1)));(sink,n1,v1);(sink,n1,v1);(sink,n2,v0);(call0,n3)]',
        'p4,l4,l2|[(call0,n0);(sink,n1,v0);(def,v2,(call,n2,(k,1)));(sink,n1,v0);(def,v1,(call,n3,(k,2)));(sink,n4,v1);(sink,n5,v2);(sink,n5,v2);(sink,n4,v1);(sink,n5,v2);(sink,n4,v1);(call0,n0)]',
        'p4,l4,l2|[(def,v1,(addk,n0,1));(sink,n1,v1);(def,v2,(call,n2,(k,2)));(call0,n3);(sink,n1,v1);(sink,n4,v2);(sink,n1,v1);(sink,n5,v0);(sink,n4,v2);(call0,n3)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v0);(sink,n2,v0);(def,v1,(sub,n3,n4));(sink,n5,v2);(sink,n2,v0);(call0,n6);(sink,n5,v2);(sink,n5,v2);(call0,n6);(sink,n7,v1)]',
        'p4,l4,l2|[(def,v2,(add,n0,n1));(sink,n2,v2);(def,v1,(glob,n3));(call0,n4);(sink,n5,v0);(sink,n6,v1);(sink,n5,v0);(sink,n6,v1);(sink,n6,v1);(sink,n5,v0)]',
        'p4,l4,l2|[(sink,n0,v0);(def,v2,(call,n1,(k,1)));(call0,n2);(def,v1,(sub,n3,n4));(sink,n5,v1);(sink,n6,v2);(sink,n6,v2);(sink,n0,v0);(call0,n2)]',
    },
}
# END TABLE


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        probes = [x for x in a[1:3] if x in ('a', 'b')] or ['a', 'b']
        sets = [x for x in a[1:3] if x in SETS] or list(SETS)
        for p in probes:
            for s in sets:
                check(p, s, show, only)
                if '--rename' in a:
                    rename_check(p, s)
    else:
        print(__doc__)
