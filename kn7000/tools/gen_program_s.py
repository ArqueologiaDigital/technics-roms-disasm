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
}

# Library-image functions to convert (CPU start, CPU end-exclusive). These live
# in code region 2 and execute at 0x4C000000; boundaries are explicit because
# the lib region has no reflection name table.
LIB_CONVERT = {
    "LibDiv32":           (0x4C0019D5, 0x4C0019F2),
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
}

# Reverse-engineering facts emitted as comments under the function headers.
# Sources: kn5000-docs /kn7000-technichord/, the KN7000 users manual (p.48),
# and the disassembly itself (matrix bases/strides, the 0x485EC940 param map).
FUNC_DOC = {
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
