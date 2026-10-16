# SP7001 probes quoted in `notes/sp7001-build-diff.md`

| script              | question it answers                                                              | run (repo root)                                                                                                     |
|---------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| `xap_base_check.py` | is BASEEXT.XAP linked at 0x5029B000? (prologue hits peak only there)             | `python3 -I notes/sp7001-probes/xap_base_check.py baserom/sp7001_baseext.xap`                                       |
| `asm_coverage.py`   | how many region-1 bytes each program source emits as assembly                    | `python3 -I notes/sp7001-probes/asm_coverage.py`                                                                    |
| `rate_probe.lua`    | how fast the two firmware time counters tick, and which task slots exist at boot | `kn7000 -bios sp7001 -str 16 -autoboot_script notes/sp7001-probes/rate_probe.lua` (writes `$TMPDIR/rate_probe.log`) |

Everything else quoted there comes from the make targets (`verify-sp7001`, `verify-sp7001-floppy`,
`symbols-sp7001`, `exports-941`, the `*-src-sp7001` generators) and the tools they run.

`rate_probe.lua` result (2026-10-16, MAME, program 942): `0x500D3C68` 999.5 counts/s (the kernel's
1 kHz tick, ms since ~0.27 s after power-on), `0x50151C0C` 499.8 counts/s (`GetTimBase`, 2 ms units);
task-pointer table `0x50380000`: ids 0-4, 7, 8 allocated, 5, 6, 9, 10 = `0xFFFFFFFF` (free), and the
next word `0x5038002C` holds the running task.
