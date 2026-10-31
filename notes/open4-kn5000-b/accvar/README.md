# Sub-lane accvar (lane kn5000-b, 2026-10-31): the accompaniment's section state machine (kn5000-98j, part 2)

The `engine` sub-lane decoded chord recognition (notes/open4-kn5000-b/engine/README.md, section kn5000-98j).
This sub-lane traces the rest of kn5000-98j in the v10 tree: how the style-control buttons (INTRO & ENDING 1/2,
FILL IN 1/2, START/STOP, SYNCHRO & BREAK, VARIATION 1-4) are latched and when the accompaniment switches
section.  The transposition of the pattern notes to the recognized chord was **not** traced; it is given as a
proposed new issue at the end, with the leads found.

Addresses are v10 RAM.  The routine names are the ones this sub-lane gives (rename list below).  The rename
script is `scripts/renaming/rename_open4_accvar.sed`, applied to v10, v9 (v8), v7, v6 and v5.  The RAM names
were added with `scripts/tools/add_kn5000_ram_names.py` (input `notes/open4-kn5000-b/accvar/ram-names.txt`).
That tool derives the v9 and v7 addresses from the same instructions.  v6 and v5 keep the numbers, because the
tool does not cover them.

## The old names were wrong

The routines that latch these buttons were called `AccPedal_SustainOn`, `AccPedal_ExprOn`,
`AccPedal_SostenutoOn`, `AccPedal_SoftOn`, `AccPedal_HoldOn`, `AccPedal_DamperOn` and `AccPedal_PortamentoOn`.
Their dispatchers were `AccPedal_Bit2_Sustain` and its twins.  None of them touches a pedal.  Each one sets or
clears one bit of the style record's section byte, `PANEL_STYLE+5` / `+6` (panel record 0x48 fields 5 and 6).
`DisplayStr_StyleSectionNames`, indexed through `VoiceCtrl_ParamSetupBytecode_Tbl4`, names every bit:

| field / bit | meaning (Tbl4 -> section name) | set by (new name)                                 | engine request bit      | lanes byte          |
|-------------|--------------------------------|---------------------------------------------------|-------------------------|---------------------|
| +5 bit 0    | START/STOP press               | `AccStyleCtl_StartStopButton` (acts, not latched) | --                      | --                  |
| +5 bit 1    | SYNCHRO armed                  | `AccStyleCtl_SynchroButton` (toggle)              | --                      | --                  |
| +5 bit 2    | INTRO1                         | `AccSection_RequestIntro1`                        | `ACC_REQ_INTRO` bit 0   | `ACC_LANES_INTRO1`  |
| +5 bit 3    | COUNT IN                       | `AccSection_RequestCountIn`                       | `ACC_REQ_INTRO` bit 1   | `ACC_LANES_COUNTIN` |
| +5 bit 4    | ENDING1                        | `AccSection_RequestEnding1`                       | `ACC_REQ_ENDING` bit 0  | `ACC_LANES_ENDING1` |
| +5 bit 5    | ENDING2                        | `AccSection_RequestEnding2`                       | `ACC_REQ_ENDING` bit 1  | `ACC_LANES_ENDING2` |
| +5 bit 6    | FILL IN1                       | `AccSection_RequestFillIn1`                       | `ACC_REQ_FILLIN` bit 0  | `ACC_LANES_FILLIN1` |
| +5 bit 7    | FILL IN2                       | `AccSection_RequestFillIn2`                       | `ACC_REQ_FILLIN` bit 1  | `ACC_LANES_FILLIN2` |
| +6 bit 2    | INTRO2                         | `AccSection_RequestIntro2`                        | `ACC_REQ_INTRO` bit 2   | `ACC_LANES_INTRO2`  |
| +7 bits 4-5 | VARIATION 1-4                  | `PanelButton_Variation`                           | `ACC_VARIATION_REQUEST` | --                  |

`SqStep_ProcessRhythmSectionEvent` reads the same bits when it shows a recorded section event.  The bit layout
agrees with that routine's header (bits 4-7 = ENDING1, ENDING2, FILL IN1, FILL IN2), written independently.

## 1. Button press -> request bit (`AccStyleCtl_*`, sequencer/accompaniment_engine.s)

`AccStyleCtl_OnSwitchEvent` (was `AccPedal_EventDispatch`) takes a switch event for record 0x48 from the SwbtWr
payload.  It stores the field (5 or 6) in `ACC_CTL_EVENT_FIELD`, the new value in `ACC_CTL_EVENT_VALUE` and the
mask of changed bits in `ACC_CTL_EVENT_MASK` (0xFF is read as 0).  It then runs three handlers.  A button counts
as pressed when its bit is set in both value and mask, and as released when it is set in the mask only.

- **`AccStyleCtl_StartStopButton`** (field 5 bit 0).  This handles START/STOP.  On the composer and
  sequencer titles it only flags the press.  Otherwise it stops a pending start (`PLAY_TRANSPORT_STATE` bit 0
  without bit 2: all three transports are cleared) or calls `AccPlayMode_TransitionRouter`.  It is refused on
  titles 108-122 and in mode 19 (`AccStyleCtl_IsStartStopBlocked`).
- **`AccStyleCtl_SynchroButton`** (field 5 bit 1).  This toggles `PANEL_STYLE+5` bit 1, the SYNCHRO armed
  bit.  Unless the event came from the switch-write path (`PANEL_EVENT_SOURCE` = 0xFF), it echoes the bit as
  a 0x48/5 switch packet when MIDI's bit 3 (`PANEL_MIDI+6`) allows.
- **`AccStyleCtl_SectionButtons`** (fields 5 and 6).  This does nothing in the composer (mode 14).  Otherwise
  it runs `AccStyleCtl_DispatchSectionButtons`, one handler per button:

| handler (new name)               | button bit    | stopped                                | running                                |
|----------------------------------|---------------|----------------------------------------|----------------------------------------|
| `AccStyleCtl_IntroEnding1Button` | field 5 bit 2 | INTRO1 (`AccSection_RequestIntro1`)    | ENDING1 (`AccSection_RequestEnding1`)  |
| `AccStyleCtl_IntroEnding2Button` | field 6 bit 2 | INTRO2 (`AccSection_RequestIntro2`)    | ENDING2 (`AccSection_RequestEnding2`)  |
| `AccStyleCtl_FillIn1Button`      | field 5 bit 6 | nothing                                | FILL IN1 (`AccSection_RequestFillIn1`) |
| `AccStyleCtl_FillIn2Button`      | field 5 bit 7 | COUNT IN (`AccSection_RequestCountIn`) | FILL IN2 (`AccSection_RequestFillIn2`) |
| `AccStyleCtl_Ending1Bit`         | field 5 bit 4 | nothing                                | ENDING1                                |
| `AccStyleCtl_Ending2Bit`         | field 5 bit 5 | nothing                                | ENDING2                                |
| `AccStyleCtl_CountInBit`         | field 5 bit 3 | COUNT IN                               | COUNT IN                               |

The "running" test is `ACC_TRANSPORT_STATE` bit 2.  For the two INTRO & ENDING buttons it applies only when the
event comes from the front panel (`PANEL_EVENT_SOURCE` = 127, set by `Audio_InitAllDefaults` and after each
queued event).  A section event from MIDI or song playback carries the resolved bit (INTRO1 / ENDING1 ...), so
it is taken literally.  That a FILL IN 2 press while stopped means COUNT IN is read from the code
(`AccStyleCtl_FillIn2Button` calls `AccSection_RequestCountIn` when bit 2 of `ACC_TRANSPORT_STATE` is clear).
The owner's manual was not checked.

Each `AccSection_Request*` routine does the following:
- marks its button as held in `ACC_SECTION_BUTTONS_HELD`.  The bits are 0 INTRO2, 2 INTRO1, 3 COUNT IN,
  4 ENDING1, 5 ENDING2, 6 FILL IN1 and 7 FILL IN2.  The matching `AccSection_Release*` clears the bit.
- sets its request bit in `PANEL_STYLE+5` / `+6`, which is also the button's LED.  A second press of a request
  that is already set, from the panel, clears it again.  So pressing INTRO twice cancels the intro.
- clears the requests it excludes.  `AccSection_RequestIntro1` clears COUNT IN, INTRO 2 and both fills.  The other
  request routines clear their own sets of bits, which were read only for INTRO 1.
- builds the change pairs `0x3480`..`0x3487` that `AccStyleCtl_SendSectionEvents` sends out as 0x48/5 and 0x48/6
  switch events (`MIDI_TransmitTempoCC`).

## 2. Request bits -> engine requests, once per tick (`SeqTick_ReadControlState`, smf_event_processor.s)

Each sequencer tick, `SeqTick_ReadControlState` copies the panel bytes into the engine's request bytes:

| engine byte                      | from                                          | previous-tick copy (`Rhythm_SaveState`) |
|----------------------------------|-----------------------------------------------|-----------------------------------------|
| `ACC_REQ_FILLIN` (0x32fb)        | +5 bit 6 -> bit 0, +5 bit 7 -> bit 1          | `ACC_REQ_FILLIN_PREV` (0x32fc)          |
| `ACC_REQ_ENDING` (0x32fd)        | +5 bit 4 -> bit 0, +5 bit 5 -> bit 1          | `ACC_REQ_ENDING_PREV` (0x32fe)          |
| `ACC_REQ_INTRO` (0x32ff)         | +5 bit 2 -> 0, +5 bit 3 -> 1, +6 bit 2 -> 2   | `ACC_REQ_INTRO_PREV` (0x3300)           |
| `ACC_STYLE_ARRANGER_ON` (0x3301) | `PANEL_REC_98+3` bit 0 (MUSIC STYLE ARRANGER) | 0x3302                                  |
| `ACC_VARIATION_REQUEST` (0x3305) | `PANEL_STYLE+7` bits 4-5 (VARIATION 1-4)      | 0x3306                                  |

`ACC_SECTION_REQUEST` is renamed `ACC_VARIATION_REQUEST`: it holds the VARIATION field, not a section.

## 3. Rising edge -> pending section (`AccSection_Latch*Requests`, seq_audio_mode.s)

A request bit that is newly set (set now, clear in the `_PREV` copy) becomes a pending section:

- **`AccSection_LatchIntroRequests`**: INTRO1 sets `ACC_PENDING_INTRO` bit 0, COUNT IN sets bit 2 and INTRO2
  sets bit 3.
- **`AccSection_LatchFillInRequests`**: FILL IN 1 sets `ACC_PENDING_FILLIN` bit 0 and FILL IN 2 sets bit 1.
- **`AccSection_LatchEndingRequests`**: ENDING 1 sets `ACC_PENDING_ENDING` bit 0 and ENDING 2 sets bit 1.

Each latch clears the pending bits of the other two groups, so the newest press wins.  Each one also decides
when the switch happens:

- **Intro or fill-in** (`AccSection_DeferToBarIfLastBeat`).  The switch is deferred to the bar line
  (`ACC_DEFER_SECTION_LANES` = all six lanes) only when the press comes on the **last beat** of the bar:
  engine beat `0x32e4` + 1 = `ACC_BEATS_PER_BAR`.  Otherwise it happens at once (section 4).  A fill pressed
  mid-bar therefore starts on the next tick and plays to the end of that bar.
- **Ending** (`AccSection_DeferToBarUnlessFirstBeat`).  The switch is deferred to the bar line
  (`ACC_DEFER_ENDING_LANES`) **unless** the press comes on the first beat (engine beat 0).  An ending pressed
  late in a bar waits for the next bar line; pressed on beat 1 it replaces the bar that has just started.

The engine beat is the one `Rhythm_AdvanceTick` keeps 24 clocks (a sixteenth) ahead of the clock.

## 4. Pending section -> new section (`AccSection_SwitchNow`, `AccSection_SwitchAtBarLine`)

**Immediately.**  `AccSection_SwitchNowUnlessDeferred` (was `AccPedal_CheckCombined`) calls
`AccSection_SwitchNow` (was `AccInit_FullReInit`) when a section is pending and its defer mask is empty.
`AccSection_SwitchNow` does the following:
1. silences the lanes (`Rhythm_SendNoteOnMax`, `AccBuf_WriteAllNotesOff`).
2. applies the Music Style Arranger step: see below.
3. reloads the variation if one is pending, and starts the pending section.  This is the intro
   (`AccSection_StartIntro`), the fill-in (`AccSection_StartFillIn`, also entered when a FILL IN button is
   still held) or the ending (`AccSection_StartEnding`).
4. keeps the lanes' beat position in the bar, clearing only the measure nibble of `ACC_LANE_BEAT_POS`.

**At the bar line.**  At each lane's bar end (`AccVoice_BarEnd_NextPage`), a lane whose bit is set in a defer
mask raises the change flags `0x32f3` bit 7 and `0x32f4` bit 0 (`AccVoice_SetChordChangeFlags`).  So does a
pending variation change (`0x330d` bit 0, set by `AccentVoice_DetectAndMarkChange` when `ACC_VARIATION_REQUEST`
moves).  The accompaniment tick (`AccTick_CheckNoteOn`) then calls `AccSection_SwitchAtBarLine`.  That routine
clears both defer masks, builds a 4-bit index and jumps through `AccSection_BarLineSwitchTable`.  The index bits
are 1 = intro pending, 2 = fill-in pending (or a FILL IN button held during an arranger step), 4 = ending
pending, and 8 = a new variation to load (arranger step, variation change or restart):

| index | handler                           | does                                                                 |
|-------|-----------------------------------|----------------------------------------------------------------------|
| 0     | `AccSection_ToVariation`          | reload the variation (`AccStyle_Init`); clear the intro / fill lanes |
| 1     | `AccSection_ToIntro`              | `AccSection_StartIntro`                                              |
| 2, 3  | `AccSection_ToFillIn`             | `AccSection_StartFillIn` (fill beats intro)                          |
| 4-7   | `AccSection_ToEnding`             | `AccSection_StartEnding` (ending beats everything)                   |
| 8     | `AccSection_ToVariation`          | new variation                                                        |
| 9     | `AccSection_ToNewVariationIntro`  | new variation, then the intro                                        |
| 10-11 | `AccSection_ToNewVariationFillIn` | new variation, then the fill-in                                      |
| 12-15 | `AccSection_ToNewVariationEnding` | new variation, then the ending                                       |

All handlers end in `AccSection_Switch_Common` (rhythm note-off, channel pressure, buffer reset).

**Music Style Arranger.**  When `ACC_STYLE_ARRANGER_ON` is set, a fill-in steps the variation:
- FILL IN 1 steps the variation index `0x333a` down by one, stopping at VARIATION 1.
- FILL IN 2 steps it up by one, stopping at VARIATION 4.

The step comes from `AccVoice_SetChordChangeFlags`, which sets `0x330e` bits 0/1 when a fill lane ends, and
from `AccSection_SwitchNow` / `AccSection_SwitchAtBarLine`.  The new variation is loaded with the section that
follows (`0x330c` bit 0).

**Starting a section.**  Each `AccSection_Start*` routine does three things:
1. points all six lanes at the section's pattern.  For rhythm-ROM styles this is the style record
   (`ACC_STYLE_RECORD`); `AccSection_StartIntro` uses offset 0x20 for INTRO1, 0x22 for COUNT IN and 0x420 for
   INTRO2, and `AccSection_StartFillIn` / `_StartEnding` go through `AccVoice_ComputeParamAddr` /
   `ACC_LANE_SECTION`.
2. sets that section's lanes byte to 0x3F.
3. clears every other lanes byte.

| section  | lanes byte |
|----------|------------|
| INTRO1   | 0x3316     |
| COUNT IN | 0x3317     |
| INTRO2   | 0x3318     |
| FILL IN1 | 0x3312     |
| FILL IN2 | 0x3313     |
| ENDING1  | 0x3314     |
| ENDING2  | 0x3315     |

For a composer style (number 0x80 and up, with `0x3363` bit 0 set), the `AccSection_StartComposer*` variants
take the section from the composer memory's source rhythm.  This applies only when that rhythm matches the one
recorded for the section (`0x3364`..`0x336f`, pairs {rhythm, section record}).  Otherwise the request is
cancelled and its LED cleared.  The six section records per group are intro 1/2, fill-in 1/2 and ending 1/2
(sections 12-17, 18-23 and 24-29 of the style image; `AccPatch_LoadIntroFillEndingFromRhythm`).

## 5. Section end -> back to the variation, or stop

A lane clears its bit in the section's lanes byte when its pattern of that section ends (the 0x83 end marker,
`AccVoice_HandleMarker83`).  Every tick, `Rhythm_SaveState` compares each lanes byte with its shadow copy
(`0x3319`..`0x331f`).  When a section's last lane finishes, it does three things:
- clears that section's request bit in `PANEL_STYLE+5` / `+6`, which turns the button's LED off.
- queues the 0x48/5 (or /6) switch event (`Rhythm_QueuePartChangeEvent`).
- clears the engine request bit (`_CheckFillIn1Done` .. `_CheckEnding2Done`).

What happens next depends on the section (`kn5000_ram_bit_usage.py --tree v10 0x3284`):
- **Fill-in.**  When FILL IN 1 ends while FILL IN 2's lanes are already running (a second fill pressed during
  the first), FILL IN 2's LED is set.  When no intro, fill or ending lane is left, `0x3284` bits 2 and 4 are
  set: the accompaniment returns to the variation.  Bit 4 is read by `AccDir_PeriodicCheck`, the VARIATION
  stepper of the per-tick vector, and `AccDir_Periodic_DisableAndReset` clears bits 2 and 4.
- **Intro.**  `0x3284` bit 3 is set; `AudioMode_CheckAndUpdateStereo` tests it.
- **Ending.**  `0x3284` bit 2 is set, the same bit as after a fill-in.  So `0x3284` is not what stops the
  accompaniment after an ending; the stop was not found (proposed new issue).

The fill-in's return to the variation happens at the fill's own end, which is the bar line.

## 6. Synchro start

`PANEL_STYLE+5` bit 1 is the SYNCHRO armed bit.  `AccAutoPlay_SetConfig` arms the synchro start
(`0x346d` bit 7) when four conditions hold:
- nothing records or plays (`SEQ_REC_TRACKS`, `SEQ_TRACK_MASK` and `CMP_RECORD_PART` are all 0);
- the accompaniment mode is on (`PANEL_STYLE+3` low three bits non-zero, bit 3 clear);
- the SYNCHRO bit is set;
- (from the code path) the request is not refused elsewhere.

While waiting, `ACC_TRANSPORT_STATE` = 128 / 134.  `INTTR4_SeqAutoStart` starts `PLAY_TRANSPORT_STATE` and
`SEQ_TRANSPORT_STATE` at the end of a bar of the accompaniment clock (`ACC_CLOCK` = 95 on the last beat, after
at least one bar).  `AccAutoPlay_PeriodicCheck` drops the SYNCHRO bit as soon as a sequencer track plays or
records (`AccAutoPlay_Disable`).  The BREAK half of SYNCHRO & BREAK while running, and synchro stop, were not
traced.

## Renames (all trees: v10, v9 / v8, v7, v6, v5)

`scripts/renaming/rename_open4_accvar.sed` holds 277 rules: these routines and their local labels.

| old                                                        | new                                                                                                              |
|------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `AccPedal_EventDispatch`                                   | `AccStyleCtl_OnSwitchEvent`                                                                                      |
| `AccPedal_SustainHandler`                                  | `AccStyleCtl_StartStopButton`                                                                                    |
| `AccPedal_StyleCheck`                                      | `AccStyleCtl_IsStartStopBlocked`                                                                                 |
| `AccPedal_ExprToggle`                                      | `AccStyleCtl_SynchroButton`                                                                                      |
| `AccPedal_DistributeParams`                                | `AccStyleCtl_SectionButtons`                                                                                     |
| `AccPedal_ProcessAllBits`                                  | `AccStyleCtl_DispatchSectionButtons`                                                                             |
| `AccPedal_SendEvents` / `AccPedal_StateSync`               | `AccStyleCtl_SendSectionEvents` / `_SyncSectionEvents`                                                           |
| `AccPedal_Bit2_Sustain` / `_Bit2_Expression`               | `AccStyleCtl_IntroEnding1Button` / `2Button`                                                                     |
| `AccPedal_Bit6_Hold` / `_Bit7_Portamento`                  | `AccStyleCtl_FillIn1Button` / `FillIn2Button`                                                                    |
| `AccPedal_Bit4_Sostenuto` / `_Bit5_Soft` / `_Bit3_Damper`  | `AccStyleCtl_Ending1Bit` / `Ending2Bit` / `CountInBit`                                                           |
| `AccPedal_SustainOn` / `Off`                               | `AccSection_RequestIntro1` / `ReleaseIntro1`                                                                     |
| `AccPedal_ExprOn` / `Off`                                  | `AccSection_RequestIntro2` / `ReleaseIntro2`                                                                     |
| `AccPedal_SostenutoOn` / `Off`                             | `AccSection_RequestEnding1` / `ReleaseEnding1`                                                                   |
| `AccPedal_SoftOn` / `Off`                                  | `AccSection_RequestEnding2` / `ReleaseEnding2`                                                                   |
| `AccPedal_HoldOn` / `Off`                                  | `AccSection_RequestFillIn1` / `ReleaseFillIn1`                                                                   |
| `AccPedal_DamperOn` / `Off`                                | `AccSection_RequestCountIn` / `ReleaseCountIn`                                                                   |
| `AccPedal_PortamentoOn` / `Off`                            | `AccSection_RequestFillIn2` / `ReleaseFillIn2`                                                                   |
| `AccVoice_ProcessPedalChanges`                             | `AccSection_LatchIntroRequests`                                                                                  |
| `AccVoice_ProcessLeftPedalChanges`                         | `AccSection_LatchFillInRequests`                                                                                 |
| `AccChord_ProcessKeyChanges`                               | `AccSection_LatchEndingRequests`                                                                                 |
| `AccVoice_CheckBitsAndSetFlags`                            | `AccSection_DeferToBarIfLastBeat`                                                                                |
| `AccChannel_SetDirtyIfActive`                              | `AccSection_DeferToBarUnlessFirstBeat`                                                                           |
| `AccVoice_ResetAll` / `AccVoice_Reassign`                  | `AccSection_StartIntro` / `StartComposerIntro`                                                                   |
| `AccVoice_SplitPointSetup` / `AccVoice_SplitReassign`      | `AccSection_StartFillIn` / `StartComposerFillIn`                                                                 |
| `AccVoice_ThirdLayer` / `AccVoice_ThirdLayerReassign`      | `AccSection_StartEnding` / `StartComposerEnding`                                                                 |
| `AccFlags_Aggregate` / `AccFlags_JumpTable`                | `AccSection_SwitchAtBarLine` / `BarLineSwitchTable`                                                              |
| `AccFlags_Handler0/1/2/4/8/9/10`                           | `AccSection_ToVariation/ToIntro/ToFillIn/ToEnding/ToNewVariationEnding/ToNewVariationIntro/ToNewVariationFillIn` |
| `AccPedal_CheckCombined`                                   | `AccSection_SwitchNowUnlessDeferred`                                                                             |
| `AccInit_FullReInit`                                       | `AccSection_SwitchNow`                                                                                           |
| `Rhythm_VoiceAssign*Detect` (locals of `Rhythm_SaveState`) | `Rhythm_SaveState_Check<Section>Done`                                                                            |
| `SeqCtl_StorePedalFlags`                                   | `SeqTick_ReadControlState_StoreIntroBits`                                                                        |
| `ACC_SECTION_REQUEST`                                      | `ACC_VARIATION_REQUEST`                                                                                          |

Left with their old names, because they were not traced far enough:
- `AccPedal_ProcessAllChanges`, which clears all requests when `AccStyle_ApplyExt_SkipClamp_Table[beats]` bit 0
  is set; that table's meaning is open.
- `AccPedal_MapToAcc` and `AccPedal_SendCtrl1..4`.
- the `AccPedal_CheckCombined_Skip*` labels inside `AccTick_ByteData`, a twin of `AccSection_SwitchNow`.

## Proposed new issue: pattern transposition to the chord

Not traced here.  Leads:
- `AccChord_ReadAndStoreKeys` copies the recognized chord into the engine (`0x32d8` / `0x32da`, compared with
  `0x32dc` / `0x32de` by `AccChord_CompareAndSetDirty`, which raises `0x32f3` bit 5).
- The lane note writers (`AccBuf_WriteNoteEvent`, `AccVoice_WriteNoteEventToBuffer`, `AccPlay_ProcessNoteEvent`
  in seq_event_playback.s) are where a root shift and a chord-type note table would apply.
- `Note_PitchClassTable` and `ToneGen_PitchClassNoteFormTable` are not transposition tables: they choose the
  0x90 / 0x91 event form of the composer's pattern writer.
- The types 31-39 voicing source and `NoteMask9_ClassTable`, left open by the engine sub-lane, belong to the
  same issue.

## Website page draft (accompaniment-engine.md)

Replace the "Research Needed" item "Document the variation/fill-in switching state machine" with this section,
placed after "## Chord Recognition" (the engine sub-lane's draft):

> ## Section switching: intro, fill-in, ending
>
> The style-control buttons do not switch the pattern themselves.  Each one sets a request bit in the style
> record (panel record 0x48), which is also the button's LED:
>
> | bit of record 0x48 | request       |
> |--------------------|---------------|
> | field 5 bit 2      | INTRO 1       |
> | field 5 bit 3      | COUNT IN      |
> | field 5 bit 4      | ENDING 1      |
> | field 5 bit 5      | ENDING 2      |
> | field 5 bit 6      | FILL IN 1     |
> | field 5 bit 7      | FILL IN 2     |
> | field 6 bit 2      | INTRO 2       |
> | field 7 bits 4-5   | VARIATION 1-4 |
>
> `AccStyleCtl_DispatchSectionButtons` turns a press into a request.  INTRO & ENDING 1/2 give an intro while the
> accompaniment is stopped and an ending while it runs.  FILL IN 1/2 give a fill-in while it runs; while it is
> stopped, FILL IN 2 gives a COUNT IN.  A second press of a pending request cancels it, and a new request
> clears the requests it excludes.
>
> Each tick `SeqTick_ReadControlState` copies the request bits into the engine (`ACC_REQ_INTRO`,
> `ACC_REQ_FILLIN`, `ACC_REQ_ENDING`).  A newly set bit becomes a pending section
> (`AccSection_Latch*Requests`).  It takes effect as follows:
>
> - **Fill-in or intro**: at once, unless the button was pressed on the last beat of the bar.  Then it waits
>   for the bar line, so a fill always plays from the current beat to a bar line.
> - **Ending**: at the next bar line, unless the button was pressed on the first beat.  Then it replaces the
>   bar that has just started.
> - **Variation change**: at the bar line.
>
> At the bar line `AccSection_SwitchAtBarLine` picks the handler from `AccSection_BarLineSwitchTable`.  An ending
> beats a fill-in, and a fill-in beats an intro.  A pending variation is loaded first.  With the MUSIC STYLE
> ARRANGER on, FILL IN 1 steps the variation down and FILL IN 2 steps it up, from VARIATION 1 to VARIATION 4.
>
> A section plays on all six lanes (`ACC_LANES_INTRO1` .. `ACC_LANES_ENDING2`, one bit per lane).  When its
> last lane reaches the pattern's end marker, `Rhythm_SaveState` clears the request and the LED.  After a
> fill-in or an intro the accompaniment returns to the variation.  (Where the firmware stops it after an ending
> is not traced yet.)
>
> SYNCHRO is record 0x48 field 5 bit 1.  When armed and nothing records or plays, the accompaniment waits
> (`ACC_TRANSPORT_STATE` 128 / 134) and `INTTR4_SeqAutoStart` starts it at the end of a bar of the
> accompaniment clock.

Also correct the "Overview" sentence that says the engine does "variation/fill switching" in the chord
detector, and add the renamed routines to the page's code references.

## Evidence

Every statement above cites the routine that does it, in v10:
- sequencer/accompaniment_engine.s: `AccStyleCtl_*`, `AccSection_*`;
- sequencer/seq_audio_mode.s: `AccSection_Latch*`, `AccSection_DeferToBar*`, `AccentVoice_DetectAndMarkChange`;
- sequencer/smf_event_processor.s: `SeqTick_ReadControlState`;
- sequencer/rhythm_routines.s: `Rhythm_SaveState`;
- display/scoop_display.s: `VoiceCtrl_ParamSetupBytecode_Tbl4`, `DisplayStr_StyleSectionNames`;
- ui_widgets/naka_extension_device.c: the 0x48 button actions.

`scripts/analysis/kn5000_ram_bit_usage.py --tree v10 0x32fb 0x32fd 0x32ff 0x3309 0x330a 0x330b 0x3470` lists
every setter, clearer and tester of the bytes named here.  No probe was needed: the meaning of every bit comes
from a name table in the ROM (`DisplayStr_StyleSectionNames`) and from code, not from a measurement.
