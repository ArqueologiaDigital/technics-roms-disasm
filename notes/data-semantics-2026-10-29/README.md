# Data semantics, 2026-10-29

The owner's goal, set 2026-10-29: describe all the data semantically, including the dumps that hold only
data, which the 2026-10-24 audit had left out of scope (`notes/repo-audit-2026-10-24/README.md`). *"Ensure any data
block in the source is only left as a generic binclude if there's no other better semantic representation
for it."*

## The instrument

`scripts/analysis/data_incbin_census.py` counts every `.incbin` / `.incbin_range` per tree and puts each one in a
class:

- **generated**: compiled C, or a committed generator from committed source;
- **media**: a self-describing file such as a JPEG or a BMP;
- **opaque**: declared with `census: opaque -- <kind>: <why>`, with a mandatory reason;
- **generic**: anything else.

The goal is generic = 0 for every tree. An opaque declaration names why no better form exists. Its docstring
defines the rules. Snapshots go to `docs/coverage/data-incbin-<date>-NN.{txt,json}`.

Baseline, before this work (2026-10-29, at b58b8f696; generic entries / bytes):

| tree              | generic n | generic bytes |
|-------------------|-----------|---------------|
| kn5000-v10        | 8         | 4,928         |
| kn5000-v9         | 8         | 4,928         |
| kn5000-v7         | 8         | 4,928         |
| kn5000-v6         | 13        | 5,130         |
| kn5000-v5         | 12        | 4,949         |
| kn5000-tabledata  | 69        | 772,289       |
| kn5000-customdata | 11        | 639,296       |
| kn7000-program    | 3         | 2,563,794     |
| kn7000-table      | 447       | 2,560,580     |
| kn7000-sp7001     | 704       | 5,176,151     |
| kn7000-b80        | 2         | 4,064,860     |
| kn7000-b893       | 3         | 2,607,409     |
| kn7000-b935       | 3         | 2,602,613     |
| kn2400            | 446       | 1,993,350     |
| kn6000            | 323       | 2,630,724     |
| kn6500            | 327       | 2,140,036     |
| hdsx3             | 30        | 533,544       |

The dumps with no tree at all are not in that table:

- KN5000: waveform ROM IC307 (4 MB) and rhythm ROM IC14 (4 MB).
- KN7000: the four wave ROMs (4 x 16 MB), the rhythm ROM IC18 beyond its 64 KB boot ROM, and the nine custom-data
  images (`*.ic21`).
- KN6000 / KN6500: `01ctmini.ic18`.
- The 50 softlist floppies: KN5000 14, WSA1 9, KN6000 21, KN7000 6.

## Conventions every lane follows

1. **Representation, best first.**
   1. Typed records: labels, `.byte` / `.short` / `.long` with symbolic pointers (`.long Rec - Base`),
      one macro per record type whose parameters name the fields, and strings as `.ascii`.
   2. A committed generator from committed, human-readable source (YAML / JSON / MIDI / text), marked
      `census: generated -- <tool>`.
   3. A standard media file.
   4. Declared opaque, with its reason.
2. **No bulk dump bytes in git.** The repo is public. Reference images are git-ignored and copied from the
   private romsets with a SHA-1 check in the Makefile: kn7000's convention, also used for KN5000 v8/v6/v5. A
   payload with no better form is an `.incbin` with skip and count, or an `.incbin_range`, of that reference.
   It is labelled per item, and its comment says what the item is. Typed tables in the source follow the
   precedent of the committed disassembly. Felipe's own instrument data (the IC21 read of his KN7000) stayed out
   of the trees until 2026-10-31, when the owner decided to add it: `kn7000/src/ic21own/` (lane ic21-own,
   `kn7000/notes/ic21-own/README.md`), its reference copied git-ignored like the others.
3. **Byte identity.** Every new image is rebuilt and gated, and wired into its model's gate and `make gate-all`.
4. **Evidence.** Every claim about a field's meaning cites the firmware code that reads it (address and label),
   or the probe that measured it. Probes are committed beside the notes they back, with a README.

## Lanes (wave A)

| lane             | scope                                                                     |
|------------------|---------------------------------------------------------------------------|
| kn5000-waveform  | IC307: directory, parameter records, one labelled PCM item per wave       |
| kn5000-rhythm    | IC14 (descrambled): signature blocks, program blocks, whatever follows    |
| kn7000-wave      | IC203/204/207/208                                                         |
| kn7000-ic18      | IC18 beyond the boot ROM: "Technics Rhythms" header, 220-style directory  |
| customdata       | KN7000 `*.ic21` x 9, KN6000/KN6500 `01ctmini.ic18`                        |
| floppy-kn5000    | the shared FAT12 floppy tree and generator; the 14 KN5000 disks           |
| floppy-others    | WSA1, KN6000 and KN7000 disk file formats; their disks on the framework   |
| kn5000-existing  | table_data, custom_data and the maincpu trees' generic includes           |
| kn7000-table     | table 84's generic segments, then tables 83 and 80                        |
| gui-kn5000       | the NAKA GUI C of v10, then v9/v7/v6/v5: readable at a glance; menu map   |
| gui-hdae5000     | the HD-AE5000 GUI, v2.06i and v2.01i                                      |
| gui-kn7000       | program 941's data region, GUI first; then the other program builds      |
| gui-wsa1         | the SX-WSA1R's pages, menus, field editors and display lists              |

The four `gui-*` lanes answer the owner's second request, the same day: *"The entire set of GUI data
structures must also be semantically described. One should be able to easily grasp all the menus, submenus,
screens, GUI widgets, etc, just by glancing at the source code. Use macros or high-level C data structures to
represent them cleanly and effectively."* Their acceptance test is `GUI-BRIEF.md`.

Each lane's outcome and open items are added below as lanes merge.

## Progress (2026-10-29, at c6630b0d7)

Every merge below was followed by its model's gate on main, all green: `make gate`, `gate-wsa1`, `gate-kn7000`,
`gate-kn6000` and `gate-floppy`.

| lane            | outcome                                                                                                   |
|-----------------|-----------------------------------------------------------------------------------------------------------|
| kn7000-wave     | 4 wave ROMs from `kn7000/src/wave/`: directory and records typed, 3,682 recordings opaque PCM (66.3 MB)   |
| kn5000-waveform | IC307 from `waveform/`: directory and records typed, 1,413 waves opaque PCM (4.17 MB); class 6 = page 2  |
| kn5000-rhythm   | IC14 from `rhythm_data/`, no `.incbin`: 202 style records, 28,400 tracks; A19/A21 raw-read check        |
| kn7000-ic18     | all of IC18 typed, no `.incbin`: 169 styles, every event one per line (`verify-ic18-full`)               |
| kn5000-existing | every KN5000 tree generic 0; HELP databases as text; custom-data style banks typed (format 2)           |
| floppy-kn5000   | `floppy/` FAT12 framework; 14 KN5000 disks, generic 0, panel/sound/song fields named                     |
| floppy-others   | 36 WSA1R/KN6000/KN7000 disks, generic 0; zlib 1.0.4 and 'J KD' LZSS byte-exact; WSA1R .TM named          |
| customdata      | 9 KN7000 + 1 KN6000 custom-data banks typed; .AST rebuilt; residue typed (opaque 4,179 B)               |
| kn7000-table    | tables 84 and 80 generic 0: 439 pictures as PNG, styles and pads typed, 'JK' voice archive typed       |
| gui-kn5000      | NAKA GUI C, v10..v5: classes, links, geometry, values by name; menu map; 130/211 titles with a path      |
| gui-hdae5000    | the HD-AE5000 GUI as nested class macros, links computed from nesting; captions; menu map               |
| gui-wsa1        | 9,027 display-list records and 3,558 key-map entries as macros; 0 numeric pointers/variables; menu map  |

Still generic on the census (entries / bytes):

| tree           | generic n | generic bytes | owner                                                         |
|----------------|-----------|---------------|---------------------------------------------------------------|
| kn7000-program | 3         | 2,563,794     | lane gui-kn7000 (program 941's data region, GUI first)        |
| kn7000-sp7001  | 6         | 2,646,270     | program 942's region (gui-kn7000 step 4); plug-in GUI tables  |
| kn7000-b893    | 3         | 2,607,409     | gui-kn7000 step 4 (ports from 941)                            |
| kn7000-b935    | 3         | 2,602,613     | gui-kn7000 step 4                                             |
| kn2400         | 446       | 1,993,350     | wave B: the MN10300 siblings, after gui-kn7000's tooling      |
| kn6000         | 323       | 2,630,724     | wave B                                                        |
| kn6500         | 327       | 2,140,036     | wave B                                                        |
| hdsx3          | 30        | 533,544       | wave B                                                        |

Typed but not yet named: fields that keep offset names because no reader was traced. They include the
KN6000/KN7000 panel-memory and sound-record fields, the 'JK' archive's tone heads, units and elements, and the
`.SQT` heads. Lane kn67-field-names is on those.

## Final state (2026-10-30, `docs/coverage/data-incbin-2026-10-30-01`)

The lanes merged after c6630b0d7, each followed on main by every gate (`make gate`, `gate-wsa1`,
`gate-kn7000`, `gate-kn6000`, `gate-kn6500`, `gate-kn2400`, `gate-hdsx3`, `gate-floppy`,
`make -C kn7000 symbols-check`), all exit 0, the last run with every `kn7000/build/*.labels` seed deleted:

| lane             | outcome                                                                                                     |
|------------------|-------------------------------------------------------------------------------------------------------------|
| gui-kn7000       | KN7000 program data regions typed, GUI first: 8,509 widget records, menu map (`verify-gui-map`)             |
| kn67-field-names | KN6000/KN7000 panel-memory, song-event and sound-record fields named from their readers                     |
| sib-kn6000       | KN6000 / KN6500 data regions typed with the KN7000 tools (profiles); GUI and menu maps                      |
| sib-kn2400       | KN2400/KN2600 and HD-SX3 data regions typed; 90 KN2400 function names fixed                                 |
| kn7000-data-rest | KN7000 data typed from the code that reads it (`data_readers.py`); generic 793 KB -> 17 KB per build        |
| siblings-final   | the reader passes on the four siblings: Music Stylist setups, chord tables, hash tables, KN6500 panel banks |
| kn7000-final     | the reader walk follows stack slots, joins and returns; resource-id trie; SP7001 plug-in GUI by class       |

Every tree outside the table below is generic 0. Generic n / bytes, with the opaque declarations beside them
(opaque here is data that no instruction reads, found by the reader walk, not PCM or compressed payloads):

| tree           | generic n | generic bytes | opaque n | opaque bytes | what is left                                                   |
|----------------|-----------|---------------|----------|--------------|----------------------------------------------------------------|
| kn7000-program | 177       | 2,948         | 4,298    | 82,196       | switch records pointing into their own tail; RAM-copied tables |
| kn7000-sp7001  | 179       | 3,044         | 4,321    | 80,480       | as kn7000-program (program 942)                                |
| kn7000-b935    | 179       | 3,044         | 4,309    | 83,003       | as kn7000-program                                              |
| kn7000-b893    | 176       | 2,944         | 4,303    | 81,886       | as kn7000-program                                              |
| kn6000         | 380       | 18,810        | 3,336    | 79,522       | blocks read but untyped, largest 5,207 B at 0x4C1A04AC         |
| kn6500         | 386       | 18,930        | 3,346    | 83,667       | as kn6000                                                      |
| kn2400         | 431       | 18,853        | 5,048    | 197,205      | effect-DSP-like streams (20 KB at 0x4853C5BE) nothing reads    |
| hdsx3          | 40        | 266           | 101      | 3,133        | small pieces                                                   |

Each remaining generic block has a reader that no pass turns into a type yet. Each opaque one is declared
with the reader search that found nothing (`kn7000/notes/data-final/README.md`, its probe
`opaque_holders.py`, and `kn6000/notes/siblings-data-final/README.md`). The large opaque totals elsewhere
(4 MB of KN5000 PCM, 66 MB of KN7000 PCM) are wave samples, one labelled item per recording.

Open items:

- the KN2400's two Music Stylist setup lists: the KN2400's and the KN2600's, chosen by bits at 0x98070000?
- the KN6000 sound hash tables' payload beyond their first field; the KN2400 effect blocks' format;
- `KssBgScreen`'s `image_id` and `icon` in the SP7001 plug-in, probably the main program's resource ids;
- the KN7000 demo-song streams are u8 rows, really 4-byte events;
- recursive structures other than the resource-id trie are typed one level deep;
- HD-AE5000 v1.15i and v1.10i still have no tree. Resolved 2026-10-30 (lane hdae-v1, merge b84f732aa):
  `hdae5000_v1_15i/` and `hdae5000_v1_10i/` are byte-identical and in `make gate`, generic 0
  (`docs/coverage/data-incbin-2026-10-30-04`); `notes/hdae5000-versions-2026-10-24/README.md`.

## Generic 0 (2026-10-30, `docs/coverage/data-incbin-2026-10-30-02`)

Lane generic-zero took the eight trees above to generic 0, in the generators (`gen_data_s.py` pass
`reader_rows`, `gen_image_s.py --rows`), with no new opaque declaration. Every tree in the census is now
generic 0. What the last pieces became (`kn7000/notes/data-final/README.md` and
`kn6000/notes/siblings-data-final/README.md`, sections "generic-zero"; probe
`kn7000/notes/data-final-probes/reader_rows_stats.py`):

- the KN7000 30-byte "switch records" were records whose first bytes an earlier pass had taken for short
  strings; `record_start()` stops that, and they are typed (`REC_func_484C01F1_Result`, resource-id-trie
  leaves, the SysEx each points at); the same fix types `func_4C02CA6A_Records_p0` (KN6000; `func_4C02CBDA_Records_p0` on the KN6500) and
  `func_5014A95C_Records_p0` (KN2400);
- every other piece that some instruction reads is written as rows at the reads' width and signedness
  (`tab_u8` ... `tab_u32`), address words as `.long Label` / `Label+N`, with a header naming the readers;
  most are blocks whose address the code only passes to a routine, so the callee decides the layout;
- the KN6000 / KN6500 code file's two `.incbin_range`s (115 + 586 B) are typed: `FirmwareVersionByte`, the
  kernel's version string, `KernelServiceHash`, `KernelRamLayout`, `KernelParams`, and its two interrupt
  dispatchers as code;
- the KN2400's `RamCodeTrailer` has a reader after all (`func_4870587E`); its notes are corrected.

Opaque fell with it (KN7000 ~82 KB -> ~64 KB per build, KN6000 79,522 -> 70,137, KN6500 83,667 -> 74,371):
bytes declared unread turned out to be record parts. Every gate passed on main after the merge with every
`kn7000/build/*.labels` seed deleted.

Left open: the reader walk does not follow an argument into the callee, so the reader-row blocks keep the
reader's widths rather than the callee's layout.

Resolved by lane callee-walk (2026-10-30, `kn7000/notes/callee-walk/README.md`): the walk follows register
and stack arguments (a caller's (N, sp), N >= 16, is the callee's (N + frame, sp)) into the routine and the
routines it hands them on to, and the siblings' walk also follows address joins, return sets and jump-table
cases; a block a routine is handed is a `REC_<routine>_Arg<slot>` record of what it reads (micro-ITRON's
`T_CTSK` for cre_tsk).  Measured against main 2a7b45be5, address-only reader-row pieces fell KN7000 941
50 -> 39, KN6000 339 -> 151, KN6500 345 -> 156, KN2400 380 -> 123, HD-SX3 30 -> 25; each one left says why in
its header (the routine stores the pointer, a library routine, or the address reaches no call the walk follows).

Resolved by lane code-island (2026-10-30, `kn7000/notes/code-island/README.md`): KN7000 `func_487B8E34` and
the opaque pieces after it were the MILK kernel's flash tail, 1,113 bytes of code between the data region
and the library image (KernelInit, KernelWaitRelease, whose call entry `func_487B8E34` was, three `retf`
hooks, KernelStart, ...).  `gen_program_s.py` (TAIL_CODE) now finds that code from the calls and jumps that
land in the data region and emits it as instructions in all four program builds; `gen_data_s.py` ends the
data region where it starts.  `func_4C03B799_Table` was one halfword (`KernelParams + 0x16`, func_4C03B799
reads no other) and two unread ones; its entries [3] on were KernelInit's code.  The siblings' 278
`.byte`-escaped instructions are instructions too (`gen_image_s.py`).

## Standalone media (2026-10-30, `docs/coverage/data-incbin-2026-10-30-03`)

At the owner's request ("Media: pictures and PCM ... standalone files that could be opened by the user on
normal media viewers / sound apps"), lane media-files (`notes/media-files-2026-10-30/README.md`) made every
picture and PCM recording a standalone PNG / JPEG / BMP / WAV file that a committed lossless converter turns
back into the ROM bytes. The census counts such includes as `generated`, with the media file named in the
marker, in its "from media" column. Opaque pcm fell from 5,095 items / 70,490,064 B to 0. The WAVs are not
committed (public repo): `make waveform-wav` and `make -C kn7000 wave-wav` write them, git-ignored, from the
reference images, and the build reads the WAVs. Snapshot `-04` adds the two HD-AE5000 v1 trees: 38 trees,
generic 0 in each.
