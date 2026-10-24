# KN7000 (PROGRAM 941): what a sequencer song can make the instrument do

Static reverse engineering, 2026-10-18 (research agent), of `baserom/kn7000_program.rom` (md5
`38079d4c334c46dca061a6339739dbbf`, base 0x48400000) and of the library it self-loads to
0x4C000000 (program file offset 0x3B8FD1). Nothing was run in MAME. **established** = read in code
or ROM data at the address given; **inferred** = follows from code read, last step not traced or
run; **unknown** = not determined. Scripts: `songrec/` (table at the end).

## 0. Corrections to the starting brief

| brief                                    | code                                                                                                                                              |
|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| due events popped by 0x48447FD2          | 0x48447FD2 drains the keybed FIFO (reads 0x98050004 at 0x484480A2) and posts M3 id 0x10700000 (source 1): local keyboard, not the sequencer       |
| ... and by 0x48453A99                    | correct: pop (0x484537FF) of the song output ring (0x5003CA00/02/04, entries 0x5003CA06/CB08/CF08), pumped by lib 0x4C014E75 into 0x4C01B6DF      |
| songs dispatched from the ISR 0x48447084 | the ISR only advances clock lanes; the engine service calls the player tick 0x484595F0 (at 0x48457549), then the recorder 0x4845A0B9 (0x4845755F) |
| LibParamSet takes (index << 24) \| id24  | 0x4C014A51 is the 942 export `PutM3Em` (entry 0x4C014A56); d0 top byte = source << 4 or sub-index, bits 23..0 = id; d1 top byte = part            |

## 1. The M3 parameter bus

Every setting change is an M3 message: word0 = source nibble (31..28), sub-index (27..24),
parameter id (23..0); word1 = value, with the part in its top byte for part-scoped ids. Names
from the 942 export table.

| routine             | address                       | role                                                                                                                    |
|---------------------|-------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| PutM3Em             | 0x4C014A51 (entry 0x4C014A56) | set in the live "Em" bank; classes 0x90/0x80, 0x700000, 0xB0007B go to the key path 0x48451AAC                          |
| PutM3Sqf / GetM3Sqf | 0x4C014B4D / 0x4C014984       | set / get in the "Sqf" (sequencer-file) bank                                                                            |
| M3SendProcess       | 0x4C014FD5                    | fan-out: Tgc 0x4C015020, Midi 0x4C015196, Seq 0x4C0152B7, Rhy 0x4C0153E3, Pad 0x4C01546E, App 0x4C0154F9, Cp 0x4C015577 |
| source filters      | 0x4858C0D4..0x4858C224        | per-process 12-entry jump tables (source 1..12)                                                                         |
| M3 queue push       | 0x4C02467F                    | ring 0x50018038 / 0x50019038 / 0x5001A038                                                                               |
| M3 dispatch         | 0x4C01B6DF                    | sources 4/5: track routing, then PutM3Em or MIDI only; 3/6: per-part MIDI routing; 2: MIDI channel routing              |
| GUI delivery        | 0x48414547                    | posts `EV_MMMDATA` (0x00050014) {id, value} to the GUI                                                                  |
| GUI subscription    | SetMmmFilter 0x4841C40A       | widgets register the ids they show, e.g. AcPmemNameProc 0x4841F482 subscribes to 0x80 and 0x600008                      |

Sources: 1 = panel / keyboard (0x16000000 or an event in PanelBtnActType3; 0x10700000 keybed),
2 = MIDI IN (0x484B2E17; SysEx tag +0x20000000 at 0x484B9B3F), 4 = song playback (0x48458712),
5 = playback of 0x98 notes (0x48458807), 6 = SysEx tag +0x60000000 (0x484B9B57). 3 and 7..12 unknown.

## 2. Event grammar and playback dispatch

A page is 256 bytes, `[0x80, prev u16, next u16]` and then a byte stream that continues in page
`next` (pages numbered from 1; inferred from data, consistent with the reader). A byte below 0x80
is a position within the beat (0..0x5F, 96 PPQN) followed by one event; a byte from 0x80 up is an
event. The ten ROM demo songs decode completely this way, one 0x82 per chain. Lengths: ROM table
0x485B9328 (read by 0x4845BC5B; every other status is -1). Event to M3: classifier 0x48458705;
M3 to event: encoder 0x484582D5 (class hash 0x485B9228).

| status    | len | meaning                                                     | M3 id (source 4)                                             | classifier / encoder    | verdict     |
|-----------|-----|-------------------------------------------------------------|--------------------------------------------------------------|-------------------------|-------------|
| 0x81      | 1   | next beat                                                   | none                                                         | reader 0x48459321       | inferred    |
| 0x82      | 1   | end of track: clears the play bits (0x48453D8B, 0x48453D1F) | none                                                         | 0x484597EE              | established |
| 0x84      | 1   | bar marker: tick-in-beat := 0                               | none                                                         | 0x48459834, 0x48459399  | inferred    |
| 0x80      | 3   | tempo = b1 + (b2 << 7) BPM                                  | 0x000004                                                     | 0x4845889A / 0x484584E5 | established |
| 0x85      | 1   | rhythm START (lane 0x5014967A, 0x48446153(4))               | 0x000001 = 1                                                 | 0x4845992B / 0x484584D5 | established |
| 0x86      | 1   | rhythm STOP (0x48446412(4))                                 | 0x000001 = 0                                                 | 0x48459951 / 0x484584DD | established |
| 0x8A      | 3   | PIC n = b1 + ((b2 & 0x3F) << 7), b2 bit 6 = USER            | 0x600014                                                     | 0x48458912 / 0x48458518 | established |
| 0x90-0x9F | 5   | note [9x, note, vel, dur u16]; 0x98 = recorded from MIDI IN | 0x900000 (0x98 as source 5)                                  | 0x484587FB / 0x48458666 | established |
| 0xA1-0xA3 | 7-9 | part parameter [Ax, part, flags, id(3), value(1-3)]         | any class-0x20 id, or class 0xB0 with a non-zero middle byte | 0x48458955 / 0x484583CA | established |
| 0xB0      | 4   | control change [B0, part, cc, value]                        | 0xB000cc                                                     | 0x48458839 / 0x48458641 | established |
| 0xC0      | 4   | program change [C0, prog, bank LSB, bank MSB]               | 0xC00000                                                     | 0x48458861 / 0x484586D5 | established |
| 0xD0      | 2   | channel aftertouch                                          | 0xD00000                                                     | 0x484588BA / 0x484586C7 | established |
| 0xE0      | 3   | pitch bend                                                  | 0xE00000                                                     | 0x484588E3 / 0x484586AC | established |
| 0xF1-0xF3 | 6-8 | global parameter [Fn, flags, id(3), value(n)]               | any class-0x00 or class-0x70 id                              | 0x48458A1E / 0x48458562 | established |
| 0xF4      | 9   | defined but never produced; read like F3                    | as F3                                                        | 0x48458A1E              | established |
| 0xF0      | -1  | SysEx is not a song event                                   | n/a                                                          | table 0x485B9328        | established |

In A/F events the flags byte restores bit 7 of the bytes that follow. The value width comes from
hash 0x485B92A8 (0x48458AC7): 0x000004 and 0x702023 take 2 bytes; 0x00B014/24/34/44/54, 0x00C000,
0x00E000 take 3; the rest 1. There are no lyric, marker or text events (lyrics are SMF-only,
MainSEQ_Read_1EventLyrics 0x484FDADF). The demo songs contain 0x80, 0x81, 0x82, 0x8A, 0x90, 0xB0,
0xC0, 0xD0, 0xE0 and one 0xA1 (id 0x20005F); no F-type, 0x84 or 0x85/0x86.

Playback: 0x484595F0 (tick) -> 0x4845979E (per-track step) reads an event (0x48459C98). 0x82, 0x84,
notes (0x48459B4E) and 0x85/0x86 are handled in place; everything else goes through the classifier
(0x4845996E). 0x80 -> PutM3Em at 0x48459988; 0x8A -> PutM3Em at 0x4845999F, then the slide-show
trigger 0x4845D863; otherwise the id must pass the whitelist 0x4845BC6D (call at 0x484599D2) or is
dropped; 0xD002 with value 0 posts 0x702023 (0x484599EA); on the CHORD-kind track (0x5004AE76)
PutM3Em directly (0x48459A29); otherwise 0x48453705 queues it, 0x48453A99 pops it and 0x4C01B6DF
dispatches it as source 4 (PutM3Em, or MIDI only when 0x4C01DA17 says so). PutM3Em then reaches the
tone generator, MIDI out, rhythm (0x48435ED9), pads, GUI and control panel. The recorder rejects
source 4.

## 3. What a song can change besides notes

Track kinds (names at 0x486773D8): 0x00-0x0F PART 1-16, 0x10 RIGHT1, 0x11 RIGHT2, 0x12 LEFT, 0x1B
CHORD, 0x1F B.PEDAL, 0x40 APC, 0x41 CONTROL, 0x42 RHYTHM. Default preset 0x485B91F8: RIGHT1,
RIGHT2, LEFT, PART 4, CHORD, CONTROL, RHYTHM, DRUMS, PART 5-9, 11-13. Playback (0x484599D2) and
recording (0x4845A15D) use the same whitelist check 0x4845BC6D:

| kind                         | list       | ids | contents                                                                                                                                                                           |
|------------------------------|------------|-----|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| parts (flag 0), B.PEDAL      | 0x485B9428 | 82  | notes, PC, AT, PB, CC 1, 5, 7, 10, 11, 64-67, 71-78, 80-83, 91-95, 120, 121, 126; 0xB08000/01/02/05; part params 0x20xxxx; 0x00B014..0x00B054; PIC 0x600014                        |
| PART 10 (flag 1, 0x485B974C) | 0x485B9574 | 62  | the same minus some CCs and RPNs                                                                                                                                                   |
| APC                          | 0x485B9670 | 12  | notes, 0xC080-0xC083, CC 7, 0x200000, 0xD001-0xD003, 0x702023, 0x000001                                                                                                            |
| CONTROL                      | 0x485B96A4 | 32  | the RHYTHM list + 0xC080-0xC083, 0x8002, 0x8006, 0x8008, 0x8020, 0x8031-0x8033, 0x8040, 0x8060, 0x8080, CC 7, 0x200000, 0x000000, 0x000003, 0x000080, 0x0000A0, 0xE000-0xE002, PIC |
| RHYTHM                       | 0x485B9728 | 8   | 0xD001-0xD003, 0x702023, 0x000001, 0xC000, 0xC004, 0x000004                                                                                                                        |
| CHORD (0x1B)                 | none       | all | 0x4845BC6D accepts every id for kinds without a list                                                                                                                               |

Named ids (labels from the firmware's own STEP RECORD labeller 0x4853E4A0, strings
0x48679158..0x486791E8):

| id                                                                                                       | meaning                                | evidence                                                           | verdict     |
|----------------------------------------------------------------------------------------------------------|----------------------------------------|--------------------------------------------------------------------|-------------|
| 0x000001                                                                                                 | rhythm START/STOP                      | labeller 0x4853E602; events 0x85/0x86; auto-recorded by 0x48453AE5 | established |
| 0x000004                                                                                                 | tempo 40..300                          | labeller TEMPO; event 0x80; SysEx F0 50 25                         | established |
| 0x00C000                                                                                                 | rhythm (style)                         | labeller RHYTHM; CustomStyleIndexFromParam 0x4848453B              | established |
| 0x00C004                                                                                                 | variation 1-4                          | labeller "VARI %d" 0x4853E520                                      | established |
| 0x00D001                                                                                                 | COUNT / INTRO 1 / INTRO 2              | labeller 0x4853E53E                                                | established |
| 0x00D002                                                                                                 | FILL IN 1 / 2                          | labeller 0x4853E58E                                                | established |
| 0x00D003                                                                                                 | ENDING 1 / 2                           | labeller 0x4853E5C9                                                | established |
| 0x702023                                                                                                 | FILL IN 1/2 panel-button event         | panel event 0x2023                                                 | established |
| 0x600014                                                                                                 | PIC                                    | event 0x8A                                                         | established |
| 0x600000                                                                                                 | chord (root / type)                    | labeller formats it with GetChordString 0x484212B1                 | established |
| 0x000080                                                                                                 | panel memory number 0..103             | MainGetPmemName 0x4841622E reads it; AcPmemNameProc subscribes     | established |
| 0x008080-0x008082                                                                                        | TECHNI-CHORD on/off, type, output part | TechniChordCompute 0x48472EBA; 0x48472E5B                          | established |
| 0x008033                                                                                                 | FADE IN/OUT 0..2                       | AcFadeBoxProc 0x48494115                                           | inferred    |
| 0x000003                                                                                                 | transpose (52..76)                     | SysEx template F0 7F 7F 04 04                                      | inferred    |
| 0x000000                                                                                                 | master fine tuning                     | SysEx template F0 7F 7F 04 03                                      | inferred    |
| 0xB08000-05                                                                                              | RPN 0, 1, 2, 5                         | id layout                                                          | inferred    |
| 0xA0, 0x8002, 0x8006, 0x8008, 0x8020, 0x8031, 0x8032, 0x8040, 0x8060, 0xC080-C083, 0xE000-E002, 0x200000 | CONTROL-track settings                 | SysEx templates exist for most                                     | unknown     |
| 0x20005F, 0x200081, 0x200088-9A, 0x2000A2, 0x2000B0-BF, 0x204080/81, 0x00B0x4                            | part-scoped parameters on part tracks  | Technics SysEx groups 00 02 xx / 00 10 xx                          | unknown     |

So: voices, mixer and sound controllers (C0 and CCs on part tracks), rhythm style, variation,
intro, fill, ending, start/stop and tempo can all change mid-song (established). The panel-memory
number 0x80 is on the CONTROL list; that replaying it performs the recall is inferred. There is no
KN5000-style panel-record snapshot in the events. Global effect types (0xA000/0xA100/0xA200) are on
no list, so they cannot change mid-song (established). Drawbars and sound-edit parameters: unknown
(candidates 0x200088..0x2000BF). Each 0x8E0-byte song record (Rec8E0TablePtr 0x48456E49) also holds a
full settings snapshot that the PANEL WRITE help text (0x48677798) says is applied at SEQUENCER
RESET; the SMF importer fills it through PutM3Sqf (0x48547CBE).

**Does the GUI follow?** There is no target-title field. M3SendProcessApp (0x4C0154F9) accepts
every source except 12 and calls 0x48414547, which posts `EV_MMMDATA`; every widget that
subscribed with SetMmmFilter redraws, so a replayed variation, tempo, panel memory or part volume
updates the open screen (established). Nothing was found that switches screens the way the
KN5000's per-title records do (unknown, probably not).

## 4. Recording on the instrument (established from code, not run)

1. M3SendProcessSeq 0x4C0152B7 accepts sources 1, 2, 3, 7, 8, 9 (table 0x4858C164) and rejects 4/5
   (its own playback), 6 and 10-12, and sub-indices 4 and 5.
2. It walks the per-track routing table 0x50014852 (0x4C01D95E), set by arming (0x48454701): CONTROL
   and RHYTHM 0xFE (everything), CHORD and APC 0x1B (everything), part tracks their part number.
3. It calls the record entry 0x484538E9: if the track is armed and the sequencer running, it pushes
   {measure, tick, track, id, value} into the record ring 0x5003BDF8 (0x48453686). Source 7 is
   skipped at 0x48453965. While stopped only a note is taken, and it starts the recording (sync
   start, 0x48453A02).
4. The recorder 0x4845A0B9 pops the ring (0x48453768), applies the whitelist (0x4845A15D), encodes
   (0x4845A170) and inserts into the track (0x4845A32C).
5. 0x48453AE5 (called from 0x48445040) records rhythm start/stop (id 0x000001) into the APC and
   CONTROL tracks.

So a user can record an automated performance on the instrument: on a CONTROL track rhythm,
variation, intro, fill, ending, start/stop, tempo, transpose, panel-memory number, TECHNI-CHORD,
fade and PIC (as F-type events); on part tracks voice changes and mixer moves. Not recorded: the
sequencer's own playback, ids not on the track's list (effect types, and every 0x70xxxx panel event
except 0x702023), source-6 messages. Whether incoming SysEx is recorded is unknown (it depends on
the source tag context byte +0x1D selects in 0x484B9B30).

## 5. SysEx

**Receive (established).** The RX ISR 0x484B1E86 routes SysEx into its own FIFO (MErxFifoWrite
0x4C024A0A, 0x500208A0; port 2 0x50020CB4); the assemblers 0x484B9D1A / 0x484B9BE3 hand a complete
message to 0x484BA1D4 / 0x484BA212, gated by bit 0 of the MIDI field 0x484B33E9(4) (0x50150F56
bits 5..6; set = ignore, inferred). The matcher 0x484C01F4 recognises Technics (0x50), GS (0x41),
XG (0x43) and universal (0x7E/0x7F) messages; handlers 0x484BA25E (Technics control), 0x484BC4AF
(universal), 0x484BD3BC (GS), 0x484BE16A (XG), 0x484C1B72 (Technics bulk/data, not traced); the
callback 0x484B9B61 applies the result (PutM3Em or a push onto the M3 queue). 260 RX descriptors;
the panel-control ones use `F0 50 2C 20 31 1F grp sub par val F7` (rhythm, variation,
0xC080-83, intro / fill / ending, panel memory 0x80, tempo `F0 50 25 lo hi F7`, TECHNI-CHORD, fade,
PIC, effect types, part parameters); GS/XG cover master volume and tuning, effect parameters,
scale tuning 0x2000C0-CB, controller destinations and sound controllers. So SysEx remote control
of panel functions and parameters exists.

**Transmit.** M3 messages reach 0x484B30B4; the MIDI process accepts source 4, so song playback
gets there too. When bit 1 of the same field is clear it sends SysEx through 0x484B9E5C (lookup
0x484BFE64) and MidiTx 0x484B3A62 (path established, enabling setting inferred).

**SysEx and songs.** Raw SysEx is never stored (0xF0 is invalid in the length table; the encoder
never produces it). Loading an SMF (LoadSmf 0x485466DE): F0/F7 events (0x48546B0C) go to 0x48547ADB,
which runs the same matcher (context 0x50081F84) with callback 0x48547C76; in the setup phase
(0x50081A40 == 0) the value goes into the initial settings (PutM3Sqf 0x48547CBE), afterwards it
becomes a song event (encoder 0x48547D05); PIC SysEx becomes an 0x8A event (0x48547E4D). Recognised
SysEx thus survives as parameter events or initial settings; unrecognised SysEx is dropped
(established path, not run).

## 6. Open

- Record a session in MAME (CONTROL track: variation, fill, panel memory, tempo), save, census, replay.
- Name the unknown ids (set handlers through the trie 0x4C01BB0C, or the MIDI implementation chart).
- Trace the set handler of 0x80 (panel-memory recall) and the SysEx source tag (0x484B9B30 / +0x1D).
- Trace the type-4 Technics bulk SysEx 0x484C1B72.
- Explain the tempo value 250 every demo song opens with.

## Reproduce (scripts in `songrec/`)

| script                       | question it answers                                                         | command                                                                                                               |
|------------------------------|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `song_tables.py`             | the length table, whitelists, presets, encoder and value-size hashes        | `python3 -I song_tables.py`                                                                                           |
| `song_event_census.py`       | which statuses and A/F ids occur in song page data                          | `python3 -I song_event_census.py ROM demo*_pages.bin` (pages from kn7000_mame `tools/slideshow/demo_song_extract.py`) |
| `sysex_desc.py`              | M3 id to transmit SysEx template                                            | `python3 -I sysex_desc.py`                                                                                            |
| `sysex_rx_ids.py`            | the ids an incoming SysEx can set                                           | `python3 -I sysex_rx_ids.py`                                                                                          |
| `callrefs.py`, `idrefs.py`   | the callers of an address; the functions that load an id                    | `python3 -I callrefs.py 0x4845a0be`                                                                                   |
| `dv.py`                      | named disassembly of a range (`tools/dis_view.py` with its symbol-list fix) | `python3 -I dv.py 0x48458705 0x48458830`                                                                              |
| `romread.py`, `padtables.py` | helpers: read the image by CPU address; align Markdown tables               | imported / `python3 -I padtables.py < in.md`                                                                          |
