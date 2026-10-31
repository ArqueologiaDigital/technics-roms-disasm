# floppy-others, 2026-10-29: the WSA1R, KN6000 and KN7000 softlist disks as typed source

Lane `floppy-others` of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md`). It covers the
9 SX-WSA1R disks (`wsa1_flop`), the 21 SX-KN6000 disks and the 6 SX-KN7000 disks (`kn6000_flop`, `kn7000_flop`,
from the 2026-10-18 rebuild). They are held on the FAT12 framework of lane floppy-kn5000 (`floppy/README.md`).
Each disk lives in `floppy/<model>/<disk>/`. Every one is FAT12, so this lane added no container of its own.

    make -C floppy gate-wsa1 gate-kn6000 gate-kn7000      # all 36 disks, SHA-1 checked
    make -C floppy src-wsa1 src-kn6000 src-kn7000         # regenerate the trees (describers below)
    make gate-floppy                                      # every model, from the root (in gate-all)

## Results

All 36 disks rebuild byte-for-byte (`make gate-floppy`, which also covers the 14 KN5000 disks). Census rows at
the lane's second-pass commit (`data_incbin_census.py`, count / bytes):

| tree          | generated | media  | opaque       | generic n | generic bytes |
|---------------|-----------|--------|--------------|-----------|---------------|
| wsa1-floppy   | 0 / 0     | 16 / 0 | 180 / 50,503 | 0         | 0             |
| kn6000-floppy | 494 / 0   | 85 / 0 | 238 / 32,861 | 0         | 0             |
| kn7000-floppy | 111 / 0   | 1 / 0  | 90 / 11,122  | 0         | 0             |

The generated and media rows show 0 bytes because those streams are build products under
`floppy/build/<model>/<disk>/`, which the census does not size yet. Every opaque entry is leftover bytes:
- free song cells and free song-store blocks;
- the stale rest of a WSA1R .MID's last 1024-byte window, and of a .CMB's last kilobyte;
- the PC formatter's boot code (WSA1R).

Typed text against the binary it spells: .CMP 5.5x, .SQT part 2 5.9x, part 1 4.3x, .PMT 4.1x, .LSW 4.2-4.3x,
the KN6000 .TM 1.6x and the WSA1R .TM 1.15x (records deduplicated into content-addressed include files).

## Containers (KN6000 / KN7000): `floppy/tools/kd/`

The first byte of the magic names the model: `I` is the KN6000, `J` the KN7000. Byte layout:
`floppy/tools/kd/kd.py`'s docstring and `floppy/tools/kd.inc`.

- **'I KD' / 'IK D'** (.CMP .TM .PMT .EFC; .SQT .LSW with two parts). Each part is a deflate stream from
  **zlib 1.0.4, level 6**. The file drops the stream's 2-byte zlib header and keeps its big-endian adler32.
  The stored size in the header still counts the dropped header (stream + 2).
  - Evidence that it is zlib 1.0.4: the KN7000 program links zlib 1.0.4 (`kn7000_manual.sym`; `deflateInit2_`
    checks "1.0.4").
  - A modern zlib reproduces the single-block streams only. Every multi-block stream on the disks ends its
    first block at exactly 4096 symbols. That is 1.0.4's unconditional `_tr_tally` early block end
    (trees.c:973), which later releases compile only under `TRUNCATE_BLOCK`, at 8192.
  - The coder is `kn7000/tools/zlib10_deflate.py`, lane customdata's Python transcription of 1.0.4's
    deflate. Until the second pass this lane vendored zlib 1.0.4's C deflate (`zdeflate104.c`), which gives
    the same bytes on every part. It was dropped so the repository has one implementation, at the cost of
    speed: 3.7 s against 0.1 s for a 1.9 MB custom-data image.
- **'J KD'** (the KN7000's .CMP .PMT .MSP .SQT .LSW). This is **LZSS**, not deflate. `probes/lzss_brute2.py`
  and `probes/jkd.py` derived the format from the TCMP header that it must decode to:
  - flag bytes, low bit first, 1 = literal;
  - a reference is `lo, hi`, with position = `lo | (hi >> 3) << 8` (13 bits) and length = `(hi & 7) + 3`;
  - an 8 KB ring filled with 0 and starting at 0x1FF6;
  - no end marker.

  Okumura's LZSS.C binary-tree encoder with N = 8192 and F = 10 reproduces every stream with no reference
  (`floppy/tools/kd/lzss_j.py`). [INFERENCE] The KN5000's SLIDE8K is probably the same coder. Its current
  compressor replays reference decisions (`scripts/build/compress_slide8k.py`), so trying `lzss_j.encode` on it
  is cheap.
- **'I K\1' / 'J K\1'** (.AST, .CST). A u32 inflated size, then one deflate part.
  - .AST: the two u32 at +8/+0xC are not read back by any routine found. On the KN7000 they look like a
    program-ROM address and a RAM address (0x48582CD3, 0x5006F220), so [INFERENCE] they are left-over stack
    words.
  - .CST: its 0x28 header bytes (a name and four program-ROM addresses) are spelled as bytes and are not
    decoded.
- **Stored**: 'IK \0' / 'JK \0' (.HMP .FAV .MD) and every other file.

`kd.py verify` over every file of the 27 disks: 397 KD and 15 K1 containers re-encode byte-identical, and
122 files are stored.

## File kinds and what describes them

| model  | kind           | how it is held                                                                                                      |
|--------|----------------|---------------------------------------------------------------------------------------------------------------------|
| KN6/7  | .CMP           | the TCMP container typed in full, every event one per line (`kn_tcmp.py`, `kn_style.inc`)                           |
| KN6/7  | .SQT           | song records (track directory, the song's panel memory as PMR_*) and event cells, all 422 chains event by event     |
| KN6/7  | .PMT           | bank names and memories, each record a PMR_* line (the shared `kn7000/src/include/panel_memory.inc`)                |
| KN6/7  | .LSW           | part 1: the current panel (PMR_*) and a second record block; part 2: per rhythm, eight sound references (`ls_refs`) |
| KN6000 | .TM            | 40 SOUND EDIT records (SOUND_HEAD / SOUND_MOD / VOICE_ELEM), the custom-sound kit block (VOICE_*), the tail         |
| KN7000 | .CST           | one CUSTOM slot record, typed by lane customdata's own emitter (`gen_customdata_s.gen_record`; kn7asm)              |
| KN7000 | .MSP           | the TPAD container: header, banks, 18 pads, every event (`kn_tpad.py`)                                              |
| KN6000 | .EFC           | 55 records of 0x42 bytes (the CUSTOM record's five 0x42-byte kinds), name first                                     |
| KN6/7  | .MD .FAV       | header and u32 entries; named groups of {kind, value} items                                                         |
| KN6/7  | .AST           | generated: the deflate of the custom-data image that `kn7000/src/customdata` / `kn6000/src/customdata` build        |
| KN6/7  | .CNV           | generated: the build output of `kn7000/src/cnv/*.s`                                                                 |
| KN6000 | .JPG           | the extracted file (media)                                                                                          |
| KN6/7  | .HMP           | the 0x18C-byte home-page record and a 160x100 BMP cut out as a `.bmp` (media)                                       |
| KN6000 | .TXT .ACT .PRE | `.ascii` lines                                                                                                      |
| KN6/7  | .VER           | a Cakewalk .WRK, chunk by chunk                                                                                     |
| WSA1R  | .TM            | 4 banks: tag, 8 lines, 64 NORMAL SOUND records, the DRUM SOUND kit and its 128 NOTE DATA blocks, every byte named |
| WSA1R  | .CMB           | 16 bank names, 128 combinations as 23 records each, named from the Reference Guide (`cmb_*`)                        |
| WSA1R  | .SEQ           | song-store blocks, events one per line                                                                              |
| WSA1R  | .SQF           | ten song records: the fields the disk notes establish, the rest with offsets (`sqf_*`)                              |
| WSA1R  | .LSW .SLS      | record blocks: the current combination (`cmb_*`) and further {tag, length} blocks                                   |
| WSA1R  | .SRM .CRM .DRM | three re-maps: names, group names, {number, source} entries                                                         |
| WSA1R  | .MID           | the SMF cut out as a `.mid` (media); the stale tail opaque                                                          |

### Styles: the TCMP container (.CMP)

Every field cited is read by a KN7000 program 941 routine. Their names and addresses are in
`kn7000_manual.sym`'s two TCMP sections, quoted in `floppy/tools/kn_style.inc`.

- **Header.** "TCMP" 00 00, then:
  - the u16BE checksum (SumU16BE over the record block);
  - the checksum start 0x70 and length 0x1B00 halfwords;
  - +0x0E, copied between containers and not validated;
  - the u24 container length;
  - the u24 allocator top (`MemStyleAllocOffsetGet`);
  - the u16 style count N, which is 3 in every file;
  - the 0x18-byte template tail, then 0x40 spaces.
- **Style record, 0x80 bytes** (at 0x70 + 0x80·s).
  - Fields: the name and the four variation names, 16-byte fields of 13 characters; at +0x50 the 20 variation
    indices it owns; at +0x70 two u16, which are little-endian (the template's 0x0010 0x0023).
  - The rest is spelled as bytes and marked "not read".
- **Variation record, 0xE0 bytes.**
  - Read fields: kind +0, the B-half flag +3 bit 4, eight per-part bytes, bars−1 +0x10, the meter +0x11, and
    the stream offset +0x15.
  - Then eight part set-ups of 24 bytes each. [INFERENCE] These are the 24 fields of the part-field table
    0x485B77D4. The first 15 match the built-in styles' set-ups (`kn7000/notes/ic18-rhythm-rom.md`): cc94 = 64
    and cc96 = 12 in every part.
- **Heap.** One object per variation, in allocation order: the owning variation's index, a u24BE length, and
  the events (`MemStyleAreaStreamsVerify`). In all 82 files the heap tiles 0x3670..top exactly, and each of the
  60 variations owns exactly one object, the one its record points at.
- **Events.** Lengths come from `RhyEventLenByStatus`:
  - note 0x9n +5, controller +2, program +3, pressure +1, bend +2, SysEx;
  - F4 beat, F5 end;
  - a byte below 0x80 is a position (the tick in the beat, per the IC18 lane's reading).

  Typed text is 5.3x the binary (`probes/tcmp_survey.py`). Each stream is its own include file,
  `payload/<unit>.p1.vNN.s`.

### Songs (.SQT)

- **Part 1** is 1 or 10 song records, of 0x870 bytes on the KN6000 and 0x8E0 on the KN7000. Each opens with
  "ZZZZ", the 10-song flag and the model signature (01 0A KN6000, 01 0D KN7000). At +0xD0 is a directory of 16
  tracks, {flags, u16 first cell}; this is the KN5000 layout, `notes/feature-presentation-cues-2026-10-18.md`.
  At +0x140 is a full PANEL MEMORY record, 42 or 43 records long, which all 605 records hold. It is typed as
  PMR_*. The bytes before it and the 0x30 / 0x50 bytes after it are spelled with their offsets. The KN7000
  keeps the records at 0x501A5800 + n·0x8E0 (`Rec8E0TablePtr` 0x48456E49, 11 entries) and the cells in its
  song memory of 0x4D8 pages at 0x501AB9A0 (`SongPageStorePtr` 0x48456E8B).
- **Part 2** holds the 256-byte cells: flags, prev, next and 251 bytes.
- **Events: a measured grammar** (`probes/sqt_try.py`) ([INFERENCE]; no KN6000 or KN7000 song reader has been
  traced):
  - a tick byte before every channel or system event;
  - 0x9n +4, 0xAn +6, 0xBn +3, 0xCn +3, 0xDn +1, 0xEn +2, 0x8n +2;
  - 0xF1 +5, 0xF2 +6, 0xF3 +7, 0x85 / 0x86 +0;
  - 0x81 beat, 0x82 end.

  All 422 track chains parse to their end. The 5 that stopped in the first pass each end with a note whose
  last byte, or a bend whose second byte, has bit 7 set; it is the track's last event before 0x82, and what
  the bit means is not traced. Free cells are declared opaque: they hold bytes left from earlier songs.

### Custom-data images (.AST)

Each .AST inflates to the SHA-1 of one custom-data dump:

- the 9 KN7000 `technics_romsets/kn7000/*.ic21`;
- `technics_roms/roms/kn6000/01ctmini.ic18` (= kn6500's).

The unit compresses `$(KN7000_CUSTOMDATA_<name>)` / `$(KN6000_CUSTOMDATA_01ctmini)` (`floppy/tools/kd/kd.mk`).
These are `kn7000/build/customdata/<name>.ic21` and `kn6000/build/01ctmini.ic18`, built by recursive make
from lane customdata's typed sources. The header words +8 / +0xC are never written by the saver
`func_4852D0E5`: they are the old contents of its stack frame (`kn7000/tools/ast_file.py`).

### WSA1R

- **.MID.** The SMF writer flushes whole 1024-byte windows (`SmfOut_WindowsFlushed` 0x126C, the length
  arithmetic at 0xF7789A; `wsa1/notes/FINDINGS-prom_b-smf-writer.md`). So 13 of the 16 files end with stale
  window bytes after the last track. The three demo1 files are not padded. Since 2026-10-31 the stale bytes
  are spelled as the copy they are, of the SMF's bytes 1024 earlier (`notes/floppy-leftovers-2026-10-31/`).
- **.SEQ.** The prom_b block store's blocks (`FINDINGS-prom_b-block-store.md`). Events use the KN5000 demo-song
  grammar (`floppy/kn5000/events.py`): bit 7 = status. It parses 443 of 444 chains ([INFERENCE]).

## What is typed but not yet named

No byte is generic any more, but many fields have only a neutral name: an offset name (`p<hex>`, `x<hex>`,
`m<hex>`, `h<hex>`, `e<hex>`) or a commented `.byte` row with its offset. By size:

- **PANEL MEMORY records** (.PMT, .LSW, and the songs' panel copies). PMR_PART's p00..p02 are the part's sound
  {program, bank LSB, bank MSB}, as lane customdata traced. The record's other fields have no reader traced:
  its loader is the one-touch writer's source (the triple tables at program 0x4858E19C), so a trace from that
  writer back into the panel parameter tables would name them in the shared include.
- **SOUND EDIT and voice records** (KN6000 .TM). The mod units and elements have no names.
  `TgPartAuxHdr45Get` and the other `TgPartAux*` accessors name the offsets they read, but not their meaning.
- **The .SQT song record's head** (+0x07..+0xCF, +0x100..+0x13F). The KN5000 lane's slot map
  (`notes/floppy-kn5000-2026-10-29/specs/sqt_slot_header.json`) names the KN5000's 0x800-byte record, but the
  KN6000/KN7000 record is longer and the offsets were not checked against a KN6000/KN7000 reader.
- **The WSA1R .SQF song record** past the fields the disk notes give, and the WSA1R panel blocks after the
  combination.
- **TCMP variation records**: bytes +0x01/+0x02, +0x0C..+0x0F, +0x12..+0x14 and +0x18..+0x1F.

## Naming round (2026-10-29, third pass)

- **Named: the WSA1R .TM records, every byte.** Technics' Reference Guide publishes the NORMAL SOUND layout
  (713 bytes: GENERAL DATA 217, TONE DATA 4 x 81, MODELING DATA 4 x 43) and the DRUM SOUND layout (KIT DATA
  0x98, SOUND SELECT 0x100, 128 NOTE DATA of 150). Both are transcribed in
  `wsa1/notes/sysex-probes/sound_layout.json` and checked to tile by `sysex_sound_layout.py`. These are the
  strides `SoundRam_ClearFourBanks` writes. `floppy/wsa1/gen_sound_macros.py` makes them into the named
  macros of `floppy/wsa1/include/wsa1_sound.inc`: 532 parameters, none of them `rsv_`.
- **Not named this round, and why:**
  - the KN6000/KN7000 panel-memory record's fields: the recall routine is not located. The library routines
    that index the record (0x3A90 / 0x750 strides, `func_4C01ED89`, `func_4C01F5FC`, the 0x4A part stride
    around `func_4C01F657`) are template copies and per-part sound fix-ups, not the field-by-field recall.
    **Since done** by lane kn67-field-names (c4a339f4c, `notes/data-semantics-2026-10-29/kn67-field-names.md`):
    the record is the live panel state (recall `func_4C021F33`), and the parameter-id trie names its fields
    in `PMR_*`; what keeps an `m<id>` / `p<hex>` name, and why, is listed in that note's "Open questions";
  - the KN6000 SOUND_MOD / VOICE_ELEM fields: the `TgPartAux*` accessors name offsets, not parameters, and the
    sound-edit screens' parameter tables were not traced;
  - the .SQT event reader and record head: no sequencer-player routine is named in `kn7000_manual.sym`, so the
    event lengths stay measured (since done: the lengths are the firmware's table 0x485B9328, lane
    kn67-field-names; the high bit below, 2026-10-31);
  - kn7asm quote stripping: changing it alters every kn7000 source that passes `.ascii \name` (CUSTOM records,
    styles), which belongs to those trees' lanes.

## Open questions

- The meanings above (the panel-memory record's are named since c4a339f4c; see above).
- ~~What the high bit in those 5 song events means.~~ Answered 2026-10-31
  (`notes/floppy-leftovers-2026-10-31/README.md`): a note's last byte is its duration in **beats**, read
  unsigned by the note handler (KN7000 `func_48459B49`, KN6000 `func_4C11938E`), so 141 / 216 are held
  notes; a bend's second byte is bits 8-15 of its 16-bit value, never masked.
- ~~The KN6000 .TM tail word.~~ Answered 2026-10-31: it is the firmware's checksum of the 40 sound records
  (KN6000 `func_4C07D7C1`, the same rule as the KN5000's), validated against RAM at power-on and recomputed
  after every load (`PostTmTransLoad`), so no load reads a file's word. It matches in 12 of the 50 files
  (13 was a miscount); the others carry a stale value.
- ~~What the 8 lines at the start of each WSA1R sound bank are.~~ Answered 2026-10-31: the USER 1 / USER 2
  sound-group names (16 per USER bank, 8 per 64 KB bank), read by `UserSoundBank_RemoteGroupNameAddr` and
  `SoundGroupName_Lookup`.
- Whether 'J KD' is the KN5000's SLIDE8K. If so, `scripts/build/compress_slide8k.py` could use `lzss_j.encode`
  instead of replaying reference decisions.
- **Macro strings across the two assemblers.** llvm-mc strips the quotes from a quoted macro argument, and
  kn7asm keeps them. So no `.ascii \name` macro serves both. The shared includes therefore leave names out of
  the macros (VOICE_HEAD_TAIL, SOUND_HEAD, PMR_NAME_HEAD / _TAIL), and the floppy sources write `.ascii`
  themselves. Giving kn7asm the GNU behaviour (quotes stripped, `"\name"` re-quotes) would let one macro take
  the name.

## Shared files touched

- `floppy/Makefile`: `MODELS`, one `include tools/kd/kd.mk`.
- `floppy/wsa1/disks.mk`, `floppy/kn6000/disks.mk`: clean-before-regenerate rules for the content-addressed
  `include/tm/`.
- `kn7000/src/include/panel_memory.inc`: the PMR_* section (generated by
  `floppy/tools/kd/gen_panel_macros.py`, between its BEGIN/END markers).
- `kn7000/src/include/voice_record.inc`: the SOUND EDIT section (SOUND_HEAD, SOUND_MOD) and VOICE_HEAD_TAIL.
- Both includes still build lane customdata's banks byte-exact: `make -C kn7000 verify-customdata` and
  `make -C kn6000 verify-customdata`.
- Removed: `floppy/tools/kd/zlib-1.0.4/`, `zdeflate104.c` and its Makefile. The deflate is now
  `kn7000/tools/zlib10_deflate.py`.
- Not touched: the root Makefile, `.gitignore`, `data_incbin_census.py`, `compare_roms.py`,
  `assert_byte_identical.py`.

## Website page draft

> **KN6000, KN7000 and WSA1R disk files**
>
> All three instruments write FAT12 1.44 MB diskettes. The KN6000 and KN7000 wrap most files in a small
> header: 'I KD' (KN6000) or 'J KD' (KN7000), a version word, a flags word and the part sizes, then one or two
> compressed parts. The KN6000 compresses with zlib 1.0.4 (deflate, level 6). It stores the zlib stream
> without its two header bytes but with its adler32. The KN7000 uses LZSS with an 8 KB ring and 3-to-10-byte
> matches, in which a reference holds an absolute ring position. Custom-data backups (.AST) are the whole
> 1.875 MB custom flash, deflated.
>
> A panel-memory file (.PMT) holds banks of 8 memories. Each memory is a list of tag/length records: a name,
> 72-byte part records and the effect, style and sequencer settings. The same record sits inside every song
> record and current-panel (.LSW) file, and is the source of the four one-touch settings a custom style saves.
> A sound-memory file (.TM) holds 40 sound-edit records and a user drum kit.
>
> A style file (.CMP) is the instrument's "TCMP" style memory, saved whole. It holds:
> - a header with a checksum and an allocator top;
> - 3 style records (name, four variation names, 20 owned variations);
> - 60 variation records (bars, meter, eight 24-field part set-ups, the stream offset);
> - a heap of 60 event streams.
>
> In a stream a position byte (0-95, 96 ticks a beat) precedes notes, controllers, program changes and pitch
> bends. F4 marks a beat and F5 ends the stream. A song file (.SQT) holds 1 or 10 song records, each with a
> 16-track directory, and an event memory of linked 256-byte cells.
>
> The WSA1R saves RAM windows: its sound flash (.TM: four banks of 64 tone records, a kit and 128 drum
> instruments), the user combination bank (.CMB: 128 combinations of 23 records), the song store's 256-byte
> blocks (.SEQ) and its workspace (.SQF), the panel, three re-map files, and Standard MIDI Files padded to 1 KB.
>
> All 36 softlist disks are rebuilt byte for byte from typed source in the disassembly repository
> (`floppy/`), with the compressed parts regenerated by the instruments' own coders.
