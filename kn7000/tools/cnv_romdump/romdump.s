# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# romdump.s -- the KN7000 ROM dumper, an application for KN7LOAD.CNV (loader.s; README.md). Copied
# to the SD card as KN7APP.BIN, it dumps the program and table flash, the custom data flash, the four
# wave ROMs and the picture flash window into C:\KN7DUMP, with MAME's ROM names.
#
# The loader calls AppEntry once per converter call. Every call does one step -- a 32 KB chunk --
# and parks the firmware with request 1, which calls again without repainting the screen. While a
# step runs, the file layer is switched to the SD card; it is switched back before returning. The
# firmware's own file layer writes the files, under 8.3 names (its FAT library has no long names).
# When every file is closed, the long-name pass rewrites the dump folder's directory cluster with
# VFAT long-name entries in front of the same 8.3 entries, so a PC sees MAME's names.
#
# Calling convention: d0, d1, a0, a1 scratch; d2, d3, a2, a3 preserved. A routine that calls anything
# makes a frame first (movm + add -0x20, sp): firmware routines store into 4..0x10(sp).

.mnbase 0x502BA000
.include "kn7cnv.inc"
.include "romdump.inc"

# ---- application header (mkapp.py fills in the size and the CRC-32) ------------------------------
AppHeader:
    .long   0x41374E4B              # "KN7A"
    .long   LOADER_ABI
    .long   0                       # AH_SIZE
    .long   AppEntry
    .long   0                       # AH_CRC
    .long   APP_BASE
    .long   0, 0
    .ascii  "KN7000 ROM DUMPER 1.0"
    .space  11                      # the name is 32 bytes (mkapp.py --name may change it)
    .long   0                       # APP_OPTIONS (mkapp.py --options), covered by the CRC

# ================================================================================================
AppEntry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_STATE), d0
    cmp     0, d0
    beq     en_first
    cmp     1, d0
    beq     en_dump
    cmp     2, d0
    beq     en_finish
    mov     (SVC+SV_MSCOUNT), a0    # done or failed: show the result a while, then end the conversion
    cmp     0, a0
    beq     en_hold_calls
    mov     (a0), d0
    mov     (V_HOLD), d1
    sub     d1, d0
    cmp     HOLD_MS, d0
    bcc     en_end
    bra     en_park
en_hold_calls:
    mov     HOLD_SPIN, d0
eh_spin:
    add     -1, d0
    bne     eh_spin
    mov     (V_HOLD), d0
    inc     d0
    mov     d0, (V_HOLD)
    cmp     HOLD_CALLS, d0
    bcc     en_end
    bra     en_park

en_first:
    mov     RomTable, a0            # the table this build reads: the ROMs, or the survey's windows
    mov     (APP_OPTIONS), d0
    mov     OPT_SURVEY, d1
    and     d1, d0
    beq     en_table
    mov     SurveyTable, a0
en_table:
    mov     a0, (V_TABLE)
    call    InitCrc, 0, 0
    call    MakeNames, 0, 0
    mov     (APP_OPTIONS), d0       # C:\KN7DUMP (-3 when it is already there); without sdfmmkdir, or
    mov     OPT_NOFOLDER, d1        # in a build without the folder, the files go to the current folder
    and     d1, d0
    bne     en_nofolder
    mov     (SVC+SV_MKDIR), a1
    cmp     0, a1
    bne     en_mkdir
en_nofolder:
    mov     1, d0
    mov     d0, (V_NOFOLDER)
    bra     en_frame
en_mkdir:
    call    SdOn, 0, 0
    mov     str_folder_c, a0
    mov     (SVC+SV_MKDIR), a1
    calls   (a1)
    call    SdOff, 0, 0
en_frame:
    call    DrawFrame, 0, 0
    mov     1, d0
    mov     d0, (V_STATE)
    bra     en_park

en_dump:
    call    SdOn, 0, 0
    call    DumpStep, 0, 0          # a file error marks that ROM and goes on with the next
    call    SdOff, 0, 0
    bra     en_park

en_finish:
    call    SdOn, 0, 0
    call    WriteManifest, 0, 0     # (a failure is shown; the dump files are already written)
    call    SdOff, 0, 0
    call    LongNames, 0, 0         # after the last close: no file open, no cached directory sector
    mov     3, d0
    mov     d0, (V_STATE)
    call    DrawDone, 0, 0
    call    HoldStart, 0, 0
    bra     en_park

en_park:                            # request 1, argument 0: call again, leave the screen alone
    mov     MAILBOX, a0
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

HoldStart:                          # leaf: V_HOLD = now (kernel ms), or call 0
    clr     d0
    mov     (SVC+SV_MSCOUNT), a0
    cmp     0, a0
    beq     hs_set
    mov     (a0), d0
hs_set:
    mov     d0, (V_HOLD)
    rets

# ================================================================================================
# Services from the loader's table.
SdOn:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     1, d0
    mov     (SVC+SV_SETEXT), a0
    calls   (a0)
    ret     [d2,d3,a2,a3], 0x30

SdOff:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_RESETEXT), a0
    calls   (a0)
    ret     [d2,d3,a2,a3], 0x30

DrawText:                           # a0 = text, d0 = x, d1 = y -> d0 = x after
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_DRAWTEXT), a3
    calls   (a3)
    ret     [d2,d3,a2,a3], 0x30

FillRect:                           # d0 = x, d1 = y, a0 = width, a1 = height
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_FILLRECT), a3
    calls   (a3)
    ret     [d2,d3,a2,a3], 0x30

RawRead:                            # d0 = card sector, d1 = count, a1 = buffer -> d0 = 0
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_RAWREAD), a3
    calls   (a3)
    ret     [d2,d3,a2,a3], 0x30

RawWrite:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_RAWWRITE), a3
    calls   (a3)
    ret     [d2,d3,a2,a3], 0x30

# InitCrc: the CRC-32 table (reflected, 0xEDB88320).
InitCrc:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     CRCTAB, a2
    clr     d2
ic_n:
    mov     d2, d0
    mov     8, d3
ic_bit:
    btst    1, d0
    beq     ic_even
    lsr     1, d0
    mov     0xEDB88320, d1
    xor     d1, d0
    bra     ic_next
ic_even:
    lsr     1, d0
ic_next:
    add     -1, d3
    bne     ic_bit
    mov     d0, (a2)
    add     4, a2
    inc     d2
    cmp     256, d2
    bne     ic_n
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# MakeNames: the program and table ROM names as MAME's kn7000 driver spells them for this build:
# kn7000_program_{even,odd}_v<release>_b<build>.ic17/.ic16, kn7000_table_{even,odd}_b<table>...,
# or ..._sp7001_b<build> on the SP7001 firmware (release byte 0xFF).
MakeNames:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d2                      # 0 program even, 1 program odd, 2 table even, 3 table odd
mn_one:
    mov     d2, d0
    asl     6, d0
    mov     NAMES, a0
    add     d0, a0
    mov     str_n_prog, a1
    cmp     2, d2
    bcs     mn_kind
    mov     str_n_table, a1
mn_kind:
    call    StrCpy, 0, 0
    mov     str_n_even, a1
    btst    1, d2
    beq     mn_lane
    mov     str_n_odd, a1
mn_lane:
    call    StrCpy, 0, 0
    mov     (SVC+SV_RELEASE), d0
    cmp     0xFF, d0
    bne     mn_rel
    mov     str_n_sp7001, a1
    call    StrCpy, 0, 0
    bra     mn_build
mn_rel:
    cmp     2, d2                   # the program names carry the release, the table names do not
    bcc     mn_build
    mov     str_n_v, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_RELEASE), d0
    lsr     4, d0
    call    PutDigit, 0, 0
    mov     0x2E, d0
    movbu   d0, (a0)
    inc     a0
    mov     (SVC+SV_RELEASE), d0
    call    PutDigit, 0, 0
mn_build:
    mov     str_n_b, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_BUILD), d0
    mov     FOUND_BUILD, d1
    cmp     2, d2
    bcs     mn_num
    mov     (SVC+SV_TBUILD), d0
    mov     FOUND_TBUILD, d1
mn_num:
    mov     d0, mdr                 # a build number not found is named "unknown"
    mov     (SVC+SV_FOUND), d0
    and     d1, d0
    bne     mn_known
    mov     str_n_unknown, a1
    call    StrCpy, 0, 0
    bra     mn_ext
mn_known:
    mov     mdr, d0
    call    PutDec, 0, 0
mn_ext:
    mov     str_n_ic17, a1
    btst    1, d2
    beq     mn_ic
    mov     str_n_ic16, a1
mn_ic:
    call    StrCpy, 0, 0
    inc     d2
    cmp     4, d2
    bne     mn_one
    ret     [d2,d3,a2,a3], 0x30

PutDigit:                           # leaf: a0 = out, d0 = low nibble as one hex digit
    and     0x0F, d0
    cmp     10, d0
    bcs     pd_num
    add     7, d0
pd_num:
    add     0x30, d0
    movbu   d0, (a0)
    inc     a0
    clr     d0
    movbu   d0, (a0)
    rets

# ================================================================================================
# DumpStep -> d0 = 0, or < 0 for a file error. Opens the next file when none is open, reads and
# writes one chunk, closes the file at its end.
DumpStep:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_FILEOPEN), d0
    cmp     0, d0
    bne     ds_have
    call    Skipped, 0, 0           # d0 = 1: this build leaves the ROM out
    cmp     0, d0
    beq     ds_open
    call    RomSkip, 0, 0
    clr     d0
    bra     ds_ret
ds_open:
    call    OpenRom, 0, 0
    cmp     0, d0
    blt     ds_skip
    bra     ds_have
ds_skip:                            # this ROM's file failed: record it and go on
    call    RomFailed, 0, 0
    clr     d0
    bra     ds_ret
ds_have:
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     (R_LEN, a2), d2
    mov     (V_POS), d0
    sub     d0, d2                  # bytes left
    mov     CHUNK, d0
    cmp     d0, d2
    bls     ds_n
    mov     d0, d2
ds_n:
    mov     a2, a0
    mov     d2, d0
    call    FillChunk, 0, 0
    mov     BUF, a0
    mov     d2, d0
    call    CrcSum, 0, 0
    mov     BUF, a0
    mov     d2, d0
    mov     (SVC+SV_WRITE), a1
    calls   (a1)
    cmp     d2, d0
    beq     ds_written
    mov     d0, (V_ERR)
    mov     (SVC+SV_CLOSE), a0
    calls   (a0)
    clr     d0
    mov     d0, (V_FILEOPEN)
    bra     ds_skip
ds_written:
    mov     (V_POS), d0
    add     d2, d0
    mov     d0, (V_POS)
    call    DrawProgress, 0, 0
    mov     (V_POS), d0
    mov     (R_LEN, a2), d1
    cmp     d1, d0
    bne     ds_ok
    call    CloseRom, 0, 0
    call    NextRom, 0, 0
ds_ok:
    clr     d0
ds_ret:
    ret     [d2,d3,a2,a3], 0x30

# RomFailed: this ROM's file could not be created or written (V_ERR): mark it, show it, next ROM.
RomFailed:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    call    RomPtr, 0, 0
    mov     ST_ERROR, d0
    mov     d0, (12, a1)
    mov     (V_ERR), d0
    mov     d0, (8, a1)
    mov     (V_FAILS), d0
    inc     d0
    mov     d0, (V_FAILS)
    mov     (V_ROM), d0
    call    DrawListLine, 0, 0
    call    NextRom, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# RomSkip: this build does not dump this ROM (APP_OPTIONS): mark it, show it, next ROM.
RomSkip:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    call    RomPtr, 0, 0
    mov     ST_SKIP, d0
    mov     d0, (12, a1)
    mov     (V_ROM), d0
    call    DrawListLine, 0, 0
    call    NextRom, 0, 0
    ret     [d2,d3,a2,a3], 0x30

Skipped:                            # leaf -> d0 = bit V_ROM of APP_OPTIONS
    mov     (APP_OPTIONS), d0
    mov     (V_ROM), d1
sk_shift:
    cmp     0, d1
    beq     sk_bit
    lsr     1, d0
    add     -1, d1
    bra     sk_shift
sk_bit:
    and     1, d0
    rets

NextRom:                            # leaf: on to the next ROM; after the last, the finishing step
    mov     (V_ROM), d0
    inc     d0
    mov     d0, (V_ROM)
    clr     d1
    mov     d1, (V_POS)
    cmp     NUM_ROMS, d0
    bne     nr_ret
    mov     2, d0
    mov     d0, (V_STATE)
nr_ret:
    rets

RomPtr:                             # leaf -> a0 = this ROM's record, a1 = its result slot
    mov     (V_ROM), d0
    mov     d0, d1
    asl     R_SHIFT, d0
    mov     (V_TABLE), a0       # the table in use (leaves: no call, which would reuse (sp))
    cmp     0, a0
    bne     rp_tbl
    mov     RomTable, a0
rp_tbl:
    add     d0, a0
    asl     4, d1
    mov     V_RESULTS, a1
    add     d1, a1
    rets

OpenRom:                            # -> d0 = 0, or < 0
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    bne     or_bare
    mov     (R_PATH, a2), a0        # "KN7DUMP\NAME.BIN"
    mov     mode_wb, a1
    mov     (SVC+SV_OPEN), a3
    calls   (a3)
    exth    d0
    cmp     0, d0
    bge     or_ok
    mov     1, d0                   # no folder after all: from now on, the current folder
    mov     d0, (V_NOFOLDER)
or_bare:
    mov     (R_PATH, a2), a0
    add     8, a0                   # past "KN7DUMP\"
    mov     mode_wb, a1
    mov     (SVC+SV_OPEN), a3
    calls   (a3)
    exth    d0
    cmp     0, d0
    bge     or_ok
    mov     d0, (V_ERR)
    bra     or_ret
or_ok:
    mov     1, d0
    mov     d0, (V_FILEOPEN)
    clr     d0
    mov     d0, (V_POS)
    mov     d0, (V_SUM)
    mov     -1, d0
    mov     d0, (V_CRC)
    call    DrawCurrent, 0, 0
    clr     d0
or_ret:
    ret     [d2,d3,a2,a3], 0x30

CloseRom:                           # closes the file; records CRC, sum, size, status
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (SVC+SV_CLOSE), a0
    calls   (a0)
    clr     d0
    mov     d0, (V_FILEOPEN)
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     a1, a3
    mov     (V_CRC), d0
    not     d0
    mov     d0, (0, a3)
    mov     (V_SUM), d0
    mov     d0, (4, a3)
    mov     (V_POS), d0
    mov     d0, (8, a3)
    mov     ST_OK, d1
    mov     (R_GOLDEN, a2), d0
    cmp     0, d0
    beq     cr_status
    mov     (V_SUM), d2
    cmp     d2, d0
    beq     cr_status
    mov     ST_FAIL, d1             # a wave ROM whose sum is not the firmware's
cr_status:
    mov     d1, (12, a3)
    mov     (V_ROM), d0
    call    DrawListLine, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# FillChunk(a0 = ROM record, d0 = bytes): BUF = the next d0 bytes of the ROM, from V_POS.
FillChunk:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d0, d3
    mov     BUF, a1
    mov     (R_KIND, a2), d0
    cmp     K_WAVE, d0
    beq     fc_wave
    cmp     K_LINEAR, d0
    beq     fc_linear
    mov     (V_POS), d1             # a 16-bit lane: file offset p -> CPU base + 2p (+2 for lane 1)
    add     d1, d1
    mov     (R_BASE, a2), a0
    add     d1, a0
    cmp     K_LANE1, d0
    bne     fc_lane
    add     2, a0
fc_lane:
    movhu   (a0), d0
    movhu   d0, (a1)
    add     4, a0
    add     2, a1
    add     -2, d3
    bne     fc_lane
    bra     fc_ret
fc_linear:
    mov     (R_BASE, a2), a0
    mov     (V_POS), d1
    add     d1, a0
fc_lin:
    movhu   (a0), d0
    movhu   d0, (a1)
    add     2, a0
    add     2, a1
    add     -2, d3
    bne     fc_lin
    bra     fc_ret
fc_wave:                            # one bank (0x8000 bytes) through the wave ROM test latches
    mov     (R_BASE, a2), a3
    mov     0x8000, d0
    movhu   d0, (WAVE_BANK, a3)     # test mode on
    call    Settle, 0, 0
    mov     (V_POS), d0
    lsr     15, d0                  # bank
    mov     0x8000, d1
    or      d1, d0
    movhu   d0, (WAVE_BANK, a3)
    mov     (R_SEL, a2), d2
    mov     0x8000, d1
    or      d1, d2                  # 0x8000 | select
    mov     BUF, a1
    clr     d1                      # word address within the bank, in bytes
fc_word:
    mov     d1, d0
    or      d2, d0
    movhu   d0, (WAVE_ADDR, a3)
    movhu   (WAVE_DATA, a3), d0
    movhu   d0, (a1)                # low byte first
    add     2, a1
    add     2, d1
    mov     0x8000, d0
    cmp     d0, d1
    bne     fc_word
    clr     d0
    movhu   d0, (WAVE_BANK, a3)     # test mode off
    call    Settle, 0, 0
fc_ret:
    ret     [d2,d3,a2,a3], 0x30

Settle:                             # leaf: about a tick
    mov     SETTLE_LOOPS, d0
se_loop:
    add     -1, d0
    bne     se_loop
    rets

# CrcSum(a0 = data, d0 = bytes): updates V_CRC and V_SUM.
CrcSum:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    mov     a0, a2
    mov     (V_CRC), d0
    mov     (V_SUM), a3
    mov     CRCTAB, a1
cc_byte:
    movbu   (a2), d1
    inc     a2
    add     d1, a3
    xor     d0, d1
    and     0xFF, d1
    asl     2, d1
    mov     (d1, a1), d2
    lsr     8, d0
    xor     d2, d0
    add     -1, d3
    bne     cc_byte
    mov     d0, (V_CRC)
    mov     a3, (V_SUM)
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# WriteManifest -> d0 = 0 or < 0: KN7DUMP\DUMPLIST.TXT, one line per ROM: MAME name, file on the
# card, size, CRC-32, byte sum (and the firmware's expected sum for a wave ROM), what was read.
WriteManifest:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     TEXT, a0
    mov     str_m_head, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_BUILD), d0
    mov     FOUND_BUILD, d1
    call    PutBuild, 0, 0
    mov     str_m_table, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_TBUILD), d0
    mov     FOUND_TBUILD, d1
    call    PutBuild, 0, 0
    mov     str_m_release, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_RELEASE), d0
    mov     2, d1
    call    PutHex, 0, 0
    mov     str_m_options, a1
    call    StrCpy, 0, 0
    mov     (APP_OPTIONS), d0
    mov     8, d1
    call    PutHex, 0, 0
    call    PutCrLf, 0, 0
    mov     str_m_found, a1         # what the loader found in this firmware
    call    StrCpy, 0, 0
    mov     (SVC+SV_FOUND), d0
    mov     2, d1
    call    PutHex, 0, 0
    mov     str_m_found2, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_TABLES), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     str_m_found3, a1
    call    StrCpy, 0, 0
    mov     (SVC+SV_OPEN), d0
    mov     8, d1
    call    PutHex, 0, 0
    call    PutCrLf, 0, 0
    clr     d2
wm_rom:
    mov     d2, (V_ROM)
    mov     a0, (0x14, sp)
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     a1, a3
    mov     (0x14, sp), a0
    mov     (R_NAME, a2), a1
    call    StrCpy, 0, 0
    mov     str_sp, a1
    call    StrCpy, 0, 0
    mov     (R_PATH, a2), a1
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    beq     wm_path
    add     8, a1                   # past "KN7DUMP\"
wm_path:
    call    StrCpy, 0, 0
    mov     str_sp, a1
    call    StrCpy, 0, 0
    mov     (12, a3), d0
    cmp     ST_SKIP, d0
    bne     wm_notskip
    mov     str_m_skip, a1          # left out by this build
    call    StrCpy, 0, 0
    bra     wm_src
wm_notskip:
    cmp     ST_ERROR, d0
    bne     wm_size
    mov     str_m_error, a1         # no file: the error code instead
    call    StrCpy, 0, 0
    mov     (8, a3), d0
    mov     8, d1
    call    PutHex, 0, 0
    bra     wm_src
wm_size:
    mov     (8, a3), d0
    call    PutDec, 0, 0
    mov     str_m_crc, a1
    call    StrCpy, 0, 0
    mov     (0, a3), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     str_m_sum, a1
    call    StrCpy, 0, 0
    mov     (4, a3), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     (R_GOLDEN, a2), d0
    cmp     0, d0
    beq     wm_src
    mov     str_m_golden, a1
    call    StrCpy, 0, 0
    mov     (R_GOLDEN, a2), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     str_m_ok, a1
    mov     (12, a3), d0
    cmp     ST_OK, d0
    beq     wm_chk
    mov     str_m_bad, a1
wm_chk:
    call    StrCpy, 0, 0
wm_src:
    mov     str_sp, a1
    call    StrCpy, 0, 0
    mov     (R_RANGE, a2), a1
    call    StrCpy, 0, 0
    call    PutCrLf, 0, 0
    inc     d2
    cmp     NUM_ROMS, d2
    bne     wm_rom
    mov     TEXT, d0
    mov     a0, d1
    sub     d0, d1
    mov     d1, (V_TEXTLEN)
    mov     path_manifest, a0
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    beq     wm_open
    add     8, a0
wm_open:
    mov     mode_wb, a1
    mov     (SVC+SV_OPEN), a3
    calls   (a3)
    exth    d0
    cmp     0, d0
    bge     wm_write
    mov     d0, (V_ERR)
    mov     str_err_open, a0
    mov     a0, (V_FAIL)
    bra     wm_ret
wm_write:
    mov     TEXT, a0
    mov     (V_TEXTLEN), d0
    mov     (SVC+SV_WRITE), a3
    calls   (a3)
    mov     d0, d2
    mov     (SVC+SV_CLOSE), a3
    calls   (a3)
    clr     d0
    mov     (V_TEXTLEN), d1
    cmp     d1, d2
    beq     wm_ret
    mov     d2, (V_ERR)
    mov     str_err_write, a0
    mov     a0, (V_FAIL)
    mov     -1, d0
wm_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# LongNames: gives the dump files MAME's names on the card. The firmware's FAT library writes 8.3
# names only, so this rewrites the folder's directory cluster: ".", "..", then for every file its
# VFAT long-name entries followed by its own 8.3 entry, unchanged. It only touches C:\KN7DUMP's first
# cluster, and only when that cluster holds nothing but these files (and old long-name or deleted
# entries) and the whole directory fits in it; otherwise it leaves the card alone and says why.
# Runs after the last fmmclose, when the library holds no copy of the folder's sectors.
LongNames:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     2, d0                   # until it succeeds, "skipped"
    mov     d0, (V_LFN)
    mov     str_lfn_off, a0         # a build without the pass
    mov     (APP_OPTIONS), d0
    mov     OPT_NOLFN, d1
    and     d1, d0
    bne     ln_skip
    mov     str_lfn_noraw, a0       # the loader found no sector access in this firmware
    mov     (SVC+SV_RAWREAD), d0
    cmp     0, d0
    beq     ln_skip
    mov     (SVC+SV_RAWWRITE), d0
    cmp     0, d0
    beq     ln_skip
    mov     str_lfn_notinfolder, a0 # the files are not in KN7DUMP
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    bne     ln_skip
    clr     d0                      # sector 0: an MBR, or a boot sector (a card without partitions)
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ln_ioerr
    clr     d2                      # partition start
    mov     SECBUF, a0
    movbu   (a0), d0
    cmp     0xEB, d0
    beq     ln_bpb0
    cmp     0xE9, d0
    beq     ln_bpb0
    mov     SECBUF+0x1C6, a0
    call    Read32U, 0, 0
    mov     d0, d2
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0           # the partition's boot sector
    cmp     0, d0
    bne     ln_ioerr
ln_bpb0:
    mov     d2, (V_PART)
    mov     SECBUF, a2              # the BPB
    movbu   (0x0B, a2), d0
    movbu   (0x0C, a2), d1
    asl     8, d1
    or      d1, d0
    mov     str_lfn_geom, a0
    cmp     512, d0
    bne     ln_skip
    movbu   (0x0D, a2), d0          # sectors per cluster, 1..64
    cmp     0, d0
    beq     ln_skip
    cmp     64, d0
    bhi     ln_skip
    mov     d0, (V_SPC)
    asl     9, d0
    mov     d0, (V_CLBYTES)
    movbu   (0x0E, a2), d0          # reserved sectors
    movbu   (0x0F, a2), d1
    asl     8, d1
    or      d1, d0
    add     d0, d2
    movbu   (0x16, a2), d0          # sectors per FAT x number of FATs
    movbu   (0x17, a2), d1
    asl     8, d1
    or      d1, d0
    movbu   (0x10, a2), d1
    mulu    d1, d0
    add     d0, d2
    mov     d2, (V_ROOTLBA)
    movbu   (0x11, a2), d0          # root entries -> sectors
    movbu   (0x12, a2), d1
    asl     8, d1
    or      d1, d0
    lsr     4, d0
    cmp     0, d0
    beq     ln_skip
    mov     d0, (V_ROOTSECS)
    add     d0, d2
    mov     d2, (V_DATALBA)
    clr     d3                      # find KN7DUMP in the root directory
ln_root:
    mov     (V_ROOTSECS), d0
    cmp     d0, d3
    bcc     ln_nofolder
    mov     (V_ROOTLBA), d0
    add     d3, d0
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ln_ioerr
    mov     SECBUF, a2
ln_rent:
    movbu   (a2), d0
    cmp     0, d0
    beq     ln_nofolder
    movbu   (11, a2), d0
    btst    0x10, d0
    beq     ln_rnext
    btst    0x08, d0                # not a long-name entry or a label
    bne     ln_rnext
    mov     a2, a0
    mov     dir_folder, a1
    call    Same11, 0, 0
    cmp     0, d0
    bne     ln_found
ln_rnext:
    add     32, a2
    mov     SECBUF+512, a0
    cmp     a0, a2
    bcs     ln_rent
    inc     d3
    bra     ln_root
ln_found:
    movbu   (0x1A, a2), d0          # the folder's first cluster
    movbu   (0x1B, a2), d1
    asl     8, d1
    or      d1, d0
    add     -2, d0
    mov     (V_SPC), d1
    mulu    d1, d0
    mov     (V_DATALBA), d1
    add     d1, d0
    mov     d0, (V_DIRLBA)
    mov     (V_SPC), d1             # read the whole cluster into BUF
    mov     BUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ln_ioerr

    mov     SHORTS, a0              # no file's entry found yet
    mov     NUM_FILES*8, d1
    clr     d0
ln_clr:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     ln_clr
    mov     BUF, a2                 # every live 8.3 entry must be ".", "..", or one of the files
    mov     BUF, d3
    mov     (V_CLBYTES), d0
    add     d0, d3                  # end of the cluster
ln_scan:
    cmp     d3, a2
    bcc     ln_noend                # no end marker: the directory goes on into another cluster
    movbu   (a2), d0
    cmp     0, d0
    beq     ln_scanned
    cmp     0xE5, d0
    beq     ln_snext                # deleted
    movbu   (11, a2), d0
    cmp     0x0F, d0
    beq     ln_snext                # a long-name entry (rebuilt below)
    movbu   (a2), d0
    cmp     0x2E, d0
    beq     ln_snext                # "." and ".."
    mov     a2, a0
    call    WhichFile, 0, 0         # d0 = file index, or -1
    cmp     0, d0
    blt     ln_foreign
    asl     5, d0                   # keep a copy of its entry
    mov     SHORTS, a1
    add     d0, a1
    mov     a2, a0
    mov     8, d1
ln_keep:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     ln_keep
ln_snext:
    add     32, a2
    bra     ln_scan
ln_scanned:
    mov     BUF2, a0                # the new cluster: zeroes, then the entries
    mov     (V_CLBYTES), d1
    lsr     2, d1
    clr     d0
ln_zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     ln_zero
    mov     BUF2, a1                # "." and ".." as they were
    mov     BUF, a0
    mov     16, d1
ln_dots:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     ln_dots
    mov     a1, (V_OUT)
    clr     d2                      # file index
ln_file:
    mov     d2, d0
    asl     5, d0
    mov     SHORTS, a2
    add     d0, a2                  # its 8.3 entry, as found
    movbu   (a2), d0
    cmp     0, d0
    beq     ln_fnext                # not on the card (its ROM failed): nothing to name
    mov     d2, d0
    call    FileName, 0, 0          # a0 = its long name, or 0
    cmp     0, a0
    beq     ln_short
    mov     a2, a1
    call    PutLfn, 0, 0            # long-name entries at V_OUT
    cmp     0, d0
    bne     ln_full
ln_short:
    mov     (V_OUT), a1
    mov     BUF2, d0
    mov     (V_CLBYTES), d1
    add     d1, d0
    add     -64, d0
    cmp     d0, a1
    bhi     ln_full                 # no room left (an end marker must follow)
    mov     a2, a0
    mov     8, d1
ln_copy:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     ln_copy
    mov     a1, (V_OUT)
ln_fnext:
    inc     d2
    cmp     NUM_FILES, d2
    bne     ln_file
    mov     (V_DIRLBA), d0          # write the cluster, read it back, compare
    mov     (V_SPC), d1
    mov     BUF2, a1
    call    RawWrite, 0, 0
    cmp     0, d0
    bne     ln_ioerr
    mov     (V_DIRLBA), d0
    mov     (V_SPC), d1
    mov     BUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ln_ioerr
    mov     BUF, a0
    mov     BUF2, a1
    mov     (V_CLBYTES), d1
    lsr     2, d1
ln_verify:
    mov     (a0), d0
    mov     (a1), d3
    cmp     d3, d0
    bne     ln_verr
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     ln_verify
    mov     1, d0
    mov     d0, (V_LFN)
    mov     str_lfn_ok, a0
    bra     ln_msg
ln_ioerr:
    mov     d0, (V_ERR)
    mov     str_lfn_io, a0
    bra     ln_skip
ln_nofolder:
    mov     str_lfn_nofolder, a0
    bra     ln_skip
ln_noend:
    mov     str_lfn_big, a0
    bra     ln_skip
ln_foreign:
    mov     str_lfn_foreign, a0
    bra     ln_skip
ln_full:
    mov     str_lfn_big, a0
    bra     ln_skip
ln_verr:
    mov     str_lfn_verify, a0
ln_skip:
    mov     2, d0
    mov     d0, (V_LFN)
ln_msg:
    mov     a0, (V_LFNMSG)
    ret     [d2,d3,a2,a3], 0x30

# Same11(a0, a1) -> d0 = 1 when the 11 bytes at a0 and a1 are equal, else 0. Leaf (counts in mdr).
Same11:
    mov     11, d0
    mov     d0, mdr
s11_loop:
    movbu   (a0), d0
    movbu   (a1), d1
    cmp     d1, d0
    bne     s11_no
    inc     a0
    inc     a1
    mov     mdr, d0
    add     -1, d0
    mov     d0, mdr
    cmp     0, d0
    bne     s11_loop
    mov     1, d0
    rets
s11_no:
    clr     d0
    rets

# WhichFile(a0 = 8.3 directory entry) -> d0 = the file it is (0..NUM_FILES-1), or -1.
WhichFile:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    clr     d2
wf_next:
    mov     d2, d0
    call    File83, 0, 0            # a0 = its 11-character name
    mov     a0, a1
    mov     a2, a0
    call    Same11, 0, 0
    cmp     0, d0
    bne     wf_hit
    inc     d2
    cmp     NUM_FILES, d2
    bne     wf_next
    mov     -1, d0
    bra     wf_ret
wf_hit:
    mov     d2, d0
wf_ret:
    ret     [d2,d3,a2,a3], 0x30

# File83(d0 = file) -> a0 = its 11-character directory name. FileName(d0 = file) -> a0 = its long
# (MAME) name, or 0 for the manifest. Leaves.
File83:
    cmp     NUM_ROMS, d0
    bcs     f83_rom
    mov     dir_manifest, a0
    rets
f83_rom:
    asl     R_SHIFT, d0
    mov     (V_TABLE), a0       # the table in use (leaves: no call, which would reuse (sp))
    cmp     0, a0
    bne     f83_tbl
    mov     RomTable, a0
f83_tbl:
    add     d0, a0
    mov     (R_83, a0), a0
    rets

FileName:
    cmp     NUM_ROMS, d0
    bcs     fn_rom
    mov     0, a0
    rets
fn_rom:
    asl     R_SHIFT, d0
    mov     (V_TABLE), a0       # the table in use (leaves: no call, which would reuse (sp))
    cmp     0, a0
    bne     fn_tbl
    mov     RomTable, a0
fn_tbl:
    add     d0, a0
    mov     (R_NAME, a0), a0
    rets

# PutLfn(a0 = long name, a1 = its 8.3 entry) -> d0 = 0, or 1 when the cluster is full. Writes the
# VFAT entries at V_OUT, last part first: sequence number (0x40 on the last), 13 UCS-2 characters
# at +1/+14/+28 (NUL after the name, then 0xFFFF), attribute 0x0F, the 8.3 name's checksum at +13.
PutLfn:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2                  # name
    clr     d0                      # checksum of the 11-byte name: rotate right, add
    mov     11, d3
pl_sum:
    btst    1, d0
    beq     pl_s0
    lsr     1, d0
    or      0x80, d0
    bra     pl_s1
pl_s0:
    lsr     1, d0
pl_s1:
    movbu   (a1), d1
    add     d1, d0
    and     0xFF, d0
    inc     a1
    add     -1, d3
    bne     pl_sum
    mov     d0, (0x14, sp)          # checksum
    mov     a2, a0                  # name length
    clr     d2
pl_len:
    movbu   (a0), d0
    cmp     0, d0
    beq     pl_lend
    inc     a0
    inc     d2
    bra     pl_len
pl_lend:
    mov     d2, (0x18, sp)          # length
    mov     d2, d0                  # parts = (length + 12) / 13
    add     12, d0
    clr     d1
    mov     d1, mdr
    mov     13, d1
    divu    d1, d0
    mov     d0, d3                  # sequence number, counting down
    mov     (V_OUT), a3
    mov     BUF2, d0                # room: parts + the 8.3 entry + an end marker
    mov     (V_CLBYTES), d1
    add     d1, d0
    mov     d3, d1
    asl     5, d1
    sub     d1, d0
    add     -64, d0
    cmp     d0, a3
    bhi     pl_full
    mov     d3, (0x1C, sp)          # parts
pl_part:
    mov     d3, d0                  # sequence byte
    mov     (0x1C, sp), d1
    cmp     d1, d0
    bne     pl_seq
    or      0x40, d0
pl_seq:
    movbu   d0, (a3)
    mov     0x0F, d0
    movbu   d0, (11, a3)
    clr     d0
    movbu   d0, (12, a3)
    movbu   d0, (26, a3)
    movbu   d0, (27, a3)
    mov     (0x14, sp), d0
    movbu   d0, (13, a3)
    mov     d3, d0                  # first character of this part: (seq - 1) * 13
    add     -1, d0
    mov     13, d1
    mulu    d1, d0
    mov     d0, d2
    mov     pl_offsets, a1          # the 13 character slots
    mov     13, d1
    mov     d1, (0x10, sp)
pl_char:
    movbu   (a1), d0
    mov     a3, a0
    add     d0, a0                  # this slot
    mov     (0x18, sp), d1
    cmp     d1, d2
    bcs     pl_namech
    beq     pl_nul
    mov     0xFF, d0                # past the NUL: 0xFFFF
    movbu   d0, (a0)
    movbu   d0, (1, a0)
    bra     pl_cnext
pl_nul:
    clr     d0
    movbu   d0, (a0)
    movbu   d0, (1, a0)
    bra     pl_cnext
pl_namech:
    mov     a2, a0
    add     d2, a0
    movbu   (a0), d1                # the character
    movbu   (a1), d0
    mov     a3, a0
    add     d0, a0                  # the slot again
    movbu   d1, (a0)
    clr     d1
    movbu   d1, (1, a0)
pl_cnext:
    inc     a1
    inc     d2
    mov     (0x10, sp), d1
    add     -1, d1
    mov     d1, (0x10, sp)
    bne     pl_char
    add     32, a3
    add     -1, d3
    bne     pl_part
    mov     a3, (V_OUT)
    clr     d0
    bra     pl_ret
pl_full:
    mov     1, d0
pl_ret:
    ret     [d2,d3,a2,a3], 0x30
pl_offsets:
    .byte   1, 3, 5, 7, 9, 14, 16, 18, 20, 22, 24, 28, 30
    .align  2

Read32U:                            # leaf: a0 = address -> d0 = little-endian u32, any alignment
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
# Text. Leaves; a0 = output pointer, returned at the NUL written.
StrCpy:                             # a1 = source
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     sc_end
    inc     a0
    inc     a1
    bra     StrCpy
sc_end:
    rets

PutBuild:                           # a0 = out, d0 = number, d1 = its FOUND_ bit: the number or "?"
    mov     d0, mdr
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

PutCrLf:
    mov     13, d0
    movbu   d0, (a0)
    mov     10, d0
    movbu   d0, (1, a0)
    add     2, a0
    clr     d0
    movbu   d0, (a0)
    rets

PutHex:                             # d0 = value, d1 = digits (1..8; the low digits of the value)
    mov     d1, a1                  # left-align: shift by (8 - digits) * 4
    mov     8, d1
    sub     a1, d1
    asl     2, d1
    asl     d1, d0
    mov     a1, d1
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

PutDec:                             # d0 = value, no leading zeros
    mov     STR+0xF0, a1
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
# The screen: title and firmware line; the ROM being dumped (number, name, what is read, a progress
# bar); the list of all ROMs with their results.
.equ Y_CUR,         56
.equ Y_RANGE,       72
.equ Y_BAR,         90
.equ BAR_X,         8
.equ BAR_W,         520
.equ Y_LIST,        114
.equ LIST_STEP,     12

SetColours:                         # leaf: d0 = foreground; background C_BG, scale 1
    mov     d0, (SVC+SV_FG)
    mov     C_BG, d0
    mov     d0, (SVC+SV_BG)
    mov     1, d0
    mov     d0, (SVC+SV_SCALE)
    rets

DrawFrame:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_BG, d0
    call    SetColours, 0, 0
    clr     d0
    clr     d1
    mov     640, a0
    mov     240, a1
    call    FillRect, 0, 0
    mov     C_TEXT, d0
    call    SetColours, 0, 0
    mov     2, d0
    mov     d0, (SVC+SV_SCALE)
    mov     str_title, a0
    mov     8, d0
    mov     4, d1
    call    DrawText, 0, 0
    mov     STR, a0                 # firmware line
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
    mov     2, d1
    call    PutHex, 0, 0
    mov     C_DIM, d0
    call    SetColours, 0, 0
    mov     STR, a0
    mov     310, d0
    mov     10, d1
    call    DrawText, 0, 0
    mov     (APP_OPTIONS), d0       # a build with options shows its name ("... SAFE") under that
    cmp     0, d0
    beq     df_noname
    mov     C_WARN, d0
    call    SetColours, 0, 0
    mov     APP_BASE+AH_NAME, a0
    mov     310, d0
    mov     23, d1
    call    DrawText, 0, 0
df_noname:
    mov     str_target, a0
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    beq     df_target
    mov     str_target_nf, a0
df_target:
    mov     8, d0
    mov     36, d1
    call    DrawText, 0, 0
    clr     d2
df_list:
    mov     d2, d0
    call    DrawListLine, 0, 0
    inc     d2
    cmp     NUM_ROMS, d2
    bne     df_list
    ret     [d2,d3,a2,a3], 0x30

DrawListLine:                       # d0 = ROM index: "[ OK ] name ... CRC32 xxxxxxxx"
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    mov     (V_ROM), d3
    mov     d2, (V_ROM)
    call    RomPtr, 0, 0
    mov     d3, (V_ROM)
    mov     a0, a2
    mov     a1, a3
    mov     d2, d1
    mov     LIST_STEP, d0
    mulu    d0, d1
    add     Y_LIST, d1
    mov     d1, (0x14, sp)
    mov     C_DIM, d0
    mov     str_l_wait, a0
    mov     (12, a3), d1
    cmp     ST_OK, d1
    bne     dl_notok
    mov     C_GOOD, d0
    mov     str_l_ok, a0
dl_notok:
    cmp     ST_FAIL, d1
    bne     dl_noterr
    mov     C_BAD, d0
    mov     str_l_bad, a0
dl_noterr:
    cmp     ST_ERROR, d1
    bne     dl_notskip
    mov     C_BAD, d0
    mov     str_l_err, a0
dl_notskip:
    cmp     ST_SKIP, d1
    bne     dl_col
    mov     C_DIM, d0
    mov     str_l_skip, a0
dl_col:
    mov     a0, (0x18, sp)
    call    SetColours, 0, 0
    mov     (0x18, sp), a0
    mov     8, d0
    mov     (0x14, sp), d1
    call    DrawText, 0, 0
    mov     (R_NAME, a2), a0
    mov     (0x14, sp), d1
    call    DrawText, 0, 0
    mov     (12, a3), d0
    cmp     ST_PENDING, d0
    beq     dl_ret
    cmp     ST_SKIP, d0
    beq     dl_ret
    mov     STR, a0
    mov     str_l_crc, a1
    mov     (12, a3), d0
    cmp     ST_ERROR, d0
    bne     dl_crc
    mov     str_l_ferr, a1
dl_crc:
    call    StrCpy, 0, 0
    mov     (0, a3), d0
    mov     (12, a3), d1
    cmp     ST_ERROR, d1
    bne     dl_crcv
    mov     (8, a3), d0             # the error code
dl_crcv:
    mov     8, d1
    call    PutHex, 0, 0
    mov     STR, a0
    mov     480, d0
    mov     (0x14, sp), d1
    call    DrawText, 0, 0
dl_ret:
    ret     [d2,d3,a2,a3], 0x30

DrawCurrent:                        # the ROM being dumped: number and name, what is read, the bar
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     C_BG, d0
    call    SetColours, 0, 0
    clr     d0
    mov     Y_CUR, d1
    mov     640, a0
    mov     30, a1
    call    FillRect, 0, 0
    mov     STR, a0
    mov     str_c_rom, a1
    call    StrCpy, 0, 0
    mov     (V_ROM), d0
    inc     d0
    call    PutDec, 0, 0
    mov     str_c_of, a1
    call    StrCpy, 0, 0
    mov     (R_NAME, a2), a1
    call    StrCpy, 0, 0
    mov     C_WARN, d0
    call    SetColours, 0, 0
    mov     STR, a0
    mov     8, d0
    mov     Y_CUR, d1
    call    DrawText, 0, 0
    mov     STR, a0
    mov     str_c_read, a1
    call    StrCpy, 0, 0
    mov     (R_RANGE, a2), a1
    call    StrCpy, 0, 0
    mov     C_TEXT, d0
    call    SetColours, 0, 0
    mov     STR, a0
    mov     8, d0
    mov     Y_RANGE, d1
    call    DrawText, 0, 0
    mov     C_FRAME, d0
    call    SetColours, 0, 0
    mov     BAR_X, d0
    mov     Y_BAR, d1
    mov     BAR_W+4, a0
    mov     16, a1
    call    FillRect, 0, 0
    mov     C_BG, d0
    call    SetColours, 0, 0
    mov     BAR_X+2, d0
    mov     Y_BAR+2, d1
    mov     BAR_W, a0
    mov     12, a1
    call    FillRect, 0, 0
    call    DrawProgress, 0, 0
    ret     [d2,d3,a2,a3], 0x30

DrawProgress:                       # the bar to V_POS / length, and "nn%"
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    call    RomPtr, 0, 0
    mov     a0, a2
    mov     (V_POS), d2             # in 256-byte units, so pos * BAR_W fits 32 bits
    lsr     8, d2
    mov     (R_LEN, a2), d3
    lsr     8, d3
    mov     d2, d0
    mov     BAR_W, d1
    mulu    d1, d0
    clr     d1
    mov     d1, mdr
    divu    d3, d0
    cmp     BAR_W, d0
    bls     dp_w
    mov     BAR_W, d0
dp_w:
    cmp     0, d0
    beq     dp_txt
    mov     d0, (0x14, sp)
    mov     C_BAR, d0
    call    SetColours, 0, 0
    mov     (0x14, sp), a0
    mov     BAR_X+2, d0
    mov     Y_BAR+2, d1
    mov     12, a1
    call    FillRect, 0, 0
dp_txt:
    mov     d2, d0
    mov     100, d1
    mulu    d1, d0
    clr     d1
    mov     d1, mdr
    divu    d3, d0
    mov     STR, a0
    call    PutDec, 0, 0
    mov     str_pct, a1
    call    StrCpy, 0, 0
    mov     C_TEXT, d0
    call    SetColours, 0, 0
    mov     STR, a0
    mov     BAR_X+BAR_W+12, d0
    mov     Y_BAR+2, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

DrawDone:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_BG, d0
    call    SetColours, 0, 0
    clr     d0
    mov     Y_CUR, d1
    mov     640, a0
    mov     54, a1
    call    FillRect, 0, 0
    mov     (V_FAILS), d0           # first line: done, and where the files are
    cmp     0, d0
    bne     dd_errors
    mov     C_GOOD, d0
    call    SetColours, 0, 0
    mov     str_done, a0
    mov     (V_NOFOLDER), d0
    cmp     0, d0
    beq     dd_line1
    mov     str_done_nf, a0
    bra     dd_line1
dd_errors:
    mov     C_BAD, d0
    call    SetColours, 0, 0
    mov     STR, a0
    mov     str_done_err, a1
    call    StrCpy, 0, 0
    mov     (V_FAILS), d0
    call    PutDec, 0, 0
    mov     str_done_err2, a1
    call    StrCpy, 0, 0
    mov     STR, a0
dd_line1:
    mov     8, d0
    mov     Y_CUR, d1
    call    DrawText, 0, 0
    mov     (V_FAIL), a1            # second line: DUMPLIST.TXT's error, else the long-name pass
    cmp     0, a1
    beq     dd_lfnline
    mov     STR, a0
    call    StrCpy, 0, 0
    mov     str_f_code, a1
    call    StrCpy, 0, 0
    mov     (V_ERR), d0
    mov     8, d1
    call    PutHex, 0, 0
    mov     str_f_close, a1
    call    StrCpy, 0, 0
    mov     C_BAD, d0
    call    SetColours, 0, 0
    mov     STR, a0
    bra     dd_line2
dd_lfnline:
    mov     C_GOOD, d0
    mov     (V_LFN), d1
    cmp     1, d1
    beq     dd_lfn
    mov     C_WARN, d0
dd_lfn:
    call    SetColours, 0, 0
    mov     (V_LFNMSG), a0
dd_line2:
    mov     8, d0
    mov     Y_RANGE, d1
    call    DrawText, 0, 0
    mov     C_TEXT, d0
    call    SetColours, 0, 0
    mov     str_leave, a0
    mov     8, d0
    mov     Y_BAR, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30


# ================================================================================================
# The ROMs, in dump order; MAME names as in the kn7000 driver (MakeNames builds the first four).
    .align  4
RomTable:
    .long   NAMES+0x00, path_prog_even, K_LANE0, 0x48400000, 0x200000, 0, 0, rg_prog_even, dir_prog_even
    .long   0, 0, 0, 0, 0, 0, 0
    .long   NAMES+0x40, path_prog_odd, K_LANE1, 0x48400000, 0x200000, 0, 0, rg_prog_odd, dir_prog_odd
    .long   0, 0, 0, 0, 0, 0, 0
    .long   NAMES+0x80, path_tbl_even, K_LANE0, 0x48000000, 0x200000, 0, 0, rg_tbl_even, dir_tbl_even
    .long   0, 0, 0, 0, 0, 0, 0
    .long   NAMES+0xC0, path_tbl_odd, K_LANE1, 0x48000000, 0x200000, 0, 0, rg_tbl_odd, dir_tbl_odd
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic21, path_ic21, K_LINEAR, 0x96800000, 0x200000, 0, 0, rg_ic21, dir_ic21
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic203, path_ic203, K_WAVE, WAVE_MAIN, 0x1000000, 0, 0x8164C77C, rg_ic203, dir_ic203
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic204, path_ic204, K_WAVE, WAVE_MAIN, 0x1000000, 1, 0x815CFC83, rg_ic204, dir_ic204
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic207, path_ic207, K_WAVE, WAVE_SUB, 0x1000000, 0, 0x8331EF0B, rg_ic207, dir_ic207
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic208, path_ic208, K_WAVE, WAVE_SUB, 0x1000000, 1, 0x83254F9D, rg_ic208, dir_ic208
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_ic19, path_ic19, K_LINEAR, 0x57800000, 0x800000, 0, 0, rg_ic19, dir_ic19
    .long   0, 0, 0, 0, 0, 0, 0

# The SURVEY build (OPT_SURVEY): where is the rhythm ROM (IC18, or IC20 on early units)? The firmware
# looks for its "Technics Rhythms" header at 0x48010000, 0x40610000, 0x40010000, 0x54E10000 and
# 0x40810000, else uses 0x54E00000 (StyleResourceWindowProbe 0x4843D6DC in 941), so these windows,
# 8 MB each, cover every candidate: CS0 0x40000000-0x40FFFFFF and CS5 0x54000000-0x55FFFFFF. The
# firmware reads in both chip selects on every boot, and by the service manual (p.79, p.100, p.102)
# they hold memory chips only, no I/O registers. Entries 6-9 are unused (left out by the build's
# skip bits).
SurveyTable:
    .long   nm_s40000000, path_s40000000, K_LINEAR, 0x40000000, 0x800000, 0, 0, rg_s40000000, dir_s40000000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_s40800000, path_s40800000, K_LINEAR, 0x40800000, 0x800000, 0, 0, rg_s40800000, dir_s40800000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_s54000000, path_s54000000, K_LINEAR, 0x54000000, 0x800000, 0, 0, rg_s54000000, dir_s54000000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_s54800000, path_s54800000, K_LINEAR, 0x54800000, 0x800000, 0, 0, rg_s54800000, dir_s54800000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_s55000000, path_s55000000, K_LINEAR, 0x55000000, 0x800000, 0, 0, rg_s55000000, dir_s55000000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_s55800000, path_s55800000, K_LINEAR, 0x55800000, 0x800000, 0, 0, rg_s55800000, dir_s55800000
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_unused, path_unused, K_LINEAR, 0x48000000, 0x800000, 0, 0, rg_unused, dir_unused
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_unused, path_unused, K_LINEAR, 0x48000000, 0x800000, 0, 0, rg_unused, dir_unused
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_unused, path_unused, K_LINEAR, 0x48000000, 0x800000, 0, 0, rg_unused, dir_unused
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_unused, path_unused, K_LINEAR, 0x48000000, 0x800000, 0, 0, rg_unused, dir_unused
    .long   0, 0, 0, 0, 0, 0, 0

str_title:      .asciz  "KN7000 ROM DUMPER"
str_target:     .asciz  "To the SD card, folder C:\KN7DUMP; file names as in MAME's kn7000 driver."
str_target_nf:  .asciz  "To the SD card's root folder, 8.3 names; DUMPLIST.TXT gives MAME's names."
str_f_prog:     .asciz  "PROGRAM "
str_f_table:    .asciz  "  TABLE "
str_f_rel:      .asciz  "  release "
str_c_rom:      .asciz  "ROM "
str_c_of:       .asciz  "/10: "
str_c_read:     .asciz  "Reading "
str_pct:        .asciz  "%  "
str_l_wait:     .asciz  "[    ] "
str_l_ok:       .asciz  "[ OK ] "
str_l_bad:      .asciz  "[SUM?] "
str_l_crc:      .asciz  "CRC32 "
str_l_err:      .asciz  "[FAIL] "
str_l_ferr:     .asciz  "error "
str_l_skip:     .asciz  "[SKIP] "
str_m_skip:     .asciz  "not dumped (left out of this build)"
str_m_options:  .asciz  "  build options 0x"
str_lfn_off:    .asciz  "Long names off in this build; DUMPLIST.TXT maps the 8.3 names to MAME's."
str_n_unknown:  .asciz  "unknown"
str_m_found:    .asciz  "loader found: 0x"
str_m_found2:   .asciz  " (1 file code, 2 file tables, 4 sectors, 8 folders, 0x10 build, 0x20 table build, 0x40 clock)  fmm tables 0x"
str_m_found3:   .asciz  "  SD open 0x"
str_m_error:    .asciz  "NOT WRITTEN, error 0x"
str_done:       .asciz  "Done: every ROM is in C:\KN7DUMP. DUMPLIST.TXT has sizes and checksums."
str_done_nf:    .asciz  "Done: the files are in the SD card's root folder, with DUMPLIST.TXT."
str_done_err:   .asciz  "Done, but "
str_done_err2:  .asciz  " ROM file(s) could not be written: [FAIL] above."
str_f_close:    .asciz  ")"
str_leave:      .asciz  "In 15 s the firmware asks 'Continue Next?': NO leaves, YES dumps again."
str_f_code:     .asciz  " (code 0x"
str_err_open:   .asciz  "DUMPLIST.TXT could not be created"
str_err_write:  .asciz  "DUMPLIST.TXT could not be written"
str_lfn_ok:     .asciz  "Long file names written: a PC shows MAME's names."
str_lfn_geom:   .asciz  "Long names skipped: unexpected card layout; 8.3 names, see DUMPLIST.TXT."
str_lfn_io:     .asciz  "Long names skipped: a card sector access failed; see DUMPLIST.TXT."
str_lfn_nofolder: .asciz "Long names skipped: KN7DUMP not found in the root; see DUMPLIST.TXT."
str_lfn_big:    .asciz  "Long names skipped: the folder is too big; empty it; see DUMPLIST.TXT."
str_lfn_foreign: .asciz "Long names skipped: KN7DUMP holds other files; see DUMPLIST.TXT."
str_lfn_noraw:  .asciz  "Long names skipped: no SD sector access found; 8.3 names, see DUMPLIST.TXT."
str_lfn_notinfolder: .asciz "Long names skipped: the files are not in KN7DUMP; see DUMPLIST.TXT."
str_lfn_verify: .asciz  "Long names: the folder did not read back as written!"
mode_wb:        .asciz  "wb"
str_folder_c:   .asciz  "C:\KN7DUMP"
path_manifest:  .asciz  "KN7DUMP\DUMPLIST.TXT"
dir_folder:     .ascii  "KN7DUMP    "
dir_manifest:   .ascii  "DUMPLISTTXT"
    .byte   0
str_m_head:     .asciz  "KN7000 ROM DUMPER (KN7APP.BIN)  PROGRAM "
str_m_table:    .asciz  "  TABLE "
str_m_release:  .asciz  "  release byte 0x"
str_m_crc:      .asciz  " crc32 "
str_m_sum:      .asciz  " bytesum "
str_m_golden:   .asciz  " expected "
str_m_ok:       .asciz  " ok"
str_m_bad:      .asciz  " MISMATCH"
str_sp:         .asciz  "  "
str_n_prog:     .asciz  "kn7000_program"
str_n_table:    .asciz  "kn7000_table"
str_n_even:     .asciz  "_even"
str_n_odd:      .asciz  "_odd"
str_n_sp7001:   .asciz  "_sp7001"
str_n_v:        .asciz  "_v"
str_n_b:        .asciz  "_b"
str_n_ic17:     .asciz  ".ic17"
str_n_ic16:     .asciz  ".ic16"
nm_ic21:        .asciz  "custom_data.ic21"
nm_ic203:       .asciz  "c3cbqd000002.ic203"
nm_ic204:       .asciz  "c3cbqd000001.ic204"
nm_ic207:       .asciz  "c3cbqd000004.ic207"
nm_ic208:       .asciz  "c3cbqd000003.ic208"
nm_ic19:        .asciz  "c3cbmd000098.ic19"
path_prog_even: .asciz  "KN7DUMP\PRGEVEN.BIN"
path_prog_odd:  .asciz  "KN7DUMP\PRGODD.BIN"
path_tbl_even:  .asciz  "KN7DUMP\TBLEVEN.BIN"
path_tbl_odd:   .asciz  "KN7DUMP\TBLODD.BIN"
path_ic21:      .asciz  "KN7DUMP\IC21.BIN"
path_ic203:     .asciz  "KN7DUMP\IC203.BIN"
path_ic204:     .asciz  "KN7DUMP\IC204.BIN"
path_ic207:     .asciz  "KN7DUMP\IC207.BIN"
path_ic208:     .asciz  "KN7DUMP\IC208.BIN"
path_ic19:      .asciz  "KN7DUMP\IC19.BIN"
dir_prog_even:  .ascii  "PRGEVEN BIN"
dir_prog_odd:   .ascii  "PRGODD  BIN"
dir_tbl_even:   .ascii  "TBLEVEN BIN"
dir_tbl_odd:    .ascii  "TBLODD  BIN"
dir_ic21:       .ascii  "IC21    BIN"
dir_ic203:      .ascii  "IC203   BIN"
dir_ic204:      .ascii  "IC204   BIN"
dir_ic207:      .ascii  "IC207   BIN"
dir_ic208:      .ascii  "IC208   BIN"
dir_ic19:       .ascii  "IC19    BIN"
rg_prog_even:   .asciz  "CPU 0x48400000-0x487FFFFF, bytes 0-1 of each 32-bit word"
rg_prog_odd:    .asciz  "CPU 0x48400000-0x487FFFFF, bytes 2-3 of each 32-bit word"
rg_tbl_even:    .asciz  "CPU 0x48000000-0x483FFFFF, bytes 0-1 of each 32-bit word"
rg_tbl_odd:     .asciz  "CPU 0x48000000-0x483FFFFF, bytes 2-3 of each 32-bit word"
rg_ic21:        .asciz  "CPU 0x96800000-0x969FFFFF (custom data flash, whole chip)"
rg_ic203:       .asciz  "main TG 0x98050000 wave port, select 0, banks 0x000-0x1FF"
rg_ic204:       .asciz  "main TG 0x98050000 wave port, select 1, banks 0x000-0x1FF"
rg_ic207:       .asciz  "sub TG 0x98040000 wave port, select 0, banks 0x000-0x1FF"
rg_ic208:       .asciz  "sub TG 0x98040000 wave port, select 1, banks 0x000-0x1FF"
rg_ic19:        .asciz  "CPU 0x57800000-0x57FFFFFF (picture flash; window unconfirmed)"

nm_unused:      .asciz  "unused"
path_unused:    .asciz  "KN7DUMP\UNUSED.BIN"
dir_unused:     .ascii  "UNUSED  BIN"
rg_unused:      .asciz  "(an unused survey slot)"
nm_s40000000:   .asciz  "survey_40000000.bin"
path_s40000000: .asciz  "KN7DUMP\R4000000.BIN"
dir_s40000000:  .ascii  "R4000000BIN"
rg_s40000000:   .asciz  "CPU 0x40000000-0x407FFFFF, CS0: rhythm probes 0x40010000, 0x40610000"
nm_s40800000:   .asciz  "survey_40800000.bin"
path_s40800000: .asciz  "KN7DUMP\R4080000.BIN"
dir_s40800000:  .ascii  "R4080000BIN"
rg_s40800000:   .asciz  "CPU 0x40800000-0x40FFFFFF, CS0: rhythm probe 0x40810000"
nm_s54000000:   .asciz  "survey_54000000.bin"
path_s54000000: .asciz  "KN7DUMP\R5400000.BIN"
dir_s54000000:  .ascii  "R5400000BIN"
rg_s54000000:   .asciz  "CPU 0x54000000-0x547FFFFF, CS5"
nm_s54800000:   .asciz  "survey_54800000.bin"
path_s54800000: .asciz  "KN7DUMP\R5480000.BIN"
dir_s54800000:  .ascii  "R5480000BIN"
rg_s54800000:   .asciz  "CPU 0x54800000-0x54FFFFFF, CS5: rhythm fallback 0x54E00000"
nm_s55000000:   .asciz  "survey_55000000.bin"
path_s55000000: .asciz  "KN7DUMP\R5500000.BIN"
dir_s55000000:  .ascii  "R5500000BIN"
rg_s55000000:   .asciz  "CPU 0x55000000-0x557FFFFF, CS5"
nm_s55800000:   .asciz  "survey_55800000.bin"
path_s55800000: .asciz  "KN7DUMP\R5580000.BIN"
dir_s55800000:  .ascii  "R5580000BIN"
rg_s55800000:   .asciz  "CPU 0x55800000-0x55FFFFFF, CS5"
