# Firmware C that is not built

The C here describes a firmware function, but Toshiba cc900 V4.23 does not turn it into the ROM's bytes.  The rule
(coordinator, 2026-11-16) is that a function is built from C only when V4.23 reproduces it, so the build is the same
with `CC900_COMPILER=v423` (the default) and `CC900_COMPILER=model`.  The tree keeps the function's hand assembly,
and `make` does not compile these files (the Makefile reads `cc900/*.c` only).
`scripts/analysis/cc900/c_build_coverage.py` still checks them and lists them as not built.

| file               | function                | why it is not built                                                                                                                      |
|--------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| `smf_operations.c` | `TrimAndPadSmfFilename` | V4.23 gives the first 42 of its 60 bytes (run `2026-11-16-18-p6-firmware`); the rest needs the model's firmware-only rule KN_LOOP_INVERT |

`TrimAndPadSmfFilename` was built from C in commit 31cb1816d (the reference model with KN_LOOP_INVERT) and returned to
hand assembly with the V4.23 build (branch cc900/vm-build).  The C file is unchanged, so its V4.23 verdict still
applies to it.
