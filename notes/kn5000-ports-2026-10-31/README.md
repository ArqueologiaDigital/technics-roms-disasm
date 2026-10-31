# KN5000 ported trees: label shifts, link scripts, v1 replays, v1 prose, port debt

Lane `open3/kn5000-ports`, 2026-10-31, base main 43242446d.  Probes: `../kn5000-ports-probes/`
(README there: what each script answers, how to run it, the signals it reads).

## 1. Names v6 and v5 inherited from v7, checked against the firmware's own tables

`scripts/converters/port_maincpu_version.py` keeps v7's label names; the byte gate cannot see a
name put on the wrong thing, and `scripts/analysis/check_ported_labels.py` (12-byte windows)
cannot see one moved onto the next of a run of look-alike procedures.  The first such shift (v5's
Yoko language checks) was found by reading v5's ApFunction table and its name table.

`../kn5000-ports-probes/ported_label_probe.py` does that for every registration of the firmware
(Function / ApFunction / MainFunction tables and their name tables at slot + 0x300, Viewable tables
and their ResName tables, the Class tables), for every pointer table of the v7 ROM, and for the
bodies that name each label.  `scripts/tools/port_fix_label_shifts.py` puts each name back
(renames through temporary names, content-checked, rebuilt byte-identical per round, repeated
until nothing is left), with HAND lists for the shifts the evidence leaves undecided.

What was found (all fixed; `v6-label-moves.txt`, `v5-label-moves.txt` here list every address
whose name changed, 595 in v6 and 633 in v5, from `llvm-nm` before and after):

| where                                            | tree   | evidence                                         | was                                                                                            |
|--------------------------------------------------|--------|--------------------------------------------------|------------------------------------------------------------------------------------------------|
| ApFunction slot 0x121 (Murai)                    | v6, v5 | name table: entry 33 "BitmapAccita16"            | BitmapAccita16 / BitmapDrawsw one procedure late, their _DataPtr / _Width / _Height            |
| ApFunction slot 0x122 (Toshi)                    | v6, v5 | name table: "SysSureLngCheck", "SureLngCheck"    | both one procedure late                                                                        |
| ApFunction slot 0x128 (Kubo)                     | v5     | name table: AttAttentionCheck .. StsAtPunchCheck | the second language-check shift: 11 names one procedure late, entry 0 unlabelled               |
| SeqRingBuf_WriteDispatch_Table                   | v6, v5 | table slots 1, 3, 4                              | SeqDMA_MultiWrite_VoiceMap / DspSysEx / SoundEdit one place off, and the SeqBuf_* they call    |
| SndDispatch_JumpTable_Main                       | v6, v5 | slots 2, 3, 5, 6                                 | SndDispatch_Handler_2 on TableEntryBegin, Handler_2 on Handler_1_Data2                         |
| PerfMode_ParamHandler_Table (odd address)        | v6, v5 | slots 5, 7                                       | PerfMode_ParamHandler_5 / _7 swapped, with PerfMode_EventTable_5                               |
| NoteNameStr_Table_0                              | v5     | slots 0-10, content of the strings               | the table label four entries late (its first four entries were TODO(port) rows)                |
| SeGfx static-op wrappers                         | v5     | the op each wrapper calls                        | SeGfx_StaticOp15_FromBuf on v7's _Op05 wrapper, Op15's under a porter name                     |
| VoiceTable_AdvanceWritePos                       | v6, v5 | VoiceScan_WriteLoop's body; the counter code     | on a `pop xde` inside CmpNcpTtl_TableDispatch_OnToItemNext                                     |
| SeMenu_CopyWriteUpdate_Step3_Join3 .. Join32 ... | v6, v5 | the title OnHide / OnDraw that jumps to each     | each stub named one off (and the other numbered block families of that kind)                   |
| v7 names the port dropped                        | v6, v5 | table slots (UNLABELLED) or bodies + bytes       | the thing under a porter name (`_Data`, `_Helper`): SeqChan_XferStep_*, SysEx_OnGmSystemOn ... |

Probe after the fixes: registry, ptrtab and body MISMATCH 0 in both trees (exit 0).  Left, read
by hand and not shifts:

- UNDECIDED 4 per tree, code changes: AccTone_DirectAddr_Mode1 (v6 and v5 test a third mode and
  jump past it), RhythmParam_CheckExit (RhythmParam_TypeCheck reads other flags),
  Tempo_DisplayEffectLookup (different code in v6/v5), Voice_ClearSlotAndRet (`ld (0x38e0), 0`,
  not `ld (xhl), 0`).
- DROPPED 212 (v6) / 216 (v5): bodies say which v7 name a porter-named thing would take, but its
  bytes are not v7's in a 32-byte window, so the name is not given.  Listed by the probe.

`check_ported_labels.py`: v7 -> v6 misplaced 189 -> 101, same 34,317 -> 34,715, only-in-v7
1,717 -> 1,337; v7 -> v5 misplaced 191 -> 89; v6 -> v5 19 -> 17 (the rest are short repetitive
items, as its docstring warns).  The earlier `scripts/renaming/rename_v5_langcheck_shift.sed`
stays in v5's sequence (it ran first; the probe now pins the same names).

## 2. ctlonly_link.ld

The four Scoop_* lines (Scoop_GlideParam_Data, Scoop_Dispatch_Nop, _CallFAA98A, _CallFAB273) held
v10's addresses in v7, v6 and v5; the other eight v7 lines did too (v7's json patched them).  The
36 handler words of `style_ui/ctlonly.c` are not in any image: every tree spells
Scoop_StaticOpHandlerTable as `.long` lines.  `scripts/tools/port_symbolize_pointers.py relink`
refused because it compared every byte of a bin; it now counts only the bytes some
`.incbin "includes/generated/<bin>", off, len` puts in the image, and also takes `--tree v7`
(Makefile `v7-c-bins-raw` / `v7-c-bins`).

| tree | link-script lines wrong (`link_script_names.py`) | divergence json entries      |
|------|--------------------------------------------------|------------------------------|
| v7   | 53 -> 7                                          | 846 -> 810 (ctlonly 36 -> 0) |
| v6   | 4 -> 0                                           | 13,792 -> 13,791             |
| v5   | 4 -> 0                                           | 15,775 -> 15,774             |

v7's 7 left (naka_technichord_part 5, naka_technichord_strings 1 script; NakaState_ZeroBlock_4,
Naka_PresentationRootState, PlySngSel2Func) are refused: the v7 image needs the values the lines
hold, so the C there names other things than the v7 labels of those names.  v9 has 2 (not touched).

## 3. The v1 replays

Both replays need `make all` first (in a fresh worktree without it the v1.15i replay names GUI
objects generically, 7 files differ).  With it, at 43242446d:

- `port-edits-v1_15i/replay.sh` rebuilds `hdae5000_v1_15i/` equal to the committed tree (0 lines).
- `port-edits-v1_10i/replay.sh` rebuilt a byte-identical tree 5 files off the committed one (108
  lines in, 122 out: v1.10i's own quoted addresses and counts, no FilePanel labels).  That output is
  now the committed tree (symbols 6,692 -> 6,690, menu map unchanged).

After item 4 both replays were run again at 7d4d44a63 (see the end of this file for the result).

## 4. v2.x prose in the v1 trees

`port-edits-v1_15i/94b_v1_prose.py` corrects 25 block comments per tree, each checked in the v1
code (its docstring): eight parts LSW..MD, three setting bytes in sector 1, ten class records, no
FilePanel / Alloc_Memory_3, no lyric settings, eight save and delete option flags, the Svc13
header, the CODE SECTION 1 list by name instead of v2.06i's addresses, and the record-table
EVIDENCE block marked as v2.06i's.  `hdae5000_version_stale_comments.py v1_15i --base v2_01i`
stays 0.  Both replays run it.

## 5. Port debt (`kn5000_source_coverage.py`, verbatim bytes)

| tree | before (43242446d) | after  | TODO(port) rows left | C-divergence raw bytes |
|------|--------------------|--------|----------------------|------------------------|
| v6   | 16,502             | 13,756 | 3,403                | 10,353                 |
| v5   | 19,310             | 15,910 | 4,284                | 11,626                 |

(The repo-root CLAUDE.md said 17,159 / 19,978, measured 2026-10-29; the 2026-10-31 lanes before
this one had already lowered them.)  `scripts/converters/port_todo_typed.py` wrote 2,746 (v6) and
3,400 (v5) bytes of the rows as `.long Label`, `.asciz` and `aligned_string`.  What is left:

- the rows: NAKA widget record fields (class ids, u16 links, rects) and pointer words whose target
  has no label; they need the NAKA record macros (`scripts/converters/naka_asm_records.py`) taught
  the v6 / v5 layouts;
- the json raw bytes: v7's C describes v7's data, and v6 / v5 differ inside naka_style_bitmaps
  (2,720 / 2,739), naka_disk_menu_file_io (2,050 / 2,057), naka_widget_names_charmap,
  naka_extension_device, naka_technichord_* ...; they need per-version C (or typed slices).

## Order to regenerate (each tree's README has the full sequence)

    python3 scripts/converters/port_todo_typed.py --tree v6
    python3 scripts/tools/port_fix_label_shifts.py --tree v6
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v6
    python3 scripts/analysis/l2_symbol_reference.py --regen --only maincpu_v6
    (the same for v5; then relink --tree v7)
