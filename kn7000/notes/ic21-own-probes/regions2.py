# regions2.py -- the details: where the home-page block of Felipe's KN7000 IC21 differs from 04HPGINI.HMP,
# what the 0x6000 block holds, and what follows the factory-sized parts of the 0x4000 (USER MIDI SETTING)
# and 0x10000 (FAVORITES) blocks.  Adapted 2026-10-31 from the private ic21-analysis/regions2.py.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
d = _paths.chip()
h = _paths.initial_data('04HPGINI.HMP')
diff = [i for i in range(len(h)) if d[0x11000 + i] != h[i]]
runs = []
for i in diff:
    if runs and i <= runs[-1][1] + 8: runs[-1][1] = i
    else: runs.append([i, i])
print('HPG: differing bytes', len(diff), 'in', len(runs), 'runs (runs merged across gaps of up to 8 equal bytes)')
for a, b in runs:
    print(f'   +{a:#06x}..+{b:#06x}  dump {d[0x11000+a:0x11000+b+1].hex()}  factory {h[a:b+1].hex()}')
print('HPG: differing bytes inside the 0x18C-byte record:', sum(i < 0x18C for i in diff),
      '; inside the BMP (+0x18C..):', sum(i >= 0x18C for i in diff))
print('HPG: dump past the factory length (0x11000+0x4442 .. 0x15480):', d[0x11000 + len(h):0x15480].hex()[:200])
blk = d[0x6000:0x8000]
print('0x6000-0x7FFF all a5a55a5a:', blk == bytes.fromhex('a5a55a5a') * (len(blk) // 4))
print('UMD past 640 B (0x4280..0x4AC0):')
for o in range(0x4280, 0x4AC0, 0x90): print('  ', hex(o), d[o:o + 0x90].hex())
print('FAV past 408 B (0x10198..0x101C0):', d[0x10198:0x101C0].hex())
