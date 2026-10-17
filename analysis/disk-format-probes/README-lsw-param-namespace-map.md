# The panel parameter-id space is a LAW: `id = 0x8000 + 0x400*tag + field`

Companion note to `analysis/disk-format-probes/lsw_param_namespace_map.py`.

```
python3 analysis/disk-format-probes/lsw_param_namespace_map.py
python3 analysis/disk-format-probes/lsw_param_namespace_map.py --quiet     # just the gate
python3 analysis/disk-format-probes/lsw_param_namespace_map.py --dump      # the census
```

ROM only, no corpus needed. It exits non-zero if any of the eight tests stops holding, on v7,
v9 **and** v10 — the census it builds is identical in all three.

## Why redo a scan that was already done

`README-lsw-leftover-records.md` calls the parameter-descriptor table "the general tool this
pass found", and scans ids `0x4000..0x4FFF`. That window had already cost one wrong conclusion:
tags `0x44/0x45/0x46` were written down as *"none of the three carries a parameter-id
descriptor, so they are not UI-editable"* — and their 48 ids turned out to sit at
`0x8200/0x8600/0x8A00`, outside the window. `README-lsw-drawbar-records.md` retracted it with
the note that *"the inference 'no descriptor found → not UI-editable' turned a search limit into
a property of the data"*.

This probe scans **the whole id space**, `0x0001..0xFFFF`, and freezes what comes out.

### The filter, and why it needs two rules rather than one

A descriptor is 18 bytes: `u32 param-id | u8 tag | u8 offset | u16 mask | …`. A candidate is
kept only if the id is `0x0001..0xFFFF`, the tag is a schema tag, the offset is inside that
record's payload, the mask is one contiguous run of bits in `0x01..0xFF`, **and**

* another valid candidate sits exactly `0x12` bytes before or after it — it is part of a run,
  which is what a table looks like and a lucky stretch of code does not; **and**
* the id occurs exactly once in the whole census — a parameter id names one field.

Both rules earn their place, and the second one is the new part:

* without the run rule the census invents `0x8D4E → tag 0x68 +0 mask 0x40` at `0xFB6C4B`, four
  random bytes inside an instruction, which would have "refuted" the tag-`0x68` finding;
* without the uniqueness rule it swallows two data tables that decode as descriptors by
  accident — `0xF800 → tag 0x00 +0 mask 0xF8` at **twenty** addresses in `0xE86A..0xE8A0`, and
  `0x0031 → tag 0x63 +0 mask 0x01` at **thirteen** addresses in `0xEE50..0xEE58` — and the law
  below acquires five spurious exceptions (tags `0x00 0x03 0x08 0x0C 0x0D`).

---

## 1. The part namespace law — PROVEN

For every one of the 25 per-part records, tag `T` in `0x00..0x18`, all the parameter ids that
name it fall in one namespace, and it is

    namespace(T) = 0x8000 + 0x400 * T

`0x00`→`0x80xx`, `0x01`→`0x84xx`, `0x02`→`0x88xx`, … `0x18`→`0xE0xx`. No exception, no gap, no
sharing. And the law is finer than the namespace: **every part carries the same ten field
constants**

    id = 0x8000 + 0x400*T + k,     k ∈ { 07, 08, 0A, 20, 40, 5B, 5D, 5E, 80, 81 }

with parts `0x01`, `0x02` and `0x03` carrying an eleventh, `k = 0x00`. So an id anywhere in
`0x8000..0xE3FF` **decodes on sight**: `(id - 0x8000) >> 10` is the part tag and `id & 0x3FF`
is which of its fields. That is a tool for the next pass, not just a fact: any UI screen table
that names such an id immediately says which part and which parameter it is editing.

## 2. The drawbar records are parts 0, 1 and 2 — arithmetically — PROVEN

    tag 0x44 -> 0x8200 = namespace(part 0x00) + 0x200
    tag 0x45 -> 0x8600 = namespace(part 0x01) + 0x200
    tag 0x46 -> 0x8A00 = namespace(part 0x02) + 0x200

16 ids each, 48 in all, and **exactly three non-part tags hold a namespace inside the part id
block `0x8000..0xE3FF` — these three.** (Tag `0x98` has a stray `0xE807`/`0xE808` pair at
`0xEDE96C`/`0xEDE97E`, above the block, so it does not clash.)

`README-lsw-drawbar-records.md` identified the trio as the drawbar registration of RIGHT 1 /
RIGHT 2 / LEFT and assigned the three parts from the *count* of records — "the set of three WAS
the clue — three parts". The namespace arithmetic reaches the same assignment without counting
anything: each record is a `+0x200` sub-namespace of one specific part's id block, and the
parts are 0, 1 and 2. Two derivations, no shared step.

The three records' `(k, offset, mask)` triples are **identical**, which is the strongest form
the old "three identical records" observation has taken:

| offset | fields |
|---|---|
| `+0` | none |
| `+1` | `k=CC` mask `0x0F`, `k=CB` mask `0xF0` |
| `+2` | `k=93` mask `0x0F`, `k=94` mask `0xF0` |
| `+3` | `k=80` mask `0x0F`, `k=81` mask `0xF0` |
| `+4` | `k=82` mask `0x0F`, `k=83` mask `0xF0` |
| `+5` | `k=84` mask `0x0F`, `k=85` mask `0xF0` |
| `+6` | `k=86` mask `0x0F`, `k=87` mask `0xF0` |
| `+7` | `k=88` mask `0x0F`, `k=C0` mask `0x10`, `k=C1` mask `0x20` |
| `+8` | `k=21` mask `0x0F` |
| `+9` | none |

i.e. **thirteen 4-bit values and two 1-bit flags**, packed two per byte. The drawbar note's
observation that `0x46` differs from `0x44`/`0x45` at `+3` — "LEFT's 16' drawbar, 8 → 0" — is
the low nibble of `+3`, `k = 0x80`, which is the *first* `k` of the run `80 81 82 83 84 85 86
87 88`: nine consecutive constants for nine consecutive nibbles. **[INFERENCE]** that those
nine are the nine footages — but it is the reading the id numbering itself suggests, and the
falsifier is cheap: move one drawbar on real hardware and see which nibble changes.

## 3. Tag `0x9A` — the negative survives the full window — PROVEN

`README-lsw-leftover-records.md` §3 said "no parameter-id descriptor names tag `0x9A`, while 14
other tags do", measured inside `0x4000..0x4FFF`. Over `0x0001..0xFFFF` it still holds, and the
census is demonstrably not blind: its neighbours in TLV block 1 collect **15** (`0x92`), **27**
(`0x99`) and **29** (`0x98`) ids in the same run of the same scan. The probe asserts those
three counts *as positive controls*, so a change that silenced the census would fail the test
rather than pass it.

This is the "state your window" upgrade the earlier notes asked for: the tag-`0x9A` negative is
no longer a statement about `0x4000..0x4FFF`.

The full list of schema tags with **no parameter id anywhere in the id space**:

    19  49  68  71  72  78  90  9A      and the whole C0..D4 D7 companion family

— consistent with everything already written about `0x68` (declared, saved, never interpreted),
`0x71` (no descriptor; reached only through the panel-memory grid) and the C-family (parked
above the notifiable range).

## 4. Tag `0x92` is a 15-parameter UI record — PROVEN (the shape; not the name)

`README-lsw-nonpart-records.md` has tag `0x92` as *"13 consecutive bytes read one at a time by
`SendEpilogue_Data`"* — shape only. It carries fifteen ids, `0x4280..0x428E`, whose
`(offset, mask)` pairs **tile all fourteen payload bytes with no gap and no overlap**:

    0x4281 -> +0x00 mask FF          0x4283..0x428E -> +0x02..+0x0D mask FF
    0x4280 -> +0x01 mask 80          0x4282        -> +0x01 mask 0F

So it is a full screen's worth of editable parameters, in namespace `0x42xx` — which tag `0x70`
also touches (`0x4201`) and tag `0x48` once (`0x4200`). **What the screen is, is still not
known**: no u32 screen table in the ROM lists `0x4281` or its neighbours (searched: every
4-byte-aligned occurrence of `0x00004281`, `0x00004283`, `0x00002880`, `0x00002884`,
`0x00002100`, `0x00008221` in `0xE00000..0xEF0000`, keeping any window of 13 consecutive u32
where ≥10 are `0`, `0xFFFFFFFF` or `0x100..0xFFFF`). The only tag whose ids *do* appear in such
a table is `0x47`, at `0xE7EE70` — the same shape as the tag-`0x43` screen at `0xE34750` that
`README-lsw-leftover-records.md` used. So the trick works; it just does not reach `0x42xx`.

---

## 5. The field constant `k` is the parameter's MIDI controller number (2026-10-06)

Section 1 left `k` as "which of its fields". The descriptors themselves (`audio/sndparam_records/run_*.c`,
`sndparam_types.h`: record = `bank_index`, byte = `bank_offset`, bits = `mask`) say which field each `k` edits, and
for the part fields that match a documented byte the match is the MIDI controller of that name (part 0x00 shown;
all 25 parts carry the same `(byte, mask)` per `k`, asserted by `scripts/renaming/gen_sndparam_desc_names.py`):

| `k` | MIDI controller | record byte, mask | independent basis |
|---|---|---|---|
| `0x00` | CC 0 Bank Select MSB | `+0`, `FF` | `+0` is the flat panel sound number (kn-disk-file-formats.md, "The voice selector's 168 options") |
| `0x20` | CC 32 Bank Select LSB | `+1`, `7F` | `+1` is its variation bank (same) |
| `0x07` | CC 7 Volume | `+3`, `7F` | |
| `0x0A` | CC 10 Pan | `+8`, `7F` | |
| `0x5B` | CC 91 Reverb send | `+7`, `7F` | |
| `0x5D` | CC 93 (General MIDI's chorus send) | `+5`, `7F` | the firmware calls it DSP EFFECT: `LswDSPEffect` answers `0x5D` (section 7) |
| `0x40` | CC 64 Sustain | `+4`, `08` | the panel SUSTAIN button's action addresses tag 0 (the current part) byte 4 bit 3 (`PanelActions_RightSeg3`, technics-docs control-panel-protocol.md) |
| `0x5E` | CC 94 (Celeste) | `+4`, `40` | DIGITAL EFFECT's action addresses byte 4 bit 6 (same list) |
| `0x01` | CC 1 Modulation | record `0xB2`, byte = part | a per-part live-controller array, not the part record |
| `0x0B` | CC 11 Expression | record `0xB3`, byte = part | same |

**[INFERENCE, with the evidence above]** The controller reading is not stated by the firmware; it is the one
reading under which the constants are not arbitrary: eight of them land on the very byte or bit the controller of
that number governs, and two of those are confirmed by the panel buttons that set them. `k = 0x08` (`+3`, `80`)
is the part's MUTE flag (section 6, 2026-10-06), and `0x80` / `0x81` / `0x82` are BEND RANGE / TUNING / KEY SHIFT
(section 7). `0x78` and `0x1B0`/`0x1B2` are not named. The drawbar keys `0x280`-`0x288` of parts 0-2 are the nine
footages of section 2. `gen_sndparam_desc_names.py` names those descriptors `SndParam_Part<TT>_<Field>`.

## 6. `k = 0x08` is the part MUTE flag, and the part tags in mixer order (2026-10-06)

The mixer-volume widget (`AcMixerVolProc`, `ui/ui_widget_defs.s`) has a 28-entry channel table, `AcMixerVol_Channels`
(`naka_disk_warning` `+0x1860`, typed as `mixer_channel_t` by `scripts/converters/mixer_channel_table_retype.py`).
Each entry is `{u32 volume_key, u32 mute_key, u16 lsw_word}`, indexed by the widget's `+28` word. Its EVT_PARA_DRAW arm,
`AcMixerVol_DrawChannel`, does two things:

* it prints `SndParam_LookupReadOnly(volume_key)` as `"%3d"` and places the fader bitmap from it;
* it draws `"MUTE"` (reversed) when `SndParam_LookupReadOnly(mute_key)` is 1.

For channels 0-22 the script asserts `volume_key = 0x8000 + 0x400*T + 0x07` and `mute_key = 0x8000 + 0x400*T + 0x08`
with `T` = the channel, in v10, v9 and v7. So the `k = 0x08` descriptor of every part, which edits bit 7 of the same
byte as the volume (`+3`, mask `0x80` against `0x7F`), is the value the mixer shows as MUTE. **[PROVEN for the
display; that the sound engine silences the part on it is not read here.]**

The parallel name table `AcMixerVol_ChannelNamePtrs` labels the channels, which gives the part tags their panel
names:

| tag `T` | 0 | 1 | 2 | 3-15 | 16-18 | 19 | 20 | 21 | 22 |
|---|---|---|---|---|---|---|---|---|---|
| mixer name | RT1 | RT2 | LEFT | PT4-PT16 | ACP1-ACP3 | BASS | DRUM | CHRD | RTBS |

Channels 23-27 are not parts: MSP and MSP again (keys `0x28801` / `0x2880B`), CTRL (`0xE407` / `0xE408`, tag `0x19`
of the same law, outside the part id block), METR (`0xE807` / `0xE808`) and MIC (`0x4141` / `0x4142`). Their
`lsw_word` is 4 except METR and MIC (3). `lsw_word` goes to `MainLswPut` / `MainLswAdd` as DE, which stores it at
`+6` of the 12-byte EVT_LSW_PUT packet for `MainPmanControl`; what it selects is not read here.

`gen_sndparam_desc_names.py` now names the 25 `k = 0x08` descriptors `SndParam_Part<TT>_Mute`.


## 7. The firmware's own names for `k`: the Lsw* part-parameter functions (2026-10-06)

The part-settings screens edit each parameter through an ApFunction of the Murai ApFunction table (registry slot
`0x121`): "LswVolume", "LswPan", "LswReverb", "LswDSPEffect", "LswDigitalEffect", "LswSustain", "LswSustainLength",
"LswKeyShift", "LswTuning", "LswBendRange", "LswGlidePedal", "LswSustainPedal", "LswKeyScaling", "LswAfterTouch",
"LswPartExp" and "LswMute" are the firmware's own name strings (shared/event_codes.s, `NAKA_APFUNC_Lsw*`). Each one
answers `EVT_GET_LSW_DATA_NO` with the parameter number it edits (`<Lsw>_GetSubParam` in ui/drawbar_panel_ui.s):

| function | answers | = part field `k` |
|---|---|---|
| LswVolume | `0x07` (part 0x17: `0x28801`) | volume |
| LswMute | `0x08` (part 0x17: `0x2880B`) | mute (section 6) |
| LswPan | `0x0A` | pan |
| LswReverb | `0x5B` (part 0x17: `0x28802`) | reverb |
| LswDSPEffect | `0x5D` | **DSP effect** |
| LswDigitalEffect | `0x5E` | digital effect |
| LswSustain | `0x40` | sustain |
| LswBendRange | `0x80` | **bend range** -- byte `+11`, `0..12` |
| LswTuning | `0x81` | **tuning** -- byte `+10`, `0..255` |
| LswKeyShift | `0x82` | **key shift** -- byte `+9`, `64 +/- 12` |
| LswSustainLength / LswSustainPedal / LswKeyScaling / LswGlidePedal / LswPartExp / LswAfterTouch | `0x600` / `0x601` / `0x602` / `0x603` / `0x604` / `0x606` | not part-block keys; another number space |

So `k = 0x5D` is the part's DSP EFFECT depth. The descriptors called it `ChorusSend`, after General MIDI's CC 93;
they are now `SndParam_Part<TT>_DspEffect`. `0x80`-`0x82` become `_BendRange`, `_Tuning` and `_KeyShift`, whose
ranges fit the byte ranges section 5 measured. Part `0x17` (the MSP) uses keys of its own in namespace `0x288xx`.
`gen_sndparam_desc_names.py` applies this, asserting each field's (record, byte, mask) on all 25 parts.

Which of these a part may edit is a per-part bit mask, `PartParam_EnableMask[30]` (naka_technichord_strings
`+0xF35C`, typed by `scripts/converters/part_param_enable_mask_retype.py`). Each Lsw function tests one bit of it:
15 Volume/Mute, 14 Pan, 13 Reverb, 12 DSPEffect, 11 Sustain, 10 SustainLength, 9 KeyShift, 8 Tuning, 7 BendRange,
6 GlidePedal, 5 SustainPedal, 4 KeyScaling, 3 DigitalEffect, 2 AfterTouch, 1 MidiChannel, 0 LocalControl.


## 8. Round 2: every key the firmware itself identifies (2026-10-17)

`scripts/renaming/gen_sndparam_desc_names_r2.py` names the descriptors that sections 5-7 left with their
address-bucketed aliases (`ExtPartParam_Entry_NNN`, `MidiChParam_Entry_NNN`, ...). It finds each descriptor
through the 972-pointer registry that `SndParam_RegisterLoop` walks and reads its 18 bytes from the ROM, so v10,
v9 and v7 are handled the same way. Every rule asserts the record, byte and mask it expects. A field moved in one
tree stops the script. It names **319 descriptors per tree**. 259 keep their aliases (listed below).

### The firmware's own key decode

`SndParam_KeyToLswPartNumber` (v10 `0xFCD7C5`, `audio/sndparam_routines.s`; it was `SndParam_DecodeMidiAddr`)
looks a key up in the hash table and, when it is found, splits it into the Lsw (part, number) pair:

    0x8000  <= key <= 0x17FFF:  part = ((key - 0x8000) >> 10) & 0x3F,   number = key & 0x3FF
    0x18000 <= key <= 0x27FFF:  part = ((key - 0x8000) >> 10) & 0x3F,   number = (key & 0x3FF) + 0x400

So section 1's law has a second half. Keys `0x18000 + 0x400*T + k` are part `T`'s Lsw numbers `0x400 + k`, the
number space the Lsw functions in section 7 answer with `0x400`, `0x401` and `0x600`-`0x606`.

### Per-part fields named from the Lsw functions

Each Lsw part-parameter function answers `EVT_GET_LSW_DATA_NO` with one number (section 7 has the first ten). The
rest are below. `LswMidiChannel`'s `EVT_GET_LSW_STRING` arm prints `"OFF"` instead of `"CH%2d"` when
`(part, 0x402)` reads 0, so `0x402` is the part's MIDI-channel ON flag. Round 3 (section 9) showed it is the TRANSMIT
gate (`+13` bit 6, tested by the MIDI senders) beside a RECEIVE gate at `0x403`, so it is now `_MidiTransmitOn`
(it was `_MidiChannelOn`). Every field sits on the same (byte, mask)
of its part's own record in all the parts that carry it. The script asserts this.

| Lsw number | key               | name suffix       | parts T        | byte | mask | range | firmware basis            |
|------------|-------------------|-------------------|----------------|------|------|-------|---------------------------|
| 0x293      | 0x8293 + 0x400*T  | `_DrawRelease`    | 0x00-0x02 (3)  | +2   | 0x0F | 0..15 | LswDrawRelease            |
| 0x294      | 0x8294 + 0x400*T  | `_DrawAttack`     | 0x00-0x02 (3)  | +2   | 0xF0 | 0..15 | LswDrawAttack             |
| 0x2CB      | 0x82CB + 0x400*T  | `_PercLevel`      | 0x00-0x02 (3)  | +1   | 0xF0 | 0..15 | LswPercLevel              |
| 0x2CC      | 0x82CC + 0x400*T  | `_PercDecay`      | 0x00-0x02 (3)  | +1   | 0x0F | 0..15 | LswPercDecay              |
| 0x400      | 0x18000 + 0x400*T | `_LocalControl`   | 0x00-0x19 (26) | +13  | 0x20 | 0..1  | LswLocalControl           |
| 0x401      | 0x18001 + 0x400*T | `_MidiChannel`    | 0x00-0x19 (26) | +13  | 0x0F | 0..15 | LswMidiChannel            |
| 0x402      | 0x18002 + 0x400*T | `_MidiTransmitOn` | 0x00-0x19 (26) | +13  | 0x40 | 0..1  | LswMidiChannel (OFF test) |
| 0x600      | 0x18200 + 0x400*T | `_SustainLength`  | 0x00-0x19 (26) | +4   | 0x07 | 0..7  | LswSustainLength          |
| 0x601      | 0x18201 + 0x400*T | `_SustainPedal`   | 0x00-0x19 (26) | +4   | 0x10 | 0..1  | LswSustainPedal           |
| 0x602      | 0x18202 + 0x400*T | `_KeyScaling`     | 0x00-0x19 (26) | +12  | 0x08 | 0..1  | LswKeyScaling             |
| 0x603      | 0x18203 + 0x400*T | `_GlidePedal`     | 0x00-0x19 (26) | +12  | 0x20 | 0..1  | LswGlidePedal             |
| 0x604      | 0x18204 + 0x400*T | `_PartExp`        | 0x00-0x19 (26) | +4   | 0x20 | 0..1  | LswPartExp                |
| 0x606      | 0x18206 + 0x400*T | `_AfterTouch`     | 0x00-0x19 (26) | +12  | 0x10 | 0..1  | LswAfterTouch             |

The `+13` byte of a part record therefore holds the MIDI channel (low nibble), LOCAL CONTROL (bit 5) and the
channel ON flag (bit 6). Bit 7 is `0x403`, which is not identified.

### Global keys

Each of these comes from a screen or a dispatcher that already names the value. The grids' row captions are
the `fixedrow` strings of their widgets: OVERALL TOUCH SENSITIVITY and FOOT CONTROLLERS in
`naka_ctrl_menu_body.bin` (+0x592, +0x3CE), and the VOCALIST WORKSTATION grid in `naka_midi_reverb.bin`
(+0x3982). The Vocalist case table, `VocalistGridCheck_LswCaseTable` (it was `MidiPart_ColWidthData`), is indexed
by `key - 0x2D00`. `MainGetPmemName` reads `0x300` as the current panel-memory number (bank = (n - 1) >> 3). Lsw functions that edit one global value answer `EVT_GET_LSW_ADDRESS` with its key:
`LswLeftHold` gives `0x28082`, `LswOrchestrator` `0x4201`, the computer-connect screen's `MdCmptCnct` `0x2C00` (its string arm draws the three MIDI connection diagrams for 0/1/2: normal, "KN as master", "KN as slave"), `LswScalingMode` / `Type` / `Shift` `0x4280` / `0x4281` /
`0x4282`, and `LswVolume` / `LswMute` / `LswReverb` give `0x28801` / `0x2880B` / `0x28802` for part `0x17` (the
MSP).

| key     | name                                     | record | byte | mask | range   | basis                                                                  |
|---------|------------------------------------------|--------|------|------|---------|------------------------------------------------------------------------|
| 0x00004 | `SndParam_Tempo`                         | 0x48   | +8   | 0xFF | 40..255 | record 0x48 +8 (SeqTimer_PostTempoUpdate)                              |
| 0x00100 | `SndParam_InitialTouch_VelocitySense`    | 0x93   | +0   | 0x0F | 0..9    | OVERALL TOUCH SENSITIVITY grid, row VELOCITY SENSE                     |
| 0x00102 | `SndParam_AfterTouch_Curve`              | 0x93   | +5   | 0xFF | 1..10   | OVERALL TOUCH SENSITIVITY grid, AFTER TOUCH rows                       |
| 0x00103 | `SndParam_AfterTouch_Threshold`          | 0x93   | +6   | 0x7F | 1..127  | OVERALL TOUCH SENSITIVITY grid, AFTER TOUCH rows                       |
| 0x00104 | `SndParam_AfterTouch_OnOff`              | 0x93   | +6   | 0x80 | 0..1    | OVERALL TOUCH SENSITIVITY grid, AFTER TOUCH rows                       |
| 0x00300 | `SndParam_PanelMemory_Number`            | 0x98   | +1   | 0x7F | 0..80   | MainGetPmemName: bank = (n - 1) >> 3                                   |
| 0x02100 | `SndParam_MidiIn_Right1Input`            | 0x80   | +3   | 0x01 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02101 | `SndParam_MidiIn_AutoPlayChord`          | 0x80   | +3   | 0x04 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02181 | `SndParam_MidiOut_TechniChord`           | 0x80   | +3   | 0x80 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02182 | `SndParam_MidiOut_DrumPattern`           | 0x80   | +0   | 0x40 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02183 | `SndParam_MidiOut_AutoPlayChord`         | 0x80   | +3   | 0x40 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02184 | `SndParam_MidiOut_Transpose`             | 0x80   | +0   | 0x20 | 0..1    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x02880 | `SndParam_FootCtrl_ExpressionPedal`      | 0x99   | +2   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x02886 | `SndParam_FootCtrl_FootSwitch1`          | 0x99   | +4   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x02888 | `SndParam_FootCtrl_FootSwitch2`          | 0x99   | +5   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x0288A | `SndParam_FootCtrl_FootContSw1`          | 0x99   | +6   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x0288C | `SndParam_FootCtrl_FootContSw2`          | 0x99   | +7   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x0288E | `SndParam_FootCtrl_FootContSw3`          | 0x99   | +8   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x02890 | `SndParam_FootCtrl_FootContSw4`          | 0x99   | +9   | 0xFF | 0..199  | FOOT CONTROLLERS grid (FSWAssGrid)                                     |
| 0x02C00 | `SndParam_ComputerConnectMode`           | 0x98   | +14  | 0x03 | 0..2    | MdCmptCnct's EVT_GET_LSW_ADDRESS; 0/1/2 pick its 3 connection diagrams |
| 0x02D00 | `SndParam_Vocalist_MidiChannel`          | 0x47   | +1   | 0x1F | 0..17   | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D01 | `SndParam_Vocalist_MidiChannelSend`      | 0x47   | +0   | 0x01 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D02 | `SndParam_Vocalist_Program`              | 0x47   | +2   | 0x7F | 0..99   | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D03 | `SndParam_Vocalist_ProgramSend`          | 0x47   | +0   | 0x02 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D04 | `SndParam_Vocalist_Harmony`              | 0x47   | +3   | 0x07 | 0..7    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D05 | `SndParam_Vocalist_HarmonySend`          | 0x47   | +0   | 0x04 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D06 | `SndParam_Vocalist_Key`                  | 0x47   | +3   | 0xF0 | 0..11   | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D07 | `SndParam_Vocalist_KeySend`              | 0x47   | +0   | 0x08 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D08 | `SndParam_Vocalist_ProgChangeOption`     | 0x47   | +4   | 0xC0 | 0..3    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D09 | `SndParam_Vocalist_ProgChangeOptionSend` | 0x47   | +0   | 0x10 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0A | `SndParam_Vocalist_ControlVolume`        | 0x47   | +5   | 0x7F | 0..121  | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0B | `SndParam_Vocalist_ControlVolumeSend`    | 0x47   | +0   | 0x20 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0C | `SndParam_Vocalist_VocoderKeySplit`      | 0x47   | +6   | 0xFF | 0..255  | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0D | `SndParam_Vocalist_VocoderKeySplitNote`  | 0x47   | +6   | 0x7F | 0..127  | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0E | `SndParam_Vocalist_VocoderKeySplitSide`  | 0x47   | +6   | 0x80 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D0F | `SndParam_Vocalist_VocoderIgnore`        | 0x47   | +0   | 0x40 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D10 | `SndParam_Vocalist_ChordalKeySplit`      | 0x47   | +7   | 0xFF | 0..255  | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D11 | `SndParam_Vocalist_ChordalKeySplitNote`  | 0x47   | +7   | 0x7F | 0..127  | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D12 | `SndParam_Vocalist_ChordalKeySplitSide`  | 0x47   | +7   | 0x80 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x02D13 | `SndParam_Vocalist_ChordalIgnore`        | 0x47   | +0   | 0x80 | 0..1    | VOCALIST WORKSTATION grid (VocalistGridCheck)                          |
| 0x04002 | `SndParam_ReverbOnOff`                   | 0x60   | +1   | 0x80 | 0..127  | SndParam_ApplySystemParam case                                         |
| 0x04003 | `SndParam_RotarySpeedSwitch`             | 0x70   | +0   | 0x04 | 0..1    | SndParam_ApplySystemParam case                                         |
| 0x04004 | `SndParam_AcousticIllusionOnOff`         | 0x60   | +1   | 0x40 | 0..1    | SndParam_ApplySystemParam case                                         |
| 0x04006 | `SndParam_EqualizerOnOff`                | 0x60   | +1   | 0x20 | 0..1    | SndParam_ApplySystemParam case                                         |
| 0x04141 | `SndParam_Mic_Volume`                    | 0x43   | +1   | 0x7F | 0..127  | mixer channel 27 MIC (AcMixerVol_Channels)                             |
| 0x04142 | `SndParam_Mic_Mute`                      | 0x43   | +1   | 0x80 | 0..1    | mixer channel 27 MIC (AcMixerVol_Channels)                             |
| 0x04201 | `SndParam_Orchestrator`                  | 0x70   | +3   | 0xFF | 0..255  | LswOrchestrator's EVT_GET_LSW_ADDRESS                                  |
| 0x04280 | `SndParam_ScaleTune_OnOff`               | 0x92   | +1   | 0x80 | 0..1    | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04281 | `SndParam_ScaleTune_Type`                | 0x92   | +0   | 0xFF | 0..128  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04282 | `SndParam_ScaleTune_Key`                 | 0x92   | +1   | 0x0F | 0..11   | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04283 | `SndParam_ScaleTune_UserNote0`           | 0x92   | +2   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04284 | `SndParam_ScaleTune_UserNote1`           | 0x92   | +3   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04285 | `SndParam_ScaleTune_UserNote2`           | 0x92   | +4   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04286 | `SndParam_ScaleTune_UserNote3`           | 0x92   | +5   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04287 | `SndParam_ScaleTune_UserNote4`           | 0x92   | +6   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04288 | `SndParam_ScaleTune_UserNote5`           | 0x92   | +7   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04289 | `SndParam_ScaleTune_UserNote6`           | 0x92   | +8   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x0428A | `SndParam_ScaleTune_UserNote7`           | 0x92   | +9   | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x0428B | `SndParam_ScaleTune_UserNote8`           | 0x92   | +10  | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x0428C | `SndParam_ScaleTune_UserNote9`           | 0x92   | +11  | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x0428D | `SndParam_ScaleTune_UserNote10`          | 0x92   | +12  | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x0428E | `SndParam_ScaleTune_UserNote11`          | 0x92   | +13  | 0xFF | 0..255  | SndParam_ApplySystemParam cases; LswScaling* addresses                 |
| 0x04900 | `SndParam_DspEffect_Algorithm`           | 0x61   | +0   | 0xFF | 0..255  | format-3 importer, slot 0 (record 0x61)                                |
| 0x04B00 | `SndParam_DigitalReverb_Algorithm`       | 0x63   | +0   | 0xFF | 0..255  | format-3 importer, slot 1 (record 0x63)                                |
| 0x05000 | `SndParam_MidiIn_VelocityMode`           | 0x80   | +10  | 0x03 | 0..2    | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x05001 | `SndParam_MidiIn_VelocityOffset`         | 0x80   | +11  | 0xFF | 0..255  | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x05002 | `SndParam_MidiIn_VelocityFixed`          | 0x80   | +12  | 0xFF | 1..127  | MIDI IN/OUT grid (InOutGridCheck)                                      |
| 0x0E807 | `SndParam_Metronome_Volume`              | 0x98   | +4   | 0x7F | 0..127  | mixer channel 26 METR (AcMixerVol_Channels)                            |
| 0x0E808 | `SndParam_Metronome_Mute`                | 0x98   | +4   | 0x80 | 0..1    | mixer channel 26 METR (AcMixerVol_Channels)                            |
| 0x28082 | `SndParam_LeftHold`                      | 0x90   | +3   | 0x01 | 0..1    | LswLeftHold's EVT_GET_LSW_ADDRESS                                      |
| 0x28801 | `SndParam_Msp_Volume`                    | 0x72   | +3   | 0x7F | 0..127  | LswVolume / LswMute / LswReverb answer for part 0x17                   |
| 0x28802 | `SndParam_Msp_Reverb`                    | 0x72   | +7   | 0x7F | 0..127  | LswVolume / LswMute / LswReverb answer for part 0x17                   |
| 0x2880B | `SndParam_Msp_Mute`                      | 0x72   | +3   | 0x80 | 0..1    | LswVolume / LswMute / LswReverb answer for part 0x17                   |

The FOOT CONTROLLERS values are function numbers `0..199` (`FswAssign_FunctionCodes`). `+0` and `+1` of record
`0x99` carry one flag bit per controller (`0x2887`, `0x2889`, ... `0x289D`), and `+10..+15` six more function
bytes that the KN5000's grid never shows. Neither is named here.

### Still unnamed after round 2

Round 2 left 259 descriptors per tree with their aliases.  Section 9 names 204 of them.

## 9. Round 3: the screens, grids, LEDs and MIDI messages behind 204 more keys (2026-10-17)

`scripts/renaming/gen_sndparam_desc_names_r3.py` applies a read-only research pass whose records are in
[`sndparam-r3/`](sndparam-r3/README.md): `proposals.json` (78 firm proposals covering 204 descriptors per tree),
the evidence for each as file:line citations machine-checked against a `git archive` of 429a926d2, and
`crosscheck_trees.py`, which found the same descriptor shape and alias for all 206 proposed keys in v9 and v7.  As in
round 2, every rule asserts the descriptor's record, byte and mask in each tree's ROM.  The evidence kinds:

- **Screens and grids.**  The MIDI menu's CONTROL MESSAGES grid (`CtlMsgGridCheck_Table`, 13 per-message filters,
  each gating that message both ways, e.g. `MidiRx_ProgramChange` on record `0x80` `+7` bit 4), COMMON SETTING
  (`ComSetGridCheck_JumpTable_Table`: NOTE ONLY, PRG.CHANGE TO P.MEM, REALTIME SYSEX, INTRO/FILLIN ENDING, APC CONTROL,
  FADE IN/OUT, PROGRAM CHANGE MODE, DRUMS TYPE, SONG SELECT), REALTIME MESSAGES (CLOCK, REALTIME COMMANDS), the
  MIDI PART SETTING grid (" PART |CHANNEL|OCTAVE| LOCAL"), and the panel memory EXPAND MODE FILTER
  (`PmExpFilter_CellKeys` / `_AltKeys`, whose row captions come from `ParamStr_Table_01` / `_02`).
- **ApFunctions.**  `MdPcgModeFunc` answers `EVT_GET_LSW_ADDRESS` with `0x2201` and draws NORMAL / TECH / GM,
  `MdDrumTypeFunc` `0x2205`, `SplitPointFunc` `0x4181`, `R12OctaveFunc` `0x40E0`, `GmOnOffFunc` `0xC0`.
- **Panel LEDs.**  Seven keys drive one LED each through the LED handler tables: MUSIC STYLE ARRANGER, CONDUCTOR,
  TECHNI CHORD, FADE IN, FADE OUT, R1/R2 OCTAVE, VARIATION and AUTO PLAY CHORD.
- **MIDI messages.**  `SndPart_SetParam` sends part numbers `0x078`, `0x1B0` and `0x1B2` as All Sound Off
  (`MIDI_SendControlChange(part, 0x78, 0)`), pitch bend and channel pressure.

Per-part fields (named `SndParam_Part<TT>_<Field>`):

| Lsw number | key               | name suffix        | parts T        | record     | byte       | mask | meaning                                                                                                                                      |
|------------|-------------------|--------------------|----------------|------------|------------|------|----------------------------------------------------------------------------------------------------------------------------------------------|
| 0x078      | 0x08078 + 0x400*T | `_AllSoundOff`     | 0x00-0x18 (25) | 0xAE       | part (= T) | 0x7F | Per-part MIDI All Sound Off: writing it sends controller 120 with value 0 to the part (the written value is ignored).                        |
| 0x1B0      | 0x081B0 + 0x400*T | `_PitchBend`       | 0x00-0x18 (25) | 0xB1       | part (= T) | 0x7F | Per-part pitch bend (14-bit, centre 0x2000), sent to the tone generator as a MIDI pitch-bend message.                                        |
| 0x1B2      | 0x081B2 + 0x400*T | `_ChannelPressure` | 0x00-0x18 (25) | 0xB4       | part (= T) | 0x7F | Per-part channel pressure (aftertouch), sent to the tone generator as a MIDI channel-pressure message.                                       |
| 0x403      | 0x18003 + 0x400*T | `_MidiReceiveOn`   | 0x00-0x19 (26) | part (= T) | 13         | 0x80 | The part receives MIDI on its channel: only parts with this flag set get incoming channel messages (stored inverted in part byte +13 bit 7). |
| 0x404      | 0x18004 + 0x400*T | `_MidiOctave`      | 0x00-0x19 (26) | part (= T) | 12         | 0x07 | The part's OCTAVE setting on the MIDI PART SETTING screen: a 3-bit signed octave shift, -3..+3.                                              |
| 0x2C0      | 0x082C0 + 0x400*T | `_Perc4`           | 0x00-0x02 (3)  | 0x44 + T   | 7          | 0x10 | DIGITAL DRAWBAR percussion 4' switch of the part (RIGHT1/RIGHT2/LEFT drawbar record).                                                        |
| 0x2C1      | 0x082C1 + 0x400*T | `_Perc2_2_3`       | 0x00-0x02 (3)  | 0x44 + T   | 7          | 0x20 | DIGITAL DRAWBAR percussion 2 2/3' switch of the part.                                                                                        |

Global keys:

| key     | name                                      | record | byte | mask | range   | meaning                                                                                                                                                                          |
|---------|-------------------------------------------|--------|------|------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x00003 | `SndParam_Transpose`                      | 0x70   | +2   | 0xFF | 0..11   | TRANSPOSE: 0..11 = -5..+6 semitones, 5 = none.                                                                                                                                   |
| 0x00005 | `SndParam_Tempo_Bit8`                     | 0x48   | +9   | 0x01 | 0..1    | Bit 8 of the 9-bit tempo (40..300 BPM); key 0x0004 (SndParam_Tempo) is bits 0-7.                                                                                                 |
| 0x000C0 | `SndParam_GmOnOff`                        | 0x91   | +3   | 0x04 | 0..1    | GM mode on/off (stored inverted in record 0x91 +3 bit 2).                                                                                                                        |
| 0x00302 | `SndParam_PanelMemory_Mode`               | 0x98   | +0   | 0x40 | 0..1    | PANEL MEMORY MODE: 0 = NORMAL, 1 = EXPAND (EXPAND recall keeps the accompaniment and applies the EXPAND MODE FILTER).                                                            |
| 0x00400 | `SndParam_MusicStyleArranger_OnOff`       | 0x98   | +3   | 0x01 | 0..1    | MUSIC STYLE ARRANGER on/off (drives the panel's MUSIC STYLE ARRANGER LED).                                                                                                       |
| 0x00401 | `SndParam_MusicStyleArranger_Mode`        | 0x98   | +3   | 0x70 | 1..3    | MUSIC STYLE ARRANGER MODE: 1 = RHYTHM, 2 = SOUND&RHYTHM, 3 = PANEL MEMORY.                                                                                                       |
| 0x02200 | `SndParam_MidiRealtime_Clock`             | 0x80   | +0   | 0x04 | 0..1    | MIDI CLOCK source: 0 = INTERNAL, 1 = MIDI (external).                                                                                                                            |
| 0x02201 | `SndParam_MidiCommon_ProgramChangeMode`   | 0x80   | +0   | 0x03 | 0..3    | MIDI PROGRAM CHANGE MODE: 0 = NORMAL, 1 = TECH, 3 = GM (2 = "Error!").                                                                                                           |
| 0x02202 | `SndParam_MidiCommon_PrgChangeToPmem`     | 0x80   | +0   | 0x08 | 0..1    | MIDI COMMON SETTING "PRG.CHANGE TO P.MEM" on/off.                                                                                                                                |
| 0x02203 | `SndParam_MidiCommon_NoteOnly`            | 0x80   | +0   | 0x10 | 0..1    | MIDI COMMON SETTING "NOTE ONLY" on/off.                                                                                                                                          |
| 0x02205 | `SndParam_MidiCommon_DrumsType`           | 0x80   | +2   | 0x18 | 0..3    | MIDI DRUMS TYPE: 0 = NORMAL, 1 = TECH, 3 = GM.                                                                                                                                   |
| 0x02280 | `SndParam_MidiCommon_SongSelect`          | 0x80   | +1   | 0x08 | 0..1    | MIDI COMMON SETTING "SONG SELECT" on/off (send Song Select).                                                                                                                     |
| 0x02281 | `SndParam_MidiRealtime_Commands`          | 0x80   | +2   | 0x04 | 0..1    | MIDI REALTIME COMMANDS on/off.                                                                                                                                                   |
| 0x02282 | `SndParam_MidiCommon_RealtimeSysex`       | 0x80   | +6   | 0x08 | 0..1    | MIDI COMMON SETTING "REALTIME SYSEX" on/off.                                                                                                                                     |
| 0x0228A | `SndParam_MidiCtlMsg_ProgramChange`       | 0x80   | +7   | 0x10 | 0..1    | MIDI CONTROL MESSAGES filter "PRG.CHANGE" on/off: gates that message type in both directions.                                                                                    |
| 0x0228B | `SndParam_MidiCtlMsg_AfterTouch`          | 0x80   | +7   | 0x20 | 0..1    | MIDI CONTROL MESSAGES filter "AFTER TOUCH" on/off: gates that message type in both directions.                                                                                   |
| 0x0228C | `SndParam_MidiCtlMsg_PitchBend`           | 0x80   | +7   | 0x40 | 0..1    | MIDI CONTROL MESSAGES filter "PITCH BEND" on/off: gates that message type in both directions.                                                                                    |
| 0x0228D | `SndParam_MidiCtlMsg_BankSelect`          | 0x80   | +8   | 0x80 | 0..1    | MIDI CONTROL MESSAGES filter "BANK SELECT" on/off: gates that message type in both directions.                                                                                   |
| 0x0228E | `SndParam_MidiCtlMsg_Volume`              | 0x80   | +8   | 0x04 | 0..1    | MIDI CONTROL MESSAGES filter "VOLUME" on/off: gates that message type in both directions.                                                                                        |
| 0x0228F | `SndParam_MidiCtlMsg_Expression`          | 0x80   | +8   | 0x08 | 0..1    | MIDI CONTROL MESSAGES filter "EXPRESSION" on/off: gates that message type in both directions.                                                                                    |
| 0x02290 | `SndParam_MidiCtlMsg_Pan`                 | 0x80   | +8   | 0x10 | 0..1    | MIDI CONTROL MESSAGES filter "PAN" on/off: gates that message type in both directions.                                                                                           |
| 0x02291 | `SndParam_MidiCtlMsg_Sustain`             | 0x80   | +8   | 0x01 | 0..1    | MIDI CONTROL MESSAGES filter "SUSTAIN" on/off: gates that message type in both directions.                                                                                       |
| 0x02294 | `SndParam_MidiCtlMsg_EffectReverb`        | 0x80   | +8   | 0x20 | 0..1    | MIDI CONTROL MESSAGES filter "EFFECT & REVERB" on/off: gates that message type in both directions.                                                                               |
| 0x02295 | `SndParam_MidiCtlMsg_Modulation`          | 0x80   | +8   | 0x02 | 0..1    | MIDI CONTROL MESSAGES filter "MODULATION" on/off: gates that message type in both directions.                                                                                    |
| 0x02296 | `SndParam_MidiCtlMsg_Tuning`              | 0x80   | +7   | 0x02 | 0..1    | MIDI CONTROL MESSAGES filter "TUNING" on/off: gates that message type in both directions.                                                                                        |
| 0x02298 | `SndParam_MidiCtlMsg_BendRange`           | 0x80   | +7   | 0x01 | 0..1    | MIDI CONTROL MESSAGES filter "BEND RANGE" on/off: gates that message type in both directions.                                                                                    |
| 0x02299 | `SndParam_MidiCtlMsg_ResetAllControllers` | 0x80   | +9   | 0x01 | 0..1    | MIDI CONTROL MESSAGES filter "RESET ALL CONT." on/off: gates that message type in both directions.                                                                               |
| 0x0229A | `SndParam_MidiCommon_FadeInOut`           | 0x80   | +1   | 0x04 | 0..1    | MIDI COMMON SETTING "FADE IN/OUT" on/off.                                                                                                                                        |
| 0x02900 | `SndParam_PmemFilter_RhythmSelection`     | 0x98   | +7   | 0x01 | 0..1    | Panel memory EXPAND MODE FILTER row "RHYTHM SELECTION": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                             |
| 0x02901 | `SndParam_PmemFilter_Tempo`               | 0x98   | +7   | 0x02 | 0..1    | Panel memory EXPAND MODE FILTER row "TEMPO": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                        |
| 0x02902 | `SndParam_PmemFilter_SplitPoint`          | 0x98   | +7   | 0x04 | 0..1    | Panel memory EXPAND MODE FILTER row "SPLIT POINT": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                  |
| 0x02903 | `SndParam_PmemFilter_Transpose`           | 0x98   | +7   | 0x08 | 0..1    | Panel memory EXPAND MODE FILTER row "TRANSPOSE": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                    |
| 0x02904 | `SndParam_PmemFilter_ApcMemory`           | 0x98   | +7   | 0x10 | 0..1    | Panel memory EXPAND MODE FILTER row "APC & MEMORY": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                 |
| 0x02905 | `SndParam_PmemFilter_Midi`                | 0x98   | +7   | 0x20 | 0..1    | Panel memory EXPAND MODE FILTER row "MIDI": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                         |
| 0x02906 | `SndParam_PmemFilter_KeyScale`            | 0x98   | +7   | 0x40 | 0..1    | Panel memory EXPAND MODE FILTER row "KEY SCALE": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                    |
| 0x02907 | `SndParam_PmemFilter_Reverb`              | 0x98   | +7   | 0x80 | 0..1    | Panel memory EXPAND MODE FILTER row "REVERB": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                       |
| 0x02908 | `SndParam_PmemFilter_DspEffect`           | 0x98   | +8   | 0x01 | 0..1    | Panel memory EXPAND MODE FILTER row "DSP EFFECT": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                   |
| 0x02909 | `SndParam_PmemFilter_Part4To16`           | 0x98   | +8   | 0x02 | 0..1    | Panel memory EXPAND MODE FILTER row "PART4-16 SETTING": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                             |
| 0x0290A | `SndParam_PmemFilter_FootCtrl`            | 0x98   | +8   | 0x04 | 0..1    | Panel memory EXPAND MODE FILTER row "FOOT CONT. SETTING": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                           |
| 0x0290B | `SndParam_PmemFilter_MicLevelReverb`      | 0x98   | +8   | 0x08 | 0..1    | Panel memory EXPAND MODE FILTER row "MIC LEVEL & REVERB": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                           |
| 0x0290C | `SndParam_PmemFilter_FadeInOut`           | 0x98   | +8   | 0x10 | 0..1    | Panel memory EXPAND MODE FILTER row "FADE IN/OUT SETTING": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                          |
| 0x0290D | `SndParam_PmemFilter_R1R2Octave`          | 0x98   | +8   | 0x20 | 0..1    | Panel memory EXPAND MODE FILTER row "R1/R2 OCTAVE": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                 |
| 0x0290E | `SndParam_PmemFilter_Vocalist`            | 0x98   | +8   | 0x40 | 0..1    | Panel memory EXPAND MODE FILTER row "VOCALIST": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                     |
| 0x0290F | `SndParam_PmemFilter_AcousticIllusion`    | 0x98   | +8   | 0x80 | 0..1    | Panel memory EXPAND MODE FILTER row "ACOUSTIC ILLUSION": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                            |
| 0x02910 | `SndParam_PmemFilter_Equalizer`           | 0x98   | +9   | 0x01 | 0..1    | Panel memory EXPAND MODE FILTER row "EQUALIZER": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                    |
| 0x02911 | `SndParam_PmemFilter_MspBank`             | 0x98   | +9   | 0x02 | 0..1    | Panel memory EXPAND MODE FILTER row "MSP BANK": 0 (drawn ON) = recalled, 1 (OFF) = the live setting is kept.                                                                     |
| 0x02A00 | `SndParam_FadeIn_Time`                    | 0x70   | +5   | 0xFF | 1..16   | FADE IN time in measures (1..16).                                                                                                                                                |
| 0x02A01 | `SndParam_FadeOut_Time`                   | 0x70   | +6   | 0xFF | 1..16   | FADE OUT time in measures (1..16).                                                                                                                                               |
| 0x02A10 | `SndParam_FadeOut_RhythmAutoStop`         | 0x70   | +7   | 0x01 | 0..1    | FADE OUT "Rhythm Auto stop" on/off.                                                                                                                                              |
| 0x02A11 | `SndParam_FadeOut_SeqAutoStop`            | 0x70   | +7   | 0x02 | 0..1    | FADE OUT "SEQ Auto stop" on/off.                                                                                                                                                 |
| 0x02A12 | `SndParam_FadeOut_AutoReset`              | 0x70   | +7   | 0x04 | 0..1    | FADE OUT "Auto reset" on/off.                                                                                                                                                    |
| 0x04001 | `SndParam_TotalExpression`                | 0xB0   | +1   | 0x7F | 0..127  | TOTAL EXPRESSION level (0..127): the expression pedal when assigned to TOTAL EXPRESSION, forced to 127 otherwise; one stage of the master output gain.                           |
| 0x04005 | `SndParam_Fade_Level`                     | 0xB0   | +3   | 0x7F | 0..127  | Current FADE IN/OUT level (0..127), ramped by the fade engine and applied as the output gain's fade stage.                                                                       |
| 0x040C0 | `SndParam_FadeIn_OnOff`                   | 0x98   | +11  | 0x80 | 0..1    | FADE IN on/off (the panel FADE IN LED).                                                                                                                                          |
| 0x040C1 | `SndParam_FadeOut_OnOff`                  | 0x98   | +11  | 0x40 | 0..1    | FADE OUT on/off (the panel FADE OUT LED).                                                                                                                                        |
| 0x040E0 | `SndParam_R1R2Octave`                     | 0x90   | +4   | 0xFF | 40..88  | RIGHT1/RIGHT2 OCTAVE as a note offset: 64 = 0, 52/40 = -1/-2, 76/88 = +1/+2 octaves.                                                                                             |
| 0x04100 | `SndParam_Conductor`                      | 0x90   | +0   | 0x1F | 0..5    | CONDUCTOR part selection (which of RIGHT1/RIGHT2/LEFT play): 0..5 = R1, R2, R1+R2, all, R1+L, R2+L.                                                                              |
| 0x04140 | `SndParam_Mic_ReverbOnOff`                | 0x43   | +0   | 0x80 | 0..1    | MIC reverb on/off (enable of DSP slot 3, ROOM/KARAOKE/BATH ROOM/STAGE).                                                                                                          |
| 0x04180 | `SndParam_SplitPoint_Preset`              | 0x70   | +0   | 0x03 | 0..3    | SPLIT POINT preset: 0 = free (key-set), 1 = LEFT, 2 = CENTER, 3 = RIGHT.                                                                                                         |
| 0x04181 | `SndParam_SplitPoint_Note`                | 0x70   | +1   | 0x7F | 21..108 | SPLIT POINT note number (21..108).                                                                                                                                               |
| 0x04200 | `SndParam_TechniChord_OnOff`              | 0x48   | +4   | 0x40 | 0..1    | TECHNI-CHORD on/off (the panel TECHNI CHORD LED).                                                                                                                                |
| 0x04202 | `SndParam_TechniChord_Type`               | 0x70   | +4   | 0x0F | 0..13   | TECHNI-CHORD type: 0 CLOSE, 1 OPEN1, 2 OPEN2, 3 DUET2, 4 COUNTRY, 5 THEATRE, 6 HYMN, 7 BLOCK, 8 BIG BAND BRASS, 9 BIG BAND REEDS, 10 OCTAVE, 11 HARD ROCK, 12 FANFARE, 13 DUET1. |
| 0x04C00 | `SndParam_Equalizer_Algorithm`            | 0x64   | +0   | 0xFF | 0..255  | Algorithm byte of the EQUALIZER DSP slot (slot 4; 79 = GEQ).                                                                                                                     |
| 0x04D00 | `SndParam_AcousticIllusion_Algorithm`     | 0x65   | +0   | 0xFF | 0..255  | Algorithm byte of the ACOUSTIC ILLUSION DSP slot (slot 2: STANDARD/PERCUSSIVE/SYMPHONIC/DEEP SPACE).                                                                             |
| 0x04E00 | `SndParam_MicReverb_Algorithm`            | 0x66   | +0   | 0xFF | 0..255  | Algorithm byte of the MIC reverb DSP slot (slot 3: ROOM/KARAOKE/BATH ROOM/STAGE).                                                                                                |
| 0x28000 | `SndParam_Style_Number`                   | 0x48   | +0   | 0xFF | 0..255  | Current rhythm style number (low byte; with Style_Bank it selects the style).                                                                                                    |
| 0x28001 | `SndParam_Style_Bank`                     | 0x48   | +1   | 0x7F | 0..7    | Current rhythm style bank (0..7); same shape as the part records' Bank field.                                                                                                    |
| 0x28002 | `SndParam_Style_Variation`                | 0x48   | +7   | 0x30 | 0..3    | VARIATION 1-4 of the current style (0..3).                                                                                                                                       |
| 0x28080 | `SndParam_Apc_Mode`                       | 0x48   | +3   | 0x07 | 0..3    | AUTO PLAY CHORD mode: 0 = off, 1 = ONE FINGER, 2 = FINGERED, 3 = PIANIST.                                                                                                        |
| 0x28081 | `SndParam_Apc_Memory`                     | 0x48   | +3   | 0x08 | 0..1    | AUTO PLAY CHORD "MEMORY" on/off.                                                                                                                                                 |
| 0x28083 | `SndParam_Apc_OnBass`                     | 0x90   | +3   | 0x02 | 0..1    | AUTO PLAY CHORD "ON BASS" on/off.                                                                                                                                                |

Two round-2 names are corrected (`sndparam-r3/observations.json`): `_MidiChannelOn` (`0x402`) is now
`_MidiTransmitOn` (above), and `SndParam_DigitalEffectOnOff` (`0x4003`) is `SndParam_RotarySpeedSwitch`.  `0x4003`
reaches the sub CPU as COMM `0x23`, which `DSP_Set_RotarySpeed` (v142) applies to DSP EFFECT slot 0 only for the
rotary-speaker algorithms (15 ROCK ROTARY, 53 ROTARY SPEAKER), and the DIGITAL DRAWBAR screen shows it on its
TREMOLO (SLOW/FAST) view; `SndParam_ApplySystemParam`'s case for it is now `SndParam_ApplySystemParam_QueueRotarySpeed`.

Five descriptors outside the 259 had names that restated an index (`--weak`, `sndparam-r3/proposals_weak_names.json`):

| key     | name                                    | was                       | meaning                                                               |
|---------|-----------------------------------------|---------------------------|-----------------------------------------------------------------------|
| 0x2A000 | `SndParam_MidiCommon_ApcControl`        | `NakaInst_Param_IdxA0_00` | MIDI COMMON SETTING "APC CONTROL" on/off (gates CC80 output).         |
| 0x2A001 | `SndParam_MidiCommon_IntroFillInEnding` | `NakaInst_Param_IdxA0_01` | MIDI COMMON SETTING "INTRO,FILLIN ENDING" on/off (gates CC82 output). |
| 0x28103 | `SndParam_Style_SynchroBreak`           | `NakaInst_Param_Field81C` | SYNCHRO & BREAK state (panel LED).                                    |
| 0x28100 | `SndParam_Style_FillIn`                 | `NakaInst_Param_Field81A` | FILL IN state: 1 / 2 light FILL IN 1 / FILL IN 2.                     |
| 0x28102 | `SndParam_Style_Ending`                 | `NakaInst_Param_Field81B` | ENDING state: 1 / 2 light INTRO & ENDING 1 / 2.                       |

### Still unnamed (55 per tree)

| keys                                                                                                                                                                                                       | where                                                       | what is known                                                                                                                                                                                                                                                                                                                               |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x18205 + 0x400*T (Lsw 0x605), parts 0x00-0x19                                                                                                                                                             | part byte +22 bit 0                                         | No reader of number 0x605 (also searched in decimal, 1541) and no access to byte +22; SndPart_SetParam ignores it. README-lsw-part-record-fields.md calls +22 the only declared bit no code touches.                                                                                                                                        |
| 0x08221 / 0x08621 / 0x08A21 (Lsw 0x221)                                                                                                                                                                    | drawbar records 0x44-0x46 +8 low nibble, range 0..1         | Not in the drawbar screen's 15-entry control table (MainMemDrawControl) and no reader of byte +8; the screen's TREMOLO SLOW/FAST is the global 0x4003.                                                                                                                                                                                      |
| 0x00C1                                                                                                                                                                                                     | record 0x91 +3 bit 0 (inverted)                             | Set to 1 only by SoundParam_InitDefaultBanks mode 2 (note_voice_mapping.s:23449), which clears GM (0xC0) and loads its own channel map. Mode 2 is used by Epilogue_Prologue/_2 (:22111) from a file-kind dispatch (SeqVoice_PopIzReturn_Prologue, :19934 area). Sent as F0 50 99 0/127. A tone-generator mode exclusive with GM, not named. |
| 0x00301                                                                                                                                                                                                    | record 0x98 +1 bit 7 (beside the panel-memory number 0x300) | BitMapOut_ByteData_PresetCopy (bitmap_out_routines.s:374) does a full PanelMemory_Recall on a panel-memory number change when 0x301 = 0, else BitMapOut_CopyVoicePreset9 (parts 0-2 bytes +14/+15/+17 only).                                                                                                                                |
| 0x04080, 0x04081                                                                                                                                                                                           | record 0x98 +2 bits 7, 6                                    | 0x4080 is sent as F0 50 85 <v> (sub-CPU Voice_SystemMsg 0x85, labelled Voice_SetKeyShiftEnable there, a guessed name) and cleared at demo setup (file_demo_proc.s:933, mislabelled Timer7_DisableInterrupt). FswAsIniFunc clears it. No reader of 0x4081 found.                                                                             |
| record 0x99 flags 0x2882, 0x2887, 0x2889, 0x288B, 0x288D, 0x288F, 0x2891, 0x2893, 0x2895, 0x2897, 0x2899, 0x289B, 0x289D; function bytes 0x2881 (+3), 0x2892/0x2894/0x2896/0x2898/0x289A/0x289C (+10..+15) | record 0x99                                                 | Each odd key is a 1-bit companion of the function byte at key-1. The FOOT CONTROLLERS grid and the PanelAction_FootSwitch*/FootController* handlers read only 0x2880/0x2886..0x2890. No reader of the flag bits or the unshown bytes except the whole-record copy under the FOOT CONT. SETTING filter row.                                  |

Two probable names are not applied (`sndparam-r3/inferred.json`):

| key     | probable name                         | record | byte | mask | why it is not named                                                                                                   | would confirm                                                                                                                                                                                                  |
|---------|---------------------------------------|--------|------|------|-----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x04000 | `SndParam_MainVolume`                 | 0xB0   | +0   | 0x7F | Probably the MAIN VOLUME slider level: the other master-gain stage beside TOTAL EXPRESSION and the fade level.        | Show that panel analog ID 27 (Encoder_ProcessExpression, RAM 0x8EE6) is the MAIN VOLUME slider, e.g. a panel capture or the service manual, or find a screen or test routine that labels RAM 0x8EE6 as volume. |
| 0x04A00 | `SndParam_DigitalReverbAlt_Algorithm` | 0x62   | +0   | 0xFF | Algorithm byte of a second DSP namespace (0x4Axx, record 0x62 with no RAM block) that shares slot 1 (DIGITAL REVERB). | A reader or writer of key 0x4A00 / record 0x62 (none found by key literal in v10) that says what the alternate slot-1 namespace is used for.                                                                   |

## PROVEN vs INFERRED

**PROVEN:** the part namespace law and its ten field constants; that only the three drawbar
records intrude into the part id block, at `+0x200` of parts 0/1/2; that the three carry
identical `(k, offset, mask)` sets; that tag `0x9A` has no id over the full window while
`0x92`/`0x98`/`0x99` collect 15/29/27 in the same scan; that tag `0x92`'s fifteen ids tile its
fourteen payload bytes; the no-id tag list; and that all of it is identical in v7, v9 and v10.

**[INFERENCE]:** that the nine consecutive constants `0x80..0x88` on nibbles `+3 lo` … `+7 lo`
are the nine drawbar footages. Falsifier: move one drawbar on hardware and watch which nibble
of the record changes.

**NOT DETERMINED:** what screen edits tag `0x92`; the names of `0x91`, `0x93`, `0x98`, `0x99`;
anything at all about `0x9A`, `0x68`, `0x71`, `0x72`, `0x78`, `0x90`, which have no id to follow.

---

## Can it fail?

Checked:

* retag one drawbar descriptor's block (`0x8621` → `0x8E21`) → `T1: census differs`,
  `T3: drawbar tag 0x45 namespace ['0x86', '0x8e'], expected [0x86]`, `T3b: … != the common
  set`, and `census differs between revisions`;
* **give tag `0x9A` a descriptor** by changing the tag byte of id `0x4285` from `0x92` to
  `0x9A` → `T4: the no-id set is [… no 9A …], expected [… 9A …]`, `T4: the positive control for
  tag 0x9A is gone — tag 0x92 collects 14 ids, expected 15`, and `T5: tag 0x92 ids cover
  offsets [0,1,2,3,5,…], its payload is 14 bytes`. The tag-`0x9A` negative is a test, not a
  memory: if a descriptor for it ever appears, this probe says so.

---

## Corrections other files need (not applied here — this pass was told not to edit)

1. `README-lsw-leftover-records.md`, "Method notes worth keeping": *"scanning the whole image
   for ids in `0x4000..0x4FFF` … yields 39 ids over 14 tags with no hand-tuning"*. The window is
   the problem, not the method; over the whole id space it is **456 entries over 44 tags**, and
   the contiguity rule alone is not enough — uniqueness is needed too.
2. Same file, §3: *"no parameter-id descriptor names tag `0x9A` either, while 14 other tags
   do"* — still true, and can now cite a full-window search instead of `0x4000..0x4FFF`.
3. Same file, §5: *"`0x44`/`0x45`/`0x46` … 'Three identical records must be three of something'
   remains a hypothesis with no ROM artefact behind it"*. There is one now: their id blocks are
   `+0x200` of parts 0, 1 and 2.
4. `README-lsw-nonpart-records.md`, tag `0x92` row (*"13 consecutive bytes read one at a time by
   `SendEpilogue_Data`"*): it is a 15-parameter UI record and the ids tile all fourteen bytes.
5. `README-lsw-drawbar-records.md`: the part assignment can cite the namespace arithmetic, and
   the field table above supersedes "nine footages" as a description of the record's layout.
