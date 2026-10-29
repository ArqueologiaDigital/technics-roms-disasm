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

## The field maps in `../specs/` (added 2026-10-29)

`floppy/kn5000/spec_struct.py` turns these JSON maps into the `kn5000_specs.inc` macros. The
scripts below produced the maps or measured the numbers quoted in them. They need the extracted
disks: `for d in floppy/kn5000/baserom/*.img; do python3 floppy/tools/fat12_extract.py $d
$TMPDIR/data-floppy-kn5000/ext/$(basename $d .img); done`.

| script              | question it answers                                                                                                              | run                                                                                         |
|---------------------|----------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| `clamp_ranges.py`   | What (min, max, mask) does the sound-RAM byte clamp (v10 0xfeec48, kit twin 0xfeee10) give each record offset?                    | `python3 clamp_ranges.py original_ROMs/kn5000_v10_program.rom <unidasm> <scratch dir> > clamp_ranges.json` |
| `tm_load.py`        | (library) the .TM corpus, from `TM_DIR` (default `$TMPDIR/data-floppy-kn5000/ext`)                                                | imported                                                                                    |
| `gen_tm_spec.py`    | Writes `specs/tm_sound_record.json`: is the 470-B record / kit tiled, and is each field in its clamp range in the corpus?         | `CLAMP_JSON=clamp_ranges.json TM_DIR=<ext> python3 gen_tm_spec.py specs/tm_sound_record.json` |
| `sqt_slots.py`      | Per-offset value variety of the SQT song slots, and slot fields against the event cells                                          | `python3 sqt_slots.py <ext> var LO HI`                                                      |
| `sqt_tracks.py`     | Do the +0xd0 track table, the +0x78 tail cells, the +0x98 write offsets and the +0x1e mask agree with the cell chains?            | `python3 sqt_tracks.py <ext>`                                                               |
| `partcalls.py`      | Which constant slot offsets do the song-slot accessors (Part_ReadByteDirect, Part_WriteByte, Part_ReadWord, Part_WriteWord) take? | `python3 partcalls.py` (from the repo root)                                                 |
| `ramrefs.py`        | Which v10 source lines name a RAM address in [lo, hi), by literal or by `.equ` name?                                              | `python3 ramrefs.py 0xf180 0xf980`                                                          |
| `write_sqt_spec.py` | Writes `specs/sqt_slot_header.json` and checks that its fields tile each region                                                  | `python3 write_sqt_spec.py specs/sqt_slot_header.json`                                      |
| `cmp_var.py`        | Per-offset value variety of the CMP style-bank header, section records and the area before the cells (`specs/style_bank_extra.json`) | `python3 cmp_var.py <ext> hdr\|rec\|pre LO HI`                                              |
