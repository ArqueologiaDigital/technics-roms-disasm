#!/usr/bin/env python3
"""headers_open4_engine.py -- lane open4/kn5000-b-engine (2026-10-31): routine headers and corrected
comments for the names that scripts/renaming/rename_open4_engine.sed introduced.

    python3 scripts/tools/headers_open4_engine.py            # edit in place (idempotent)
    python3 scripts/tools/headers_open4_engine.py --check    # exit 1 if anything is still to do

1. Main CPU v10/v9/v7/v6/v5: a version-neutral header (registers and symbol names only, no RAM
   numbers, since those move between versions) above each routine in HEADERS; any comment block
   directly above the label is replaced.
2. Exact text corrections (EDITS): each `old` must occur exactly once in its file, or `new` already.
Files are handled as bytes.  Evidence: notes/open4-kn5000-b/engine/README.md.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
ACC = 'maincpu/sequencer/accompaniment_engine.s'
SCOOP = 'maincpu/display/scoop_display.s'

VIEW = ('\n;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer\'s measure view,\n'
        ';   B = the section\'s last measure, D = the previous and E = the current play measure; returns C.\n')

HEADERS = {
    ACC: {
        'AccTiming_ScrollFourBarViewBack':
            '; AccTiming_ScrollFourBarViewBack: four-measure view: when C > 0, B > C + 2 and the play moved back from\n'
            ';   measure C + 1 (D) to C (E), scrolls the view one measure back, C = C - 1.' + VIEW,
        'AccTiming_WrapFourBarViewToEnd':
            '; AccTiming_WrapFourBarViewToEnd: four-measure view: when C = 0 and the play wrapped from measure 1 (D)\n'
            ';   to B + 1 (E), shows the last four measures, C = B - 3.' + VIEW,
        'AccTiming_WrapFourBarViewToStart':
            '; AccTiming_WrapFourBarViewToStart: four-measure view: when C = B - 3 and the play wrapped from measure\n'
            ';   B + 1 (D) to 1 (E), shows the first four measures, C = 0.' + VIEW,
        'AccTiming_ScrollTwoBarViewForward':
            '; AccTiming_ScrollTwoBarViewForward: two-measure view: when B > C + 1 and the play moved from measure\n'
            ';   C + 2 (D) to C + 3 (E), scrolls the view one measure on, C = C + 1.' + VIEW,
        'AccTiming_ScrollTwoBarViewBack':
            '; AccTiming_ScrollTwoBarViewBack: two-measure view: when C > 0, B > C and the play moved back from\n'
            ';   measure C + 1 (D) to C (E), C = C - 1.' + VIEW,
        'AccTiming_WrapTwoBarViewToEnd':
            '; AccTiming_WrapTwoBarViewToEnd: two-measure view: when C = 0 and the play wrapped from measure 1 (D)\n'
            ';   to B + 1 (E), shows the last two measures, C = B - 1.' + VIEW,
        'AccTiming_WrapTwoBarViewToStart':
            '; AccTiming_WrapTwoBarViewToStart: two-measure view: when C = B - 1 and the play wrapped from measure\n'
            ';   B + 1 (D) to 1 (E), shows the first two measures, C = 0.' + VIEW,
        'CmpStep_MoveRecPartTowardBass_Impl':
            '; CmpStep_MoveRecPartTowardBass_Impl: replaces the composer STEP title\'s record part (CMP_RECORD_PART) by\n'
            ';   its predecessor through the 32-byte map CmpStep_RecPartTowardBass_Map (DRM 16 -> AC3 4 -> AC2 2 ->\n'
            ';   AC1 1 -> BAS 8, BAS stays), then AudioInit_SelectAndDispatch, AudioMode_ResetVoiceState and\n'
            ';   DrumKit_UpdateStatusFlags. Basis: callers + body -- the opposite step of\n'
            ';   CmpStep_MoveRecPartTowardDrums_Impl; its XIZ wrapper is CmpStep_MoveRecPartTowardBass.\n',
        'CmpStep_MoveRecPartTowardBass':
            '; CmpStep_MoveRecPartTowardBass: XIZ-preserving call of CmpStep_MoveRecPartTowardBass_Impl (record part one\n'
            ';   step toward BAS). Basis: callers + body -- AccDraw_SecondarySub_Handler08 (TT_CMSTEP switch 8) calls it.\n',
        'ToneGen_ReplaceCursorNoteEvent':
            '; ToneGen_ReplaceCursorNoteEvent: replaces the note event at the pattern cursor by its converted form:\n'
            ';   saves its bytes (ToneGen_SaveCursorEventBytes), deletes it (ToneGen_DeleteEventAtCursor), builds the\n'
            ';   0x90 / 0x91 event (ToneGen_BuildConvertedNoteEvent) and inserts it (ToneGen_StepWithBoundsCheck).\n'
            ';   Basis: callers + body -- ToneGen_WriteMultiChanParam calls it when the stored status differs from the\n'
            ';   one it computes.\n',
    },
    SCOOP: {
        'SeqTrack_ReadByteAndAdvance':
            '; SeqTrack_ReadByteAndAdvance: reads the byte at the current track\'s song-data cursor\n'
            ';   (VoiceSlot_ReadCurrentParams) and moves the cursor one byte on (SeqTrack_AdvanceCursor, DE = 1).\n'
            ';   Out: A = the byte, W = 0 when the cursor moved, 0xff when it was at the end of the track.\n'
            ';   Basis: body + SeqTrack_AdvanceCursor.\n',
        'SeqTrack_AdvanceCursor':
            '; SeqTrack_AdvanceCursor: moves the current track\'s song-data cursor DE bytes on.  The cursor is a\n'
            ';   block number and an offset 5..255 into a 256-byte song block (5 header bytes: flags, prev, next;\n'
            ';   251 data bytes); past offset 255 it follows the next link (+3) once per 251 bytes.  When the\n'
            ';   cursor is in the track\'s tail block (the song record\'s per-track tail-block table) it may not pass\n'
            ';   the track\'s write offset (the per-track offset table 32 bytes after it).  Out: W = 0 when moved,\n'
            ';   0xff when the chain or the write offset stopped it (cursor unchanged).  Basis: body.\n',
    },
}

EDITS = [
    ('v10/' + ACC,
     '; (0 when B <= 3; else AccTiming_ScrollFourBarViewForward, AccTiming_ScrollFourBarViewBack,\n'
     '; _CheckRoot1, _CheckInversion1); with more a two-measure view (0 when B <= 1; else\n'
     '; AccTiming_ScrollTwoBarViewForward, _CheckMirror, _CheckRoot2, _CheckInversion2).  Then 0x3747 = E and\n',
     '; (0 when B <= 3; else AccTiming_ScrollFourBarViewForward, AccTiming_ScrollFourBarViewBack,\n'
     '; AccTiming_WrapFourBarViewToEnd, AccTiming_WrapFourBarViewToStart); with more a two-measure view (0 when\n'
     '; B <= 1; else AccTiming_ScrollTwoBarViewForward, AccTiming_ScrollTwoBarViewBack,\n'
     '; AccTiming_WrapTwoBarViewToEnd, AccTiming_WrapTwoBarViewToStart).  Then 0x3747 = E and\n'),
    ('v142/subcpu/kn5000_subprogram_v142.s',
     '; Fast path: if the 32-bit global at 0x1345 is non-zero it is returned unconditionally\n'
     ';   (a forced/override node).\n'
     '; Walk: for each byte b of the list - if bit7 is set the pool head is read from the\n'
     ';   global pointer array at 0x130F indexed by (b & 0x7F)*4, otherwise from the array\n',
     '; Fast path: the 32-bit word at 0x1345 is the FREE list, the class-6 head of pool 17\n'
     ';   (pool record 0x132B = 0x112D + 17*30, filled by Voice_Retire_ToFreePool): a free\n'
     ';   voice is always taken first.  (This was read as a "forced/override node".)\n'
     '; Walk: for each byte b of the list - if bit7 is set the pool head is read from the\n'
     ';   class heads of pool 16 (record 0x130D, heads at 0x130F; the victims that\n'
     ';   Voice_Allocate_Nodes_StealAtQuota parks there) indexed by (b & 0x7F)*4, otherwise from the array\n'),
    ('v142/subcpu/kn5000_subprogram_v142.s',
     '; In:  XWA = part descriptor; the local pool array is at XWA+2.\n'
     '; Out: XHL = first non-empty pool head, or 0.\n'
     '; Uses the fixed ROM priority list at 0x00F603 (06 05 02 04 03 01 00 FF) and, unlike\n'
     '; Voice_Find_Candidate, has no bit7 escape to the global array and no 0x1345 override.\n',
     '; In:  XWA = a 30-byte pool record (node+0x1D: +0 quota, +1 count, +2 seven class heads).\n'
     '; Out: XHL = first non-empty class head, or 0.\n'
     '; Uses the fixed ROM order Voice_StealPoolOrder (classes 6 5 2 4 3 1 0: decayed, released,\n'
     '; then sounding) and, unlike Voice_Find_Candidate, neither pool 16 nor the free list.\n'),
    ('v142/subcpu/kn5000_subprogram_v142.s',
     '; Polyphony accounting: part active count is (part_desc+1), limit is (part_desc+0); if below the limit just increment it.\n',
     '; Polyphony accounting: the pool record (node+0x1D) holds the quota at +0 and the count at +1; below the quota just count the node.\n'),
    ('v142/subcpu/kn5000_subprogram_v142.s',
     '; At the limit - steal: Voice_FindStealCandidate picks a victim node, it is re-keyed into the list at 0x130D with its own (node+0x21) key, the count is bumped and flag bit4 is set on it.\n',
     '; At the quota - steal: Voice_FindStealCandidate picks a victim in the same pool, it moves to pool 16 (record 0x130D) under its own class (node+0x21), the count is bumped and flag bit4 is set on it.\n'),
    ('v142/subcpu/subcpu_data_tables.s',
     '; --- 0x00F597-0x00F602  (Voice_Part_PoolPtr_ModeB) -- 27 x u32 pointers, channel -> section record, mode B\n'
     '; \xe2\x98\x85 0x00F597 is NOT a pitch table. Both tables have identical shape and are read by the same\n',
     '; --- 0x00F597-0x00F602  Voice_Part_PoolPtr_ModeB -- 27 x u32 pointers, channel -> section record, mode B\n'
     '; (It was called Voice_Pitch_Table_High; it is not a pitch table.) Both tables have identical shape and are read by the same\n'),
    ('v142/subcpu/subcpu_data_tables.s',
     '; --- 0x00F603-0x00F632  (Voice_StealPoolOrder) -- FOUR 0xFF-terminated voice search-order lists\n',
     '; --- 0x00F603-0x00F632  Voice_StealPoolOrder + Voice_Search_Order_List_1..3 -- FOUR 0xFF-terminated voice search-order lists\n'),
    ('v142/subcpu/subcpu_data_tables.s',
     '; --- 0x00F633-0x00F692  (Voice_LayerClassTable) -- 16 x 6-byte slot-type descriptors\n',
     '; --- 0x00F633-0x00F692  Voice_LayerClassTable -- 16 x 6-byte slot-type descriptors\n'),
    ('v142/subcpu/subcpu_data_tables.s',
     '; priority_key is passed to Voice_List_MoveToPool; node_param is stored in\n'
     '; (voice+0x26) at 0x022406.\n',
     '; priority_key is the pool class the node joins when allocated (Voice_List_MoveToPool);\n'
     '; node_param, stored in (voice+0x26) at 0x022406, is the class it moves to when the note is\n'
     '; released (Voice_Reprioritise).  Pool classes: 0-2 sounding, 3-5 released, 6 decayed / free.\n'),
]


def label_index(lines, label):
    want = label.encode() + b':'
    hits = [i for i, l in enumerate(lines) if l == want]
    if len(hits) > 1:
        raise SystemExit('label %s found %d times' % (label, len(hits)))
    return hits[0] if hits else None


def main():
    check = '--check' in sys.argv
    todo = set()
    for t in TREES:
        for rel, heads in HEADERS.items():
            p = os.path.join(ROOT, t, rel)
            lines = open(p, 'rb').read().split(b'\n')
            changed = False
            for label, text in heads.items():
                want = text.encode().rstrip(b'\n').split(b'\n')
                i = label_index(lines, label)
                if i is None:
                    print('note: %s has no %s' % (t, label))
                    continue
                j = i
                while j > 0 and lines[j - 1].startswith(b';'):
                    j -= 1
                if lines[j:i] != want:
                    lines[j:i] = want
                    changed = True
            if changed:
                todo.add(p)
                if not check:
                    open(p, 'wb').write(b'\n'.join(lines))
    for rel, old, new in EDITS:
        p = os.path.join(ROOT, rel)
        data = open(p, 'rb').read()
        o, n = old.encode('latin-1') if '\xe2' in old else old.encode(), new.encode()
        if data.count(n) == 1 and data.count(o) == 0:
            continue
        if data.count(o) != 1:
            raise SystemExit('%s: old text found %d times: %r' % (rel, data.count(o), old[:60]))
        todo.add(p)
        if not check:
            open(p, 'wb').write(data.replace(o, n))
    for p in sorted(todo):
        print(('would edit ' if check else 'edited ') + os.path.relpath(p, ROOT))
    if check and todo:
        sys.exit(1)


if __name__ == '__main__':
    main()
