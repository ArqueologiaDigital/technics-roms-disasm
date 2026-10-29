# Data semantics, 2026-10-29

The owner's goal, set 2026-10-29: describe all the data semantically, including the dumps that hold only
data, which the 2026-10-24 audit had left out of scope (`notes/repo-audit-2026-10-24/README.md`). *"Ensure any data
block in the source is only left as a generic binclude if there's no other better semantic representation
for it."*

## The instrument

`scripts/analysis/data_incbin_census.py` counts every `.incbin` / `.incbin_range` per tree and puts each one in a
class:

- **generated**: compiled C, or a committed generator from committed source;
- **media**: a self-describing file such as a JPEG or a BMP;
- **opaque**: declared with `census: opaque -- <kind>: <why>`, with a mandatory reason;
- **generic**: anything else.

The goal is generic = 0 for every tree. An opaque declaration names why no better form exists. Its docstring
defines the rules. Snapshots go to `docs/coverage/data-incbin-<date>-NN.{txt,json}`.

Baseline, before this work (2026-10-29, at b58b8f696; generic entries / bytes):

| tree              | generic n | generic bytes |
|-------------------|-----------|---------------|
| kn5000-v10        | 8         | 4,928         |
| kn5000-v9         | 8         | 4,928         |
| kn5000-v7         | 8         | 4,928         |
| kn5000-v6         | 13        | 5,130         |
| kn5000-v5         | 12        | 4,949         |
| kn5000-tabledata  | 69        | 772,289       |
| kn5000-customdata | 11        | 639,296       |
| kn7000-program    | 3         | 2,563,794     |
| kn7000-table      | 447       | 2,560,580     |
| kn7000-sp7001     | 704       | 5,176,151     |
| kn7000-b80        | 2         | 4,064,860     |
| kn7000-b893       | 3         | 2,607,409     |
| kn7000-b935       | 3         | 2,602,613     |
| kn2400            | 446       | 1,993,350     |
| kn6000            | 323       | 2,630,724     |
| kn6500            | 327       | 2,140,036     |
| hdsx3             | 30        | 533,544       |

The dumps with no tree at all are not in that table:

- KN5000: waveform ROM IC307 (4 MB) and rhythm ROM IC14 (4 MB).
- KN7000: the four wave ROMs (4 x 16 MB), the rhythm ROM IC18 beyond its 64 KB boot ROM, and the nine custom-data
  images (`*.ic21`).
- KN6000 / KN6500: `01ctmini.ic18`.
- The 50 softlist floppies: KN5000 14, WSA1 9, KN6000 21, KN7000 6.

## Conventions every lane follows

1. **Representation, best first.**
   1. Typed records: labels, `.byte` / `.short` / `.long` with symbolic pointers (`.long Rec - Base`),
      one macro per record type whose parameters name the fields, and strings as `.ascii`.
   2. A committed generator from committed, human-readable source (YAML / JSON / MIDI / text), marked
      `census: generated -- <tool>`.
   3. A standard media file.
   4. Declared opaque, with its reason.
2. **No bulk dump bytes in git.** The repo is public. Reference images are git-ignored and copied from the
   private romsets with a SHA-1 check in the Makefile: kn7000's convention, also used for KN5000 v8/v6/v5. A
   payload with no better form is an `.incbin` with skip and count, or an `.incbin_range`, of that reference.
   It is labelled per item, and its comment says what the item is. Typed tables in the source follow the
   precedent of the committed disassembly. Felipe's own instrument data (the IC21 read of his KN7000) stays out
   of the trees.
3. **Byte identity.** Every new image is rebuilt and gated, and wired into its model's gate and `make gate-all`.
4. **Evidence.** Every claim about a field's meaning cites the firmware code that reads it (address and label),
   or the probe that measured it. Probes are committed beside the notes they back, with a README.

## Lanes (wave A)

| lane             | scope                                                                     |
|------------------|---------------------------------------------------------------------------|
| kn5000-waveform  | IC307: directory, parameter records, one labelled PCM item per wave       |
| kn5000-rhythm    | IC14 (descrambled): signature blocks, program blocks, whatever follows    |
| kn7000-wave      | IC203/204/207/208                                                         |
| kn7000-ic18      | IC18 beyond the boot ROM: "Technics Rhythms" header, 220-style directory  |
| customdata       | KN7000 `*.ic21` x 9, KN6000/KN6500 `01ctmini.ic18`                        |
| floppy-kn5000    | the shared FAT12 floppy tree and generator; the 14 KN5000 disks           |
| floppy-others    | WSA1, KN6000 and KN7000 disk file formats; their disks on the framework   |
| kn5000-existing  | table_data, custom_data and the maincpu trees' generic includes           |
| kn7000-table     | table 84's generic segments, then tables 83 and 80                        |

Each lane's outcome and open items are added below as lanes merge.
