# Older program builds: 935 (v1.5) and 893 (v1.3), ported from 941

**2026-10-24.** Program builds 935 and 893 are byte-exact targets with real source
(`src/b935/`, `src/b893/`). They were made the way SP7001's program 942 was
(`notes/sp7001-build-diff.md`): everything recovered for build 941 is carried through the
exact 941 -> N offset map, and only what has no counterpart is left out. 935 is described
first; 893 uses the same method, and its section below gives only what differs.

## Where the reference comes from

| build | release | reference image (git-ignored)     | made from (private romset, `ROMSET_DIR`)                                   | SHA-1 of the 4 MiB image                   |
|-------|---------|-----------------------------------|----------------------------------------------------------------------------|--------------------------------------------|
| 935   | v1.5    | `baserom/kn7000_program_b935.rom` | `kn7000_program_{even,odd}_v1.5_b935.ic1{7,6}`, `tools/rom_from_eproms.py` | `5690195daa4c098069c0d84b4933bd1325f98269` |
| 893   | v1.3    | `baserom/kn7000_program_b893.rom` | `kn7000_program_{even,odd}_v1.3_b893.ic1{7,6}`, `tools/rom_from_eproms.py` | `13e0b29181b7bbee671dba70d707e0f55161a15c` |

The Makefile rule de-interleaves the two EPROM halves and refuses an image whose SHA-1 is not
the one recorded. Program 935 pairs with table build 84, the table 941 pairs with, so the
symbol porter's table map is the identity. The image's header byte at `0x4840000F` (the
release the IC18 boot ROM shows as `NOW(CURRENT)`) reads `0x15`.

## Reproduce

    make verify-935          # build src/b935/program.s, compare with the reference
    make symbols-935         # kn7000_b935{,_manual,_exports}.sym + src/b935/symbols.inc (needs 941's baserom)
    make program-src-935     # regenerate src/b935/ (needs unidasm and 941's baserom; ~3 min)
    make ported-names-935    # kn7000_b935_bycode.sym (needs unidasm; then program-src-935 again)
    make check-names-935     # do the ported names sit on the same routine as in 941?
    python3 -I tools/offset_map.py baserom/kn7000_program.rom baserom/kn7000_program_b935.rom kn7000.sym kn7000_manual.sym

## What differs between 935 and 941

`tools/offset_map.py` (last command above): image `0x3F6E9D` bytes against 941's `0x3F6F01`.
Most of code region 1 sits at delta -66 (941 `0x01064F..0x18599C`), the library image and the
end of the data region at -100. The edits concentrate in three places:

- **the front of code region 1.** 941 rewrote and reordered the DSP boot code: 941
  `0x4D10..0x557B` (`DspFullReinit`, `DspBootDefaultEffects`, `DspBootProbe` and the DSP host
  port writers) has no 1:1 counterpart, 941 `0x557B..0xD118` sits at +10029 / +12129 and 941
  `0xD400..0x1023C` (the record interpreter, `ResetEntry`) at -34188 / -34192;
- **the end of code region 1.** 941 has a 5-byte stack template (a data island at
  `0x18599C`) after `DemoJpgDataL8`'s `retf`; 935 has two 0xFF bytes and the `.rodata` straight
  after, so its region 1 ends at `0x18595C` (`PORTED_BUILDS["b935"]` in `tools/gen_program_s.py`);
- **the data region.** Several blocks moved (the DSP record pool by +208548, others by -79840 and
  -100); `ResourceIdTrie` and `StyleRecordTable` hold small rewrites.

## How the source is made

`tools/gen_program_s.py --profile b935` is the `sp7001` profile's method with one change: a 941
item that has no 1:1 counterpart is dropped and counted instead of aborting the run.

- **Names.** `tools/port_symbols.py` ports `kn7000.sym`, `kn7000_manual.sym` and
  `kn7000_exports_from_942.sym`. With `--check-recovered` it re-derives the reflection names from
  935's own MILK tables: all 2302 sit exactly at the address the map gives. `--min-run 16` (new)
  refuses an address that only a 1:1 run shorter than 16 bytes holds: between two anchored
  segments, difflib aligned 6 equal bytes of rewritten code and put 941's `DspFullReinit` inside
  935's `ResetEntry`. `tools/check_ported_names.py` caught that (see below).
- **Names by code.** For the routines the map cannot place, `tools/port_names_by_code.py` (the
  tool the MN10300 sibling trees use) carries a 941 name when the relocation-masked code is the same
  and unique on both sides. Its new `--b-src` option reads the unnamed entries from the
  `func_<ADDR>` labels of a `gen_program_s.py` source (that generator writes no `labels.inc`).
- **Layout.** The palette, the data-region end and the library base come through the map.
  A FUNC_END cap, a data island and a LIB_CONVERT range port only when their whole 941 range maps
  1:1 onto one run of 935.
- **Notes.** FUNC_DOC and annotation text have their 941 CPU addresses translated. An address
  without a counterpart is printed `build-941 0x...`, so it never reads as a 935 address. Two
  addresses are the same in every build: `0x4840000F` and the library loader's sentinel
  destination `0x4C03FFF0` (the latter checked in the build's own descriptor). A note is
  written for 941's routine, so when the build's routine under the same name is different code
  (the test `make check-names-<N>` applies), `mark_edited_docs()` puts a first line on the note
  saying so. In 935 no noted routine is edited; in 893 two are, `TechniChordCompute` and
  `SdCardDetectDebounce` (the generator prints the list when it runs).
- **Boot header.** 935 links the reset `jmp` in its 3-byte form, so its second vector is at
  `0x8`, not `0xA`. `boot_header()` now spells that layout too (`_reset`, `_vector_08`,
  `_rom_marker` = the release byte).

## Measured (2026-10-24)

| what                                                              | value                  | from                               |
|-------------------------------------------------------------------|------------------------|------------------------------------|
| reflection names at exactly the ported address                    | 2302 of 2302           | `make symbols-935`                 |
| `kn7000.sym` rows ported                                          | 2376 of 2376           | `kn7000_b935.sym`                  |
| `kn7000_manual.sym` rows ported                                   | 1860 of 1866           | `kn7000_b935_manual.sym`           |
| `kn7000_exports_from_942.sym` rows ported                         | 184 of 184             | `kn7000_b935_exports.sym`          |
| names carried by code (`DspBootDefaultEffects`, `DspBootProbe`)   | 2                      | `kn7000_b935_bycode.sym`           |
| 941 names with no place in 935                                    | 4                      | the four UNPORTED rows not carried |
| ported names on the same routine as in 941 (relocation-masked)    | 3609                   | `make check-names-935`             |
| ported names on an edited routine (`DspManagerInit`, constants)   | 1                      | `make check-names-935`             |
| region-1 functions converted (named + unnamed)                    | 3104 + 33              | `make program-src-935`             |
| library functions converted                                       | 529 of 529             | `make program-src-935`             |
| `.byte` escapes                                                   | 0                      | `make program-src-935`             |
| 941 FUNC_END caps / data islands / LIB_CONVERT ranges dropped     | 0 / 1 (`0x18599C`) / 0 | `make program-src-935`             |
| `func_<ADDR>` function labels left (941's committed source: 6620) | 6617                   | see below                          |

The four 941 names with no place in 935 are `DspWritePMWord`, `DspWriteDMWord`, `DspRegWrite`
and `DspFullReinit`. They name DSP host-port code in the stretch 941 rewrote; the offset map
gives them no 1:1 place, and `tools/port_names_by_code.py` finds no routine of 935 with the same
code that passes its rule (8 unmasked instructions, unique on both sides).

The `func_` count is the number of function labels that no symbol file names:

    cat src/b935/program.s src/b935/program/*.s | grep -acE '^func_[0-9A-F]{8}:'

`grep -a` is needed because the `.s` files hold raw ROM bytes.

## Still open

- ~~Name, by reading the code, 935's and 893's own versions of the DSP host-port routines that
  941 rewrote.~~ **CLOSED 2026-11-02** (lane mn10300-names). The range given here before,
  `0x48404D10`..`0x48407CA8`, is wrong for 935 and 893. In those builds that range holds the code
  941 has at `0xD29C`..`0x1023C` (the JPEG engine, `ResetEntry`). 935's and 893's DSP host-port
  block is **`0x4840AE62`..`0x4840B696`**, at the same address in both builds and with the same
  code apart from relocated addresses. 941 moved it to `0x48404D10`..`0x4840557E`. The probe
  `notes/mn10300-names-probes/oldbuilds_dsp_hostport_match.py` splits both blocks at their
  function starts and finds 35 functions on each side, in the same order. 30 pairs have the same
  relocation-masked code. The other five differ as follows:
  - `DspPortRead` and `DspPortWrite`: 941 sets the bus control word `0x32000026` to `0x924`
    around the data-port access;
  - `DspPortWriteChecked` and `DspPortWriteSlow`: a callee frame size;
  - `DspDebugPrintHex16`: 941 has a dead `nop; ret` after it.

  That is all 941 "rewrote" here; the rest is the move. The four names that found no place sit at
  the same call entries as in 941:

  | name             | 941          | 935 / 893    |
  |------------------|--------------|--------------|
  | `DspFullReinit`  | `0x48404FF6` | `0x4840B10E` |
  | `DspWritePMWord` | `0x484050B8` | `0x4840B1D0` |
  | `DspWriteDMWord` | `0x4840511A` | `0x4840B232` |
  | `DspRegWrite`    | `0x484052E0` | `0x4840B3F8` |

  The lane also names the block's 29 unnamed helpers in all three builds: `DspPortRead` /
  `DspPortWrite` (port id `0x9C2` = the index port `0x98000000`, `0x9C4` = the data port
  `0x9C000000`), `DspWaitReady`, `DspSetIndex`, `DspRegRead`, the `*Slow` variants that raise the
  bus wait states, `DspHostPortStatus`, `DspBootRunTestRecord`, `StrapBit3Debounced`, and the
  RAM flags `DspHostPortError` / `DspReadyWaitEnabled`. 941's rows go in `kn7000_manual.sym`, and
  935's and 893's in `kn7000_b935_own.sym` / `kn7000_b893_own.sym`.

  Two causes kept these names from porting. First, the offset map aligns 941's moved block only
  as single bytes scattered across 893's moved code. Second, `tools/port_names_by_code.py` takes
  the build's candidates from its `func_<ADDR>` labels, which sit at the `add -N, sp` prologue,
  while 941 names these four at the call entry 3 bytes in, so the two signatures never compare
  equal.  (Fixed 2026-11-06, lane kn7000-names: the tool takes B's `func_<ADDR>_entry` labels
  too, and finds three of the four on its own, `kn7000-names/README.md`.) `kn7000_manual.sym` also said `DspFullReinit` "downloads the kernel then every effect
  record". The code does something else. It pulses the DSP reset line (GPIO `0x36008004` bit 7),
  sets the ready line's interrupt mode, and then makes up to 11 attempts to write `0x91919191` and
  `0x20` to index 0 one byte at a time and read them back. A good read-back clears
  `DspHostPortError`.
- 893's `func_` labels and the SD-card code that 941 reworked are named only where 941's
  names port. **Measured and split 2026-11-02**
  (`notes/mn10300-names-probes/oldbuilds_b893_func_census.py`, at `c240d1c0b`). 893 has 6,463
  `func_` labels; the 6,615 in the table below is an older count. They fall into four classes:
  - **6,402** have a 941 twin that 941 does not name either. These are named by naming 941.
  - **5** have a twin that 941 now names but that 893 does not carry yet: `TickHookStub`,
    `TickHookPass`, `PanelService`, `PanelPump`, `TickJobsTask`. These are new, uncommitted rows of
    `kn7000_manual.sym`, and `make symbols-893` carries them.
  - **16** have a same-code twin in 941 within 0x100 bytes, but no 16-byte 1:1 run covers their
    first byte.
  - **40** have no twin at all.

  The SD-card part is **CLOSED**:
  - **893's SD SOUND / SD AUDIO cursor accessors are mislabelled.** 893 keeps those cursors 8
    bytes lower in RAM (`0x500062F4..`, against 941's `0x500062FC..`). The offset map therefore
    aligned 941's byte-identical one-line getters with the wrong variables, and six ported names
    sit on the wrong routine. `SdAudSongIndexGet` at `0x48572487` is really `SdSndSongIndexGet`,
    for example, and `SdSndSongIndexGet` at `0x48572499` is really `SdSndPlayChIndexGet`.
    `check-names-893` cannot see this, because the masked code is identical. Each setter's bound
    and store fixes which variable is which. `oldbuilds_ported_ram_check.py` compares the RAM
    operands of all 681 short ported routines that name RAM against the map's RAM deltas, and only
    one disagrees: `SdAudSongIndexSet`. The deltas come from the same mis-aligned runs, so the
    getters themselves still look consistent to it.
  - The eight "unported" `SdSnd*` rows all have their 893 routine. `kn7000_b893_own.sym` gives the
    15 corrected rows, at `0x48572475`..`0x48572599`.
  - The other SD near-twins (`0x485583C9` after `SdcFmm`, and `0x4855E040`, `0x4855E09F` and
    `0x4855E0D6`, the SD free-space cache) are unnamed in 941 too.

  Of the 40 with no twin, 33 are the DSP block above, now named. The remaining **7** are open,
  with this next step: find the 941 routine that has the same callers, then name both builds.
  - `0x48404D10`, `0x48404E71` and `0x48405091` are JPEG decoder helpers. Their 941 twins are the
    unnamed `func_4840D29C`, `func_4840D3FD` and `func_4840D61D`: same prologue, edited bodies.
  - `0x484101FD` is a routine nothing calls: it waits 20 ticks, calls `DspManagerInit`, then
    loops over `func_4841222C(0x80 | n, 0xFF)`.
  - `0x48451649` (after `GetChord`) reads `GetM3EmVal(0x00C00000 | ...)`.
  - `0x485785B0` and `0x485788D8` are SD AUDIO player state routines.
    `0x485785B0` reloads the tempo through `TempoBpmReloadWrite`.
    `0x485788D8` requires `func_48577DCD() == 2`.

  The other 9 near-twins are also unnamed in 941: `0x48523537`, `0x4852358B` and `0x4852365C`
  (after `SingleLoad*`), and `0x4852F74D`, `0x4852F76C` and `0x4852F77B` (after `ResetSave*`).
- ~~`scripts/analysis/semantic_score.py` and `doc_quality_census.py` include neither 942 nor these
  builds.~~ **CLOSED 2026-10-31** (lane open4/misc): 942 has been rated since rules 4 (2026-10-24), and
  both scripts now list `program935` and `program893` as well (semantic score rules 6).  At the lane's
  base (`130735749`) they rate: bytes 4,148,024 / 4,194,304 (98.90 %) and 4,149,297 / 4,194,304
  (98.93 %) source; names 12,540 / 19,328 and 12,534 / 19,318 semantic (64.88 % each).  The integrator
  writes the badges and the ledger snapshots.

## Program 893 (v1.3)

893 is the program flash of Felipe's own instrument. The romset's two EPROM halves are byte-
identical to the dumper's pass-1 reads of that instrument
(`real_dump_v1.3_b893/pass1-run{1,2}/PRG{EVEN,ODD}.BIN`, the same in both runs). It pairs with
table build 80 (`make verify-table80`), so the symbol porter maps table 84 to table 80. The
release byte at `0x4840000F` reads `0x13`.

    make verify-893 symbols-893 program-src-893 ported-names-893 check-names-893

Mapping 941 to 893 is far slower than mapping 941 to 935 (1784 insertions against 167). It
takes about ten minutes, so `tools/offset_map.py` gained `cached()`. The Makefile's port
saves the maps in `build/offset-maps/`, keyed by the SHA-1 of both images and of
`offset_map.py`, and `gen_program_s.py` reuses them. The two builds' layouts:

- code region 1 ends at `0x1846A0`: `DemoJpgDataL8`'s `retf` is at `0x18469A`, followed by three
  0xFF bytes. The library image is at file `0x3B76B1`, and the image ends at `0x3F55CF`;
- the front of region 1 (the DSP boot code) is the same as in 935. Both builds carry
  `DspBootDefaultEffects` and `DspBootProbe` at the same addresses, by code;
- after the library loader's last record, 893 has one byte more than 941 and 935: `0xF0`, at
  `0x3F55CE`. It is emitted as a data island of this build alone (`PORTED_BUILDS["b893"]
  ["islands"]`). **Checked 2026-11-02:** nothing reads it.
  - The loader is `func_484D782E` in 893 and `func_484D7A3B` in 941. `ResetEntry`'s tail calls
    it just before `jmp KernelStart`. It reads 12-byte records `{u16 flags, u16 len, u32 src, u32
    dest}`. For a record without bit 15 it takes the length from the next record's `src`; for the
    record with bit 15 it uses `len`. It copies the bytes and stops after that record:
    `mov a3, d0; and 0x8000, d0; bne` -> `retf`.
  - No 32-bit word of the image points at `0x487F55CE`.
  - `kn7000_ic18.sym` names no checksum of the program flash; the boot ROM's sums cover update
    disks only.
  - The boot ROM's update writer stops at the stream's size. `UpdFlashFlush` pads only the last
    partial word, and it pads with 0xFF.

  So the byte belongs to the image itself and is not a flash leftover from a short update. The
  v1.4 upper half (build 929, `kn7000_program_{even,odd}_v1.4_b929_upper`) ends at its record too,
  as 941 and 935 do. [INFERENCE] The tool that built 893's image left it there. No v1.3 update
  disk is held to check this against. Also, the record-1 comment that `gen_program_s.py` carries
  over from 941 says "length 0xDF15" in 893 too. 893's word is `0xDF02`, the low half of its own
  library length `0x3DF02`; 941's and 935's are `0xDF15`;
- 941's `LibF64ToI16` (library) has no counterpart, and its LIB_CONVERT range is dropped.

| what                                                                   | value        | from                      |
|------------------------------------------------------------------------|--------------|---------------------------|
| reflection names in 893's own tables                                   | 2298         | `make symbols-893`        |
| ... exactly at the ported address                                      | 2206         | `make symbols-893`        |
| ... taken from 893's table (64 name rewritten code, 28 ambiguous runs) | 92           | `make symbols-893`        |
| `kn7000.sym` rows ported                                               | 2371 of 2376 | `kn7000_b893.sym`         |
| `kn7000_manual.sym` rows ported                                        | 1849 of 1866 | `kn7000_b893_manual.sym`  |
| `kn7000_exports_from_942.sym` rows ported                              | 184 of 184   | `kn7000_b893_exports.sym` |
| names carried by code (`DspBootDefaultEffects`, `DspBootProbe`)        | 2            | `kn7000_b893_bycode.sym`  |
| ported names on the same routine as in 941 (relocation-masked)         | 3550         | `make check-names-893`    |
| ported names on an edited routine                                      | 49           | `make check-names-893`    |
| region-1 functions converted (named + unnamed)                         | 3094 + 33    | `make program-src-893`    |
| library functions converted                                            | 527 of 527   | `make program-src-893`    |
| `.byte` escapes                                                        | 0            | `make program-src-893`    |
| `func_<ADDR>` function labels left                                     | 6615         | `grep -ac` on `src/b893`  |

Of the 5 `kn7000.sym` rows that do not port, 4 name code that 941 added: `SaveSameNameText`,
`SaveSameNameYes`, `SaveSameNameNo` and `SdcSendIndexCustomSaveFunc`. They are not in 893's
own tables either. The fifth is `INITIAL_SP`: the RAM moves around it disagree (+0 and -4), so
it is not guessed.

The 17 manual rows that do not port are:

- the six DSP names, as in 935;
- the `SdSnd*` index accessors (8 rows, two of them `_entry`);
- `DspTypeRecordTable` and `LibF64ToI16`;
- `TechnicsRhythmsTable`, a table-flash address that table 80 does not hold.

Of the 49 edited routines, 41 are reflection-named: 893's own tables put them there, so the
name is certain. Most are SD-card list, title and switch handlers. The other 8 were read one
by one with `check_ported_names.py --list-differs`. Seven have the same or nearly the same
instruction count: `ResetEntry`, `DspManagerInit`, `SdCardDetectDebounce`,
`SdCardUsableCheck`, `SdAudListIndexSetClamped`, `_findnext` and `SDModuleModeReq`. The eighth,
`TechniChordCompute`, has the same prologue, the same helper call and the same RAM store as in
941, and 893 adds an early return in front of them. That is why its first return comes after
19 instructions instead of 70.
