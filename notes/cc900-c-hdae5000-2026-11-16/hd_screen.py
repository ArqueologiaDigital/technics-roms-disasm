#!/usr/bin/env python3
"""hd_screen.py OUT_PREFIX: which untried HD-AE5000 v2.06i routines could still be compiled C?

QUESTION ANSWERED / WHY (2026-11-22): lane_sub's sub_screen.py (notes/cc900-c-subcpu-2026-11-16/, after lane_p6's
xr_screen.py) found small routines -- memory-to-memory setters among them -- that the earlier pools had dropped.
This is the same screen for hdae5000/ (v2.06i):
1. Pool: every routine of survey.py's survey (fresh, from the hand source) whose label line is still in the hand
   source (not built from C, not an inner label of a built body), that no probe or staged file defines
   (probes/*.c, hdae5000/cc900-staged/*.c; `cc900-name:` short names mapped), that is not PPORT_* (hand
   assembly, HANDOFF-2026-11-18.md) and not the Toshiba library (survey kind lib).  Unlike survey.py's kinds,
   memory-to-memory moves and the disk-driver range (>= 0x2971a3, documented hand assembly) are KEPT, and reported.
2. Metrics on the routine's hand source: hand marks (ei / di / ldc / swi / reti / link / unlk / djnz / xor r,r,
   push or pop of a register other than XIZ / IZ, push / pop sr), ends (ret / retd / a jump), push (XIZ / IZ saved in
   the first 4 instructions), frame, mem2mem (an instruction with two memory operands, e.g. `ld (a),(b)`).
   A candidate has no hand mark and ends in ret / retd or a jump.
Writes OUT_PREFIX.pool (every pool row with its metrics) and OUT_PREFIX.candidates (candidates, largest first) and
prints the counts.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_screen.py notes/cc900-c-hdae5000-2026-11-16/screen/hd_2026-11-22
Run from the repository root.
"""
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import survey                                                # noqa: E402

FUNC = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)', re.M)
HAND = [r'^(ei|di|ldc|swi|reti|link|unlk|djnz\w*|halt)\b', r'^xor\s+(\w+),\s*\1$',
        r'^push\w*\s+(?!xiz\b|iz\b)\w+$', r'^pop\w*\s+(?!xiz\b|iz\b)\w+$', r'^(push|pop)\s+sr\b']
MEM2 = re.compile(r'^\w+\s+\([^)]*\)\s*,\s*\([^)]*\)')
DRIVER = 0x2971a3


def defined():
    out = set()
    for p in glob.glob(os.path.join(HERE, 'probes', '*.c')) + glob.glob(os.path.join(REPO, 'hdae5000',
                                                                                    'cc900-staged', '*.c')):
        t = open(p, encoding='latin-1').read()
        names = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t))
        out |= {names.get(n, n) for n in FUNC.findall(t)}
    return out


def body_of(lines, name, routines):
    s = next((i for i, l in enumerate(lines) if l.startswith(name + ':') and '.include' not in l), None)
    if s is None:
        return None
    first = lines[s].split(';', 1)[0][len(name) + 1:].strip()
    body = [first] if first else []
    for l in lines[s + 1:]:
        m = re.match(r'^([A-Za-z_]\w*):', l)
        if m and m.group(1) in routines:
            break
        c = l.split(';', 1)[0]
        if m:
            c = c[len(m.group(0)):]
        c = re.sub(r'\s+', ' ', c.strip())
        if c and not c.startswith('.set') and not c.startswith('.L') or (c.startswith('.L') and ':' not in c):
            body.append(c)
    return body


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    prefix = sys.argv[1]
    os.makedirs(os.path.dirname(os.path.abspath(prefix)), exist_ok=True)
    rows = [r for r in survey.routines() if r['kind'] not in ('data', 'lib')]
    routines = {r['label'] for r in rows}
    done = defined()
    texts = {}
    pool = []
    for r in rows:
        name = r['label']
        if name in done or '_PPORT_' in name or name.startswith('HDAE5000_PPORT'):
            continue
        f = r['file']
        if f not in texts:
            texts[f] = open(os.path.join(REPO, 'hdae5000', f), 'rb').read().decode('latin-1').split('\n')
        body = body_of(texts[f], name, routines)
        if body is None:
            continue
        hand = sum(1 for x in body for rx in HAND if re.search(rx, x))
        last = body[-1].split()[0] if body else ''
        ends = last in ('ret', 'retd') or last in ('jp', 'jr', 'jrl') and ',' not in body[-1]
        mem2 = sum(1 for x in body if MEM2.match(x))
        push = any(re.match(r'push\w*\s+(xiz|iz)$', x) for x in body[:4])
        frame = any(re.match(r'(lda xsp, ?\(xsp ?-|dec \d+, ?xsp)', x) for x in body[:4])
        addr = int(r['addr'], 16) if r['addr'] != '-' else 0
        pool.append((r['bytes'], addr, name, f, r['kind'], hand, ends, mem2, push, frame, len(body)))
    pool.sort(key=lambda x: (-x[0], x[1]))
    cand = [p for p in pool if p[5] == 0 and p[6]]
    with open(prefix + '.pool', 'w') as fh:
        fh.write('# bytes addr label file kind hand ends mem2mem push frame insns\n')
        for p in pool:
            fh.write('%5d %06x %-48s %-24s %-6s hand=%d ends=%d mem2=%d push=%d frame=%d n=%d\n' % p)
    with open(prefix + '.candidates', 'w') as fh:
        fh.write('# hd_screen.py: %d candidates (no hand mark, ending in a return or a jump) of %d untried '
                 'routines; %d below the disk driver (0x2971a3)\n'
                 % (len(cand), len(pool), sum(1 for p in cand if p[1] < DRIVER)))
        for p in cand:
            fh.write('%5d %06x %-48s %-24s %-6s mem2=%d push=%d frame=%d n=%d%s\n'
                     % (p[0], p[1], p[2], p[3], p[4], p[7], p[8], p[9], p[10],
                        '  (driver range)' if p[1] >= DRIVER else ''))
    print('pool %d untried routines (%d B); candidates %d (%d B), %d below the driver range, %d with a '
          'memory-to-memory move' % (len(pool), sum(p[0] for p in pool), len(cand), sum(p[0] for p in cand),
                                     sum(1 for p in cand if p[1] < DRIVER), sum(1 for p in cand if p[7])))


if __name__ == '__main__':
    main()
