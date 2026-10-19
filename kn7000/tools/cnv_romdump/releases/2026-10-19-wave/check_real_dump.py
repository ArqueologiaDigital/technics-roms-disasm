#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_real_dump.py DIR [DIR2] -- after the dumper has run on a real KN7000: did its files reach the computer
# whole, and what are they? DIR holds what was copied off the SD card (DUMPLIST.TXT and the dump files, under
# their 8.3 or their long names). Per file:
#   * size and CRC-32 must be what the instrument computed while it wrote the file (DUMPLIST.TXT): a mismatch
#     means the copy from the card went wrong, not the dump;
#   * whether the bytes equal a ROM we already have (technics_romsets/kn7000), or are new;
#   * for a wave ROM, whether its byte sum is the one the firmware's own WAVE ROM test expects of that chip
#     (DUMPLIST.TXT's "expected"; the same four values in every program build). That shows every byte of the
#     chip was read, though not their order.
# For the program and table flash it joins the even/odd halves and reads, from the image itself, the release
# byte, the build numbers (as the loader does) and runs find_fw.py's firmware search over the program.
# With DIR2 (a second run, copied off separately) every file must be byte-identical in both: two reads that
# agree are the usual evidence that a dump read stably.
#   python3 -I check_real_dump.py ~/kn7000-dump-run1 ~/kn7000-dump-run2
import hashlib
import os
import re
import struct
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_fw  # noqa: E402

KNOWN = os.path.expanduser('~/compartilhado/technics_romsets/kn7000')


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


def known_roms():
    out = {}
    for n in sorted(os.listdir(KNOWN)) if os.path.isdir(KNOWN) else []:
        h = hashlib.sha1(open(os.path.join(KNOWN, n), 'rb').read()).hexdigest()
        out[h] = max(out.get(h, ''), n, key=len)         # the most specific of the names a file has
    return out


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


d1 = sys.argv[1]
d2 = sys.argv[2] if len(sys.argv) > 2 else None
files, rows, header = load_dir(d1)
files2 = load_dir(d2)[0] if d2 else None
print('\n'.join(header))
print()
known = known_roms()
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
    data[short] = b
    what = known.get(sha) or (ic21_part(b) if short == 'IC21.BIN' else 'new: not in our set')
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
print()
print('everything checks out' if bad == 0 else f'{bad} problem(s): see above')
sys.exit(1 if bad else 0)
