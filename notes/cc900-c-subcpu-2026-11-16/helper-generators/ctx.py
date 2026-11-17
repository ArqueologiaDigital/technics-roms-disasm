#!/usr/bin/env python3
"""scratch (helper S): idiff.py with context.  Prints, for each difference between our V4.23 bytes and the ROM
(unidasm text of both, addresses dropped), N equal instructions before and after.
usage (from the csub repo root): python3 -B ctx.py LISTING FUNCTION [--cfile C] [--n N]"""
import difflib, os, re, subprocess, sys
REPO = os.getcwd()
sys.path.insert(0, os.path.join(REPO, 'notes', 'cc900-c-subcpu-2026-11-16'))
import sub_v423 as S
import check_bytes

a = sys.argv[1:]
cfiles = [a[i + 1] for i, x in enumerate(a) if x == '--cfile']
N = int(a[a.index('--n') + 1]) if '--n' in a else 6
S.KEEP_BYTES = {}
S.compare(a[0], 'v142/subcpu', cfiles)
ours = S.KEEP_BYTES[a[1]]
ref = check_bytes.load_reference(os.path.join(REPO, 'symbols', 'subcpu_symbols_reference.txt'))
rom = open(os.path.join(REPO, 'original_ROMs', 'kn5000_subprogram_v142.rom'), 'rb').read()
addr = ref[a[1]] if not isinstance(ref[a[1]], tuple) else ref[a[1]][0]
off = S.rom_offset(addr)
tmp = os.environ['TMPDIR']
romlen = int(a[a.index('--romlen') + 1]) if '--romlen' in a else len(ours)


def dis(tag, data):
    p = os.path.join(tmp, 'ctx_%s.bin' % tag)
    open(p, 'wb').write(data)
    r = subprocess.run([os.path.expanduser('~/compartilhado/tools/unidasm'), p, '-arch', 'tlcs900', '-basepc', '0'],
                       capture_output=True, text=True)
    out = []
    for l in r.stdout.splitlines():
        m = re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)', l)
        if not m:
            continue
        ins = re.sub(r'0x[0-9a-f]{4,}', 'ADDR', m.group(3).strip())
        out.append((int(m.group(1), 16), ins))
    return out


o = dis('ours', ours)
r = dis('rom', rom[off:off + romlen])
print('ours %d B, rom slice %d B' % (len(ours), romlen))
sm = difflib.SequenceMatcher(a=[x[1] for x in o], b=[x[1] for x in r], autojunk=False)
for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag == 'equal':
        continue
    print('--- %s ours +%d / rom +%d' % (tag, o[i1][0] if i1 < len(o) else -1, r[j1][0] if j1 < len(r) else -1))
    for k in range(max(0, j1 - N), j1):
        print('        ' + r[k][1])
    for k in range(i1, i2):
        print('  ours: ' + o[k][1])
    for k in range(j1, j2):
        print('  rom : ' + r[k][1])
    for k in range(j2, min(len(r), j2 + N)):
        print('        ' + r[k][1])
