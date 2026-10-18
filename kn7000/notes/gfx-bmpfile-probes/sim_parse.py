#!/usr/bin/env python3
# Runs the real ROM code of GetBitmapInfo (0x48421DE1) and BmpUnpackRow
# (0x48422016) on test inputs in tools/mn10300_sim.py, to check what the
# annotations claim: outputs, return values, bit/nibble order, and the
# colour-table copy length. Library calls (memcpy 0x4C003039, LibStrncmp
# 0x4C00203C, LibDiv32 0x4C0019D5) and Malloc_entry/Free_entry are modelled in
# Python (high-level emulation); everything else is the ROM's own instructions.
# usage (from the kn7000_disassembly root): python3 sim_parse.py
import struct, sys
sys.path.insert(0, "tools")
import mn10300_sim as S

RET = 0x48400000          # sentinel return address: stop when pc reaches it
HEAP = 0x50800000
M32 = 0xFFFFFFFF

class Sim(S.Sim):
    def __init__(self, mem):
        super().__init__(mem)
        self.heap = HEAP
        self.log = []
    def _hle(self, target):
        d, a, m = self.d, self.a, self.m
        if target == 0x4C003039:                      # memcpy(a0 dest, a1 src, d0 n)
            n = d[0] if d[0] < 0x80000000 else 0
            self.log.append(("memcpy", a[0], a[1], d[0]))
            for i in range(n):
                m.w(a[0] + i, 1, m.r(a[1] + i, 1))
        elif target == 0x4C00203C:                    # LibStrncmp, as in the lib ROM
            s1, s2, n = a[0], a[1], d[0]
            r = 0
            for i in range(n):
                c1, c2 = m.r(s1 + i, 1), m.r(s2 + i, 1)
                if c1 != c2: r = (c1 - c2) & M32; break
                if c1 == 0: break
            d[0] = r
        elif target == 0x4C0019D5:                    # LibDiv32: signed d0 / d1
            x = d[0] - (1 << 32) if d[0] & 0x80000000 else d[0]
            y = d[1] - (1 << 32) if d[1] & 0x80000000 else d[1]
            q = abs(x) // abs(y) * (1 if (x < 0) == (y < 0) else -1)
            d[0] = q & M32
        elif target == 0x4841662A:                    # Malloc_entry(d0 = size) -> a0
            self.log.append(("malloc", d[0]))
            a[0] = self.heap; self.heap += (d[0] + 15) & ~15 & 0xFFFFF
        elif target == 0x484166DE:                    # Free_entry(a0)
            self.log.append(("free", a[0]))
        else:
            return False
        return True
    REGS = ((0x80, 2, "d"), (0x40, 3, "d"), (0x20, 2, "a"), (0x10, 3, "a"))
    def _call(self, target, retpc, regs, adj):
        if self._hle(target):
            self.pc = retpc
            return
        # real MN10300 call: return address at (sp), registers below it,
        # sp -= imm8 (the imm8 frame includes the saved registers)
        self.m.w(self.sp, 4, retpc)
        self.mdr = retpc
        t = self.sp
        for bit, n, k in self.REGS:
            if regs & bit:
                t -= 4
                self.m.w(t, 4, (self.d if k == "d" else self.a)[n])
        self.sp = (self.sp - adj) & M32
        self.pc = target
    def step(self):
        # tools/mn10300_sim.py returns from a cd/dd call to pc+4/pc+6 (onto the
        # call's own frame byte) and keeps the return address and saved
        # registers outside the call's imm8 frame, which does not match the
        # movm + add prologues. Model call/ret/retf the way the CPU does.
        pc = self.pc
        op = self.r8(pc)
        if op == 0xCD:
            disp = self.sx16(self.r16(pc + 1)); regs = self.r8(pc + 3); adj = self.r8(pc + 4)
            self._call((pc + disp) & M32, (pc + 5) & M32, regs, adj)
        elif op == 0xDD:
            disp = self.r32(pc + 1); regs = self.r8(pc + 5); adj = self.r8(pc + 6)
            self._call((pc + disp) & M32, (pc + 7) & M32, regs, adj)
        elif op in (0xDE, 0xDF):
            regs = self.r8(pc + 1); adj = self.r8(pc + 2)
            self.sp = (self.sp + adj) & M32
            t = self.sp
            for bit, n, k in self.REGS:
                if regs & bit:
                    t -= 4
                    (self.d if k == "d" else self.a)[n] = self.m.r(t, 4)
            self.pc = self.m.r(self.sp, 4) if op == 0xDF else self.mdr
        else:
            super().step()
            return
        self.steps += 1

def run(sim, pc, steps=200000):
    sim.m.w(sim.sp, 4, RET)       # as a calls would leave it: return address at (sp)
    sim.pc = pc
    while sim.pc != RET:
        sim.step()
        steps -= 1
        assert steps > 0, "step cap"

def new():
    mem = S.Mem(open("baserom/kn7000_program.rom", "rb").read(),
                open("baserom/kn7000_table.rom", "rb").read())
    sim = Sim(mem)
    sim.sp = 0x50700000
    return mem, sim

def put(mem, addr, b):
    for i, x in enumerate(b): mem.w(addr + i, 1, x)
def get(mem, addr, n):
    return bytes(mem.r(addr + i, 1) for i in range(n))

def bmp(magic=b"BM", bisize=40, planes=1, bpp=8, comp=0, clrused=0, offbits=None,
        ncolours=4, w=4, h=2):
    pal = bytes(i % 0xE0 for i in range(ncolours * 4))
    if offbits is None: offbits = 54 + len(pal)
    ih = struct.pack("<IiiHHIIiiII", bisize, w, h, planes, bpp, comp, 0, 0, 0, clrused, 0)
    pix = bytes(0x80 + i for i in range(64))
    fh = magic + struct.pack("<IHHI", 54 + len(pal) + len(pix), 0x1111, 0x2222, offbits)
    return fh + ih + pal + pix

def get_bitmap_info(img):
    mem, sim = new()
    IMG, FH, IH, PAL, PIX = 0x50100000, 0x50200000, 0x50200100, 0x50200200, 0x50200800
    put(mem, IMG, img)
    for base, n in ((FH, 16), (IH, 40), (PAL, 0x500), (PIX, 4)):
        put(mem, base, b"\xEE" * n)
    sim.a[0], sim.a[1], sim.d[0], sim.d[1] = IMG, FH, IH, PAL
    # 5th argument: the caller's (0x18,sp); the callee reads it as (0x3c,sp)
    # after its 0x24-byte frame
    sim.m.w(sim.sp + 0x18, 4, PIX)
    run(sim, 0x48421DE1)
    pal = get(mem, PAL, 0x500)
    ncopied = next((i for i in range(0x500) if pal[i] == 0xEE), 0x500)
    pix = struct.unpack("<I", get(mem, PIX, 4))[0]
    return sim.d[0], get(mem, FH, 16), get(mem, IH, 40), ncopied, pix - IMG if pix != 0xEEEEEEEE else None, sim.log

def unpack(row, count, bpp, rowlen):
    mem, sim = new()
    ROW = 0x50100000
    put(mem, ROW, row + b"\xEE" * (rowlen - len(row)))
    sim.a[0], sim.d[0], sim.d[1] = ROW, count, bpp
    run(sim, 0x48422016)
    return get(mem, ROW, rowlen), sim.log

if __name__ == "__main__":
    print("GetBitmapInfo  (d0, file-header struct, ncopied colour bytes, pixel offset)")
    cases = [
        ("good 8bpp, 4 colours", bmp()),
        ("bad magic 'BA'", bmp(magic=b"BA")),
        ("magic NUL 'B\\0'", bmp(magic=b"B\0")),
        ("magic '\\0\\0'", bmp(magic=b"\0\0")),
        ("biSize 12", bmp(bisize=12)),
        ("planes 2", bmp(planes=2)),
        ("bpp 2", bmp(bpp=2)),
        ("bpp 24", bmp(bpp=24)),
        ("bpp 4", bmp(bpp=4)),
        ("bpp 1", bmp(bpp=1)),
        ("clrused 256", bmp(clrused=256)),
        ("clrused 257", bmp(clrused=257)),
        ("compression 1", bmp(comp=1)),
        ("offbits 54 (no palette)", bmp(offbits=54)),
        ("offbits 54+0x400", bmp(offbits=54 + 0x400, ncolours=256)),
        ("offbits 54+0x404", bmp(offbits=54 + 0x404, ncolours=256)),
        ("offbits 50 (< 54)", bmp(offbits=50)),
        ("offbits 54+0x8000", bmp(offbits=54 + 0x8000)),
        ("offbits 54+0x10000+8", bmp(offbits=54 + 0x10008)),
        ("height -2 (top-down)", bmp(h=-2)),
        ("width 0", bmp(w=0)),
    ]
    for name, img in cases:
        r, fh, ih, n, pix, log = get_bitmap_info(img)
        ihs = "copied" if ih[:4] != b"\xEE" * 4 else "untouched"
        print(f"  {name:26s} d0={r} fh={fh.hex()} info {ihs:9s} colours={n:#x} pix={pix if pix is None else hex(pix)}")
    print("\nBmpUnpackRow")
    for bpp, row, count, rowlen in ((8, b"\x12\x34", 2, 4), (4, b"\x12\x34\x56\x78", 2, 8),
                                    (1, b"\xA5\x81", 2, 16), (2, b"\x12", 1, 4), (0x104, b"\x12\x34", 2, 8),
                                    (4, b"\x12", 0, 4)):
        out, log = unpack(row, count, bpp, rowlen)
        print(f"  bpp={bpp:#x} count={count} in={row.hex()} -> {out.hex()}  {log}")
