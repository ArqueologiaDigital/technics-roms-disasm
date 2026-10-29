# Wave ROM probes (2026-10-29)

The scripts behind `../wave-roms-2026-10-29.md`. They read the four chip images from the private romset
(`$KN7000_WAVE_DIR`, default `~/compartilhado/technics_romsets/kn7000`, read-only) and print numbers only:
no ROM data is written. numpy is needed. Each runs in about a second.

| script            | question it answers                                                                                                                                                                       | run                       |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| `wavestream.py`   | (library) joins a pair into its stream, reads a page's directory and a record                                                                                                             | imported by the others    |
| `layout_probe.py` | what each 2 MiB page holds (entries, 8-bit entries, recordings, record words, first recording, end fill), and do the rules R1-R8 the source relies on hold everywhere                     | `python3 layout_probe.py` |
| `loop_probe.py`   | do the records' LOOP_START / LOOP_END marks, counted in granules of 2^(K+4) samples, fall where the data repeats its loop's first 32 samples after the end (and with L/2, 2L as controls) | `python3 loop_probe.py`   |
| `format_probe.py` | does directory word P bit 3 mean "two 8-bit samples per word" (lag-1 correlation as 8-bit against as 16-bit, per recording)                                                               | `python3 format_probe.py` |

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
