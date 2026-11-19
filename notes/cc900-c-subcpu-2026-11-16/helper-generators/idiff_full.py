"""idiff_full.py LISTING CFILE FUNC...: instruction-level diff (MAME unidasm of both sides) of V4.23's bytes for FUNC,
as sub_v423.py builds them, against the ROM's.  QUESTION: where is the REAL first difference (not a branch
displacement), also in a switch that spans several labels?

Helper AL's fix of idiff.py (helper P's, 2026-11-19): idiff.py cut the ROM side at survey.tsv's size, which for a
switch whose case bodies sit under labels of their own is only the switch head; this script takes at least our
function's length.  Its scratch file goes to $TMPDIR/cc900-idiff/ (not helper P's scratch dir).
Environment: IDIFF=--full prints the whole diff (default: 2 lines of context).
Prints only MAME's disassembly of bytes, never listing text.

    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/idiff_full.py LISTING.asm FILE.c FUNC ...
"""
import sys, os, subprocess, re, difflib
HERE = os.path.dirname(os.path.abspath(__file__))
NOTES = os.path.dirname(HERE)
sys.path.insert(0, NOTES)
import sub_v423 as S
UNI = os.path.expanduser('~/compartilhado/tools/unidasm')
SCR = os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-idiff')
os.makedirs(SCR, exist_ok=True)
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
sz = [l.rstrip('\n').split('\t') for l in open(os.path.join(NOTES, 'survey.tsv'))]
sz = {x[3]: int(x[1]) for x in sz[1:] if len(x) > 3 and x[1].isdigit()}

def dis(b, base):
    p = os.path.join(SCR, 'idiff_%d.bin' % os.getpid())
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

full = '--full' in os.environ.get('IDIFF', '')
for fn in fns:
    print('########', rows.get(fn))
    mine = got.get(fn)
    if mine is None:
        print('  no bytes'); continue
    at = S.rom_offset(ref[fn])
    r = rom[at:at + max(len(mine), sz.get(fn, 0))]
    a = dis(mine, ref[fn]); b = dis(r, ref[fn])
    for l in difflib.unified_diff(a, b, 'ours', 'rom', n=999 if full else 2, lineterm=''):
        print('  ' + l)
