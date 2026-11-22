#!/usr/bin/env python3
"""xr_screen.py POOL OUT: which routines of a new_pool.py list show the shape of V4.23 compiling WITHOUT -O
(-Xr or plain), where only `register` locals live in registers?

For each routine (hand source from its label to the next label that is a routine of modules_v10.tsv):
  push   prologue saves XIZ / IZ (push xiz, pushw iz) in its first 4 instructions
  spill  a parameter register stored to the frame in the prologue (ld (xsp+N), xwa|xbc|xde|wa|bc|de|a|c|e)
  reld   loads of a spilled-parameter slot later in the body
  sr     store-then-reload pairs: `ld (xsp+N), R` followed directly by `ld R', (xsp+N)` (same N)
  ldac   `lda xR, (<not a register>...)`: an address constant held in a register, the -O signature
  hand   features V4.23 never writes (ei/di, ldc, swi, reti, bank registers, link/unlk, djnz, xor r,r)
Family: (push or a frame) and (sr >= 1 or reld >= 2) and ldac == 0 and hand == 0.
Writes OUT (family, largest first) and OUT.all (every row with its metrics)."""
import re
import sys
import pathlib

PHASE6 = pathlib.Path('/home/fsanches/compartilhado/disasm-lanes/phase6')
ROOT = PHASE6 / 'v10' / 'maincpu'
MOD = PHASE6 / 'notes' / 'cc900-phase6-2026-11-16' / 'modules_v10.tsv'

routines = set()
for line in MOD.read_text().splitlines():
    c = line.split('\t')
    if len(c) == 4 and c[0] != 'address':
        routines.add(c[1])

HAND = [r'\bei\b|\bdi\b', r'\bldc\b', r'\bswi\b', r'\breti\b', r'_werp|_berp|\bldf\b|\bincf\b|\bdecf\b',
        r'\blink\b|\bunlk\b', r'\bdjnz\b', r'\bxor\s+(\w+),\s*\1\b']
LABEL = re.compile(r'^([A-Za-z_.]\w*):')
STORE = re.compile(r'^\s*ld\s+\(xsp\s*\+\s*(\d+)\)\s*,\s*(\w+)\s*$')
LOAD = re.compile(r'^\s*ld\s+(\w+)\s*,\s*\(xsp\s*\+\s*(\d+)\)\s*$')
PARAM = {'xwa', 'xbc', 'xde', 'wa', 'bc', 'de', 'a', 'c', 'e'}
cache = {}


def lines_of(f):
    if f not in cache:
        p = ROOT / f
        cache[f] = p.read_bytes().decode('latin-1').splitlines() if p.is_file() else []
    return cache[f]


def body_of(name, f):
    L = lines_of(f)
    s = next((i for i, l in enumerate(L) if l.startswith(name + ':')), None)
    if s is None:
        return None
    out = []
    for l in L[s + 1:]:
        m = LABEL.match(l)
        if m and m.group(1) in routines:
            break
        if '.include' in l and out:
            break
        c = l.split(';', 1)[0]
        if m:
            c = c[len(m.group(0)):]
        if c.strip():
            out.append(c.strip())
        if len(out) > 1500:
            break
    return out


def metrics(body):
    head = body[:4]
    push = any(re.match(r'push\w*\s+(xiz|iz)\b', x) for x in head)
    frame = any(re.match(r'(lda\s+xsp\s*,\s*\(xsp\s*-|dec\s+\d+\s*,\s*xsp)', x) for x in head)
    slots = set()
    for x in body[:8]:
        m = STORE.match(x)
        if m and m.group(2) in PARAM:
            slots.add(m.group(1))
    reld = 0
    for x in body[8:]:
        m = LOAD.match(x)
        if m and m.group(2) in slots:
            reld += 1
    sr = 0
    for a, b in zip(body, body[1:]):
        m, n = STORE.match(a), LOAD.match(b)
        if m and n and m.group(1) == n.group(2):
            sr += 1
    ldac = sum(1 for x in body if re.match(r'lda\s+x\w+\s*,\s*\((?!\s*x(wa|bc|de|hl|ix|iy|iz|sp)\b)', x))
    hand = sum(1 for x in body for rx in HAND if re.search(rx, x))
    return push, frame, len(slots), reld, sr, ldac, hand


def main():
    pool, out = sys.argv[1], sys.argv[2]
    rows = []
    for line in open(pool):
        p = line.split()
        if len(p) < 5:
            continue
        size, addr, name, mod, f = int(p[0]), p[1], p[2], p[3], p[4]
        body = body_of(name, f)
        if body is None:
            continue
        push, frame, spill, reld, sr, ldac, hand = metrics(body)
        fam = (push or frame) and (sr >= 1 or reld >= 2) and ldac == 0 and hand == 0
        rows.append((fam, size, addr, name, mod, f, push, frame, spill, reld, sr, ldac, hand, len(body)))
    with open(out + '.all', 'w') as fh:
        for r in rows:
            fh.write('%d %5d %s %-44s %4s %-40s push=%d frame=%d spill=%d reld=%d sr=%d ldac=%d hand=%d n=%d\n'
                     % ((int(r[0]),) + r[1:6] + tuple(int(v) for v in r[6:])))
    fam = [r for r in rows if r[0]]
    with open(out, 'w') as fh:
        fh.write('# xr_screen.py over %s: %d of %d routines show the unoptimised -Xr shape, %d B\n'
                 % (pool, len(fam), len(rows), sum(r[1] for r in fam)))
        for r in fam:
            fh.write('%5d  %s  %-44s %4s  %-40s push=%d spill=%d reld=%d sr=%d n=%d\n'
                     % (r[1], r[2], r[3], r[4], r[5], int(r[6]), r[8], r[9], r[10], r[13]))
    print('family: %d of %d routines, %d B' % (len(fam), len(rows), sum(r[1] for r in fam)))


if __name__ == '__main__':
    main()
