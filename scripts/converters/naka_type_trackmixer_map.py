#!/usr/bin/env python3
r"""naka_type_trackmixer_map.py -- type runs of offset-named members of naka_sequencer_channels.c from
the code that reads their RAM copies.

QUESTION ANSWERED
-----------------
"What are the field_XXXX members of naka_sequencer_channels.c?"  (register item N-d8cf1242: 291 of
them on 2026-11-06.)  Most of that blob is the work-RAM image Boot_InitWorkRAM (boot/system_handlers.s)
copies at power-on: ROM 0xEED8C8.. -> RAM 0x3D524.. (0x219E bytes, WorkRamInit_Image) and ROM 0xEEFA66..
-> RAM 0xE35E.. (WorkRamInit_Image2).  So a member at blob offset o (ROM 0xEEE078 + o) is the power-on
value of RAM 0x3D524 + (0xEEE078 + o - 0xEED8C8), and its readers are the code that addresses that RAM.
Each SPEC below is one run of members read that way, with the reading that names it:

  * TrackMixer_ColumnPartMap, blob 0xF14..0xF48 (field_0f14 .. field_0f40, bytes_0f42) = RAM 0x3EBE8:
    TrackMixer_Init (ui/drawbar_panel_ui.s, EVT_SHOW of AcTrackMixerProc) `ld xwa, 0x3ebe8; calr
    Util_StoreGridArrayBase` installs it as the PsMixer grid array, whose word [page*8 + column]
    PsMixer_ReadWordArrayEntry reads as the column's part; TrackMixer_UpdateHandler `ld xhl, 0x3ebe8;
    add xhl, 2*DE; ld (xhl), wa` writes word [track] (DE = 0..15).  32 words with the 6 already typed
    as TrackMixer_GridRowMapEnd.
  * ChordName_TypeRootTables, blob 0x1624..0x1724 (field_1624 .. field_1722, 128 words) = RAM 0x3F2F8:
    MainChordPre_AppendChordSuffix (kn5000_v10_program.s) `lda xbc, (0x03f2f8:24)`, then
    `ld xbc, (xbc + 4*DISPLAY_CHORD_TYPE)`, `ld xbc, (xbc + 4*DISPLAY_CHORD_ROOT)`,
    `ld xbc, (xbc + 4*DISPLAY_CHORD_BASS)` and Strcat's the result: 64 32-bit RAM pointers, one per chord
    type, each to a root table (RAM 0x3F228 / 0x3F25C / 0x3F290 / 0x3F2C4, 13 pointers apart).

The members of a run are replaced by one array member (pure comment lines between them go too), its
initializer by the values read from the compiled blob.  The file is recompiled and compared before it is
written, so the bytes do not change.

RUN (repository root, built tree)
    python3 scripts/converters/naka_type_trackmixer_map.py --tree v10      # also v9, v7
"""
import argparse
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LLVM = '/home/fsanches/compartilhado/llvm-project/build/bin'
MEMBER = re.compile(r'^    (?:uint8_t|uint16_t|uint32_t|char) ((?:field|bytes|ptr)_([0-9a-f]{4}))(?:\[(\d+)\])?;')

SPECS = [
    dict(name='TrackMixer_ColumnPartMap', ctype='uint16_t', start=0xF14, end=0xF48, fmt='0x%04X', per=13,
         comment=('AcTrackMixerProc\'s column -> part map: the power-on image of RAM 0x3EBE8 (Boot_InitWorkRAM\n'
                  '     * copies WorkRamInit_Image to RAM 0x3D524).  TrackMixer_Init installs it as the PsMixer grid\n'
                  '     * array (Util_StoreGridArrayBase), PsMixer_ReadWordArrayEntry reads word [page*8 + column] as\n'
                  '     * the column\'s part, TrackMixer_UpdateHandler writes word [track] (0..15).  32 words: these 26\n'
                  '     * and TrackMixer_GridRowMapEnd (scripts/converters/naka_type_trackmixer_map.py)'),
         stop_comment=True),
    dict(name='ChordName_TypeRootTables', ctype='uint32_t', start=0x1624, end=0x1724, fmt='0x%08X', per=4,
         comment=('the chord-name lookup\'s first level: the power-on image of RAM 0x3F2F8, 64 RAM pointers, one\n'
                  '     * per chord type.  MainChordPre_AppendChordSuffix loads 0x3F2F8 and follows [4*DISPLAY_CHORD_TYPE],\n'
                  '     * then [4*DISPLAY_CHORD_ROOT] in the root table it points at (RAM 0x3F228 / 0x3F25C / 0x3F290 /\n'
                  '     * 0x3F2C4), then [4*DISPLAY_CHORD_BASS], and appends that string\n'
                  '     * (scripts/converters/naka_type_trackmixer_map.py)'),
         stop_comment=False),
]


def compile_c(tree, path, out):
    uw = os.path.join(ROOT, tree, 'maincpu', 'ui_widgets')
    ld = os.path.join(uw, 'naka_sequencer_channels_link.ld')
    subprocess.run([LLVM + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-Wno-comment',
                    '-I', uw, '-o', out + '.o', path], check=True)
    subprocess.run([LLVM + '/ld.lld', '-e', '0', '-T', ld, '-o', out + '.elf', out + '.o'], check=True)
    subprocess.run([LLVM + '/llvm-objcopy', '-O', 'binary', '-j', '.text', out + '.elf', out], check=True)
    return open(out, 'rb').read()


def apply_spec(s, sp, blob):
    lines = s.split('\n')
    first = last = None
    names = []
    for i, ln in enumerate(lines):
        m = MEMBER.match(ln)
        if not m:
            continue
        off = int(m.group(2), 16)
        if sp['start'] <= off < sp['end']:
            if first is None:
                first = i
            last = i
            names.append(m.group(1))
    if first is None or int(names[0][-4:], 16) != sp['start']:
        return None
    m = MEMBER.match(lines[last])
    size = {'uint8_t': 1, 'char': 1, 'uint16_t': 2, 'uint32_t': 4}[lines[last].split()[0]] * int(m.group(3) or 1)
    if int(m.group(2), 16) + size != sp['end']:
        sys.exit('naka_type_trackmixer_map: %s: the run does not end at 0x%X' % (sp['name'], sp['end']))
    for i in range(first, last + 1):
        if not (MEMBER.match(lines[i]) or re.match(r'^    /\* .*\*/$', lines[i])):
            sys.exit('naka_type_trackmixer_map: %s: unexpected line in the run: %s' % (sp['name'], lines[i]))
    stop = last + 1
    if sp['stop_comment']:      # orphan comments the old split left after the run
        while re.match(r'^    /\* (\d+ pointers|zero padding|NAKA_TYPE_\w+) \*/$', lines[stop]):
            stop += 1
    esz = {'uint16_t': 2, 'uint32_t': 4}[sp['ctype']]
    n = (sp['end'] - sp['start']) // esz
    decl = ['    /* ' + sp['comment'] + ' */', '    %s %s[%d];' % (sp['ctype'], sp['name'], n)]
    lines[first:stop] = decl
    s = '\n'.join(lines)
    vals = struct.unpack('<%d%s' % (n, 'H' if esz == 2 else 'I'), blob[sp['start']:sp['end']])
    rows = [', '.join(sp['fmt'] % v for v in vals[k:k + sp['per']]) for k in range(0, n, sp['per'])]
    init = '    .%s = {\n%s\n    },\n\n' % (sp['name'], '\n'.join('        %s,' % r for r in rows))
    pos = None
    for nm in names:
        mm = re.search(r'^    \.%s = (?:\{[^}]*\}|[^\n]*),\n\n' % re.escape(nm), s, re.M)
        if not mm:
            sys.exit('naka_type_trackmixer_map: no initializer for ' + nm)
        if pos is None:
            pos = mm.start()
            s = s[:mm.start()] + init + s[mm.end():]
        else:
            s = s[:mm.start()] + s[mm.end():]
    return s, len(names)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    ap.add_argument('--scratch', default=os.path.join(os.environ.get('TMPDIR', '/home/fsanches/compartilhado/tmp'),
                                                      'naka_type_trackmixer_map'))
    a = ap.parse_args()
    p = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_sequencer_channels.c')
    s = open(p, 'rb').read().decode('latin-1')
    os.makedirs(a.scratch, exist_ok=True)
    before = compile_c(a.tree, p, os.path.join(a.scratch, 'seqch_before.bin'))
    done = []
    for sp in SPECS:
        r = apply_spec(s, sp, before)
        if r is None:
            continue            # typed already
        s, k = r
        done.append('%s (%d members)' % (sp['name'], k))
    if not done:
        print('naka_type_trackmixer_map %s: nothing to do' % a.tree)
        return
    tmp = os.path.join(a.scratch, 'naka_sequencer_channels.c')
    open(tmp, 'wb').write(s.encode('latin-1'))
    after = compile_c(a.tree, tmp, os.path.join(a.scratch, 'seqch_after.bin'))
    if after != before:
        sys.exit('naka_type_trackmixer_map: %s: the compiled blob differs; not written' % a.tree)
    open(p, 'wb').write(s.encode('latin-1'))
    print('naka_type_trackmixer_map %s: %s' % (a.tree, ', '.join(done)))


if __name__ == '__main__':
    main()
