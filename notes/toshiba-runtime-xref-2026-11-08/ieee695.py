#!/usr/bin/env python3
"""Read Toshiba TLCS-900 IEEE-695 libraries (.lib, tulib) and objects (.rel).

A library starts with a module named LIBRARY whose directory holds one F8 14 block per member:
(index, 0, file offset, size, E8 public names, E9 external names).  Each member is an IEEE-695 module
(MB "T900" <name>) whose parts W2 (sections), W3 (externals) and W5 (data) are read here.
Data: E5 sec; E2 D0 sec expr (PC); E4 items, an item being n<0x80 + n literal bytes or BC expr size BD
(a relocated field of `size` bytes), or BA expr ... size BB (a PC-relative field, with a range check).
F7 n repeats the next E4 record's literal bytes n times.

usage: ieee695.py FILE.lib [--dump MEMBER]    (prints one line per member and section)
"""
import sys

class Rd:
    def __init__(s, b, p=0): s.b, s.p = b, p
    def peek(s): return s.b[s.p]
    def u8(s): v = s.b[s.p]; s.p += 1; return v
    def num(s):
        c = s.u8()
        if c < 0x80: return c
        assert 0x80 <= c <= 0x88, hex(c)
        n = c - 0x80; v = int.from_bytes(s.b[s.p:s.p + n], 'big'); s.p += n; return v
    def isnum(s): return s.p < len(s.b) and s.b[s.p] <= 0x88
    def string(s):
        c = s.u8()
        if c == 0xde: c = s.u8()
        elif c == 0xdf: c = int.from_bytes(s.b[s.p:s.p + 2], 'big'); s.p += 2
        v = s.b[s.p:s.p + c]; s.p += c; return v.decode('latin-1')
    def expr(s):
        """tokens until a byte that cannot be in an expression (>= 0xDB other than variables, or E-records)"""
        out = []
        while s.p < len(s.b):
            c = s.peek()
            if c <= 0x88: out.append(s.num())
            elif 0xa0 <= c <= 0xb9: out.append(('op', s.u8()))
            elif 0xc0 <= c <= 0xda:
                s.u8(); letter = chr(c - 0xc0 + ord('@'))
                if letter in 'IRXNPLSWBEAMCDGHTY' and s.isnum(): out.append((letter, s.num()))
                else: out.append((letter,))
            else: break
        return out

class Module:
    def __init__(s, b):
        r = Rd(b)
        assert r.u8() == 0xe0
        s.proc = r.string(); s.name = r.string()
        s.W = {}
        while True:
            c = r.peek()
            if c == 0xec:
                r.u8()
                while r.isnum(): r.num()
                if 0xc1 <= r.peek() <= 0xda: r.u8()     # address order letter (L / M)
                continue
            if c == 0xe2 and b[r.p + 1] == 0xd7:
                r.p += 2; i = r.num(); s.W[i] = r.num(); continue
            break
        s.sections = {}; s.publics = {}; s.externals = {}; s.pubval = {}
        s.parse_sections(b, s.W.get(2, 0), s.W.get(3, 0))
        s.parse_externals(b, s.W.get(3, 0), s.W.get(4, 0) or s.W.get(5, 0))
        s.parse_data(b, s.W.get(5, 0), s.W.get(6, len(b)) or len(b))
        for i, n in s.publics.items():
            v = s.pubval.get(i)
            if v and len(v) == 3 and v[0][0] == 'R' and v[2] == ('op', 0xa5):
                s.pubval[i] = (v[0][1], v[1])
    def parse_sections(s, b, a, e):
        if not a: return
        r = Rd(b, a)
        while r.p < e:
            c = r.u8()
            if c == 0xe6:
                i = r.num(); t = ''
                while 0xc1 <= r.peek() <= 0xda: t += chr(r.u8() - 0xc0 + ord('@'))
                s.sections[i] = {'type': t, 'name': r.string(), 'size': 0}
            elif c == 0xe7:
                r.num(); r.expr()
            elif c == 0xe2:
                v = r.u8(); i = r.num(); x = r.expr()
                if v == 0xd3: s.sections[i]['size'] = x[0] if x and isinstance(x[0], int) else x
                elif v == 0xcc: s.sections[i]['base'] = x
            else:
                raise ValueError('section part: %02x at %x' % (c, r.p - 1))
    def parse_externals(s, b, a, e):
        if not a: return
        r = Rd(b, a)
        while r.p < e:
            c = r.u8()
            if c == 0xe8: i = r.num(); s.publics[i] = r.string()
            elif c == 0xe9: i = r.num(); s.externals[i] = r.string()
            elif c == 0xf1:
                r.u8()
                while r.isnum(): r.num()
            elif c == 0xf4:   # weak external
                while r.isnum(): r.num()
            elif c == 0xe2:
                v = r.u8(); i = r.num(); x = r.expr()
                if v == 0xc9: s.pubval[i] = x
            else:
                raise ValueError('external part: %02x at %x' % (c, r.p - 1))
    def parse_data(s, b, a, e):
        if not a: return
        r = Rd(b, a); cur = None
        while r.p < e:
            c = r.u8()
            if c == 0xe5: cur = r.num(); s.sections[cur].setdefault('data', {}); s.sections[cur]['pc'] = 0
            elif c == 0xe2:
                v = r.u8(); i = r.num(); x = r.expr()
                if v == 0xd0:
                    pc = 0
                    if len(x) == 3 and x[2] == ('op', 0xa5): pc = x[1]
                    s.sections[i]['pc'] = pc
            elif c == 0xe4:
                sec = s.sections[cur]; d = sec['data']
                while r.p < e and (r.peek() < 0x80 or r.peek() in (0xba, 0xbc)):
                    if r.peek() in (0xba, 0xbc):     # BC expr size BD; BA expr ... size BB (PC-relative, range-checked)
                        close = r.u8() + 1; x = r.expr()
                        size = x.pop() if x and isinstance(x[-1], int) else None
                        assert r.u8() == close
                        sec.setdefault('relocs', []).append((sec['pc'], size, x))
                        for k in range(size): d[sec['pc'] + k] = None
                        sec['pc'] += size
                    else:
                        n = r.u8()
                        for k in range(n): d[sec['pc'] + k] = b[r.p + k]
                        r.p += n; sec['pc'] += n
            elif c == 0xf7:   # repeat data: F7 count, then one E4 record whose literal bytes repeat count times
                cnt = r.num(); assert r.u8() == 0xe4 and r.peek() < 0x80
                n = r.u8(); chunk = b[r.p:r.p + n]; r.p += n
                sec = s.sections[cur]
                for k in range(cnt * n): sec['data'][sec['pc'] + k] = chunk[k % n]
                sec['pc'] += cnt * n
            elif c == 0xe1: break
            else:
                raise ValueError('data part: %02x at %x' % (c, r.p - 1))
    def code(s, sec):
        d = s.sections[sec].get('data', {})
        n = max(d) + 1 if d else 0
        return [d.get(k, -1) for k in range(n)]

def library(b):
    """yield (directory publics, Module) for each member"""
    assert b[0] == 0xe0
    p = 0; out = []
    while True:
        p = b.find(b'\xf8\x14', p)
        if p < 0: break
        r = Rd(b, p + 2)
        try:
            idx = r.num(); r.num(); off = r.num(); size = r.num()
        except AssertionError:
            p += 2; continue
        if off + size > len(b) or b[off] != 0xe0: p += 2; continue
        out.append((off, size)); p = r.p
    mods = []
    for o, n in out:
        try:
            mods.append(Module(b[o:o + n]))
        except Exception as ex:
            mb = b[o:o + n]; import re
            mo = re.search(r'at ([0-9a-f]+)', str(ex)); q = int(mo.group(1), 16) if mo else 0
            print('PARSE ERROR in member at %x: %s\n  %s' % (o, ex, mb[max(0, q - 24):q + 16].hex(' ')), file=sys.stderr)
    return mods

if __name__ == '__main__':
    b = open(sys.argv[1], 'rb').read()
    mods = library(b)
    for m in mods:
        if '--dump' in sys.argv and m.name != sys.argv[sys.argv.index('--dump') + 1]: continue
        for i, sec in sorted(m.sections.items()):
            code = m.code(i)
            pubs = ['%s@%s' % (n, m.pubval.get(k)) for k, n in m.publics.items() if isinstance(m.pubval.get(k), tuple) and m.pubval[k][0] == i]
            print('%-20s %-10s %-4s size=%-5s data=%-5d relocs=%-3d %s' % (m.name, sec['name'], sec['type'], sec['size'], len(code), len(sec.get('relocs', [])), ' '.join(pubs)))
            if '--dump' in sys.argv:
                print(' '.join('..' if x is None else '??' if x == -1 else '%02x' % x for x in code))
                print(sec.get('relocs'))
    print('%d members' % len(mods), file=sys.stderr)
