# SP7001 firmware vs. the reconstructed build — what actually changed

**2026-10-16.** Goal: disassemble the **SP7001** KN7000 firmware in this repo, reusing the
existing build and spending effort only on what genuinely differs.

## The firmware variants (from the merged MAME driver `matsushita/kn7000.cpp`)

Each KN7000 flash image is a program + table pair; each half is two 2 MiB EPROMs (IC17 even,
IC16 odd) word-interleaved into a 4 MiB image (program at `0x48400000`, table at `0x48000000`).

| BIOS     | program build | table build | note                                 |
|----------|---------------|-------------|--------------------------------------|
| `sp7001` | **942**       | **83**      | Key Soft Service SD PLUG-iN (2003-08-23) |
| `v16`    | 941           | 84          | **what this repo reconstructs today** |
| `v15`    | 935           | 84          |                                      |
| `v14`    | 929 (partial) | 84          |                                      |

So SP7001 differs from the repo's current base in **both** halves: program `941→942` and table
`84→83` (83 is the older table build, paired with the SP7001 program).

## Reproduce (tools in `tools/`)

    R=~/compartilhado/technics_romsets/kn7000
    python3 -I tools/rom_from_eproms.py $R/kn7000_program_even_v1.6_b941.ic17  $R/kn7000_program_odd_v1.6_b941.ic16  program_941.rom
    python3 -I tools/rom_from_eproms.py $R/kn7000_program_even_sp7001_b942.ic17 $R/kn7000_program_odd_sp7001_b942.ic16 program_942.rom
    python3 -I tools/rom_from_eproms.py $R/kn7000_table_even_b84.ic17           $R/kn7000_table_odd_b84.ic16           table_84.rom
    python3 -I tools/rom_from_eproms.py $R/kn7000_table_even_sp7001_b83.ic17    $R/kn7000_table_odd_sp7001_b83.ic16    table_83.rom
    python3 -I tools/diff_builds.py program_941.rom program_942.rom 0x48400000
    python3 -I tools/diff_builds.py table_84.rom    table_83.rom    0x48000000

Sanity: `program_941.rom` and `table_84.rom` are **byte-identical** to this repo's
`baserom/kn7000_{program,table}.rom` over their full extracted length (the extraction just trims
the trailing 0xFF padding: program 37119 bytes, table 92972). So the de-interleave is correct and
the repo's base is exactly the MAME dumps' content.

## What actually changed

**PROGRAM 941 → 942: 3,487,812 bytes differ (83.2%), 2827 change-regions.** This is **not** a
clean relocation: an alignment probe finds only ~50% of 941's 64-byte blocks present anywhere in
942, with inconsistent shifts. 942 is a substantial rebuild — roughly half the image is shared
(some of it shifted), half is genuinely different. **Byte-level reuse is not viable for the
program.** The smart reuse here is *function/symbol-level*: this repo already recovers ~444 named
functions from the firmware's MILK reflection tables (`tools/gen_symbols.py`); re-running that on
942 names most functions for free, leaving only the genuinely-new SP7001 routines to analyse by
hand.

**TABLE 84 → 83: 1,754,268 bytes differ (41.8%), but only 5 change-regions:**

| region (CPU addr)           | size      | what it is (from the SP7001 RE)                         |
|-----------------------------|-----------|---------------------------------------------------------|
| `0x480000F0-0x48000151`     | 98 B      | small header/directory delta                            |
| `0x48139EE9`                | 1 B       | single byte                                             |
| `0x48244F7A-0x483F8868`     | 1.78 MB   | bulk table-data delta; **contains the SP7001 code** at ~`0x483Exxxx` |
| `0x483F887C-0x483FA56B`     | 7408 B    | includes the activation keystream records (`0x483F8B74`) |
| `0x483FA57C-0x483FB59F`     | 4132 B    | activation/apply code tail                              |

The table diff is concentrated. Most of the 1.78 MB block is table **data** that differs between
builds 83 and 84; the SP7001 **code** worth disassembling is the upper slice
(~`0x483E0000`–`0x483FBFFF`), where the reverse-engineered activation gate lives
(`0x483E9E1C` OK-handler, `0x483EF0AF` comparator, `0x483F8B74` keystream — see
`research-scratch/kn7000-sp7001-activation/`).

## Implication for "only work on what changed"

- **Table (83):** byte/region-level reuse of build 84 for the shared parts; **disassemble only the
  SP7001 code slice** (`~0x483E0000–0x483FBFFF`), seeding it from the existing activation RE.
- **Program (942):** regenerate a byte-exact listing mechanically (existing `gen_program_s.py`),
  reuse 941's recovered **symbols/annotations** by name, and hand-analyse only the functions that
  are new or changed vs 941 (the SP7001 feature: floppy→SD song-conversion + the activation).

Open design question (for Felipe): how to carry a second build variant in a repo currently built
around one byte-exact target — see the plan in the session discussion.
