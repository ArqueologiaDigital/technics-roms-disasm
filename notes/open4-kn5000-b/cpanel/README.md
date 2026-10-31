# Control panel: analog controllers, LED start-up, frame types 6/7, the data-wheel circuit

Lane `open4/kn5000-b-cpanel` (wave 4, 2026-10-31).  Issues: kn5000-3c7, kn5000-bq4, kn5000-9ye,
kn5000-xhi, kn5000-z9k, and the kn5000-nl6 lead `ENCODER_STATE_BASE`.

Sources read: `v10/maincpu/ui/cpanel_routines.s`, `midi/midi_encoder_routines.s`,
`audio/audio_control_engine.s`, `midi_encoder_constants.s`, `ui_widgets/widget_dispatch.s`,
`ui_widgets/naka_extension_device.c` (and the same files of v9, v7, v6, v5); the service manual
`technics-docs/service_manual/technics_sx-kn5000.pdf`, PDF page 32 (sheet II-11/II-12, CPU SECTION (A)) and
PDF page 45 (sheet II-35/II-36, CPL/CPC/CPCR/CPCL); technics-docs `control-panel-protocol.md`,
`panel-parameter-keys.md`, `data-wheel-investigation.md`, `hardware-architecture.md`.
Probes: [`probes/`](probes/README.md).  Labels below are the names after this lane's renames.

## kn5000-3c7: analog controllers

### What the hardware has

From the schematics (render recipe in `probes/README.md`):

| input                 | where                                                | conditioning                                 |
|-----------------------|------------------------------------------------------|----------------------------------------------|
| CPL MCU AD0, pin 11   | IC1 M37471M2196S on the CPL board                    | tied to ground: unused                       |
| CPL MCU AD1, pin 12   | `BEND`, CN3 pin 2 from the HB board (wheel pots)     | 1 kΩ (R15) series, 0.1 µF (C9) to ground     |
| CPL MCU AD2, pin 13   | `MOD`, CN3 pin 4 from the HB board                   | 1 kΩ (R16), 0.1 µF (C10)                     |
| CPL MCU AD3, pin 14   | `MAIN VOLUME`, VR1 20 kΩ (B) on the CPL board itself | 1 kΩ (R17), 0.1 µF (C11)                     |
| CPL MCU VREF, pin 18  | +5D through R4 100 Ω, C6 47 µF                       |                                              |
| main CPU AN0, pin 150 | `EXP` (expression-pedal jack)                        | R71 100 Ω series, C79 0.1 µF                 |
| main CPU AN1, pin 151 | `AFT` (after-touch sensor)                           | D1/D2 MA110 clamps, R18 1 kΩ, C80/C16 0.1 µF |

The old reading of the source (IDs 2 and 5 = modulation wheel and volume slider, IDs 25-27 = breath, foot and
expression) matched none of this.

### How each one is read and what it posts

Each control reaches the firmware as an 8-bit value, goes through one handler of `ENCODER_HANDLER_TABLE`
(`CPanel_EncoderDispatch`), and ends as a panel-event record whose tag is a panel record of
`panel-parameter-keys.md`: `0xB1` = pitch bend (Lsw `0x1B0` `_PitchBend`), `0xB2` = modulation (`0x001`
`_Modulation`), `0xB3` = part expression (`0x00B` `_Expression`), `0xB4` = channel pressure (`0x1B2`
`_ChannelPressure`), `0xB0` byte +1 = TOTAL EXPRESSION (`SndParam_TotalExpression`, function code 182).

| control          | path to the firmware                                      | id  | handler                          | event (action list)               | posts                                  |
|------------------|-----------------------------------------------------------|-----|----------------------------------|-----------------------------------|----------------------------------------|
| pitch bend wheel | CPL frame `0xD1`, type 2                                  | 25  | `Encoder_ProcessPitchBend`       | 22, `PanelAction_PitchBend`       | `{0xB1, 0}`, byte split to 14 bits     |
| modulation wheel | CPL frame `0xD2`                                          | 26  | `Encoder_ProcessModulation`      | 23, `PanelAction_Modulation`      | `{0xB2, 0}` unless MD_DEMO             |
| MAIN VOLUME      | CPL frame `0xD3`                                          | 27  | `Encoder_ProcessMainVolume`      | 24, `PanelEvent_Post`             | `{0xB0, 0}` (record 0xB0 byte +0)      |
| expression pedal | `ADREG04` high byte (AN0), `AnalogIn_PollExpressionPedal` | 2   | `Encoder_ProcessExpressionPedal` | 26, `PanelAction_ExpressionPedal` | `{0xB0, 1}` (182) or `{0xB3, 0}` (183) |
| after touch      | `ADREG15` high byte (AN1), `AnalogIn_PollAfterTouch`      | 5   | `Encoder_ProcessAfterTouch`      | 27, `PanelAction_AfterTouch`      | `{0xB4, 0}` when AFTER TOUCH is on     |

Evidence per row:

- **Pitch bend.**  `PanelAction_PitchBend` turns the byte `b` into LSB `(b & 1) << 6`, MSB `b >> 1` (0xFF gives
  0x7F/0x7F): a 14-bit bend.  `ENCODER_LUT_PITCHBEND` (256 B) has a plateau of 0x80 over raw 0x77..0x89: a
  centre dead band.  `Audio_SendPitchBendToParts` (was `Audio_IteratePartsWithExpression`) builds the same
  split from `ANALOG_PITCHBEND_VALUE`.  While a part records (`CMP_RECORD_PART` bits 0-3) or `(0x7f0b)` is set,
  `Encoder_ProcessPitchBend` rescales to `64 + (v/2 - 64) * n/12` with `n = ENCODER_BEND_RANGE`:
  `ENCODER_LUT_BEND_RANGE_MULT[k] = round(256 (k+1) / 12)` and `..._OFFSET[k] = 64 * MULT[k]`, 12 entries;
  `n = 0` sends nothing.  `ENCODER_BEND_RANGE` is record 0x93 byte +4 bits 0-3
  (`Encoder_OnTouchSensitivityChange`).  [INFERENCE] It is a bend range in semitones, 1..12: the 12 steps of
  n/12 fit that and nothing else found; no screen that edits record 0x93 byte +4 was traced.
- **Modulation.**  Tag `0xB2`; `Audio_SendModulationToParts` (was `..._IteratePartsWithVolume`) writes tag 178.
- **MAIN VOLUME.**  The third analog input of the CPL MCU.  `Encoder_ProcessMainVolume` uses a linear curve
  and never suppresses a repeat.  The record-0xB0 listener `ExtData_Voice_CompareAndDispatch` pairs the two
  bytes with the two variables: a write of byte +0 marks `ANALOG_MAIN_VOLUME_PENDING` and dispatches
  `{0xB0, 0, value, mask}` (`ExtData_Voice_CompareAndDispatch_Helper`), a write of byte +1 runs
  `MidiCh_ConfigVoiceAndParts` on `ANALOG_EXPRESSION_PEDAL_VALUE`.  [INFERENCE] Record 0xB0 byte +0 is the
  master volume: no panel-parameter key for it was found (byte +1 is TOTAL EXPRESSION, +3 the fade level).
- **Expression pedal.**  `PanelAction_ExpressionPedal` reads key `0x2880`, `SndParam_FootCtrl_ExpressionPedal`
  (the FOOT CONTROLLERS grid's EXPRESSION PEDAL assignment): 182 posts `{0xB0, 1}` (TOTAL EXPRESSION), 183
  retags to `{0xB3, 0}` (part expression), anything else posts nothing.  `Audio_SendExpressionToParts` (was
  `MIDI_DispatchVoiceParamCC`) sends tag 179 only when `PANEL_FOOT_CONTROLLERS+2` = 183 and the part's
  `_PartExp` bit (part +4 bit 5) is set.
- **After touch.**  `PanelAction_AfterTouch` posts only when key `0x104` (`SndParam_AfterTouch_OnOff`, record
  0x93 byte +6 bit 7) is set.  `Encoder_AfterTouch_ApplyThresholdCurve` computes
  `(max(v, T) - T) * 256 / 236 * M[C] / 20`, clamped to 127, with `T = ENCODER_AFTERTOUCH_THRESHOLD` (record
  0x93 byte +6 bits 0-6, `SndParam_AfterTouch_Threshold`) and `C = ENCODER_AFTERTOUCH_CURVE` (byte +5,
  `SndParam_AfterTouch_Curve`, range 1..10) indexing the 11-entry `ENCODER_LUT_AFTERTOUCH_CURVE_MULT`.
  `Encoder_OnTouchSensitivityChange` is listed in `SwbtB2_Code93_Listeners` (record 0x93 = OVERALL TOUCH
  SENSITIVITY).  `Audio_SendAfterTouchToParts` (was `..._IteratePartsWithPan`) writes tag 180 only for parts
  whose `_AfterTouch` bit (part +12 bit 4) is set.
- The main-CPU path, `AnalogIn_PollCpuAdc` (was `MidiParam_ProcessDeltas`): `AnalogIn_ReadAdcHigh` reads the
  high byte of `ADREG04`/`ADREG15` (0x121/0x123).  `AnalogIn_DebounceChange` compares it with the last accepted
  value: |delta| <= 2 is ignored and resets the counters, 3..6 is accepted on the second consecutive such
  reading, > 6 only on the fourth (a spike filter); acceptance sets bit 3 of `ADC_AN0_STATUS` /
  `ADC_AN1_STATUS`; the poller then runs the handler and sets bit 7 of `ADC_AN0_OUTPUT+1` / `ADC_AN1_OUTPUT+1`,
  which `PanelInput_QueueCpuAdcChanges` turns into records `{26 or 27, value, 0x7F}`.

[INFERENCE] The id = 24 + AD channel mapping of the CPL frames (AD1 -> 25, AD2 -> 26, AD3 -> 27) is read from the
three rows above agreeing with the three wired inputs; the panel MCU's mask ROM is not dumped, so the firmware
cannot show it directly.

### Renames (v10, v9, v7, v6, v5; sed script `scripts/renaming/rename_open4_cpanel.sed`)

108 rules.  Main ones:

| old                                     | new                                                                                                                                  |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| `Encoder_ProcessModwheel`               | `Encoder_ProcessExpressionPedal`                                                                                                     |
| `Encoder_ProcessVolume`                 | `Encoder_ProcessAfterTouch`                                                                                                          |
| `Encoder_ClampScaleAndNormalize`        | `Encoder_AfterTouch_ApplyThresholdCurve`                                                                                             |
| `Encoder_ProcessBreath`                 | `Encoder_ProcessPitchBend`                                                                                                           |
| `Encoder_ProcessFoot`                   | `Encoder_ProcessModulation`                                                                                                          |
| `Encoder_ProcessExpression`             | `Encoder_ProcessMainVolume`                                                                                                          |
| `Encoder_ApplySystemModeSettings`       | `Encoder_OnTouchSensitivityChange`                                                                                                   |
| `MIDI_CC_MODWHEEL_VALUE` / `_PENDING`   | `ANALOG_EXPRESSION_PEDAL_VALUE` / `_PENDING`                                                                                         |
| `MIDI_CC_EXPRESSION_VALUE` / `_PENDING` | `ANALOG_MAIN_VOLUME_VALUE` / `_PENDING`                                                                                              |
| `MIDI_CC_BREATH_VALUE`                  | `ANALOG_PITCHBEND_VALUE`                                                                                                             |
| `MIDI_CC_FOOT_VALUE`                    | `ANALOG_MODULATION_VALUE`                                                                                                            |
| `MIDI_CC_VOLUME_VALUE`                  | `ANALOG_AFTERTOUCH_VALUE`                                                                                                            |
| `ENCODER_BREATH_MODE`                   | `ENCODER_BEND_RANGE`                                                                                                                 |
| `ENCODER_VOLUME_MODE`                   | `ENCODER_AFTERTOUCH_CURVE`                                                                                                           |
| `ENCODER_RANGE_LIMIT`                   | `ENCODER_AFTERTOUCH_THRESHOLD`                                                                                                       |
| `ENCODER_RAW_*`                         | `ENCODER_RAW_{EXPRESSION_PEDAL,AFTERTOUCH,PITCHBEND,MODULATION,MAIN_VOLUME}`                                                         |
| `ENCODER_LUT_*`                         | `ENCODER_LUT_{EXPRESSION_PEDAL,AFTERTOUCH,AFTERTOUCH_CURVE_MULT,PITCHBEND,BEND_RANGE_MULT,BEND_RANGE_OFFSET,MODULATION,MAIN_VOLUME}` |
| `ENCODER_0_*` / `ENCODER_1_*`           | `ADC_AN0_*` / `ADC_AN1_*`                                                                                                            |
| `MidiParam_ProcessDeltas`               | `AnalogIn_PollCpuAdc`                                                                                                                |
| `MidiParam_ProcessChannel0` / `1`       | `AnalogIn_PollExpressionPedal` / `AnalogIn_PollAfterTouch`                                                                           |
| `MidiChannel_GetParamByIndex`           | `AnalogIn_ReadAdcHigh`                                                                                                               |
| `MIDI_ComputeParamDelta`                | `AnalogIn_DebounceChange`                                                                                                            |
| `Audio_IteratePartsWithExpression`      | `Audio_SendPitchBendToParts`                                                                                                         |
| `Audio_IteratePartsWithVolume`          | `Audio_SendModulationToParts`                                                                                                        |
| `Audio_IteratePartsWithPan`             | `Audio_SendAfterTouchToParts`                                                                                                        |
| `MIDI_DispatchVoiceParamCC`             | `Audio_SendExpressionToParts`                                                                                                        |
| `PanelAction_Event22` / `Event23`       | `PanelAction_PitchBend` / `PanelAction_Modulation`                                                                                   |
| `PanelAction_ModWheel` / `Volume`       | `PanelAction_ExpressionPedal` / `PanelAction_AfterTouch`                                                                             |
| `PanelInput_QueueWheelChanges`          | `PanelInput_QueueCpuAdcChanges`                                                                                                      |

The `.equ` comments, the routine headers, the ENCODER_HANDLER_TABLE / LUT comments and the PanelAction
headers were rewritten in all five trees.  `scripts/converters/panel_button_actions_retype.py` (a one-shot
converter, not in the build) has its handler names and strings updated so a re-run agrees.  Historical
records (`analysis/kn5000-naming/*.json`, `scripts/renaming/rename_*` of earlier waves,
`scripts/analysis/v7_shift_map.json`, `v7/maincpu/transplant_manifest.txt`) keep the old names on purpose.

## kn5000-bq4: control-panel start-up

Most of the issue was already on the website (init commands, timing, panel detection).  Two things were not.

**`CPanel_InitLEDBuffer` was misnamed.**  Now `CPanel_SendFramePolled`.  It stores WA at
`CPANEL_LED_TX_BUFFER` and pulses PF6 (SCLK1 / CTS1) low for 2 x `DELAY_300_LOOPS`.  It then switches PF4/PF6
to TxD1/SCLK1 on the baud-rate clock, writes `buffer[CPANEL_LED_READ_PTR]` and the next byte to `SC1BUF` with
polled delays, and restores the input clock.  So it sends one 2-byte frame without the interrupt state
machine.  It initialises nothing.  Nothing calls it in v10 or v7: no reference in the sources, and its address
(0xFC4021 v10, 0xFC3856 v7) occurs nowhere in the ROM images (`probes/ref_scan.py`).

**The power-on LED pattern.**  The main CPU has no lamp test and no all-LEDs-off command.
`CPanel_LED_FlushImage` (was `CtrlPanel_UpdateLEDState`) sends a row (`Set_LEDs`: 2-byte frame
`{Protocol_values_for_LED_rows[r], pattern}` through `LED_WriteToPanel` and `CPanel_LedQueue_PushByte`) only
when `CPANEL_LED_IMAGE[r]` differs from `CPANEL_LED_IMAGE_SENT[r]`.  `Boot_InitWorkRAM` zeroes both images
(0x400-0xE35C).  So after power-on, only rows with at least one lit LED are ever sent.  What the panel MCUs
show before the first frame is decided by their undumped mask ROMs.

Measured in MAME (`probes/led_boot_tap.lua`, a write tap on `CPANEL_LED_IMAGE_SENT`; logs
`probes/led_boot_tap.cold.log` and `.second.log`, identical; kn7000_mame build of 2026-10-31, romset
`technics_romsets/kn5000`, cold start, which opens "ALL INITIAL SETTING"):

| emulated time | row (protocol byte) | pattern | LEDs lit                                 |
|---------------|---------------------|---------|------------------------------------------|
| 7.754 s       | 2 (`0xC2`)          | `0x01`  | STANDARD ROCK                            |
| 7.754 s       | 3 (`0xC3`)          | `0x01`  | VARIATION 1                              |
| 7.754 s       | 6 (`0x00`)          | `0x08`  | DIGITAL REVERB                           |
| 7.754 s       | 7 (`0x01`)          | `0x01`  | PIANO                                    |
| 7.754 s       | 10 (`0x04`)         | `0x44`  | PART SELECT: RIGHT 1, CONDUCTOR: RIGHT 1 |
| 7.920 s       | 6 (`0x00`)          | `0x09`  | + SUSTAIN                                |
| 12.868 s      | 5 (`0xC8`)          | `0x01`  | OTHER PARTS/TR                           |

Before 7.75 s the panels receive only the init commands (`1F DA`, `1F 1A`, `1D 00`, `DD 03`, `1E 80`) and
polls.  The times are MAME's, with the sub-CPU boot ROM a `BAD_DUMP`, and are not real-hardware
measurements.  The LED states are the firmware's factory defaults.

Headers were added to `CPanel_LedQueue_PushByte` / `CPanel_LedQueue_PushBlock` (were `Seq_TimerEventLoop` /
`SeqBuf_TimerEvent_BytecodeBlock2`, names unrelated to what they do: they push into
`CPANEL_LED_EVENT_QUEUE`) and to `CPanel_SendFramePolled`.

## kn5000-9ye: frame types 6/7 and the two flags

**Type 6/7 frame** (`CPanel_RX_MultiBytePacket`, sized by `CPanel_SM_RXByte1`):

| byte       | bits | meaning                                                                                  |
|------------|------|------------------------------------------------------------------------------------------|
| H0         | 7:6  | panel select, as in a button frame (00 right, 11 left)                                   |
| H0         | 5:4  | `11` (type 6 or 7)                                                                       |
| H0         | 3:0  | N - 1: N = 1..16 data bytes.  Bit 3 is also the low type bit, so type 7 = a run of 9..16 |
| H1         | 4:0  | first segment (bit 4 clear) or first controller id (bit 4 set); bits 7:5 ignored         |
| D0..D(N-1) | 7:0  | state of segment / id H1 + i                                                             |

`CPanel_SM_RXByte1` expects `(H0 & 0x0F) + 3` bytes when `(H0 & 0x3F) >= 0x30`, otherwise 2.  The parser
waits until all N + 2 bytes are in the ring.  It writes one 3-byte record per data byte:
`{(H0 & 0xC0) | (H1 + i), value, changed}`.
- Segment bytes are exchanged into `STATE_OF_CPANEL_BUTTONS` (0x8E4A + segment, + 0x10 for the left panel),
  with `changed = old ^ new`: the same as `CPanel_RX_ButtonPacket` does for a single segment.
- Controller bytes go through `CPanel_EncoderDispatch`, with `changed = 0xFF`.  There is no record when the
  handler returns 0xFFFF.

So one type 6/7 frame can carry up to 16 segments of one panel.  [INFERENCE] This is the reply format of the
`2B 00` / `EB 00` start-up requests, which ask for every segment at once; no capture of a real panel exists to
confirm it.

**`CPANEL_TX_RX_FLAGS` bit 4.**  Tested only in `CPanel_RX_MultiBytePacket`: if set, a segment whose bits did not
change would produce no record.  Nothing sets it.  The absolute accesses to 0x8D8C (`probes/flag_access_scan.py`)
are `or 0x40/0x01/0x02/0x04`, `and 0xFC/0xFE/0xFD/0xFB`, `add 0x40` (bits 6-7 count) and `bit 0/1/4`.  The only
writer of 0 is the boot RAM clear.  So the drop is dead code, and every segment of a multi-segment frame is
queued, changed or not.

**`CPANEL_PROTOCOL_FLAGS`.**  Only bit 0 is ever read (`bit 0` in `CPanel_SM_RXByteN`): it means "RX ring full, do
not advance the write pointer".  `CPanel_SM_RXByte1` sets it when fewer than 3 bytes are free and clears it
otherwise.  The init and reset paths set it until the next frame header recomputes it.  Bits 1, 3, 6 and 7 are
written and never read.  Bit 2 is written only by the unlabelled instructions right after `CPanel_SM_Idle`'s
`jrl` (0xFC47F1 in v10, 0xFC47F6 is the `or`).  No source label sits there, and no copy of the address is in
the ROM (`probes/ref_scan.py`), so that code is unreachable and bit 2 is never set at run time.

## kn5000-xhi: the ROTA/ROTB circuit

PDF page 45 (sheet II-35, CPL board): one encoder, SW101 TEMPO/PROGRAM (part QSRGT002AA, "ENCODER SWITCH",
per the parts list quoted on data-wheel-investigation.md), three pins:

| SW101 pin | to                                                                                                  |
|-----------|-----------------------------------------------------------------------------------------------------|
| A         | ground (common)                                                                                     |
| B         | R11 4.7 kΩ pull-up to +5D; R13 47 kΩ series to IC1 pin 30 `ROTA`; C7 0.001 µF from pin 30 to ground |
| C         | R12 4.7 kΩ pull-up to +5D; R14 47 kΩ series to IC1 pin 31 `ROTB`; C8 0.001 µF from pin 31 to ground |

Each phase is an RC low-pass of 47 kΩ x 1 nF = 47 µs time constant, which debounces the switch contacts.  The
MCU counts detents and reports a signed count in frame `[0xD7, count]`.  The main CPU never sees the
quadrature.  The same sheet confirms the other CPL pins quoted above: AD0 grounded; AD1/AD2/AD3 = BEND / MOD /
MAIN VOLUME; X1 4 MHz; serial SIN pin 5, SOUT pin 4, CLK pin 3, CNTR1 pin 29.  The main connector CN1 carries
+36V, +5D, DATA, SCK, CPRST, VCON.  CN2 passes DATA/SCK/CPRST/+5D on to the CPR board.

## kn5000-z9k

Its last blocking child was kn5000-xhi.  With the circuit above, every page the issue names (II-3/4, II-9,
II-11, II-35, II-38) has been read into the website or these notes.  The analog-board pages are tracked as
kn5000-jy9 / kn5000-xel (other sub-lane).

## kn5000-nl6 lead: `ENCODER_STATE_BASE`

Wrong.  0x8F18 (v9/v10; v7 0x8E7C; v6/v5 0x8E58) is not encoder state: it is the 16-byte LED image, the wanted
pattern of LED rows 0..14 in `Protocol_values_for_LED_rows` order.  The ~50 `SndParam_SetResBit*` /
`ExtData_VoiceParam_DispatchBytecode_Mode*` handlers set and clear its bits.  `CPanel_LED_FlushImage` sends
what differs from the copy at +0x10.  Renamed `CPANEL_LED_IMAGE`, and the copy is now
`CPANEL_LED_IMAGE_SENT` (`CPANEL_LED_IMAGE + 0x10`, was a bare `0x8f28` / `0x8e8c` / `0x8e68`).

Seen in passing and not acted on: `ExtData_VoiceParam_DispatchBytecode` and the `MIDI_ProcessChangedChannels_*`
/ `MidiChanged_*` handler names belong to the panel-LED handler lists (they set mode LEDs).  They deserve
`PanelLed_*` names, which is a separate batch.

## Website page drafts

### control-panel-protocol.md

**§3 "Encoder Packet Format (Type 2)", table "Known Encoder IDs"**, replace with:

| ID     | Handler                          | Control                  | Source                       |
|--------|----------------------------------|--------------------------|------------------------------|
| 2      | `Encoder_ProcessExpressionPedal` | expression pedal         | main CPU AN0 (not a frame)   |
| 5      | `Encoder_ProcessAfterTouch`      | after-touch sensor       | main CPU AN1 (not a frame)   |
| 25     | `Encoder_ProcessPitchBend`       | pitch bend wheel         | CPL frame `0xD1` (AD1, BEND) |
| 26     | `Encoder_ProcessModulation`      | modulation wheel         | CPL frame `0xD2` (AD2, MOD)  |
| 27     | `Encoder_ProcessMainVolume`      | MAIN VOLUME slider       | CPL frame `0xD3` (AD3, VR1)  |
| 31     | `Encoder_PassthroughIdentity`    | TEMPO/PROGRAM data wheel | CPL frame `0xD7`             |
| others | `Encoder_ReturnDefaultConstant`  | none (returns 1)         |                              |

IDs 2 and 5 are never sent by a panel.  The main CPU's own A/D poller (`AnalogIn_PollCpuAdc`) calls the table
with them.

**§3 "From a button change to an action"**: in the first paragraph, replace "22-24 = left-panel headers
`0xD1`, `0xD2`, `0xD3` (Type 2 frames of encoder IDs 25-27: `Encoder_ProcessBreath`, `Encoder_ProcessFoot`,
`Encoder_ProcessExpression`)" with "22-24 = left-panel headers `0xD1`, `0xD2`, `0xD3`: the pitch bend wheel,
the modulation wheel and the MAIN VOLUME slider (encoder IDs 25-27)".  Replace "26 = the modulation wheel and
27 = the volume slider (`ENCODER_0_OUTPUT` / `ENCODER_1_OUTPUT`, queued by `PanelInput_QueueWheelChanges`)" with
"26 = the expression pedal and 27 = the after-touch sensor (main CPU AN0 / AN1, `ADC_AN0_OUTPUT` /
`ADC_AN1_OUTPUT`, queued by `PanelInput_QueueCpuAdcChanges`)".  Rows 22-27 of the action-list table become:

| index | segment | buttons (mask)                         | event id, arg  | handler                       |
|------:|:--------|:---------------------------------------|:---------------|:------------------------------|
| 22    | --      | pitch bend wheel (CPL `0xD1`) (`0xFF`) | `0xB1`, `0x00` | `PanelAction_PitchBend`       |
| 23    | --      | modulation wheel (CPL `0xD2`) (`0x7F`) | `0xB2`, `0x00` | `PanelAction_Modulation`      |
| 24    | --      | MAIN VOLUME (CPL `0xD3`) (`0x7F`)      | `0xB0`, `0x00` | `PanelEvent_Post`             |
| 26    | --      | expression pedal (CPU AN0) (`0x7F`)    | `0xB0`, `0x01` | `PanelAction_ExpressionPedal` |
| 27    | --      | after touch (CPU AN1) (`0x7F`)         | `0xB4`, `0x00` | `PanelAction_AfterTouch`      |

Add after the table: "The tags of 22-27 are panel records: `0xB1` pitch bend, `0xB2` modulation, `0xB3` part
expression, `0xB4` channel pressure, `0xB0` byte +1 TOTAL EXPRESSION, byte +0 (inferred) master volume (see
[Panel Parameter Keys]).  `PanelAction_PitchBend` spreads the byte over a 14-bit bend (LSB `(b & 1) << 6`, MSB
`b >> 1`).  `PanelAction_ExpressionPedal` follows the FOOT CONTROLLERS assignment of the EXPRESSION PEDAL (key
`0x2880`): 182 TOTAL EXPRESSION posts `{0xB0, 1}`, 183 retags to `{0xB3, 0}`.  `PanelAction_AfterTouch` posts
only while AFTER TOUCH is on (key `0x104`)."

**§5 "Analog Controller / Encoder Format"**: replace the first sentence with "The three analog controls of the
CPL board (pitch bend, modulation, MAIN VOLUME) send **absolute 8-bit A/D values** in Type 2 frames.  The
expression pedal and the after-touch sensor are read by the main CPU's own A/D converter, not by a panel."
Replace the table "Active Encoder IDs and Handlers" with:

| ID  | Handler                          | Control          | Processing                                                                                    | Output variable                 |
|-----|----------------------------------|------------------|-----------------------------------------------------------------------------------------------|---------------------------------|
| 2   | `Encoder_ProcessExpressionPedal` | expression pedal | invert, /2, `ENCODER_LUT_EXPRESSION_PEDAL` (128 B)                                            | `ANALOG_EXPRESSION_PEDAL_VALUE` |
| 5   | `Encoder_ProcessAfterTouch`      | after touch      | `ENCODER_LUT_AFTERTOUCH` (256 B), then threshold and curve (record 0x93 +5/+6)                | `ANALOG_AFTERTOUCH_VALUE`       |
| 25  | `Encoder_ProcessPitchBend`       | pitch bend       | invert, `ENCODER_LUT_PITCHBEND` (256 B, centre dead band); bend-range rescale while recording | `ANALOG_PITCHBEND_VALUE`        |
| 26  | `Encoder_ProcessModulation`      | modulation wheel | /2, `ENCODER_LUT_MODULATION` (128 B)                                                          | `ANALOG_MODULATION_VALUE`       |
| 27  | `Encoder_ProcessMainVolume`      | MAIN VOLUME      | invert, /2, `ENCODER_LUT_MAIN_VOLUME` (linear), never suppresses a repeat                     | `ANALOG_MAIN_VOLUME_VALUE`      |
| 31  | `Encoder_PassthroughIdentity`    | data wheel       | none (signed detent count)                                                                    | --                              |

Drop the "MIDI CC" column: none of these values is a MIDI controller number inside the firmware.  The LUT table
gets the new names (`ENCODER_LUT_EXPRESSION_PEDAL` 0xEDA13C, `ENCODER_LUT_AFTERTOUCH` 0xEDA1BC,
`ENCODER_LUT_AFTERTOUCH_CURVE_MULT` 0xEDA2BC, `ENCODER_LUT_PITCHBEND` 0xEDA2D2, `ENCODER_LUT_BEND_RANGE_MULT`
0xEDA3D2, `ENCODER_LUT_BEND_RANGE_OFFSET` 0xEDA3EA, `ENCODER_LUT_MODULATION` 0xEDA402,
`ENCODER_LUT_MAIN_VOLUME` 0xEDA482).  In the HLE sample, `response[0]` for the CPL controls is `0xD1`/`0xD2`/`0xD3`.

**§5 "MIDI Parameter Delta Processing"**: retitle "Main-CPU A/D: expression pedal and after touch"; the routine is
`AnalogIn_PollCpuAdc` (0xFC6ED1).  Channel 0 is AN0 = expression pedal (ID 2), channel 1 is AN1 = after touch
(ID 5), from the CPU SECTION (A) sheet: `EXP` -> R71 -> pin 150 AN0, `AFT` -> MA110 clamp, R18 -> pin 151 AN1.
Rename `ENCODER_0_*`/`ENCODER_1_*` -> `ADC_AN0_*`/`ADC_AN1_*`, `MIDI_ComputeParamDelta` -> `AnalogIn_DebounceChange`,
`MidiChannel_GetParamByIndex` -> `AnalogIn_ReadAdcHigh`.

**§5 "MIDI Controller Output"**: replace the controller-mapping table with:

| Variable                        | Control          | Sent as                                   | Sender                                    |
|---------------------------------|------------------|-------------------------------------------|-------------------------------------------|
| `ANALOG_PITCHBEND_VALUE`        | pitch bend       | record `0xB1` (14-bit)                    | `Audio_SendPitchBendToParts`              |
| `ANALOG_MODULATION_VALUE`       | modulation       | record `0xB2`                             | `Audio_SendModulationToParts`             |
| `ANALOG_EXPRESSION_PEDAL_VALUE` | expression pedal | record `0xB0` +1, or `0xB3` per part      | `Audio_SendExpressionToParts`             |
| `ANALOG_AFTERTOUCH_VALUE`       | after touch      | record `0xB4` (parts with AFTER TOUCH on) | `Audio_SendAfterTouchToParts`             |
| `ANALOG_MAIN_VOLUME_VALUE`      | MAIN VOLUME      | record `0xB0` +0                          | `ExtData_Voice_CompareAndDispatch_Helper` |

**§6 memory map**: rows 0x8EE0-0x8EF4 and 0x8EFC-0x8F18 take the new names (table in these notes, "Renames").
Add `0x8F28 CPANEL_LED_IMAGE_SENT 16 bytes, rows as last sent` and give 0x8F18 as `CPANEL_LED_IMAGE`, 16 bytes,
wanted LED rows 0-14.  Flag tables:

| Bit (`CPANEL_TX_RX_FLAGS`) | Usage                                                                                                    |
|----------------------------|----------------------------------------------------------------------------------------------------------|
| 0                          | RX in progress (set by `INTA_HANDLER`, cleared when the last reply byte arrives)                         |
| 1                          | TX in progress (set by `CPanel_SendCommand`, `CPanel_SM_TXComplete` and `CPanel_InterruptPoll_MainLoop`) |
| 2                          | Set by `CPanel_RX_ProcessWithFlag`, cleared by `CPanel_RX_Process`; never read                           |
| 4                          | Never set.  `CPanel_RX_MultiBytePacket` would drop unchanged segments when it is set: dead code          |
| 6-7                        | 2-bit counter (`add 0x40`); bit 6 set by `CPanel_InitHardware`                                           |

| Bit (`CPANEL_PROTOCOL_FLAGS`) | Usage                                                                                              |
|-------------------------------|----------------------------------------------------------------------------------------------------|
| 0                             | RX ring full: `CPanel_SM_RXByteN` does not advance the write pointer (read in `CPanel_SM_RXByteN`) |
| 1, 3, 6, 7                    | Written (TX start, sync frame, INTA count-down, idle) and never read                               |
| 2                             | Written only by unreachable code after `CPanel_SM_Idle`; never set at run time                     |

**§7 Code Reference, Initialization Routines**: row `0xFC4021 CPanel_InitLEDBuffer "Configure serial port,
init LED array"` becomes `0xFC4021 CPanel_SendFramePolled "Sends WA as one 2-byte frame on SC1 with polled
timing (no caller in this build)"`.

**§9 "Multi-byte Packet Purpose (Types 6, 7)"**: retitle "(RESOLVED)" and replace the body with the type 6/7
table and the paragraph after it from section kn5000-9ye of these notes.

**New subsection under §3 "LED Control Commands"**, "Power-on LED sequence": the text and table of section
kn5000-bq4 above, from "The main CPU has no lamp test" to the end of the table, with the caveat paragraph.

### hardware-architecture.md, "CPL Board (Control Panel Left)"

Replace the rows `AD0-AD3`, `BEND`, `MOD0, MOD1`, `MAIN VOLUME` with:

| Pin/Signal                   | Function                                                              |
|------------------------------|-----------------------------------------------------------------------|
| `AD0` (pin 11)               | grounded, unused                                                      |
| `AD1` (pin 12)               | `BEND`, pitch bend wheel from the HB board (CN3 pin 2), 1 kΩ + 0.1 µF |
| `AD2` (pin 13)               | `MOD`, modulation wheel from the HB board (CN3 pin 4), 1 kΩ + 0.1 µF  |
| `AD3` (pin 14)               | `MAIN VOLUME`, VR1 20 kΩ (B) on the CPL board, 1 kΩ + 0.1 µF          |
| `ROTA`, `ROTB` (pins 30, 31) | SW101 TEMPO/PROGRAM encoder, see below                                |

and add a subsection "Data-wheel encoder (SW101)" with the SW101 table and RC paragraph of section kn5000-xhi.
Under "Main CPU", add "Analog inputs: AN0 (pin 150) = `EXP`, expression-pedal jack (R71 100 Ω, C79 0.1 µF);
AN1 (pin 151) = `AFT`, after-touch sensor (MA110 clamp diodes D1/D2, R18 1 kΩ, C80/C16 0.1 µF).  Sheet II-11."

### data-wheel-investigation.md

After the paragraph that introduces SW101, add the SW101 pin table and: "Each phase is pulled up by 4.7 kΩ and
low-pass filtered by 47 kΩ and 1 nF (τ = 47 µs) before the MCU pin; the MCU does the quadrature decoding and
reports detents as `[0xD7, count]`."

### boot-sequence.md

In the timeline, add: "Panel LEDs: nothing is lit by the main CPU until the first `CPanel_LED_FlushImage` pass
after the main screen state is built (about 7.75 s emulated in MAME; see [Control Panel Protocol])."

### Symbol sync on the website (Symbol Name Synchronization policy)

These technics-docs pages quote names this lane renamed; apply `scripts/renaming/rename_open4_cpanel.sed` to them
(it is whole-word and safe on prose) when publishing the drafts above, then reread the changed sentences, since
the old names carried the old meanings ("breath", "foot", "modulation wheel", "volume slider"):

| page                        | old names quoted                                                                                                        |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------|
| control-panel-protocol.md   | 33 distinct (encoders, LUTs, `MIDI_CC_*`, `ENCODER_0/1_*`, PanelAction_*, `CPanel_InitLEDBuffer`, `ENCODER_STATE_BASE`) |
| memory-map.md               | 31 distinct (the 0x8ECA-0x8F18 RAM block and the 0xEDA13C-0xEDA482 LUTs)                                                |
| data-wheel-investigation.md | the five `Encoder_Process*` handlers                                                                                    |
| rom-reconstruction.md       | `Encoder_ProcessModwheel`                                                                                               |

Also in memory-map.md, describe 0x8F18 as `CPANEL_LED_IMAGE` (16 B) and add 0x8F28 `CPANEL_LED_IMAGE_SENT` (16 B).
