# The MN10300 trees' last open items (lane mn10300-rest, 2026-10-31)

Lane mn10300-rest of wave 3 of the open-items effort ("work on all open items until nothing else is left
open"). It takes the open items of `../mn10300-formats/README.md`, `../mn10300-typer/README.md`,
`../callee-walk/README.md`, `../code-island/README.md`, `../data-final/README.md`,
`../../../kn6000/notes/siblings-data-final/README.md`, `../../../hdsx3/README.md` ("Open work") and
`../sp7001-plugin-menu-map.md`. The trees are the KN7000 program builds 941, 942 (SP7001), 935 and 893, the
SX-KN6000, SX-KN6500, SX-KN2400 and the HD-SX3 (HD-SX6) plug-in. Probes: `../mn10300-rest-probes/` (README
there). Every rule the lane added to the generator is a switch (`gen_data_s.FEATURES`, read from the
environment variable `GEN_DATA_S_OFF`), so `rest_stats.py` measures each against main.

## Outcome per item

| item | what                                                            | outcome                                                                                                                                                                                                                                     |
|------|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | the KN2400's `7c aa aa 7d ...` streams at 0x4853C5BE            | CLOSED: the effect DSP's programs, scripts and maps, 55,111 bytes typed (section 1)                                                                                                                                                         |
| 2    | FX_DESC `pnum9` / `pnum10` / `pnum11`                           | CLOSED: `speed_param`, `tempo_param`, `drive_param`; also `mode` and FX_PARAM `x29` (section 1)                                                                                                                                             |
| 3    | the KN6000 switch states 2 and 3                                | CLOSED: the SOUND EXPLORER categories, the even state for a part with a DSP unit (section 2)                                                                                                                                                |
| 4    | the KN7000 'Tone' hash payload's readers                        | CLOSED: ToneKeyFind and its family; payload typed `jk_tone_key`; "Dir1" is the switch-key hash                                                                                                                                              |
| 5    | loops that test before stepping; memory-slot following          | CLOSED: both rules added and measured; what they cannot reach is a run-time dispatch (section 3)                                                                                                                                            |
| 6    | offset-named fields                                             | CLOSED for the uses the code shows: 630 -> 256 in 941, the siblings alike (section 4)                                                                                                                                                       |
| 7    | HD-SX3 entry vectors, the 2,630 `calls (aN)`, run-time pointers | CLOSED (section 5)                                                                                                                                                                                                                          |
| 8    | the zone side bits 0x400 / 0x800; the notes' other open items   | CLOSED: 0x400 MAIN, 0x800 SUB; the rest in section 6                                                                                                                                                                                        |
| 9    | the opaque `unknown-dump` blocks                                | PARTLY CLOSED: every group searched, readers found for most; 173,555 formerly opaque bytes typed over the eight trees by new passes; the groups with a reader but no typing pass yet, and what stays opaque and why, are listed (section 7) |

## 1. The KN2400's effect DSP (items 1 and 2)

The "20 KB of `7c aa aa 7d 55 55 ...` streams" are one family, 0x48533EAC..0x48541618 (55,148 bytes, with the
37-byte `FxUnitStepRows` inside it): for each of the 208 DSP types a **program stream**, a **parameter script**
and an **address map**, the six units' idle programs, the boot and clear streams and three coefficient waves.
Nothing loads from them directly; four pointer tables are their only readers, which is why the reader search
called them opaque (probe `kn2400_fx_streams.py`).

| table (kn2400_manual.sym) | reader                                                                                  | blocks |
|---------------------------|-----------------------------------------------------------------------------------------|--------|
| `FxTypeProgramTable`      | `FxDspProgramLoad` 0x50189F4E (`mov 0x48541630, a0 / mov (d0, a0), d1` 0x50189F74 / 7A) | 103    |
| `FxUnitIdleProgramTable`  | `FxDspProgramLoad` 0x50189F64 (type 0)                                                  | 6      |
| `FxTypeScriptTable`       | `FxDspParamApply` 0x5018A267 (0x5018A298)                                               | 89     |
| `FxTypeMapTable`          | `FxDspParamApply` (0x5018A28C)                                                          | 85     |
| boot / clear / waves      | `FxDspBoot`, `FxDspClearRun`, `FxDspQueueFlush`                                         | 9      |
| orphans (nothing points)  | parsed as the kind they parse as [INFERENCE: older copies]                              | 22     |

**Program streams** (`FxDspStreamExec` 0x5018A345, `movbu (a0), d0` 0x5018A358, the kind compares at
0x5018A366..0x5018A389): records of a kind byte and a 12-bit length counting the whole record. 0xFB raw bytes
(sent after a 12-byte command, func_5018A2C1), 0xFC 4-byte program words (word i to step
`FxUnitProgramBase[unit]` + i, `FxDspStepWrite`; 6,785 words), 0xFD / 0xF7 big-endian u24 coefficients from an
address (0xFD as one burst, `FxDspBurstWrite`; 0xF7 each after register 0xFF = its address), 0xFE {u16
register, u24 value} pairs (`FxDspIndirectWrite`), 0xFF the end. The `7c aa aa 7d 55 55 ...` bytes are 19
0xF7 records at coefficient 0x8D, 33 values each, a curve from 0x800000 to 0x7FFFFF; the `Str_yUUz_UU_*`
"strings" were inside them. The DSP sits behind the halfword registers at 0x98050000 + 2 x reg
(`FxSerialRegWrite` 0x5018B22B), busy on bit 2 of 0x98070000, its chip select, reset and strobe on bits 4 / 2
/ 1 of the write-only latch 0x98000000 (`Latch98000000Set` / `Clear`).

**Parameter scripts** (`FxParamScriptRun`, `FxScriptGroupFind`, `FxParamEntryExec` 0x5018A7B8): one group per
parameter number, {u16 big-endian length, entries {kind, index into the kind's map group, operands}, 0x7A},
0xFF after the last group. The operand bytes per kind are each converter's pointer advance
(`gen_data_s.FX_OPS`); 0x64 / 0x66 / 0x21 are {u24 lo, u24 hi} and give lo + (hi - lo) x v / 99 (0x21
doubled), 0x67 an offset plus v ms in samples, 0x68 x v / 180, 0x79 bypasses the unit and runs
`FxDspClearStream`. Eight groups of types 96..99 (no descriptor, no name) and the map of type 127 do not tile;
they stay bytes with the reason [INFERENCE: never reached].

**Address maps** (`FxMapAddrFind` 0x5018AE27): groups {u16 BE length, kind, u16 BE DSP addresses}, 0xFF after
the last.

They are typed by `gen_data_s.py fx_streams()` (profile key `fx_streams` = 208), macros `FXP_*`, `FXS_*`,
`FXM_*` in `src/include/data_tables.inc`, labels `FxProgram_<type>`, `FxScript_<type>`, `FxMap_<type>`,
`FxUnitIdleProgram<unit>`, `*Orphan_<ADDR>`, each header naming the types and their effect names. The type
is the `FxDescTable` index: the effect presets `FxPresetTable` points at hold it at +0x12
(`FxDescIndexGet`).

**The descriptor fields** (probe `kn2400_fx_pnums.py`; renamed in `FX_DESC` / `FX_PARAM` and in the getters'
names):

| field          | was      | reader and role                                                                                                                                                                                                     |
|----------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| FX_DESC +8     | `mode`   | `connection`: `FxConnectionGet` 0x4863BA0B maps it to the unit's connection message (kind 9); 0 reverbs / choruses / gates, 1 depth effects, 2 rotary / amp / wah / pitch, 3 Dry/Wet [INFERENCE: a connection type] |
| FX_DESC +9     | `pnum9`  | `speed_param`: `FxSpeedNudge` 0x4863B51E (no caller; a label now) moves that parameter by (value - 0x40) within min / max: LFO SPEED, SLOW LFO SPEED or PEDAL in the 27 descriptors that set it                     |
| FX_DESC +10    | `pnum10` | `tempo_param`: `FxParamValueGet` 0x4863DF3E answers GetM3Em id 4 (TEMPO) for it (0x4863DFD6 / 0x4863E068); the two "TEMPO" effects                                                                                  |
| FX_DESC +11    | `pnum11` | `drive_param`: func_4863B2B6 / func_4863B3CF reload an effect of the same type keeping its parameters (kind 5) only when it is -1; the DRIVE of 9 twins                                                             |
| FX_PARAM +0x1D | `x29`    | `depth_link`: 0 when the parameter follows the depth control; `FxParamNextDepthLinked` (was FxParamX29Get) searches for the next one, `FxDepthApply` scales it                                                      |

## 2. Sound switch states, the 'Tone' hash, the TG sides (items 3, 4, 8)

**KN6000 switch states** (probe `kn6000_swno_states.py`). `SoundSwNoGet` 0x4C09AFB0 reads the state at
0x4C09AFD0 and answers 0 {+3, +5}, 1 {+3, +6}, 2 {+4, +7}, 3 {+4, +8}; for states 2 / 3 it then adds 2 x the
source ToneKeyFind found (0x4C09B010..18: the 0x57000000 / 0x56000000 archives). The inverse,
`SoundSwNoBankGet` 0x4C09B200, makes the ShortKeyHash key group from the group + 0 (state 0), + 0x10 (1),
+ 0x40 (2 / 4 / 6) or + 0x60 (3 / 5 / 7); `SoundGroupNames` (data_4C3EB620) gives 0x00..0x0F the panel SOUND
GROUP buttons and 0x40..0x7F the 32 SOUND EXPLORER categories. The even state is the one for a part that has a
DSP unit: `PartHasDspUnit` 0x4C007A5B compares GetM3EmVal(0xB050 .. 0xB010), the DSP units' parts, with the
part, and `MainGetSoundName` (MT_GetSoundSwNo) adds 1 when there is none. `GetSoundDev` uses 2 / 3. So:

| state | payload bytes                             | name                     |
|-------|-------------------------------------------|--------------------------|
| 0     | +3 `panel_group`, +5 `panel_no_dsp`       | panel switch, DSP unit   |
| 1     | +3 `panel_group`, +6 `panel_no`           | panel switch             |
| 2     | +4 `explorer_group`, +7 `explorer_no_dsp` | SOUND EXPLORER, DSP unit |
| 3     | +4 `explorer_group`, +8 `explorer_no`     | SOUND EXPLORER           |

The round trip ShortKeyHash -> sound -> ToneKeyHash agrees for all 2,898 entries. `TONE_KEY_PAYLOAD` has the
new field names; 20 routines are named in `kn6000_manual.sym`. [INFERENCE] bank MSB 0x28..0x2F are the
variants that need a DSP unit (state 0 holds 11 such switches where state 1 holds the 0x20 ones).

**KN7000 'Tone' hash** (probe `kn7000_tone_hash_readers.py`). The same routines, with four archive sources:
`ToneKeyFind` 0x4856FC51, `SoundSwNoGet` 0x4856FF75 (+3 .. +8), `SoundIconGet` (+2), `SoundToneIndexGet`
(+0), `ShortKeyLookup`, `SoundSwNoBankGet` (state 1's offset is 0x12: the KN7000 has 18 panel groups),
`SoundGroupNameGet`, `SoundGroupSizeGet`, `PartHasDspUnit` 0x484161BE ... (31 names in `kn7000_manual.sym`,
ported to 942 / 935 / 893). In the table flash's archive (`tools/gen_table_voices.py`) the payload is
`jk_tone_key`; the table called "Dir1" is the switch-key hash (u16 key = key group << 8 | number, payload
`jk_sw_key` msb, lsb, program: `JkSwKey*`); `JkGroupTable` is `JkGroupSizes`. The "entry +14" zone pointers
of the generator were payload bytes +6..+9 read as an offset (they labelled nothing) and are gone. Round trip:
3,323 entries, 0 bad.

**TG sides** (probe `tg_side_bits.py`): 0x400 is the MAIN TG 0x98050000 (IC203 / IC204), 0x800 the SUB TG
0x98040000 (IC207 / IC208): `TgVoiceSideSelect` -> `TgElemRequestFlags` (bits 0x08 / 0x10) ->
`TgVoiceNodePick` (`TgNodeScanSideA` keeps the slots below 0x40) -> `TgVoiceRegWrite` 0x4C036F98 (slots below
0x40 to 0x98050000). All 5,215 zones name an existing wave entry on that side (the swapped reading: 2,120 do
not), so each zone comment now names only that side's recording.

## 3. Loops and memory slots (item 5)

- **`top_tested`** (`data_readers.Reader.loop_bound`): a loop `L: cmp End, aN` / an exit taken once aN reaches
  End (bcc / bge / beq) / ... / `add s, aN` / `bra L` bounds the array as array_end's bottom-tested loops do.
  It adds no bound in the images (941: 46 bound accesses with and without it): the compiler writes its
  pointer loops bottom-tested; a scan of the four trees' code for a top-tested `cmp <data label>, aN` with a
  branch back finds none (0 of 27 / 112 / 115 compares with an exit after them in 941 / KN2400 / KN6000).
  The top-tested loops the opaque search found compare a loaded field with a terminator (0xFF, -1, 0, 0xFFFF:
  section 7), not a pointer with an end.
- **`fld_slots`** (`mem_ptrs` extended): a pointer the code loaded from a typed field and stored to a memory
  slot, the only thing ever stored there, is that field's pointer again where the slot is loaded. 131 such
  slots in 941 (localeconv's ...); they type no new byte, because their targets are typed already.
- What stays out of reach is a run-time dispatch, not a walk limit: SetApTimer's message field is read only by
  ApTimer, which hands it to `ProcCall` 0x4842948C, and ProcCall calls the procedure the task registered in
  the RAM table 0x5011FAAC (`lsr 16 / asl 4 / add 0x5011faac` / `mov (4, a0), a2`), filled when a window
  registers itself. Code addresses stored to a fixed memory slot and called back through it (a `calls` of a
  loaded slot) occur once in 941 (zlib's `zalloc` / `zfree` in the z_stream record); none in the KN6000.

## 4. Field names (item 6)

`tools/data_field_uses.py` now follows the loaded register from the access's own place (`Access.pos`, the
file and line the walk read it at: two places of one instruction no longer disagree), follows a value parked in
the frame to its reloads (`mov dN, (N, sp)` ... `mov (N, sp), dM`), goes on at an unconditional branch's
target, reads a compare before a backward beq / bne as a search key (not a count), and where the places of a
field's readers still disagree names the field by the uses of all of them, by `name_for()`'s precedence. A
field compared only with 640 / 639 is `x`, with 240 / 239 `y`, and a number field used as a pointer `addr`.
Each is a switch (`field_pos`, `field_slots`, `field_bra`, `field_keyloop`, `field_merge`, `field_screen`).

Record fields still named only by their offset although a reader touches them
(`../mn10300-formats-probes/field_names_census.py`, main 43242446d -> this branch):

| tree       | before | after | named after |
|------------|--------|-------|-------------|
| kn7000-941 | 630    | 256   | 968         |
| kn7000-942 | 633    | 258   | 969         |
| kn7000-935 | 639    | 263   | 975         |
| kn7000-893 | 638    | 263   | 968         |
| kn6000     | 683    | 264   | 914         |
| kn6500     | 685    | 263   | 915         |
| kn2400     | 637    | 208   | 922         |
| hdsx3      | 43     | 37    | 8           |

The names given most (941, `rest_stats.py`'s two runs): `key` 270 (hash buckets and search loops),
`index` 67, `param_key`, `kind` and `count` 6 each, then named routines' arguments (`memcpy_d1`,
`LibF64Mul_d0` ...).

What stays offset-named (941 checked by `why_off`-style classification of the remaining fields): values whose
only use is a store, an arithmetic combination or a return (156), uses that name nothing (`cmp 0`, a pointer
used as one: 73), and fields read through `memcpy` / `strcpy` (12, their bytes are text or blocks).

## 5. The HD-SX3 plug-in (item 7)

- **Entry vectors** (probe `hdsx3_entry_vectors.py`): all 20 (+0x08 .. +0x54) are called by the KN6000 and
  the KN6500, each through a stub that tests `XaprBoardDetect`'s result: +0x08 `XaprEntryInit` once at boot
  with the registry base, +0x0C `XaprEntryIdle` every pass of the main task loop, +0x10 / +0x14 the two
  interrupt handlers' bodies (groups 0x18 and 0x1B), +0x18 the PutM3Em hook of message group 0x70, +0x1C ..
  +0x54 the host file layer's operations while its ExtMode flag is set (free space, names, error, open,
  close, remove, getc, putc, read, write, seek, rewind, tell). Header +0x04: `XaprBoardDetect` accepts the
  board only when the word it points at also reads "XAPR". Names in `hdsx3_manual.sym`, the host's side in
  `kn6000_manual.sym` / `kn6500_manual.sym`.
- **Indirect calls** (probe `hdsx3_indirect_calls.py`): 2,630 (also `command grep -c 'calls\s*(a[0-3])'
  hdsx3/src/program.s`; the item table above said 2,625 until 2026-11-02), all resolved: 2,444 through registry slot
  0x100 (block 0), 183 through slot 0x107 (block 7), 3 through the tag table of func_97834719. Every host
  call in `hdsx3/src/program.s` now carries the routine's name (`gen_image_s.py --host-calls`, from the
  `host_calls.tsv` gen_data_s.py writes). `milk_model.py` read slot-0x107 calls as block-0 routines
  (0xEC SaveTm_HD as RegisterObjectTable): it now follows the slot-0x100 chain only (the 11 registrations
  are unchanged).
- **Run-time-built pointers**: none besides the registry: every `calls` register comes from the registry
  chain or the tag table.

## 6. The other open items of the notes (item 8)

| note                    | item                                                    | outcome                                                                                                                                                            |
|-------------------------|---------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| mn10300-formats 1       | strap-chosen tables not named                           | `func_487019FB_*_Table` are `SoundAlphaListTable` / `...KN2400`; `func_5015A8CC_entry_L21_Table` is the KN2600's parameter-group lists (section 7, kn2400 group 9) |
| mn10300-formats 2       | the KN7000 'Tone' hash's readers                        | CLOSED (section 2)                                                                                                                                                 |
| mn10300-formats 3       | the 20 KB streams                                       | CLOSED (section 1)                                                                                                                                                 |
| mn10300-typer           | top-tested loops; `mem_ptrs` finds few slots            | CLOSED (section 3)                                                                                                                                                 |
| mn10300-typer           | field names offset-named                                | CLOSED (section 4)                                                                                                                                                 |
| callee-walk             | a pointer the routine stores                            | a run-time dispatch (section 3)                                                                                                                                    |
| data-final              | recursive structures one level deep                     | closed by lane mn10300-typer's `deep_records`                                                                                                                      |
| data-final / siblings   | the 1,525 "high-entropy" bytes ("JPEG tables")          | the powers of ten, `Pow10Table`, in every tree (section 7)                                                                                                         |
| siblings-data-final     | the effect-program blocks                               | CLOSED (section 1)                                                                                                                                                 |
| sp7001 plug-in menu map | titles without a screen (TT_PS, TT_SDAUDPLY, TT_SDCCUS) | the host's screens (PanelSimulator, SDAudPlayScreen, SdCardCustomLoadSave), from 942's gui_ids.inc                                                                 |
| table-semantics         | which TG each side bit means                            | CLOSED (section 2)                                                                                                                                                 |

## 7. The opaque blocks (item 9)

Four probes grouped every `census: opaque -- unknown-dump` piece and searched each group's readers beyond the
linear walk: indirect accesses through tables, offsets added to a base, loops that test a terminator before
stepping, copies into RAM, the initialised RAM image (`opaque_groups.py`, `opaque_readers_941.py`,
`kn6000_opaque.py`, `kn2400_opaque.py`, `hdsx3_opaque.py`).

**Typed by this lane** (new passes): the KN2400 effect DSP (55,111 B), the powers of ten (309 doubles: 941
0x486D06DC, 942 0x486D1700, 935 0x486BCEFC, 893 0x486BB6A4, KN6000 0x4C326F54, KN6500 0x4C2B276C, KN2400
0x485288D8, HD-SX3 0x978AFD98; PfDoubleToDecimal reads base +- 8 x the exponent), the EUC-JP strings of the
language tables (AcLanguageTextProc `cmp 6, d0` / `mov (d0, a3), a0`), the siblings' parameter-id tries
(`ResourceIdTrie`, the KN7000's design, read by `ResourceIdFind`: KN6000 0x4C02CA6A, KN2400 0x5014A95C; these
were `func_4C02CA6A` / `func_5014A95C` when this lane wrote it), the KN7000 builds' own
"Technics Pads" copy, the KN2400's alphabetical sound lists (both strap sets).

Opaque bytes per tree (main -> this branch, the table under "Measurements"): 941 45,394 -> 33,741, 942 43,654 ->
31,158, 935 46,280 -> 34,612, 893 45,007 -> 33,339, KN6000 54,782 -> 39,985, KN6500 59,027 -> 44,212, KN2400
155,297 -> 61,226, HD-SX3 2,981 -> 594: 173,555 bytes over the eight trees.

**Readers found, typing not written in this lane.** Each group below has a traced reader and an exact layout
in its probe; no pass of the generator writes them yet, so they stay opaque with the census marker. They are
the next lane's work list (bytes per tree):

| group                                         | KN7000 941 | KN6000 / KN6500          | KN2400 | reader (example)                                                                                                                                                                |
|-----------------------------------------------|------------|--------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| widget variables in the initialised RAM image | 3,526      | 2,950 / 2,948            | 3,876  | the class Proc's dereference (PsListBoxProc `add 0x2c, a0 / mov (a0), a1`)                                                                                                      |
| 128 x 64 code / chord maps                    | 5,352      | 5,352                    | 4,426  | func_48412A17 / func_4C15F0D9 / func_4863D95A (`asl 7`, `cmp 0x7f`)                                                                                                             |
| chord voicings and inversions                 | 5,008      | 3,486 / 5,142            | 5,147  | func_4856DC66 / func_4C0FE8A1 / func_486F84EC (memcpy 8, `+ 8 x root`)                                                                                                          |
| terminator-ended lists (12 / 13-byte records) | 7,516      | 8,857                    | 4,189  | PanelButtonDispatch (`cmp -1`), func_484061F9 / func_4C155072 (0xFF)                                                                                                            |
| style / setup lists (u16 until 0xFFFF)        | 638        | 4,624 / 5,056            | 7,694  | func_4847D083 / func_4C164F0F / func_4863EFAC                                                                                                                                   |
| FX presets                                    | -          | -                        | 18,434 | FxPresetGet 0x4863CDB5, FxDescIndexGet (+0x12)                                                                                                                                  |
| fixed-count tables past their typed part      | 4,663      | 5,244                    | 896    | ChordRecogTable2 (2048 x 2), the 32-slot hash tables, the 101-entry clamp, HpFlashWriteDefaults (99 words), the mixer pages, the CRC-7 table, the KN6000 constant-length copies |
| copies into RAM of a constant length          | -          | 1,182 (in the row above) | -      | HpFlashWriteDefaults, MemStyleRecInit (128), func_4C02F9BB (memcpy 1,984)                                                                                                       |

(Typed 2026-11-02 by lane mn10300-data, `../mn10300-data/README.md` section 1: `widget_vars`, `maps128`,
`chord_voicings`, `sentinel_lists` (the terminator-ended and style lists), `fx_presets`, `index_bounds` and
`table_terminators` (the fixed-count tables); what is still left is that note's section 4.)

**Stays opaque, by group, and why**: alignment padding and record tails no reader reaches (941 443 B, the
107 x `01 00` after the switch descriptors), IvCustomizeBase's x / y (no Hp* or Customize routine reads +0x30
/ +0x34), the reflection tables' second halves (the file-name slots: only the slot after the last name is
read), the flash sector tables (+8 unread), the KN2400's chord-name tables (no word of the image points into
them) and its coefficient curves at 0x4840DAF8 (no holder), the HD-SX3's dead `"\n"` literal and its unread
caption table. Each is listed in its probe's `--left` output.

## Measurements

Before: main (the lane's base 43242446d; main after its merges, 14867ef84, has the same reader rows, opaque pieces
and offset-named fields, measured on its committed sources). After: this branch's committed sources after the merge
with main and the regeneration (typed bytes as gen_data_s.py reports them; reader rows and opaque pieces n / bytes,
`typer_stats.text_stats`; fields `field_names_census.py`):

| tree   | typed before | typed after | change  | reader rows before | reader rows after | opaque before   | opaque after   | offset-named fields before | after |
|--------|--------------|-------------|---------|--------------------|-------------------|-----------------|----------------|----------------------------|-------|
| 941    | 2,143,981    | 2,154,302   | +10,321 | 78 / 905           | 78 / 905          | 2,174 / 45,394  | 2,073 / 33,741 | 630                        | 256   |
| 942    | 2,150,400    | 2,161,564   | +11,164 | 81 / 1,013         | 81 / 1,013        | 2,196 / 43,654  | 2,094 / 31,158 | 633                        | 258   |
| 935    | 2,144,574    | 2,154,908   | +10,334 | 84 / 1,049         | 84 / 1,049        | 2,192 / 46,280  | 2,090 / 34,612 | 639                        | 263   |
| 893    | 2,144,470    | 2,156,004   | +11,534 | 79 / 917           | 79 / 917          | 2,177 / 45,007  | 2,076 / 33,339 | 638                        | 263   |
| kn6000 | 2,436,905    | 2,450,916   | +14,011 | 142 / 9,370        | 136 / 9,310       | 2,347 / 54,782  | 2,175 / 39,985 | 683                        | 264   |
| kn6500 | 1,948,203    | 1,962,208   | +14,005 | 147 / 9,486        | 141 / 9,426       | 2,364 / 59,027  | 2,189 / 44,212 | 685                        | 263   |
| kn2400 | 1,688,962    | 1,783,452   | +94,490 | 184 / 8,255        | 171 / 7,098       | 3,419 / 155,297 | 2,885 / 61,226 | 637                        | 208   |
| hdsx3  | 482,118      | 484,505     | +2,387  | 34 / 211           | 34 / 211          | 98 / 2,981      | 95 / 594       | 43                         | 37    |

The typed figure of the KN7000 builds also holds main's own changes since the base (its KN7000 data
regeneration, db4ea1c3a, and the stale song events lane floppies types with `k5_*`), so it is a little less
than the opaque bytes this lane typed (941: 11,653).

**Bytes typed before and not after** (`rest_stats.py`'s "typed in the off run only"): 0 in the four KN7000
builds and the HD-SX3. KN6000 962, KN2400 894 (KN6500 the same shape): the over-long struct arrays
`func_4C02CA6A_Records` (244 x 8) / `func_5014A95C_Records` (229 x 8), named after the reader now called
`ResourceIdFind` (the generated record labels keep the old stem, e.g. `func_4C02CA6A_Records_p0_86`), that ran from the parameter-id trie's
root over what follows it (the root has 16 entries; ResourceIdFind never reads past them), one reader table at
their end, and the KN2400's `func_50144C7D_Selected_1`, a "record" inside a leaf. They are what an over-long
item held, as in lane mn10300-typer.

**Census figures** (read-only): `scripts/analysis/data_incbin_census.py --compare
docs/coverage/data-incbin-2026-10-31-02.json` exits 0, generic 0 everywhere. The siblings' opaque *piece*
counts in the census taken mid-regeneration rose (KN6000 2,347 -> 2,551) while their bytes fell; with the trie
leaves typed the final pieces fall too (the table above). `scripts/analysis/doc_quality_census.py --compare
docs/coverage/doc-quality-2026-10-31-02.json` exits 1 for one figure per sibling:

| image  | debt                          | before -> after  | why                                                                                                       |
|--------|-------------------------------|------------------|-----------------------------------------------------------------------------------------------------------|
| kn2400 | (a) routines without a header | 21,242 -> 21,243 | `FxSpeedNudge` 0x4863B51E: code no traced path reached, a routine with a name now (a label nothing calls) |
| kn6000 | (a) routines without a header | 19,021 -> 19,022 | `XaprIsrGroup24` 0x4C172AA2: the interrupt handler only a def_int immediate names, labelled now           |
| kn6500 | (a) routines without a header | 19,070 -> 19,071 | `XaprIsrGroup24` 0x4C1732A4, the same                                                                     |

(Run again on the final, merged tree: the same three, and two KN5000 rises, v6 7,827 -> 7,828 and v5 7,829 ->
7,832, which come from main's lanes merged after that snapshot, not from this lane: it changes no KN5000 file.)
`make dispatch-census` measures no MN10300 image.

**Gates** (worktree, `kn7000/build/*.labels` deleted first): `make gate-kn7000 gate-kn6000 gate-kn6500
gate-kn2400 gate-hdsx3` and `make -C kn7000 symbols-check`: both exit 0 (52 OK lines, no FAIL), after the merge with main
(14867ef84) and the regeneration; `make -C kn7000 data-and-code-src` after the builds stopped in round 1 with nothing
changed.

## Regenerating

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides, `UNIDASM=` and
`SP7001_UPDATES=`):

1. `make -C kn7000 table-src table-src-sp7001` (the voice archives);
2. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500`, then `hdsx3` (its host is the
   KN6000), then `make -C hdsx3 gui-map`;
3. `make -C kn7000 symbols-sp7001 symbols-935 symbols-893 SYMOUT=<scratch>` and copy the three
   `kn7000_*_manual.sym`;
4. `python3 tools/gen_program_s.py --profile <b>` for 941, sp7001, b935 and b893;
5. `make -C kn7000 data-and-code-src`, then `make -C kn7000 plugin-src` and `python3 tools/gui_menu_map.py
   --profile sp7001plugin`;
6. build the four programs (`make -C kn7000 verify verify-sp7001 verify-935 verify-893`), then
   `data-and-code-src` once more.

## Website page draft

(For the KN2400, KN6000, KN7000 and HD-SX3 pages of technics-docs, to be added by the website sync.)

> **The KN2400's effect DSP.** The SX-KN2400 downloads a program into its effect DSP for each effect type: a
> stream of records that write program words, coefficients and registers, a script per effect parameter that
> turns the panel value into coefficients (a range, a delay in milliseconds, a scale), and a map of the DSP
> addresses each script entry writes. 208 types, 55 KB, now one macro per record in the source; the
> descriptors' parameter numbers name the LFO speed a control nudges, the parameter that follows the tempo,
> and the drive an amp twin keeps.
>
> **Sound switches.** Every sound has four switch positions: on the panel's SOUND GROUP buttons and in the
> SOUND EXPLORER's 32 categories, each twice -- once for a part that has a DSP effect unit and once for one
> that has none. The KN6000 and KN7000 share the tables and routines; the KN7000's tone generator side bits
> say whether a zone's recording is in the MAIN or the SUB wave ROMs.
>
> **The HD-SX6 plug-in's entry points.** The expansion board's program exports 20 entry points: start-up, an
> idle call, two interrupt handlers, a parameter hook, and a whole file system that the KN6000's own file
> layer forwards to while the hard disk is in use. Every call it makes into the KN6000 is now named.
>
> **What was left opaque.** The "high-entropy" blocks were the C library's table of powers of ten; the
> Japanese messages are EUC-JP strings. What still has no type is listed with the routine that reads it.
