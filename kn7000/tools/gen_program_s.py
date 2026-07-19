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
}

# A converted function whose named block extends past its real end (because the
# next named boundary is far away) can cap the converted range here; the
# remainder of the block stays raw .incbin_range.
FUNC_END = {
    "TechniChordAugDimFold": 0x737D2,   # next (unnamed) function at 0x484737D2
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


def disasm_function(d, off, end):
    """Returns list of (file_off, bytes, mnem, ops) using unidasm; None on a
    misaligned decode. unidasm's mn10300 has a LENGTH BUG on the F4 page (movbu
    register-indexed, always 2 bytes): it prints the instruction correctly but
    consumes only the 0xF4 byte, then re-decodes the postbyte as a phantom
    instruction. When a bare-F4 line appears, take the true 2 bytes from the
    ROM and restart unidasm past them (the byte-exact enc==b check in
    emit_function still guards the result either way)."""
    insns = []
    cur = off
    while cur < end:
        out = subprocess.run(
            [UNIDASM, ROM, "-arch", "mn10300", "-basepc", f"0x{BASE + cur:x}",
             "-skip", f"0x{cur:x}", "-count", str(end - cur)],
            capture_output=True, text=True).stdout
        restart = False
        for line in out.splitlines():
            m = INSN.match(line)
            if not m:
                continue
            addr = int(m.group(1), 16) - BASE
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


def emit_function(d, off, end, name, names, used):
    """Returns asm source lines for a converted function (byte-exact)."""
    insns = disasm_function(d, off, end)
    if insns is None:
        return None                       # contains an F4 gap; keep as .incbin
    lines = []
    for addr, b, mnem, ops in insns:
        cpu = BASE + addr
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
          f'.incbin_range {ROMQ}, 0x32573C + 0x800, 0x3B8000',
          '',
          '# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4) ----',
          f'.incbin_range {ROMQ}, 0x3B8000, 0x3F6F01',
          '',
          '.org 0x3F6F01   # end of image']

    open(OUT, "w").write("\n".join(L) + "\n")
    print(f"wrote {OUT}: {converted}/{len(CONVERT)} requested functions converted to asm")


if __name__ == "__main__":
    main()
