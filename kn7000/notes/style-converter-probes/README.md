# Style converter probes (notes/style-converter.md)

The `.CNV` files come from the installers `scd7000.exe` / `scd6000.exe` (CA software mirror,
`7000/files`, `6000/files`): `unzip -d DIR INSTALLER`.

| script            | question it answers                                                                     | command                                                                                                                                                                               |
|-------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cnv_calls.py`    | does a converter call anything outside itself?                                          | `python3 -I cnv_calls.py ~/compartilhado/kn7000_mame_build/unidasm KORG.CNV`                                                                                                          |
| `title_pool.py`   | which number does each `_TT_STYLCNV*` screen have?                                      | `python3 -I title_pool.py ../../baserom/kn7000_program.rom`                                                                                                                           |
| `ram_strings.cmd` | what text does the KN7000 keep at 0x50001100-0x50001400 after boot (TECHNICS, prompts)? | `cp ram_strings.cmd $TMPDIR/r.cmd`, then in kn7000_mame `REMOTE_CMD=$TMPDIR/r.cmd ./tools/rig.sh remote kn7000 -s 120 -l $TMPDIR/r.log -- -harddisk ""` and `grep ^STR $TMPDIR/r.log` |

Results on 2026-10-18 (all six converters of both disks, PROGRAM 941):

    GEM_WS2.CNV  (99857 bytes): call inside 809, jmp inside 692
    GEM_WX2.CNV (108049 bytes): call inside 878, jmp inside 856
    KORG.CNV    (108912 bytes): call inside 876, jmp inside 958
    SOLTON.CNV   (96706 bytes): call inside 752, jmp inside 680
    TECHNICS.CNV(101992 bytes): call inside 582, jmp inside 621   (both disks' builds)
    Roland.cnv   (91872 bytes): call inside 702, jmp inside 614
    no call or jump outside the file, none through a register

    0x46 _TT_STYLCNVWAIT  0x47 _TT_STYLCNVMODL  0x48 _TT_STYLCNVCNVT  0x49 _TT_STYLCNVSTOR
    0x4A _TT_STYLCNVTXT   0x4B _TT_STYLCNVSEL   0x4C _TT_STYLCNVCONT

    STR 5000119C TECHNICS V1.0
    STR 500011B0 Insert Style Disk of    Technics KN 1000/750
    STR 500011DD V1.0

The counts include bytes in data areas that decode as instructions; the check that matters is
that none of them leaves the file.

## Can STYLE CONVERT load a converter from the SD card? (2026-10-18)

| file               | question it answers                                                                                            | command                                                                                                        |
|--------------------|----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `sdmark.s`         | (the marker converter) did the firmware load and call this copy, from which drive?                             | assembled by `sd_cnv.sh`                                                                                       |
| `sd_cnv.sh`        | with copies of the marker on the SD card, does STYLE CONVERT list or run one, from the menus or the SD screen? | `notes/style-converter-probes/sd_cnv.sh FLOPPY ROUTE OUTDIR` (FLOPPY none, blank or flop; ROUTE menu or sd)    |
| `drive_callers.py` | does the STYLE CONVERT code ever set the fmm drive byte?                                                       | `python3 -I drive_callers.py UNIDASM ../../baserom/kn7000_program.rom ../../baserom/kn7000_program_sp7001.rom` |

`sd_cnv.sh` puts the marker as `AW.CNV` on a copy of the real KN7000's SD card in three folders:
`\` (tag ROOT), `\PRIVATE\TECHNICS\KN7000` (KN7K) and its `TFLD001` (TFLD). It boots program 941
(the published overlay build) and prints the fmm drive byte `0x5007125A`, the marker's call count
`0x502E0000`, the tag of the copy that ran (`0x502E0008`) and the main task's title
(`0x500009A0`, `0xF0000` + title). Results, 2026-10-18:

| floppy                     | route                        | STYLE CONVERT screen        | after OK                      | drive byte throughout                  |
|----------------------------|------------------------------|-----------------------------|-------------------------------|----------------------------------------|
| blank + `AW.CNV` (control) | DISK MENU                    | `0x47` (the converter list) | 162 calls, tag `FLOP`, `0x4A` | 0                                      |
| blank, no converter        | DISK MENU                    | `0x46` "insert the disk"    | 0 calls                       | 0                                      |
| none                       | DISK MENU                    | `0x46`                      | 0 calls                       | 0                                      |
| blank, no converter        | SD CARD LOAD, then DISK MENU | `0x46`                      | 0 calls                       | 0, also on the SD MENU (title `0x104`) |
| none                       | SD CARD LOAD, then DISK MENU | `0x46`                      | 0 calls                       | 0, also on the SD MENU                 |

The SD MENU (SD CARD LOAD) lists SD TOOLS, SD PREFERENCES, FAVORITE SONGS, CUSTOM STYLE LOAD/SAVE,
LOAD, SAVE, SD SONG MEDLEY, SD-AUDIO PLAY and SD-SOUND PLAY: no STYLE CONVERT.

`drive_callers.py` output (both builds alike):

    kn7000_program.rom: drive byte 0x5007125A, set 0x48532346, set-0 0x48532355, '*.CNV' pattern 0x485CD534
      set     44 callers {'0x4848xxxx': 1, '0x4855xxxx': 42, '0x4858xxxx': 1}; inside STYLE CONVERT: 0
      set-0   46 callers {'0x4848xxxx': 1, '0x4851xxxx': 2, '0x4855xxxx': 42, '0x4858xxxx': 1}; inside STYLE CONVERT: 0
    kn7000_program_sp7001.rom: drive byte 0x5007126A, set 0x48532335, set-0 0x48532344, '*.CNV' pattern 0x485CDA28
      (the same counts)
