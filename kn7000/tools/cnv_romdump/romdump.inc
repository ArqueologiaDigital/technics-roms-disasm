# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# romdump.inc -- constants of the ROM dumper application (romdump.s, KN7APP.BIN; README.md). Its code
# is at APP_BASE; everything below is in the application part of the style converter area
# (kn7cnv.inc), which the loader zeroes before loading it.

.equ BUF,           0x502C0000      # 32 KB: one chunk of the file being written; the folder's cluster
.equ CHUNK,         0x8000
.equ BUF2,          0x502C8000      # 32 KB: the folder's cluster as rewritten with long names
.equ VARS,          0x502E0000
.equ CRCTAB,        0x502E1000      # 1 KB: CRC-32 table
.equ STR,           0x502E2000      # 256 bytes: a line being formatted
.equ NAMES,         0x502E2100      # 4 x 64 bytes: program/table ROM names built from the build numbers
.equ SECBUF,        0x502E3000      # 512 bytes: one SD sector
.equ SHORTS,        0x502E3200      # MAX_ROMS+1 x 32 bytes: the files' 8.3 directory entries, as found
.equ TEXT,          0x502E4000      # 4 KB: manifest text

# ---- variables ---------------------------------------------------------------------------------
.equ V_STATE,       VARS+0x00       # 0 = first call, 1 = dumping, 2 = finishing, 3 = done
.equ V_ROM,         VARS+0x04       # index of the ROM being dumped
.equ V_POS,         VARS+0x08       # bytes of it written so far
.equ V_CRC,         VARS+0x0C       # running CRC-32 (pre-inverted)
.equ V_SUM,         VARS+0x10       # running byte sum (the wave ROM test's checksum)
.equ V_ERR,         VARS+0x14       # last error code
.equ V_FAIL,        VARS+0x18       # DUMPLIST.TXT's failure message (pointer), or 0
.equ V_TEXTLEN,     VARS+0x1C
.equ V_FILEOPEN,    VARS+0x20       # 1 while a dump file is open
.equ V_LFN,         VARS+0x24       # long-name pass: 0 not run, 1 done, 2 skipped
.equ V_LFNMSG,      VARS+0x28       # its message
.equ V_PART,        VARS+0x2C       # card geometry, from the MBR and boot sector
.equ V_SPC,         VARS+0x30
.equ V_ROOTLBA,     VARS+0x34
.equ V_ROOTSECS,    VARS+0x38
.equ V_DATALBA,     VARS+0x3C
.equ V_DIRLBA,      VARS+0x40       # the dump folder's first cluster
.equ V_CLBYTES,     VARS+0x44       # bytes per cluster
.equ V_OUT,         VARS+0x48       # long-name pass: write pointer into BUF2
.equ V_HOLD,        VARS+0x4C       # when the result appeared (kernel ms), or calls since then
.equ V_NOFOLDER,    VARS+0x50       # 1: files are written without the KN7DUMP folder (current folder)
.equ V_FAILS,       VARS+0x54       # ROMs whose file could not be written
.equ V_TABLE,       VARS+0x58       # the ROM table in use: RomTable, SurveyTable (OPT_SURVEY) or Survey2Table
.equ V_NROMS,       VARS+0x5C       # its number of entries: NUM_ROMS, or NUM_SURVEY2 (OPT_SURVEY2)
.equ V_TITLE,       VARS+0x60       # the screen title: str_title, or str_title_dsp (OPT_DSP, OPT_DSPMEM)
.equ V_LASTHIT,     VARS+0x64       # CountSig: the first hit
# the effects DSP's host port, through the firmware's own routines (romdump_dsp.s DspFind); 0 = not found
.equ V_DSPOK,       VARS+0x68       # 1 when every routine below was found and cross-checked
.equ V_DFOUND,      VARS+0x6C       # what DspFind got: DF_* bits
.equ V_DWAIT,       VARS+0x70       # the handshake wait (calls entry; only its flag operands are used)
.equ V_DREGWR,      VARS+0x74       # register write: d0 = IOP register, d1 = high half, (0x10, sp) = low half
.equ V_DREGRD,      VARS+0x78       # register read: d0 = IOP register -> d0 = (high << 16) + sign-extended low
.equ V_DIDXWR,      VARS+0x7C       # the index write (0x98000000), guarded by the dead flag: d0 = index
.equ V_DDATARD,     VARS+0x80       # one 16-bit data-port read (0x9C000000), guarded -> d0 (-1 when dead)
.equ V_DDEAD,       VARS+0x84       # the firmware's "DSP dead" flag (byte; 941 0x500066CC, 893 0x500066D8)
.equ V_DDOWN,       VARS+0x88       # its "kernel downloaded" flag (byte; 941 0x500066CD, 893 0x500066D9)
.equ V_DSTAT,       VARS+0x8C       # the current DSP file's status bits (DS_*)
.equ V_DPOLLS,      VARS+0x90       # phase 2: FIFO status polls, in all and the most for one word
.equ V_DPOLLMAX,    VARS+0x94
.equ V_DWORDS,      VARS+0x98       # phase 2: words read
.equ DF_WAIT,       1               # DspFind: the handshake wait found once
.equ DF_REGS,       2               #   the register read/write block found once
.equ DF_IDX,        4               #   its index-write call leads to a calls entry of the right frame
.equ DF_DATA,       8               #   its data-read call does too, and tests the same dead flag
.equ DS_FOUND,      1               # DSP file status: the routines were found (else nothing was read)
.equ DS_DEADBEFORE, 2               #   the firmware's dead flag was set before: nothing was read
.equ DS_DEADDURING, 4               #   it became set during the reads: the rest is left 0
.equ DS_NOCLOCK,    8               #   no millisecond counter: the time stamps are 0, the spacing a delay loop
.equ DS_WAITOUT,    0x10            #   a wait for the millisecond counter timed out
.equ DS_PRECHECK,   0x20            #   phase 2: a check before the readback failed, nothing was written
.equ DS_FSTIMEOUT,  0x40            #   phase 2: EPB0 stayed empty (DMAC0 FS) for too long: stopped
.equ DS_RESTORED,   0x80            #   phase 2: DMAC0, IIEP0, IMEP0, CEP0 written back
.equ DS_SKIPPED,    0x100           #   pass 8: an earlier block stopped (V_RSTOP), so this chunk read nothing
.equ HOLD_MS,       15000           # show the result this long before ending the conversion ...
.equ HOLD_CALLS,    23000           # ... or this many calls when the loader found no ms counter, each made
.equ HOLD_SPIN,     10000           # to last about 0.65 ms by a delay loop (loader.s HOLD_SPIN)
.equ V_RESULTS,     VARS+0x100      # per ROM: +0 CRC-32, +4 byte sum, +8 bytes written, +12 status
.equ ST_PENDING,    0
.equ ST_OK,         1
.equ ST_FAIL,       2               # written, but the wave ROM's byte sum is not the firmware's
.equ ST_ERROR,      3               # the file could not be created or written (error in +8)
.equ ST_SKIP,       4               # not dumped: this build leaves it out (APP_OPTIONS)

# ---- build options: the word after the header, set by mkapp.py --options (0 = the full dumper) ----
.equ APP_OPTIONS,   APP_BASE+0x40
.equ OPT_SKIP,      0xFFFF          # bit n set: leave ROM n of the table out (bits 10-15 only matter to a
                                    # table longer than 10 entries, so MAX_ROMS is 16)
.equ OPT_NOFOLDER,  0x10000         # no sdfmmkdir: the files go to the current folder (the root)
.equ OPT_NOLFN,     0x20000         # no long-name pass: no raw SD sector access at all
.equ OPT_SURVEY,    0x40000         # read SurveyTable's windows instead of RomTable's ROMs (the rhythm ROM search)
.equ OPT_SURVEY2,   0x80000         # read Survey2Table's 14 windows instead (takes precedence over OPT_SURVEY)
.equ OPT_DSP,       0x100000        # the DSP probe, phase 1 (DspTable: read-only, IOP registers and host side)
.equ OPT_DSPMEM,    0x200000        # the DSP probe, phase 2 (DspMemTable: DSP memory through EPB0 DMA)
.equ OPT_DSPRATE,   0x400000        # the DSP probe, pass 8 (DspRateTable: the frame rate); only in a build assembled
                                    # with -D DSPRATE (romdump_dsprate.s), which the other builds leave out
.equ OPT_CPUTIME,   0x800000        # pass 9, the CPU timing probe (CpuTimeTable); only in a build assembled with
                                    # -D CPUTIME (romdump_cputime.s), which the other builds leave out
.equ OPTS_SAFE,     0x303E0         # the SAFE build: program, table and IC21 only, ordinary files only
.equ OPTS_PICTURE,  0x301FF         # the IC19 build: the picture flash window only, ordinary files only
.equ OPTS_WAVE,     0x3021F         # the WAVE build: the four wave ROMs only, ordinary files only
.equ OPTS_SURVEY,   0x703C0         # the SURVEY build: SurveyTable's six windows, ordinary files only
.equ OPTS_SURVEY2,  0xB0000         # the SURVEY2 build: Survey2Table's 14 windows, ordinary files only
.equ OPTS_DSPPROBE, 0x130000        # the DSP probe, phase 1, ordinary files only
.equ OPTS_DSPMEM,   0x230000        # the DSP probe, phase 2, ordinary files only
.equ OPTS_DSPRATE,  0x430000        # the DSP probe, pass 8 (frame rate), ordinary files only
.equ OPTS_CPUTIME,  0x830000        # pass 9, the CPU timing probe, ordinary files only

# ---- ROM table records (RomTable in romdump.s) ---------------------------------------------------
.equ R_NAME,        0               # MAME name (pointer)
.equ R_PATH,        4               # the file on the card, "KN7DUMP\XXXXXXXX.XXX" (pointer)
.equ R_KIND,        8               # how it is read, see below
.equ R_BASE,        12              # CPU address, or the tone generator port
.equ R_LEN,         16              # bytes in the file
.equ R_SEL,         20              # wave: chip select bit (P+8 bit 0)
.equ R_GOLDEN,      24              # wave: the firmware's expected byte sum (0 = none)
.equ R_RANGE,       28              # text: what is read (pointer)
.equ R_83,          32              # the 11-character directory name, "PRGEVEN BIN" (pointer)
.equ R_SHIFT,       6               # records are 64 bytes
.equ K_LANE0,       0               # bytes 0-1 of every 32-bit word (the .ic17 half of a flash pair)
.equ K_LANE1,       1               # bytes 2-3 (the .ic16 half)
.equ K_LINEAR,      2               # plain bytes, read 16 bits at a time
.equ K_WAVE,        3               # a wave ROM through the tone generator's test latches
.equ K_DSPHOST,     4               # DSP probe: the host side (INTC GxICR block, the firmware's DSP variables)
.equ K_DSPIOP,      5               # DSP probe: one snapshot of the IOP registers, twice
.equ K_DSPTIME,     6               # DSP probe: timers, DMA status and SPORT DMA counts over time
.equ K_DSPPM,       7               # DSP probe phase 2: program memory through EPB0
.equ K_DSPDM,       8               # DSP probe phase 2: data memory through EPB0, and the SPORT TCBs
.equ K_DSPRATE,     9               # DSP probe pass 8: the frame rate, four 32 KB chunks (romdump_dsprate.s)
.equ K_CPUTIME,     10              # pass 9: CPU and bus timing, CT_CHUNKS 32 KB chunks (romdump_cputime.s)
.equ NUM_ROMS,      10              # entries in RomTable and SurveyTable
.equ NUM_SURVEY2,   14              # entries in Survey2Table
.equ NUM_DSP,       3               # entries in DspTable
.equ NUM_DSPMEM,    2               # entries in DspMemTable
.equ NUM_DSPRATE,   1               # entries in DspRateTable
.equ NUM_CPUTIME,   1               # entries in CpuTimeTable
.equ MAX_ROMS,      16              # the most any table may have (16 skip bits; V_RESULTS, SHORTS sized for it)
                                    # the files: V_NROMS dump files, then DUMPLIST.TXT

# ---- colours (RGB565) ----------------------------------------------------------------------------
.equ C_BG,          0x0010
.equ C_TEXT,        0xFFFF
.equ C_DIM,         0x8410
.equ C_GOOD,        0x07E0
.equ C_BAD,         0xF800
.equ C_WARN,        0xFFE0
.equ C_BAR,         0x041F
.equ C_FRAME,       0xC618

# ---- wave ROM test latches (941 MainWaveRomTestFunc 0x484A2E3A / read loop 0x484839A1) ------------
.equ WAVE_MAIN,     0x98050000      # IC203 (select 0) and IC204 (select 1), per the firmware's test screen
.equ WAVE_SUB,      0x98040000      # IC207 and IC208
.equ WAVE_BANK,     6               # 0x8000 | bank (bank = file offset >> 15)
.equ WAVE_ADDR,     8               # 0x8000 | (file offset & 0x7FFE) | select
.equ WAVE_DATA,     0xA             # 16 bits: file[offset] = low byte, file[offset + 1] = high byte
.equ SETTLE_LOOPS,  160000          # the firmware sleeps one tick (1 ms, the kernel's 1 kHz tick) after entering
                                    # and leaving test mode; this is about 10 ms in MAME, margin for a faster CPU
