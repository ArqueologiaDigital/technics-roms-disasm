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

What stays opaque: 1 declaration in `floppy/wsa1`, `qsdisk/01WORKS_.SEQ` block 838 after its 0x82: 250 bytes
of 0xDF 0xF7 pairs, which no grammar explains (the other two free blocks of that file are 0xFF fill).

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
(`kn_soundram.py`) says so per file.

## N-8f18a2ad (panel-memory fields)

Already done on main before this wave: lane kn67-field-names named the PMR_* fields from the parameter-id
trie (c4a339f4c, `notes/data-semantics-2026-10-29/kn67-field-names.md`). `notes/floppy-others-2026-10-29/README.md`
still called it open; it now points there. What keeps a neutral name, and why, is that note's open-questions
list (its own register rows).

## Census rows (read-only run of `data_incbin_census.py`, count / bytes; generic is 0 before and after)

| tree          | opaque before | opaque after | generated after | media after    |
|---------------|---------------|--------------|-----------------|----------------|
| wsa1-floppy   | 180 / 50,503  | 1 / 250      | 9 / 4,032       | 29 / 620,454   |
| kn6000-floppy | 238 / 32,861  | 126 / 1,768  | 494 / 2,906,247 | 85 / 2,126,762 |
| kn7000-floppy | 90 / 11,122   | 96 / 5,270   | 111 / 4,152,022 | 1 / 17,078     |

wsa1-floppy's generated rose by the nine boot-stub includes, its media by the 13 .MID copies (16 / 613,706
before). kn7000-floppy's opaque count rose (90 -> 96) while its bytes fell: a tail is now split where the events
resume. The generated byte figures are sized only because the trees were built (the "before" run had them
unsized).

## Open

- KN6000 / KN7000: the 1,768 + 5,270 stale bytes no event order explains (declared opaque; not copies of
  any cell, `probes/sqt_residue.py`).
- WSA1R: block 838's 0xDF 0xF7 run.
- Which firmware path changes a KN6000 sound without recomputing the checksum (the 38 stale words).

## Website page draft (for the floppy formats page)

> **Leftovers on the disks.** The instruments write whole buffers, so files carry bytes past their data. The
> WSA1R moves files in kilobytes: a combination bank's last kilobyte repeats 0x100 bytes of the chunk before
> (combination 112), an SMF's last window repeats the window before, and a song file ends with free blocks of
> its block store. The KN6000 and KN7000 song cells keep, after a track's end, events of an earlier version of
> the song, often in the KN5000's own event order: the factory songs were converted from KN5000 files. A note's
> last byte is its duration in beats (0..255), so a few held notes have it above 127. The KN6000 sound file's
> last word is the sound records' checksum as RAM held it; the instrument recomputes it after a load, so a stale
> value does no harm. The WSA1R disks' PC boot sector is a small "not a bootable disk" stub.
