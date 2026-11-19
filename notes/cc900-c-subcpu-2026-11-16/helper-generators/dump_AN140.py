"""dump_AN140.py LISTING CFILE FUNC: dump_AN.py against sub-CPU payload v1.40 instead of v1.42: the ROM is
original_ROMs/kn5000_subprogram_v140.rom and FUNC's address comes from symbols/subcpu_v140_symbols_reference.txt
(sub_v423.py's TREES['v140/subcpu']); the listing's bytes are built with tree='v140/subcpu', as
`sub_v423.py one LISTING --tree v140/subcpu` does.  Everything else as dump_AN.py (helper AN, 2026-11-19, lane_sub
round 28, for the v1.40 form of Audio_Process_DSP, whose v1.40 body is 1,491 B: set ROMLEN=1491).

    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/dump_AN140.py LISTING.asm FILE.c FUNC  (repository root)

dump_AN.py's own description follows.

dump_AN.py LISTING CFILE FUNC: write MAME's disassembly of V4.23's bytes for FUNC (as sub_v423.py builds them) and
of the ROM's bytes at FUNC's address to two text files, one instruction per line, for a side-by-side comparison
(`diff -y`).

QUESTION ANSWERED: in a LONG function (a switch over many labels, e.g. Audio_Process_DSP, 1,409 B), which
instructions really differ from the ROM's?  difflib's unified diff (idiff.py) loses its alignment after the first
long mismatch; a side-by-side diff of the two full disassemblies stays aligned, and the jump lines whose only
difference is the displacement are easy to filter out.

Helper AN, 2026-11-19 (lane_sub round 24), from helper P's idiff.py.  Branch targets inside the function are
printed relative (L+N), so a byte shift elsewhere does not change other lines.  Prints only MAME's disassembly of
bytes, never listing text.

Environment:
    ROMLEN   number of ROM bytes to disassemble (default: the larger of survey.tsv's size and our length; survey.tsv
             gives only the first label's size, the switch head)
    DUMPTAG  tag in the output names (default x)
    DUMPDIR  output directory (default $TMPDIR/cc900-idiff)
Output: DUMPDIR/ours_<TAG>.txt, DUMPDIR/rom_<TAG>.txt.

    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/dump_AN.py LISTING.asm FILE.c FUNC    (repository root)
    diff -y -W 110 $TMPDIR/cc900-idiff/ours_x.txt $TMPDIR/cc900-idiff/rom_x.txt | grep '[|<>]'
"""
import sys, os, subprocess, re
HERE = os.path.dirname(os.path.abspath(__file__))
NOTES = os.path.dirname(HERE)
sys.path.insert(0, NOTES)
import sub_v423 as S
UNI = os.path.expanduser('~/compartilhado/tools/unidasm')
OUT = os.environ.get('DUMPDIR') or os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')),
                                                'cc900-idiff')
os.makedirs(OUT, exist_ok=True)
if len(sys.argv) != 4:
    sys.exit(__doc__)
lst, cfile, fn = sys.argv[1:4]
orig = S.check_bytes.assemble
got = {}


def spy(src):
    r = orig(src)
    got.update(r)
    return r


S.check_bytes.assemble = spy
TREE = 'v140/subcpu'
rows = {r[0]: r for r in S.compare(lst, tree=TREE, cfiles=[cfile])}
romf, symf = S.TREES[TREE]
rom = open(os.path.join(S.REPO, romf), 'rb').read()
ref = S.check_bytes.load_reference(os.path.join(S.REPO, symf))


def dis(b, base):
    p = os.path.join(OUT, 'dump_AN.bin')
    open(p, 'wb').write(b)
    out = subprocess.run([UNI, p, '-arch', 'tlcs900', '-basepc', hex(base)], capture_output=True, text=True).stdout
    res = []
    for l in out.split('\n'):
        m = re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)', l)
        if not m:
            continue
        a = int(m.group(1), 16)
        t = m.group(3)

        def rel(mm):
            v = int(mm.group(1), 16)
            if base <= v <= base + len(b):
                return 'L%+d' % (v - a)
            return mm.group(0)
        if re.match(r'(jr|jrl|jp|djnz|calr)', t):
            t = re.sub(r'0x([0-9a-f]{6})', rel, t)
        res.append(t)
    return res


print('########', rows.get(fn))
mine = got.get(fn)
if mine is None:
    sys.exit('no bytes for %s' % fn)
sz = {}
for l in open(os.path.join(NOTES, 'survey.tsv')):
    x = l.rstrip('\n').split('\t')
    if len(x) > 3:
        sz[x[3]] = x[1]
n = int(os.environ.get('ROMLEN') or max(int(sz.get(fn, 0)), len(mine)))
at = S.rom_offset(ref[fn])
tag = os.environ.get('DUMPTAG', 'x')
a = dis(mine, ref[fn])
b = dis(rom[at:at + n], ref[fn])
open(os.path.join(OUT, 'ours_%s.txt' % tag), 'w').write('\n'.join(a) + '\n')
open(os.path.join(OUT, 'rom_%s.txt' % tag), 'w').write('\n'.join(b) + '\n')
print('ours: %d instructions (%d B); rom: %d instructions (%d B); in %s' % (len(a), len(mine), len(b), n, OUT))
