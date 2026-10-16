# SP7001 probes quoted in `notes/sp7001-build-diff.md`

| script              | question it answers                                                   | run (repo root)                                                      |
|---------------------|-----------------------------------------------------------------------|----------------------------------------------------------------------|
| `xap_base_check.py` | is BASEEXT.XAP linked at 0x5029B000? (prologue hits peak only there)  | `python3 -I notes/sp7001-probes/xap_base_check.py baserom/sp7001_baseext.xap` |
| `asm_coverage.py`   | how many region-1 bytes each program source emits as assembly         | `python3 -I notes/sp7001-probes/asm_coverage.py`                     |

Everything else quoted there comes from the make targets (`verify-sp7001`, `verify-sp7001-floppy`,
`symbols-sp7001`, `exports-941`, the `*-src-sp7001` generators) and the tools they run.
