#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# verify_dump.py SD.img [--prefix N] [--no-prefill] [--driver kn7000.cpp] -- did the dumper write the right
# bytes under the right names? Reads C:\KN7DUMP from the SD card image and, for every file:
#   * its long name must be one of MAME's kn7000 ROM names (or custom_data.ic21, the whole IC21 chip);
#   * a ROM the driver has hashes for must match them (CRC-32 and SHA-1);
#   * custom_data.ic21 must be what the CPU read at 0x96800000-0x969FFFFF when the dump ended (--ic21-ref, saved
#     by dump.cmd.in; the firmware writes its homepage record there at boot); the verifier also says whether
#     the part from 0x20000 is still 01ctmini.ic21, which the driver loads there;
#   * the undumped ROMs must hold the test data prefill.lua put in MAME: the wave ROM region upstream's driver
#     answers that port and select with, and the picture window's tap data.
# --prefix N compares only the first N bytes (run_test.sh --fast). Exit status 0 = everything matches.
import hashlib
import os
import re
import struct
import sys
import zlib

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from fatls import Fat  # noqa: E402

args = sys.argv[1:]
img = args[0]
prefix = int(args[args.index('--prefix') + 1]) if '--prefix' in args else None
prefill = '--no-prefill' not in args
ic21_ref = args[args.index('--ic21-ref') + 1] if '--ic21-ref' in args else None
driver = args[args.index('--driver') + 1] if '--driver' in args else \
    os.path.expanduser('~/compartilhado/mame-pr-kn-flop-rebuild/src/mame/matsushita/kn7000.cpp')
ROMS = os.path.expanduser('~/compartilhado/technics_romsets/kn7000')


def h32(x):
    x &= 0xffffffff
    x ^= x >> 16; x = (x * 0x7feb352d) & 0xffffffff
    x ^= x >> 15; x = (x * 0x846ca68b) & 0xffffffff
    x ^= x >> 16
    return x


def stream(seed, nbytes):
    return b''.join(struct.pack('<I', h32(i * 0x9E3779B9 + seed)) for i in range((nbytes + 3) // 4))[:nbytes]


# MAME's ROM names and hashes for the kn7000 set
src = open(driver).read()
body = src[src.index('ROM_START(kn7000)'):]
body = body[:body.index('ROM_END')]
hashes = {m.group(1): (int(m.group(2), 16), m.group(3)) for m in
          re.finditer(r'"([^"]+)",\s*0x[0-9a-f]+,\s*0x[0-9a-f]+,\s*CRC\(([0-9a-f]+)\)\s*SHA1\(([0-9a-f]+)\)', body)}
names = set(re.findall(r'ROMX?_LOAD\(\s*"([^"]+)"', body))
# upstream's tone generator mapping: TG 0 (0x98040000) = waveform_main_*, TG 1 (0x98050000) = waveform_sub_*;
# the firmware's WAVE ROM test calls 0x98050000 MAIN TG (IC203/IC204) -- so these are swapped there.
WAVE = {'c3cbqd000002.ic203': ('waveform_sub_y', 0x207), 'c3cbqd000001.ic204': ('waveform_sub_x', 0x208),
        'c3cbqd000004.ic207': ('waveform_main_y', 0x203), 'c3cbqd000003.ic208': ('waveform_main_x', 0x204)}

fat = Fat(img)
folder = next((cl for n, lng, attr, cl, size in fat.entries(0) if n == 'KN7DUMP' and attr & 0x10), None)
if folder is None:
    sys.exit('no KN7DUMP folder on the card')
rows, bad = [], 0
for short, lng, attr, cl, size in fat.entries(folder):
    if attr & 0x10 or short in ('.', '..'):
        continue
    data = fat.read_file(cl, size)
    name = lng or short
    crc, sha = zlib.crc32(data) & 0xffffffff, hashlib.sha1(data).hexdigest()
    n = len(data) if prefix is None else min(prefix, len(data))
    if short == 'DUMPLIST.TXT':
        rows.append((name, short, size, f'{crc:08x}', 'manifest', 'ok' if size > 0 else 'EMPTY'))
        bad += size == 0
        continue
    if name in hashes:
        want_crc, want_sha = hashes[name]
        if prefix is None:
            ok = crc == want_crc and sha == want_sha
            how = f'MAME CRC {want_crc:08x} SHA-1 {want_sha[:12]}..'
        else:
            ok, how = True, 'MAME hash (not checked on a prefix)'
    elif name == 'custom_data.ic21' and ic21_ref and os.path.exists(ic21_ref):
        ref = open(ic21_ref, 'rb').read()
        ok, how = data[:n] == ref[:n], 'what the CPU reads there (ref_ic21.bin)'
        if prefix is None:
            ctm = open(os.path.join(ROMS, '01ctmini.ic21'), 'rb').read()
            how += '; from 0x20000 = 01ctmini.ic21' if data[0x20000:] == ctm else '; from 0x20000 != 01ctmini.ic21'
    elif name in WAVE and prefill:
        region, seed = WAVE[name]
        ok, how = data[:n] == stream(seed, n), f'test data in {region} (seed {seed:#x})'
    elif name == 'c3cbmd000098.ic19' and prefill:
        ok, how = data[:n] == stream(0x19, n), 'test data at 0x57800000 (seed 0x19)'
    else:
        ok, how = False, 'no reference'
    if name not in names and name != 'custom_data.ic21':
        ok, how = False, how + '; NOT a MAME ROM name'
    bad += not ok
    rows.append((name, short, size, f'{crc:08x}', how, 'MATCH' if ok else 'DIFFERENT'))
w = [max(len(str(r[i])) for r in rows + [('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')])
     for i in range(6)]
head = ('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')
print('| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |')
print('|' + '|'.join('-' * (w[i] + 2) for i in range(6)) + '|')
for r in rows:
    print('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')
print(f'{len(rows) - bad} of {len(rows)} files as expected')
sys.exit(1 if bad else 0)
