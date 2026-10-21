# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# menu_data.s -- the program menu's constant data (included by menu.s, after the code).

# The buttons, in B_* order (menu.inc): the offset of the segment's byte from the CPR bitmap (CPL/CPC
# segments at +0x30) and the switch's bit (the MAME driver's :cpanel field masks, which follow the
# firmware's bitmaps: technics-anotherworld kn7000/probes/awpanelmap.lua).
ButtonTab:
    .byte   0x30, 0x02              # B_L1   LCDL 1           CPL_SEG0 SW1
    .byte   0x30, 0x08              #        LCDL 2           CPL_SEG0 SW3
    .byte   0x30, 0x20              #        LCDL 3           CPL_SEG0 SW5
    .byte   0x30, 0x01              #        LCDL 4           CPL_SEG0 SW0
    .byte   0x30, 0x04              # B_L5   LCDL 5           CPL_SEG0 SW2
    .byte   0x05, 0x10              # B_R1   LCDR 1           CPR_SEG5 SW4
    .byte   0x05, 0x20              # B_R2   LCDR 2           CPR_SEG5 SW5
    .byte   0x07, 0x01              #        LCDR 3           CPR_SEG7 SW0
    .byte   0x06, 0x01              # B_R4   LCDR 4           CPR_SEG6 SW0
    .byte   0x05, 0x01              # B_R5   LCDR 5           CPR_SEG5 SW0
    .byte   0x3B, 0x80              # B_EXIT EXIT             CPC_SEG11 SW7
    .byte   0x3B, 0x10              # B_PGUP PAGE UP          CPC_SEG11 SW4
    .byte   0x3B, 0x20              # B_PGDN PAGE DOWN        CPC_SEG11 SW5
    .byte   0x02, 0x01              # B_PREV PART SELECT LEFT CPR_SEG2 SW0
    .byte   0x01, 0x02              # B_NEXT PART SELECT RIGHT 1 CPR_SEG1 SW1

# The panel decoder's two sites (technics-anotherworld src/fwfind.s: 941 0x484AD22F and 0x484AD3DD).
    .align  2
sig_panel1:     # PanelFrameDecode: mov CPR, a0; mov a2, d0; and 0xc0, d0; beq; mov CPL, a0; ...
    .word   0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100, 0xf1, 0xd8, 0xf8, 0xe0, 0xc0, 0xc8, 0x08
    .word   0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100, 0xf1, 0xd8, 0xf8, 0xe0, 0x0f, 0xf1, 0x60
    .word   0xf0, 0x40, 0xf0, 0x5c, 0xFFFF
sig_panel2:     # the same choice in the next routine
    .word   0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100, 0xf8, 0xef, 0xc0, 0xc8, 0x08
    .word   0xfc, 0xdc, 0x100, 0x100, 0x100, 0x100, 0xf8, 0xb8, 0x10, 0x85, 0x0f, 0xf2, 0x0d
    .word   0xf1, 0x64, 0xFFFF

LfnOffs:        # where a long-name entry keeps its 13 UCS-2 characters
    .byte   1, 3, 5, 7, 9, 14, 16, 18, 20, 22, 24, 28, 30
name_app:       .ascii  "KN7APP  BIN"
name_manifest:  .ascii  "MANIFESTTXT"
key_name:       .asciz  "NAME"
key_icon:       .asciz  "ICON"
str_83punct:    .asciz  "!#$%&'()-@^_`{}~"

str_request:    .asciz  "KN7000 PROGRAM MENU"
str_title:      .asciz  "KN7000 PROGRAMS"
str_croot:      .asciz  "C:\"
str_page:       .asciz  "PAGE "
str_spaces3:    .asciz  "   "
str_programs:   .asciz  " PROGRAMS"
str_p_panel:    .asciz  "Looking for the panel's buttons in the firmware..."
str_p_root:     .asciz  "Reading the SD card's root folder..."
str_p_scan:     .asciz  "Looking into the folders: "
str_p_of:       .asciz  " of "
str_e_none:     .asciz  "No programs on this SD card."
str_e_how:      .asciz  "A program is a folder in the root with a KN7APP.BIN in it."
str_e_how2:     .asciz  "Its MANIFEST.TXT may give a NAME= and an ICON= (README)."
str_w_app:      .asciz  "\KN7APP.BIN  "
str_w_bytes:    .asciz  " bytes"
str_w_noman:    .asciz  "  (no MANIFEST.TXT)"
str_w_manbad:   .asciz  "  (MANIFEST.TXT unreadable)"
str_w_iconbad:  .asciz  "  (its icon file is unusable)"
str_l_pgup:     .asciz  "PAGE UP"
str_l_pgdn:     .asciz  "PAGE DOWN"
str_l_leave:    .asciz  "LEAVE"
str_l_run:      .asciz  "RUN"
str_l_wait:     .asciz  "WAIT"
str_m_reading:  .asciz  "Reading and checking KN7APP.BIN..."
str_ck_read:    .asciz  "Could not read KN7APP.BIN from the card: not started."
str_ck_size:    .asciz  "KN7APP.BIN is empty or over 188160 bytes: not started."
str_ck_header:  .asciz  "Not a KN7LOAD application (bad header): not started."
str_ck_abi:     .asciz  "Built for another loader version: not started."
str_ck_crc:     .asciz  "Damaged: its CRC-32 does not match. Not started."
str_f_head:     .asciz  "The program menu cannot go on:"
str_f_loader:   .asciz  "the floppy's KN7LOAD.CNV is not the loader this menu was built for."
str_f_noraw:    .asciz  "the loader found no SD sector read here: the folders cannot be listed."
str_f_nopanel:  .asciz  "the panel's button bitmaps are not found in this firmware."
str_f_io:       .asciz  "the SD card could not be read (is it in?)."
str_f_format:   .asciz  "the SD card is not FAT16 with 512-byte sectors (the instrument's format)."
str_f_exit:     .asciz  "Hold EXIT for 1.5 s and let go to leave; then 'Continue Next?'."
str_f_wait:     .asciz  "In 15 s the firmware asks 'Continue Next?': NO leaves."
str_t_failed:   .asciz  "PROGRAM NOT STARTED: YES = MENU"

    .align  4
.include "default_icon.inc"         # DefaultIcon: ICON_W x ICON_W RGB565 (gen_icons.py)
TrampImage:
.include "tramp_bin.inc"            # tramp.s, assembled at T_CODE (mkinc.py)
.include "font8x13.inc"             # ../cnv_romdump (gen_font.py: X11 misc-fixed 8x13, public domain)
