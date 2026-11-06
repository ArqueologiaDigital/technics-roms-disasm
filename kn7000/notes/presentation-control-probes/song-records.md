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
2 = MIDI IN channel messages (0x484B2E17; func_484B9B2E adds +0x20000000 when bit 0 of the
per-channel context's +0x1D is set, which func_484B2F27 / func_484B2FEC do for 0x50150AE4 / 0x50150D04),
3 = MIDI IN SysEx (func_484BFBEA, called by 72 SysEx handlers, adds +0x30000000 when bit 0 of the SysEx
context's +0x1F is set; func_484BA1D1 / func_484BA20F store 0x01 / 0x41 there), 4 = song playback
(0x48458712), 5 = playback of 0x98 notes (0x48458807), 6 = bit 1 of the same bytes (+0x60000000 in
both routines; no writer of bit 1 was found, so source 6 looks unused). (Corrected 2026-11-02: this
line used to give 0x484B9B30, a channel-message routine, as the SysEx tag.) 7..12 unknown.

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

| id                                                           | meaning                                                                     | evidence                                                                                                                                                                                                                                                                                                            | verdict                                           |
|--------------------------------------------------------------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| 0x000001                                                     | rhythm START/STOP                                                           | labeller 0x4853E602; events 0x85/0x86; auto-recorded by 0x48453AE5                                                                                                                                                                                                                                                  | established                                       |
| 0x000004                                                     | tempo 40..300                                                               | labeller TEMPO; event 0x80; SysEx F0 50 25                                                                                                                                                                                                                                                                          | established                                       |
| 0x00C000                                                     | rhythm (style)                                                              | labeller RHYTHM; CustomStyleIndexFromParam 0x4848453B                                                                                                                                                                                                                                                               | established                                       |
| 0x00C004                                                     | variation 1-4                                                               | labeller "VARI %d" 0x4853E520                                                                                                                                                                                                                                                                                       | established                                       |
| 0x00D001                                                     | COUNT / INTRO 1 / INTRO 2                                                   | labeller 0x4853E53E                                                                                                                                                                                                                                                                                                 | established                                       |
| 0x00D002                                                     | FILL IN 1 / 2                                                               | labeller 0x4853E58E                                                                                                                                                                                                                                                                                                 | established                                       |
| 0x00D003                                                     | ENDING 1 / 2                                                                | labeller 0x4853E5C9                                                                                                                                                                                                                                                                                                 | established                                       |
| 0x702023                                                     | FILL IN 1/2 panel-button event                                              | panel event 0x2023                                                                                                                                                                                                                                                                                                  | established                                       |
| 0x600014                                                     | PIC                                                                         | event 0x8A                                                                                                                                                                                                                                                                                                          | established                                       |
| 0x600000                                                     | chord (root / type)                                                         | labeller formats it with GetChordString 0x484212B1                                                                                                                                                                                                                                                                  | established                                       |
| 0x000080                                                     | panel memory number; setting it recalls memory n (1..104)                   | MainGetPmemName 0x4841622E reads it; AcPmemNameProc subscribes; record kind 9 -> func_4C016C5C -> func_4C021827                                                                                                                                                                                                     | established                                       |
| 0x008080-0x008082                                            | TECHNI-CHORD on/off, type, output part                                      | TechniChordCompute 0x48472EBA; 0x48472E5B                                                                                                                                                                                                                                                                           | established                                       |
| 0x008033                                                     | FADE IN/OUT 0..2                                                            | AcFadeBoxProc 0x48494115                                                                                                                                                                                                                                                                                            | inferred                                          |
| 0x000003                                                     | transpose (52..76)                                                          | SysEx template F0 7F 7F 04 04                                                                                                                                                                                                                                                                                       | inferred                                          |
| 0x000000                                                     | master fine tuning                                                          | SysEx template F0 7F 7F 04 03                                                                                                                                                                                                                                                                                       | inferred                                          |
| 0xB08000-05                                                  | RPN 0, 1, 2, 5                                                              | id layout                                                                                                                                                                                                                                                                                                           | inferred                                          |
| 0x008020                                                     | REVERB on/off (bit 7 of block 0x4C byte 0)                                  | PutM3Em in REVSELTitleFunc; EffDispGrid reads it                                                                                                                                                                                                                                                                    | inferred (caller name)                            |
| 0x008060                                                     | split mode 0..3                                                             | AcSplitBoxProc reads it                                                                                                                                                                                                                                                                                             | inferred (caller name)                            |
| 0x00C080                                                     | APC / chord mode 0..3                                                       | ApcSelFunc, TtChordFinder, MainCOMP_RtcControl                                                                                                                                                                                                                                                                      | inferred (caller name)                            |
| 0x00C082, 0x00C083                                           | APC switches (1 bit each)                                                   | ApcSelFunc reads both                                                                                                                                                                                                                                                                                               | inferred (caller name)                            |
| 0x20005F                                                     | the part's DIGITAL EFFECT on/off                                            | PutM3Em in DSPSELTitleFunc; EffDispGrid                                                                                                                                                                                                                                                                             | inferred (caller name)                            |
| 0x2000A2                                                     | the part's tremulant 0..7                                                   | AcTabTremulantProc                                                                                                                                                                                                                                                                                                  | inferred (caller name)                            |
| 0x200090-0x200098                                            | the part's drawbars                                                         | kn67-field-names (drawbar records)                                                                                                                                                                                                                                                                                  | inferred                                          |
| 0x00B014-0x00B054                                            | the DSP (sound unit) groups' part keys                                      | SndUnitRecApply and friends read them                                                                                                                                                                                                                                                                               | inferred (caller name)                            |
| 0x0000A1                                                     | MUSIC STYLE ARRANGER MODE: 1 RHYTHM, 2 SOUND & RHYTHM, 3 PANEL MEMORY       | MSAModeBoxProc reads (MainGetM3Em) and writes (MainPutM3Em) it on the "MUSIC STYLE ARRANGER MODE" screen (menu RHYTHM / SOUND & RHYTHM / PANEL MEMORY); func_4C02AD08: 1 nothing, 2 the style's own setting for the variation (func_4C02ACA8), 3 recall PANEL MEMORY variation + 1 (func_4C0219BF -> func_4C021F33) | established                                       |
| 0x0000A0                                                     | MUSIC STYLE ARRANGER on (1) / off (0)                                       | func_4C029CF5 runs on a rhythm (0xC000) or variation (0xC004) change and acts, by mode 0xA1, only when it reads 1; the owner's manual p. 64 (MSA on: VARIATION 1-4 changes the panel per the mode)                                                                                                                  | inferred                                          |
| 0x200000                                                     | the part's MUTE (bit 7 of the part's volume byte)                           | MicEffMuteToggleFunc writes 1 / 0 (for CHORD 0x1B also part 0x1C); HarmPartMuteCheck; VCLSELTitleFunc subscribes (SetMmmFilter)                                                                                                                                                                                     | established (1 = muted: inferred from the toggle) |
| 0x008040                                                     | CONDUCTOR 0..5                                                              | panel_memory.inc tag 0x41 +0 (the KN5000's SndParam_Conductor; KN6000 code picks RIGHT1 / RIGHT2 from it)                                                                                                                                                                                                           | inferred                                          |
| 0x00E001, 0x00E002                                           | the pad parts' volume (bits 0-6), and bit 7 of the same byte                | panel_memory.inc tag 0x46 +0 (sent as controller 7 to parts 0x1D / 0x1E)                                                                                                                                                                                                                                            | inferred (0xE002's meaning: unknown)              |
| 0x00E000                                                     | a one-shot trigger, like intro / fill / ending                              | func_48460C22 answers -1 for 0xD001-D003 and 0xE000 alone; TX template `F0 50 2C 20 31 1F 01 00 32 vv F7`, 0..127; no panel record                                                                                                                                                                                  | partly: what it triggers is unknown               |
| 0x008002, 0x008006                                           | volume-like, default 127                                                    | func_4C01C124, the controller defaults of the full panel re-send, sets 0x8001 (MASTER VOLUME, universal SysEx 04 01), 0x8002, 0x8004, 0x8006 to 127; 0x8002's TX template `F0 50 2C 20 31 1F 00 00 10 vv F7`                                                                                                        | unknown                                           |
| 0x008031, 0x008032                                           | default 0                                                                   | func_4C01C124 sets both to 0; no panel record, no reader                                                                                                                                                                                                                                                            | unknown                                           |
| 0x008008                                                     | 0..127, tag 0x44 +8 bits 0-6                                                | func_484B0AAA / func_484B0B46 compare it (or 0x8006) with func_4C01D1A3's result and set bit 4 of the MIDI context byte 0x50150A3E                                                                                                                                                                                  | unknown                                           |
| 0x00C081                                                     | 0..3, tag 0x42 +4 bits 0-3; when non-zero it replaces 0xC080 (the APC mode) | func_4844EB15, func_4845127C (`C081 ? C081 : C080`)                                                                                                                                                                                                                                                                 | unknown (an APC-mode override)                    |
| 0x200081, 0x200088-8F, 0x200099-9A, 0x2000B0-BF, 0x204080/81 | part-scoped parameters on part tracks                                       | panel_memory.inc: 0x200088-8B RIGHT1-only nibbles +0x24/+0x25, 0x2000B0-BF bits +0x38/+0x39, 0x204080 bits 0-2 / 0x204081 bit 4 of +0x04 (TG code 0x85); no named reader                                                                                                                                            | unknown                                           |

So: voices, mixer and sound controllers (C0 and CCs on part tracks), rhythm style, variation,
intro, fill, ending, start/stop and tempo can all change mid-song (established). The panel-memory
number 0x80 is on the CONTROL list, and replaying it recalls that panel memory: PutM3Em finds no
special handler for 0x80 (func_4C0216A3's class tables), so func_4C015E50 runs the setter of the
record's kind 9 (func_4C015E50_Table 0x4858C318), func_4C016C5C, which stores the number and calls
func_4C021827 (n = 1..104; it recalls through func_4C021F33, the `memcpy(0x84000020, memory, 0x750)`
of kn67-field-names), unless the setter's flag argument has bit 0 (PutM3Em passes 0). Established
from code, not run (`songtable_m3_set_kinds.py`). There is no
KN5000-style panel-record snapshot in the events. Global effect types (0xA000/0xA100/0xA200) are on
no list, so they cannot change mid-song (established). Drawbars: 0x200090-0x200098 are on the part
list (inferred, from kn67-field-names); other sound-edit parameters: unknown. Each 0x8E0-byte song record (Rec8E0TablePtr 0x48456E49) also holds a
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
except 0x702023), source-6 messages. Incoming SysEx is recorded like a panel change: its results
carry source 3 (func_484BFBEA, section 1), which M3SendProcessSeq's table 0x4858C164 accepts (static
path, not run).

## 5. SysEx

**Receive (established).** The RX ISR 0x484B1E86 routes SysEx into its own FIFO (MErxFifoWrite
0x4C024A0A, 0x500208A0; port 2 0x50020CB4); the assemblers 0x484B9D1A / 0x484B9BE3 hand a complete
message to 0x484BA1D4 / 0x484BA212, gated by bit 0 of the MIDI field 0x484B33E9(4) (0x50150F56
bits 5..6; set = ignore, inferred). The matcher 0x484C01F4 recognises Technics (0x50), GS (0x41),
XG (0x43) and universal (0x7E/0x7F) messages; handlers 0x484BA25E (Technics control), 0x484BC4AF
(universal), 0x484BD3BC (GS), 0x484BE16A (XG), 0x484C1B72 (descriptor type 4, section 6); the
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

## 6. Open (status 2026-11-06, lane kn7000-names; before: 2026-11-02, lane mn10300-names, agent songtable)

- Record a session in MAME (CONTROL track: variation, fill, panel memory, tempo), save, census,
  replay. Still open: it needs a MAME run.
- **Unknown ids: more named, still open** (2026-11-06, lane kn7000-names; table in section 3,
  `song_id_users.py`, which also counts the Main* / Force / Non / Add wrappers and SetMmmFilter that
  `m3em_callers.py` misses). Named now: 0xA1 MUSIC STYLE ARRANGER MODE (established), 0xA0 MUSIC STYLE
  ARRANGER on/off (inferred), 0x200000 the part's MUTE (established); 0x8040 CONDUCTOR and 0xE001 the pad
  volume from `panel_memory.inc`. Still without a meaning: 0x8002, 0x8006, 0x8008, 0x8031, 0x8032, 0xC081,
  0xE000, 0xE002, 0x200081, 0x200088-8F/99-9A, 0x2000B0-BF, 0x204080/81 (what each row knows is in the
  table). The MIDI implementation chart is not at hand: the owner's manual (QQTG0671) has none; its MIDI
  chapter only names "EXCLUSIVE data". Next step: the GUI screens that edit them (search their TX templates' Technics
  parameter numbers, e.g. 0x8002 = `00 00 10`, in the panel-control SysEx tables, and each id in the
  AcMmm* / *Func handlers' MT_GetMmmParam1 answers), or a MAME run that watches the panel record bytes while
  the panel's buttons are pressed.
- **Set handler of 0x80: closed.** Kind 9 -> func_4C016C5C -> func_4C021827 recalls panel memory n
  (section 3). **SysEx source tag: closed.** Source 3, from func_484BFBEA and context +0x1F; the
  routine this list named (0x484B9B30, +0x1D) tags channel messages with source 2 (section 1).
- **Type-4 Technics SysEx 0x484C1B72: closed** (2026-11-06, lane kn7000-names, section 7,
  `sysex_pccom.py`): it is the PC COMMUNICATION protocol, file commands from a computer. The payload of
  every group, the frame the instrument sends back and the reply codes are in section 7. Not traced (a
  naming question for those routines, not a format one): which directory operation each of the five
  SD-card commands is.
- **Tempo 250: closed.** The 0x80 event is BPM with no scale or offset (func_48458898:
  `b1 + (b2 << 7)`; TempoBpmReloadWrite 0x4844786C, 40..300, TM5 reload 1,250,000 / BPM). Eight of
  the ten demo songs set 250 BPM (song 4: 200) at beat 0, together with the first slide (0x8A), and
  their real tempo at beat 4 (song 4: beat 2, song 1: beat 8), where the music starts; song 6 starts
  at once at 138 (`songtable_demo_tempo.py`). So the first bar is an empty lead-in that plays in about
  one second. [INFERENCE] It is the set-up bar a sequencer recording begins with, shortened that way
  while the first picture is drawn.

## 7. PC COMMUNICATION: the type-4 Technics SysEx (2026-11-06, lane kn7000-names)

Established from code, not run (`sysex_pccom.py`). The 47 type-4 descriptors (section 5) are one protocol: a
computer sends file commands, the instrument shows the screen TT_PCCOM ("PC COMMUNICATION", title 0x12F) and
runs them. [INFERENCE] The computer side is the CD-ROM's "Technics SongManager & AudioRecorder (for
KN7000)", which was not decoded. No file data travels in the SysEx: each command names a file the instrument
loads or saves itself.

**Frames.** Every frame ends `cc F7`; `cc` is the CRC-7 (polynomial x^7 + x^3 + 1, the SD card's)
of bytes 1 .. n-3, from the table at 0x4874C4F8 (func_484C3517 writes it, func_484C356A checks it).
The instrument answers with `F0 50 28 20 31 1F cc F7` (done, func_484C35EF) or `F0 50 29 20 31 1F ee cc F7`
(status ee, func_484C364E): ee = 1 for a bad check byte, else the low 7 bits of func_4858391E's negative
result: -1 (0x7F) busy (func_48583890 / func_4858389E) or a name stem longer than 8 characters, -2 (0x7E)
kind 10 outside mode 1 or kind 11 without kind 10 first, -3 (0x7D) a file command while the PC COMMUNICATION
title is not up. When the wait for the go-ahead fails, the handler sends no status: it posts kind 11 with
code 2 (func_484C1B4A) and returns -2.

**Commands** (`F0 50 2C 20 31 1F 7F gg ss L1 L2 L3 p1 p2 p3 .. name 00 cc F7`; the request record copied to
0x50172F4C is {kind, gg, p1, p2, p3, .., +0xB: the NUL-terminated name from message +0x14}):

| sub  | message                      | kind | what func_4858391E runs                                                                                   |
|------|------------------------------|------|-----------------------------------------------------------------------------------------------------------|
| 0x0B | `F0 50 32 7E 31 1F cc F7`    | 10   | enter: ChangeTitle(TT_PCCOM) when the mode is 1, else -2                                                  |
| 0x0C | `F0 50 33 7E 31 1F 00 cc F7` | 11   | leave: back to the previous mode / title (ChangeMode, InterruptTitle 0x23 or 0x4A)                        |
| 0x0E | `7F 10 00`                   | 2    | LoadSmf of the named file (opened "rb")                                                                   |
| 0x0F | `7F 10 04`                   | 1    | SaveSmf, its arguments the record bytes +1..+4                                                            |
| 0x10 | `7F gg 00`, gg 0..0x0B       | 4    | load group gg: Lsw, Pmt, Md, Fav, Hmp, Efc, Sqt, Cmp, Msp, Tm, Rcm, Cst (`7F 06 01` = 0x0C: SqfSeq)       |
| 0x11 | `7F gg 04`, gg 0..0x0B       | 3    | save group gg: the same list (Pmt only for bank p1 = 1, 3 or 0x0D)                                        |
| 0x12 | `7F 20 00`                   | 7    | SD-card operation func_48552292 (-> func_48562237 -> func_48561FCE, a `_findfirst` walk)                  |
| 0x13 | `7F 20 01`                   | 8    | SD-card operation func_48552304 (-> func_4856557B)                                                        |
| 0x14 | `7F 20 02`                   | 9    | SD-card operation func_4855233B (-> func_485655A0, `_findfirst` / `_findclose`, "C:"), then SdRemountSync |
| 0x15 | `7F 20 04`                   | 5    | SD-card operation func_48552257 (-> func_48561FCE)                                                        |
| 0x16 | `7F 20 05`                   | 6    | SD-card operation func_485522CD (-> func_48565556)                                                        |
| 0x17 | `7F 30 00`                   | 12   | PictureImport of the named file                                                                           |

The five SD-card commands each first call SDModuleModeReq, SdCardReadyCheck and SdCardDetectPoll2; which
directory or file operation each is was not traced. L1..L3 form a 21-bit number (func_484C34ED,
`b9 << 14 | b10 << 7 | b11`) that the handlers store and never read, as they do the constant 0x348.

**Exchange.** A command handler checks the frame, echoes the whole request back (copied to 0x5015177C, sent
through func_484B3B94), then waits (func_484C3A03) up to 5000 ticks of 0x50151BFC for a frame
`F0 50 23 20 .. 1F ..` (type 0x23: go ahead), reading raw MIDI bytes itself. While waiting, a frame with a bad
check byte, or `29` with ee = 1, makes it send the request again (counted in 0x50151BF8 / 0x50151BF6); `2F`
cancels (bit 6 of 0x50151BF5, func_484C301C), any other `29` fails. Then it runs the command and sends the
done / status frame. Sub 5 (`F0 50 29 ..` from the computer) outside a wait resends the last frame while
the state 0x50151BFA is 1..12. Subs 0, 1, 3, 4, 6, 7, 9, 0x0A and 0x0D are accepted and ignored.

## Reproduce (scripts in `songrec/`)

| script                                                 | question it answers                                                                                    | command                                                                                                               |
|--------------------------------------------------------|--------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `song_tables.py`                                       | the length table, whitelists, presets, encoder and value-size hashes                                   | `python3 -I song_tables.py`                                                                                           |
| `song_event_census.py`                                 | which statuses and A/F ids occur in song page data                                                     | `python3 -I song_event_census.py ROM demo*_pages.bin` (pages from kn7000_mame `tools/slideshow/demo_song_extract.py`) |
| `sysex_desc.py`                                        | M3 id to transmit SysEx template                                                                       | `python3 -I sysex_desc.py`                                                                                            |
| `sysex_rx_ids.py`                                      | the ids an incoming SysEx can set                                                                      | `python3 -I sysex_rx_ids.py`                                                                                          |
| `callrefs.py`, `idrefs.py`                             | the callers of an address; the functions that load an id                                               | `python3 -I callrefs.py 0x4845a0be`                                                                                   |
| `dv.py`                                                | named disassembly of a range (`tools/dis_view.py` with its symbol-list fix)                            | `python3 -I dv.py 0x48458705 0x48458830`                                                                              |
| `romread.py`, `padtables.py`                           | helpers: read the image by CPU address; align Markdown tables                                          | imported / `python3 -I padtables.py < in.md`                                                                          |
| `../../mn10300-names-probes/songtable_m3_set_kinds.py` | what setting id 0x80 runs: PutM3Em's class tables and the kind setters                                 | from `kn7000/`: `python3 -I notes/mn10300-names-probes/songtable_m3_set_kinds.py`                                     |
| `../../mn10300-names-probes/songtable_sysex_rx.py`     | the type-4 SysEx descriptors and sub-handlers; the context template's source bytes                     | from `kn7000/`: `python3 -I notes/mn10300-names-probes/songtable_sysex_rx.py`                                         |
| `../../mn10300-names-probes/songtable_song_ids.py`     | record and callers of each unknown song id                                                             | from `kn7000/`: `python3 -I notes/mn10300-names-probes/songtable_song_ids.py`                                         |
| `../../mn10300-names-probes/songtable_demo_tempo.py`   | the demo songs' tempo events and lead-in                                                               | from `kn7000/`: `python3 -I notes/mn10300-names-probes/songtable_demo_tempo.py`                                       |
| `song_id_users.py`                                     | every reader, writer and subscriber of each still-unknown song id, all M3 accessor wrappers included   | from `kn7000/`: `python3 -I notes/presentation-control-probes/song_id_users.py [ID_HEX ...]`                          |
| `sysex_pccom.py`                                       | the PC COMMUNICATION commands behind the type-4 descriptors: kinds, file routines, reply frames, CRC-7 | from `kn7000/`: `python3 -I notes/presentation-control-probes/sysex_pccom.py`                                         |
