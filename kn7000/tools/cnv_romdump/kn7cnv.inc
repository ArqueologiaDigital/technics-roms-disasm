# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# kn7cnv.inc -- the contract between KN7LOAD.CNV (the floppy loader, loader.s) and the applications it
# loads from the SD card (README.md). Everything lives in the style converter area: the firmware
# zeroes 0x30000 bytes at 0x502B8000, reads the .CNV there and calls its first byte, on its main task.
#
#   0x502B8000  the loader (code, font, signatures)
#   0x502B9D00  the loader's variables
#   0x502B9E00  the service table (below), filled by the loader before the application runs
#   0x502BA000  the application: KN7APP.BIN from the SD card's root folder, linked to run here, then
#               whatever RAM it uses up to 0x502E8000 (zeroed by the loader before each load)

.equ CNV_BASE,      0x502B8000
.equ CNV_END,       0x502E8000
.equ LOADER_VARS,   0x502B9D00
.equ SVC,           0x502B9E00
.equ APP_BASE,      0x502BA000
.equ APP_MAX,       CNV_END-APP_BASE
.equ MAILBOX,       0x5031BC00      # converter mailbox: byte 0 = request, its argument from byte 1
.equ RQ_PARK,       1               # "copy 4 bytes, call me again": parks the firmware, no repaint
.equ RQ_TEXT,       5               # "show this text, call me again" (the firmware repaints)
.equ RQ_END,        0xFE            # end of the conversion

# ---- the service table at SVC ------------------------------------------------------------------
# Firmware routines (found by the loader in the program flash, whatever the build) are entered with
# `calls (aN)`. All of them may change d0, d1, a0, a1 and store into 4..0x10(sp) of the caller's frame.
.equ SV_MAGIC,      0x00            # "KN7S"
.equ SV_ABI,        0x04            # LOADER_ABI
.equ SV_SETEXT,     0x08            # SetExtMode(d0 = 1): the fmm file layer -> SD card
.equ SV_RESETEXT,   0x0C            # ResetExtMode: -> floppy (as the firmware expects between calls)
.equ SV_OPEN,       0x10            # fmmopen(a0 = name, a1 = mode "rb"/"wb") -> d0 (16-bit, < 0 = error)
.equ SV_CLOSE,      0x14            # fmmclose
.equ SV_READ,       0x18            # fmmread(a0 = buffer, d0 = bytes) -> d0 = bytes read
.equ SV_WRITE,      0x1C            # fmmwrite(a0 = buffer, d0 = bytes) -> d0 = bytes written
.equ SV_RAWREAD,    0x20            # SD sector read(d0 = card sector, d1 = count <= 0x80, a1 = buffer) -> d0 = 0
.equ SV_RAWWRITE,   0x24            # SD sector write, same arguments
.equ SV_MKDIR,      0x28            # sdfmmkdir(a0 = "C:\FOLDER") -> d0 = 0, or -3 (exists or failed)
.equ SV_SETPATH,    0x2C            # sdfmpath(a0 = folder, or 0 = none): fmmopen's base folder on SD
.equ SV_PATHBUF,    0x30            # that folder's 0x80-byte buffer (the loader empties it around each call)
.equ SV_DRIVE,      0x34            # address of the fmm drive byte
.equ SV_BUILD,      0x38            # PROGRAM build number (SOFT VERSION)
.equ SV_TBUILD,     0x3C            # TABLE build number
.equ SV_RELEASE,    0x40            # release byte at 0x4840000F (0x16 = v1.6, 0xFF on SP7001)
.equ SV_DRAWTEXT,   0x44            # DrawText(a0 = text, d0 = x, d1 = y) -> d0 = x after; SV_FG on SV_BG, SV_SCALE
.equ SV_FILLRECT,   0x48            # FillRect(d0 = x, d1 = y, a0 = width, a1 = height) in SV_FG
.equ SV_FG,         0x4C            # RGB565
.equ SV_BG,         0x50
.equ SV_SCALE,      0x54            # 1 or 2
.equ SV_CALLS,      0x58            # calls since the application was loaded
.equ SV_APPSIZE,    0x5C            # bytes loaded
.equ LOADER_ABI,    1

# ---- the application header, at APP_BASE ---------------------------------------------------------
.equ AH_MAGIC,      0x00            # "KN7A"
.equ AH_ABI,        0x04            # LOADER_ABI it was built for
.equ AH_SIZE,       0x08            # bytes in the file
.equ AH_ENTRY,      0x0C            # entered with `calls` on every converter call; sets the request
.equ AH_CRC,        0x10            # CRC-32 of the file from AH_NAME to its end (mkapp.py fills it)
.equ AH_BASE,       0x14            # APP_BASE, as linked
.equ AH_NAME,       0x20            # 32 bytes, NUL-padded: shown by the loader

# ---- the LCD: 640 x 240, RGB565 ------------------------------------------------------------------
.equ FB,            0x9CE00000
.equ FB_STRIDE,     1280
