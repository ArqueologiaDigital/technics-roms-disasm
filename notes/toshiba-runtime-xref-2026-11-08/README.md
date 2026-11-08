# Toshiba's development tools against our images (2026-11-08)

**Question.** Does any code in Toshiba's TLCS-900 development tools appear in our ROM images, so that it can be
recognised and cross-referenced?  Felipe asked this after the two tool sets were archived:

- the C compiler v1.10, `SW96CN0-ZCC`, 2009;
- the BMSKTOPAS91FY42 kit CD's "Toshiba IDE Limited Version", whose runtime was assembled in 2003.

`../toshiba-tools-2026-11-07/README.md` says where both are kept.  Both are newer than the firmware, so a third,
older one was then looked for and found (same day): **TLCS-900 C Compiler V4.23** of 1998, as shipped in SNK's Neo
Geo Pocket Color SDK.  Its runtime's members were assembled on 1997-05-26.  Where it is kept, and what it settles,
is under "The 1998 compiler (V4.23)" below; the counts in this note include it.

**Answer: yes.**

- Toshiba's C runtime library is linked into every KN5000 program image and into the HD-AE5000.  So is its C
  startup routine.  The images are main CPU v5 to v10, sub-CPU payload v1.40 to v1.42, the table data's boot
  code and HD-AE5000 v1.10i to v2.06i.
- The SX-WSA1R's prom_a carries two of its arithmetic helpers.
- 437 exact routine or table hits, verified with relocated fields masked, name code that we had named by hand.
- 121 more names come from the calls and pointers inside those routines.
- 25 more routines or tables match closely but not exactly.
- The firmware's runtime is neither of the three builds: it was compiled after 1997-05-26 and before the 2003 build
  (see "The 1998 compiler (V4.23)").  (Before the 1997 build was added: 391 hits, 130 names, 25 near matches.)
- Most of our labels already described these routines correctly.  About two dozen do not; see "Proposed renames".
- Toshiba's SFR headers confirm our TMP94C241 register names: 184 of 185 agree.  They also confirm the
  SX-WSA1R's TMP95C061 names, which came from MAME: 93 of 107 agree.
- There is no kernel or uITRON code in either tool set.  The KN5000 and WSA1R kernel (`wsa1/kernel/kernel.s`) has
  no match here.

Inputs were read only.  No Toshiba program was run.  No Toshiba binary, and no run of more than a few
signature bytes, is committed here; only names, sizes, addresses and our labels.

## How the libraries were read

The three `c900ml.lib` files (207 members in V4.23, 155 in v1.10) and the two `c900pic.lib` files (83 members in
v1.10) are IEEE-695 libraries.  `ieee695.py` reads them:

- **The directory.** The first module is named `LIBRARY`.  Each `F8 14` block in it gives one member's file offset
  and size, plus its public and external names.
- **Each member.** Each member is an IEEE-695 module with processor `T900`.  The reader uses the `W` part offsets
  (`E2 D7`) to find three parts:
  - the section part: `E6` type and name, `E2 D3` size;
  - the external part: `E8` / `E9` names, `E2 C9` public values (`R<section> + offset`);
  - the data part.
- **The data part.** It is made of `E5` (current section), `E2 D0` (PC) and `E4` load records, in which
  - `n` (below 0x80) is followed by `n` literal bytes;
  - `BC expr size BD` is a relocated field;
  - `BA expr ... size BB` is a PC-relative, range-checked field (calr / jrl);
  - `F7 n` repeats the next `E4` record's literal bytes `n` times.

The parse was checked by decoding `_strcpy`: its 118 bytes disassemble as the routine, with `call _memchr` /
`call _memcpy` as relocated 24-bit fields.

The member records also carry each member's build.  The v1.10 runtime was assembled with asm900 `2.2j.73` on
2008-12-05; its `thc1` is 1.8r.21.  The kit-CD runtime was assembled with asm900 `2.2hj` on 2003-10-20; its `thc1`
is 1.8r.15.  All 207 members of the V4.23 runtime were assembled with asm900 `2.2b` on 1997-05-26; they record no
`thc1` version.  (The date is the `82 07 cd 05 1a ...` record after the assembler version string: year 0x07cd,
month, day, hour, minute, second.)

## Method

1. `lib_match.py` cuts every section of every member at its public symbols, giving one piece per routine or table.
   It searches each piece in each image.
   - The anchor is the piece's longest run of known bytes.
   - Every other known byte must agree.
   - Relocated bytes are wildcards.
2. `xref_runtime.py` runs that over the five libraries and the 19 images, and keeps the trustworthy hits.
   - It searches the PT_LOAD segments of each image's linked ELF, so addresses are linked addresses.
     `make gate` proves those bytes equal to the reference image.
   - It keeps a piece only if it has at least 12 known bytes, at least 6 distinct values, and at most 4 hits in an
     image.  Fill and tiny tables match everywhere otherwise.
   - For every hit, it reads the targets of the piece's relocated calls and pointers back from the image.
   - When two library pieces look identical except for relocated fields, it tells them apart by those targets.
     An example is `._fdiv_d` and `._fmul_d`, which differ only in the routine they call.  It scores each
     candidate's callees against the library code of the routines they name.  The result is the `callee score` in
     the check column.
   - A reference that lands on another hit confirms the hit (`refs confirmed N`).
   - A reference that lands where no piece matched gives that address the library name (`xref.inferred.tsv`).
   - It names every address from the ELF's symbols.
3. `near_match.py` looks for pieces with no exact hit.  It tries starts that share any 6-byte known window and
   reports the best one scoring at least 80 % of known bytes.  It runs over one image of each family.
4. `startup_idiom.py` finds the zero-fill and copy loops of Toshiba's C startup, `Stc94ml.mac` / `Stc95ml.mac`, by
   instruction bytes with branch displacements wildcarded.
5. `sfr_compare.py` compares Toshiba's `Io900h2.h` (TMP94C241) and `Io900h.h` (TMP95C061F) with our SFR `.equ`
   files, address by address.
6. `common_blocks.py` looks for exact blocks of 24 bytes or more shared with:
   - the kit's ROM monitors, `91FY12/22/27/42.bin` and `internal.bin`;
   - all 18 debugger POD firmwares, `Config/Debugger/TLCS-900/Tool/Firmware/*.M25`, one of them `UF94C241.M25` for
     our CPU.

   It drops fill and counting sequences.

## Results

### Hits per image

Columns after the first two: which runtime builds a hit matches.  1997 = V4.23, 2003 = kit-CD IDE, 2008 = v1.10.

| image       | exact hits | 1997 + 2003 + 2008 | 1997 + 2003 | 2003 + 2008 | 1997 + 2008 | 1997 | 2003 | 2008 |
|-------------|------------|--------------------|-------------|-------------|-------------|------|------|------|
| maincpu v10 | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v9  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v7  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v6  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| maincpu v5  | 28         | 9                  | 15          | 0           | 0           | 2    | 2    | 0    |
| subcpu v142 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| subcpu v141 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| subcpu v140 | 54         | 21                 | 22          | 0           | 0           | 10   | 1    | 0    |
| table data  | 5          | 1                  | 4           | 0           | 0           | 0    | 0    | 0    |
| hdae v2.06i | 33         | 16                 | 12          | 1           | 0           | 2    | 2    | 0    |
| hdae v2.01i | 33         | 16                 | 12          | 1           | 0           | 2    | 2    | 0    |
| hdae v1.15i | 31         | 16                 | 11          | 1           | 0           | 1    | 2    | 0    |
| hdae v1.10i | 31         | 16                 | 11          | 1           | 0           | 1    | 2    | 0    |
| wsa1 prom_a | 2          | 1                  | 1           | 0           | 0           | 0    | 0    | 0    |

The following images have no hits: the sub-CPU boot (IC30), the custom data, and the SX-WSA1R's prom_b, prom_c and
prom_d.

**Which build is closer.**  (Corrected the same day.  With only the 2003 and 2008 builds, this said that 1 to 23
routines per image match only the 2003 one, so the firmware's runtime is "closer to the kit CD's".  The 1997 build
shows that most of those match it too: they are older code that the 2003 build had kept.)
- No routine matches only the 2008 runtime.  The v1.10 runtime rewrote several string routines: its `_strcpy`
  calls `_memchr` and `_memcpy`.
- 2 to 10 per image match only the 1997 one.  They are `_memccpy`, `_strrchr` and `_strrev`, and in the sub-CPU
  the math routines `_cos`, `_sin`, `_tan`, `__trig`, `_pow`, `_exp`, `_log` and `_modf` with the constant tables of
  `_pow` and `_exp`.  The 2003 build changed them.
- Three routines match the 2003 build (and for `_ldiv` the 2008 one too) but not the 1997 one: `_ultoa`, `_ldexp`
  and `_ldiv`.  The "2003" column also counts the `__doform` hex-digit strings, but those are the same in all
  builds: only the 2003 `c900pic.lib` cuts them into a piece of their own.
- So the firmware's runtime is neither build.  It sits between them, as the firmware's date (1998-2000) suggests.
  "The 1998 compiler (V4.23)" below shows what the differences are.

`results/tables.md` has every hit and inferred name for v10, v142, the table data, HD-AE5000 v2.06i and WSA1
prom_a.  `results/xref.resolved.tsv` and `results/xref.inferred.tsv` cover all 19 images.

### Main CPU v10 (the same routines in v5 to v9)

The C string, conversion and arithmetic runtime, at `0xff091d`-`0xff0ffa` and `0xff27f7`-`0xff28e9`, plus `__ctype`
at `0xeed778`.

| address  | Toshiba name | our label                  |
|----------|--------------|----------------------------|
| 0xeed778 | `__ctype`    | `CType_ClassTable`         |
| 0xff091d | `_strstr`    | `TmFlash_CompareStrings`   |
| 0xff097d | `_strcspn`   | `StrSearch_Init`           |
| 0xff09a0 | `_atoi`      | `ParseInt16`               |
| 0xff09f6 | `_atol`      | `ParseInt32`               |
| 0xff0a5c | `C9H_mullu`  | `Math_Multiply32`          |
| 0xff0bc3 | `SDivMod`    | `Math_DivModSigned32`      |
| 0xff0c12 | `C9H_remlu`  | `Math_RemainderU32` (call) |
| 0xff0c18 | `C9H_divlu`  | `Math_DivideU32`           |
| 0xff0cc1 | `_strncmp`   | `String_Compare`           |
| 0xff0d1e | `_memcmp`    | `Mem_Compare`              |
| 0xff0d99 | `_memcpy`    | `Mem_Copy`                 |
| 0xff0de3 | `_itoa`      | `Itoa_Safe`                |
| 0xff0f79 | `.sbrk`      | `Heap_Alloc`               |
| 0xff0fbe | `_ltoa`      | `Strlen_LoadParam`         |
| 0xff27f7 | `_ultoa`     | `Sprintf_ItoaBaseN`        |
| 0xff2880 | `._fld_xx`   | `Sprintf_CopyBytes10`      |
| 0xff2891 | `_memccpy`   | `Sprintf_StringNSearch`    |
| 0xff28d1 | `_memchr`    | `Sprintf_MemChr`           |
| 0xff28e9 | `_strnset`   | `Sprintf_StrNSet`          |
| 0xff2909 | `_strrchr`   | `Sprintf_StringLength`     |

The rest already carry the library's name: `Strncat`, `Strncpy`, `Strcat`, `Strchr`, `Strcpy`, `Strlen` and
`Memset`.

Two more names come from references:
- `.sbrk`'s pointers name the RAM cells `_SBRK_break` (`0x03d524`) and `_SBRK_size` (`0x03d528`);
- `0x03d524` is also where the startup copies the initialised data (below).

There are near matches too:
- `0xff2139` `Sprintf_FormatGGeneral` is `__facnv`, the float-to-decimal converter of `%e` / `%f` / `%g`: 0.95 of
  its 1,635 known bytes against the 1997 build;
- `0xeed878` `Sprintf_TypeSwitch` is the `__doform` constant table, scoring 0.87 against the 2003 build
  (`doform_switch.py` shows its offsets lie between the 1997 and 2003 builds);
- `_vsprintf` scores 0.88 at `Sprintf_Unlocked+3`.

`printf`'s `__doprnt` itself does not match: the firmware's is a different build.

### Sub-CPU payload v1.42 (the same in v1.40 and v1.41)

Toshiba's whole software floating-point package, at `0x03d2ac`-`0x03ee3e`:
- double and float add, sub, mul, div, cmp and neg;
- conversion to and from integers;
- the unpacked-accumulator internals (`._fset_*`, `._fadj_*`, `._fadd_acf`, `._fsub_acf`);
- `_frexp`, `_ldexp`, `_fabs` and `__fint`.

Its tables sit at `0x00f34e`-`0x00f428`: `__trig_c`'s coefficients, `_g_dbltbl`, `_g_ldbltbl` and `_g_mathtbl`.

The math routines are exact against the 1997 build: `_cos`, `_sin`, `_tan` and `__trig` (`FP_cos`, `FP_sin`,
`FP_tan`, `FP_SinCos_Kernel`), `_pow`, `_exp`, `_log` and `_modf` (`FP_pow`, `FP_exp`, `FP_log`, `FP_modf`), and
the constant tables of `_pow` and `_exp` at `0x01f646` and `0x01f6b6`.  Against the 2003 build only `_cos`, `_tan`,
`_log` and `_pow` had matched, and only nearly (0.81-0.86).

The near matches left:
- `._fdiv_acf` at `FP_SP_DivCore` (0.88, 1997 build), `._fsub_acf` at `FP_SP_SubMantissa+2` (0.91) and
  `._fadd_acf` at `FP_SP_AddMantissa+2` (0.80);
- two more constant tables at `0x01f666` and `0x01f6be` (0.80, 0.91);
- the 2003 build's `_pow` 10 bytes before `FP_pow` (0.81), which is the 1997 build's exact hit seen through the
  other build.

Our `FP_*` names were right about what nearly every routine does.

### Table data (the update / boot code at the top of the ROM)

| address  | Toshiba name | our label        |
|----------|--------------|------------------|
| 0x9ffb2f | `.sbrk`      | `Boot_sbrk`      |
| 0x9ffb56 | `_malloc`    | `Boot_malloc`    |
| 0x9ffbdc | `_strncmp`   | `Boot_memcmp`    |
| 0x9ffc0e | `SDivMod`    | `Boot_SDivMod32` |
| 0x9ffc63 | `C9H_divlu`  | `Boot_UDivMod32` |

The references also name three RAM cells: `_SBRK_break` (`0x009998`), `_SBRK_size` (`0x00999c`) and `__allocb`
(`0x0099a0`).

### HD-AE5000 (v1.10i to v2.06i)

33 hits in v2.06i:
- the string and memory routines;
- `_sprintf` and `_vsprintf`, which call `__doprnt` = `HDAE5000_DoPrintf`;
- `_itoa`, `_ltoa`, `_ultoa` and `_ldiv`;
- the float pack / unpack, conversion and divide routines;
- `C9H_mullu` and `SDivMod`, with `C9H_divls`, `C9H_remls`, `C9H_divlu` and `C9H_remlu` named by reference;
- `__ctype`.

Our `HDAE5000_*` labels agree with all of them.  With the 1997 build, `_memccpy` and `_strrev` are exact too.
Near matches: `HDAE5000_FltDec_Convert` is `__facnv` (0.95, 1997 build), as in the main CPU;
`._fdiv_acf` is `HDAE5000_Unpacked_Div` (0.88); `HDAE5000_DoPrintf_ConvTable` is `__doform`'s constant table (0.87).

### SX-WSA1R prom_a

Two hits: `C9H_mullu` = `Int_Mul32` (`0xfe68dd`) and `SDivMod` = `Int_SignedDiv` (`0xfe68f3`), as one 108-byte
block.  They are the only cc900 runtime in the WSA1R images, and its startup is not Toshiba's template.

### The C startup: `__startup` of `Stc94ml.mac`

`results/startup_idiom.txt` lists every zero-fill and copy loop of Toshiba's startup template, with the start,
source and size loaded before it.

The startup does three things, filled in by the linker:
1. it zero-fills the `f_area` sections;
2. it copies `f_data` from ROM to `__DataRAM`;
3. it jumps to `__Initial`.

Per image:
- **Main CPU v10:** `Boot_InitWorkRAM` is exactly that template, with two area / data pairs.
  - It zero-fills `0x010000`+`0x2d524` and `0x000400`+`0xdf5d`.
  - It copies `WorkRamInit_Image` (`0xeed8c8`, `0x219e` bytes) to `0x03d524` and `WorkRamInit_Image2` to
    `0x00e35e`.
  - So `0x03d524` = `0x010000` + `0x2d524`: the data lands right after the area, as `C94.lcf`'s
    `far_data addr=org(far_area)+sizeof(far_area)` puts it.
- **Sub-CPU payload:** `MemClear_DRAM_And_ExtRAM` and `MemClear_ExtRAM` are its two zero-fills.
- **Table data:** `Boot_ClearRAM`, with two zero-fills and two copies.  The data lands at `0x009998` = `0x00104e` + `0x894a`,
  where `_SBRK_break` lives.
- **HD-AE5000:** `HDAE5000_Clear_Work_Buffer`, with its data at `0x23952a` = `0x22a000` + `0xf52a`.
- **Sub-CPU boot (IC30):** `COPY_VECTORS` uses the copy loop alone.

Our names for the loops' inner labels (`MemCopy_DataValidation`, `MemCopy_SetupAndDMA`) do not describe them.  They
are the template's `FAR_AREA_2` / `FAR_AREA_1` steps: the odd byte, then the next block.

### SFR names

`results/sfr_tmp94c241.md` compares Toshiba's `Io900h2.h` ("For TMP94C241", 1997) with
`v10/maincpu/shared/sfr_tmp94c241.s`.
- Every one of its 185 addresses is in ours.
- 184 have the same name.  The odd one is 0x82: Toshiba's `TFFCR`, our `T02FFCR`.
- The v9, v7 and v142 copies give the same result.

`results/sfr_tmp95c061.md` compares `Io900h.h` ("For TMP95C061F", 1994-96) with `wsa1/include/tmp95c061_sfr.inc`,
whose names were taken from MAME because no databook was available.
- 93 of 107 agree.
- Toshiba spells the port data registers `IOP1`...`IOPB`, where we and MAME write `P1`...`PB`.
- Toshiba orders the timer interrupt-enable names `INTET01`, `INTET23`, `INTET45` and `INTET67`; ours are
  `INTET10`, `INTET32`, `INTET54` and `INTET76`.
- Toshiba defines `P1FC` at 0x05, which ours lacks.
- Our 0xf1 / 0xf2 entries are not SFRs.

So Toshiba's own header now backs the include's names, which so far rested on MAME alone.

### The 1998 compiler (V4.23)

**Where it is kept.**  SNK's Neo Geo Pocket Color SDK shipped Toshiba's tools.  Three community copies are kept in
`~/compartilhado/upstream_repos/file_archive/`, each its own git repository whose first commit is the download:
- `devrs.com/ngpcbins/` (root `d5fbaa1`): `ngpcbins.zip`, from devrs.com.  The live file equals the Wayback
  Machine's captures of 2020-2021.  Its `T900/` is a 2000-04-09 install of TLCS-900 C Compiler V4.23 and
  Assembler V2.23.  `T900/README/HIS96CE0.TXT` (1998-07-01) gives the versions: cc900 V1.33, thc1 V08o0216,
  thc2 V08n0411, c900ml.lib V4.23.  The executables are dated 1998-02-12 to 1998-06-29.  `LIB/SRC/` holds the
  runtime's C and assembler source.
- `sebastianmihai.com/ngpc/` (root `1330e81`): Sebastian Mihai's dev kit (2012).  Its `T900/` is devrs.com's, plus
  three files.
- `franck.charlet.pagesperso-orange.fr/NGPC_SDK/` (root `d60d3c2`): Franck Charlet's kit (2017), from the Wayback
  Machine.  It has the same `C900ML.LIB` and history files, but the 2008-2009 executables (byte-identical to
  v1.10's) in place of the 1998 ones.

**What its runtime shows.**  Its `c900ml.lib` is the "1997" build in the tables above.  `build_diff.py` writes
`results/build_diff.md`: for every hit that some build does not match, how that build's copy differs.  The C sources
of the routines involved are all older than that build: `_LDIV.C` and `_ULTOA.C` 1994-12-05, `_LDEXP.C` 1995-06-20,
`__DOFORM.C` 1997-02-07.  So where the firmware differs from the 1997 build, the compiler differs, not the source:
- `_ldiv`: in the 1997 build, `bf 08 60` (store XWA to `(xsp+8)`) is followed by `af 08 20`, `ld xwa, (xsp+8)`,
  which reloads the value just stored.  The firmware has the 2003 build's 67 bytes, without that reload.
- `_ldexp`: the 1997 build is 3 bytes longer.  The first difference is a branch displacement at +42.
- `_ultoa`: the same 136 bytes, but the 1997 build has `af 08 20` (`ld xwa, (xsp+8)`) and `b8 20 00 00` in the
  opposite order.  The firmware has the 2003 order.
- `__doprnt`, which matches nowhere: its case table (`Sprintf_TypeSwitch`, `0xeed878`) holds 22 offsets into the
  routine.  Every offset past 105 is 3 lower in the firmware than in the 1997 build (272 -> 269, 1764 -> 1761).  The
  2003 build has the same 3 bytes fewer, and 1 more byte fewer between its offsets 1674 and 1760, which the firmware
  does not have (1761).  So in this routine too, the firmware's code is later than 1997 and earlier than 2003.

The routines that match only the 1997 build show the other bound.  `_memccpy`, `_strrchr`, `_strrev` and the
sub-CPU's math routines were changed again by 2003.

So the firmware's runtime was compiled after 1997-05-26, by a code generator that already dropped that reload, and
before the 2003 rewrites.  V4.23's own thc1 / thc2 (1998-06-04) fit those dates.  Whether they produced exactly these
bytes needs them run: compile `LIB/SRC/_LDIV.C`, `_ULTOA.C`, `_LDEXP.C` and `__DOFORM.C` with them, in a VM, and
compare with the firmware.  Toshiba shipped the runtime's source so that users could rebuild it.  So the firmware's
runtime may have been rebuilt with its developers' own compiler, and then it would also show which compiler built
their C.

V4.23's `CUSTOMIZ/C900_H2/IO900H2.H` (TMP94C241, 1997-06-01) is the same file as the kit CD's `Io900h2.h`, apart
from line endings, so the SFR comparison below holds for it too.

### Negative results

- **The kernel.** No code in either tool set matches `wsa1/kernel/kernel.s` or any kernel routine of ours.  The only
  uITRON trace on the kit CD is the IDE's RTOS-aware debug window (`System/Target_Dependent/RtosW.tlb`); there is no
  kernel library.  So the hypothesis that Toshiba supplied the kernel is neither confirmed nor refuted here.
  `../toshiba-tools-2026-11-07/README.md` says what would settle it.
- **The ROM monitors.** They share only the cc900 runtime's `SDivMod` block with our images (85-108 bytes, in
  every image listed above).
- **The POD firmwares.** Including `UF94C241.M25`, which is 68000 code for the emulator pod, they share nothing
  but fill and counting tables.
- **Compiler idioms.**
  - Compiled C calls these helpers with cc900's interface, through `C9H_mullu`, `C9H_divlu`, the `._f*` float
    entry points and `__ctype`.  For example, `call Math_Multiply32` appears 163 times in `v10/maincpu`'s text,
    not counting compiled-C `.incbin`s.
  - Together with the startup template, that makes the KN5000's C cc900 output, linked with Toshiba's runtime.
  - The runtime alone does not tell which cc900 version compiled it.  The code generator's output was not compared
    in this pass, because nothing here runs the Windows compilers.  The 1997 build narrows it: see "The 1998
    compiler (V4.23)".

## Proposed renames (for a later lane; nothing was renamed here)

Each row is backed by an exact hit in `results/xref.resolved.tsv`, or by a reference in `xref.inferred.tsv` where
marked "(ref)".  The table gives Toshiba's name; the new label is for that lane to choose, and Toshiba's name should
go into the header comment whatever the label becomes.

| image(s)      | address  | our label                                       | Toshiba name               | why                                                                      |
|---------------|----------|-------------------------------------------------|----------------------------|--------------------------------------------------------------------------|
| maincpu v5-10 | 0xff0fbe | `Strlen_LoadParam`                              | `_ltoa`                    | it is ltoa(value, buf, radix): '-' for negative base 10, then `_ultoa`   |
| maincpu v5-10 | 0xff091d | `TmFlash_CompareStrings`                        | `_strstr`                  | library strstr; nothing flash-specific                                   |
| maincpu v5-10 | 0xff097d | `StrSearch_Init`                                | `_strcspn`                 | a complete routine, not an init step                                     |
| maincpu v5-10 | 0xff0f79 | `Heap_Alloc`                                    | `.sbrk`                    | sbrk: moves `_SBRK_break`; `_malloc` is elsewhere                        |
| maincpu v5-10 | 0xff27f7 | `Sprintf_ItoaBaseN`                             | `_ultoa`                   | library ultoa, used by `_ltoa` / `_itoa` too                             |
| maincpu v5-10 | 0xff2891 | `Sprintf_StringNSearch`                         | `_memccpy`                 | called by `_strcpy` as memccpy; exact against the 1997 build             |
| maincpu v5-10 | 0xff2909 | `Sprintf_StringLength`                          | `_strrchr`                 | strlen + 1, then scans backwards for the character: strrchr              |
| maincpu v5-10 | 0xff2139 | `Sprintf_FormatGGeneral`                        | `__facnv` (near, 0.95)     | the whole float-to-decimal converter, not only `%g`; another build of it |
| maincpu v5-10 | 0xff28d1 | `Sprintf_MemChr`                                | `_memchr`                  | not sprintf-private                                                      |
| maincpu v5-10 | 0xff28e9 | `Sprintf_StrNSet`                               | `_strnset`                 | not sprintf-private                                                      |
| maincpu v5-10 | 0xff0cc1 | `String_Compare`                                | `_strncmp`                 | bounded compare                                                          |
| maincpu v5-10 | 0xff09a0 | `ParseInt16`                                    | `_atoi`                    | (int is 16-bit in cc900's model)                                         |
| maincpu v5-10 | 0xff09f6 | `ParseInt32`                                    | `_atol`                    |                                                                          |
| maincpu v5-10 | 0x03d524 | (none)                                          | `_SBRK_break` (ref)        | RAM cell, first of the initialised data                                  |
| table data    | 0x9ffbdc | `Boot_memcmp`                                   | `_strncmp`                 | stops at a NUL: strncmp, not memcmp                                      |
| table data    | 0x009998 | (none)                                          | `_SBRK_break` (ref)        | with `_SBRK_size` 0x00999c, `__allocb` 0x0099a0                          |
| subcpu v14x   | 0x00f428 | `FPConst_Zero`                                  | `__FloatErrorHandle` (ref) | a cell `._fset_dac` reaches through, not a constant                      |
| subcpu v14x   | 0x00f420 | `FPConst_MaxNorm`                               | `_g_mathtbl` (ref)         | `_ldexp`'s limit table                                                   |
| subcpu v14x   | 0x03dfd6 | `FP_SP_Normalize`                               | `._fcvt_dacl` (ref)        | `._fld_dl` (long -> double) calls it: DP, not SP?                        |
| subcpu v14x   | 0x03de1a | `FP_DP_Normalize`                               | `._fcvt_facl` (ref)        | `._fld_fl` (long -> float) calls it: SP, not DP?                         |
| subcpu v14x   | 0x03de33 | `FP_DP_NormCore`                                | `._fcvt_facul`             | the float variant, by Toshiba's name                                     |
| subcpu v14x   | 0x03dfef | `FP_SP_NormCore`                                | `._fcvt_dacul` (ref)       | the double variant, by Toshiba's name                                    |
| subcpu v14x   | 0x03ea34 | `FP_SP_DecodeToInt`                             | `._fcvt_uldac` (ref)       | double accumulator -> unsigned long                                      |
| subcpu v14x   | 0x03dd51 | `FP_DP_CallWithBuf12`                           | `._fld_dul`                | callee score 0.50 vs 0.00 against `._fld_dl`                             |
| all KN5000    | startup  | `MemCopy_DataValidation`, `MemCopy_SetupAndDMA` | `FAR_AREA_2`-style steps   | the template's odd-byte step, not validation or DMA                      |

The four SP/DP rows are a question for that lane, not a finding.  Toshiba's `d`/`f` names and our SP/DP names
disagree on exactly these routines; on `._fset_acd` / `._fset_acf` they agree.  Reading the code settles it.

## Files

| file               | what question it answers / how to run                                                                                                                                                                           |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ieee695.py`       | reads a Toshiba IEEE-695 library: `python3 -I ieee695.py LIB [--dump MEMBER]` lists members, sections, sizes, relocations                                                                                       |
| `lib_match.py`     | masked search of library pieces in raw images (the matcher the others import); standalone: `python3 -I lib_match.py --lib N=FILE.lib --img N=FILE@BASE`                                                         |
| `xref_runtime.py`  | which runtime routines are in our images and under which labels: `python3 -I -B xref_runtime.py results/xref.tsv > results/xref.summary.txt`; writes `xref.tsv`, `.resolved.tsv`, `.inferred.tsv`               |
| `md_tables.py`     | the Markdown tables: `python3 -I -B md_tables.py results/xref.resolved.tsv results/xref.inferred.tsv > results/tables.md`                                                                                       |
| `near_match.py`    | routines that match nearly (another build): `python3 -I -B near_match.py results/xref.resolved.tsv results/near.tsv` (about 10 minutes)                                                                         |
| `build_diff.py`    | where the three runtime builds differ, on the hits that some build does not match: `python3 -I -B build_diff.py results/xref.resolved.tsv > results/build_diff.md`                                              |
| `doform_switch.py` | `__doprnt`'s size per build, from its case table (firmware v10 and the three builds): `python3 -I -B doform_switch.py > results/doform_switch.txt`                                                              |
| `startup_idiom.py` | where Toshiba's `__startup` loops are: `python3 -I -B startup_idiom.py > results/startup_idiom.txt`                                                                                                             |
| `sfr_compare.py`   | Toshiba's SFR header against ours: `python3 -I -B sfr_compare.py <Io900h2.h> v10/maincpu/shared/sfr_tmp94c241.s --md > results/sfr_tmp94c241.md` (likewise `Io900h.h` against `wsa1/include/tmp95c061_sfr.inc`) |
| `common_blocks.py` | exact blocks shared with the ROM monitors and POD firmwares: `python3 -I -B common_blocks.py <unpacked>/rom-monitor/*.bin <Firmware>/*.M25 <Firmware>/*.m25 > results/common_blocks.tsv`                        |

Inputs and their paths are given in `xref_runtime.py` (`TOSHIBA_V423`, `TOSHIBA_IDE`, `TOSHIBA_V110`):
- the V4.23 install tree: `~/compartilhado/upstream_repos/file_archive/devrs.com/ngpcbins/`, under
  `unpacked/zip/T900/`;
- the v1.10 install tree: `~/compartilhado/upstream_repos/file_archive/archive.org/ToshibaTLCS900CompilerV1.10/`,
  under `unpacked/msi/install-1033/TOSHIBA/T900/`;
- the kit CD's IDE: `~/compartilhado/upstream_repos/file_archive/github.com/colinoflynn/Toshiba-TLCS-900-L-Resources/`,
  under `unpacked/toshiba-ide/install-1033/Toshiba/IDE/`.

The images are the linked ELFs of a built tree (`make all`, `make -C wsa1`); `make gate` proves them equal to the
references.  `TMPDIR=~/compartilhado/tmp`.

Open:
- the near matches show where a different build of a routine sits.  Aligning them instruction by instruction would
  name their internal labels;
- `__doprnt` in the main CPU and the HD-AE5000 has no exact match; its case table places it between the 1997 and 2003
  builds (`doform_switch.py`);
- which compiler built the firmware's runtime, and its C: V4.23's thc1 / thc2 fit the dates.  Running them in a VM on
  the runtime's sources (above) would test it.
