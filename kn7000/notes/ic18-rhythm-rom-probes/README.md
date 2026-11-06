# IC18 rhythm data probes (notes/ic18-rhythm-rom.md)

Run from this directory. The chip image is private: `~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18`
(SHA-1 `2dc71f5082063cd6b21e4ed16acd67e9d326a79f`), or the copy `make verify-ic18-full` leaves in
`../../baserom/kn7000_ic18.rom`.

| script                        | question it answers                                                                                                                                                       | command                                                                                                                                                                                               |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ic18_rhythm_probe.py`        | what is where from 0x10000 to the end of the chip, does every record and event stream parse as the firmware reads it, and what do the fields hold?                        | `python3 -I ic18_rhythm_probe.py ~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18 --program ../../baserom/kn7000_program.rom --table ../../baserom/kn7000_table.rom --source ../../src/ic18` |
| `rhythm_noteconv_tables.py`   | what does each NoteConvRules table (program 941, 0x48736104) do to a key written over C, per chord type (and root)? (N-c052c027)                                          | `python3 -I rhythm_noteconv_tables.py`                                                                                                                                                                |
| `rhythm_kit_tone_fallback.py` | which kit does ToneKeyFind fall back to for the ten kit sounds the internal archive lacks, and how many drum notes then name the key as Standard Kit 1 does? (N-83177c3d) | `python3 -I rhythm_kit_tone_fallback.py`                                                                                                                                                              |
| `rhythm_part_eq_and_units.py` | which TG registers the part EQ coefficients reach, and what a variation's bytes +2/+3 select (func_48442164)? (N-e779328f)                                                | `python3 -I rhythm_part_eq_and_units.py`                                                                                                                                                              |

`--program` (program 941) adds the rhythm groups, `--table` (table 84) the comparison with the table ROM's copy
of the header, `--source` (the `src/ic18` directory) the size of the text against the bytes and the
number of `.incbin` lines (0). The signals it reads, and what passes:

- the header's checksum word at file 0x10010 against the big-endian halfword sum it describes: `equal`;
- the index: entries `< 220` (styles), `0x8000 + n` (aliases), `0x4000 + n` (table-ROM styles), and how many
  resolve to nothing after one alias hop: must print 0;
- the tiling of 0x10000 to the end of the last style by the count-ins, the style records (0xC6 bytes each)
  and their variations: `0 bytes uncovered, 0 covered twice`;
- every event stream, with RhyEventLenByStatus's lengths: `malformed: 0` (opens with 0xF4, ends with 0xF5 at
  the stored length, bars x beats 0xF4 markers, data bytes < 0x80);
- the bytes below 0x80 between events: `max 95, falling within a beat: 0` is what makes them tick positions.

What it printed on 2026-10-29 (abridged), at the commit that typed the event streams:

    checksum 0xe2da, over 0x100000 halfwords from +0x100000 (file 0x110000): recomputed 0xe2da equal
    count block 00 00 00 dc 00 60 0d 08 04 02 02 02 -> count 220, then 96
    {'alias': 1828, 'table ROM': 51, 'style': 169}
    IDs that resolve to no style after one alias hop: 0
    styles + count-ins cover 0x10000..0x3fbad3: 0 bytes uncovered, 0 covered twice
    3388 streams; malformed: 0
    slot order in the chip: (12, 13, 16, 17, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 14, 15, 18, 19) (169 styles)
    position bytes: 324664, max 95, falling within a beat: 0
    events: {'0x90': 529662, '0xb0': 113223, '0xd0': 4, '0xe0': 23491, '0xf4': 39412, '0xf5': 3388}
    set-up events by status: {'0xb0': 22351, '0xc0': 4947}
    last style ends 0x3fbad3; non-0xFF bytes up to 0x3ffc6d (16794 bytes); then 0xFF to 0x3FFFE8
      of those 10 records' streams, 10 occur nowhere else in the chip
    == bytes by representation (header and tables 4,678; style records 33,462; variation headers and
       set-up events 117,229; style event streams 3,955,326; leftovers 16,794; count-ins 364; erased and
       version 915): sum 4,128,768 of 4,128,768 bytes from 0x10000
      ../../src/ic18: 171 files (169 style files), 760,109 lines, 14,378,065 bytes of text for 4,128,768
       bytes: 3.48x; .incbin lines: 0
    table ROM copy at file 0x3e828c, 0x1248 bytes: differs from IC18 in 7 bytes at [...] count 221
    243 rhythms in the groups; 169 of the 169 IC18 styles are in one; group order = chip order: True

The three `rhythm_*` probes (2026-11-06) read program 941 (`../../baserom/kn7000_program.rom`) and its
generated source (`../../src/program/`), and `rhythm_kit_tone_fallback.py` / `rhythm_part_eq_and_units.py`
also `../../baserom/kn7000_ic18.rom`; each docstring gives the signals and the expected output.
`rhythm_kit_tone_fallback.py` reuses `../mn10300-names-probes/rhythm_drum_kit_keys.py`'s tables but reads
the voice names itself: that probe still expects a voice name on an `.ascii` line, and since the
archive's records became `VOICE_HEAD "name", ...` it prints `'?'` for every key.

`tools/gen_ic18_rhythm_s.py` makes the same checks before it writes `src/ic18/rhythm.s`, the style files and
`old_build.s`, and stops on any difference.
