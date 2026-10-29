# floppy/ -- diskette images rebuilt from typed source

Every Technics diskette image in MAME's floppy softlists, held as source and rebuilt byte for byte.
The boot sector, both FATs and every directory entry are typed field by field, and each file is a
unit of its own that a format describer can type by what it holds. Set up 2026-10-29 for the
data-semantics effort (`notes/data-semantics-2026-10-29/README.md`). The KN5000 notes are in
`notes/floppy-kn5000-2026-10-29/README.md`.

```
make -C floppy gate-kn5000      # rebuild the 14 KN5000 disks, check each one's SHA-1
make -C floppy gate             # every model in MODELS
make gate-floppy                # the same, from the root (part of make gate-all)
make -C floppy src-kn5000       # regenerate floppy/kn5000/<disk>/ from the references
```

## Layout

| path                             | what                                                                  |
|----------------------------------|-----------------------------------------------------------------------|
| `Makefile`                       | the generic rules, one template per model and one per disk            |
| `tools/fat12.inc`                | macros: position asserts, the FAT12 packer, `fat_dirent`, `fat_lfn`   |
| `tools/fat12lib.py`              | image reader (BPB, FATs, directory tree, chains); never normalises    |
| `tools/fat12_to_s.py`            | the generator: image -> `<model>/<disk>/*.s`                          |
| `tools/fat12_extract.py`         | image -> files, into `build/<model>/<disk>/` (for media includes)    |
| `tools/sha1_gate.py`             | the gate: rebuilt image SHA-1 == recorded SHA-1                       |
| `<model>/disks.mk`               | disk list, softlist name, SHA-1 per disk, describer module            |
| `<model>/formats.py`             | the model's format describers (`describe(ctx)`)                       |
| `<model>/include/*.inc`          | the model's format macros (on the include path of every disk)         |
| `<model>/<disk>/disk.s`          | generated: the whole image, in disk order                             |
| `<model>/<disk>/boot.s`          | generated: boot sector                                                |
| `<model>/<disk>/fat.s`           | generated: one FAT copy as cluster chains (or `fat1.s`, `fat2.s` ...) |
| `<model>/<disk>/root.s`          | generated: root directory                                             |
| `<model>/<disk>/dir_<path>.s`    | generated: a subdirectory's entries                                   |
| `<model>/<disk>/files/<unit>.s`  | generated: one unit per file                                          |
| `<model>/baserom/<disk>.img`     | git-ignored reference, copied from the softlist zip with a SHA-1 check |
| `build/`                         | git-ignored output                                                    |

The committed `<model>/<disk>/` trees are exactly what `make src-<model>` writes. To change one,
change the generator, the describer or a macro, then regenerate. Do not edit the output.

## The assembler: llvm-mc

The images are assembled by the repository's pinned `llvm-mc` (`-triple=tlcs900 -filetype=obj`)
and turned into raw images by `llvm-objcopy -O binary`. They hold data only, so the triple does not
matter: it is little-endian, which suits FAT. The disk sets of models with other CPUs (WSA1R,
KN6000, KN7000) build the same way. `kn7000/tools/kn7asm.py` was the other candidate. It was not
chosen for three reasons:

- `llvm-mc` already has `.macro` with named and keyword parameters, `.rept`, `.if`, `.error`,
  `.set` variables and numeric local labels. The FAT12 packer and the position asserts are built
  from these.
- It takes `.incbin "f", skip, count`, the form `data_incbin_census.py` sizes.
- It is fast: all 14 KN5000 disks assemble in a few seconds.

Every object depends on `$(LLVM_MC)`, so a new assembler rebuilds every image.

## References and the gate

The reference images are those of the 2026-10-18 rebuild of the softlists,
`$(PROJECTS_ROOT)/technics_romsets/floppy-rebuild-2026-10-18/roms/<list>/<disk>.zip`. Their
`summary.tsv` lists the SHA-1s, and `kn7000/Makefile`'s `SOFTLIST_DIR` names the same set. The
softlist headers say how the images were made: "faithful reconstructions built from the archives'
own files". `make` copies `<disk>.img` out of the zip into `<model>/baserom/`. It refuses a copy
whose SHA-1 is not the one in `disks.mk`. `gate-<model>` rebuilds every disk and has
`tools/sha1_gate.py` compare each image's SHA-1 with the recorded one. The script exits 1 on any
mismatch, and also when a SHA-1 is missing or no disk is named. On a failure it prints the first
differing offset.

Bulk bytes never enter git: a payload with no better form is an `.incbin "<disk>.img", skip, count`
of the git-ignored reference (`-I <model>/baserom`).

## What the generator writes

- **Boot sector** (`boot.s`). The BPB, one labelled line per field. The FAT geometry fields are
  spelled by the same `FAT12_*` symbols that place everything else, so the geometry is written
  once. Then the DOS 4 extended fields when the signature byte says they are there, the boot code
  and the signature word. Short boot code is `.byte`, with what it does. Long boot code (a PC
  formatter's) is `census: opaque -- code`.
- **FAT** (`fat.s`). Every 12-bit slot of a FAT copy, spelled as chains:
  - `fat12_run FIRST, N, LAST` for each contiguous run, with the file it belongs to;
  - `fat12_free N` for free entries and for the slots past the last cluster;
  - `fat12_entry V` for slots 0 and 1, and for anything else.

  The packer in `fat12.inc` reproduces the 12-bit packing exactly: entries 2k and 2k+1 go in bytes
  3k..3k+2. `fat12_run` asserts that the chain starts at the next slot, and `fat12_end` that the
  copy is filled exactly. When the copies agree, `fat.s` is included once per copy. Otherwise each
  copy gets its own file.
- **Directories** (`root.s`, `dir_<path>.s`). `fat_dirent "NAME    ", "EXT", attrs, hour, min,
  sec, year, month, day, cluster, size` per used slot, with the time and date decoded; every stored
  value round-trips. Bytes 12..21 (DOS 7) are keyword parameters, emitted only when non-zero.
  Other entries:
  - VFAT long names: `fat_lfn`;
  - deleted entries: `fat_dirent` with the `\345` name byte;
  - runs of zero slots: `.fill`.
- **Data area** (`disk.s`). Cluster by cluster:
  - each file is `.include "files/<unit>.s"`, asserted at its first cluster (`fat12_at_cluster`)
    and asserted to be exactly the file's size (`at`);
  - the slack after a file is `.fill` when uniform;
  - free clusters are one `.fill` per uniform run;
  - anything non-uniform (slack, free or lost clusters, reserved sectors) is an `.incbin` declared
    `census: opaque -- unknown-dump:`, naming what the bytes are.

  A fragmented file is placed fragment by fragment in `disk.s` and is not offered to describers.
  None of the softlist images has one.

Unit names (`fat12lib.unit_name`) are the 8.3 name, with every character outside `[A-Za-z0-9_-]`
spelled `xHH`, for example `06(DEMO).TM` -> `06x28DEMOx29.TM`. Without that, make would read
`(...)` as an archive member.

## Writing a format describer

`<model>/formats.py` defines `describe(ctx)`. The generator calls it once per unfragmented file.
It returns the unit's source as a string or a list of lines, or `None` to leave the file as one
generic `.incbin`. A describer is written once per format, and every disk that holds the format
uses it. `ctx` carries these fields:

| field           | meaning                                                                         |
|-----------------|---------------------------------------------------------------------------------|
| `ctx.data`      | the file's bytes                                                                |
| `ctx.entry`     | its `fat12lib.Entry` (`name`, `ext`, `size`, `attr`, `cluster`, `time`, `date`) |
| `ctx.path`      | `NAME.EXT` (with `DIR/` prefixes)                                               |
| `ctx.unit`      | the unit name                                                                   |
| `ctx.label`     | a label prefix unique within the disk (`F_<unit>`); prefix every label with it  |
| `ctx.ref`       | the reference file name to `.incbin` (`<disk>.img`)                             |
| `ctx.offset`    | the file's first byte in the reference                                          |
| `ctx.extracted` | the name of the file's own copy under `build/<model>/<disk>/` (on `-I`)         |
| `ctx.disk`      | the disk name                                                                   |

A unit must emit exactly `ctx.entry.size` bytes, and `disk.s` asserts that it does. Its macros go in
`<model>/include/*.inc` (or in `tools/` when they are not model-specific). Each one has a header
naming the firmware routine that reads the structure. A module may also set `BOOT_NOTE`, a list of
comment lines put at the top of every `boot.s`, to say which firmware routine writes that boot
sector.

## Census

`scripts/analysis/data_incbin_census.py` has one `TREES` row per model (`kn5000-floppy` =
`floppy/kn5000`, `wsa1-floppy`, `kn6000-floppy`, `kn7000-floppy`). `.fill` and typed records are
not includes and are not counted. Every `.incbin` is counted:

| line                                                  | counts as |
|-------------------------------------------------------|-----------|
| an `.incbin` of an extracted `.bmp` (or other media)  | media     |
| `census: generated -- <tool>` on it or above it       | generated |
| `census: opaque -- <kind>: <why>` on it or above it   | opaque    |
| anything else, such as a file left to `default_unit`  | generic   |

## Adding a model

1. Write `<model>/disks.mk`, following `kn5000/disks.mk`. It sets `<model>_LIST` (the softlist
   name), `<model>_DISKS`, one `<model>_SHA1_<disk>` per disk, and optionally `<model>_FORMATS`.
   When the zips are not under `$(SOFTLIST_DIR)/<list>/`, it also sets `<model>_ZIPDIR`.
2. Add the model to `MODELS` in this Makefile.
3. Run `make -C floppy src-<model> gate-<model>`.
4. Commit `<model>/`.
