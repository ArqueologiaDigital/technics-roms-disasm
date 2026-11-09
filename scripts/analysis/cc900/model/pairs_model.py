#!/usr/bin/env python3
"""Which firmware library pairs does our own toolchain rebuild from Toshiba's C, with no Toshiba program involved?

usage: python3 -I -B pairs_model.py PAIRS.tsv LIBCOPY [--personality kn5000] [--image NAME ...] [--show N]
For each source/binary pair of PAIRS.tsv (../pairs.py) whose source is a function the reference model compiles, the
model compiles LIBCOPY/libsrc/<SOURCE> as the library was built (cdecl, -O3 -XS, -DFLOAT; LIBCOPY as in
../results/model_ledger.md), to_llvm.py translates the function with asm900's encoding choices, llvm-mc assembles it
at the pair's address, and the bytes are compared with the image (the PT_LOAD segments of the byte-identical rebuild's
ELF, which make gate proves equal to the reference image).  Absolute operands resolve through the image's own
addresses: the other pairs' publics (pairs.tsv), the image's labels (llvm-nm), the library's data objects.
Prints a TSV row per pair: image, address, public, source, length, result (`MATCH`, `N diff first +OFF`, or why not
compared), then a summary.  Scratch files go to $TMPDIR.
"""
import os, re, sys, subprocess, tempfile, collections
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(HERE))))
sys.path.insert(0, os.path.join(R, 'notes/toshiba-runtime-xref-2026-11-08'))
import frontend, codegen, to_llvm
import xref_runtime as X

BIN = os.path.expanduser('~/compartilhado/llvm-project/build/bin')

def assemble(text, addr):
    """llvm-mc + ld.lld at addr; returns (bytes or None, stderr)"""
    with tempfile.TemporaryDirectory() as d:
        s, o, e, b = (os.path.join(d, n) for n in ('f.s', 'f.o', 'f.elf', 'f.bin'))
        open(s, 'w').write(text)
        r = subprocess.run([BIN + '/llvm-mc', '-triple=tlcs900', '-filetype=obj', s, '-o', o], capture_output=True, text=True)
        if r.returncode: return None, r.stderr
        r = subprocess.run([BIN + '/ld.lld', '-Ttext=0x%x' % addr, '--image-base=0', '-e', '0', o, '-o', e],
                           capture_output=True, text=True)
        if r.returncode: return None, r.stderr
        subprocess.run([BIN + '/llvm-objcopy', '-O', 'binary', '-j', '.text', e, b], check=True)
        return open(b, 'rb').read(), ''

def main():
    a = sys.argv[1:]
    pairs, lib = a[0], a[1]
    pers = a[a.index('--personality') + 1] if '--personality' in a else 'kn5000'
    show = int(a[a.index('--show') + 1]) if '--show' in a else 0
    want = [a[i + 1] for i, x in enumerate(a) if x == '--image']
    rows = [l.rstrip('\n').split('\t') for l in open(pairs)][1:]
    byimg = collections.defaultdict(list)
    for r in rows: byimg[r[0]].append(r)
    images = {n: elf for n, ref, elf in X.IMAGES}
    defines = ['__900__', '__LARGE__', 'FLOAT', '__CDECL=', '__ASM(x)=']
    units = {}
    tally = collections.Counter(); shown = 0
    print('image\taddress\tpublic\tsource\tlength\tresult')
    for img, rs in byimg.items():
        if want and img not in want: continue
        elf = images.get(img)
        if not elf or not os.path.exists(elf): continue
        segs = X.segments(elf)
        def read(addr, n):
            for va, b in segs:
                if va <= addr and addr + n <= va + len(b): return b[addr - va:addr - va + n]
            return None
        syms = {}
        for ad, names in X.symbols(elf).items():
            for n in names: syms.setdefault(n, ad)
        xr = os.path.join(R, 'notes/toshiba-runtime-xref-2026-11-08/results/xref.resolved.tsv')
        for f in (xr, xr.replace('resolved', 'inferred')):    # library pieces found in the image, and helpers named
            for l in open(f):                                  # by the calls to them (C9H_remlu in _ultoa)
                c = l.rstrip('\n').split('\t')
                if c[0] == img:
                    for n in c[2].split('|'): syms.setdefault(n.strip(), int(c[1], 16))
        for r in rs: syms[r[2].split()[0]] = int(r[1], 16)          # the pairs' own publics (_strlen, ___ctype)
        for r in rs:
            pub, src = r[2], r[4]
            if ' data' in pub or not pub.startswith(('_', '.')): continue
            path = os.path.join(lib, 'libsrc', src)
            if not os.path.exists(path): tally['no source'] += 1; continue
            if path not in units:
                try:
                    u = frontend.load(path, defines, [os.path.join(lib, 'inc')])
                    units[path] = codegen.compile_unit(u, opt='O3XS', adecl=False, personality=pers)
                except Exception as ex: units[path] = {'__error__': str(ex)}
            out = units[path]
            lines = codegen.FULL.get(pub) or out.get(pub)    # whole function (inline-assembly labels included), or data
            if not lines:                                  # ___ctype: a second public at __ctype's address
                twin = [q[2] for q in rs if q[1] == r[1] and q[2] != pub and (codegen.FULL.get(q[2]) or out.get(q[2]))]
                if twin:
                    tally['alias'] += 1; print('\t'.join([img, r[1], pub, src, '-', 'alias of %s' % twin[0]])); continue
            if not lines or not lines[0].endswith(':'):
                res = 'model: ' + (lines[0][:40] if lines else 'no function')
                tally['model cannot'] += 1; print('\t'.join([img, r[1], pub, src, '-', res])); continue
            consts, _ = to_llvm.split_consts(lines)
            PH = 0xfffff0                                  # FP constants: the linker placed them; take each address from
            for k, lab in enumerate(consts): syms[lab] = PH - 8 * k   # the image's own operand, check the double there
            statics = {}                                   # a static (no public symbol): placed by the linker; its
            text = None                                    # address is taken from the image's own operand below
            for _ in range(8):
                try: text = '\t.text\n' + '\n'.join(to_llvm.translate_function(pub, lines, syms)) + '\n'; break
                except KeyError as ex:
                    name = str(ex).strip("'").replace('no address for ', '').strip()
                    if name in syms or not name.startswith('_'): text = None; break
                    statics[name] = (0xf0 - len(statics)) << 16 | (0xfe10 - 0x111 * len(statics)); syms[name] = statics[name]
            if text is None:
                tally['unresolved symbol'] += 1; print('\t'.join([img, r[1], pub, src, '-', 'unresolved']))
                for n_ in statics: syms.pop(n_, None)
                continue
            if '; untranslated' in text:
                bad = [l for l in text.split('\n') if 'untranslated' in l][0].strip()
                tally['untranslated'] += 1; print('\t'.join([img, r[1], pub, src, '-', bad])); continue
            addr = int(r[1], 16)
            text = to_llvm.relax(text, lambda t: assemble(t, addr)[1])
            code, err = assemble(text, addr)
            bad_const = None
            if consts and code is not None:
                import struct
                for lab in consts:
                    ph = syms[lab].to_bytes(3, 'little'); at = code.find(ph)
                    rb = read(addr + at, 3) if at >= 0 else None
                    real = int.from_bytes(rb, 'little') if rb else None
                    wantb = struct.pack('<d' if consts[lab][0] == 'fdatad' else '<f', float(consts[lab][1]))
                    if os.environ.get('PM_DEBUG'): sys.stderr.write('%s %s at=%s real=%s\n' % (pub, lab, at, hex(real) if real else None))
                    if real is None or read(real, len(wantb)) != wantb: bad_const = lab; break
                    text = text.replace('0x%x' % syms[lab], '0x%x' % real); syms[lab] = real
                code, err = assemble(text, addr)
            bad_static = None
            if statics and code is not None:
                for name, ph in statics.items():
                    pat = ph.to_bytes(3, 'little'); addrs = set(); at = code.find(pat)
                    while at >= 0:
                        rb = read(addr + at, 3)
                        if rb: addrs.add(int.from_bytes(rb, 'little'))
                        at = code.find(pat, at + 1)
                    pp = bytes([0x0b, (ph >> 16) & 0xff, (ph >> 24) & 0xff, 0x0b, ph & 0xff, (ph >> 8) & 0xff])
                    at = code.find(pp)                     # pushw hi / pushw lo of the address
                    while at >= 0:
                        rb = read(addr + at, 6)
                        if rb and rb[0] == 0x0b and rb[3] == 0x0b:
                            addrs.add((rb[1] | rb[2] << 8) << 16 | rb[4] | rb[5] << 8)
                        at = code.find(pp, at + 1)
                    if len(addrs) != 1: bad_static = name; break     # every use must agree on one address
                    real = addrs.pop(); text = text.replace('0x%x' % ph, '0x%x' % real)
                    text = text.replace('pushw 0x%x' % ((ph >> 16) & 0xffff), 'pushw 0x%x' % ((real >> 16) & 0xffff))
                    text = text.replace('pushw 0x%x' % (ph & 0xffff), 'pushw 0x%x' % (real & 0xffff))
                code, err = assemble(text, addr)
            for n_ in statics: syms.pop(n_, None)
            if bad_static:
                tally['differs'] += 1; print('\t'.join([img, r[1], pub, src, '-', 'static %s: uses disagree' % bad_static]))
                continue
            if bad_const:
                tally['differs'] += 1; print('\t'.join([img, r[1], pub, src, '-', 'constant %s not in the image' % bad_const]))
                continue
            if code is None:
                tally['assembler'] += 1
                print('\t'.join([img, r[1], pub, src, '-', 'llvm: ' + err.strip().splitlines()[0][:90]])); continue
            ref = read(addr, len(code))
            if ref is None: tally['outside image'] += 1; continue
            diff = [i for i in range(len(code)) if code[i] != ref[i]]
            if not diff: res = 'MATCH'; tally['MATCH'] += 1
            else:
                res = '%d diff first +%d' % (len(diff), diff[0]); tally['differs'] += 1
                if shown < show:
                    shown += 1
                    sys.stderr.write('---- %s %s\n%s\nours %s\nrom  %s\n' % (img, pub, text, code.hex(' '), ref.hex(' ')))
            print('\t'.join([img, r[1], pub, src, str(len(code)), res]))
    print('# ' + ', '.join('%s %d' % kv for kv in tally.most_common()))

if __name__ == '__main__':
    main()
