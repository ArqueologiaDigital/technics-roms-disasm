# Sub-lane `subcmd` of lane open6/kn5000-d (wave 6, 2026-11-02)

Issues: **kn5000-1gu** (main-CPU sender of sub-CPU system sub-command 0x09) and **kn5000-a1f** (song
controller events 0xD0 / 0xD1 / 0xD3, and the two value bytes of 0xBn / 0xCn).

Addresses are main CPU v10 and sub CPU v1.42.  Labels are the ones in the sources today.  The renames proposed
in `rename_subcmd.sed` are given after an arrow (old -> new); the lead applies them to v10/v9/v7/v6/v5.  No
assembly was edited and no build was run in this sub-lane.  Probes: `probes/README.md`.

---

## kn5000-1gu -- who sends system sub-command 0x09, and when

### The record (sub CPU)

`MIDI_Dispatch` (0x034D93) stages a 4-byte `0xF0` record at 0x2B09 (`MIDI_Status_System`, 0x034F9C) and calls
`Voice_SystemMsg` (0x02A7AF).  That routine reads only byte +2 (the sub-command) and byte +3 (the value).  Byte
+1 is never read: the main CPU puts 0x50 there for most sub-commands and 0x7F for 0x09, and v1.42 ignores both.
Sub-command 0x09 is tested before the table (`cp c, 0x9`) and jumps to `Voice_SystemMsg_DispatchTable`
(0x02A7FC), which runs `Voice_SetPolyphonyMode` (0x028ADC) with A = byte +3:

| byte +3 | `Voice_GlobalFlags` (0x041343) bit 0 | `Voice_Reset_Engine` (0x021ECB) | pool quotas                                           |
|---------|--------------------------------------|---------------------------------|-------------------------------------------------------|
| 1       | set                                  | WA = 1                          | `Voice_Pool_Quota_ModeB` (0x00F519), 16 pools         |
| other   | cleared                              | WA = 0                          | `Voice_Pool_Quota_ModeA` (0x00F507), 32 / 16 / 4 / 12 |

`Voice_Reset_Engine` takes the ModeB quota row and `Voice_Part_PoolPtr_ModeB` when its argument is non-zero
(`CmdTable_InitEntry_AltPtr`, `ChanStruct_Init_Entry_AltPtr`).  `Voice_SetPolyphonyMode` then calls
`VoiceSlot_ClearAll`, so every sounding voice is dropped, and re-runs the portamento pitch of parts 0-15.

### The senders (main CPU)

All system records go through one builder, `SeqVoice_CheckAndRet_Prologue` (0xFEBC36) -> **`SubCPU_SendSystemRecord`**.
It builds the packet {4, 0xF0, A, C, E} and passes it to `MIDI_SendCmdPacket` (0xFEBF48, `sendCOMM` handler 0).
Two inline builders exist as well: `MIDI_SendSysExCmd` (0xFEBDA1, sub-command 0x87) and `AudioInit_VoiceParamCtrl`
(0xFDED11, 0x91).  `probes/subcmd_probe.py syssenders` lists the 24 calls.  Two of them send 0x09, both with
byte +1 = 0x7F:

1. **`COMM_WriteAndCheck` (0xFEBDD2) -> `SubCPU_SetPolyphonyModeAndResendVolumes`.**  A != 0 gives mode byte 1,
   A = 0 gives 2.  It sends F0 7F 09 mode, then re-sends CC 7 (volume) to parts 0-0x16, 0x17 and 0x18.  The value
   is 0 while the part's mute (Lsw 0x008) is 1, otherwise the part's volume (Lsw 0x007)
   (`MIDI_SendPartVolumes_Loop` 0xFEBDFB, `MIDI_SendPartVol_ExtraParts`).  Its only caller is `MidiCtrl_Bit2ToChannel`
   (0xFD8BE9) -> **`MidiCtrl_GmBitToPolyphonyMode`**, which passes 1 when bit 2 of A is set and 0 otherwise.  That
   routine has two callers, both listeners of panel code 0x91 in `SwbtWr_DispatchLoop` (0xFDB32E).  The event is
   {0x91, field 3, value, mask} with mask bit 2 set:
   - bank 1: `MidiCtrl_ModeSwitchHandler` (0xFD86AC, `SwbtB1_Code91_Listeners`) sets 0xB7EE bit 0.  Unless bit 15
     of 0x11F5 is set, it stops play (`AccWrap_PlayModeDispatch`, `AccompSeq_StopSequence`).  It then sends the mode,
     runs `MidiCtrl_SendControlPacket` and `MidiCtrl_FullReconfigure`, and clears 0xB7EE bit 0;
   - bank 2: `MidiCtrl_ModeSwitch_Data` (0xFD8BCC, first entry of `SwbtB2_Code91_Listeners`) ->
     **`MidiCtrl_GmSwitchListener`** sends the mode only while 0xB7EE bit 0 is clear.
2. **`SndParam_ApplySystemParam` (0xFEB2C3), system parameter 0x00C0.**  Value != 0 gives 1, value 0 gives 2;
   it sends F0 7F 09 mode.  `SndParam_Registry` defines key 0xC0 as record 0x91 field 3 mask 0x04, range 0..1,
   shift 2 (`probes/subcmd_probe.py registry`).  `GmOnOffFunc` answers `EVT_GET_LSW_ADDRESS` with `0xC0`
   (analysis/disk-format-probes/README-lsw-param-namespace-map.md).  [INFERENCE] This case looks dormant in v10.
   The bank-2 code-0x91 listener that feeds `SndParam_ApplyEventField`, `UIStateEvt_ProcessHandler` (0xFEAC83),
   forwards only bit 0 of field 3 (key 0xC1 -> sub-command 0x99).  Only the 0x91 listeners were checked.

Record 0x91 is `PANEL_GM` (0xFDAA).  Field 3 bit 2 is **GM ON/OFF**: `SysEx_OnGmSystemOn` (0xFDA896,
F0 7E 7F 09 01) sets it, and `SysEx_OnGmSystemOff` (0xFDA8D8) clears it.  The mode selection is therefore:

| GM ON/OFF (PANEL_GM+3 bit 2) | record      | sub-CPU mode | allocation                                                                        |
|------------------------------|-------------|--------------|-----------------------------------------------------------------------------------|
| ON                           | F0 7F 09 01 | B            | 16 pools, parts 0-15 -> pools 0-15 (one per MIDI channel)                         |
| OFF                          | F0 7F 09 02 | A            | 4 pools 32 / 16 / 4 / 12 for the panel's part groups (`Voice_Part_PoolPtr_ModeA`) |

This turns the engine README's [INFERENCE] ("mode A is the keyboard's own allocation, mode B a 16-part
multi-timbral one") into a finding: mode B is General MIDI mode.

### When GM ON/OFF changes (the triggers)

| trigger                                | routine (v10)                                                                                            | GM bit                                                                                                                                                          |
|----------------------------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GM System On / Off received on MIDI IN | `SysEx_OnGmSystemOn` / `_Off` -> `AssswbWr(0x91, 3, …, mask 4)`, `SwbtWr_ReinitBothBanks`                | on / off.  Gated by `CURRENT_TITLE` and `PANEL_MIDI` bit 4                                                                                                      |
| a song is selected or synced           | `SongBank_CheckAccompanimentMode` (0xF20C2F) -> **`SongBank_ApplySongGmFlag`**; SetWall sync at 0xF2026C | on when the song record's +0xBD (0xF23D) is 0xFF, else off; queues {0x91, 3, 4 or 0, 4} (`SwbtWr_QueueMainEvent`)                                               |
| SMF playback set-up                    | `FloppyIO_ConfigureSwitchboard` (0xF23801)                                                               | mode 0 (0x11F8 = 0): on, and +0xBD = 0xFF; other modes: off, and +0xBD = 0                                                                                      |
| disk-file playback set-up              | `SoundParam_InitDefaultBanks` (0xFEDDA2) through `SoundParam_NotifyChange(0xC0, value)`                  | [INFERENCE] A = 0: off; A = 1: on; A = 2: off, with key 0xC1 = 1.  The bit is first forced to the opposite state, so the write is seen as a change; see caveats |
| power-on                               | `Audio_FullReinitWithPreset` (0xFC7D7B)                                                                  | `SoundParam_NotifyChange(0xC0, 0)` = off, unless `Sys_CheckPowerStableFlag` (0xEF0988) finds 0x5A5A at 0xFFCC                                                   |
| power-off                              | `NMI_HANDLER` (0xEF08A5)                                                                                 | stores 0x5A5A at 0xFFCC when GM is on, 0xA5A5 when it is off, so the GM state survives power-off                                                                |

The sub CPU itself boots in mode A (`Voice_Reset_Engine(0)` in its audio init).  [INFERENCE] The first 0x09
of a session arrives with the first GM ON/OFF event after the payload is loaded.  At boot that event is the
`SoundParam_NotifyChange(0xC0, 0)` above (GM off) or the restored GM state.

`SoundParam_NotifyChange` writes key 0xC0 through `SndParam_RegisterEntry_Data` (0xFCDB7E, handler type 1).  That
routine clamps the value to the entry's range (+7 / +8), shifts it by +9 & 15, XORs it with +10, and posts it
when it differs from the old bits.  For key 0xC0 this means value 1 = GM on.

### Caveats

- The `SoundParam_InitDefaultBanks` row assumes BC is the value written (`SndParam_NotifyAndReturn` documents BC
  = value).  The routine sets or clears the bit directly just before the write, so the posted event always
  carries a change.  Read that way, case A = 0 turns GM **off**, although its first instruction sets the bit.
  The file types behind A = 0..3 (`SeqVoice_PopIzReturn_Prologue`) were not identified.
- What bit 0 of PANEL_GM+3 (key 0xC1, sub-command 0x99 `Voice_SetCCMaxFlag`, song record +0xCB) means is not
  settled.  `SongBank_CheckBassMode` keeps its name.
- Only v10 was read.  The renamed labels exist in v9/v7/v6/v5, ported by the label-checked ports.

### Website page draft

**technics-docs `audio-subsystem.md`, section "Voice allocation".**  Replace the sentence that says the main-CPU
sender is not known with:

> #### Mode A and mode B: General MIDI
>
> The quota mode is the GM ON/OFF switch (`PANEL_GM`, record 0x91, field 3 bit 2).  Each change of that bit
> sends the system record `F0 7F 09 <mode>`.  Mode 1 means GM on and selects mode B: 16 pools, one per MIDI
> channel.  Mode 2 means GM off and selects mode A, the keyboard's four pools of 32 / 16 / 4 / 12 voices.
> On the main CPU, the panel-code 0x91 listeners `MidiCtrl_ModeSwitchHandler` and `MidiCtrl_GmSwitchListener`
> call `MidiCtrl_GmBitToPolyphonyMode`, which calls `SubCPU_SetPolyphonyModeAndResendVolumes`.  That routine
> sends the record through `SubCPU_SendSystemRecord`, then re-sends CC 7 to every part, because
> `Voice_SetPolyphonyMode` drops all sounding voices (`VoiceSlot_ClearAll`).  The bit changes on:
> - GM System On / Off from MIDI IN (`SysEx_OnGmSystemOn` / `SysEx_OnGmSystemOff`);
> - selecting a song whose record byte +0xBD is 0xFF, the flag SMF playback sets (`SongBank_ApplySongGmFlag`,
>   `FloppyIO_ConfigureSwitchboard`);
> - power-on: GM is turned off unless it was on at power-off (`NMI_HANDLER` stores 0x5A5A / 0xA5A5 at 0xFFCC).
>
> The sub CPU starts in mode A.

**technics-docs `inter-cpu-protocol.md`, after the MIDI record table.**  Add:

> System records (`0xF0`) are `F0 <b1> <sub-command> <value>`.  `Voice_SystemMsg` reads only the last two bytes;
> the main CPU writes 0x50 as b1, and 0x7F for sub-command 0x09.  Sub-command 0x09 = polyphony mode (1 = GM /
> 16 pools, else the keyboard's 4 pools), sent when GM ON/OFF changes.  Most system records come from
> `SubCPU_SendSystemRecord`.

---

## kn5000-a1f -- song controller events 0xD0-0xD3 and the value bytes of 0xBn / 0xCn

### Playback path (main CPU)

1. **Player.**  `SeqNoteCh_DispatchEventType` (0xF3B0DC) has a case per event.  `SeqNoteCh_HandleEventD0` /
   `D1` / `D3` fall into `SeqNote_SendNoteOff` (0xF3B1F3) -> **`SeqNoteCh_SendControllerEvent`**.  That routine
   stores the track's part (track - 1) after the value and writes the 4-byte event {Dn, tick, value, part}.  0xD2
   goes through `SeqNote_NoteOff_WritePart` (0xF3B225) -> **`SeqNoteCh_SendPitchBendEvent`** and writes 5 bytes,
   {D2, tick, lsb, msb, part}.  Both use `SeqBuf_WriteMidiEvent` (0xF3D9AC).  Nothing in either routine is a note-off.
2. **Batch.**  Non-note events are flushed by `SeqBuf_FlushAndReinit_VoiceCCEvents` (0xF3DA8E), which calls
   `Audio_ReinitAndProcessEvents` (0xFCAD39).  That runs three steps:
   - `Audio_SyncAndProcessSequencer` (0xFCAD44) copies each event to 0x91B5, with 0xFF after it;
   - `PendingParam_ScanAllTables` (0xFCB8C4);
   - `MidiPkt_ProcessEventQueue`.
3. **Class dispatch.**  `VoiceMode_ParamDispatch` (0xFCAD7D) stores byte +1 (the tick) in `PANEL_EVENT_SOURCE`.  It
   indexes `VoiceMode_ParamDispatch_Table` with (status & 0x70) >> 4: 0x8n -> 0, 0xBn -> 3, 0xCn -> 4, 0xDn -> 5
   (`VoiceParam_DispatchByMode`, 0xFCB44E).  0x9n, 0xAn, 0xEn and 0xFn land on a `ret`.
4. **Track filter.**  `MidiVoiceNote_Dispatch` (0xFCB6E3) takes the track from byte +3 (+4 for 0xD2) and puts it in
   `MIDI_CUR_PART`.  The event is dropped (0x91B5 = 0xFF) unless the track's TRACK ASSIGN is a sound part.
   0xD0-0xD2 use `MidiVoiceNote_LookupMode0_Data` / `MidiVoiceNote_PartAssignsD1D2` (15 values).  0xD3 uses
   `MidiVoiceNote_LookupMode3_Data`, which also takes DRUMS (12) and CONTROL (15).
5. **Defer.**  `VoiceParam_ModeDispatch_Table[status & 3]` stores the value with bit 7 set as a "pending" flag in a
   16-entry per-track array.  MIDI IN fills three of these arrays too:

| event | stored by (old -> new name)                                                     | array                  | MIDI IN writer of the same array          |
|-------|---------------------------------------------------------------------------------|------------------------|-------------------------------------------|
| 0xD0  | `VoiceParam_StorePendingB4` -> `VoiceParam_StorePendingChanPressure` (0xFCB47F) | 0x94D2                 | none                                      |
| 0xD1  | `VoiceParam_StorePendingModulation` (0xFCB509)                                  | 0x9452                 | `MidiCC_SetPendingPartModulation` (CC 1)  |
| 0xD2  | `VoiceParam_StorePendingPitchBend` (0xFCB593)                                   | 0x9472 (word, lsb/msb) | `MidiRx_SetPendingPartPitchBend`          |
| 0xD3  | `VoiceNote_StoreBankSelect` -> `VoiceParam_StorePendingExpression` (0xFCB626)   | 0x9432                 | `MidiCC_SetPendingPartExpression` (CC 11) |

   0xD3 is sent at once instead of deferred while `DEMO_CONTROL_FLAGS` (0x28AD) bit 7 is set.
6. **Send.**  `PendingParam_ScanAllTables` posts each flagged entry as a panel event {record, part tag, value,
   0x7F}, through `SwbtWr_WriteVoiceParam_PreserveRegs` (pitch bend: `SwbtWr_WriteParamBlockSafe`).  The part tag
   is `SeqTrackAssign_PartTagTable[TRACK ASSIGN]`.  The scanner also calls `MIDI_DispatchCC_Guarded` unless
   0x90CE[track] = 0x10 ([INFERENCE] the MIDI OUT echo, not traced).
7. **Panel event -> sub CPU.**  The bank-2 listeners `HdaeRom_AltTableEntry2..5` (0xFEAF26 / 0xFEAF52 / 0xFEAF7E /
   0xFEAFB6, codes 0xB1-0xB4) call `SndParam_ApplyEventField` (0xFEB083).  That routine finds the key's Lsw number;
   `SndPart_SetParam` (0xFEB0E5) then sends the record.  Lsw numbers are from
   analysis/disk-format-probes/README-lsw-param-namespace-map.md; the sub-CPU handlers are from `MIDI_Dispatch`.

| song event              | panel event              | Lsw   | `SndPart_SetParam` case -> builder                                                                  | sub-CPU record                                                                            | sub-CPU handler (v1.42)         |
|-------------------------|--------------------------|-------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|---------------------------------|
| 0xD0                    | {0xB4, tag, value, 0x7F} | 0x1B2 | `SndPart_SetChannelPressure` -> `MIDI_SendChannelPressure`                                          | `D0 part 00 value` (**channel pressure**)                                                 | `Voice_ChanPressure` (0x02A4EA) |
| 0xD1                    | {0xB2, tag, value, 0x7F} | 0x001 | `SndPart_SetModWheel` -> `MIDI_SendControlChange`                                                   | `B0 part 01 value` (**modulation**, CC 1)                                                 | `Voice_CtrlChange` (0x02A282)   |
| 0xD2                    | {0xB1, tag, lsb, msb}    | 0x1B0 | `SndPart_SetPitchBend` -> `MIDI_SendPitchBend`                                                      | `E0 part lsb msb` (**pitch bend**)                                                        | `Voice_PitchBend` (0x02A5E6)    |
| 0xD3                    | {0xB3, tag, value, 0x7F} | 0x00B | `SndPart_SetExpression` -> `MIDI_SendControlChange`                                                 | `B0 part 0B value` (**expression**, CC 11)                                                | `Voice_CtrlChange`              |
| 0xD3 on a CONTROL track | {0xB0, 1, value, 0x7F}   | -     | `VoiceNote_ApplyBankSelect` -> `Audio_WriteBankSelectParams` (-> `Audio_PostPendingAnalogControls`) | the **expression pedal** level (`ANALOG_EXPRESSION_PEDAL_PENDING`), not a per-part record | (not traced further)            |

The recorder writes the same mapping (`probes/subcmd_probe.py recordmap`, `SeqTrackAssign_RecordMapTable`
0xFCBA47).  On every sound track it maps {0xB4, tag} to emitter 6 = `MIDI_EmitRecord_D0` (0xFCAA3D), {0xB1} to
`_D2`, {0xB2} to `_D1` and {0xB3} to `_D3`.  The DRUMS track records only 0xB3 -> D3, and the CONTROL track only
{0xB0, 1} -> D3.  Each emitter writes {Dn, `SEQ_BEAT_TICK`, value, track}; 0xD2 writes {lsb, msb} as the value.
D0 is recorded only while bit 0 of RAM 0xFFC2 is set; what sets it was not traced.  The disk census (values
0 / 127 for D3) fits the expression pedal and expression.

So: **0xD0 = channel pressure (aftertouch), 0xD1 = modulation, 0xD2 = pitch bend, 0xD3 = expression** (the
expression pedal on the CONTROL track).  Song event and sub-CPU record share the status nibble only for 0xD0.

`Voice_ChanPressure`'s header says "+2 value", but the routine reads the value at +3 (`ld a, (xwa + 3)`), and
`MIDI_SendChannelPressure` puts 0 at +2 and the value at +3.  That header comment needs fixing in
`v142/subcpu/core/07_voice_ctrlchange.s`.  It is a comment edit, not a rename, so the lead should make it.

### 0xBn and 0xCn: the two value bytes

The recorder emitters and the playback decoders settle the layout.  Bytes after the status: tick, then four
data bytes, then on playback the track.

| event | bytes +2 .. +5                                                           | status low bits                                               | recorder                                                           | playback decode                                                                                                                                                                                                                                                                                                                 |
|-------|--------------------------------------------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0xBn  | panel record & 0x7F, field, **value** & 0x7F, **write mask** & 0x7F      | bit 0 = value bit 7, bit 1 = mask bit 7, bit 2 = record bit 7 | `MIDI_EmitRecord_B0` (0xFCA976)                                    | `VoiceMode3_InitChannelMatch` (0xFCB369) restores the three bits.  It matches {record, field} against the track's `SeqTrackAssign_PlaybackMapTable` (0xFCBFA3) list and ANDs the mask with the entry's mask; no match or an empty mask drops the event.  The entry's index picks the `VoiceMode_ParamHandler_3` (0xFCB001) case |
| 0xCn  | part-record tag, 0, **part record +0** & 0x7F, **part record +1** & 0x7F | bit 0 = +0 bit 7, bit 1 = +1 bit 7                            | `TempoCC_TransmitBytecodeBlock` (0xFCA924) -> `MIDI_EmitRecord_C0` | `VoiceMode_CheckPendingFlags` (0xFCAFD2) -> `VoiceMode4_RestoreValueHighBits` restores the bits.  `VoiceMode_ParamHandler_4` (0xFCADD4) writes +0 and +1 into the part record (+1 keeping its bit 7), posts {tag, 1, +1, 0x7F} and {tag, 0, +0, 0xFF}, then `SndParam_UpdateVoiceEntry_Safe`                                    |

So the second value byte of 0xBn is the panel event's write mask, not a second value.  The two value bytes of
0xCn are the part record's bytes +0 and +1: the flat panel sound number (Lsw 0x000, sent as CC 0) and its
variation bank (Lsw 0x020, CC 32).  The engine README's "[INFERENCE: program, bank]" is confirmed with those
precise meanings.

### Renames (`rename_subcmd.sed`)

`SeqNote_SendNoteOff` -> `SeqNoteCh_SendControllerEvent`, `SeqNote_NoteOff_WritePart` -> `SeqNoteCh_SendPitchBendEvent`,
`VoiceParam_StorePendingB4` / `SendPendingB4` (+ `_Guard`, `_Done`, `PendingB4_ScanEntry` / `_NextEntry`) ->
`…ChanPressure`, `VoiceNote_StoreBankSelect` / `WriteBankAndCC` / `SetupCCParams` / `CheckBankSelect` /
`ApplyBankSelect` -> `VoiceParam_StorePendingExpression` / `VoiceParam_SendPendingExpression[_SetupParams /
_CheckPedal / _ApplyPedal]`, `Audio_WriteBankSelectParams` -> `Audio_PostPendingAnalogControls`,
`TempoCC_TransmitBytecodeBlock` -> `MIDI_EmitRecord_C0`, `VoiceMode_CheckPendingFlags` ->
`VoiceMode4_RestoreValueHighBits`; for kn5000-1gu the twelve in the first part of the sed file.

Comments the lead should update after the sed:
- `PendingParam_ScanAllTables`'s header says "B4 (record 0xB4 …; meaning not established)".  It should say:
  channel pressure, filled by song event 0xD0.
- `MidiSeqBuf_ProcessorTable`'s header names `TempoCC_TransmitBytecodeBlock`; the sed renames it there too.

Prose that quotes renamed names: `notes/open4-kn5000-b/midi/README.md:190` (`SeqVoice_CheckAndRet_Prologue`),
`analysis/disk-format-probes/README-lsw-panel-schema.md:169` and `README-lsw-nonpart-records.md:133`
(`SongBank_CheckAccompanimentMode`), `technics-docs/sysex-messages.md:58` (`SeqVoice_CheckAndRet_Prologue`).

### Website page draft

**technics-docs `sequencer.md`, section "Events".**  Replace the 0xBn, 0xCn and 0xD0-0xD3 rows with:

> | status | len | layout after the tick         | meaning                                                                                                                                                                                                                                             |
> |--------|-----|-------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
> | 0xBn   | 6   | record, field, value, mask    | **panel-parameter change**: the panel event {record, field, value, mask}, low 7 bits each; n bit 0 / 1 / 2 carry bit 7 of value / mask / record.  On playback the pair is matched against the track type's list (`SeqTrackAssign_PlaybackMapTable`) |
> | 0xCn   | 6   | part tag, 0, sound, variation | **sound select** of a part record: bytes +0 (panel sound number) and +1 (variation bank), n bit 0 / 1 = their bit 7                                                                                                                                 |
> | 0xD0   | 3   | value                         | **channel pressure** (aftertouch) of the track's part                                                                                                                                                                                               |
> | 0xD1   | 3   | value                         | **modulation** (CC 1)                                                                                                                                                                                                                               |
> | 0xD2   | 4   | lsb, msb                      | **pitch bend**                                                                                                                                                                                                                                      |
> | 0xD3   | 3   | value                         | **expression** (CC 11); on a CONTROL track the expression pedal                                                                                                                                                                                     |
>
> ### Controller events on playback
>
> The player adds the track number to 0xD0-0xD3 and queues them with the other non-note events.
> `Audio_ReinitAndProcessEvents` keeps the newest value per track (the arrays MIDI IN uses for CC 1, CC 11 and
> pitch bend) and sends each as a panel event: 0xB4 channel pressure, 0xB2 modulation, 0xB1 pitch bend, 0xB3
> expression, with field = the part's tag.  That reaches the sub CPU as `D0 part 00 value`, `B0 part 01 value`,
> `E0 part lsb msb` and `B0 part 0B value` (`SndPart_SetParam`).  Recording runs the other way: the same four panel
> events become D0 / D1 / D2 / D3 (`SeqTrackAssign_RecordMapTable`, `MIDI_EmitRecord_D0`…`_D3`).

**technics-docs `subcpu-command-format.md` (or `inter-cpu-protocol.md`, MIDI record table)** -- add: the 0xD0 record
is `D0 part 00 value` (value at +3).
