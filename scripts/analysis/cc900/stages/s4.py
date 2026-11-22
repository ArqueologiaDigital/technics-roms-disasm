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
    def __init__(self, zim, regs):
        self.recs = [dump.parse_line(l) for l in zim[1:-1]]
        self.regs = dict(regs)                       # 'P0' / 'I1' -> register name or 'stack'
        self.code = []

    def name(self, x):
        return re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x).group(1) if x and re.match(r'^[*&]?([A-Z]\d+|@[\w.$]+)', x) else None

    def reg(self, x):
        """the register an I / P / T operand lives in"""
        n = self.name(x)
        r = self.regs.get(n)
        if r is None and n and n.startswith('T'):
            r = self.new_temp(n, size_of(x))
        if r is None or r == 'stack':
            raise Unsupported('operand ' + str(x))
        return r

    def new_temp(self, n, size):
        busy = {fam_of(r) for k, r in self.regs.items() if r and r != 'stack'}
        for f in FAMS:
            if f not in busy and (size != 1 or NAMES[f][0]):
                self.regs[n] = sized(f, size)
                return self.regs[n]
        raise Unsupported('no register for ' + n)

    def src(self, x, size):
        v = const(x)
        if v is not None:
            return hexc(v, size)
        m = re.match(r'^@([\w.$]+)\(', x)
        if m:
            return '(%s)' % m.group(1)
        return self.reg(x)

    def emit(self, *ins):
        self.code.append(' '.join(i for i in ins if i))

    def gen(self):
        for r in self.recs:
            op = r.op
            if op in ('BEGIN', 'DUMMY', 'PIN'):
                continue
            if op == 'END':
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
            elif op == '=':
                size = size_of(r.res)
                d = self.reg(r.res)
                s = self.src(r.args[0], size)
                if s != d:
                    self.emit('ld', d + ',' + s)
            elif op in ALU:
                size = size_of(r.res)
                self.emit(ALU[op], self.reg(r.res) + ',' + self.src(r.args[0], size))
            elif op in ('++', '--'):
                v = const(r.args[0])
                self.emit('inc' if op == '++' else 'dec', '0x%x,%s' % (v, self.reg(r.res)))
            else:
                raise Unsupported(op)
        return self.code
