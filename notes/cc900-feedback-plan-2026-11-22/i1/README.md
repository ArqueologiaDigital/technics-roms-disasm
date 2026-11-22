# Step I1: the compiler passes under Ghidra

Feedback plan section 13, step I1.  The outputs reproduce Toshiba's code, so they are written only to the private
`~/compartilhado/cc900-oracle/internals/` (never pushed); this directory holds our scripts and counts only.

| file                   | question it answers                                                                                     |
|------------------------|---------------------------------------------------------------------------------------------------------|
| `i1_ghidra.sh`         | runs Ghidra 12.2 headless on one build (`i1_ghidra.sh KEY EXE`): import, auto-analysis, ExportFunctions |
| `ExportFunctions.java` | the post-script: every function's entry, size, name, callers and callees, and the decompiler's C        |

Tools: Ghidra 12.2 (needs Java 25) and Temurin JDK 25.0.5.1+2, each archived raw in its own git repository under
`~/compartilhado/upstream_repos/file_archive/github.com/` (`NationalSecurityAgency/ghidra-release-12.2`,
`adoptium/temurin25-jdk-25.0.5.1`) and unpacked in `~/compartilhado/tools/`.

## Result (2026-11-22)

Runs: `i1_ghidra.sh thc2-1998 .../devrs.com/ngpcbins/unpacked/zip/T900/BIN/THC2.EXE`, likewise `thc2-2003` (the IDE's
`T900SK/bin/thc2.exe`), `thc2-2009` (v1.10's `T900/bin/thc2.exe`) and `thc1-1998` (V4.23's `THC1.EXE`).  About a
minute each.  Counts from each `functions.tsv` (column `library` = named by Ghidra's Function ID, i.e. MSVC runtime):

| key       | functions | bytes in functions | named runtime | decompiled | decompiled lines | failures |
|-----------|-----------|--------------------|---------------|------------|------------------|----------|
| thc2-1998 | 597       | 255,813            | 12            | 583        | 50,039           | 0        |
| thc2-2003 | 673       | 290,290            | 23            | 648        | 57,751           | 0        |
| thc2-2009 | 1,057     | 415,447            | 261           | 793        | 48,967           | 0        |
| thc1-1998 | 553       | 206,474            | 22            | 529        | 41,310           | 0        |

Function ID knows little of the 1998 runtime (MSVC 5): of V4.23's code generator only 12 runtime functions are
named, so its unnamed functions still include the static C runtime.  The private commit is cc900-oracle fc12b60.
