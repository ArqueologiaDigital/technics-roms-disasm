#!/usr/bin/env python3
"""rawsites.py TREE NEEDDIR [BIN...] -- each raw run of TREE's C-divergence json, with the top-level C
member that holds it (DWARF of the C compiled with -g), the offset inside the member, the C's compiled
bytes and the bytes TREE needs (NEEDDIR from ported_c_rebase.py --need)."""
import bisect, json, os, re, subprocess, sys, tempfile, shutil
sys.path.insert(0, 'scripts/converters')
import ported_c_rebase as R
BIN = os.path.expanduser('~/compartilhado/llvm-project/build/bin')


def members(tree, b):
    src, inc, ld = R.rule(tree, b)
    tmp = tempfile.mkdtemp(prefix='rawsites-')
    try:
        o = os.path.join(tmp, 'x.o')
        subprocess.run([BIN + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-g', '-w']
                       + (['-I', inc] if inc else []) + ['-o', o, src], check=True)
        elf = os.path.join(tmp, 'x.elf')
        subprocess.run([BIN + '/ld.lld'] + (['-T', ld] if ld else ['-e', '0', '--unresolved-symbols=ignore-all'])
                       + ['-o', elf, o], check=True)
        dw = subprocess.run([BIN + '/llvm-dwarfdump', '--debug-info', elf], capture_output=True, text=True).stdout
    finally:
        shutil.rmtree(tmp)
    blocks = re.split(r'\n(?=0x[0-9a-f]+:\s+DW_TAG_)', dw)
    structs, cur = [], None
    for blk in blocks:
        head = blk.split('\n')[0]
        if 'DW_TAG_structure_type' in head:
            m = re.search(r'DW_AT_byte_size\s+\((0x[0-9a-f]+)\)', blk)
            cur = [int(m.group(1), 16) if m else 0, []]
            structs.append(cur)
        elif 'DW_TAG_member' in head and cur is not None:
            nm = re.search(r'DW_AT_name\s+\("([^"]+)"\)', blk)
            loc = re.search(r'DW_AT_data_member_location\s+\((0x[0-9a-f]+)\)', blk)
            if nm and loc:
                cur[1].append((int(loc.group(1), 16), nm.group(1)))
    structs.sort(key=lambda s: -s[0])
    return src, (sorted(structs[0][1]) if structs else [])


tree, need = sys.argv[1], sys.argv[2]
want = set(sys.argv[3:])
j = json.load(open('%s/maincpu/includes/%s_c_divergence.json' % (tree, tree)))
for b, e in sorted(j.items()):
    raw = e.get('raw', {})
    if not raw or (want and b not in want):
        continue
    src, mem = members(tree, b)
    cur = R.compile_bin(tree, b)
    nd = open(os.path.join(need, b), 'rb').read()
    offs = [m[0] for m in mem]
    runs = []
    for o in sorted(map(int, raw)):
        if runs and o - runs[-1][1] <= 4:
            runs[-1][1] = o
        else:
            runs.append([o, o])
    print('== %s (%s) %d raw' % (b, os.path.relpath(src), len(raw)))
    for s, t in runs:
        k = bisect.bisect_right(offs, s) - 1
        mname, moff = (mem[k][1], mem[k][0]) if k >= 0 else ('?', 0)
        print('  %5x..%5x  %s+%d   cur %s  need %s' % (s, t, mname, s - moff, cur[s:t + 1].hex(' '), nd[s:t + 1].hex(' ')))
