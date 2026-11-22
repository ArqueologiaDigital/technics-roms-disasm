#!/usr/bin/env python3
"""Step I0 of the feedback plan (section 13): an inventory of the cc900 compiler passes we hold.

QUESTION ANSWERED: before any disassembly (I1), what are thc1 and thc2 in each dev-kit build: which copies are the
same file, how big each is, how it was linked (PE header, sections, imported DLLs and functions, a debug directory
or COFF symbols), what its banner calls the pass, and how big the job is (code bytes, call / ret counts as a rough
function count).  Also a few marker strings that say which pass does what (TLCS-900 register names in the code
generator, C keywords and diagnostics in the front end): only their COUNTS are printed, never Toshiba's text, except
the pass name in the banner ("Parser", "Code Generator").

Pure Python (no pefile / capstone): the PE32 header is parsed by hand.  Static reading only; nothing is run.

Usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/i0_inventory.py [ARCHIVE_ROOT]
ARCHIVE_ROOT defaults to ~/compartilhado/upstream_repos/file_archive.  Prints Markdown.
"""
import collections
import datetime
import glob
import hashlib
import os
import re
import struct
import sys

ROOT = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else '~/compartilhado/upstream_repos/file_archive')
REGS = [b'XWA', b'XBC', b'XDE', b'XHL', b'XIX', b'XIY', b'XIZ', b'XSP']
KEYWORDS = [b'typedef', b'struct', b'union', b'switch', b'register', b'volatile']


def pe(data):
    """the PE32 facts of one image: header fields, sections, imports"""
    off = struct.unpack_from('<I', data, 0x3c)[0]
    assert data[off:off + 4] == b'PE\0\0'
    machine, nsec, stamp, symptr, nsym, optsz, chars = struct.unpack_from('<HHIIIHH', data, off + 4)
    opt = off + 24
    magic, lmaj, lmin = struct.unpack_from('<HBB', data, opt)
    assert magic == 0x10b
    sizecode, = struct.unpack_from('<I', data, opt + 4)
    entry, = struct.unpack_from('<I', data, opt + 16)
    base, = struct.unpack_from('<I', data, opt + 28)
    ndirs, = struct.unpack_from('<I', data, opt + 92)
    dirs = [struct.unpack_from('<II', data, opt + 96 + 8 * i) for i in range(ndirs)]
    secs = []
    for i in range(nsec):
        s = off + 24 + optsz + 40 * i
        name = data[s:s + 8].rstrip(b'\0').decode('latin-1')
        vsize, va, rsize, rptr = struct.unpack_from('<IIII', data, s + 8)
        secs.append((name, va, vsize, rptr, rsize))

    def rva2off(rva):
        for name, va, vsize, rptr, rsize in secs:
            if va <= rva < va + max(vsize, rsize):
                return rptr + rva - va
        return None

    def cstr(o):
        return data[o:data.index(b'\0', o)].decode('latin-1')

    imports = collections.OrderedDict()
    if len(dirs) > 1 and dirs[1][0]:
        o = rva2off(dirs[1][0])
        while True:
            oft, _, _, name_rva, ft = struct.unpack_from('<IIIII', data, o)
            if not name_rva:
                break
            dll = cstr(rva2off(name_rva)).upper()
            funcs = []
            t = rva2off(oft or ft)
            while True:
                v, = struct.unpack_from('<I', data, t)
                if not v:
                    break
                funcs.append('#%d' % (v & 0xffff) if v & 0x80000000 else cstr(rva2off(v) + 2))
                t += 4
            imports[dll] = funcs
            o += 20
    debug = bool(len(dirs) > 6 and dirs[6][0])
    return dict(stamp=stamp, symptr=symptr, nsym=nsym, linker='%d.%02d' % (lmaj, lmin), sizecode=sizecode,
                entry=entry, base=base, secs=secs, imports=imports, debug=debug)


def code_counts(data, info):
    """rough i386 counts in the code section(s): near `ret` (c3 / c2 nn nn) and `push ebp; mov ebp,esp` frames"""
    rets = frames = 0
    for name, va, vsize, rptr, rsize in info['secs']:
        if name.lower() not in ('.text', 'code', 'text'):
            continue
        blob = data[rptr:rptr + min(vsize, rsize)]
        frames += blob.count(b'\x55\x8b\xec')
        rets += blob.count(b'\xc3') + blob.count(b'\xc2')
    return frames, rets


def table(head, rows):
    w = [max(len(str(x)) for x in c) for c in zip(head, *rows)]
    out = ['| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (n + 2) for n in w) + '|']
    out += ['| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)


def main():
    paths = sorted(p for p in glob.glob(os.path.join(ROOT, '**', '*'), recursive=True)
                   if re.fullmatch(r'thc[12]\.exe', os.path.basename(p), re.I) and '/.git/' not in p)
    by_hash = collections.OrderedDict()
    for p in paths:
        h = hashlib.sha256(open(p, 'rb').read()).hexdigest()
        by_hash.setdefault(h, []).append(os.path.relpath(p, ROOT))
    rows, secrows, improws, markrows = [], [], [], []
    for h, ps in by_hash.items():
        data = open(os.path.join(ROOT, ps[0]), 'rb').read()
        info = pe(data)
        pas = os.path.basename(ps[0]).lower().split('.')[0]
        role = re.search(rb'TLCS-900 C Compiler - ([A-Za-z ]+?) \(32\)', data)
        role = role.group(1).decode() if role else '-'
        stamp = datetime.datetime.fromtimestamp(info['stamp'], datetime.timezone.utc).strftime('%Y-%m-%d')
        frames, rets = code_counts(data, info)
        tag = h[:12]
        rows.append((tag, pas, len(data), stamp, info['linker'],
                     role, 'yes' if info['debug'] else 'no', info['nsym'], len(ps), ps[0]))
        secrows.append((tag, pas, ', '.join('%s %d' % (s[0], s[2]) for s in info['secs']), '0x%x' % info['base'],
                        '0x%x' % info['entry']))
        improws.append((tag, pas, '; '.join('%s %d' % (d, len(f)) for d, f in info['imports'].items())))
        markrows.append((tag, pas, sum(data.count(r) for r in REGS), sum(data.count(k) for k in KEYWORDS),
                         frames, rets))
    print('## I0: the thc1 / thc2 builds held (`%s`)\n' % ROOT.replace(os.path.expanduser('~'), '~'))
    print(table(('sha256[:12]', 'pass', 'bytes', 'PE stamp', 'linker', 'banner says', 'debug dir', 'COFF syms',
                 'copies', 'first copy'), rows))
    print('\n### Sections (name and virtual size), image base, entry point\n')
    print(table(('sha256[:12]', 'pass', 'sections', 'base', 'entry'), secrows))
    print('\n### Imports (DLL and number of functions)\n')
    print(table(('sha256[:12]', 'pass', 'imports'), improws))
    print('\n### Markers (counts only)\n')
    print(table(('sha256[:12]', 'pass', 'TLCS-900 32-bit register names', 'C keywords', '`push ebp; mov ebp,esp`',
                 'c3 / c2 bytes in code'), markrows))
    print('\nregister names suggest the code generator; C keywords the front end.  Frame and ret byte counts are '
          'upper bounds on the function count (the bytes also occur inside other instructions).')
    print('\n### Every copy\n')
    print(table(('sha256[:12]', 'path'), [(h[:12], p) for h, ps in by_hash.items() for p in ps]))


if __name__ == '__main__':
    main()
