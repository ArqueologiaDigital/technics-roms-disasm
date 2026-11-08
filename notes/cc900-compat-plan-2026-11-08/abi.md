# The cc900 ABI, as the oracle shows it (phase 0, 2026-11-08)

What `-mabi=cc900` has to implement.  Every rule below comes from compiling our probe files
(`scripts/analysis/cc900/corpus/abi/*.c`, one question per file) with the three dev-kit compilers in the oracle VM:
oracle run `2026-11-08-4-abi` (private repository `~/compartilhado/cc900-oracle`, commit `e40c003`), with no options
and with `-O3 -XS`.  "probe:function" names the C function whose listing shows the rule.

**The three compilers agree on all of it.**  V4.23 (code generator 0.8n.04.11), the 2003 IDE (1.8n.05.45) and v1.10
(1.8n.06) give the same listing for every probe except in code-generation details.  They differ in one `fdatad`
spelling, one varargs loop, a `double`-to-`long` temporary and one load placement.  So the ABI is one target, and the
differences belong to the personalities.  All listings are "maximum" mode (`$MAXIMUM`, `large` sections), the mode of
the KN5000 firmware and of `c900ml.lib`.

## Types

| type          | size               | alignment | evidence                                                                               |
|---------------|--------------------|-----------|----------------------------------------------------------------------------------------|
| `char`        | 1                  | 1         | sizes:`sz_char`; plain `char` is **signed** (sizes:`signed_char_test` = 1)             |
| `short`       | 2                  | 2         | sizes:`sz_short`, `sz_s_cs` = 4                                                        |
| `int`         | 2                  | 2         | sizes:`sz_int`, `off_ci` = 2                                                           |
| `long`        | 4                  | 2         | sizes:`sz_long`, `off_cl` = 2, `sz_s_cl` = 6                                           |
| pointers      | 4                  | 2         | sizes:`sz_ptr`, `sz_fptr`, `sz_s_cp` = 6                                               |
| `float`       | 4                  | 2         | sizes:`sz_float`, `sz_s_cf` = 6                                                        |
| `double`      | 8                  | 2         | sizes:`sz_double`, `off_cd` = 2, `sz_s_cd` = 10; IEEE-754, little-endian (`g_d` = 6.0) |
| `long double` | 10                 | 2         | sizes:`sz_ldouble`                                                                     |
| structs       | rounded up to even | 2         | sizes:`sz_s_c` = 2 (one `char`), `sz_s_cc` = 4 (three), `sz_s_lc` = 6                  |

`size_t`, `ptrdiff_t` and `wchar_t` still need a probe (from `stddef.h`).  Globals of 2 bytes or more start at even
addresses: asm900 leaves the byte before them unwritten (sizes: `g_c1` at 42, `g_i` at 44).

## Calls

- **Every argument goes on the stack**, pushed right to left, so the first argument is nearest the return address.
  The return address takes 4 bytes, so a leaf function finds its first argument at `(XSP+4)`
  (args_callee:`a_i`, `a_second` at `+6`).
- **Argument slots**: `char`, `short` and `int` take 2 bytes; `char` is sign-extended to 16 bits first
  (args_caller:`c_c`: `ld A,(_gc)` / `exts WA` / `push WA`; a constant is `pushw 5`).  `long`, pointers and
  `float` take 4 bytes.  `double` takes 8 bytes, high half pushed first (args_caller:`c_d`).  Structs are copied onto
  the stack at their size (structs:`s_pass_pair`, `s_pass_big`).  args_callee:`a_mix` shows the offsets:
  `char` +4, `int` +6, `long` +8, pointer +12.
- **The caller removes the arguments**: `inc N,XSP` for N up to 8, `lda XSP,XSP+N` above (args_caller:`c_mix`,
  `c_six`).  Several calls in a row can share one adjustment at the end (args_caller:`c_two`: `pushw 1` / `cal` /
  `pushw 2` / `cal` / `inc 4,XSP`).
- **Variadic functions use the same convention** (varargs:`v_call`, `v_sum`, `v_long`).  `va_arg` walks a pointer up
  from the last named argument.
- **Calls through a pointer** are `ld XWA,<pointer>` / `call XWA` (fptr:`fp_call`, `fp_arg`).

## Results

| result type                       | where                                                                                                                                              | evidence                                  |
|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `char`                            | L (not extended)                                                                                                                                   | returns:`r_c`, `use_c`; args_callee:`a_c` |
| `unsigned char` promoted to `int` | HL (`extz HL`)                                                                                                                                     | args_callee:`a_uc`                        |
| `short`, `int`                    | HL                                                                                                                                                 | returns:`r_i`                             |
| `long`, pointers, `float`         | XHL                                                                                                                                                | returns:`r_l`, `r_p`, `r_f`               |
| struct of up to 4 bytes           | XHL                                                                                                                                                | returns:`r_pair`, `use_pair`              |
| larger struct, `double`           | memory: the caller passes the destination's address as a hidden **first** argument, pushed as two words (`pushw _gd >> 16` / `pushw _gd & 0xffff`) | returns:`r_big`, `r_d`, `use_d`           |

The two-word push of an address is the source of the `pushw Sym@hi16` / `pushw Sym@lo16` pairs in the firmware
(CLAUDE.md, "Far pointer as two word pushes").  String literals passed as arguments are pushed the same way
(varargs:`v_call`).

## The register convention: `__adecl` (`-Xr`), which the firmware's own C uses

cc900 has a second function type.  `__adecl` (a function qualifier, `#pragma adecl`, or `-Xr` for a whole file)
passes the first three arguments in registers; the documentation is the v1.10 C compiler reference, section 3.2.1,
and V4.23 already implements it (its `THC1.EXE` holds the strings `adecl` / `cdecl`; oracle run
`2026-11-08-6-abi-adecl`, cc900-oracle commit `e8a18a4`, probes `corpus/abi/adecl.c` and the others with `-Xr`
and `-O3 -XS -Xr`).  The three compilers agree on it as well.

| rule                                                                                                                    | evidence                                            |
|-------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| 1st argument in A / WA / XWA (by size), 2nd in BC / XBC, 3rd in DE / XDE; a `long` or pointer uses the 32-bit register  | adecl:`d_c`, `d_i2`, `d_l3`, `c_t2`, `c_t3`         |
| 4th and later arguments on the stack, **pushed left to right** (the 4th first), found from `(XSP+4)` upwards            | adecl:`c_t4`, `c_t5`, `d_i4`, `d_i5`                |
| the callee removes its stack arguments: `retd N`                                                                        | adecl:`d_i4` (`retd 2`), `d_i5`, `d_l4` (`retd 4`)  |
| result in L / HL / XHL as for cdecl; a float, double or struct result is refused (`THC1-Error-373`)                     | adecl:`d_*`; `-Xr` on returns.c, args_callee.c      |
| variadic functions cannot be adecl (`THC1-Error-374`)                                                                   | `-Xr` on varargs.c                                  |
| symbols take a `.` prefix instead of `_` (`.d_c`), so a cdecl and an adecl function never link to each other by mistake | every adecl listing                                 |
| a call whose arguments all fit in registers, in tail position, becomes a jump (`j .t1`)                                 | adecl:`c_t1`, `c_t2`, `c_t3`                        |
| a cdecl function (declared `__cdecl`) is called with the cdecl convention from an adecl file                            | adecl:`c_lib` (`push` / `cal _lib_f` / `inc 6,XSP`) |
| a register argument needed after a call is kept in IZ/QIZ or homed to a stack slot                                      | adecl:`d_keep`                                      |

**The firmware is mostly adecl.**  Its own functions take arguments in XWA / XBC / XDE and end with `retd` when they
have stack arguments, and Toshiba's headers declare every library function `__CDECL` (the library sources do too),
which is what a program compiled with `-Xr` needs.  Its store-then-reload pairs (`ld (xsp+14),xwa` / `ld
xwa,(xsp+14)`: 124 in main CPU v10, 100 in sub-CPU v142, `scripts/analysis/cc900/idiom_census.py`) include such
homed register arguments being read back, at least the two looked at so far (`Voice_Calc_LevelPair_PatchAtk`,
`Flash_EraseSectorAndWrite`): a different case from the cdecl library's reload.  Classifying all of them is phase 4
work.

## Registers

- **Callee-saved: XIZ only.**  A function that keeps values across a call puts them in IZ and QIZ (the two halves
  of XIZ) and saves XIZ: `push XIZ` ... `pop XIZ`, or `push IZ` when only IZ is used (saves:`sv_keep_across`,
  `sv_many`, `sv_register`).  The library's own functions show the same (`compiler_id/prologue_saves.py`).
- **Everything else is scratch** across a call: XWA, XBC, XDE, XHL, XIX, XIY (saves:`sv_many` reloads from the frame
  after `cal _g0`).
- **Register variables** are 16-bit values in IZ and QIZ, even without `register` (saves:`sv_register`,
  `sv_many`).
- **Frame.**  Locals live at `(XSP+d)`: `dec N,XSP` for small frames, `lda XSP,XSP-N` for larger ones, then
  `push XIZ` if XIZ is used.  There is no frame pointer.

## Helpers (the runtime's calling conventions)

| operation                               | call                                                                                                                                 | evidence                             |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| `long` `*`, `/`, `%` (signed, unsigned) | `C9H_mulls`, `C9H_divls`, `C9H_remls`, `C9H_divlu`, ...: operands in XWA and XBC, result in XHL                                      | fptr:`h_lmul` .. `h_uldiv`           |
| `int` `*`, `/`                          | inline `muls` / `divs`                                                                                                               | fptr:`h_imul`, `h_idiv`              |
| `long` shifts by a variable count       | inline: `bit 4,A` / `sla 0,XHL` (16) / `and A,0xf` / `sla A,XHL`                                                                     | fptr:`h_lshl`, `h_lshr`              |
| `float` / `double` arithmetic           | `._fadd_f`, `._fmul_d`, ...: XWA = address of the result, XBC and XDE = addresses of the operands                                    | fptr:`h_fadd`, `h_dmul`              |
| `double` compare                        | `._fcmp_d`: XWA, XBC = operand addresses, DE = condition code; result in HL                                                          | fptr:`h_dcmp`                        |
| conversions                             | `._fld_ld` (`double` to `long`), `._fld_dl` (`long` to `double`), `._fld_dd` (copy): XWA = destination address, XBC = source address | fptr:`h_d2l`, `h_l2d`; returns:`r_d` |
| struct copy                             | inline `ldirw` with BC = words (`ldiw` pairs for 4 bytes)                                                                            | structs:`s_copy`, `s_pass_pair`      |

## Sections and data placement

| section   | holds                                                  | evidence                                          |
|-----------|--------------------------------------------------------|---------------------------------------------------|
| `f_code`  | code (`section code large align=1,1`)                  | every probe                                       |
| `f_data`  | initialised variables, in definition order             | globals:`g_init`, `s_init`, `g_strp`              |
| `f_const` | `const` objects, string literals, `switch` tables      | globals:`c_val`, `c_str`; switch:`sw_dense`       |
| `f_area`  | uninitialised variables, emitted after everything else | globals:`g_bss`, `s_bss`, `gl_local_static`'s `n` |

A string literal or a switch table is emitted at its first use: the listing switches to `f_const` in the middle of
the function, writes the data (`S<n>` labels), and switches back (globals:`gl_lit`, switch:`sw_dense`).  Statics get
no public symbol; externals are declared `extern large`.

## `switch`

Dense cases: a table of 16-bit offsets in `f_const` (`dw L2-L50000`), read with `add WA,WA` / `lda XIX,S50000` /
`ld WA,(XIX+WA)` / `lda XIX,L50000` / `j XIX+WA` after a range check (switch:`sw_dense`).  Sparse cases: a chain of
`cp` / `j eq` (switch:`sw_sparse`).  The threshold between the two still needs probing (phase 1's micro-tests).

## Still to probe

The density threshold of `switch`; bit fields; `size_t` and `ptrdiff_t`; `enum` size; function pointers inside
structs; `alloca` (if supported); the "minimum" memory model (`-ms`?) and the CPU options, which matter for the
Neo Geo Pocket by-product (TLCS-900/H); struct arguments of odd sizes; a `char` as the 2nd or 3rd adecl
argument (C or E?); whether the firmware's adecl functions really were compiled with `-Xr` or with qualifiers.
