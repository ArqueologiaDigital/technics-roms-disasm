# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# user_settings.inc -- record macros for the KN7000's user settings in the custom-data flash IC21
# (CPU 0x96800000) below the CUSTOM STYLE bank: the USER MIDI SETTING image at 0x96804000, the
# flash-test pattern at 0x96806000, FAVORITES at 0x96810000 and the HOME PAGE at 0x96811000.  The
# .MD, .FAV and .HMP files of the Initial Data Disk hold the same records.  Used by
# kn7000/src/ic21own/ (kn7asm syntax).  Format and evidence: kn7000/notes/ic21-own/README.md.
#
# Routine addresses are KN7000 program 941's (kn7000/src/program/), as in customdata.inc; names in
# CamelCase are the firmware's own reflection names or kn7000_manual.sym's.  [INFERENCE] marks a
# reading no traced code fixes.  All multi-byte fields are little-endian.

# The signature every one of these records starts with: 'JK ' and a NUL (the KN6000's is 'IK ').
# The boot check of the USER MIDI SETTING image (func_4C023EC9) compares its 3 bytes; the
# FAVORITES check (func_4849EDA9) and HpFlashCheck strcmp it against the ROM template; a file
# load checks it with func_4852B746.
.macro USR_SIGNATURE
	.ascii	"JK "
	.byte	0
.endm

# ---- the settings Initial Setting keeps: 0xAA4 bytes at 0x96804000, RAM copy 0x500D2B14 -------
# "User MIDI Settings, Help language, and Rhythm Custom etc. are not affected by Initial Setting"
# (help text HelpTextEn41_0, kn7000/src/table.s): the image holds the three USER MIDI SETTINGs (the
# .MD part, +0x000), the CUSTOM PANEL (+0x280) and system settings such as the language (+0xA70).
# func_4C024247 copies the whole image to RAM, func_4C024000(n) programs section n back after a change
# (FlashProgram128Words) and func_4C024030(n) re-reads it, through the case tables func_4C024000_Table /
# func_4C024030_Table (23 cases; probe kn7000/notes/ic21-own-probes/section_map.py):
#   n = 0 +0x000 0x10 header; 1 +0x010 0xC0 parameter ids; 2..4 +0x0D0 / +0x160 / +0x1F0 0x90 the
#   three settings; 5 language; 6 the six display times; 7 jump_insert + file_priority; 8 para_load1..4;
#   9 wall_home1..4; 10 contrast; 11 r_a94; 12 r_a96; 13 +0x280 0x750 / 14 +0x280 0x7F0 the CUSTOM PANEL;
#   15 data_protect; 16 +0x000 0x280 the .MD part whole; 17 cus_mem_mode; 18 acc_reverb_mask;
#   19 rsp_select; 20, 21 nothing; 22 panel_sw1 + panel_sw2.
# Callers, by n: LangSetFlashFunc 5, MainTimeFlashFunc 6, SetupFlashFunc 7, MainFlashFunc 8,
# MainWallSetFlashFunc 9, FN_TtContrast (func_4854E5C6) 10, func_4C021F7F 13, func_4C021FD9 14,
# MainDtPrtFlashFunc 15, func_484C44FC 16, CustomPanelFlashFunc 17, TestVideoOutFunc 19,
# SdcSetupFlashFunc 22.  No routine writes 11, 12 or 18.
# The CUSTOM PANEL is "a special Panel Memory in which you can store your favorite Panel Memory
# settings ... Even initializing the KN will not delete the Custom Panel" (HelpTextEn35_0):
# func_4C021903 stores the live panel state 0x84000020 there (func_4C021F7F 0x750 bytes,
# func_4C021FD9 0x7F0) or recalls it (func_4C021FB8, func_4C022012).  It is spelled with the
# PANEL MEMORY record macros PMR_* of panel_memory.inc: a 43-record list (0x750 bytes), then a
# second list of 0xA0 bytes, each ended by FF FF.
# At boot (func_4854AC28) func_4C023EC9 checks the signature; when it is missing it rebuilds the
# image from ROM: the .MD part (func_484C41B6), the CUSTOM PANEL (func_4C01ED5D: Str_empty_1431), the USR_SETUP
# defaults (26 halfwords func_4C023EC9_Table), and also resets the home page
# (HpFlashWriteDefaults) and the favorites (func_4849EDEB).
#
# The .MD part (= a .MD file, 640 bytes): a header whose six halfwords locate its sections.
# The code uses the same offsets as constants (func_484C41B6 copies the ROM default section by
# section: 0x10, 0xC0, 3 x 0x90); w04 is 0 in every image.
.macro UMD_HEADER w04, ids_off, ids_size, sets_off, set_size, set_count
	USR_SIGNATURE
	.word	\w04, \ids_off, \ids_size, \sets_off, \set_size, \set_count
.endm
# The parameter-id list: 44 ids, then 0xFFFFFF up to 0xC0 bytes.  func_484C4229 (load a setting
# into the live parameters, PutM3Em) and func_484C4414 (store, GetM3EmVal) walk it until 0xFFFFFF.
# An id whose bits 20-23 are 0x2, 0x8, 0x9, 0xB, 0xC, 0xD or 0xE (func_4C01BC28) is a part
# parameter and takes 32 bytes in a setting, one per part; any other takes one byte.
.macro UMD_PARAM id
	.long	\id
.endm
.macro UMD_PARAM_END
	.long	0xffffff
.endm
# A part parameter's 32 values, part n = the parameter id with n in its top byte (func_484C4229:
# id | n << 24).  [INFERENCE] n is the part's panel tag (kn7000/src/include/panel_memory.inc, PMR_PART):
# 0-15 PART1-16, 16-18 RIGHT1, RIGHT2, LEFT, 19-26 ACCOMP1-5, BASS, DRUMS1, DRUMS2, 27 CHORD.
.macro UMD_PARTS part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14, part15, part16, right1, right2, left, acc1, acc2, acc3, acc4, acc5, bass, drums1, drums2, chord, p28, p29, p30, p31
	.byte	\part1, \part2, \part3, \part4, \part5, \part6, \part7, \part8, \part9, \part10, \part11, \part12, \part13, \part14, \part15, \part16
	.byte	\right1, \right2, \left, \acc1, \acc2, \acc3, \acc4, \acc5, \bass, \drums1, \drums2, \chord, \p28, \p29, \p30, \p31
.endm
# A one-byte parameter's value; `id` (not emitted) names the parameter it belongs to.  The loader
# skips 0x8060 and 0x8061 (split mode, split point) when their value is 0xFF.
.macro UMD_VALUE id, value
	.byte	\value
.endm

# The 0x34 bytes after the CUSTOM PANEL (+0xA70..+0xAA3, RAM 0x500D3584..0x500D35B7): 26 halfwords
# of system settings, each section of func_4C024030 one field group.  Named after the firmware's
# routines that read the RAM copy (reflection names):
#   language       0x500D3584  CheckLanguage, AcLanguageTextProc (also AcIndexWideToggleFunc*)
#   to_save_reminder .. to_easy_setting  0x500D3586..0x500D3590  the DISPLAY TIME OUT screen (distim):
#                  DispTimeSetGridCheck maps grid rows 2..7 of its TIME column to these six, in the order
#                  of the grid's row captions "SAVE REMINDER", "'COMPLETED' MESSAGE", "ARE YOU SURE?",
#                  "ERROR MESSAGE", "SOUND/RHYTHM SELECT", "EASY SETTING" (Str_SAVE_REMINDER_COMPLETED_...);
#                  GetIntTimeID reads them, and the file-name procs (FmmFileNameFunc ...) the third
#   jump_insert    0x500D3592  JumpInsertFunc
#   file_priority  0x500D3594  FilePriorityFunc
#   para_load1..4  0x500D3596..0x500D359C  ParaLoadOptGridCheck (PARAMETER LOAD options)
#   wall_home1..4  0x500D359E..0x500D35A4  WallHomeEditCheck (wallpaper / home page)
#   contrast       0x500D35A6  the LCD contrast: FN_TtContrast (func_4854E5C6, the CONTRAST screen) re-reads
#                  it (section 10) and hands it to func_484ABAA9, which clamps it to 3..100 and sends the
#                  panel CPU command 0x1C with func_484ABAA9_Table[value]; event 0x2060002 stores a new one
#   r_a94, r_a96   0x500D35A8, 0x500D35AA  read by no routine of programs 893, 935 or 941 (only the section
#                  copy and compare of func_4C024030 / func_4C024263, and the boot default 0 and 1;
#                  probe section_map.py): kept at their defaults
#   data_protect   0x500D35AC  DataProtectGridCheck
#   cus_mem_mode   0x500D35AE  the CUSTOM PANEL MODE screen (custommem): 0 = PANEL MEMORY, 1 = ALL PANEL
#                  (CusMemModeBoxProc frames the menu box it indexes; the boxes are "  PANEL MEMORY" and
#                  "  ALL PANEL", in that order).  Non-zero makes func_4C021903 store and recall the
#                  0x7F0-byte CUSTOM PANEL instead of 0x750 bytes: ALL PANEL adds the panel state outside a
#                  panel memory, the second record list (tags 0x52, 0x50, 0x51, 0x60-0x62, 0x68)
#   acc_reverb_mask 0x500D35B0 one bit per accompaniment part, bits 0-7 = ACCOMP1-5, BASS, DRUMS1, DRUMS2
#                  (part tags 0x13-0x1A): func_4C027803, the CC91 (reverb depth) case of the part-CC table
#                  func_4C024DD8_Records_4, sends a part's CC91 value only when its bit is set, else 0.
#                  Default 0xFF; nothing writes it
#   rsp_select     0x500D35B2  RSpSelectProc, TestVideoOutFunc; bit 0 survives the reset of func_4C023EC9
#   panel_sw1, panel_sw2  0x500D35B4  SdcPanelSwAsFunc (one 4-byte section)
.macro USR_SETUP language, to_save_reminder, to_completed, to_are_you_sure, to_error, to_sound_rhythm, to_easy_setting, jump_insert, file_priority, para_load1, para_load2, para_load3, para_load4, wall_home1, wall_home2, wall_home3, wall_home4, contrast, r_a94, r_a96, data_protect, cus_mem_mode, acc_reverb_mask, rsp_select, panel_sw1, panel_sw2
	.word	\language, \to_save_reminder, \to_completed, \to_are_you_sure, \to_error, \to_sound_rhythm, \to_easy_setting
	.word	\jump_insert, \file_priority, \para_load1, \para_load2, \para_load3, \para_load4
	.word	\wall_home1, \wall_home2, \wall_home3, \wall_home4, \contrast, \r_a94, \r_a96
	.word	\data_protect, \cus_mem_mode, \acc_reverb_mask, \rsp_select, \panel_sw1, \panel_sw2
.endm

# ---- the flash test: 0x96806000 ----------------------------------------------------------------
# func_4849FCF2, one step of the ROM test (MainRomTestFunc, and the test runner func_484A4FBA),
# fills a 0x200-byte buffer with the word 0x5A5AA5A5 (bytes A5 A5 5A 5A), programs it to
# 0x96806000 in 0x80-byte chunks, 0x2000 bytes when func_4849FC1A returns 1 and 0x320 otherwise,
# and reads it back through CUSTOM_FLASH_CMD (halfwords 0xA5A5, 0x5A5A from halfword 0x3000);
# a mismatch sets bit 3 of the test result.  Nothing erases it afterwards.
# func_4849FC1A returns 1 only on page 1, ROM DEVICE TEST (Testmenu1: "PROGRAM ROM IC16", "RHYTHM ROM
# IC18 (IC20)", "CUSTOM FLASH IC21"), of the service TEST MENU (screen TestMenu2, title TT_TESTMENU =
# 0xFC): byte +0x1F9 of the test state buffer func_4849FB5C (0x5006BA20) is the title the test runs
# under (func_484A08DE stores GetTitleNow there) and must be 0xFC, and byte +0x1F8 is
# func_4849FBE4_Table[page] for the TEST MENU page (AcTestMenuPageProc, func_4849FC08; pages 1..12),
# 1 for page 1.  Run from elsewhere (the other stest screens) the test writes the short 0x320 bytes.
.macro FLASH_TEST_WORDS16
	.long	0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5
	.long	0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5, 0x5a5aa5a5
.endm
# 0x80 bytes: one of the chunks the test programs.
.macro FLASH_TEST_CHUNK
	FLASH_TEST_WORDS16
	FLASH_TEST_WORDS16
.endm

# ---- FAVORITES: 0x198 bytes at 0x96810000, RAM copy 0x5006B888 ---------------------------------
# func_4849EDA9 (boot) rewrites it from the ROM template func_4849EDEB_Table when its signature
# or stamp differ (func_4849EDEB, func_4849EE0B: FlashProgram128Words 0x198 bytes), then
# func_4849EE33 loads it into RAM.  Header: the signature and a u32 stamp compared with the
# template's (0xFFFFFFF3 in program 941).
.macro FAV_HEADER stamp
	USR_SIGNATURE
	.long	\stamp
.endm
# Four banks of 100 bytes at +0x08 (FavBankNamingFunc: 0x5006B890 + bank*0x64): a 16-character
# name, a u32 0, then ten items.  The u32 is the name's NUL terminator and pad: FavBankNamingFunc has
# the naming window write the name (at most 0x10 characters, MT_GetString) with its NUL to the bank's
# start, and func_4849E435 and the MT_GetString case of the bank list (0x4849D1B5, "1:%s|2:%s|...")
# read it with strcpy / sprintf; the items start at +0x14.
.macro FAV_BANK name, w10
	.ascii	\name
	.long	\w10
.endm
# An item: {u32 kind, u32 value}, at bank +0x14 + i*8.  AcFavoriteProc dispatches on the kind
# through AcFavoriteProc_Table; what each handler recalls on EV_SWIN and draws (program 941):
.equ FAVK_NONE, 0             # 0, 1, 10..15: func_4849D4D4, an empty box
.equ FAVK_SETTING, 2          # func_4849D575: "FAVORITES SETTING", opens the FAVORITES SETTING page
                              # (ChangeMode 0xD, ChangeTitle 0x10); value 0
.equ FAVK_SOUND, 3            # func_4849D6A8: a sound, value {program, bank LSB, bank MSB} low byte
                              # first, put to parameter 0xC00000 of the selected part (0x8041)
.equ FAVK_RHYTHM, 4           # func_4849DAAF: a rhythm (style), value its id, put to parameter 0xC000;
                              # name func_48433C1E
.equ FAVK_STYLIST, 5          # func_4849DCF9: a MUSIC STYLIST setup, value its number (below 0x438 the
                              # 1,080 built-in StyleRecordTable setups, above them the user's;
                              # func_4847F22A names it), recalled by MainFuncCall(0x830000, 0x860003)
.equ FAVK_MENU, 6             # func_4849DE62: a menu page, value an index into func_4849DE62_Table
                              # (114 {text, ..., mode, title, event} records, "SOUND MENU", "SOUND PART
                              # SETTING", "MIXER" ...); opened with ChangeMode / ChangeTitle /
                              # InterruptTitle, indices 0x2C..0x6E through MainFuncCall(0x830000, 0x860002)
.equ FAVK_PANIC, 7            # func_4849E0E0: "PANIC", parameter 0x600004 := 0; value 0
.equ FAVK_MUTE_KEYS, 8        # func_4849E193: "MUTE KEYS : ON / OFF", toggles parameter 0x600005; value 0
.equ FAVK_SOUND_MODE, 9       # func_4849E303: the sound mode, parameter 8 := value, 0 "NX SOUND ON",
                              # 2 "GM LEVEL2 ON" (func_4849E303_Table)
.macro FAV_ITEM kind, value
	.long	\kind, \value
.endm

# ---- HOME PAGE: 0x4442 bytes at 0x96811000 (HmpBlobGet): a 0x18C-byte record, then a BMP --------
# HpFlashCheck (boot) rewrites the record from the ROM template when its signature or stamp differ
# (HpFlashWriteDefaults: record, then HpBmpResetDefault: the ROM's default BMP to 0x9681118C);
# HpRecordLoad copies the record to RAM 0x5006B5F8.  A .HMP file is the same 0x4442 bytes
# (HmpFileLoad, HmpInstall).  Header: the signature, a u32 stamp (0xFF), then the home-page type,
# a u32 at +0x08 (RAM 0x5006B600: AcHpTypeEditProc keeps it in 0..5 and indexes TtNormal_Records with
# it; AcHpPartsListProc sets 5 when the user edits the parts):
.equ HPT_DEFAULT, 0           # "DEFAULT"
.equ HPT_DEFAULT_PICTURE, 1   # "DEFAULT WITH PICTURE"
.equ HPT_PRESET1, 2           # "PRESET 1"
.equ HPT_PRESET2, 3           # "PRESET 2"
.equ HPT_PRESET3, 4           # "PRESET 3"
.equ HPT_USER, 5              # "USER": the record's own 64 parts
.macro HP_HEADER stamp, type
	USR_SIGNATURE
	.long	\stamp, \type
.endm
# 64 parts of 6 bytes at +0x0C (func_48496956 walks 0x40 of them): {u16 kind, s16 x, s16 y}.  The kind
# indexes TtNormal_Table (49 HomePagePart records: view id, part number, name; func_48496956,
# AcHpPreviewProc), named by Text_TITLE_BAR_NORM's 49 strings; HPK_NONE (0x31) is the table's end
# record (view -1), an unused part (AcHpPartsListProc).  x and y are the part's cell on the page
# (func_48496956 copies them to 0x5006B784 / 0x5006B786 and compares them with the view's +0x18 / +0x1A);
# y = -1 (0xFFFF) is the row above the grid, where the TITLE BAR parts (kinds 0-5) sit in every preset
# layout (TtNormal_Records_p0_0..3) and in the factory record (probe hp_parts.py).
.equ HPK_TITLE_BAR_NORM, 0
.equ HPK_TITLE_BAR_PMEM, 1
.equ HPK_TITLE_BAR_RHYTHM, 2
.equ HPK_TITLE_BAR_PAD, 3
.equ HPK_TITLE_BAR_SPLIT, 4
.equ HPK_TITLE_BAR_SEQ, 5
.equ HPK_BALANCE_NORM_1, 6
.equ HPK_BALANCE_NORM_2, 7
.equ HPK_BALANCE_MIXER_1, 8
.equ HPK_BALANCE_MIXER_2, 9
.equ HPK_BALANCE_SEQ, 10
.equ HPK_BALANCE_8PT_L_1, 11
.equ HPK_BALANCE_8PT_L_2, 12
.equ HPK_BALANCE_8PT_R_1, 13
.equ HPK_BALANCE_8PT_R_2, 14
.equ HPK_RIGHT_COMBI_1, 15
.equ HPK_RIGHT_COMBI_2, 16
.equ HPK_LEFT_COMBI_1, 17
.equ HPK_LEFT_COMBI_2, 18
.equ HPK_R1_SOUND_LARGE, 19
.equ HPK_R1_SOUND_NORM, 20
.equ HPK_R2_SOUND_LARGE, 21
.equ HPK_R2_SOUND_NORM, 22
.equ HPK_LEFT_SOUND_LARGE, 23
.equ HPK_LEFT_SOUND_NORM, 24
.equ HPK_RHYTHM_LARGE, 25
.equ HPK_RHYTHM_NORM, 26
.equ HPK_TEMPO_NORM, 27
.equ HPK_TEMPO_SMALL, 28
.equ HPK_CHORD_NORM, 29
.equ HPK_CHORD_SMALL, 30
.equ HPK_SPLIT_POINT, 31
.equ HPK_R1_R2_OCT, 32
.equ HPK_TRANSPOSE, 33
.equ HPK_PAD, 34
.equ HPK_MONITOR, 35
.equ HPK_PMEMORY_BANK, 36
.equ HPK_PMEMORY_1_8, 37
.equ HPK_CURRENT_PMEMORY, 38
.equ HPK_PADS_BANK, 39
.equ HPK_PAD_1_6, 40
.equ HPK_PICTURE, 41
.equ HPK_SEQ_SONG, 42
.equ HPK_FAVORITES_BANK, 43
.equ HPK_GLOBAL_EFFECTS, 44
.equ HPK_SOUND_DSP, 45
.equ HPK_SOUND_LOAD_OPT, 46
.equ HPK_FOOT_SWITCH, 47
.equ HPK_FOOT_CONTROLLER, 48
.equ HPK_NONE, 0x31
.macro HP_PART kind, x, y
	.word	\kind, \x, \y
.endm
