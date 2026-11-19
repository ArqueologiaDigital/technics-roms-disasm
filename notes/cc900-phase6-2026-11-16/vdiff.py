#!/usr/bin/env python3
"""Where does V4.23's code for one probe function first differ from the ROM, and what are the instructions there?

One function of a V4.23 listing, translated the asm_vs_rom.py way (cc900-name aliases and 31-character cuts
resolved), assembled, and printed beside the ROM: offsets, our bytes, the ROM's bytes, the translated instruction,
`!` on the rows that differ.  lane_p6 used it on 2026-11-19 to find the one-spot retries (DrawStringCentered's
early `lda xde`, VwBoxProc's extz, the register-order spots).
The printed instructions are a translation of Toshiba's listing: read them, never paste them into the repository.
usage (from scripts/analysis/cc900):
    python3 -B ../../../notes/cc900-phase6-2026-11-16/vdiff.py LISTING.asm FUNC [--cfile C] [--ctx N]"""
import os, sys, re, subprocess
HERE = os.getcwd()
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, 'model'))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import listing, to_llvm, check_bytes, asm_vs_rom
import cc900_firmware_c as fw

a = sys.argv[1:]
ctx = int(a[a.index('--ctx') + 1]) if '--ctx' in a else 12
tree = os.path.join(REPO, 'v10/maincpu')
ref = check_bytes.load_reference(os.path.join(REPO, 'symbols/maincpu_v10_symbols_reference.txt'))
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_v10_program.rom'), 'rb').read()
module, places = set(), {}
for i, x in enumerate(a):
    if x == '--cfile':
        places.update(fw.data_map(a[i + 1])); module |= fw.module_names(a[i + 1])
to_llvm.MODULE = module or None
alias = {}
for i, x in enumerate(a):
    if x == '--cfile':
        for m in re.finditer(r'cc900-name:\s*(\w+)=(\w+)', open(a[i + 1], encoding='latin-1').read()):
            alias[m.group(1)] = m.group(2)
fw.RUNTIME.update(fw.runtime_names(tree))
lmap = {}
for i, x in enumerate(a):
    if x == '--cfile':
        lmap.update(fw.label_map(a[i + 1]))


class CutNames(fw.Names):
    def resolve(self, n, depth=0):
        if n in lmap:
            n = lmap[n]
        r = super().resolve(n, depth)
        b = n.lstrip('_.')
        if r[0] is None and len(b) == 31:
            full = [k for k in list(self.values) + list(self.labels) if len(k) > 31 and k[:31] == b]
            if len(set(full)) == 1:
                return super().resolve(full[0], depth)
        return r


names = CutNames(fw.tree_values(tree), ref)
to_llvm.SPELL = None
text = open(a[0], encoding='latin-1').read()
to_llvm.WIDTHS = listing.attributes(text)
for name, lines in listing.split(text).items():
    bare = name.lstrip('_.')
    bare = alias.get(bare, bare)
    if bare != a[1] and bare != a[1][:31]:
        continue
    if bare not in ref:
        bare = a[1]
    consts, _ = to_llvm.split_consts(lines)
    pl = places.get(bare, {})
    to_llvm.DATA = {c: '0x%x' % ref[pl[k]] for k, c in enumerate(consts, 1) if k in pl and pl[k] in ref}
    body = [l for l in to_llvm.translate_function(name, lines, names) if l not in ('\t.globl %s' % bare, bare + ':')]
    fa = ref[bare]
    targets = sorted({int(m.group(1), 16) for m in re.finditer(r'__cc900_at_([0-9a-f]+)', '\n'.join(body))})
    sets = ''.join('\t.set __cc900_at_%x, .Lcc900_fn0 + %d\n' % (t, t - fa) for t in targets)
    body = asm_vs_rom.place_locals(body, fa)
    src = '\t.text\n\t.globl %s\n%s:\n.Lcc900_fn0:\n%s\n%s' % (bare, bare, '\n'.join(body), sets)
    sp = os.path.join(os.environ.get('TMPDIR', '.'), 'vdiff.s')
    open(sp, 'w').write(src)
    mine = check_bytes.assemble(src)[bare]
    r = rom[fa - 0xe00000:fa - 0xe00000 + len(mine)]
    first = next((i for i in range(len(mine)) if mine[i] != r[i]), None)
    print('%s %d B, first diff %s' % (bare, len(mine), first))
    out = subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-mc'), '-triple=tlcs900', '-show-encoding', sp],
                         capture_output=True, text=True).stdout
    off = 0
    rows = []
    for l in out.splitlines():
        m = re.search(r'encoding: \[([^\]]*)\]', l)
        if m:
            n = len(m.group(1).split(','))
            rows.append((off, n, l.split(';')[0].strip()))
            off += n
        elif re.match(r'^\S+:', l.strip()):
            rows.append((off, 0, l.strip()))
    for o, n, ins in rows:
        if first is None or abs(o - first) <= ctx * 3:
            mark = '!' if n and mine[o:o + n] != r[o:o + n] else ' '
            print('%s %4d  %-22s %-22s %s' % (mark, o, mine[o:o + n].hex(' '), r[o:o + n].hex(' '), ins))
