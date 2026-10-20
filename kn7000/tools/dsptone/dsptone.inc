# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# dsptone.inc -- DSPTONE's memory map and constants (dsptone.s; README.md). DSPTONE is an application of
# KN7LOAD.CNV (../cnv_romdump/kn7cnv.inc, included first), started from the program menu (../kn7menu) or as
# the root's KN7APP.BIN. Everything it writes in the main CPU's memory lies in the application area
# 0x502BA000-0x502E7EFF, which the loader (or the menu's trampoline) zeroes before it starts the program;
# guard.py checks this map at every build.

# ---- in the application area ---------------------------------------------------------------------
.equ IMAGE_MAX,     0x502DC000      # the image (header, code, font, the DSP program, the PCM) ends below
.equ M_VARS,        0x502DC000      # 1 KB: variables (V_* below)
.equ LINES,         0x502DC400      # NLINES text lines of LINE_LEN bytes: what the screen shows
.equ LINE_LEN,      80
.equ NLINES,        12
.equ DECBUF,        0x502DC800      # 32 bytes: PutDec's digits
.equ RBBUF,         0x502DD000      # 1 KB: words read back from the DSP (6 bytes a PM word, 4 a DM word)
.equ AREA_END,      0x502DD400      # the end of what DSPTONE uses (below the launch block, kn7cnv.inc LB_ADDR)

# ---- variables, at M_VARS ------------------------------------------------------------------------
.equ V_STATE,       M_VARS+0x00     # ST_* below
.equ V_CALLS,       M_VARS+0x04     # converter calls so far
.equ V_PANEL,       M_VARS+0x08     # the firmware's switch bitmaps (CPR; CPL/CPC at +0x30), or 0
.equ V_MS,          M_VARS+0x0C     # the kernel's millisecond counter (SV_MSCOUNT), or 0
.equ V_TMP,         M_VARS+0x10     # CountFlash: the first hit
.equ V_BTN,         M_VARS+0x14     # the buttons down at the last call (B_* bits)
.equ V_PRESSED,     M_VARS+0x18     # the buttons that went down at this call
.equ V_REDRAW,      M_VARS+0x1C     # 1: draw the whole screen at the end of this call
.equ V_DIRTY,       M_VARS+0x20     # bit k: line k changed, draw it
.equ V_LCDSUM,      M_VARS+0x24     # the sampled LCD checksum after our last drawing
.equ V_FG,          M_VARS+0x28     # drawing colours (RGB565) and text scale
.equ V_BG,          M_VARS+0x2C
.equ V_SCALE,       M_VARS+0x30
.equ V_EXIT_T0,     M_VARS+0x34     # when EXIT went down (ms | 1), 0 = up
.equ V_EXITARMED,   M_VARS+0x38     # 1 once EXIT has been held QUIT_MS
.equ V_LEAVEREQ,    M_VARS+0x3C     # 1 once the button that ends the program went down
.equ V_FAILT0,      M_VARS+0x40     # when the failure screen came up
.equ V_NREDRAW,     M_VARS+0x44     # full redraws because the LCD no longer showed ours
# the firmware's DSP host-port routines (DspFind; ../cnv_romdump/romdump_dsp.s), `calls` entries
.equ V_DFOUND,      M_VARS+0x50     # DF_* bits
.equ V_DSPOK,       M_VARS+0x54     # 1 when all of them were found and agree
.equ V_DWAIT,       M_VARS+0x58     # the handshake wait (where the flags are read from)
.equ V_DREGWR,      M_VARS+0x5C     # 2x16 register write (d0 = register, d1 = high half, (0x10, sp) = low half)
.equ V_DREGRD,      M_VARS+0x60     # 2x16 register read (d0 = register)
.equ V_DIDXWR,      M_VARS+0x64     # guarded index write (d0 = index)
.equ V_DDATARD,     M_VARS+0x68     # guarded data-port read
.equ V_DDATAWR,     M_VARS+0x6C     # guarded data-port write (d0 = 0x9C4, the data port; d1 = 16 bits)
.equ V_DDEAD,       M_VARS+0x70     # the firmware's "DSP dead" flag (byte)
.equ V_DDOWN,       M_VARS+0x74     # its "kernel downloaded" flag (byte)
# what was found on the DSP, and what was done
.equ V_SYSCON,      M_VARS+0x80
.equ V_DMAC0,       M_VARS+0x84     # DMAC0, IIEP0, IMEP0, CEP0, as found (put back at the end)
.equ V_IIEP0,       M_VARS+0x88
.equ V_IMEP0,       M_VARS+0x8C
.equ V_CEP0,        M_VARS+0x90
.equ V_DMASTAT,     M_VARS+0x94
.equ V_SLOT_HI,     M_VARS+0x98     # the unit-0 CALL slot as found: bits 47-32,
.equ V_SLOT_LO,     M_VARS+0x9C     #   bits 31-0
.equ V_RBFAIL,      M_VARS+0xA0     # the last readback stopped early (FS never showed data, or the dead flag)
.equ V_HOOKED,      M_VARS+0xA4     # 1 while the slot points at our program
.equ V_MODE,        M_VARS+0xA8     # what MSGR6 was last set to
.equ V_HB,          M_VARS+0xAC     # the heartbeat (MSGR7) last read, and when
.equ V_HBMS,        M_VARS+0xB0
.equ V_HB0,         M_VARS+0xB4     # ... and at the start of the current rate window
.equ V_HB0MS,       M_VARS+0xB8
.equ V_RATE,        M_VARS+0xBC     # frames per second, over the last window (0 = not yet)
.equ V_PCMDONE,     M_VARS+0xC0     # samples uploaded and copied
.equ V_PCMOK,       M_VARS+0xC4     # 1 once the whole PCM is in SDRAM (PCMLEN read back)
.equ V_PCMLEN,      M_VARS+0xC8     # PCMLEN as read back
.equ V_WAITS,       M_VARS+0xCC     # MSGR4 polls in the current upload call
.equ V_STALL,       M_VARS+0xD0     # calls in a row in which the DSP did not finish a copy
.equ V_RESTORED,    M_VARS+0xD4     # 1 restored and verified, 2 restore failed
.equ V_ERRS,        M_VARS+0xD8     # problems seen (shown)
.equ V_T0,          M_VARS+0xDC     # this call's start (ms)
.equ V_WINDOWS,     M_VARS+0xE0     # heartbeat rate windows completed
.equ V_RDSTEP,      M_VARS+0xE4     # the next step of a full redraw (1..RD_STEPS), 0 = none under way
.equ V_FINDSTEP,    M_VARS+0xE8     # DoFind: the signatures searched so far
.equ V_LINECOL,     M_VARS+0x100    # NLINES words: each line's colour
.equ V_CUR,         M_VARS+0x140    # the line being written
.equ V_SIGN,        M_VARS+0x180    # NSIGS words: DoFind's hit counts,
.equ V_SIGA,        M_VARS+0x190    #   and first hits
.equ NSIGS,         4

.equ ST_INIT,       0               # first call: the loader's table
.equ ST_FIND,       1               # the panel bitmaps and the firmware's DSP routines, by signature
.equ ST_CHECK,      2               # the DSP's state: flags, SYSCON, channel 8, the unit-0 slot (read back)
.equ ST_LOAD,       3               # our program, its table and variables into the DSP; read back and compared
.equ ST_HOOK,       4               # the unit-0 slot pointed at our program; read back
.equ ST_RUN,        5               # playing; the buttons choose sine, chirp, silence, stop
.equ ST_UPLOAD,     6               # the PCM into SDRAM, chunk by chunk, a bounded time per call
.equ ST_UNHOOK,     7               # the slot put back as found; read back
.equ ST_DONE,       8               # the result; LEAVE (or EXIT held) ends the conversion
.equ ST_FAIL,       9               # cannot go on: the reason stays on screen
.equ ST_END,        10              # answered 0xFE

.equ DF_WAIT,       1               # V_DFOUND bits
.equ DF_REGS,       2
.equ DF_IDX,        4
.equ DF_DATA,       8
.equ DF_WRITE,      0x10

.equ MODE_SILENT,   0               # MSGR6
.equ MODE_SINE,     1
.equ MODE_PCM,      2

# ---- DSP host-port constants (TRM Tables E-15, E-16; the firmware's own values) -------------------
.equ IOP_SYSCON,    0x00
.equ IOP_EPB0,      0x04
.equ IOP_DMAC0,     0x1C
.equ IOP_DMASTAT,   0x37
.equ IOP_IIEP0,     0x40
.equ IOP_IMEP0,     0x41
.equ IOP_CEP0,      0x42
.equ DMAC_UP_PM,    0xA1            # the firmware's PM upload: DEN | DTYPE | PMODE 10 (16 -> 48)
.equ DMAC_UP_DM,    0x41            # its DM upload: DEN | PMODE 01 (16 -> 32)
.equ DMAC_CLOSE,    0xA0            # what it writes after each block (DEN off)
.equ DMAC_RB_PM,    0xA5            # readback (pass 7): the same with TRAN
.equ DMAC_RB_DM,    0x45
.equ DMAC_FLSH,     0x2000
.equ DMAC_KEEP,     0x1FE4          # the bits put back: not DEN, CHEN, the read-only PS/FS, not FLSH
.equ DATA_PORT,     0x9C4           # the firmware's id of the data port 0x9C000000

# ---- limits (every loop is bounded) --------------------------------------------------------------
.equ FS_POLLS,      1000            # DMAC0 reads waiting for EPB0 to hold a word (readback)
.equ COPY_POLLS,    400             # MSGR4 reads waiting for the DSP to finish a copy, per chunk and call
.equ STALL_CALLS,   40              # calls in a row without a finished copy: the upload gives up
.equ UPLOAD_MS,     80              # upload work per converter call before the firmware gets the main task back
.equ HOLD_MS,       15000           # a failure stays on screen this long when no button can be read
.equ HOLD_CALLS,    300
.equ QUIT_MS,       1500            # hold EXIT this long to stop
.equ RATE_MS,       1000            # the heartbeat's rate window
.equ RQ_SHOW,       5               # the request answered on every call: show the text, call again

# ---- the buttons, as B_* bit numbers (ButtonTab) -------------------------------------------------
.equ B_R1,          0               # LCDR 1: SINE
.equ B_R2,          1               # LCDR 2: CHIRP
.equ B_R3,          2               # LCDR 3: MUTE
.equ B_R4,          3               # LCDR 4: LEAVE (after the restore, or on the failure screen)
.equ B_R5,          4               # LCDR 5: STOP (restore the firmware's effect)
.equ B_EXIT,        5               # EXIT, held QUIT_MS: STOP, then LEAVE
.equ NBUTTONS,      6

# ---- the screen ----------------------------------------------------------------------------------
.equ TITLE_H,       28
.equ ROW_H,         42              # the right buttons' rows, from TITLE_H, as the firmware lays them out
.equ TEXT_X,        8
.equ TEXT_Y,        34
.equ TEXT_DYL,      15              # line spacing
.equ TEXT_W,        504             # the text's width (63 characters); the labels after it
.equ LINE_CHARS,    63
.equ TITLE2_X,      640-8-16*8      # the title bar's right-hand text (16 characters)
.equ LABEL_X,       520
.equ LABEL_W,       116
.equ MARK_DY,       (ROW_H-10)/2
.equ TEXT_DY,       (ROW_H-13)/2
.equ C_BG,          0x0000
.equ C_TITLE,       0x0010
.equ C_TEXT,        0xFFFF
.equ C_DIM,         0x8410
.equ C_LABEL,       0x3186
.equ C_STOP,        0x8000
.equ C_MARK,        0xFFFF
.equ C_BAD,         0xF800
.equ C_WARN,        0xFFE0
.equ C_OK,          0x07E0
.equ C_LINE,        0x4208
