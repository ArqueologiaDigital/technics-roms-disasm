# Probes behind notes/floppy-kn5000-2026-10-29/README.md

The references must exist first (`make -C floppy refs-kn5000`, which copies them out of the
softlist zips into the git-ignored `floppy/kn5000/baserom/`).

| script                     | question it answers                                                                                                     | run                                                                                                  |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `kn5000_floppy_formats.py` | Do the 14 disks hold the formats `floppy/kn5000/formats.py` types, and do the claims in the notes hold?                 | `python3 notes/floppy-kn5000-2026-10-29/probes/kn5000_floppy_formats.py floppy/kn5000/baserom/*.img` |

`kn5000_floppy_formats.py` reads these signals:

- the boot sector against `original_ROMs/kn5000_v10_program.rom` 0x450da (`FDC_Format2HD_BootSectorHead`);
- the panel record lists, parsed from `v10/maincpu/ui_widgets/naka_extension_device.c`;
- the style-cell link base (block 20), tested against every base from 0 to 63;
- the IC19 grammar, extended with 0xd4 / 0xd5 of 2 data bytes. The docstring has the counter-test
  with 1 and 3 data bytes.

It exits 1 on a failure. The counts it prints on 2026-10-29 are the table in the notes README. The
generator's output itself is checked by the SHA-1 gate (`make -C floppy gate-kn5000`).
