# SD PLUG-iN (SP7001) and the reserved plug-in region — build 941 has no SD code-load path

**2026-10-08.** Question: KEY SOFT SERVICE sold an *SD PLUG-iN* (product **SP7001**)
for the KN7000 that loaded plug-in program code from the SD card into a
Technics-**reserved** RAM/ROM region. Where is that SD code-load entry point in the
firmware?

**Answer: it is not in this disassembly.** This tree is **program build 941**
(`GetTtSoftverID` `0x48488AAC` returns the software-version constant `0x00100000`;
the SOFT VERSION screen reports `PROGRAM : 941`). SP7001 required a later firmware,
Technics **"Update V2.0"**, which is unpreserved. Build 941 — and, being earlier,
the owner's **build 893** — predate it.

Full write-up, version table and vendor citations:
[docs `/kn7000-sd-plugin/`](https://arqueologiadigital.github.io/technics-docs/kn7000-sd-plugin/).
Companion firmware analysis: `kn7000_mame/notes/FINDINGS-sd-media-codeexec-and-parsers.md`
and `kn7000_mame/notes/FINDINGS-expansion-buses-and-code-exec.md`.

## Evidence in this image (941)

- **No `PLUG` / `SP700` / `V2.0` / `SD-PLUG` / `KEYSOFT` strings** anywhere in
  `kn7000_program.rom`.
- The SD file path is a **fixed-table dispatch**, never a pointer taken from card
  data: `DiskLoadDispatch` `0x4852CFE4` (walks the handler table) and the
  tag/ext matcher at `0x4852B6B0`. The runtime library self-loads from program
  flash (`LibRomImageBase` `0x487B8FD1` = lib `0x4C000000`), **not** from the card.
- A narrow confirming scan: across the whole 4 MiB image there is **exactly one**
  "load a function pointer from a fixed RAM cell and jump through it" site —
  **`0x487F46D8`** — and it is **RTOS task-switch machinery**, a companion to
  `LibIrqScheduler` `0x487F6DF7`: it saves `SP` into the current task block at
  `*(0x5038002C)` and resumes another task's stack from `0x50380CB8`, then
  `jmp (a2)` to a **saved task PC**. No card byte reaches it. It is **not** a
  plug-in/overlay vector. (Now labelled `TaskYieldSwitch` in `kn7000_manual.sym`.)

So the reserved-region/SD-load hook SP7001 relies on was **added in V2.0**, not
present (even dormant) in 941. A V2.0 dump would be needed to locate the reserved
region, the on-card plug-in format, and the loader routine.

## Why this matters for ROM archival

The owner's instrument runs the older **893**, which is the firmware worth
archiving. SP7001's SD code-load path is *not* a way to dump 893: the hook is in
V2.0, and flashing V2.0 to obtain it would overwrite 893. The non-destructive 893
route remains the MEMORY DUMP screen / `dumpgrab` / an IC16-IC17 clip read. If a
**V2.0** image is ever obtained, its documented SD-load path could run a dumper
plug-in on a V2.0 unit to read the undumped `0x4C000000` library ROM and the wave
ROMs over SD.
