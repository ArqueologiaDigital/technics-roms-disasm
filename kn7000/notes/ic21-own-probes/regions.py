# regions.py -- Felipe's KN7000 IC21 read, region by region below the CUSTOM bank (0x20000), against the
# factory Initial Data files of the idd7000 floppy: which parts are factory content, which are not.
# Adapted 2026-10-31 from the private ic21-analysis/regions.py (paths only; see _paths.py).
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
d = _paths.chip()
sw = lambda b: bytes(b[i ^ 1] for i in range(len(b) - len(b) % 2))


def spans(buf):
    out, i = [], 0
    while i < len(buf):
        if buf[i] == 0xFF:
            i += 1; continue
        j = i
        while j < len(buf) and buf[j:j + 64] != b'\xff' * len(buf[j:j + 64]): j += 64
        out.append((i, j)); i = j
    return out


def exact(buf, a, b):
    """[a, b) trimmed to its first and last non-0xFF byte."""
    while a < b and buf[a] == 0xFF: a += 1
    while b > a and buf[b - 1] == 0xFF: b -= 1
    return a, b


print('non-blank spans below 0x20000 (64-byte steps):', [(hex(a), hex(b)) for a, b in spans(d[:0x20000])])
print('the same spans, trimmed to their first and last non-0xFF byte:',
      [(hex(a), hex(b)) for a, b in (exact(d, a, b) for a, b in spans(d[:0x20000]))])
for off, n in ((0x4000, '02UMDINI.MD'), (0x10000, '03FAVINI.FAV'), (0x11000, '04HPGINI.HMP')):
    f = _paths.initial_data(n); seg = d[off:off + len(f)]
    for tag, g in (('as is', f), ('byte-swapped', sw(f))):
        eq = sum(x == y for x, y in zip(seg, g))
        print(f'{off:#07x} vs {n} ({len(f)} B, {tag}): {eq} bytes equal ({100*eq/len(f):.1f}%)')
    print('   dump :', seg[:48].hex()); print('   file :', f[:48].hex())
print('0x6000 block head:', d[0x6000:0x6040].hex())
print('0x6000 block strings:', [s.decode() for s in re.findall(rb'[ -~]{4,}', d[0x6000:0x8000])][:30])
print('0x4000 block strings:', [s.decode() for s in re.findall(rb'[ -~]{4,}', d[0x4000:0x4B00])][:30])
