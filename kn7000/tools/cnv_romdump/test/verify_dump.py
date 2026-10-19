#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# verify_dump.py SD.img [--prefix N] [--no-prefill] [--degraded] [--skip-mask M] [--driver kn7000.cpp] -- did the
# dumper write
# the right bytes under the right names? Reads C:\KN7DUMP from the SD card image (or the root folder, when the
# dumper had no folder routines) and, for every file, by its 8.3 name (PRGEVEN.BIN ...):
#   * its long name must be one of MAME's kn7000 ROM names (or custom_data.ic21, the whole IC21 chip); with
#     --degraded (run_test.sh --loader-test) it may also have no long name, or "unknown" for the build number;
#   * a ROM the driver has hashes for must match them (CRC-32 and SHA-1);
#   * custom_data.ic21 must be what the CPU read at 0x96800000-0x969FFFFF when the dump ended (--ic21-ref, saved
#     by dump.cmd.in; the firmware writes its homepage record there at boot); the verifier also says whether
#     the part from 0x20000 is still 01ctmini.ic21, which the driver loads there;
#   * the undumped ROMs must hold the test data prefill.lua put in MAME: the wave ROM region upstream's driver
#     answers that port and select with, and the picture window's tap data.
#   * a program or table half is checked against the driver's hashes for that half, whatever its name says
#     (with --prefix: against the first N bytes of those ROM files in technics_romsets);
#   * --skip-mask M: bit n set = ROM n (RomTable order) was left out of the build (run_test.sh --safe) and must
#     not be on the card;
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
degraded = '--degraded' in args
survey = '--survey' in args             # the SURVEY build: six CPU windows (romdump.s SurveyTable), not ROMs
skip = int(args[args.index('--skip-mask') + 1], 0) if '--skip-mask' in args else 0
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

# the dumper's 8.3 names (romdump.s path_*) -> what the file holds
ROLE = {'PRGEVEN.BIN': 'kn7000_program_even_', 'PRGODD.BIN': 'kn7000_program_odd_',
        'TBLEVEN.BIN': 'kn7000_table_even_', 'TBLODD.BIN': 'kn7000_table_odd_', 'IC21.BIN': 'custom_data.ic21',
        'IC203.BIN': 'c3cbqd000002.ic203', 'IC204.BIN': 'c3cbqd000001.ic204', 'IC207.BIN': 'c3cbqd000004.ic207',
        'IC208.BIN': 'c3cbqd000003.ic208', 'IC19.BIN': 'c3cbmd000098.ic19', 'DUMPLIST.TXT': 'DUMPLIST.TXT'}
SURVEY = (0x40000000, 0x40800000, 0x54000000, 0x54800000, 0x55000000, 0x55800000)
if survey:                              # their 8.3 names are R + the base's top seven hex digits
    ROLE = {f'R{b:08X}'[:8] + '.BIN': f'survey_{b:08x}.bin' for b in SURVEY}
    ROLE['DUMPLIST.TXT'] = 'DUMPLIST.TXT'

fat = Fat(img)
folder = next((cl for n, lng, attr, cl, size in fat.entries(0) if n == 'KN7DUMP' and attr & 0x10), None)
where = 'C:\\KN7DUMP'
if folder is None or not any(s in ROLE for s, *_ in fat.entries(folder)):
    folder, where = 0, 'the root folder'
print(f'dump files in {where}')
rows, bad = [], 0
for short, lng, attr, cl, size in fat.entries(folder):
    if attr & 0x10 or short in ('.', '..') or short not in ROLE:
        continue
    data = fat.read_file(cl, size)
    role = ROLE[short]
    name = lng or short
    crc, sha = zlib.crc32(data) & 0xffffffff, hashlib.sha1(data).hexdigest()
    n = len(data) if prefix is None else min(prefix, len(data))
    if short == 'DUMPLIST.TXT':
        rows.append((name, short, size, f'{crc:08x}', 'manifest', 'ok' if size > 0 else 'EMPTY'))
        bad += size == 0
        continue
    if role.startswith('kn7000_'):          # a program or table half: the driver's hashes for that half
        cands = {n: h for n, h in hashes.items() if n.startswith(role) and '_lower' not in n and '_upper' not in n}
        hit = next((n for n, (c, s) in cands.items() if c == crc and s == sha), None)
        if prefix is not None:          # the start of the ROM files with those hashes
            hit = next((c for c in cands if os.path.exists(os.path.join(ROMS, c))
                        and open(os.path.join(ROMS, c), 'rb').read(n) == data[:n]), None)
            ok, how = hit is not None, f'first {n} bytes of {hit}' if hit else 'no ROM file starts like this'
        elif name in hashes:
            ok = hashes[name] == (crc, sha)
            how = f'MAME CRC {hashes[name][0]:08x} SHA-1 {hashes[name][1][:12]}..'
        else:
            ok, how = hit is not None, f'MAME hash of {hit}' if hit else 'none of the MAME hashes for this half'
        if lng and lng not in names and degraded and re.fullmatch(re.escape(role) + r'.*_bunknown\.ic1[67]', lng):
            name, how = (hit or name), how + '; named with build "unknown"'
    elif role == 'custom_data.ic21' and ic21_ref and os.path.exists(ic21_ref):
        ref = open(ic21_ref, 'rb').read()
        ok, how = data[:n] == ref[:n], 'what the CPU reads there (ref_ic21.bin)'
        if prefix is None:
            ctm = open(os.path.join(ROMS, '01ctmini.ic21'), 'rb').read()
            how += '; from 0x20000 = 01ctmini.ic21' if data[0x20000:] == ctm else '; from 0x20000 != 01ctmini.ic21'
    elif role in WAVE and prefill:
        region, seed = WAVE[role]
        ok, how = data[:n] == stream(seed, n), f'test data in {region} (seed {seed:#x})'
    elif role == 'c3cbmd000098.ic19' and prefill:
        ok, how = data[:n] == stream(0x19, n), 'test data at 0x57800000 (seed 0x19)'
    elif role.startswith('survey_') and prefill:
        base = int(role[7:15], 16)
        ok, how = data[:n] == stream(base >> 16, n), f'test data at {base:#010x} (seed {base >> 16:#x})'
    else:
        ok, how = False, 'no reference'
    if lng is None and degraded:
        how += '; no long name (8.3 only)'
        name = role if not role.endswith('_') else (hit or name)
    elif name not in names and name != 'custom_data.ic21':
        ok, how = False, how + '; NOT a MAME ROM name'
    bad += not ok
    rows.append((name, short, size, f'{crc:08x}', how, 'MATCH' if ok else 'DIFFERENT'))
seen = {r[1] for r in rows}
if survey and any(e[0] == 'UNUSED.BIN' for e in fat.entries(folder)):
    bad += 1
    rows.append(('unused', 'UNUSED.BIN', 0, '-', 'an unused survey slot was written', 'UNEXPECTED'))
for i, short in enumerate(ROLE):        # every file the build writes must be there, and only those
    left_out = i < 10 and skip >> i & 1
    if left_out and short in seen:
        bad += 1
        rows = [r[:5] + ('LEFT OUT, YET WRITTEN',) if r[1] == short else r for r in rows]
    elif left_out:
        rows.append((ROLE[short], short, 0, '-', 'left out of this build', 'absent, ok'))
    elif short not in seen:
        rows.append((ROLE[short], short, 0, '-', 'not on the card', 'MISSING'))
        bad += 1
w = [max(len(str(r[i])) for r in rows + [('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')])
     for i in range(6)]
head = ('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')
print('| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |')
print('|' + '|'.join('-' * (w[i] + 2) for i in range(6)) + '|')
for r in rows:
    print('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')
print(f'{len(rows) - bad} of {len(rows)} files as expected')
sys.exit(1 if bad else 0)
