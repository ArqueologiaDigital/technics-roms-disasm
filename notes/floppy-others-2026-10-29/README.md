# floppy-others, 2026-10-29: the WSA1R, KN6000 and KN7000 softlist disks as typed source

Lane `floppy-others` of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md`). It covers the
9 SX-WSA1R disks (`wsa1_flop`), the 21 SX-KN6000 disks and the 6 SX-KN7000 disks (`kn6000_flop`, `kn7000_flop`,
from the 2026-10-18 rebuild). They are held on the FAT12 framework of lane floppy-kn5000 (`floppy/README.md`).
Each disk lives in `floppy/<model>/<disk>/`. Every one is FAT12, so this lane added no container of its own.

    make -C floppy gate-wsa1 gate-kn6000 gate-kn7000      # all 36 disks, SHA-1 checked
    make -C floppy src-wsa1 src-kn6000 src-kn7000         # regenerate the trees (describers below)
    make gate-floppy                                      # every model, from the root (in gate-all)

## Results

All 36 disks rebuild byte-for-byte. Census rows, at the lane's last commit (`data_incbin_census.py`,
count / bytes):

| tree          | generated | media  | opaque       | generic n | generic bytes |
|---------------|-----------|--------|--------------|-----------|---------------|
| wsa1-floppy   | 0 / 0     | 16 / 0 | 167 / 47,175 | 92        | 6,052,864     |
| kn6000-floppy | 494 / 0   | 85 / 0 | 237 / 32,791 | 1467      | 6,670,437     |
| kn7000-floppy | 111 / 0   | 1 / 0  | 90 / 11,122  | 106       | 1,039,008     |

These are the generic bytes before this lane started: wsa1 7,834,534, kn6000 5,058,008 and kn7000 4,172,513.
The KN6000 and KN7000 figures are not comparable before and after. Before, a compressed file counted at its
stored size. Now it is a generated stream plus its **inflated** payload, and an untyped payload counts at the
inflated size. The generated and media streams show 0 bytes because they are build products. The census
sizes them only from `<tree>/build/`, and the floppy build is in `floppy/build/`.

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
  - `floppy/tools/kd/zlib-1.0.4/` vendors the deflate half, unmodified, and `zdeflate104.c` drives it.
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

| model  | kind                                   | files            | how it is held                                                                                                   | status         |
|--------|----------------------------------------|------------------|------------------------------------------------------------------------------------------------------------------|----------------|
| KN6/7  | .CMP                                   | 82               | TCMP container typed in full, every event one per line (`kn_tcmp.py`, `kn_style.inc`)                            | typed          |
| KN6/7  | .SQT                                   | 101              | part 2: event cells and events typed (`kn_sqt.py`, `kn_song.inc`); part 1: track directory typed, rest reference | mostly typed   |
| KN6/7  | .AST                                   | 10               | generated: zdeflate104 of the custom-data image (below)                                                          | generated      |
| KN6/7  | .CNV                                   | 12               | generated: the build output of `kn7000/src/cnv/*.s`                                                              | generated      |
| KN6000 | .JPG                                   | 64               | the extracted file                                                                                               | media          |
| KN6/7  | .HMP                                   | 22               | the 0x18C-byte home-page record (halfwords), then the BMP cut out as a `.bmp`                                    | media + record |
| KN6000 | .TXT .ACT .PRE                         | 18               | `.ascii` lines                                                                                                   | typed          |
| KN6/7  | .VER                                   | 2                | a Cakewalk .WRK, chunk by chunk                                                                                  | typed          |
| KN6/7  | .PMT                                   | 72               | payload is the reference                                                                                         | **generic**    |
| KN6000 | .TM                                    | 50               | payload is the reference                                                                                         | **generic**    |
| KN6/7  | .LSW                                   | 80               | payload is the reference                                                                                         | **generic**    |
| KN7000 | .MSP .CST                              | 15               | payload is the reference                                                                                         | **generic**    |
| KN6000 | .EFC                                   | 2                | payload is the reference                                                                                         | **generic**    |
| KN6/7  | .MD .FAV                               | 4                | the reference                                                                                                    | **generic**    |
| WSA1R  | .MID                                   | 16               | the SMF cut out as a `.mid`; the stale rest of the last 1024-byte window opaque                                  | media + opaque |
| WSA1R  | .SEQ                                   | 10               | the song-store blocks typed; each chain's events one per line                                                    | typed          |
| WSA1R  | .TM .CMB .SQF .LSW .SLS .SRM .CRM .DRM | 92 (and 3 empty) | the reference                                                                                                    | **generic**    |

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
  The rest of the record is the reference: **open**.
- **Part 2** holds the 256-byte cells: flags, prev, next and 251 bytes.
- **Events: a measured grammar** (`probes/sqt_try.py`) ([INFERENCE]; no KN6000 or KN7000 song reader has been
  traced):
  - a tick byte before every channel or system event;
  - 0x9n +4, 0xAn +6, 0xBn +3, 0xCn +3, 0xDn +1, 0xEn +2, 0x8n +2;
  - 0xF1 +5, 0xF2 +6, 0xF3 +7, 0x85 / 0x86 +0;
  - 0x81 beat, 0x82 end.

  412 of 417 track chains parse to their end. The other 5 stay as reference bytes, and the unit names the
  status where parsing stopped. Free cells are declared opaque: they hold bytes left from earlier songs.

### Custom-data images (.AST)

Each .AST inflates to the SHA-1 of one custom-data dump:

- the 9 KN7000 `technics_romsets/kn7000/*.ic21`;
- `technics_roms/roms/kn6000/01ctmini.ic18` (= kn6500's).

The unit compresses `$(KN7000_CUSTOMDATA_<name>)` / `$(KN6000_CUSTOMDATA_01ctmini)` (`floppy/tools/kd/kd.mk`).
Until lane customdata's tree builds those images, the variables point at git-ignored copies of the dumps,
taken with a SHA-1 check. **Integration step:** set the variables to that tree's build outputs.

### WSA1R

- **.MID.** The SMF writer flushes whole 1024-byte windows (`SmfOut_WindowsFlushed` 0x126C, the length
  arithmetic at 0xF7789A; `wsa1/notes/FINDINGS-prom_b-smf-writer.md`). So 13 of the 16 files end with stale
  window bytes after the last track, and these are declared opaque. The three demo1 files are not padded.
- **.SEQ.** The prom_b block store's blocks (`FINDINGS-prom_b-block-store.md`). Events use the KN5000 demo-song
  grammar (`floppy/kn5000/events.py`): bit 7 = status. It parses 443 of 444 chains ([INFERENCE]).

## Still generic, and why (by bytes)

| kind                        | bytes (inflated) | what was tried / what it is                                                                                                                                                                                                  |
|-----------------------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| WSA1R .TM                   | 4,456,448        | "WSA SOUND RAM S0", a 16-char name list, then sound parameter records (RAM 0xE80000, DiskLoad_Sound). Low entropy (4-5 bits), not PCM. The record layout needs the L7A1429 parameter notes: not attempted.                   |
| KN6000/KN7000 .PMT          | 3,272,224        | 'IK '/'JK ' panel memory. A tag/length walk from any start resynchronises at one offset and stops (`probes/pmt_tlv.py`), so it is not the KN5000's PanelTlv list. The real layout needs the KN7000 PM loader: not found yet. |
| KN6000 .TM                  | 2,354,900        | "KN6000 SOUND RAM", then 66 slots of 712 bytes from +0x10 (42 open with a printable 16-char name), then 90 bytes. Measured, not traced; parameter fields unknown.                                                            |
| KN6000/KN7000 .SQT part 1   | 1,275,765        | the song records outside the track directory; fields unknown                                                                                                                                                                 |
| WSA1R .CMB                  | 1,184,768        | "ZZZZ" .. "WSA1", combination RAM 0x16300 bytes to 0xEC0000 (DiskLoad_Combination); not attempted                                                                                                                            |
| KN6000/KN7000 .LSW          | 589,296          | two parts, "ZZ" + 'IK '/'JK ' panel settings; not attempted                                                                                                                                                                  |
| WSA1R .SQF                  | 307,200          | the sequencer workspace 0xC00 or the ten bank copies (FINDINGS-prom_b-disk-and-file-menus.md has +4 / +5 / +0x1C / +0x100 / +0x7E); typing those few fields is the next step                                                 |
| KN7000 .CST, .MSP           | 192,836          | CST: a custom style (u32 size, names); MSP: "TPAD" (a TCMP-like header, "Compile Bank" records); not attempted                                                                                                               |
| WSA1R small kinds           | 104,448          | .LSW .SLS .SRM .CRM .DRM: RAM windows the disk notes name (0x7000, 0x5210, 0x5860, 0x5EB0)                                                                                                                                   |
| KN6000/KN7000 .EFC .MD .FAV | 9,364            | not attempted                                                                                                                                                                                                                |

None of these is declared opaque: each one can be decoded, and the time ran out.

## Open questions

- Which KN6000/KN7000 routine reads .SQT events? Tracing it would turn the measured lengths into cited ones,
  and could decode the 5 chains that stop.
- What .AST +8/+0xC and the .CST header's four addresses are.
- The TCMP variation record's +0x01/+0x02, +0x0C..+0x0F, +0x12..+0x14 and +0x18..+0x1F. The two bytes at +0x18
  are FF FF as in the built-in records' sound-unit parts.
- Whether 'J KD' is the KN5000 SLIDE8K. If so, `compress_slide8k.py` could become a plain encoder.

## Shared files touched

- `floppy/Makefile`: `MODELS` and one `include tools/kd/kd.mk` line.
- New in shared places: `floppy/tools/kd/`, `floppy/tools/kd.inc`, `kn_style.inc`, `kn_song.inc`.

Not touched: the root Makefile, `.gitignore`, `data_incbin_census.py` (its TREES rows existed),
`compare_roms.py`, `assert_byte_identical.py`.

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
> The WSA1R saves RAM windows: sound RAM (.TM), combinations (.CMB), the song store's 256-byte blocks (.SEQ)
> and its workspace (.SQF), plus Standard MIDI Files padded to 1 KB.
>
> All 36 softlist disks are rebuilt byte for byte from typed source in the disassembly repository
> (`floppy/`), with the compressed parts regenerated by the instruments' own coders.
