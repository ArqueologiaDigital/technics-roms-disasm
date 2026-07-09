#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# A small MN10300 interpreter used to (a) sanity-check the instruction semantics
# on real firmware and (b) trace the KN7000 boot's hardware I/O -- including the
# register-INDIRECT accesses that the static I/O scan (notes/io-map.md) can't see.
#
# It implements the same instruction subset as the MAME CPU core draft
# (kn7000_mame/src/devices/cpu/mn10300/mn10300.cpp). It is NOT cycle-accurate and
# models no peripherals: I/O reads return 0 (overridable), and the run stops when
# it spins on an I/O poll, hits an unimplemented opcode, or reaches a step cap --
# which is exactly the point where a peripheral model would be needed next.

import struct
import sys

M32 = 0xFFFFFFFF


class Unmapped(Exception):
    def __init__(self, kind, addr):
        super().__init__(f"{kind} @ 0x{addr:08X}")
        self.kind = kind
        self.addr = addr


def valid_io(a):
    # 0x9C000000 is the effects-DSP (ADSP-21065L) host data port + sound-board
    # GPIO/rev registers (0x9CC000xx); 0x9CE00000 is the LCD framebuffer window.
    # Modelling the 0x9C bank as I/O lets the DSP boot path be simulated.
    return (0x20000000 <= a < 0x30000000 or 0x32000000 <= a < 0x38000000
            or 0x98000000 <= a < 0x99000000
            or 0x9C000000 <= a < 0x9D000000)


class Mem:
    def __init__(self, program, table):
        self.program = program
        self.table = table
        self.ram = bytearray(0x2000000)     # work RAM @0x50000000 (generous 32MB)
        self.devram = bytearray(0x100000)   # scratch backing for the device windows
        self.io_log = []                    # (kind, addr, value)

    def _region(self, a):
        if 0x48400000 <= a < 0x48400000 + len(self.program):
            return ("rom", self.program, a - 0x48400000)
        if 0x48000000 <= a < 0x48000000 + len(self.table):
            return ("rom", self.table, a - 0x48000000)
        if 0x50000000 <= a < 0x50000000 + len(self.ram):
            return ("ram", self.ram, a - 0x50000000)
        # Device windows found by the boot trace (LCD V-RAM / video / wave-DMA):
        # 0x8C000000 and 0x90000000. Back them with a small scratch buffer folded
        # by mask so the boot's copies/writes succeed and we can trace onward.
        if 0x8C000000 <= a < 0x8D000000 or 0x90000000 <= a < 0x98000000:
            return ("ram", self.devram, a & 0xFFFFF)
        if valid_io(a):
            return ("io", None, a)
        # anything else = undumped resource (library ROM 0x4C, picture flash
        # 0x57800000) or a wild pointer from an I/O value we couldn't supply.
        raise Unmapped("data-access", a)

    def r(self, a, n):
        kind, buf, off = self._region(a)
        if kind == "io":
            self.io_log.append(("r%d" % n, a, None))
            return 0
        v = 0
        for i in range(n):
            v |= buf[off + i] << (8 * i)
        return v

    def w(self, a, n, val):
        kind, buf, off = self._region(a)
        if kind == "io":
            self.io_log.append(("w%d" % n, a, val & ((1 << (8 * n)) - 1)))
            return
        if kind == "rom":
            self.io_log.append(("wROM", a, val))      # writes to ROM = a bug/flash cmd
            return
        for i in range(n):
            buf[off + i] = (val >> (8 * i)) & 0xFF


class Sim:
    def __init__(self, mem):
        self.m = mem
        self.d = [0, 0, 0, 0]
        self.a = [0, 0, 0, 0]
        self.sp = 0x50021CF8
        self.pc = 0x4840FF7E              # reset entry (jmp target from file 0x0)
        self.mdr = self.lir = self.lar = 0
        self.Z = self.N = self.C = self.V = 0
        self.steps = 0
        self.hle = False          # HLE-stub calls into the undumped library ROM?
        self.lib_calls = []       # (target, d0, d1, a0, a1, retpc) when hle

    # -- fetch helpers (little-endian) --
    def r8(self, a):  return self.m.r(a, 1)
    def r16(self, a): return self.m.r(a, 2)
    def r32(self, a): return self.m.r(a, 4)

    def sx8(self, v):  return v - 0x100 if v & 0x80 else v
    def sx16(self, v): return v - 0x10000 if v & 0x8000 else v

    def setnz(self, r):
        r &= M32
        self.Z = 1 if r == 0 else 0
        self.N = 1 if r & 0x80000000 else 0

    def add(self, x, y, cin=0):
        w = (x & M32) + (y & M32) + cin
        r = w & M32
        self.Z = 1 if r == 0 else 0
        self.N = 1 if r & 0x80000000 else 0
        self.C = 1 if w > M32 else 0
        self.V = 1 if (~(x ^ y) & (x ^ r)) & 0x80000000 else 0
        return r

    def sub(self, x, y, bin=0):
        w = (x & M32) - (y & M32) - bin
        r = w & M32
        self.Z = 1 if r == 0 else 0
        self.N = 1 if r & 0x80000000 else 0
        self.C = 1 if (w >> 32) & 1 else 0
        self.V = 1 if ((x ^ y) & (x ^ r)) & 0x80000000 else 0
        return r

    def cond(self, cc):
        Z, N, C, V = self.Z, self.N, self.C, self.V
        return [N ^ V, not ((N ^ V) or Z), not (N ^ V), (N ^ V) or Z,
                C, not (C or Z), not C, C or Z, Z, not Z][cc]

    def _call(self, target, retpc, regs, adj):
        # Calls into the undumped library ROM (0x4C000000) can optionally be
        # HLE-stubbed: the C ABI makes the callee preserve `regs` and free its
        # own `adj`-byte frame, so a call is net-zero on the caller's regs/sp --
        # we just record it, set a return value, and fall through.
        if self.hle and 0x4C000000 <= target < 0x4D000000:
            self.lib_calls.append((target, self.d[0], self.d[1],
                                   self.a[0], self.a[1], retpc))
            self.d[0] = self._hle_lib(target)
            self.pc = retpc
            return
        self.push(retpc)
        self.store_regs(regs)
        self.sp = (self.sp - adj) & M32
        self.pc = target

    def _hle_lib(self, target):
        # Pure stub: no side effects, return 0. (Confidently-modelled functions
        # like memcpy can be added here once the call sequence is understood.)
        return 0

    def push(self, v):
        self.sp = (self.sp - 4) & M32
        self.m.w(self.sp, 4, v)

    def pop(self):
        v = self.m.r(self.sp, 4)
        self.sp = (self.sp + 4) & M32
        return v

    # register list (only D2/D3/A2/A3 seen in real KN7000 code)
    def store_regs(self, mask):
        if mask & 0x80: self.push(self.d[2])
        if mask & 0x40: self.push(self.d[3])
        if mask & 0x20: self.push(self.a[2])
        if mask & 0x10: self.push(self.a[3])

    def load_regs(self, mask):
        if mask & 0x10: self.a[3] = self.pop()
        if mask & 0x20: self.a[2] = self.pop()
        if mask & 0x40: self.d[3] = self.pop()
        if mask & 0x80: self.d[2] = self.pop()

    def step(self):
        pc = self.pc
        op = self.r8(pc)
        dst = op & 3
        src = (op >> 2) & 3
        self.pc = (pc + 1) & M32

        # single-byte group --------------------------------------------------
        if op in (0x00, 0x04, 0x08, 0x0C):
            self.d[src] = 0; self.Z, self.N, self.C, self.V = 1, 0, 0, 0
        elif 0x10 <= op <= 0x13: self.d[dst] = self.sx8(self.d[dst] & 0xFF) & M32
        elif 0x14 <= op <= 0x17: self.d[dst] &= 0xFF
        elif 0x18 <= op <= 0x1B: self.d[dst] = self.sx16(self.d[dst] & 0xFFFF) & M32
        elif 0x1C <= op <= 0x1F: self.d[dst] &= 0xFFFF
        elif 0x20 <= op <= 0x23:
            self.a[dst] = self.add(self.a[dst], self.sx8(self.r8(self.pc))); self.pc += 1
        elif 0x28 <= op <= 0x2B:
            self.d[dst] = self.add(self.d[dst], self.sx8(self.r8(self.pc))); self.pc += 1
        elif 0x24 <= op <= 0x27: self.a[dst] = self.r16(self.pc); self.pc += 2
        elif 0x2C <= op <= 0x2F: self.d[dst] = self.sx16(self.r16(self.pc)) & M32; self.pc += 2
        elif 0x30 <= op <= 0x33: self.d[dst] = self.r32(self.r16(self.pc)); self.pc += 2
        elif 0x34 <= op <= 0x37: self.d[dst] = self.r8(self.r16(self.pc)); self.pc += 2
        elif 0x38 <= op <= 0x3B: self.d[dst] = self.r16(self.r16(self.pc)); self.pc += 2
        elif 0x3C <= op <= 0x3F: self.a[dst] = self.sp
        elif op in (0x40, 0x44, 0x48, 0x4C): self.d[src] = self.add(self.d[src], 1)
        elif op in (0x41, 0x45, 0x49, 0x4D): self.a[src] = (self.a[src] + 1) & M32
        elif op in (0x42, 0x46, 0x4A, 0x4E):
            self.m.w((self.sp + self.r8(self.pc)) & M32, 4, self.d[src]); self.pc += 1
        elif op in (0x43, 0x47, 0x4B, 0x4F):
            self.m.w((self.sp + self.r8(self.pc)) & M32, 4, self.a[src]); self.pc += 1
        elif 0x50 <= op <= 0x53: self.a[dst] = (self.a[dst] + 4) & M32
        elif 0x54 <= op <= 0x57: self.d[dst] = (self.d[dst] << 2) & M32; self.setnz(self.d[dst])
        elif 0x58 <= op <= 0x5B:
            self.d[dst] = self.m.r((self.sp + self.r8(self.pc)) & M32, 4); self.pc += 1
        elif 0x5C <= op <= 0x5F:
            self.a[dst] = self.m.r((self.sp + self.r8(self.pc)) & M32, 4); self.pc += 1
        elif 0x60 <= op <= 0x6F: self.m.w(self.a[dst], 4, self.d[src])
        elif 0x70 <= op <= 0x7F: self.d[src] = self.m.r(self.a[dst], 4)
        elif op in (0x80, 0x85, 0x8A, 0x8F):
            self.d[dst] = self.sx8(self.r8(self.pc)) & M32; self.pc += 1
        elif 0x81 <= op <= 0x8E: self.d[dst] = self.d[src]
        elif op in (0x90, 0x95, 0x9A, 0x9F): self.a[dst] = self.r8(self.pc); self.pc += 1
        elif 0x91 <= op <= 0x9E: self.a[dst] = self.a[src]
        elif op in (0xA0, 0xA5, 0xAA, 0xAF):
            self.sub(self.d[dst], self.sx8(self.r8(self.pc))); self.pc += 1
        elif 0xA1 <= op <= 0xAE: self.sub(self.d[dst], self.d[src])
        elif op in (0xB0, 0xB5, 0xBA, 0xBF):
            self.sub(self.a[dst], self.r8(self.pc)); self.pc += 1
        elif 0xB1 <= op <= 0xBE: self.sub(self.a[dst], self.a[src])
        elif 0xC0 <= op <= 0xC9:
            d = self.sx8(self.r8(self.pc)); self.pc += 1
            if self.cond(op & 0xF): self.pc = (pc + d) & M32
        elif op == 0xCA:
            d = self.sx8(self.r8(self.pc)); self.pc = (pc + d) & M32
        elif op == 0xCB: pass
        elif op == 0xCC: self.pc = (pc + self.sx16(self.r16(self.pc))) & M32
        elif op == 0xCD:
            disp = self.sx16(self.r16(self.pc)); regs = self.r8(self.pc + 2); adj = self.r8(self.pc + 3)
            self._call((pc + disp) & M32, (pc + 4) & M32, regs, adj)
        elif op == 0xCE: self.load_regs(self.r8(self.pc)); self.pc += 1
        elif op == 0xCF: self.store_regs(self.r8(self.pc)); self.pc += 1
        elif op == 0xDB: self.lar = self.pc; self.lir = self.r32(self.pc)
        elif 0xD0 <= op <= 0xD9:
            if self.cond(op & 0xF): self.pc = self.lar
        elif op == 0xDC: self.pc = (pc + self.r32(self.pc)) & M32
        elif op == 0xDD:
            disp = self.r32(self.pc); regs = self.r8(self.pc + 4); adj = self.r8(self.pc + 5)
            self._call((pc + disp) & M32, (pc + 6) & M32, regs, adj)
        elif op in (0xDE, 0xDF):
            regs = self.r8(self.pc); adj = self.r8(self.pc + 1)
            self.sp = (self.sp + adj) & M32; self.load_regs(regs); self.pc = self.pop()
        elif 0xE0 <= op <= 0xEF: self.d[dst] = self.add(self.d[dst], self.d[src])
        elif op == 0xF0: self._f0()
        elif op == 0xF1: self._f1()
        elif op == 0xF2: self._f2()
        elif op == 0xF3: self._f3()
        elif op == 0xF4: self._f4()
        elif op == 0xF8: self._f8()
        elif op == 0xFA: self._fa()
        elif op == 0xFC: self._fc()
        elif op == 0xFE: self._fe()
        else:
            raise NotImplementedError(f"opcode {op:02X} @ {pc:08X}")
        self.steps += 1

    # --- prefixed groups (subset used by real code) ---
    def _f0(self):
        op2 = self.r8(self.pc); self.pc += 1
        r = (op2 >> 2) & 3; am = op2 & 3; hi = op2 >> 4
        if hi == 0x0: self.a[r] = self.m.r(self.a[am], 4)
        elif hi == 0x4: self.d[r] = self.m.r(self.a[am], 1)
        elif hi == 0x6: self.d[r] = self.m.r(self.a[am], 2)
        elif hi == 0x1: self.m.w(self.a[am], 4, self.a[r])
        elif hi == 0x5: self.m.w(self.a[am], 1, self.d[r])
        elif hi == 0x7: self.m.w(self.a[am], 2, self.d[r])
        elif hi == 0x8:
            v = self.m.r(self.a[am], 1); self.Z = 0 if v & self.d[r] else 1
            self.m.w(self.a[am], 1, v | self.d[r])
        elif hi == 0x9:
            v = self.m.r(self.a[am], 1); self.Z = 0 if v & self.d[r] else 1
            self.m.w(self.a[am], 1, v & ~self.d[r] & 0xFF)
        elif hi == 0xF:
            if op2 <= 0xF3: self.push(self.pc); self.pc = self.a[am]      # calls (aM)
            elif op2 <= 0xF7: self.pc = self.a[am]                        # jmp (aM)
            elif op2 == 0xFC: self.pc = self.pop()                        # rets
            else: raise NotImplementedError(f"F0 {op2:02X}")

    def _f1(self):
        op2 = self.r8(self.pc); self.pc += 1
        d = op2 & 3; s = (op2 >> 2) & 3; C = self.C
        h = op2 >> 4
        if h == 0x0: self.d[d] = self.sub(self.d[d], self.d[s])
        elif h == 0x1: self.d[d] = self.sub(self.d[d], self.a[s])
        elif h == 0x2: self.a[d] = self.sub(self.a[d], self.d[s])
        elif h == 0x3: self.a[d] = self.sub(self.a[d], self.a[s])
        elif h == 0x4: self.d[d] = self.add(self.d[d], self.d[s], C)
        elif h == 0x5: self.d[d] = self.add(self.d[d], self.a[s])
        elif h == 0x6: self.a[d] = self.add(self.a[d], self.d[s])
        elif h == 0x7: self.a[d] = self.add(self.a[d], self.a[s])
        elif h == 0x8: self.d[d] = self.sub(self.d[d], self.d[s], C)
        elif h == 0x9: self.sub(self.d[d], self.a[s])
        elif h == 0xA: self.sub(self.a[d], self.d[s])
        elif h == 0xD: self.d[d] = self.a[s]
        elif h == 0xE: self.a[d] = self.d[s]

    def _f2(self):
        op2 = self.r8(self.pc); self.pc += 1
        d = op2 & 3; s = (op2 >> 2) & 3; h = op2 >> 4
        if h == 0x0: self.d[d] &= self.d[s]; self._logic(d)
        elif h == 0x1: self.d[d] |= self.d[s]; self._logic(d)
        elif h == 0x2: self.d[d] ^= self.d[s]; self._logic(d)
        elif h == 0x3 and op2 < 0x34: self.d[d] = ~self.d[d] & M32; self._logic(d)
        elif h == 0x4:
            p = self._sx(self.d[s]) * self._sx(self.d[d]); self.d[d] = p & M32; self.mdr = (p >> 32) & M32; self.setnz(self.d[d])
        elif h == 0x5:
            p = self.d[s] * self.d[d]; self.d[d] = p & M32; self.mdr = (p >> 32) & M32; self.setnz(self.d[d])
        elif h in (0x9, 0xA, 0xB):
            n = self.d[s] & 0x1F
            if n:
                if h == 0x9: self.d[d] = (self.d[d] << n) & M32
                elif h == 0xA: self.d[d] = (self.d[d] & M32) >> n
                else: self.d[d] = self._sx(self.d[d]) >> n & M32
            self.setnz(self.d[d])
        elif h == 0xD and op2 < 0xD4: self.mdr = M32 if self.d[d] & 0x80000000 else 0
        elif h == 0xE:
            if op2 < 0xE4: self.d[d] = self.mdr
            else: self.d[d] = self._psw()
        elif h == 0xF:
            if op2 & 2:
                if op2 & 1: self._setpsw(self.d[s])
                else: self.mdr = self.d[s]
            elif (op2 & 1) == 0: self.sp = self.a[s]

    def _f3(self):
        op2 = self.r8(self.pc); self.pc += 1
        store = op2 & 0x40; areg = op2 & 0x80; reg = (op2 >> 4) & 3
        ea = (self.a[op2 & 3] + self.d[(op2 >> 2) & 3]) & M32
        if store: self.m.w(ea, 4, self.a[reg] if areg else self.d[reg])
        else:
            v = self.m.r(ea, 4)
            if areg: self.a[reg] = v
            else: self.d[reg] = v

    def _f4(self):
        op2 = self.r8(self.pc); self.pc += 1
        half = op2 & 0x80; store = op2 & 0x40; reg = (op2 >> 4) & 3
        ea = (self.a[op2 & 3] + self.d[(op2 >> 2) & 3]) & M32
        n = 2 if half else 1
        if store: self.m.w(ea, n, self.d[reg])
        else: self.d[reg] = self.m.r(ea, n)

    def _f8(self):
        op2 = self.r8(self.pc); b = self.r8(self.pc + 1); self.pc += 2
        sd = self.sx8(b)
        if op2 < 0x80:
            typ = (op2 >> 5) & 3; store = op2 & 0x10; r = (op2 >> 2) & 3
            ea = (self.a[op2 & 3] + sd) & M32
            self._tmove(typ, store, r, ea)
        elif (op2 & 0xF2) == 0x92:
            self.m.w((self.sp + b) & M32, 1 if (op2 & 3) == 2 else 2, self.d[(op2 >> 2) & 3])
        else:
            k = op2 & 0xFC
            if k in (0xB8, 0xBC):
                self.d[op2 & 3] = self.m.r((self.sp + b) & M32, 1 if ((op2 >> 2) & 3) == 2 else 2)
            elif k in (0xC0, 0xC4, 0xC8): self._shift((op2 >> 2) & 3, op2 & 3, b)
            elif k in (0xE0, 0xE4, 0xEC):
                d = op2 & 3; lop = (op2 >> 2) & 3
                if lop == 0: self.d[d] &= b; self._logic(d)
                elif lop == 1: self.d[d] |= b; self._logic(d)
                else: self.Z = 0 if self.d[d] & b else 1
            elif k == 0xE8:
                take = [not self.V, self.V, not self.N, self.N][op2 & 3]
                if take: self.pc = (self.pc - 3 + sd) & M32
            elif k == 0xF0: self.sp = self.m.r((self.a[op2 & 3] + sd) & M32, 4)
            elif k == 0xF4: self.m.w((self.a[op2 & 3] + sd) & M32, 4, self.sp)
            elif k == 0xFC and op2 == 0xFE: self.sp = (self.sp + sd) & M32

    def _fa(self):
        op2 = self.r8(self.pc); imm = self.r16(self.pc + 1); self.pc += 3
        d = op2 & 3
        if op2 < 0x80:
            typ = (op2 >> 5) & 3; store = op2 & 0x10; r = (op2 >> 2) & 3
            ea = (self.a[op2 & 3] + self.sx16(imm)) & M32
            self._tmove(typ, store, r, ea)
            return
        k = op2 & 0xFC
        if k == 0xC0: self.d[d] = self.add(self.d[d], self.sx16(imm))
        elif k == 0xD0: self.a[d] = self.add(self.a[d], self.sx16(imm))
        elif k == 0xC8: self.sub(self.d[d], self.sx16(imm))
        elif k == 0xD8: self.sub(self.a[d], imm)
        elif k == 0xE0: self.d[d] &= imm; self._logic(d)
        elif k == 0xE4: self.d[d] |= imm; self._logic(d)
        elif k == 0xE8: self.d[d] ^= imm; self._logic(d)
        elif k == 0xEC: self.Z = 0 if self.d[d] & imm else 1
        elif k == 0xB0: self.a[d] = self.m.r((self.sp + imm) & M32, 4)
        elif k == 0xB4: self.d[d] = self.m.r((self.sp + imm) & M32, 4)
        elif k == 0xB8: self.d[d] = self.m.r((self.sp + imm) & M32, 1)
        elif k == 0xBC: self.d[d] = self.m.r((self.sp + imm) & M32, 2)
        elif k == 0xA0: self.a[d] = self.m.r(imm, 4)
        elif k == 0xFC:
            if op2 == 0xFE: self.sp = (self.sp + self.sx16(imm)) & M32
            elif op2 == 0xFF: self.push(self.pc); self.pc = (self.pc - 4 + self.sx16(imm)) & M32

    def _fc(self):
        op2 = self.r8(self.pc); imm = self.r32(self.pc + 1)
        start = self.pc - 1; self.pc += 5
        d = op2 & 3
        if op2 < 0x80:
            typ = (op2 >> 5) & 3; store = op2 & 0x10; r = (op2 >> 2) & 3
            self._tmove(typ, store, r, (self.a[op2 & 3] + imm) & M32); return
        if op2 < 0xA0:
            typ = op2 & 3; r = (op2 >> 2) & 3
            ea = (self.sp + imm) & M32 if op2 & 0x10 else imm
            self._tmove(0 if typ == 0 else (1 if typ == 1 else typ), True, r, ea, areg=(typ == 0)); return
        if op2 < 0xC0:
            typ = (op2 >> 2) & 3; r = op2 & 3
            ea = (self.sp + imm) & M32 if op2 & 0x10 else imm
            self._tmove(0 if typ == 0 else (1 if typ == 1 else typ), False, r, ea, areg=(typ == 0)); return
        k = op2 & 0xFC
        if k == 0xC0: self.d[d] = self.add(self.d[d], imm)
        elif k == 0xD0: self.a[d] = self.add(self.a[d], imm)
        elif k == 0xC4: self.d[d] = self.sub(self.d[d], imm)
        elif k == 0xD4: self.a[d] = self.sub(self.a[d], imm)
        elif k == 0xC8: self.sub(self.d[d], imm)
        elif k == 0xD8: self.sub(self.a[d], imm)
        elif k == 0xCC: self.d[d] = imm
        elif k == 0xDC: self.a[d] = imm
        elif k == 0xE0: self.d[d] &= imm; self._logic(d)
        elif k == 0xE4: self.d[d] |= imm; self._logic(d)
        elif k == 0xE8: self.d[d] ^= imm; self._logic(d)
        elif k == 0xEC: self.Z = 0 if self.d[d] & imm else 1
        elif k == 0xFC:
            if op2 == 0xFE: self.sp = (self.sp + imm) & M32
            elif op2 == 0xFF: self.push(self.pc); self.pc = (start + imm) & M32

    def _fe(self):
        op2 = self.r8(self.pc)
        if op2 <= 0x02:
            addr = self.r32(self.pc + 1); mask = self.r8(self.pc + 5); self.pc += 6
        elif 0x80 <= op2 <= 0x82:
            addr = self.r16(self.pc + 1); mask = self.r8(self.pc + 3); self.pc += 4
        else:
            self.pc += 1; return
        v = self.m.r(addr, 1); self.Z = 0 if v & mask else 1
        k = op2 & 0x0F
        if k == 0: self.m.w(addr, 1, v | mask)
        elif k == 1: self.m.w(addr, 1, v & ~mask & 0xFF)

    def _tmove(self, typ, store, r, ea, areg=None):
        if areg is None:
            areg = (typ == 1)
        if typ in (0, 1):
            if store: self.m.w(ea, 4, self.a[r] if areg else self.d[r])
            else:
                v = self.m.r(ea, 4)
                if areg: self.a[r] = v
                else: self.d[r] = v
        elif typ == 2:
            if store: self.m.w(ea, 1, self.d[r])
            else: self.d[r] = self.m.r(ea, 1)
        else:
            if store: self.m.w(ea, 2, self.d[r])
            else: self.d[r] = self.m.r(ea, 2)

    def _shift(self, sh, d, n):
        n &= 0x1F
        if n:
            if sh == 0: self.d[d] = (self.d[d] << n) & M32
            elif sh == 1: self.d[d] = (self.d[d] & M32) >> n
            else: self.d[d] = self._sx(self.d[d]) >> n & M32
        self.setnz(self.d[d])

    def _logic(self, d):
        self.d[d] &= M32; self.setnz(self.d[d]); self.C = 0; self.V = 0

    def _sx(self, v):
        v &= M32
        return v - (1 << 32) if v & 0x80000000 else v

    def _psw(self):
        return (self.Z) | (self.N << 1) | (self.C << 2) | (self.V << 3)

    def _setpsw(self, v):
        self.Z = v & 1; self.N = (v >> 1) & 1; self.C = (v >> 2) & 1; self.V = (v >> 3) & 1


def main():
    import argparse
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--program", default="baserom/kn7000_program.rom")
    ap.add_argument("--table", default="baserom/kn7000_table.rom")
    ap.add_argument("--steps", type=int, default=200000)
    ap.add_argument("--hle-lib", action="store_true",
                    help="stub calls into the undumped library ROM (0x4C...) and "
                         "trace the call sequence instead of stopping at the first one")
    args = ap.parse_args()

    mem = Mem(open(args.program, "rb").read(), open(args.table, "rb").read())
    sim = Sim(mem)
    sim.hle = args.hle_lib
    reason = "step cap"
    plo, phi = 0x48400080, 0x48400000 + len(mem.program)
    try:
        while sim.steps < args.steps:
            pc = sim.pc
            # Stop cleanly when the boot leaves the program ROM -- most likely a
            # call into the undumped library/kernel ROM at 0x4C000000 (which we
            # cannot execute), or a wild jump. Either way that's the frontier.
            if not (plo <= pc < phi):
                reason = f"left program ROM: PC=0x{pc:08X}" + \
                    (" (undumped library ROM @0x4C000000)" if 0x4C000000 <= pc < 0x4D000000 else "")
                break
            # I/O-poll detector: many consecutive I/O reads of the same 1-2
            # addresses with no writes = waiting on a status bit we don't model.
            # (Memory-clear/init loops write RAM and make progress, so they pass.)
            n0 = len(mem.io_log)
            sim.step()
            tail = mem.io_log[-80:]
            if len(mem.io_log) - n0 and len(tail) == 80 and \
               all(k.startswith("r") for k, _, _ in tail) and \
               len({a for _, a, _ in tail}) <= 2:
                reason = f"spinning at PC=0x{pc:08X} polling I/O 0x{tail[-1][1]:08X}"
                break
    except NotImplementedError as e:
        reason = str(e)
    except Exception as e:
        reason = f"{type(e).__name__}: {e}"

    print(f"executed {sim.steps} instructions; stopped: {reason}")
    print(f"final PC={sim.pc:08X} SP={sim.sp:08X} "
          f"D={[hex(x) for x in sim.d]} A={[hex(x) for x in sim.a]}")
    ios = mem.io_log
    print(f"\n{len(ios)} I/O accesses. First 40:")
    for k, a, v in ios[:40]:
        print(f"  {k:5s} 0x{a:08X}" + (f" = 0x{v:X}" if v is not None else ""))
    # distinct I/O addresses touched (incl. register-indirect)
    seen = {}
    for k, a, v in ios:
        seen.setdefault(a, k)
    print(f"\ndistinct I/O addresses touched at runtime: {len(seen)}")

    if sim.hle:
        lc = sim.lib_calls
        from collections import Counter
        distinct = Counter(t for t, *_ in lc)
        print(f"\n{len(lc)} library-ROM calls HLE-stubbed "
              f"({len(distinct)} distinct entry points). First 30 in order:")
        for t, d0, d1, a0, a1, ret in lc[:30]:
            print(f"  0x{t:08X}  (d0=0x{d0:X} d1=0x{d1:X} a0=0x{a0:X} a1=0x{a1:X}) "
                  f"from 0x{ret - 6:08X}")


if __name__ == "__main__":
    main()
