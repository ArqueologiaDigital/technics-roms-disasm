#!/usr/bin/env python3
"""cdiv_show.py TREE BIN MEMBER... -- print compiled vs needed bytes of C members (hex, diff marked).
needed = the tree's patched bin in includes/generated (the build applied the json); compiled = this C
compiled now (unpatched), in $TMPDIR."""
import os, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cdiv_members as CM
ROOT = os.environ.get('REPO') or os.getcwd()
BIN = CM.BIN

def compile_raw(tree, name):
    c = os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', name[:-4] + '.c')
    tmp = tempfile.mkdtemp(prefix='cdivc-')
    o = os.path.join(tmp, 'x.o'); out = os.path.join(tmp, 'x.bin')
    subprocess.run([BIN + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-I', os.path.dirname(c), '-o', o, c], check=True)
    ld = c[:-2] + '_link.ld'
    if os.path.exists(ld):
        e = os.path.join(tmp, 'x.elf')
        subprocess.run([BIN + '/ld.lld', '-T', ld, '-o', e, o], check=True); o2 = e
    else:
        o2 = o
    subprocess.run([BIN + '/llvm-objcopy', '-O', 'binary', '-j', '.text', o2, out], check=True)
    data = open(out, 'rb').read()
    for f in os.listdir(tmp):
        os.remove(os.path.join(tmp, f))
    os.rmdir(tmp)
    return data

def need(tree, name):
    return open(os.path.join(ROOT, tree, 'maincpu', 'includes', 'generated', name), 'rb').read()

if __name__ == '__main__':
    tree, name = sys.argv[1], sys.argv[2]
    c = os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', name[:-4] + '.c')
    size, mem = CM.members(c)
    have = compile_raw(tree, name); want = need(tree, name)
    idx = {m[1]: k for k, m in enumerate(mem)}
    for nm in sys.argv[3:]:
        k = idx[nm]; a = mem[k][0]; e = mem[k + 1][0] if k + 1 < len(mem) else size
        print('%s @%x (%s), %d B' % (nm, a, mem[k][2], e - a))
        for r in range(a, e, 16):
            h = have[r:min(e, r + 16)]; w = want[r:min(e, r + 16)]
            print('  C %s' % ' '.join('%02x' % x for x in h))
            print('  R %s' % ' '.join(('%02x' % y) if x != y else '..' for x, y in zip(h, w)))
