# IC307 probes (lane kn5000-waveform, 2026-10-29)

Read-only scripts behind every figure in `../README.md`. Both are imported by
`scripts/generators/gen_waveform_ic307_s.py`, which built the `waveform/` tree from them.

| script                     | question it answers                                                                                                                                                                                                                                                                                                                       | run                                                                                 |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| `ic307_layout.py`          | What is in each 1 MB page of IC307: directory length, record extents, zero alignment, distinct waves and their lengths, the 0xFF tail; the shapes of the parameter words (key-split vs sequence words, end / marker bits, the 3-bit field pair); which records repeat another's tail; whether each page's first wave is a 256-sample sine | `python3 notes/waveform-ic307-2026-10-29/probes/ic307_layout.py [ic307]`            |
| `tonedb_selector_users.py` | For each recording selector (class << 12) + entry: which wave sources (catalogue names), tone records, drum instruments, SETs and drawbar zone records reach it, walking the Sub CPU's wave-selection chain over `original_ROMs/kn5000_table_data.rom`; per class, how many entries are used and the largest                              | `python3 notes/waveform-ic307-2026-10-29/probes/tonedb_selector_users.py [sel ...]` |

`ic307_layout.py` reads `original_ROMs/kn5000_waveform_rom.ic307` (`make original_ROMs/kn5000_waveform_rom.ic307`
copies it from the private romset), else `~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307`, and
prints the image's SHA-1 so a reader can see it is the audited dump (`4b511bff6625f4655cabd96a263bf548d2ef4bf7`).

What each script reads, and what a value means:

- `ic307_layout.py`: page `p` starts at file offset `p * 0x100000`. Word 0 of a page / 4 = N, the directory length.
  Entry `i` is `{u16 record offset, u16 wave start / 16}` at `4 i`. A record's head word must equal its entry's
  wave start (asserted). A record ends where the next one starts; the last one ends at its last non-zero word. A
  wave's length is the distance to the next distinct wave start, or to the page's trailing run of 0xFF.
- `tonedb_selector_users.py`: the routines it mirrors are named in its docstring, with their v1.42 addresses.
  Its class census line `class c: n distinct entries, max entry m` is the class-to-page evidence. Classes 4, 5, 6
  and 7 print max entries 197, 167, 1071 and 56, which are pages 0-3's N - 1. Classes 0, 1 and 3 print 213, 176
  and 435, more than IC307's pages 0, 1 and 3 hold.
