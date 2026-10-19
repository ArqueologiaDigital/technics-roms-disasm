# Can file or MIDI data open the Panel Simulator, DEBUG TOOLS or LCD capture? (PROGRAM 941)

Static analysis, 2026-10-18 (research agent; this repository's `disasm/program.asm`, the library
disassembly in `lib.asm` produced by the scripts here). Question: apart from the gated panel
chord, can data a user puts on a floppy/SD card (a song `.SQT` and its `.ACT`, `FEATURE.PRE`,
panel-memory files, MIDI/SysEx in a song or on MIDI IN) make 941 (a) enter mode 0, the Panel
Simulator (`_MD_PS`, `ChangeMode` 0x4842B348 with d0 = 0), (b) open title 0xFF (`_TT_DEBUG`),
0xF2 (`_TT_MEMDUMP`) or 0xF0 (`_TT_SOFTVER`), or (c) run `CaptureLcd` (0x48415680),
`CaptureLcdArea` or `CaptureLcdCheck` (0x4848886E)?

## Verdicts

| question                                                  | verdict                                   |
|-----------------------------------------------------------|-------------------------------------------|
| (a) ChangeMode(0) / Panel Simulator                       | not reachable from file or MIDI data      |
| (b) title 0xFF / 0xF2 / 0xF0                              | not reachable from file or MIDI data      |
| (c) CaptureLcd / CaptureLcdArea / CaptureLcdCheck         | not reachable from file or MIDI data      |

The only runtime door is the physical panel chord in the `0x48414xxx` handler, and on 941 even
that is closed (release byte `0x4840000F` = 0x16; the gate wants 0xFF, as in the SP7001 build 942).

## Evidence

**(a)** Of the 103 `ChangeMode` (entry 0x4842B348) call sites, exactly one loads 0: `0x484148EC`
(`clr d0`), inside the chord dispatcher `0x484148C0`, behind the `cmp 0xFF` release-byte gate at
`0x484148E4`. All others pass non-zero performance-mode constants (1, 2, 6, 8, 0xC, 0xD, 0xF, 0x18)
or take the mode from ROM tables or UI-set event parameters that cannot be 0:

| call site    | routine            | where the mode comes from                                        |
|--------------|--------------------|------------------------------------------------------------------|
| `0x48416F26` | GroupBoxProc       | ROM table                                                        |
| `0x4841D1A9` | AcTitleMenuProc    | ROM title-menu table                                             |
| `0x4841EBB9` | IvExitModeProc     | the widget's own +0x18 field (ROM-defined)                       |
| `0x4842AFBD` | ModeProc           | mode-proc table `0x5000097C`                                     |
| `0x484319EA` | EasySetControl     | slot table `0x50033F64`, filled with ROM constants               |
| `0x4849DF96` | AcFavoriteProc     | ROM favorite table `0x48603758`                                  |
| `0x4849DFDB` | AcFavoriteProc     | ROM favorite table `0x48603758`                                  |
| `0x484A6166` | CustomModeFunc     | restores `GetModeOld() & 0x1F`, saved at `0x484A6157`            |
| `0x48488B50` | DbVariableMenuProc | DEBUG TOOLS only (reachable only after the gated ChangeMode(0))  |

None of them reads file or MIDI bytes.

**(b)** 0xF2 and 0xF0 appear as constant title arguments only at `0x484148F9` and `0x4841491D`
(both `InterruptTitle`, both in the same gated chord). 0xFF (`_TT_DEBUG`) is never a constant
argument to any of the nine title-change entries; it is opened only by the Panel Simulator's
DEBUG TOOLS soft key, i.e. only after the gated ChangeMode(0). Every data-derived `ChangeTitle`
(0x4842B3F4) / `InterruptTitle` (0x4842B4A0) site reads ROM title-menu / EasySet / favorite
tables or a UI-set `EV_CHANGE_TITLE` parameter (normal SD/effect/help titles 0x100-0x12F,
0x3C/0x3E); none yields 0xFF, 0xF2 or 0xF0 and none reads a title number from file or MIDI data.
`MT_SetDebugMode` (0x600E4) is sent only from `DbModeEditBoxProc` (`0x484883E4`, `0x4848841B`),
itself only inside DEBUG TOOLS.

**(c)** `CaptureLcd` (0x48415680) has two live callers: chord A `0x48414934` and chord B
`0x48414A35`, both behind the same 0xFF gate (`0x48414926` / `0x48414A27` -> `0x484D7928`). The
third textual call (`0x48488883`) is the body of `CaptureLcdCheck` itself. `CaptureLcdArea`
(0x48415A87) and `CaptureLcdCheck` (0x4848886E) have no callers: their only references are
pointers in the reflection table `0x487276E4` and the ApFunction table `0x48742674`; nothing
loads CaptureLcdCheck's function id `0x120000` for a FuncCall or delivers message 0x50005 to its
class. So "no caller in 941" holds.

## External-data surfaces (all negative)

No mode or title changer is called from: the `.ACT` / SSW slide-show engine
(`0x4857Fxxx`-`0x48580xxx`), the `FEATURE.PRE` / demo loader (`0x4854Exxx`), the sequencer song
load (`0x4852Cxxx`-`0x4852Fxxx`), the fmm file layer (`0x48532xxx`), the SMF/.MID parser
(`0x48480xxx`), or the MIDI RX ISRs (`0x484B1E86`, `0x484B2037`). The `SHOW` tag sends `EV_PAINT`
(0x50009, at `0x4857FC34`) to an object that already exists, not a mode or title change; `DA`
sends `MT_SleepMainTask`, `LibParamSet(0x90600007, NO)`, `MT_WakeUpMainTask`. Registration /
panel-memory recall (`AcFavoriteProc`) reads ROM favorite tables, not the loaded data. The panel-
remote procs `IvKNPRWinProc` / `IvPageKNPRProc` call no changer.

## Strongest residual candidate (still negative)

The generic `{event, arg}` dispatch in EasySetControl / AcFavoriteProc / AcTitleMenu could in
principle name mode 0 or a debug title if its tables were writable from a file, but all three
tables are ROM or are filled by registration code with ROM constants (`0x50033F64`, `0x48603758`,
`0x486062F8`, the title-menu tables), and none of their entries is 0 / 0xFF / 0xF2 / 0xF0.

## Reproduce (scripts in `reach/`)

| script             | question it answers                                                                                              | command                                                             |
|--------------------|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| `callsites.py`     | for every call to a routine, where its argument register was last set (reaching definition, join points flagged) | `python3 -I callsites.py ../../../disasm/program.asm 4842b348 [d0]` |
| `registry.py`      | the `RegisterObjectTable` calls the GUI makes at boot (class, proc, count, table)                                | `python3 -I registry.py`                                            |
| `rom.py`, `sym.py` | helpers: image access (program and library alias) and nearest-symbol lookup                                      | imported; `python3 -I sym.py ADDR` prints a symbol                  |

The library listing (`lib.asm`, 106,581 lines) is not committed; it is unidasm of the library's
bytes in the program image: `python3 -c "d=open('baserom/kn7000_program.rom','rb').read();
open('lib.bin','wb').write(d[0x3B8FD1:0x3F6EE8])"` then `unidasm lib.bin -arch mn10300 -basepc
0x4c000000` (checked byte-identical, 2026-10-18).
