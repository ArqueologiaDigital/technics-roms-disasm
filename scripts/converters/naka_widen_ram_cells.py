#!/usr/bin/env python3
r"""naka_widen_ram_cells.py -- type the 32-bit widget RAM cells of naka_sequencer_channels.c as one member.

QUESTION ANSWERED
-----------------
"What are the lone `uint16_t field_XXXX` members between the named RAM cells of
naka_sequencer_channels.c?"  (register item N-d8cf1242.)  That blob is the work-RAM image
Boot_InitWorkRAM copies to RAM 0x3D524 (WorkRamInit_Image), and many of its members are the live-value
cells of widget records: a record field whose propdata letter is m..s (pBoolProc, pSwordProc, pUwordProc,
pScharProc, pUcharProc, pSlongProc, pUlongProc: SupportClass_PropTypeRecords entries 'm'-'A' ..
's'-'A', read from the v10 ROM) holds the cell's RAM address, and naka_ram_cells.h names the cell
RAM_<Record>_<Field>.  The C member of such a cell was cut as `uint16_t <Record>_<Field>` plus a
`uint16_t field_XXXX` for its high half whenever the field's letter is r or s (pSlong / pUlong): a
32-bit cell.  This merges each such pair into one `int32_t` (r) / `uint32_t` (s) member, when

  * the named member's RAM address (0x3D524 + its ROM address - 0xEED8C8) is its RAM_<name>'s value;
  * every record field that names RAM_<name> (in the C records of the tree, `.field = RAM_<name>`) or
    holds its address (the asm records' NAKA_REC_<Class> calls, `field=0x...`) has letter r or s, and they
    agree;
  * the next member is `uint16_t field_XXXX` with XXXX = the named member's offset + 2.

Values come from the compiled blob; the file is recompiled and compared before it is written.

RUN (repository root, built tree)
    python3 scripts/converters/naka_widen_ram_cells.py --tree v10 [--dry-run]      # also v9, v7
"""
import argparse
import collections
import glob
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LLVM = '/home/fsanches/compartilhado/llvm-project/build/bin'
BLOB_BASE, IMG_ROM, IMG_RAM, IMG_END = 0xEEE078, 0xEED8C8, 0x3D524, 0xEEFA66


def compile_c(tree, path, out):
    uw = os.path.join(ROOT, tree, 'maincpu', 'ui_widgets')
    ld = os.path.join(uw, 'naka_sequencer_channels_link.ld')
    subprocess.run([LLVM + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-Wno-comment',
                    '-I', uw, '-o', out + '.o', path], check=True)
    subprocess.run([LLVM + '/ld.lld', '-e', '0', '-T', ld, '-o', out + '.elf', out + '.o'], check=True)
    subprocess.run([LLVM + '/llvm-objcopy', '-O', 'binary', '-j', '.text', out + '.elf', out], check=True)
    return open(out, 'rb').read()


def class_letters(uw):
    """class -> {field: letter} from naka_classes.h's member comments (`/* +30 r RAM cell ... */`)."""
    out = {}
    t = open(os.path.join(uw, 'naka_classes.h')).read()
    for m in re.finditer(r'typedef struct __attribute__\(\(packed\)\) \{\n(.*?)\n\} naka_cls_(\w+)_t;', t, re.S):
        f = {}
        for mm in re.finditer(r'^\s+\S+ (\w+)(?:\[\d+\])?;\s+/\* \+\d+ (\S) ', m.group(1), re.M):
            f[mm.group(1)] = mm.group(2)
        out[m.group(2)] = f
    return out


def cell_letters(uw, letters):
    """RAM_<cell> -> set of propdata letters of the record fields that name it, over the tree's C."""
    out = collections.defaultdict(set)
    for p in glob.glob(os.path.join(uw, '*.c')):
        t = open(p, 'rb').read().decode('latin-1')
        for m in re.finditer(r'\.(\w+) = \{\n        \.class_ = NAKA_CLASS\((\w+)\),\n(.*?)\n    \},', t, re.S):
            cls = m.group(2)
            for mm in re.finditer(r'^        \.(\w+) = (RAM_\w+),', m.group(3), re.M):
                out[mm.group(2)].add(letters.get(cls, {}).get(mm.group(1), '?'))
    return out


def asm_cell_letters(tree, letters):
    """RAM address -> set of propdata letters of the asm records' fields (NAKA_REC_<Class> calls) that
    hold it as a number."""
    out = collections.defaultdict(set)
    for p in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        t = open(p, 'rb').read().decode('latin-1')
        for m in re.finditer(r'^\s*NAKA_REC_(\w+) (.*)$', t, re.M):
            f = letters.get(m.group(1), {})
            for mm in re.finditer(r'(\w+)=(0x[0-9a-fA-F]+)\b', m.group(2)):
                lt = f.get(mm.group(1))
                if lt and lt in 'mnopqrs':
                    out[int(mm.group(2), 16)].add(lt)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--scratch', default=os.path.join(os.environ.get('TMPDIR', '/home/fsanches/compartilhado/tmp'),
                                                      'naka_widen_ram_cells'))
    a = ap.parse_args()
    uw = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets')
    p = os.path.join(uw, 'naka_sequencer_channels.c')
    s = open(p, 'rb').read().decode('latin-1')
    cells = {m.group(1): int(m.group(2), 16) for m in
             re.finditer(r'#define (RAM_\w+)\s+0x([0-9A-Fa-f]+)u', open(os.path.join(uw, 'naka_ram_cells.h')).read())}
    cl = class_letters(uw)
    used = cell_letters(uw, cl)
    by_addr = asm_cell_letters(a.tree, cl)
    os.makedirs(a.scratch, exist_ok=True)
    before = compile_c(a.tree, p, os.path.join(a.scratch, 'before.bin'))
    pairs = []
    why = collections.Counter()
    for m in re.finditer(r'^    uint16_t (\w+);\n    uint16_t field_([0-9a-f]{4});\n', s, re.M):
        name, off = m.group(1), int(m.group(2), 16) - 2
        rom = BLOB_BASE + off
        if not (IMG_ROM <= rom < IMG_END - 3):
            why['outside the first image'] += 1
            continue
        ram = IMG_RAM + rom - IMG_ROM
        if cells.get('RAM_' + name) != ram:
            why['no RAM_ cell of that address'] += 1
            continue
        lt = used.get('RAM_' + name, set()) | by_addr.get(ram, set())
        if not lt or not lt <= {'r', 's'} or len(lt) != 1:
            why['letters %s' % ''.join(sorted(lt)) if lt else 'no record field names it'] += 1
            continue
        pairs.append((name, off, lt.pop()))
    print('naka_widen_ram_cells %s: %d pairs to merge; not merged: %s' % (a.tree, len(pairs), dict(why)))
    if a.dry_run or not pairs:
        return
    for name, off, lt in pairs:
        ctype = 'int32_t' if lt == 'r' else 'uint32_t'
        s, n = re.subn(r'^    uint16_t %s;\n    uint16_t field_%04x;\n' % (name, off + 2),
                       '    %s %s;  /* letter %s cell (32-bit) */\n' % (ctype, name, lt), s, count=1, flags=re.M)
        assert n == 1, name
        v = struct.unpack('<I', before[off:off + 4])[0]
        val = ('-1' if v == 0xFFFFFFFF else '0x%08X' % v) if lt == 'r' else '0x%08X' % v
        s, n = re.subn(r'^    \.%s = [^\n]*,\n\n    \.field_%04x = [^\n]*,\n' % (name, off + 2),
                       '    .%s = %s,\n' % (name, val), s, count=1, flags=re.M)
        assert n == 1, ('init', name)
    tmp = os.path.join(a.scratch, 'naka_sequencer_channels.c')
    open(tmp, 'wb').write(s.encode('latin-1'))
    after = compile_c(a.tree, tmp, os.path.join(a.scratch, 'after.bin'))
    if after != before:
        sys.exit('naka_widen_ram_cells: %s: the compiled blob differs; not written' % a.tree)
    open(p, 'wb').write(s.encode('latin-1'))
    print('naka_widen_ram_cells %s: %d cells widened' % (a.tree, len(pairs)))


if __name__ == '__main__':
    main()
