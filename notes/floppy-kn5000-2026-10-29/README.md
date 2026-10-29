# The 14 KN5000 floppies as source (lane floppy-kn5000, 2026-10-29)

The diskettes of MAME's `kn5000_flop` softlist, rebuilt byte for byte from typed source in
`floppy/kn5000/`, on the shared framework in `floppy/` (interface: `floppy/README.md`). This note
covers three things:

- the KN5000 file formats the describers type (`floppy/kn5000/formats.py`, `events.py`,
  `include/kn5000_files.inc`);
- the firmware evidence for each format;
- what is still not typed.

```
make -C floppy gate-kn5000                    # 14 x "OK ... rebuilds <disk>.img (SHA-1 ...)"
make -C floppy src-kn5000                     # regenerate floppy/kn5000/<disk>/ (needs the refs)
python3 notes/floppy-kn5000-2026-10-29/probes/kn5000_floppy_formats.py floppy/kn5000/baserom/*.img
```

## The disks

The images are the 2026-10-18 rebuild of the softlist. Per the softlist header they are
"faithful reconstructions built from the archives' own files": no original diskette was dumped.
All 14 have the same layout:

- the KN5000 formatter's boot sector;
- two identical FATs;
- files stored contiguously, in directory order;
- zero slack after each file's end;
- every free cluster filled with 0xE5.

The generator checks every one of those properties rather than assuming it. The volume label is
a root entry with attributes 0x28.

| disk    | content (softlist)                          | files                                                      |
|---------|---------------------------------------------|------------------------------------------------------------|
| idd5000 | Initial Data (factory default)              | `01CTMINI.RCM` + 5 wallpaper `.BMP`                        |
| ca5000r | style disk                                  | 5 styles x (TM PMT LSW CMP)                                |
| ca5000w | wallpapers                                  | 14 `.BMP`                                                  |
| ca5001  | Volksmusik ... ca5010, mix5000: style disks | per style TM SQT PMT LSW CMP, a `(DEMO)` set, `_INHALT.TXT`, `BITMAP.BMP` |

Bytes per kind, over all 14 disks: CMP 4,717,568 (75 files), PMT 4,304,384 (64), BMP 2,304,830 (29),
TM 1,350,626 (46), SQT 665,856 (72), RCM 470,016 (1), LSW 229,824 (63) and TXT 4,432 (11).

## Boot sector and FAT

The first 32 bytes of every boot sector are the firmware's `FDC_Format2HD_BootSectorHead` (v10
0xe450da), byte for byte. `FDC_Format2HD_WriteBoot` (v10/v9 0xf522f5) writes that block: EB 1C 90
`"Technics"`, a DOS 3.x BPB for 1.44 MB, then `EB FE` (x86 `jmp $`) at 0x1e. The rest of the
sector is zero, including the signature word, so a PC cannot boot these disks. Checked by the
probe's BOOT row (14/14).

FAT slot 0 is 0xff0, the media byte F0 that `FDC_Format2HD_FatHead` starts with.

## The file formats

The KN5000 numbers its file types by an index into `FileIO_TypeExtensions` (v10 0xea0340: LSW PMT
SQT CMP "TM " MSP RCM "MD " SQF SEQ). `SaveAll_RegionSaveRecs` maps each index to a save
handler. The handlers are named `FileIO_SaveRegion<n>_*`, and the `_VRAM` / `_ExtMem` suffixes
are older misnomers. Each handler writes the RAM it saves verbatim, so a file's layout is the RAM
layout of its region. The writers below come from `v10/maincpu/demo/file_demo_proc.s`.

| ext | type | on-screen name   | writer (v10)                                                      | what it holds                                                                            | typed here                                                                                                                                                                                    |
|-----|------|------------------|-------------------------------------------------------------------|------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| LSW | 0    | CURRENT PANEL    | `FileIO_SaveRegion0_VRAM` 0xf87af6                                | RAM 0xf980..0xffc0 (32-B header, panel block 0, block 1) + 0x800 from 0x1e7800 = 0xe40 B | header and its `"HK"` (`FileIO_CheckRegionSignature(0)`); every record's tag and length (`panel_tlv`), checked against `PanelTlv_Block0_Layout` / `_Block1_Layout`                         |
| PMT | 1    | PANEL MEMORY     | `FileIO_SaveRegion1_VRAM` 0xf87b88                                | RAM 0x1ed350..0x200000: header, 10 bank names, 80 x 960-B panel blocks                   | header, the size fields read through 0x1ed350 + 13 (960 B, count 80 or 8), the bank names, one label per memory                                                                              |
| SQT | 2    | SEQUENCER        | `FileIO_SaveRegion2_ExtMem` 0xf87cac                              | 0x800-B song slots (SEQ_SONG_SLOTS 0xab000) + event memory (0xb0000)                     | slot signature `"ZZZZ"`, all-songs flag, `01 08` signature, song name; every event cell (`seq_cell`) and **every event, one per line** (`sq_*`)                                             |
| CMP | 3    | COMPOSER         | `FileIO_SaveRegion3_ExtMem` 0xf87d2c                              | RHYTHM_PATTERN_BUF_A, size from `cmp_sv_mae`: one IC19-format style bank                 | bank magic, the 30 directory records (5 chain pointers, name), every cell (`style_cell`) and **every event, one per line** (`st_*`)                                                         |
| TM  | 4    | SOUND MEMORY     | `FileIO_SaveRegion4_VRAM` 0xf87e41                                | RAM 0x1e0000, 0x72aa B                                                                   | `"KN5000 SOUND RAM"` header (checked at boot), 40 x 470-B records and one kit record, each by its 16-B name                                                                                  |
| RCM | 6    | RHYTHM CUSTOM    | `FileIO_SaveRegion6_Simple` 0xf87e00 / `FileIO_LoadRcmToFlash` 0xf186a9 | header + 8 chunks for Custom Data Flash sections 0..7                                    | magic, the chunk-length table at +0x40, sections 0..6 as style banks (as CMP, events one per line), section 7's slot counts                                                                 |
| BMP | -    | (wallpaper)      | `CaptureLcd` 0xfaf030; read by `Gfx_LoadSplashBMP` 0xfae86d        | Windows BMP, 8 bpp                                                                       | BITMAPFILEHEADER / BITMAPINFOHEADER fields (`bmp_*` macros); palette and pixels are `.incbin`s of the extracted `.bmp` (census: media)                                                       |
| TXT | -    | -                | (a PC)                                                            | the disk's table of contents, CR LF text                                                 | every line as `.ascii`                                                                                                                                                                        |

The sources come from the CURRENT PANEL / PANEL MEMORY ... names of the HD-AE5000 and KN7000 UI
(technics-docs `hdae5000.md`), `docs/kn-disk-file-formats.md` (the LSW writer, the
SaveAll table and the `.SEQ` cell), `docs/accompaniment-style-format.md` (the IC19 bank),
technics-docs `custom-data-flash.md` (RCM, BMP, the section-7 slot store) and `boot-sequence.md`
(the TM header check).

### Events, one per line

The integrator ruled on 2026-10-29 that parseable music is typed, never opaque. Two grammars are
spelled, both in `floppy/kn5000/events.py` with their macros in `include/kn5000_files.inc`.

- **Style banks** (CMP, RCM sections 0..6) use the IC19 grammar of `scripts/build/style_events.py`:
  `st_beat`, `st_end`, `st_note pos, note, vel, dur_ticks, dur_beats`, `st_note2` (+2 bytes),
  `st_ctl1..3 pos, value`. The bank also needs **`st_ctl4` / `st_ctl5` (0xd4 / 0xd5, two data
  bytes)**, which the factory IC19 banks never use. That argument count is measured. With two data
  bytes, all 29 chains that stopped at 0xd4/0xd5 parse to their END. With one or three, 20+ chains
  break. The probe holds the test.
  - Cell links count blocks from **block 20 of the bank** (bank + 0x1400), in all 82 banks
    (75 CMP + 7 RCM sections). No other base makes 1/10 as many links mutual (BASE row).
  - Three CMPs (`04LATIN`, `06STMMIX`, `14}DEMO`) have cell-shaped blocks 12..19 below that
    base. They are typed as unlinked blocks.
  - A chain is tokenised as one stream and cut back into its cells. An event split by a cell
    boundary is `.byte` in both cells, with the whole event in the comment.
  - Bytes after `st_end` are PAD: `.fill` when uniform, else `.byte`.
  - Two chains still hit a byte outside the grammar (0x10 and 0x87). Their rest is `.byte`,
    marked "not decoded".
- **Sequencer** (SQT event memory) uses the demo-song grammar of `scripts/build/demo_preset_to_midi.py`:
  - `sq_beat`;
  - `sq_note status, pos, note, vel, dur_ticks, dur_beats`, and `sq_run` for running status;
  - `sq_ev status, data...` for 0x82 end-of-track and any other status;
  - `sq_data` for data bytes under no status.

  Every byte tokenises under this grammar. A chain starts at a cell whose PREV is 0 and whose
  byte 0 is non-zero. Byte-0 = 0 cells are the free list, and each is tokenised alone.

Typed text is 4.9x the binary for CMP, 3.9x for SQT and 4.3x for RCM, under the integrator's 6x
limit.

## Probe results (`probes/kn5000_floppy_formats.py`, all 14 disks, 0 failures)

| row                                                          | count   |
|--------------------------------------------------------------|---------|
| boot sector == firmware head, rest zero                      | 14 / 14 |
| LSW 0xe40 B, `"HK"` at +4                                    | 63      |
| LSW blocks opening with all 46 / 30 layout records           | 36      |
| LSW block 0 with 43 records (no tags 0x99, 0x80)             | 13      |
| PMT memories with all 46 block-0 records                     | 4,128   |
| PMT memories with the first 43                               | 344     |
| TM files, KN5000 0x72aa layout / KN3000 image                | 45 / 1  |
| style banks whose link base is block 20                      | 82      |
| style cells / chains / events                                | 18,400 / 12,324 / 506,970 |
| style next links mutual / not                                | 5,958 / 13 |
| SQT cells; next links mutual / not                           | 1,377; 1,186 / 7 |

The firmware's record lists are identical in v5, v6, v7, v9 and v10
(`*/maincpu/ui_widgets/naka_extension_device.c`). So the 43-record blocks (13 LSWs, 344 PMT
memories) and the LSW block-1 variants (28 and 29 records) come from an older firmware than any
dumped revision. That is an [INFERENCE]: all of these files date from 1997-98. The describers type
each such block as far as it follows the list, then as tag/length records up to its FF FF mark.

## What is not typed, and why

These payloads stay `.incbin`s of the file's extracted copy, and the census counts them as
**generic**. Each is labelled per item, and its comment says what it is:

- **PMT memories (960 B each), LSW record payloads, TM sound records (454 B each) and the kit
  record**: panel and sound parameters. Their framing is typed (record tags and lengths, names).
  The field values are not: the firmware's per-field rules (`PanelTlv_Rules_*`, RULE_* in
  `naka_extension_device.c`) give a type, offset, mask and range per field, but no names. A
  describer that spells each field through those rules is the next step. These bytes are the
  largest remainder.
- **CMP / RCM directory bytes** at record +0x0c..+0x3f and +0x50..+0x5f, the bank header
  +4..+0x5f, and the region between the directory and block 20. No field has been identified
  (`docs/accompaniment-style-format.md`).
- **SQT slot header** +7..+0xff and +0x110..+0x7ff. The demo-preset layout (track table at
  +0xd0) does **not** hold here: every start field read 0xffff. So which chain is which track is
  open.

Declared opaque (`unknown-dump`):

- the LSW's 0x800 bytes from RAM 0x1e7800, a region nothing in the firmware has been mapped to;
- the body of `ca5000r/03FOLKS2.TM`, a 29,696-byte `"KN3000 SOUND RAM"` image whose layout is
  another model's.

## Open questions

1. What do 0xd4 / 0xd5 do in the style player? The argument count is measured; the meaning is not.
2. Where does an SQT slot name its tracks' first cells?
3. Thirteen style links and seven SQT links are not mutual. Are they edits left behind, or a
   second link convention?
4. The two style chains that stop at 0x10 / 0x87: is that corruption in the archives, or another
   status?
5. Which firmware revision wrote the 43-record panel blocks? A v1-v4 dump would settle it.

## Website page draft (for technics-docs, "KN5000 disk files")

> **KN5000 disk files.** The KN5000 formats a 1.44 MB diskette itself. It writes a FAT12 boot
> sector whose first 32 bytes come from ROM (`FDC_Format2HD_BootSectorHead`): `"Technics"`, a
> DOS 3 BPB, and `jmp $` as boot code, so the disk does not boot a PC. Each file type is an index
> into `FileIO_TypeExtensions`. Every save handler writes a fixed RAM region verbatim, so each
> file's layout is the RAM layout of that region:
>
> - `.LSW` (current panel): the panel work area, two tag/length/value blocks, plus 2 KB from
>   0x1e7800;
> - `.PMT` (panel memory): 80 panel blocks of 960 bytes, under 10 bank names;
> - `.SQT` (sequencer): 2 KB song slots, then the event memory in linked 256-byte cells;
> - `.CMP` (composer): one accompaniment-style bank in the IC19 custom-data format;
> - `.TM` (sound memory): a 0x72aa-byte image of RAM 0x1e0000, opening with `"KN5000 SOUND RAM"`;
> - `.RCM` (rhythm custom): an image of Custom Data Flash sections 0..7, which the loader writes to
>   flash, stamping the section number into the style directory on the way;
> - `.BMP`: the instrument's own 320 x 240 x 8 screenshot format.
>
> All 14 disks of the MAME softlist rebuild byte for byte from typed source in the disassembly
> repository (`floppy/kn5000/`). Every style and sequencer event is spelled there one per line.
> The style data also uses two controller events the factory banks never use, 0xd4 and 0xd5, each
> with two data bytes.

## Files

- `floppy/kn5000/disks.mk`: the disk list and SHA-1s.
- `floppy/kn5000/formats.py`: the describers, one per extension.
- `floppy/kn5000/events.py`: the two event grammars.
- `floppy/kn5000/include/kn5000_files.inc`: the record and event macros.
- `floppy/kn5000/<disk>/`: the generated sources.
- `notes/floppy-kn5000-2026-10-29/probes/`: the asserting probe (README there).
