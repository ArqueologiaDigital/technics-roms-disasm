# name_fields.py -- every NAME FIELD of the CUSTOM bank of Felipe's KN7000 IC21, read from the records'
# structure rather than from text runs: per slot record (and complete stale record in a free block) the
# record's style name and four ONE TOUCH SETTING names (+0x04, +0x14..+0x44), the TCMP style record's name
# and its four variation-name fields, the TPAD bank name and the six pad names (layout:
# kn7000/notes/custom-data-ic21.md).  Each is classified: a KN5000 program v10 name, the same with ':'
# written '.', a KN7000 program 893 / table 80 name, a name of the nine factory sets, blank, or none.
# Question: did anyone type a name of their own into this unit's CUSTOM memory?
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
import gen_customdata_s as G  # noqa: E402  (kn7000/tools, on the path through _paths)

bank = _paths.chip()[0x20000:]
k5 = _paths.rd(_paths.KN5000_V10)
k7 = _paths.table80() + _paths.program('893')
sets = b''.join(_paths.factory_sets().values())


def records(d):
    """(kind, label, offset) of every slot record and complete stale record."""
    slots = {d[2 + 2 * s]: s for s in range(G.NSLOTS) if d[2 + 2 * s]}
    b = 1
    while b < G.NBLOCKS:
        try:
            size, _, _ = G.parse_record(d, b * G.BLOCK, 'kn7000')
        except ValueError:
            b += 1
            continue
        yield ('slot' if b in slots else 'stale'), (f'Slot{slots[b]:02d}' if b in slots else f'Stale{b:02d}'), b * G.BLOCK
        b += (size + G.BLOCK - 1) // G.BLOCK


def fields(d, base):
    size, _, secs = G.parse_record(d, base, 'kn7000')
    r = d[base:base + size]
    yield 'style name', r[4:20]
    for i in range(4):
        yield f'one touch setting {i + 1}', r[0x14 + 16 * i:0x24 + 16 * i]
    t = r[secs[1][0]:secs[1][0] + secs[1][1]]
    yield 'TCMP style', t[0x70:0x80]
    for i in range(4):
        yield f'TCMP variation-name field {i + 1}', t[0x80 + 16 * i:0x90 + 16 * i]
    p = r[secs[2][0]:secs[2][0] + secs[2][1]]
    yield 'TPAD bank', p[0x70:0x80]
    for i in range(6):
        yield f'TPAD pad {i + 1}', p[0xA0 + 0x60 * i:0xB0 + 0x60 * i]


cls = {}
for kind, lab, base in records(bank):
    for what, raw in fields(bank, base):
        w = raw.rstrip(b'\0 ').strip()
        if not w:
            c = 'blank'
        elif w in k5:
            c = 'KN5000 program'
        elif w.replace(b'.', b':') in k5:
            c = "KN5000 program, ':' written '.'"
        elif w in k7:
            c = 'KN7000 program/table'
        elif w in sets:
            c = 'factory KN7000 sets'
        else:
            c = 'none of these'
        cls.setdefault(c, []).append((kind, lab, what, w.decode('latin1')))
n = sum(len(v) for v in cls.values())
print(f'{n} name fields in {len({(k, l) for v in cls.values() for k, l, _, _ in v})} records')
for c, v in sorted(cls.items(), key=lambda kv: -len(kv[1])):
    names = sorted({x[3] for x in v})
    print(f'{c}: {len(v)} fields, {len(names)} distinct')
    if c != 'blank':
        print('   ', names)
