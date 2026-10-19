#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_real_dump.py DIR [DIR2] [--pass4 P4DIR] [--pass1 P1DIR] -- after the dumper has run on a real KN7000: did
# its files reach the computer whole, and what are they? DIR holds what was copied off the SD card (DUMPLIST.TXT
# and the dump files, under their 8.3 or their long names). Per file:
#   * size and CRC-32 must be what the instrument computed while it wrote the file (DUMPLIST.TXT): a mismatch
#     means the copy from the card went wrong, not the dump;
#   * whether the bytes equal a ROM we already have (technics_romsets/kn7000), or are new; an address window
#     (R*.BIN) that holds copies of one is reported as such ("c3cbnd000046.ic18 x2");
#   * for a wave ROM, whether its byte sum is the one the firmware's own WAVE ROM test expects of that chip
#     (DUMPLIST.TXT's "expected"; the same four values in every program build). That shows every byte of the
#     chip was read, though not their order.
# For the program and table flash it joins the even/odd halves and reads, from the image itself, the release
# byte, the build numbers (as the loader does) and runs find_fw.py's firmware search over the program.
# For the SURVEY build's address windows (SurveyTable's six R*.BIN) it runs find_rhythm.py on them: where the
# rhythm ROM is, and whether it passes the firmware's own check.
# With DIR2 (a second run, copied off separately) every file must be byte-identical in both: two reads that
# agree are the usual evidence that a dump read stably.
# The SURVEY2 build (romdump.s Survey2Table) brings 14 windows; for them:
#   * --pass4 P4DIR (pass 4, the SURVEY build's run): every R*.BIN in both is compared byte for byte, per 1 MB
#     slice. A slice that differs counts as a problem, unless pass 4 read open bus there (at least 98% FF and
#     some other residue values), which need not read the same twice;
#   * --pass1 P1DIR (pass 1, the SAFE build's run): R5680000.BIN (0x56800000) is compared with its IC21.BIN
#     (read at 0x96800000), and R4C00000.BIN (the library RAM at 0x4C000000) with the program flash joined
#     from its PRGEVEN.BIN and PRGODD.BIN: where in the flash the copy comes from, and how much of it agrees;
#   * R4400000.BIN (IC23, 0x44000000-0x441FFFFF): does it repeat every 256 KB? Each 256 KB copy is compared
#     with the first; the first is also checked for a shorter period (128 KB, 64 KB);
#   * the expansion slot windows (R4100000, R4180000, R5600000, R5700000) and the work RAM (R5018000): what
#     they hold (FF/00 share, distinct values; the 'TCMP' and 'TPAD' containers in the work RAM).
# These are findings; only a damaged copy, a missing file, a second run (DIR2) that differs, or a pass-4 data
# slice that differs count as problems (exit status 1).
#   python3 -I check_real_dump.py ~/kn7000-dump-run1 ~/kn7000-dump-run2
#   python3 -I check_real_dump.py pass5-run1 --pass4 pass4-run1 --pass1 pass1-run1
#   python3 -I check_real_dump.py --self-test     # the SURVEY2 analyses on made-up files
import hashlib
import os
import re
import struct
import sys
import zlib
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_fw  # noqa: E402
import find_rhythm  # noqa: E402

KNOWN = os.path.expanduser('~/compartilhado/technics_romsets/kn7000')
MB = 0x100000
SURVEY = (0x40000000, 0x40800000, 0x54000000, 0x54800000, 0x55000000, 0x55800000)     # romdump.s SurveyTable
SLOTS = (0x41000000, 0x41800000, 0x56000000, 0x57000000)                               # the expansion slots
IC23, IC23_SIZE = 0x44000000, 0x40000
PROGRAM_BASE = 0x48400000


def window_base(name):
    m = re.fullmatch(r'R([0-9A-F]{7})\.BIN', name, re.I)
    return int(m.group(1), 16) << 4 if m else None


def load_dir(d):
    """{8.3 name: bytes, MAME name: bytes} for the files in d, and the manifest rows."""
    files = {}
    for n in os.listdir(d):
        p = os.path.join(d, n)
        if os.path.isfile(p):
            files[n.upper()] = files[n] = open(p, 'rb').read()
    man = files.get('DUMPLIST.TXT')
    if man is None:
        sys.exit(f'{d}: no DUMPLIST.TXT')
    rows = []
    for line in man.decode('latin1').splitlines()[2:]:
        f = line.split()
        if len(f) < 3:
            continue
        name, short = f[0], f[1].split('\\')[-1]
        m = re.search(r'\s(\d+) crc32 ([0-9A-F]{8}) bytesum ([0-9A-F]{8})', line)
        g = re.search(r'expected ([0-9A-F]{8})', line)
        golden = int(g.group(1), 16) if g else None
        if m:
            rows.append((name, short, int(m.group(1)), int(m.group(2), 16), int(m.group(3), 16), None, golden))
        else:
            rows.append((name, short, None, None, None, 'left out' if 'not dumped' in line else 'NOT WRITTEN', golden))
    return files, rows, man.decode('latin1').splitlines()[:2]


def known_roms(extra=()):
    """sha1 -> name of every ROM file we have, and size -> {sha1 of the file: name} for finding copies of one
    inside a window. extra: (name, bytes) pairs to recognise as well (pass 1's IC21.BIN)."""
    out, by_size = {}, {}
    files = [(n, open(os.path.join(KNOWN, n), 'rb').read()) for n in sorted(os.listdir(KNOWN))] \
        if os.path.isdir(KNOWN) else []
    for n, b in files + list(extra):
        h = hashlib.sha1(b).hexdigest()
        out[h] = max(out.get(h, ''), n, key=len)         # the most specific of the names a file has
        by_size.setdefault(len(b), {})[h] = out[h]
    return out, by_size


def copies_of_known(b, by_size):
    """'name xN' when the window b is N copies of one known ROM, 'starts with name' when only its start is."""
    for size in sorted(by_size, reverse=True):
        if size < 0x10000 or len(b) % size or size > len(b):
            continue
        name = by_size[size].get(hashlib.sha1(b[:size]).hexdigest())
        if name:
            n = len(b) // size
            return f'{name} x{n}' if b == b[:size] * n else f'starts with {name}'
    return None


def ic21_part(b):
    """The driver's custom-data files are the part of IC21 from 0x20000 on: which one is this?"""
    for n in sorted(os.listdir(KNOWN)) if os.path.isdir(KNOWN) else []:
        if n.endswith('.ic21') and open(os.path.join(KNOWN, n), 'rb').read() == b[0x20000:]:
            return f'from 0x20000: {n}'
    return 'new: not in our set'


def table(head, rows):
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    print('| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |')
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in rows:
        print('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')


def ranges(a, b, limit=6):
    """Where a and b differ, over the shorter length: up to limit (start, end) byte ranges, the number of bytes
    that differ, and whether there are more ranges than listed."""
    n = min(len(a), len(b))
    out, total, more, i = [], 0, False, 0
    while i < n:
        j = min(i + 0x1000, n)
        if a[i:j] != b[i:j]:
            for k in range(i, j):
                if a[k] != b[k]:
                    total += 1
                    if out and out[-1][1] == k:
                        out[-1][1] = k + 1
                    elif len(out) < limit:
                        out.append([k, k + 1])
                    else:
                        more = True
        i = j
    return out, total, more


def fmt_ranges(rs, base, more):
    s = ', '.join(f'{base + a:#010x}-{base + b - 1:#010x}' for a, b in rs)
    return s + (' ...' if more else '')


def stats(b):
    return (f'FF {b.count(255) * 100 / len(b):.1f}%, 00 {b.count(0) * 100 / len(b):.1f}%, '
            f'{len(set(b))} distinct values, starts {b[:8].hex(" ")}')


def open_bus(s):
    """pass 4's open-bus slices: almost all FF, with a few residue values (blank flash is FF throughout)."""
    return s.count(255) >= len(s) * 0.98 and len(set(s)) > 1


def compare_pass4(data, p4dir):
    """Every window in both runs, slice by slice: '.' the same, 'n' differs where pass 4 read open bus, 'D'
    differs in data. -> number of problems (data slices that differ, windows missing from this run)."""
    print(f'second read of the pass 4 windows, against {p4dir}:')
    rows, bad = [], 0
    for n in sorted(os.listdir(p4dir)):
        base = window_base(n)
        if base is None:
            continue
        old = open(os.path.join(p4dir, n), 'rb').read()
        new = data.get(n.upper())
        if new is None:
            rows.append((n, f'{base:#010x}', 'NOT IN THIS RUN', '-', '-'))
            bad += 1
            continue
        if new == old:
            rows.append((n, f'{base:#010x}', 'identical', '.' * ((len(old) + MB - 1) // MB), '0'))
            continue
        marks, nbytes = '', 0
        for i in range(0, max(len(old), len(new)), MB):
            a, b = old[i:i + MB], new[i:i + MB]
            if a == b:
                marks += '.'
                continue
            nbytes += sum(x != y for x, y in zip(a, b)) + abs(len(a) - len(b))
            marks += 'n' if open_bus(a) else 'D'
        bad += marks.count('D') + (len(old) != len(new))
        what = 'differs only where pass 4 read open bus' if 'D' not in marks and len(old) == len(new) else 'DIFFERS'
        rows.append((n, f'{base:#010x}', what, marks, str(nbytes)))
    table(('file', 'CPU base', 'against pass 4', '1 MB slices', 'bytes that differ'), rows)
    print("   ('.' the same; 'n' differs where pass 4 read open bus, which need not repeat; 'D' differs in data)")
    print()
    return bad


def ic23_repeat(b):
    print(f'IC23 (R4400000.BIN, CPU {IC23:#010x}-{IC23 + len(b) - 1:#010x}): does it repeat every 256 KB?')
    first = b[:IC23_SIZE]
    rows = []
    for k in range(0, len(b), IC23_SIZE):
        c = b[k:k + IC23_SIZE]
        if k == 0:
            what = 'the first copy: ' + stats(c)
        elif c == first:
            what = '= the first copy'
        else:
            rs, total, more = ranges(first, c)
            what = f'differs from the first in {total} bytes: {fmt_ranges(rs, IC23 + k, more)}'
        rows.append((f'{IC23 + k:#010x}', what))
    table(('copy at', 'what it holds'), rows)
    equal = sum(r[1] == '= the first copy' for r in rows[1:])
    if len(rows) > 1:
        print(f'   {equal} of {len(rows) - 1} copies after the first equal it'
              + (': IC23 repeats every 256 KB through the window.' if equal == len(rows) - 1 else
                 '. Words that differ by a few bytes may be ones the firmware wrote between the two reads (it'
                 ' runs while the dumper reads), or a stale cache line (0x44000000 is the cached view).'))
    for p in (0x20000, 0x10000):
        if first[:p] * (IC23_SIZE // p) == first:
            print(f'   the first copy itself repeats every {p // 1024} KB: the chip, or its decoding, is smaller')
            break
    else:
        print('   the first copy has no shorter period (128 KB, 64 KB): the chip has all of A1-A17')
    print()


def library_check(lib, prog):
    """Where in the program flash the library RAM's bytes come from, and over how much they agree."""
    deltas = Counter()
    for off in range(0, len(lib) - 0x100, 0x2000):
        probe = lib[off:off + 0x100]
        if len(set(probe)) < 16:
            continue
        p = prog.find(probe)
        if p >= 0 and prog.find(probe, p + 1) < 0:
            deltas[p - off] += 1
    if not deltas:
        print('library RAM (R4C00000.BIN): none of its 256-byte pieces occurs once in the program flash')
        return
    d, votes = deltas.most_common(1)[0]
    src = prog[d:d + len(lib)] if d >= 0 else b''
    n = len(src)
    run = next((i for i in range(n) if lib[i] != src[i]), n) if d >= 0 else 0
    rs, total, more = ranges(lib[:n], src)
    print(f'library RAM (R4C00000.BIN, 0x4C000000) against the program flash: it is the copy from '
          f'{PROGRAM_BASE + d:#010x} ({votes} pieces agree on that); the first {run:#x} bytes are identical'
          f' (to 0x{0x4C000000 + run - 1:08X}); over the {n:#x} bytes both have, {total} differ'
          + (f': {fmt_ranges(rs, 0x4C000000, more)}' if total else ''))
    rest = lib[n:]
    if rest:
        print(f'   past the end of the program flash: {len(rest):#x} bytes, {stats(rest)}')
    tail = lib[run:]
    if run < len(lib):
        print(f'   from 0x{0x4C000000 + run:08X} on: {stats(tail)}')


def findings(data, args):
    """The SURVEY2 windows -> problems (only pass 4's data slices that differ count)."""
    bad = 0
    if args.get('pass4'):
        bad += compare_pass4(data, args['pass4'])
    if 'R4400000.BIN' in data:
        ic23_repeat(data['R4400000.BIN'])
    p1 = args.get('pass1')
    if p1 and 'R5680000.BIN' in data and os.path.exists(os.path.join(p1, 'IC21.BIN')):
        ic21 = open(os.path.join(p1, 'IC21.BIN'), 'rb').read()
        b = data['R5680000.BIN']
        if b == ic21:
            print(f'R5680000.BIN (0x56800000-0x{0x56800000 + len(b) - 1:08X}) is byte for byte IC21.BIN of {p1}'
                  ' (read at 0x96800000): IC21 answers there too.')
        else:
            rs, total, more = ranges(ic21, b)
            print(f'R5680000.BIN (0x56800000) is NOT IC21.BIN of {p1}: {total} bytes differ'
                  + (f', {fmt_ranges(rs, 0x56800000, more)}' if total < len(b) // 2 else '') + f'; {stats(b)}')
        print()
    if p1 and 'R4C00000.BIN' in data and all(os.path.exists(os.path.join(p1, n)) for n in ('PRGEVEN.BIN', 'PRGODD.BIN')):
        prog = find_fw.interleave(*(open(os.path.join(p1, n), 'rb').read() for n in ('PRGEVEN.BIN', 'PRGODD.BIN')))
        library_check(data['R4C00000.BIN'], prog)
        print()
    slots = [(f'R{b:08X}'[:8] + '.BIN', b) for b in SLOTS]
    if any(n in data for n, _ in slots):
        print('the expansion slot windows (no board fitted):')
        table(('file', 'CPU window', 'what it holds'),
              [(n, f'{b:#010x}-{b + len(data[n]) - 1:#010x}', stats(data[n])) for n, b in slots if n in data])
        print()
    if 'R5018000.BIN' in data:
        b = data['R5018000.BIN']
        tags = [(t, [f'{0x50180000 + m.start():#010x}' for m in re.finditer(t, b)][:4]) for t in (b'TCMP', b'TPAD')]
        print(f'work RAM (R5018000.BIN, 0x50180000-0x{0x50180000 + len(b) - 1:08X}): {stats(b)}; '
              + '; '.join(f"'{t.decode()}' at {', '.join(a) if a else 'nowhere'}" for t, a in tags))
        print()
    return bad


def main(argv):
    args, pos = {}, []
    it = iter(argv)
    for a in it:
        if a in ('--pass4', '--pass1'):
            args[a[2:]] = next(it)
        else:
            pos.append(a)
    d1 = pos[0]
    d2 = pos[1] if len(pos) > 1 else None
    files, rows, header = load_dir(d1)
    files2 = load_dir(d2)[0] if d2 else None
    print('\n'.join(header))
    print()
    extra = []
    if args.get('pass1') and os.path.exists(os.path.join(args['pass1'], 'IC21.BIN')):
        extra.append(('IC21.BIN (pass 1)', open(os.path.join(args['pass1'], 'IC21.BIN'), 'rb').read()))
    known, by_size = known_roms(extra)
    out, bad, data = [], 0, {}
    for name, short, size, crc, bsum, why, golden in rows:
        if why:
            out.append((name, short, '-', '-', why, '-', '-', '-'))
            bad += why != 'left out'
            continue
        b = files.get(short) or files.get(short.upper()) or files.get(name)
        if b is None:
            out.append((name, short, size, f'{crc:08x}', 'NOT FOUND in ' + d1, '-', '-', '-'))
            bad += 1
            continue
        whole = len(b) == size and zlib.crc32(b) & 0xffffffff == crc and sum(b) & 0xffffffff == bsum
        bad += not whole
        sha = hashlib.sha1(b).hexdigest()
        again = '-'
        if files2 is not None:
            b2 = files2.get(short) or files2.get(short.upper()) or files2.get(name)
            again = 'identical' if b2 == b else ('MISSING' if b2 is None else 'DIFFERENT')
            bad += again != 'identical'
        data[short.upper()] = b
        what = known.get(sha) or (ic21_part(b) if short.upper() == 'IC21.BIN' else None) \
            or (copies_of_known(b, by_size) if window_base(short) is not None else None) or 'new: not in our set'
        fw = '-'
        if golden is not None:
            fw = f'= {golden:08x}' if sum(b) & 0xffffffff == golden else f'DIFFERS ({sum(b) & 0xffffffff:08x} != {golden:08x})'
            bad += not fw.startswith('=')
        out.append((name, short, len(b), f'{zlib.crc32(b) & 0xffffffff:08x}',
                    'whole (= DUMPLIST.TXT)' if whole else 'DAMAGED IN TRANSFER', what, again, fw))
    table(('MAME name (from DUMPLIST.TXT)', '8.3', 'bytes', 'crc32', 'copy off the card', 'known as', 'second run',
           "firmware's expected sum"), out)
    print()

    if 'PRGEVEN.BIN' in data and 'PRGODD.BIN' in data:
        img = find_fw.interleave(data['PRGEVEN.BIN'], data['PRGODD.BIN'])
        print(f'program flash (even + odd, {len(img)} bytes), sha1 {hashlib.sha1(img).hexdigest()}')
        find_fw.analyse('this dump', img)
        print()
    if 'TBLEVEN.BIN' in data and 'TBLODD.BIN' in data:
        img = find_fw.interleave(data['TBLEVEN.BIN'], data['TBLODD.BIN'])
        off = struct.unpack_from('<I', img, 0x1C)[0]
        build = re.match(rb'[0-9A-Za-z .]*', img[off:off + 16]).group(0) if off < len(img) - 16 else b''
        print(f'table flash (even + odd, {len(img)} bytes), sha1 {hashlib.sha1(img).hexdigest()}; '
              f'build string at {off:#x}: {build.decode("latin1")!r}')
    bad += findings(data, args)
    survey = sorted(n for n in os.listdir(d1) if window_base(n) in SURVEY)
    if survey:                          # SurveyTable's windows only, joined as in pass 4
        find_rhythm.main([os.path.join(d1, n) for n in survey])
    print()
    print('everything checks out' if bad == 0 else f'{bad} problem(s): see above')
    return bad


def self_test():
    """Made-up SURVEY2 files (small windows) with a made-up pass 1 and pass 4: an IC23 that repeats but for one
    word, IC21 at 0x56800000, a library copied from 0x487B8FD1, a pass-4 window whose open-bus slice reads
    different residue; then the same with a data slice that differs, which must count as a problem."""
    import contextlib
    import io
    import random
    import tempfile
    r = random.Random(7000)
    prog = bytearray(r.randbytes(0x400000))
    ic21 = bytes(r.randbytes(0x100000)) + b'\xff' * 0x100000
    ic23 = bytearray(r.randbytes(IC23_SIZE))
    lib = bytes(prog[0x3B8FD1:0x3F6EE9]) + bytes(0x40000 - 0x3DF18)
    openbus = bytearray(b'\xff' * MB)
    openbus[0:6] = b'\x80\x00\x80\x00\xfe\xff'
    p4 = {f'R{b:08X}'[:8] + '.BIN': (bytes(r.randbytes(MB)) + bytes(openbus)) for b in SURVEY}
    run = dict(p4)
    last = bytearray(ic23)
    last[0x100] ^= 0xFF
    last[0x101] ^= 0xFF                                     # two bytes the firmware changed meanwhile
    run['R4400000.BIN'] = bytes(ic23) * 7 + bytes(last)
    run['R4C00000.BIN'] = lib
    run['R5680000.BIN'] = ic21
    run['R5018000.BIN'] = b'TCMP' + bytes(r.randbytes(0x117FFC))
    for b in SLOTS:
        run[f'R{b:08X}'[:8] + '.BIN'] = b'\xff' * 0x10000
    noisy = bytearray(run['R5400000.BIN'])
    noisy[MB + 3] ^= 0x40                                   # open bus: different residue on the second read
    run['R5400000.BIN'] = bytes(noisy)
    with tempfile.TemporaryDirectory(prefix='check_real_dump_') as t:
        dirs = {k: os.path.join(t, k) for k in ('p1', 'p4', 'run')}
        for d in dirs.values():
            os.mkdir(d)
        for n, b in p4.items():
            open(os.path.join(dirs['p4'], n), 'wb').write(b)
        open(os.path.join(dirs['p1'], 'IC21.BIN'), 'wb').write(ic21)
        open(os.path.join(dirs['p1'], 'PRGEVEN.BIN'), 'wb').write(b''.join(prog[i:i + 2] for i in range(0, len(prog), 4)))
        open(os.path.join(dirs['p1'], 'PRGODD.BIN'), 'wb').write(b''.join(prog[i + 2:i + 4] for i in range(0, len(prog), 4)))

        def write_run(files):
            lines = ['KN7000 ROM DUMPER (KN7APP.BIN)  PROGRAM 893  TABLE 80  release byte 0x13  build options 0x000B0000',
                     'loader found: 0x7F (self-test)']
            for n, b in files.items():
                open(os.path.join(dirs['run'], n), 'wb').write(b)
                lines.append(f'survey_{window_base(n):08x}.bin  {n}  {len(b)} crc32 {zlib.crc32(b) & 0xffffffff:08X}'
                             f' bytesum {sum(b) & 0xffffffff:08X}  CPU window')
            open(os.path.join(dirs['run'], 'DUMPLIST.TXT'), 'w', newline='\r\n').write('\n'.join(lines) + '\n')

        def check():
            with contextlib.redirect_stdout(io.StringIO()) as out:
                n = main([dirs['run'], '--pass4', dirs['p4'], '--pass1', dirs['p1']])
            return n, out.getvalue()

        write_run(run)
        n_ok, ok = check()
        bad_run = dict(run)
        broken = bytearray(run['R4000000.BIN'])
        broken[0x1234] ^= 1                                 # a data slice that differs
        bad_run['R4000000.BIN'] = bytes(broken)
        write_run(bad_run)
        n_bad, bad = check()
    assert n_ok == 0 and 'everything checks out' in ok, ok
    assert 'differs only where pass 4 read open bus' in ok and '| .n ' in ok, ok
    assert '6 of 7 copies after the first equal it' in ok and 'differs from the first in 2 bytes: 0x441c0100-0x441c0101' in ok, ok
    assert 'is byte for byte IC21.BIN' in ok, ok
    assert 'copy from 0x487b8fd1' in ok and 'the first 0x3df18 bytes are identical' in ok, ok
    assert "'TCMP' at 0x50180000" in ok and 'FF 100.0%' in ok, ok
    assert n_bad == 1 and '| D. ' in bad and 'DIFFERS' in bad, bad
    print('self-test passed: open-bus noise is not a problem, a changed data byte is; IC23 copies compared;'
          ' IC21 found at 0x56800000; the library found at 0x487B8FD1')


if __name__ == '__main__':
    if sys.argv[1:] == ['--self-test']:
        self_test()
    else:
        sys.exit(1 if main(sys.argv[1:]) else 0)
