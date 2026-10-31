# custom.py -- the CUSTOM STYLE bank of Felipe's KN7000 IC21 (chip 0x20000..) against the nine factory
# sets: how much of it is found in any of them (aligned 64 KB sectors; 256-byte chunks anywhere), and its
# text that none has.  Adapted 2026-10-31 from the private ic21-analysis/custom.py.
import os, re, sys, hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
d = _paths.chip()[0x20000:]
sets = _paths.factory_sets()
print('header dump   :', d[:64].hex())
print('header ctmini :', sets['01ctmini'][:64].hex())
print('aligned 64 KB sectors (chip offset): which known sets hold the same sector')
for s in range(0, len(d), 0x10000):
    blk = d[s:s + 0x10000]
    same = [n for n, b in sets.items() if b[s:s + 0x10000] == blk]
    blank = blk == b'\xff' * len(blk)
    print(f'   {0x20000 + s:#08x}  {"blank" if blank else ""} {", ".join(same) if same else ("-" if not blank else "")}')
C = 256
known = set()
for b in sets.values():
    for i in range(0, len(b) - C + 1, 16):          # any 16-byte-aligned 256-byte chunk of any set
        known.add(hashlib.sha1(b[i:i + C]).digest())
end = len(d.rstrip(b'\xff'))
n = tot = 0
for i in range(0, end, C):
    tot += 1; n += hashlib.sha1(d[i:i + C]).digest() in known
print(f'256-byte chunks of the used part (0x20000..{0x20000 + end:#x}): {n} of {tot} occur in a known set ({100*n/tot:.1f}%)')
allstr = set()
for b in sets.values(): allstr |= set(re.findall(rb'[ -~]{6,}', b))
mine = [s for s in re.findall(rb'[ -~]{6,}', d[:end]) if s not in allstr]
print(f'text strings (6+ chars) in the dump: {len(set(re.findall(rb"[ -~]{6,}", d[:end])))} distinct; not in any known set: {len(set(mine))}')
for s in sorted(set(mine))[:80]: print('   ', s.decode())
