#!/usr/bin/env python3
"""respell_open4_engine_tables.py -- lane open4/kn5000-b-engine (2026-10-31), one-shot respellings.

Run after scripts/renaming/rename_open4_engine.sed (it uses the new names):
    python3 scripts/tools/respell_open4_engine_tables.py            # edit in place
    python3 scripts/tools/respell_open4_engine_tables.py --check    # exit 1 if anything is still to do

1. Main CPU v10/v9/v7/v6/v5: CmpStep_RecPartTowardBass_Map / CmpStep_RecPartTowardDrums_Map, two
   32-byte record-part maps that the disassembly spelled as instructions (nop, `ld (1:8), 0:io`,
   `push sr`, `rcf` ...), become `.byte` rows.  The lines replaced must add up to exactly 32 bytes
   (the instruction sizes are listed below), so the build stays byte-identical.
2. Main CPU v10/v9/v7/v6/v5: each of the 41 ChordTables_TypeIntervals rows gets its chord type number
   and name, and ChordRecog_IntervalMaskTable's "[INFERENCE]" line is replaced by what
   notes/open4-kn5000-b/engine/probes/chord_table_check.py measured.
3. Sub CPU v142: Voice_LayerClassTable's 16 six-byte records become {.long list, .byte class, param};
   Voice_Part_PoolPtr_ModeB's 27 pointers become `.long 0x112d + 30*k` like its mode-A twin.
The files are read and written as bytes (they hold non-UTF-8 .ascii).  Evidence:
notes/open4-kn5000-b/engine/README.md.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ['v10', 'v9', 'v7', 'v6', 'v5']

SIZES = [(re.compile(rb'^\tnop$'), 1), (re.compile(rb'^\tpush\tsr$'), 1), (re.compile(rb'^\trcf$'), 1),
         (re.compile(rb'^\tld\t\((1|P0):8\), 0:io$'), 3), (re.compile(rb'^\t\.zero (\d+)$'), None),
         (re.compile(rb'^\t\.byte (0x[0-9a-f]{2})$'), 1)]

MAPS = {
    b'CmpStep_RecPartTowardBass_Map': (
        b'; Indexed by CMP_RECORD_PART & 31 (CmpStep_MoveRecPartTowardBass_Impl); only the part codes\n'
        b'; 1 AC1, 2 AC2, 4 AC3, 8 BAS and 16 DRM are ever read.\n',
        [b'\t.byte\t0x00, 0x08, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00\t; AC1 -> BAS, AC2 -> AC1, AC3 -> AC2\n',
         b'\t.byte\t0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00\t; BAS stays\n',
         b'\t.byte\t0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00\t; DRM -> AC3\n',
         b'\t.zero\t8\n']),
    b'CmpStep_RecPartTowardDrums_Map': (
        b'; Indexed by CMP_RECORD_PART & 31 (CmpStep_MoveRecPartTowardDrums_Impl); only the part codes\n'
        b'; 1 AC1, 2 AC2, 4 AC3, 8 BAS and 16 DRM are ever read.\n',
        [b'\t.byte\t0x00, 0x02, 0x04, 0x00, 0x10, 0x00, 0x00, 0x00\t; AC1 -> AC2, AC2 -> AC3, AC3 -> DRM\n',
         b'\t.byte\t0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00\t; BAS -> AC1\n',
         b'\t.byte\t0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00\t; DRM stays\n',
         b'\t.zero\t8\n']),
}


def size_of(line):
    for rx, n in SIZES:
        m = rx.match(line)
        if m:
            return int(m.group(1)) if n is None else n
    return None


def respell_map(data, label, path):
    head, rows = MAPS[label]
    lines = data.split(b'\n')
    try:
        i = lines.index(label + b':')
    except ValueError:
        if (label + b':\n' + rows[0]) in data:
            return data, False
        raise SystemExit('%s: %s not found' % (path, label.decode()))
    if lines[i + 1].startswith(b'\t.byte\t0x00, 0x0'):
        return data, False
    total, j = 0, i + 1
    while total < 32:
        n = size_of(lines[j])
        if n is None:
            raise SystemExit('%s: %s: unexpected line %r after %d bytes' % (path, label.decode(), lines[j], total))
        total += n
        j += 1
    if total != 32:
        raise SystemExit('%s: %s: lines add up to %d bytes, not 32' % (path, label.decode(), total))
    new = [head.rstrip(b'\n')] if not lines[i - 1].startswith(b'; Indexed by CMP_RECORD_PART') else []
    new += [label + b':'] + [r.rstrip(b'\n') for r in rows]
    lines[i:j] = new
    return b'\n'.join(lines), True


CHORD_NAMES = ['M', '7', 'M7', 'aug', 'm', 'm7', 'dim7', 'm7(b5)', 'mM7', '7sus4', '6', '7(#5)', '(b5)',
               '7(b5)', '9', '7(b9)', 'M7(9)', '6(9)', 'm6', 'dim', 'm7(9)', 'm6(9)', 'sus4', '7(#9)',
               'M7(b5)', 'M7(#5)', 'mM7(b5)', '7(13)', '7(#5)', '7(13)'] + ['no voicing'] * 9 + ['add9', 'madd9']
OLD_INF = b'; [INFERENCE] the fingered-chord recognition table (chord type, root offset).\n'
NEW_INF = (b'; The fingered-chord recognition table: +0 = chord type (1-based row of ChordTables_TypeIntervals),\n'
           b'; +1 bits 0-6 = root offset in semitones above the reference note, bit 7 = accept without trying\n'
           b'; fewer notes.  Checked on all 292 non-zero entries by\n'
           b'; notes/open4-kn5000-b/engine/probes/chord_table_check.py (types 31-39 have no voicing row).\n')


def annotate_chords(data):
    changed = False
    if OLD_INF in data:
        data = data.replace(OLD_INF, NEW_INF)
        changed = True
    lines = data.split(b'\n')
    if b'ChordTables_TypeIntervals:' not in lines:
        return data, changed
    i = lines.index(b'ChordTables_TypeIntervals:')
    for k in range(41):
        ln = lines[i + 1 + k]
        assert re.match(rb'^\t\.byte[ \t]0x[0-9a-f]{2}, 0x[0-9a-f]{2}, 0x[0-9a-f]{2}, 0x[0-9a-f]{2}', ln), ln
        if b';' not in ln:
            lines[i + 1 + k] = ln + b'\t; type %d: %s' % (k + 1, CHORD_NAMES[k].encode())
            changed = True
    return b'\n'.join(lines), changed


def respell_v142(data):
    changed = False
    old_start = data.find(b'Voice_LayerClassTable:\n\t.byte 0x0b, 0xf6')
    if old_start >= 0:
        end = data.index(b'\n\n', old_start)
        block = data[old_start:end].split(b'\n')[1:]
        raw = bytes(int(x, 16) for row in block for x in row.replace(b'\t.byte ', b'').split(b', '))
        assert len(raw) == 96, len(raw)
        lists = {0xF60B: b'Voice_Search_Order_List_1', 0xF61A: b'Voice_Search_Order_List_2',
                 0xF628: b'Voice_Search_Order_List_3'}
        out = [b'Voice_LayerClassTable:']
        for k in range(16):
            rec = raw[6 * k:6 * k + 6]
            ptr = int.from_bytes(rec[:4], 'little')
            out.append(b'\t.long\t%s\t; slot class %d' % (lists[ptr], k))
            out.append(b'\t.byte\t%d, %d\t\t\t; allocation pool key, released pool key' % (rec[4], rec[5]))
        data = data[:old_start] + b'\n'.join(out) + data[end:]
        changed = True
    old_start = data.find(b'Voice_Part_PoolPtr_ModeB:\n\t.byte 0x2d, 0x11')
    if old_start >= 0:
        end = data.index(b'\n\n', old_start)
        block = data[old_start:end].split(b'\n')[1:]
        out = [b'Voice_Part_PoolPtr_ModeB:']
        for p, row in enumerate(block):
            b4 = bytes(int(x, 16) for x in row.replace(b'\t.byte ', b'').split(b', '))
            g, r = divmod(int.from_bytes(b4, 'little') - 0x112D, 30)
            assert r == 0 and 0 <= g < 18, row
            out.append(b'\t.long 0x112d + 30*%d\t\t; part %d -> pool %d' % (g, p, g))
        assert len(out) == 28, len(out)
        data = data[:old_start] + b'\n'.join(out) + data[end:]
        changed = True
    return data, changed


def main():
    check = '--check' in sys.argv
    todo = []
    for t in TREES:
        p = os.path.join(ROOT, t, 'maincpu/sequencer/accompaniment_engine.s')
        data = open(p, 'rb').read()
        any_change = False
        for label in MAPS:
            data, ch = respell_map(data, label, p)
            any_change |= ch
        if any_change:
            todo.append(p)
            if not check:
                open(p, 'wb').write(data)
        for rel in ('maincpu/audio/note_voice_mapping.s', 'maincpu/ui_widgets/widget_dispatch.s'):
            p = os.path.join(ROOT, t, rel)
            data, ch = annotate_chords(open(p, 'rb').read())
            if ch:
                todo.append(p)
                if not check:
                    open(p, 'wb').write(data)
    p = os.path.join(ROOT, 'v142/subcpu/subcpu_data_tables.s')
    data, ch = respell_v142(open(p, 'rb').read())
    if ch:
        todo.append(p)
        if not check:
            open(p, 'wb').write(data)
    for p in todo:
        print(('would respell ' if check else 'respelled ') + os.path.relpath(p, ROOT))
    if check and todo:
        sys.exit(1)


if __name__ == '__main__':
    main()
