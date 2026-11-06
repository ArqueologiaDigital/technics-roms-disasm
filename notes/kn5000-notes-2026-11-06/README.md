# Lane kn5000-notes (wave 10, 2026-11-06): accompaniment questions and NAKA C debt

Base main a385de42f, branch `open10/kn5000-notes`.  Items: N-4d5d5317, N-5f302102, N-870a801e, N-1d99fc9b
(accompaniment, from `notes/open6-kn5000-d/accomp/README.md`), N-45db7885, N-2f640c1d, N-7c99f0f2, N-d8cf1242
(NAKA C, from `notes/data-semantics-2026-10-29/gui-kn5000/README.md`) and N-51b2e19c (flag bytes, from
`notes/ram-naming-2026-10-24/README.md`).  Addresses are v10 main-CPU addresses.  Statements without a tag are
read from the code; `[INFERENCE]` marks the rest.

## Accompaniment

### The sounding-note tables 0x3094 / 0x30C4 (N-4d5d5317, CLOSED)

The six tables are now `ACC_DRUM1_NOTES`, `ACC_DRUM2_NOTES` (8 slots x 6 bytes) and `ACC_BASS_NOTES`,
`ACC_ACCOMP1_NOTES` .. `ACC_ACCOMP3_NOTES` (8 x 9 bytes), in `ram/acc_notes_names.txt` (applied to v10 / v9 / v7
with `scripts/tools/add_kn5000_ram_names.py`).  A drum slot, read from its writer `AccKbdTiming_WriteNoteEvent`
and its reader `AccKbdTiming_TableScan` (sequencer/accompaniment_engine.s):

| byte  | meaning                                                                                    |
|-------|--------------------------------------------------------------------------------------------|
| +0    | the ring record's status, 0x90; bit 7 set = sounding, cleared (`and 0x7f`) at the note-off |
| +1    | 0 (written 0, read by none of the table's walkers; the ring record's tick byte)            |
| +2    | note, as sent                                                                              |
| +3    | velocity                                                                                   |
| +4/+5 | time left, high byte beats, low byte ticks 0..95; at least 10 ticks for a drum note        |

The note goes out on channel nibble 8 (`or a, 0x8`, both drum parts).  When all eight slots sound,
`AccKbdTiming_SlotOverflow` sends the note-off of slot `ACC_SLOT_STEAL_INDEX` (round-robin through
`AccTiming_SlotOffsetTables`) and reuses it.  `AccTiming_MasterTick` / `AccTiming_InitAllParts` count every slot
down by the clock delta (`ACC_SLOT_STRIDE`, `ACC_SLOT_TABLE_SIZE` select the table shape) and keep
`ACC_NEXT_NOTE_OFF`, the least time left, which `SeqTiming_Snapshot` compares with.  The 9-byte slots of the other
four parts add the ring record's tail at +6 (0x90: the pattern note; 0x91: ext1, ext2, pattern note; 0x92: two
bytes), which `Rhythm_ValidateAndSend` re-converts on a chord change.  `AccEnding_StopWhenSilent` ORs byte +0 of
every slot: the accompaniment stops after an ending once no bit 7 is left.  The routine that was called
`AccompVoice_BulkReadRegisters` only clears byte +0 of every slot (no note-off); it is `AccNotes_ForgetAllSounding`.

### 0x3283 bits 0 / 1 and 0x3328's writers (N-5f302102, CLOSED)

`ACC_RUN_FLAGS` (0x3283): `Seq_ProcessAllInputState` copies bit 2 of `ACC_TRANSPORT_STATE` (running) into bit 0 at
the start of every accompaniment tick; `Rhythm_SaveState` copies bit 0 into bit 1 at its end.  So bits 0 and 1 both
set = the accompaniment ran through the last two ticks.  The synchro test (`AccSynchro_StartOrCancelStop` /
`_StartOrCancelStopSong`, accompaniment_engine.s): a chord key while `ACC_TRANSPORT_STATE` bit 2 is clear but bits 0
and 1 are set (it has stopped since the last tick) sets `ACC_SYNCHRO_STATE` bit 0 (bit 1 for the song case)
instead of bit 2: the start is deferred to the main loop, where `AccAutoPlay_DeferredAction` starts it and runs
`AccReplay_FullRestart`, which waits (up to 0x200 polls of `RhythmBuf_CheckEmpty`) for the rhythm byte stream to
drain first.  A chord key on a longer-stopped accompaniment starts it at once.  Bit 2 is the ending-parked bit of
the open6 note.  The 30 bit-0 tests elsewhere use it as "running this tick".

`ACC_LANES_ENDED` (0x3328): set per lane by `AccVoice_ParkLaneAtEnd` (end marker during an ending),
`AccKbd2_CheckActive` and `AccPart_Reactivate` (bar end during an ending), together with `ACC_LANES_PARKED`; cleared
whole by `AccStyle_ResetAllVoiceState` and the five section starts (`AccSection_StartIntro_SetMasks`, `_Mode2`,
`_Mode3`, `AccSection_StartFillIn_SetForward`, `_SetReverse`).  Unlike `ACC_LANES_PARKED` it is not cleared when all
six lanes are in.  Readers: `AccVoice_HandleMarker83` (a lane in it stays parked), `AccVoice_SelectByMask` (counts as
a section lane for the bank choice), `SeqPlay_HandleEvent_SyncTiming` (an ending still in effect).

### What sets CHORD_FLAGS / 0x32D7 bit 0 (N-870a801e, CLOSED: nothing)

Every write of `CHORD_FLAGS` (0xCEDE), the song chord's `SEQ_CHORD_FLAGS` (0x2306) and `ACC_CHORD_FLAGS` (0x32D7)
in v10, v9 and v7 was listed (`kn5000_ram_bit_usage.py --name CHORD_FLAGS`, plus every whole-byte store and
memory-to-memory move):

- bit instructions: bit 0 is only cleared (`and 254` in `NoteDisplay_ClearAndSetUpdate`, `NoteDisplay_InitState`,
  `NoteDisplay_SetOverlayFlags`, `NoteDisplay_SetUpdateFlags`), never set;
- whole-byte stores copy a byte that is itself a CHORD_FLAGS value: the save / restore through 0xCEC0
  (`VoiceSlot_CheckAndApply_LoadReg_*`), the stack save / restore of `NoteDisplay_StoreAndDispatch`, its result
  record (the recognizer's own CHORD_FLAGS) copied by `BitMapOut_*` to CHORD_FLAGS or to 0x2306, and
  `ACC_CHORD_PREV_FLAGS` (a copy of ACC_CHORD_FLAGS) in `AccChord_ReadAndStoreKeys`; or the constant 0
  (`AccChord_SetDefaultKeys`);
- no HD-AE5000 image names 0xCEDE.

So bit 0 is never set at run time in these builds, and `Rhythm_RootOnlyNote` (step 3 of the open6 conversion) and
the two recognizer tests of bit 0 (`Voice_DispatchByTimingState`, `VoiceSlot_IterateAlloc_TestBit24`) are dead
paths.  [INFERENCE] a flag of an older or shared recognizer (the code that tests it is the same compiled C as the
other models').  Block copies into 0xCEDE were looked for (`lda xde` / `ld xde` with a 0xCCxx..0xCExx base): none.

The 0x2306 override itself: `SEQ_CHORD_TYPE` / `_ROOT` / `_BASS` / `_FLAGS` (0x2300, 0x2302, 0x2304, 0x2306, a byte
each, two apart) are the chord `NoteDisplay_StoreAndDispatch` recognizes from a song part's notes
(`BitMapOut_PrepareAndDisplaySimple`, `BitMapOut_WriteMultiIdx`); `SEQ_CHORD_FROM_SONG` (0x2308) is set by
`Accomp_ValidateAutoPlayChordVoice` when song slot 0 has an active part of type 0x0d whose voice-table flag is set.

### Rhythm_TransposeWithMod and its caller (N-1d99fc9b, CLOSED)

The caller chain, all in v10 (`sequencer/accompseq_routines.s` unless named):

    MainLoop_SequencerPhase (boot/system_handlers.s) -> AccompSeq_PeriodicEntry -> AccompSeq_PeriodicMain
      -> AccompSeq_CheckChannelActive -> AccompSeq_SetupChannel1 / _2 -> AccompSeq_InitEventDispatch
      -> AccompSeq_ProcessTimedEvent -> AccompSeq_ParseEvents -> AccompSeq_ProcessNoteOn6 (0x90) / _NoteOn8 (0x91)
      -> AccompSeq_ConvertNote90 / AccompSeq_ConvertNote91 -> Rhythm_PhraseConvertNote_Tramp
      (smf_event_processor.s) -> Rhythm_PhraseConvertNote (rhythm_routines.s)

The engine is the two-channel AccompSeq phrase player (ring buffers 0x7AEC / 0x7BEC): `AccompSeq_InitPartFull`
starts a phrase for a voice (L, H); below 0x80 its record is `AccompSeq_StyleDataTable` + 32 x
`Voice_DecodeNoteChannel2()` (78 built-in records, `naka_widget_descriptors.c`), from 0x80 the MSP data at
`MSP_SETTINGS__BASE_ADDR` (0x1E8800).  `AccompSeq_ProcessChordChange` restarts it on a chord change and
`AccompSeq_PortaFadeOut_Helper` at a bar change.  [INFERENCE] the phrase is picked by the sound being played
(program / bank through `Voice_NoteChannelTable2`); which panel feature presents it was not checked.

The converter, compared with the pattern converter `AccVoice_CorrectNote` of the open6 note:

- a note of 0x78 or more, or a channel whose program byte (0x7E40 / 0x7E41, through 0x7E48) is 0xF0 or more, is
  fixed (`ACCSEQ_CONVERT_FLAGS` bit 2);
- no chord (type or root 0): the note is left as it is (the pattern converter makes it 0);
- a 0x91 note takes its rule byte (`ACCSEQ_NOTE_EXT1` / `_EXT2`, copied from 0x7E5A / 0x7E5B by
  `AccompSeq_ConvertNote91`) through `Rhythm_ChordExtSelect`, with the same nibble / bit 4 / bit 5 rules
  (`Rhythm_PhraseExtShift`; a dropped note returns 0);
- the chord-type row always comes from the ACCOMP1 map `Rhythm_ChordRowMap_Acc1` (`Rhythm_PhraseChordRow`);
- the root shift has a fixed turnover of 6 and folds by octaves only above 0x7F (`Rhythm_PhraseRootShift`); there is
  no bass rule, no root-only rule and no per-part turnover or ceiling.

Renames: `scripts/renaming/rename_kn5000_notes_accomp.sed` (v10 / v9 / v7 / v6 / v5).

## NAKA C

Measured with `python3 scripts/analysis/naka_gui_census.py` (columns rom addrs, field_XX, records) and
`probes/naka_untyped_elements.py` (v10).  Before = main a385de42f.

| measure                                      | v10 before | v10 after | v9 after | v7 before | v7 after | v6 / v5 before | v6 / v5 after |
|----------------------------------------------|------------|-----------|----------|-----------|----------|----------------|---------------|
| rom addrs (numeric ROM addresses in the C)   | 9          | 1         | 1        | 9         | 1        | 11             | 7             |
| field_XX members                             | 523        | 434       | 434      | 531       | 442      | 531            | 509           |
| widget records typed in the C                | 3,242      | 3,259     | 3,259    | 3,242     | 3,259    | 3,242          | 3,250         |
| Viewable elements with no typed record (v10) | 69         | 52        | -        | -         | -        | -              | -             |

(v9 before = v10 before.  The register's "65" for the last row used an older rule; the probe's rule gives 69 at the
base, 52 now: 3 at the end of a C blob, 49 in the asm, 13 of those the work-RAM view records of WorkRamInit_Image.)

### What changed

1. **Straddling records** (N-2f640c1d, N-45db7885): `scripts/converters/naka_type_straddling_records.py` types the
   records that the old positional typing cut across (an IvExit and the record after it read as one 24-byte
   `naka_dispatch_t`): 17 records per tree in naka_disk_menu_file_io.c (6), naka_perf_style.c (2),
   naka_technichord_part.c (8) and naka_widget_names_charmap.c (1).  Each is compiled before and after and written
   only if identical; `naka_gui_symbolize.py` then names the values.  Six symbolic initializers were the decoder's
   false pointers (bytes that sit on no 4-byte field of the class: rectangle words, two 16-bit fields):
   `NAKA_ADDR(CRTC_LINE_COMPARE)` x2, `NAKA_ADDR(Naka_PresentationRootState)` x2 (the rect {319, 239}, as
   `fd_test_data.s` already said), `NAKA_ADDR(NakaData_DescriptorPad1)`, `NAKA_ADDR(SCREEN_BPP)`; they are spelled as
   the field values they are.  So the `.link_ptr = 0x00EB0000` / `0x00FB0020` "addresses" were rectangle words.
2. **EditSw texts** (N-45db7885): the four old EditSw records whose `str` pointed at the text right after them
   (`0x00E0FC10`, `0x00E0FC3C`, `0x00E850A8`, `0x00E8512C`) now point at `char <Record>_Str[4]` members ("~80",
   "~81") through `SELF()` (`--strings` pass of the same script).
3. **Case tables** (N-45db7885, N-d8cf1242): `scripts/converters/naka_case_tables_retype.py` now registers each tree's
   naka_classes.h and lets through a `<X>_ptr` member whose initializer is exactly `NAKA_ADDR(<symbol>)` inside a
   range the asm spells as `.short <Case> - <Base>`: `CtrlPanel_DispatchByIndex_CaseTable` (43 entries, held the
   `ptr_0d72 = 0x00E000CA` and `Data_WidgetNamesCharMapBlock_ptr` false pointers) and
   `AcPresentationControlProc_CaseTable` (held `ChordTypeStr_Flat9_Flat13_ptr`), v10 / v9 / v7.

v6 / v5 (names only, as the brief asks): the retyping of naka_technichord_part.c and naka_widget_names_charmap.c
was not applied there.  Their C still compiles v10's values in those records (RAM-cell and pointer values) and the
C-divergence json patches the bytes, so typing them changes the compiled blob: that belongs with lane v6v5-port
(N-2a3d2074), which owns those json raw bytes.  Next step there: retype the 9 records in those two files after the
json is regenerated (`ported_c_rebase.py --regen`), with `naka_type_straddling_records.py --tree v6 --apply`.

### Left (exact)

- **rom addrs, 1 per tree (v6 / v5: 7)**: `naka_direct_play.c` `w119.inst_ptr = 0x00F40008`, the PsWideToggle
  element 9 of slot 0xE3, whose record runs past the end of the C blob (its `onoff` field is in the asm).  Two more
  records end the same way (naka_normal_mode.c Window element 24 of slot 0x1, naka_sound_menu_drawbar.c
  AcWindowPage element 1 of slot 0x2).  Next step: move each record's tail from the asm into the C blob (or the
  record into the asm as a NAKA_REC_ macro call) so one member can cover it.
- **field_XX, 434 (v10)**: 291 of them in naka_sequencer_channels.c (unchanged; next step as before: trace the
  base-pointer readers of that blob's members).
- **49 untyped elements in the asm**: the 13 work-RAM view records and 36 records whose blocks hold strings or other
  statements (`naka_asm_records.py --report`).

### Titles with no menu path (N-7c99f0f2)

`docs/gui/kn5000-menu-map.md`: 130 -> 158 of 211 titles with a path (81 -> 53 without), code transitions 93 -> 275.

- `SeMenu_SendEvent` (audio/semenu_routines.s) is the sound editor's title opener: `ld (xsp), c`; C = 0 ->
  `UI_ChangeTitleByIndex(A)`, else a repaint (`UI_PostRefreshEvent`).  It is reached by tail jumps from its own
  file, so `name_title_index_operands.py`'s fixpoint never saw its entry; it is now declared beside the stack
  forwarders.  That names 194 title operands per tree as `TT_*` (30 titles, 28 of them TITLE_SE* pages).
- `naka_gui_model.dirmd_page_handlers()` models the DirmdEmulator pages: `<Page>TitleFunc` copies
  `<Page>TitleFunc_Methods` (OnDraw, OnHide, OnSwitchIn, Nop) and calls DirmdEmulator; OnSwitchIn jumps to
  `<Page>TitleFunc_DispatchSwitch`, which calls through `<Page>TitleFunc_SwitchHandlers`.  The titles those handlers
  open are the page's code transitions.  32 pages, 615 routines.
- Left: 53 titles.  TITLE_SEFILHPQ1 / SEFILL241 / SEFILH241 / SEFILBPF1 are opened with an index the code computes
  (the filter-type step), not a constant; the rest are DefaultFunction titles and test / converter screens that no
  traced code opens.  Next step: resolve the 20 call sites with an unknown index path
  (`name_title_index_operands.py --report`), starting with the filter-type selector.

### Flag bytes (N-51b2e19c)

`probes/flag_byte_uses.py` counts the numeric memory operands of the listed flag bytes (v10).  This lane named
0x3283 (`ACC_RUN_FLAGS`, above), 0x32F4 (`ACC_PART_FLAGS`) and 0x332C (`ACC_LANES_RESYNC`); their evidence is in
`ram/acc_flag_names.txt`.  Totals over the 20 addresses of the list: numeric 967 -> 747.  Left numeric: 0xC1FE,
0xC594, 0xC596, 0xC598, 0xC59C (audio configuration), 0x28B2 / 0x28B3 (sequencer play state), 0x34CD, 0x35B0,
0xE3E2.  Next step: the same per-bit reading for 0xC596 first (its bits 0-2 / 4 are the AUTO PLAY CHORD mode,
open6 note A6), with `scripts/analysis/kn5000_ram_bit_usage.py`.

## Probes and scripts

| script                                               | question it answers                                                                             | command                                                                         |
|------------------------------------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `probes/spell_acc_note_tables.py`                    | spells the ACC_*_NOTES bases loaded into XBC / XIX and the loop ends as names (no byte changes) | `python3 notes/kn5000-notes-2026-11-06/probes/spell_acc_note_tables.py`         |
| `probes/naka_untyped_elements.py`                    | which registered Viewable elements have no typed record, and where they live                    | `python3 notes/kn5000-notes-2026-11-06/probes/naka_untyped_elements.py --list`  |
| `probes/flag_byte_uses.py`                           | numeric / named memory operands of the N-51b2e19c flag bytes                                    | `python3 notes/kn5000-notes-2026-11-06/probes/flag_byte_uses.py --tree v10`     |
| `scripts/converters/naka_type_straddling_records.py` | types the NAKA records that straddle C members; `--strings` names the old EditSw texts          | `python3 scripts/converters/naka_type_straddling_records.py --tree v10 --apply` |
| `ram/acc_notes_names.txt`, `ram/acc_flag_names.txt`  | RAM names with their evidence, input of `scripts/tools/add_kn5000_ram_names.py`                 | `python3 scripts/tools/add_kn5000_ram_names.py <file>`                          |

## Website page draft

**accompaniment-engine.md**, "Research Needed" (line 345 today quotes `Rhythm_TransposeWithMod`).  Replace "(the
only path found is a song override at 0x2306); the caller of the second converter `Rhythm_TransposeWithMod`;" with:

> nothing sets CHORD_FLAGS bit 0 in v10 / v9 / v7 (every writer copies a CHORD_FLAGS value or stores 0), so the
> root-only rule is a dead path; the second converter, `Rhythm_PhraseConvertNote`, belongs to the AccompSeq phrase
> player (`AccompSeq_ConvertNote90` / `_91`), which converts with the ACCOMP1 rows, a fixed turnover of 6 and no bass
> rule;

and add to "## Section switching", after the ending paragraph:

> The accompaniment keeps a record of every sounding note per part (`ACC_DRUM1_NOTES` .. `ACC_ACCOMP3_NOTES`: status,
> note, velocity and the time left), counts them down every tick and stops after an ending only when none is left.
> A chord key that comes just after the accompaniment stopped (it ran through the last two ticks) has its synchro
> start deferred to the main loop, which first lets the rhythm byte stream drain.

**ui-framework.md**, "Widget records in the C sources", append:

> Since 2026-11-06 the records the first typing had cut across (an IvExit read together with the record after it)
> are typed too (`scripts/converters/naka_type_straddling_records.py`), so a record's 32-bit words are never read
> as pointers when they are rectangle words.  The sound editor's pages (TITLE_SE*) are DirmdEmulator screens: their
> menu paths come from each page's method table and switch handlers, and the docs/gui menu map now gives 158 of the
> 211 titles a path.
