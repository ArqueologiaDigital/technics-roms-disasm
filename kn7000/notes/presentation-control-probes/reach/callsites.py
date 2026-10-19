"""For each call to a target, find the reaching definition of a register (default d0)
by walking backwards in the listing; flag join points (branch targets) crossed.
Usage: callsites.py <listing> <target-hex> [reg]"""
import re, sys
lst = sys.argv[1]; tgt = int(sys.argv[2], 16); reg = sys.argv[3] if len(sys.argv) > 3 else 'd0'
lines = []
for ln in open(lst):
    m = re.match(r'^([0-9a-f]{8}): ((?:[0-9a-f]{2} )+)\s*(\S+)\s*(.*)$', ln.rstrip())
    if m:
        lines.append((int(m.group(1), 16), m.group(3), m.group(4)))
idx = {a: i for i, (a, _, _) in enumerate(lines)}
targets = set()
for a, mn, ops in lines:
    if mn.startswith('b') or mn in ('jmp', 'call', 'calls') or mn.startswith('l'):
        m = re.match(r'0x([0-9a-f]+)', ops)
        if m: targets.add(int(m.group(1), 16))
def writes(mn, ops, r):
    parts = [p.strip() for p in ops.split(',')]
    if mn in ('clr', 'inc', 'dec', 'exth', 'exthu', 'extb', 'extbu', 'asl2', 'not') and parts and parts[0] == r:
        return True
    if mn in ('mov', 'movbu', 'movhu', 'movb', 'movh', 'add', 'sub', 'and', 'or', 'xor', 'asl', 'asr', 'lsr', 'mul', 'mulu', 'div', 'divu', 'addc', 'subc') and parts and parts[-1] == r:
        return True
    if mn in ('call', 'calls'):
        return r in ('d0', 'd1', 'a0', 'a1')  # clobbered by call (return value)
    return False
for i, (a, mn, ops) in enumerate(lines):
    if mn != 'call' or not ops.startswith('0x%08x' % tgt):
        continue
    j = i - 1; chain = []; join = False; r = reg
    while j >= 0 and i - j < 40:
        pa, pmn, pops = lines[j]
        if pa + 0 in targets and j != i - 1: pass
        if pmn in ('ret', 'retf', 'rets', 'rti', 'jmp', 'bra'):
            chain.append('<<%s at %08x>>' % (pmn, pa)); break
        if writes(pmn, pops, r):
            chain.append('%08x %s %s' % (pa, pmn, pops))
            if pmn in ('exth', 'exthu', 'extb', 'extbu'):
                j -= 1; continue
            m = re.match(r'^(\w+), (\w+)$', pops)
            if pmn == 'mov' and m and re.match(r'^[ad]\d$', m.group(1)):
                r = m.group(1); j -= 1; continue
            break
        j -= 1
    join = any(lines[k][0] in targets for k in range(j + 1, i + 1))
    print('%08x  %s%s' % (a, ' | '.join(chain), '  [JOIN]' if join else ''))
