# Repository audit, 2026-10-24

A read-only audit of the whole tree, run against HEAD `14aec1197`. It answers two questions:

1. Which official Technics ROMs and programs exist on this machine, and which of them are in this repo?
2. How good are the labels and comments in each tree that is in the repo?

`audit-2026-10-24.json` holds the full output of the six audit lanes and the completeness critic. That
covers every measured figure, the command that produced it, and the 20 work packages below. The lanes'
throwaway scripts are kept in `~/compartilhado/research-scratch/sessions/2026-10-24_tmp/` (commit f458821).
The figures are a snapshot taken at that HEAD. Re-measure with the scripts each lane names; do not copy
the numbers forward.

## Inventory

The `in repo` column records the state when the audit ran. The work packages below change it, and the
current state is in the root `README.md`.

| model                  | artifact                                                                       | kind           | in repo (2026-10-24)   |
|------------------------|--------------------------------------------------------------------------------|----------------|------------------------|
| KN5000                 | Main program v10 (kn5000_v10_program.rom)                                      | mixed          | fully-disassembled     |
| KN5000                 | Main program v9 (kn5000_v9_program.rom)                                        | mixed          | fully-disassembled     |
| KN5000                 | Main program v8 (kn5000_v8_program.rom)                                        | mixed          | none                   |
| KN5000                 | Main program v7 (kn5000_v7_program.rom)                                        | mixed          | fully-disassembled     |
| KN5000                 | Main program v6 (kn5000_v6_program.rom)                                        | mixed          | none                   |
| KN5000                 | Main program v5 (kn5000_v5_program.rom)                                        | mixed          | none                   |
| KN5000                 | Main program v3, v4 (kn5000_v3/v4_program.rom)                                 | cpu-code       | none                   |
| KN5000                 | Sub-CPU payload v1.42 (kn5000_subprogram_v142.rom)                             | cpu-code       | fully-disassembled     |
| KN5000                 | Sub-CPU v1.42 compressed update image (kn5000_subprogram_v142_compressed.rom)  | data           | fully-disassembled     |
| KN5000                 | Sub-CPU payload v1.41 (kn5000_subprogram_v141.rom)                             | cpu-code       | dump-only              |
| KN5000                 | Sub-CPU v1.41 compressed image (kn5000_subprogram_v141_compressed.rom)         | data           | dump-only              |
| KN5000                 | Sub-CPU payload v1.40 (kn5000_subprogram_v140.rom)                             | cpu-code       | dump-only              |
| KN5000                 | Sub-CPU v1.40 compressed image (kn5000_subprogram_v140_compressed.rom)         | data           | dump-only              |
| KN5000                 | Sub-CPU payload v1.39                                                          | cpu-code       | none                   |
| KN5000                 | Sub-CPU boot ROM IC30 (kn5000_subcpu_boot.ic30)                                | cpu-code       | fully-disassembled     |
| KN5000                 | Table data ROM IC3 (even) + IC1 (odd), and the interleaved kn5000_table_data.r | mixed          | partially-disassembled |
| KN5000                 | Custom data flash IC19 (kn5000_custom_data_rom.ic19)                           | data           | fully-disassembled     |
| KN5000 (synthetic)     | kn5000_custom_data_with_preset.ic19                                            | data           | none                   |
| KN5000 / HD-AE5000     | HD-AE5000 v2.06i (hd-ae5000_v2_06i.ic4)                                        | mixed          | fully-disassembled     |
| KN5000 / HD-AE5000     | HD-AE5000 v2.01i (hd-ae5000_v2_01i.ic4)                                        | mixed          | none                   |
| KN5000 / HD-AE5000     | HD-AE5000 v1.15i (hd-ae5000_v1_15i.ic4), and the unversioned hd-ae5000.ic4     | mixed          | none                   |
| KN5000 / HD-AE5000     | HD-AE5000 v1.10i (hd-ae5000_v1_10i.ic4)                                        | mixed          | none                   |
| KN5000                 | Rhythm data ROM IC14, descrambled (kn5000_rhythm_data_rom.ic14)                | data           | none                   |
| KN5000                 | Rhythm data ROM IC14, raw read with address lines swapped (kn5000_rhythm_data_ | data           | none                   |
| KN5000                 | Waveform ROM IC307 (kn5000_waveform_rom.ic307)                                 | data           | none                   |
| KN5000                 | Waveform ROMs IC304/IC305/IC306                                                | data           | none                   |
| KN5000                 | Official system update v10 installer kn5-10.zip / KN5VA.exe (HKMSPRG.SLD)      | floppy-program | none                   |
| KN5000                 | kn5000_v10_disk.img (+ kn5000_v10_disk.mfi): v10 update floppy image           | floppy-program | none                   |
| KN5000 / HD-AE5000     | Official HD-AE5000 v1.15 update installer ae5-115.zip / AE5-115.exe (HKEXTROM. | floppy-program | none                   |
| KN5000                 | Floppy idd5000 (Initial Data disk, factory default)                            | floppy-data    | none                   |
| KN5000                 | Floppies ca5000r, ca5000w, ca5001-ca5010, mix5000 (style/wallpaper/demo librar | floppy-data    | none                   |
| KN7000 (not KN5000)    | KN7000/floppy-archive/*.zip (Bosm, Brow, CAN, CNAT, MAME, Nearn, Quie)         | floppy-data    | none                   |
| KN5000 (homebrew)      | Homebrew run sets custom_kn5000_roms/{anotherworld,apploader,mines}            | mixed          | none                   |
| KN5000 (PC software)   | HD-TechManager5000 v1.20 (HDTMD120.EXE/.W02, setup.EXE/.W02, ppkn50.dll)       | cpu-code       | dump-only              |
| none (PC hardware)     | at_keybc.zip, ct486.zip, et4000.zip, kb_ms_natural.zip                         | unknown        | none                   |
| SX-WSA1R               | OS v2 EPROMs A/B/C/D (wsa1_os_v2.ic12/ic13/ic28/ic21 = QSIGCWSA1AX/BX/CX/DX)   | mixed          | fully-disassembled     |
| SX-WSA1R               | wsa1_flop softlist: dance, demo1, etec, giontop, gjs1, mcompos, myset, qsdisk, | floppy-data    | none                   |
| SX-KN7000              | Program build 941 (v1.6) + Table build 84 (default target)                     | mixed          | byte-exact-skeleton    |
| SX-KN7000              | Program build 942 / Table build 83 (SP7001 PLUG-iN) + BASEEXT.XAP              | mixed          | byte-exact-skeleton    |
| SX-KN7000              | Program build 935 (v1.5)                                                       | mixed          | none                   |
| SX-KN7000              | Program build 893 (v1.3) + Table build 80, read from Felipe's own unit         | mixed          | none                   |
| SX-KN7000              | Program build 929 (v1.4), upper half only                                      | mixed          | none                   |
| SX-KN7000              | IC18 rhythm ROM C3CBND000046 (4 MB), first 64 KB = instrument boot ROM         | mixed          | none                   |
| SX-KN7000              | IC19 picture ROM C3CBMD000098 (2 MB)                                           | data           | fully-disassembled     |
| SX-KN7000              | Wave ROMs C3CBQD000001-4 (IC204, IC203, IC208, IC207), 16 MB each              | data           | none                   |
| SX-KN7000              | Custom-data images 01ctmini/01-04custm1-8.ic21 (9 x 1,966,080 B) + idd7000 sma | data           | none                   |
| SX-KN7000              | kn7000_flop softlist: ca7001, custom1, custom2, idd7000, organs, scd7000       | mixed          | fully-disassembled     |
| SX-KN6000              | Program IK1.SLD + IK2.SLD (v7.1), kn6000_program_even/odd.rom                  | cpu-code       | none                   |
| SX-KN6500              | Program IKV1.SLD + IKV2.SLD (v1.3), kn6500_program_even/odd.rom                | cpu-code       | none                   |
| SX-KN2400 / SX-KN2600  | Program LKG1.SLD + LKG2.SLD (v1.1), kn2400_program_even/odd.rom (KN2600 = same | cpu-code       | none                   |
| SX-KN6000              | kn6000_flop softlist (21 disks: ca6000p/s, ca6001-ca6010, ca6dim, ca6fp01-04,  | mixed          | fully-disassembled     |
| HD-SX3 / HD-SX6 (KN600 | hd-sx3_v1_1.bin, XAPR plug-in flash image                                      | cpu-code       | none                   |
| SX-KN1500              | IC15 mask ROM QSIGT3C16079 (technics_qsigt3c16079_5y68-j079_japan_9649eai.ic15 | mixed          | none                   |
| SX-KN6000 / SX-KN6500  | 01ctmini.ic18 (custom data) and kn6000/kn6500_table_fontph.rom                 | data           | none                   |
| (tooling) kn7000_extra | kn7000_extract.py, name_extract_nul.py, image_extract.py, rom_split_evenodd.py | unknown        | none                   |

The audit treats three groups as out of scope for a byte-exact source tree, for now:

- **Data-only floppies.** All 14 KN5000 disks, the 9 WSA1R disks, and every KN6000/KN7000 disk except
  the Style Convert disks hold no code. The Style Convert converters are already disassembled, in
  `kn7000/src/cnv/`.
- **x86 PC programs.** These are HD-TechManager5000 and the SongManager & AudioRecorder installers.
- **The KN1500 IC15 dump.** It is defective: 4 of its 8 blocks of 256 KiB have every odd byte 0xFF, so
  it needs a re-dump first.

## Work packages, from the completeness critic

| id   | work package                                                                               | size                                     |
|------|--------------------------------------------------------------------------------------------|------------------------------------------|
| WP01 | Remove repo hazards (merge driver, llvm-convert-all, website targets, stale CLAUDE.md path | S (3-4 h)                                |
| WP02 | Measurement first: doc-quality census, kn7000 in semantic_score, fresh census snapshot     | S-M (1 day)                              |
| WP03 | KN5000: propagate v10 routine headers to v9/v7 mechanically                                | S (2-4 h + review list)                  |
| WP04 | KN5000: apply the pending naming proposals and harmonize                                   | S (about 2 h for the pending files); M f |
| WP05 | KN5000 v8: the fourth main-program build                                                   | S (2-3 h)                                |
| WP06 | table_data: round-trip the six FTBMP feature-demo BMPs (318,468 B of verbatim debt)        | S (2-4 h)                                |
| WP07 | KN5000 v7 catch-up: bitmaps, transplants, fall-through bytes, .Lc_ locals                  | M ((a) 1 h, (b) 4-8 h, (c) 10-20 h)      |
| WP08 | kn7000 generator: symbolic output, then convert everything                                 | M (2-4 days)                             |
| WP09 | kn7000 table.s: type the directory and extract the JPEGs                                   | S-M (1 day)                              |
| WP10 | WSA1 doc refresh and toolchain record                                                      | S (3 h)                                  |
| WP11 | WSA1: respell 12,350 byte-emitter macros as native instructions                            | M (1-2 days)                             |
| WP12 | WSA1: split the monolithic prom_a/prom_b sources into subject files                        | M-L (2-3 days)                           |
| WP13 | WSA1 naming waves: T_ slots, sub_ routines, display-list and typed-data objects, headers   | L (about 15-20 lane-days in total)       |
| WP14 | KN7000 additional builds: IC18 boot ROM, table 80, program 935                             | (a) M (2-3 days); (b) S (1 h); (c) M (1- |
| WP15 | MN10300 siblings: KN2400/2600, KN6000, KN6500, HD-SX3 skeletons, then conversion           | S per skeleton (half a day); M-L per mod |
| WP16 | KN5000 routine headers (v10 first, then propagate)                                         | L (100+ agent-hours)                     |
| WP17 | KN5000 symbolization: RAM addresses, HD-AE5000 locals, C fields, KNOWN-B                   | L ((a) 40-60 h, (b) 4 h, (c) 15-20 h, (d |
| WP18 | KN5000 older and extra versions: sub-CPU v141/v140, HD-AE5000 v1.10/v1.15/v2.01, program v | S for the gate; L per tree (v141 and v2. |
| WP19 | Issue tracker and stray-file triage                                                        | S-M (half a day to a day)                |
| WP20 | Out-of-gate programs: DSP microcode ISAs, KN1500, PC software (decision and research)      | L / blocked                              |

Each package's scope, files, conflicts with other packages, gate and value are in the JSON, under
`critic.work_packages`.

## Policy decision recorded for this work

The repo has a public GitHub remote. New byte-exact targets (KN5000 v8, the KN7000 extra builds, and the
MN10300 siblings KN2400/KN6000/KN6500/HD-SX3) therefore follow the kn7000/ convention. Their reference
image is git-ignored and regenerated from the manufacturer's update installers or the private romset,
and the repo records its SHA-1. The KN5000 and WSA1R dumps that were already committed stay as they
are. The owner can revisit this.
