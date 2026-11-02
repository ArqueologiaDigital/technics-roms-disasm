# Probes of lane mn10300-names (2026-11-02)

Read-only scripts behind the figures in `../mn10300-names/README.md` and the notes it names.
Each script's docstring says what question it answers, which signal it reads and how to run it;
the table gives the question in short and where its answer is written.  They read only the
git-ignored reference images (`baserom/`), the generated sources and the symbol files.  Those
that decode code need `UNIDASM=/path/to/unidasm` (MAME's).  Run from `kn7000/` unless the
docstring says the repo root.

| probe                                 | question it answers                                                                                | answer in                                        |
|---------------------------------------|----------------------------------------------------------------------------------------------------|--------------------------------------------------|
| `names_reflection_table_dump.py`      | how gen_symbols.py pairs the reflection table that holds a name; do its two arrays have one length | `../mn10300-names/README.md` (N-01128b1c)        |
| `names_kn2400_ram_tables.py`          | does any KN2400 reflection table name a procedure in its RAM-linked range (0 tables)               | `../../../kn2400/README.md` (N-e7ed1928)         |
| `siblings_kn2400_ram_copy_table.py`   | what RamSectionsCopy copies from RamCodeTrailer, and where to                                      | `../../../kn2400/notes/data-region/README.md`    |
| `siblings_kn6000_compconn_bitmaps.py` | which pictures the KN6000's four unnamed bitmap procedures answer, who draws them                  | `../../../kn6000/notes/data-region.md`           |
| `siblings_kn6000_voice_readers.py`    | which of voice_record.inc's field readers the KN6000 has as the same code                          | `../../../kn6000/notes/data-region.md`           |
| `rhythm_style_record_readers.py`      | does any reader of a built-in style record (941, KN2400, KN6000, KN6500) read +0x89                | `../ic18-rhythm-rom.md`                          |
| `rhythm_count_block_readers.py`       | which bytes of the "Technics Rhythms" count block are read                                         | `../ic18-rhythm-rom.md`                          |
| `rhythm_drum_kit_keys.py`             | what each drum key of the kits is called; does one key layout hold across the kits                 | `../ic18-rhythm-rom.md`                          |
| `rhythm_style_semantics.py`           | the style fields 941's code gives a meaning to: slots, halves, gate, rule, set-up, units           | `../ic18-rhythm-rom.md`                          |
| `songtable_zzzj.py`                   | what the 220 'ZZZJ' records and their eight entries select (the SOUND ARRANGER)                    | `../table-semantics-2026-10-29.md`               |
| `songtable_part_more.py`              | part_more's field order; does any data disagree with "never used"                                  | `../table-semantics-2026-10-29.md`               |
| `songtable_pad_fields.py`             | the pad / TPAD / TCMP head bytes' readers; the byte after the last built-in pad                    | `../table-semantics-2026-10-29.md`               |
| `songtable_demo_l.py`                 | does the Feature Demo ever ask for the '27\n' JPEG placeholders                                    | `../table-semantics-2026-10-29.md`               |
| `songtable_demo_tempo.py`             | why the demo songs open with tempo 250                                                             | `../presentation-control-probes/song-records.md` |
| `songtable_m3_set_kinds.py`           | what setting M3 id 0x000080 (panel-memory number) does                                             | `../presentation-control-probes/song-records.md` |
| `songtable_sysex_rx.py`               | the type-4 Technics SysEx handler's messages; the M3 source of an incoming SysEx                   | `../presentation-control-probes/song-records.md` |
| `songtable_song_ids.py`               | the song-record event ids listed as unknown, joined with their parameter records and callers       | `../presentation-control-probes/song-records.md` |
| `ramgui_ramrefs.py`                   | is a work-RAM span referenced by any build (941, 942 + plug-ins, 935, 893), and what bounds it     | `../work-ram-map.md`                             |
| `ramgui_reset_layout.py`              | each build's boot stack, .data and .bss as its reset code sets them up                             | `../work-ram-map.md`                             |
| `ramgui_userhp_boxes.py`              | the true W x H of each USER HP preview picture, from the HOME PAGE part's view                     | `../table-semantics-2026-10-29.md`               |
| `oldbuilds_dsp_hostport_match.py`     | 935 / 893's DSP host-port block against 941's, routine by routine                                  | `../older-program-builds.md`                     |
| `oldbuilds_b893_func_census.py`       | 893's func_ labels by class (941 twin unnamed / named, near twin, own)                             | `../older-program-builds.md`                     |
| `oldbuilds_ported_ram_check.py`       | do ported short routines touch the same RAM in 893 as in 941 (finds mis-ported names)              | `../older-program-builds.md`                     |
| `oldbuilds_baseext_indirect_calls.py` | what BASEEXT.XAP's indirect calls reach (MILK methods, export table, KssContext, vtables)          | `../sp7001-build-diff.md`                        |

The IC18 boot ROM's probe is `../ic18-boot-rom-probes/ic18boot_xref.py`; the wave ROMs' are in
`../wave-roms-probes/` (`wave_*.py`).
