"""Reconstruct RegisterObjectTable(class d0, a0 -> {type, proc, count, table}) calls
by tracking constant register values and stack stores in program.asm."""
import re, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from rom import *
L = '/home/fsanches/compartilhado/technics-roms-disasm/kn7000/disasm/program.asm'
lines = []
for ln in open(L):
    m = re.match(r'^([0-9a-f]{8}): ((?:[0-9a-f]{2} )+)\s*(\S+)\s*(.*)$', ln.rstrip())
    if m: lines.append((int(m.group(1), 16), m.group(3), m.group(4)))
def val(s):
    s = s.strip()
    try: return int(s, 0) & 0xffffffff
    except: return None
regs = {}; stack = {}
out = []
for a, mn, ops in lines:
    if mn == 'call' and ops.startswith('0x4842a717'):
        cls = regs.get('d0')
        rec = [stack.get(o) for o in (0x1c, 0x20, 0x24, 0x28)]
        out.append((a, cls, rec))
        regs.pop('d0', None); regs.pop('d1', None); regs.pop('a0', None); regs.pop('a1', None)
        continue
    if mn in ('ret', 'retf', 'rets'): regs = {}; stack = {}; continue
    p = [x.strip() for x in ops.split(',')]
    if mn in ('mov', 'movhu') and len(p) == 2:
        src, dst = p
        m = re.match(r'^\((0x[0-9a-f]+|\d+), sp\)$', dst) if False else re.match(r'^\((0x[0-9a-f]+|\d+)$', dst)
        if dst.endswith('sp)') or (len(p) == 2 and p[1] == 'sp)'):
            pass
    # handle "(0x1c, sp)" which splits into two parts
    mm = re.match(r'^(\S+), \((0x[0-9a-f]+|\d+), sp\)$', ops)
    if mn in ('mov', 'movhu') and mm:
        stack[int(mm.group(2), 0)] = regs.get(mm.group(1)); continue
    mm = re.match(r'^(\S+), ([ad]\d)$', ops)
    if mn == 'mov' and mm:
        v = val(mm.group(1))
        if v is None and re.match(r'^[ad]\d$', mm.group(1)): v = regs.get(mm.group(1))
        regs[mm.group(2)] = v; continue
    mm = re.match(r'^([ad]\d)$', ops)
    if mn == 'clr' and mm: regs[mm.group(1)] = 0; continue
    if mn == 'call': regs.pop('d0', None); regs.pop('d1', None); regs.pop('a0', None); regs.pop('a1', None)
for a, cls, rec in out:
    t, pr, n, tb = rec
    print('%08x class=%s type=%s proc=%s count=%s table=%s' % (a, hex(cls) if cls is not None else '?', hex(t) if t is not None else '?', hex(pr) if pr is not None else '?', hex(n & 0xffff) if n is not None else '?', hex(tb) if tb is not None else '?'))
