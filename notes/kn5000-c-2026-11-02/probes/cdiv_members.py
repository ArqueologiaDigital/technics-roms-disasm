#!/usr/bin/env python3
"""cdiv_members.py TREE [BIN...] -- which C members hold the raw bytes of TREE's C-divergence json?

Compiles each C file with -g (into $TMPDIR), reads the top-level members of its `<name>_data`
object from DWARF (llvm-dwarfdump), maps every raw offset of the json to the member covering it and
prints per member: offset, name, type, size, raw bytes in it.  Reads only the json and the C (no ROM)."""
import collections, json, os, re, subprocess, sys, tempfile
ROOT = os.environ.get('REPO') or os.getcwd()
BIN = os.path.expanduser('~/compartilhado/llvm-project/build/bin')

def members(cfile):
    tmp = tempfile.mkdtemp(prefix='cdiv-')
    o = os.path.join(tmp, 'x.o')
    subprocess.run([BIN + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-g',
                    '-I', os.path.dirname(cfile), '-o', o, cfile], check=True)
    ld = cfile[:-2] + '_link.ld'
    elf = o
    if os.path.exists(ld):
        elf = os.path.join(tmp, 'x.elf')
        subprocess.run([BIN + '/ld.lld', '-T', ld, '-o', elf, o], check=True)
    dw = subprocess.run([BIN + '/llvm-dwarfdump', '--debug-info', elf], capture_output=True, text=True).stdout
    for f in os.listdir(tmp):
        os.remove(os.path.join(tmp, f))
    os.rmdir(tmp)
    # find the structure type whose name is the blob's typedef: take the largest structure
    blocks = re.split(r'\n(?=0x[0-9a-f]+:\s+DW_TAG_)', dw)
    best, cur, cursz, out = None, None, 0, {}
    structs = []
    for blk in blocks:
        if 'DW_TAG_structure_type' in blk.split('\n')[0]:
            m = re.search(r'DW_AT_byte_size\s+\((0x[0-9a-f]+)\)', blk)
            cur = [int(m.group(1), 16) if m else 0, []]
            structs.append(cur)
            continue
        if 'DW_TAG_member' in blk.split('\n')[0] and cur is not None:
            nm = re.search(r'DW_AT_name\s+\("([^"]+)"\)', blk)
            loc = re.search(r'DW_AT_data_member_location\s+\((0x[0-9a-f]+)\)', blk)
            ty = re.search(r'DW_AT_type\s+\(0x[0-9a-f]+ "([^"]*)"\)', blk)
            if nm and loc:
                cur[1].append((int(loc.group(1), 16), nm.group(1), ty.group(1) if ty else '?'))
        elif 'DW_TAG_structure_type' not in blk.split('\n')[0] and not blk.startswith(' ') and 'DW_TAG_member' not in blk:
            pass
    structs.sort(key=lambda s: -s[0])
    size, mem = structs[0]
    mem.sort()
    return size, mem

if __name__ == '__main__':
    tree = sys.argv[1]
    want = set(sys.argv[2:])
    d = json.load(open(os.path.join(ROOT, tree, 'maincpu', 'includes', '%s_c_divergence.json' % tree)))
    for name, ent in sorted(d.items(), key=lambda kv: -len(kv[1].get('raw', {}))):
        if want and name not in want:
            continue
        raw = ent.get('raw', {})
        if not raw:
            continue
        c = None
        for sub in ('ui_widgets', 'includes', 'audio', 'ui'):
            p = os.path.join(ROOT, tree, 'maincpu', sub, name[:-4] + '.c')
            if os.path.exists(p):
                c = p; break
        if c is None:
            print('##', name, len(raw), 'raw; C not found'); continue
        size, mem = members(c)
        offs = [m[0] for m in mem]
        import bisect
        per = collections.Counter()
        for o in map(int, raw):
            k = bisect.bisect_right(offs, o) - 1
            per[k] += 1
        print('## %s: %d raw, json size %d, C size %d, %d relocs' % (name, len(raw), ent['size'], size, len(ent.get('reloc', []))))
        for k, n in sorted(per.items()):
            a = mem[k][0]; e = mem[k + 1][0] if k + 1 < len(mem) else size
            print('   %6x %-44s %-26s %6d raw %4d' % (a, mem[k][1][:44], mem[k][2][:26], e - a, n))
