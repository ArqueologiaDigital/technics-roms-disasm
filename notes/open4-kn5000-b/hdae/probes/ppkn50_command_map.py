#!/usr/bin/env python3
"""Which HD-AE5000 PC-link command bytes does each ppkn50.dll export send?

QUESTION: ppkn50.dll (HD-TechManager5000 v1.20's parallel-port DLL) starts every link
transaction with `push <command>; push <port>; call 0x10002810` (its SendCommand: strobe,
connection test, then the 256-byte packet whose byte 0 is the command).  This lists, for every
export, the command immediates it passes to SendCommand directly or through the internal
functions it calls (followed transitively), and whether it reads the reply's failure byte
(packet byte 255, DLL address 0x100121bf -- the byte the firmware's
HDAE5000_PPORT_FlagPacketError sets to 0xFF).

Needs GNU objdump with pei-i386 support (binutils).  The DLL is vendor data; it is only read.

Usage: python3 -I ppkn50_command_map.py hdae5000/hd-techmanager5000/ppkn50.dll
"""
import re
import subprocess
import sys

dll = sys.argv[1]
SEND = 0x10002810
exp = {}
p = subprocess.run(['objdump', '-p', dll], capture_output=True, text=True).stdout
rva = {}
for m in re.finditer(r'\[\s*(\d+)\] \+base\[\s*\d+\] ([0-9a-f]{8}) Export RVA', p):
    rva[int(m.group(1))] = 0x10000000 + int(m.group(2), 16)
for m in re.finditer(r'\[\s*(\d+)\] \+base\[\s*\d+\]\s+[0-9a-f]{4} (\w+)', p):
    exp[m.group(2)] = rva[int(m.group(1))]

dis = subprocess.run(['objdump', '-d', '-M', 'intel', dll], capture_output=True, text=True).stdout
ins = []
for line in dis.splitlines():
    m = re.match(r'\s*([0-9a-f]{8}):\s+(?:[0-9a-f]{2} )+\s*(.*)', line)
    if m:
        ins.append((int(m.group(1), 16), m.group(2).strip()))
addrs = [a for a, _ in ins]
idx = {a: i for i, (a, _) in enumerate(ins)}


starts = sorted(set(exp.values()) | {int(t, 16) for _, s in ins
                                       for t in re.findall(r'call\s+0x([0-9a-f]+)', s)})


def body(start):
    """Instructions from start up to the next function start (an export or any call target)."""
    nxt = next((x for x in starts if x > start), 1 << 32)
    i = idx[start]
    out = []
    while i < len(ins) and ins[i][0] < nxt:
        out.append(ins[i])
        i += 1
    return out


memo = {}


def commands(start, depth=0):
    if start in memo:
        return memo[start]
    memo[start] = (set(), False)
    cmds, fail = set(), False
    b = body(start)
    for k, (a, s) in enumerate(b):
        m = re.match(r'call\s+0x([0-9a-f]+)', s)
        if m:
            t = int(m.group(1), 16)
            if t == SEND:
                pushes = [x for _, x in b[max(0, k - 6):k] if x.startswith('push')]
                if len(pushes) >= 2:
                    imm = re.match(r'push\s+(0x[0-9a-f]+|\d+)$', pushes[-2])
                    cmds.add(int(imm.group(1), 0) if imm else pushes[-2])
            elif t in idx and depth < 6:
                c2, f2 = commands(t, depth + 1)
                cmds |= c2
                fail |= f2
        if '0x100121bf' in s:
            fail = True
    memo[start] = (cmds, fail)
    return memo[start]


rows = []
for name, a in sorted(exp.items(), key=lambda x: x[1]):
    c, f = commands(a)
    rows.append((name, '0x%08x' % a, ', '.join(('%d' % x) if isinstance(x, int) else x for x in sorted(c, key=str)) or '-', 'yes' if f else 'no'))
hdr = ('export', 'address', 'commands sent (decimal)', 'reads reply byte 255')
w = [max(len(r[i]) for r in rows + [hdr]) for i in range(4)]
fmt = '| ' + ' | '.join('%%-%ds' % x for x in w) + ' |'
print(fmt % hdr)
print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
for r in rows:
    print(fmt % r)
