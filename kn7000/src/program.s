# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact.
# Panasonic MN10300, mapped at CPU 0x48400000. Code region 1 is split at
# the 443 recovered functions; functions listed in tools/gen_program_s.py
# CONVERT are emitted as real MN10300 assembly (verified byte-exact by the
# mn10300_asm encoder), the rest remain raw .incbin_range. Regenerate with
# tools/gen_program_s.py. make verify guarantees byte-identity.

.equ PROGRAM_ROM_BASE, 0x48400000
.mnbase 0x48400000   # CPU address of output offset 0 (for PC-relative ops)
.include "src/symbols.inc"

# ---- boot header (0x0..0x80) ----
_reset:
    .byte 0xDC, 0x7E, 0xFF, 0x00, 0x00      # jmp  0x4840FF7E   (reset entry)
    .byte 0xCB, 0xCB, 0xCB, 0xCB, 0xCB      # nop x5
_vector_0a:
    .byte 0xDC, 0xC5, 0x77, 0x0D, 0x00      # jmp  0x484D77CF
_rom_marker:
    .byte 0x16                              # ROM-present marker (cmp vs 0xFF)
    .space 0x80 - 0x10, 0xFF
    .org 0x000080

# ============================================================================
# Code region 1 -- organised by recovered function.
# ============================================================================
.incbin_range "baserom/kn7000_program.rom", 0x000080, 0x014b8d
# DeleteEvent  (CPU 0x48414b8d)
.incbin_range "baserom/kn7000_program.rom", 0x014b8d, 0x014ba7
# SleepMainTask  (CPU 0x48414ba7)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x0006009e, d1
    call    0x48414a77, 0, 0x14
    ret     0, 0x14
# WakeUpMainTask  (CPU 0x48414bc1)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x0006009f, d1
    call    0x48414afd, 0, 0x14
    ret     0, 0x14
# SleepApTask  (CPU 0x48414bdb)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x000600a0, d1
    call    0x48414afd, 0, 0x14
    ret     0, 0x14
# WakeUpApTask  (CPU 0x48414bf5)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x50021fd8)
    mov     d0, (0x50021fdc)
    mov     d0, (0x50021fe0)
    mov     -1, d0
    mov     0x00050006, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050005, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050007, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050017, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050014, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000c, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000d, d1
    call    0x48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000e, d1
    call    0x48429906, [d2], 0x18
    clr     d0
    mov     d0, (0x10, sp)
    mov     -1, d0
    mov     0x000600a1, d1
    call    0x484298a0, [d2], 0x1c
    ret     0, 0x14
# LcdOn  (CPU 0x48414c98)
.incbin_range "baserom/kn7000_program.rom", 0x014c98, 0x01567d
# GetJpegSize  (CPU 0x4841567d)
.incbin_range "baserom/kn7000_program.rom", 0x01567d, 0x015a87
# CaptureLcd  (CPU 0x48415a87)
.incbin_range "baserom/kn7000_program.rom", 0x015a87, 0x016148
# VwBitmapFileProc  (CPU 0x48416148)
.incbin_range "baserom/kn7000_program.rom", 0x016148, 0x01648c
# AcLanguageTextProc  (CPU 0x4841648c)
.incbin_range "baserom/kn7000_program.rom", 0x01648c, 0x0164a8
# SetModeLed  (CPU 0x484164a8)
.incbin_range "baserom/kn7000_program.rom", 0x0164a8, 0x0164f4
# InterruptTitleEZ  (CPU 0x484164f4)
.incbin_range "baserom/kn7000_program.rom", 0x0164f4, 0x016512
# SetOtherPartLed  (CPU 0x48416512)
.incbin_range "baserom/kn7000_program.rom", 0x016512, 0x016536
# SetHoldLed  (CPU 0x48416536)
.incbin_range "baserom/kn7000_program.rom", 0x016536, 0x01655a
# TitleFuncCall  (CPU 0x4841655a)
.incbin_range "baserom/kn7000_program.rom", 0x01655a, 0x016563
# GetMode2Sw  (CPU 0x48416563)
.incbin_range "baserom/kn7000_program.rom", 0x016563, 0x016587
# InitializeTaskTimer  (CPU 0x48416587)
.incbin_range "baserom/kn7000_program.rom", 0x016587, 0x016590
# SetDialLed  (CPU 0x48416590)
.incbin_range "baserom/kn7000_program.rom", 0x016590, 0x0167e0
# DrawWallPreview  (CPU 0x484167e0)
.incbin_range "baserom/kn7000_program.rom", 0x0167e0, 0x01688b
# IvPR604Proc  (CPU 0x4841688b)
.incbin_range "baserom/kn7000_program.rom", 0x01688b, 0x0168d2
# ShiftBox  (CPU 0x484168d2)
.incbin_range "baserom/kn7000_program.rom", 0x0168d2, 0x016908
# VwEditSwLineProc  (CPU 0x48416908)
.incbin_range "baserom/kn7000_program.rom", 0x016908, 0x016986
# VwTextBoxProc  (CPU 0x48416986)
.incbin_range "baserom/kn7000_program.rom", 0x016986, 0x016ae2
# SetBox  (CPU 0x48416ae2)
.incbin_range "baserom/kn7000_program.rom", 0x016ae2, 0x016af7
# GetClientBox  (CPU 0x48416af7)
.incbin_range "baserom/kn7000_program.rom", 0x016af7, 0x016def
# GetViewInstance  (CPU 0x48416def)
.incbin_range "baserom/kn7000_program.rom", 0x016def, 0x016e04
# GetBox  (CPU 0x48416e04)
.incbin_range "baserom/kn7000_program.rom", 0x016e04, 0x016e2e
# DrawStringReverse  (CPU 0x48416e2e)
.incbin_range "baserom/kn7000_program.rom", 0x016e2e, 0x016e6d
# DrawDesignBox  (CPU 0x48416e6d)
.incbin_range "baserom/kn7000_program.rom", 0x016e6d, 0x016e8a
# GetFrameColor  (CPU 0x48416e8a)
.incbin_range "baserom/kn7000_program.rom", 0x016e8a, 0x016eac
# BoxLeftCheck  (CPU 0x48416eac)
.incbin_range "baserom/kn7000_program.rom", 0x016eac, 0x016ece
# MainRamGet  (CPU 0x48416ece)
.incbin_range "baserom/kn7000_program.rom", 0x016ece, 0x017600
# IvSpecWinProc  (CPU 0x48417600)
.incbin_range "baserom/kn7000_program.rom", 0x017600, 0x017609
# CheckProgDial  (CPU 0x48417609)
.incbin_range "baserom/kn7000_program.rom", 0x017609, 0x017612
# IvMainEditSwProc  (CPU 0x48417612)
.incbin_range "baserom/kn7000_program.rom", 0x017612, 0x01768d
# IvCatchEventProc  (CPU 0x4841768d)
.incbin_range "baserom/kn7000_program.rom", 0x01768d, 0x0176cc
# SetDialFocus  (CPU 0x484176cc)
.incbin_range "baserom/kn7000_program.rom", 0x0176cc, 0x0176d5
# SetDialEnable  (CPU 0x484176d5)
.incbin_range "baserom/kn7000_program.rom", 0x0176d5, 0x0176f4
# SetDialUp  (CPU 0x484176f4)
.incbin_range "baserom/kn7000_program.rom", 0x0176f4, 0x017713
# GetRootParam  (CPU 0x48417713)
.incbin_range "baserom/kn7000_program.rom", 0x017713, 0x01773b
# SetAutoIncDefault  (CPU 0x4841773b)
.incbin_range "baserom/kn7000_program.rom", 0x01773b, 0x017810
# BoxRightCheck  (CPU 0x48417810)
.incbin_range "baserom/kn7000_program.rom", 0x017810, 0x017b24
# ScreenProc  (CPU 0x48417b24)
.incbin_range "baserom/kn7000_program.rom", 0x017b24, 0x017b30
# SetProgDial  (CPU 0x48417b30)
.incbin_range "baserom/kn7000_program.rom", 0x017b30, 0x017b80
# VwUserBitmapProc  (CPU 0x48417b80)
.incbin_range "baserom/kn7000_program.rom", 0x017b80, 0x017ba5
# DrawDesignFrame  (CPU 0x48417ba5)
.incbin_range "baserom/kn7000_program.rom", 0x017ba5, 0x017dda
# AcIndexPushSwProc  (CPU 0x48417dda)
.incbin_range "baserom/kn7000_program.rom", 0x017dda, 0x017def
# SetTempoObject  (CPU 0x48417def)
.incbin_range "baserom/kn7000_program.rom", 0x017def, 0x017e04
# TtlScreenProc  (CPU 0x48417e04)
.incbin_range "baserom/kn7000_program.rom", 0x017e04, 0x017e6d
# DrawTitleBar  (CPU 0x48417e6d)
.incbin_range "baserom/kn7000_program.rom", 0x017e6d, 0x0180a1
# GroupBoxProc  (CPU 0x484180a1)
.incbin_range "baserom/kn7000_program.rom", 0x0180a1, 0x01846e
# GetSoundDev  (CPU 0x4841846e)
.incbin_range "baserom/kn7000_program.rom", 0x01846e, 0x018473
# WindowProc  (CPU 0x48418473)
.incbin_range "baserom/kn7000_program.rom", 0x018473, 0x0184cf
# VwStrBoxProc  (CPU 0x484184cf)
.incbin_range "baserom/kn7000_program.rom", 0x0184cf, 0x0185b2
# ConvPaletteMono4  (CPU 0x484185b2)
.incbin_range "baserom/kn7000_program.rom", 0x0185b2, 0x0185d7
# VwLabelProc  (CPU 0x484185d7)
.incbin_range "baserom/kn7000_program.rom", 0x0185d7, 0x018625
# DrawBitmapSP  (CPU 0x48418625)
.incbin_range "baserom/kn7000_program.rom", 0x018625, 0x0187ac
# ApDeliveryEvent  (CPU 0x484187ac)
.incbin_range "baserom/kn7000_program.rom", 0x0187ac, 0x01880e
# SetColorMode  (CPU 0x4841880e)
.incbin_range "baserom/kn7000_program.rom", 0x01880e, 0x0189ec
# VwBitmapProc  (CPU 0x484189ec)
.incbin_range "baserom/kn7000_program.rom", 0x0189ec, 0x018a7d
# VwIconProc  (CPU 0x48418a7d)
.incbin_range "baserom/kn7000_program.rom", 0x018a7d, 0x018b81
# VwEditSwLabelProc  (CPU 0x48418b81)
.incbin_range "baserom/kn7000_program.rom", 0x018b81, 0x018ba6
# GetEditSwPoint  (CPU 0x48418ba6)
.incbin_range "baserom/kn7000_program.rom", 0x018ba6, 0x018c2f
# VwFrameProc  (CPU 0x48418c2f)
.incbin_range "baserom/kn7000_program.rom", 0x018c2f, 0x018c63
# GetClientFrame  (CPU 0x48418c63)
.incbin_range "baserom/kn7000_program.rom", 0x018c63, 0x018cb7
# GetClientFrame2  (CPU 0x48418cb7)
.incbin_range "baserom/kn7000_program.rom", 0x018cb7, 0x018d19
# SetZeroPoint  (CPU 0x48418d19)
.incbin_range "baserom/kn7000_program.rom", 0x018d19, 0x018f66
# VwBoxProc  (CPU 0x48418f66)
.incbin_range "baserom/kn7000_program.rom", 0x018f66, 0x01908d
# PsCursorBoxProc  (CPU 0x4841908d)
.incbin_range "baserom/kn7000_program.rom", 0x01908d, 0x0191d0
# AcIndexToggleProc  (CPU 0x484191d0)
.incbin_range "baserom/kn7000_program.rom", 0x0191d0, 0x0192ff
# AcMmmBoxProc  (CPU 0x484192ff)
.incbin_range "baserom/kn7000_program.rom", 0x0192ff, 0x0194a2
# AcRamBoxProc  (CPU 0x484194a2)
.incbin_range "baserom/kn7000_program.rom", 0x0194a2, 0x019883
# PsRadioBoxProc  (CPU 0x48419883)
.incbin_range "baserom/kn7000_program.rom", 0x019883, 0x0198b4
# GetDialFocus  (CPU 0x484198b4)
.incbin_range "baserom/kn7000_program.rom", 0x0198b4, 0x019e34
# PsGridBoxProc  (CPU 0x48419e34)
.incbin_range "baserom/kn7000_program.rom", 0x019e34, 0x01a07d
# PsListBoxProc  (CPU 0x4841a07d)
.incbin_range "baserom/kn7000_program.rom", 0x01a07d, 0x01ae18
# AcListBoxProc  (CPU 0x4841ae18)
.incbin_range "baserom/kn7000_program.rom", 0x01ae18, 0x01b1d1
# AcTempoBoxProc  (CPU 0x4841b1d1)
.incbin_range "baserom/kn7000_program.rom", 0x01b1d1, 0x01b8e3
# PsEditBoxProc  (CPU 0x4841b8e3)
.incbin_range "baserom/kn7000_program.rom", 0x01b8e3, 0x01b96d
# PsNumEditBoxProc  (CPU 0x4841b96d)
.incbin_range "baserom/kn7000_program.rom", 0x01b96d, 0x01b9eb
# PsTblEditBoxProc  (CPU 0x4841b9eb)
.incbin_range "baserom/kn7000_program.rom", 0x01b9eb, 0x01bb45
# AcOnOffBoxProc  (CPU 0x4841bb45)
.incbin_range "baserom/kn7000_program.rom", 0x01bb45, 0x01be8e
# AcNumEditBoxProc  (CPU 0x4841be8e)
.incbin_range "baserom/kn7000_program.rom", 0x01be8e, 0x01c32f
# ProcCall  (CPU 0x4841c32f)
.incbin_range "baserom/kn7000_program.rom", 0x01c32f, 0x01c377
# MainGetM3Em  (CPU 0x4841c377)
.incbin_range "baserom/kn7000_program.rom", 0x01c377, 0x01c3bf
# MainPutM3Em  (CPU 0x4841c3bf)
.incbin_range "baserom/kn7000_program.rom", 0x01c3bf, 0x01c40a
# AcTransposeBoxProc  (CPU 0x4841c40a)
.incbin_range "baserom/kn7000_program.rom", 0x01c40a, 0x01c43a
# AcMmmEditBoxProc  (CPU 0x4841c43a)
.incbin_range "baserom/kn7000_program.rom", 0x01c43a, 0x01c88b
# DrawEditSw  (CPU 0x4841c88b)
.incbin_range "baserom/kn7000_program.rom", 0x01c88b, 0x01c8d0
# MainRamPut  (CPU 0x4841c8d0)
.incbin_range "baserom/kn7000_program.rom", 0x01c8d0, 0x01c915
# MainRamAdd  (CPU 0x4841c915)
.incbin_range "baserom/kn7000_program.rom", 0x01c915, 0x01c963
# VwEditSwBoxProc  (CPU 0x4841c963)
.incbin_range "baserom/kn7000_program.rom", 0x01c963, 0x01cc3b
# AcBitEditBoxProc  (CPU 0x4841cc3b)
.incbin_range "baserom/kn7000_program.rom", 0x01cc3b, 0x01cc80
# MainBitPut  (CPU 0x4841cc80)
.incbin_range "baserom/kn7000_program.rom", 0x01cc80, 0x01ccc8
# AcRamEditBoxProc  (CPU 0x4841ccc8)
.incbin_range "baserom/kn7000_program.rom", 0x01ccc8, 0x01d0ec
# PsMenuBoxProc  (CPU 0x4841d0ec)
.incbin_range "baserom/kn7000_program.rom", 0x01d0ec, 0x01d24b
# AcMixerVolProc  (CPU 0x4841d24b)
.incbin_range "baserom/kn7000_program.rom", 0x01d24b, 0x01d2bb
# AcTitleMenuProc  (CPU 0x4841d2bb)
.incbin_range "baserom/kn7000_program.rom", 0x01d2bb, 0x01d81b
# DrawTitleBarOW  (CPU 0x4841d81b)
.incbin_range "baserom/kn7000_program.rom", 0x01d81b, 0x01d952
# PsEditSwBoxProc  (CPU 0x4841d952)
.incbin_range "baserom/kn7000_program.rom", 0x01d952, 0x01d9b2
# PsWideESBoxProc  (CPU 0x4841d9b2)
.incbin_range "baserom/kn7000_program.rom", 0x01d9b2, 0x01dbbf
# AcIndexEditSwProc  (CPU 0x4841dbbf)
.incbin_range "baserom/kn7000_program.rom", 0x01dbbf, 0x01dcc1
# VwMenuBoxProc  (CPU 0x4841dcc1)
.incbin_range "baserom/kn7000_program.rom", 0x01dcc1, 0x01dd90
# PassEvent  (CPU 0x4841dd90)
.incbin_range "baserom/kn7000_program.rom", 0x01dd90, 0x01df23
# AcFuncEditSwProc  (CPU 0x4841df23)
.incbin_range "baserom/kn7000_program.rom", 0x01df23, 0x01e0ce
# PsPageBoxProc  (CPU 0x4841e0ce)
.incbin_range "baserom/kn7000_program.rom", 0x01e0ce, 0x01e1cd
# AcWindowPageProc  (CPU 0x4841e1cd)
.incbin_range "baserom/kn7000_program.rom", 0x01e1cd, 0x01e5c5
# MainBitGet  (CPU 0x4841e5c5)
.incbin_range "baserom/kn7000_program.rom", 0x01e5c5, 0x01e637
# IvFixWinProc  (CPU 0x4841e637)
.incbin_range "baserom/kn7000_program.rom", 0x01e637, 0x01e894
# AcFuncToggleProc  (CPU 0x4841e894)
.incbin_range "baserom/kn7000_program.rom", 0x01e894, 0x01e8f4
# PsToggleBoxProc  (CPU 0x4841e8f4)
.incbin_range "baserom/kn7000_program.rom", 0x01e8f4, 0x01e92c
# PsInvisibleBoxProc  (CPU 0x4841e92c)
.incbin_range "baserom/kn7000_program.rom", 0x01e92c, 0x01e9eb
# IvPageControlProc  (CPU 0x4841e9eb)
.incbin_range "baserom/kn7000_program.rom", 0x01e9eb, 0x01eae3
# GetFocusParam  (CPU 0x4841eae3)
.incbin_range "baserom/kn7000_program.rom", 0x01eae3, 0x01eb4f
# IvExitProc  (CPU 0x4841eb4f)
.incbin_range "baserom/kn7000_program.rom", 0x01eb4f, 0x01ec0b
# IvExitModeProc  (CPU 0x4841ec0b)
.incbin_range "baserom/kn7000_program.rom", 0x01ec0b, 0x01ec82
# IvTrackSwitchProc  (CPU 0x4841ec82)
.incbin_range "baserom/kn7000_program.rom", 0x01ec82, 0x01ed01
# GetBoxCenter  (CPU 0x4841ed01)
.incbin_range "baserom/kn7000_program.rom", 0x01ed01, 0x01ed7b
# InitializeResource  (CPU 0x4841ed7b)
.incbin_range "baserom/kn7000_program.rom", 0x01ed7b, 0x01edf5
# IvOthJpnWinProc  (CPU 0x4841edf5)
.incbin_range "baserom/kn7000_program.rom", 0x01edf5, 0x01ef41
# DrawFuncParam  (CPU 0x4841ef41)
.incbin_range "baserom/kn7000_program.rom", 0x01ef41, 0x01efc0
# AcTrackSwitchProc  (CPU 0x4841efc0)
.incbin_range "baserom/kn7000_program.rom", 0x01efc0, 0x01f018
# AcStrRadioBoxProc  (CPU 0x4841f018)
.incbin_range "baserom/kn7000_program.rom", 0x01f018, 0x01f0d9
# SetNotDrawFlag  (CPU 0x4841f0d9)
.incbin_range "baserom/kn7000_program.rom", 0x01f0d9, 0x01f160
# SetDialDown  (CPU 0x4841f160)
.incbin_range "baserom/kn7000_program.rom", 0x01f160, 0x01f3a0
# AcSoundNameProc  (CPU 0x4841f3a0)
.incbin_range "baserom/kn7000_program.rom", 0x01f3a0, 0x01f455
# AcRhythmNameProc  (CPU 0x4841f455)
.incbin_range "baserom/kn7000_program.rom", 0x01f455, 0x01f5c9
# AcPmemNameProc  (CPU 0x4841f5c9)
.incbin_range "baserom/kn7000_program.rom", 0x01f5c9, 0x01fdda
# SetPageObject  (CPU 0x4841fdda)
.incbin_range "baserom/kn7000_program.rom", 0x01fdda, 0x01fe6a
# PsParaBoxProc  (CPU 0x4841fe6a)
.incbin_range "baserom/kn7000_program.rom", 0x01fe6a, 0x02012f
# AcGridBoxProc  (CPU 0x4842012f)
.incbin_range "baserom/kn7000_program.rom", 0x02012f, 0x0205b8
# PsTrackSwitchProc  (CPU 0x484205b8)
.incbin_range "baserom/kn7000_program.rom", 0x0205b8, 0x020652
# IvShowHideProc  (CPU 0x48420652)
.incbin_range "baserom/kn7000_program.rom", 0x020652, 0x020869
# VwLineProc  (CPU 0x48420869)
.incbin_range "baserom/kn7000_program.rom", 0x020869, 0x0208ba
# PsTextBoxProc  (CPU 0x484208ba)
.incbin_range "baserom/kn7000_program.rom", 0x0208ba, 0x020ab6
# DrawBitmapSPFast16  (CPU 0x48420ab6)
.incbin_range "baserom/kn7000_program.rom", 0x020ab6, 0x020def
# ApDeleteSpecificEvent  (CPU 0x48420def)
.incbin_range "baserom/kn7000_program.rom", 0x020def, 0x0210b7
# PsVariSelectProc  (CPU 0x484210b7)
.incbin_range "baserom/kn7000_program.rom", 0x0210b7, 0x0212b1
# DrawJpegFile  (CPU 0x484212b1)
.incbin_range "baserom/kn7000_program.rom", 0x0212b1, 0x02168a
# AcChordBoxProc  (CPU 0x4842168a)
.incbin_range "baserom/kn7000_program.rom", 0x02168a, 0x02179b
# GetChordString  (CPU 0x4842179b)
.incbin_range "baserom/kn7000_program.rom", 0x02179b, 0x021804
# InitializeBlock31  (CPU 0x48421804)
.incbin_range "baserom/kn7000_program.rom", 0x021804, 0x0218ef
# RefreshSwEvent  (CPU 0x484218ef)
    add     -8, sp
    call    0x484218ff, [a2], 0x20
    ret     0, 8
    movm    [a2], (sp)
    add     -0x1c, sp
    movhu   (0x500d3c64), d0
    mov     0x5000757c, a2
    exth    d0
    mov     a2, a0
    mov     0x38, d1
    nop
    nop
    mul     d1, d0
    add     d0, a0
    movhu   (8, a0), d0
    mov     sp, a0
    exth    d0
    add     0x18, a0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    call    0x48421a27, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d0, a2
    movhu   (8, a2), d0
    mov     1, d1
    exth    d0
    call    0x4c03cd7f, 0, 0
    ret     [a2], 0x20
    movm    [a2,a3], (sp)
    add     -0x1c, sp
    movhu   (0x500d3c64), d0
    mov     0x5000757c, a3
    exth    d0
    mov     0x38, d1
    nop
    nop
    mul     d0, d1
    mov     d1, a0
    add     a3, a0
    movhu   (8, a0), d0
    mov     sp, a0
    exth    d0
    add     0x18, a0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    call    0x48421a5e, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d0, a3
    movhu   (8, a3), d0
    mov     a0, a2
    exth    d0
    mov     1, d1
    call    0x4c03cd7f, 0, 0
    mov     a2, a0
    ret     [a2,a3], 0x24
    movm    [d2,a2,a3], (sp)
    add     -0x1c, sp
    mov     a0, (0x30, sp)
    mov     sp, a3
    add     0x18, a3
    mov     0x5000757c, d2
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d0, d1
    mov     d1, a0
    add     d2, a0
    movhu   (8, a0), d0
    mov     a3, a0
    exth    d0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    mov     (0x30, sp), a0
    call    0x48421ab1, [a2], 4
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     1, d1
    mov     a0, a2
    mov     d0, a0
    movhu   (8, a0), d0
    exth    d0
    call    0x4c03cd7f, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a0
    movhu   (6, a0), d0
    mov     1, d1
    exth    d0
    call    0x4c03cd7f, 0, 0
    cmp     0, a2
    bne     0x48421a1f
    clr     d0
    mov     d0, d1
    call    0x4c03c0e4, 0, 0
    cmp     0, a2
    beq     0x484219af
    mov     a2, a0
    ret     [d2,a2,a3], 0x28
    clr     d0
    movhu   d0, (0x5011f880)
    movhu   d0, (0x5011f882)
    movhu   d0, (0x5011f884)
    movhu   d0, (0x5011f886)
    mov     0x1ff, d0
    movhu   d0, (0x5011f888)
    mov     0x5002a034, a0
    mov     a0, (0x5002c034)
    mov     a0, (0x5002c038)
    retf    0, 0
    movhu   (0x5011f882), d1
    movhu   (0x5011f886), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    mov     0, a0
    beq     0x48421aac
    movhu   (0x5011f882), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     (d0, a0), a0
    movhu   (0x5011f882), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f882)
    exth    d0
    cmp     0x80, d0
    blt     0x48421a9d
    clr     d0
    movhu   d0, (0x5011f882)
    movhu   (0x5011f888), d0
    exth    d0
    add     4, d0
    movhu   d0, (0x5011f888)
    retf    0, 0
    movm    [a2], (sp)
    movhu   (0x5011f888), d0
    mov     a0, a2
    exth    d0
    cmp     4, d0
    mov     0, a0
    bcs     0x48421b06
    movhu   (0x5011f886), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     a2, (d0, a0)
    movhu   (0x5011f886), d0
    exth    d0
    asl2    d0
    add     d0, a0
    movhu   (0x5011f886), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f886)
    exth    d0
    cmp     0x80, d0
    blt     0x48421af5
    clr     d0
    movhu   d0, (0x5011f886)
    movhu   (0x5011f888), d0
    mov     4, d1
    exth    d0
    sub     d1, d0
    movhu   d0, (0x5011f888)
    retf    [a2], 4
    movhu   (0x5011f882), d0
    movhu   d0, (0x5011f880)
    retf    0, 0
    movhu   (0x5011f880), d1
    movhu   (0x5011f886), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    mov     0, a0
    beq     0x48421b57
    movhu   (0x5011f880), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     (d0, a0), a0
    movhu   (0x5011f880), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f880)
    exth    d0
    cmp     0x80, d0
    blt     0x48421b57
    clr     d0
    movhu   d0, (0x5011f880)
    retf    0, 0
    movm    [d2], (sp)
    add     3, d0
    mov     d0, d2
    lsr     2, d2
    asl2    d2
    mov     (0x5002c038), a0
    mov     0x5002a034, d0
    mov     a0, d1
    sub     d0, d1
    add     d2, d1
    cmp     0x2000, d1
    bcc     0x48421b85
    mov     a0, d0
    add     d2, d0
    mov     d0, (0x5002c038)
    bra     0x48421b8e
    mov     d0, a0
    add     d2, d0
    mov     d0, (0x5002c038)
    retf    [d2], 4
    retf    0, 0
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x4c03dc38, [d2,d3,a2], 0x1c
    movhu   (0xc, sp), d1
    movhu   (0x500d3c64), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    bne     0x48421bb3
    mov     1, d0
    bra     0x48421bb4
    clr     d0
    ret     0, 0x10
# SetRootParam  (CPU 0x48421bb7)
.incbin_range "baserom/kn7000_program.rom", 0x021bb7, 0x021c59
# ShiftSize  (CPU 0x48421c59)
.incbin_range "baserom/kn7000_program.rom", 0x021c59, 0x021d4c
# SetLcdMode  (CPU 0x48421d4c)
.incbin_range "baserom/kn7000_program.rom", 0x021d4c, 0x021d55
# GetColorMode  (CPU 0x48421d55)
.incbin_range "baserom/kn7000_program.rom", 0x021d55, 0x021d5e
# CheckColorLcd  (CPU 0x48421d5e)
.incbin_range "baserom/kn7000_program.rom", 0x021d5e, 0x021d67
# Check2BitLcd  (CPU 0x48421d67)
.incbin_range "baserom/kn7000_program.rom", 0x021d67, 0x021d70
# DrawBitmapSP2  (CPU 0x48421d70)
.incbin_range "baserom/kn7000_program.rom", 0x021d70, 0x021d82
# Draw2BpFile  (CPU 0x48421d82)
.incbin_range "baserom/kn7000_program.rom", 0x021d82, 0x021d94
# DrawBitmapFileEx  (CPU 0x48421d94)
.incbin_range "baserom/kn7000_program.rom", 0x021d94, 0x021dbe
# BfFile2Struct  (CPU 0x48421dbe)
.incbin_range "baserom/kn7000_program.rom", 0x021dbe, 0x021de1
# BfStruct2File  (CPU 0x48421de1)
.incbin_range "baserom/kn7000_program.rom", 0x021de1, 0x021e88
# DrawJpegFileR  (CPU 0x48421e88)
.incbin_range "baserom/kn7000_program.rom", 0x021e88, 0x02246a
# LcdOff  (CPU 0x4842246a)
.incbin_range "baserom/kn7000_program.rom", 0x02246a, 0x0224b3
# DrawBitmapFile  (CPU 0x484224b3)
.incbin_range "baserom/kn7000_program.rom", 0x0224b3, 0x0224fb
# InitializeGraphics  (CPU 0x484224fb)
.incbin_range "baserom/kn7000_program.rom", 0x0224fb, 0x0225d5
# UpdateScreen  (CPU 0x484225d5)
.incbin_range "baserom/kn7000_program.rom", 0x0225d5, 0x022630
# SetNeedUpdate  (CPU 0x48422630)
.incbin_range "baserom/kn7000_program.rom", 0x022630, 0x022697
# SetChangeRect  (CPU 0x48422697)
.incbin_range "baserom/kn7000_program.rom", 0x022697, 0x0226c4
# ReadPixel  (CPU 0x484226c4)
.incbin_range "baserom/kn7000_program.rom", 0x0226c4, 0x02271a
# ModifyPixel  (CPU 0x4842271a)
.incbin_range "baserom/kn7000_program.rom", 0x02271a, 0x022894
# ModifyPixelEx  (CPU 0x48422894)
.incbin_range "baserom/kn7000_program.rom", 0x022894, 0x022c8d
# DrawLine  (CPU 0x48422c8d)
.incbin_range "baserom/kn7000_program.rom", 0x022c8d, 0x02302c
# DrawDottedLine  (CPU 0x4842302c)
.incbin_range "baserom/kn7000_program.rom", 0x02302c, 0x02319f
# DrawBox  (CPU 0x4842319f)
.incbin_range "baserom/kn7000_program.rom", 0x02319f, 0x0235d5
# DrawFrame  (CPU 0x484235d5)
.incbin_range "baserom/kn7000_program.rom", 0x0235d5, 0x0238cb
# DrawFrameEx  (CPU 0x484238cb)
.incbin_range "baserom/kn7000_program.rom", 0x0238cb, 0x023a00
# DrawCircle  (CPU 0x48423a00)
.incbin_range "baserom/kn7000_program.rom", 0x023a00, 0x023b56
# DrawWall  (CPU 0x48423b56)
.incbin_range "baserom/kn7000_program.rom", 0x023b56, 0x023c88
# DrawBitmapSPFast  (CPU 0x48423c88)
.incbin_range "baserom/kn7000_program.rom", 0x023c88, 0x023dcd
# DrawBitmap  (CPU 0x48423dcd)
.incbin_range "baserom/kn7000_program.rom", 0x023dcd, 0x023efb
# DrawIcons  (CPU 0x48423efb)
.incbin_range "baserom/kn7000_program.rom", 0x023efb, 0x0240a4
# GetPartSelect  (CPU 0x484240a4)
.incbin_range "baserom/kn7000_program.rom", 0x0240a4, 0x02429e
# IvScreenProc  (CPU 0x4842429e)
.incbin_range "baserom/kn7000_program.rom", 0x02429e, 0x0243cd
# CaptureLcdArea  (CPU 0x484243cd)
.incbin_range "baserom/kn7000_program.rom", 0x0243cd, 0x0245bc
# GetTitleFlag  (CPU 0x484245bc)
.incbin_range "baserom/kn7000_program.rom", 0x0245bc, 0x024784
# AcMixerVolWideProc  (CPU 0x48424784)
.incbin_range "baserom/kn7000_program.rom", 0x024784, 0x0248de
# MainDeleteEvent  (CPU 0x484248de)
.incbin_range "baserom/kn7000_program.rom", 0x0248de, 0x024a9f
# VwUserBitmapByNameProc  (CPU 0x48424a9f)
.incbin_range "baserom/kn7000_program.rom", 0x024a9f, 0x024cc8
# InterruptTitleDirect  (CPU 0x48424cc8)
.incbin_range "baserom/kn7000_program.rom", 0x024cc8, 0x024ebd
# CheckHoldLED  (CPU 0x48424ebd)
.incbin_range "baserom/kn7000_program.rom", 0x024ebd, 0x024f7d
# GetBitmapInfo  (CPU 0x48424f7d)
.incbin_range "baserom/kn7000_program.rom", 0x024f7d, 0x025265
# VwJpegFileProc  (CPU 0x48425265)
.incbin_range "baserom/kn7000_program.rom", 0x025265, 0x025393
# DrawFrameSP  (CPU 0x48425393)
.incbin_range "baserom/kn7000_program.rom", 0x025393, 0x025896
# DrawString  (CPU 0x48425896)
.incbin_range "baserom/kn7000_program.rom", 0x025896, 0x02597a
# DrawStringCentered  (CPU 0x4842597a)
.incbin_range "baserom/kn7000_program.rom", 0x02597a, 0x0259f3
# DrawStringLeftJustify  (CPU 0x484259f3)
.incbin_range "baserom/kn7000_program.rom", 0x0259f3, 0x025abf
# DrawStringRightJustify  (CPU 0x48425abf)
.incbin_range "baserom/kn7000_program.rom", 0x025abf, 0x025b18
# IvExitScreenProc  (CPU 0x48425b18)
.incbin_range "baserom/kn7000_program.rom", 0x025b18, 0x025cee
# MovePixels  (CPU 0x48425cee)
.incbin_range "baserom/kn7000_program.rom", 0x025cee, 0x025ee2
# DrawLineEx  (CPU 0x48425ee2)
.incbin_range "baserom/kn7000_program.rom", 0x025ee2, 0x0261a1
# GetClientBox2  (CPU 0x484261a1)
.incbin_range "baserom/kn7000_program.rom", 0x0261a1, 0x027da1
# ConvertBitmapFile  (CPU 0x48427da1)
.incbin_range "baserom/kn7000_program.rom", 0x027da1, 0x027fff
# AcWallPreviewProc  (CPU 0x48427fff)
.incbin_range "baserom/kn7000_program.rom", 0x027fff, 0x02829f
# GetPaletteRGB4  (CPU 0x4842829f)
.incbin_range "baserom/kn7000_program.rom", 0x02829f, 0x0284b4
# CheckViewObject  (CPU 0x484284b4)
.incbin_range "baserom/kn7000_program.rom", 0x0284b4, 0x028d79
# SetPresetWall  (CPU 0x48428d79)
.incbin_range "baserom/kn7000_program.rom", 0x028d79, 0x02936f
# InitializeEventQueue  (CPU 0x4842936f)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    exth    d0
    call    0x48428c43, [d2,d3,a2,a3], 0x44
    ret     0, 0x10
# DispatchEvent  (CPU 0x48429388)
    movm    [d2,d3], (sp)
    add     -0x1c, sp
    mov     sp, a0
    add     0x18, a0
    mov     d1, d3
    mov     d0, d2
    call    0x48414a4f, [a2], 4
    mov     (0x34, sp), a0
    mov     d2, d0
    mov     a0, (0x10, sp)
    movhu   (0x18, sp), d1
    exth    d1
    mov     d1, (0x14, sp)
    mov     d3, d1
    call    0x48428555, [d2,d3,a2,a3], 0x28
    ret     [d2,d3], 0x24
# SendEvent  (CPU 0x484293ad)
    movm    [d2,d3], (sp)
    add     -0x1c, sp
    mov     sp, a0
    add     0x18, a0
    mov     d1, d3
    mov     d0, d2
    call    0x48414a4f, [a2], 4
    mov     (0x34, sp), a0
    mov     d2, d0
    mov     a0, (0x10, sp)
    movhu   (0x18, sp), d1
    exth    d1
    mov     d1, (0x14, sp)
    mov     d3, d1
    call    0x484285e4, [d2,d3,a2,a3], 0x38
    ret     [d2,d3], 0x24
# PostEvent  (CPU 0x484293d2)
    movm    [d2,a2,a3], (sp)
    add     -0x1c, sp
    mov     d0, d2
    mov     a1, a3
    mov     a0, a2
    mov     sp, a0
    add     0x18, a0
    call    0x48414a4f, [a2], 4
    movhu   (0x18, sp), d0
    mov     d2, d1
    exth    d0
    mov     a3, a1
    mov     a2, a0
    call    0x48428792, [d2,d3,a2,a3], 0x2c
    mov     1, d0
    ret     [d2,a2,a3], 0x28
# DeleteSpecificEvent  (CPU 0x484293f5)
    movm    [d2,d3], (sp)
    add     -0x18, sp
    mov     sp, a0
    add     0x14, a0
    mov     d1, d3
    mov     d0, d2
    call    0x48414a4f, [a2], 4
    movhu   (0x14, sp), d1
    mov     d2, d0
    exth    d1
    mov     d1, (0x10, sp)
    mov     d3, d1
    call    0x484288b1, [d2,d3,a2,a3], 0x54
    ret     [d2,d3], 0x20
# FuncCall  (CPU 0x48429416)
.incbin_range "baserom/kn7000_program.rom", 0x029416, 0x02943b
# GetEvent  (CPU 0x4842943b)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x10, a0), d0
    ret     0, 0x10
# GetCurrentTarget  (CPU 0x48429460)
    movm    [d3], (sp)
    add     -0x10, sp
    mov     d0, d3
    cmp     -1, d3
    beq     0x48429489
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     d3, (0x10, a0)
    ret     [d3], 0x14
# SetFocusParam  (CPU 0x4842948c)
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    mov     d1, (0x3c, sp)
    mov     sp, a0
    add     0x18, a0
    call    0x48414a4f, [a2], 4
    mov     d3, d0
    lsr     16, d0
    exthu   d0
    asl     4, d0
    add     0x5011faac, d0
    mov     d0, a0
    mov     (4, a0), a2
    cmp     0, a2
    bne     0x484294b9
    clr     d0
    ret     [d2,d3,a2,a3], 0x30
    movhu   (0x18, sp), d1
    mov     0x5000757c, d2
    exth    d1
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a0
    mov     d3, (0x20, a0)
    mov     (0x3c, sp), a0
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a1
    mov     a0, (0x24, a1)
    mov     (0x40, sp), a3
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    mov     d0, a1
    add     d2, a1
    mov     a3, (0x28, a1)
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    mov     d0, a0
    add     d2, a0
    mov     (0xc, a0), d0
    mov     0x00060000, d1
    mov     d0, (0x14, sp)
    clr     d0
    mov     d0, (0x10, sp)
    mov     d3, d0
    calls   (a2)
    movhu   (0x18, sp), d1
    mov     d3, (0x1c, sp)
    exth    d1
    mov     0x38, d3
    nop
    nop
    mul     d1, d3
    mov     d3, a0
    add     d2, a0
    mov     d0, (0xc, a0)
    lsr     16, d0
    exthu   d0
    asl     4, d0
    mov     0x38, d3
    nop
    nop
    mul     d1, d3
    mov     d3, a0
    add     d2, a0
    mov     (0xc, a0), d1
    mov     d0, a0
    add     0x5011faac, a0
    mov     (0xc, a0), a0
    exthu   d1
    mov     0x18, d0
    nop
    nop
    mulu    d0, d1
    mov     (d1, a0), a1
    clr     d0
    cmp     0, a1
    beq     0x4842954f
    mov     a3, (0x10, sp)
    mov     (0x3c, sp), d1
    mov     (0x1c, sp), d0
    calls   (a1)
    movhu   (0x18, sp), d1
    mov     0x38, d3
    exth    d1
    nop
    nop
    mul     d3, d1
    add     d1, d2
    mov     (0x14, sp), d1
    mov     d2, a0
    mov     d1, (0xc, a0)
    ret     [d2,d3,a2,a3], 0x30
# ObjectProc  (CPU 0x48429564)
.incbin_range "baserom/kn7000_program.rom", 0x029564, 0x02960c
# KillApTimer  (CPU 0x4842960c)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x14, a0), d0
    ret     0, 0x10
# GetRootObject  (CPU 0x48429631)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x18, a0), d0
    ret     0, 0x10
# GetRootEvent  (CPU 0x48429656)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x1c, a0), d0
    ret     0, 0x10
# SetAutoInc  (CPU 0x4842967b)
    movm    [d3], (sp)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    mov     d0, d3
    call    0x48414a4f, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     d3, (0x14, a0)
    ret     [d3], 0x14
# InitDrawTask  (CPU 0x484296a3)
.incbin_range "baserom/kn7000_program.rom", 0x0296a3, 0x0296cb
# SetRootEvent  (CPU 0x484296cb)
.incbin_range "baserom/kn7000_program.rom", 0x0296cb, 0x0296f3
# SetRootObject  (CPU 0x484296f3)
.incbin_range "baserom/kn7000_program.rom", 0x0296f3, 0x029718
# GetFocusObject  (CPU 0x48429718)
.incbin_range "baserom/kn7000_program.rom", 0x029718, 0x02973d
# GetFocusEvent  (CPU 0x4842973d)
.incbin_range "baserom/kn7000_program.rom", 0x02973d, 0x029762
# GetPaletteRGB  (CPU 0x48429762)
.incbin_range "baserom/kn7000_program.rom", 0x029762, 0x02978a
# SetFocusObject  (CPU 0x4842978a)
.incbin_range "baserom/kn7000_program.rom", 0x02978a, 0x0297b2
# SetFocusEvent  (CPU 0x484297b2)
.incbin_range "baserom/kn7000_program.rom", 0x0297b2, 0x0297da
# SetCurrentTarget  (CPU 0x484297da)
.incbin_range "baserom/kn7000_program.rom", 0x0297da, 0x0297ec
# MainDispatchEvent  (CPU 0x484297ec)
.incbin_range "baserom/kn7000_program.rom", 0x0297ec, 0x029808
# MainSendEvent  (CPU 0x48429808)
.incbin_range "baserom/kn7000_program.rom", 0x029808, 0x029824
# MainPostEvent  (CPU 0x48429824)
.incbin_range "baserom/kn7000_program.rom", 0x029824, 0x029839
# MainDeleteSpecificEvent  (CPU 0x48429839)
.incbin_range "baserom/kn7000_program.rom", 0x029839, 0x029851
# DrawFunc  (CPU 0x48429851)
.incbin_range "baserom/kn7000_program.rom", 0x029851, 0x02986d
# MainAddM3Em  (CPU 0x4842986d)
.incbin_range "baserom/kn7000_program.rom", 0x02986d, 0x02987f
# ApDispatchEvent  (CPU 0x4842987f)
.incbin_range "baserom/kn7000_program.rom", 0x02987f, 0x02989b
# MainGetEvent  (CPU 0x4842989b)
.incbin_range "baserom/kn7000_program.rom", 0x02989b, 0x0298b7
# RefreshApTask  (CPU 0x484298b7)
    movm    [d2,d3,a2], (sp)
    add     -0x14, sp
    mov     d1, d3
    mov     d0, d2
    cmp     -1, d2
    bne     0x484298cd
    mov     (0x30, sp), a0
    mov     a0, (0x10, sp)
    call    0x484298a0, [d2], 0x1c
    bra     0x484298fe
    mov     0xc, d0
    call    0x4841662a, [d2,a2,a3], 0x28
    mov     a0, a2
    mov     d2, (a2)
    mov     d3, (4, a2)
    mov     (0x30, sp), a1
    mov     -1, d0
    mov     a1, (8, a2)
    mov     a0, (0x10, sp)
    mov     0x0005002f, d1
    call    0x484298a0, [d2], 0x1c
    mov     a2, (0x10, sp)
    mov     -1, d0
    mov     0x00060023, d1
    call    0x484298a0, [d2], 0x1c
    ret     [d2,d3,a2], 0x20
# ApSendEvent  (CPU 0x48429901)
.incbin_range "baserom/kn7000_program.rom", 0x029901, 0x029919
# ApDeleteEvent  (CPU 0x48429919)
.incbin_range "baserom/kn7000_program.rom", 0x029919, 0x029935
# PsWideToggleProc  (CPU 0x48429935)
.incbin_range "baserom/kn7000_program.rom", 0x029935, 0x02994c
# SetMmmFilter  (CPU 0x4842994c)
.incbin_range "baserom/kn7000_program.rom", 0x02994c, 0x0299f1
# InitializeTimer  (CPU 0x484299f1)
.incbin_range "baserom/kn7000_program.rom", 0x0299f1, 0x029c95
# ApTimer  (CPU 0x48429c95)
.incbin_range "baserom/kn7000_program.rom", 0x029c95, 0x029f9d
# SetApTimer  (CPU 0x48429f9d)
.incbin_range "baserom/kn7000_program.rom", 0x029f9d, 0x029fd0
# ResetApTimer  (CPU 0x48429fd0)
.incbin_range "baserom/kn7000_program.rom", 0x029fd0, 0x02a208
# DrawStringAlignment  (CPU 0x4842a208)
.incbin_range "baserom/kn7000_program.rom", 0x02a208, 0x02a4e5
# InheritedProc  (CPU 0x4842a4e5)
.incbin_range "baserom/kn7000_program.rom", 0x02a4e5, 0x02a6c5
# UnRegisterObject  (CPU 0x4842a6c5)
.incbin_range "baserom/kn7000_program.rom", 0x02a6c5, 0x02a6ed
# CountObject  (CPU 0x4842a6ed)
.incbin_range "baserom/kn7000_program.rom", 0x02a6ed, 0x02a717
# InitializeObjectTable  (CPU 0x4842a717)
.incbin_range "baserom/kn7000_program.rom", 0x02a717, 0x02a737
# RegisterObjectTable  (CPU 0x4842a737)
.incbin_range "baserom/kn7000_program.rom", 0x02a737, 0x02a7b2
# RegisterObject  (CPU 0x4842a7b2)
.incbin_range "baserom/kn7000_program.rom", 0x02a7b2, 0x02a802
# WordwrapStrings  (CPU 0x4842a802)
.incbin_range "baserom/kn7000_program.rom", 0x02a802, 0x02aaf0
# ClassProc  (CPU 0x4842aaf0)
.incbin_range "baserom/kn7000_program.rom", 0x02aaf0, 0x02ab7d
# TrackIDProc  (CPU 0x4842ab7d)
.incbin_range "baserom/kn7000_program.rom", 0x02ab7d, 0x02ac0c
# InitPaletteRGB  (CPU 0x4842ac0c)
.incbin_range "baserom/kn7000_program.rom", 0x02ac0c, 0x02ac35
# FunctionProc  (CPU 0x4842ac35)
.incbin_range "baserom/kn7000_program.rom", 0x02ac35, 0x02ac7b
# MainFunctionProc  (CPU 0x4842ac7b)
.incbin_range "baserom/kn7000_program.rom", 0x02ac7b, 0x02acfa
# ApFunctionProc  (CPU 0x4842acfa)
.incbin_range "baserom/kn7000_program.rom", 0x02acfa, 0x02ad40
# ApFuncCall  (CPU 0x4842ad40)
.incbin_range "baserom/kn7000_program.rom", 0x02ad40, 0x02adc3
# MethodProc  (CPU 0x4842adc3)
.incbin_range "baserom/kn7000_program.rom", 0x02adc3, 0x02ae30
# MainFuncCall  (CPU 0x4842ae30)
.incbin_range "baserom/kn7000_program.rom", 0x02ae30, 0x02b309
# UnregisteredMode  (CPU 0x4842b309)
.incbin_range "baserom/kn7000_program.rom", 0x02b309, 0x02b326
# GetModeNow  (CPU 0x4842b326)
.incbin_range "baserom/kn7000_program.rom", 0x02b326, 0x02b343
# SwInEasySet  (CPU 0x4842b343)
.incbin_range "baserom/kn7000_program.rom", 0x02b343, 0x02b371
# ChangeMode  (CPU 0x4842b371)
.incbin_range "baserom/kn7000_program.rom", 0x02b371, 0x02b3af
# DrawBitmapSPFast4  (CPU 0x4842b3af)
.incbin_range "baserom/kn7000_program.rom", 0x02b3af, 0x02b3ef
# ChangeModeEZ  (CPU 0x4842b3ef)
.incbin_range "baserom/kn7000_program.rom", 0x02b3ef, 0x02b41d
# ChangeTitle  (CPU 0x4842b41d)
.incbin_range "baserom/kn7000_program.rom", 0x02b41d, 0x02b45b
# ChangeModeDirect  (CPU 0x4842b45b)
.incbin_range "baserom/kn7000_program.rom", 0x02b45b, 0x02b49b
# ChangeTitleEZ  (CPU 0x4842b49b)
.incbin_range "baserom/kn7000_program.rom", 0x02b49b, 0x02b4c9
# InterruptTitle  (CPU 0x4842b4c9)
.incbin_range "baserom/kn7000_program.rom", 0x02b4c9, 0x02b507
# ChangeTitleDirect  (CPU 0x4842b507)
.incbin_range "baserom/kn7000_program.rom", 0x02b507, 0x02b9ec
# DrawBitmapSPFast256  (CPU 0x4842b9ec)
.incbin_range "baserom/kn7000_program.rom", 0x02b9ec, 0x02ba04
# ModeFuncCall  (CPU 0x4842ba04)
.incbin_range "baserom/kn7000_program.rom", 0x02ba04, 0x02ba1c
# GetModeOld  (CPU 0x4842ba1c)
.incbin_range "baserom/kn7000_program.rom", 0x02ba1c, 0x02c982
# UnregisteredTitle  (CPU 0x4842c982)
.incbin_range "baserom/kn7000_program.rom", 0x02c982, 0x02c99f
# GetTitleNow  (CPU 0x4842c99f)
.incbin_range "baserom/kn7000_program.rom", 0x02c99f, 0x02c9bc
# IntTimeIDProc  (CPU 0x4842c9bc)
.incbin_range "baserom/kn7000_program.rom", 0x02c9bc, 0x02c9ce
# CheckNotDrawFlag  (CPU 0x4842c9ce)
.incbin_range "baserom/kn7000_program.rom", 0x02c9ce, 0x02c9e8
# GetInterruptTime  (CPU 0x4842c9e8)
.incbin_range "baserom/kn7000_program.rom", 0x02c9e8, 0x02ca0d
# ConvertStringsEx  (CPU 0x4842ca0d)
.incbin_range "baserom/kn7000_program.rom", 0x02ca0d, 0x02cae0
# KinsokuStrings  (CPU 0x4842cae0)
.incbin_range "baserom/kn7000_program.rom", 0x02cae0, 0x02cb02
# ApPostEvent  (CPU 0x4842cb02)
.incbin_range "baserom/kn7000_program.rom", 0x02cb02, 0x02cb4a
# EventProc  (CPU 0x4842cb4a)
.incbin_range "baserom/kn7000_program.rom", 0x02cb4a, 0x02cb92
# RegisterOTBlock  (CPU 0x4842cb92)
.incbin_range "baserom/kn7000_program.rom", 0x02cb92, 0x02d244
# GetIntTimeID  (CPU 0x4842d244)
.incbin_range "baserom/kn7000_program.rom", 0x02d244, 0x02d361
# GetConst  (CPU 0x4842d361)
.incbin_range "baserom/kn7000_program.rom", 0x02d361, 0x02d388
# SetChange  (CPU 0x4842d388)
.incbin_range "baserom/kn7000_program.rom", 0x02d388, 0x02d3a0
# ViewableProc  (CPU 0x4842d3a0)
.incbin_range "baserom/kn7000_program.rom", 0x02d3a0, 0x02d3c7
# SetConst  (CPU 0x4842d3c7)
.incbin_range "baserom/kn7000_program.rom", 0x02d3c7, 0x02d3df
# GetChange  (CPU 0x4842d3df)
.incbin_range "baserom/kn7000_program.rom", 0x02d3df, 0x02d406
# SetVisible  (CPU 0x4842d406)
.incbin_range "baserom/kn7000_program.rom", 0x02d406, 0x02d41c
# GetVisible  (CPU 0x4842d41c)
.incbin_range "baserom/kn7000_program.rom", 0x02d41c, 0x02d443
# SetMovable  (CPU 0x4842d443)
.incbin_range "baserom/kn7000_program.rom", 0x02d443, 0x02d459
# GetMovable  (CPU 0x4842d459)
.incbin_range "baserom/kn7000_program.rom", 0x02d459, 0x02d483
# NextView  (CPU 0x4842d483)
.incbin_range "baserom/kn7000_program.rom", 0x02d483, 0x02d4ad
# PrevView  (CPU 0x4842d4ad)
.incbin_range "baserom/kn7000_program.rom", 0x02d4ad, 0x02d4d6
# SuperView  (CPU 0x4842d4d6)
.incbin_range "baserom/kn7000_program.rom", 0x02d4d6, 0x02d500
# SubView  (CPU 0x4842d500)
.incbin_range "baserom/kn7000_program.rom", 0x02d500, 0x02d5db
# Link  (CPU 0x4842d5db)
.incbin_range "baserom/kn7000_program.rom", 0x02d5db, 0x02d721
# Unlink  (CPU 0x4842d721)
.incbin_range "baserom/kn7000_program.rom", 0x02d721, 0x02d7d3
# SetSuperView  (CPU 0x4842d7d3)
.incbin_range "baserom/kn7000_program.rom", 0x02d7d3, 0x02d91a
# GetLinkView  (CPU 0x4842d91a)
.incbin_range "baserom/kn7000_program.rom", 0x02d91a, 0x02d934
# ResStringProc  (CPU 0x4842d934)
.incbin_range "baserom/kn7000_program.rom", 0x02d934, 0x02d953
# OTBlockProc  (CPU 0x4842d953)
.incbin_range "baserom/kn7000_program.rom", 0x02d953, 0x02d962
# ResourceProc  (CPU 0x4842d962)
.incbin_range "baserom/kn7000_program.rom", 0x02d962, 0x02d971
# ResBitmapProc  (CPU 0x4842d971)
.incbin_range "baserom/kn7000_program.rom", 0x02d971, 0x02d980
# ResFrameProc  (CPU 0x4842d980)
.incbin_range "baserom/kn7000_program.rom", 0x02d980, 0x02d98f
# ResIconProc  (CPU 0x4842d98f)
.incbin_range "baserom/kn7000_program.rom", 0x02d98f, 0x02d99e
# ResFontProc  (CPU 0x4842d99e)
.incbin_range "baserom/kn7000_program.rom", 0x02d99e, 0x02d9ad
# SetPaletteRGB  (CPU 0x4842d9ad)
.incbin_range "baserom/kn7000_program.rom", 0x02d9ad, 0x02d9f1
# DrawBitmapFast  (CPU 0x4842d9f1)
.incbin_range "baserom/kn7000_program.rom", 0x02d9f1, 0x02db23
# GetBitmapSize  (CPU 0x4842db23)
.incbin_range "baserom/kn7000_program.rom", 0x02db23, 0x02db30
# ApDeleteEventMmm  (CPU 0x4842db30)
.incbin_range "baserom/kn7000_program.rom", 0x02db30, 0x02dc88
# InitializeBlock47  (CPU 0x4842dc88)
.incbin_range "baserom/kn7000_program.rom", 0x02dc88, 0x02dcec
# GetLcdMode  (CPU 0x4842dcec)
.incbin_range "baserom/kn7000_program.rom", 0x02dcec, 0x02dd6f
# GetEditSwPointInit  (CPU 0x4842dd6f)
.incbin_range "baserom/kn7000_program.rom", 0x02dd6f, 0x02de2d
# u2d  (CPU 0x4842de2d)
.incbin_range "baserom/kn7000_program.rom", 0x02de2d, 0x02dedc
# InitSptClassTable  (CPU 0x4842dedc)
.incbin_range "baserom/kn7000_program.rom", 0x02dedc, 0x02dee5
# GetBitmapCount  (CPU 0x4842dee5)
.incbin_range "baserom/kn7000_program.rom", 0x02dee5, 0x02deee
# GetFontNameTable  (CPU 0x4842deee)
.incbin_range "baserom/kn7000_program.rom", 0x02deee, 0x02df0f
# GetIconNameTable  (CPU 0x4842df0f)
.incbin_range "baserom/kn7000_program.rom", 0x02df0f, 0x02df18
# GetFrameCount  (CPU 0x4842df18)
.incbin_range "baserom/kn7000_program.rom", 0x02df18, 0x02df21
# ResNameProc  (CPU 0x4842df21)
.incbin_range "baserom/kn7000_program.rom", 0x02df21, 0x02df3c
# GetBitmapNameTable  (CPU 0x4842df3c)
.incbin_range "baserom/kn7000_program.rom", 0x02df3c, 0x02df45
# GetIconCount  (CPU 0x4842df45)
.incbin_range "baserom/kn7000_program.rom", 0x02df45, 0x02df4e
# GetFrameNameTable  (CPU 0x4842df4e)
.incbin_range "baserom/kn7000_program.rom", 0x02df4e, 0x02df57
# GetFontCount  (CPU 0x4842df57)
.incbin_range "baserom/kn7000_program.rom", 0x02df57, 0x02df60
# GetFrameSPSize  (CPU 0x4842df60)
.incbin_range "baserom/kn7000_program.rom", 0x02df60, 0x02df73
# GetCharHeight  (CPU 0x4842df73)
.incbin_range "baserom/kn7000_program.rom", 0x02df73, 0x02df86
# GetCharDescent  (CPU 0x4842df86)
.incbin_range "baserom/kn7000_program.rom", 0x02df86, 0x02dfa8
# GetCenteredDelta  (CPU 0x4842dfa8)
.incbin_range "baserom/kn7000_program.rom", 0x02dfa8, 0x02e051
# SetVariFlag  (CPU 0x4842e051)
.incbin_range "baserom/kn7000_program.rom", 0x02e051, 0x02e0bb
# ConvertStrings  (CPU 0x4842e0bb)
.incbin_range "baserom/kn7000_program.rom", 0x02e0bb, 0x02e16c
# CalcTotalWidth  (CPU 0x4842e16c)
.incbin_range "baserom/kn7000_program.rom", 0x02e16c, 0x02e25f
# d2u  (CPU 0x4842e25f)
.incbin_range "baserom/kn7000_program.rom", 0x02e25f, 0x02e5dc
# InitModeTitleTable  (CPU 0x4842e5dc)
.incbin_range "baserom/kn7000_program.rom", 0x02e5dc, 0x02e609
# SupportClassProc  (CPU 0x4842e609)
.incbin_range "baserom/kn7000_program.rom", 0x02e609, 0x02e664
# swordProc  (CPU 0x4842e664)
.incbin_range "baserom/kn7000_program.rom", 0x02e664, 0x02e6be
# uwordProc  (CPU 0x4842e6be)
.incbin_range "baserom/kn7000_program.rom", 0x02e6be, 0x02e718
# ucharProc  (CPU 0x4842e718)
.incbin_range "baserom/kn7000_program.rom", 0x02e718, 0x02e773
# scharProc  (CPU 0x4842e773)
.incbin_range "baserom/kn7000_program.rom", 0x02e773, 0x02e7cb
# slongProc  (CPU 0x4842e7cb)
.incbin_range "baserom/kn7000_program.rom", 0x02e7cb, 0x02e823
# ulongProc  (CPU 0x4842e823)
.incbin_range "baserom/kn7000_program.rom", 0x02e823, 0x02e87b
# boolProc  (CPU 0x4842e87b)
.incbin_range "baserom/kn7000_program.rom", 0x02e87b, 0x02e99f
# pBoolProc  (CPU 0x4842e99f)
.incbin_range "baserom/kn7000_program.rom", 0x02e99f, 0x02eac8
# pSwordProc  (CPU 0x4842eac8)
.incbin_range "baserom/kn7000_program.rom", 0x02eac8, 0x02ebf0
# pUwordProc  (CPU 0x4842ebf0)
.incbin_range "baserom/kn7000_program.rom", 0x02ebf0, 0x02ed19
# pScharProc  (CPU 0x4842ed19)
.incbin_range "baserom/kn7000_program.rom", 0x02ed19, 0x02ee41
# pUcharProc  (CPU 0x4842ee41)
.incbin_range "baserom/kn7000_program.rom", 0x02ee41, 0x02ef65
# pSlongProc  (CPU 0x4842ef65)
.incbin_range "baserom/kn7000_program.rom", 0x02ef65, 0x02f089
# EventIDProc  (CPU 0x4842f089)
.incbin_range "baserom/kn7000_program.rom", 0x02f089, 0x02f0f7
# RECTWProc  (CPU 0x4842f0f7)
.incbin_range "baserom/kn7000_program.rom", 0x02f0f7, 0x02f1c6
# RectX1Proc  (CPU 0x4842f1c6)
.incbin_range "baserom/kn7000_program.rom", 0x02f1c6, 0x02f26d
# RectY1Proc  (CPU 0x4842f26d)
.incbin_range "baserom/kn7000_program.rom", 0x02f26d, 0x02f31b
# RectX2Proc  (CPU 0x4842f31b)
.incbin_range "baserom/kn7000_program.rom", 0x02f31b, 0x02f3ee
# RectY2Proc  (CPU 0x4842f3ee)
.incbin_range "baserom/kn7000_program.rom", 0x02f3ee, 0x02f44c
# POINTWProc  (CPU 0x4842f44c)
.incbin_range "baserom/kn7000_program.rom", 0x02f44c, 0x02f50c
# PointXProc  (CPU 0x4842f50c)
.incbin_range "baserom/kn7000_program.rom", 0x02f50c, 0x02f5a7
# pStringProc  (CPU 0x4842f5a7)
.incbin_range "baserom/kn7000_program.rom", 0x02f5a7, 0x02f747
# ViewIDProc  (CPU 0x4842f747)
.incbin_range "baserom/kn7000_program.rom", 0x02f747, 0x02f7a1
# ViewFlagProc  (CPU 0x4842f7a1)
.incbin_range "baserom/kn7000_program.rom", 0x02f7a1, 0x02f7fc
# ColorIDProc  (CPU 0x4842f7fc)
.incbin_range "baserom/kn7000_program.rom", 0x02f7fc, 0x02f857
# FontIDProc  (CPU 0x4842f857)
.incbin_range "baserom/kn7000_program.rom", 0x02f857, 0x02f8b1
# EditSwIDProc  (CPU 0x4842f8b1)
.incbin_range "baserom/kn7000_program.rom", 0x02f8b1, 0x02f90b
# AlignmentIDProc  (CPU 0x4842f90b)
.incbin_range "baserom/kn7000_program.rom", 0x02f90b, 0x02f9a0
# EditSwStyleIDProc  (CPU 0x4842f9a0)
.incbin_range "baserom/kn7000_program.rom", 0x02f9a0, 0x02f9fa
# LineModeIDProc  (CPU 0x4842f9fa)
.incbin_range "baserom/kn7000_program.rom", 0x02f9fa, 0x02fa54
# MainFuncIDProc  (CPU 0x4842fa54)
.incbin_range "baserom/kn7000_program.rom", 0x02fa54, 0x02faae
# PartIDProc  (CPU 0x4842faae)
.incbin_range "baserom/kn7000_program.rom", 0x02faae, 0x02fb08
# IvExitWindowProc  (CPU 0x4842fb08)
.incbin_range "baserom/kn7000_program.rom", 0x02fb08, 0x02fb62
# PointYProc  (CPU 0x4842fb62)
.incbin_range "baserom/kn7000_program.rom", 0x02fb62, 0x02fc88
# IconIDProc  (CPU 0x4842fc88)
.incbin_range "baserom/kn7000_program.rom", 0x02fc88, 0x02fd89
# TitleIDProc  (CPU 0x4842fd89)
.incbin_range "baserom/kn7000_program.rom", 0x02fd89, 0x02fe8a
# FrameIDProc  (CPU 0x4842fe8a)
.incbin_range "baserom/kn7000_program.rom", 0x02fe8a, 0x02ff8b
# BitmapIDProc  (CPU 0x4842ff8b)
.incbin_range "baserom/kn7000_program.rom", 0x02ff8b, 0x03012b
# ApFuncIDProc  (CPU 0x4843012b)
.incbin_range "baserom/kn7000_program.rom", 0x03012b, 0x0302cb
# ConstFlagProc  (CPU 0x484302cb)
.incbin_range "baserom/kn7000_program.rom", 0x0302cb, 0x030575
# ClassIDProc  (CPU 0x48430575)
.incbin_range "baserom/kn7000_program.rom", 0x030575, 0x030889
# ScreenIDProc  (CPU 0x48430889)
.incbin_range "baserom/kn7000_program.rom", 0x030889, 0x030b9d
# BorderIDProc  (CPU 0x48430b9d)
.incbin_range "baserom/kn7000_program.rom", 0x030b9d, 0x030dde
# OTBlockIDProc  (CPU 0x48430dde)
.incbin_range "baserom/kn7000_program.rom", 0x030dde, 0x03101f
# ModeIDProc  (CPU 0x4843101f)
.incbin_range "baserom/kn7000_program.rom", 0x03101f, 0x031260
# StringProc  (CPU 0x48431260)
.incbin_range "baserom/kn7000_program.rom", 0x031260, 0x03131c
# NameProc  (CPU 0x4843131c)
.incbin_range "baserom/kn7000_program.rom", 0x03131c, 0x0313da
# pUlongProc  (CPU 0x484313da)
.incbin_range "baserom/kn7000_program.rom", 0x0313da, 0x0313e9
# ObjectIDProc  (CPU 0x484313e9)
.incbin_range "baserom/kn7000_program.rom", 0x0313e9, 0x0313f8
# pFuncProc  (CPU 0x484313f8)
.incbin_range "baserom/kn7000_program.rom", 0x0313f8, 0x031407
# pProcProc  (CPU 0x48431407)
.incbin_range "baserom/kn7000_program.rom", 0x031407, 0x031416
# pPropProc  (CPU 0x48431416)
.incbin_range "baserom/kn7000_program.rom", 0x031416, 0x031425
# WindowIDProc  (CPU 0x48431425)
.incbin_range "baserom/kn7000_program.rom", 0x031425, 0x031676
# BlinkHoldLed  (CPU 0x48431676)
.incbin_range "baserom/kn7000_program.rom", 0x031676, 0x031683
# GetSw2Mode  (CPU 0x48431683)
.incbin_range "baserom/kn7000_program.rom", 0x031683, 0x031690
# VwIconListProc  (CPU 0x48431690)
.incbin_range "baserom/kn7000_program.rom", 0x031690, 0x0317d1
# GetTitleOld  (CPU 0x484317d1)
.incbin_range "baserom/kn7000_program.rom", 0x0317d1, 0x0317ec
# ModeProc  (CPU 0x484317ec)
.incbin_range "baserom/kn7000_program.rom", 0x0317ec, 0x03180a
# RegisterMode  (CPU 0x4843180a)
.incbin_range "baserom/kn7000_program.rom", 0x03180a, 0x031836
# TitleProc  (CPU 0x48431836)
.incbin_range "baserom/kn7000_program.rom", 0x031836, 0x031862
# RegisterTitle  (CPU 0x48431862)
.incbin_range "baserom/kn7000_program.rom", 0x031862, 0x0318ad
# CheckDialLED  (CPU 0x484318ad)
.incbin_range "baserom/kn7000_program.rom", 0x0318ad, 0x0318e9
# RegisterEasySet  (CPU 0x484318e9)
.incbin_range "baserom/kn7000_program.rom", 0x0318e9, 0x031cb6
# InitializeBlock29  (CPU 0x48431cb6)
.incbin_range "baserom/kn7000_program.rom", 0x031cb6, 0x031cb9
# InitializeBlock30  (CPU 0x48431cb9)
.incbin_range "baserom/kn7000_program.rom", 0x031cb9, 0x031cbc
# InitializeBlock35  (CPU 0x48431cbc)
.incbin_range "baserom/kn7000_program.rom", 0x031cbc, 0x031cbf
# InitializeBlock36  (CPU 0x48431cbf)
.incbin_range "baserom/kn7000_program.rom", 0x031cbf, 0x031cc2
# InitializeBlock37  (CPU 0x48431cc2)
.incbin_range "baserom/kn7000_program.rom", 0x031cc2, 0x031cc5
# InitializeBlock38  (CPU 0x48431cc5)
.incbin_range "baserom/kn7000_program.rom", 0x031cc5, 0x031cc8
# InitializeBlock41  (CPU 0x48431cc8)
.incbin_range "baserom/kn7000_program.rom", 0x031cc8, 0x031ccb
# InitializeBlock42  (CPU 0x48431ccb)
.incbin_range "baserom/kn7000_program.rom", 0x031ccb, 0x031cce
# InitializeBlock43  (CPU 0x48431cce)
.incbin_range "baserom/kn7000_program.rom", 0x031cce, 0x031cd1
# InitializeBlock44  (CPU 0x48431cd1)
.incbin_range "baserom/kn7000_program.rom", 0x031cd1, 0x031cd4
# InitializeBlock45  (CPU 0x48431cd4)
.incbin_range "baserom/kn7000_program.rom", 0x031cd4, 0x031cd7
# InitializeBlock46  (CPU 0x48431cd7)
.incbin_range "baserom/kn7000_program.rom", 0x031cd7, 0x07acbf
# InitializeBlock20  (CPU 0x4847acbf)
.incbin_range "baserom/kn7000_program.rom", 0x07acbf, 0x087420
# InitializeBlock00  (CPU 0x48487420)
.incbin_range "baserom/kn7000_program.rom", 0x087420, 0x088cde
# InitializeBlock01  (CPU 0x48488cde)
.incbin_range "baserom/kn7000_program.rom", 0x088cde, 0x089cb3
# InitializeBlock04  (CPU 0x48489cb3)
.incbin_range "baserom/kn7000_program.rom", 0x089cb3, 0x08a4d8
# InitializeBlock03  (CPU 0x4848a4d8)
.incbin_range "baserom/kn7000_program.rom", 0x08a4d8, 0x08a9b8
# InitializeBlock06  (CPU 0x4848a9b8)
.incbin_range "baserom/kn7000_program.rom", 0x08a9b8, 0x09327b
# InitializeBlock02  (CPU 0x4849327b)
.incbin_range "baserom/kn7000_program.rom", 0x09327b, 0x0971f1
# InitializeBlock05  (CPU 0x484971f1)
.incbin_range "baserom/kn7000_program.rom", 0x0971f1, 0x09cb19
# InitializeBlock07  (CPU 0x4849cb19)
.incbin_range "baserom/kn7000_program.rom", 0x09cb19, 0x09eea0
# InitializeBlock21  (CPU 0x4849eea0)
.incbin_range "baserom/kn7000_program.rom", 0x09eea0, 0x09f85b
# InitializeBlock15  (CPU 0x4849f85b)
.incbin_range "baserom/kn7000_program.rom", 0x09f85b, 0x0a5e36
# InitializeBlock17  (CPU 0x484a5e36)
.incbin_range "baserom/kn7000_program.rom", 0x0a5e36, 0x0a8970
# InitializeBlock16  (CPU 0x484a8970)
.incbin_range "baserom/kn7000_program.rom", 0x0a8970, 0x0cef78
# InitializeBlock23  (CPU 0x484cef78)
.incbin_range "baserom/kn7000_program.rom", 0x0cef78, 0x0d544e
# InitializeBlock24  (CPU 0x484d544e)
.incbin_range "baserom/kn7000_program.rom", 0x0d544e, 0x0d5f18
# InitializeBlock25  (CPU 0x484d5f18)
.incbin_range "baserom/kn7000_program.rom", 0x0d5f18, 0x0d7bbd
# InitializeBlock26  (CPU 0x484d7bbd)
.incbin_range "baserom/kn7000_program.rom", 0x0d7bbd, 0x0f9897
# InitializeBlock18  (CPU 0x484f9897)
.incbin_range "baserom/kn7000_program.rom", 0x0f9897, 0x0fdc59
# InitializeBlock22  (CPU 0x484fdc59)
.incbin_range "baserom/kn7000_program.rom", 0x0fdc59, 0x106b62
# InitializeBlock10  (CPU 0x48506b62)
.incbin_range "baserom/kn7000_program.rom", 0x106b62, 0x10747d
# InitializeBlock08  (CPU 0x4850747d)
.incbin_range "baserom/kn7000_program.rom", 0x10747d, 0x110daa
# InitializeBlock09  (CPU 0x48510daa)
.incbin_range "baserom/kn7000_program.rom", 0x110daa, 0x1164fe
# InitializeBlock28  (CPU 0x485164fe)
.incbin_range "baserom/kn7000_program.rom", 0x1164fe, 0x116866
# InitializeBlock19  (CPU 0x48516866)
.incbin_range "baserom/kn7000_program.rom", 0x116866, 0x134200
# InitializeBlock13  (CPU 0x48534200)
.incbin_range "baserom/kn7000_program.rom", 0x134200, 0x14d8ab
# InitializeBlock27  (CPU 0x4854d8ab)
.incbin_range "baserom/kn7000_program.rom", 0x14d8ab, 0x14e3fc
# GetDefaultWindowID  (CPU 0x4854e3fc)
.incbin_range "baserom/kn7000_program.rom", 0x14e3fc, 0x14ea2c
# InitializeBlock32  (CPU 0x4854ea2c)
.incbin_range "baserom/kn7000_program.rom", 0x14ea2c, 0x1661a0
# InitializeBlock11  (CPU 0x485661a0)
.incbin_range "baserom/kn7000_program.rom", 0x1661a0, 0x16d087
# InitializeBlock12  (CPU 0x4856d087)
.incbin_range "baserom/kn7000_program.rom", 0x16d087, 0x172f46
# InitializeBlock33  (CPU 0x48572f46)
.incbin_range "baserom/kn7000_program.rom", 0x172f46, 0x17dd90
# InitializeBlock34  (CPU 0x4857dd90)
.incbin_range "baserom/kn7000_program.rom", 0x17dd90, 0x181ec1
# InitializeBlock14  (CPU 0x48581ec1)
.incbin_range "baserom/kn7000_program.rom", 0x181ec1, 0x183606
# InitializeBlock39  (CPU 0x48583606)
.incbin_range "baserom/kn7000_program.rom", 0x183606, 0x1844eb
# InitializeBlock40  (CPU 0x485844eb)
.incbin_range "baserom/kn7000_program.rom", 0x1844eb, 0x186000

# ---- data / resources region ----
.incbin_range "baserom/kn7000_program.rom", 0x186000, 0x32573C

# ---- display palette (256-entry 0x00RRGGBB CLUT + a themed sub-range) ----
display_palette:
    .long 0x00000000, 0x00000080, 0x00008000, 0x00008080, 0x00800000, 0x00800080, 0x00808000, 0x00808080   # idx   0
    .long 0x00303030, 0x000080FF, 0x000048FF, 0x00004080, 0x0038FF68, 0x00000000, 0x00C8C8C8, 0x00808080   # idx   8
    .long 0x000048FF, 0x000048FF, 0x00000000, 0x0060FFFF, 0x00FFFF90, 0x00FF90FF, 0x0060FF60, 0x00800000   # idx  16
    .long 0x00808080, 0x0000FFFF, 0x000048FF, 0x0000FFFF, 0x000048FF, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  24
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  32
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  40
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  48
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  56
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  64
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  72
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  80
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  88
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  96
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 104
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 112
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 120
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 128
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 136
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 144
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 152
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 160
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 168
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 176
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 184
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 192
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 200
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 208
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 216
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 224
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 232
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x00808080, 0x00000000, 0x00C0FFC0, 0x00408040   # idx 240
    .long 0x00585858, 0x000000FF, 0x0000FF00, 0x0000FFFF, 0x00FF0000, 0x00FF00FF, 0x00FFFF00, 0x00C8C8C8   # idx 248
    .long 0x00FF0000, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FFA0A0, 0x00FF6060, 0x00FF6060, 0x00FFA0A0   # idx 256
    .long 0x00FF0000, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF0000, 0x00FFFFFF, 0x00FF0000, 0x00FF0000   # idx 264
    .long 0x00FFFFFF, 0x00FF0000, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FF0000   # idx 272
    .long 0x00FFA0A0, 0x00FFFFFF, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 280
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 288
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 296
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 304
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 312
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 320
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 328
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 336
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 344
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 352
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 360
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 368
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 376
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 384
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 392
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 400
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 408
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 416
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 424
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 432
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 440
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 448
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 456
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 464
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 472
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 480
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 488
    .long 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF0000, 0x00FF0000, 0x00FF0000   # idx 496
    .long 0x00FF6060, 0x00FF6060, 0x00FFA0A0, 0x00FFA0A0, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FFFFFF   # idx 504
.org 0x325F3C
.incbin_range "baserom/kn7000_program.rom", 0x32573C + 0x800, 0x3B8000

# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4) ----
.incbin_range "baserom/kn7000_program.rom", 0x3B8000, 0x3F6F01

.org 0x3F6F01   # end of image
