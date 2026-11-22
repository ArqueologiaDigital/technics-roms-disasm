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
         'XIX': ('IXL', 'IX', 'XIX'), 'XIY': ('IYL', 'IY', 'XIY'), 'XIZ': ('IZL', 'IZ', 'XIZ')}
SAVE_FROM_CODE = True                                # XIZ halves saved as the generated code uses them
MEM_SIZES = True                                     # @(p..) / *p sized by p's pointee
LIVENESS = True                                      # a temporary may take a register whose variable is dead
SHARED_EPILOGUE = True                               # returns with pops / a frame share one epilogue (L50000)
RET_CC = True                                        # a jump to a bare ret is that ret
BYTE_TEMPS = False                                   # may a byte temporary take IXL / IYL / IZL
COND = {'BLT': 'lt', 'BLE': 'le', 'BGT': 'gt', 'BGE': 'ge', 'BEQ': 'eq', 'BNE': 'ne'}
UCOND = {'BLT': 'ult', 'BLE': 'ule', 'BGT': 'ugt', 'BGE': 'uge', 'BEQ': 'eq', 'BNE': 'ne'}
ARGREG = ['XWA', 'XBC', 'XDE']
ALU = {'+=': 'add', '-=': 'sub', '&=': 'and', '|=': 'or', '^=': 'xor'}


class Unsupported(Exception):
    pass


SIZE_POINTEE = True                                  # a type-0 load result has its pointer's pointee size
LOAD_REUSE = False                                    # a load whose base register dies writes into that family
USE_HINT = True                                      # a temporary copied into a register variable shares it
UNS0 = {}                                            # T<n> of type 0 -> unsigned, as what it is copied from
SIZE0 = {}                                           # T<n> of type 0 -> size inferred for the current function


TYPES = {}                                           # the unit's -g type records: number -> (kind, fields)
BASIC = {2: 'SCHAR', 3: 'UCHAR', 4: 'SSHORT', 5: 'USHORT', 6: 'SINT', 7: 'UINT', 8: 'SLONG', 9: 'ULONG'}


def load_types(path):
    """read the -g type records (`symbol_t N,kind,...`) of a listing into TYPES"""
    TYPES.clear()
    for l in open(path, encoding='latin-1'):
        m = re.match(r'^\tsymbol_t\s+(\d+),(\w+),(.*)$', l.rstrip('\r\n'))
        if m:
            TYPES.setdefault(int(m.group(1)), (m.group(2), m.group(3).split(',')))


def pointee(t):
    """the basic type name a numbered pointer type points to, or None"""
    k = TYPES.get(t)
    if k and k[0] == 'P':
        b = int(k[1][0])
        return BASIC.get(b)
    return None


def sp_adjust(n):
    """XSP += n: inc / dec take 1..8, larger steps are an lda"""
    if abs(n) <= 8:
        return ('inc' if n > 0 else 'dec', '0x%x,XSP' % abs(n))
    return ('lda', 'XSP,XSP%s0x%x' % ('+' if n > 0 else '-', abs(n)))


def tsize(t):
    """the size of a numbered type as an argument slot (chars widen to 2)"""
    if t in BASIC:
        return max(2, SIZES[BASIC[t]])
    k = TYPES.get(t)
    return 4 if k and k[0] == 'P' else 2


def callee_pops(fn):
    """bytes of stack arguments a register-convention function pops itself (retd), from its -g type record"""
    for t, (kind, f) in TYPES.items():
        if kind == 'xa' and f and f[0] == '"%s"' % fn:
            ps = [int(f[i]) for i in range(4, len(f) - 1, 3)]
            return sum(tsize(x) for x in ps[3:])
    return 0


def deref_type(x):
    """the basic type name a memory operand @(p..) / *p reads, from p's pointer type, or None"""
    m = re.match(r'^(?:@\(|\*)[A-Z]\d+\(([A-Z]+) [FN]\*\)', x or '')
    if m:
        return m.group(1)
    m = re.match(r'^(?:@\(|\*)[A-Z]\d+\((\d+)\)', x or '')
    if m:
        return pointee(int(m.group(1)))
    return None


def size_of(x):
    if MEM_SIZES and deref_type(x):
        return SIZES.get(deref_type(x), 2)
    if x and re.match(r'^[*&]?T\d+\(0\)', x):
        return SIZE0.get(re.match(r'^[*&]?(T\d+)', x).group(1), 4)
    if x and re.match(r'^#C', x):
        return 1
    if x and re.match(r'^#L', x):
        return 4
    if x and re.match(r'^#', x):
        return 2
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', x or '')
    if not m:
        return 4
    return 4 if m.group(2) else SIZES.get(m.group(1), 2)


def unsigned(x):
    if MEM_SIZES and deref_type(x):
        return deref_type(x).startswith('U')
    if x and re.match(r'^[*&]?T\d+\(0\)', x):
        return UNS0.get(re.match(r'^[*&]?(T\d+)', x).group(1), False)
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', x or '')
    return bool(m) and (m.group(2) is not None or m.group(1).startswith('U'))


def fam_of(r):
    for f, ns in NAMES.items():
        if r in ns:
            return f
    return None


def sized(f, size):
    if size not in (1, 2, 4) or f not in NAMES:
        raise Unsupported('size %s of %s' % (size, f))
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
    def __init__(self, zim, regs, offs=None, frame=0, name=None):
        self._args = (zim, regs, offs, frame, name)
        self.recs = [dump.parse_line(l) for l in zim[1:-1]]
        self.regs = dict(regs)                       # 'P0' / 'I1' -> register name or 'stack'
        self.offs = dict(offs or {})                 # stack variables' offsets from XSP (after the prologue)
        self.frame = frame
        self.retd = callee_pops(name) if name else 0
        self.spd = 0                                 # bytes pushed for a call in progress
        vals = [r for r in self.regs.values() if r]
        lo = any(r in ('IZ', 'IZH', 'IZL', 'XIZ') for r in vals)
        hi = any(r in ('QIZ', 'QIZH', 'QIZL', 'XIZ') for r in vals)
        self.save_iz = 'XIZ' if lo and hi else ('IZ' if lo else ('QIZ' if hi else None))
        self.code = []
        self.hints = self.temp_hints()
        self.psize = {}
        for l in zim:
            m = re.search(r'\|(P\d+)(\([^()]*\))', l)
            if m:
                self.psize.setdefault(m.group(1), size_of(m.group(1) + m.group(2)))
        SIZE0.clear()
        UNS0.clear()
        for _ in range(3):                           # a type-0 temporary has the size of what it is copied from/to
            for r in self.recs:
                xs = [x for x in [r.res] + r.args if x]
                if r.op in ('=', 'CONV') and len(xs) == 2 and r.op == '=':
                    a, b = xs
                    for u, v in ((a, b), (b, a)):
                        m = re.match(r'^[*&]?(T\d+)\(0\)', u)
                        pm = re.match(r'^@\([*&]?[A-Z]\d+\(([A-Z]+) [FN]\*\)', v) or \
                            re.match(r'^\*[A-Z]\d+\(([A-Z]+) [FN]\*\)', v)
                        pn = re.match(r'^(?:@\(|\*)[A-Z]\d+\((\d+)\)', v)
                        if not pm and pn and pointee(int(pn.group(1))):
                            pm = re.match(r'(.*)', pointee(int(pn.group(1))))
                        if m and pm and u is a and SIZE_POINTEE:
                            SIZE0.setdefault(m.group(1), size_of('X(%s)' % pm.group(1)))   # a load: the pointee's size
                            UNS0.setdefault(m.group(1), pm.group(1).startswith('U'))
                        elif m and not re.match(r'^[*&]?T\d+\(0\)', v) and not v.startswith(('@(', '*')):
                            SIZE0.setdefault(m.group(1), size_of(v))
                            UNS0.setdefault(m.group(1), unsigned(v))
                        elif m and re.match(r'^[*&]?T\d+\(0\)', v):
                            n2 = re.match(r'^[*&]?(T\d+)', v).group(1)
                            if n2 in SIZE0:
                                SIZE0.setdefault(m.group(1), SIZE0[n2])
                            if n2 in UNS0:
                                UNS0.setdefault(m.group(1), UNS0[n2])

    def name(self, x):
        return re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x).group(1) if x and re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x) else None

    def stack(self, x):
        n = self.name(x)
        if n in self.offs:
            o = self.offs[n] + self.spd + getattr(self, 'carg', 0)
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
        if USE_HINT:
            for r in self.recs:                      # a temporary converted / copied into a register variable
                n = self.name(r.res) if r.res else None
                if r.op in ('CONV', '=') and n and n[0] in 'IP' and self.regs.get(n) not in (None, 'stack') and \
                        r.args and self.name(r.args[0]) and self.name(r.args[0]).startswith('T') and \
                        not r.args[0].startswith(('*', '@', '&')):
                    h.setdefault(self.name(r.args[0]), fam_of(self.regs[n]))
        for i in range(len(self.recs) - 1, -1, -1):
            r = self.recs[i]
            n = self.name(r.res) if r.res else None
            if r.op == '=' and n and n.startswith('T') and r.args and self.name(r.args[0]) and \
                    self.name(r.args[0]).startswith('T') and n in h:
                h.setdefault(self.name(r.args[0]), h[n])   # T1 = T0 copies pass the hint back
        return h

    def dies(self, x, i):
        n = self.name(x)
        if LIVENESS:
            save = getattr(self, 'pos', 0)
            self.pos = i
            try:
                return n not in self.live_out()
            finally:
                self.pos = save
        return not any(n and any(self.name(y) == n or (y and n + '(' in y) for y in [rr.res] + rr.args)
                       for rr in self.recs[i + 1:])

    def live_out(self):
        """variables live after the current record (dataflow, flow.live_sets)"""
        if not hasattr(self, '_live'):
            import flow
            names = sorted({self.name(x) for r in self.recs for x in [r.res] + r.args
                            if x and self.name(x) and self.name(x)[0] in 'IPT'})
            self._live = flow.live_sets(self.recs, names)
            self._succ = flow.successors(self.recs)
        out = set()
        for j in self._succ[self.pos]:
            out |= self._live[j]
        return out

    def new_temp(self, n, size, prefer=None):
        if LIVENESS:
            lo = self.live_out()
            busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack' and k in lo and k != n}
        else:
            busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack' and self.live(k)}
        prefs = [f for f in (self.hints.get(n), prefer) if f]
        for f in prefs + FAMS:
            if (f not in busy or f in prefs) and (size != 1 or f in ('XWA', 'XBC', 'XDE', 'XHL') or BYTE_TEMPS):
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
            d = int(m.group(2)) if m.group(2) else 0
            return '(%s%s)' % (m.group(1), '' if not d else (' + 0x%x' % d if d > 0 else ' - 0x%x' % -d))
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
        m = re.match(r'^&@([\w.$]+)\([^()]*\)$', x or '')
        if m:
            return m.group(1)
        m = self.stack(x) or self.mem(x)
        if m:
            return m
        return self.reg(x)

    def dst(self, x):
        return self.stack(x) or self.mem(x) or self.reg(x)

    def emit(self, *ins):
        ins = [i for i in ins if i]
        if len(ins) == 2 and ins[0] in ('ld', 'cp', 'add', 'sub', 'and', 'or', 'xor', 'adc', 'sbc') and \
                ins[1].startswith('(') and re.search(r'\),(0x[0-9a-f]+|-?\d+)$', ins[1]):
            sz = getattr(self, 'cur_size', 2)            # a memory destination and an immediate: sized mnemonic
            ins[0] += {1: 'b', 2: 'w'}.get(sz, '')
        self.code.append(' '.join(ins))

    def live(self, k):
        """is variable k still read at or after the current record"""
        i = getattr(self, 'pos', 0)
        return any(any(self.name(y) == k or (y and k + '(' in y) for y in [rr.res] + rr.args) for rr in self.recs[i:])

    def gen(self):
        """the function's code; XIZ is saved by the halves the code itself uses (temporaries included)"""
        code = self._gen()
        if not SAVE_FROM_CODE:
            return code
        body = [c for c in code if not re.match(r'^(push|pop) (XIZ|IZ|QIZ)$', c)]
        lo = any(re.search(r'\b(XIZ|IZ|IZL|IZH)\b', c) for c in body)
        hi = any(re.search(r'\b(XIZ|QIZ|QIZL|QIZH)\b', c) for c in body)
        want = 'XIZ' if lo and hi else ('IZ' if lo else ('QIZ' if hi else None))
        if want == self.save_iz or (want == 'IZ' and any(re.search(r'\bXIZ\b', c) for c in body)):
            return code
        f2 = Fn(*self._args)
        f2.save_iz = want if not any(re.search(r'\bXIZ\b', c) for c in body) else 'XIZ'
        return f2._gen()

    def _gen(self):
        for i_, r in enumerate(self.recs):
            self.pos = i_
            op = r.op
            if op == 'BEGIN':
                if self.frame:
                    self.emit(*sp_adjust(-self.frame))
                if self.save_iz:
                    self.emit('push', self.save_iz)
                spilled = sorted([p for p in self.regs if p.startswith('P') and int(p[1:]) < 3 and
                                  self.regs[p] == 'stack'], key=lambda p: -int(p[1:]))
                o = {'XIZ': 4, 'IZ': 2, 'QIZ': 2}.get(self.save_iz, 0)
                for k in spilled:                    # spilled register parameters: slots above the saved XIZ, the
                    sz = self.psize.get(k, 2)        # highest first, each an even size; stored at entry
                    self.offs[k] = o
                    self.emit('ld', '%s,%s' % ('(XSP+0x%x)' % o if o else '(XSP)', sized(ARGREG[int(k[1:])], sz)))
                    o += sz + (sz & 1)
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
                last = not any(x.op == 'END' for x in self.recs[i_ + 1:])
                if (self.save_iz or self.frame) and SHARED_EPILOGUE:
                    if not last:                     # one epilogue, at the end: the other returns jump to it
                        self.emit('j', 'L50000')
                        continue
                    if any(c == 'j L50000' for c in self.code):
                        self.emit('L50000:')
                if self.save_iz:
                    self.emit('pop', self.save_iz)
                if self.frame:
                    self.emit(*sp_adjust(self.frame))
                self.emit('retd', '0x%x' % self.retd) if self.retd else self.emit('ret')
            elif op == 'LAB':
                self.emit(r.args[0] + ':')
            elif op == 'JMP':
                self.emit('j', r.args[0])
            elif op in COND:
                a, b = r.args
                size = size_of(a)
                self.cur_size = size
                self.emit('cp', (self.stack(a) or self.mem(a) or self.reg(a)) + ',' + self.src(b, size))
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
                    d_ = int(m.group(2)) if m.group(2) else 0
                    self.emit('lda', '%s,%s%s' % (self.long_of(r.res), m.group(1),
                                                  '' if not d_ else (' + 0x%x' % d_ if d_ > 0 else ' - 0x%x' % -d_)))
                elif self.stack(a):
                    o = self.offs[self.name(a)]          # the address of a stack variable
                    self.emit('lda', '%s,%s' % (self.long_of(r.res), 'XSP+0x%x' % o if o else 'XSP'))
                elif self.mem(a):
                    self.emit('lda', '%s,%s' % (self.long_of(r.res), self.mem(a)[1:-1]))
                else:
                    raise Unsupported('ADDR of ' + a)
            elif op == 'FORCE':
                a = r.args[0]
                ra = self.reg(a)                     # the 32-bit product lands in the operand's own family
                self.regs[self.name(r.res)] = NAMES[fam_of(ra)][2]
                self.signed_of = getattr(self, 'signed_of', {})
                self.signed_of[self.name(r.res)] = not unsigned(a)
            elif op in ('*=', '/=', '%=') and self.name(r.res) in self.regs and size_of(r.res) == 4 and \
                    re.search(r'\(0\)', r.res or ''):
                sg = getattr(self, 'signed_of', {}).get(self.name(r.res), True)
                m = {'*=': 'mul', '/=': 'div', '%=': 'div'}[op] + ('s' if sg else '')
                self.emit(m, '%s,%s' % (self.reg(r.res), self.src(r.args[0], 2)))
            elif op in ('LOW', 'HIGH'):
                rn = self.reg(r.args[0])
                f = fam_of(rn)
                n = self.name(r.res)
                if n.startswith('T') and n not in self.regs:
                    self.regs[n] = sized(f, size_of(r.res))
                elif op == 'LOW' and self.dst(r.res) != sized(f, 2):
                    self.emit('ld', '%s,%s' % (self.dst(r.res), sized(f, 2)))
                elif op == 'HIGH':
                    raise Unsupported('HIGH')
            elif op == 'ARICALL':
                a, b = r.args                        # a runtime helper: operands in XWA / XBC, result in XHL
                for x, f in ((b, 'XBC'), (a, 'XWA')):
                    v = const(x)
                    if v is not None:
                        self.emit('ld', '%s,%s' % (f, hexc(v, 4)))
                    else:
                        sx = self.stack(x) or self.mem(x) or self.reg(x)
                        if sx != f:
                            self.emit('ld', '%s,%s' % (f, sx))
                self.emit('cal', r.extra.strip())
                n = self.name(r.res)
                if n.startswith('T') and n not in self.regs:
                    self.regs[n] = 'XHL'
                elif self.dst(r.res) != 'XHL':
                    self.emit('ld', '%s,XHL' % self.dst(r.res))
            elif op in ('CARG', 'CARG &'):
                a = r.args[0]
                n = int(r.extra.strip().lstrip('#')) if r.extra else 2
                self.carg = getattr(self, 'carg', 0) + n
                if op == 'CARG &':
                    sym = a.split('(')[0].lstrip('@')
                    self.emit('pushw', '%s >> 16' % sym)
                    self.emit('pushw', '%s & 0xffff' % sym)
                else:
                    v = const(a)
                    if v is not None:
                        if n == 4:
                            self.emit('pushw', '0x%x' % ((v >> 16) & 0xffff))
                            self.emit('pushw', '0x%x' % (v & 0xffff))
                        else:
                            self.emit('pushw', '0x%x' % (v & 0xffff))
                    else:
                        self.emit('push', self.stack(a) or self.mem(a) or self.reg(a))
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
            elif LOAD_REUSE and op == '=' and self.name(r.res) and self.name(r.res).startswith('T') and \
                    self.name(r.res) not in self.regs and r.args and r.args[0].startswith(('@(', '*')) and \
                    self.name(r.args[0].lstrip('*@(')) and self.dies(r.args[0].lstrip('*@('), i_) and \
                    self.regs.get(self.name(r.args[0].lstrip('*@('))) not in (None, 'stack') and \
                    self.name(r.res) not in self.hints:
                size = size_of(r.res)
                s_ = self.src(r.args[0], size)
                self.regs[self.name(r.res)] = sized(fam_of(self.regs[self.name(r.args[0].lstrip('*@('))]), size)
                self.emit('ld', self.regs[self.name(r.res)] + ',' + s_)
            elif op == '=':
                size = size_of(r.res)
                self.cur_size = size
                d = self.dst(r.res)
                s = self.src(r.args[0], size)
                mn = 'ld'
                if r.args[0].startswith('&@') and not d.startswith('('):
                    n = self.name(r.res)                 # the address of a global: ld when it is then added to,
                    nxt = next((q for q in self.recs[i_ + 1:]        # lda when it is used as an address
                                if any(x and self.name(x) == n for x in [q.res] + q.args)), None)
                    if not (nxt is not None and nxt.op == '+=' and self.name(nxt.res) == n):
                        mn = 'lda'
                if s != d:
                    self.emit(mn, d + ',' + s)
            elif op in ALU:
                size = size_of(r.res)
                self.cur_size = size
                self.emit(ALU[op], self.dst(r.res) + ',' + self.src(r.args[0], size))
            elif op == 'CONV' and r.args and not r.args[0].startswith(('@', '*', '#')) and not self.stack(r.args[0]):
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
                elif self.stack(a) or self.mem(a):
                    self.emit('ld', '%s,%s' % (sized(f, size_of(a)), self.stack(a) or self.mem(a)))
                else:
                    ra = self.reg(a)
                    if fam_of(ra) != f:
                        self.emit('ld', '%s,%s' % (sized(f, size_of(a)), ra))
            elif op == 'AARG' and r.extra and re.match(r'^#[24],\d+$', r.extra):
                sz = int(r.extra[1])                 # a stack argument of a register-convention call: pushed
                a = r.args[0]
                v = const(a)
                if v is not None:
                    if sz == 4:
                        self.emit('pushw', '0x%x' % ((v >> 16) & 0xffff))
                    self.emit('pushw', '0x%x' % (v & 0xffff))
                else:
                    ra = self.reg(a)
                    self.emit('push', sized(fam_of(ra), sz))
                self.spd += sz
            elif op == 'CCALL':
                target = r.args[0].split('(')[0].lstrip('@')
                self.emit('cal', target)
                k = getattr(self, 'carg', 0)
                if k:
                    self.emit(*sp_adjust(k))              # the caller pops the arguments
                    self.carg = 0
                if r.res and r.res != 'A':
                    rr = sized('XHL', size_of(r.res))
                    n = self.name(r.res)
                    if n and n.startswith('T') and n not in self.regs:
                        self.regs[n] = rr
                    elif self.dst(r.res) != rr:
                        self.emit('ld', self.dst(r.res) + ',' + rr)
            elif op in ('ACALL', 'CCALL'):
                target = r.args[0].split('(')[0].lstrip('@')
                nxt = next((x for x in self.recs[i_ + 1:] if x.op not in ('DUMMY',)), None)
                if r.res is None and nxt is not None and nxt.op == 'END' and not self.frame and not self.save_iz \
                        and not self.spd and not self.retd:
                    self.emit('j', target)               # a call that ends the function: a jump
                    self.tail = True
                else:
                    self.emit('cal', target)
                    self.spd = 0                         # (the callee popped its stack arguments)
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
            elif op == 'CONV' and r.args and (r.args[0].startswith(('@', '*')) or self.stack(r.args[0])):
                sd = size_of(r.res)
                rd = self.reg(r.res)
                f = fam_of(rd)
                sa = 2 if sd == 4 else 1                 # (a widening load: the lower half, then extended)
                self.emit('ld', sized(f, sa) + ',' + self.src(r.args[0], sa))
                self.emit('extz' if True else 'exts', rd)
            elif op in ('++', '--'):
                v = const(r.args[0])
                d = self.dst(r.res)
                m_ = 'inc' if op == '++' else 'dec'
                if d.startswith('('):
                    m_ += {1: 'b', 2: 'w', 4: 'l'}[size_of(r.res)]   # a memory operand: sized mnemonic
                self.emit(m_, '0x%x,%s' % (v, d))
            else:
                raise Unsupported(op)
        if RET_CC:
            self.ret_peephole()
        return self.code

    def ret_peephole(self):
        """a jump to a label whose code is a bare ret / retd becomes that return (conditional: ret cc)"""
        at = {}
        for i, l in enumerate(self.code):
            if l.endswith(':'):
                j = i
                while j < len(self.code) and self.code[j].endswith(':'):
                    j += 1
                if j < len(self.code) and (self.code[j] == 'ret' or self.code[j].startswith('retd ')):
                    at[l[:-1]] = self.code[j]
        out = []
        for l in self.code:
            m = re.match(r'^j (?:(\w+),)?(L\d+)$', l)
            if m and m.group(1) and m.group(2) in at and at[m.group(2)] == 'ret':
                l = 'ret' + (' ' + m.group(1) if m.group(1) else '')
            out.append(l)
        self.code = out
