# Wave ROM probes (2026-10-29)

The scripts behind `../wave-roms-2026-10-29.md`. They read the four chip images from the private romset
(`$KN7000_WAVE_DIR`, default `~/compartilhado/technics_romsets/kn7000`, read-only) and print numbers only:
no ROM data is written. numpy is needed. Each runs in about a second; the `wave_*` probes of 2026-11-02 take
up to 9 s, and the ones marked "from `kn7000/`" also read the git-ignored `baserom/kn7000_table.rom` and
`baserom/kn7000_wave_*.bin` that `make` writes, and the 'JK' archive source `src/table/voices/internal_archive.s`.

| script                  | question it answers                                                                                                                                                                                                                                 | run                                                 |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| `wavestream.py`         | (library) joins a pair into its stream, reads a page's directory and a record                                                                                                                                                                       | imported by the others                              |
| `layout_probe.py`       | what each 2 MiB page holds (entries, 8-bit entries, recordings, record words, first recording, end fill), and do the rules R1-R8 the source relies on hold everywhere                                                                               | `python3 layout_probe.py`                           |
| `loop_probe.py`         | do the records' LOOP_START / LOOP_END marks, counted in granules of 2^(K+4) samples, fall where the data repeats its loop's first 32 samples after the end (and with L/2, 2L as controls)                                                           | `python3 loop_probe.py`                             |
| `format_probe.py`       | does directory word P bit 3 mean "two 8-bit samples per word" (lag-1 correlation as 8-bit against as 16-bit, per recording)                                                                                                                         | `python3 format_probe.py`                           |
| `wave_page_order.py`    | could a permutation of whole pages hide in the dump: how many page orders let every one of the 5,215 tone-database zones name an existing entry, and for those left, which keeps each sound's recordings falling in period as its zones rise in key | `python3 -I wave_page_order.py` (from `kn7000/`)    |
| `wave_reverse_entry.py` | what is `Main_P00_E0AF` (P bit 9 set): what its B points at, how it relates to entry 0x0AE, and which sounds play the two                                                                                                                           | `python3 -I wave_reverse_entry.py` (from `kn7000/`) |
| `wave_record_extent.py` | where does each recording end (every record word is a run of granules, a value below 0x80 one granule), what lies between recordings, which starts are alternate starts into another recording                                                      | `python3 -I wave_record_extent.py`                  |
| `wave_split_list.py`    | what the split list belongs to: one granule per value, how alike those granules are, and how the values of two entries over the same recording differ with their keys                                                                               | `python3 -I wave_split_list.py` (from `kn7000/`)    |
| `wave_port_readers.py`  | which instructions of program 941 touch the TG ports, at which offset: can any firmware code read the wave ROMs besides the service checksum                                                                                                        | `python3 -I wave_port_readers.py`                   |

## The signals, and the results of 2026-10-29

- `layout_probe.py`: R1-R8 hold for all 32 pages and all 3,974 entries. The per-page table is copied
  into the notes and into the header of `src/wave/main.s` / `sub.s` (which `tools/gen_wave_s.py` computes
  itself and checks again).
- `loop_probe.py`: for each entry whose record has both marks, PASS = the samples `[le, le+32)` equal
  `[ls, ls+32)` (16-bit entries: words; 8-bit entries: bytes). Main 571 of 577, sub 374 of 377. With the
  granule halved or doubled: 0 of 577 / 0 of 563 and 0 of 377 / 1 of 370. So the segment length
  (256 - value) x 2^(K+4) samples, the two flags and the granule code K are what the data says.
- `format_probe.py`: per recording, PASS = it correlates better as 8-bit iff P bit 3 is set.
  Main: 4 of 1,805 bit-3-clear recordings read better as 8-bit, 419 of 423 bit-3-set ones do; sub:
  0 of 916 and 510 of 514. The few exceptions are short or noise-like recordings, where neither
  reading correlates much.

## The results of 2026-11-02 (lane mn10300-names, agent `wave`)

- `wave_page_order.py`: of the 16! page orders, exactly one (the dump's) lets every MAIN zone name an existing
  entry; for SUB two do, the dump's and the swap of pages 0x0B and 0x0E (36 entries each). Over the 47
  neighbouring zone pairs that touch those two pages, log2(period) rises by more than half an octave going up
  the keyboard in 0 pairs as dumped and in 10 with the pages swapped (all pages as dumped: 83 of 1,345 MAIN and
  82 of 1,447 SUB pairs, layered sounds such as drawbar footages).
- `wave_reverse_entry.py`: `Main_P00_E0AF` is the only entry of either stream with any of P bits 11:9 set. The
  10,944 words at its B read as 16-bit audio (lag-1 correlation 0.989; 0.006 as 8-bit) and lie inside entry
  0x065's 16-bit loop (words 0x26f80..0x2b580). -B mod 2^16 = 0xd750 = the last of the 964 units entry 0x0AE's
  segments cover (0xd38d..0xd750); both records hold the segments 128, 128, 202, 128, 212 (0x0AE with its loop
  flags, E0AF with none and a REC_END word whose one granule falls on the zero words 0xd38b0..0xd38cf). Parameter
  record 658 (bank key MSB 0, LSB 0x78, program 110) selects E0AF: "Reverse Cymbal" / "Reverse Cym.1/.2";
  record 636 (LSB 0x08, program 110) selects 0x0AE: "Ride Cymbal 1/2".
- `wave_record_extent.py`: with every record word counted as a run of granules (a value below 0x80 = one
  granule), no recording runs past the next one, and no non-zero word lies between one recording's end and
  the next start. MAIN 2,178 recordings and 96 alternate-start entries (all ending where their recording
  ends, all with its loop); SUB 1,402 and 29 (17 with a loop, the same). After the end: nothing in 2,125 MAIN /
  1,376 SUB recordings, runs of 16-224 zero words in 53 / 26. The last granule of a record without LOOP_END is
  all zero in 187 of 262 MAIN and 296 of 410 SUB "segments, then REC_END" records, never in the 432 / 564
  split-list ones. The 18 / 2 records with LOOP_END and no LOOP_START: their run-out repeats the recording's
  first 32 samples in every case.
- `wave_split_list.py`: 1,181 of 1,273 split lists descend by exactly 8 per word. Neighbouring split granules
  correlate at a median 0.994 (5,205 pairs). Of the 452 pairs of entries that play one recording with the same
  segments and different lists, all 452 differ by a constant, and in all 452 the higher list belongs to the
  higher keys: shift 8 = 11.2 keys on average, 16 = 24.3, 24 = 37.2, 32 = 49.2, 40 = 62.4, 48 = 74.7, i.e.
  8 per octave of key.
- `wave_port_readers.py`: the wave-ROM latches +6 / +8 / +A of both ports are used by 10 labels, all inside the
  checksum core 0x484839A1..0x48483B11; no instruction loads a port address into a register as a base.

