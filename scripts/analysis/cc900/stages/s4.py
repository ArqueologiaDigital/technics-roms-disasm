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


COALESCE_FROM = 'T'                                  # copies of dying values of these kinds share the register
WIDEN_FROM = 'T'                                     # a dying source of these kinds is widened in place
BYTE_TO_LONG_CLEAR = True                            # byte -> long zero extension: ld X,0 / ld low,src
STRUCT_AT_0 = True                                   # *p / @(p) of a struct pointer reads its first field
COALESCE_READ_ONLY = True                            # a dying variable's copy that is only compared shares its register
BACK_HINTS = 'one'                                   # hints pass back through one T = T copy ('all': chains; False: none)
RESERVE_HINTED = True                                # avoid registers hinted to temporaries defined while live
COALESCE_RESPECTS_RESERVED = True                    # no coalescing into a register reserved for another value
HINT_YIELDS = False                                   # a hint gives way to a register reserved for another temporary
COALESCE_UNMODIFIED = False                          # a copy that is modified afterwards gets its own register
FORCE_COPY_LIVE = True                               # a multiply / divide operand still needed is copied first
ACROSS_XIZ = True                                    # a temporary live across a call goes to XIZ
BYTE_LOAD_A = True                                   # a byte temporary loaded from memory is built in A
RETURN_HINT = True                                   # a returned temporary is built in XHL
CALL_TARGET_HL = True                                # an indirect call's target temporary prefers XHL, then XIX
FORCED = {}                                          # temporary -> family, imposed by a probe (s4_temps.py)
LOG = []                                             # new_temp decisions of the last generation
LABEL_NEXT = [50000]                                 # L5000n / S5000n counters: per unit, not per function
TABLE_NEXT = [50000]
EPI_NEEDS_TWO_ENDS = True                           # does the epilogue label need more than one return
CHAINS = []                                          # thc1's switch dispatch chains of the unit, in order
CHAIN_POS = [0]


def load_switches(inter):
    """read thc1's dispatch chains (`==,X,#c,T` / `TRUE,T,,L` runs, then `JMP,Ldefault`) into CHAINS"""
    del CHAINS[:]
    CHAIN_POS[0] = 0
    LABEL_NEXT[0] = TABLE_NEXT[0] = 50000
    lines = [l.rstrip('\r\n') for l in open(inter, encoding='latin-1')]
    i = 0
    while i < len(lines):
        vals, var, j = {}, None, i
        while j < len(lines):
            if lines[j].startswith('\t'):
                j += 1
                continue
            m = re.match(r'^==,([^,]+),#[LC]?U?(-?\d+),(T\d+)$', lines[j])
            k = j + 1
            while k < len(lines) and lines[k].startswith('\t'):
                k += 1
            if m and k < len(lines) and re.match(r'^TRUE,%s,,(L\d+)$' % m.group(3), lines[k]) and \
                    var in (None, m.group(1)):
                var = m.group(1)
                vals.setdefault(int(m.group(2)), lines[k].split(',')[-1])
                j = k + 1
                continue
            break
        if len(vals) >= 2:
            m = re.match(r'^JMP,(L\d+)$', lines[j]) if j < len(lines) else None
            CHAINS.append((vals, m.group(1) if m else None))
            i = j
        else:
            i += 1


def switch_shape(labels):
    """(base, default) of a Switch whose case labels are `labels`, from the next matching dispatch chain; thc2 may have
    merged labels, so a chain label maps to one Switch label, consistently"""
    for c in range(CHAIN_POS[0], len(CHAINS)):
        vals, dflt = CHAINS[c]
        for lo in sorted(vals):
            if lo + len(labels) - 1 > max(vals):
                continue
            mp, ok = {}, True
            for i, l in enumerate(labels):
                want = vals.get(lo + i, '<default>')
                if mp.setdefault(want, l) != l:
                    ok = False
                    break
            if not ok or labels[0] != mp.get(vals.get(lo)) or vals.get(lo + len(labels) - 1) is None:
                continue
            d = mp.get('<default>') or (mp.get(dflt, dflt) if dflt else None)
            if d is None:
                continue
            CHAIN_POS[0] = c + 1
            return lo, d
    return None


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


def full_size(t):
    """bytes of a numbered or basic type"""
    if t in BASIC:
        return SIZES[BASIC[t]]
    k = TYPES.get(t)
    if not k:
        return None
    if k[0] == 'P':
        return 4
    if k[0] in ('S', 'U'):
        return int(k[1][1])
    if k[0] == 'Z':
        e, n = full_size(int(k[1][1])), int(k[1][4])
        return e * (n + 1) if e and n >= 0 else None
    return None


def field_type(t, d):
    """the basic type at byte offset d of type t (a struct field / array element), or None"""
    if t in BASIC:
        return BASIC[t] if d == 0 else None
    k = TYPES.get(t)
    if not k:
        return None
    if k[0] == 'P':
        return None
    if k[0] in ('S', 'U'):
        f = k[1]
        best = None
        for i in range(3, len(f) - 2, 3):
            ft, off = int(f[i + 1]), int(f[i + 2])
            if off <= d and (best is None or off >= best[1]):
                best = (ft, off)
        return field_type(best[0], d - best[1]) if best else None
    if k[0] == 'Z':
        e = int(k[1][1])
        es = full_size(e)
        return field_type(e, d % es) if es else None
    return None


def block_size(x):
    """bytes of the object a memory operand @(p..) / *p / @sym(T) names, from the -g type records, or None"""
    m = re.match(r'^@[\w.$]+\((\d+)\)', x or '')
    if m:
        return full_size(int(m.group(1)))
    m = re.match(r'^(?:@\(|\*)[A-Z]\d+\((\d+)\)', x or '')
    if m:
        k = TYPES.get(int(m.group(1)))
        return full_size(int(k[1][0])) if k and k[0] == 'P' else None
    return None


def deref_type(x):
    """the basic type name a memory operand @(p..) / *p reads, from p's pointer type, or None"""
    m = re.match(r'^(?:@\(|\*)[A-Z]\d+\(([A-Z]+) [FN]\*\)', x or '')
    if m:
        return m.group(1)
    m = re.match(r'^(?:@\(|\*)[A-Z]\d+\((\d+)\)(?:\(Def\))?(?:\{..\})?(?:([+-]\d+)\)$)?', x or '')
    if m:
        k = TYPES.get(int(m.group(1)))
        if k and k[0] == 'P' and (m.group(2) or STRUCT_AT_0):
            return field_type(int(k[1][0]), int(m.group(2) or 0))   # a field of the pointee
        return pointee(int(m.group(1)))
    m = re.match(r'^(?:@[\w.$]+|[IP]\d+)\((\d+)\)(?:\{..\})?\[([+-]?\d*)\]$', x or '')
    if m:
        return field_type(int(m.group(1)), int(m.group(2) or 0))
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
        self.soft = {}
        for r in self.recs:                          # an indirect call's target: XHL, else XIX
            if r.op == 'ACALP' and r.args and self.name(r.args[0]) and self.name(r.args[0]).startswith('T') and CALL_TARGET_HL:
                self.soft[self.name(r.args[0])] = ['XIX', 'XHL'] if r.res else ['XHL', 'XIX']   # (a result: XHL is its)
        self.psize = {}
        for l in zim:
            m = re.search(r'\|(P\d+)(\([^()]*\))', l)
            if m:
                self.psize.setdefault(m.group(1), size_of(m.group(1) + m.group(2)))
        SIZE0.clear()
        UNS0.clear()
        for r in self.recs:                          # a bit test fixes its type-0 operand's size by the bit number
            if r.op in ('JRBC', 'JRBS') and len(r.args) == 2 and re.match(r'^T\d+\(0\)', r.args[0] or ''):
                b = const(r.args[1])
                if b is not None and b >= 8:
                    SIZE0[re.match(r'^(T\d+)', r.args[0]).group(1)] = 2 if b < 16 else 4
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
        self.hints = self.temp_hints()         # (after the type-0 sizes: hints read them)

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
        for r in self.recs:                          # a block copy's address temporaries: XIX (destination), XIY (source)
            if r.op == 'LDIR':
                for x, f in ((r.res, 'XIX'), (r.args[0] if r.args else None, 'XIY')):
                    m = re.match(r'^(?:\*|@\()(T\d+)\([^()]*\)(?:\(Def\))?(?:\{..\})?\)?$', x or '')
                    if m:
                        h.setdefault(m.group(1), f)
        if RETURN_HINT:
            for r in self.recs:                      # a temporary returned: built in XHL
                if r.op == '=' and r.res == 'A' and r.args and self.name(r.args[0]) and \
                        self.name(r.args[0]).startswith('T') and not r.args[0].startswith(('*', '@', '&')):
                    h.setdefault(self.name(r.args[0]), 'XHL')
        if USE_HINT:
            for r in self.recs:                      # a temporary converted / copied into a register variable
                n = self.name(r.res) if r.res else None
                if r.op in ('CONV', '=') and n and n[0] in 'IP' and self.regs.get(n) not in (None, 'stack') and \
                        r.args and self.name(r.args[0]) and self.name(r.args[0]).startswith('T') and \
                        not r.args[0].startswith(('*', '@', '&')):
                    h.setdefault(self.name(r.args[0]), fam_of(self.regs[n]))
        if BYTE_LOAD_A:
            for r in self.recs:                      # a byte loaded from memory into a temporary: through A
                n = self.name(r.res) if r.res else None
                if r.op == '=' and n and n.startswith('T') and not r.res.startswith(('*', '@')) and r.args and \
                        r.args[0].startswith(('@', '*')) and size_of(r.res) == 1 and n not in h:
                    self.soft.setdefault(n, ['XWA'])     # (soft: only when A is free)
        direct = set(h)
        for i in range(len(self.recs) - 1, -1, -1):
            r = self.recs[i]
            n = self.name(r.res) if r.res else None
            if BACK_HINTS and r.op == '=' and n and n.startswith('T') and r.args and self.name(r.args[0]) and \
                    self.name(r.args[0]).startswith('T') and n in h and (n in direct or BACK_HINTS == 'all'):
                h.setdefault(self.name(r.args[0]), h[n])   # T1 = T0 copies pass the hint back
        return h

    def reserved(self, n):
        """families hinted to other temporaries defined while n is still live (after the current record)"""
        self.live_out()
        out = set()
        for j in range(self.pos + 1, len(self.recs)):
            r = self.recs[j]
            m = self.name(r.res) if r.res else None
            if m and m != n and m in self.hints and m not in self.regs and n in self._live[j] and \
                    any(n in self._live[k] for k in self._succ[j]):
                out.add(self.hints[m])
            if r.op == 'AARG' and r.extra and re.match(r'^#0,[123]$', r.extra) and \
                    any(n in self._live[k] for k in self._succ[j]) and self.name(r.args[0]) != n:
                out.add(ARGREG[int(r.extra[-1]) - 1])      # an argument register loaded while n lives
        return out

    def only_compared(self, n, i):
        """is variable n, after record i, used only as the operand of compare branches"""
        uses = [r for r in self.recs[i + 1:] if any(x and self.name(x) == n for x in [r.res] + r.args)]
        return bool(uses) and all(r.op in ('BEQ', 'BNE', 'BLT', 'BGE', 'BGT', 'BLE') for r in uses)

    def written_after(self, n, i):
        """is variable n written (or modified in place, a Switch included) by a record after i"""
        for r in self.recs[i + 1:]:
            if r.res and self.name(r.res) == n and not r.res.startswith(('*', '@')) and \
                    r.op not in ('BEQ', 'BNE', 'BLT', 'BGE', 'BGT', 'BLE', 'JRBC', 'JRBS', 'AARG', 'CARG', 'DUMMY', 'PIN'):
                return True
        return False

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

    def across(self, n):
        """is temporary n live across a call (it then needs XIZ, the register calls keep)"""
        if not ACROSS_XIZ:
            return False
        if not hasattr(self, '_across'):
            self._across = {}
        if n not in self._across:
            import flow
            self._across[n] = flow.live_across_call(self.recs, n)
        return self._across[n]

    def new_temp(self, n, size, prefer=None):
        if LIVENESS:
            lo = self.live_out()
            busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack' and k in lo and k != n}
        else:
            busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack' and self.live(k)}
        res_ = self.reserved(n) if RESERVE_HINTED else set()
        busy = set(busy) | res_
        prefs = [f for f in (self.hints.get(n), prefer) if f and (f not in res_ or not HINT_YIELDS)]
        if n not in FORCED and self.across(n):
            held = {r for k, r in self.regs.items() if r and k != n and k in self.live_out() and r in
                    ('XIZ', 'IZ', 'QIZ', 'IZL', 'IZH', 'QIZL', 'QIZH')}
            lo_ = held & {'XIZ', 'IZ', 'IZL', 'IZH'}
            hi_ = held & {'XIZ', 'QIZ', 'QIZL', 'QIZH'}
            pick = ('XIZ' if not held else None) if size == 4 else \
                (('IZ' if not lo_ else ('QIZ' if not hi_ else None)) if size == 2 else
                 ('QIZH' if not hi_ else ('IZL' if not lo_ else None)))
            if pick:                                 # a temporary live across a call: XIZ's free part
                self.regs[n] = pick
                LOG.append((n, size, 'XIZ', len(self.code), sorted(str(b) for b in busy), prefs, self.recs[self.pos].op))
                return pick
        if n in FORCED:                              # (a choice imposed by a probe, s4_temps.py)
            self.regs[n] = sized(FORCED[n], size)
            LOG.append((n, size, FORCED[n], len(self.code), sorted(str(b) for b in busy), prefs, self.recs[self.pos].op))
            return self.regs[n]
        for f in [g for g in self.soft.get(n, []) if g not in busy]:
            self.regs[n] = sized(f, size)            # a soft preference: taken only when free
            LOG.append((n, size, f, len(self.code), sorted(str(b) for b in busy), prefs, self.recs[self.pos].op))
            return self.regs[n]
        for f in prefs + FAMS:
            if (f not in busy or f in prefs) and (size != 1 or f in ('XWA', 'XBC', 'XDE', 'XHL') or BYTE_TEMPS):
                self.regs[n] = sized(f, size)
                LOG.append((n, size, f, len(self.code), sorted(str(b) for b in busy), prefs, self.recs[self.pos].op))
                return self.regs[n]
        live_busy = busy - res_                      # every family taken once reservations count: ignore them;
        for f in FAMS:                               # a byte may then take IXL / IYL as well
            if f not in live_busy and f != 'XIZ':
                self.regs[n] = sized(f, size)
                LOG.append((n, size, f, len(self.code), sorted(str(b) for b in busy), prefs, self.recs[self.pos].op))
                return self.regs[n]
        raise Unsupported('no register for ' + n)

    def long_of(self, x):
        r = self.reg(x)
        return NAMES[fam_of(r)][2]

    def mem(self, x):
        """a memory operand as the listing writes it, or None"""
        if x.startswith('*'):
            return '(%s)' % self.long_of(x[1:])
        m = re.match(r'^@([\w.$]+)\([^()]*\)(?:\[([+-]\d+)?\])?$', x)
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
        has_epi = bool(self.save_iz or self.frame) and (sum(r.op == 'END' for r in self.recs) > 1
                                                        or not EPI_NEEDS_TWO_ENDS)
        nsw = sum(r.op == 'Switch' for r in self.recs)
        self.label0 = LABEL_NEXT[0]
        self.table0 = TABLE_NEXT[0]
        self.has_epi = has_epi
        LABEL_NEXT[0] += has_epi + nsw
        TABLE_NEXT[0] += nsw
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
        f2.label0, f2.table0, f2.has_epi = self.label0, self.table0, self.has_epi
        f2.save_iz = want if not any(re.search(r'\bXIZ\b', c) for c in body) else 'XIZ'
        return f2._gen()

    def _gen(self):
        del LOG[:]
        self.epi_label = 'L%d' % self.label0
        self.next_label = self.label0 + (1 if self.has_epi else 0)
        self.next_table = self.table0
        self.tables = []
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
                top = {'XIZ': 4, 'IZ': 2, 'QIZ': 2}.get(self.save_iz, 0) + self.frame
                for k in sorted(spilled, key=lambda p: int(p[1:])):   # spilled register parameters: the top of the
                    sz = self.psize.get(k, 2)                          # frame, P0 highest, each an even size
                    top -= sz + (sz & 1)
                    self.offs[k] = top
                for k in spilled:                    # stored at entry, the highest parameter first
                    o = self.offs[k]
                    self.emit('ld', '%s,%s' % ('(XSP+0x%x)' % o if o else '(XSP)', sized(ARGREG[int(k[1:])], self.psize.get(k, 2))))
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
                        self.emit('j', self.epi_label)
                        continue
                    if any(c == 'j ' + self.epi_label for c in self.code):
                        self.emit(self.epi_label + ':')
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
                if FORCE_COPY_LIVE and (self.name(a)[0] != 'T' or not self.dies(a, i_)):
                    rn = self.new_temp(self.name(r.res), 4)  # (an operand still needed: copied first)
                    self.emit('ld', '%s,%s' % (sized(fam_of(rn), 2), ra))
                    self.regs[self.name(r.res)] = NAMES[fam_of(rn)][2]
                else:
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
                if r.res == 'A' or n is None:
                    pass                                 # (the function's own result: already in XHL)
                elif n.startswith('T') and n not in self.regs and not self.across(n):
                    self.regs[n] = 'XHL'
                elif n.startswith('T') and n not in self.regs:
                    self.emit('ld', '%s,XHL' % self.new_temp(n, 4))   # kept across a later call: moved to XIZ
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
            elif op == 'Switch':
                labels = r.args[0].split() if len(r.args) == 1 else r.args
                shape = switch_shape(labels)
                if shape is None:
                    raise Unsupported('Switch shape')
                base, dflt = shape
                x = r.res
                n_ = self.name(x)
                sz = size_of(x)
                if re.match(r'^T\d+\(0\)', x) and n_ not in SIZE0:
                    sz = 2                               # (a promoted switch operand: int)
                    SIZE0[n_] = 2
                rr = self.reg(x)
                uns = unsigned(x)
                if base:
                    self.emit(*(('dec', '0x%x,%s' % (base, rr)) if 0 < base <= 8 else ('sub', '%s,0x%x' % (rr, base & 0xffffffff))))
                if uns:
                    if base:
                        self.emit('cp', rr + ',0x0'); self.emit('j', 'ult,' + dflt)
                    self.emit('cp', '%s,0x%x' % (rr, len(labels) - 1)); self.emit('j', 'ugt,' + dflt)
                else:
                    self.emit('cp', rr + ',0x0'); self.emit('j', ('lt,' if base else 'm,') + dflt)
                    self.emit('cp', '%s,0x%x' % (rr, len(labels) - 1)); self.emit('j', 'gt,' + dflt)
                S = 'S%d' % self.next_table
                L = 'L%d' % self.next_label
                self.next_table += 1
                self.next_label += 1
                self.emit('add', '%s,%s' % (rr, rr))
                if sz == 4:
                    w = NAMES[fam_of(rr)][1]
                    self.emit('add', '%s,%s' % (rr, S))
                    self.emit('ld', '%s,(%s)' % (w, rr))
                else:
                    w = rr
                    self.emit('lda', 'XIX,' + S)
                    self.emit('ld', '%s,(XIX+%s)' % (w, w))
                self.emit('lda', 'XIX,' + L)
                self.emit('j', 'XIX+' + w)
                self.emit(L + ':')
                self.tables += ['dw %s-%s' % (l, L) for l in labels]
            elif op == 'LDIR':
                dst_, src_ = r.res, r.args[0]          # a block copy: source address to XIY, destination to XIX
                n_ = block_size(dst_) or block_size(src_)
                if not n_:
                    raise Unsupported('LDIR size')
                for x, reg_ in ((src_, 'XIY'), (dst_, 'XIX')):
                    m = re.match(r'^@([\w.$]+)\([^()]*\)$', x)
                    if m:
                        self.emit('ld', '%s,%s' % (reg_, m.group(1)))
                        continue
                    a_ = self.mem(x)
                    if a_ is None:
                        raise Unsupported('LDIR operand ' + x)
                    a_ = a_[1:-1]
                    if a_ != reg_:
                        self.emit('lda' if re.search(r'[+-]', a_) else 'ld', '%s,%s' % (reg_, a_))
                self.emit('ld', 'BC,0x%x' % (n_ // 2))
                self.emit('ldirw', '(XIX+),(XIY+)')
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
                    self.name(r.args[0]) in self.regs and self.regs[self.name(r.args[0])] != 'stack' and \
                    ((self.name(r.args[0])[0] in COALESCE_FROM and
                      not (COALESCE_UNMODIFIED and self.written_after(self.name(r.res), i_))) or
                     (COALESCE_READ_ONLY and self.only_compared(self.name(r.res), i_))):
                ra = self.regs[self.name(r.args[0])]      # a copy of a variable that dies here: the same register
                if COALESCE_RESPECTS_RESERVED and fam_of(ra) in self.reserved(self.name(r.res)):
                    ra = self.new_temp(self.name(r.res), size_of(r.res))   # (unless reserved for another value)
                    self.emit('ld', '%s,%s' % (ra, sized(fam_of(self.regs[self.name(r.args[0])]), size_of(r.res))))
                    continue
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
                store = None
                if r.res == 'A':                         # into the return value: XHL
                    n = '_ret%d' % i_
                    self.regs[n] = sized('XHL', sd)
                    r = dump.Rec(r.block, r.op, n + '(%s)' % ('ULONG' if sd == 4 else ('UINT' if sd == 2 else 'UCHAR')), r.args, r.extra, r.raw)
                elif self.mem(r.res) or self.stack(r.res):   # into memory: through a register, then stored
                    store = self.mem(r.res) or self.stack(r.res)
                    n = 'T9%03d' % i_
                    self.new_temp(n, sd)
                    r = dump.Rec(r.block, r.op, n + '(%s)' % ('ULONG' if sd == 4 else ('UINT' if sd == 2 else 'UCHAR')), r.args, r.extra, r.raw)
                if n.startswith('T') and n not in self.regs and self.dies(a, i_) and \
                        (self.name(a)[0] in WIDEN_FROM):
                    self.regs[n] = sized(fam_of(ra), sd)     # widened in place
                rd = self.reg(r.res)
                ext = 'exts' if not unsigned(a) else 'extz'
                fd = fam_of(rd)
                if sd == 4 and sa == 1 and fd != fam_of(ra) and ext == 'extz' and BYTE_TO_LONG_CLEAR:
                    self.emit('ld', '%s,0x0' % rd)       # byte -> long, zero-extended: clear, then the low byte
                    self.emit('ld', '%s,%s' % (sized(fd, 1), ra))
                elif sd > sa:
                    if fd != fam_of(ra):
                        self.emit('ld', sized(fd, sa) + ',' + ra)
                    if sd == 4 and sa == 1:
                        self.emit(ext, sized(fd, 2))     # (extz / exts widen one step)
                    self.emit(ext, rd)
                elif sd == sa:
                    if rd != ra:
                        self.emit('ld', rd + ',' + ra)
                else:
                    lo = sized(fam_of(ra), sd)
                    if rd != lo:
                        self.emit('ld', rd + ',' + lo)
                if store:
                    self.cur_size = sd
                    self.emit('ld', '%s,%s' % (store, rd))
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
                    if n and n.startswith('T') and n not in self.regs and not self.across(n):
                        self.regs[n] = rr
                    elif n and n.startswith('T') and n not in self.regs:
                        self.emit('ld', '%s,%s' % (self.new_temp(n, size_of(r.res)), rr))
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
                        elif n.startswith('T') and n not in self.regs and not self.across(n):
                            self.regs[n] = rr
                        elif n.startswith('T') and n not in self.regs:
                            self.emit('ld', '%s,%s' % (self.new_temp(n, size_of(r.res)), rr))
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
        self.code = getattr(self, 'tables', []) + self.code
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
