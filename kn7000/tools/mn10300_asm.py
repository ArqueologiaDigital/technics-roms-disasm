#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# A (partial) MN10300 instruction ENCODER -- the inverse of MAME's mn103dasm.cpp.
#
# The KN7000 disassembly has no real assembler (no GNU binutils MN10300 target is
# available), which is why the buildable source is still an .incbin skeleton.
# This is the beginnings of one: it turns MN10300 assembly (in MAME unidasm's
# operand syntax) back into the exact instruction bytes, so disassembled code can
# eventually replace the raw .incbin blocks and still rebuild byte-for-byte.
#
# Encoding rules (from mn103dasm.cpp): destination register = low 2 bits of the
# operand byte, source = bits[3:2]; PC-relative targets are relative to the START
# of the instruction; multi-byte operands are little-endian. Where a mnemonic has
# several encodings (imm8/imm16/imm32, disp8/16/32), the SMALLEST that fits the
# operand is chosen -- the same rule a compiler uses.
#
# validate_asm.sh round-trips this against unidasm over the real ROM.

import re
import struct

CONDS = {"lt": 0, "gt": 1, "ge": 2, "le": 3, "cs": 4, "hi": 5,
         "cc": 6, "ls": 7, "eq": 8, "ne": 9}


class EncError(Exception):
    pass


def reg(tok):
    """Returns ('d'|'a'|'sp', index) for a register token."""
    tok = tok.strip()
    if tok == "sp":
        return ("sp", 0)
    m = re.fullmatch(r"([da])([0-3])", tok)
    if not m:
        raise EncError(f"not a register: {tok!r}")
    return (m.group(1), int(m.group(2)))


def imm(tok):
    tok = tok.strip()
    try:
        return int(tok, 16) if tok.startswith(("0x", "-0x")) else int(tok, 0)
    except ValueError:
        raise EncError(f"not an immediate: {tok!r}")


def split_ops(s):
    """Split operands on commas not inside [] or ()."""
    out, buf, depth = [], "", 0
    for ch in s:
        if ch in "[(":
            depth += 1
        elif ch in "])":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(buf.strip()); buf = ""
        else:
            buf += ch
    if buf.strip():
        out.append(buf.strip())
    return out


def u8(v):  return bytes([v & 0xFF])
def le16(v): return struct.pack("<H", v & 0xFFFF)
def le32(v): return struct.pack("<I", v & 0xFFFFFFFF)


def fits_s8(v):  return -0x80 <= v <= 0x7F
def fits_s16(v): return -0x8000 <= v <= 0x7FFF
def fits_u8(v):  return 0 <= v <= 0xFF
def fits_u16(v): return 0 <= v <= 0xFFFF


def mem(tok):
    """Parse a memory operand: (disp, sp) | (disp) | (aM) | (disp, aM).
    Returns a dict describing it."""
    inner = tok.strip()[1:-1]
    parts = split_ops(inner)
    if len(parts) == 1:
        p = parts[0]
        if re.fullmatch(r"a[0-3]", p):
            return {"kind": "areg", "a": int(p[1])}
        return {"kind": "abs", "disp": imm(p)}
    disp = imm(parts[0]); base = parts[1]
    if base == "sp":
        return {"kind": "sp", "disp": disp}
    if re.fullmatch(r"a[0-3]", base):
        return {"kind": "adisp", "a": int(base[1]), "disp": disp}
    raise EncError(f"bad memory operand {tok!r}")


def encode(mnem, ops_str, pc):
    """Encode one instruction to bytes. pc = address of this instruction."""
    ops = split_ops(ops_str) if ops_str else []

    if mnem == "nop":
        return b"\xcb"
    if mnem == "clr":
        _, d = reg(ops[0]); return u8(0x00 | (d << 2))
    if mnem in ("extb", "extbu", "exth", "exthu"):
        base = {"extb": 0x10, "extbu": 0x14, "exth": 0x18, "exthu": 0x1C}[mnem]
        _, d = reg(ops[0]); return u8(base | d)
    if mnem == "inc":
        c, d = reg(ops[0]); return u8((0x40 if c == "d" else 0x41) | (d << 2))
    if mnem == "inc4":
        _, d = reg(ops[0]); return u8(0x50 | d)
    if mnem == "asl2":
        _, d = reg(ops[0]); return u8(0x54 | d)
    if mnem == "setlb":
        return b"\xdb"
    if mnem == "lra":
        return b"\xda"
    if mnem[0] == "l" and mnem[1:] in CONDS:          # Lcc loop branch (1 byte)
        return u8(0xD0 | CONDS[mnem[1:]])

    # --- branches / jumps / calls ---
    if mnem == "bra" or mnem in ("b" + c for c in CONDS):
        target = imm(ops[0]); disp = (target - pc) & 0xFFFFFFFF
        d = target - pc
        if not fits_s8(d):
            raise EncError(f"{mnem} disp8 out of range: {d}")
        op = 0xCA if mnem == "bra" else (0xC0 | CONDS[mnem[1:]])
        return u8(op) + u8(d)
    if mnem == "jmp":
        target = imm(ops[0]); d = target - pc
        if fits_s16(d):
            return b"\xcc" + le16(d)
        return b"\xdc" + le32(d & 0xFFFFFFFF)
    if mnem in ("call", "calls"):
        target = imm(ops[0]); d = (target - pc) & 0xFFFFFFFF
        if mnem == "calls":
            if fits_s16(target - pc):
                return b"\xfa\xff" + le16(target - pc)
            return b"\xfc\xff" + le32(d)
        regs = encode_reglist(ops[1]); adj = imm(ops[2]) & 0xFF
        if fits_s16(target - pc):
            return b"\xcd" + le16(target - pc) + u8(regs) + u8(adj)
        return b"\xdd" + le32(d) + u8(regs) + u8(adj)
    if mnem in ("ret", "retf"):
        regs = encode_reglist(ops[0]); adj = imm(ops[1]) & 0xFF
        return u8(0xDF if mnem == "ret" else 0xDE) + u8(regs) + u8(adj)
    if mnem == "movm":
        # movm regs,(sp)  or  movm (sp),regs
        if ops[0].startswith("["):
            return b"\xcf" + u8(encode_reglist(ops[0]))
        return b"\xce" + u8(encode_reglist(ops[1]))

    # --- shifts (imm8 or reg count) -> F8 or F2 ---
    if mnem in ("asl", "lsr", "asr"):
        sh = {"asl": 0, "lsr": 1, "asr": 2}[mnem]
        _, di = reg(ops[1])
        if re.match(r"-?(0x)?[0-9a-fA-F]+$", ops[0]):        # imm8 count -> F8 C0/C4/C8
            return b"\xf8" + u8(0xC0 | (sh << 2) | di) + u8(imm(ops[0]))
        _, si = reg(ops[0])                                   # reg count -> F2 9x/Ax/Bx
        return b"\xf2" + u8((0x90 + sh * 0x10) | (si << 2) | di)

    # --- F2 reg-reg: not / mul / div ---
    if mnem == "not":
        _, di = reg(ops[0]); return b"\xf2" + u8(0x30 | di)
    if mnem in ("mul", "mulu", "div", "divu"):
        base = {"mul": 0x40, "mulu": 0x50, "div": 0x60, "divu": 0x70}[mnem]
        _, si = reg(ops[0]); _, di = reg(ops[1])
        return b"\xf2" + u8(base | (si << 2) | di)

    # --- ALU/mov families dispatched by operand shapes ---
    if mnem in ("mov", "movbu", "movhu"):
        return enc_move(mnem, ops, pc)
    if mnem in ("add", "sub", "cmp", "and", "or", "xor"):
        return enc_alu(mnem, ops)

    raise EncError(f"unsupported mnemonic: {mnem} {ops_str}")


REGLIST_BITS = {"d2": 0x80, "d3": 0x40, "a2": 0x20, "a3": 0x10}


def encode_reglist(tok):
    """Encode a movm/call register-list like [d2,d3,a2,a3] or 0."""
    tok = tok.strip()
    if tok == "0":
        return 0
    mask = 0
    for r in tok.strip("[]").split(","):
        r = r.strip()
        if r in REGLIST_BITS:
            mask |= REGLIST_BITS[r]
        elif r == "other":
            mask |= 0x02
        else:
            raise EncError(f"unhandled reg-list member {r!r}")
    return mask


def is_reg_tok(t):
    return re.fullmatch(r"[da][0-3]|sp", t.strip()) is not None


def enc_move(mnem, ops, pc):
    src, dst = ops[0], ops[1]

    # register <-> memory
    if src.startswith("("):
        return enc_ldst(mnem, mem(src), reg(dst), store=False)
    if dst.startswith("("):
        return enc_ldst(mnem, mem(dst), reg(src), store=True)

    # reg <- reg (mov only)
    if mnem == "mov" and is_reg_tok(src) and is_reg_tok(dst):
        sc, si = reg(src); dc, di = reg(dst)
        if sc == "sp":  return u8(0x3C | di)               # mov sp, aD
        if dc == "sp" and sc == "a": return b"\xf2" + u8(0xF0 | (si << 2))  # mov aS, sp
        if sc == "d" and dc == "d" and si != di: return u8(0x80 | (si << 2) | di)
        if sc == "a" and dc == "a" and si != di: return u8(0x90 | (si << 2) | di)
        if sc == "a" and dc == "d": return b"\xf1" + u8(0xD0 | (si << 2) | di)  # mov aS,dD
        if sc == "d" and dc == "a": return b"\xf1" + u8(0xE0 | (si << 2) | di)  # mov dS,aD
        raise EncError(f"unhandled mov reg,reg {ops}")

    # imm -> reg
    if mnem == "mov" and not is_reg_tok(src):
        v = imm(src); dc, di = reg(dst)
        if dc == "d":
            if fits_s8(v):  return u8(0x80 | (di << 2) | di) + u8(v)
            if fits_s16(v): return u8(0x2C | di) + le16(v)
            return b"\xfc" + u8(0xCC | di) + le32(v)
        else:  # a-reg, zero-extended small forms
            if fits_u8(v):  return u8(0x90 | (di << 2) | di) + u8(v)
            if fits_u16(v): return u8(0x24 | di) + le16(v)
            return b"\xfc" + u8(0xDC | di) + le32(v)
    raise EncError(f"unhandled {mnem} {ops}")


def enc_ldst(mnem, m, r, store):
    rc, ri = r
    size = {"mov": 0, "movbu": 2, "movhu": 3}[mnem]  # 0=word(a/d),2=byte,3=half

    if m["kind"] == "sp":
        disp = m["disp"]
        if size == 0 and fits_u8(disp):     # 32-bit mov <-> (disp8,sp)
            if store:
                return u8((0x42 if rc == "d" else 0x43) | (ri << 2)) + u8(disp)
            return u8((0x58 if rc == "d" else 0x5C) | ri) + u8(disp)
        if size in (2, 3) and rc == "d" and fits_u8(disp):
            if store:                        # movbu/movhu dD,(disp8,sp) -> F8 0x92/0x93
                return b"\xf8" + u8(0x90 | (ri << 2) | size) + u8(disp)
            return b"\xf8" + u8(0xB8 | ((size & 1) << 2) | ri) + u8(disp)  # load
        # 16-bit (disp,sp) forms via FA (word: B0/B4, byte:B8, half:BC ; store 0x1x)
        if fits_u16(disp):
            if store and size == 0:
                return b"\xfa" + u8(0x10 | (ri << 2) | (0 if rc == "a" else 1)) + le16(disp)
            if not store:
                typ = {0: (0 if rc == "a" else 1), 2: 2, 3: 3}[size]
                return b"\xfa" + u8(0xB0 | (typ << 2) | ri) + le16(disp)

    if m["kind"] == "adisp":
        disp = m["disp"]
        typ = {0: (1 if rc == "a" else 0), 2: 2, 3: 3}[size]
        dirbit = 0x10 if store else 0
        if fits_s8(disp):                    # (disp8,aM) -> F8 op2<0x80
            return b"\xf8" + u8((typ << 5) | dirbit | (ri << 2) | m["a"]) + u8(disp & 0xFF)
        if fits_s16(disp):                   # (disp16,aM) -> FA op2<0x80
            return b"\xfa" + u8((typ << 5) | dirbit | (ri << 2) | m["a"]) + le16(disp)
        return b"\xfc" + u8((typ << 5) | dirbit | (ri << 2) | m["a"]) + le32(disp)

    if m["kind"] == "areg" and size == 0 and rc == "d":
        return u8((0x60 if store else 0x70) | (ri << 2) | m["a"])

    if m["kind"] == "abs":                   # (abs16) short forms, else FC (abs32)
        a = m["disp"]
        if size == 0 and rc == "d" and fits_u16(a):
            if store: return u8(0x01 | (ri << 2)) + le16(a)   # mov dD,(abs16)
            return u8(0x30 | ri) + le16(a)                    # mov (abs16),dD
        if size in (2, 3) and rc == "d" and fits_u16(a):
            if store: return u8((0x02 if size == 2 else 0x03) | (ri << 2)) + le16(a)
            return u8((0x34 if size == 2 else 0x38) | ri) + le16(a)
        # abs32 via FC 0x80-0xBF (store 0x80-0x9F / load 0xA0-0xBF), bit4=0 => abs
        typ = {0: (0 if rc == "a" else 1), 2: 2, 3: 3}[size]
        if store:
            return b"\xfc" + u8(0x80 | (typ) | (ri << 2)) + le32(a)
        return b"\xfc" + u8(0xA0 | (typ << 2) | ri) + le32(a)

    raise EncError(f"unhandled ld/st {mnem} store={store} {m} {r}")


def enc_alu(mnem, ops):
    src, dst = ops[0], ops[1]
    dc, di = reg(dst)

    if is_reg_tok(src):       # reg, reg
        sc, si = reg(src)
        if mnem == "add" and dc == "d" and sc == "d":
            return u8(0xE0 | (si << 2) | di)               # add dS,dD
        # F2 reg-reg logicals (data regs only)
        if mnem in ("and", "or", "xor") and dc == "d" and sc == "d":
            return b"\xf2" + u8({"and": 0x00, "or": 0x10, "xor": 0x20}[mnem]
                                | (si << 2) | di)
        # F1 cross-type add/sub/cmp/mov between data and address regs
        F1 = {("sub", "d", "d"): 0x00, ("sub", "a", "d"): 0x10,
              ("sub", "d", "a"): 0x20, ("sub", "a", "a"): 0x30,
              ("add", "a", "d"): 0x50, ("add", "d", "a"): 0x60,
              ("add", "a", "a"): 0x70, ("cmp", "a", "d"): 0x90,
              ("cmp", "d", "a"): 0xA0, ("mov", "a", "d"): 0xD0,
              ("mov", "d", "a"): 0xE0}
        k = (mnem, sc, dc)
        if k in F1:
            return b"\xf1" + u8(F1[k] | (si << 2) | di)
        raise EncError(f"unhandled reg-reg {mnem} {ops}")

    v = imm(src)

    if mnem == "add" and dc == "sp":                       # add imm,sp
        if fits_s8(v):  return b"\xf8\xfe" + u8(v)
        if fits_s16(v): return b"\xfa\xfe" + le16(v)
        return b"\xfc\xfe" + le32(v)

    # per-op opcode nibbles for the FA (imm16) / FC (imm32) prefixed forms
    FA = {("add", "d"): 0xC0, ("add", "a"): 0xD0, ("cmp", "d"): 0xC8,
          ("cmp", "a"): 0xD8, ("and", "d"): 0xE0, ("or", "d"): 0xE4,
          ("xor", "d"): 0xE8}
    FC = {("add", "d"): 0xC0, ("add", "a"): 0xD0, ("sub", "d"): 0xC4,
          ("sub", "a"): 0xD4, ("cmp", "d"): 0xC8, ("cmp", "a"): 0xD8,
          ("and", "d"): 0xE0, ("or", "d"): 0xE4, ("xor", "d"): 0xE8}
    key = (mnem, dc)
    signed = mnem in ("add", "sub") or (mnem == "cmp" and dc == "d")
    small = fits_s8(v) if signed else fits_u8(v)
    mid = fits_s16(v) if signed else fits_u16(v)

    # imm8 short forms (each op has a distinct encoding)
    if small:
        if mnem == "add" and dc == "d":  return u8(0x28 | di) + u8(v)
        if mnem == "add" and dc == "a":  return u8(0x20 | di) + u8(v)
        if mnem == "cmp" and dc == "d":  return u8(0xA0 | (di << 2) | di) + u8(v)
        if mnem == "cmp" and dc == "a":  return u8(0xB0 | (di << 2) | di) + u8(v)
        if mnem in ("and", "or") and dc == "d":            # F8 E0/E4 (no xor imm8)
            return b"\xf8" + u8({"and": 0xE0, "or": 0xE4}[mnem] | di) + u8(v)
    # imm16 forms (FA)
    if mid and key in FA:
        return b"\xfa" + u8(FA[key] | di) + le16(v)
    # imm32 forms (FC)
    if key in FC:
        return b"\xfc" + u8(FC[key] | di) + le32(v)
    raise EncError(f"unhandled alu {mnem} {ops}")


if __name__ == "__main__":
    import sys
    # quick self-test on a couple of instructions
    tests = [("nop", "", 0), ("clr", "d0", 0), ("mov", "d1, d0", 0),
             ("add", "-0x14, sp", 0), ("ret", "0, 0x14", 0)]
    for mn, ops, pc in tests:
        print(f"{mn} {ops}  -> {encode(mn, ops, pc).hex()}")
