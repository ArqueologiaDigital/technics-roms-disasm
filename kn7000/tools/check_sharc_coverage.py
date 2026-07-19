#!/usr/bin/env python3
"""check_sharc_coverage.py — verify every SHARC instruction used by the KN7000
effects-DSP download-record pool is supported by the SHARC core the kn7000
MAME build actually runs (interpreter AND DRC).

Sources of truth:
  * disasm/dsp/*.asm            — the pool's listings (PM sections = 48-bit code words)
  * kn7000_mame/src/devices/cpu/sharc/{sharc.cpp,sharcops.hxx,sharcdrc.cpp,sharcfe.cpp,sharc.h}
    (overlay, symlinked into the build tree) + stock upstream
    {compute.hxx,sharcops_table.cpp,sharcinternal.ipp} — the support tables below
    are a hand-audited mirror of those files (audited 2026-07-19).

Decode mirrors MAME exactly:
  * top level    = sharcops_table.cpp mask/value pairs on bits 47..32
  * compute      = 23-bit field, bit22 = multifunction; else cu = bits 21..20
  * imm shift    = shiftop bits 21..16 (of the low 32), data = (op>>8 & 0xff)|(op>>19 & 0xf00)
  * sysreg bitop = bop bits 39..37, sreg bits 35..32

Statuses:
  interp : OK          — real implementation in sharcops.hxx/compute.hxx
           THROW       — throw emu_fatalerror when executed
  drc    : NATIVE      — inline UML emission in sharcdrc.cpp
           FALLBACK    — generate_unimplemented_compute/shiftimm -> per-op interpreter
                         call (functionally the interpreter's semantics, perf cost only)
           CRASH       — generate_opcode returns false -> cfuncs::unimplemented throw,
                         or fallback lands on an interpreter THROW, or the frontend
                         (sharcfe.cpp) fatals/returns false at describe time

Usage: tools/check_sharc_coverage.py [--tsv out.tsv]
Exit status 1 if any used instruction is not fully supported in both paths.
"""

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DSP_DIR = REPO / "disasm" / "dsp"
RECORDS_TSV = REPO / "dsp" / "records.tsv"

# ---------------------------------------------------------------------------
# Top-level opcode table — verbatim from sharcops_table.cpp (mask/value on the
# top 16 bits of the 48-bit word). First match wins (the table is disjoint).
# ---------------------------------------------------------------------------
TOP_TABLE = [
    (0xE000, 0x2000, "compute_dreg_dm_dreg_pm"),
    (0xFF00, 0x0100, "compute"),
    (0xF000, 0x4000, "compute_ureg_dmpm_premod"),
    (0xF000, 0x5000, "compute_ureg_dmpm_postmod"),
    (0xF180, 0x6000, "compute_dm_to_dreg_immmod"),
    (0xF180, 0x6080, "compute_dreg_to_dm_immmod"),
    (0xF180, 0x6100, "compute_pm_to_dreg_immmod"),
    (0xF180, 0x6180, "compute_dreg_to_pm_immmod"),
    (0xF000, 0x7000, "compute_ureg_to_ureg"),
    (0xF000, 0x8000, "imm_shift_dreg_dmpm"),
    (0xFF00, 0x0200, "imm_shift"),
    (0xFF00, 0x0400, "compute_modify"),
    (0xFF80, 0x0600, "direct_jump"),
    (0xFF80, 0x0680, "direct_call"),
    (0xFF80, 0x0700, "relative_jump"),
    (0xFF80, 0x0780, "relative_call"),
    (0xFF80, 0x0800, "indirect_jump"),
    (0xFF80, 0x0880, "indirect_call"),
    (0xFF80, 0x0900, "relative_jump_compute"),
    (0xFF80, 0x0980, "relative_call_compute"),
    (0xE000, 0xC000, "indirect_jump_compute_dreg_dm"),
    (0xE000, 0xE000, "relative_jump_compute_dreg_dm"),
    (0xFF00, 0x0A00, "rts"),
    (0xFF00, 0x0B00, "rti"),
    (0xFF00, 0x0C00, "do_until_counter_imm"),
    (0xFF00, 0x0D00, "do_until_counter_ureg"),
    (0xFF00, 0x0E00, "do_until"),
    (0xFF00, 0x1000, "dm_to_ureg_direct"),
    (0xFF00, 0x1100, "ureg_to_dm_direct"),
    (0xFF00, 0x1200, "pm_to_ureg_direct"),
    (0xFF00, 0x1300, "ureg_to_pm_direct"),
    (0xF100, 0xA000, "dm_to_ureg_indirect"),
    (0xF100, 0xA100, "ureg_to_dm_indirect"),
    (0xF100, 0xB000, "pm_to_ureg_indirect"),
    (0xF100, 0xB100, "ureg_to_pm_indirect"),
    (0xF000, 0x9000, "imm_to_dmpm"),
    (0xFF00, 0x0F00, "imm_to_ureg"),
    (0xFF00, 0x1400, "sysreg_bitop"),
    (0xFF80, 0x1600, "modify"),
    (0xFF80, 0x1680, "bit_reverse"),
    (0xFF00, 0x1700, "push_pop_stacks"),
    (0xFF80, 0x0000, "nop"),
    (0xFF80, 0x0080, "idle"),
]

# Top-level classes that carry a 23-bit compute field (bits 0..22)
HAS_COMPUTE = {
    "compute_dreg_dm_dreg_pm", "compute", "compute_ureg_dmpm_premod",
    "compute_ureg_dmpm_postmod", "compute_dm_to_dreg_immmod",
    "compute_dreg_to_dm_immmod", "compute_pm_to_dreg_immmod",
    "compute_dreg_to_pm_immmod", "compute_ureg_to_ureg", "compute_modify",
    "indirect_jump", "indirect_call", "relative_jump_compute",
    "relative_call_compute", "indirect_jump_compute_dreg_dm",
    "relative_jump_compute_dreg_dm", "rts", "rti",
}
HAS_SHIFTIMM = {"imm_shift", "imm_shift_dreg_dmpm"}

# Top-level support. Interpreter: everything in the table is implemented except
# bit_reverse (sharcop_bit_reverse throws). Unmatched word -> sharcop_unimplemented.
TOP_INTERP_THROW = {"bit_reverse"}
# DRC generate_opcode: every group/subop present in the table is emitted natively
# except bit_reverse (returns false -> cfuncs::unimplemented throw at run time).
TOP_DRC_CRASH = {"bit_reverse"}

# ---------------------------------------------------------------------------
# Compute-field support tables (hand-audited from the overlay core).
# key spaces: MF (multiop 6-bit), ALU (op 8-bit), MUL (op 8-bit),
#             SHIFTREG (shiftop = op>>2, 6-bit), SHIFTIMM (shiftop 6-bit)
# ---------------------------------------------------------------------------

# --- interpreter: sharcops.hxx COMPUTE() -----------------------------------
MF_INTERP_OK = ({0x00, 0x01, 0x04, 0x05, 0x06, 0x08, 0x09, 0x0A, 0x0C, 0x0D,
                 0x0E, 0x10, 0x11, 0x12, 0x14, 0x15, 0x16}
                | set(range(0x18, 0x20)) | set(range(0x20, 0x30))
                | set(range(0x30, 0x40)))
ALU_INTERP_OK = ({0x01, 0x02, 0x05, 0x06, 0x09, 0x0A, 0x21, 0x22, 0x25, 0x26,
                  0x29, 0x2A, 0x30, 0x40, 0x41, 0x42, 0x43, 0x61, 0x62, 0x63,
                  0x81, 0x82, 0x89, 0x8A, 0x91, 0x92, 0xA1, 0xA2, 0xB0, 0xBD,
                  0xC1, 0xC4, 0xC5, 0xC9, 0xCA, 0xD9, 0xDA, 0xE0, 0xE1, 0xE2,
                  0xE3}
                 | set(range(0x70, 0x80)) | set(range(0xF0, 0x100)))
# multiplier: 0x14/0x16 (MR=0), 0x30 (FMUL) + the whole general decode for
# oper=(op>>6)!=0 i.e. every op >= 0x40. SAT/RND (op<0x40 except above) throw.
MUL_INTERP_OK = {0x14, 0x16, 0x30} | set(range(0x40, 0x100))
SHIFTREG_INTERP_OK = {0x00, 0x02, 0x08, 0x10, 0x12, 0x19, 0x30, 0x31, 0x33}
SHIFTIMM_INTERP_OK = {0x00, 0x01, 0x02, 0x08, 0x10, 0x11, 0x12, 0x13, 0x19,
                      0x30, 0x31, 0x32, 0x33}

# --- DRC: sharcdrc.cpp generate_compute / generate_shift_imm ---------------
MF_DRC_NATIVE = ({0x00, 0x01,          # native except MR2F/MR2B subcases
                  0x04, 0x05, 0x06, 0x08, 0x09, 0x0A, 0x0C, 0x0D, 0x0E,
                  0x10, 0x11, 0x12, 0x14, 0x15, 0x16}
                 | set(range(0x18, 0x20)) | set(range(0x30, 0x40)))
MF_DRC_FALLBACK = {0x07, 0x0F} | set(range(0x20, 0x30))
ALU_DRC_FALLBACK = {0x30, 0x92, 0xA5, 0xAD, 0xCD, 0xDD, 0xE0}
ALU_DRC_NATIVE = ALU_INTERP_OK - {0x30, 0x92, 0xE0}
# multiplier: native = all signed*signed forms with oper!=0, + explicit cases
MUL_DRC_EXTRA_NATIVE = {0x14, 0x16, 0x30, 0x40, 0x70, 0xB0, 0xB2}
SHIFTREG_DRC_NATIVE = {0x00, 0x02, 0x08, 0x10, 0x12, 0x19, 0x30, 0x31, 0x33}
SHIFTREG_DRC_FALLBACK = {0x01, 0x09, 0x11, 0x13, 0x1B, 0x20, 0x21, 0x22, 0x23,
                         0x24, 0x25}
SHIFTIMM_DRC_NATIVE = {0x00, 0x01, 0x02, 0x08, 0x10, 0x11, 0x12, 0x19, 0x30,
                       0x31, 0x32, 0x33}
SHIFTIMM_DRC_FALLBACK = {0x13, 0x1B}   # -> interpreter SHIFT_OPERATION_IMM

# --- frontend describe (sharcfe.cpp): multifunction default returns false ---
MF_FE_OK = MF_INTERP_OK | {0x07, 0x0F, 0x1D}   # FE also knows 0x07/0x0F

# names for reporting -------------------------------------------------------
MF_NAMES = {
    0x00: "Rn = MRxx", 0x01: "MRxx = Rn",
    0x04: "Rm=Rxm*Rym (SSFR), Ra=Rxa+Rya",
    0x05: "Rm=Rxm*Rym (SSFR), Ra=Rxa-Rya",
    0x06: "Rm=Rxm*Rym (SSFR), Ra=(Rxa+Rya)/2",
    0x07: "Ra=Rx+Ry, Rs=Rx-Ry (dual)",
    0x08: "MRF+=Rxm*Rym (SSF), Ra=Rxa+Rya",
    0x09: "MRF+=Rxm*Rym (SSF), Ra=Rxa-Rya",
    0x0A: "MRF+=Rxm*Rym (SSF), Ra=(Rxa+Rya)/2",
    0x0C: "Rm=MRF+Rxm*Rym (SSFR), Ra=Rxa+Rya",
    0x0D: "Rm=MRF+Rxm*Rym (SSFR), Ra=Rxa-Rya",
    0x0E: "Rm=MRF+Rxm*Rym (SSFR), Ra=(Rxa+Rya)/2",
    0x0F: "Fa=Fx+Fy, Fs=Fx-Fy (dual)",
    0x10: "MRF-=Rxm*Rym (SSF), Ra=Rxa+Rya",
    0x11: "MRF-=Rxm*Rym (SSF), Ra=Rxa-Rya",
    0x12: "MRF-=Rxm*Rym (SSF), Ra=(Rxa+Rya)/2",
    0x14: "Rm=MRF-Rxm*Rym (SSFR), Ra=Rxa+Rya",
    0x15: "Rm=MRF-Rxm*Rym (SSFR), Ra=Rxa-Rya",
    0x16: "Rm=MRF-Rxm*Rym (SSFR), Ra=(Rxa+Rya)/2",
    0x18: "Fm=Fxm*Fym, Fa=Fxa+Fya",
    0x19: "Fm=Fxm*Fym, Fa=Fxa-Fya",
    0x1A: "Fm=Fxm*Fym, Fa=FLOAT Fxa BY Rya",
    0x1B: "Fm=Fxm*Fym, Ra=FIX Fxa BY Rya",
    0x1C: "Fm=Fxm*Fym, Fa=(Fxa+Fya)/2",
    0x1D: "Fm=Fxm*Fym, Fa=ABS Fxa",
    0x1E: "Fm=Fxm*Fym, Fa=MAX(Fxa,Fya)",
    0x1F: "Fm=Fxm*Fym, Fa=MIN(Fxa,Fya)",
}
for _m in range(0x20, 0x30):
    MF_NAMES[_m] = "Rm=Rxm*Rym (SSFR), Ra=Rxa+Rya, Rs=Rxa-Rya"
for _m in range(0x30, 0x40):
    MF_NAMES[_m] = "Fm=Fxm*Fym, Fa=Fxa+Fya, Fs=Fxa-Fya (dual)"

ALU_NAMES = {
    0x01: "Rn = Rx + Ry", 0x02: "Rn = Rx - Ry", 0x05: "Rn = Rx + Ry + CI",
    0x06: "Rn = Rx - Ry + CI - 1", 0x09: "Rn = (Rx + Ry)/2 (AVG)",
    0x0A: "COMP(Rx, Ry)", 0x21: "Rn = PASS Rx", 0x22: "Rn = -Rx",
    0x25: "Rn = Rx + CI", 0x26: "Rn = Rx + CI - 1", 0x29: "Rn = Rx + 1",
    0x2A: "Rn = Rx - 1", 0x30: "Rn = ABS Rx", 0x40: "Rn = Rx AND Ry",
    0x41: "Rn = Rx OR Ry", 0x42: "Rn = Rx XOR Ry", 0x43: "Rn = NOT Rx",
    0x61: "Rn = MIN(Rx, Ry)", 0x62: "Rn = MAX(Rx, Ry)",
    0x63: "Rn = CLIP Rx BY Ry", 0x81: "Fn = Fx + Fy", 0x82: "Fn = Fx - Fy",
    0x89: "Fn = (Fx + Fy)/2 (FAVG)", 0x8A: "COMP(Fx, Fy)",
    0x91: "Fn = ABS(Fx + Fy)", 0x92: "Fn = ABS(Fx - Fy)",
    0xA1: "Fn = PASS Fx", 0xA2: "Fn = -Fx", 0xA5: "Fn = RND Fx",
    0xAD: "Rn = MANT Fx", 0xB0: "Fn = ABS Fx", 0xBD: "Fn = SCALB Fx BY Ry",
    0xC1: "Rn = LOGB Fx", 0xC4: "Fn = RECIPS Fx", 0xC5: "Fn = RSQRTS Fx",
    0xC9: "Rn = FIX Fx", 0xCA: "Fn = FLOAT Rx", 0xCD: "Rn = TRUNC Fx",
    0xD9: "Rn = FIX Fx BY Ry", 0xDA: "Fn = FLOAT Rx BY Ry",
    0xDD: "Rn = TRUNC Fx BY Ry", 0xE0: "Fn = Fx COPYSIGN Fy",
    0xE1: "Fn = MIN(Fx, Fy)", 0xE2: "Fn = MAX(Fx, Fy)",
    0xE3: "Fn = CLIP Fx BY Fy",
}
for _o in range(0x70, 0x80):
    ALU_NAMES[_o] = "Ra=Rx+Ry, Rs=Rx-Ry (fixed dual add/sub)"
for _o in range(0xF0, 0x100):
    ALU_NAMES[_o] = "Fa=Fx+Fy, Fs=Fx-Fy (float dual add/sub)"


def mul_name(op):
    if op == 0x14:
        return "MRF = 0"
    if op == 0x16:
        return "MRB = 0"
    if op == 0x30:
        return "Fn = Fx * Fy"
    oper = (op >> 6) & 3
    if oper == 0:
        kind = "SAT" if not (op & 0x10) else "RND"
        return f"MR {kind} form (op 0x{op:02X})"
    sign = ("UU", "US", "SU", "SS")[((op >> 5) & 1) * 2 + ((op >> 4) & 1)]
    frac = "F" if op & 8 else "I"
    rnd = "R" if op & 1 else ""
    dst = ("MRB" if op & 2 else "MRF") if op & 4 else "Rn"
    mr = "MRB" if op & 2 else "MRF"
    base = {1: "Rx*Ry", 2: f"{mr} + Rx*Ry", 3: f"{mr} - Rx*Ry"}[oper]
    return f"{dst} = {base} ({sign}{frac}{rnd})"


SHIFT_NAMES = {
    0x00: "LSHIFT Rx BY <y>", 0x01: "ASHIFT Rx BY <y>", 0x02: "ROT Rx BY <y>",
    0x08: "Rn = Rn OR LSHIFT Rx BY <y>", 0x09: "Rn = Rn OR ASHIFT Rx BY <y>",
    0x10: "FEXT Rx BY bit:len", 0x11: "FDEP Rx BY bit:len",
    0x12: "FEXT Rx BY bit:len (SE)", 0x13: "FDEP Rx BY bit:len (SE)",
    0x19: "Rn = Rn OR FDEP Rx BY bit:len",
    0x1B: "Rn = Rn OR FDEP Rx BY bit:len (SE)",
    0x20: "Rn = EXP Rx", 0x21: "Rn = EXP Rx (EX)", 0x22: "Rn = LEFTZ Rx",
    0x23: "Rn = LEFTO Rx", 0x24: "Rn = FPACK Fx", 0x25: "Fn = FUNPACK Rx",
    0x30: "BSET Rx BY <y>", 0x31: "BCLR Rx BY <y>", 0x32: "BTGL Rx BY <y>",
    0x33: "BTST Rx BY <y>",
}

SREG_NAMES = {0x0: "USTAT1", 0x1: "USTAT2", 0x9: "IRPTL", 0xA: "MODE2",
              0xB: "MODE1", 0xC: "ASTAT", 0xD: "IMASK", 0xE: "STKY",
              0xF: "IMASKP"}
BOP_NAMES = {0: "BIT SET", 1: "BIT CLR", 2: "BIT TGL", 4: "BIT TST",
             5: "BIT XOR"}

# DRC sysreg-bitop coverage (sharcdrc.cpp case 0x14): SET/CLEAR/TOGGLE support
# USTAT1/2, IRPTL, MODE2, MODE1, ASTAT, IMASK, STKY, IMASKP natively;
# TEST supports all but ASTAT; XOR always returns false (-> crash).
def sysreg_bitop_support(bop, sreg):
    """returns (interp, drc) status strings"""
    if bop in (3, 6, 7):
        return "THROW", "CRASH"
    interp = "OK"
    if sreg == 0xF:  # IMASKP: interpreter GET/SET_UREG(0x7f) throws
        interp = "THROW"
    if bop == 5:
        return interp, "CRASH"          # DRC XOR: return false
    if bop == 4 and sreg == 0xC:
        return interp, "CRASH"          # DRC TEST ASTAT: return false
    if sreg not in SREG_NAMES:
        return "THROW", "CRASH"
    drc = "NATIVE" if interp == "OK" else "CRASH"
    return interp, drc


def classify_compute(compute):
    """-> (key, name, interp, drc) for a nonzero 23-bit compute field."""
    if compute & 0x400000:  # multifunction
        multiop = (compute >> 16) & 0x3F
        name = MF_NAMES.get(multiop, f"multifunction 0x{multiop:02X}")
        key = f"MF   0x{multiop:02X}"
        interp = "OK" if multiop in MF_INTERP_OK else "THROW"
        if multiop in (0x00, 0x01):
            ai = (compute >> 12) & 0xF
            name += f" [{('MR0F','MR1F','MR2F','?','MR0B','MR1B','MR2B','?')[ai & 7]}]"
            key += f".{ai & 7}"
            drc = "FALLBACK" if (ai & 3) == 2 else "NATIVE"   # MR2x falls back
        elif multiop in MF_DRC_NATIVE:
            drc = "NATIVE"
        elif multiop in MF_DRC_FALLBACK:
            drc = "FALLBACK" if interp == "OK" else "CRASH"
        else:
            drc = "CRASH"   # default -> fallback -> interpreter throw
        if multiop not in MF_FE_OK:
            drc = "CRASH"   # frontend describe_compute returns false
        return key, name, interp, drc

    cu = (compute >> 20) & 3
    op = (compute >> 12) & 0xFF
    if cu == 0:
        name = ALU_NAMES.get(op, f"ALU op 0x{op:02X}")
        interp = "OK" if op in ALU_INTERP_OK else "THROW"
        if op in ALU_DRC_NATIVE:
            drc = "NATIVE"
        elif op in ALU_DRC_FALLBACK:
            drc = "FALLBACK" if interp == "OK" else "CRASH"
        else:
            drc = "CRASH" if interp == "THROW" else "FALLBACK"
        return f"ALU  0x{op:02X}", name, interp, drc
    if cu == 1:
        name = mul_name(op)
        interp = "OK" if op in MUL_INTERP_OK else "THROW"
        ss_native = (op & 0x30) == 0x30 and (op & 0xC0) != 0
        if ss_native or op in MUL_DRC_EXTRA_NATIVE:
            drc = "NATIVE"
        else:
            drc = "FALLBACK" if interp == "OK" else "CRASH"
        return f"MUL  0x{op:02X}", name, interp, drc
    if cu == 2:
        shiftop = op >> 2
        name = SHIFT_NAMES.get(shiftop, f"shiftop 0x{shiftop:02X}") + " [by Ry]"
        interp = "OK" if shiftop in SHIFTREG_INTERP_OK else "THROW"
        if shiftop in SHIFTREG_DRC_NATIVE:
            drc = "NATIVE"
        elif shiftop in SHIFTREG_DRC_FALLBACK:
            drc = "FALLBACK" if interp == "OK" else "CRASH"
        else:
            drc = "CRASH" if interp == "THROW" else "FALLBACK"
        return f"SHFR 0x{shiftop:02X}", name, interp, drc
    return f"CU3  0x{op:02X}", "invalid compute unit 3", "THROW", "CRASH"


def classify_shiftimm(word):
    shiftop = (word >> 16) & 0x3F
    name = SHIFT_NAMES.get(shiftop, f"shiftop 0x{shiftop:02X}") + " [imm]"
    interp = "OK" if shiftop in SHIFTIMM_INTERP_OK else "THROW"
    if shiftop in SHIFTIMM_DRC_NATIVE:
        drc = "NATIVE"
    elif shiftop in SHIFTIMM_DRC_FALLBACK:
        drc = "FALLBACK" if interp == "OK" else "CRASH"
    else:
        drc = "CRASH"   # DRC generate_shift_imm default -> unimplemented throw
    return f"SHFI 0x{shiftop:02X}", name, interp, drc


def decode_word(word):
    """-> list of (key, name, interp, drc) contributions for one 48-bit word."""
    out = []
    top16 = (word >> 32) & 0xFFFF
    handler = None
    for mask, val, name in TOP_TABLE:
        if (top16 & mask) == val:
            handler = name
            break
    if handler is None:
        out.append((f"TOP  0x{top16:04X}", "NOT IN OPCODE TABLE", "THROW", "CRASH"))
        return out
    interp = "THROW" if handler in TOP_INTERP_THROW else "OK"
    drc = "CRASH" if handler in TOP_DRC_CRASH else "NATIVE"
    if handler == "sysreg_bitop":
        bop = (word >> 37) & 7
        sreg = (word >> 32) & 0xF
        interp, drc = sysreg_bitop_support(bop, sreg)
        bname = BOP_NAMES.get(bop, f"bop{bop}")
        sname = SREG_NAMES.get(sreg, f"sreg{sreg:X}")
        out.append((f"SYS  {bop}.{sreg:X}", f"{bname} {sname}", interp, drc))
        return out
    out.append((f"TOPC {handler}", handler, interp, drc))
    if handler in HAS_COMPUTE:
        compute = word & 0x7FFFFF
        if compute:
            out.append(classify_compute(compute))
    elif handler in HAS_SHIFTIMM:
        out.append(classify_shiftimm(word))
    return out


PM_HDR = re.compile(r"^; ---- (PM|DM) @ 0x([0-9A-Fa-f]+)")
INSN = re.compile(r"^([0-9a-f]{4}): ([0-9a-f]{16}) (.*)$")
RECFILE = re.compile(r"^rec(\d+)_")


def load_record_names():
    names = {}
    if RECORDS_TSV.exists():
        for line in RECORDS_TSV.read_text().splitlines():
            if line.startswith("#") or not line.strip():
                continue
            f = line.split("\t")
            if len(f) >= 7:
                names[int(f[0])] = f[6]
    return names


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tsv", help="write the per-class table to this TSV file")
    args = ap.parse_args()

    rec_names = load_record_names()
    # key -> [count, name, interp, drc, set(recs)]
    classes = {}
    per_word_total = 0
    rec_word_counts = {}

    for asm in sorted(DSP_DIR.glob("rec*.asm")):
        m = RECFILE.match(asm.name)
        rec = int(m.group(1))
        in_pm = False
        nwords = 0
        for line in asm.read_text().splitlines():
            h = PM_HDR.match(line)
            if h:
                in_pm = (h.group(1) == "PM")
                continue
            if not in_pm:
                continue
            im = INSN.match(line)
            if not im:
                continue
            word = int(im.group(2), 16) & 0xFFFFFFFFFFFF
            nwords += 1
            per_word_total += 1
            for key, name, interp, drc in decode_word(word):
                ent = classes.setdefault(key, [0, name, interp, drc, set()])
                ent[0] += 1
                ent[4].add(rec)
        rec_word_counts[rec] = rec_word_counts.get(rec, 0) + nwords

    # ---- report ----
    def verdict(interp, drc):
        if interp == "OK" and drc == "NATIVE":
            return "OK"
        if interp == "OK" and drc == "FALLBACK":
            return "OK (drc-fallback)"
        return "GAP"

    rows = sorted(classes.items(), key=lambda kv: (-kv[1][0], kv[0]))
    print(f"pool: {len(rec_word_counts)} records, {per_word_total} PM words, "
          f"{len(classes)} distinct instruction/compute classes\n")
    hdr = f"{'count':>7}  {'class':<22} {'interp':<7} {'drc':<9} {'verdict':<17} name"
    print(hdr)
    print("-" * len(hdr))
    gaps = []
    for key, (cnt, name, interp, drc, recs) in rows:
        v = verdict(interp, drc)
        print(f"{cnt:>7}  {key:<22} {interp:<7} {drc:<9} {v:<17} {name}")
        if v == "GAP":
            gaps.append((key, name, interp, drc, cnt, sorted(recs)))

    if args.tsv:
        with open(args.tsv, "w") as f:
            f.write("count\tclass\tname\tinterp\tdrc\tverdict\trecords\n")
            for key, (cnt, name, interp, drc, recs) in rows:
                f.write(f"{cnt}\t{key}\t{name}\t{interp}\t{drc}\t"
                        f"{verdict(interp, drc)}\t"
                        f"{','.join(str(r) for r in sorted(recs))}\n")

    print()
    if gaps:
        print("GAPS (used but not fully supported):")
        for key, name, interp, drc, cnt, recs in gaps:
            recl = ", ".join(f"rec{r:02d} ({rec_names.get(r, '?')})" for r in recs)
            print(f"  {key} {name}: interp={interp} drc={drc} x{cnt}\n    used by: {recl}")
        sys.exit(1)
    print("VERDICT: every instruction used by the pool is implemented in the "
          "interpreter, and the DRC handles all of them (native or "
          "interpreter-fallback). No crash-capable gaps.")


if __name__ == "__main__":
    main()
