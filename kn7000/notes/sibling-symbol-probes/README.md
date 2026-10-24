# Reflection-table probes for the MN10300 sibling trees

| script                    | question it answers                                                                                       |
|---------------------------|-----------------------------------------------------------------------------------------------------------|
| `whole_image_pairings.py` | What would `gen_symbols.py` pair if the whole image counted as code, beyond what the code ranges give it? |

The sibling trees (`../../../kn2400`, `kn6000`, `kn6500`, `hdsx3`) run `gen_symbols.py` with
`--code-range` set to their code ranges. A MILK reflection table is a run of code pointers, a
NUL word, and a parallel run of pointers to identifier strings. `gen_symbols.py` accepts one when
at least 90% of the first run point into "code". With the whole image counted as code, tables
whose first run points into data pass too, and their names land on data. The probe shows which
tables those are, and how many addresses they would name.

Run from the repository root, after `make -C <tree> baserom`. The code ranges are the
Makefiles' `--code-range` / `SYMRANGE` values:

    python3 kn7000/notes/sibling-symbol-probes/whole_image_pairings.py --rom kn2400/baserom/kn2400_program.rom \
        --base 0x48400000 --code-range 0x1e427c:0x3285be
    python3 kn7000/notes/sibling-symbol-probes/whole_image_pairings.py --rom kn6000/baserom/kn6000_program.rom \
        --base 0x4c000000 --code-range 0x0:0x10 --code-range 0x80:0x176037 --code-range 0x3f47ec:0x3f77e7
    python3 kn7000/notes/sibling-symbol-probes/whole_image_pairings.py --rom kn6500/baserom/kn6500_program.rom \
        --base 0x4c000000 --code-range 0x0:0x10 --code-range 0x80:0x176839 --code-range 0x37e44c:0x381447
    python3 kn7000/notes/sibling-symbol-probes/whole_image_pairings.py --rom hdsx3/baserom/hdsx3_extapr.rom \
        --base 0x97800000 --code-range 0x80:0x3ded6

Output on 2026-10-24:

    kn2400/baserom/kn2400_program.rom: 2277 names with the code ranges, 2471 with the whole image; 194 addresses named only by the whole-image run
      extra table: code array at file 0x17d040, 10 entries, names ['MT_GetPadRun', 'MT_SetPadRun', 'MT_GetRhyRun'] ...
      extra table: code array at file 0x182bb4, 18 entries, names ['MT_SetValue', 'MT_GetValue', 'MT_GetCurSongName'] ...
      extra table: code array at file 0x1867f4, 20 entries, names ['MT_GetFileSfx', 'MT_GetSelectedFileNumber', 'MT_PsFileNameBoxID'] ...
      extra table: code array at file 0x187418, 118 entries, names ['DiskMenu', 'TT_DKMENU1', 'TT_DKMENU2'] ...
      extra table: code array at file 0x18bab8, 5 entries, names ['MT_GetEff', 'MT_PutEff', 'MT_AddEff'] ...
      extra table: code array at file 0x1cf7d0, 7 entries, names ['MT_PsFolderFileBoxID', 'MT_GetSelectedFolderNumber', 'MT_SetFavSong'] ...
      extra table: code array at file 0x1d0a90, 16 entries, names ['SdCardMenu', 'SD_MN_LDSW', 'SD_MN_TLSW'] ...
    kn6000/baserom/kn6000_program.rom: 1255 names with the code ranges, 1293 with the whole image; 38 addresses named only by the whole-image run
      extra table: code array at file 0x38665c, 39 entries, names ['DiskMenu', 'TT_DKMENU1', 'TT_DKMENU2'] ...
    kn6500/baserom/kn6500_program.rom: 1395 names with the code ranges, 1434 with the whole image; 39 addresses named only by the whole-image run
      extra table: code array at file 0x311ed0, 40 entries, names ['DiskMenu', 'TT_DKMENU1', 'TT_DKMENU2'] ...
    hdsx3/baserom/hdsx3_extapr.rom: 98 names with the code ranges, 98 with the whole image; 0 addresses named only by the whole-image run

The KN2400's `MT_*` tables pair event-name strings with method names: their "code" side points
at the text `"EV_DISPPADRUN"` and the like in the data, which comes first in that image. The
`DiskMenu` and `SdCardMenu` tables are menu definitions whose pointers lead into data. The
KN6000's and KN6500's `DiskMenu` tables name one address fewer than their length (38 of 39, 39 of
40) because one entry, `DKTdeltext`, is a null pointer.

The 2,471 / 1,293 / 1,434 / 98 totals are the whole-image counts the lane brief quoted for
`gen_symbols.py`.
