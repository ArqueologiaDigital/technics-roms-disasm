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
#   * --survey / --survey2: the SURVEY or SURVEY2 build's windows (romdump.s SurveyTable, Survey2Table), R<base>.BIN.
#     A window with test data (prefill.lua, prefill_survey2.lua) must hold it. Each of SURVEY2's three RAM windows
#     (IC23 at 0x84000000, 0x50180000, 0x4C000000) must equal what the CPU read there at the end (--refdir:
#     ref_<base>.bin), except at words the firmware wrote during the run (writes_<base>.txt); with CS1 as plain RAM
#     ("model plain"), 0x84040000 on must also hold the test data (seed 0x8404).
#   * --dsp / --dspmem / --dsprate: the DSP probe's files (romdump_dsp.s, romdump_dsprate.s): format, the routines
#     found (= find_dsp.py), and the host-port traffic dsp_tap.lua counted (--refdir); pass 8 (--dsprate) may latch
#     only MSGR2, IIR0A and CR0A, and writes no data.
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
survey2 = '--survey2' in args           # the SURVEY2 build: 14 CPU windows (romdump.s Survey2Table)
dsp1 = '--dsp' in args                  # the DSP probe, phase 1 (romdump_dsp.s DspTable)
dsp2 = '--dspmem' in args               # phase 2 (DspMemTable)
dsp3 = '--dsprate' in args              # pass 8, the frame rate (romdump_dsprate.s DspRateTable)
refdir = args[args.index('--refdir') + 1] if '--refdir' in args else None
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
# Survey2Table: SurveyTable's six, then the RAM windows, then 0x56800000 and the expansion slots (base, bytes)
SURVEY2 = [(b, 0x800000) for b in SURVEY] + [(0x84000000, 0x200000), (0x50180000, 0x118000), (0x4C000000, 0x40000),
                                              (0x56800000, 0x200000), (0x41000000, 0x10000), (0x41800000, 0x10000),
                                              (0x56000000, 0x10000), (0x57000000, 0x10000)]
RAMWIN = (0x84000000, 0x50180000, 0x4C000000)       # no test data: compared with what the CPU read at the end
DSPFILES = {'DSPHOST.BIN': ('dsp_host.bin', 0x650, b'DSPHOST1'), 'DSPIOP.BIN': ('dsp_iop.bin', 0x870, b'DSPIOP01'),
            'DSPTIME.BIN': ('dsp_time.bin', 0x55F0, b'DSPTIME1'), 'DSPPM.BIN': ('dsp_pm.bin', 0x5480, b'DSPPM001'),
            'DSPDM.BIN': ('dsp_dm.bin', 0x36A0, b'DSPDM001'), 'DSPRATE.BIN': ('dsp_rate.bin', 0x20000, b'DSPRATE1')}
if dsp3:
    ROLE = {'DSPRATE.BIN': 'dsp_rate.bin', 'DUMPLIST.TXT': 'DUMPLIST.TXT'}
elif dsp1 or dsp2:
    ROLE = {k: v[0] for k, v in DSPFILES.items() if (k in ('DSPPM.BIN', 'DSPDM.BIN')) == dsp2 and k != 'DSPRATE.BIN'}
    ROLE['DUMPLIST.TXT'] = 'DUMPLIST.TXT'


def dsp_expected(build):
    """what DspFind should find in that program build (find_dsp.py, the same search in Python)"""
    import find_dsp
    tags = {893: '893', 941: '941', 942: '942', 935: '935'}
    return find_dsp.find(find_dsp.images()[tags[build]]) if build in tags else None


def dsp_traffic():
    """dsp_traffic.txt (dsp_tap.lua): index writes, data reads and data writes by index"""
    t = {'I': {}, 'R': {}, 'W': {}}
    for ln in open(os.path.join(refdir, 'dsp_traffic.txt')).read().split('\n'):
        f = ln.split()
        if f and f[0] == 'W':
            t['W'][(int(f[1], 16), int(f[2], 16))] = int(f[3])
        elif f:
            t[f[0]][int(f[1], 16)] = int(f[2])
    return t


def dsp_file(short, data, build):
    _, size, magic = DSPFILES[short]
    if len(data) != size or data[:8] != magic:
        return False, f'size {len(data)} / magic {data[:8]!r}: not the probe\'s format'
    st = struct.unpack_from('<I', data, 8)[0]
    f = struct.unpack_from('<8I', data, 0x30)
    want = dsp_expected(build)
    names = ('regwr', 'regrd', 'idxwr', 'datard', 'dead', 'downloaded')
    got = dict(zip(('found', 'wait', 'regwr', 'regrd', 'idxwr', 'datard', 'dead', 'downloaded'), f))
    if not isinstance(want, dict):
        return False, f'no expectation for program {build}'
    same = all(got[n] == want[n] for n in names) and got['wait'] == want['wait'] and got['found'] == 15
    how = (f'found {got["found"]:#x}, register read {got["regrd"]:#010x}, dead flag {got["dead"]:#010x}: '
           + ('as find_dsp.py finds them' if same else 'NOT what find_dsp.py finds') + f'; status {st:#x}')
    ok = same and st & 1
    if refdir and short == 'DSPIOP.BIN' and os.path.exists(os.path.join(refdir, 'ref_iop.bin')):
        import check_dsp_probe
        ref = struct.unpack('<256I', open(os.path.join(refdir, 'ref_iop.bin'), 'rb').read())
        a = struct.unpack_from('<256I', data, 0x70)
        b = struct.unpack_from('<256I', data, 0x470)
        # registers that move by themselves: status, counters, pin states, the SPORT channels' index and count
        live = {0x03, 0x19, 0x2A, 0x2D, 0x2F, 0x37} | {c + k for c in (0x30, 0x38, 0x50, 0x58, 0x60, 0x68, 0x70, 0x78)
                                                      for k in (0, 2)}
        diff = [r for r in check_dsp_probe.READ if not a[r] == b[r] == ref[r]]
        hard = [r for r in diff if r not in live]
        how += (f'; {len(check_dsp_probe.READ) - len(diff)} of {len(check_dsp_probe.READ)} registers, both passes, = '
                'what the port answers after the run')
        if diff:
            how += '; differ: ' + ', '.join(f'{check_dsp_probe.IOP[r]} {a[r]:#x}/{b[r]:#x}/after {ref[r]:#x}'
                                            + ('' if r in hard else ' (live)') for r in diff)
        ok = ok and not hard
    for name, ref_name, off, n, wb in (('DSPPM.BIN', 'ref_pm.bin', 0x80, 0xE00, 6), ('DSPDM.BIN', 'ref_dm.bin', 0x80, 0xD00, 4)):
        if refdir and short == name and os.path.exists(os.path.join(refdir, ref_name)):
            ref = open(os.path.join(refdir, ref_name), 'rb').read()
            words_read = struct.unpack_from('<I', data, 0x70)[0]
            eq = sum(data[off + wb * i:off + wb * (i + 1)] == ref[wb * i:wb * (i + 1)] for i in range(n))
            how += f'; {words_read} words read; {eq} of {n} equal to what the DSP holds at the end'
            if st & 0x20:                     # the pre-check refused: nothing may have been read
                ok = ok and words_read == 0
            elif name == 'DSPPM.BIN':         # program memory does not change while the kernel runs
                ok = ok and words_read == n and eq == n
    return ok, how


if survey or survey2:                   # their 8.3 names are R + the base's top seven hex digits
    ROLE = {f'R{b:08X}'[:8] + '.BIN': f'survey_{b:08x}.bin' for b in (dict(SURVEY2) if survey2 else SURVEY)}
    ROLE['DUMPLIST.TXT'] = 'DUMPLIST.TXT'


def ram_window(base, data, n):
    """SURVEY2's RAM windows: the file against what the CPU read there at the end (ref_<base>.bin), word by word;
    a word that differs must have been written during the run (writes_<base>.txt, word offsets in hex; for
    IC23 at 0x84000000 also modulo 256 KB when the driver mirrors it)."""
    if not refdir:
        return False, 'no --refdir'
    ref = open(os.path.join(refdir, f'ref_{base:08x}.bin'), 'rb').read()
    lines = open(os.path.join(refdir, f'writes_{base:08x}.txt')).read().split()
    model = None
    if lines[:1] == ['model']:
        model, lines = lines[1], lines[2:]
    written = {int(x, 16) for x in lines}
    mirror = model == 'mirrored'
    if mirror:
        written |= {w % 0x40000 for w in written}
    diff = [o for o in range(0, n, 4) if data[o:o + 4] != ref[o:o + 4]]
    unexplained = [o for o in diff if o not in written and not (mirror and o % 0x40000 in written)]
    how = f'what the CPU read at the end (ref_{base:08x}.bin); {len(written)} words written during the run'
    if diff:
        how += f', {len(diff)} words differ, {len(unexplained)} of them not written'
    ok = not unexplained
    if base == 0x84000000:
        how += f'; driver model: {model}'
        if model == 'plain' and n > 0x40000:
            hi = data[0x40000:n] == stream(0x8404, n - 0x40000)
            how += '; from 0x84040000 the test data (seed 0x8404)' if hi else '; from 0x84040000 NOT the test data'
            ok = ok and hi
        elif mirror and n >= 0x80000:
            reps = sum(data[k:k + 0x40000] == data[:0x40000] for k in range(0x40000, n, 0x40000))
            how += f'; {reps} of {n // 0x40000 - 1} copies after the first equal it'
    return ok, how

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
    elif short in DSPFILES and (dsp1 or dsp2 or dsp3):
        m = re.search(rb'PROGRAM (\d+)', fat.read_file(*next((cl, sz) for sh, lg, at, cl, sz in fat.entries(folder)
                                                             if sh == 'DUMPLIST.TXT')))
        ok, how = dsp_file(short, data, int(m.group(1)) if m else None)
    elif role.startswith('survey_') and survey2 and int(role[7:15], 16) in RAMWIN:
        ok, how = ram_window(int(role[7:15], 16), data, n)
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
if (survey or survey2) and any(e[0] == 'UNUSED.BIN' for e in fat.entries(folder)):
    bad += 1
    rows.append(('unused', 'UNUSED.BIN', 0, '-', 'an unused survey slot was written', 'UNEXPECTED'))
for i, short in enumerate(ROLE):        # every file the build writes must be there, and only those
    left_out = i < len(ROLE) - 1 and skip >> i & 1
    if left_out and short in seen:
        bad += 1
        rows = [r[:5] + ('LEFT OUT, YET WRITTEN',) if r[1] == short else r for r in rows]
    elif left_out:
        rows.append((ROLE[short], short, 0, '-', 'left out of this build', 'absent, ok'))
    elif short not in seen:
        rows.append((ROLE[short], short, 0, '-', 'not on the card', 'MISSING'))
        bad += 1
if (dsp1 or dsp2 or dsp3) and refdir and os.path.exists(os.path.join(refdir, 'dsp_traffic.txt')):
    t = dsp_traffic()
    writes = sorted(t['W'])
    allowed = {0x1C, 0x40, 0x41, 0x42} if dsp2 else set()
    wrong = [w for w in writes if w[0] not in allowed]
    import check_dsp_probe
    idx_bad = [i for i in t['I'] if i not in check_dsp_probe.READ and not (dsp2 and i in (0x04, 0x1C, 0x40, 0x41, 0x42))]
    if dsp3:
        idx_bad += [i for i in t['I'] if i not in (0x0A, 0x60, 0x62) and i not in idx_bad]
    ok = not wrong and not idx_bad
    bad += not ok
    how = (f"index writes {sum(t['I'].values())} to {len(t['I'])} registers, data reads {sum(t['R'].values())}, "
           f"data writes {sum(t['W'].values())}: " + (', '.join(f'{i:#04x}={v:#06x} x{t["W"][(i, v)]}' for i, v in writes)
                                                    or 'none'))
    if wrong or idx_bad:
        how += f'; NOT ALLOWED: writes {wrong}, indexes {idx_bad}'
    rows.append(('host port traffic', '-', '-', '-', how, 'ok' if ok else 'WRONG'))
w = [max(len(str(r[i])) for r in rows + [('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')])
     for i in range(6)]
head = ('file (long name)', '8.3', 'bytes', 'crc32', 'expected', 'result')
print('| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |')
print('|' + '|'.join('-' * (w[i] + 2) for i in range(6)) + '|')
for r in rows:
    print('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')
print(f'{len(rows) - bad} of {len(rows)} files as expected')
sys.exit(1 if bad else 0)
