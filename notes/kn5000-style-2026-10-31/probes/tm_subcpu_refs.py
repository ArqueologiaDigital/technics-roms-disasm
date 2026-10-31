#!/usr/bin/env python3
"""Which sub-CPU v1.42 instructions read a byte of a tone record (the 470-byte .TM sound record's first 426
bytes), by the pointer they go through?  A recorded reader search per record offset.

Tone-record pointers, as notes in table_data/tone_database_records.s (RECORD LAYOUT FROM THE READERS) say:
  REC   the part's tone pointer: a load from Part_PatchRecord_Ptr (part +0x06), or `ld xRR, (xSS + 19)` /
        `(xSS + 0x13)` (voice slot +0x13); a displacement d on xRR within WINDOW lines = record offset d;
  BLK   a partial block: `ld xRR, (xSS + 23)` / `(xSS + 0x17)` (voice slot +0x17, paramA, the bound block
        rec + 0x66 + 0x51 * rank); a displacement d on xRR = partial-block offset d (record 0x66 + d for rank 0).
Rows are candidates (the register may be reloaded in the window); quoted rows were read.
usage: tm_subcpu_refs.py [REPO] [--window N] [--rec OFF ...] [--blk OFF ...]
Output: "REC +0xOFF  line  routine | instruction" / "BLK +0xOFF ...", then per asked offset its count."""
import collections, pathlib, re, sys
args = sys.argv[1:]
def take(flag):
    if flag not in args:
        return []
    i = args.index(flag); j = i + 1
    while j < len(args) and not args[j].startswith('--'):
        j += 1
    v = [int(x, 0) for x in args[i + 1:j]]; del args[i:j]; return v
win = 12
if '--window' in args:
    i = args.index('--window'); win = int(args[i + 1]); del args[i:i + 2]
want_rec, want_blk = take('--rec'), take('--blk')
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[3]
src = repo / 'v142' / 'subcpu' / 'kn5000_subprogram_v142.s'
L = src.read_bytes().split(b'\n')
label = re.compile(rb'^([A-Za-z_$][\w$]*):')
recload = re.compile(rb'\bld\s+(x[a-z]{2,3})\s*,\s*\((?:x[a-z]{2,3}\s*\+\s*(?:19|0x13)(?::8)?|x[a-z]{2,3}\s*\+\s*[a-z]{2})\)')
patch = re.compile(rb'Part_PatchRecord_Ptr')
blkload = re.compile(rb'\bld\s+(x[a-z]{2,3})\s*,\s*\(x[a-z]{2,3}\s*\+\s*(?:23|0x17)(?::8)?\)')
disp = re.compile(rb'\((x[a-z]{2,3})\s*\+\s*(0x[0-9a-fA-F]+|\d+)(?::8|:16)?\)')
def val(t):
    return int(t, 16) if t[:2] in (b'0x', b'0X') else int(t)
hits = collections.defaultdict(list)
rout = '?'
live = {}            # register -> (kind, lines left)
pending_patch = 0
for n, l in enumerate(L, 1):
    code = l.split(b';')[0]
    m = label.match(l)
    if m:
        rout = m.group(1).decode(); live = {}
    if patch.search(code):
        pending_patch = 4
    mb = blkload.search(code)
    mr = recload.search(code)
    newreg = None
    if mb:
        newreg = (mb.group(1), 'BLK')
    elif mr and (pending_patch or re.search(rb'\+\s*(?:19|0x13)', code)):
        newreg = (mr.group(1), 'REC')
    for reg, d in disp.findall(code):
        if reg in live and (not newreg or reg != newreg[0]):
            kind, _ = live[reg]
            hits[(kind, val(d))].append((n, rout, l.strip().decode('latin-1')[:100]))
    if newreg:
        live[newreg[0]] = (newreg[1], win)
    for r in list(live):
        k, left = live[r]
        if left <= 1:
            del live[r]
        else:
            live[r] = (k, left - 1)
    if pending_patch:
        pending_patch -= 1
asked = [('REC', o) for o in want_rec] + [('BLK', o) for o in want_blk]
keys = asked or sorted(hits)
for k in keys:
    for n, r, t in hits.get(k, []):
        print(f'{k[0]} +0x{k[1]:03x}  {src.relative_to(repo)}:{n}  {r} | {t}')
for k in keys:
    print(f'count {k[0]} +0x{k[1]:03x} {len(hits.get(k, []))}')
