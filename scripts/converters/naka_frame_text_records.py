#!/usr/bin/env python3
r"""naka_frame_text_records.py -- end the NAKA records whose text follows them under their label where they end.

QUESTION ANSWERED
-----------------
"Why does naka_asm_records.py --apply skip the FDTest elements of Viewable slot 0xFC and six of slot
0x2?" (register item N-2f640c1d).  --apply rewrites a record only when its label starts a block of plain
data lines that ends exactly at the record's last byte.  Seven FDTest records of
factory_test/fd_test_data.s do not meet that:

  * FDTest_DiagList_NG / _OK (PsNumEditBox), FDTest_Label_MemoryDump (Label),
    FDTest_Container_DebugHDAE2 (TtlScreen) and FDTest_ConsoleArea2 (AcScreenMenu, class 0x01600041):
    the record's text, an `aligned_string` its `str` / `title` field points at, follows it under the
    same label -- their siblings give that text a label of its own (FDTest_String_Load2 ...);
  * FDTest_Group_OnOff (Box) and FDTest_MenuItem_Go1 (VwEditSwBox): a `.zero N` line (not a plain data
    line for the tool) holds zero fields.

and in ui_widgets/naka_sound_technichord_dispatch.s (the sound menu, slot 0x2) five AcTitleMenu entries
(NakaMenuItem_MasterTuning, _Reverb, _Equalizer, _DspEffect, _LeftHold) hold their caption the same way,
where their siblings have MenuStr_<entry> (MenuStr_KeyScaling ...), and NakaWidget_SoundEdit (AcSndEMenu)
has a `.zero 4`.

This gives each of those texts a label named as its siblings' are (FDTest_String_<record>,
MenuStr_<entry>), and spells the `.zero` runs as `.long 0` rows; then naka_asm_records.py --apply writes
the 13 as macro calls whose text fields name those labels.  The image does not change (make gate).

RUN (repository root, built tree), per tree v10, v9, v7:
    python3 scripts/converters/naka_frame_text_records.py --tree v10
    make <tree's program ROM>
    python3 scripts/converters/naka_asm_records.py --tree v10 --apply
It skips a file it has already converted (lane kn5000-naka2 ran the FDTest part first, as
naka_frame_fdtest_records.py, then added the sound menu's).
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = {
    'factory_test/fd_test_data.s': (
        {'FDTest_DiagList_NG': 'FDTest_String_DiagList_NG',
         'FDTest_DiagList_OK': 'FDTest_String_DiagList_OK',
         'FDTest_Label_MemoryDump': 'FDTest_String_MemoryDump',
         'FDTest_Container_DebugHDAE2': 'FDTest_String_DebugHDAE2',
         'FDTest_ConsoleArea2': 'FDTest_String_ConsoleArea2'},
        ('FDTest_Group_OnOff', 'FDTest_MenuItem_Go1')),
    'ui_widgets/naka_sound_technichord_dispatch.s': (
        {'NakaMenuItem_MasterTuning': 'MenuStr_MasterTuning',
         'NakaMenuItem_Reverb': 'MenuStr_Reverb',
         'NakaMenuItem_Equalizer': 'MenuStr_Equalizer',
         'NakaMenuItem_DspEffect': 'MenuStr_DspEffect',
         'NakaMenuItem_LeftHold': 'MenuStr_LeftHold'},
        ('NakaWidget_SoundEdit',)),
}


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def block(lines, lab):
    """(first, end) line indices of the block under `lab:` (to the next column-0 label)"""
    i = next(k for k, l in enumerate(lines) if l == lab + ':')
    j = i + 1
    while j < len(lines) and not re.match(r'^[A-Za-z_]\w*:', lines[j]):
        j += 1
    return i, j


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    a = ap.parse_args()
    for rel, (text_records, zero_records) in FILES.items():
        p = os.path.join(ROOT, a.tree, 'maincpu', rel)
        L = rd(p).split('\n')
        first = next(iter(text_records.values()))
        if any(l.startswith(first + ':') for l in L):
            print('naka_frame_text_records %s: %s already converted' % (a.tree, rel))
            continue
        for lab, slab in text_records.items():
            i, j = block(L, lab)
            s = [k for k in range(i + 1, j) if L[k].lstrip().startswith('aligned_string ')]
            assert len(s) == 1 and s[0] == j - 1, (lab, s, j)
            L[s[0]] = '%s:\t%s' % (slab, L[s[0]].strip())
        for lab in zero_records:
            i, j = block(L, lab)
            z = [k for k in range(i + 1, j) if re.match(r'^\t\.zero\s+(\d+)\s*$', L[k])]
            assert len(z) == 1, (lab, z)
            n = int(re.match(r'^\t\.zero\s+(\d+)', L[z[0]]).group(1))
            assert n % 4 == 0, (lab, n)
            L[z[0]] = '\t.long\t' + ', '.join(['0'] * (n // 4))
        wr(p, '\n'.join(L))
        print('naka_frame_text_records %s: %s: %d texts labelled, %d .zero runs spelled as .long'
              % (a.tree, rel, len(text_records), len(zero_records)))


if __name__ == '__main__':
    main()
