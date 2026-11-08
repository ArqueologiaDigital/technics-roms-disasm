# The MN10300 data generator, wave 10: value-name lists, boot sectors, style lists, false strings (lane mn10300-data2, 2026-11-06)

Lane `mn10300-data2` of wave 10 of the open-items effort. Its items (`notes/open-items/REGISTER.md`):
the `gen_data_s.py` hand-overs L-mn10300-names-bitcount-inference, L-mn10300-names-data-own-syms and
N-f67b155c; the record types the walk lacked, N-027de254, N-044cdbc6, N-4666109a, N-4b34dd8b, N-2468beef;
and the false-string and table-tail groups of `../mn10300-data/README.md` section 4. The O-kn7000-* /
O-kn6000-* / O-kn6500-* / O-kn2400-* / O-hdsx3-* rows shrink as a consequence (section 4 below).

The machinery is `kn7000/tools/gen_data_s.py` (and `data_struct_names.py`); every new rule is a key of
`gen_data_s.FEATURES` (off with `GEN_DATA_S_OFF=rule,...`): `support_values`, `sibling_support`,
`boot_sectors`, `panel_700`, `style_lists`, `reclaim_strings`, `curated_counts`. Probes:
`../mn10300-data2-probes/` (README there).

## 1. What the generator now types

| rule (`FEATURES`)                   | what it types                                                                                                                                                                                                                                                                                                     | reader evidence                                                                                                                                                                                                                                                                                                                        |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `support_values`                    | each SupportClass entry's +8: its value-name list, `{char *name, u32 value}` pairs ended by a pair whose name is "" (`SPT_VALUE_NAME`, `src/include/data_tables.inc`); a class with no names (+4 = 0: the integers, IDs, pointers, rects) has only the end pair, its "" the four bytes before it                  | the support classes' common handler, 941 func_48431434 (each `xxxProc` passes it what it does not answer; a3 = the entry): `movhu (4, a3), d0` / `cmp 0, d0` / `beq`, `mov (8, a3)` the list, `asl 3` / `mov (4, a0), d0` / `cmp d3, d0` (value -> name), `strcmp` (name -> value, -1 when none), `movbu (a0), d0` / `cmp 0` (the end) |
| `sibling_support`                   | the SupportClass table itself in the siblings (KN2400 registry slot 0xD, KN6000 / KN6500 slot 0x1C0), with its value-name lists                                                                                                                                                                                   | InitSptClassTable: `mov CLASS_SupportClass` ... `mov 0x37, d0` (the count) / `mov <table>, d0` / `mov 0x1c0, d0` / `call RegisterObjectTable`                                                                                                                                                                                          |
| `boot_sectors`                      | the first 32 bytes of a FAT boot sector a routine copies with memcpy (`FAT_BOOT_HEAD`): the formatters' heads (`EB 1C 90 "Technics"`, a 720 KB BPB 512 / 2 / 1 / 2 / 112 / 1440 / F9 / 3 / 9 / 2, a 1.44 MB one 512 / 1 / 1 / 2 / 224 / 2880 / F0 / 9 / 18 / 2, then `EB FE`) and FloppySectorRead's fallback BPB | 941 FdFormat720K / FdFormat1440K `memset` a 512-byte sector, `mov Head, a1` / `mov 0x20, d0` / `call memcpy`; FloppySectorRead `mov Head, a1` / `mov 0x200, d0` / `call memcpy` when sector 0 cannot be read; the layout is the FAT boot sector's (Microsoft, "FAT: General Overview of On-Disk Format")                               |
| `panel_700`                         | the KN6000 / KN6500 default panel memory, 0x700 bytes and 42 records (no part 0x1F), with the PMR_* macros the 0x750-byte KN7000 one already had                                                                                                                                                                  | KN6000 func_4C02FB29's memcpy loops copy its records' payloads to the record at 0x84000020 (`mov Table, d1` / `add d2, d1` / `mov 2, a1` / `add d1, a1` / `mov 0x48, d0` / `call memcpy` / `add 0x4a, d2`); the CUSTOM banks' records are 0x700 bytes apart (`../custom-data-ic21.md`)                                                 |
| `style_lists`                       | what a StyleGenre record's +4 points at: its styles, GenreStyle `{char *name, u16 *setups}` pairs ended by a pair whose setups is 0, and each style's four MusicStylistSetup numbers and 0xFFFF                                                                                                                   | 941 StyleListBoxGetItem 0x4847C216: `asl 3` / `add StyleGenreTable, a0` / `mov (4, a0), d0`, the pair's `mov (4, a0), d0`, `movhu (d0, a1), d3` four times (`cmp 4, d2`), the next pair's `mov (0xc, a0), d0` / `cmp 0, d0`; StyleSubCatHeaderBuild `mov (d0, a3), a1` / memcpy 0x10 (the name)                                        |
| `reclaim_strings`                   | the bytes of a string typed_refs took by its look alone (a guessed `Str_` label, no code naming it) are given back when a reader-walked sentinel list covers them                                                                                                                                                 | e.g. `Str_p_20` = `85 20 70 00`, the first word of a 12-byte PanelButtonDispatch record (`mov (a2), d0` / `cmp -1, d0` / `add 0xc, a2`)                                                                                                                                                                                                |
| `curated_counts`                    | a record count `data_struct_names.OPTIONS` states with its evidence, when the bound is in a callee the index rule does not follow: ChordRecogTable2, 2,048 records (was 256)                                                                                                                                      | func_4844D297 indexes it by func_4844D680's answer, an interval mask built by or-ing one of 0x01 .. 0x400 per note (its jump table, cases 0..10), or 0xFFFF (refused before the index): 0 .. 2047; the table ends 4,096 bytes on, where func_484375EA_Table starts                                                                     |
| (no switch) own symbols             | 935 / 893 read `kn7000_b935_own.sym` / `kn7000_b893_own.sym` with gen_program_s.py's override rule (`read_syms_own`: an own row replaces a ported row at its address or with its name): 935's `func_4840AE62_Table` is now `DspReadyWaitEnabled`                                                                  | the own files' rows; `DspReadyWaitOn` / `DspReadyWaitOff` store it                                                                                                                                                                                                                                                                     |
| (no switch) name-carrying macros    | the KN6000's built-in tone and voice records are `SOUND_NAME_HEAD "<name>", ...` / `VOICE_HEAD "<name>", ...`; SOUND_HEAD, VOICE_HEAD_TAIL, PMR_NAME_HEAD and PMR_NAME_TAIL are deleted (`voice_record.inc`, `floppy/tools/kd/gen_panel_macros.py` -> `panel_memory.inc`)                                         | the bytes are the same (gates)                                                                                                                                                                                                                                                                                                         |
| (no switch) the 4-bpp default cited | a bitmap with no MT_GetBitCount answer says it is drawn at 4 bpp, and why (N-c62a74fa)                                                                                                                                                                                                                            | VwUserBitmapProc 0x48418625 draws any answer but 1 and 8 with DrawBitmapSPFast16; a bitmap proc answers 0 to a message it has no case for                                                                                                                                                                                              |

Field names added by hand (`data_struct_names.py`, N-2468beef): `FlashChip` {maker_id, device_id, nsectors,
sectors} (FlashReadAutoselect compares +0 / +2 with the autoselect reads; FlashProgram128Words bounds its sector
loop with +4 and walks +8), `DiskFileHandler` {file_kind, proc} (DiskLoadDispatch hands +0 to FmmLoadFilterIsSet /
FmmCurFileHasType, compares it with 7, calls +4), `PanelTestSwitch` {test_class, test_arg} (PanelSelfTestScanEntry
switches on +0, `cmp 0xf0` .. `cmp 0xf6`, and the case uses +1), and `ChordRecogEntry` / `ChordRecogEntry2`
{chord_type, root_flags} again under the labels the two tables have had since their rename (the lookup is by the
current label, so their names had been lost).

## 2. The items

| item                               | outcome                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| L-mn10300-names-bitcount-inference | CLOSED: the comment cites VwUserBitmapProc (N-c62a74fa) instead of `[INFERENCE]`, and a default-depth bitmap's header says it is drawn with DrawBitmapSPFast16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| L-mn10300-names-data-own-syms      | CLOSED: PROFILES b935 / b893 read their `_own.sym` with gen_program_s.py's override rule; 935's DSP ready flag 0x500066DD is `DspReadyWaitEnabled` (was `func_4840AE62_Table`), 893's 0x500066D9 likewise; 893's LibLoadDescriptorTail (0x487F55CE) is past the data region, so the data has no label for it                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| N-f67b155c                         | CLOSED: gen_data_s.py tones() writes SOUND_NAME_HEAD / VOICE_HEAD with the name (the KN6000's built-in tone and voice records: 2,429 heads); SOUND_HEAD, VOICE_HEAD_TAIL, PMR_NAME_HEAD and PMR_NAME_TAIL had no caller left and are deleted (`voice_record.inc`; `gen_panel_macros.py`, which writes `panel_memory.inc`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| N-027de254                         | CLOSED: the descriptors are the support classes' value-name lists (`support_values`, section 1), read by the classes' common handler func_48431434 at +4 (the name count) and +8 (the list); typed in all seven program images (the four KN7000 builds, KN6000, KN6500, KN2400: 54 lists each), the KN2400's data_484151E0 among them. The "pointer into its own tail" was the end pair's empty name, which sits right before the list. The 107 x `01 00` "after the switch descriptors" (group record-rest) are not these: they stay with that group                                                                                                                                                                                                                                                                               |
| N-044cdbc6                         | CLOSED: what was handed only to memcpy is typed: 941's data_485BA394 (and every build's and sibling's twin, the KN2400's data_4841E3E4 too) is a FAT boot-sector head (`boot_sectors`, with the two formatter heads beside it, which had been a string "\xEB\x1C\x90Technics" and 20 opaque bytes), the KN6000 / KN6500 func_4C02FB29 / func_4C02FC99 blocks are the records of the default panel memory (`panel_700`). The strcpy / LibStrlen arguments were strings already                                                                                                                                                                                                                                                                                                                                                       |
| N-4666109a                         | BLOCKED: no static reader exists to find. Pad +0x13..+0x15 are `00 00 FF` in all 120 pads, TCMP +0x0C..+0x0F / +0x12..+0x14 / +0x1A..+0x1F zero in all 60 records, and the binders, the name getter and the copy into a user pad were read through (`../table-semantics-2026-10-29.md`). What remains is a run-time write-watch on those bytes of the MEMORY area while a pad or a composer pattern is edited, in the KN7000 MAME driver (another repository: kn7000_mame / mamedev), which no lane of this repository can run                                                                                                                                                                                                                                                                                                      |
| N-4b34dd8b                         | OPEN (smaller): PM_SET88's m008008 is one of a pair. 941 ApcSeqSliderRoute (KN6000 func_4C114272) sets parameters 0x008006 and 0x008008 from panel control 0xC2 (KN6000 0xC6, PanelCtrlValueGet; 941 latch byte 0x5006BEAD, reset to 0x80 by PanelCtrlLatchReset, written by PanelCtrlLatch32 through PanelCtrlLatch32_Table): in DEMO mode or while the sequencer plays (ApcSeqSliderOnSeq answers 0) 0x008006 := 0x7F and 0x008008 := the control, otherwise the other way round; the callers are the sequencer's play / part changes (PlayLedCtrlSeq, SetSeqPlyPart). So 0x008008 is that control's level for the song playback and 0x008006 for the rest. The control itself is not identified (which slider or pedal is wire 0xC2): next step, the KN7000 panel's control list (service manual) or the MAME driver's panel HLE |
| N-2468beef                         | OPEN (L): named by hand from their readers (section 1): FlashChip, DiskFileHandler, PanelTestSwitch and the two chord-recognition tables' fields; the census (section 3) gives the count left. Next step: the same, kind by kind, from `../mn10300-formats-probes/field_names_census.py --list`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| L-mn10300-names-kn2400-titles      | CLOSED: profile key `title_names` (KN2400: TitleNameTable 0x48414BD8, 0x140 entries); gui_ids.inc gains the 25 TT_ names the table holds for titles no RegisterTitle call names (`../kn7000-names-probes/names_kn2400_titles.py` lists the same 25), the firmware's 17 placeholders (`_TT_13e`) left unnamed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| N-61c32961                         | OPEN (not reached): the indexed form of `sentinel_lists` for func_4C11B347 / func_4861CCC5 (the list read as `(dI, aT)` with dI stepped by one, `asl2 d1` / `mov (d1, a0), d0` until -1) is still to write; what it would type is 21 bytes (KN6000) and 4 bytes (KN2400). Next step as before                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| N-fb88572c                         | OPEN (not reached): the frozen `gui_object_names.tsv` (design in `../gui-data-region/README.md`) is still to write. Next step as there                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| false-string group                 | smaller (section 4): the GenreStyle lists and setups (one-character "strings" that were a setup number's low byte), the PanelButtonDispatch records whose first byte typed_refs took for a string (`reclaim_strings`), the MILK value-name lists' empty names                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| table-tail group                   | smaller (section 4): ChordRecogTable2 (1,500 bytes) is its 2,048 records; the rest is section 4's                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

## 3. Measurements

Before: main 1345995bc's committed data directories (the base a385de42f with lane kn7000-names' regeneration of
the KN2400 and 941; `git archive`); after: this branch's, regenerated (`../mn10300-data-probes/data_stats.py --dirs
BEFORE AFTER --brief`: typed bytes from labels.sym, reader rows and opaque pieces n / bytes, offset-named fields
with a reader, bytes a BEFORE item held that no AFTER item holds):

| tree                           | typed before | typed after | change | reader rows before | reader rows after | opaque before  | opaque after | offset-named fields before | after | typed before only |
|--------------------------------|--------------|-------------|--------|--------------------|-------------------|----------------|--------------|----------------------------|-------|-------------------|
| kn7000/src/program/data        | 2,256,494    | 2,264,713   | +8,219 | 77 / 872           | 76 / 836          | 912 / 15,782   | 629 / 9,760  | 254                        | 244   | 2                 |
| kn7000/src/sp7001/program/data | 2,261,320    | 2,265,957   | +4,637 | 80 / 980           | 79 / 944          | 917 / 15,655   | 641 / 11,133 | 255                        | 246   | 0                 |
| kn7000/src/b935/program/data   | 2,257,429    | 2,262,066   | +4,637 | 83 / 1,016         | 82 / 980          | 930 / 16,322   | 654 / 11,800 | 260                        | 251   | 0                 |
| kn7000/src/b893/program/data   | 2,257,716    | 2,262,353   | +4,637 | 78 / 884           | 77 / 848          | 919 / 15,855   | 643 / 11,333 | 260                        | 251   | 0                 |
| kn6000/src/program/data        | 2,549,408    | 2,556,875   | +7,467 | 135 / 9,275        | 129 / 8,449       | 1,145 / 24,654 | 774 / 18,082 | 262                        | 255   | 2                 |
| kn6500/src/program/data        | 2,062,463    | 2,070,274   | +7,811 | 140 / 9,391        | 134 / 8,565       | 1,176 / 27,134 | 765 / 20,216 | 261                        | 254   | 0                 |
| kn2400/src/program/data        | 1,906,859    | 1,916,287   | +9,428 | 137 / 2,513        | 135 / 1,749       | 1,192 / 27,313 | 801 / 18,746 | 200                        | 194   | 0                 |
| hdsx3/src/program/data         | 484,903      | 484,906     | +3     | 34 / 211           | 34 / 211          | 40 / 386       | 40 / 386     | 37                         | 37    | 9                 |

The "typed before only" bytes: 941 2 and KN6000 2 are the second 0xFFFF after a StyleLetter's setup list
(`func_4847D083_List_29` / `StyleAlphabetTable_p4_27` held 6 bytes, the setups and two end words; the list now ends
at its first 0xFFFF, which is where StyleAlphaPageTextBuild stops); HD-SX3 9 are the tail of a 677-byte record over
`"INFO FILE"` and the 0xFF pad after it, now that string and pad. Only 941 has the ChordRecogTable2 count (its two
tables carry the names in 941 alone), hence its larger gain.

Offset-named fields with a reader (`../mn10300-formats-probes/field_names_census.py`, base a385de42f -> this branch):
941 255 -> 244, 942 255 -> 246, 935 260 -> 251, 893 260 -> 251, KN6000 262 -> 255, KN6500 261 -> 254, KN2400 200 ->
194, HD-SX3 37 -> 37 (some by the names above, some because the passes of section 1 now type records the struct
walk used to cover with offset-named fields).

**Census figures** (read-only on the merged branch, then the snapshot): `scripts/analysis/data_incbin_census.py
--compare docs/coverage/data-incbin-2026-11-06-01.json` exits 0 (nothing rose, generic 0); the new snapshot is
`docs/coverage/data-incbin-2026-11-06-02`. `scripts/analysis/doc_quality_census.py --compare
docs/coverage/doc-quality-2026-11-06-04.json`: "nothing rose" (snapshot `doc-quality-2026-11-06-05`: only the
file counts of 942 / 935 moved, one more data part each). `make semantic-score` (measured at 55d7fc5c, the
previous row 7fbdeebd): KN7000 82.57 -> 82.68, MN10300 siblings 80.86 -> 81.84, the score 95.03 -> 95.17
(its KN5000 part 96.96 -> 97.06 comes from main's merged lanes, not from this one).

**Gates** (worktree, after merging main 0e864995c; `kn7000/build/*.labels` deleted before symbols-check): `make
gate-kn7000` (35 OK lines), `make gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3` (18 OK), `make -C kn7000
symbols-check`, `make gate gate-wsa1 gate-floppy`: every one exits 0, no FAIL line.

## 4. The opaque groups

`../mn10300-data-probes/opaque_left.py` by group, base a385de42f -> this branch (bytes; the totals include the
small groups not shown):

| tree   | false-string   | table-tail     | after-string   | labelled-held   | align-pad  | record-rest | ram-widget-var | other      | total            |
|--------|----------------|----------------|----------------|-----------------|------------|-------------|----------------|------------|------------------|
| 941    | 4,304 -> 2,426 | 5,354 -> 3,556 | 2,869 -> 1,389 | 2,383 -> 1,398  | 232 -> 217 | 219 -> 219  | 128 -> 128     | 210 -> 348 | 15,782 -> 9,760  |
| 942    | 4,163 -> 2,285 | 5,358 -> 5,060 | 2,881 -> 1,389 | 2,378 -> 1,405  | 235 -> 220 | 219 -> 219  | 128 -> 128     | 210 -> 348 | 15,655 -> 11,133 |
| 935    | 4,304 -> 2,426 | 5,354 -> 5,056 | 3,417 -> 1,925 | 2,379 -> 1,406  | 232 -> 217 | 219 -> 219  | 128 -> 128     | 194 -> 332 | 16,322 -> 11,800 |
| 893    | 4,198 -> 2,320 | 5,333 -> 5,055 | 3,065 -> 1,573 | 2,171 -> 1,398  | 232 -> 217 | 219 -> 219  | 128 -> 128     | 194 -> 332 | 15,855 -> 11,333 |
| kn6000 | 2,551 -> 2,024 | 9,400 -> 5,965 | 1,597 -> 946   | 10,434 -> 8,435 | 300 -> 288 | 0 -> 0      | 128 -> 128     | 72 -> 232  | 24,654 -> 18,082 |
| kn6500 | 5,024 -> 3,979 | 8,290 -> 5,780 | 1,553 -> 902   | 11,645 -> 8,892 | 308 -> 297 | 0 -> 0      | 128 -> 128     | 16 -> 176  | 27,134 -> 20,216 |
| kn2400 | 3,707 -> 1,795 | 9,018 -> 7,483 | 3,861 -> 2,711 | 9,899 -> 6,013  | 219 -> 207 | 125 -> 125  | 4 -> 4         | 176 -> 176 | 27,313 -> 18,746 |
| hdsx3  | 133 -> 133     | 4 -> 4         | 93 -> 93       | 76 -> 76        | 10 -> 10   | 6 -> 6      | 48 -> 48       | 0 -> 0     | 386 -> 386       |

`941 other` rose by 138 bytes only because PanelSwitchClassTable's tail is now under a table named PanelTestSwitch
(the group rule reads the label); the bytes were opaque before too.

What is left, by group (941; the other builds alike, the siblings the same kinds):

- false-string (2,426): record heads an earlier pass took for a string whose reader the walk still does not reach:
  `Str_empty_285` (641 bytes after it, func_484061F9's 13-byte records), `Str_N` (336), the EUC-JP text tails.
- table-tail (3,556): the key lists of func_4C021761 / func_4C0216A3 (the loop tests +8 through a second pointer),
  func_484061F9's lists after its last pointer, TgPartEgRampBuild_Table_3 (8 x 0x66 by `mulu`), the mixer pages.
- after-string (1,389), labelled-held (1,398): bytes after a real string, and blocks a pointer holds with no reader
  the walk follows (the KN6000 / KN2400 DSP effect records at 0x4C398D0E.. / 0x48476318.. are the largest).
- record-rest (219): the 107 x `01 00` after the KN7000's switch descriptors (not N-027de254's descriptors).

The register's O- rows (`../mn10300-data2-probes/opaque_rows.py`: BEFORE the register as committed, AFTER the
census on this branch, grouped as `collect_open_items.py` does):

| id                                   | class                                 | pieces / bytes before | pieces / bytes after | bytes  |
|--------------------------------------|---------------------------------------|-----------------------|----------------------|--------|
| O-hdsx3-unknown-dump-1bf2b6          | printable non-NUL text, program flash | 3 / 157               | 3 / 157              | +0     |
| O-hdsx3-unknown-dump-274483          | binary, program flash                 | 19 / 102              | 19 / 102             | +0     |
| O-hdsx3-unknown-dump-71c25d          | 7-bit values, program flash           | 1 / 8                 | 1 / 8                | +0     |
| O-hdsx3-unknown-dump-a08889          | 7-bit values, initialised-RAM image   | 5 / 20                | 5 / 20               | +0     |
| O-hdsx3-unknown-dump-b7393d          | address-like words, program flash     | 2 / 55                | 2 / 55               | +0     |
| O-hdsx3-unknown-dump-bfbe48          | address-like words, RAM image         | 3 / 16                | 3 / 16               | +0     |
| O-hdsx3-unknown-dump-f491a3          | binary, initialised-RAM image         | 7 / 28                | 7 / 28               | +0     |
| O-kn2400-unknown-dump-1bf2b6         | printable non-NUL text, program flash | 257 / 3,397           | 150 / 2,470          | -927   |
| O-kn2400-unknown-dump-274483         | binary, program flash                 | 736 / 19,532          | 470 / 12,124         | -7,408 |
| O-kn2400-unknown-dump-337026         | printable non-NUL bytes, RAM image    | 4 / 208               | 2 / 172              | -36    |
| O-kn2400-unknown-dump-71c25d         | 7-bit values, program flash           | 104 / 1,890           | 104 / 1,890          | +0     |
| O-kn2400-unknown-dump-a08889         | 7-bit values, initialised-RAM image   | 1 / 4                 | 1 / 4                | +0     |
| O-kn2400-unknown-dump-b7393d         | address-like words, program flash     | 85 / 2,186            | 71 / 2,026           | -160   |
| O-kn2400-unknown-dump-bfbe48         | address-like words, RAM image         | 3 / 88                | 1 / 52               | -36    |
| O-kn2400-unknown-dump-f491a3         | binary, initialised-RAM image         | 2 / 8                 | 2 / 8                | +0     |
| O-kn6000-unknown-dump-1bf2b6         | printable non-NUL text, program flash | 220 / 1,781           | 130 / 947            | -834   |
| O-kn6000-unknown-dump-274483         | binary, program flash                 | 644 / 18,994          | 400 / 13,570         | -5,424 |
| O-kn6000-unknown-dump-71c25d         | 7-bit values, program flash           | 57 / 1,459            | 44 / 1,433           | -26    |
| O-kn6000-unknown-dump-a08889         | 7-bit values, initialised-RAM image   | 51 / 108              | 51 / 108             | +0     |
| O-kn6000-unknown-dump-b7393d         | address-like words, program flash     | 158 / 2,120           | 139 / 1,940          | -180   |
| O-kn6000-unknown-dump-bfbe48         | address-like words, RAM image         | 6 / 160               | 1 / 52               | -108   |
| O-kn6000-unknown-dump-f491a3         | binary, initialised-RAM image         | 9 / 32                | 9 / 32               | +0     |
| O-kn6500-unknown-dump-1bf2b6         | printable non-NUL text, program flash | 233 / 1,754           | 142 / 1,003          | -751   |
| O-kn6500-unknown-dump-274483         | binary, program flash                 | 681 / 21,240          | 397 / 15,383         | -5,857 |
| O-kn6500-unknown-dump-71c25d         | 7-bit values, program flash           | 54 / 1,777            | 41 / 1,751           | -26    |
| O-kn6500-unknown-dump-a08889         | 7-bit values, initialised-RAM image   | 51 / 108              | 51 / 108             | +0     |
| O-kn6500-unknown-dump-b7393d         | address-like words, program flash     | 143 / 2,065           | 125 / 1,889          | -176   |
| O-kn6500-unknown-dump-bfbe48         | address-like words, RAM image         | 6 / 160               | 1 / 52               | -108   |
| O-kn6500-unknown-dump-f491a3         | binary, initialised-RAM image         | 8 / 30                | 8 / 30               | +0     |
| O-kn7000-b893-unknown-dump-1bf2b6    | printable non-NUL text, program flash | 233 / 1,969           | 133 / 1,402          | -567   |
| O-kn7000-b893-unknown-dump-274483    | binary, program flash                 | 400 / 11,724          | 242 / 7,901          | -3,823 |
| O-kn7000-b893-unknown-dump-337026    | printable non-NUL bytes, RAM image    | 1 / 4                 | 0 / 0                | -4     |
| O-kn7000-b893-unknown-dump-71c25d    | 7-bit values, program flash           | 154 / 1,623           | 154 / 1,623          | +0     |
| O-kn7000-b893-unknown-dump-a08889    | 7-bit values, initialised-RAM image   | 52 / 108              | 52 / 108             | +0     |
| O-kn7000-b893-unknown-dump-b7393d    | address-like words, program flash     | 69 / 380              | 52 / 252             | -128   |
| O-kn7000-b893-unknown-dump-f491a3    | binary, initialised-RAM image         | 10 / 47               | 10 / 47              | +0     |
| O-kn7000-b935-unknown-dump-1bf2b6    | printable non-NUL text, program flash | 223 / 1,960           | 123 / 1,393          | -567   |
| O-kn7000-b935-unknown-dump-274483    | binary, program flash                 | 400 / 11,725          | 243 / 7,914          | -3,811 |
| O-kn7000-b935-unknown-dump-71c25d    | 7-bit values, program flash           | 162 / 2,066           | 161 / 2,054          | -12    |
| O-kn7000-b935-unknown-dump-a08889    | 7-bit values, initialised-RAM image   | 52 / 108              | 52 / 108             | +0     |
| O-kn7000-b935-unknown-dump-b7393d    | address-like words, program flash     | 82 / 412              | 65 / 284             | -128   |
| O-kn7000-b935-unknown-dump-bfbe48    | address-like words, RAM image         | 1 / 4                 | 0 / 0                | -4     |
| O-kn7000-b935-unknown-dump-f491a3    | binary, initialised-RAM image         | 10 / 47               | 10 / 47              | +0     |
| O-kn7000-program-unknown-dump-1bf2b6 | printable non-NUL text, program flash | 228 / 1,931           | 128 / 1,364          | -567   |
| O-kn7000-program-unknown-dump-274483 | binary, program flash                 | 402 / 11,903          | 240 / 6,804          | -5,099 |
| O-kn7000-program-unknown-dump-71c25d | 7-bit values, program flash           | 150 / 1,421           | 147 / 1,197          | -224   |
| O-kn7000-program-unknown-dump-a08889 | 7-bit values, initialised-RAM image   | 52 / 108              | 52 / 108             | +0     |
| O-kn7000-program-unknown-dump-b7393d | address-like words, program flash     | 70 / 380              | 53 / 252             | -128   |
| O-kn7000-program-unknown-dump-bfbe48 | address-like words, RAM image         | 1 / 4                 | 0 / 0                | -4     |
| O-kn7000-program-unknown-dump-f491a3 | binary, initialised-RAM image         | 9 / 35                | 9 / 35               | +0     |
| O-kn7000-sp7001-unknown-dump-1bf2b6  | printable non-NUL text, program flash | 225 / 1,915           | 126 / 1,352          | -563   |
| O-kn7000-sp7001-unknown-dump-274483  | binary, program flash                 | 404 / 11,748          | 248 / 7,957          | -3,791 |
| O-kn7000-sp7001-unknown-dump-71c25d  | 7-bit values, program flash           | 152 / 1,449           | 150 / 1,417          | -32    |
| O-kn7000-sp7001-unknown-dump-a08889  | 7-bit values, initialised-RAM image   | 52 / 108              | 52 / 108             | +0     |
| O-kn7000-sp7001-unknown-dump-b7393d  | address-like words, program flash     | 74 / 396              | 56 / 264             | -132   |
| O-kn7000-sp7001-unknown-dump-bfbe48  | address-like words, RAM image         | 1 / 4                 | 0 / 0                | -4     |
| O-kn7000-sp7001-unknown-dump-f491a3  | binary, initialised-RAM image         | 9 / 35                | 9 / 35               | +0     |

total bytes: before 143,101, after 101,456 (-41,645)

Four rows reach 0: O-kn7000-program-unknown-dump-bfbe48, O-kn7000-sp7001-unknown-dump-bfbe48,
O-kn7000-b935-unknown-dump-bfbe48 (the 4-byte RAM word after func_4848F914_Table's "PT 1".."PT 9", the rest of that
pointer table, now typed: `nv_not_ptrs`) and O-kn7000-b893-unknown-dump-337026 (its 893 twin).

## Regenerating

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides, `UNIDASM=` and
`SP7001_UPDATES=`):

1. `make -C kn7000 verify verify-sp7001 verify-935 verify-893` (the labels the KN7000 generation reads);
2. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500` (in parallel), then `hdsx3`, then `make -C
   <each> gui-map`;
3. `make -C kn7000 data-and-code-src` (fixpoint after 3 rounds here), `make -C kn7000 plugin-src`, `make -C kn7000
   gui-map`;
4. rebuild the four programs and run `gen_data_s.py --profile 941` / `b893` into a scratch directory: it matched the
   committed sources (the fixpoint holds with fresh labels);
5. `python3 -I floppy/tools/kd/gen_panel_macros.py` (panel_memory.inc without PMR_NAME_HEAD / _TAIL).

## Website page draft

(For the KN7000, KN6000 / KN6500, KN2400 program-data pages of technics-docs.)

> **The framework's value names, the disk formats' boot sectors, the style lists.** Each of the MILK framework's 54
> support classes (the integer, ID, pointer, rectangle and flag types an object's properties have) points at a list
> of value names, `{name, value}` pairs ended by an empty name: "True" / "False", the view flags `VF_*`, the colours
> `CL_*`, the borders `BD_*` ... ; the debugger's property dump turns a value into its name and back with them. The
> disk formatters' boot sectors are typed too: the jump, the OEM name "Technics" and the BIOS parameter block of a
> 720 KB disk (1,440 sectors, media 0xF9) and of a 1.44 MB one (2,880 sectors, media 0xF0), then a two-byte `jmp $`.
> The Music Stylist's genre lists now show every style with its four setups, and the eras and letters theirs. On the
> SX-KN6000 / KN6500 the default panel memory (0x700 bytes, 42 records) is typed record by record, as on the KN7000.
