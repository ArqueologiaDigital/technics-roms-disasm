#!/usr/bin/env python3
"""Stage S4 of the rebuilt back end (README.md): instruction selection, from thc2's -zim records and the registers of
its parameters and locals (S3's output; in the oracle-fed check, thc2's own -g records), to the listing's code lines.
Checked by s4_check.py against thc2's listing (listing2.py).

First version: frameless functions; copies, constants, compound arithmetic, compares and branches, labels, jumps,
returns (the value in the HL family), ++ / --.  Temporaries take the first free register family (XWA, XBC, ...).
"""
import re

import dump

SIZES = {'SCHAR': 1, 'UCHAR': 1, 'SSHORT': 2, 'USHORT': 2, 'SINT': 2, 'UINT': 2, 'SLONG': 4, 'ULONG': 4}
FAMS = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ']
NAMES = {'XWA': ('A', 'WA', 'XWA'), 'XBC': ('C', 'BC', 'XBC'), 'XDE': ('E', 'DE', 'XDE'), 'XHL': ('L', 'HL', 'XHL'),
         'XIX': (None, 'IX', 'XIX'), 'XIY': (None, 'IY', 'XIY'), 'XIZ': (None, 'IZ', 'XIZ')}
COND = {'BLT': 'lt', 'BLE': 'le', 'BGT': 'gt', 'BGE': 'ge', 'BEQ': 'eq', 'BNE': 'ne'}
UCOND = {'BLT': 'ult', 'BLE': 'ule', 'BGT': 'ugt', 'BGE': 'uge', 'BEQ': 'eq', 'BNE': 'ne'}
ARGREG = ['XWA', 'XBC', 'XDE']
ALU = {'+=': 'add', '-=': 'sub', '&=': 'and', '|=': 'or', '^=': 'xor'}


class Unsupported(Exception):
    pass


def size_of(x):
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', x or '')
    if not m:
        return 4
    return 4 if m.group(2) else SIZES.get(m.group(1), 2)


def unsigned(x):
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', x or '')
    return bool(m) and (m.group(2) is not None or m.group(1).startswith('U'))


def fam_of(r):
    for f, ns in NAMES.items():
        if r in ns:
            return f
    return None


def sized(f, size):
    n = NAMES[f][{1: 0, 2: 1, 4: 2}[size]]
    if n is None:
        raise Unsupported('byte of ' + f)
    return n


def const(x):
    m = re.match(r'^#[ CL]?U?(-?\d+)$', x or '')
    if not m:
        return None
    return int(m.group(1))


def hexc(v, size):
    return '0x%x' % (v & ((1 << (8 * size)) - 1))


class Fn:
    def __init__(self, zim, regs, offs=None, frame=0):
        self.recs = [dump.parse_line(l) for l in zim[1:-1]]
        self.regs = dict(regs)                       # 'P0' / 'I1' -> register name or 'stack'
        self.offs = dict(offs or {})                 # stack variables' offsets from XSP (after the prologue)
        self.frame = frame
        self.save_iz = any(fam_of(r) == 'XIZ' or r in ('QIZ', 'QIZH', 'QIZL', 'IZH', 'IZL')
                           for r in self.regs.values() if r)
        self.code = []
        self.hints = self.temp_hints()

    def name(self, x):
        return re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x).group(1) if x and re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x) else None

    def stack(self, x):
        n = self.name(x)
        if n in self.offs:
            o = self.offs[n]
            return '(XSP+0x%x)' % o if o else '(XSP)'
        return None

    def reg(self, x):
        """the register an I / P / T operand lives in"""
        n = self.name(x)
        r = self.regs.get(n)
        if r is None and n and n.startswith('T'):
            r = self.new_temp(n, size_of(x))
        if r is None or r == 'stack':
            raise Unsupported('operand ' + str(x))
        return r

    def temp_hints(self):
        """T -> preferred family: the argument register it is copied into, or a source that dies with it"""
        h = {}
        for i, r in enumerate(self.recs):
            if r.op == 'AARG' and r.extra and re.match(r'^#0,[123]$', r.extra) and self.name(r.args[0]):
                h[self.name(r.args[0])] = ARGREG[int(r.extra[-1]) - 1]
        for i in range(len(self.recs) - 1, -1, -1):
            r = self.recs[i]
            n = self.name(r.res) if r.res else None
            if r.op == '=' and n and n.startswith('T') and r.args and self.name(r.args[0]) and \
                    self.name(r.args[0]).startswith('T') and n in h:
                h.setdefault(self.name(r.args[0]), h[n])   # T1 = T0 copies pass the hint back
        return h

    def dies(self, x, i):
        n = self.name(x)
        return not any(n and any(self.name(y) == n or (y and n + '(' in y) for y in [rr.res] + rr.args)
                       for rr in self.recs[i + 1:])

    def new_temp(self, n, size, prefer=None):
        busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack' and self.live(k)}
        prefs = [f for f in (self.hints.get(n), prefer) if f]
        for f in prefs + FAMS:
            if (f not in busy or f in prefs) and (size != 1 or NAMES[f][0]):
                self.regs[n] = sized(f, size)
                return self.regs[n]
        raise Unsupported('no register for ' + n)

    def long_of(self, x):
        r = self.reg(x)
        return NAMES[fam_of(r)][2]

    def mem(self, x):
        """a memory operand as the listing writes it, or None"""
        if x.startswith('*'):
            return '(%s)' % self.long_of(x[1:])
        m = re.match(r'^@([\w.$]+)\([^()]*\)(?:\[([+-]\d+)\])?$', x)
        if m:
            return '(%s%s)' % (m.group(1), '' if not m.group(2) else '+0x%x' % int(m.group(2)))
        if x.startswith('@('):
            inner = x[2:-1]
            e = dump.operand_end(inner, 0)
            base, rest = inner[:e], inner[e:]
            b = self.long_of(base)
            if not rest:
                return '(%s)' % b
            m = re.match(r'^([+-])(\d+)$', rest)
            if m:
                d = int(m.group(2)) * (1 if m.group(1) == '+' else -1)
                return '(%s%s0x%x)' % (b, '+' if d >= 0 else '-', abs(d)) if d else '(%s)' % b
            if rest.startswith('+'):
                return '(%s+%s)' % (b, self.reg(rest[1:]))
        return None

    def src(self, x, size):
        v = const(x)
        if v is not None:
            return hexc(v, size)
        m = self.stack(x) or self.mem(x)
        if m:
            return m
        return self.reg(x)

    def dst(self, x):
        return self.stack(x) or self.mem(x) or self.reg(x)

    def emit(self, *ins):
        self.code.append(' '.join(i for i in ins if i))

    def live(self, k):
        """is variable k still read at or after the current record"""
        i = getattr(self, 'pos', 0)
        return any(any(self.name(y) == k or (y and k + '(' in y) for y in [rr.res] + rr.args) for rr in self.recs[i:])

    def gen(self):
        for i_, r in enumerate(self.recs):
            self.pos = i_
            op = r.op
            if op == 'BEGIN':
                if self.frame:
                    self.emit('dec', '0x%x,XSP' % self.frame)
                if self.save_iz:
                    self.emit('push', 'XIZ')
                for k in sorted([p for p in self.regs if p.startswith('P') and int(p[1:]) < 3], key=lambda p: int(p[1:])):
                    want, f = self.regs[k], ARGREG[int(k[1:])]
                    if want and want != 'stack' and fam_of(want) != f:   # a parameter kept elsewhere: moved in
                        self.emit('ld', '%s,%s' % (want, sized(f, {0: 1, 1: 2, 2: 4}[NAMES[fam_of(want)].index(want)]
                                                                 if want in NAMES[fam_of(want)] else 2)))
                continue
            if op in ('DUMMY', 'PIN'):
                continue
            if op == 'END':
                if getattr(self, 'tail', False):
                    self.tail = False
                    continue
                if self.save_iz:
                    self.emit('pop', 'XIZ')
                if self.frame:
                    self.emit('inc', '0x%x,XSP' % self.frame)
                self.emit('ret')
            elif op == 'LAB':
                self.emit(r.args[0] + ':')
            elif op == 'JMP':
                self.emit('j', r.args[0])
            elif op in COND:
                a, b = r.args
                size = size_of(a)
                self.emit('cp', self.reg(a) + ',' + self.src(b, size))
                self.emit('j', (UCOND if unsigned(a) else COND)[op] + ',' + r.res)
            elif op == '=' and r.res == 'A':
                a = r.args[0]
                size = size_of(a)
                dst = sized('XHL', size)
                s = self.src(a, size)
                if s != dst:
                    self.emit('ld', dst + ',' + s)
            elif op == 'ADDR':
                a = r.args[0]
                m = re.match(r'^@([\w.$]+)\([^()]*\)(?:\[([+-]\d+)\])?$', a)
                if m:
                    self.emit('lda', '%s,%s%s' % (self.long_of(r.res), m.group(1),
                                                  '' if not m.group(2) else '+0x%x' % int(m.group(2))))
                else:
                    self.emit('lda', '%s,%s' % (self.long_of(r.res), self.mem(a)[1:-1]))
            elif op == 'asm':
                self.emit(r.args[0].strip())
            elif op == 'ACALP':
                target = self.long_of(r.args[0])
                nxt = next((x for x in self.recs[i_ + 1:] if x.op not in ('DUMMY',)), None)
                if r.res is None and nxt is not None and nxt.op == 'END' and not self.frame and not self.save_iz:
                    self.emit('j', target)
                    self.tail = True
                else:
                    self.emit('call', target)
            elif op == '=' and self.name(r.res) and self.name(r.res).startswith('T') and \
                    self.name(r.res) not in self.regs and r.args and self.name(r.args[0]) and \
                    not r.args[0].startswith(('*', '@', '#')) and self.dies(r.args[0], i_) and \
                    self.name(r.args[0]) in self.regs and self.regs[self.name(r.args[0])] != 'stack':
                ra = self.regs[self.name(r.args[0])]      # a copy of a variable that dies here: the same register
                self.regs[self.name(r.res)] = sized(fam_of(ra), size_of(r.res)) if size_of(r.res) != 4 or True else ra
            elif op == '=':
                size = size_of(r.res)
                d = self.dst(r.res)
                s = self.src(r.args[0], size)
                if s != d:
                    self.emit('ld', d + ',' + s)
            elif op in ALU:
                size = size_of(r.res)
                self.emit(ALU[op], self.dst(r.res) + ',' + self.src(r.args[0], size))
            elif op == 'CONV' and r.args and not r.args[0].startswith(('@', '*', '#')):
                a = r.args[0]
                sa, sd = size_of(a), size_of(r.res)
                ra = self.reg(a)
                n = self.name(r.res)
                if n.startswith('T') and n not in self.regs and self.dies(a, i_):
                    self.regs[n] = sized(fam_of(ra), sd)     # widened in place
                rd = self.reg(r.res)
                if sd > sa:
                    if fam_of(rd) != fam_of(ra):
                        self.emit('ld', sized(fam_of(rd), sa) + ',' + ra)
                    self.emit('exts' if not unsigned(a) else 'extz', rd)
                elif sd == sa:
                    if rd != ra:
                        self.emit('ld', rd + ',' + ra)
                else:
                    lo = sized(fam_of(ra), sd)
                    if rd != lo:
                        self.emit('ld', rd + ',' + lo)
            elif op == 'AARG' and r.extra and re.match(r'^#0,[123]$', r.extra):
                f = ARGREG[int(r.extra[-1]) - 1]
                a = r.args[0]
                v = const(a)
                if v is not None:
                    size = 4 if a.startswith('#L') else 2
                    self.emit('ld', '%s,%s' % (sized(f, size), hexc(v, size)))
                else:
                    ra = self.reg(a)
                    if fam_of(ra) != f:
                        self.emit('ld', '%s,%s' % (sized(f, size_of(a)), ra))
            elif op in ('ACALL', 'CCALL'):
                target = r.args[0].split('(')[0].lstrip('@')
                nxt = next((x for x in self.recs[i_ + 1:] if x.op not in ('DUMMY',)), None)
                if r.res is None and nxt is not None and nxt.op == 'END' and not self.frame and not self.save_iz:
                    self.emit('j', target)               # a call that ends the function: a jump
                    self.tail = True
                else:
                    self.emit('cal', target)
                    if r.res:
                        rr = sized('XHL', size_of(r.res))
                        n = self.name(r.res)
                        if r.res == 'A' or n is None:
                            pass                     # the result is the function's own: already in HL
                        elif n.startswith('T') and n not in self.regs:
                            self.regs[n] = rr
                        elif self.dst(r.res) != rr:
                            self.emit('ld', self.dst(r.res) + ',' + rr)
            elif op in ('JRBC', 'JRBS'):
                a, b = r.args
                self.emit('bit', '0x%x,%s' % (const(b), self.src(a, size_of(a))))
                self.emit('j', ('eq' if op == 'JRBC' else 'ne') + ',' + r.res)
            elif op in ('BSET', 'BCLR'):
                self.emit('set' if op == 'BSET' else 'res', '0x%x,%s' % (const(r.args[0]), self.dst(r.res)))
            elif op in ('<<=', '>>='):
                v = const(r.args[0])
                m = 'sll' if op == '<<=' else ('srl' if unsigned(r.res) else 'sra')
                if v is None:
                    raise Unsupported('shift by a register')
                self.emit(m, '0x%x,%s' % (v, self.reg(r.res)))
            elif op == 'CONV' and r.args and r.args[0].startswith(('@', '*')):
                sd = size_of(r.res)
                rd = self.reg(r.res)
                f = fam_of(rd)
                sa = 2 if sd == 4 else 1                 # (a widening load: the lower half, then extended)
                self.emit('ld', sized(f, sa) + ',' + self.src(r.args[0], sa))
                self.emit('extz' if True else 'exts', rd)
            elif op in ('++', '--'):
                v = const(r.args[0])
                self.emit('inc' if op == '++' else 'dec', '0x%x,%s' % (v, self.dst(r.res)))
            else:
                raise Unsupported(op)
        return self.code
