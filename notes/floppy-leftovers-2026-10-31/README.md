# Floppy leftovers, 2026-10-31: the WSA1R / KN6000 / KN7000 disks' stale bytes, typed or proven copies

Lane `floppies` of wave 4 (`~/compartilhado/tmp/open-items-wave3/WAVE4.md`). It takes the non-KN5000 rows of the
open-items register's "floppies" section: the opaque groups of `data_incbin_census.py --list opaque` for
`wsa1-floppy`, `kn6000-floppy` and `kn7000-floppy`, and the M questions of `notes/floppy-others-2026-10-29/`.
Probes: `probes/README.md`.

    make -C floppy src-wsa1 src-kn6000 src-kn7000     # regenerate (the describers below)
    make gate-floppy                                  # all 50 floppies, SHA-1 checked

## WSA1R

| leftover                                | what it is (evidence)                                                                                                                                                                                                                                                                                                                           | spelled as                                                                                                  |
|-----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| boot code, 9 x 448 B                    | one PC boot stub on all nine disks (`notes/open-items/probes/wsa1_boot_sectors.py`): print "This is not a bootable disk ..." with INT 10h, wait for a key (INT 16h), INT 19h. [INFERENCE] written by the tool that made the images; the instrument's own formatter writes `jmp $`                                                               | `floppy/tools/pc_boot_stub.s`, 16-bit x86, assembled by `floppy/Makefile` (`llvm-mc -triple=i386`)          |
| .CMB +0x16300..+0x163FF, 13 x 256 B     | a copy of +0x13700..+0x137FF, the first 0x100 bytes of combination 112, in all 13 files (`probes/wsa1_leftovers.py`). `DiskSave_StreamLinkRamToFile` (prom_a 0xFE2AA9, mode 1) fetches the bank in 8 chunks of 0x2C00 and one of 0x300 and writes each window 0x400 at a time; the last write carries window +0x300..+0x3FF of the chunk before | the `cmb_*` records it repeats, under `<file>_StaleCopyOfC112`                                              |
| .MID past the last track, 13 files      | a copy of the SMF's bytes 1024 earlier: the 1024-byte window buffer is reused for each window (`SmfOut_WindowsFlushed`); all 13 (`probes/wsa1_leftovers.py`)                                                                                                                                                                                    | `.incbin "<x>.smf.mid", n - 1024, len` of the committed .mid                                                |
| .SEQ blocks in no chain, 145 (36,395 B) | the file is a whole number of KB: it ends with the first blocks of the free chain, the .SQF's +0xB8 free head first (7 files); `01E_TEC1` and `01220497` also hold blocks on neither list (used + free < 1292). 118 of `01220497`'s repeat a chained block (k = k - 139). `probes/seq_layout.py`, `seq_orphans.py`                              | the chained block's own lines; `cmb_*` records (`02SD_CMB`); else song events where the grammar parses them |
| sound bank +0x10..+0x8F (N-336ff4a8)    | the USER 1 / USER 2 sound-group names: `UserSoundBank_RemoteGroupNameAddr` (prom_a 0xF9F7F6) and `SoundGroupName_Lookup` (prom_a 0xFC2035) read group H at 0xE80010 / 0xEA0010 + 16*H (H 0-7) and 0xE90010 / 0xEB0010 + 16*(H-8)                                                                                                                | `.ascii` lines under `<file>_Bank<n>_GroupNames`, each with its USER and group number                       |

Nothing stays opaque in `floppy/wsa1` since 2026-11-02 (lane open6/misc2).  `qsdisk/01WORKS_.SEQ` block 838's
250 bytes after its 0x82 are exactly `DF F7` 125 times (DF at even file offsets), now spelled `.rept 125` /
`.byte 0xdf, 0xf7` (`floppy/wsa1/formats.py`).  The same two values, 0xFF with bit 3 and / or bit 5 cleared, fill
the tails after the 0x82 of blocks 837 (249 B, with some 0xFF) and 245 (188 B, `FF FF FF F7`), the last blocks
of two live chains; no other WSA1R disk has such a run, and no WSA1R source holds 0xF7DF / 0xDFF7 as a constant
(`notes/misc2-2026-11-02/probes/wsa1_f7df_runs.py`).  [INFERENCE] RAM of the block store that nothing wrote
after the blocks' end of track (power-on contents), not song data.  (The other two free blocks of that file
are 0xFF fill.)

## KN6000 / KN7000 .SQT

**The bytes after a track's 0x82 and the free cells are stale events in two orders** (`kn_sqt.py`
`stale_tokens`): this model's tick-first order, and the KN5000's status-first order (`floppy/kn5000/events.py`:
`9n tick key velocity ticks beats`). In 76 of 327 tails the KN5000-order notes occur, tick, key, velocity and
duration equal and in order, among the notes of the same track's live events (`probes/sqt_tails2.py`).
[INFERENCE] these songs were made from KN5000 song files converted in place; the converted stream, shorter, left
the end of the original. The tokenizer picks, per event, the order that parses furthest (a dynamic programme);
what neither explains stays declared opaque from the next point where 12 bytes parse again. It types < 1 % of
random bytes. Macros: `k5_note`, `k5_run`, `k5_ev` in `floppy/tools/kn_song.inc`.

| model  | stale bytes | tick-first | KN5000 order | cut events | still opaque                                               |
|--------|-------------|------------|--------------|------------|------------------------------------------------------------|
| KN6000 | 32,861      | 17,923     | 12,046       | 1,124      | 1,768 (126 declarations)                                   |
| KN7000 | 11,122      | 5,541      | 222          | 89         | 5,270 (96 declarations; the demo cells' RAM noise, mostly) |

The KN6000 free cell (`ca6000s/03SMBMIX.SQT`, 251 B) is typed the same way.

**What the still-opaque bytes are** (lane open6/misc2, 2026-11-02, `notes/misc2-2026-11-02/probes/sqt_residue_bits.py`):

| part                            | declarations / bytes | what the probe shows                                                                                                                                                     |
|---------------------------------|----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| KN7000, declarations of >= 32 B | 36 / 4,997           | set bits by file offset mod 8: 3.23 3.27 3.57 3.62 4.74 4.76 4.46 4.58, against a flat 2.4-2.5 for the files' other bytes. [INFERENCE] power-on RAM contents, not events |
| KN7000 < 32 B, KN6000 < 32 B    | 60 / 273, 119 / 498  | event fragments (0x90 note statuses, 0x81 beats), mostly followed by 0x81 / 0x80 / 0xFF: events cut where neither order resynchronises                                   |
| KN6000, declarations of >= 32 B | 7 / 1,270            | no phase bias; mostly 0xFF with 0x80 / 0x40 / 0x90 runs: not explained                                                                                                   |

So the KN7000's large residue is explained: RAM nothing wrote has no source, and opaque is its final spelling.
What is left is the cut fragments (a tokenizer step) and the KN6000's seven large runs.

**The high bit in 5 song events (N-79dbbec8).** Traced in KN7000 941: the per-track step `func_48459799`
reads an event with `func_48459C93` (bytes copied unmasked). For a note, `func_48459B49` reads +4 and +3
through `func_48459032` (seek, read, `extbu`: unsigned) and sets the note-off at the track's beat + byte +4,
plus one when tick + byte +3 reaches 0x60 (0x48459BEA..0x48459C1D). So +3 is the duration's ticks and +4 its
**beats, 0..255**: the 4 notes with 141 / 216 are held that long (each is its track's last event). The KN6000
twin is `func_4C11938E` (same code, RAM 0x5005B81C / 0x5005B8C4). For a bend, the encoder `func_484586AC`
writes value & 0xFF and value >> 8, and the classifier `func_484588DE` rebuilds lsb | msb << 8: the second
byte is bits 8-15 of the 16-bit M3 value (0xBF in `ca6dim/01PIANOD`), nothing masks it. `sq_note`'s
parameters are now `dur_ticks, dur_beats` (both `kn_song.inc` twins).

## KN6000 .TM tail word (N-db6d83e9)

The KN6000's checksum is `func_4C07D7C1`: ~(LE16 sum of 0x37A0 halfwords from RAM 0x8402F4F4), the sound
block 0x8402F4E4 + 0x10, i.e. the 40 sound records (KN7000 `func_4844AC9B`, 0x840327F8; the KN5000's rule).
It lives at block +0xB7F8. Writers: the power-on default set-up `func_4C07DD55`, the per-sound store
`func_4C07D7E0`, and `func_4C07DEC8` (signature and checksum), which `PostTmTransLoad` (0x4C07DF7B) calls after
every .TM load. The power-on check `func_4C07E1D4` compares RAM against it and re-initialises on a mismatch. So
**no load reads a file's word**: the file holds RAM's value at save time. It matches in 12 of 50 files
(`probes/tm_tail.py`, `tm_tail2.py`: no other range or sum matches more; the earlier "13" was a miscount);
[INFERENCE] the other 38 were saved after sounds were changed by a path that does not recompute it. The describer
(`kn_soundram.py`) says so per file.  Their words are carried over from an earlier recompute (Open, below).

## N-8f18a2ad (panel-memory fields)

Already done on main before this wave: lane kn67-field-names named the PMR_* fields from the parameter-id
trie (c4a339f4c, `notes/data-semantics-2026-10-29/kn67-field-names.md`). `notes/floppy-others-2026-10-29/README.md`
still called it open; it now points there. What keeps a neutral name, and why, is that note's open-questions
list (its own register rows).

## Census rows (read-only run of `data_incbin_census.py`, count / bytes; generic is 0 before and after)

| tree          | opaque before | opaque after | generated after | media after    |
|---------------|---------------|--------------|-----------------|----------------|
| wsa1-floppy   | 180 / 50,503  | 1 / 250      | 9 / 4,032       | 29 / 620,454   |
| (2026-11-02)  |               | 0 / 0        |                 |                |
| kn6000-floppy | 238 / 32,861  | 126 / 1,768  | 494 / 2,906,247 | 85 / 2,126,762 |
| kn7000-floppy | 90 / 11,122   | 96 / 5,270   | 111 / 4,152,022 | 1 / 17,078     |

wsa1-floppy's generated rose by the nine boot-stub includes, its media by the 13 .MID copies (16 / 613,706
before). kn7000-floppy's opaque count rose (90 -> 96) while its bytes fell: a tail is now split where the events
resume. The generated byte figures are sized only because the trees were built (the "before" run had them
unsized).

## .SQT stale bytes, layer cuts (2026-11-06, lane kn7000-names; N-e140c8dc, O-kn6000-floppy-unknown-dump-397763)

Most of what no event order explained was the tokenizer cutting events in the wrong place, not other data.  A
save writes its stream from the cell's start and ends it with 0x82, so the bytes after an end of track are an
older save's, cut wherever the newer one stopped.  `kn_sqt.stale_tokens` now:

- at a **layer start** (the bytes' start, or right after a stale 0x82) offers every prefix of a run of data bytes
  as "cut at the start", so the rest can begin the next event with its tick (before: the whole run, so the tick
  of the next event was swallowed: `4a 5e 00 | 5e 90 31 59 09 01` is three cut bytes and a whole note), and a
  tick-first event whose tick was the layer before's last byte;
- at the **end** of the bytes, a tick-first event cut short (`3f 90 32 55 15`), as it already did for a
  KN5000-order note;
- spells a run of 0xFF (at most two bytes with one bit clear) as `.fill` (the song memory is 0xFF until a save
  writes it; free cells are often 251 x 0xFF);
- spells a run of at least 64 bytes that is, at one alignment, at least 75 % the bytes of one of the file's song
  records as `.byte` rows headed "the image of song-record bytes +0xA..+0xB" (`kn_sqt.record_image`).

The two song-record images (`probes/sqt_record_images.py`): ca6000s `03SMBMIX` free cell, 215 B = record
+0x775..+0x84B (186 equal to its own song 1, 179..193 to the disk's nine other files, always at +0x775);
ca6dim `08ENKADC`, 237 B = +0x57B..+0x667 (220 equal to its own, 236 to `12HEITER`'s song 2).  [INFERENCE] the
cell's RAM held a song record's image before it held events; how is not traced.

| bytes (`probes/sqt_stale_cover.py`) | KN6000 before | KN6000 after | KN7000 before | KN7000 after |
|-------------------------------------|---------------|--------------|---------------|--------------|
| tick-first events                   | 17,923        | 18,528       | 5,541         | 5,847        |
| KN5000-order events                 | 12,046        | 11,650       | 222           | 0            |
| cut events                          | 1,124         | 1,377        | 89            | 230          |
| erased (0xFF)                       | -             | 818          | -             | 0            |
| song-record images                  | -             | 452          | -             | 0            |
| unexplained (declared opaque)       | 1,768         | 36           | 5,270         | 5,045        |
| total                               | 32,861        | 32,861       | 11,122        | 11,122       |

The KN7000's 222 "KN5000-order" bytes were all misreadings: with the layer cuts every one reads tick-first.  So
the KN5000-order layers are a KN6000 trait only.  `data_incbin_census.py` (read-only): kn6000-floppy opaque
126 / 1,768 -> 3 / 36, kn7000-floppy 96 / 5,270 -> 39 / 5,045; generic 0 in both.  The false-positive rate on
uniform random bytes rose from 0.71 % to 0.81 % (`probes/sqt_random_types.py`, seeded); 0 random runs pass the
erased or record-image rules.

What stays opaque:

- KN7000, 5,045 B in 39 runs: RAM nothing wrote [INFERENCE], now with a measurement (`probes/sqt_ram_phase.py`):
  their bytes hold 3.22 / 3.26 / 3.56 / 3.61 set bits at RAM address mod 8 = 0..3 and 4.75 / 4.78 / 4.48 / 4.59
  at 4..7, while the typed stale events hold 2.4..2.5 at every position.  Variable-length events cannot know
  their address mod 8; power-up DRAM content does.  No run reaches the record-image share (at most 28 %).
- KN6000, 36 B in 3 runs: `08GIVEUP` (ca6000s) twice `c1 xx 12 00 0x` between two beats, a status-first 0xC1
  with 4 data bytes where every 0xC1 on the KN5000 / WSA1R disks has 5 (10 B); `05TULPEN` (ca6000s) 26 bytes of
  0x81 / 0x83 / 0xC3 with five data bytes among them, no event shape.

## Open

- ~~KN6000 / KN7000: the 1,768 + 5,270 stale bytes no event order explains.~~ CLOSED 2026-11-06 (section
  "layer cuts" above): 36 + 5,045 are left, declared opaque with what they are (KN7000: RAM with an address-mod-8
  bit pattern; KN6000: two short 0xC1 events and 26 status bytes).
- ~~WSA1R: block 838's 0xDF 0xF7 run.~~ CLOSED 2026-11-02 (above).
- Which firmware path changes a KN6000 sound without recomputing the checksum (the 38 stale words).
  2026-11-02 (`notes/misc2-2026-11-02/probes/tm_stale_carryover.py`): the stale words are carried over.  Three
  ca6001 files keep the true checksum of 03MARSH1, the file before them, and 0xB0C5 is shared by 24 files on
  eight disks.  So the word is the last checksum RAM computed (after a .TM load, or at power-on), and the
  sounds were changed after it.  In v7.1 every routine that names the sound block (0x8402F4E4 / 0x8402F4F4)
  recomputes the checksum or is followed by `func_4C07DEC8` (`func_4C07D7E0`, `func_4C07DD55`, `func_4C07DDDE`
  / `func_4C07DE82` through PostTmTransLoad and its siblings, `func_4C162473` through `func_4C07E006`).  The only
  routine handing out a record pointer, `func_4C07E096`, has one caller, which reads a name.  **BLOCKED**: the
  path is not in v7.1's static references (v7.1's installer is dated 2004-03-19 in `kn6-71.zip`; which version
  made the disks is not known).  It needs an older KN6000 program
  (none is in the mirror: `kn6-71.zip` only), or the KN6000 table flash to test whether 0xB0C5 is the default
  set's checksum (the KN7000's 40 defaults give 0xFDC2).

## Website page draft (for the floppy formats page)

> **Leftovers on the disks.** The instruments write whole buffers, so files carry bytes past their data. The
> WSA1R moves files in kilobytes: a combination bank's last kilobyte repeats 0x100 bytes of the chunk before
> (combination 112), an SMF's last window repeats the window before, and a song file ends with free blocks of
> its block store. The KN6000 and KN7000 song cells keep, after a track's end, events of an earlier version of
> the song. On the KN6000 these are often in the KN5000's own event order (11,650 of 32,861 stale bytes; on the
> KN7000 none), which suggests, as an inference, that the KN6000's factory songs were converted from
> KN5000 files. An older save's events begin right after the newer one's end of track, cut mid-event; a few
> cells hold an image of a song record instead, and the KN7000's untouched song memory shows its power-up
> bit pattern. A note's
> last byte is its duration in beats (0..255), so a few held notes have it above 127. The KN6000 sound file's
> last word is the sound records' checksum as RAM held it; the instrument recomputes it after a load, so a stale
> value does no harm. The WSA1R disks' PC boot sector is a small "not a bootable disk" stub.
