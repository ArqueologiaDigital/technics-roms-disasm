# open4/wsa1-d probes (2026-10-31)

Sub-lane D of the wave-4 WSA1R lane: prom_b data objects, the block-store heap's size, the
single-record display-list entry shapes, and the prom_a power-on splash.  Every script reads the
committed ROM images in `wsa1/original_ROMs/` and/or the sources, runs from `wsa1/`, and exits
non-zero on drift with `--selftest`.

| script                            | question it answers                                                                                                                                                  | command                                                                   |
|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `workspace_defaults_partition.py` | How does prom_b `WorkspaceDefaults` (0xF46074, 161 bytes) divide, and how many 256-byte records does the 0x617800 heap hold? (N-c4ef2711, N-0bbd0164, N-1837e44c)    | `python3 notes/open4-d-probes/workspace_defaults_partition.py --selftest` |
| `single_record_entry_census.py`   | Every way a single display-list record is run, over both CPU-1 images (N-8884e5fe); needs the ELFs `make gate-wsa1` builds                                           | `python3 notes/open4-d-probes/single_record_entry_census.py --selftest`   |
| `splash_layer_and_logo.py`        | Which layer the first power-on splash blit (0xF94131) draws into, and what the dithered logotype reads (N-89745684, N-37157ced); `--render PNG` writes the composite | `python3 notes/open4-d-probes/splash_layer_and_logo.py --selftest`        |

Signals read, so the numbers keep their meaning:

* `workspace_defaults_partition.py`: each run's start is the imm32 of the `ld XIX/XIY` (opcodes
  `0x44`/`0x45`) at its copy site; each length is the loop bound at the listed bound site
  (`DD DF 63` = `cp IY,7 / jr ULE`; `DD CF 08 00 67` = `cp IY,8 / jr C`; `DD CF 11 00 67` =
  `cp IY,0x11 / jr C`; `31 03 00` = `ld BC,3`; `CB CC 03` = `and C,3`).  The heap figures are the
  six bytes at prom_b `0xF46084`: long `0x00617800` (base) and word `0x050C` = 1292 (count), which
  `BStore_BootPhase0` copies to `0x3604`/`0x3608`.  Pass = every check `ok`, `FAILURES: 0`.
* `single_record_entry_census.py`: the handler set is read from `DisplayList_HandlerTable` (36
  slots) and `DisplayListB_HandlerTable` (15 slots); a reference is any operand naming a handler,
  a RunOne runner, or a `T_*` thunk whose `jp` target is one of them.  Pass = the figures
  measured at 130735749 (17 thunks, 328 references, 66 + 71 routines, 0 numeric spellings).
* `splash_layer_and_logo.py`: byte patterns at prom_a `0xF8278A` (RESET clear count), `0xF8E8A2`-
  `0xF8E8B6` (the three SAD words), `0xF94112`-`0xF9416F` (no `F1 40 25`, i.e. no store to 0x2540),
  the two blits, the three SAD rewrites and the two scroll stops; then the layer that fits.  Pass =
  19 checks `ok`.
