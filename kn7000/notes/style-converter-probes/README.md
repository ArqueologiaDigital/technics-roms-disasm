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
