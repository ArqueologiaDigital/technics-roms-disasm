[![semantic disasm](docs/badges/semantic-score.svg)](#how-semantic-is-it)
[![KN5000 semantic](docs/badges/semantic-score-kn5000.svg)](#how-semantic-is-it)
[![SX-WSA1R semantic](docs/badges/semantic-score-wsa1.svg)](#how-semantic-is-it)
[![SX-KN7000 semantic](docs/badges/semantic-score-kn7000.svg)](#how-semantic-is-it)
[![bytes understood](docs/badges/semantic-bytes.svg)](#how-semantic-is-it)
[![semantic names](docs/badges/semantic-names.svg)](#how-semantic-is-it)
[![jump tables resolved](docs/badges/semantic-entry.svg)](#how-semantic-is-it)
[![C fields named](docs/badges/semantic-fields.svg)](#how-semantic-is-it)

It's been many many years that I've been studying the ROM code of the Technics KN5000 music keyboard with two major goals:

- [To emulate it on MAME](https://github.com/mamedev/mame/pull/14558)
- To be able to develop custom software to run on the real device.

There's much more info at https://forum.fiozera.com.br/t/technics-kn5000-homebrew-development/321

This repo started as a private one. But after putting so much effort into documenting the boot code, I decided to publish it, because it may be useful for other people interested in learning how this machine works.

I hope nobody gets mad at me for doing so. As this device was discontinued decades ago, I believe that there's no actual harm in doing so. It is much more like a museum item being studied by people interested in the history of electronic music equipment development.

Cheers,
Felipe Sanches


## How semantic is it?

Every image already rebuilds byte-identical to its dump, so byte-match says nothing about progress. The
badges above measure understanding instead, over every rated image of all three models. They are produced by
`make semantic-score`, i.e. `scripts/analysis/semantic_score.py`, whose docstring defines each part:

- **bytes understood**: bytes whose purpose the source states with evidence: code, documented data and
  verified filler (`scripts/analysis/data_range_census.py`). That strict measure exists for the KN5000 and
  the SX-WSA1R only. The pooled badge also adds the SX-KN7000's bytes, which use a weaker measure: the share
  of bytes emitted as source rather than passthrough, an upper bound (see below). The KN7000 is about 42% of
  the pooled bytes, so the badge mixes two definitions. The per-model figures in
  `docs/badges/semantic-score.json` keep them apart.
- **semantic names**: linked symbols whose name says what the thing is. Names that only restate an
  address (`sub_F4A2B0`) or a position (`Foo_Helper7`, `Foo_Case5`) do not count. Local branch labels
  (`Foo_Skip2`, prom_c's `Foo__F9A123`) are not rated, so each routine counts once.
- **jump tables resolved**: jump/call tables whose every entry lands on a labelled instruction, spelled
  symbolically (the committed dispatch census, `docs/coverage/`).
- **C fields named**: C struct members with a meaningful name rather than an index (`str_3`,
  `field_0a38`).

The SX-KN7000 has no ELF, no dispatch census and no C. Its score is the mean of two parts, both read from the
sources: **bytes** is the share emitted as source rather than `.incbin_range` passthrough
(`kn7000/tools/coverage_score.py`'s source coverage), and **names** is named routines among the recovered
functions and converter routines. Its images are program 941, table 84 and the seven Style Convert converters.

The score is the mean of these components, per model and overall. Every number behind it, with its
commit, is in `docs/badges/semantic-score.json`; the trend is in `docs/badges/semantic-score-history.csv`.

## This repository now holds three disassemblies

This was `kn5000-roms-disasm`. Since 2026-10-19 it is **technics-roms-disasm**: one tree for
every Technics ROM disassembly, the KN5000 at the root and each other model in its own folder.

Since 2026-09-01 this tree also contains the **Technics SX-WSA1R** disassembly,
under `wsa1/`, migrated here from its own repository so that both products build
from one tree and can share code. That repository is decommissioned; all WSA1R
work continues here.

    make everything    build the KN5000 images and the WSA1R's four
    make gate-all      run both byte-identity gates
    make wsa1          the WSA1R alone

The byte-identity gate is the only thing that certifies either disassembly, so
neither is "built" until its gate is green.

All 206 WSA1R commits were rewritten to the `wsa1/` prefix before the merge, so
`git log wsa1/<path>` reaches the whole history rather than stopping at the
migration.

There is a real connection between the two machines, not just a shared
repository: the multitasking kernel that the WSA1R's two processors run is also
present in **both** of the KN5000's — one kernel, four processors, two products.
See `wsa1/notes/FINDINGS-kernel-in-the-kn5000.md`.

Since 2026-10-19 it also contains the **Technics SX-KN7000** disassembly, under `kn7000/`, migrated
from its own (never published) repository, `kn7000_disassembly`, which is now decommissioned. All
163 of its commits were rewritten to the `kn7000/` prefix, and
`kn7000/notes/migration-commit-map.txt` maps the old commit hashes to the new ones.

    make kn7000        the KN7000's program + table (941/84) and IC19 picture images
    make gate-kn7000   their byte-identity gates, plus the SP7001 set (942/83), the seven
                       Style Convert Disk converters, table build 80 and the IC18 boot ROM

`make everything` and `make gate-all` include it. The KN7000 runs on a Panasonic MN10300, not the
TLCS-900, so `kn7000/` has its own assembler (`kn7000/tools/kn7asm.py`) and its own
`kn7000/README.md`. It also holds the [ROM dumper](kn7000/tools/cnv_romdump/README.md) that read a
real KN7000's program, table and picture ROMs through its own Style Convert function.

## Current state (measured 2026-10-24)

The project began with Alfred Arnold's ASL, which only knows the TMP96C141 instruction set; with it, the
rebuild was at about 85% byte-match on 23 Dec 2025. It now assembles with its own TLCS-900 backend for LLVM
(`llvm-mc -triple=tlcs900`, branch `tlcs900_backend`; the exact commit and binary hash are in
`TOOLCHAIN_VERSION`). The LLVM `.s` sources are authoritative. The ASL sources are kept, unbuilt, in
`archive/asl/`.

**Every image of all three models rebuilds byte-identical to its dump:**

| model    | images                                                                                                                                                    | gate               |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| KN5000   | main CPU v10, v9 and v7; sub-CPU payload v1.42 and its compressed update image; sub-CPU boot (IC30); table data; custom data (IC19); HD-AE5000 v2.06i (9) | `make gate`        |
| SX-WSA1R | prom_a (IC12), prom_b (IC13), prom_c (IC28), prom_d (4)                                                                                                   | `make gate-wsa1`   |
| KN7000   | program 941 and table 84; IC19 picture ROM; SP7001 program 942, table 83 and BASEEXT.XAP; the seven Style Convert Disk converters                         | `make gate-kn7000` |

    make everything    build all three models
    make gate-all      run every byte-identity gate

The gates are the only thing that certify a disassembly. A green gate says nothing about how much of an
image is real source rather than a passed-through blob, so that is measured separately:

| model    | how much of the image is source                                                                                                                                            | command                                                  |
|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| KN5000   | 96.8% over its 8 measured images (the compressed v1.42 update image is not measured on its own); every image 100% except v7 (99.7%) and table data (84.8%, 318,468 B blob) | `python3 scripts/analysis/kn5000_source_coverage.py`     |
| SX-WSA1R | 100% (no `.incbin` left); 78.0% substantive, the rest verified filler                                                                                                      | `cd wsa1 && python3 scripts/analysis/source_coverage.py` |
| KN7000   | 3.88% of the program ROM is real assembly; the rest is still `.incbin` of the git-ignored reference image                                                                  | `cd kn7000 && python3 tools/coverage_score.py`           |

The two TLCS-900 models together (the 12 images that script measures, KN5000 and SX-WSA1R) are 97.4% source.

How much of that source is *understood* (named, explained) is what the badges at the top measure; see
[How semantic is it?](#how-semantic-is-it).

Copyrighted dumps for the newer targets are not committed: the KN7000's reference images are git-ignored
and regenerated by `kn7000/Makefile` from the update disks and private romsets beside this tree (the IC19
picture ROM's SHA-1 is recorded in that Makefile, so its gate is checkable without the dump).

## Homebrew

My main homebrew project is to port Eric Chahi's Another World virtual machine to run on the musical
keyboard (because we can! LOL). The first code in that direction was at
https://github.com/felipesanches/kn5000_homebrew/blob/main/demos/anotherworld/another.asm
