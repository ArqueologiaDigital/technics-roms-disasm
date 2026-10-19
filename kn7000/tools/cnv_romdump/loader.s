# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# loader.s -- KN7LOAD.CNV: a style converter that loads the real application from the SD card
# (README.md). It is the only file the floppy needs; applications are updated by copying a new
# KN7APP.BIN to the SD card's root folder.
#
# DISK MENU > STYLE CONVERT loads this file at 0x502B8000 and calls its first byte on the firmware's
# main task. On the first call the loader finds the firmware routines it and the application need
# (the fmm file layer, raw SD sector access, the SD folder calls, the build numbers) by their code,
# whatever the build, fills the service table (kn7cnv.inc), reads KN7APP.BIN to 0x502BA000 and checks
# its header and CRC-32. From then on every converter call goes to the application, which sets the
# mailbox request itself; around each call the loader empties the SD "current folder", so that the
# application's file names are relative to C:\, and puts it back afterwards. When the application
# ends the conversion (0xFE) and the firmware's "Continue Next?" is answered YES, the next call loads
# KN7APP.BIN afresh. Nothing outside the converter area, the mailbox and the LCD is written.
#
# Calling convention: d0, d1, a0, a1 scratch; d2, d3, a2, a3 preserved. A routine that calls anything
# makes a frame first (movm + add -0x20, sp), as firmware routines store into 4..0x10(sp).

.mnbase 0x502B8000
.include "kn7cnv.inc"

.equ LV_STATE,      LOADER_VARS+0x00    # 0 = load, 1 = running, 2 = failed, 3 = the application ended
.equ LV_FOUND,      LOADER_VARS+0x04    # 1 once the firmware search has succeeded
.equ LV_ERR,        LOADER_VARS+0x08
.equ LV_TOPEN,      LOADER_VARS+0x0C    # fmmopen's dispatch table
.equ LV_HITS,       LOADER_VARS+0x10
.equ LV_LASTHIT,    LOADER_VARS+0x14
.equ LV_FAIL,       LOADER_VARS+0x18    # pointer to the failure message
.equ LV_STR,        LOADER_VARS-0x100   # 128 bytes: a line being formatted (PutDec builds its digits at the
                                        # end), in the zeroed gap after the loader's image (Makefile: < 0x1C00)
.equ LV_SAVEDPATH,  LOADER_VARS+0x80    # 0x80 bytes: the SD current folder while the application runs
.equ LV_HOLD,       LOADER_VARS+0x1C    # calls spent showing a failure before ending the conversion
.equ LV_A_SETEXT,   LOADER_VARS+0x60    # what FindFileSig found (used when the tables are not)
.equ LV_A_RESETEXT, LOADER_VARS+0x64
.equ LV_A_OPEN,     LOADER_VARS+0x68
.equ LV_A_CLOSE,    LOADER_VARS+0x6C
.equ LV_A_READ,     LOADER_VARS+0x70
.equ LV_A_WRITE,    LOADER_VARS+0x74
.equ LV_SIGSTEP,    LOADER_VARS+0x78    # how far FindFileSig got: 0 drive switch, 1 open, 2 close, 3 read, 4 write, 5 all
.equ LV_NTAB,       LOADER_VARS+0x7C    # places with the dispatch tables' shape (1 is a find)
.equ HOLD_MS,       15000               # show a failure this long (kernel milliseconds) ...
.equ HOLD_CALLS,    23000               # ... or this many calls when the counter was not found, each made to
.equ HOLD_SPIN,     10000               # last about 0.65 ms by a delay loop (1531 calls a second in MAME). Parked
                                        # with request 1 the firmware calls again at once, 20000 to 300000 times
                                        # a second in MAME (941) depending on the work per call: bare calls are no
                                        # clock (test/dump.cmd.in, calls_in_1s_after_done)
.equ C_BG,          0x0010
.equ C_TEXT,        0xFFFF
.equ C_DIM,         0x8410
.equ C_BAD,         0xF800

Entry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (LV_STATE), d0
    cmp     1, d0
    beq     en_run
    cmp     2, d0
    beq     en_hold                 # failed: show why a while, then end the conversion
    # 0 (first call) or 3 (the application ended and the firmware called again): load it
    mov     (LV_FOUND), d0
    cmp     0, d0
    bne     en_load
    call    InitScreen, 0, 0
    call    Discover, 0, 0
    cmp     0, d0
    beq     en_found
    call    DrawFirmware, 0, 0      # what was found, and how far the file searches got
    call    DrawSearch, 0, 0
    bra     en_fail
en_found:
    mov     1, d0
    mov     d0, (LV_FOUND)
en_load:
    call    InitScreen, 0, 0
    call    DrawFirmware, 0, 0
    call    LoadApp, 0, 0           # d0 = 0, or 1 with LV_FAIL set
    cmp     0, d0
    bne     en_fail
    mov     1, d0
    mov     d0, (LV_STATE)
    clr     d0
    mov     d0, (SVC+SV_CALLS)
en_run:
    mov     (SVC+SV_CALLS), d0
    inc     d0
    mov     d0, (SVC+SV_CALLS)
    call    PathSave, 0, 0
    mov     (APP_BASE+AH_ENTRY), a0
    calls   (a0)
    call    PathRestore, 0, 0
    mov     MAILBOX, a0
    movbu   (a0), d0
    cmp     RQ_END, d0
    bne     en_ret
    mov     3, d0                   # the application is done; a new call loads it again
    mov     d0, (LV_STATE)
    bra     en_ret
en_fail:
    mov     2, d0
    mov     d0, (LV_STATE)
    call    DrawFail, 0, 0
    clr     d0                      # start of the hold: now, or call 0
    mov     (SVC+SV_MSCOUNT), a0
    cmp     0, a0
    beq     en_hold0
    mov     (a0), d0
en_hold0:
    mov     d0, (LV_HOLD)
en_hold:
    mov     (SVC+SV_MSCOUNT), a0
    cmp     0, a0
    beq     en_hold_calls
    mov     (a0), d0
    mov     (LV_HOLD), d1
    sub     d1, d0
    cmp     HOLD_MS, d0
    bcc     en_end
    bra     en_hold_park
en_hold_calls:
    mov     HOLD_SPIN, d0
eh_spin:
    add     -1, d0
    bne     eh_spin
    mov     (LV_HOLD), d0
    inc     d0
    mov     d0, (LV_HOLD)
    cmp     HOLD_CALLS, d0
    bcc     en_end
en_hold_park:
    mov     MAILBOX, a0             # request 1, argument 0: call again, leave the screen alone
    mov     RQ_PARK, d0
    movbu   d0, (a0)
    clr     d0
    movbu   d0, (1, a0)
    movbu   d0, (2, a0)
    movbu   d0, (3, a0)
    movbu   d0, (4, a0)
    bra     en_ret
en_end:
    mov     MAILBOX, a0
    mov     RQ_END, d0
    movbu   d0, (a0)
en_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# PathSave: keep the SD current folder and empty it (file names become relative to C:\).
# PathRestore: put it back.
PathSave:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_SETPATH), a1    # without sdfmpath, file names stay relative to the current folder
    cmp     0, a1
    beq     ps_ret
    mov     (SVC+SV_PATHBUF), a0
    mov     LV_SAVEDPATH, a1
    mov     0x80, d1
ps_copy:
    movbu   (a0), d0
    movbu   d0, (a1)
    inc     a0
    inc     a1
    add     -1, d1
    bne     ps_copy
    mov     0, a0
    mov     (SVC+SV_SETPATH), a1
    calls   (a1)
ps_ret:
    ret     [d2,d3,a2,a3], 0x30

PathRestore:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_SETPATH), a1
    cmp     0, a1
    beq     pr_ret
    mov     LV_SAVEDPATH, a0
    movbu   (a0), d0
    cmp     0, d0
    beq     pr_ret
    mov     (SVC+SV_SETPATH), a1
    calls   (a1)
pr_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# LoadApp -> d0 = 0, or 1 with LV_FAIL set. Zeroes the application area, reads C:\KN7APP.BIN into
# it and checks the header (magic, loader ABI, link address, size, entry) and the CRC-32.
LoadApp:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     APP_BASE, a0            # zero the application area
    mov     APP_MAX/4, d1
    clr     d0
la_zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     la_zero
    mov     1, d0
    mov     (SVC+SV_SETEXT), a0
    calls   (a0)
    call    PathSave, 0, 0
    mov     str_appname, a0
    mov     mode_rb, a1
    mov     (SVC+SV_OPEN), a3
    calls   (a3)
    exth    d0
    mov     d0, (LV_ERR)
    cmp     0, d0
    bge     la_read
    call    PathRestore, 0, 0
    mov     (SVC+SV_RESETEXT), a0
    calls   (a0)
    mov     str_no_app, a0
    bra     la_fail
la_read:
    mov     APP_BASE, a2            # read in 16 KB pieces until a short one
    clr     d2                      # bytes read
la_piece:
    mov     APP_MAX, d0
    sub     d2, d0
    mov     0x4000, d1
    cmp     d1, d0
    bls     la_n
    mov     d1, d0
la_n:
    cmp     0, d0
    beq     la_close
    mov     d0, d3                  # asked for
    mov     a2, a0
    mov     (SVC+SV_READ), a1
    calls   (a1)
    cmp     0, d0
    blt     la_close
    add     d0, d2
    add     d0, a2
    cmp     d3, d0
    beq     la_piece
la_close:
    mov     (SVC+SV_CLOSE), a0
    calls   (a0)
    call    PathRestore, 0, 0
    mov     (SVC+SV_RESETEXT), a0
    calls   (a0)
    mov     d2, (SVC+SV_APPSIZE)
    mov     d2, (LV_ERR)
    mov     str_bad_app, a0         # the header
    mov     0x40, d0
    cmp     d0, d2
    bcs     la_fail
    mov     (APP_BASE+AH_MAGIC), d0
    mov     0x41374E4B, d1          # "KN7A"
    cmp     d1, d0
    bne     la_fail
    mov     str_old_app, a0
    mov     (APP_BASE+AH_ABI), d0
    cmp     LOADER_ABI, d0
    bne     la_fail
    mov     str_bad_app, a0
    mov     (APP_BASE+AH_BASE), d0
    mov     APP_BASE, d1
    cmp     d1, d0
    bne     la_fail
    mov     (APP_BASE+AH_SIZE), d0
    cmp     d2, d0
    bne     la_fail
    mov     (APP_BASE+AH_ENTRY), d0
    mov     APP_BASE+AH_NAME+0x20, d1
    cmp     d1, d0
    bcs     la_fail
    mov     APP_BASE, d1
    add     d2, d1
    cmp     d1, d0
    bcc     la_fail
    mov     APP_BASE+AH_NAME, a0    # CRC-32 of the file from AH_NAME on
    mov     d2, d0
    add     -AH_NAME, d0
    call    Crc32, 0, 0
    mov     d0, (LV_ERR)
    mov     (APP_BASE+AH_CRC), d1
    mov     str_crc_app, a0
    cmp     d1, d0
    bne     la_fail
    clr     d0
    bra     la_ret
la_fail:
    mov     a0, (LV_FAIL)
    mov     1, d0
la_ret:
    ret     [d2,d3,a2,a3], 0x30

# Crc32(a0 = data, d0 = bytes) -> d0 = the CRC-32 (reflected, 0xEDB88320), bit by bit.
Crc32:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    mov     -1, d0
    mov     0xEDB88320, d2
c3_byte:
    movbu   (a0), d1
    inc     a0
    xor     d1, d0
    mov     8, d1
c3_bit:
    btst    1, d0
    beq     c3_even
    lsr     1, d0
    xor     d2, d0
    bra     c3_next
c3_even:
    lsr     1, d0
c3_next:
    add     -1, d1
    bne     c3_bit
    add     -1, d3
    bne     c3_byte
    not     d0
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Discover -> d0 = 0, or 1 with LV_FAIL set when no way to read and write files was found.
#
# Every search is independent, and only file access is required; whatever else is missing is left 0
# in the service table (SV_FOUND says what was found) and the application carries on without it.
# File access comes from either of two places, so that a firmware whose code differs from the builds
# we know is still usable:
#   - the fmm dispatch tables, found by their shape alone (FindTables): the SD backends are then
#     called directly, and the drive byte is never touched;
#   - the fmm dispatchers and the drive switch, found by masked code signatures (FindFileSig).
# When both are found they must agree (fmmopen's table = the tables + 12); the tables are used then.
# Signatures with only build-dependent operands masked, each of which must match exactly once:
# raw SD sector read/write, sdfmmkdir/sdfmpath, the SOFT VERSION build number, the kernel tick.
# kn7000_disassembly tools/cnv_romdump/find_fw.py runs the same searches over every program image
# we have. LoaderTest (test builds only) switches searches off, to exercise the fallbacks.
Discover:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d0
    mov     d0, (SVC+SV_FOUND)
    mov     (LoaderTest), d0
    btst    0x01, d0
    bne     di_nosig
    call    FindFileSig, 0, 0       # d0 = 1 when the dispatchers were found
    cmp     0, d0
    beq     di_nosig
    mov     FOUND_FILESIG, d0
    call    Found, 0, 0
di_nosig:
    mov     (LoaderTest), d0
    btst    0x02, d0
    bne     di_notab
    call    FindTables, 0, 0        # d0 = the tables, or 0
    cmp     0, d0
    beq     di_notab
    mov     d0, (SVC+SV_TABLES)
    mov     FOUND_TABLES, d0
    call    Found, 0, 0
di_notab:
    mov     (SVC+SV_FOUND), d2      # choose: the tables (when the signatures agree or are absent) ...
    btst    FOUND_TABLES, d2
    beq     di_use_sig
    btst    FOUND_FILESIG, d2
    beq     di_use_tab
    mov     (SVC+SV_TABLES), d0
    add     12, d0
    mov     (LV_TOPEN), d1
    cmp     d1, d0
    beq     di_use_tab
    mov     (SVC+SV_FOUND), d0      # they disagree: trust neither table address, use the code found
    and     0xFFFFFFFF-FOUND_TABLES, d0
    mov     d0, (SVC+SV_FOUND)
    clr     d0
    mov     d0, (SVC+SV_TABLES)
    bra     di_use_sig
di_use_tab:
    mov     (SVC+SV_TABLES), a2     # record k, column 1 (SD): error 0, open 1, close 2, read 6, write 7
    mov     (16, a2), d0
    mov     d0, (SVC+SV_OPEN)
    mov     (28, a2), d0
    mov     d0, (SVC+SV_CLOSE)
    mov     (76, a2), d0
    mov     d0, (SVC+SV_READ)
    mov     (88, a2), d0
    mov     d0, (SVC+SV_WRITE)
    mov     NoOp, d0
    mov     d0, (SVC+SV_SETEXT)
    mov     d0, (SVC+SV_RESETEXT)
    bra     di_optional
di_use_sig:                         # ... or the dispatchers, with the drive switch
    btst    FOUND_FILESIG, d2
    beq     di_optional             # neither (SV_OPEN stays 0): the rest is still looked for, for the screen
    mov     (LV_A_SETEXT), d0
    mov     d0, (SVC+SV_SETEXT)
    mov     (LV_A_RESETEXT), d0
    mov     d0, (SVC+SV_RESETEXT)
    mov     (LV_A_OPEN), d0
    mov     d0, (SVC+SV_OPEN)
    mov     (LV_A_CLOSE), d0
    mov     d0, (SVC+SV_CLOSE)
    mov     (LV_A_READ), d0
    mov     d0, (SVC+SV_READ)
    mov     (LV_A_WRITE), d0
    mov     d0, (SVC+SV_WRITE)

di_optional:
    mov     (LoaderTest), d0        # raw SD sector read, and write 0x33 bytes after it
    btst    0x04, d0
    bne     di_noraw
    mov     sig_raw, a0
    mov     0x48400000, d0
    mov     0x487FFF00, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     di_noraw
    mov     (LV_LASTHIT), d0
    mov     d0, (SVC+SV_RAWREAD)
    add     0x33, d0
    mov     d0, (SVC+SV_RAWWRITE)
    mov     FOUND_RAW, d0
    call    Found, 0, 0
di_noraw:
    mov     (LoaderTest), d0        # sdfmmkdir, and sdfmpath 0x3F bytes after it
    btst    0x08, d0
    bne     di_nofolder
    mov     sig_sdfolder, a0
    mov     0x48400000, d0
    mov     0x487FFF00, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     di_nofolder
    mov     (LV_LASTHIT), a2
    mov     a2, a0
    add     0x3F+10, a0             # sdfmpath: mov FOLDERBUF, a0
    call    Read32U, 0, 0
    mov     0x50000000, d1          # the buffer must lie in work RAM
    cmp     d1, d0
    bcs     di_nofolder
    mov     0x503FFF80, d1
    cmp     d1, d0
    bhi     di_nofolder
    mov     d0, (SVC+SV_PATHBUF)
    mov     a2, (SVC+SV_MKDIR)
    mov     a2, d0
    add     0x3F, d0
    mov     d0, (SVC+SV_SETPATH)
    mov     FOUND_FOLDER, d0
    call    Found, 0, 0
di_nofolder:
    mov     (LoaderTest), d0        # SOFT VERSION: mov (B), d0 ... -> the PROGRAM build number
    btst    0x10, d0
    bne     di_nobuild
    mov     sig_build, a0
    mov     0x48400000, d0
    mov     0x487FFF00, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     di_nobuild
    mov     (LV_LASTHIT), a0
    add     2, a0
    call    Read32U, 0, 0
    mov     d0, a0
    mov     0x48400000, d1
    cmp     d1, d0
    bcs     di_nobuild
    mov     0x487FFFFE, d1
    cmp     d1, d0
    bhi     di_nobuild
    movbu   (a0), d0
    movbu   (1, a0), d1
    asl     8, d1
    or      d1, d0
    mov     d0, (SVC+SV_BUILD)
    mov     FOUND_BUILD, d0
    call    Found, 0, 0
di_nobuild:
    mov     0x4840000F, a0          # the release byte: always there
    movbu   (a0), d0
    mov     d0, (SVC+SV_RELEASE)
    call    TableBuild, 0, 0
    mov     (LoaderTest), d0        # the kernel's millisecond counter, from its tick handler
    btst    0x20, d0
    bne     di_notick
    mov     sig_tick, a0
    mov     0x48400000, d0
    mov     0x487FFF00, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     di_notick
    mov     (LV_LASTHIT), a2
    mov     a2, a0
    add     7, a0
    call    Read32U, 0, 0
    mov     d0, d2
    mov     a2, a0
    add     14, a0
    call    Read32U, 0, 0
    cmp     d2, d0
    bne     di_notick
    mov     0x50000000, d1
    cmp     d1, d0
    bcs     di_notick
    mov     0x503FFFFC, d1
    cmp     d1, d0
    bhi     di_notick
    mov     d0, (SVC+SV_MSCOUNT)
    mov     FOUND_TICK, d0
    call    Found, 0, 0
di_notick:
    mov     0x53374E4B, d0          # "KN7S"
    mov     d0, (SVC+SV_MAGIC)
    mov     LOADER_ABI, d0
    mov     d0, (SVC+SV_ABI)
    mov     DrawText, d0
    mov     d0, (SVC+SV_DRAWTEXT)
    mov     FillRect, d0
    mov     d0, (SVC+SV_FILLRECT)
    clr     d0
    mov     (SVC+SV_OPEN), d1
    cmp     0, d1
    bne     di_ret
    mov     str_no_file, a0
    mov     a0, (LV_FAIL)
    mov     1, d0
di_ret:
    ret     [d2,d3,a2,a3], 0x30

Found:                              # leaf: SV_FOUND |= d0
    mov     (SVC+SV_FOUND), d1
    or      d0, d1
    mov     d1, (SVC+SV_FOUND)
    rets

NoOp:                               # the drive switch when the SD backends are called directly
    rets

# FindFileSig -> d0 = 1 when the drive switch and the fmmopen/fmmclose/fmmread/fmmwrite dispatchers
# were each found exactly once (into LV_A_*, LV_TOPEN, SV_DRIVE), else 0.
FindFileSig:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d0
    mov     d0, (LV_SIGSTEP)
    mov     sig_ext, a0
    mov     0x48400000, d0
    mov     0x487FFF00, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     ff_no
    mov     (LV_LASTHIT), a2
    mov     a2, (LV_A_SETEXT)
    mov     a2, d0
    add     0x0F, d0
    mov     d0, (LV_A_RESETEXT)
    mov     a2, a0
    add     8, a0
    call    Read32U, 0, 0
    mov     d0, d2                  # the drive byte address, three times in the signature
    mov     d0, (SVC+SV_DRIVE)
    mov     a2, a0
    add     18, a0
    call    Read32U, 0, 0
    cmp     d2, d0
    bne     ff_no
    mov     a2, a0
    add     27, a0
    call    Read32U, 0, 0
    cmp     d2, d0
    bne     ff_no
    mov     1, d0
    mov     d0, (LV_SIGSTEP)
    mov     sig_open, a0            # fmmopen, within 4 KB after the drive switch
    mov     a2, d0
    mov     a2, d1
    add     0x1000, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     ff_no
    mov     (LV_LASTHIT), a3
    mov     a3, (LV_A_OPEN)
    mov     a3, a0
    add     8, a0
    call    Read32U, 0, 0
    mov     d0, (LV_TOPEN)
    mov     a3, a0
    add     28, a0
    call    Read32U, 0, 0
    cmp     d2, d0
    bne     ff_no
    mov     2, d0
    mov     d0, (LV_SIGSTEP)
    mov     sig_close, a0           # fmmclose: table 12 bytes after fmmopen's
    mov     5, d0
    mov     12, d1
    mov     25, a1
    call    FindDispatcher, 0, 0
    cmp     0, d0
    beq     ff_no
    mov     d0, (LV_A_CLOSE)
    mov     3, d0
    mov     d0, (LV_SIGSTEP)
    mov     sig_rw, a0              # fmmread: 0x3C bytes after
    mov     8, d0
    mov     0x3C, d1
    mov     28, a1
    call    FindDispatcher, 0, 0
    cmp     0, d0
    beq     ff_no
    mov     d0, (LV_A_READ)
    mov     4, d0
    mov     d0, (LV_SIGSTEP)
    mov     sig_rw, a0              # fmmwrite: 0x48 bytes after
    mov     8, d0
    mov     0x48, d1
    mov     28, a1
    call    FindDispatcher, 0, 0
    cmp     0, d0
    beq     ff_no
    mov     d0, (LV_A_WRITE)
    mov     5, d0
    mov     d0, (LV_SIGSTEP)
    mov     1, d0
    bra     ff_ret
ff_no:
    clr     d0
ff_ret:
    ret     [d2,d3,a2,a3], 0x30

# FindTables -> d0 = the fmm dispatch tables, or 0 unless exactly one place fits. Found by their shape
# alone: eleven 12-byte records (error, open, close, remove, two more, read, write, seek, rewind, tell)
# of three code pointers into the program flash, the floppy and SD columns each ascending and within
# 64 KB, the three columns in separate stretches of code.
.equ TB_RECS,       11
FindTables:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     0x48400000, a2
    clr     d2                      # hits
    mov     0, a3                   # the last one
ft_next:
    mov     0x487FFF00, d0
    cmp     d0, a2
    bcc     ft_done
    mov     (a2), d0                # quick reject: the first word must point into the program flash
    mov     0x48400000, d1
    cmp     d1, d0
    bcs     ft_skip
    mov     0x48800000, d1
    cmp     d1, d0
    bcc     ft_skip
    mov     a2, a0
    call    CheckTables, 0, 0
    cmp     0, d0
    beq     ft_skip
    inc     d2
    mov     a2, a3
ft_skip:
    add     4, a2
    bra     ft_next
ft_done:
    mov     d2, (LV_NTAB)
    clr     d0
    cmp     1, d2
    bne     ft_ret
    mov     a3, d0
ft_ret:
    ret     [d2,d3,a2,a3], 0x30

# CheckTables(a0 = candidate) -> d0 = 1 when the 33 words there have the dispatch tables' shape.
CheckTables:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     a2, a0                  # every word a program flash address
    mov     TB_RECS*3, d2
ct_flash:
    mov     (a0), d0
    mov     0x48400000, d1
    cmp     d1, d0
    bcs     ct_no
    mov     0x48800000, d1
    cmp     d1, d0
    bcc     ct_no
    add     4, a0
    add     -1, d2
    bne     ct_flash
    clr     d3                      # columns 0 (floppy) and 1 (SD): ascending, within 64 KB
ct_col:
    mov     a2, a0
    mov     d3, d0
    asl     2, d0
    add     d0, a0
    mov     TB_RECS-1, d2
ct_asc:
    mov     (a0), d0
    mov     (12, a0), d1
    cmp     d0, d1
    bls     ct_no                   # not strictly ascending
    add     12, a0
    add     -1, d2
    bne     ct_asc
    mov     d3, d0                  # last - first <= 0x10000
    asl     2, d0
    mov     a2, a1
    add     d0, a1
    mov     (a1), d0
    mov     ((TB_RECS-1)*12, a1), d1
    sub     d0, d1
    mov     0x10000, d0
    cmp     d0, d1
    bhi     ct_no
    inc     d3
    cmp     2, d3
    bne     ct_col
    # column ranges: floppy [first0, last0], SD [first1, last1] must not overlap
    mov     (a2), d0                # first0
    mov     ((TB_RECS-1)*12, a2), d1    # last0
    mov     (4, a2), d2             # first1
    mov     ((TB_RECS-1)*12+4, a2), d3  # last1
    cmp     d2, d1                  # last0 < first1 ?
    bcs     ct_c2
    cmp     d0, d3                  # last1 < first0 ?
    bcs     ct_c2
    bra     ct_no
ct_c2:                              # column 2: within 64 KB, and clear of both other ranges
    mov     d0, (0x14, sp)          # first0
    mov     d1, (0x18, sp)          # last0
    mov     a2, a0
    add     8, a0
    mov     (a0), d0                # min2 = max2 = the first
    mov     d0, a3                  # min2
    mov     d0, a1                  # max2
    mov     TB_RECS-1, d1
ct_mm:
    add     12, a0
    mov     (a0), d0
    cmp     a3, d0
    bcc     ct_mm1
    mov     d0, a3
ct_mm1:
    cmp     a1, d0
    bls     ct_mm2
    mov     d0, a1
ct_mm2:
    add     -1, d1
    bne     ct_mm
    mov     a1, d0                  # max2 - min2 <= 0x10000
    mov     a3, d1
    sub     d1, d0
    mov     0x10000, d1
    cmp     d1, d0
    bhi     ct_no
    mov     a1, d0                  # clear of the SD range [d2, d3]: max2 < first1 or min2 > last1
    cmp     d2, d0
    bcs     ct_c2b
    mov     a3, d0
    cmp     d3, d0
    bls     ct_no
ct_c2b:
    mov     a1, d0                  # clear of the floppy range
    mov     (0x14, sp), d1
    cmp     d1, d0
    bcs     ct_yes
    mov     a3, d0
    mov     (0x18, sp), d1
    cmp     d1, d0
    bls     ct_no
ct_yes:
    mov     1, d0
    bra     ct_ret
ct_no:
    clr     d0
ct_ret:
    ret     [d2,d3,a2,a3], 0x30

# FindDispatcher(a0 = signature, d0 = table operand offset, d1 = table distance from fmmopen's,
# a1 = drive operand offset) -> d0 = the one hit within 4 KB of the drive switch whose table and
# drive byte fit, or 0.
FindDispatcher:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, (0x14, sp)
    mov     d0, (0x18, sp)
    mov     (LV_TOPEN), d2
    add     d1, d2
    mov     a1, (0x1C, sp)
    mov     (LV_A_SETEXT), a2
    mov     a2, d3
    add     0x1000, d3
    mov     0, a3
    clr     d0
    mov     d0, (LV_HITS)
fd_next:
    mov     (0x14, sp), a0
    mov     a2, d0
    mov     d3, d1
    call    FindSig, 0, 0
    cmp     0, d0
    beq     fd_done
    mov     d0, a2
    mov     a2, a0
    mov     (0x18, sp), d0
    add     d0, a0
    call    Read32U, 0, 0
    cmp     d2, d0
    bne     fd_skip
    mov     a2, a0
    mov     (0x1C, sp), d0
    add     d0, a0
    call    Read32U, 0, 0
    mov     (SVC+SV_DRIVE), d1
    cmp     d1, d0
    bne     fd_skip
    mov     a2, a3
    mov     (LV_HITS), d0
    inc     d0
    mov     d0, (LV_HITS)
fd_skip:
    inc     a2
    bra     fd_next
fd_done:
    mov     (LV_HITS), d0
    cmp     1, d0
    bne     fd_none
    mov     a3, d0
    bra     fd_ret
fd_none:
    clr     d0
fd_ret:
    ret     [d2,d3,a2,a3], 0x30

# TableBuild: the TABLE build number, as the SOFT VERSION screen reads it: the decimal digits at
# 0x48000000 + u32(0x4800001C), up to a non-digit (at most 6). Sets FOUND_TBUILD when the pointer lies
# in the table flash and at least one digit is there; otherwise SV_TBUILD stays 0. Leaf.
TableBuild:
    clr     d1
    mov     d1, (SVC+SV_TBUILD)
    mov     0x4800001C, a0
    mov     (a0), d0
    mov     0x003FFFF0, d1          # an offset inside the 4 MB table flash
    cmp     d1, d0
    bhi     tb_ret
    mov     0x48000000, d1
    add     d1, d0
    mov     d0, a0
    movbu   (a0), d0                # at least one digit
    add     -0x30, d0
    cmp     9, d0
    bhi     tb_ret
    clr     d1
    mov     6, d0
    mov     d0, mdr                 # digit count, kept in mdr
tb_dig:
    movbu   (a0), d0
    add     -0x30, d0
    cmp     9, d0
    bhi     tb_done
    mov     d1, a1
    asl     2, d1
    add     a1, d1
    add     d1, d1
    add     d0, d1
    inc     a0
    mov     mdr, d0
    add     -1, d0
    mov     d0, mdr
    cmp     0, d0
    bne     tb_dig
tb_done:
    mov     d1, (SVC+SV_TBUILD)
    mov     (SVC+SV_FOUND), d0
    or      FOUND_TBUILD, d0
    mov     d0, (SVC+SV_FOUND)
tb_ret:
    rets

# CountSig(a0 = signature, d0 = start, d1 = end) -> d0 = hits; LV_LASTHIT = the first.
CountSig:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d1, d3
    clr     d2
    mov     d2, (LV_LASTHIT)
cs_next:
    mov     a2, a0
    mov     d3, d1
    call    FindSig, 0, 0
    cmp     0, d0
    beq     cs_done
    cmp     0, d2
    bne     cs_more
    mov     d0, (LV_LASTHIT)
cs_more:
    inc     d2
    inc     d0
    bra     cs_next
cs_done:
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

# FindSig(a0 = signature, d0 = start, d1 = end) -> d0 = first address in [start, end) where it
# matches, or 0. Elements are 16-bit: 0x00nn = byte nn, 0x0100 = any byte, 0xFFFF = end; the first
# is a byte.
FindSig:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    movhu   (a2), d3
    mov     d0, a3
    mov     d1, (0x14, sp)
fs_loop:
    mov     (0x14, sp), d0
    cmp     d0, a3
    bcc     fs_none
    movbu   (a3), d2
    cmp     d3, d2
    bne     fs_next
    mov     a2, a0
    mov     a3, a1
fs_cmp:
    movhu   (a0), d2
    mov     0xFFFF, d0
    cmp     d0, d2
    beq     fs_hit
    btst    0x100, d2
    bne     fs_any
    movbu   (a1), d1
    cmp     d2, d1
    bne     fs_next
fs_any:
    add     2, a0
    inc     a1
    bra     fs_cmp
fs_next:
    inc     a3
    bra     fs_loop
fs_hit:
    mov     a3, d0
    bra     fs_ret
fs_none:
    clr     d0
fs_ret:
    ret     [d2,d3,a2,a3], 0x30

# Read32U(a0 = address) -> d0 = the little-endian u32 there, at any alignment. Leaf.
Read32U:
    movbu   (3, a0), d0
    asl     8, d0
    movbu   (2, a0), d1
    or      d1, d0
    asl     8, d0
    movbu   (1, a0), d1
    or      d1, d0
    asl     8, d0
    movbu   (a0), d1
    or      d1, d0
    rets

# ================================================================================================
# The loader's screen.
InitScreen:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_BG, d0
    mov     d0, (SVC+SV_FG)
    mov     d0, (SVC+SV_BG)
    clr     d0
    clr     d1
    mov     640, a0
    mov     240, a1
    call    FillRect, 0, 0
    mov     C_TEXT, d0
    mov     d0, (SVC+SV_FG)
    mov     2, d0
    mov     d0, (SVC+SV_SCALE)
    mov     str_title, a0
    mov     8, d0
    mov     4, d1
    call    DrawText, 0, 0
    mov     1, d0
    mov     d0, (SVC+SV_SCALE)
    mov     str_loading, a0
    mov     8, d0
    mov     40, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

DrawFirmware:                       # "PROGRAM 941  TABLE 84  release 16"
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     LV_STR, a0
    mov     str_f_prog, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_BUILD), d0
    mov     FOUND_BUILD, d1
    call    PutBuild, 0, 0
    mov     str_f_table, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_TBUILD), d0
    mov     FOUND_TBUILD, d1
    call    PutBuild, 0, 0
    mov     str_f_rel, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_RELEASE), d0
    asl     24, d0
    mov     2, d1
    call    PutHex, 0, 0
    mov     C_DIM, d0
    mov     d0, (SVC+SV_FG)
    mov     LV_STR, a0
    mov     8, d0
    mov     60, d1
    call    DrawText, 0, 0
    mov     LV_STR, a0              # what the search found
    mov     str_k_file, a1
    call    StrCpy, 0, 0
    mov     str_k_none, a1
    mov     (SVC+SV_FOUND), d2
    btst    FOUND_FILESIG, d2
    beq     dfw_tab
    mov     str_k_code, a1
dfw_tab:
    btst    FOUND_TABLES, d2
    beq     dfw_file
    mov     str_k_tables, a1
dfw_file:
    call    StrCpy, 0, 0
    mov     str_k_raw, a1
    call    StrCpy, 0, 0
    mov     FOUND_RAW, d0
    call    PutYesNo, 0, 0
    mov     str_k_folder, a1
    call    StrCpy, 0, 0
    mov     FOUND_FOLDER, d0
    call    PutYesNo, 0, 0
    mov     str_k_clock, a1
    call    StrCpy, 0, 0
    mov     FOUND_TICK, d0
    call    PutYesNo, 0, 0
    mov     LV_STR, a0
    mov     8, d0
    mov     72, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

PutBuild:                           # leaf: a0 = out, d0 = number, d1 = its FOUND_ bit: the number or "?"
    mov     d0, mdr                 # keep the number
    mov     (SVC+SV_FOUND), d0
    and     d1, d0
    beq     pb_unknown
    mov     mdr, d0
    bra     PutDec
pb_unknown:
    mov     0x3F, d0
    movbu   d0, (a0)
    inc     a0
    clr     d0
    movbu   d0, (a0)
    rets

DrawSearch:                         # "search: fmm tables 0 places, file code 2 of 5 steps"
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     LV_STR, a0
    mov     str_s_tab, a1
    call    StrCpy, 0, 0
    mov     (LV_NTAB), d0
    call    PutDec, 0, 0
    mov     str_s_code, a1
    call    StrCpy, 0, 0
    mov     (LV_SIGSTEP), d0
    call    PutDec, 0, 0
    mov     str_s_steps, a1
    call    StrCpy, 0, 0
    mov     C_DIM, d0
    mov     d0, (SVC+SV_FG)
    mov     LV_STR, a0
    mov     8, d0
    mov     148, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

PutYesNo:                           # leaf: a0 = out, d0 = a FOUND_ bit: "yes" or "no"
    mov     (SVC+SV_FOUND), d1
    and     d0, d1
    mov     str_yes, a1
    bne     pyn_copy
    mov     str_no, a1
pyn_copy:
    bra     StrCpy

DrawFail:                           # the reason, and the code involved
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_BAD, d0
    mov     d0, (SVC+SV_FG)
    mov     (LV_FAIL), a0
    mov     8, d0
    mov     84, d1
    call    DrawText, 0, 0
    mov     C_TEXT, d0
    mov     d0, (SVC+SV_FG)
    mov     (LV_ERR), d0
    cmp     0, d0
    beq     dfl_leave
    mov     LV_STR, a0
    mov     str_code, a1
    call    StrCpy, 0, 0
    mov     (LV_ERR), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     LV_STR, a0
    mov     8, d0
    mov     100, d1
    call    DrawText, 0, 0
dfl_leave:
    mov     str_leave, a0
    mov     8, d0
    mov     124, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# StrCpy(a0 = out, a1 = text) -> a0 at the NUL it copied. Leaf.
StrCpy:
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     sc_end
    inc     a0
    inc     a1
    bra     StrCpy
sc_end:
    rets

# PutHex(a0 = out, d0 = value left-aligned, d1 = digits) and PutDec(a0 = out, d0 = value). Leaves.
PutHex:
    mov     d0, a1
ph_dig:
    mov     a1, d0
    lsr     28, d0
    cmp     10, d0
    bcs     ph_num
    add     7, d0
ph_num:
    add     0x30, d0
    movbu   d0, (a0)
    inc     a0
    mov     a1, d0
    asl     4, d0
    mov     d0, a1
    add     -1, d1
    bne     ph_dig
    clr     d0
    movbu   d0, (a0)
    rets

PutDec:
    mov     LV_STR+0x7F, a1         # digits built backwards at the end of LV_STR
    clr     d1
    movbu   d1, (a1)
pdc_dig:
    clr     d1
    mov     d1, mdr
    mov     10, d1
    divu    d1, d0
    mov     mdr, d1
    add     0x30, d1
    add     -1, a1
    movbu   d1, (a1)
    cmp     0, d0
    bne     pdc_dig
pdc_copy:
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     pdc_end
    inc     a0
    inc     a1
    bra     pdc_copy
pdc_end:
    rets

# ================================================================================================
# Drawing services (exported in the service table). FillRect(d0 = x, d1 = y, a0 = width, a1 = height)
# in SV_FG. DrawText(a0 = text, d0 = x, d1 = y) in SV_FG on SV_BG at SV_SCALE (1 or 2) -> d0 = x after.
FillRect:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d1, d2
    mov     FB_STRIDE, d3
    mulu    d3, d2
    add     d0, d0
    add     d0, d2
    mov     FB, a2
    add     d2, a2
    mov     (SVC+SV_FG), d3
fr_row:
    mov     a2, a3
    mov     a0, d2
fr_px:
    movhu   d3, (a3)
    add     2, a3
    add     -1, d2
    bne     fr_px
    add     FB_STRIDE, a2
    add     -1, a1
    cmp     0, a1
    bne     fr_row
    ret     [d2,d3,a2,a3], 0x30

DrawText:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d0, d2
    mov     d1, d3
dt_char:
    movbu   (a2), d0
    cmp     0, d0
    beq     dt_done
    inc     a2
    mov     d2, d1
    mov     d3, a1
    call    DrawChar, 0, 0
    mov     (SVC+SV_SCALE), d0
    asl     3, d0
    add     d0, d2
    bra     dt_char
dt_done:
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

DrawChar:                           # d0 = character, d1 = x, a1 = y
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    cmp     0x20, d0
    bcs     dc_blank
    cmp     0x7F, d0
    bcs     dc_ok
dc_blank:
    mov     0x20, d0
dc_ok:
    add     -0x20, d0
    mov     13, d2
    mulu    d2, d0
    mov     Font8x13, a3
    add     d0, a3
    mov     a1, d2
    mov     FB_STRIDE, d3
    mulu    d3, d2
    add     d1, d1
    add     d1, d2
    mov     FB, a2
    add     d2, a2
    mov     13, d0
    mov     d0, (0x14, sp)
dc_row:
    movbu   (a3), d2
    inc     a3
    mov     (SVC+SV_SCALE), d0
    mov     d0, (0x18, sp)
dc_rep:
    mov     a2, a0
    mov     0x80, d3
dc_px:
    mov     (SVC+SV_BG), d1
    mov     d2, d0
    and     d3, d0
    beq     dc_put
    mov     (SVC+SV_FG), d1
dc_put:
    movhu   d1, (a0)
    add     2, a0
    mov     (SVC+SV_SCALE), d0
    cmp     2, d0
    bne     dc_px1
    movhu   d1, (a0)
    add     2, a0
dc_px1:
    lsr     1, d3
    bne     dc_px
    add     FB_STRIDE, a2
    mov     (0x18, sp), d0
    add     -1, d0
    mov     d0, (0x18, sp)
    bne     dc_rep
    mov     (0x14, sp), d0
    add     -1, d0
    mov     d0, (0x14, sp)
    bne     dc_row
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Firmware signatures: 0x00nn = byte nn, 0x0100 = any byte (an operand that moves between builds).
    .align  2
sig_ext:        # SetExtMode, ResetExtMode, CheckExtMode (941: 0x48532346)
    .word   0x81, 0x15, 0xa5, 0x03, 0xc2, 0x08, 0xfc, 0x82, 0x100, 0x100, 0x100, 0x100
    .word   0xde, 0x00, 0x00, 0x00, 0xfc, 0x82, 0x100, 0x100, 0x100, 0x100, 0xde, 0x00, 0x00
    .word   0xfc, 0xa8, 0x100, 0x100, 0x100, 0x100, 0xde, 0x00, 0x00, 0xFFFF
sig_open:       # fmmopen (941: 0x48532390)
    .word   0xcf, 0x30, 0xf8, 0xfe, 0xe4, 0x97, 0xfc, 0xde, 0x100, 0x100, 0x100, 0x100
    .word   0x3d, 0x21, 0x10, 0x85, 0xf4, 0xdb, 0xf0, 0x42, 0x49, 0xf0, 0x51, 0x45, 0x44, 0xd9
    .word   0xfc, 0xa8, 0x100, 0x100, 0x100, 0x100, 0x3d, 0x54, 0x21, 0x10, 0xf3, 0xa1, 0x9d
    .word   0xf0, 0xf2, 0xdf, 0x30, 0x24, 0xFFFF
sig_close:      # fmmclose and the other argument-less dispatchers (941: 0x485323BC)
    .word   0xf8, 0xfe, 0xec, 0xfc, 0xdd, 0x100, 0x100, 0x100, 0x100
    .word   0x3c, 0x20, 0x08, 0x85, 0xf4, 0xdb, 0xf0, 0x41, 0x45, 0xf0, 0x50, 0x41, 0x44, 0xd9
    .word   0xfc, 0xa8, 0x100, 0x100, 0x100, 0x100, 0x3c, 0x54, 0x20, 0x08, 0xf3, 0x80
    .word   0xf0, 0xf0, 0xdf, 0x00, 0x14, 0xFFFF
sig_rw:         # fmmread and fmmwrite (941: 0x48532463, 0x4853248F)
    .word   0xcf, 0xa0, 0xf8, 0xfe, 0xe4, 0x82, 0xfc, 0xde, 0x100, 0x100, 0x100, 0x100
    .word   0x3d, 0x21, 0x10, 0x85, 0xf4, 0xdb, 0xf0, 0x42, 0x49, 0xf0, 0x51, 0x45, 0x44, 0xd9
    .word   0xfc, 0xa8, 0x100, 0x100, 0x100, 0x100, 0x3d, 0x54, 0x21, 0x10, 0xf3, 0x91, 0x88
    .word   0xf0, 0xf1, 0xdf, 0xa0, 0x24, 0xFFFF
sig_raw:        # raw SD sector read and write, back to back (941: 0x48470348)
    .word   0xcf, 0x80, 0xf8, 0xfe, 0xe8, 0x82, 0xfc, 0xa8, 0x100, 0x100, 0x100, 0x100
    .word   0x10, 0xa0, 0x00, 0xc8, 0x15, 0x80, 0x01, 0xfc, 0x82, 0x100, 0x100, 0x100, 0x100
    .word   0x00, 0xfc, 0x82, 0x100, 0x100, 0x100, 0x100, 0x80, 0x06, 0xca, 0x0e
    .word   0x1d, 0x46, 0x10, 0x80, 0x03, 0x94, 0x89, 0xcd, 0x100, 0x100, 0x00, 0x1c, 0xdf, 0x80, 0x1c
    .word   0xcf, 0x80, 0xf8, 0xfe, 0xe8, 0x1d, 0x46, 0x10, 0x81, 0x94, 0x80, 0x04
    .word   0xcd, 0x100, 0x100, 0x00, 0x1c, 0xdf, 0x80, 0x1c, 0xFFFF
sig_sdfolder:   # sdfmmkdir and sdfmpath, back to back (941: 0x48565D45)
    .word   0xcf, 0xa0, 0xf8, 0xfe, 0xf4, 0x92, 0x08, 0xdd, 0x100, 0x100, 0x100, 0x100, 0x00, 0x1c
    .word   0x98, 0xdd, 0x100, 0x100, 0x100, 0x100, 0xa0, 0x18, 0xa8, 0xc2, 0x10
    .word   0xfc, 0xa4, 0x100, 0x100, 0x100, 0x100, 0x8a, 0xf5, 0xa0, 0x1f, 0xc8, 0x04, 0x8a, 0xfd
    .word   0xfc, 0xad, 0x100, 0x100, 0x100, 0x100, 0x19, 0x84, 0xa5, 0x00, 0xc0, 0x04, 0x88, 0x18
    .word   0xfc, 0x83, 0x100, 0x100, 0x100, 0x100, 0x88, 0xdf, 0xa0, 0x14
    .word   0xf8, 0xfe, 0xec, 0x91, 0xb5, 0x00, 0xc9, 0x16, 0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100
    .word   0x00, 0x2d, 0x80, 0x00, 0xdd, 0x100, 0x100, 0x100, 0x100, 0x20, 0x04, 0x00, 0xca, 0x10
    .word   0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100, 0xdd, 0x100, 0x100, 0x100, 0x100, 0x00, 0x00
    .word   0x00, 0xdf, 0x00, 0x14, 0xFFFF
sig_tick:       # the kernel's 1 kHz tick handler: mov (MS), d0; inc d0; mov d0, (MS) (941 lib 0x4C02BB05)
    .word   0xcf, 0x80, 0xf8, 0xfe, 0xf0, 0xfc, 0xa4, 0x100, 0x100, 0x100, 0x100, 0x40
    .word   0xfc, 0x81, 0x100, 0x100, 0x100, 0x100, 0xf8, 0xec, 0x01, 0xc8, 0x09
    .word   0xdd, 0x100, 0x100, 0x100, 0x100, 0x80, 0x0c, 0xfa, 0xfc, 0xff, 0xf7, 0xcb, 0xcb
    .word   0xfc, 0xac, 0x18, 0x01, 0x00, 0x34, 0xfa, 0xe0, 0x00, 0xff, 0xf8, 0xe4, 0x01
    .word   0xfc, 0x83, 0x18, 0x01, 0x00, 0x34, 0xFFFF
sig_build:      # SOFT VERSION: mov (B), d0; clr d3; movhu d0, (x); mov (0x4800001C), d2; add 0x48000000, d2
    .word   0xfc, 0xa4, 0x100, 0x100, 0x100, 0x100, 0x0c, 0xfc, 0x83, 0x100, 0x100, 0x100, 0x100
    .word   0xfc, 0xa6, 0x1c, 0x00, 0x00, 0x48, 0xfc, 0xc2, 0x00, 0x00, 0x00, 0x48, 0xFFFF

    .align  4
LoaderTest:                         # test builds only (run_test.sh --loader-test N): switch searches off
    .long   0                       # 1 file signatures, 2 fmm tables, 4 raw sectors, 8 SD folders,
                                    # 0x10 build number, 0x20 ms counter
str_title:      .asciz  "KN7000 SD APP LOADER"
str_loading:    .asciz  "Looking for the firmware's file routines, then loading C:\KN7APP.BIN"
str_appname:    .asciz  "KN7APP.BIN"
mode_rb:        .asciz  "rb"
str_f_prog:     .asciz  "PROGRAM "
str_f_table:    .asciz  "  TABLE "
str_f_rel:      .asciz  "  release "
str_code:       .asciz  "code 0x"
str_k_file:     .asciz  "file routines: "
str_k_none:     .asciz  "none"
str_k_code:     .asciz  "by code"
str_k_tables:   .asciz  "by tables"
str_k_raw:      .asciz  "  sectors: "
str_k_folder:   .asciz  "  folders: "
str_k_clock:    .asciz  "  clock: "
str_s_tab:      .asciz  "search: fmm table shapes found "
str_s_code:     .asciz  ", file code steps "
str_s_steps:    .asciz  " of 5"
str_yes:        .asciz  "yes"
str_no:         .asciz  "no"
str_leave:      .asciz  "In 15 s the firmware asks 'Continue Next?': NO leaves the converter."
str_no_file:    .asciz  "No file routines found (neither fmm tables nor code): cannot use the SD card."
str_no_app:     .asciz  "No C:\KN7APP.BIN on the SD card (or no card): copy an application there."
str_bad_app:    .asciz  "C:\KN7APP.BIN is not an application for this loader (bad header)."
str_old_app:    .asciz  "C:\KN7APP.BIN was built for another loader version."
str_crc_app:    .asciz  "C:\KN7APP.BIN is damaged: its CRC-32 does not match."

.include "font8x13.inc"
