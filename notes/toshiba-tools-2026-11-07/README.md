# Toshiba's TLCS-900 tools and its uITRON 3.0 kernel: what was searched (2026-11-07)

**Question.** The kernel the KN5000's two CPUs and the WSA1R's two CPUs share (`wsa1/kernel/kernel.s`) is a
uITRON 3.0 kernel on Toshiba TLCS-900 CPUs.  Felipe's hypothesis: it is the kernel Toshiba sold with its TLCS-900
tools, in source form.  A copy of that product would be a direct reference for the disassembly.

## What Toshiba sold

Toshiba's own catalogues list a "TLCS-900 Family Real-Time OS", conforming to uITRON 3.0, sold beside the TIDE
development environment (Toshiba TLCS-900 Family product manual, "Outline of Development System"; the
TLCS-900/H1 data sheet of May 2009, TMP92CF26AXBG / TMP92CZ26AXBG):

| part number   | what                                                                       |
|---------------|----------------------------------------------------------------------------|
| `SW96RN2-ZCC` | the real-time OS, object version ("object code can be freely copied")      |
| `SW96RNC-ZCC` | the same with source code ("オブジェクトコピーフリー権、ソースコード付き") |
| `SW96CN0-ZCC` | the TLCS-900 C compiler (same SW96 family)                                 |
| `SW00MN0-ZCC` | today's integrated development environment for the TLCS-900 family         |

No "TR900" product was found.  TX19 is Toshiba's MIPS-based family, not TLCS-900.

## Where we looked, and what is there

| source                                                                             | holds                                                                                                            | the RTOS?     |
|------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|---------------|
| toshiba.semicon-storage.com, "Development tool download"                           | the IDE `SW00MN0-ZCC` V2.20 and the flash programmer `SW00FN0-ZCC` V4.00                                         | no            |
| github.com/colinoflynn/Toshiba-TLCS-900-L-Resources (the BMSKTOPAS91FY42 kit's CD) | "Toshiba IDE Limited Version": CC900, ASM900, TULIB, the CC900 C runtime (`c900ml.lib` ...)                      | no            |
| archive.org `ToshibaTLCS900CompilerV1.10`                                          | `SW96CN0-ZCC` v1.10 (`setup.exe`), zip sha256 `47e8a6d15dfb57cc61e026b7bd0cdc8b469b5a769d7900654ab1f956f9982e42` | no            |
| archive.org: the 1994 / 1995 TLCS-900 data books (bitsavers)                       | hardware documentation                                                                                           | no            |
| RTEMS's uITRON 3.0 layer (github.com/RTEMS/rtems, tag 4.9.3, `cpukit/itron`)       | an independent uITRON 3.0 API; its `status.h` error codes equal the firmware's                                   | not Toshiba's |

The kit CD's examples installer is an Inno Setup archive that was not unpacked (no extractor on this machine).

## Kept

The kit CD is kept permanently, at Felipe's request (2026-11-07), as a bare mirror in the share's repository
archive: `~/compartilhado/upstream_repos/repo_archive/colinoflynn/Toshiba-TLCS-900-L-Resources.git`, master
`a57ff856ec333014a606129b9c2c3520331055f6` (that archive's README, commit 43e9adb).  It is not in this repository:
it is Toshiba's software.  Its README: the IDE's CD key is 7921, and Toshiba issued a security advisory about these
installers, so run them only in a VM.

The C compiler `SW96CN0-ZCC` v1.10 from archive.org is kept too, at Felipe's request (2026-11-08):
`~/compartilhado/upstream_repos/file_archive/archive.org/ToshibaTLCS900CompilerV1.10/`, a git repository of its own
whose root commit `b15ec81` holds the zip (sha256 in the table above) and archive.org's metadata as downloaded
(upstream_repos README, commit 3f360bc).  Later commits there unpack it without running anything: `setup.exe` is an
InstallShield launcher around an MSI, and `unpacked/msi/install-1033/TOSHIBA/T900/` holds its 41 files, each
checked against the MSI's own MD5 table.  Among them are `bin/` (cc900, thc1/thc2, asm900, tulink, tulib),
`lib/c900ml.lib` and `c900pic.lib`, the startup code in `custom/`, and the three manuals as PDF.  That makes the
side lead below possible for v1.10's runtime as well as the kit CD's.

## What would settle the hypothesis

The object version, `SW96RN2-ZCC`, was licensed for free copying of its object code, so its kernel library may
survive on development kits or in project archives more often than the source.  Either version could be compared
with the kernel bytes in the KN5000 and WSA1R ROMs.  A side lead: the CC900 C runtime on the kit CD could be
compared with library routines in the KN5000 images.

The MN10300 "MILK" kernel of the SX-KN7000 family is also uITRON 3.0 (`kn7000/notes/uitron3-function-codes/`), but
it runs on a Panasonic CPU and is a separate build; it is not expected in Toshiba's product.
