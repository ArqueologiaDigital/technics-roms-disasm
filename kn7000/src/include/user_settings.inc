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
# func_4C024247 copies the whole image to RAM, func_4C024000(n) programs it back after a change
# (FlashProgram128Words, 0xAA4 bytes), and func_4C024030(n) re-reads section n:
#   n = 0 +0x000 0x10 header; 1 +0x010 0xC0 parameter ids; 2..4 +0x0D0 / +0x160 / +0x1F0 0x90 the
#   three settings; 5 +0x000 0x280 the .MD part whole; 6 +0x280 0x750 / 7 +0x280 0x7F0 the CUSTOM
#   PANEL; 8..20 the fields of USR_SETUP.
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
#   disp_time1..6  0x500D3586..0x500D3590  DispTimeSetGridCheck reads all six, GetIntTimeID; the
#                  third is also read by the file-name procs (FmmFileNameFunc ...) [INFERENCE] a display
#                  time / display option grid
#   jump_insert    0x500D3592  JumpInsertFunc
#   file_priority  0x500D3594  FilePriorityFunc
#   para_load1..4  0x500D3596..0x500D359C  ParaLoadOptGridCheck (PARAMETER LOAD options)
#   wall_home1..4  0x500D359E..0x500D35A4  WallHomeEditCheck (wallpaper / home page)
#   s35a6, s35a8, s35aa  0x500D35A6..AA  (func_4854E5C6 reads the first; no named reader)
#   data_protect   0x500D35AC  DataProtectGridCheck
#   cus_mem_mode   0x500D35AE  CusMemModeBoxProc; non-zero makes func_4C021903 store and recall the
#                  0x7F0-byte CUSTOM PANEL instead of 0x750 bytes ([INFERENCE] the help text's choice
#                  "whether to load all panel settings or to load panel memory parameters",
#                  HelpTextEn35_1)
#   s35b0          0x500D35B0  func_4C027803
#   rsp_select     0x500D35B2  RSpSelectProc, TestVideoOutFunc; bit 0 survives the reset of func_4C023EC9
#   panel_sw1, panel_sw2  0x500D35B4  SdcPanelSwAsFunc (one 4-byte section)
.macro USR_SETUP language, disp_time1, disp_time2, disp_time3, disp_time4, disp_time5, disp_time6, jump_insert, file_priority, para_load1, para_load2, para_load3, para_load4, wall_home1, wall_home2, wall_home3, wall_home4, s35a6, s35a8, s35aa, data_protect, cus_mem_mode, s35b0, rsp_select, panel_sw1, panel_sw2
	.word	\language, \disp_time1, \disp_time2, \disp_time3, \disp_time4, \disp_time5, \disp_time6
	.word	\jump_insert, \file_priority, \para_load1, \para_load2, \para_load3, \para_load4
	.word	\wall_home1, \wall_home2, \wall_home3, \wall_home4, \s35a6, \s35a8, \s35aa
	.word	\data_protect, \cus_mem_mode, \s35b0, \rsp_select, \panel_sw1, \panel_sw2
.endm

# ---- the flash test: 0x96806000 ----------------------------------------------------------------
# func_4849FCF2, one step of the ROM test (MainRomTestFunc, and the test runner func_484A4FBA),
# fills a 0x200-byte buffer with the word 0x5A5AA5A5 (bytes A5 A5 5A 5A), programs it to
# 0x96806000 in 0x80-byte chunks, 0x2000 bytes when func_4849FC1A returns 1 and 0x320 otherwise,
# and reads it back through CUSTOM_FLASH_CMD (halfwords 0xA5A5, 0x5A5A from halfword 0x3000);
# a mismatch sets bit 3 of the test result.  Nothing erases it afterwards.
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
# name, a u32 (0 in every image), then ten items.
.macro FAV_BANK name, w10
	.ascii	\name
	.long	\w10
.endm
# An item: {u32 kind, u32 value}, at bank +0x14 + i*8.  AcFavoriteProc dispatches on the kind
# through AcFavoriteProc_Table: 0, 1 and 10..15 func_4849D4D4, 2 func_4849D575, 3 func_4849D6A8,
# 4 func_4849DAAF, 5 func_4849DCF9, 6 func_4849DE62, 7 func_4849E0E0, 8 func_4849E193,
# 9 func_4849E303.  [INFERENCE] kind 3 is a sound, its value {program, bank LSB, bank MSB} low byte
# first as in PM_PART; every bank ends with a kind-2 item of value 0.
.macro FAV_ITEM kind, value
	.long	\kind, \value
.endm

# ---- HOME PAGE: 0x4442 bytes at 0x96811000 (HmpBlobGet): a 0x18C-byte record, then a BMP --------
# HpFlashCheck (boot) rewrites the record from the ROM template when its signature or stamp differ
# (HpFlashWriteDefaults: record, then HpBmpResetDefault: the ROM's default BMP to 0x9681118C);
# HpRecordLoad copies the record to RAM 0x5006B5F8.  A .HMP file is the same 0x4442 bytes
# (HmpFileLoad, HmpInstall).  Header: the signature, a u32 stamp (0xFF), then the home-page type,
# a u32 at +0x08 (RAM 0x5006B600: AcHpTypeEditProc keeps it in 0..5 and TtNormal_Records is
# indexed by it; AcHpPartsListProc sets 5).
.macro HP_HEADER stamp, type
	USR_SIGNATURE
	.long	\stamp, \type
.endm
# 64 parts of 6 bytes at +0x0C (func_48496956 walks 0x40 of them): a u16 kind, 0x31 = none
# (AcHpPartsListProc), and two u16 that func_48496956 copies to 0x5006B784 / 0x5006B786 and
# compares with the view's +0x18 / +0x1A ([INFERENCE] the part's x and y on the page).
.macro HP_PART kind, x, y
	.word	\kind, \x, \y
.endm
