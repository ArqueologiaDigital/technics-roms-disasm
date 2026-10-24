"""Make LIB_CONVERT overrides-only (run from kn7000/).

- entries whose range ends at the next symbol-file boundary go: lib_split derives
  them from the symbol files;
- the nine names LIB_CONVERT alone held move into kn7000_manual.sym;
- each section comment of the old dict moves to LIB_SECTION_DOC under the first
  function after it (emitted above that function in program.s), so nothing it
  said is lost."""
import re
import sys
sys.path.insert(0, 'tools')
import gen_program_s as G

src = open('tools/gen_program_s.py').read()
a = src.index('LIB_CONVERT = {\n')
b = src.index('\n}\n', a) + 3
block = src[a:b]

d = open(G.ROM, 'rb').read()
sym = {G.BASE + off: nm for off, nm in G.load_syms(d)}
man = G.load_manual_syms()
lo, hi = G.LIB_CPU_BASE, G.LIB_DELTA + G.IMAGE_END
named = {}
for adr, nm in list(sym.items()) + list(man):
    if lo <= adr < hi and not nm.endswith('_entry'):
        named[nm] = adr
starts = sorted(set(named.values()) | {cs for cs, _ in G.LIB_CONVERT.values()})

keep, section, pending = [], {}, []
only_here = []
for line in block.split('\n')[1:-2]:
    st = line.strip()
    if st.startswith('#'):
        pending.append(re.sub(r'^#\s?', '', st))
        continue
    m = re.match(r'"(\w+)":\s*\((0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+)\),', st)
    if not m:
        assert not st, line
        continue
    nm, cs, ce = m.group(1), int(m.group(2), 16), int(m.group(3), 16)
    if pending:
        section[nm] = [re.sub(r'\s*-{3,}\s*$', '', re.sub(r'^-{2,}\s*', '', t)) for t in pending]
        pending = []
    nxt = next((x for x in starts if x > cs), hi)
    if nm not in named:
        only_here.append((cs, nm))
    if ce != nxt:
        keep.append(line)
assert not pending

new_block = ('LIB_CONVERT = {\n'
             '    # a library function\'s range when something that is not its code\n'
             '    # follows it before the next named function (the bytes after its end\n'
             '    # come out as an unnamed function): (CPU start, CPU end-exclusive)\n'
             + '\n'.join(keep) + '\n}\n')
sec = ['', '# Notes on groups of library functions, emitted above the first function of',
       '# each group (they were the section comments of the old explicit LIB_CONVERT).',
       'LIB_SECTION_DOC = {']
for nm, lines in section.items():
    sec.append(f'    "{nm}": (')
    for t in lines:
        sec.append(f'        {t!r},')
    sec.append('    ),')
sec.append('}\n')
src = src[:a] + new_block + '\n'.join(sec) + src[b:]
open('tools/gen_program_s.py', 'w').write(src)

# the nine names into kn7000_manual.sym, after TgPartElemEnabled_entry
mb = open('kn7000_manual.sym', 'rb').read()
anchor = b'0x4C00ED01  TgPartElemEnabled_entry\n'
i = mb.index(anchor) + len(anchor)
add = b''.join(b'0x%08X  %-23s ; SOUND EDIT flag refresher: copies one bit (or byte) of the part-setting record into the SOUND EDIT record (kn7000_mame notes/sound-edit-parameters.md section 3)\n'
               % (cs, nm.encode()) for cs, nm in sorted(only_here))
mb = mb[:i] + add + mb[i:]
open('kn7000_manual.sym', 'wb').write(mb)
print(f'kept {len(keep)} overrides, {len(section)} section notes, moved {len(only_here)} names to kn7000_manual.sym')
