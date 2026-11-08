# Lane open14/kn7000-subsystems (2026-11-07, wave 13): program 941's func_ routines named from evidence

Wave 12 found that automatic porting had plateaued (7 to 25 new sibling names per model), and that
every name program 941 gains reaches 942, 935 and 893 through the offset map and the KN6000,
KN6500 and KN2400 through `aligned-names` (1,358 / 1,421 / 2,320 call-site pairs that 941 itself
left unnamed; `../sibling-names2/README.md`).  This lane named 941's `func_<ADDR>` routines by hand,
range by range, from the evidence each routine carries, and propagated the names.  Items:
N-99771106 (893), N-a810f3f6 / N-f22bdce4 / N-b3ba9d8b (KN6000 / KN6500 / KN2400) and
L-wave12-kn7000-handback-names.  The probes are in `../kn7000-subsystems-probes/` (README there).

## How the names were made

1. `routine_graph.py` splits 941's generated source into routines and lists, per address range,
   each `func_` routine with its named callers, named callees, the strings and named data it uses,
   and which siblings pair it by call sites (`--list`, `--rank`); `--show` prints one body with its
   strings resolved.  `--clusters` measured where the evidence is (`clusters-92b5cc4a7.txt`).
2. The code was read in nine ranges (one reader per range, the same brief for each): every name was
   given only after reading the routine's body, and every row says its evidence class and its
   evidence.  The classes:

| class  | meaning                                                                                          |
|--------|--------------------------------------------------------------------------------------------------|
| STR    | a firmware string the routine itself uses (screen text, message, file name / pattern, format)    |
| TABLE  | a firmware table names it or its slot (reflection / class-procedure / name / id table)           |
| WRAP   | its whole body is one call of a named routine with constant arguments, or a named routine's twin |
| CALLEE | what it does, read from the named routines it calls and the arguments it passes them             |
| CALLER | its callers are all in one named subsystem, and its body does what the name says                 |
| RAM    | the named RAM it reads / writes (accessor, flag, counter, record of a named owner)               |
| IO     | the named I/O registers or hardware windows it drives                                            |
| BODY   | a self-contained helper whose body alone shows what it computes                                  |

3. `check_proposals.py` checked every row: a well-formed name, new in every MN10300 tree (a name
   the IC18 boot ROM or the Style Convert converters give the same code is reused, as the tree
   already does for `localeconv` and the printf helpers), on a 941 `func_` routine start, with a
   class and evidence.  The routines the IC21 notes name (`custom-data-ic21.md`,
   `ic21-own/README.md`, 109 of them) were left to lane kn7000-ic21, and so were routines whose job
   is reading or writing CUSTOM STYLE / CUSTOM SOUND data.
4. Six of the nine readers were stopped by a usage limit, four of them before they wrote their
   notes (ranges 0x48400000, 0x484A0000, 0x48540000 and the library); their rows up to that point
   were kept and checked like the others.
   A sample of rows from every range was re-read against its body before the merge.  Six rows
   failed the checker and were fixed: two library names IC18 gives the same code (kept), two JPEG
   marker writers with too short a note (rewritten), and two names two readers gave different
   routines: the composer's `CmpRecArrangeSet` (the store, 0x4843C786) against its GUI-side
   request (0x48508C55, now `CmpRecArrangeRequest`, with its pad twin `PadRecArrangeRequest`), and
   `PadBankNameGet` (the reader, 0x484373B7) against `MainFuncCall(FN_MainPAD_GetPadBankName)`
   (0x48511A3F, now `PadBankNameRequest`).

All 2,312 names are one section of `../../kn7000_manual.sym` ("lane open14/kn7000-subsystems"),
one subsection per range, each row `0xADDR  Name  ; [CLASS] evidence`.

## What was named (`name_tally.py`, `name-tally.txt`)

| range                                        | names | STR | TABLE | WRAP | CALLEE | CALLER | RAM | IO  | BODY |
|----------------------------------------------|-------|-----|-------|------|--------|--------|-----|-----|------|
| the two names lane kn7000-research2 proposed | 2     | 0   | 0     | 0    | 0      | 2      | 0   | 0   | 2    |
| 0x48400000..0x48430000                       | 320   | 5   | 3     | 6    | 121    | 37     | 69  | 159 | 194  |
| 0x48430000..0x48450000                       | 275   | 12  | 7     | 9    | 52     | 95     | 52  | 0   | 273  |
| 0x48450000..0x48460000                       | 326   | 0   | 2     | 27   | 110    | 62     | 106 | 0   | 142  |
| 0x48460000..0x48470000                       | 243   | 8   | 39    | 15   | 91     | 71     | 112 | 0   | 114  |
| 0x48470000..0x484A0000                       | 241   | 31  | 13    | 12   | 113    | 6      | 101 | 0   | 79   |
| 0x484A0000..0x484F0000                       | 212   | 9   | 5     | 6    | 81     | 110    | 67  | 9   | 83   |
| 0x484F0000..0x48540000                       | 234   | 58  | 21    | 10   | 153    | 82     | 77  | 0   | 83   |
| 0x48540000..0x48590000                       | 324   | 68  | 10    | 3    | 188    | 43     | 174 | 0   | 97   |
| 0x4C000000..0x4C040000                       | 135   | 27  | 3     | 2    | 13     | 105    | 1   | 0   | 134  |
| total                                        | 2312  | 218 | 103   | 90   | 922    | 613    | 759 | 168 | 1201 |

(A row with two classes counts in both; every row has at least one.)

By subsystem, in the readers' words:

| range                 | the subsystems named                                                                                                                                                                                                                                                                                    |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x48400000-0x48430000 | the two floppy-controller drivers of region 1 (each routine the same code as an IC18 `Fdc*` routine; the copy entered on strap 3 is `FdcStrap3*`, the program's own `FdcPrg*`), the JPEG encoder's helpers (`JpegFdct8x8`, marker writers), the DSP host port, draw-queue helpers                       |
| 0x48430000-0x48450000 | PERFORMANCE PAD editor and TPAD heap, the composer (MEMORY style editor), the five tempo clocks (10-byte blocks at 0x50149666 + 10 k), style part templates, user SOUND RAM, rhythm event-stream editors, the SOUND ARRANGER SRAM table                                                                 |
| 0x48450000-0x48460000 | sequencer switch flags and measures, the song records (`Rec8E0TablePtr`'s 11 records), song-memory pages and their free chain, song cursors, song event encode / decode, record / output queues, held-key lists                                                                                         |
| 0x48460000-0x48470000 | the sequencer's title and mode enter / leave handlers (named after their jump-table slots), medley play, note / drum edit, step record, a C file layer (`Fs*`, the names lane sibling-names3 gave the same routines in the KN6000 and KN2400) and the FAT12/16 driver (`Fat*`) with its operation table |
| 0x48470000-0x484A0000 | floppy media type and find, the SD sector layer and the SD FAT format writer, the file stream reader task, Techni-Chord, Style Convert, style list boxes, the disk playback player (SMF 0 / 1, E-SEQ, PianoDisc), part-parameter procs, drawbar shadows                                                 |
| 0x484A0000-0x484F0000 | the service tests (sine sweep, RAM / VRAM), the panel LED shadows and serial helpers, MIDI 1 / 2 receive and transmit, the PC COMMUNICATION protocol                                                                                                                                                    |
| 0x484F0000-0x48540000 | the sound / drum editor's field read, write and value texts, file manager string helpers and lists, the `*_HD` load / save helpers, the fmm drive dispatch (`FmmGetc`, `FmmPutc`, `FmmWrite`), the SLIDE codec buffers, composer / pad dialogs                                                          |
| 0x48540000-0x48590000 | the SD card screens and list scanners, the SD AUDIO / SD SOUND players (`SdAud*`), the slide show (`Ssw*`), help                                                                                                                                                                                        |
| 0x4C000000-0x4C040000 | the uITRON kernel's inner routines (queues, ready queue, TCB lookup), soft-float helpers, TG part controllers (`TgPartExpressionSet` ...), the M3 store's setters                                                                                                                                       |

Findings the readers reported that touch existing names or data (none was renamed here):

- `StyleIdArrayHandler` (`kn7000.sym`) is passed as the event handler of `StylePartFieldEmit`,
  `PartFieldCcSend` and `PartSustainOffSoundOff`, and called as `handler(status, data1, data2,
  data3)`: it maps `status & 0x0F` through `StylePartToTgPart` and sends the event on (notes to
  `MetronomeNoteEvent` while 0x50034C3D is set, else `PartEventToParam`): the style parts' MIDI
  event output, not a builder of style-ID arrays.  Its pad twin `func_484378EF` is left unnamed.
- `Rec8E0TablePtr`'s comment calls the song-slot reading "plausible only"; the bodies confirm it:
  `GetSeqPlyPart` reads record 0 at +0x1E, the current-song switch stores record 0 to its slot and
  loads the new one, and the capacity routines sum a record's track page chains.
- Data labels the generator attached by value, not by meaning: `SeqTrackModWheelReset`
  (0x48454C49) loads M3 id 0xB00001 (CC 1), spelled `SndArgrScreen_StrBox_PATTERN_id`;
  `Str_empty_266` and `Str_a_3` are byte variables (the current drum key; a sine-sweep note), not
  strings; `PostEvent_Records` is the style-era table.  For lane mn10300-data5 (`gen_data_s.py`).
- `kn7000_manual.sym` names 0x4C0216A3 twice: `M3SetSpecialDispatch` (hand) and
  `M3HookDispatch` (the generated sibling-port block, which the code uses).

Open leads the readers listed (bodies read, no name given for lack of evidence): the key-bed router
`func_484524EB` and the 0x14-byte record lists at 0x5003ADE4; the play / rec / punch re-arm
handlers (`func_4845B26E`, `func_48459D31`, `func_4845C0CC`); the pad and composer recorders and
the rhythm controller core (0x4843E8A7.., 0x484428BC..); the transport start / continue / stop
sequences (0x48445DA5..); the lyrics box (0x484FA4BB..); the single-load row builders; the
parameter-dump formatters; the disk-player text rings; empty `ret` stubs (no evidence in a body
of `ret`).

## Propagation

In the order of `../kn7000-research2/README.md` and `../sibling-names/README.md`:

1. `make -C kn7000 symbols-sp7001 exports-941 symbols-935 symbols-893`: 942 takes 2,311 of the 2,312
   names, 935 all, 893 2,303 (the rest sit in code those builds lack or rewrote).
   `tools/check_ported_names.py` keeps every ported name on the same routine as in 941 except on
   routines a build edited: 942 manual same 3,680 / differs 2 (`ResetEntry`, `TickJobsTask`, as
   before), 935 3,682 / 1, 893 3,621 / 44, 35 of the 44 new names on code 893 edits (the SD AUDIO
   player, the SD / picture list scanners, the composer measure dialogs).
2. `make -C kn7000 data-and-code-src`: fixpoint in 3 rounds (round 2 moved 427 / 494 / 493 / 503
   lines of labels.sym in 941 / 935 / 893 / 942, data the generator now names after the new
   routines); all four builds byte-identical.
3. The data labels the generator had derived from a `func_<ADDR>` name keep it (a label the code
   spells is fixed).  `../../tools/derived_label_renames.py` writes, per tree, the sed rules that
   rename them after the routine the code now names at that address
   (`scripts/renaming/rename_kn7000_subsystems_derived_<tree>.sed`): 408 / 433 / 454 / 452 labels
   in 941 / 942 / 935 / 893 (the 37 / 59 / 80 / 80 left from earlier names included, among them
   `func_48449462_Records` -> `TableToneKeyMap_Records`); after the merge with main the same
   command renamed 409 / 434 / 455 / 453.  One per build stays, because its new spelling is
   another label already (`TechniChordUpdate_Var`), and 893's four `SdSndEditDef*` ones.  `data-and-code-src` afterwards changes no label (fixpoint in 2
   rounds).
4. The prose: `scripts/renaming/rename_kn7000_subsystems_routines.sed` (word-bounded `func_<ADDR>`
   -> name) on `kn7000_manual.sym`, `kn7000_b893_own.sym` and the 22 kn7000 notes that quote a
   renamed routine; the ported symbol files take the comments from `symbols-*`; changed tables
   re-padded.  `make -C kn7000 plugin-src gui-map`: no change.
5. Siblings (`kn6000`, `kn6500`, `kn2400`, `hdsx3`): `aligned-names`, `data-and-code-src`, the
   derived labels of the routines that took one of these names
   (`derived_label_renames.py --only` the new aligned rows: 130 / 132 / 256 / 0 labels), `ram-names`,
   `data-and-code-src`, `gui-map`; a second `aligned-names` wrote the same files in every model
   (fixpoint).

Measured on the final tree, after merging main 4e1d77a5b (which brought lane sibling-names3's hand
names and lane kn7000-ic21's IC21 reader names); "main" is that merge base, the tools' own reports:

| model  | aligned routine names (main -> after) | call-site audit, right / wrong | RAM pairs      | RAM names (owner + accessor) |
|--------|---------------------------------------|--------------------------------|----------------|------------------------------|
| KN6000 | 115 -> 1,040                          | 498 / 2 -> 758 / 3             | 2,123 -> 2,316 | 503 -> 602                   |
| KN6500 | 114 -> 1,056                          | 504 / 2 -> 761 / 3             | 2,124 -> 2,317 | 502 -> 601                   |
| KN2400 | 249 -> 1,629                          | 674 / 3 -> 1,107 / 3           | 3,147 -> 3,355 | 643 -> 773                   |
| HD-SX3 | 2 -> 6                                | 36 / 0 -> 36 / 0               | 0              | -                            |

The audit's wrong pairs are the ones wave 11 listed, plus one in the KN6000 and KN6500 (below).

**Merged with lane open14/sibling-names3**, which named the siblings' C file layer, string helpers
and INSTALL_SCRATCH cursor by hand in the same wave (`FsOpen`, `FsRead` ..., `StrCopy`,
`StrAppend`, `StrCopyPad`, `FileNameWithExt`, `FsMountVolume`, `ScratchPosReset` ...).  Their
routines are the same code as 941's that this lane had called `Vfs*` (`VfsFileOpen` ...), `FmmStr*`,
`FmmNameWithExtBuild`, `FatVolumeMount` and `ScratchCursor*`: after the merge the call-site audit
counted twelve "wrong" pairs where the two names met (KN6000 9, KN2400 3).  941 took the siblings'
names (`scripts/renaming/rename_kn7000_subsystems_fs.sed`: 25 file-layer routines, the twelve the
siblings had not named given the same `Fs` prefix, three string helpers, `FileNameWithExt`,
`FsMountVolume` and seven INSTALL_SCRATCH cursor routines), so each routine has one name across the
models.  One difference stays: 941's `SoundRamHeaderStamp`
(0x4844B431) and the KN6000's `SoundRamSumUpdate` (0x4C07DEC8, `kn6000_manual.sym`, marked
"[INFERENCE: name from the store]") are the same routine: both copy the 16-character "KN7000 /
KN6000 SOUND RAM" signature to the SOUND RAM header and then store `SoundRamChecksumCalc`'s value.
The KN6000 row is lane sibling-names3's file, so it is left for them (proposed:
`SoundRamHeaderStamp`, which says both steps); until then the pair is the audit's one new wrong
entry in the KN6000 and KN6500.

The pre-existing derived labels of the siblings (KN6000 714, KN6500 714, KN2400 2,881 labels made
from `func_` names that were named before this lane, `derived_label_renames.py <model>` without
`--only`) were left: they sit in the data regions lane mn10300-data5 regenerates this wave, and the
same command renames them in one step afterwards.

## Before and after

func_<ADDR> routine starts, `placeholders.py`: at this lane's base (`placeholders-92b5cc4a7.txt`), at
main 4e1d77a5b, the merge base of the final tree (`placeholders-main-4e1d77a5b.txt`: the other wave-13
lanes' names), and after (`placeholders-after.txt`).  The "this lane" column is main minus after.

| tree   | base 92b5cc4a7 | main 4e1d77a5b | after | this lane |
|--------|----------------|----------------|-------|-----------|
| 941    | 6,290          | 6,282          | 3,970 | 2,312     |
| 942    | 6,289          | 6,281          | 3,970 | 2,311     |
| 935    | 6,287          | 6,279          | 3,967 | 2,312     |
| 893    | 6,279          | 6,271          | 3,968 | 2,303     |
| KN6000 | 5,632          | 5,501          | 4,577 | 924       |
| KN6500 | 5,659          | 5,529          | 4,599 | 930       |
| KN2400 | 6,480          | 6,430          | 5,060 | 1,370     |
| HD-SX3 | 459            | 459            | 455   | 4         |

`../sibling-names-probes/sibling_name_census.py` on main's files (`sibling-census-main-4e1d77a5b.txt`)
and on the final tree (`sibling-census-after.txt`) reads the same in the siblings, and the RAM
operands the new RAM names spell:

| model  | func_ (stats)   | named          | work RAM 0x50 ops / addrs        |
|--------|-----------------|----------------|----------------------------------|
| KN6000 | 9,600 -> 8,057  | 2,962 -> 3,887 | 17,339 / 2,484 -> 16,871 / 2,387 |
| KN6500 | 9,658 -> 8,100  | 2,967 -> 3,898 | 17,379 / 2,495 -> 16,910 / 2,398 |
| KN2400 | 11,166 -> 8,901 | 3,528 -> 4,899 | 20,564 / 2,916 -> 19,952 / 2,786 |
| HD-SX3 | 765 -> 758      | 179 -> 183     | 0 / 0                            |

`make doc-quality` (`docs/coverage/doc-quality-2026-11-08-01`, against `-07-04`, main's last:
nothing rose) reads the same: (e) placeholder routine names program 6,282 -> 3,970, program942
6,281 -> 3,970, program935 6,279 -> 3,967, program893 6,271 -> 3,968, KN6000 5,501 -> 4,577, KN6500
5,529 -> 4,599, KN2400 6,430 -> 5,060, HD-SX3 459 -> 455; (b) operands spelled as a number outside
the image KN6000 14,110 -> 13,716, KN6500 14,134 -> 13,739, KN2400 15,464 -> 14,934 (the new RAM
names); (a) routines without a header program 20,241 -> 20,128.

## Items

**893's own routines (N-99771106).**  `../mn10300-names-probes/oldbuilds_b893_func_census.py b893`
now reads 3,977 `func_` labels: twin-unnamed 3,965, near-twin 10, own 2.  The two own ones were the
SD AUDIO player routines 0x485785B0 and 0x485788D8, in the family this lane named in 941 (`SdAud*`,
0x485790A9..).  0x485788D8 is 941's `SdAudFfStart` (0x48579A66, the one new name the offset map does
not place in 893) with an edited body: the same caller `MainSDAudPlay_FwdSW`, the same
`SdAudPlayGateGet` = 2 test, the same flags and `SdAudCmdKick`, but no tempo reload.  It is named in
`kn7000_b893_own.sym`.  0x485785B0 is the twin of 941's `func_48579683` (caller `func_4857A9C7`): a
chain of four checks (`func_485797F5`, `func_4857981F`, `func_485798AC`, a 0x2BC window, then
`func_485798CB`) each of which, on failure, clears a flag and, in 941 only, reloads the tempo.  The
four checks are unnamed in 941 too, so neither routine has a name yet.

| item                           | outcome | in one line                                                                                                                                                                                                                 |
|--------------------------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| L-wave12-kn7000-handback-names | CLOSED  | `SoundKindGet` / `TableToneKeyMap` in `kn7000_manual.sym`, ported to 942 / 935 / 893; their data labels renamed (`TableToneKeyMap_Records` / `_Table`), and every other derived label of a named routine in the four builds |
| N-99771106                     | OPEN    | 893 func_ 6,271 -> 3,968 (main -> after); own 2 -> 1 (`SdAudFfStart`); next: 941's `func_48579683` and its four checks, then 893's 0x485785B0                                                                               |
| N-a810f3f6                     | OPEN    | KN6000 func_ starts 5,501 -> 4,577 (main -> after; aligned names 115 -> 1,040); next: name more of 941's 3,970, then re-run `aligned-names`                                                                                 |
| N-f22bdce4                     | OPEN    | KN6500 5,529 -> 4,599 (114 -> 1,056); next as N-a810f3f6                                                                                                                                                                    |
| N-b3ba9d8b                     | OPEN    | KN2400 6,430 -> 5,060 (249 -> 1,629); next as N-a810f3f6                                                                                                                                                                    |

What is left in 941, measured: 3,970 `func_` routines; of them, the ones the siblings pair by call
sites (the siblings' `notes/routine-map-kn7000.tsv`, "A unnamed") are the next names with the
widest reach.  The readers' open leads above are the densest places to start.

## Website page draft

*For technics-docs' KN7000 firmware page, section "Names" (after the paragraph on the reflection
tables); text only, the integrator publishes it.*

> **Most of the program's routines have names now.**  Beyond the 2,302 names the firmware's own
> reflection tables give and the hand-named modules, a pass in November 2026 read the remaining
> unnamed routines of program v1.6 range by range and named 2,312 of them, each from evidence in its
> own code: the strings it prints or compares, the named routines it calls and how, the variables and
> hardware registers it uses, or the table that lists it.  Each name's evidence is recorded beside it
> in the symbol file.  Among them are both copies of the floppy-controller driver, the FAT file
> system and the SD-card layer, the song memory of the sequencer (song records, 256-byte pages, the
> read and write cursors), the tempo clocks, the performance-pad and composer editors, the SD audio
> player, the PC COMMUNICATION protocol and the kernel's queues.  The names reach program v1.3, v1.5
> and the SP7001 build by the same code, and the KN6000, KN6500 and KN2400 wherever their code calls
> the same routines in the same places.
