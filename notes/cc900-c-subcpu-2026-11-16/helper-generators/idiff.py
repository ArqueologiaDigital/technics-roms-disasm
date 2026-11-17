"""idiff.py LISTING CFILE FUNC...: instruction-level diff (MAME unidasm of both sides) of V4.23's bytes for FUNC, as
sub_v423.py builds them, against the ROM's.  QUESTION: where is the REAL first difference (not a branch displacement)?
Prints only MAME's disassembly of bytes, never listing text."""
import sys, os, subprocess, re, difflib
sys.path.insert(0, '/home/fsanches/compartilhado/disasm-lanes/csub/notes/cc900-c-subcpu-2026-11-16')
import sub_v423 as S
UNI = os.path.expanduser('~/compartilhado/tools/unidasm')
SCR = '/home/fsanches/compartilhado/tmp/cc900-tab/lane_sub/P/'
lst, cfile = sys.argv[1:3]
fns = sys.argv[3:]
orig = S.check_bytes.assemble
got = {}
def spy(src):
    r = orig(src); got.update(r); return r
S.check_bytes.assemble = spy
rows = {r[0]: r for r in S.compare(lst, cfiles=[cfile])}
romf, symf = S.TREES['v142/subcpu']
rom = open(os.path.join(S.REPO, romf), 'rb').read()
ref = S.check_bytes.load_reference(os.path.join(S.REPO, symf))

def dis(b, base):
    p = SCR + 'idiff.bin'
    open(p, 'wb').write(b)
    out = subprocess.run([UNI, p, '-arch', 'tlcs900', '-basepc', hex(base)], capture_output=True, text=True).stdout
    res = []
    for l in out.split('\n'):
        m = re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)', l)
        if not m:
            continue
        a = int(m.group(1), 16); t = m.group(3)
        def rel(mm):
            v = int(mm.group(1), 16)
            if base <= v <= base + len(b):
                return 'L%+d' % (v - a)
            return mm.group(0)
        if re.match(r'(jr|jrl|jp|djnz|calr)', t):
            t = re.sub(r'0x([0-9a-f]{6})', rel, t)
        res.append(t)
    return res

for fn in fns:
    print('########', rows.get(fn))
    mine = got.get(fn)
    if mine is None:
        print('  no bytes'); continue
    at = S.rom_offset(ref[fn])
    full = '--full' in os.environ.get('IDIFF', '')
    sz = [l.split('\t') for l in open('/home/fsanches/compartilhado/tmp/cc900-tab/lane_sub/survey.tsv')]
    sz = {x[3]: x[1] for x in sz if len(x) > 3}
    r = rom[at:at + int(sz[fn])]
    a = dis(mine, ref[fn]); b = dis(r, ref[fn])
    n = 0 if full else 2
    for l in difflib.unified_diff(a, b, 'ours', 'rom', n=n if not full else 999, lineterm=''):
        print('  ' + l)
