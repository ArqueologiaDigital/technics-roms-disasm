#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# dsp_prog.py -- the effects-DSP side of DSPTONE (README.md): our own ADSP-21065L program, its data, and the
# include file the MN10300 application (dsptone.s) carries them in.
#
#   python3 -I dsp_prog.py BUILD_DIR [--check UNIDASM] [--listing OUT.lst] [--wav OUT.wav]
# writes BUILD_DIR/dsp_equ.inc (the addresses and sizes, for the top of dsptone.s) and BUILD_DIR/dsp_data.inc
# (the program, the sine table, the variables and the PCM, included after the code).
#
# What the program is. The firmware's resident DSP kernel (rec04, kn7000/dsp/kernel-architecture.md) stays as it
# is: it keeps the SPORT DMA rings, the 44.1 kHz frame loop, BUSLK and the per-frame strobe the main CPU's
# handshake depends on. Our program is one *effect unit* of that kernel, the kernel's own ABI: it is uploaded to
# free program memory (PM 0x8200, never written by the firmware: power-on contents on the unit, pass 7) and the
# kernel's unit-0 CALL slot (PM 0x8080, "CALL (0x8400) (DB)", the panel REVERB unit) is pointed at it with the
# same single-word PM poke the firmware uses to load an effect. Per frame it reads unit 0's input pair
# DM(I4+0x20/0x21), adds a sample of its own, clips to 24 bits, writes unit 0's return pair DM(I4++), and leaves
# the cursors as every effect does (RTS (DB); R4 = DM(I1,M5), R7 = PM(I12,M8); MODIFY (I8, 0x50)). It addresses
# memory only with immediate offsets and MODIFY by immediates, never through M0-M7: the kernels of program builds
# 893 and 941 set them differently (893: M0 = +1, M2 = +3; 941: M2 = +1; effects write their outputs with
# DM(I4, M0) in 893 and DM(I4, M2) in 941). M5 and M8, which the epilogue uses, are 0x4D and +1 in both.
#
# Host <-> DSP: four message registers (IOP 0x0C-0x0F), which the kernel zeroes at boot and nothing else uses
# (MSGR2 is the mic reverbs' I3 cell, MSGR3 the boot probes' answer):
#   MSGR4 (0x0C)  copy request: words of STAGE to unpack into SDRAM; the DSP zeroes it when done
#   MSGR5 (0x0D)  where they go: a sample offset into the PCM area
#   MSGR6 (0x0E)  mode: 0 = input only (silence), 1 = sine, 2 = the PCM, looped
#   MSGR7 (0x0F)  heartbeat: +1 every frame the program runs (the host reads it to see that it does)
# Memory it uses: DM 0x9D00-0x9F06 (internal; never written by the firmware: power-on contents on the unit,
# pass 7) and SDRAM 0x70000-0x7FFFF (above the kernel's three delay rings, which end at 0x69D3F).
#
# --check runs MAME's SHARC disassembler over the encoded words and compares each line with the text it was
# meant to be; any difference fails. --wav writes the PCM as a WAV (to listen to what the unit should play).
import math
import os
import re
import struct
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sharc_enc import (Program, alu, compute, shift_imm, ureg_move, ureg_imm, dm_read_abs,  # noqa: E402
                       dm_write_abs, dm_read_off, dm_write_off, rts, modify_imm)

FS = 44100
PM_CODE = 0x8200          # our code: PM 0x8102-0x82FF is never written by the firmware (pass 7)
PM_SLOT0 = 0x8080         # the kernel's unit-0 CALL slot
CALL_DB = 0x06BE04000000  # "CALL (addr) (DB)", unconditional, absolute: the slot word less its target
TABLE = 0x9D00            # 256 words: one cycle of sine, 24-bit, pre-scaled
STAGE = 0x9E00            # 256 words: the host's PCM staging buffer, two 16-bit samples per word
STAGE_WORDS = 256
V_PHASE, V_INC, V_POS, V_LEN, V_CPY, V_SAVEI5, V_SAVEI7 = 0x9F00, 0x9F01, 0x9F02, 0x9F03, 0x9F04, 0x9F05, 0x9F06
NVARS = 7
PCMBASE = 0x70000         # SDRAM: the unpacked PCM, one 24-bit sample per word
PCM_MAX = 0x10000         # samples (0x70000-0x7FFFF)
MSGR4, MSGR5, MSGR6, MSGR7 = 0x0C, 0x0D, 0x0E, 0x0F
CLIP24 = 0x7FFFFF

TONE_HZ = 440.0
TONE_PEAK = 0xCCCCD       # a tenth of 24-bit full scale (-20 dBFS): in MAME about 7 dB over a C4 note
TONE_INC = round(TONE_HZ * (1 << 24) / FS)
PCM_PEAK = 3277           # the chirp, 16-bit: a tenth of full scale, the same level as the sine
CHIRP_F0, CHIRP_F1, CHIRP_S, GAP_S, FADE_S = 220.0, 3520.0, 0.75, 0.25, 0.015


def program():
    p = Program(PM_CODE)
    e = p.emit
    e(dm_write_abs(V_SAVEI7, "I7"), f"DM(0x{V_SAVEI7:08X}) = I7")       # I7 is put back at the end
    e(dm_read_off("R0", 0x20, "I4"), "R0 = DM(0x00000020, I4)")          # unit 0's input, left
    e(dm_read_off("R1", 0x21, "I4"), "R1 = DM(0x00000021, I4)")          # and right
    e(dm_read_abs("R2", MSGR7), "R2 = DM(0x0000000F)")                   # heartbeat
    e(compute(alu("INC", "R2", "R2")), "R2 = R2 + 1")
    e(dm_write_abs(MSGR7, "R2"), "DM(0x0000000F) = R2")
    e(ureg_imm("R12", 0), "R12 = 0x00000000")                            # our sample: none yet
    e(dm_read_abs("R3", MSGR6), "R3 = DM(0x0000000E)")                   # mode
    e(ureg_imm("R4", 1), "R4 = 0x00000001")
    e(compute(alu("COMP", "R0", "R3", "R4")), "COMP(R3, R4)")
    p.jump("sine", "EQ")
    e(ureg_imm("R4", 2), "R4 = 0x00000002")
    e(compute(alu("COMP", "R0", "R3", "R4")), "COMP(R3, R4)")
    p.jump("pcm", "EQ")
    p.jump("copy")
    # mode 1: phase accumulator (24 bits, masked: MODE1.ALUSAT is set, adds saturate, so no wrap), table lookup
    p.label("sine")
    e(dm_read_abs("R5", V_PHASE), f"R5 = DM(0x{V_PHASE:08X})")
    e(dm_read_abs("R6", V_INC), f"R6 = DM(0x{V_INC:08X})")
    e(compute(alu("ADD", "R5", "R5", "R6")), "R5 = R5 + R6")
    e(ureg_imm("R6", 0xFFFFFF), "R6 = 0x00FFFFFF")
    e(compute(alu("AND", "R5", "R5", "R6")), "R5 = R5 AND R6")
    e(dm_write_abs(V_PHASE, "R5"), f"DM(0x{V_PHASE:08X}) = R5")
    e(shift_imm("LSHIFT", "R5", "R5", -16), "R5 = LSHIFT R5 BY -16")
    e(ureg_move("I7", "R5"), "I7 = R5")
    e(0, "NOP")                                                          # I7 written: one cycle before use
    e(dm_read_off("R12", TABLE, "I7"), f"R12 = DM(0x{TABLE:08X}, I7)")
    p.jump("copy")
    # mode 2: the PCM in SDRAM, looped over [0, length); silence until a length is known
    p.label("pcm")
    e(dm_read_abs("R6", V_LEN), f"R6 = DM(0x{V_LEN:08X})")
    e(compute(alu("PASS", "R6", "R6")), "R6 = PASS R6")
    p.jump("copy", "LE")
    e(dm_read_abs("R5", V_POS), f"R5 = DM(0x{V_POS:08X})")
    e(compute(alu("COMP", "R0", "R5", "R6")), "COMP(R5, R6)")
    e(compute(alu("SUB", "R5", "R5", "R5"), "GE"), "IF GE, R5 = R5 - R5")
    e(ureg_move("I7", "R5"), "I7 = R5")
    e(compute(alu("INC", "R5", "R5")), "R5 = R5 + 1")
    e(dm_read_off("R12", PCMBASE, "I7"), f"R12 = DM(0x{PCMBASE:08X}, I7)")
    e(dm_write_abs(V_POS, "R5"), f"DM(0x{V_POS:08X}) = R5")
    # the copy request: two STAGE words (four 16-bit samples) per frame, unpacked to 24 bits into SDRAM
    p.label("copy")
    e(dm_read_abs("R7", MSGR4), "R7 = DM(0x0000000C)")
    e(compute(alu("PASS", "R7", "R7")), "R7 = PASS R7")
    p.jump("mix", "LE")
    e(dm_read_abs("R8", V_CPY), f"R8 = DM(0x{V_CPY:08X})")                # words done so far
    e(dm_write_abs(V_SAVEI5, "I5"), f"DM(0x{V_SAVEI5:08X}) = I5")       # I5 is put back below
    e(dm_read_abs("R9", MSGR5), "R9 = DM(0x0000000D)")
    e(compute(alu("ADD", "R10", "R8", "R8")), "R10 = R8 + R8")
    e(compute(alu("ADD", "R9", "R9", "R10")), "R9 = R9 + R10")
    e(ureg_imm("R10", PCMBASE), f"R10 = 0x{PCMBASE:08X}")
    e(compute(alu("ADD", "R9", "R9", "R10")), "R9 = R9 + R10")
    e(ureg_move("I5", "R9"), "I5 = R9")                                  # SDRAM destination
    e(ureg_imm("R10", STAGE), f"R10 = 0x{STAGE:08X}")
    e(compute(alu("ADD", "R10", "R10", "R8")), "R10 = R10 + R8")
    e(ureg_move("I7", "R10"), "I7 = R10")                                # STAGE source
    e(0, "NOP")
    for k in range(2):                       # immediate offsets: no M register (their values differ by build)
        e(dm_read_off("R10", k, "I7"), f"R10 = DM(0x{k:08X}, I7)")
        e(shift_imm("LSHIFT", "R11", "R10", 16), "R11 = LSHIFT R10 BY 16")
        e(shift_imm("ASHIFT", "R11", "R11", -8), "R11 = ASHIFT R11 BY -8")   # the low half: the earlier sample
        e(dm_write_off(2 * k, "I5", "R11"), f"DM(0x{2 * k:08X}, I5) = R11")
        e(shift_imm("ASHIFT", "R10", "R10", -16), "R10 = ASHIFT R10 BY -16")
        e(shift_imm("LSHIFT", "R10", "R10", 8), "R10 = LSHIFT R10 BY 8")     # the high half: the later one
        e(dm_write_off(2 * k + 1, "I5", "R10"), f"DM(0x{2 * k + 1:08X}, I5) = R10")
    e(compute(alu("INC", "R8", "R8")), "R8 = R8 + 1")
    e(compute(alu("INC", "R8", "R8")), "R8 = R8 + 1")
    e(compute(alu("COMP", "R0", "R8", "R7")), "COMP(R8, R7)")
    p.jump("saveidx", "LT")
    e(dm_read_abs("R9", MSGR5), "R9 = DM(0x0000000D)")                   # done: the PCM now reaches
    e(compute(alu("ADD", "R10", "R7", "R7")), "R10 = R7 + R7")           #   offset + 2 x words
    e(compute(alu("ADD", "R9", "R9", "R10")), "R9 = R9 + R10")
    e(dm_read_abs("R10", V_LEN), f"R10 = DM(0x{V_LEN:08X})")
    e(compute(alu("MAX", "R9", "R9", "R10")), "R9 = MAX(R9, R10)")
    e(dm_write_abs(V_LEN, "R9"), f"DM(0x{V_LEN:08X}) = R9")
    e(ureg_imm("R8", 0), "R8 = 0x00000000")
    e(dm_write_abs(MSGR4, "R8"), "DM(0x0000000C) = R8")                  # tell the host
    p.label("saveidx")
    e(dm_write_abs(V_CPY, "R8"), f"DM(0x{V_CPY:08X}) = R8")
    e(dm_read_abs("I5", V_SAVEI5), f"I5 = DM(0x{V_SAVEI5:08X})")
    # out: input + our sample, clipped to the 24 bits the SPORT sends
    p.label("mix")
    e(compute(alu("ADD", "R0", "R0", "R12")), "R0 = R0 + R12")
    e(compute(alu("ADD", "R1", "R1", "R12")), "R1 = R1 + R12")
    e(ureg_imm("R14", CLIP24), f"R14 = 0x{CLIP24:08X}")
    e(compute(alu("CLIP", "R0", "R0", "R14")), "R0 = CLIP R0 BY R14")
    e(compute(alu("CLIP", "R1", "R1", "R14")), "R1 = CLIP R1 BY R14")
    e(dm_write_off(0, "I4", "R0"), "DM(0x00000000, I4) = R0")           # unit 0's return pair; I4 on by two,
    e(dm_write_off(1, "I4", "R1"), "DM(0x00000001, I4) = R1")           #   as two DM(I4, Mx) writes leave it (Mx =
    e(modify_imm("I4", 2), "MODIFY (I4, 0x00000002)")                   #   M2 in 941, M0 in 893: not used here)
    e(dm_read_abs("I7", V_SAVEI7), f"I7 = DM(0x{V_SAVEI7:08X})")
    # the kernel's effect epilogue, word for word (rec05 0x8403-0x8405; the same in 893: M5 = 0x4D, M8 = 1 in both
    # builds' kernel init): the next unit's cursors
    e(rts(db=True), "RTS (DB)")
    e(0x234903800000, "R4 = DM(I1, M5),  R7 = PM(I12, M8)")
    e(modify_imm("I8", 0x50), "MODIFY (I8, 0x00000050)")
    return p.assemble()


def sine_table():
    return [round(TONE_PEAK * math.sin(2 * math.pi * k / 256)) & 0xFFFFFFFF for k in range(256)]


def chirp():
    """an exponential sweep CHIRP_F0 -> CHIRP_F1 over CHIRP_S, faded in and out, then GAP_S of silence"""
    n, gap, fade = round(CHIRP_S * FS), round(GAP_S * FS), round(FADE_S * FS)
    k = math.log(CHIRP_F1 / CHIRP_F0)
    out = []
    for i in range(n):
        t = i / FS
        phase = 2 * math.pi * CHIRP_F0 * CHIRP_S / k * (math.exp(k * t / CHIRP_S) - 1)
        env = min(1.0, i / fade, (n - 1 - i) / fade)
        env = 0.5 - 0.5 * math.cos(math.pi * max(env, 0.0))
        out.append(round(PCM_PEAK * env * math.sin(phase)))
    out += [0] * gap
    if len(out) % 4:                       # whole copy steps: two words, four samples
        out += [0] * (4 - len(out) % 4)
    assert len(out) <= PCM_MAX
    return out


def check(words, unidasm):
    """unidasm -arch sharc over the words: each line must be the text it was meant to be"""
    with tempfile.NamedTemporaryFile(suffix=".bin") as t:
        t.write(b"".join(struct.pack("<Q", w) for _, w, _ in words))
        t.flush()
        out = subprocess.run([unidasm, t.name, "-arch", "sharc", "-basepc", hex(PM_CODE)],
                             capture_output=True, text=True, check=True).stdout
    lines = [ln for ln in out.splitlines() if re.match(r"\s*[0-9a-f]+: [0-9a-f]{16}", ln)]
    bad = 0
    for (pc, w, text), ln in zip(words, lines):
        got = re.sub(r"\s+", " ", ln.split(None, 2)[2].strip())
        if got != re.sub(r"\s+", " ", text):
            print(f"dsp_prog: PM 0x{pc:04X} {w:012X}: unidasm says '{got}', meant '{text}'")
            bad += 1
    if len(lines) != len(words):
        print(f"dsp_prog: unidasm gave {len(lines)} lines for {len(words)} words")
        bad += 1
    return bad


def write_inc(build, words, table, pcm):
    v = [0, TONE_INC, 0, 0, 0, 0, 0]
    with open(os.path.join(build, "dsp_equ.inc"), "w") as f:
        f.write("# Generated by dsp_prog.py -- the DSP side of DSPTONE (do not edit; see dsp_prog.py)\n")
        for name, val in (("DSP_CODE_ADDR", PM_CODE), ("DSP_CODE_WORDS", len(words)), ("DSP_SLOT0", PM_SLOT0),
                          ("DSP_CALLDB_HI", CALL_DB >> 32), ("DSP_TABLE", TABLE), ("DSP_STAGE", STAGE),
                          ("DSP_STAGE_WORDS", STAGE_WORDS), ("DSP_VARS", V_PHASE), ("DSP_NVARS", NVARS),
                          ("DSP_V_LEN", V_LEN), ("DSP_PCMBASE", PCMBASE), ("DSP_PCM_SAMPLES", len(pcm)),
                          ("DSP_MSGR4", MSGR4), ("DSP_MSGR5", MSGR5), ("DSP_MSGR6", MSGR6),
                          ("DSP_MSGR7", MSGR7), ("DSP_TONE_INC", TONE_INC)):
            f.write(f".equ {name + ',':<17} 0x{val:X}\n")
    with open(os.path.join(build, "dsp_data.inc"), "w") as f:
        f.write("# Generated by dsp_prog.py -- the DSP side of DSPTONE (do not edit; see dsp_prog.py)\n")
        f.write("\n# the program: PM words as the host streams them, three 16-bit halves each, least significant "
                "first\n    .align  4\nDspCode:\n")
        for pc, w, text in words:
            f.write(f"    .word   0x{w & 0xFFFF:04X}, 0x{(w >> 16) & 0xFFFF:04X}, 0x{w >> 32:04X}"
                    f"    # {pc:04X}: {text}\n")
        f.write("\n# DM 0x%04X: one cycle of sine, 24-bit, peak 0x%X\n    .align  4\nDspTable:\n" % (TABLE, TONE_PEAK))
        for k in range(0, 256, 8):
            f.write("    .long   " + ", ".join(f"0x{x:08X}" for x in table[k:k + 8]) + "\n")
        f.write("\n# DM 0x%04X: PHASE, INC (%.1f Hz), PCMPOS, PCMLEN, CPYIDX, SAVEI5, SAVEI7\nDspVars:\n" % (V_PHASE, TONE_HZ))
        f.write("    .long   " + ", ".join(f"0x{x:08X}" for x in v) + "\n")
        f.write(f"\n# the PCM: {len(pcm)} 16-bit samples, a {CHIRP_F0:g}-{CHIRP_F1:g} Hz sweep over {CHIRP_S} s, "
                f"then {GAP_S} s of silence\n    .align  4\nDspPcm:\n")
        for k in range(0, len(pcm), 16):
            f.write("    .word   " + ", ".join(f"0x{x & 0xFFFF:04X}" for x in pcm[k:k + 16]) + "\n")
        f.write("DspPcmEnd:\n    .align  4\n")


def write_wav(path, pcm):
    data = b"".join(struct.pack("<h", x) for x in pcm)
    with open(path, "wb") as f:
        f.write(b"RIFF" + struct.pack("<I", 36 + len(data)) + b"WAVEfmt " +
                struct.pack("<IHHIIHH", 16, 1, 1, FS, FS * 2, 2, 16) + b"data" + struct.pack("<I", len(data)) + data)


def main():
    out = sys.argv[1]
    args = sys.argv[2:]
    words = program()
    assert PM_CODE + len(words) <= 0x8300, "the code must stay in PM 0x8102-0x82FF"
    table, pcm = sine_table(), chirp()
    if "--check" in args:
        bad = check(words, args[args.index("--check") + 1])
        if bad:
            sys.exit(f"dsp_prog: {bad} instruction(s) do not disassemble as meant")
        print(f"dsp_prog: {len(words)} instructions, each disassembles as meant (unidasm -arch sharc)")
    if "--listing" in args:
        with open(args[args.index("--listing") + 1], "w") as f:
            for pc, w, text in words:
                f.write(f"{pc:04x}: {w:012x}  {text}\n")
    if "--wav" in args:
        write_wav(args[args.index("--wav") + 1], pcm)
    write_inc(out, words, table, pcm)
    print(f"dsp_prog: {out}/dsp_equ.inc, dsp_data.inc: {len(words)} PM words at 0x{PM_CODE:04X}, sine {TONE_HZ:g} Hz (INC {TONE_INC}), "
          f"PCM {len(pcm)} samples")


if __name__ == "__main__":
    main()
