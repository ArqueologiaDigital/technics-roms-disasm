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
.equ TEXT,          0x502E1800      # 2 KB: manifest text
.equ STR,           0x502E2000      # 256 bytes: a line being formatted
.equ NAMES,         0x502E2100      # 4 x 64 bytes: program/table ROM names built from the build numbers
.equ SECBUF,        0x502E3000      # 512 bytes: one SD sector
.equ SHORTS,        0x502E3200      # 12 x 32 bytes: the files' 8.3 directory entries, as found

# ---- variables ---------------------------------------------------------------------------------
.equ V_STATE,       VARS+0x00       # 0 = first call, 1 = dumping, 2 = finishing, 3 = done, 4 = failed
.equ V_ROM,         VARS+0x04       # index of the ROM being dumped
.equ V_POS,         VARS+0x08       # bytes of it written so far
.equ V_CRC,         VARS+0x0C       # running CRC-32 (pre-inverted)
.equ V_SUM,         VARS+0x10       # running byte sum (the wave ROM test's checksum)
.equ V_ERR,         VARS+0x14       # last error code
.equ V_FAIL,        VARS+0x18       # pointer to the failure message
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
.equ V_RESULTS,     VARS+0x100      # per ROM: +0 CRC-32, +4 byte sum, +8 bytes written, +12 status
.equ ST_PENDING,    0
.equ ST_OK,         1
.equ ST_FAIL,       2

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
.equ NUM_ROMS,      10
.equ NUM_FILES,     11              # the ROMs and DUMPLIST.TXT

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
.equ SETTLE_LOOPS,  40000           # the firmware sleeps one tick after entering and leaving test mode
