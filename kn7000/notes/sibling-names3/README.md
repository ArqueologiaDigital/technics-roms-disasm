# Lane open14/sibling-names3 (2026-11-07, wave 13): sibling-only code named by hand

Wave 13 continues `../sibling-names2/README.md` (wave 12) and `../uitron3-function-codes/README.md`.
Items: routine names N-a810f3f6 (KN6000), N-f22bdce4 (KN6500), N-b3ba9d8b (KN2400); RAM operands
N-8fce01b1 (KN6000), N-cccf0416 (KN6500), N-dc17693c (KN2400).  Wave 12 had shown that what the
KN7000 can still give the siblings is small; this lane names the code that has **no KN7000 twin**
from the sibling firmware's own evidence, reading each body before naming it.  The probes are in
`../sibling-names3-probes/` (README there).

## Where the sibling-only code is (measured first)

`routine_graph.py <model> --clusters` (func_ routines per 64 KB, at the base 92b5cc4a7):

| model  | largest regions (func_ routines)                                                               |
|--------|------------------------------------------------------------------------------------------------|
| KN6000 | 0x4C12 720, 0x4C11 717, 0x4C05 440, 0x4C04 387, 0x4C08 378, 0x4C03 361, 0x4C09 329, 0x4C06 305 |
| KN2400 | 0x4861 662, 0x4862 655, 0x5017 467, 0x5015 451, 0x4870 329, 0x5014 318, 0x486E 317, 0x5018 280 |

The two largest regions of each are one module: the sequencer (GetSeqPlyPart, SetSeqSongNo,
sqpstp_op, LoadSmf, SaveSmf ...) at 0x4C11xxxx-0x4C12xxxx in the KN6000 / KN6500 and at
0x4861xxxx-0x4862xxxx in the KN2400.  It is the same code in the three siblings and not the
KN7000's, so a name given in the KN6000 reaches the other two (below).  Only a few dozen of its
routines carry a string or a GUI id of their own (`--evidence`); most are tied to the rest only
through RAM, so this lane named the sequencer's file-image and SMF layer and left its core.

## Evidence classes

Every hand row in `<model>_manual.sym` (block `; ---- lane open14/sibling-names3`) starts with one
class; `hand_names_check.py` refuses a row without one.

| class       | the name comes from                                                                                                |
|-------------|--------------------------------------------------------------------------------------------------------------------|
| `string`    | a string the body uses ("MThd", "PPORT CHIP OK", "LCDCAP%02d.BMP", a file mode "rb" / "wb" with the file type)     |
| `gui`       | the GUI objects and events the body posts (TEST6_OK_id, HDD_DBMEMO_id with EV_MEMODRAW ...)                        |
| `io`        | the I/O registers it drives (the ATA registers at 0x98060000, the PPORT / USB chips)                               |
| `table`     | a slot of a table another image names: the XAPR plug-in's header words, named in `../../../hdsx3/`                 |
| `callee`    | what it calls and how (deflateInit_ with the stream, FileRead into INSTALL_SCRATCH ...)                            |
| `caller`    | its one named caller: a reflection-named trampoline whose body it is (`<name>_Impl`), or a step of a named routine |
| `ram`       | the one variable it reads or writes, whose use elsewhere says what it is                                           |
| `body`      | what the code does, read instruction by instruction ([INFERENCE] where the meaning is inferred)                    |
| `libc`      | a library routine (zlib 1.0.4's inflateInit_), with the KN7000 941 twin                                            |
| `same-body` | another sibling's hand row: the same masked body, in the same place of the routine order (`port_hand_names.py`)    |
| `data`      | a data address (FileTypeExtTable)                                                                                  |
| `var`       | a RAM address, from what the named routines that use it do with it                                                 |

## What was named

KN6000 (`kn6000_manual.sym`, 154 rows; KN6500 and KN2400 by porting, below):

- **The file layer and the XAPR plug-in.**  `FileOpen` was named; its siblings were not.  Each of
  them takes, when FileExtMode is set, the XAPR plug-in's header slot of the same name (the host's
  `XaprCall*` stubs; the slot names are the plug-in's own, `../../../hdsx3/README.md`): FileError,
  FileClose, FileRemove, FileGetc, FilePutc, FileRead, FileWrite, FileSeek, FileRewind, FileTell.
  The slot order confirms the reading of each body.
- **The file system library under it**, a stdio-like API of its own (mode letters r w a + b ~ d,
  an error number at 0x50200000, a FILE with a device method table): FsOpen, FsRead, FsWrite,
  FsSeek, FsRewind, FsTell, FsGetc, FsPutc, FsClose, FsRename / FsRemove / FsMkdir / FsRmdir
  ([INFERENCE] for the last four).  Not `fopen` ...: the image also links the C runtime's `fwrite`
  (0x4C004289, PfOutString's), a different routine.
- **The zlib file codec** (ZFile*): the two z_streams, the 64 KB block buffer, the status word and
  the space budget, and `inflateInit_` (941's twin, too short to port).
- **Trampoline bodies.**  `wrapper_bodies.py`: 24 func_ routines are the whole work of a
  reflection-named trampoline (`LoadPmt_HD` is `call` + ret of it), named `<name>_Impl` as
  `DrawBox` / `DrawBox_Impl`.  The file-type audit below checks them.
- **The sequencer's file image and the SMF reader**: the INSTALL_SCRATCH cursor (Scratch*),
  SmfReadByte / SmfReadU32BE / SmfReadHeaderChunk / SmfReadTrackChunkHeader / SmfReadTracks, the
  MThd fields (SmfFormat, SmfTrackCount, SmfDivision), LoadSmf's three steps, SaveSmf's file calls.
- **The expansion board's test screens** (HDDTestProc, HDD_COMM_TEST): the log printers, the slot,
  RAM address-line, PPORT and USB chip checks, and the ATA layer (HddRegWrite8 / HddRegRead8 /
  HddRegRead16, HddStatus, HddWaitReady, HddIdentify 0xEC, HddReset, HddWriteSector 0x30).
- **The factory test mode**: RamTestWords / RamTestBytes (0x5A / 0xA5 patterns over the
  RamTestRegion records), RomTestChecksums, the TEST2 / TEST5 / TEST6 / TEST7 / MIDI-IO result
  screens.
- **The built-in resources' checks**: TechnicsRhythmsHeaderParse, TechnicsPadsResourceCheck,
  SoundRamSignatureCheck, SoundRamSumUpdate [INFERENCE].
- **22 RAM addresses** (class `var`) read off those routines.

KN2400 (`kn2400_manual.sym`, 66 rows): the KN6000's rows that port (48, 15 of them RAM, among them the Fs library,
which the KN2400's fmm layer sits on), the string helpers and FileNameWithExt with its 14-entry
FileTypeExtTable ("ACT" added), 13 load / save bodies by their file type (`file_type_bodies.py`:
LoadCmpFile, SaveTmFile ...), 2 trampoline bodies, and three of its own (CaptureLcdWriteBmp,
FsMountVolume [INFERENCE], TestSdImmunityFile).

KN6500 (`kn6500_manual.sym`, 152 rows): the KN6000's rows that port (135, 21 of them RAM), the 14 XAPR slot stubs
(`xapr_slot_callers.py`: the stubs differ only in the slot address, which the porting masks) and
FileTypeExtTable.

## How the names were checked

- `hand_names_check.py <model>`: every row has a class, names a func_ routine (or a data / RAM
  address), and no name is used twice in the model's symbol files and labels.  PASS for all three.
- `port_hand_names.py A B --report` audits its rule where the answer is known (routines both images
  name already, paired the same way; `port-audit.txt`, final tree): KN6000 -> KN6500 2,233 alike /
  0 unlike; KN6000 -> KN2400 1,074 / 2 (`M3HookDispatch` / `M3SetSpecialDispatch`, a pair wave 11 already lists as two names
  for one routine, and `CmpPrtCpyEditFunc` / `CmpEasyCompEditFunc`).  Before the repeated-body
  refusal the KN6500 audit found 119 unlike pairs, almost all FtLangText01 / FtLangText03 style
  off-by-one pairings inside runs of identical procedures: that is why the rule exists.
- `file_type_bodies.py kn6000 0x4C14C83E FileNameWithExt` audits the file-type rule on the KN6000,
  where the bodies are named by their reflection-named trampolines: every type it finds agrees
  (PMT -> LoadPmt_HD_Impl / SavePmt_HD_Impl ... AST -> LoadRcm_HD_Impl / SaveRcm_HD_Impl).
- Each image rebuilds byte-identical (`make -C <model> verify`).

## Results

`../sibling-names-probes/sibling_name_census.py` at the base 92b5cc4a7
(`../sibling-names3-probes/census-92b5cc4a7.txt`) and after (`census-after.txt`):

| model  | func_ (stats) before | after  | func_ starts before | after | named before | after | work RAM ops / addrs before | after          |
|--------|----------------------|--------|---------------------|-------|--------------|-------|-----------------------------|----------------|
| KN6000 | 9,843                | 9,600  | 5,632               | 5,501 | 2,831        | 2,962 | 17,755 / 2,522              | 17,339 / 2,484 |
| KN6500 | 9,899                | 9,658  | 5,659               | 5,529 | 2,837        | 2,967 | 17,791 / 2,531              | 17,379 / 2,495 |
| KN2400 | 11,254               | 11,166 | 6,480               | 6,430 | 3,478        | 3,528 | 20,908 / 2,933              | 20,564 / 2,916 |
| HD-SX3 | 765                  | 765    | 459                 | 459   | 179          | 179   | 0 / 0                       | 0 / 0          |

RAM names (`<model>_ram.sym`, `name_ram_by_use.py` re-run on the new routine names, unchanged tool):
KN6000 486 -> 503, KN6500 486 -> 502, KN2400 641 -> 643 (the owner rule: every reference in one
named routine); plus the hand `var` rows, 22 in the KN6000, 21 in the KN6500 and 15 in the KN2400.  The
work-RAM operand fall (KN6000 -416, KN6500 -412, KN2400 -344) is mostly those `var` rows: errno,
the zlib streams and the status word are spelled in dozens of places each.

Regeneration order, each to its fixpoint (as `../sibling-names/README.md`, without `aligned-names`,
which lane kn7000-subsystems owns): `data-and-code-src`, `ram-names`, `data-and-code-src`, again
until `ram-names` writes the same file.  All three images rebuild byte-identical
(`make -C <model> verify`).

## Left open, and the next step

- **The sequencer's core** (0x4C11 / 0x4C12 in the KN6000, 0x4861 / 0x4862 in the KN2400) is still
  mostly func_.  Its routines are tied together through RAM, not strings: the next step is to name
  its variables first, from the named accessors (GetSeqPlyPart ...) and from the per-track masks
  (0x5004EE92 is a 16-bit per-track mask that func_4C113F38 sets and clears together with
  SetSeqPlyPartBit), then the routines by the variables they own.  A name given in the KN6000
  reaches the KN6500 and, for most of this module, the KN2400 through `port_hand_names.py`.
- The Lyrics / PlayDisp display procedures (0x4C0D1xxx-0x4C0D5xxx), the file-name list helpers of
  the Fmm*FileNameFunc screens (0x4C14C9xx-0x4C14Exxx) and the help pages are next in the KN6000's
  evidence list (`routine_graph.py kn6000 --evidence`).
- The KN2400's 30 short tone-generator twins stay as wave 12 left them: they differ only in the
  byte variable they read, in a block whose layout the KN2400 changed, and none of their callers in
  the RAM-linked library is named yet.
- RAM from the firmware's own tables (panel-memory maps, parameter tables pointing at RAM) was not
  reached: the data region's tables that hold work-RAM addresses are few (`data_03.s` /
  `data_06.s`: 9 operands in the KN6000) and the panel-memory banks are copied by offset, not by
  address, so no table names a variable directly.  `name_ram_by_use.py` was not changed; its owner
  rule grew with the new routine names.
- `FileTypeExtTable`'s KN6000 / KN6500 strings are typed as `.byte` rows under `StrAppend_Lf_List_*`
  (lane mn10300-data5's generator): they are the strings "LSW" ... "SEQ" and would read better as
  `.asciz` (the KN2400's `Text_LSW` already is).

## Website page draft

*For the technics-docs pages on the MN10300 siblings (`kn6000-disassembly.md`, `kn2400-disassembly.md`),
section "Names", after wave 12's paragraph (`../sibling-names2/README.md`).  Text only; the integrator
publishes it.*

**Names from the firmware's own evidence.**  Code the SX-KN7000 does not have gets its names by hand
since November 2026, each with the evidence it rests on: the strings it uses, the screens it posts
to, the hardware registers it drives, or a table another image names.  The expansion board's
plug-in, for instance, lists its file services in its header, so the keyboard routines that call
each slot take the slot's name, and through them the keyboard's whole file layer (open, read, write,
seek, close) and the small file-system library beneath it got names.  The SMF reader, the zlib file
codec, the hard-disk test screens and the factory test mode followed.  The SX-KN6500 and SX-KN2400
share much of this code; a routine named in one sibling passes to another when its code, with every
address masked, is the same at the same place in the link order, a rule checked on the routines both
models already name.

## Items

| item       | outcome | in one line                                                                                                                                   |
|------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| N-a810f3f6 | OPEN    | KN6000 func_ starts 5,632 -> 5,501 (census func_ 9,843 -> 9,600): 154 hand rows; next: the sequencer core by its variables, Lyrics, Fmm lists |
| N-f22bdce4 | OPEN    | KN6500 5,659 -> 5,529 (9,899 -> 9,658): 152 rows, 135 carried from the KN6000; next as N-a810f3f6                                             |
| N-b3ba9d8b | OPEN    | KN2400 6,480 -> 6,430 (11,254 -> 11,166): 66 rows; the 30 short TG twins unchanged (no named caller tells them apart); next as N-a810f3f6     |
| N-8fce01b1 | OPEN    | KN6000 work-RAM 17,755 / 2,522 -> 17,339 / 2,484 (22 hand var rows, owner names 461 -> 478)                                                   |
| N-cccf0416 | OPEN    | KN6500 17,791 / 2,531 -> 17,379 / 2,495 (21 carried var rows)                                                                                 |
| N-dc17693c | OPEN    | KN2400 20,908 / 2,933 -> 20,564 / 2,916 (15 carried var rows)                                                                                 |
