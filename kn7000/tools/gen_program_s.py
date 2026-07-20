#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/program.s. Code region 1 is split at the recovered function
# boundaries (kn7000.sym reflection names + kn7000_manual.sym hand-recovered
# names). Functions named in CONVERT are emitted as REAL MN10300 assembly
# (via MAME unidasm for the mnemonics, verified byte-exact with the mn10300_asm
# encoder); every other function stays a raw .incbin_range block. Instructions
# the encoder can't reproduce (a handful of compiler non-minimal encodings and
# udf* coprocessor ops) fall back to a .byte escape, so the rebuild is always
# byte-identical.  Run:  make program-src   (or python3 tools/gen_program_s.py)

import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as ASM

BASE = 0x48400000
# The "library ROM" is NOT a separate chip: the boot copies file offset
# 0x3B8FD1.. of this image to 0x4C000000 (via the 0x8C000000 alias) and runs it
# there -- kn7000_mame/notes/library-rom-loading.md. Library code is therefore
# linked for 0x4C000000: converted lib functions are emitted under a shifted
# .mnbase so PC-relative encodings reproduce byte-exactly.
LIB_FILE_BASE = 0x3B8FD1
LIB_CPU_BASE = 0x4C000000
LIB_DELTA = LIB_CPU_BASE - LIB_FILE_BASE   # cpu addr = file offset + delta
ROM = "baserom/kn7000_program.rom"
SYM = "kn7000.sym"
MANUAL_SYM = "kn7000_manual.sym"
UNIDASM = os.environ.get("UNIDASM", "../mame-sony-video/unidasm")
OUT = "src/program.s"

# Functions to emit as real assembly this pass (verified clusters). Growing this
# set converts more of the ROM from opaque .incbin into understood source.
CONVERT = {
    # task control
    "SleepMainTask", "WakeUpMainTask", "SleepApTask", "WakeUpApTask",
    "RefreshApTask", "RefreshSwEvent",
    # event queue / dispatch
    "InitializeEventQueue", "DispatchEvent", "SendEvent", "PostEvent",
    "DeleteSpecificEvent", "GetEvent", "GetCurrentTarget", "GetRootEvent",
    "SetFocusParam", "SetAutoInc", "KillApTimer", "GetRootObject",
    # object / view property accessors (these call the hot framework helper
    # GetLinkView, so the converted code shows readable named calls)
    "SetVisible", "SetMovable", "SetChange", "SetConst", "GetJpegSize",
    "ConvPaletteMono4", "VwEditSwLabelProc", "ScreenProc", "CaptureLcd",
    "DrawDesignBox", "PsUsrBmpToggleProc", "MusicStylistJpgData",
    "SetNeedUpdate", "SetDialFocus", "GetFrameSPSize", "GetCharHeight",
    "GetBitmapSize", "GetCharDescent", "CheckColorLcd", "SetLcdMode",
    # display / LCD / bitmap-resource accessor module
    "Check2BitLcd", "GetColorMode", "GetSoundDev", "GetBitmapCount",
    "GetIconCount", "GetFrameCount", "GetFontCount", "GetBitmapNameTable",
    "GetIconNameTable", "GetFrameNameTable", "GetSw2Mode", "GetMode2Sw",
    "GetModeNow", "GetTitleNow", "GetTitleOld", "GetViewInstance",
    "SetCurrentTarget", "SetBox", "SetDialEnable", "SetDialUp",
    "CheckProgDial", "SetProgDial", "GetColorMode", "SetHoldLed",
    "SetOtherPartLed", "GetRootParam", "SetRootParam", "CheckNotDrawFlag",
    "GetSw2Mode", "SetAutoIncDefault",
    # Techni-Chord harmony engine (kn7000_manual.sym names; RE'd in kn5000-docs
    # /kn7000-technichord/ + the users manual, corrected style mapping -- the
    # style param 0x8081 is a legacy order mapped to the GUI grid by the
    # 14-halfword table 0x485EC940; DUET 1 is stored last, param 13)
    "TechniChordOrchestratorPart", "TechniChordCompute",
    "TechniChordClose", "TechniChordDuet1", "TechniChordOpen1",
    "TechniChordOpen2", "TechniChordDuet2", "TechniChordCountry",
    "TechniChordTheatre", "TechniChordHymn", "TechniChordBlock",
    "TechniChordBigBandBrass", "TechniChordBigBandReeds", "TechniChordOctave",
    "TechniChordHardRock", "TechniChordFanfare", "TechniChordOff",
    "TechniChordAugDimFold",
    # Control-panel serial transport + frame decode + button dispatch
    # (kn7000_manual.sym names; RE'd in kn7000_mame/notes/panel-serial-protocol.md
    # -- the boot-handshake bring-up chain and the switch-report wire format)
    "PanelTransaction", "PanelSignOnRequest", "PanelInitHookNop",
    "PanelStatusPoll", "PanelWaitLinkIdle", "PanelTxKick",
    "PanelAtnIsr", "PanelTxDoneIsr", "PanelRxIsr",
    "PanelTxState1", "PanelTxState2", "PanelTxState3", "PanelTxState4",
    "PanelTxState5", "PanelTxState6", "PanelRxState8", "PanelRxState9",
    "PanelXferIdleState", "PanelLinkRxRearm", "PanelTxPump",
    "PanelLedMirrorResetA", "PanelHeaderValidate", "PanelErrorRecovery",
    "PanelRxDecodeExpect", "PanelRxDecodeQuiet", "PanelFrameDecode",
    "PanelButtonDispatch",
    # SD-card subsystem, layer 1: the disk worker task + message plumbing
    # (kn7000_manual.sym names; RE'd in kn7000_mame/notes/sd-card-emulation-plan.md)
    "DiskInit", "DiskWorkerStatusClear", "DiskWorkerTask",
    "DiskCmdReplyCopy", "DiskCmdTransact", "DiskCmdPostAsync",
    "SdWorkerCmdHandler",
    # layer 2: driver state + card init/identify
    "SdMediaStateGet", "SdMediaStateSet", "SdDrvPhaseSet", "SdDrvPhaseGet",
    "SdDrvRecordsReset", "SdProbeFlagGet", "SdCardReadyCheck",
    "SdCardDetectPoll", "SdCardInitFull", "SdCardInfoReset", "SdCardIdentify",
    # layer 3: the SPI transport on the 0x9805000C mailbox + slot GPIO
    "DriveLetterClass", "SdHwInit", "SdSpiPortSetup", "SdSpiClockSet",
    "SdCsAssertWrap", "SdCsRelease", "SdCsAssert", "SdDetectPortInit",
    "SdCardDetectRaw", "SdCardDetectDebounce",
    "SdPowerLineSet", "SdPowerLineClear", "SdPowerRailSet", "SdPowerRailClear",
    "SdSlotDrainWait", "SdSlotDischarge", "SdSlotSenseGet",
    "SdWriteProtectGet", "SdSlotRelease",
    "SdSpiSendByte", "SdSpiSendBuf", "SdSpiRecvByte", "SdSpiRecvBuf",
    "SdSpinDelay", "SdSpiClockBurst",
    "SdResponseScan", "SdWaitNotBusy", "SdSenseBusyWait", "SdDataRespWait",
    "SdTokenWait", "SdCommandSend", "SdCrcSelfTest",
    "SdReadBlockCmd", "SdWriteBlockCmd", "SdCsdBitfield",
    "SdDataCrc16", "SdCmdCrc7",
    "SdPowerCtrlSet", "SdPowerCtrlClear", "SdPowerCtrlWrite",
    # layer 4: the UI-side mount state machine
    "SdStateReset", "SdUnmountCleanup", "SdStateResetCall",
    "SdCardInsertMsgHandler", "SdStateMachineTick",
    "SdMountWorker", "SdMountDone", "SdSyncWorker", "SdSyncDone",
    "SdMountSyncPost", "SdUiMountGateCheck", "SdMountBusyCheck",
    "SdErrorFlagsGet", "SD_SetState", "SD_GetState", "SdCardFsInit",
    # Tempo / TM5 clock module: the 96-PPQN sequencer timebase + the metronome
    # + the MIDI realtime sync (kn7000_manual.sym names; RE'd in
    # kn7000_mame/notes/sequenced-playback-and-style-data-rootcause.md root
    # cause 1, modeled in the MAME driver commit 60d5392)
    "TempoModuleBoot", "TempoHookNop", "MidiRealtimeModeSet",
    "MidiRealtimeModeGet", "TempoClockSourceSet", "TempoClockSourceClear",
    "TempoClockSourceGet", "TempoSyncParamDispatch",
    "MetronomeClickPost", "MetronomeStateReset", "MetronomeVoiceInit",
    "MetronomeClickRateSet", "MetronomeBeatTask", "MetronomeNoteEvent",
    "TempoClkStartApply", "TempoClkStopApply", "TempoClkAdvance",
    "TempoClkAdvanceExtHold", "TempoClkMidiClockStep", "MidiRealtimeSend",
    "TempoClocksReset", "TempoClkArmRestart", "TempoClkStartNow",
    "TempoClkArmContinue", "TempoClkContinueNow", "TempoClkStopRequest",
    "TempoClkStopNow", "TempoClkBeatStopRequest", "TempoTick96Isr",
    "MidiClockRxHandler", "MidiStartRxHandler", "MidiContinueRxHandler",
    "MidiStopRxHandler", "Tm5TempoTimerStart", "Tm5TempoIsrRegister",
    "TempoTimerInit", "TempoBpmReloadWrite", "TempoReloadFromInterval",
    "Tm5TimerRestart",
    # Tempo-sync parameter layer (params 0xD001-0xD003 + the 0x70xxxx property
    # group; sits directly after Tm5TimerRestart)
    "TempoSyncD001Set", "TempoSyncD002Set", "TempoSyncD002Apply",
    "TempoSyncD003Set", "TempoSyncModeASet", "TempoSyncModeBSet",
    "TempoSyncPartB0Set", "TempoSyncE000Set", "TempoSyncSetDispatch",
    # TG-present strap probe (read by the TG cold bring-up TgChipResetSideA/B)
    "TgStrapProbe", "TgStrapProbeZero", "TgStrapProbeSideB",
    # the region-1 voice-resource bank fetchers the library's shadow builders
    # call across the region boundary
    "VoiceRecFetchBanked", "VoiceSubRecFetch", "VoiceModRecDefaultPtr",
    "VoiceRecDefaultPtr", "VoiceSubRecDefaultPtr", "VoiceElemRecFetchBank0",
    "VoiceModRecFetch", "VoiceElemRecFetch",
    # the five voice-resource BANK SOURCES + the MIDI-keyed classifier
    # (notes/sound-bank-classes.md)
    "VoiceBankClassify", "VoiceBankLookupInternal", "VoiceBankLookupSrc1",
    "VoiceBankLookupSrc2", "VoiceBankLookupSrc3", "VoiceBankLookupSrc4",
    "VoiceBankKeyEqual", "VoiceBankHashIndex",
    "VoiceParamBankClassify", "VoiceParamBankLookupInternal",
    "VoiceParamBankLookupSrc1", "VoiceParamBankLookupSrc2",
    "VoiceParamBankLookupSrc3", "VoiceParamBankLookupSrc4",
    "VoiceParamBankKeyEqual", "VoiceParamBankHashIndex",
    "VoiceBankSourcePresent", "VoiceBankSourcePresentAlt",
    "VoiceBankSourceQuery", "VoiceBankSourceFlagGet",
    "VoiceBankSourceFlagStubB", "VoiceBankSourceFlagStubC",
    "VoiceParamRecFetchBanked", "CustomVoiceRecFetch", "UserVoiceRecPtr",
    # the VOICE-LIST INDEX layer: three more per-archive hash directories plus
    # the byte-attribute one, and the two global index spaces the tone/drum
    # SELECTION GRIDS address sounds by (notes/sound-bank-classes.md)
    "VoiceAttrClassify", "VoiceAttrLookupInternal", "VoiceAttrLookupSrc1",
    "VoiceAttrLookupSrc2", "VoiceAttrLookupSrc3", "VoiceAttrLookupSrc4",
    "VoiceAttrKeyEqual", "VoiceAttrHashIndex", "VoiceAttrByteGet",
    "VoiceListIndexOfBank", "VoiceListIndexLookupInternal",
    "VoiceListIndexLookupSrc1", "VoiceListIndexLookupSrc2",
    "VoiceListIndexLookupSrc3", "VoiceListIndexLookupSrc4",
    "VoiceListIndexKeyEqual", "VoiceListIndexHashIndex",
    "VoiceArchiveKindByte", "VoiceArchiveKindByteAlt",
    "VoiceListEntryByIndex", "VoiceListEntryLookupInternal",
    "VoiceListEntryLookupSrc1", "VoiceListEntryLookupSrc2",
    "VoiceListEntryLookupSrc3", "VoiceListEntryLookupSrc4",
    "VoiceListEntryKeyEqual", "VoiceListEntryHashIndex",
    "VoiceListIndexMapAtoB", "VoiceArchiveCountA", "VoiceArchiveCountB",
    "VoiceListMapLookupInternal", "VoiceListMapLookupSrc1",
    "VoiceListMapLookupSrc2", "VoiceListMapLookupSrc3",
    "VoiceListMapLookupSrc4", "VoiceListMapKeyEqual", "VoiceListMapHashIndex",
    # the BOOT ARCHIVE PARSER that decides which of the four expansion voice
    # archives are fitted (notes/sound-bank-classes.md "How sources 1..4 are
    # validated"): four near-identical blocks, one per window
    "VoiceArchiveScanBoot",
    # ---- the RHYTHM/STYLE NAME MODULE 0x484332F9..0x48433C1E plus the
    #      resource WINDOW PROBE and the table-ROM segment accessors
    #      (notes/sequenced-playback-and-style-data-rootcause.md 2a) ----------
    "StyleBuiltinNameTableInit", "StyleNameSourceSet", "StyleNameCommit",
    "StyleNameCommitMem", "StyleNameCommitCustom", "StyleVariationNameGet",
    "StyleRecordSlotSelect", "StyleRecordBindBuiltin", "StyleRecordBindMem",
    "StyleRecordBindCustom", "StyleNameModuleBoot", "StyleResourceVerify",
    "StyleNameSelectCommit", "StyleSlotRecordDiffers", "StyleRecordSelectBind",
    "StyleNameAndRecordSelect", "StyleNameBufCopy", "StyleBoundRecByteCfGet",
    "StyleBoundRecByteCeInc", "StyleBoundRecByteCfLow3",
    "StyleVariationNameFlagGet", "StyleBuiltinNameResolve",
    "StyleResourceWindowProbe", "TableRomStyleSubTablePtr",
    "TableRomStyleResourcePtr", "TableRomSeg04Ptr", "TableRomNullPtr",
    "TableRomSeg01PtrSize", "TableRomSeg02PtrSize", "TableRomSeg03PtrSize",
    "TableRomOneStub",
}

# A converted function whose named block extends past its real end (because the
# next named boundary is far away) can cap the converted range here; the
# remainder of the block stays raw .incbin_range.
FUNC_END = {
    "TechniChordAugDimFold": 0x737D2,   # next (unnamed) function at 0x484737D2
    "SdErrorFlagsGet": 0x152257,        # next (unnamed) function at 0x48552257
    "SdCardFsInit": 0x1630E6,           # next (unnamed) function at 0x485630E6
    "TempoSyncParamDispatch": 0x45358,  # next (unnamed) function at 0x48445358
    "TempoSyncSetDispatch": 0x47F33,    # next (unnamed) function at 0x48447F33
    "TgStrapProbeSideB": 0xD774E,       # next (unnamed) function at 0x484D774E
    "VoiceElemRecFetch": 0x49925,       # next (unnamed) function at 0x48449925
    "VoiceParamRecFetchBanked": 0x499E9,   # next (unnamed) function at 0x484499E9
    "VoiceBankHashIndex": 0x17176B,        # next (unnamed) function at 0x4857176B
    "VoiceParamBankHashIndex": 0x171056,   # next (unnamed) function at 0x48571056
    "VoiceBankSourceQuery": 0x48C45,       # next (unnamed) function at 0x48448C45
    "VoiceBankSourceFlagStubC": 0x4A3F6,   # next (unnamed) function at 0x4844A3F6
    "CustomVoiceRecFetch": 0x4A47A,        # next (unnamed) function at 0x4844A47A
    "UserVoiceRecPtr": 0x4AC0D,            # next (unnamed) function at 0x4844AC0D
    "VoiceAttrByteGet": 0x49B3B,           # next (unnamed) function at 0x48449B3B
    "VoiceListMapHashIndex": 0x172607,     # next (unnamed) function at 0x48572607
    "StyleBuiltinNameResolve": 0x33C1E,    # next (unnamed) function at 0x48433C1E
    "TableRomOneStub": 0x3D834,            # next (unnamed) function at 0x4843D834
}

# Library-image functions to convert (CPU start, CPU end-exclusive). These live
# in code region 2 and execute at 0x4C000000; boundaries are explicit because
# the lib region has no reflection name table.
LIB_CONVERT = {
    "LibDiv32":           (0x4C0019D5, 0x4C0019F2),
    # ---- the SOFT-FLOAT IEEE-754 double runtime + libm subset (the firmware
    #      has no FPU: TgPartGlidePlan/Tick and others do their math here;
    #      args on the caller's stack at (8,sp) lo/(0xC,sp) hi and
    #      (0x10,sp)/(0x14,sp), result in d0 lo : d1 hi; errno = 0x500AD390)
    "LibF64Pow":          (0x4C000000, 0x4C000263),
    "LibF64UnpackedToI32": (0x4C000263, 0x4C0002B3),
    "LibF64ToI32":        (0x4C0002B3, 0x4C0002CB),
    "LibF64Unpack":       (0x4C0002CB, 0x4C000311),
    "LibF64Log":          (0x4C000311, 0x4C000523),
    "LibI32ToF64":        (0x4C000523, 0x4C00057D),
    "LibF64Sub":          (0x4C00057D, 0x4C00058E),
    "LibF64Add":          (0x4C00058E, 0x4C0007E2),
    "LibF64Cmp":          (0x4C0007E2, 0x4C000851),
    "LibF64CmpZero":      (0x4C000851, 0x4C000874),
    "LibF64Mul":          (0x4C000874, 0x4C000B17),
    "LibF64Div":          (0x4C000B17, 0x4C000CD3),
    "LibF64Ldexp":        (0x4C000CD3, 0x4C000D54),
    "LibF64Frexp":        (0x4C000D54, 0x4C000D99),
    "LibF64Exp":          (0x4C000D99, 0x4C000F54),
    "LibU32ToF64":        (0x4C000F54, 0x4C000F8F),
    "LibF64Abs":          (0x4C000F8F, 0x4C000FA7),
    "LibF64Modf":         (0x4C000FA7, 0x4C00104C),
    "LibF64ToI16":        (0x4C001624, 0x4C00163D),
    "LibU16ToF64":        (0x4C0016AC, 0x4C0016B0),
    "LibI16ToF64":        (0x4C0019F2, 0x4C0019F6),
    # ---- the melodic zone param fetchers under TgElemNoteOnFresh/Std
    #      (tone-zone desc2 bytes -> shadow-image level/velo/send/filter-EG
    #      fields; sensitivity curve ROM 0x486D2713, key-scale pair
    #      0x486D1354/0x486D13D4) -------------------------------------------
    # ---- SOUND EDIT: the nine uniform FLAG REFRESHERS that copy single bits
    #      (and two whole bytes) out of the part-setting record
    #      0x500B5340+part*0x54C into the SOUND EDIT record
    #      0x500C0784+(part-0x10)*0x2C8. All nine are gated on part 0x10..0x12
    #      and on 0x4C00C6BF(part). Section 3 of
    #      kn7000_mame/notes/sound-edit-parameters.md ---------------------
    "TgSoundEditFlag4DBit7Refresh": (0x4C00EDE4, 0x4C00EE41),
    "TgSoundEditFlag4DLowRefresh":  (0x4C00EE41, 0x4C00EE9A),
    "TgSoundEditFlag4EBit7Refresh": (0x4C00EE9A, 0x4C00EEF7),
    "TgSoundEditFlag4ELowRefresh":  (0x4C00EEF7, 0x4C00EF4B),
    "TgSoundEditFlag4FBit7Refresh": (0x4C00EF4B, 0x4C00EFA8),
    "TgSoundEditFlag51Bit7Refresh": (0x4C00EFA8, 0x4C00F04E),
    "TgSoundEditFlag51LowRefresh":  (0x4C00F04E, 0x4C00F0A2),
    "TgSoundEditByte52Refresh":     (0x4C00F0A2, 0x4C00F0E6),
    "TgSoundEditByte53Refresh":     (0x4C00F0E6, 0x4C00F12A),
    "TgZoneParamClamp":   (0x4C00FD4C, 0x4C00FD68),
    "TgZoneLevelScaleCalc": (0x4C00FD68, 0x4C00FE03),
    "TgZoneVeloSenseCalc": (0x4C00FE03, 0x4C00FE4D),
    "TgZoneSendLevelsCalc": (0x4C00FE4D, 0x4C00FF44),
    "TgZoneFilterEgLevel1Calc": (0x4C00FF44, 0x4C00FF9A),
    "TgZoneFilterEgLevel2Calc": (0x4C00FF9A, 0x4C00FFF0),
    "TgZoneFilterEgLevelCalc": (0x4C00FFF0, 0x4C010042),
    # ---- their byte-for-byte KIT/TABLE twins under TgKitElemNoteOn ---------
    "TgKitZoneParamClamp": (0x4C011F2F, 0x4C011F4B),
    "TgKitZoneLevelScaleCalc": (0x4C011F4B, 0x4C011FE6),
    "TgKitZoneVeloSenseCalc": (0x4C011FE6, 0x4C012030),
    "TgKitZoneSendLevelsCalc": (0x4C012030, 0x4C012127),
    "TgKitZoneFilterEgLevel1Calc": (0x4C012127, 0x4C01217D),
    "TgKitZoneFilterEgLevel2Calc": (0x4C01217D, 0x4C0121D3),
    "TgKitZoneFilterEgLevelCalc": (0x4C0121D3, 0x4C012225),
    "TgPartElemLastSet":  (0x4C012225, 0x4C012254),
    "TgStageHeldPolicyShed": (0x4C0147AD, 0x4C014803),
    "TgVoicePoolReset":   (0x4C014803, 0x4C014943),
    # ---- the raw EG/shadow param helpers + the routing-field writer --------
    "TgVoiceEgSegParamGet": (0x4C03A20F, 0x4C03A2BD),
    "TgVoiceEgSegFlagTest": (0x4C03A2BD, 0x4C03A310),
    "TgVoiceRouteFieldSet": (0x4C037C16, 0x4C037C90),
    # ---- the TG voice allocator + steal engine under TgNoteOn (element
    #      staging -> side select -> hw slot pick w/ ROM steal-order lists;
    #      kn7000_mame/notes/tg-voice-allocator.md) ---------------------------
    "TgPartElemMaskUpdate": (0x4C00ECA1, 0x4C00ECEA),
    "TgPartElemMaskGet":  (0x4C00ECEA, 0x4C00ECFF),
    "TgPartElemEnabled":  (0x4C00ECFF, 0x4C00ED20),
    "TgPartElemLastClear": (0x4C012254, 0x4C01226C),
    "TgPartElemLastGet":  (0x4C01226C, 0x4C01227F),
    "TgVoiceRoutePtrCalc": (0x4C02BE45, 0x4C02BECB),
    "TgVoiceSideSelect":  (0x4C02BECB, 0x4C02BF32),
    "TgPartPitchWordCalc": (0x4C02BF32, 0x4C02BF86),
    "TgPartHoldQuery":    (0x4C02E0F3, 0x4C02E2C1),
    "TgPartHoldMark":     (0x4C02E2C1, 0x4C02E5A7),
    "TgPitchZoneFold":    (0x4C02FB25, 0x4C02FB79),
    "TgPitchNoteResolve": (0x4C02FB79, 0x4C02FBDE),
    "TgLevelResolve":     (0x4C02FBDE, 0x4C02FCBA),
    "TgElemStageFresh":   (0x4C034927, 0x4C034BA4),
    "TgElemStageRestrike": (0x4C034BA4, 0x4C034E58),
    "TgElemRequestFlags": (0x4C034E58, 0x4C034FF0),
    "TgMelodicVoiceAlloc": (0x4C034FF0, 0x4C035879),
    "TgDrumStageStd":     (0x4C035879, 0x4C03595A),
    "TgDrumNoteOnStd":    (0x4C03595A, 0x4C035BE0),
    "TgDrumStageTable":   (0x4C035BE0, 0x4C035CC4),
    "TgDrumReqFlagsTable": (0x4C035CC4, 0x4C035D1C),
    "TgDrumNoteOnTable":  (0x4C035D1C, 0x4C035EA5),
    "TgTableToneStage":   (0x4C035EA5, 0x4C03600D),
    "TgNodeRingSeed":     (0x4C03A779, 0x4C03A78D),
    "TgNodeRingInsert":   (0x4C03A78D, 0x4C03A7AC),
    "TgVoiceNodeToClassRing": (0x4C03A7AC, 0x4C03A80A),
    "TgNodeFreeUnlink":   (0x4C03A80A, 0x4C03A825),
    "TgNodeFreeInsert":   (0x4C03A825, 0x4C03A84D),
    "TgVoiceNodeToOrderList": (0x4C03A84D, 0x4C03A8E3),
    "TgNodeSlotUnlink":   (0x4C03A8E3, 0x4C03A8FE),
    "TgNodeSlotInsert":   (0x4C03A8FE, 0x4C03A926),
    "TgVoiceNodeRetire":  (0x4C03A926, 0x4C03AA06),
    "TgVoiceNodeFadeKick": (0x4C03AA06, 0x4C03AA31),
    "TgVoiceNodeReleaseStep": (0x4C03AA31, 0x4C03AA81),
    "TgVoiceStatusSweep": (0x4C03AA81, 0x4C03AC8C),
    "TgNodeScanSideA":    (0x4C03AC8C, 0x4C03ACA8),
    "TgNodeScanSideB":    (0x4C03ACA8, 0x4C03ACC4),
    "TgVoiceNodePick":    (0x4C03ACC4, 0x4C03AD9F),
    "TgVoiceMigrateFind": (0x4C03AD9F, 0x4C03AE02),
    "TgSlotAllocate":     (0x4C03AE02, 0x4C03B0C8),
    "TgVoiceNodeKeyOff":  (0x4C03B0C8, 0x4C03B12B),
    # ---- the TG note path: key event -> note-on -> per-element EG/release
    #      programming (tg-pitch-pipeline.md + tg-envelope-sweep-results.md) --
    "TgExclGroupChoke":   (0x4C03099F, 0x4C030A7F),
    "TgTotalLevelCalc":   (0x4C030A7F, 0x4C030A98),
    "TgElemNoteOnStd":    (0x4C030A98, 0x4C030E6E),
    "TgVoiceKillHandler": (0x4C030E6E, 0x4C030FB4),
    "TgPitchInitCalc":    (0x4C030FB4, 0x4C031122),
    "TgPitchRuntimeCalc": (0x4C031122, 0x4C0311F1),
    "TgKeyOffAmpRelease": (0x4C031944, 0x4C031C4B),
    "TgPitchEgAttackCalc": (0x4C031C4B, 0x4C031D96),
    "TgPitchEgDecayCalc":  (0x4C031D96, 0x4C031F02),
    "TgKeyOffPitchRelease": (0x4C031F02, 0x4C0321BA),
    "TgFilterEgAttackCalc":  (0x4C0321BA, 0x4C03231A),
    "TgFilterEgDecayCalc":   (0x4C03231A, 0x4C03248B),
    "TgKeyOffFilterRelease": (0x4C03248B, 0x4C032747),
    "TgNoteOnTableTone":  (0x4C03600D, 0x4C036187),
    "TgKeyOffSample":     (0x4C03656E, 0x4C0365FD),
    "TgNoteOn":           (0x4C036832, 0x4C036D3A),
    "TgVoiceSlotService": (0x4C036D3A, 0x4C036E9E),
    "TgPartKeyEvent":     (0x4C036E9E, 0x4C036F98),
    "TgVoiceRegWrite":    (0x4C036F98, 0x4C036FE5),
    "TgVoiceRegWriteB":   (0x4C036FE5, 0x4C037008),
    "TgGlobalRegWriteBoth": (0x4C037008, 0x4C037037),
    "TgGlobalRegWriteB":  (0x4C037037, 0x4C03705A),
    "TgCmdReadA":         (0x4C03705A, 0x4C037082),
    "TgCmdReadB":         (0x4C037082, 0x4C0370AA),
    "TgVoiceStatusRead":  (0x4C0370AA, 0x4C0370F3),
    "TgVoiceRecordReset": (0x4C0370F3, 0x4C037123),
    "TgVoiceRecordPtr":   (0x4C037123, 0x4C037135),
    "TgVoiceGateOn":      (0x4C037393, 0x4C037694),
    "TgVoiceGateOnWrap":  (0x4C037694, 0x4C0376A0),
    "TgVoiceGateOff":     (0x4C0376A0, 0x4C0376DE),
    "TgVoiceEgBurstWrite": (0x4C0376DE, 0x4C037759),
    "TgVoiceDirtyAll":    (0x4C037C90, 0x4C037CCC),
    "TgVoiceDirtyRelease": (0x4C037CCC, 0x4C037D0F),
    "LibTickSleep":       (0x4C03DD74, 0x4C03DD98),
    # ---- the TG note-path closure set: per-class note-on/key-off programmers
    #      + the voice-list collect/release engine + the portamento pair
    #      (2026-07-20; kn7000_mame/notes/tg-voice-allocator.md glide section)
    "TgDrumAmpReleaseCalc": (0x4C00AD43, 0x4C00AE3B),
    "TgDrumKeyOffProgram": (0x4C00C0AC, 0x4C00C233),
    "TgPartAuxRecPtr":    (0x4C00C233, 0x4C00C25B),
    "TgVoiceListReleaseByNote": (0x4C010042, 0x4C010068),
    "TgVoiceListCollectByNote": (0x4C010068, 0x4C01008C),
    "TgVoiceListReleasePart": (0x4C01008C, 0x4C0100AC),
    "TgVoiceListCollectPart": (0x4C0100AC, 0x4C0100CB),
    "TgVoiceListCollectPartLive": (0x4C0100CB, 0x4C0100E8),
    "TgVoiceListCollectPart2": (0x4C0100E8, 0x4C010107),
    "TgVoiceListCollectPartAll": (0x4C010107, 0x4C010124),
    "TgVoiceListCollectGlobal": (0x4C010124, 0x4C01013D),
    "TgTableKeyOffProgram": (0x4C0115A5, 0x4C011730),
    "TgKitElemNoteOn":    (0x4C013542, 0x4C013F0A),
    "TgElemKeyOffRelease": (0x4C013F0A, 0x4C014040),
    "TgActiveHighWaterUpdate": (0x4C014784, 0x4C01479A),
    "TgActiveHighWaterReset": (0x4C01479A, 0x4C0147A4),
    "TgLastKeyPartSet":   (0x4C0147A4, 0x4C0147AD),
    "TgPartGlidePlan":    (0x4C02D795, 0x4C02DAF7),
    "TgPartGlideTick":    (0x4C02E5A7, 0x4C02E85D),
    "TgVoiceLevelWordCalc": (0x4C0315CD, 0x4C031627),
    "TgElemNoteOnFresh":  (0x4C033CAE, 0x4C034669),
    "TgKitLayerStage":    (0x4C0365FD, 0x4C0366D2),
    "TgKitLayerNoteOn":   (0x4C0366D2, 0x4C03678A),
    "TgNoteOnKitLayer":   (0x4C03678A, 0x4C036832),
    # ---- the NOTE LEVEL chain + amp-EG rate tails under the note-on
    #      programmers (2026-07-20; the "pitch chain internals" of the
    #      previous pass's notes are in fact the LEVEL side) -----------------
    "TgNoteLevelVariationCalc": (0x4C0311F1, 0x4C03129D),
    "TgVoiceNoteLevelCalc": (0x4C03129D, 0x4C03132B),
    "TgElemLevelBaseCalc": (0x4C03132B, 0x4C0315CD),
    "TgAmpEgAttackRateCalc": (0x4C031627, 0x4C031787),
    "TgAmpEgDecayRatePairCalc": (0x4C031787, 0x4C031944),
    "TgLevelTermFinalize": (0x4C02BF86, 0x4C02C153),
    # ---- the per-part TYPE-7 EG TIME-RAMP module (whole 0x4C011730..
    #      0x4C011F2F gap closed) + its two scaled-cache readers -------------
    "TgPartEgRampInit":   (0x4C011730, 0x4C01180E),
    "TgPartEgRampScaleASet": (0x4C01180E, 0x4C0118E3),
    "TgPartEgRampScaleAGet": (0x4C0118E3, 0x4C0118F5),
    "TgPartEgRampScaleACurve": (0x4C0118F5, 0x4C011910),
    "TgPartEgRampScaleAReset": (0x4C011910, 0x4C0119EA),
    "TgPartEgRampScaleBSet": (0x4C0119EA, 0x4C011ABC),
    "TgPartEgRampScaleBGet": (0x4C011ABC, 0x4C011ACE),
    "TgPartEgRampScaleBCurve": (0x4C011ACE, 0x4C011AE9),
    "TgPartEgRampScaleBReset": (0x4C011AE9, 0x4C011BC0),
    "TgPartEgRampScaleBSet2": (0x4C011BC0, 0x4C011C23),
    "TgPartEgRampScaleBGet2": (0x4C011C23, 0x4C011C35),
    "TgPartEgRampScaleBReset2": (0x4C011C35, 0x4C011C9D),
    "TgPartEgRampTickHeld": (0x4C011C9D, 0x4C011D32),
    "TgPartEgRampTickIdle": (0x4C011D32, 0x4C011DB6),
    "TgPartEgRampReleaseEdge": (0x4C011DB6, 0x4C011E44),
    "TgPartEgRampEngageEdge": (0x4C011E44, 0x4C011EC9),
    "TgPartEgRampDispatchTick": (0x4C011EC9, 0x4C011F2F),
    "TgPartEgRampSegScaled": (0x4C03A310, 0x4C03A389),
    "TgPartEgRampCache54Scaled": (0x4C03A389, 0x4C03A3CD),
    # ---- the per-slot force-off / damp programmers + live EG-time writers --
    "TgVoiceStealSilence": (0x4C037135, 0x4C03723F),
    "TgVoiceForceOff":    (0x4C03723F, 0x4C0372B7),
    "TgVoiceForceOffSoft": (0x4C0372B7, 0x4C037329),
    "TgVoiceDamp7F":      (0x4C037329, 0x4C03735B),
    "TgVoiceDampA2":      (0x4C03735B, 0x4C037393),
    "TgVoiceReg0401Write": (0x4C037A34, 0x4C037A79),
    "TgVoiceReg0405Write": (0x4C037A79, 0x4C037ABE),
    "TgVoiceEgSegRegsWrite": (0x4C037ABE, 0x4C037B1A),
    # ---- the DRUM-side zone param fetchers (third link of the family) ------
    "TgDrumZoneParamClamp": (0x4C009F01, 0x4C009F1D),
    "TgDrumZoneLevelScaleCalc": (0x4C009F1D, 0x4C009FB8),
    "TgDrumZoneVeloSenseCalc": (0x4C009FB8, 0x4C00A002),
    "TgDrumZoneSendLevelsCalc": (0x4C00A002, 0x4C00A0F9),
    "TgDrumFilterEgLevel1Calc": (0x4C00A0F9, 0x4C00A14F),
    "TgDrumFilterEgLevel2Calc": (0x4C00A14F, 0x4C00A1A5),
    "TgDrumFilterEgLevelCalc": (0x4C00A1A5, 0x4C00A1F7),
    "TgNodeRingCollect":  (0x4C03B12B, 0x4C03B15A),
    "TgPartSlotMaskBuild": (0x4C03B15A, 0x4C03B1E5),
    "TgPartPendingFlush": (0x4C03B1E5, 0x4C03B280),
    "TgNodePendingMark":  (0x4C03B280, 0x4C03B2BF),
    "TgNodeRingCollectActive": (0x4C03B2BF, 0x4C03B2F7),
    "TgSlotReleaseKick":  (0x4C03B2F7, 0x4C03B342),
    "TgNodeRingReleaseWalk": (0x4C03B342, 0x4C03B3B0),
    "TgVoiceListBuild":   (0x4C03B3B0, 0x4C03B514),
    # ---- the part CONTROLLER MOD-MATRIX (2026-07-20): six per-destination
    #      sum resolvers (the "level hooks" 0x4C006A17/0x4C00685C of the
    #      earlier notes) + the dest-enable mask/value satellites -------------
    "TgPartModSumPitch":  (0x4C0067CD, 0x4C006857),
    "TgPartModSumLevel":  (0x4C006857, 0x4C0068E1),
    "TgPartModSumFilter": (0x4C0068E1, 0x4C006988),
    "TgPartModSumCutoff": (0x4C006988, 0x4C006A12),
    "TgPartModSumNoteLevel": (0x4C006A12, 0x4C006A9C),
    "TgPartModSumDest40": (0x4C006A9C, 0x4C006B23),
    "TgPartModDestEnableUpdate": (0x4C006B23, 0x4C006BDD),
    "TgPartModDestValueCalc": (0x4C006BDD, 0x4C006ED1),
    # ---- the raw voice-record register writers (the 0x4C037759..0x4C037A34
    #      + 0x4C037B1A..0x4C037C16 gaps around the gate-on/off family) ------
    "TgVoiceEgRegsWriteAuto": (0x4C037759, 0x4C0377FE),
    "TgVoiceReg0102Write": (0x4C0377FE, 0x4C037836),
    "TgVoiceEgRegsWriteRaw": (0x4C037836, 0x4C0378B6),
    "TgVoiceSendWordALevelSet": (0x4C0378B6, 0x4C0378D7),
    "TgVoiceSendWordBLevelSet": (0x4C0378D7, 0x4C0378F8),
    "TgVoiceSendWordsWrite": (0x4C0378F8, 0x4C037930),
    "TgVoiceNoteLevelWrite": (0x4C037930, 0x4C037974),
    "TgVoiceFadeLevelGateOff": (0x4C037974, 0x4C0379EA),
    "TgVoiceReg01WriteGateOff": (0x4C0379EA, 0x4C037A34),
    "TgVoiceEgRate89HiSet": (0x4C037B1A, 0x4C037B4A),
    "TgVoiceEgRate89LoSet": (0x4C037B4A, 0x4C037B70),
    "TgVoiceReg0809Write": (0x4C037B70, 0x4C037BA8),
    "TgVoiceReg4000GroupWrite": (0x4C037BA8, 0x4C037C16),
    # ---- the part TONE/PROGRAM setup module after the EG-ramp readers ------
    "TgPartToneModSetupMelodic": (0x4C03A3CD, 0x4C03A5CD),
    "TgPartToneModSetupDrum": (0x4C03A5CD, 0x4C03A602),
    "TgPartToneModSetupTable": (0x4C03A602, 0x4C03A65B),
    "TgPartToneModSetupDispatch": (0x4C03A65B, 0x4C03A6F2),
    "TgPartProgramSet":   (0x4C03A6F2, 0x4C03A75B),
    "TgPartProgramInitAll": (0x4C03A75B, 0x4C03A779),
    # ---- the LFO/mod runtime engine 0x4C02C153..0x4C02D795 (the region
    #      between TgLevelTermFinalize and TgPartGlidePlan) ------------------
    "TgVoiceZoneVeloResolve": (0x4C02C153, 0x4C02C1ED),
    "TgVoiceZoneVeloGate": (0x4C02C1ED, 0x4C02C236),
    "TgModCurveSquareScale": (0x4C02C236, 0x4C02C25D),
    "TgPartCutoffResolve": (0x4C02C25D, 0x4C02C2C9),
    "TgVoiceModSlotUpdate": (0x4C02C2C9, 0x4C02C6CD),
    "TgPartModDestApply": (0x4C02C6CD, 0x4C02C941),
    "TgPartModDestRefreshAll": (0x4C02C941, 0x4C02CA50),
    "TgPartModValueForElem": (0x4C02CA50, 0x4C02CA74),
    "TgPartModRetrigger": (0x4C02CA74, 0x4C02CB24),
    "TgVoiceReleaseCountdownTick": (0x4C02CB24, 0x4C02CBA4),
    "TgVoiceLevelRampTick": (0x4C02CBA4, 0x4C02CD50),
    "TgPartFadeRatePick": (0x4C02CD50, 0x4C02CD6D),
    "TgVoiceFadeParamsPlan": (0x4C02CD6D, 0x4C02CFE6),
    "TgVoiceModDepthWrite": (0x4C02CFE6, 0x4C02D0A7),
    "TgVoiceModLfoStep":  (0x4C02D0A7, 0x4C02D2B0),
    "TgPartModSlotSweep": (0x4C02D2B0, 0x4C02D52A),
    "TgVoicePeriodicService": (0x4C02D52A, 0x4C02D75F),
    "TgPartGlideStateReset": (0x4C02D75F, 0x4C02D795),
    # ---- the PART TONE APPLY LAYER under TgPartToneModSetup*/TgPartProgram-
    #      Set (the 0x4C038503..0x4C03A20F gap): tone-block accessors, the
    #      voice-record fetch/apply ladders, the program-change rebuild and
    #      the mod-unit parameter builders (2026-07-20) ---------------------
    "TgPartToneProgramGet": (0x4C0384C4, 0x4C0384D9),
    "TgPartToneBankLoGet": (0x4C0384D9, 0x4C0384EE),
    "TgPartToneBankHiGet": (0x4C0384EE, 0x4C038503),
    "TgPartToneDescPtr":  (0x4C038503, 0x4C038515),
    "TgPartToneIsTableClass": (0x4C038515, 0x4C038535),
    "TgPartVoiceRecFetch": (0x4C038535, 0x4C03858D),
    "TgPartVoiceRecFetchSel": (0x4C03858D, 0x4C0385C7),
    "TgPartVoiceRecFetchIdx": (0x4C0385C7, 0x4C03862D),
    "TgPartVoiceRecFetchIdxSel": (0x4C03862D, 0x4C03866F),
    "TgPartElemMapScratchBuild": (0x4C03866F, 0x4C038713),
    "TgPartElemProgramApply": (0x4C038713, 0x4C0387C7),
    "TgPartElemProgramApplySel": (0x4C0387C7, 0x4C038802),
    "TgPartElemProgramApplyIdx": (0x4C038802, 0x4C038871),
    "TgPartElemProgramApplyIdxSel": (0x4C038871, 0x4C0388B3),
    "TgPartProgramHandlerDispatch": (0x4C0388B3, 0x4C03893D),
    "TgPartProgramApply": (0x4C03893D, 0x4C03949F),
    "TgPartToneModUnitBuild": (0x4C03949F, 0x4C0396E2),
    "TgPartToneModParamBuild": (0x4C0396E2, 0x4C0399DB),
    "TgPartModUnitParamGet": (0x4C0399DB, 0x4C039A04),
    "TgPartModUnitRampStep": (0x4C039A04, 0x4C039C5F),
    "TgPartModUnitDepthCurve": (0x4C039C5F, 0x4C039CA0),
    "TgPartToneTypeParamGet": (0x4C039CA0, 0x4C039D7E),
    "TgPartEgRampBuild":  (0x4C039D7E, 0x4C03A20F),
    # ---- the WRITE side of the controller mod matrix: the panel/MIDI
    #      config setter + its value-scaling leaves (2026-07-20) -----------
    "TgPartModRouteMaskSet": (0x4C005673, 0x4C005730),
    "TgModValueScale1":   (0x4C005730, 0x4C005766),
    "TgModValueScale2":   (0x4C005766, 0x4C00579C),
    "TgModValueScale3":   (0x4C00579C, 0x4C0057D2),
    "TgModValueScale4":   (0x4C0057D2, 0x4C00580B),
    "TgModValueScale5":   (0x4C00580B, 0x4C00583E),
    "TgModValueScale6":   (0x4C00583E, 0x4C005874),
    "TgModDepthScaleClamp": (0x4C005874, 0x4C0058B3),
    "TgPartModVoiceApply": (0x4C0058B3, 0x4C005A28),
    "TgPartModVoiceApplyB": (0x4C005A28, 0x4C005CD6),
    "TgPartModVoicesRefreshA": (0x4C005CD6, 0x4C005DBF),
    "TgPartModVoicesRefreshB": (0x4C005DBF, 0x4C005EBB),
    "TgModDepthScaleRom": (0x4C005EBB, 0x4C005EF0),
    "TgPartModVoicesRefreshC": (0x4C005EF0, 0x4C005F6B),
    "TgPartModDepthDefaultSet": (0x4C005F6B, 0x4C00603B),
    "TgPartModConfigStore": (0x4C00603B, 0x4C006333),
    "TgPartModConfigSet": (0x4C006333, 0x4C0067CD),
    # ---- the TG CHIP BRING-UP + the OUTPUT-CHANNEL / GLOBAL register file
    #      (the 0x4C037D0F..0x4C0384C4 gap between the voice-record writers
    #      and the tone-block accessors; 2026-07-20) --------------------------
    "TgChanEgSeg0LevelSet": (0x4C037D0F, 0x4C037D42),
    "TgChanEgSeg0Set":    (0x4C037D42, 0x4C037D87),
    "TgChanEgSeg1LevelSet": (0x4C037D87, 0x4C037DBC),
    "TgChanEgSeg1Set":    (0x4C037DBC, 0x4C037E03),
    "TgChanEgSeg2LevelSet": (0x4C037E03, 0x4C037E37),
    "TgChanEgSeg2Set":    (0x4C037E37, 0x4C037E7D),
    "TgChanEgSeg3LevelSet": (0x4C037E7D, 0x4C037EB2),
    "TgChanEgSeg3Set":    (0x4C037EB2, 0x4C037F0B),
    "TgChanOutLevelPairSet": (0x4C037F0B, 0x4C037F52),
    "TgChanRegHookNop":   (0x4C037F52, 0x4C037F55),
    "TgGlobalRegsA0LoadA": (0x4C037F55, 0x4C037FBB),
    "TgGlobalRegsA0LoadB": (0x4C037FBB, 0x4C038025),
    "TgGlobalRegA000Set": (0x4C038025, 0x4C038043),
    "TgGlobalRegA002Set": (0x4C038043, 0x4C038064),
    "TgGlobalRegsB0LoadA": (0x4C038064, 0x4C038101),
    "TgGlobalRegsB0LoadB": (0x4C038101, 0x4C03819E),
    "TgChipResetSideA":   (0x4C03819E, 0x4C03833A),
    "TgChipResetSideB":   (0x4C03833A, 0x4C0384A8),
    "TgGlobalRegsReloadA": (0x4C0384A8, 0x4C0384C4),
    # ---- the LOCAL-EDIT SHADOW module: the writable per-part edit copies of
    #      the (read-only) tone resource records, their accessors and the
    #      builders that populate them (2026-07-20) ---------------------------
    "TgPartAuxModRecPtr": (0x4C00C25B, 0x4C00C28D),
    "TgPartAuxElemRecPtr": (0x4C00C28D, 0x4C00C2BF),
    "TgPartToneDescScratchPtr": (0x4C00C2BF, 0x4C00C2C8),
    "TgPartLocalEditRecPtr": (0x4C00C2C8, 0x4C00C2DA),
    "TgPartLocalEditModRecPtr": (0x4C00C2DA, 0x4C00C2F9),
    "TgPartLocalEditElemRecPtr": (0x4C00C2F9, 0x4C00C318),
    "TgPartLocalEditActive": (0x4C00C6BF, 0x4C00C6D4),
    "TgPartLocalEditFlagB": (0x4C00C6D4, 0x4C00C6E9),
    "TgPartAuxRecBuild":  (0x4C00C6E9, 0x4C00C763),
    "TgPartToneDescScratchCopy": (0x4C00C763, 0x4C00C783),
    "TgPartLocalEditRecBuild": (0x4C00C783, 0x4C00C7F7),
    "TgPartAuxElemRecBuild": (0x4C00C7F7, 0x4C00C840),
    "TgPartLocalEditElemRecBuild": (0x4C00C840, 0x4C00C890),
    # ---- the three TgPartModRetrigger satellites -------------------------
    # ---- the aux-record FIELD ACCESSORS (leaf get/set pairs; the SOUND EDIT
    #      layer's offset applier 0x4C00A820 drives the ranged ones) ---------
    "TgPartAuxHdr45Get":  (0x4C00C318, 0x4C00C32E),
    "TgPartAuxHdr46Get":  (0x4C00C32E, 0x4C00C344),
    "TgPartAuxHdr47Get":  (0x4C00C344, 0x4C00C35A),
    "TgPartAuxMod04Get":  (0x4C00C35A, 0x4C00C37D),
    "TgPartAuxMod05Get":  (0x4C00C37D, 0x4C00C3A0),
    "TgPartAuxMod06Get":  (0x4C00C3A0, 0x4C00C3C3),
    "TgPartAuxMod19Get":  (0x4C00C3C3, 0x4C00C3E9),
    "TgPartAuxMod28Get":  (0x4C00C3E9, 0x4C00C40C),
    "TgPartAuxMod2AGet":  (0x4C00C40C, 0x4C00C42F),
    "TgPartAuxMod2CGet":  (0x4C00C42F, 0x4C00C452),
    "TgPartAuxMod2EGet":  (0x4C00C452, 0x4C00C475),
    "TgPartAuxHdr45Set":  (0x4C00C475, 0x4C00C48E),
    "TgPartAuxHdr46Set":  (0x4C00C48E, 0x4C00C4A7),
    "TgPartAuxHdr47Set":  (0x4C00C4A7, 0x4C00C4C0),
    "TgPartAuxMod04Set":  (0x4C00C4C0, 0x4C00C4E6),
    "TgPartAuxMod05Set":  (0x4C00C4E6, 0x4C00C50C),
    "TgPartAuxMod06Set":  (0x4C00C50C, 0x4C00C532),
    "TgPartAuxMod19Set":  (0x4C00C532, 0x4C00C56A),
    "TgPartAuxMod28Set":  (0x4C00C56A, 0x4C00C590),
    "TgPartAuxMod2ASet":  (0x4C00C590, 0x4C00C5B6),
    "TgPartAuxMod2CSet":  (0x4C00C5B6, 0x4C00C5DC),
    "TgPartAuxMod2ESet":  (0x4C00C5DC, 0x4C00C602),
    "TgPartAuxMod52Bit7Set": (0x4C00C602, 0x4C00C641),
    "TgPartAuxMod56Bit7Set": (0x4C00C641, 0x4C00C680),
    "TgPartAuxMod5ABit7Set": (0x4C00C680, 0x4C00C6BF),
    # ---- THE LOCAL-EDIT LIFECYCLE: the driver, the setter and the clearer of
    #      bit0 of the per-part edit-state record 0x500C58AE+part*9 ----------
    "TgPartAuxHdrDerive": (0x4C00C890, 0x4C00C96C),
    "TgPartAuxRecRefresh": (0x4C00C96C, 0x4C00CA19),
    "TgPartAuxModAllEnabled": (0x4C00CA19, 0x4C00CA67),
    "TgPartEditStateDefaults": (0x4C00CA67, 0x4C00CABD),
    "TgPartLocalEditRecBuildAll": (0x4C00CABD, 0x4C00CB3F),
    "TgPartLocalEditActivate": (0x4C00CB3F, 0x4C00CBC2),
    "TgPartLocalEditSelect": (0x4C00CBC2, 0x4C00CCB1),
    "TgLocalEditPartSet": (0x4C00CCB1, 0x4C00CCBA),
    "TgPartLocalEditClear": (0x4C00E5C0, 0x4C00E5D2),
    "TgLocalEditResetAll": (0x4C00E5D2, 0x4C00E5F0),

    # ---- DIGITAL DRAWBAR: the per-part registration record 0x500082C8+part*0x1C
    #      (nine 4-bit drawbar levels packed three-to-a-word, PERCUSSIVE TONE,
    #      the four +/- offset bytes and the derived level words) -------------
    "TgDrawbarToneRecInit": (0x4C00A1F7, 0x4C00A253),
    "TgPartDrawbarCapture": (0x4C00A253, 0x4C00A2F1),
    "TgPartDrawbarTypeSet": (0x4C00A2F1, 0x4C00A307),
    "TgPartDrawbarTypeClear": (0x4C00A307, 0x4C00A31C),
    "TgPartDrawbarTypeGet": (0x4C00A31C, 0x4C00A330),
    "TgPartDrawbarRegExport": (0x4C00A330, 0x4C00A389),
    "TgPartDrawbarUnitEnable": (0x4C00A389, 0x4C00A44C),
    "TgDrawbarNibbleScatter": (0x4C00A44C, 0x4C00A483),
    "TgDrawbarLevelsScan": (0x4C00A483, 0x4C00A519),
    "TgPartDrawbarLevelsDerive": (0x4C00A519, 0x4C00A594),
    "TgPartDrawbarOffsetsReset": (0x4C00A594, 0x4C00A5C7),
    "TgPartDrawbarPairSet1": (0x4C00A5C7, 0x4C00A5FB),
    "TgPartDrawbarPairSet2": (0x4C00A5FB, 0x4C00A653),
    "TgPartDrawbarPairSet3": (0x4C00A653, 0x4C00A6AB),
    "TgPartDrawbarPairSet4": (0x4C00A6AB, 0x4C00A702),
    "TgPartDrawbarPairSet5": (0x4C00A702, 0x4C00A74D),
    "TgPartDrawbarAtkRlsSet": (0x4C00A74D, 0x4C00A786),
    "TgPartDrawbarPercSet": (0x4C00A786, 0x4C00A7BC),
    "TgEditOffsetAddClamp": (0x4C00A7BC, 0x4C00A7E5),
    "TgPartDrawbarOffsetApply": (0x4C00A7E5, 0x4C00A90C),

    # ---- LFO EDIT: the twelve LFO groups of ROM table 0x486D2ED5 projected
    #      onto the SOUND EDIT record's +0x45 parameter block ----------------
    "TgPartEditLfoLoadA":  (0x4C00CCBA, 0x4C00CD10),
    "TgPartEditLfoLoadB":  (0x4C00CD10, 0x4C00CD6F),
    "TgPartEditLfoLoadC":  (0x4C00CD6F, 0x4C00CDC6),
    "TgPartEditLfoLoadD":  (0x4C00CDC6, 0x4C00CE1C),
    "TgPartEditLfoLoadE":  (0x4C00CE1C, 0x4C00CE74),
    "TgPartEditLfoLoadF":  (0x4C00CE74, 0x4C00CEC8),
    "TgPartEditLfoLoadG":  (0x4C00CEC8, 0x4C00CF28),
    "TgPartEditLfoLoadH":  (0x4C00CF28, 0x4C00CF8B),
    "TgPartEditLfoGroupLoad": (0x4C00CF8B, 0x4C00D047),
    "TgPartEditLfoFlagSet": (0x4C00D047, 0x4C00D0AC),
    "TgPartCtrlSenseKit": (0x4C013497, 0x4C013542),
    "TgPartCtrlSenseElem": (0x4C030896, 0x4C03099F),
    "TgPartCtrlSenseMelodic": (0x4C033C0A, 0x4C033CAE),
    # ---- the GLOBAL EFFECT-CHANNEL REFRESHERS: the caller layer above the
    #      output-channel register file 0x4C037D0F.., re-run by the effect
    #      ENABLE setters at 0x4C00908F+ (per-part-effect-application.md,
    #      reverb-toggle-findings.md) ------------------------------------
    "TgPartGlobalChanRefresh": (0x4C004DE4, 0x4C0050DE),
    "TgGlobalChan6Refresh": (0x4C0050DE, 0x4C005241),
    "TgGlobalChan7Refresh": (0x4C005241, 0x4C005396),
    "TgGlobalChanBRefresh": (0x4C005396, 0x4C00542E),
    "TgGlobalChan3Refresh": (0x4C00542E, 0x4C0054A5),
    "TgGlobalChan5Refresh": (0x4C0054A5, 0x4C005535),
    "TgGlobalChan1Refresh": (0x4C005535, 0x4C005593),
    "TgGlobalChanCRefresh": (0x4C005593, 0x4C00566E),
    # ---- the TG GLOBAL-PARAMETER MODULE 0x4C008CBB..0x4C009837: the master
    #      volume / master tune / group-gain globals, the effect ENABLE bits
    #      in 0x500C0758 + 0x500C075A, and the COMMAND DISPATCHER that drives
    #      every one of them from the sound-command byte stream.  The
    #      dispatcher's 64-slot key/handler table lives in the program ROM at
    #      0x48586C60 (key = command id - 8, slot = (id-8) & 0x3F) -- see
    #      kn7000_mame/notes/effect-enable-bits.md ------------------------
    "TgGlobalAllPartsRefresh":      (0x4C008CBB, 0x4C008CD0),
    "TgMasterVolumeRecompute":      (0x4C008CD0, 0x4C008D8E),
    "TgMasterVolumeMainSet":        (0x4C008D8E, 0x4C008DAE),
    "TgMasterTuneFineSet":          (0x4C008DAE, 0x4C008DBE),
    "TgMasterTuneTransposeSet":     (0x4C008DBE, 0x4C008DCD),
    "TgMasterVolumeSubSet":         (0x4C008DCD, 0x4C008DED),
    "TgMasterVolumeAuxSet":         (0x4C008DED, 0x4C008E0D),
    "TgGroupGainPartsLoSet":        (0x4C008E0D, 0x4C008E21),
    "TgGroupGainClass23Set":        (0x4C008E21, 0x4C008E35),
    "TgGroupGainParts13To1ASet":    (0x4C008E35, 0x4C008E49),
    "TgGlobalRampStateSet":         (0x4C008E49, 0x4C008EA4),
    "TgGlobalRampParamSet":         (0x4C008EA4, 0x4C008F0C),
    "TgAllPartsRefreshAndFlush":    (0x4C008F0C, 0x4C008F45),
    "TgPartEffectRefresh":          (0x4C008F45, 0x4C008F8C),
    "TgAllPartsEffectRefresh":      (0x4C008F8C, 0x4C008FA1),
    "TgEffectRouteSelect":          (0x4C008FA1, 0x4C008FF6),
    "TgReverbPartsApply":           (0x4C008FF6, 0x4C009050),
    "TgGlobalByte0768Set":          (0x4C009050, 0x4C009059),
    "TgDrawbarGlobal82B2Set":       (0x4C009059, 0x4C009062),
    "TgDrawbarGlobal82BDSet":       (0x4C009062, 0x4C00906B),
    "TgDrawbarGlobal82BESet":       (0x4C00906B, 0x4C009074),
    "TgDrawbarGlobal82BFSet":       (0x4C009074, 0x4C00907D),
    "TgDrawbarGlobal82C0Set":       (0x4C00907D, 0x4C009086),
    "TgDrawbarGlobal82BCSet":       (0x4C009086, 0x4C00908F),
    "TgEffectEnableReverb":         (0x4C00908F, 0x4C0090C0),
    "TgEffectEnableBit10":          (0x4C0090C0, 0x4C0090EC),
    "TgEffectEnableBit4":           (0x4C0090EC, 0x4C009115),
    "TgGroupGainClass23Enable":     (0x4C009115, 0x4C009140),
    "TgGroupGainParts13To1AEnable": (0x4C009140, 0x4C00916B),
    "TgEffectEnableMulti":          (0x4C00916B, 0x4C009197),
    "TgEffectEnableBit13":          (0x4C009197, 0x4C0091C3),
    "TgEffectEnableBit14":          (0x4C0091C3, 0x4C0091EF),
    "TgMasterVolumeSubEnable":      (0x4C0091EF, 0x4C00921A),
    "TgGlobalFlag0Get":             (0x4C00921A, 0x4C009226),
    "TgGlobalFlag1Get":             (0x4C009226, 0x4C009232),
    "TgGlobalFlag2Get":             (0x4C009232, 0x4C00923E),
    "TgGlobalFlag0Set":             (0x4C00923E, 0x4C009250),
    "TgGlobalFlag1Set":             (0x4C009250, 0x4C009262),
    "TgGlobalFlag2Set":             (0x4C009262, 0x4C009274),
    "TgGlobalFlag0Clear":           (0x4C009274, 0x4C009289),
    "TgGlobalFlag1Clear":           (0x4C009289, 0x4C00929E),
    "TgGlobalFlag2Clear":           (0x4C00929E, 0x4C0092B3),
    "TgGlobalParamCommand":         (0x4C0092B3, 0x4C009565),
    "TgGlobalParamInit":            (0x4C009565, 0x4C009837),
}

# Reverse-engineering facts emitted as comments under the function headers.
# Sources: kn5000-docs /kn7000-technichord/, the KN7000 users manual (p.48),
# and the disassembly itself (matrix bases/strides, the 0x485EC940 param map).
FUNC_DOC = {
    "TgGlobalParamCommand": [
        "★ the TG GLOBAL-PARAMETER COMMAND DISPATCHER (d0 = command id,",
        "d1 = value). ONE function: the ~30 blocks after the jump are inline",
        "handlers, all returning through this frame ('ret [d2,d3,a2],0xa4').",
        "  id < 9 or id > 0x50 -> ignored;  slot = (id - 8) & 0x3F in the",
        "  64-entry program-ROM table 0x48586C60 (8 bytes: u32 key = id-8,",
        "  u32 handler); a key mismatch means 'unassigned' and falls into the",
        "  no-op tail 0x4C009562.",
        "Fed from the sound-command byte stream (the only caller is the stream",
        "interpreter at 0x4C003ED3, which pulls two bytes and calls the",
        "post-prologue entry 0x4C0092B9).",
        "The handlers that matter for the DSP effects (see the map in",
        "kn7000_mame/notes/effect-enable-bits.md):",
        "  id 0x29 -> TgEffectRouteSelect       0x500C0758 bits 1..3",
        "  id 0x2B -> TgReverbPartsApply        per-part reverb send pass",
        "  id 0x40 -> TgEffectEnableReverb      bit9  + chan 3 and 0x0B",
        "  id 0x41 -> TgEffectEnableBit10       bit10 (no channel refresh)",
        "  id 0x42 -> TgEffectEnableBit4        bit4  (no channel refresh)",
        "  id 0x43/0x44 -> the two GROUP-GAIN gates in 0x500C075A",
        "  id 0x45 -> TgEffectEnableMulti       bit12 + chan 0x0C and 6",
        "  id 0x46 -> TgEffectEnableBit13       bit13 + chan 1",
        "  id 0x47 -> TgEffectEnableBit14       bit14 + chan 5",
    ],
    "TgEffectEnableReverb": [
        "★ REVERB ENABLE (0x500C0758 bit9). Identified twice over: the",
        "live button trace in kn7000_mame/notes/reverb-toggle-findings.md",
        "puts the panel REVERB toggle on exactly these two stores, and the",
        "handler that calls it (dispatcher id 0x40) then re-runs",
        "TgGlobalChan3Refresh + TgGlobalChanBRefresh -- sub-TG channels 3 and",
        "0x0B, which notes/effect-return-routing.md captured live as the",
        "reverb RETURN (ch03 reg 0xA) and reverb SEND (ch0B reg 8).",
        "NOTE the asymmetry: 'off' only really clears bit9 when 0x500C0758",
        "bit3 is clear -- with route bit3 set (TgEffectRouteSelect value 3)",
        "the reverb is forced ON regardless of the requested state.",
    ],
    "TgEffectEnableMulti": [
        "MULTI ENABLE (0x500C0758 bit12). Its dispatcher handler (id 0x45)",
        "re-runs TgGlobalChanCRefresh + TgGlobalChan6Refresh, and both of",
        "those gate their programming on this same bit (0x4C0055A4 and",
        "0x4C0051BE). Sub-TG channel 6 is the MULTI return captured live in",
        "kn7000_mame/notes/effect-return-routing.md (ch06 reg 0xA, 0 <-> 0x7F",
        "on the panel MULTI toggle), which is what pins this bit to the MULTI",
        "effect. Channel 0x0C is additionally gated on 0x500082C4 == 1, a",
        "DIGITAL DRAWBAR global.",
    ],
    "TgEffectRouteSelect": [
        "0x500C0758 bits 1..3 as a 3-VALUE FIELD: clears the 0x000E mask,",
        "then value 1/2/3 sets bit1/bit2/bit3 (0 = none). Dispatcher id 0x29.",
        "bit2 and bit3 are read by the low-level element layer",
        "(0x4C0350E4 / 0x4C03517E / 0x4C03527F / 0x4C03531E / 0x4C035555 /",
        "0x4C03578C for bit2, 0x4C03545D / 0x4C035502 / 0x4C035693 /",
        "0x4C035739 for bit1) and bit3 also forces REVERB on in",
        "TgEffectEnableReverb. Which GUI control writes it is NOT claimed.",
    ],
    "TgMasterVolumeRecompute": [
        "The MASTER VOLUME summing node. Three byte terms live at",
        "0x500082B4 (main), 0x500082B6 (sub) and 0x500082B8 (aux); each is",
        "biased by -0x7F and they are added, clamped to [-0x7F, 0] and",
        "published twice:",
        "  0x500C077E = 0x7F + sum of ALL THREE, hw write via 0x4C038028",
        "  0x500C0780 = 0x7F + main + aux + (sub only if 0x500C075A bit5),",
        "               hw write via 0x4C038046",
        "so 0x500C075A bit5 (TgMasterVolumeSubEnable) is what takes the SUB",
        "term out of the second bus. Each store is followed by a",
        "0x7F-denominator scale through LibDiv32 (value * 0xC992 / 0x7F).",
    ],
    "TgGroupGainClass23Set": [
        "GROUP MASTER GAIN for part class 2/3 -> halfword 0x500C0760, the",
        "term TgLevelTermFinalize folds in (gated there on 0x500C075A bit3 --",
        "the bit TgGroupGainClass23Enable owns, and note that setter is",
        "INVERTED: a non-zero argument CLEARS the bit). Value 0 stores the",
        "hard mute -0x200; otherwise value - 0x7F. Dispatcher id 0x23.",
        "Its three siblings: 0x500C0764 parts <= 0x0F (id 0x22),",
        "0x500C0762 parts 0x13..0x1A (id 0x24, gated on bit4), and",
        "0x500C0766 class 4, written by the id-0x50 handler through the",
        "program-ROM curve 0x4858662E.",
    ],
    "TgGlobalRampStateSet": [
        "Start/stop of the 0x500082A4 RAMP STATE MACHINE (state bits in",
        "0x500082A4, step counter 0x500082A6/A8, advanced once per tick by",
        "0x4C009837 walking the program-ROM curve 0x486D27EB). It sits in the",
        "0x500082xx DIGITAL DRAWBAR global block, so a rotary/tremolo",
        "slow<->fast speed ramp is the natural reading -- deliberately NOT",
        "claimed, the code names nothing.",
    ],
    "VoiceArchiveScanBoot": [
        "\u2605 the BOOT ARCHIVE PARSER (kn7000_mame/notes/sound-bank-classes.md,",
        "'How sources 1..4 are validated'). Four near-identical blocks, one per",
        "expansion voice-archive window -- 0x57000000, 0x56000000, 0x41000000,",
        "0x41800000 -- each doing:",
        "  1. header self-check   *(u32*)base + base == base + 0x200",
        "  2. TWO 16-byte signature compares against \"Expansion Board \"",
        "     (0x485B8518) at *(base+4) and *(base+8); the compare walks the",
        "     reference string only while bytes match, so a mismatch leaves the",
        "     counter < 0x10 and fails the gate",
        "  3. present  -> presence byte 0x501496B4+n = 1, archive ID",
        "     *(base + *(base)) -> 0x501496A4+n*4, and the five parallel",
        "     descriptor arrays 0x5003A554 / 0x5003A568 / 0x5003A57C /",
        "     0x5003A590 / 0x5003A5A4 get slot n+1 from dir = base +",
        "     *(base+0x0C), dir + *(dir+0x14) and that + 0x0C",
        "     absent   -> all five slots alias the INTERNAL bank (index 0,",
        "     built at the top of the function from table ROM *(0x48000018))",
        "Which SOUND GROUP panel button (MEMORY vs EW EXPANSION) is which of",
        "classes 1..4 is deliberately NOT claimed: the firmware uses the same",
        "signature for all four windows, only the address differs.",
    ],
    "StyleNameModuleBoot": [
        "\u2605 boot entry of the RHYTHM/STYLE NAME MODULE and the exact place",
        "the \"8 Beat 1\" bug is decided (kn7000_mame/notes/",
        "sequenced-playback-and-style-data-rootcause.md, root cause 2a):",
        "StyleResourceWindowProbe picks a \"Technics Rhythms\" resource window",
        "(cached at 0x5000775C) and StyleBuiltinNameTableInit opens it; if that",
        "fails the PROGRAM-ROM STUB 0x48729988 -- whose header declares",
        "count = 1 -- is installed instead, after which StyleBuiltinNameResolve",
        "gates every style-ID out of range and returns the fallback string",
        "\"  8 Beat 1\" (0x4872AB42). In emulation none of the probed windows",
        "carries the resource, so the stub always wins.",
    ],
    "StyleResourceWindowProbe": [
        "probes five physical windows for the 16-byte \"Technics Rhythms\"",
        "signature -- 0x48010000 (table ROM +0x10000), 0x40610000, 0x40010000,",
        "0x54E10000, 0x40810000 -- and UNCONDITIONALLY returns 0x54E00000 as the",
        "last resort (no signature gate ahead of it, which is why 0x54E00000 is",
        "the natural install window for a Phase-C dump / Phase-D synthetic).",
    ],
    "StyleBuiltinNameResolve": [
        "style-index -> name pointer. Name table *(0x50034B7C) (u16BE entries),",
        "count gate *(0x50034B74); entry < count = plain, name = resource base",
        "*(0x50034B78) + u24BE(sub-table *(0x50034B80) + entry*3). Entries with",
        "bits 0xC000 == 0x8000 take one extra hop through the name table;",
        "0xC000 == 0x4000 resolves against the SECONDARY sub-table",
        "*(0x50034B90) (table ROM segment 59, 0x48244F78, intact in our dump).",
        "Anything unresolved returns the fallback *(0x50034B88).",
    ],
    "TgDrawbarToneRecInit": [
        "\u2605 DIGITAL DRAWBAR (manual p36, kn7000_mame/notes/",
        "sound-gui-inventory.md). The nine drawbars of the KN7000's tonewheel",
        "organ model are stored as nine 4-BIT levels packed three to a word in",
        "the per-part registration record 0x500082C8+part*0x1C:",
        "  +0x00/+0x02/+0x04  three 12-bit registration words",
        "  +0x06              PERCUSSIVE TONE (2 bits = the 2 2/3' + 4' buttons)",
        "  +0x08 ATTACK TIME  +0x09 RELEASE TIME",
        "  +0x0A PERCUSSIVE TONE DECAY  +0x0B PERCUSSIVE TONE LEVEL",
        "  +0x0C/+0x0E/+0x10  derived level words   +0x19  drawbar TYPE flag",
        "The scatter table 0x486D10A0 (3 x 3 bytes) maps word nibbles onto the",
        "nine display slots -- word0 -> 0,1,6 / word1 -> 3,5,8 / word2 -> 2,4,7 --",
        "which is exactly why the five TgPartDrawbarPairSetN entry points below",
        "hand over the drawbars in screen order, two per call.",
    ],
    "TgPartDrawbarOffsetApply": [
        "\u2605 the bridge from the DRAWBAR screen to the synthesis engine: the",
        "four registration words go straight into aux mod-unit fields +0x04/+0x05",
        "of the part's SOUND EDIT shadow, and the four parameter bytes are added",
        "as SIGNED OFFSETS on top of whatever the sound already had, clamped by",
        "TgEditOffsetAddClamp_entry. Units 0..2 (the sustained footages) take the",
        "percussive decay/level bytes into aux +0x28/+0x2E with a 0..100 range;",
        "unit 3 (the percussion tap) takes ATTACK into aux +0x19 (0..0x7F) and",
        "RELEASE into aux +0x2A/+0x2C (0..100).",
    ],
    "TgEditOffsetAddClamp": [
        "the shared +/- applier behind every offset-style edit parameter:",
        "clamp((u8)current + (s8)delta, min, max) with min/max on the caller's",
        "outgoing-arg area. Callers pass max 0x64 (the manual's +/-100 ranges)",
        "or 0x7F. Also used by the SOUND EDIT aux-field setters.",
    ],
    "TgPartEditLfoGroupLoad": [
        "\u2605 LFO EDIT (manual p174). The firmware really does carry TWELVE LFO",
        "GROUPS: ROM table 0x486D2ED5, stride 0x27, twelve records, each with",
        "four (speed, depth, ...) triples at +0x00/+0x03/+0x06/+0x09 -- one per",
        "LFO EDIT destination page (PITCH MODULATION / AMP / FILTER / PAN).",
        "The group is the low nibble of byte +0x44 of the part's tone descriptor;",
        "the jump table 0x48586F28 routes it to one of EIGHT different unpackers,",
        "because the groups do not all use the same triples -- groups 0..3 read",
        "the first, 4..5 the first two, 6 the third, 9 the fourth, 8 only the",
        "+0x18 tail, and 0x0A/0x0B a flag-plus-6-bit form. Each unpacker writes",
        "the 8-byte LFO parameter block at +0x45 of the per-part SOUND EDIT",
        "record 0x500C0784+(part-0x10)*0x2C8 (parts 0x10..0x12 only).",
    ],
    "LibF64Pow": [
        "SOFT-FLOAT RUNTIME (the firmware has no FPU): IEEE-754 double",
        "helpers 0x4C000000..0x4C001A00, a classic errno-style compiler",
        "runtime + libm subset. ABI: doubles on the caller's outgoing-arg",
        "area -- arg1 lo/hi at (8,sp)/(0xC,sp), arg2 at (0x10,sp)/(0x14,sp),",
        "result in d0(lo):d1(hi); error cell 0x500AD390 (1=domain, 2=range).",
        "pow(x,y) = this function: y split by LibF64Modf; the integer part",
        "by repeated squaring, the fraction via LibF64Exp(frac*LibF64Log(x))",
    ],
    "LibF64Add": [
        "arg1 + arg2 (LibF64Sub flips arg2's sign bit and falls in here):",
        "unpack both (class codes 0=normal/1=Inf/2=zero/4=NaN), align,",
        "add/sub mantissas with guard bits, renormalize, repack",
    ],
    "LibF64Cmp": [
        "compare arg1 ? arg2, returning with the CPU flags set so the",
        "caller's SIGNED branches (blt/bge/ble) read the result directly;",
        "the sign-fold xors PSW N|V when the magnitude order inverts",
    ],
    "TgZoneLevelScaleCalc": [
        "first of the melodic ZONE PARAM FETCHERS (the leaf layer under",
        "TgElemNoteOnFresh/Std; byte-for-byte twins at 0x4C011F2F.. serve",
        "TgKitElemNoteOn): tone-zone (desc2) UI bytes -> hardware units via",
        "the +-50-index sensitivity curve ROM 0x486D2713 (negative offsets",
        "use the negated mirror), key scaling via 0x486D1354/0x486D13D4",
    ],
    "TgNoteLevelVariationCalc": [
        "the NOTE LEVEL chain (2026-07-20): this + TgVoiceNoteLevelCalc +",
        "TgElemLevelBaseCalc were the previous pass's 'pitch chain internals'",
        "-- they follow TgPitchRuntimeCalc in program order but compute the",
        "note/element LEVEL. Modes (desc halfword bits 15..14): 0 = velocity-",
        "sense level offset (tone block +0x91), 1 = PSEUDO-RANDOM level from",
        "the 1 kHz tick 0x50151BFC, 2/3 = set level-word bit15/bit16 +",
        "neutral 0x40 -- per-note level humanization for kit voices",
    ],
    "TgElemLevelBaseCalc": [
        "-> librec+0x12/+0x14 base level term (read back by TgVoiceLevelWord-",
        "Calc): key follow (0x70 -> fixed table 0x486D2805), the VELOCITY and",
        "KEY FADE zones desc2+0x1C..0x27 (crossfade attenuation, hard edge",
        "-0x200, slopes -0x40*delta/(hi-lo) via LibDiv32) + glide/master",
        "adjusts -- tg-envelope-sweep-results.md level pipeline",
    ],
    "TgLevelTermFinalize": [
        "TgVoiceLevelWordCalc's tail: fold in part volume/expression/offset,",
        "the four GROUP MASTER gains (0x500C0760/62/64/66 by part class),",
        "the mono/legato mute gates, then map the attenuation index through",
        "the log->hw level ROM 0x486D1BD4 -- the last step of every",
        "class-0x3000 level word",
    ],
    "TgPartEgRampInit": [
        "per-part TYPE-7 EG TIME-RAMP module (0x4C011730..0x4C011F2F, the",
        "curve helpers under TgVoiceEgSegParamGet): 8-byte state 0x50009D38+",
        "part*8 {flags, cntA, cntB, scaleA h+4, scaleB h+6; 0x100 = 1.0},",
        "enabled for tone type 7 when partrec halfword bit 0x1000 is set;",
        "TgPartEgRampDispatchTick runs an engage/release edge machine per",
        "part, ramping the scales through ROMs 0x4858712C/0x4858717C and",
        "LIVE-refreshing sounding voices (TgPartClassRegCollect ->",
        "TgGlobalRegWriteBoth_entry + per-slot TgVoiceReg0401/0405Write).",
        "Which panel feature drives partrec bit12 is still open.",
    ],
    "TgVoiceStealSilence": [
        "the STEAL/boot silencer (TgSlotAllocate's steal path) -- the only",
        "writer of the r1/r2=0xC000 pattern (the forever-note erratum's",
        "'boot/steal only' finding, notes/reverb-toggle-findings.md era):",
        "zero the EG segments and ramp to silence at rate 0xFF before reuse",
    ],
    "TgVoiceForceOff": [
        "the per-slot FORCE-OFF TgVoicePoolReset sweeps over all 0x80 slots:",
        "r0=0xA280/r1=0xA200 (rate 0xA2 -> level 0x80/0) + EG segs cleared;",
        "rate-0x7F and no-clear variants follow it",
    ],
    "TgDrumZoneParamClamp": [
        "the DRUM-side zone param fetcher set (third link of the family after",
        "the melodic 0x4C00FD4C.. and kit 0x4C011F2F.. sets), serving the",
        "class-0x10 drum programmers around TgDrumAmpReleaseCalc; same",
        "sensitivity curve ROM 0x486D2713 + key-scale pair 0x486D1354/13D4",
    ],
    "TgVoiceEgSegParamGet": [
        "the raw EG-segment read both fresh note-on programmers call: the",
        "part's cached EG halfword (0x500CE404+part*0x130+0x4A+seg*4) gated",
        "by the tone-TYPE feature record 0x486D2ED5+type*0x27 (type = tone",
        "rec +0x44 & 0xF; type 7 scales through the curve helpers, types",
        "0xA/0xB need tone rec +0x45)",
    ],
    "TgVoiceRouteFieldSet": [
        "the routing/level init at the top of TgElemNoteOnFresh and",
        "TgKitElemNoteOn: shadow +0x40 word bits 12..19 := route byte;",
        "mode 0 remaps by hardware config (PanelSubTypeGet_entry -> ROM",
        "tables 0x485877B4/0x48587774), modes 1..4 = the +0x20/+0x30 banks",
    ],
    "TechniChordOrchestratorPart": [
        "returns d0 = the part that sounds the harmony notes: param 0x8082",
        "(0xFF = auto -> part 0x10 or 0x11 by lib part-mask), then rejects the",
        "part (-1) when part-check param 0xB0007E[part<<24] == 1",
    ],
    "TechniChordCompute": [
        "the Techni-Chord harmony engine (pure software -- no TG registers):",
        " 1. GetCurrentChord copies {type, root, ...} from RAM 0x50000B18",
        " 2. chord-type normalise via jump table 0x485BC3EC (types 29..41 are",
        "    remapped to a basic type so the 28-row voicing matrices suffice)",
        " 3. gate on param 0x8080 == 1 (techni-chord ON), then dispatch the",
        "    voicing via the 14-entry jump table 0x485BC3B4 indexed by style",
        "    param 0x8081 (LEGACY order: the GUI grid maps through 0x485EC940;",
        "    param 13 = grid slot 3 = DUET 1, appended after FANFARE)",
        " 4. tail: fill each emitted note entry's flag byte from struct+0x27",
        "struct (a0): +0x26 melody note, +0x27 melody flag, +4 note count,",
        "+6 the 2-byte harmony note entries",
    ],
    "TechniChordClose": [
        "style CLOSE (param 0, and the base for OPEN 1/2 + DUET 1): fetch the",
        "chord-tone list (max 0x10), fold each tone by octaves into the octave",
        "below the melody, keep tones more than 2 semitones below it, max 4",
    ],
    "TechniChordDuet1": [
        "DUET 1 (param 13 = grid slot 3; the style Technics appended to the",
        "legacy 13-style enumeration): CLOSE voicing clamped to 1 note",
    ],
    "TechniChordOpen1": [
        "OPEN 1 (param 1): CLOSE, then drop the first harmony note an octave",
    ],
    "TechniChordOpen2": [
        "OPEN 2 (param 2): CLOSE re-spread by octave shifts (single close note",
        "raised above the melody; multi-note: first down, close followers up)",
    ],
    "TechniChordDuet2": [
        "DUET 2 (param 3 -- the ORIGINAL 'DUET' slot): one harmony note =",
        "melody - matrix[type][interval], matrix 0x485BA574 (28 rows x 12);",
        "interval = (melody - root + AugDimFold + 1) mod 12",
    ],
    "TechniChordCountry": [
        "COUNTRY (param 4): one note; matrix 0x485BAEA4 (28 x 12 x 1)",
    ],
    "TechniChordTheatre": [
        "THEATRE (param 5): two notes; matrix 0x485BA6C4 (28 x 12 x 2)",
    ],
    "TechniChordHymn": [
        "HYMN (param 6): three notes = four-part writing incl. the melody;",
        "matrix 0x485BAFF4 (28 x 12 x 3)",
    ],
    "TechniChordBlock": [
        "BLOCK (param 7): four notes; matrix 0x485BA964 (28 x 12 x 4)",
    ],
    "TechniChordBigBandBrass": [
        "BIG BAND BRASS (param 8): three notes; matrix 0x485BB3E4 (28 x 12 x 3)",
    ],
    "TechniChordBigBandReeds": [
        "BIG BAND REEDS (param 9): four notes; matrix 0x485BBE64 (28 x 12 x 4)",
        "-- 'big band reeds which adds four harmony notes' (users manual)",
    ],
    "TechniChordOctave": [
        "OCTAVE (param 10): fixed melody+12 & melody-12 (pair 0x485BC3A4);",
        "chord-independent -- works even unsplit (users manual)",
    ],
    "TechniChordHardRock": [
        "HARDROCK (param 11): fixed melody-5 & melody-12 (pair 0x485BC3A6,",
        "fourth + octave below = power chords); chord-independent",
    ],
    "TechniChordFanfare": [
        "FANFARE (param 12): fixed melody+10 & melody+5 (pair 0x485BC3A8,",
        "stacked fourths above the melody); chord-independent",
    ],
    "TechniChordOff": [
        "techni-chord off / style out of range: harmony note count = 0",
    ],
    "TechniChordAugDimFold": [
        "(d0 = chord type, d1 = root 1..12) -> root-fold offset for the",
        "symmetric chord types: type 4 in buckets of 4 semitones (0/4/8),",
        "type 7 in buckets of 3 (0/3/6/9); 0 otherwise, -1 for type 0 (no",
        "chord). Makes enharmonically identical aug/dim chords share one set",
        "of matrix columns in the 7 matrix voicing styles",
    ],
    # ---- control-panel serial protocol (notes/panel-serial-protocol.md) ----
    "PanelTransaction": [
        "boot ping transaction: PanelTxKick(0x20,00) pings CPL, then (0xE0,00)",
        "pings CPR, each bracketed by wait-idle + ring reset; an RX-ring head",
        "move (0x5006BDB2 != 0) marks the board as answered in result nibble",
        "0x5006BDA5 (bit0 CPL, bit3 CPR). Caller 0x484ABBB5 retries 10x for 9",
    ],
    "PanelSignOnRequest": [
        "boot sign-on/ID sequence: commands 0x29,00 / 0xEA,00 / 0x20,10 /",
        "0xE3,10 with tick waits, then PanelRxDecodeQuiet parses the replies;",
        "the sign-on bytes land in the wire shadow tables that PanelTypeDetect",
        "(0x484AC19F) reads to identify the panel hardware type",
    ],
    "PanelInitHookNop": [
        "retf-only init step (boot init 0x484ABB47 calls it last)",
    ],
    "PanelStatusPoll": [
        "runtime poll: commands 0x29,00 / 0xEB,00 / 0x20,10 / 0xE6,10, each",
        "followed by PanelRxDecodeExpect; run by PanelTxPump every 4th flush",
        "and by service method 0x484ABBA5",
    ],
    "PanelWaitLinkIdle": [
        "wait for the link to go idle: presence GPIO 0x36008084 bit0 high,",
        "flags 0x5006BDA2 bits1-2 clear, TX ring drained (rd==wr); 200 retries",
        "of PanelBusyWait3000, timeout sets error bit7 of status 0x5006BDA4",
    ],
    "PanelTxKick": [
        "start a command transaction: [cmd,arg] -> TX ring slots 0x5006BE14/15",
        "(rd:=0, wr:=2), TX-busy bit2 set / overrun bit1 clear, state:=1, dwell",
        "0x78 -> 0x34001010, board-select strobes (0x36008024/25 set, 0x36008004",
        "bit6 mirrors PanelModeFlagGet, bit1 clear, 0x36008064 set), disable",
        "INTC grp4(ATN)+grp6(RX) / enable grp5(TX-done), SIO0 direction TX",
        "(cfg&0xFFF8|4), start (cfg|=0x8000) and send the first sync 0x00",
    ],
    "PanelAtnIsr": [
        "INTC group 0x1A: the panel's 2-edge ATN pulse. Pass 1 (0x5006BE92==0):",
        "EXTMD 0x34000280 bits7:6 11b->10b (arm the opposite edge), ATN flag",
        "bit0 of 0x5006BDA2. Pass 2: if no reply pending (0x5006BDA1==0) turn",
        "the link around to RX -- cfg|=0x07 then |=0x4000 (RX enable), enable",
        "grp6 / disable grp5, state:=8; else spurious -> error bit6 0x5006BDA4.",
        "Both passes ack GxICR 0x34000168 inside an IE-off bracket and restore",
        "EXTMD to 11b",
    ],
    "PanelTxDoneIsr": [
        "INTC group 0x11 (sync-transfer complete, TX side): dispatch the link",
        "state via PanelXferStateTable 0x48613034[0x5006BDA0], ack 0x34000144",
    ],
    "PanelRxIsr": [
        "INTC group 0x10 (RX byte ready): SIO0 status 0x3400080C error bits0-2",
        "-> flag 0x50150A38, dispatch the same state table, ack 0x34000140",
    ],
    "PanelTxState1": [
        "TX state 1 (line sync): board strobes, presence GPIO 0x36008084 bit0",
        "-- if LOW abort the transaction (state:=0, error bit2 of 0x5006BDA4,",
        "disable grp5/6); else dwell 0x3C, direction TX + start, sync 0x00,",
        "state:=2. (This presence test was the silent killer of the MAME HLE",
        "bring-up until GPIO 0x36008084 bit0 was mapped high)",
    ],
    "PanelTxState2": [
        "TX state 2 (payload 1 = CMD): ack pending ATN (GxICR 0x34000168),",
        "enable grp5, transmit ring[rd++] from 0x5006BE14; reply-length",
        "classify: (b&0x3F)>=0x30 -> countdown 0x5006BDA1:=(b&0xF)+3, else 2;",
        "state:=3. No CONFIG bit15 write: in the interrupt-driven protocol",
        "every DATA write clocks one transfer (bit15 is only the boot's",
        "polled-path start/busy flag)",
    ],
    "PanelTxState3": ["TX state 3: interleaved line sync 0x00, state:=4"],
    "PanelTxState4": ["TX state 4 (payload 2 = ARG): transmit ring[rd++], state:=5"],
    "PanelTxState5": [
        "TX state 5 (line sync): strobes + dwell 0x3C, sync 0x00, re-arm the",
        "ATN path (enable grp4+grp5, disable grp6), direction TX, sync again,",
        "state:=6",
    ],
    "PanelTxState6": [
        "TX state 6 (frame end): if >=2 more bytes queued in the TX ring ->",
        "state:=1 and kick the next 7-byte frame inline (strobes, dwell 0x78,",
        "direction TX, sync, TX-busy set); else final -- re-arm ATN (grp4),",
        "disable grp5/6, dwell 0x3C, TX-busy bit2 clear, state stays 0",
    ],
    "PanelRxState8": [
        "RX state 8 (first reply byte): direction RX (cfg|=0x07), ack+enable",
        "grp4/6 inside the IE-off bracket, read RXD 0x34000809 into the RX",
        "ring 0x5006BDB4[head 0x5006BDB2] (ring-gap < 3 -> overrun bit1 of",
        "0x5006BDA4, head not advanced), reply countdown 0x5006BDA1 := 2, or",
        "(b&0xF)+3 for a length-extended reply ((b&0x3F)>=0x30); state:=9",
    ],
    "PanelRxState9": [
        "RX state 9 (rest of the reply): store RXD -> ring (unless overrun),",
        "countdown--; at 1 the transaction completes -- state:=0, overrun flag",
        "clear, strobes, direction TX, ack ATN, enable grp4/6, disable grp5,",
        "RX enable off (cfg&=0xBFFF); otherwise stay in RX for the next byte",
    ],
    "PanelXferIdleState": [
        "state-table slots 0/7/10: a transfer completed while idle -> error",
        "bit7 of 0x5006BDA4",
    ],
    "PanelLinkRxRearm": [
        "reset the link to ATN-armed idle: flag bit3 clear, status bit4 set,",
        "RX enable off, disable grp5/6, ack GxICR 0x34000168, enable grp4",
        "(no static caller in either code region -- runtime-dispatched)",
    ],
    "PanelTxPump": [
        "periodic TX flush (from panel service method 0x484ABB98): a 2-bit",
        "phase counter in 0x5006BDA2 bits6-7 advances 0x40/call; on wrap runs",
        "PanelStatusPoll + 0x484ABAE6, otherwise PanelTxFifoToRing; then if",
        "the link is free (presence high, flags idle) and the ring holds >=2",
        "bytes, re-kicks the TX state machine inline (same sequence as",
        "PanelTxKick); busy 0x14 consecutive calls -> error bit7 0x5006BDA4",
    ],
    "PanelLedMirrorResetA": [
        "clear the LED bank-A last-sent mirror 0x50150A5C..0x50150A6D so the",
        "diff-flush task retransmits every LED register",
    ],
    "PanelHeaderValidate": [
        "switch-report framing rule: header bits7:6 must be 00 or 11 (2 wire",
        "banks) -> 0 ok, else -1",
    ],
    "PanelErrorRecovery": [
        "error-nibble state machine on 0x5006BE91: hi-nibble countdown -> on 0",
        "full link reset (FIFOs, rings, flags, 0x484ABD54/0x484ABD73) + error",
        "code 0x0A; else lo-nibble countdown -> on 0 PanelLedMirrorResetA",
    ],
    "PanelRxDecodeExpect": [
        "run PanelFrameDecode with flag bit4 of 0x5006BDA2 SET (a reply is",
        "expected; used between PanelStatusPoll commands)",
    ],
    "PanelRxDecodeQuiet": [
        "run PanelFrameDecode with flag bit4 CLEAR (idle drain; service",
        "method 0x484ABB8D)",
    ],
    "PanelFrameDecode": [
        "THE switch-report frame decoder (loop head 0x484AD11C). Per frame:",
        "backpressure gate (stop while 0 <= PanelEventFifoFree < 4), need >=2",
        "RX-ring bytes, validate the header byte (= the first data byte;",
        "PanelHeaderValidate fail -> error nibble 0x10 in 0x5006BE91), then",
        "type=(b&0x38)>>3: 0/1 momentary [ADDR,DATA] -> XOR edge-detect vs",
        "shadow tables 0x5006BE50 (bank 00) / 0x5006BE80 (bank 11), enqueue",
        "[ADDR,DATA,CHANGED] into the cooked FIFO + latch 0x5006BDA6/7/8;",
        "2 -> PanelCtrlDispatch (latched controls; event enqueued only on",
        "change); 3/4/5 -> skip 2 bytes, sync flag bit3 of 0x5006BDA4;",
        "6/7 -> length-checked batch of control updates",
    ],
    # ---- SD-card subsystem (notes/sd-card-emulation-plan.md; MAME driver
    #      counterpart = the spi_sdcard hookup in kn7000.cpp). The data path is
    #      a byte-wide SPI master: shift register 0x9805000C, per-byte handshake
    #      via INTC group 0x1C ICR 0x34000170, clock latch 0x9805000E, CS = GPIO
    #      0x36008004 bit1 active-low. -------------------------------------------
    "DiskInit": [
        "create the disk-worker world: SdHwInit, reset the driver records",
        "(0x50160644 block), phase:=1, power line+rail off, SdSlotRelease,",
        "media state:=1; create+start MILK task 8 (descriptor 0x4867b9a4 ->",
        "DiskWorkerTask, prio 3, stack 0xC00), create mailboxes 9 (commands)",
        "and 0xA (completions), clear the 10 client ctrl blocks 0x50082738..",
        "0x50082918 (0x30 bytes each) and post the done-event to each",
    ],
    "DiskWorkerStatusClear": ["clear the ctrl-block status halfword (4,a0)"],
    "DiskWorkerTask": [
        "MILK task 8 main loop: blocking-receive a 0x14-byte message from",
        "mailbox 9 (LibMsgReceive), dispatch on type halfword +8: 2 ->",
        "DiskDriveCtrlHandler (drive-letter control commands), 3 ->",
        "SdWorkerCmdHandler (SD media commands); optional per-message",
        "completion callback (calls), then clear status + post done-event 0xA",
    ],
    "DiskCmdReplyCopy": [
        "transact completion callback (installed at ctrl+0x2C): when the",
        "pending flag 0x500051b0 == 1 copy the 16-byte reply between the",
        "caller buffer and the shadow 0x501606b0, result -> 0x500051b2,",
        "pending := 0",
    ],
    "DiskCmdTransact": [
        "BLOCKING disk command: ctrl codes at (a0) (0x14 -> phase:=3, 0x15 ->",
        "phase:=1, 0 resets the busy latch); busy gate 0x500051b4 -> 0xFB;",
        "mailbox-full probe (-0x55) -> 1; copy the message into the shadow",
        "0x501606b0 + ctrl+0x1C, install DiskCmdReplyCopy, post event 9, wake",
        "task 3, then sleep-poll the pending flag with a 0x1F40-tick timeout",
        "on 0x50151bfc (-> 1); on completion the reply is copied back and",
        "0x500051b2 is returned",
    ],
    "DiskCmdPostAsync": [
        "non-blocking post: phase==3 -> 0x8002, mailbox full -> 0x8001; else",
        "status:=2, copy the 0x14-byte message to ctrl+8, post event 9, 0",
    ],
    "SdWorkerCmdHandler": [
        "worker message TYPE 3 = SD media commands. Message: {+0 cmd u16,",
        "+4 start sector u32, +8 sector count u32, +0xC buffer ptr}.",
        "Gate: media state==3 or cmd==0, else 0x40 (not ready). In-use LED on",
        "(SdInUseLedSet). cmd 0 = init/mount ladder: state 2 -> park frame",
        "0x50007e8a, power line+rail on, SdCardInitFull; state 0 -> rails off",
        "+ SdSlotDrainWait (-> probe flag 0x50160644), then power on + init;",
        "success -> state 3, fail -> state 1 + 0xFD. cmd 3 = read: initflag",
        "0x5016064c else 0x30; range vs capacity 0x50160664 else 2; per",
        "sector: byte addr = sector * mult 0x50160668 -> CMD17 frame",
        "0x50007ee4 (arg big-endian @+5..+8), SdReadBlockCmd(0x200 -> buffer),",
        "4 retries. cmd 4 = write: WP -> 0x2F, CMD24 frame 0x50007eee,",
        "SdWriteBlockCmd, error 3. cmd 8 = last error 0x5016064e; 0xA = init",
        "check (0x30); 0xB = nop; 0xC = total bytes 0x5016065c LE -> buffer;",
        "else 7. Nonzero result -> 0x5016064e; LED off",
    ],
    "SdMediaStateGet": ["read the media state 0x50160646 (0..3, 3 = ready)"],
    "SdMediaStateSet": ["validate {0,1,2,3} -> 0x50160646, else -1"],
    "SdDrvPhaseSet": ["validate {1,2,3} -> 0x50160648 (3 blocks the async post)"],
    "SdDrvPhaseGet": ["read 0x50160648"],
    "SdDrvRecordsReset": [
        "a0 = driver block 0x50160644: invalidate the CSD record (+0x28 =",
        "0x5016066c) and reset the card-info record (+8 = 0x5016064c)",
    ],
    "SdProbeFlagGet": ["read the drive probe/attach flag 0x50160644"],
    "SdCardReadyCheck": [
        "debounced card-detect AND initflag 0x5016064c -> 1 else 0 (the",
        "mount worker's card gate; the MAME 'initflag chicken-and-egg' site)",
    ],
    "SdCardDetectPoll": [
        "debounced card-detect (also scanned by PanelGpioSwScan as a",
        "pseudo-switch source)",
    ],
    "SdCardInitFull": [
        "THE full SPI card init (a0 = card-info record 0x5016064c):",
        "CS release, program slowest op rate (0xA) + apply (3), 10x 0xFF wake",
        "clocks with CS released, rate 0xB (medium); CMD0 loop until R1==0x01",
        "(retry ladder via rate query 0xD: rate-1 failure x3 -> drop to 0xB,",
        "rate-2 x3 -> 0xA, rate-3 x3 -> reset + -1); CMD1 loop (0x100 tries,",
        "0x14-tick sleeps; non-idle reply -> -2); CMD59 (good CRC, frame",
        "0x50007ed0) + SdCrcSelfTest (bad CRC) x3 -- non-fatal, fallback",
        "rate 0xA; SdCardIdentify with the same retry ladder (-3 on failure)",
    ],
    "SdCardInfoReset": [
        "zero the card-info record (block len := 0x200, capacity := 0,",
        "initflag := 0) + re-init the CID shadow 0x50082728 from ROM",
        "0x4875894c",
    ],
    "SdCardIdentify": [
        "identify stage (ROM frames 0x4867b9cc CMD10 / 0x4867b9d8 CMD9 /",
        "0x4867b9e4 CMD16): CMD9 -> 16-byte CSD; CMD16(0x200); multiplier",
        "0x50160668 := 0x200 (byte addressing, SDSC); CSD fields via",
        "SdCsdBitfield: C_SIZE [0x36..0x41] + C_SIZE_MULT [0x4E..0x50] +",
        "READ_BL_LEN [0x2C..0x2F] -> sector-count limit 0x50160664 + total",
        "bytes 0x5016065c; TAAC/NSAC/R2W_FACTOR -> access timeouts +8/+0xC;",
        "initflag := 1; CMD10 -> CID shadow 0x50082728",
    ],
    "DriveLetterClass": [
        "drive letter 'A'..'N' -> class via jump table 0x4867ba2c:",
        "'A'/'J'/'K' -> 1 (floppy-class), others -> 2 (SD-class), else -1",
    ],
    "SdHwInit": ["boot hw init: CS assert pulse + SdSpiPortSetup + SdDetectPortInit"],
    "SdSpiPortSetup": [
        "subtype!=4: flush 0xFFFF -> 0x98050004; EXTMD 0x34000280 |= 0x0C00",
        "(the SPI-handshake group edge config); force the slow clock (mode 2)",
    ],
    "SdSpiClockSet": [
        "d0 = mode: 2 = force slow (rate 3, gap 0x19); 3 = apply the stored",
        "operational pair 0x50005208/09 (subtypes 5/3 stay slow); 0xA/0xB/0xC",
        "= program the op rate slow/med/fast (rate code 3/2/1, gap",
        "0x1C/0xE/4); 0xD = query the rate code; else -1. Writes the clock",
        "latch 0x9805000E = rate|0x80 with a 2-tick verify poll; the",
        "inter-byte gap count lands in 0x50005200 (read by SdSpiSendByte)",
    ],
    "SdCsAssertWrap": ["plain-call wrapper around SdCsAssert"],
    "SdCsRelease": ["CS high (inactive): bset bit1 (0x02) of GPIO 0x36008004"],
    "SdCsAssert": ["CS low (active): bclr bit1 of GPIO 0x36008004"],
    "SdDetectPortInit": [
        "subtype!=4: bset 0x06 -> 0x9cc00005; SdSlotDischarge; power line +",
        "rail off; EXTMD 0x34000280 bits9:8 := 01 (the card-detect edge);",
        "W1C the pending detect (write 1 -> ICR 0x3400016c)",
    ],
    "SdCardDetectRaw": [
        "raw card-detect: subtype 4 -> always present (1); software override",
        "0x50005204 >= 0 -> its low byte; else IE-off strobe (write 1 ->",
        "ICR 0x3400016c, read back), IE-on, btst bit4: clear = present (1),",
        "set = absent (0). (The MAME driver drives this bit + the override)",
    ],
    "SdCardDetectDebounce": [
        "100-tick (counter 0x50151bfc) insertion debounce over the raw read;",
        "last-raw shadow 0x5000520c, edge timestamp 0x50005210; removal is",
        "reported immediately",
    ],
    "SdPowerLineSet": ["subtype!=4: bset bit2 (0x04) of 0x9cc00009 (slot power line)"],
    "SdPowerLineClear": ["bclr bit2 of 0x9cc00009"],
    "SdPowerRailSet": ["SdPowerCtrlSet(4): raise 0x98060000 bit2 (SD power rail)"],
    "SdPowerRailClear": ["SdPowerCtrlClear(4): drop 0x98060000 bit2"],
    "SdSlotDrainWait": [
        "power everything down (line+rail off, bit1 off, override := -1),",
        "sleep 0x1E ticks, then watch the slot sense (0x9cc00009 bit0) decay:",
        "0x7D0-tick window (timeout marks 0x50007efc := 0xFA), 100-tick",
        "low-confirm; always returns 0 (caller then sets the probe flag)",
    ],
    "SdSlotDischarge": [
        "slot flush cycle: line+rail off, CS assert, LATCH the debounced",
        "presence into the override 0x50005204, bset bit1 of 0x9cc00009, gap",
        "0xA, slow clock, then shift out 20,000 x 0x00 through 0x9805000C --",
        "the boot-time SPI write storm the MAME RE first observed",
    ],
    "SdSlotSenseGet": ["read 0x9cc00009 bit0 (subtype 4 -> 0)"],
    "SdWriteProtectGet": ["read the WP switch 0x9cc00009 bit4 (subtype 4 -> 0)"],
    "SdSlotRelease": [
        "line+rail off, bclr bit1 of 0x9cc00009, detect override := -1",
        "(back to the physical pin)",
    ],
    "SdSpiSendByte": [
        "THE byte primitive: IE-off bracket {W1C ICR 0x34000170, read back},",
        "IE-on, write d0 to the SPI shift register 0x9805000C (clocks 8 bits",
        "MSB-first through the card), bounded spin on DETECT bit4 with the",
        "per-rate gap count 0x50005200",
    ],
    "SdSpiSendBuf": ["send d0 bytes from (a0) with the same W1C/write/spin per byte"],
    "SdSpiRecvByte": [
        "full-duplex read: shift 0xFF out, spin on DETECT, read the answered",
        "byte back from 0x9805000C",
    ],
    "SdSpiRecvBuf": ["receive d0 bytes into (a0) (0xFF filler clocks)"],
    "SdSpinDelay": ["counted spin loop (d0 iterations)"],
    "SdSpiClockBurst": [
        "send d0 x 0xFF filler clocks (the >=74 wake-up clocks run with CS",
        "RELEASED, per the SD spec)",
    ],
    "SdResponseScan": [
        "scan for the R1 byte (bit7 clear) across up to 0x200 reads (0x64",
        "spin between) -> (a0) halfword R1<<8; type 2 (R2) ORs a second byte",
        "into the low half; type 3 (R1b) appends SdWaitNotBusy(0x1F4);",
        "timeout -> -1. (R1 0x01 idle therefore reads back as 0x100)",
    ],
    "SdWaitNotBusy": [
        "poll until the card answers 0xFF (busy released); d0/2-tick timeout",
        "-> -1, 2-tick sleeps between polls",
    ],
    "SdSenseBusyWait": [
        "expect the slot sense (0x9cc00009 bit0) high, then wait (d0/2-tick",
        "timeout) for it to clear; -1 if already low or timed out (used for",
        "the slow-clock class-2 commands during init)",
    ],
    "SdDataRespWait": [
        "scan for the write data-response token (b & 0x11) == 0x01: sss ==",
        "010 (0x05) -> 0 accepted, else -2 (CRC/write error); 0x1400 reads",
        "max -> -1",
    ],
    "SdTokenWait": ["poll for the 0xFE start-block token, d0/2-tick timeout -> -1"],
    "SdCommandSend": [
        "send one command frame a0 = {clockMode u16, respType u16, cmd[6]}:",
        "CS assert, clock set from clockMode, CRC7 -> cmd[5] ((crc<<1)|1),",
        "send the 6 bytes; mode-2 extras (5-tick sleep, SdSenseBusyWait 0x258,",
        "0xC8 spin); SdResponseScan(respType); CS release; mode-3 flush byte.",
        "-0xA = busy-sense fail, -1 = no response, else the R1<<8 halfword",
    ],
    "SdCrcSelfTest": [
        "send the ROM CMD59 frame 0x4867ba64 with a DELIBERATELY corrupted",
        "CRC7 ((crc-1)<<1|1) and expect the card to flag COM_CRC_ERROR:",
        "returns 1 iff R1 bit3 (0x0800 in the halfword) came back set.",
        "SdCardInitFull runs good+bad CMD59 three times, non-fatally",
    ],
    "SdReadBlockCmd": [
        "block read (a0=frame, d0=len, a1=dest): command preamble as in",
        "SdCommandSend; R1 gates (mode 3 needs ==0, else btst 0x0400/0x1200",
        "R1-error bits fail); SdTokenWait(0x64) for 0xFE; SdSpiRecvBuf(len);",
        "read the CRC16 pair and verify vs SdDataCrc16 -- mismatch sets the",
        "0x0800 flag in the returned status (the check that failed against",
        "MAME's init-0xFFFF CRC16 until spi_sdcard was patched).",
        "-0xA/-1/-2 = busy-sense/response/token failure",
    ],
    "SdWriteBlockCmd": [
        "block write (a0=frame, d0=len, a1=src): preamble, R1==0 gate, CRC16",
        "over the payload, send 0xFE token + data + CRC hi/lo, SdDataRespWait,",
        "SdWaitNotBusy(0x1F4). -0xA/-1/-2/-3 = busy/response/data-response/",
        "not-busy failure, else the status halfword",
    ],
    "SdCsdBitfield": [
        "extract CSD bits [d0..d1] from the big-endian 16-byte buffer at",
        "(0x40,sp): byte-span switch 0..3, LSB/MSB mask tables ROM",
        "0x4867ba70/0x4867ba78, bit math via LibDiv32",
    ],
    "SdDataCrc16": [
        "CRC-16 poly 0x1021 over (a0, len d0) -- INIT 0x0000: the finding",
        "that unblocked the MAME mount (util::crc16 inits 0xFFFF, so every",
        "CSD/data read failed CRC until spi_sdcard's sd_data_crc16 was",
        "patched to init 0)",
    ],
    "SdCmdCrc7": [
        "table-driven CRC7 (ROM table 0x4875896c, poly 0x09) over (a0, len",
        "d0), returns the accumulator >> 1; callers store (crc<<1)|1 as the",
        "frame's end byte",
    ],
    "SdPowerCtrlSet": [
        "IE-off: OR d0 into the power shadow 0x50005214 -> 0x98060000,",
        "10-count settle spin (bit2 = the SD power rail)",
    ],
    "SdPowerCtrlClear": ["IE-off: AND ~d0 into 0x50005214 -> 0x98060000, settle"],
    "SdPowerCtrlWrite": ["direct byte -> shadow 0x50005214 + 0x98060000"],
    # ---- SD mount state machine (UI side; state byte 0x50083cd8) ----
    "SdStateReset": [
        "full reset to idle: state := 0, clear the favorites directory",
        "(FavFormat), close handles 0x50083bac..b2 := -1, clear the",
        "0x50083bb6..ba work bytes + bbf/bc4/bc5, reload the defaults",
        "0x50083bc6/c7 from ROM 0x4868da64",
    ],
    "SdUnmountCleanup": [
        "unmount teardown: the same cleanup without touching the state byte",
        "or the 0x50083bb6..ba work bytes",
    ],
    "SdStateResetCall": ["thin wrapper -> SdStateReset"],
    "SdCardInsertMsgHandler": [
        "system-message hook for the card-detect transition message",
        "0x107020BB (d1 = inserted): UI mode 0xFC ignored. REMOVE: card-busy",
        "0x50083bc1 := 0, VFS invalidate 0x48565f64; state 2 -> pending-eject",
        "0x500058a0 := 1, else SdUnmountCleanup + state := 0; card-ready := 0.",
        "INSERT: 0x48565f67; pending 0 -> state := 1 (kicks the mount), 1 ->",
        "pending := 2. Always forwarded to the SD-audio notifier 0x48578ddd",
    ],
    "SdStateMachineTick": [
        "THE demand-driven SD supervisor (the notes' 'state machine tick'),",
        "dispatching on SD_GetState (0x50083cd8):",
        " 1 = mount requested: gate SdMountBusyCheck==0, install the",
        "     {SdMountWorker, SdMountDone} pair at 0x50083bc8/cc, state:=2,",
        "     schedule via the job poster 0x484729ad",
        " 2 = job running: pump the runner 0x48472a55",
        " 3 = MOUNTED: SdUiMountGateCheck, then UI supervision -- event 0x106",
        "     + error bit1 raises the property-0x0006008F dialog; events",
        "     0x108/109/10B/10C/113/120 sync the SD screens, gated on the",
        "     card-busy byte 0x50083bc1",
        " 4 = mount failed: failure-UI branch (0x48551d2a)",
        " 0 = idle: UI resync branch (0x48551f28)",
        "UI properties live on object 0x0210033F (setter 0x484298a0)",
    ],
    "SdMountWorker": [
        "the mount job (pointer-installed by state 1): clear the error flags",
        "0x50083bc3; gates SdCardReadyCheck + SdCardDetectPoll2 (fail ->",
        "card-ready := 0, -8); SdCardFsInit = card init + FAT mount (fail ->",
        "card-ready := 2, -7) else card-ready := 1; then card info",
        "0x4855ea17/0x4855eabd, 0x4855e845 (fail -> error bit0), directory",
        "0x4857bf6c (bit1), SdPlaylistLoad (bit2), handle 0x4855fbec ->",
        "0x50083bac. This is the path that reaches 'state 3 MOUNTED' in MAME",
    ],
    "SdMountDone": [
        "mount completion callback: result < 0 -> state 4, else state 3",
        "(MOUNTED); done flag 0x50083bc4 := 1; pending-eject 0x500058a0:",
        "1 -> unmount + card-ready := 0, 2 -> unmount + state := 1 (remount);",
        "SD-audio notifies 0x4857926f / 0x48578ff0",
    ],
    "SdSyncWorker": [
        "re-sync job (installed by SdMountSyncPost): the card gates +",
        "SdCardFsInit + card-ready, then rescan 0x4855fab3",
    ],
    "SdSyncDone": ["re-sync completion: state 3/4 + the same pending-eject logic"],
    "SdMountSyncPost": [
        "the Sdc screens' sync poster (notes: 0x4855216b): install the",
        "{SdSyncWorker, SdSyncDone} pair, state := 2, schedule via 0x484729ad",
    ],
    "SdUiMountGateCheck": [
        "GetProperty(object 0x0210033F, property 0x00060047) != -1 -> 1",
        "(the gate the MAME RE found blocking the state-0 UI kick)",
    ],
    "SdMountBusyCheck": [
        "job runner busy (0x48472abb) or 0x4851ad68 -> 1 (blocks the",
        "state-1 mount kick)",
    ],
    "SdErrorFlagsGet": ["read the mount error flags 0x50083bc3"],
    "SD_SetState": ["write the SD state byte 0x50083cd8 (0 idle / 1 kick / 2 mounting / 3 mounted / 4 failed)"],
    "SD_GetState": ["read 0x50083cd8"],
    "SdCardFsInit": [
        "card init + FAT mount trampoline -> 0x48565d17 (the VFS device-'C'",
        "chain; 'card-init 0x485630de' in the MAME notes)",
    ],
    "PanelButtonDispatch": [
        "one switch-event record [normSeg,DATA,CHANGED] -> button events:",
        "normSeg >= 0x21 rejected; self-test mode (0x5006BFB2==1) routes to",
        "the panel-test grid handler 0x484A11E1 first; descriptor array =",
        "ButtonDescPtrTable[normSeg] (bank A 0x48614978 / B 0x486149FC by",
        "PanelModeFlagGet), then per 12-byte descriptor {evt u32, mask, shift,",
        "gate, arg, type} while CHANGED bits remain: bit match -> action by",
        "type 0/1 press event 0x10000000|evt (1 adds the key-click), 2 system",
        "event 0x16000000|evt, 3 rhythm-transport composite, 4 continuous",
        "value (DATA<<6); handled bits are cleared from CHANGED",
    ],
    # ---- Tempo / TM5 clock module (96-PPQN sequencer timebase) ----
    # RE: notes/sequenced-playback-and-style-data-rootcause.md root cause 1
    # (TM5 modeled in the MAME driver, commit 60d5392). Six 10-byte "clock
    # consumer" blocks: 0x50149666 seq main, 0x50149670/0x5014967A sub-clocks,
    # 0x50149684 sub-clock, 0x5014968E metronome/count-in, plus the count-in
    # control 0x50149698 {ctl, target, count}. Block: +0 beat-in-bar, +2
    # beats-per-bar (0 = free run), +4 tick-in-beat (0..0x5F), +6 free tick
    # counter, +8 flags (bit15 RUNNING, 14 start-req, 13 stop-req, 12 stop-at-
    # beat, 11 just-started, 10 stopped, 9 hot-start, 8 at-origin, 7 bar wrap).
    "TempoModuleBoot": [
        "boot hook (function table 0x487314D4): TempoTimerInit +",
        "TempoClocksReset, zero the MIDI-sync bytes 0x50149654..62 and the",
        "metronome enables 0x5003A50C/0D/0E",
    ],
    "TempoHookNop": ["retf-only filler for the 0x487314D4 hook table"],
    "MidiRealtimeModeSet": [
        "validate 0..3 -> mode 0x50149654 (< 3 allows realtime out, == 0",
        "required by the realtime RX handlers)",
    ],
    "MidiRealtimeModeGet": ["read 0x50149654 -> mode >= 2"],
    "TempoClockSourceSet": ["clock-source byte 0x50149662 := 1"],
    "TempoClockSourceClear": ["0x50149662 := 0"],
    "TempoClockSourceGet": ["read the clock-source byte 0x50149662"],
    "TempoSyncParamDispatch": [
        "property dispatch on the low 24 bits of d0: 0x2020 -> MIDI-clock-",
        "slave flag 0x50149656 := (d1==1), and on clearing re-program TM5",
        "from tempo param 4 (GetParam -> TempoBpmReloadWrite); 0x2023 ->",
        "suppress byte 0x5014965A; 0x2041 -> enable byte 0x50149658",
    ],
    "MetronomeClickPost": [
        "(d0 = beat-in-bar, d1 = tick-in-beat) key one metronome click:",
        "pending note-off first (countdown 0x5003A532 > 0), then beat 0 &",
        "tick < 0xC -> note 0x10 vel 0x6A (downbeat), other beat & tick <",
        "0xC -> 0x11/0x54, subdivision -> 0x11/0x34; off-countdown := 0x10",
    ],
    "MetronomeStateReset": [
        "click-off countdown 0x5003A532 := 0, click interval 0x5003A534 :=",
        "0x60 (one beat)",
    ],
    "MetronomeVoiceInit": [
        "program the metronome part 0x20: lib 0x4C02986D(0x20, 0) with the",
        "parameter block {0, 0x26, 0} (part 0x21 is the chord finder's)",
    ],
    "MetronomeClickRateSet": [
        "d0 = 2..4 -> click interval 0x5003A534 := 0x60/d0 (LibDiv32);",
        "out of range -> 0x60 (one click per beat)",
    ],
    "MetronomeBeatTask": [
        "metronome pump (runtime-dispatched, no static caller): reads the",
        "metro clock pos/tick under the scheduler lock (0x48445886) and the",
        "flag getters 0x4844590E (run) / 1D (just-started) / 2C (stopped) /",
        "3B (at-origin); just-started at the origin -> immediate downbeat;",
        "stopped -> flush the note-off; running -> countdown -= elapsed",
        "ticks (counter get/clear 0x484458EA/0x484458F6) and click when the",
        "beat/tick window (last state 0x5003A536/38/3A) advances",
    ],
    "MetronomeNoteEvent": [
        "(d0 = note, d1 = velocity) -> lib key event 0x4C02976F on part 0x20",
    ],
    "TempoClkStartApply": [
        "apply a pending start: gate bit14 -> set RUNNING + bit11, clear",
        "14/10/13/12; bit8 := started at the origin (pos==0 && tick==0);",
        "clear the bar-wrap event bit7",
    ],
    "TempoClkStopApply": [
        "apply a pending stop: gate bit13 -> clear RUNNING + every transient",
        "flag, set bit10 (stopped)",
    ],
    "TempoClkAdvance": [
        "per-tick advance: tick-in-beat++, wrap at 0x60 -> beat-in-bar++ vs",
        "beats-per-bar (0 = free run; bar wrap rewinds and sets bit7); a",
        "stop-at-beat request (bit12) becomes a stop-request + apply at the",
        "beat wrap; the +6 free tick counter increments every call",
    ],
    "TempoClkAdvanceExtHold": [
        "MIDI-clock-slave advance: only while tick%4 < 3, then HOLD at the",
        "24-PPQN boundary until the next real 0xF8 steps past it (a pending",
        "stop still advances + applies)",
    ],
    "TempoClkMidiClockStep": [
        "consume one received 0xF8: snap tick-in-beat to the next multiple",
        "of 4 (one 24-PPQN quantum) with the same wrap/bar logic; the free",
        "counter accounts the skipped ticks",
    ],
    "MidiRealtimeSend": [
        "send realtime byte d0 to MIDI out (0x484B22B4): gate mode",
        "0x50149654 < 3; 0xF8 always passes, others need enable 0x50149658",
        "set and suppress 0x5014965A clear",
    ],
    "TempoClocksReset": [
        "zero the five clock blocks + the count-in block (lib memset",
        "0x4C003024), the global phase 0x50149664 and last-tick 0x5003A53C",
    ],
    "TempoClkArmRestart": [
        "rewind (pos := 0, tick := 0) and request a start (set bit14, clear",
        "RUNNING/9/13/12) -- the ISR applies it on the next tick",
    ],
    "TempoClkStartNow": [
        "set bit9 (hot start), rewind, set bit14, then TempoClkStartApply",
        "inline: immediate start from zero (the slave-mode 0xFA path)",
    ],
    "TempoClkArmContinue": [
        "request a start WITHOUT rewinding: clear bit9, set bit14, clear",
        "15/13/12 (position and tick keep their values)",
    ],
    "TempoClkContinueNow": [
        "set bit9 + bit14 and apply inline: immediate continue from the",
        "current position (the slave-mode 0xFB path)",
    ],
    "TempoClkStopRequest": [
        "request a stop: clear bit9, set bit13 (+ bit15 so the clock counts",
        "until it lands), clear 12/14; the ISR applies it on a 24-PPQN",
        "boundary so the outgoing clock stream stays aligned",
    ],
    "TempoClkStopNow": [
        "set bit9 + bit13, apply the stop inline, then rewind pos/tick",
    ],
    "TempoClkBeatStopRequest": [
        "request a stop at the next beat wrap: clear bit9, set bit12",
        "(+ bit15), clear bit14 (TempoClkAdvance converts it at the wrap)",
    ],
    "TempoTick96Isr": [
        "THE 96-PPQN TEMPO ISR (TM5 underflow -> INTC group 7; the handler",
        "the MAME RE found registered at 0x4844780C):",
        " 1. global phase 0x50149664 = (phase+1) mod 0x60",
        " 2. slave mode (0x50149656): advance all five clocks with the",
        "    24-PPQN HOLD variant, re-apply pending sub-clock starts, ack",
        " 3. internal: advance all five; a RUNNING->stopped edge on the",
        "    main clock sends 0xFC (MIDI stop)",
        " 4. apply pending starts: main first; if main runs, the three",
        "    sub-clocks follow; otherwise the COUNT-IN ladder counts the",
        "    metronome clock's bar wraps (bit7) up to 0x5014969A, then",
        "    starts/continues per the ctl bits 11..13 of 0x50149698 and",
        "    sends 0xFA (start) or 0xFB (continue)",
        " 5. apply pending stops only when tick%4 == 0 (24-PPQN alignment;",
        "    a main-clock stop takes all five down together)",
        " 6. main running & tick%4 == 0 -> send 0xF8 (24-PPQN clock out)",
        " 7. ack: GxICR 0x3400011C := (icr & 0xFF00) | 1 inside an IE-off",
        "    bracket, read back",
    ],
    "MidiClockRxHandler": [
        "received 0xF8 (acts only in slave mode 0x50149656): measure the",
        "interval on the 1 kHz tick 0x50151BFC (last at 0x5003A53C, clamped",
        "0x7F) -> TempoReloadFromInterval(2*dt) re-programs TM5 as a 4x",
        "interpolator; then step every armed/running clock by one 24-PPQN",
        "quantum (TempoClkMidiClockStep / start-apply for armed ones)",
    ],
    "MidiStartRxHandler": [
        "received 0xFA: gates mode==0, enable, !suppress, clock-source==0,",
        "main clock neither armed nor running. Internal clock: ArmRestart",
        "the main clock [+ the sub-clocks per 0x5014965C/5E, + 0x50149684",
        "when byte 0x50037C64 != 0, + the count-in clock per ctl bit15].",
        "Slave: relay 0xFA, TempoClkStartNow set, Tm5TimerRestart, 0xF8",
    ],
    "MidiContinueRxHandler": [
        "received 0xFB: same gates; ArmContinue set (internal) or relay",
        "0xFB + ContinueNow set + Tm5TimerRestart + 0xF8 (slave)",
    ],
    "MidiStopRxHandler": [
        "received 0xFC: gates mode < 1, enable, !suppress; stop-request the",
        "main clock (0xFC relayed when main was already idle), then stop",
        "each sub-clock that is armed or running",
    ],
    "Tm5TempoTimerStart": [
        "TM5 bring-up (the sequence the MAME driver models): mode",
        "0x34001082 low3 := 1, reload 0x34001092 := 0x28B0 (= 120 BPM),",
        "bset/bclr 0x40 (load pulse), bset 0x80 (count enable)",
    ],
    "Tm5TempoIsrRegister": [
        "register TempoTick96Isr for INTC group 7: descriptor {1, isr, 7,",
        "GxICR 0x3400011C, 0, level 4} -> lib 0x4C03DB26, then enable via",
        "0x4C03DCC8(3)",
    ],
    "TempoTimerInit": [
        "module init: 0x5003A540 := 1,250,000 (the 2 MHz timebase constant:",
        "reload = 1,250,000/BPM), 0x5003A544 := 0x7D0, then start TM5 +",
        "register the ISR",
    ],
    "TempoBpmReloadWrite": [
        "THE live tempo rewrite (25 callers across the tempo UI): clamp BPM",
        "to 40..300 (out of range -> 120), TM5 reload 0x34001092 :=",
        "1,250,000 / BPM -- takes effect at the next underflow",
    ],
    "TempoReloadFromInterval": [
        "slave-mode reload from a measured 0xF8 interval (d0 = 2*ms):",
        ">= 0x3F -> clamp 40 BPM, <= 8 -> clamp 300 BPM, else reload :=",
        "d0 * 0x7D0 / 4 (four internal ticks per received clock)",
    ],
    "Tm5TimerRestart": [
        "TM5 phase resync: bclr 0x80, load pulse, bset 0x80 (slave-mode",
        "start/continue re-aligns the interpolator to the incoming clock)",
    ],
    # ---- library window: TG voice/register primitives ----
    # RE: notes/tg-pitch-pipeline.md (voice records + TG A/B port split).
    "LibDiv32": [
        "signed 32-bit divide d0/d1 with the fast paths the sym file",
        "documents: d1==1 -> d0, d1==-1 -> -d0, else ext/div",
    ],
    "LibTickSleep": [
        "sleep d0 ticks of the lib tick counter 0x500D3C58: yield loop via",
        "0x4C03C0E4 until the counter passes start+d0",
    ],
    "TgVoiceSlotService": [
        "(d0 = slot, d1 = mode) service dispatch on the lib voice record",
        "0x500AF940 + slot*0xB4 (the notePitch16 record of the pitch",
        "pipeline): class bits (+2)&0x7C select 0x10/0x40/0x08 -> handlers",
        "0x4C00C0B1/0x4C0115AA/0x4C030E73; 0x04/0x20 -> bookkeeping on",
        "rec+0x52 (set 0x80) / rec+0x54 (!=0xFF: clear bits13:12, set",
        "bit12) with fallthrough to 0x4C013F0F; run in the note-on loops",
        "for every sounding element (callers 0x4C036F35/0x4C036F6E)",
    ],
    "TgVoiceRegWrite": [
        "THE slot-routed TG register write (the pitch-pipeline notes'",
        "primitive): word = (slot<<20) | d1 | data16 from (0x18,sp);",
        "slot < 0x40 -> hi16 to TG A addr port 0x98050000 + lo16 to data",
        "port 0x98050002; else slot&0x3F to TG B 0x98040000/0x98040002",
    ],
    "TgVoiceRegWriteB": ["the same 20-bit slot layout, TG B only"],
    "TgGlobalRegWriteBoth": [
        "global-register write (16-bit d0 shifted 18, not a slot field):",
        "broadcast the word to TG A then TG B",
    ],
    "TgGlobalRegWriteB": ["the 18-shift global write, TG B only"],
    "TgCmdReadA": [
        "issue the raw 32-bit word d0 to TG A (hi16 -> 0x98050000, lo16 ->",
        "0x98050002), then read the data port back: the TG readback",
        "primitive (returns the answered halfword)",
    ],
    "TgCmdReadB": ["the same readback primitive on TG B 0x98040000/0x98040002"],
    "TgVoiceStatusRead": [
        "(d0 = slot) poll one voice's status: gate byte 0x500CE380 == 0x7F",
        "(no TG present) skips the hardware; else command 0xFC010000 |",
        "(slot&0x3F)<<20 through TgCmdReadA/B -> status & 0x1FFF",
    ],
    "TgVoiceRecordReset": [
        "re-init voice record d0: copy the 0x84-byte ROM template",
        "0x4858766C over 0x500CA0B0 + slot*0x84 (the tg-pitch notes'",
        "record array, stride confirmed); returns a0 = the record",
    ],
    "TgVoiceRecordPtr": ["a0 := 0x500CA0B0 + slot*0x84"],
    # ---- the TG note path (tg-pitch-pipeline.md, tg-envelope-sweep-results.md).
    #      The 0x84-byte shadow record 0x500CA0B0+slot*0x84 caches each TG reg
    #      as a 4-byte entry [lo16 = note-on value | hi16 = release value]:
    #      +0 reg0, +4 reg1, +8 reg2, +0xC reg4, +0x10 reg5, +0x18 reg8,
    #      +0x1C reg9 (+0x0A also holds the reg3 gate-off value).
    "TgPartKeyEvent": [
        "(d0 flags, d1 part, stack note/velocity) the part-level key router",
        "(parts >= 0x22 rejected). velocity&0x7F nonzero -> NOTE-ON via",
        "0x4C0147A4 + TgNoteOn. velocity 0 -> KEY-OFF: hold-state query",
        "0x4C02E0F9 -> 0xFF/0xFE release the note's voices now (voice list",
        "0x4C010047, per slot 0x4C03B0CD + TgVoiceSlotService_entry(slot,0));",
        "0 -> mark-only via 0x4C02E2C7 = the sustain/hold path (the pedal",
        "keeps the voice sounding; released later by the slot service).",
        "Both key-off flavours finish with TgKeyOffSample.",
    ],
    "TgNoteOn": [
        "THE per-part note-on dispatcher (d0 part, d1 note, stack velocity).",
        "Tone class = (part tone block 0x500CE404+part*0x130 desc +0x10)&0xC0:",
        " 0x00/0xC0 melodic: repeat-note damping (part pitch struct 0x500AD5A8+",
        "  part*0x10C: +0x20 last-on tick vs global tick 0x50151BFC, repeats",
        "  within 0x19 ticks bump the +0x24 counter -> damp code 0x10/0x20 at",
        "  +0x25), allocate up to 4 element slots via 0x4C034FF5 (slot bytes at",
        "  stack rec+0x0A, steal list +0x20), then per slot: TgVoiceRecordReset",
        "  + per-class programmer (lib rec +2 bit1 -> TgElemNoteOnStd, bit2 ->",
        "  0x4C033CB3, else 0x4C013547) + TgVoiceDirtyAll + TgVoiceGateOn;",
        "  stolen slots: TgVoiceGateOff + TgVoiceDirtyRelease (skipped while",
        "  rec+0x52 != 0 or rec+2 bit8)",
        " 0x80: drum-kit sub-classes 0x80..0x83 (&0xCF) with their own",
        "  builders (0x4C03595F / 0x4C035D21) and per-element programmers",
        " 0x40: TgNoteOnTableTone, then per new slot TgExclGroupChoke +",
        "  TgElemNoteOnStd/TgVoiceGateOn",
        "epilogue: clears desc halfword +4 bit15 (the note-pending flag)",
    ],
    "TgNoteOnTableTone": [
        "class-0x40 note-on record builder (d0 part, d1 note, a0 out record):",
        "out+0 := (part<<8)|note|0x80; the tone's per-note 3-byte table",
        "(0x4C038503(part) +0x27 + note*3) enables up to two synth layers,",
        "each staged in 0x500C9D58 / 0x500C9E0C (built by 0x4C035EAA; flag",
        "bytes from ROM 0x4858711C/1D or'd 0x80 -> out+2/+3; send bits from",
        "0x4C02BED0 -> out+6/+7), then each staged 0xB4-byte record is copied",
        "over the lib voice record 0x500AF940+slot*0xB4 (slot bytes out+0xA/B)",
    ],
    "TgKeyOffSample": [
        "key-off retrigger (d0 part, d1 note): only for tone class",
        "(desc+0x10)&0xCF == 0x80 kits whose zone halfword flags 1|2|4 request",
        "a key-off sample; allocates a slot via 0x4C036312 (slot byte at",
        "rec+0x0B), then TgVoiceRecordReset + the 0x4C00BC83 programmer +",
        "TgVoiceDirtyAll + TgVoiceGateOn + gate-off bookkeeping 0x4C037CCE",
    ],
    "TgExclGroupChoke": [
        "exclusive-group choke, the hi-hat-style cutoff (d0 part, d1 new",
        "slot): desc(lib rec+0x38)+0x0E bit7 = tone is in an exclusive group",
        "(id &0x7F indexes the damp-rate table 0x48586EA4); collects the",
        "part's sounding voices via 0x4C01010A and for each voice whose",
        "descriptor carries the same group id: shadow release halves of",
        "reg0/reg1 := damp rate<<8 (levels cleared) then TgVoiceEgBurstWrite",
    ],
    "TgElemNoteOnStd": [
        "per-element note-on programmer, standard class (d0 slot, a0 shadow",
        "rec; lib rec +2 bit1): fills the shadow cache -- +0x40 zone word",
        "(desc+2 & 0xFFF), pitch16 via 0x4C02FB7E then +0x48 pitch18 :=",
        "((pitch16+0x1800)<<2)&0x3FFFF (THE tg-pitch-pipeline formula),",
        "+0x24 level (0x4C02FBE3 & 0x7F), effect sends +0x5C/+0x2C from",
        "desc2+0x18/+0x19 via the curve tables 0x486D1F54/0x486D2154",
        "(suppressed when TgTotalLevelCalc >= 0x100), plus the class-0x04 /",
        "class-0x0C global broadcasts",
    ],
    "TgVoiceKillHandler": [
        "slot-service class-0x08 handler (d0 slot): clears the lib record's",
        "active bit (+8 bit7); when desc+0x0D bit5 continues into the",
        "0x50009944 block via 0x4C02FE59, else plain return",
    ],
    "TgPitchInitCalc": [
        "the tg-pitch-pipeline notes' INIT pitch computation (0x4C030FB9):",
        "note16 -> pitch16 with zone center/key-follow exponent, coarse/fine",
        "tunes and multisample correction; populates lib rec +0x0C notePitch16",
        "race-free before the note's first TG pitch write",
    ],
    "TgPitchRuntimeCalc": [
        "the notes' RUNTIME pitch recompute (0x4C031127): the init formula",
        "plus modulation (part offset, mod matrix, LFO, portamento); called",
        "from every per-class voice-refresh handler",
    ],
    "TgKeyOffAmpRelease": [
        "key-off AMPLITUDE release compute -- h1 of the key-off trio (d0",
        "key-off offset, a0 lib rec, a1 out = two [rate|level] pairs).",
        "rate index = clamp(desc2+0x2E base + part-FX record (0x500B5340+",
        "n*0x54C) +0x48 RELEASE offset + d0 + key scaling (desc2+0x31..0x33",
        "breakpoints vs lib rec+0xC note), 0..100) -> curve ROM 0x486D2649.",
        "The pairs land in the shadow release halves of reg0/reg1 and reach",
        "the chip via TgVoiceEgBurstWrite (the piano's 0x9180/0x9100 burst).",
        "STATIC ANSWER to tg-envelope-sweep-results RESULT 2: the screen RLS",
        "param enters the key-off COMPUTATION here, not any TG register.",
    ],
    "TgKeyOffPitchRelease": [
        "key-off PITCH-EG release compute -- h2 (a0 lib rec, a1 out):",
        "desc2+0x11 release rate + desc2+0x12 scale via the curves",
        "0x486D2649/0x486D2713; out pairs -> shadow reg4/reg5 release halves",
        "(the piano burst's 0xAE00/0xAE00 = pitch pairs rewritten to a flat",
        "instant-zero, exactly the a1 sweep's re-reading)",
    ],
    "TgKeyOffFilterRelease": [
        "key-off FILTER-EG release compute -- h3 (a0 lib rec, a1 out):",
        "desc2+0x46 rate via 0x486D2649, signed level = clamp(desc2+0x47 +",
        "desc2+0x3E, -50..50) via 0x486D2713 -- desc2+0x3E is the folded",
        "CUTOFF ADJUST the a1 sweep saw in every filter level byte; out",
        "pairs -> shadow reg8/reg9 release halves (the piano burst's 0x22B0:",
        "rate 0x22 sweeping the filter to signed level 0xB0 = fully dark)",
    ],
    "TgPitchEgAttackCalc": [
        "running-voice PITCH-EG ATTACK program (a0 lib rec, a1 desc2): rate",
        "desc2+0x0B via curve 0x486D2649, key scaling desc2+0x15..0x17; the",
        "desc2+0x0B..0x12 block is the PITCH EG (regs 4..6 -- the a1 sweep's",
        "live r4..rB decode fixed the filter/pitch attribution)",
    ],
    "TgPitchEgDecayCalc": [
        "running-voice PITCH-EG DECAY program: rates desc2+0x0D/+0x0F via",
        "curve 0x486D2649, key scaling desc2+0x17",
    ],
    "TgFilterEgAttackCalc": [
        "running-voice FILTER-EG ATTACK program: desc2+0x40 rate (values >= 2",
        "via curve 0x486D2649), key scaling desc2+0x4A; the desc2+0x3E..0x4C",
        "block is the FILTER EG (regs 8..0xA per the a1 live decode)",
    ],
    "TgFilterEgDecayCalc": [
        "running-voice FILTER-EG DECAY program: desc2+0x42/+0x44 rates via",
        "curve 0x486D2649, desc2+0x4C scaling",
    ],
    "TgTotalLevelCalc": [
        "(d0, d1) -> 0x4C00F9B4(d0, d1, 0x40) & 0xFFFF; a result >= 0x100",
        "makes TgElemNoteOnStd skip the effect-send fields",
    ],
    "TgVoiceGateOn": [
        "NOTE-ON commit (d0 slot, a0 shadow rec): reg3 := 0x87FF (the",
        "envelope notes' RESULT-3 gate-on), class-0x3000 reg := (rec+0x54 &",
        "0x18000)|0x4000, then streams the cached note-on halves (reg0 :=",
        "rec+0, reg1 := rec+4, reg2 := rec+8, reg4 := rec+0xC, ...)",
    ],
    "TgVoiceGateOff": [
        "KEY-UP commit (d0 slot, a0 shadow rec): class-0x3000 reg := rec+0x54",
        "& ~0x4000, then reg3 := the rec+0x0A gate-off value -- the envelope",
        "notes' universal r3 hi-byte-0x80 key-release write",
    ],
    "TgVoiceEgBurstWrite": [
        "flush the cached RELEASE halves of regs 0,1,4,5,8,9 (rec +0x02/+0x06/",
        "+0x0E/+0x12/+0x1A/+0x1E) -- THE managed key-off 6-write release burst",
        "of the envelope sweep (wire regs 0x10/0x11/0x14/0x15/0x18/0x19 = the",
        "odd element's register bank at +0x10); also the choke flush",
    ],
    "TgVoiceDirtyAll": [
        "set bit7 in the shadow dirty masks +0x78/+0x7A/+0x7C/+0x80 (mark",
        "every register bank for the flush pass)",
    ],
    "TgVoiceDirtyRelease": [
        "clear bit7 in the same masks (drop pending flushes on release/steal)",
    ],
    # ---- the voice allocator + steal engine (tg-voice-allocator.md): each hw
    #      slot has a 0x2C-byte node at 0x500D1278+slot*0x2C; class rings live
    #      in list arrays (+0/+1 side quotas, +2/+3 side-active counts, +4..
    #      class heads): per-part *(0x500D0C64+part*0x1C), global active
    #      0x500D1238, global free 0x500D1258 (class-6 head 0x500D1274) ------
    "TgMelodicVoiceAlloc": [
        "THE melodic 4-element allocator under TgNoteOn (d0 part, d1 note, a0",
        "request rec, stack vel/damp). Per element k enabled by the tone",
        "block halfword +4 (bits 1/2/4/8; APC-class 0xD parts remap the pair):",
        "TgPartElemLastGet == 0xFF ? TgElemStageFresh : TgElemStageRestrike",
        "into the staging record 0x500C9D58+k*0xB4, TgVoiceSideSelect ->",
        "TgElemRequestFlags; then the TgPartElemEnabled gate, TgSlotAllocate,",
        "and each staged record is copied over the LIVE lib voice record",
        "0x500AF940+slot*0xB4 (chosen slots at rec+0xA.., 0x80+ = failed)",
    ],
    "TgSlotAllocate": [
        "hw slot assignment for a staged request (a0 rec: +0 (part<<8)|note|",
        "0x80, +2.. pool bytes bit7|pool-desc idx, +6.. policy 0x18 side bits/",
        "bit7 held/bit6 no-retrigger, out +0xA.. slots): per element",
        "TgVoiceNodePick over the pool's ROM steal-order list (0x485879D8+",
        "pool*8) -> fail = slot 0xFF; on success the node is re-armed (+0x28",
        "note, +0x2A 0xFF, +0x2B refade class, +0x26 8|held<<7, sustain mask",
        "0x500D288C bit per policy bit7), moved to the part's class ring",
        "(entry class = pooldesc+4) + order list; a side over quota migrates",
        "a TgVoiceMigrateFind donor node to the global array 0x500D1238,",
        "victim slot released via 0x4C00F824",
    ],
    "TgVoiceNodePick": [
        "THE steal chooser (d0 side policy &0x18, a0 part array, a1 ROM",
        "steal-order list): 0x18 = either side -> free head 0x500D1274 first,",
        "then the first non-empty ring in list order (entry bit7 = global ring",
        "0x500D123C[cls], else the part's own ring); 0x08/0x10 = must land on",
        "TG A/B -> same walk but each ring is scanned with TgNodeScanSideA/B;",
        "policy 0 -> no allocation. List order = the steal priority: retired",
        "(6) first, then releasing (5..2), held (1,0) last, global before",
        "own-part at each step",
    ],
    "TgVoiceMigrateFind": [
        "side-rebalance donor search (d0 wanted slot, a0 global array): walk",
        "the ROM order 0x486D383C [06 05 02 04 03 01 00] over the global class",
        "rings, return the first node on the OPPOSITE TG side",
    ],
    "TgVoiceStatusSweep": [
        "periodic TG poll driving retire/fade (16 slots per pass, rotating",
        "group 0x5000B210): gone-bits via cmd 0xFC08 vs the sustain mask",
        "0x500D288C -> TgVoiceNodeRetire + notify; surviving slots read their",
        "envelope level (cmd 0xFC02, (x&0x1FFF)>>5) into node+0x2A, < 0x80",
        "with flag bit2 -> TgVoiceNodeFadeKick; TG A half then TG B half",
    ],
    "TgVoiceNodeRetire": [
        "envelope-finished voice -> free pool: side-active count-- (never",
        "below the quota), node to the free array 0x500D1258 class 6 (head",
        "0x500D1274 = the pick's first choice), order list 0x500D101C,",
        "slot ring unlinked, flags := 1, level := 0",
    ],
    "TgVoiceNodeKeyOff": [
        "key-up node transition (d0 slot): drop the held flag (+0x26 bit7),",
        "clear the slot's sustain-mask bit (0x500D288C[slot>>4]), then",
        "TgVoiceNodeReleaseStep -- TgPartKeyEvent's per-slot call before",
        "TgVoiceSlotService",
    ],
    "TgVoiceSideSelect": [
        "TG side word for a staged voice (a0 rec): kit class (+0x18) 1/2 ->",
        "0x400 (TG A), 3/4 -> 0x800 (TG B); melodic class 0 -> mode",
        "0x484D7751(): 1..3 = the note's routing entry *(rec+0x34) & 0x0C00,",
        "5 = table 0x48586514, 4 = 0; folded into request bits 0x08/0x10 by",
        "TgElemRequestFlags",
    ],
    "TgVoiceRoutePtrCalc": [
        "rec+0x34 := the note's routing-entry ptr (kit tables via maincpu",
        "0x48449DAA/0x48449DF8 indexed by note rec+0xA hi7) -- the halfword",
        "TgVoiceSideSelect reads bits 10/11 from",
    ],
    "TgPartHoldQuery": [
        "key-off hold/top-note query (d0 part, d1 note): part flags bit6",
        "clear -> 0xFE (release now); else find the part's highest sounding",
        "note; releasing the TOP note promotes the next-highest (class-0x3000",
        "word rewrites via TgVoiceRegWrite_entry, top-note byte 0x500AD5A8+",
        "part*0x10C+0x26 updated); returns 0 = hold-managed (mark only)",
    ],
    "TgPartHoldMark": [
        "the Part-52 mark-only pedal path (d0 part, d1 note): records the",
        "held key in the part's 0x500AD5A8 block for the pedal-release sweep;",
        "no TG write happens here",
    ],
    "TgPitchZoneFold": [
        "multisample octave fold (a0 librec): librec+0x0C := zone center16,",
        "librec+0x0A := zone pitch folded by +-0xC00 octave steps into the",
        "sample's mapped key window [desc+9 << 8, (desc+0xA << 8)+0xFF]",
    ],
    "TgPitchNoteResolve": [
        "pitch16 producer for TgElemNoteOnStd (a0 librec) = folded zone pitch",
        "+0x0A + optional sample corr + part word (+0x64) + master tune",
        "0x500C075C + part offset resolve 0x4C0067D2, clamped 0..0x7FFF",
    ],
    "TgLevelResolve": [
        "note level 0..0x7F (a0 librec): part state +0x1D 1..3 w/ flags bit0",
        "-> 0 (mute) / bit1 -> 0x7F (solo); part-link flag borrows the linked",
        "part's level byte; else 0x4C006A17 + velocity + expression sum",
    ],
    "TgDrumNoteOnStd": [
        "drum-kit note-on builder (TgNoteOn class-0x80 sub-path): up to 2",
        "layers staged via TgDrumStageStd (class 0x10 voices) into",
        "0x500C9D58/0x500C9E0C, pool bytes ROM 0x48587114/15, then",
        "TgSlotAllocate + the staged-record copy to 0x500AF940+slot*0xB4",
    ],
    "TgDrumNoteOnTable": [
        "drum-kit note-on builder, table-class variant (class 0x81..0x83",
        "kits): layers staged via TgDrumStageTable (class 0x40 voices) +",
        "TgDrumReqFlagsTable (pool bytes ROM 0x48587118)",
    ],
    # ---- tempo-sync parameter layer (0x484478E7..0x48447F33), directly after
    #      the TM5 clock module: keeps the mode trio 0xD001/0xD002/0xD003
    #      consistent and mirrors into the 0x70xxxx property group ----------
    "TempoSyncD001Set": [
        "set sync param 0xD001 := d1 (gate: unchanged -> return): value 0 only",
        "while the 0x50149682 clock is stopped (bit15 getter 0x484455EB);",
        "values 1..3 first propagate the current value into 0xD002/0xD003",
        "(when nonzero) via LibParamSet",
    ],
    "TempoSyncD002Set": [
        "set 0xD002 := d1 (gates: 0x50149682 bit15 stopped, 0x48445645 bit12",
        "clear, value != current and != 0); propagates into 0xD001/0xD003",
    ],
    "TempoSyncD002Apply": [
        "apply 0xD002 (d0 value, d1 target 1/2): gate 0x484455EB, require",
        "0xD002 != 0; propagate into 0xD001/0xD003, then property 0x702023",
        "(the realtime-suppress id TempoSyncParamDispatch consumes) with",
        "index 0 (d1=1) or 1 (d1=2)",
    ],
    "TempoSyncD003Set": [
        "set 0xD003 := d1 (values 0..2; gate 0x484455EB); propagates into",
        "0xD001/0xD002 first",
    ],
    "TempoSyncModeASet": [
        "composite setter A (d0 value, d1: lo byte = apply gate, hi byte =",
        "variant): running (0x484455EB) -> defer via TempoSyncD003Set(1/2);",
        "stopped -> toggle 0xD001 between 0 and 2 (variant 0) or 0 and 3",
        "(variant 1) via TempoSyncD001Set",
    ],
    "TempoSyncModeBSet": [
        "composite setter B: variant 0 stopped -> property 0x600010 := value",
        "(gate 0x48445454 bit15); running -> TempoSyncD002Set(value,1);",
        "variant 1 -> toggle 0xD001 1<->0 / defer via TempoSyncD002Set(2);",
        "value 0 -> TempoSyncD002Apply(1/2) by variant",
    ],
    "TempoSyncPartB0Set": [
        "gated by d1 lo byte: read param 0xC000, then 0x4843FCA5 == 0 ->",
        "0x4843FCEB(val,1) + part property 0xB0 index 1 := d0, else",
        "0x4843FCEB(val,0) + property 0xB0 index 0 := d0",
    ],
    "TempoSyncE000Set": [
        "gated by d1 lo byte: property 0xE000 index d0 := 0x007F7F7F",
    ],
    "TempoSyncSetDispatch": [
        "the module's property SET dispatcher: ids 0x1xxxxxx route through the",
        "hash table 0x485B7A0C (8-byte {key,handler} rows, keys 0x702022..",
        "0x703004) -> handlers call TempoSyncModeASet/ModeBSet/PartB0Set/",
        "E000Set/the metronome poster 0x48446AE5; ids 0x0xxxxxx handle",
        "0x702023 (via TempoSyncD002Apply) and 0xD001/0xD002/0xD003/0xD008",
        "directly (0xD008: applies to whichever of 0xD001/0xD002 is active)",
    ],
    # ---- the 2026-07-20 TG note-path closure set (tg-voice-allocator.md
    #      glide section, tg-pitch-pipeline.md, tg-envelope-sweep-results.md)
    "TgPartGlidePlan": [
        "plan the part's PORTAMENTO ramp (d0 part, d1 from-note, stack",
        "to-note; called under TgPartHoldMark when partrec bit7 = portamento",
        "on): interval = to - from, then SOFT-DOUBLE math (constants 100.0 /",
        "12.0 / 256.0 / +-5.0) against the per-part curve record",
        "0x486D319C[partrec+6] (rate double + base step halfword at +8) finds",
        "the ticks-per-step; writes the glide state into the part's",
        "0x500AD5A8+part*0x10C block -- +0x30 dbl per-step delta, +0x38 dbl",
        "remainder, +0x28 tick period, +0x2A steps+1, +0x40 start offset",
        "(interval<<8), +0x46 curve base -- and ARMS the tick (+0x29 := 0,",
        "+0x2C := 0); zero interval or portamento off -> state cleared.",
        "NOTE: this settles the block's meaning -- it is the part's",
        "mono/portamento state, not a damper-pedal mark list",
    ],
    "TgPartGlideTick": [
        "the per-part PORTAMENTO tick (d0 part; called from the periodic",
        "part service when partrec bits 6+7 are set): idle while +0x29 ==",
        "-1; every +0x28 ticks advance the step +0x2C; mid-ramp ->",
        "interpolate the pitch offset halfwords +0x42/+0x40 from the planned",
        "soft-double deltas (mul 0x4C000523 / div 0x4C000B1C / to-int",
        "0x4C001629), then rewrite every part voice (TgVoiceListCollectPart):",
        "pitch via TgPitchRuntimeCalc -> class-0x2400 write, level via",
        "TgVoiceLevelWordCalc (bit14 cleared) -> class-0x3000 write; final",
        "step -> snap the current note's (+0x26) voices, and when +0x48 == 0",
        "release the previous note's (+0x27) voices (TgVoiceListReleaseByNote",
        "+ TgVoiceNodeKeyOff + TgVoiceSlotService), then disarm (+0x29 := -1)",
    ],
    "TgElemNoteOnFresh": [
        "THE fresh-strike note-on programmer for melodic class-bit2 voices",
        "(d0 slot, a0 request rec; TgNoteOn dispatch librec+2 bit2 -- fresh",
        "staging sets class 0x104/0x004, so every FIRST strike lands here;",
        "TgElemNoteOnStd programs the bit1 restrikes): builds the complete",
        "shadow register image before gate-on -- routing/level init",
        "0x4C037C1B, the TgPitchRuntimeCalc pitch chain, the level word via",
        "TgVoiceLevelWordCalc, melodic zone param fetchers (0x4C00FD4E ..",
        "0x4C00FFF5), all four EG segment computers (pitch/filter attack +",
        "decay) and the amp EG, raw EG writes via 0x4C03A214/0x4C03A2BF for",
        "both the even and odd companion register blocks, and the initial",
        "glide offset from the part's 0x500AD5A8 block",
    ],
    "TgKitElemNoteOn": [
        "the fresh note-on programmer for the NON-melodic classes (drum 0x10",
        "/ table 0x40 staged records; TgNoteOn's else-dispatch). Near-twin",
        "of TgElemNoteOnFresh -- same pitch/level/EG program structure, but",
        "the tone parameters come through the kit/table fetchers",
        "0x4C011F31/0x4C0121D8 instead of the melodic zone fetchers",
    ],
    "TgDrumKeyOffProgram": [
        "key-off release programmer for class-0x10 DRUM voices (d0 slot;",
        "TgVoiceSlotService dispatch): clear the note-on flag librec+8 bit7,",
        "compute the three release families into 0x50008680/88/90",
        "(TgDrumAmpReleaseCalc / TgKeyOffPitchRelease /",
        "TgKeyOffFilterRelease), merge the release halves into the shadow",
        "regs +0x02/+0x06/+0x0E/+0x12/+0x1A/+0x1E, then TgVoiceEgBurstWrite",
        "-- the same 6-write release burst the melodic path uses",
    ],
    "TgTableKeyOffProgram": [
        "key-off release programmer for class-0x40 TABLE voices: identical",
        "shape to TgDrumKeyOffProgram but the amp release comes from",
        "TgKeyOffAmpRelease(offset 0), buffers at 0x50009D1C/24/2C",
    ],
    "TgElemKeyOffRelease": [
        "key-off release programmer for the remaining classes (the class-2",
        "restrikes; TgVoiceSlotService else-dispatch): amp release with the",
        "key-off offset from the note's routing entry ((librec+0x48)+1),",
        "buffers 0x50009F58/60/68; class bit8 -> the APC-part special case",
        "(part tone desc+0x44 nibble 0xD), TgVoiceGateOff + raw writes",
        "0x4C03783B/0x4C037AC3 + TgVoiceNodeKeyOff",
    ],
    "TgNoteOnKitLayer": [
        "TgNoteOn's kit sub-path for the PCM layer of kit classes",
        "0x81/0x82/0x83 (&0xCF; 0x81/0x83 unless velocity bit7, 0x82/0x83",
        "also need kit halfword +4 bit4): allocate via TgKitLayerNoteOn,",
        "then the ONE-SHOT program chain per slot -- TgVoiceRecordReset,",
        "TgElemNoteOnFresh, TgVoiceDirtyAll, TgVoiceGateOn, TgVoiceGateOff",
        "(immediate gate-off = one-shot), TgVoiceDirtyRelease",
    ],
    "TgVoiceListBuild": [
        "THE voice-list engine behind the TgVoiceList* wrappers (a0 req: +0",
        "flags, +2 match hi=part lo=note|0x80, +4 mask): match hi & 0x3F00",
        "all set -> pool sweep over the 128 nodes 0x500D1278+n*0x2C (flag",
        "bit0 clear = in use) collecting every slot; else part < 0x22 ->",
        "the part's order-ring heads (0x500D0C64+part*0x1C: +4 sounding, +8",
        "releasing), dispatched by flags: 0x80 -> TgNodeRingReleaseWalk",
        "(note-filtered when mask & 0x7F; re-walked while the head moves),",
        "0x40 -> TgNodeRingCollectActive on the releasing ring, else",
        "TgNodeRingCollect on one or both rings; slot bytes to req+6,",
        "0xFF/0x80-terminated",
    ],
    "TgPartModSumPitch": [
        "the part CONTROLLER MOD-MATRIX (six per-destination siblings, one",
        "per enable bit 0x02..0x40): 3 mod SOURCES per part, source i's",
        "current value = partrec halfword +0x66+dest*0xC+i*2 and depth =",
        "+0x6C+dest*0xC+i*2; the route masks live at partrec+0x53A+bank*4",
        "(d1 = bank; byte[i] bit<dest> = route on, byte[i+2] bit<dest> =",
        "negative sign).  Sum over the routed sources of value*depth/0x100",
        "(LibDiv32).  THIS one is the PITCH destination (bit 0x02) --",
        "the 'part offset resolve' folded in by TgPitchNoteResolve and",
        "TgPitchRuntimeCalc",
    ],
    "TgPartModSumLevel": [
        "matrix sibling for the element LEVEL-term destination (bit 0x04,",
        "values +0x72 / depths +0x78) -- TgLevelTermFinalize's hook",
    ],
    "TgPartModSumFilter": [
        "matrix sibling bit 0x08 (values +0x7E / depths +0x84) + the",
        "part's signed base byte partrec+0x44 added at the tail (the",
        "filter-offset consumer in TgVoiceKillHandler's retrigger path)",
    ],
    "TgPartModSumCutoff": [
        "matrix sibling bit 0x10 (values +0x8A / depths +0x90) -- the",
        "CUTOFF term TgPartCutoffResolve folds with the key-follow curve",
    ],
    "TgPartModSumNoteLevel": [
        "matrix sibling bit 0x20 (values +0x96 / depths +0x9C) -- the",
        "NOTE-level hook of TgLevelResolve / TgVoiceNoteLevelCalc",
    ],
    "TgPartModSumDest40": [
        "matrix sibling bit 0x40 (values +0xA2 / depths +0xA8), consumed",
        "by the note-on programmers TgElemNoteOnFresh / TgKitElemNoteOn",
    ],
    "TgPartModDestEnableUpdate": [
        "(d0 part, d1 dest 0..11) recompute bit<dest> of the part's mod",
        "dest-enable mask partrec+0x52C: for each of the 3 banks",
        "(partrec+0x34C+bank*0x78, 12 dest records of 0xA bytes) OR the 4",
        "route bytes at +2.. and sum the depth halfword +8; the bit is set",
        "only when a route exists AND the summed depth is nonzero",
    ],
    "TgVoiceEgRegsWriteAuto": [
        "(d0 slot, a0 regs) write the six EG registers -- src +4/+8/+0x10/",
        "+0x14/+0x1C/+0x20 to classes 0x0001/0x0002/0x0005/0x0006/0x0009/",
        "0x000A via TgVoiceRegWrite -- unless the voice record's halfword",
        "+2 has bit7 (then TgVoiceEgBurstWrite takes over); gated on the",
        "TG-enable 0x500CE380 != 0x7F like the whole writer family",
    ],
    "TgVoiceEgRegsWriteRaw": [
        "the no-burst-check twin of TgVoiceEgRegsWriteAuto (same six",
        "classes) -- the raw helper 0x4C03783B cited by TgElemKeyOffRelease",
    ],
    "TgVoiceFadeLevelGateOff": [
        "(d0 slot, d1 level13) restore regs r0/r1 from the record, then",
        "set the LEVEL WORD's (librec+0x54 -> class 0x3000) low 13 bits to",
        "d1 with bit14 cleared and gate the voice off -- the fade-to-level",
        "kill used by TgVoiceLevelRampTick",
    ],
    "TgPartToneModSetupMelodic": [
        "(d0 part) build the part tone block's (0x500CE404+part*0x130) mod",
        "control halfword +4 and the four LFO/mod unit blocks +0x60+u*0x34",
        "for a MELODIC tone: unit source codes 1/2/4 from the 2-bit fields",
        "of desc+0x12 (written to block byte +0x20), active flags bits0-3 +",
        "0x2000/0x4000 from desc+0x11 via the jump tables 0x485879B4/",
        "0x48587990 indexed by desc+0x44's low nibble; partrec bit-0x2000",
        "AND nibble 0xD forces units 2/3 on (their block byte +0x88/+0xBC",
        "area bit0); tails into 0x4C0394A4 / 0x4C039D83(part,0) /",
        "0x4C0396E7 (the unconverted apply layer)",
    ],
    "TgPartProgramSet": [
        "(d0 part, d1 prog, stack bank-lo/bank-hi/opt) THE ONLY writer of a",
        "part's voice. Sets the part's tone address bytes (tone block",
        "0x500CE404+part*0x130, +8 from d1, +7 and +6 from the stack), then",
        "rebuilds through 0x4C00E5C0/0x4C009C8D/0x4C007C45/0x4C038942/",
        "0x4C007724 and re-runs TgPartToneModSetupDispatch.",
        "★ THAT FIRST STEP IS TgPartLocalEditClear: assigning a voice to a",
        "part DISCARDS THAT PART'S SOUND EDIT (bit0 of 0x500C58AE+part*9",
        "goes to 0, so the tone-apply layer stops reading the RAM shadow).",
        "Only two callers: TgPartProgramInitAll at boot, and the 0xC0",
        "(program-change) case of the library's TG command interpreter at",
        "0x4C003D4A. That interpreter reads a MIDI-SHAPED byte stream from",
        "the queue 0x500AD39C -- status & 0xF0 selects 0x90 note-on (->",
        "TgPartKeyEvent), 0xA0, 0xB0, 0xC0 program change, 0xD0, 0xE0, 0xF0",
        "-- but over 34 PARTS rather than 16 MIDI channels and with longer",
        "payloads. Any panel action that changes a part's sound therefore",
        "arrives here, and clears the edit on the way through.",
    ],
    "TgPartCutoffResolve": [
        "(d0 part, d1 bank, a0 librec, stack depth/base) -> 0..0x70 filter",
        "cutoff: key-follow curve ROM 0x486D23E4[note librec+0x10 & 0x7F]",
        "* depth >> 5, + TgPartModSumCutoff(part,bank) + base + the part's",
        "signed cutoff offset partrec+0x45",
    ],
    "TgVoiceModSlotUpdate": [
        "update one mod-destination SLOT (8-byte {val,flags,phase,, depth,,",
        "target}) of a voice (librec+0x82+u*8) or of the part dynamic state",
        "(0x500AD5A8+part*0x10C+0x4A+bank*0x30+u*8): target = source read",
        "0x4C0399DD scaled by note velocity (librec+0x10, 0x7F-vel) and",
        "clamped to +-0x1FFF; source sel 0/1 adds 0x4C0146D3(part,3) +",
        "partrec+0x43 << 6 and the tone entry's low-5-bit rate, clamped",
        "0..0x1E into the slot's period byte; slot armed with flags 0x10",
        "(one-shot delay) or cleared when depth 0; the routed value is",
        "read back through partrec+0x52C bit<dest> -> TgPartModDestValueCalc",
    ],
    "TgPartModDestApply": [
        "(d0 part, d1 sel, stack bank/dest) compute and latch one mod",
        "DESTINATION at part level: cache slot partstate+2+dest*2 (0xFFFF =",
        "invalid), gates = tone block halfword +0xA & ROM 0x486D1224[dest]",
        "and partrec+0x52C bit<dest>; value via 0x4C00F9B4(part,sel,",
        "0x40|dest when the tone's +0x2C+dest*2 byte has bit7); dests 0/4",
        "add 0x4C0146D3(part,2) + partrec+0x41 << 6; result < 0x100 is",
        "summed with the partrec+0x34C bank tables (+dest*0xA halfwords",
        "+0/+0x78), clamped 0..0x3FFF and written to the part GLOBAL reg",
        "class 0x0400 (both TGs); tone +0x2C bit7 also derives the class",
        "0x0C00 write (val & 0x7F << 16) / 0x48",
    ],
    "TgPartModDestRefreshAll": [
        "(d0 part, d1 sel) TgPartModDestApply for all 12 destinations,",
        "then -- partrec bit-0x2000 parts only -- the TYPE-7 EG TIME-RAMP",
        "extras: ratios TgPartEgRampSegScaled(part,0/1) and",
        "TgPartEgRampCache54Scaled feed 0x4C00F9B4 sels 0x10/0x11/0x20,",
        "results latched at partstate+0x1A/+0x1C/+0x1E and written to the",
        "class-0x0400 global regs (the STATIC-RE answer to what partrec",
        "bit13 gates: the ramp-scaled part registers)",
    ],
    "TgVoiceReleaseCountdownTick": [
        "(a0 librec) tick the voice's release countdown halfword +0x52:",
        "bit15 counts the high byte down by 0x100 -- at 0 sets the voice",
        "record's +0xA bit15, gates off and key-offs the node; bit7 counts",
        "the low 7 bits -- at 0 TgVoiceSlotService(slot, 0xFF)",
    ],
    "TgVoiceLevelRampTick": [
        "(a0 librec) tick the LEVEL WORD +0x54 auto-ramp: low 7 bits != 0",
        "just count down (hitting 1 -> TgVoiceDampA2); else pick the note",
        "level source by bit11 (librec+0x58 vs +0x50) -> TgVoiceNoteLevel-",
        "Write, then mode bits 0x7000: 0x4000 = ramp +0x56 by the signed",
        "step +0x5A -- floor -0x100 kills the voice (node key-off + slot",
        "service), passing the hold level +0x5E re-plans via TgVoiceLevel-",
        "WordCalc -> TgVoiceFadeLevelGateOff; 0x2000 = TgVoiceDamp7F +",
        "TgVoiceReg01WriteGateOff; 0x1000 = ramp by +0x5C toward the",
        "target with TgVoiceDampA2 on the final step",
    ],
    "TgVoiceModLfoStep": [
        "step one mod-slot OSCILLATOR (a1 slot state, a0 tone entry, d0",
        "part): flags byte +1 bit-0x18 modes -- 0x10 = delay counter",
        "(+2 counts to the period byte +0, then re-arms as running 0x08),",
        "0x08 = running (phase wrap -> value via 0x4C0399DD or LibDiv32",
        "triangle scaled by the depth +4), output halfword +6; the +-0x1FFF",
        "result is scaled by the tone block's +0xE+dest*2 halfword / 0x800",
    ],
    "TgPartModSlotSweep": [
        "the per-part MOD-SLOT service sweep (frame 0x104): per part --",
        "portamento TgPartGlideTick (partrec bits 6+7), tone +0xA gate,",
        "0x4C039A09(part), collect the part's voices (TgVoiceListCollect-",
        "PartAll) and for each librec walk the 4 mod units: unit's tone",
        "entry +0x52+u*4 (bit7 = per-voice), stepping the librec+0x82+u*8",
        "or shared part slots via TgVoiceModLfoStep and writing the",
        "per-voice depth regs via TgVoiceModDepthWrite (classes 0x0409/",
        "0x0402/0x040D/0x0406 from record +0x2C/+0x30/+0x2E/+0x32); tail =",
        "global sweep releasing voices whose +0x52 countdown fired",
        "(graceful TgVoiceReleaseCountdownTick for partrec bit-0x2000",
        "parts, immediate key-off otherwise)",
    ],
    "TgVoicePeriodicService": [
        "the OTHER periodic tick: all 0x22 parts get TgPartGlideTick +",
        "0x4C039A09, then 0x4C009A16/0x4C009839 and -- when active -- a",
        "global voice sweep (TgVoiceListCollectGlobal) running the +0x52",
        "release countdowns AND the +0x54 level-word auto-ramps",
        "(TgVoiceLevelRampTick), with the immediate-release fallback for",
        "parts without bit-0x2000",
    ],
    "TgPartGlideStateReset": [
        "(d0 part) reset the part's PORTAMENTO state (0x500AD5A8+part*",
        "0x10C): current note +0x26 := 0xFF, clear the planned deltas",
        "+0x28..+0x35 and the live offsets +0x40/+0x42, retrig +0x44 := -1",
    ],
    "TgPartToneProgramGet": [
        "the PART TONE BLOCK accessor leaves (2026-07-20). The block is",
        "0x500CE404+part*0x130; TgPartProgramSet writes the three tone-",
        "address bytes +8/+7/+6 (program / bank-lo / bank-hi) and the",
        "resolved tone DESCRIPTOR pointer lives at +0. This one reads +8.",
        "All four are `rets` leaves (called with `calls`, no reg save).",
    ],
    "TgPartToneIsTableClass": [
        "(d0 part, 16-bit) -> 1 when the part's tone descriptor is a TABLE",
        "tone, i.e. (desc+0x10 & 0xC0) == 0x40 -- the same class nibble",
        "TgNoteOn dispatches on (0x00/0xC0 melodic, 0x80 drum kit, 0x40",
        "table)",
    ],
    "TgPartVoiceRecFetch": [
        "the VOICE-RECORD FETCH ladder (2026-07-20). Four parallel entries:",
        "TgPartVoiceRecFetch/Idx take (part, elem[, idx]) plus a flag byte",
        "whose bit7 selects the RESOURCE path; TgPartVoiceRecFetch*Sel are",
        "the thin front ends that first ask 0x4C00C6BF whether the part is",
        "using its LOCAL EDIT copy -- if so they read the RAM record",
        "0x500C1183+idx*0x8E (0x4C00C2C8/0x4C00C2DC) instead. On the",
        "resource path the tone-block program byte +8 picks the fetcher:",
        "0x11/0x19 are special-cased (0x4844A434/0x4844A4B5) against the",
        "generic ones (0x4844ABF7 = table 0x501496B8+0x70F7+idx*0x8E,",
        "0x4844AC30, 0x48449790/0x484496CE = the banked resource lookup",
        "through 0x5003A5A4/A8/AC + 0x5003A554/58/5C). Same 0x8E record",
        "stride on both sides -- the RAM copy is an edit shadow of the",
        "resource record.",
    ],
    "TgPartElemMapScratchBuild": [
        "(d0 part, d1 sub, stack note/arg/arg) build the part's ELEMENT MAP",
        "scratch record at 0x50009F70+part*0x8C+sub*0x23: when the global",
        "halfword 0x5000B208 has bit15 set the record comes from",
        "0x4844987E instead; otherwise a 0x23-byte template is copied from",
        "ROM 0x485877FC and six 3-byte entries at +5 are filled with",
        "(note&0x7F, arg, arg). Returns the record in a0.",
    ],
    "TgPartElemProgramApply": [
        "the APPLY twin of the fetch ladder: same four-entry shape (plain /",
        "Sel / Idx / IdxSel) but instead of returning a record it programs",
        "the part -- flag bit7 = resource path (tone-block +8 of 0x10/0x18",
        "special-cased to 0x4844AC55/0x4844A510/0x4844AC78/0x4844A56B),",
        "class match on desc+0x10 & 0xCF routing to 0x4C00A1F9 or the",
        "element-map builder TgPartElemMapScratchBuild, and the *Sel front",
        "ends divert to the local-edit writers 0x4C00C28F/0x4C00C2FB when",
        "0x4C00C6BF says the part is edited locally",
    ],
    "TgPartProgramHandlerDispatch": [
        "(d0 part, ...) dispatch on the part's tone-block program byte +8",
        "(range 0x11..0x78) through the 8-byte {program, handler} hash",
        "table 0x48587830..0x485878B0 (linear probe, wraps at the end):",
        "a hit jumps to the entry's handler, a miss falls through to the",
        "generic TgPartElemProgramApplyIdxSel / *IdxSel pair. Reached by",
        "an indirect jump, not by a `call`.",
    ],
    "TgPartProgramApply": [
        "THE PROGRAM-CHANGE REBUILD (0x4C038942, called by TgPartProgram-",
        "Set after it stores the tone-address bytes). 2.9 KB of per-class",
        "work: the same {program, handler} table pair 0x485878B0/",
        "0x48587930 selects a case, each of which re-fetches the part's",
        "records (0x4C00C233 TgPartAuxRecPtr, 0x4C00C25D/0x4C00C28F,",
        "0x4C0109E5), rebuilds the element assignment (TgPartElemLastSet",
        "0x4C01222A, 0x4844992A/0x484499EB) and re-runs the element",
        "programmers 0x4C00A1F9 / TgPartElemMapScratchBuild. Local-edit",
        "parts (0x4C00C6BF) take the 0x4C038BE4 branch.",
    ],
    "TgPartToneModUnitBuild": [
        "(d0 part) the apply layer TgPartToneModSetupMelodic tails into:",
        "copies the 8-byte ROM template 0x48587820 to the frame, then",
        "walks the part's four mod-unit blocks (tone block +0x60+u*0x34)",
        "against the PART RECORD 0x500B5340+part*0x54C, latching the unit",
        "configuration built by TgPartToneModSetup*",
    ],
    "TgPartToneModParamBuild": [
        "(d0 part, d1 sel) clear the tone block's mod control halfwords",
        "+0xA/+0xC and rebuild the per-unit parameter set from the part",
        "record 0x500B5340+part*0x54C+0x42 and the block fields +4/+0x26/",
        "+0x32/+0x60 -- the companion of TgPartToneModUnitBuild",
    ],
    "TgPartModUnitParamGet": [
        "THE MOD-SOURCE READ cited by TgVoiceModSlotUpdate/TgVoiceModLfo-",
        "Step (0x4C0399DD): (d0 part, d1 unit, stack idx) -> the halfword",
        "at tone block +0x60+unit*0x34 +0x22+idx*2 (i.e. 0x500CE404+part*",
        "0x130 +0x82+unit*0x34+idx*2). Confirms the +0x60+u*0x34 mod-unit",
        "block stride documented for TgPartToneModSetupMelodic.",
    ],
    "TgPartModUnitRampStep": [
        "(d0 part) the per-part mod-unit RAMP step run by TgPartModSlot-",
        "Sweep and TgVoicePeriodicService (the 0x4C039A09 call sites):",
        "for each unit it interpolates through the halfword curve ROM",
        "0x486D1E54 in DOUBLE PRECISION (LibU32ToF64/LibU16ToF64 ->",
        "LibF64Div/Mul/Add -> 0x4C001417) and stores the result back as a",
        "halfword -- the only soft-float user in the mod runtime",
    ],
    "TgPartModUnitDepthCurve": [
        "(d0 part, d1 idx, stack signed offset) -> curve ROM 0x486D1E54",
        "halfword at clamp(desc+0x2B+idx*2 + offset, 0..0x7F) -- the depth",
        "curve TgPartModUnitRampStep interpolates between",
    ],
    "TgPartToneTypeParamGet": [
        "(d0 part, d1 sel) read a parameter of the tone's TYPE feature",
        "record 0x486D2ED5+type*0x27 (type = desc+0x44 & 0xF), byte",
        "+0x16+sel*5, with per-type dispatch: types 0..3 share one path",
        "(sel 1 subtracts the desc+0x49 signed byte from -0x64), 4/5 a",
        "second, 6/8 a third, everything else the default. Same feature",
        "record TgVoiceEgSegParamGet indexes.",
    ],
    "TgPartEgRampBuild": [
        "(d0 part, d1 sel) THE TYPE-7 EG TIME-RAMP BUILDER (0x4C039D83,",
        "the third tail of TgPartToneModSetupMelodic): starts with",
        "TgPartEgRampInit and then RETURNS IMMEDIATELY unless the part",
        "record's halfword 0x500B5340+part*0x54C has bit 0x2000 set --",
        "independent confirmation that partrec bit13 gates the EXTENDED /",
        "type-7 family. The body walks the part's cached EG halfwords",
        "(tone block +0x4A) against the ROM feature/curve set 0x486D2ED5",
        "(type record), 0x486D2986/0x486D29DA/0x486D2D0A and writes the",
        "scaled ramp back -- the source TgPartEgRampSegScaled and",
        "TgPartEgRampCache54Scaled later read.",
    ],
    "TgPartModRouteMaskSet": [
        "THE ROUTE/SIGN MASK WRITER of the mod matrix: (d0 part, d1 src,",
        "stack mask/setbits/clrbits) walks the 12 destinations, and for",
        "each one whose bit is set in the per-dest ROM tables 0x485865EC",
        "(route) / 0x485865F0 (sign) ORs or ANDs the corresponding byte of",
        "the PART RECORD 0x500B5340+part*0x54C at +0x53A+dest*4 (ROUTE)",
        "and +0x53C+dest*4 (SIGN) -- pinning down which of the +0x53A",
        "bank bytes is which, a detail the read-side decode left open",
    ],
    "TgModValueScale1": [
        "(d0 value, d1 flags, stack depth) -> value*depth scaled: flags",
        "bit7 = BIPOLAR (value re-centred at 0x40 and doubled), the",
        "product is <<8 and divided by 0x1FC0 through LibDiv32. SIX",
        "byte-identical twins exist (0x4C005730/5766/579C/57D2/580B/583E)",
        "-- one per mod-matrix parameter group, so that the jump-table",
        "cases of TgPartModConfigSet/Store can each call their own.",
    ],
    "TgPartModVoiceApply": [
        "(d0 sel, d1 slot, a0 part state) re-apply ONE mod parameter to a",
        "live voice: TgVoiceRecordPtr(slot) then a per-sel case that",
        "rewrites the voice record fields and their TG registers.",
        "TgPartModVoiceApplyB is the larger sibling (state +0x3C).",
    ],
    "TgPartModVoicesRefreshA": [
        "(d0 part, d1 param) the LIVE RE-APPLY helpers TgPartModConfigSet",
        "calls after storing: TgVoiceListCollectPartAll builds the part's",
        "voice list (entries from +6, 0x80 terminates) and each voice is",
        "pushed through TgPartModVoiceApply*. Three flavours (A/B/C) for",
        "the different parameter groups.",
    ],
    "TgModDepthScaleRom": [
        "(d0 value, d1 flags) -> value * ROM halfword 0x486D1E90 / 0x7F",
        "with the same bit7 bipolar re-centring -- the fixed-scale leaf",
        "used by the depth cases of TgPartModConfigSet",
    ],
    "TgPartModDepthDefaultSet": [
        "(d0 part, d1 dest, stack param 1..6) write a per-destination",
        "DEFAULT into the part record's depth halfwords 0x500B5340+part*",
        "0x54C +0x6C+dest*0xC (0x200), +0x78+... (0x20), ... -- the reset",
        "path for the value/depth pair array the sum resolvers read",
    ],
    "TgPartModConfigStore": [
        "the STORE-ONLY twin of TgPartModConfigSet: identical parameter",
        "range (1..0x2E) and identical partrec targets (+0x66+dest*0xC",
        "value, +0x72+... i.e. the next dest's slot) through its own",
        "46-entry jump table 0x48586658, but WITHOUT the voice re-collect",
        "and re-apply -- the bulk/preset-load path, where the caller",
        "refreshes everything once at the end",
    ],
    "TgModDepthScaleClamp": [
        "(d0 value, d1 flags, stack depth) -> the same bipolar scaling but",
        "normalised through divu by 0x7F and >>6, clamped to 0..0x1FFF --",
        "the +-0x1FFF slot range TgVoiceModSlotUpdate/TgVoiceModLfoStep",
        "work in",
    ],
    "TgPartModConfigSet": [
        "THE WRITE SIDE OF THE CONTROLLER MOD MATRIX (2026-07-20) --",
        "the setter whose read side is TgPartModSumPitch..TgPartModSum-",
        "Dest40. (d0 part, d1 source, stack param/value/...): the param",
        "byte (&0x7F, valid 1..0x2E) indexes the 46-entry jump table",
        "0x48586710. Each case scales the incoming value through one of",
        "the 0x4C0057xx / TgModValueScale* leaves and stores it into the",
        "PART RECORD 0x500B5340+part*0x54C at +0x66+dest*0xC+src*2 (value)",
        "or +0x72+... (i.e. +0x66+dest*0xC with dest stepping by 0xC) --",
        "exactly the value/depth pair layout the sum resolvers read. It",
        "then re-collects the part's live voices (TgVoiceListCollectPart-",
        "All) and re-applies (0x4C0040F4/0x4C004324/0x4C0043F5/0x4C004499)",
        "so the change is audible immediately. The route/sign-mask and",
        "dest-enable cases call TgPartModDestEnableUpdate to recompute",
        "partrec+0x52C from the +0x34C bank tables.",
    ],
    "TgPartCtrlSenseKit": [
        "the three TgPartModRetrigger SATELLITES (0x4C01349C kit /",
        "0x4C033C0F melodic / 0x4C03089B element). All three are gated by",
        "the same pair: the GLOBAL mode halfword 0x500C0758 bit 0x0200 and",
        "the part record's halfword bit0; the sensitivity byte is",
        "partrec+0x13. The kit/melodic pair scale it by the tone",
        "descriptor's +0x4C byte (only for partrec bit-0x2000 parts) and",
        "then by desc+0x43, both as (0x80 + signed byte)/0x100 through",
        "LibDiv32, and clamp through TgKitZoneParamClamp / TgZoneParam-",
        "Clamp to 0..0x7F; with the global bit clear they fall back to",
        "0x28 when 0x500C0758 bit 0x02 is also clear. NOTE the scaling",
        "bytes +0x43/+0x4C are read from the TONE DESCRIPTOR (tone block",
        "+0 -> desc), not from the part record -- earlier mod-matrix docs",
        "that said 'partrec+0x43' conflated the two.",
    ],
    "TgPartCtrlSenseElem": [
        "the ELEMENT flavour of the TgPartModRetrigger satellites (a0 tone",
        "rec, a1 zone rec): same 0x500C0758 bit9 + partrec bit0 +",
        "partrec+0x13 gate, then a mode taken from partrec+0x62 bits",
        "11..12 selects between the per-element signed offset",
        "partrec+0xCE+elem*5 and the zone record's +0xF byte scaled by",
        "(0x80 + signed)/0x100 -- the per-element tuning term",
    ],
    "TgChanEgSeg0LevelSet": [
        "THE TG OUTPUT-CHANNEL REGISTER FILE (0x4C037D0F..0x4C037F52).",
        "Thirteen channels, shadowed in RAM at 0x500CE2B0 + chan*0x10 and",
        "mirrored to the chip through TgVoiceRegWrite_entry with the",
        "channel number in the 20-bit SLOT field, so the composed address",
        "halfword is 0x8008 + chan*0x10 (bit15 set = the non-voice",
        "register space). The shadow holds a four-segment level envelope:",
        "  +0x00 hw  class 0x8008  seg0  rate = bits 11..8, level = bits 6..0",
        "  +0x02 hw  class 0x8108  seg1  same layout",
        "  +0x04 hw  class 0x8208  seg2  same layout",
        "  +0x08 long class 0x8308  seg3  rate bits 11..8, level bits 6..0,",
        "                                 plus a 5-bit field at bits 16..12",
        "  +0x0C long class 0x800A  a pair of 7-bit levels (bits 14..8, 6..0)",
        "Each field has a LEVEL-ONLY setter and a rate+level setter; both",
        "read-modify-write the shadow first, then push the whole halfword.",
        "Channels are picked per part: the part record 0x500B5340+part*",
        "0x54C halfword +0x62 bits 10..8 index the ROM map 0x486D109A",
        "(value 8 = 'no channel', the caller 0x4C004DE4 returns early).",
        "Defaults come from the 13 x 16-byte ROM image 0x4858759C, copied",
        "into the shadow by TgChipResetSideA.",
    ],
    "TgChanEgSeg3Set": [
        "the seg3 rate+level setter also writes the 5-bit field at bits",
        "16..12 of the +0x08 longword. Bit 16 straddles OUT of the 16-bit",
        "data word: TgVoiceRegWrite ORs it into the register-address half,",
        "so a set bit 16 addresses 0x8309 instead of 0x8308.",
    ],
    "TgGlobalRegsA0LoadA": [
        "(a0 table) load the five class-0xA0xx GLOBAL registers of TG A",
        "from an 18-byte image: longs at +0/+4/+8/+0xC -> classes 0xA000/",
        "0xA002/0xA004/0xA006, halfword +0x10 -> class 0xA008, all at slot",
        "0 through TgVoiceRegWrite_entry. Gated on the TG-enable cell",
        "0x500CE380 != 0x7F like the whole writer family. ROM image =",
        "0x486D11F4; the TG B twin TgGlobalRegsA0LoadB uses 0x486D1208 and",
        "notably IGNORES the table for the first four, writing the",
        "constant 0x00008000 instead.",
    ],
    "TgGlobalRegsB0LoadA": [
        "(a0 table) load the eight class-0xB000..0xB00E GLOBAL registers",
        "of TG A from eight consecutive halfwords, slot 0, through",
        "TgVoiceRegWrite_entry; same 0x500CE380 != 0x7F gate. ROM image =",
        "0x486D11D4 (TG A) / 0x486D11E4 (TG B, TgGlobalRegsB0LoadB): the",
        "two differ in exactly one halfword (+0xC: 0x03AF vs 0x032F).",
    ],
    "TgChipResetSideA": [
        "THE TG COLD BRING-UP, side A -- the other half of the silence",
        "story in kn7000_mame/notes (the TG-enable gate 0x500CE380).",
        "Sequence, verbatim from the code:",
        "  1. call the STRAP PROBE 0x484D7713 and set 0x500CE380 = 0x7F",
        "     ('no TG', every register writer becomes a no-op);",
        "  2. if the probe returns 3 the chip is absent -- SKIP the reset",
        "     and leave 0x7F in place;",
        "  3. otherwise 0x500CE380 = 0x40 (TG present) and pulse the chip:",
        "     1 -> 0x98050010 three times, then 3 -> 0x98050004 three times;",
        "  4. load the global blocks (TgGlobalRegsB0LoadA 0x486D11D4,",
        "     TgGlobalRegsA0LoadA 0x486D11F4);",
        "  5. for each of the 0x40 hardware voice slots: copy the 0x84-byte",
        "     ROM template 0x4858766C into the voice record 0x500CA0B0+",
        "     slot*0x84, then TgVoiceGateOnWrap / TgVoiceGateOff /",
        "     TgVoiceStealSilence;",
        "  6. for each of 0x100 sample entries write classes 0x0400/0x0C00",
        "     from 0x48587700/0x48587702 via TgGlobalRegWriteBoth;",
        "  7. for each of the 13 output channels copy the 16-byte default",
        "     0x4858759C+chan*0x10 into the shadow 0x500CE2B0+chan*0x10 and",
        "     push all five channel registers (0x8008/0x8108/0x8208/0x8308/",
        "     0x800A).",
        "TgChipResetSideB is the same for TG B (port 0x98040000/0x98040004,",
        "0x80 voice slots, channel slots 0x40+chan, and it RETURNS when the",
        "probe says 3 rather than skipping only the reset).",
    ],
    "TgGlobalRegsReloadA": [
        "re-push TG A's global blocks from the same ROM images the cold",
        "reset used (0x486D11D4 -> TgGlobalRegsB0LoadA, 0x486D11F4 ->",
        "TgGlobalRegsA0LoadA) without touching the voice slots or the",
        "channel shadow -- the 'restore global defaults' entry",
    ],
    "TgPartAuxModRecPtr": [
        "THE LOCAL-EDIT SHADOW (0x4C00C233..0x4C00C890). A part playing an",
        "EDITED sound does not read the read-only tone resource record; it",
        "reads a writable RAM copy, and every fetch/apply entry in the",
        "part tone-apply layer comes in a plain and a *Sel flavour, the",
        "*Sel one asking TgPartLocalEditActive which to use.",
        "There are TWO copy families, laid out contiguously in .bss:",
        "  0x500BDB04 + idx*0x2C8   AUX EDIT RECORD (TgPartAuxRecPtr), but",
        "        ONLY idx 0x10/0x11/0x12 exist -- every other index returns",
        "        NULL, so the three records occupy exactly 0x500C0784..",
        "        0x500C0FDC. The 0x2C8 divides EXACTLY: header 0x54, then",
        "        4 x 0x7A mod units at +0x54 (this function), then",
        "        4 x 0x23 elements at +0x23C (TgPartAuxElemRecPtr).",
        "  0x500C0FDC               a 423-byte tone-descriptor SCRATCH copy",
        "        (TgPartToneDescScratchPtr / *Copy), filling the gap up to",
        "  0x500C1183 + idx*0x8E    THE LOCAL-EDIT SHADOW proper. 0x8E is",
        "        exactly the resource record's stride, and the record",
        "        divides as header 0x10 + 2 x 0x1C (at +0x10, TgPartLocal-",
        "        EditModRecPtr) + 2 x 0x23 (at +0x48, TgPartLocalEdit-",
        "        ElemRecPtr) = 0x8E.",
        "Lifecycle: TgPartAuxRecBuild and TgPartLocalEditRecBuild POPULATE",
        "(from the resource record), TgPartAuxElemRecBuild / TgPartLocal-",
        "EditElemRecBuild refresh one sub-record, and nothing here frees or",
        "clears them -- the copies are permanent per-part buffers, so an",
        "edit is invalidated only by REBUILDING it from the resource.",
    ],
    "TgPartLocalEditActive": [
        "(d0 part) -> nonzero when the part runs its LOCAL EDIT copy: bit0",
        "of the byte 0x500C58AE + part*9. This is the predicate every *Sel",
        "front end in the tone-apply layer consults (0x4C00EDF5 and ~30",
        "more call sites) to choose the RAM shadow 0x500C1183+idx*0x8E over",
        "the resource record. TgPartLocalEditFlagB reads bit1 of the same",
        "byte -- the 9-byte per-part record is the edit-state block: byte 0",
        "is the flags, bytes 1..6 are edit parameters seeded from ROM",
        "(TgPartEditStateDefaults). SETTER = TgPartLocalEditActivate /",
        "TgPartLocalEditSelect; CLEARER = TgPartLocalEditClear, whose",
        "callers are the part-switch inside TgPartLocalEditSelect, the boot",
        "reset TgLocalEditResetAll, and -- the user-visible one --",
        "TgPartProgramSet (its 0x4C00E5C0 step IS this clear).",
    ],
    "TgPartLocalEditActivate": [
        "★ THE SETTER of the local-edit bit, and the whole answer to 'does",
        "my sound edit survive?'. (d0 part). The guard the compiler emitted",
        "is `if (0x10 <= part <= 0x12 || (flags & 3) == 3)`, and the second",
        "half can never do anything (it falls straight into the",
        "`if (flags & 1) return` below), so IN PRACTICE only the three aux",
        "parts 0x10/0x11/0x12 can go into local-edit state. If bit0 is",
        "already set it returns immediately -- otherwise it SETS bit0, then",
        "TgPartAuxRecRefresh_entry (build the aux record + its four mod",
        "units), TgPartEditStateDefaults_entry (seed bytes 1..6 from the",
        "ROM defaults at 0x486D3192) and finally re-applies the part's tone",
        "through 0x4C0384C4/0x4C0384D9/0x4C0384EE + 0x4C038942.",
        "It is called LAZILY from the SOUND EDIT parameter APIs (0x4C00D047,",
        "0x4C00E8D3, 0x4C00EAA0, 0x4C00F170, 0x4C01466C): the shadow springs",
        "into existence the first time a parameter is read or written, and",
        "from then on the *Sel front ends read RAM instead of the ROM",
        "resource record.",
    ],
    "TgPartLocalEditClear": [
        "★ THE CLEARER. (d0 part) writes 0 over byte 0 of the 9-byte record",
        "0x500C58AE+part*9 -- one store, and the part is no longer 'edited'.",
        "Nothing frees the shadow buffer: the RAM copy stays exactly as the",
        "user left it, but TgPartLocalEditActive now returns 0, so every",
        "*Sel front end goes back to the read-only resource record and the",
        "edit is functionally gone. The next activation REBUILDS the shadow",
        "from the resource, overwriting it.",
        "Three callers: (1) TgPartLocalEditSelect, when the current edit",
        "part changes; (2) TgLocalEditResetAll at lib bring-up; (3) ★",
        "TgPartProgramSet -- the part PROGRAM (voice) setter.",
    ],
    "TgPartLocalEditSelect": [
        "(d0 part) make `part` the current edit part. The global 0x500C59E0",
        "holds it (0xFF = none, TgLocalEditPartSet writes it). If a",
        "DIFFERENT part is currently selected, that part's flag byte is",
        "cleared through TgPartLocalEditClear and its unedited tone is",
        "re-applied -- i.e. moving the SOUND EDIT focus to another part",
        "throws the previous part's edit away. Then the same",
        "0x10..0x12 guard as TgPartLocalEditActivate, 0x500C59E0 = part,",
        "bit0 set, and TgPartLocalEditRecBuildAll_entry rebuilds the entire",
        "shadow (all 0x80 records plus both element sub-records each).",
    ],
    "TgPartAuxMod28Get": [
        "One of the aux-record FIELD ACCESSORS: leaf get/set pairs over the",
        "mod-unit block 0x500BDB04+idx*0x2C8 +0x54+unit*0x7A. The ranged",
        "ones (+0x19, +0x28, +0x2A, +0x2C, +0x2E) are driven by the offset",
        "applier at 0x4C00A820, which reads the field, adds a signed delta",
        "and clamps it through 0x4C00A7BE to +/-0x64 (100) or +/-0x7F --",
        "the shape of a SOUND EDIT parameter with a +/-100 display range.",
        "The +0x19 setter writes the LOW 7 BITS ONLY and clears bit7 while",
        "doing so; +0x52/+0x56/+0x5A have bit7-only setters instead.",
    ],
    "VoiceRecFetchBanked": [
        "The region-1 VOICE-RESOURCE BANK FETCHERS -- the read-only side the",
        "local-edit shadow is copied FROM. Five banks: a class code 0..4",
        "(computed by 0x485713DB) selects a bank descriptor pointer",
        "0x5003A5A4+class*4 and a load base 0x5003A554+class*4 (records are",
        "stored as offsets relative to where the bank was loaded, so every",
        "lookup adds the base back). Descriptor +0x04 and +0x14 are dword",
        "directories of records, +0x18 is the element table (stride 0x23).",
        "A record is 0x8E bytes: header 0x10, two 0x1C sub-records at +0x10",
        "(VoiceSubRecFetch), four 0x7A mod units at +0x54",
        "(VoiceModRecFetch) -- the same geometry the RAM shadow mirrors.",
        "Overrides are indirected through 0x484494E4(part, record byte",
        "+0x0D or +0x11); a 0xFF answer means 'no override' and the",
        "*Default* leaves supply the fallback pointer.",
    ],
    "TgPartAuxRecBuild": [
        "(d0 part) POPULATE the aux edit record: TgPartToneDescPtr gives",
        "the read-only descriptor, 286 halfwords (572 bytes) of it are",
        "copied into 0x500BDB04+idx*0x2C8 -- i.e. the header plus all four",
        "mod-unit slots -- then for each of the four mod units the",
        "0x3D-halfword (122 = 0x7A byte) block pointed at by tone block",
        "+0x60+unit*0x34 is copied over the unit sub-record +0x54+",
        "unit*0x7A. The 0x7A stride of TgPartAuxModRecPtr is therefore",
        "exactly one mod-unit parameter block.",
    ],
    "TgPartLocalEditRecBuild": [
        "(d0 part, d1 idx, stack ...) POPULATE the local-edit shadow:",
        "TgPartVoiceRecFetch_entry returns the resource record, its first",
        "0x48 bytes are copied verbatim to 0x500C1183+idx*0x8E, then the",
        "region-1 fetcher 0x48449813 supplies replacements for the two",
        "0x1C sub-records -- +0x10 is overwritten unless resource byte",
        "+0xD bit1 is set, +0x2C unless bit2 is set. So the shadow is a",
        "byte-for-byte copy of the resource record EXCEPT for those two",
        "banked sub-records, which come from a separate lookup.",
    ],
    "TgPartAuxElemRecBuild": [
        "(d0 part, d1 elem, stack ...) refresh ONE aux ELEMENT sub-record:",
        "TgPartElemProgramApply_entry produces the source, 0x23 bytes go",
        "to 0x500BDB04+idx*0x2C8 +0x23C+elem*0x23. TgPartLocalEditElem-",
        "RecBuild is the shadow-side twin (source TgPartElemProgram-",
        "ApplyIdx_entry, destination 0x500C1183+idx*0x8E +0x48+elem*0x23).",
    ],
}

INSN = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")


def load_syms(data):
    syms = []
    for line in open(SYM):
        m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
        if m and not line.startswith(";"):
            a = int(m.group(1), 16)
            if a >= BASE:
                syms.append((a - BASE, m.group(2)))
    return sorted(syms)


def load_manual_syms():
    """Hand-recovered names from kn7000_manual.sym (uncommented entries only).
    Names ending in `_entry` mark the MN10300 register-save-`call` entry a few
    bytes after a function's movm prologue: they become equates + in-code
    comment markers, but NOT function-split boundaries."""
    syms = []
    for line in open(MANUAL_SYM):
        if line.lstrip().startswith(";"):
            continue
        m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
        if m:
            syms.append((int(m.group(1), 16), m.group(2)))
    return syms


def discover_functions(d):
    """Every `call`/`calls` target in code region 1 is a function entry point.
    (On the MN10300 the call instruction itself saves the register list, so a
    callee does not begin with a uniform prologue -- it starts straight into its
    work -- which is why we key on *being called* rather than on a byte pattern.)
    These give the internal helpers the reflection tables don't name a synthetic
    `func_<ADDR>` label, so converted code shows named calls everywhere. `jmp`
    targets are excluded here (they can be intra-function), but a jmp that lands
    on one of these entries is still resolved by name_target."""
    out = subprocess.run(
        [UNIDASM, ROM, "-arch", "mn10300", "-basepc", f"0x{BASE + 0x80:x}",
         "-skip", "0x80", "-count", str(0x186000 - 0x80)],
        capture_output=True, text=True).stdout
    entries = set()
    for line in out.splitlines():
        m = re.match(r"[0-9a-f]+:\s+(?:[0-9a-f]{2} )+\s+calls?\s+0x([0-9a-f]+)", line)
        if m:
            t = int(m.group(1), 16)
            if BASE + 0x80 <= t < BASE + 0x186000:
                entries.add(t)
    return entries


def disasm_function(d, off, end, delta=BASE):
    """Returns list of (file_off, bytes, mnem, ops) using unidasm; None on a
    misaligned decode. `delta` maps file offset -> CPU address (BASE for code
    region 1, LIB_DELTA for the 0x4C library window). unidasm's mn10300 has a
    LENGTH BUG on the F4 page (movbu register-indexed, always 2 bytes): it
    prints the instruction correctly but consumes only the 0xF4 byte, then
    re-decodes the postbyte as a phantom instruction. When a bare-F4 line
    appears, take the true 2 bytes from the ROM and restart unidasm past them
    (the byte-exact enc==b check in emit_function still guards the result
    either way)."""
    insns = []
    cur = off
    while cur < end:
        out = subprocess.run(
            [UNIDASM, ROM, "-arch", "mn10300", "-basepc", f"0x{delta + cur:x}",
             "-skip", f"0x{cur:x}", "-count", str(end - cur)],
            capture_output=True, text=True).stdout
        restart = False
        for line in out.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            addr = int(m.group(1), 16) - delta
            b = bytes.fromhex(m.group(2).replace(" ", ""))
            if addr != cur:      # misaligned decode -> bail, keep as .incbin
                return None
            if b == b"\xf4":     # F4 length bug: real op = F4 + postbyte
                insns.append((addr, d[cur:cur + 2], m.group(3), m.group(4).strip()))
                cur += 2
                restart = True
                break
            insns.append((addr, b, m.group(3), m.group(4).strip()))
            cur += len(b)
            if cur >= end:
                break
        if not restart:
            break
    return insns if cur == end else None


# control-transfer mnemonics whose first operand is an absolute CPU target we
# can rewrite to a symbol name (only when it lands exactly on a named function).
CALL_MNEMS = {"call", "calls", "jmp"}


def name_target(ops, names, used):
    """Rewrite `call 0x48429388, ...` -> `call DispatchEvent, ...` when the
    target is a known function (semantic name or synthetic func_<ADDR>). Records
    the name in `used` so its equate can be emitted. Branch targets stay numeric."""
    m = re.match(r"(0x[0-9a-fA-F]+)(.*)", ops)
    if not m:
        return ops
    addr = int(m.group(1), 16)
    if addr in names:
        used.add(addr)
        return names[addr] + m.group(2)
    return ops


def emit_function(d, off, end, name, names, used, delta=BASE):
    """Returns asm source lines for a converted function (byte-exact)."""
    insns = disasm_function(d, off, end, delta)
    if insns is None:
        return None                       # contains an F4 gap; keep as .incbin
    lines = []
    for addr, b, mnem, ops in insns:
        cpu = delta + addr
        if addr != off and cpu in names and names[cpu].endswith("_entry"):
            # register-save-`call` entry point (the caller's reg list + frame
            # size perform the prologue); referenced by name at the call sites
            lines.append(f"# {names[cpu]}:   (register-save `call` entry)")
            used.add(cpu)
        try:
            enc = ASM.encode(mnem, ops, cpu)
        except ASM.EncError:
            enc = None
        if enc == b:
            if mnem in CALL_MNEMS:
                ops = name_target(ops, names, used)
            lines.append(f"    {mnem:8s}{ops}".rstrip())
        else:
            # keep the exact bytes; annotate with the disassembly for the reader
            hexb = ", ".join(f"0x{x:02X}" for x in b)
            lines.append(f"    .byte {hexb}   # {mnem} {ops}".rstrip())
    return lines


def main():
    d = open(ROM, "rb").read()
    syms = load_syms(d)
    manual = load_manual_syms()
    r1 = [s for s in syms if 0x80 <= s[0] < 0x186000]
    # manual function starts inside code region 1 become split boundaries too
    # (the `_entry` register-save entries deliberately do not)
    known = {off for off, _ in r1}
    for a, nm in manual:
        off = a - BASE
        if 0x80 <= off < 0x186000 and off not in known \
                and not nm.endswith("_entry"):
            r1.append((off, nm))
            known.add(off)
    r1.sort()
    sym_by_addr = {BASE + off: nm for off, nm in syms}
    pal = [struct.unpack_from("<I", d, 0x32573C + 4 * i)[0] for i in range(512)]

    # Full name map: reflection-table names + manual names + synthetic
    # func_<ADDR> for the internal helpers neither covers, so every call in
    # converted code resolves to a label. `used` records which get referenced
    # (to emit equates; manual names are not in symbols.inc, so they are
    # equated here when used).
    names = dict(sym_by_addr)
    names.update({a: nm for a, nm in manual})
    for a in discover_functions(d):
        names.setdefault(a, f"func_{a:08X}")
    used = set()

    L = ['# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>',
         '# Licensed under the terms of the GNU General Public License v3 or later',
         '#',
         '# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact.',
         '# Panasonic MN10300, mapped at CPU 0x48400000. Code region 1 is split at',
         '# the recovered functions (kn7000.sym + kn7000_manual.sym); functions',
         '# listed in tools/gen_program_s.py',
         '# CONVERT are emitted as real MN10300 assembly (verified byte-exact by the',
         '# mn10300_asm encoder), the rest remain raw .incbin_range. Regenerate with',
         '# tools/gen_program_s.py. make verify guarantees byte-identity.',
         '',
         '.equ PROGRAM_ROM_BASE, 0x48400000',
         '.mnbase 0x48400000   # CPU address of output offset 0 (for PC-relative ops)',
         '.include "src/symbols.inc"',
         '',
         '# ---- boot header (0x0..0x80) ----',
         '_reset:',
         '    .byte 0xDC, 0x7E, 0xFF, 0x00, 0x00      # jmp  0x4840FF7E   (reset entry)',
         '    .byte 0xCB, 0xCB, 0xCB, 0xCB, 0xCB      # nop x5',
         '_vector_0a:',
         '    .byte 0xDC, 0xC5, 0x77, 0x0D, 0x00      # jmp  0x484D77CF',
         '_rom_marker:',
         '    .byte 0x16                              # ROM-present marker (cmp vs 0xFF)',
         '    .space 0x80 - 0x10, 0xFF',
         '    .org 0x000080',
         '',
         '# ============================================================================',
         '# Code region 1 -- organised by recovered function.',
         '# ============================================================================']

    ROMQ = '"baserom/kn7000_program.rom"'
    body = []
    if r1[0][0] > 0x80:
        body.append(f".incbin_range {ROMQ}, 0x000080, {r1[0][0]:#08x}")

    converted = 0
    for i, (off, name) in enumerate(r1):
        end = r1[i + 1][0] if i + 1 < len(r1) else 0x186000
        body.append(f"# {name}  (CPU {BASE + off:#010x})")
        for doc in FUNC_DOC.get(name, ()):
            body.append(f"#   {doc}")
        end_conv = min(end, FUNC_END.get(name, end))
        block = emit_function(d, off, end_conv, name, names, used) if name in CONVERT else None
        if block is not None:
            body.extend(block)
            converted += 1
            if end_conv < end:
                body.append(f"# (unnamed code follows to the next boundary)")
                body.append(f".incbin_range {ROMQ}, {end_conv:#08x}, {end:#08x}")
        else:
            body.append(f".incbin_range {ROMQ}, {off:#08x}, {end:#08x}")

    # ---- code region 2: the library window (built before the equates so its
    # named calls are recorded in `used`) ------------------------------------
    lib_body = ['',
                '# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4). The library',
                '#      image the boot self-loads to 0x4C000000 starts at file offset',
                '#      0x3B8FD1 (notes/library-rom-loading.md); converted lib functions',
                '#      are emitted under the shifted .mnbase so their PC-relative',
                '#      encodings reproduce the 0x4C link address byte-exactly. ----']
    cur2 = 0x3B8000
    lib_converted = 0
    for name, (cs, ce) in sorted(LIB_CONVERT.items(), key=lambda kv: kv[1][0]):
        so, eo = cs - LIB_DELTA, ce - LIB_DELTA
        assert 0x3B8FD1 <= so < eo <= 0x3F6F01, name
        if cur2 < so:
            lib_body.append(f".incbin_range {ROMQ}, {cur2:#08x}, {so:#08x}")
        lib_body.append(f"# {name}  (lib CPU {cs:#010x})")
        for doc in FUNC_DOC.get(name, ()):
            lib_body.append(f"#   {doc}")
        block = emit_function(d, so, eo, name, names, used, LIB_DELTA)
        if block is not None:
            lib_body.append(f".mnbase 0x{LIB_DELTA:08X}   # lib window: CPU 0x4C000000 = file 0x3B8FD1")
            lib_body.extend(block)
            lib_body.append(".mnbase 0x48400000")
            lib_converted += 1
        else:
            lib_body.append(f".incbin_range {ROMQ}, {so:#08x}, {eo:#08x}")
        cur2 = eo
    lib_body += [f".incbin_range {ROMQ}, {cur2:#08x}, 0x3F6F01",
                 '',
                 '.org 0x3F6F01   # end of image']

    # equates for the synthetic helper labels actually referenced by converted code
    auto = sorted(a for a in used if a not in sym_by_addr)
    if auto:
        L.append(f"# {len(auto)} synthetic labels for internal helpers called by "
                 "converted code")
        for a in auto:
            L.append(f".equ {names[a]}, 0x{a:08X}")
        L.append("")
    L.extend(body)

    # data / resources region, with the display palette as typed .long
    L += ['',
          '# ---- data / resources region ----',
          f'.incbin_range {ROMQ}, 0x186000, 0x32573C',
          '',
          '# ---- display palette (256-entry 0x00BBGGRR CLUT + a themed sub-range) ----',
          'display_palette:']
    for i in range(0, 512, 8):
        row = ", ".join(f"0x{v:08X}" for v in pal[i:i + 8])
        L.append(f"    .long {row}   # idx {i:3d}")
    L += ['.org 0x325F3C',
          f'.incbin_range {ROMQ}, 0x32573C + 0x800, 0x3B8000']
    L.extend(lib_body)

    open(OUT, "w").write("\n".join(L) + "\n")
    print(f"wrote {OUT}: {converted}/{len(CONVERT)} region-1 + "
          f"{lib_converted}/{len(LIB_CONVERT)} library functions converted to asm")


if __name__ == "__main__":
    main()
