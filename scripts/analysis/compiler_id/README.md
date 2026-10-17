# Which compiler built the KN5000 firmware? (2026-10-17)

**Answer:** Toshiba's own TLCS-900 C compiler package. That is `cc900` with its `thc1` / `thc2` passes, the
`asm900` assembler and the `tulink` linker, plus Toshiba's standard library `c900ml.lib`. No ROM image carries a
compiler banner. The proof is that the firmware links Toshiba's runtime library, instruction for instruction. The
write-up is the technics-docs page [Original Toolchain](https://arqueologiadigital.github.io/technics-docs/original-toolchain/),
`technics-docs/original-toolchain.md`.

## The reference: Toshiba's package

A later edition of the package (Ver1.10, 2009) is public, and still holds the 1994-1997 library sources and the
V4.23 release notes (1998-07-01):

    https://ahchay.com/NGPC/Downloads/T900.zip
    sha256 70687d4b166f73d230fe3b20c8827a50807bdef891fcbda2c6491667f813f4c0

It is **not** committed here; it is Toshiba's code. Unpack it into a directory of its own (untrusted download) and
pass its `T900/` directory to the scripts.

## One command

    unzip -q T900.zip -d ~/compartilhado/tmp/t900        # anywhere outside the repository
    scripts/analysis/compiler_id/verify_toshiba_runtime.sh ~/compartilhado/tmp/t900/T900

It prints one line per check and ends with `PASS: every Toshiba runtime match holds`. Measured 2026-10-17:

| check                                                      | KN5000 location                    | result                |
|------------------------------------------------------------|------------------------------------|-----------------------|
| `C9H_mulls` / `C9H_mullu` (LIB/SRC/LMULL.ASM)              | main CPU v10 0xFF0A5C              | 10 of 10 instructions |
| `SDivMod` .. `C9H_divlu` (LIB/SRC/LDIVL.ASM)               | main CPU v10 0xFF0BC3              | 96 of 96 instructions |
| the same, boot code                                        | table data 0x9FFC0E                | 96 of 96 instructions |
| TLCS-900 `memcpy` (LIB/SRC/_MEMCPY.C, inline asm)          | main CPU v10 0xFF0D99 (`Mem_Copy`) | 17 of 17 instructions |
| `_startup` f_area clear (CUSTOMIZ/C900_H2/STC94ML.C)       | main CPU v10 0xEF0B46              | 19 of 19 instructions |
| `_startup` f_data copy (same file)                         | main CPU v10 0xEF0BB0              | 11 of 11 instructions |
| `._fcmp_d` (LIB/SRC/CMP_D.MAC)                             | sub-CPU payload v1.42 0x3D2AC      | 34 of 34 instructions |
| `._fcmp_f` (LIB/SRC/CMP_F.MAC)                             | sub-CPU payload v1.42 0x3D306      | 26 of 26 instructions |
| `_ctype[256]` (LIB/SRC/_CTYPE.C with INCLUDE/CTYPE.H bits) | main CPU v10 0xEED778              | 256 of 256 bytes      |

The library sources are compared with operand values (`STRICT=1`). The startup sample and the float compares spell
some operands symbolically (`startof(f_area)`, `__DataRAM`, `TAB_EQ`, `COND_EQ`) where the ROM has numbers, so they
are compared by instruction shape.

## The scripts

| script                        | question it answers                                                                                                                                                                                                             | run                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `verify_toshiba_runtime.sh`   | do all the library matches above still hold?                                                                                                                                                                                    | `verify_toshiba_runtime.sh T900_DIR [SCRATCH]`                          |
| `srccmp.py`                   | does a Toshiba `.ASM` / `.MAC` (or extracted) source equal the instructions at an address of a ROM, after normalising mnemonic aliases (`j`/`jr`/`jrl`, `cal`/`call`, `ldib` = `ldi`, condition names)? Uses `../tools/unidasm` | `STRICT=1 python3 -I srccmp.py SRC ROM FILEBASE ADDR`                   |
| `extract_toshiba_snippets.py` | regenerates the three sequences that live in C files as `__asm("...")`: `_startup`'s f_area and f_data loops, and the TLCS-900 `memcpy`                                                                                         | `python3 -I extract_toshiba_snippets.py T900_DIR OUTDIR`                |
| `ctype_check.py`              | is a ROM's 256-byte character-class table Toshiba's `_ctype`?                                                                                                                                                                   | `python3 -I ctype_check.py T900_DIR ROM FILE_OFFSET`                    |
| `zerotest_after_call.py`      | after a call, does the code test L/HL/XHL or A/WA/XWA? Toshiba returns results in XHL                                                                                                                                           | `python3 zerotest_after_call.py 'v10/maincpu/**/*.s'`                   |
| `prologue_saves.py`           | which register does a function that allocates a frame save first? Toshiba's library preserves only XIZ                                                                                                                          | `python3 prologue_saves.py 'v10/maincpu/**/*.s'`                        |
| `mnemcount.py`                | how often do the shape features occur (`link`/`unlk`, `retd`, `lda xsp,(xsp-N)` ...)?                                                                                                                                           | `python3 mnemcount.py 'v10/maincpu/**/*.s'`                             |
| `switchidiom.py`              | how many compiled-`switch` jump sequences (`add wa,wa ... jp t,(xix+wa)`) does a ROM hold, with the base right after the `jp`?                                                                                                  | `python3 switchidiom.py ROM@BASE ...`                                   |
| `retbytes.py`                 | the same zero-test question as a byte census of a ROM (approximate: a linear scan)                                                                                                                                              | `python3 retbytes.py ROM ...`                                           |
| `libextract.py`, `xsearch.py` | which v10 runtime routines (bytes from the ELF's symbols) occur, exactly or in part, in other images?                                                                                                                           | `python3 libextract.py > lib.json; python3 xsearch.py lib.json ROM ...` |
| `strscan2.py`                 | does any word-like string of an image match a pattern (compiler names, copyright notices)?                                                                                                                                      | `python3 strscan2.py FILE 'toshiba|tlcs|c900|cc900|iar|copyright'`      |

`libextract.py` writes the routine bytes of the v10 ROM. Its output is ROM-derived and regenerable, so it is not
committed. The scripts came from the 2026-10-17 identification pass. That pass also compared the HD-AE5000, the
SX-KN1500, SNK's Neo Geo Pocket BIOS and the SX-WSA1R images; those figures are on the docs page.
