# Sub-lane `midi` of lane kn5000-b (wave 4, 2026-10-31)

Issues: kn5000-81p (Technics 0x50 SysEx wire formats), kn5000-5ck (proprietary CCs 0x91 / 0x9B / 0x9D),
kn5000-ake (MIDI implementation umbrella), kn5000-8dy (sound-selection descriptor slots +0x30 / +0x34 and the
C0 sender), kn5000-cox (panel sound catalogue), and the kn5000-nl6 lead `SysEx_BytecodeDispatcher`.

All addresses are main CPU v10 or sub CPU v1.42 unless stated.  Every routine named here is a label in the
current source; the renames this sub-lane made are listed at the end.

Probes (`probes/README.md` says how to run each):

| script                               | question                                                                  |
|--------------------------------------|---------------------------------------------------------------------------|
| `probes/sysex_rx_catalogue.py`       | which incoming SysEx byte strings are recognised, and which routine runs  |
| `probes/technics_param_addresses.py` | which panel field each Technics parameter-change/request address reaches  |
| `probes/sound_desc_slots_30_34.py`   | what descriptor slots +0x30 / +0x34 hold; is the voice index a GM program |

Generator: `scripts/generators/gen_sound_patch_catalogue.py`, output `sound-patch-catalogue.md` (kn5000-cox).

## kn5000-5ck: proprietary controllers 0x91, 0x9B, 0x9D

`Voice_CtrlChange` (sub CPU) compares the controller number against 0x9D, 0x9C, 0x9B, 0x97, 0x95, 0x91, 0x5E,
0x5D, 0x5B, 0x40, 0x0B, 0x0A, 0x07 and 0x01.  0x95 / 0x97 / 0x9C were named in October (glide pedal, sustain
length, key scaling, all sent by `SndPart_SetParam`).  The three left were named "reverb depth", "delay depth"
and "delay feedback" with no reader behind them.  Each setter stores one byte of the part record
(`0x041368 + part * 0x11F`); the readers of those bytes say what they are:

| CC   | part byte          | readers (v1.42)                                                                                        | what the value does                                                                                                                                                                                                                                                                                                                                                   | reset value (`Voice_ResetAllControllers`) |
|------|--------------------|--------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| 0x91 | +0x17 (`0x04137F`) | `Voice_Env_ApplyVelocity_Type0` / `_Type2`, sub-cases 2 and 3 only                                     | the part's own velocity-switch configuration, twin of the global byte `0x04134B` (`Voice_SetVelSwitchConfig`, sub-command F0 50 91).  Bit 3 (type 0/1) or bit 4 (type 2) set = nothing; else bit 0 (case 2), or bit 0 with bit 1 clear (case 3), lets `Instrument_LookupProgram_HiNibble` / `_LoNibble` install the patch's +0x2A octave-shift nibble into part +0x6D | 0                                         |
| 0x9B | +0x25 (`0x04138D`) | `Voice_Apply_GateRouting`, called by `Voice_Build_GateCommand` and `Voice_Build_GateCommand_NoPartial` | patches the voice's gate/control word (TG bank +0x000).  Low nibble: 0 = force bits 11:9 to 7, 1 = leave, 2 = force to 1.  High nibble 0x00 / 0x10 / 0x20: the same for bits 14:12                                                                                                                                                                                    | 1                                         |
| 0x9D | +0x26 (`0x04138E`) | `Voice_Level_ClearAllOutputRegs`, `Voice1_UpdatePitch_WriteStereoField`, `Voice_Step_ExprRamp`         | chooses the low 7 bits of the voice's TG register 0x180 (pan on tone-generator.md, 0x40 = centre): 1 = 0x00, 2 = 0x7F, anything else = the voice's own value                                                                                                                                                                                                          | 0                                         |

Senders.  `SndPart_SetParam` sends none of the three.  A search of every `MIDI_SendControlChange` call in the
v10 tree (controller in BC, spelled in decimal or hex; `command grep -rn -B12 "MIDI_SendControlChange$" v10/maincpu`)
finds one sender of 0x91 and none of 0x9B / 0x9D:

- `SwbtB2_Code9A_Listener` (audio/note_voice_mapping.s): on panel event payload 1 = 4..19, looks the part up
  through `SEQ_TRACK_ASSIGN` and `AudioInit_SlotOrderMap`; for parts 0, 1 and 2 it sends CC 0x91 with value
  payload 3 AND payload 2.
- The global byte is sent by `AudioInit_VoiceParamCtrl` as `F0 50 91 <(0xC5A8)>`, rebuilt from PANEL_MIDI+3 bit 0,
  RAM `0xC5C8`, `0xC1FF` and `0xC596`.

Controllers above 0x7F cannot arrive on MIDI IN, so 0x9B and 0x9D stay at their reset values unless code not found
by this search sends them (HD-AE5000 was searched too; nothing).  That they are dormant in v10 is a finding of the
search, not a proof.

The website's midi-subsystem.md "Research Needed" line (CC97 = chorus depth, CC9B = delay depth, CC9C = delay on/off,
CC9D = delay feedback) is stale on all four; its table rows for 0x91 / 0x9B / 0x9D are wrong.

Source changes: renames below, new headers on the three setters, `Voice_Apply_GateRouting` and `Voice_CtrlChange`,
and the reset list in `Voice_ResetAllControllers`' header (which still said "portamento rate / depth / time", "reverb
depth, chorus enable, chorus depth, delay depth, delay enable, delay feedback"), corrected to the setters it calls.

### Website page draft (midi-subsystem.md, "Proprietary Controllers" table and "Research Needed")

Replace the proprietary-controller table with:

| CC#  | Handler                    | Parameter                            | Part byte   | Notes                                                                                                                              |
|------|----------------------------|--------------------------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------|
| 0x91 | `Voice_CC_VelSwitchConfig` | velocity-switch configuration (part) | +0x17       | `Voice_CC_SetVelSwitchConfig`; read by the `Voice_Env_ApplyVelocity_*` dispatchers; sent by `SwbtB2_Code9A_Listener` for parts 0-2 |
| 0x95 | `Voice_CC_GlidePedal`      | glide pedal on/off                   | +0x0A bit 2 | `Voice_CC_SetGlidePedal` (part parameter 0x603)                                                                                    |
| 0x97 | `Voice_CC_SustainLength`   | sustain length                       | +0x18       | `Voice_CC_SetSustainLength`, raw byte (part parameter 0x600)                                                                       |
| 0x9B | `Voice_CC_GateRoutingMode` | gate-word routing override           | +0x25       | `Voice_CC_SetGateRoutingMode`; nibbles 0/1/2 force bits 11:9 / 14:12 of the gate word to 7 / leave / 1; no sender found            |
| 0x9C | `Voice_CC_KeyScaling`      | key scaling on/off                   | +0x02 bit 8 | `Voice_CC_SetKeyScaling` (part parameter 0x602)                                                                                    |
| 0x9D | `Voice_CC_TgPanMode`       | TG register 0x180 (pan) override     | +0x26       | `Voice_CC_SetTgPanMode`; 1 = 0x00, 2 = 0x7F, else the voice's own value; no sender found                                           |

and the last Research Needed line with: "~~Map remaining proprietary CC handlers~~ — 0x91 = per-part velocity-switch
configuration, 0x95 = glide pedal, 0x97 = sustain length, 0x9B = gate routing override, 0x9C = key scaling,
0x9D = TG pan override (2026-10-31; the earlier reverb/chorus/delay readings had no reader behind them)."

## kn5000-81p: the Technics (0x50) SysEx wire formats

### Receive: the recognition trie

`SysExRx_TrieRoot` (`0xEE493E`) is the root of an 817-entry trie of `{key, action, next}` records that
`MidiSeq_AssignVoiceSlots` / `MidiSeq_ScanSlot*_Loop` walk byte by byte after the parser state machine
(`SysEx_ParserLoop`) has taken F0 and the manufacturer byte (0x41, 0x50 or 0x7E).  An entry with a non-zero action
ends the match; the action is the **message id**, and two tables indexed by it pick the routines:
`SeqChan_CommandHandlers` (the bulk-transfer state machine, `MidiTable_DispatchHelper`, only on title 0x57
TITLE_MDEXC) and `SeqData_Handlers` (`SeqData_DispatchHandler`, parameter and universal messages).
`probes/sysex_rx_catalogue.py` walks the trie and prints all 101 terminal paths (34 ids).  Condensed:

| id    | bytes after F0 50                          | direction | meaning                                                                            | routine                                                                     |
|-------|--------------------------------------------|-----------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| 7     | `21 01 28 12 F7`                           | both      | handshake request (the sender's opening message)                                   | `MidiPkt_XferAnswerMsg21` answers once with `22 01 28 12 F7`                |
| 8     | `22 01 28 12 F7`                           | both      | handshake reply                                                                    | `MidiPkt_HandleCmdCode01` (stores three fields, state 2)                    |
| 1, 2  | `23 7E F7`, `24 7E F7`                     | sent      | ACK / NAK-shaped (WSA1R names)                                                     | received as bare `ret`s                                                     |
| 3     | `27 7E F7`                                 | both      | end of a transfer group                                                            | `MidiPkt_XferOnGroupEnd` (sets the group's bit of `0xBD1A`)                 |
| 4     | `28 7E F7`, `2A 7E F7`                     | both      | end of dump / destination full                                                     | `MidiSysEx_ProcessBlock`                                                    |
| 5     | `29 7E F7`                                 | both      | error / abort                                                                      | `SeqChan_UnhandledCmd_0x12` (error 23, `MidiSysEx_RecoverAbortedXferGroup`) |
| 9     | `25 <lo> <hi> F7`                          | both      | tempo: BPM = lo + 16 * hi, 40..300                                                 | `SeqData_FormatOutput_Dispatch` -> `SeqTimer_SetPanelTempo`                 |
| 10    | `7E <hi lo nibbles ...> <more> <cs> F7`    | both      | bulk data packet                                                                   | `MidiPkt_XferOnDataPacket` -> `SeqChan_StepCmdHandlers[state]`              |
| 11-25 | `2D 01 28 12 <adr3> <len3>`                | both      | data-dump block header (table below)                                               | `MidiPkt_ArpExtHandler_A` ... `MidiPkt_ArpExtHandler_J`                     |
| 27    | `2C 01 28 12 <adr3> <siz3> <data> <cs> F7` | both      | parameter change (address table below)                                             | `SysEx_OnTechnicsParamChange`                                               |
| 26    | `2C 01 28 12 28/30 xx xx xx xx xx`         | received  | parameter change, addresses 28xxxx / 30xxxx                                        | `SeqData_FormatOutput_CaseC`                                                |
| 29    | `2B 01 28 12 <adr3> <siz3> <cs> F7`        | received  | parameter request: answered with a 2C message                                      | `SysEx_OnTechnicsParamRequest`                                              |
| 28    | `2B 01 28 12 28/30 xx xx xx xx xx`         | received  | parameter request, addresses 28xxxx / 30xxxx                                       | `SeqData_FormatOutput_Default`                                              |
| 30-35 | `2B 01 28 12 <grp> 00 00 xx xx xx`         | received  | dump request: 20 panel, 38 sound memory, 50 style image, 60 sequencer, 48 MSP user | `MidiPkt_DispatchData_Chan4/3/1/2/6` -> `SysEx_InitiateSend` code 4/3/1/2/6 |
| 36/37 | (F0 7E) `7F 09 01` / `7F 09 02`            | received  | GM System On / Off                                                                 | `SysEx_OnGmSystemOn` / `SysEx_OnGmSystemOff`                                |
| 38    | (F0 41) `<dev> 42 12 40 ...`               | received  | Roland GS data set (reverb/chorus macro and level)                                 | `SysEx_OnRolandGsParam`                                                     |

`SysEx_InitiateSend` code 5 has no dump-request row (id 34 is not in the trie), which is why
`SysEx_InitiateSend_SendNoData` is never selected by a request.

### Bulk transfer

The data-dump block headers (`SysEx_TechMsg_*`, sent by `MidiPkt_ArpConfigChain_Data_Helper*`, and recognised as
ids 11-25) give each group's blocks; the receive handlers' headers give where each lands:

| id | header after `2D 01 28 12` | group / block                      | lands at (receive side)                          |
|----|----------------------------|------------------------------------|--------------------------------------------------|
| 11 | `20 00 00 00 0C 40`        | panel, block 1 (live panel)        | `MidiPkt_SetXferBlock_LivePanel`                 |
| 12 | `24 00 00 04 59 30`        | panel, block 2 (80 panel memories) | `0x1ED350`, 0x12CB0 bytes                        |
| 13 | `38 00 00 00 00 10`        | sound RAM, start (16-byte id)      | total at `0x1E0000`, 0x72AA bytes                |
| 14 | `38 00 10 00 5A 50`        | sound RAM, block 2                 | the rest of `0x1E0000`                           |
| 15 | `50 00 00 00 00 60`        | style image, start                 | `RHYTHM_PATTERN_BUF_A`, 0x16800 or the used size |
| 16 | `50 00 60 00 26 60`        | style image, block 2               |                                                  |
| 17 | `50 27 40`                 | style image, block 3               |                                                  |
| 18 | `60 00 00 00 10 00`        | sequencer: current song            |                                                  |
| 19 | `60 10 00 01 20 00`        | sequencer: song slots              |                                                  |
| 20 | `61 30 00 <len>`           | sequencer: event memory            | `0xB0000`, 0x4D800 or the used size              |
| 23 | `48 00 00 00 00 20`        | accompaniment block area, start    | `0x1E8800`, 0x3C00 or the used size              |
| 24 | `48 00 20 00 01 60`        | accompaniment block area, block 2  |                                                  |
| 25 | `48 02 00`                 | accompaniment block area, block 3  |                                                  |

The 3-byte fields after the address are the block's length as transmitted (their unit, bytes or 7-bit nibble
count, is not checked here).  Each block's data follows as `F0 50 7E` packets: every data byte is sent as two
nibbles, high first (`ArpQueue_ProcessAndSort_Data_Helper2`), until the 252-byte output buffer is full or the
block ends; then a continuation byte (1 = more, 0 = last, `_Helper3`), the checksum `-(sum) & 0x7F`
(`ArpQueue_ComputeAndEnqueue` with `SysEx_ChecksumEoxTemplate`) and F7.  A group ends with `27 7E F7`, the dump
with `28 7E F7` (or `29 7E F7` after an error), sent by `SysEx_FinishBulkSend`.  Session: the sender opens with
`21 01 28 12 F7`, the receiver answers `22 01 28 12 F7`.

### Parameter change / request addresses

`SysEx_DispatchTechnicsParamChange` switches on the address group (field 1 from the trie: 1 = `00 00 xx`,
3 = `01 00 xx`, 7 = `0A 00 xx`) and takes a 20-byte MIDI control record from `MidiCtl_SelectTable0` / `4` / `10`
(requests: `1` / `5` / `11`).  The record holds the address again (+0..+2), the panel-memory record tag (+6),
byte (+7), mask (+8) and range (+9..+10).  `probes/technics_param_addresses.py --md` prints all 34:

| address  | size | panel record, byte, mask | range   | known field (ram_panel_records.s)                  |
|----------|------|--------------------------|---------|----------------------------------------------------|
| 00 00 00 | 1    | 0x91 +0 0xFF             | -64..63 |                                                    |
| 00 00 01 | 1    | 0x91 +2 0xFF             | 0..1    |                                                    |
| 00 00 02 | 1    | 0x70 +2 0xFF             | 0..11   | transpose (+2)                                     |
| 00 00 03 | 1    | 0x93 +0 0x0F             | 0..9    |                                                    |
| 00 00 08 | 1    | 0x90 +4 0xFF             | 40..88  | R1R2 octave (+4)                                   |
| 00 00 10 | 1    | 0x98 +1 0x7F             | 0..80   | panel memory number (+1)                           |
| 00 00 11 | 1    | 0x98 +0 0x40             | 0..1    | panel memory mode (+0)                             |
| 00 00 12 | 1    | 0x98 +3 0x01             | 0..48   | music style arranger (+3)                          |
| 00 00 13 | 1    | 0x98 +3 0x70             | 1..3    | music style arranger (+3)                          |
| 00 00 20 | 2    | 0x17 +0 0xFF             | 0..127  |                                                    |
| 01 00 00 | 1    | 0xB0 +1 0x7F             | 0..127  |                                                    |
| 01 00 08 | 1    | 0x48 +4 0x40             | 0..1    |                                                    |
| 01 00 09 | 1    | 0x70 +4 0x0F             | 0..13   | TechniChord type (+4)                              |
| 01 00 10 | 1    | 0x60 +1 0x80             | 0..127  | acoustic illusion / equalizer / reverb on/off (+1) |
| 01 00 11 | 1    | 0x63 +0 0xFF             | 9..27   |                                                    |
| 01 00 21 | 1    | 0x61 +0 0xFF             | 1..99   |                                                    |
| 01 00 22 | 1    | 0x61 +17 0xFF            | 0..99   |                                                    |
| 01 00 30 | 1    | 0x60 +1 0x40             | 0..1    | acoustic illusion / equalizer / reverb on/off (+1) |
| 01 00 31 | 1    | 0x65 +0 0xFF             | 57..60  |                                                    |
| 01 00 40 | 1    | 0x43 +0 0x80             | 0..1    |                                                    |
| 01 00 41 | 1    | 0x66 +0 0xFF             | 88..91  |                                                    |
| 0A 00 00 | 2    | 0x48 +0 0xFF             | 0..139  |                                                    |
| 0A 00 02 | 1    | 0x48 +3 0x07             | 0..3    |                                                    |
| 0A 00 03 | 1    | 0x48 +3 0x08             | 0..1    |                                                    |
| 0A 00 04 | 1    | 0x90 +3 0x02             | 0..1    | APC on bass / left hold (+3)                       |
| 0A 00 08 | 1    | 0x48 +5 0x02             | 0..1    |                                                    |
| 0A 00 09 | 1    | 0x48 +7 0x30             | 0..3    |                                                    |
| 0A 00 0A | 1    | 0x48 +5 0x04             | 0..2    |                                                    |
| 0A 00 0B | 1    | 0x48 +5 0x08             | 0..1    |                                                    |
| 0A 00 0C | 1    | 0x48 +5 0xC0             | 0..2    |                                                    |
| 0A 00 0E | 1    | 0x48 +5 0x30             | 0..2    |                                                    |
| 0A 00 10 | 1    | 0x98 +11 0x80            | 0..1    |                                                    |
| 0A 00 11 | 1    | 0x98 +11 0x40            | 0..1    |                                                    |
| 0A 00 18 | 1    | 0x43 +1 0x7F             | 0..127  |                                                    |

The trie accepts a subset of these per direction (it has no request path for `00 00 20`, `0A 00 0A`-`0A 00 11`).
The panel-record tags are the panel-memory TLV tags (`PanelTlv_PayloadOfTag`); tag 0x48 is the style record.
Naming each field is left open: it needs each tag's keys, which `ram_panel_records.s` does not have for most tags.

### Internal F0 50 records to the sub CPU

`MIDI_SendSysExCmd` (F0 50 87, rhythm mode) is on sysex-messages.md.  The sub CPU's `Voice_SystemMsg` accepts more
sub-commands: 0x80-0x87 (`Voice_SystemMsg_DispatchTable`: 0x80/0x81 bare `ret`s, 0x82 master tune, 0x83 pitch-bend
range, 0x84 ignored, 0x85 key-shift enable, 0x86 scale-tune mode, 0x87 rhythm mode), 0x09 (polyphony mode),
0x91 (`Voice_SetVelSwitchConfig`, sent by `AudioInit_VoiceParamCtrl`), 0x92 (`Voice_AllVoices_PortamentoUpdate`),
0x99, and 0xA3-0xB1 (`Voice_SystemMsg_SubA3` .. `_SubB1`: scale-tune user offsets, velocity update, scale-tune
enable).  `SeqVoice_CheckAndRet_Prologue` sends `{4, F0, A, C, E}` records of this shape.

### Website page draft (sysex-messages.md, new section "Technics (0x50) Messages on MIDI" after "SysEx Parser State Machine")

> The KN5000's own 0x50 messages share the WSA1R's command bytes (21-2D, 7E) but use the model header
> `01 28 12` where the WSA1R uses `04 md 11`.  Incoming messages are recognised by a byte trie,
> `SysExRx_TrieRoot` (0xEE493E, 817 six-byte entries); the matched entry's action byte is a message id that
> indexes `SeqChan_CommandHandlers` (bulk transfer, only on the MIDI EXCLUSIVE screen) and `SeqData_Handlers`
> (parameters, tempo, GM and GS).

followed by the three tables above (messages, bulk-transfer blocks, parameter addresses), the packet-format
paragraph, and the internal-record list as a new row set under "Known Command Bytes".  Also correct the "Bulk Data
Transfer" section's "6 mode-specific handlers": `SysExSend_SwitchOffsets` has 7 entries (codes 0-6: all data, style
image, sequencer, sound memory, panel memory, none, MSP user).

## kn5000-ake: the MIDI implementation umbrella

With 81p and 5ck traced, the remaining work is the summary table on midi-subsystem.md, which says "Based on
KN5000 specifications".

### Website page draft (midi-subsystem.md, "MIDI Implementation")

Replace the heading's lead line with "Traced from the firmware:" and the table with:

| Feature          | What the firmware does                                                                                                                                             | Where                                                |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| Channel messages | 8n, 9n, Bn, Cn, Dn, En dispatched; An (poly pressure) is ignored                                                                                                   | `MIDI_CHANNEL_MESSAGE_DISPATCHER`, midi-serial-io.md |
| Parts            | 26 internal parts (0x00-0x19) in the sub CPU; the main CPU maps MIDI channels to parts                                                                             | `Voice_CtrlChange` rejects part >= 0x1A              |
| Controllers      | 0x01, 0x07, 0x0A, 0x0B, 0x40, 0x5B, 0x5D, 0x5E, the channel-mode range 0x78-0x7F (0x7A, 0x7C-0x7F ignored), internal 0x80-0x82, 0x91, 0x95, 0x97, 0x9B, 0x9C, 0x9D | `Voice_CtrlChange`; table above                      |
| Program change   | `{5, C0, part, program, bank, effect}` record to the sub CPU after `SndParam_ApplyMaskClamp`                                                                       | `SndPart_SendProgramChange`, sound-categories.md     |
| Bank select      | received Cn remapped through descriptor +0x38 into Bn 00, Bn 20, Cn                                                                                                | `SndParam_LookupFromPointerTable`                    |
| System real time | F8 clock (96 PPQN internal), FA/FB/FC; F8 sent on MIDI OUT; FE sent while bit 4 of 0xFD50 is set                                                                   | midi-serial-io.md                                    |
| SysEx            | Technics 0x50 (handshake, dump, parameter change/request, tempo), Universal 7E (GM On/Off), Roland 41 GS (reverb/chorus)                                           | sysex-messages.md                                    |
| GM mode          | descriptor mode 1 (128 GM voices, GS drum-set map) selected by `SndParam_LookupReadOnly(0xC0)`                                                                     | sound-categories.md                                  |

## kn5000-8dy: descriptor slots +0x30 / +0x34, and the C0 sender

**+0x30 is a GS drum-set map.**  `probes/sound_desc_slots_30_34.py` groups its 128 two-byte entries: indices
0-7, 25 and 64-127 -> `F0 00`; 8-15 -> `F3`; 16-23 -> `F7`; 24 and 26-31 -> `F2`; 32-39 -> `F1`; 40-47 -> `F5`;
48-55 -> `FC`; 56-63 -> `FD` (identical in v10, v9 and v7).  That is the GS drum-set numbering (Standard 1,
Room 9, Power 17, Electronic 25, TR-808 26, Jazz 33, Brush 41, Orchestra 49, SFX 57), and the generator resolves
the targets to Standard, Room, Power, Electric, Jazz, Brush, Orchestral and Sound Effect Kit.
`SndParam_LookupAndDispatch` uses it for a program change in bank 0x78 (the GM2 rhythm bank, 120);
`SndParam_LookupOscEnvelope` uses it instead of +0x1C for part 15 and for sounds >= 0xF0.  The kits are
programs 0xF0+k in bank 0, which `SndParam_ApplyMaskClamp` turns into program k in bank 0x40 (bank 1 -> 0x41).

**+0x34 is a note shift for SMF import.**  Its only reader, `SndParam_LookupByPartAndNote`, is called by
`MidiNoteOn_NonDrumLookupA` / `B` (sequencer/smf_tonegen_core.s, the SMF loader: it scales delta times to 96 ticks
per beat), which add the byte to the note number of each note-on on channels other than 10.  The voice index it is
indexed by is the GM program number: +0x1C resolves voice v to the KN5000 tone for GM program v+1 (0 Piano,
8 Celesta, 32 Acoustic Bass; `sound-patch-catalogue.md`, "GM voice map").  +12 goes to the basses, Bowed Bass,
Bright Trombone, Orchestral Tuba, Bigband Brass, Bassoon, Bass & Lead, Agogo, Breath Noise and Rock Harmonics;
-12 to Celesta, Glockenspiel, Music Box, Xylophone, Tubular Bells, Full Drawbars, Perc Organ, Piccolo, Whistle,
Tinkle Bell and Wood Block.  [INFERENCE] an octave correction between GM's written pitch and the KN5000 tones.

**The C0 sender** (sound-categories.md step 4) is `SndPart_SendProgramChange` (was `SendChannelPressure_Prologue`):
WA = part, BC = program, DE = bank, a pushed word = the part's DIGITAL EFFECT switch.  It runs
`SndParam_ApplyMaskClamp` and sends `{5, 0xC0, part, program, bank, effect (0 / 0x7F)}` with `MIDI_SendCmdPacket`.
Its only caller is `Song_SendPartDataBlocks`, which flushes the pending tables `0xCFD0` (program) / `0xD010` (bank)
that `SndPart_SetParam` fills for Lsw 0x000 / 0x020.  `SndParam_Init` sends the one literal C0 record
(part 0x19, program 0, bank 0x40).

`SndParam_ApplyMaskClamp` (mode 0, not for bank 0x78): program < 0x80 -> bank & 7; >= 0x80 with bank 7 ->
program & 0x7F in bank 0x70 (the two drawbar presets); 0x80-0xEF: bank 0 -> bank 0x10, bank 5 -> 0x15 (RAM user banks;
the panel's MEMORY A and B are programs 0x80-0xA7 in bank 0, entries 0-39 of user bank 0x10); 0xF0-0xFF: bank 0/1 -> program & 0x0F in bank 0x40/0x41 (drum kits), bank 6 -> 0x50, bank 5 -> 0x55
(user kits); anything else -> program 0, bank 0.  These are exactly the selectors `ToneDB_Find_PatchRecord` admits
(<= 7, 0x40, 0x41, 0x70) or diverts to RAM (0x10, 0x15, 0x50, 0x55).

Source: comments on descriptor slots +0x30 / +0x34 in `audio/sound_data.s` (v10, v9, v7, v6, v5; the labels
`SOUND_DATA_ORGAN_ACCORDION` / `SOUND_DATA_ORCHESTRAL_PAD` are kept, as the page says, for continuity), the rename
and a header on `SndPart_SendProgramChange` in all five trees.

### Website page draft (sound-categories.md)

In the slot table, replace the +0x30 and +0x34 rows:

| Slot  | Label (historical)           | What it is                                                                                                                       | Reader (v10)                                               |
|-------|------------------------------|----------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| +0x30 | `SOUND_DATA_ORGAN_ACCORDION` | **GS drum-set map**: drum-set program p -> KN5000 kit (0xF0+k, 0): Standard, Room, Power, Electric, Jazz, Brush, Orchestral, SFX | `SndParam_LookupOscEnvelope`, `SndParam_LookupAndDispatch` |
| +0x34 | `SOUND_DATA_ORCHESTRAL_PAD`  | **SMF-import note shift** per GM voice (0, +12, -12), added to note numbers on channels other than 10                            | `SndParam_LookupByPartAndNote`                             |

State that the voice index of +0x18/+0x1C/+0x30/+0x34 is the GM program number (0-based).  Replace step 4 of
"Sound Selection Flow" with: "**Program change** — `SndPart_SendProgramChange` sends the record
`{5, 0xC0, part, program, bank, effect}` to the sub CPU after `SndParam_ApplyMaskClamp` has turned panel program
numbers >= 0x80 into the tone database's bank selectors (0x70 drawbars, 0x40/0x41 drum kits, 0x10/0x15/0x50/0x55
RAM memories)."  Steps 5-7 stand.

## kn5000-cox: the panel sound catalogue

`scripts/generators/gen_sound_patch_catalogue.py` walks the firmware's own path (header of the script): the
descriptor's category/slot grid (+0x14, +0x24 in mode 1), the last-slot tables (+0x3C/+0x40/+0x44, +0x48/+0x4C),
`SndParam_ApplyMaskClamp`, then the sub CPU's `ToneDB_Find_PatchRecord` over the table-data tone database
(`ToneDB_BankMap_Main` -> `ToneDB_ToneNumBanks_Main` -> `ToneDB_ToneOffsetTable` -> record name).  Its output,
`sound-patch-catalogue.md` (`--check` compares), lists:

| section                     | sounds | from                           |
|-----------------------------|--------|--------------------------------|
| mode 0, ordinary parts      | 368    | +0x14 grid, +0x3C last slots   |
| mode 0, drum part (part 15) | 16     | +0x14 row 15, +0x40            |
| mode 0, part 20             | 16     | +0x14 row 15, +0x44            |
| mode 1, ordinary parts      | 128    | +0x24 grid, +0x48              |
| mode 1, drum part           | 8      | +0x24 row 15, +0x4C, via +0x30 |
| GM voice map                | 128    | +0x1C, +0x34                   |

Every cell resolves to a named ROM tone except MEMORY A/B (programs 0x80-0xA7 of bank 0, which become entries
0-39 of RAM user bank 0x10) and the user drum kit (bank 0x50), as the firmware's own bank selectors say.  The 368 total agrees with `sound_data_map_proof.py`.

Left open (and why): the per-sound sample mappings, envelopes and filters the issue also lists are fields of the
tone records whose layout is on tone-database.md; a per-tone parameter dump is not part of this catalogue.  The
mode-1 drum rows apply the mode-0 rewrite to the +0x30 result, which is an inference (the mode-1 send of a bank
0x78 pair is not traced).

### Website page draft (sound-categories.md, "Instrument Patch Catalog")

Replace the whole string-scan catalogue (from "The Table Data ROM contains the display names" to the end of the
per-group lists) with: a two-sentence lead ("The panel's sound list, read from the firmware's own tables:
category/slot grid -> program/bank -> `SndParam_ApplyMaskClamp` -> tone record.  Generated by
`scripts/generators/gen_sound_patch_catalogue.py`; slot numbers are as on the panel.") and the 18 mode-0 category
tables plus the drum-kit table of `sound-patch-catalogue.md`, then a collapsed "GM mode (mode 1)" section with the
mode-1 tables and the GM voice map.  Drop the "~311 names found by the string scan" count.

## kn5000-nl6 lead: `SysEx_BytecodeDispatcher`

Checked against the code (v10 display/scoop_display.s): it is the TT_SQSTEP panel-button action dispatcher, not a
SysEx routine.  It reads three request masks, takes the lowest set bit (`SqStep_LowestSetBitOfByte` / `_OfWord`)
and dispatches: 0x0DBF (note-length buttons, from `SwbtB2_CodeA8_Listener`) sends `F0 50 87 <byte | 2>` from the
6-byte table and selects the note length; 0x0DC0 (from `PerfMode_Handler_EvtB`) calls
`MemoryConfig_Handler_Table[bit]`; the word 0x1108 goes to `_Helper2`'s action switch.  All three callers are gated
on title 0x8A.  Renamed `SqStep_PanelButtonDispatch` (with all its `_Skip*`, `_Helper*`, `_Tbl*` locals), and its
table `SysInit_BytecodeBlock` (`.ascii "P@0 "` + `.byte 0x10, 0x00` in v10/v9, which is not text) is now
`SqStep_ButtonRhythmModeBytes`, `.byte 0x50, 0x40, 0x30, 0x20, 0x10, 0x00`, in all five trees.

## Renames (sed: `scripts/renaming/rename_open4_midi.sed`)

| old                                                       | new                                                               | trees                    |
|-----------------------------------------------------------|-------------------------------------------------------------------|--------------------------|
| `Voice_CC_91`                                             | `Voice_CC_VelSwitchConfig`                                        | v142 (v141, v140 regen.) |
| `Voice_CC_SetReverbDepth`                                 | `Voice_CC_SetVelSwitchConfig`                                     | v142 (v141, v140 regen.) |
| `Voice_CC_9B`                                             | `Voice_CC_GateRoutingMode`                                        | v142 (v141, v140 regen.) |
| `Voice_CC_SetDelayDepth`                                  | `Voice_CC_SetGateRoutingMode`                                     | v142 (v141, v140 regen.) |
| `Voice_CC_9D`                                             | `Voice_CC_TgPanMode`                                              | v142 (v141, v140 regen.) |
| `Voice_CC_SetDelayFeedback`                               | `Voice_CC_SetTgPanMode`                                           | v142 (v141, v140 regen.) |
| `SysEx_BytecodeDispatcher` (and `_*` locals)              | `SqStep_PanelButtonDispatch` (same suffixes)                      | v10, v9, v7, v6, v5      |
| `SysInit_BytecodeBlock`                                   | `SqStep_ButtonRhythmModeBytes`                                    | v10, v9, v7, v6, v5      |
| `SendChannelPressure_Prologue`                            | `SndPart_SendProgramChange`                                       | v10, v9, v7, v6, v5      |
| `SendChannelPressure_InitVal` / `_LoadReg` / `_LoadParam` | `SndPart_SendProgramChange_EffectSet` / `_StoreEffect` / `_Build` | v10, v9, v7, v6, v5      |

Old names remain in dated history files (analysis/, notes/ JSON, old sed scripts, v7 transplant manifest), which
record what was named then and are not rewritten.  The technics-docs pages that quote old names:
midi-subsystem.md (`Voice_CC_91`, `Voice_CC_9B`, `Voice_CC_9D`, `Voice_CC_Set*Depth/Feedback`), audio-subsystem.md,
sound-parameter-protocol.md and sysex-messages.md (grep for the six sub-CPU names); the drafts above replace them.
