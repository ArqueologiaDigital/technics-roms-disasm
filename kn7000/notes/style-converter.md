# Style converters (.CNV): loadable programs behind DISK MENU > STYLE CONVERT (2026-10-18)

Static analysis of PROGRAM 941 plus the KN6000 program, the two Style Convert Disks
(`scd7000.exe`, `scd6000.exe` in the CA software mirror) and one RAM read on a booted KN7000.
Scripts in `style-converter-probes/`.

## The disk

| file                     | size    | KN6000 disk = KN7000 disk? | converts styles of                                   |
|--------------------------|---------|----------------------------|------------------------------------------------------|
| `GEM_WS2.CNV`            | 99,857  | identical                  | GEM (General Music) WS2                              |
| `GEM_WX2.CNV`            | 108,049 | identical                  | GEM WX2                                              |
| `KORG.CNV`               | 108,912 | identical                  | Korg                                                 |
| `Roland.cnv`             | 91,872  | identical                  | Roland                                               |
| `SOLTON.CNV`             | 96,706  | identical                  | Solton                                               |
| `TECHNICS.CNV`           | 101,992 | relinked (data moved 0x2C) | Technics KN1000 / KN750 (the firmware's own prompt)  |
| `V1%0_.ver`, `V2%0_.ver` | 369     | same content, other name   | none: a version tag read from the name only          |

The brands are only in the file names: the converters contain no text at all.

## What a .CNV is

A raw MN10300 program, no header, linked to run at `0x502B8000`. Offset 0 is `bra main` (0x33
in KORG). Offsets 2-0x32 are C start-up: zero the BSS, copy initial data, both at fixed
`0x502Cxxxx`/`0x502Dxxxx` addresses. `main` is a state machine (state byte at `0x502D127C` in
KORG): each call does one step and returns. **Nothing in a converter calls outside itself**:
every call and jump in all six lands inside the file and none goes through a register
(`cnv_calls.py`). It can only talk to the firmware through memory, which is why one binary runs
on both firmwares.

## How the firmware runs one (KN7000 941; the KN6000 has the same code)

1. STYLE CONVERT lists `*.CNV` (filter `0x485CD536`, code `0x48478D6D`). If there is none, it
   opens title 0x46 `_TT_STYLCNVWAIT` ("Please Insert the Style Convert Disk!").
2. It lists `*.VER` (`0x485CD542`, code `0x48478E3E`) and parses the **name**, looking for `.`
   and `%`. `V1%0_` reads "V1.0" (`%` stands in for the second dot an 8.3 name cannot hold), and
   the result is copied to `0x500011A4`. The file's content (a Cakewalk `.wrk` header,
   `CAKEWALK\x1a`) is not used.
3. For the chosen converter (code `0x48479016`): `fmmopen(name, "rb")`, zero 0x30000 bytes at
   `0x502B8000`, `fmmread` the whole file there, `fmmclose`. It records the first free byte
   after it, rounded up to 0x100, at `0x5004E440`, and clears the converter's init flag at
   `0x5031BBFE` and the byte at `0x5031BFFF`.
4. It compares the converter's 8-character name with RAM `0x5000119C`, which holds `TECHNICS`
   (read on a booted KN7000: `ram_strings.cmd`), and sets `0x5004ED70` for the Technics
   converter.
5. It primes the mailbox at `0x5031BC00` (byte 0 = `0xFF`, byte 1 = 0, 4 bytes from the
   file's list entry at +2) and calls the converter: `mov 0x502B8000, a0; calls (a0)`
   (`0x48479929`; KN6000 file offset 0x16154A).
6. Each time the converter returns, `0x4847993A` reads its request from mailbox byte 0, serves
   it, writes `0xFF` back and calls the converter again:

| request | what the firmware does (handler)                                                                                   | screen                 |
|---------|--------------------------------------------------------------------------------------------------------------------|------------------------|
| 1       | copies 4 bytes from the mailbox to `0x50150831`, calls again                                                       |                        |
| 2       | directory and file-name services, sub-code in byte 1: 0x00, 0x10, 0x40, and 0x80 (a name pattern with `.` `*` `?`) |                        |
| 4       | file I/O for the converter: fmmopen, fmmread, fmmseek, fmmtell, fmmrewind, fmmclose (`0x48479D64`)                 | 0x48 `_TT_STYLCNVCNVT` |
| 3       | `0x48479818`, then a selection screen (`0x4847A60F`)                                                               | 0x4B `_TT_STYLCNVSEL`  |
| 5       | shows a text; for TECHNICS V1.0 the firmware's own "Insert Style Disk of Technics KN 1000/750" (RAM `0x500011B0`)  | 0x4A `_TT_STYLCNVTXT`  |
| 0       | conversion finished: the STORE screen; for TECHNICS `0x4847A857` and ChangeMode(1) instead                         | 0x49 `_TT_STYLCNVSTOR` |
| 0xFE    | error                                                                                                              | 0x4C `_TT_STYLCNVCONT` |
| other   | `0x4847A6DA`                                                                                                       | 0x4C `_TT_STYLCNVCONT` |

Title numbers: `title_pool.py` (title = pool index + 1, checked on `_TT_DEBUG` 0xFF,
`_TT_MEMDUMP` 0xF2 and `_TT_SOFTVER` 0xF0).

## Not established

- The layout of each request's arguments in the mailbox, beyond the bytes listed.
- Where the converted style is left for the STORE screen.
- What the Technics path does after `ChangeMode(1)`.
- That the TECHNICS converter reads KN1000/KN750 disks rests on the firmware's prompt text.
- No conversion has been run end to end in MAME.
