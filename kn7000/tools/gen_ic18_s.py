#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/ic18/boot.s, the complete byte-exact source of the KN7000's boot
# ROM: the first 64 KB of IC18 (C3CBND000046), which the CPU sees at 0x40000000
# from reset. notes/ic18-boot-rom.md describes the program; this is how the
# source is made from the image.
#
# The image has five parts, read off its own reset code (`layout()` checks every
# constant it relies on):
#
#   0x0000-0x03FF  ROM at 0x40000000: the reset and NMI vectors, then the bytes of
#                  an older link of this ROM that the new one did not overwrite
#   0x0400-0x0593  the initialised-data IMAGE, copied by the reset code to
#                  0x50010000 (its run address; the code names those addresses)
#   0x0594-0x0AFF  ROM: the reset code and the NMI handler, run in place
#   0x0B00-0xFA0B  the program IMAGE, copied to work RAM at 0x50000010 by the
#                  reset code and run there: code, then its constant data
#   0xFA0C-0xFFFF  ROM: the 12-byte descriptor of that copy, then erased (0xFF)
#
# Every byte becomes source; nothing is .incbin'd:
#
#   * code: recursive descent from the reset vector, the NMI vector, the two
#     interrupt thunks the reset code builds in work RAM, the program's main,
#     the indirect-jump tables (compiled `switch` statements: a bounds check,
#     then `mov TABLE, a0 ; mov (d0, a0), a0 ; jmp (a0)`; and three hashed
#     {key, handler} tables searched by a loop) and the tables of routine
#     pointers called through `calls (a0)`; then every gap left in a code range
#     decoded as unreferenced code, iterated until none is left. Mnemonics come
#     from MAME's unidasm and are kept only if tools/mn10300_asm.py re-encodes the
#     exact bytes (a long form the assembler would not choose gets a `:32` or
#     `:16` width suffix);
#   * data: text is .ascii/.asciz, pointer words .long <label>, the 8x16 font a
#     .byte row per glyph line, everything else typed by the width the code
#     reads it with, else bytes;
#   * addresses: every code and data address an operand names is a label; RAM
#     outside the image (.bss, the stack) and the hardware registers are .equ.
#
# Names come from kn7000_ic18.sym (`0xADDR NAME ; header comment`), then from
# the firmware (PROGRAM 941) for a routine byte-identical to a named one of it,
# then Str_<text> for strings, then func_/loc_/<area>_<ADDR>.
#
# Usage:
#   gen_ic18_s.py --rom baserom/kn7000_ic18_boot.bin --out src/ic18/boot.s
#                 [--names kn7000_ic18.sym] [--fw-rom P.rom --fw-r1-end N
#                 --fw-lib-file N --fw-sym S.sym ...] [--report]
import argparse
import collections
import difflib
import hashlib
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as ASM          # noqa: E402

ROM = 0x40000000
INSN = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")
COND_B = {"beq", "bne", "bgt", "bge", "ble", "blt", "bhi", "bcc", "bcs", "bls",
          "bnc", "bns", "bvc", "bvs"}
LOOP = {"leq", "lne", "lgt", "lge", "lle", "llt", "lhi", "lcc", "lcs", "lls", "lra"}
RETS = {"ret", "retf", "rets", "rti"}
XFER = {"bra", "jmp", "call", "calls"} | COND_B
WIDTH = {"movbu": 1, "movhu": 2, "mov": 4}
REGS = {"d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3", "sp", "mdr", "psw"}


def u32(d, o):
    return struct.unpack_from("<I", d, o)[0]


def first_target(ops):
    m = re.match(r"0x([0-9a-f]+)", ops)
    return int(m.group(1), 16) if m else None


def printable(c):
    return 0x20 <= c < 0x7F or c in (9, 10, 13)


class Image:
    """The 64 KB and its address spaces."""

    def __init__(self, path):
        self.path = path
        self.d = open(path, "rb").read()
        if len(self.d) != 0x10000:
            sys.exit(f"gen_ic18_s: {path}: expected 65536 bytes, got {len(self.d)}")
        # the copy descriptor the reset code reads (count at +2, source at +4,
        # destination at +8, which it moves to the uncached view, +0x40000000)
        self.desc = 0xFA0C
        cnt = struct.unpack_from("<H", self.d, self.desc + 2)[0]
        src, dst = struct.unpack_from("<II", self.d, self.desc + 4)
        self.img0, self.img1, self.img_run = src - ROM, src - ROM + cnt, dst
        if (self.img0, self.img1, self.img_run) != (0xB00, 0xFA0C, 0x50000010):
            sys.exit("gen_ic18_s: the copy descriptor at 0xFA0C is not the expected one")
        # .data: 0x194 bytes from 0x40000400 to 0x50010000 (checked in layout())
        self.dat0, self.dat1, self.dat_run = 0x400, 0x594, 0x50010000

    def space(self, o):
        if self.img0 <= o < self.img1:
            return "img"
        if self.dat0 <= o < self.dat1:
            return "data"
        return "rom"

    def cpu(self, o):
        s = self.space(o)
        if s == "img":
            return self.img_run + o - self.img0
        if s == "data":
            return self.dat_run + o - self.dat0
        return ROM + o

    def file(self, cpu):
        """file offset of a CPU address (run addresses for the two images), or None."""
        if self.img_run <= cpu < self.img_run + self.img1 - self.img0:
            return cpu - self.img_run + self.img0
        if self.dat_run <= cpu < self.dat_run + self.dat1 - self.dat0:
            return cpu - self.dat_run + self.dat0
        o = cpu - ROM
        if 0 <= o < len(self.d) and self.space(o) == "rom":
            return o
        return None

    def region_end(self, o):
        s = self.space(o)
        if s == "img":
            return self.img1
        if s == "data":
            return self.dat1
        return self.dat0 if o < self.dat0 else (self.img0 if o < self.img0 else len(self.d))


class Decoder:
    """pc -> (bytes, mnemonic, operands), decoding with unidasm on demand at the
    pc's own run address. Two unidasm quirks are corrected as in gen_cnv_s: F4
    (register-indexed movbu) is 2 bytes, and FA 9x stores print no register."""

    def __init__(self, unidasm, im):
        self.u, self.im, self.c = unidasm, im, {}

    def at(self, pc):
        if pc not in self.c:
            im = self.im
            o = im.file(pc)
            if o is None:
                raise KeyError(f"0x{pc:08X} is outside the image")
            n = min(0x400, im.region_end(o) - o)
            out = subprocess.run([self.u, im.path, "-arch", "mn10300", "-basepc", hex(pc),
                                  "-skip", hex(o), "-count", str(n)],
                                 capture_output=True, text=True, check=True).stdout
            lines = [m for m in map(INSN.match, out.splitlines()) if m]
            if len(lines) > 1 and n == 0x400:
                lines = lines[:-1]                 # the last may be cut by -count
            for m in lines:
                a = int(m.group(1), 16)
                b = bytes.fromhex(m.group(2).replace(" ", ""))
                mn, ops = m.group(3), m.group(4).strip()
                fo = im.file(a)
                if b == b"\xf4":
                    b = im.d[fo:fo + 2]
                if len(b) == 4 and b[0] == 0xFA and 0x90 <= b[1] <= 0x9F:
                    op = b[1] & 3
                    mn = ("mov", "mov", "movbu", "movhu")[op]
                    ops = re.sub(r"^d\d+", f"{'a' if op == 0 else 'd'}{(b[1] >> 2) & 3}", ops)
                if fo + len(b) > im.region_end(fo):
                    break                          # runs past its region: not an instruction here
                self.c.setdefault(a, (b, mn, ops))
            if pc not in self.c:
                self.c[pc] = (im.d[o:o + 1], "?", "")
        return self.c[pc]


# The program's indirect transfers (run addresses of the `jmp (a0)` / `calls
# (a0)`), each checked against the instructions that set a0 up:
#   switch: TABLE of COUNT case addresses, indexed by the switch value minus its
#           lowest case (the bounds check before it gives both)
#   hash:   {key, handler} records from TABLE to END, searched from (key & 15)
#           with wrap-around; key 0 ends the search
#   ptrs:   TABLE of COUNT routine pointers, called with `calls (a0)`
#   var:    a routine pointer held in the word at ADDR (its initial value is
#           the only one the program stores: see find_code())
#   ext:    a jump out of this ROM
INDIRECT = {
    0x500002A0: ("switch", 0x5000C538, 0x78 - 0x45 + 1),   # cmp 0x45 / cmp 0x78
    0x5000066B: ("hash", 0x5000C608, 0x5000C688),
    0x500031AB: ("ptrs", 0x5000C794, 11),                  # 11 pointers, then a .bss address
    0x500031FA: ("ptrs", 0x5000C794, 11),
    0x50006B1E: ("switch", 0x5000C890, 0x4E - 0x40 + 1),   # cmp 0x40 / cmp 0x4e
    0x50007131: ("switch", 0x5000C8CC, 0x4E - 0x41 + 1),   # cmp 0x41 / cmp 0x4e
    0x5000842F: ("ptrs", 0x500100F0, 32),                  # one per interrupt group
    0x50008BE9: ("ext", 0x48400000),
    0x50008C78: ("var", 0x5000DF50),
    0x50009820: ("switch", 0x5000CD70, 0x0C - 0x00 + 1),   # cmp 0 / cmp 0xc
    0x500098F3: ("hash", 0x5000CDA4, 0x5000CE24),
    0x50009A15: ("hash", 0x5000CE24, 0x5000CEA4),
    0x4000000F: ("ext", 0x50000006),                       # the NMI thunk the reset code builds
}

ENTRY_RESET = 0x40000000
FW_MIN = 5          # instructions a routine needs before its body is compared with the firmware's
ENTRY_NMI = 0x40000008

# The bytes of an older link that the new one did not overwrite (file offsets):
# code that ran in ROM (its reset code from 0x64, then routines up to where the
# new .data image starts), and between them the older link's .data image.
STALE_CODE = [(0x11, 0x2F), (0x64, 0x400)]
STALE_DATA = (0x2F, 0x64)


class Program:
    def __init__(self, im, unidasm):
        self.im = im
        self.dec = Decoder(unidasm, im)
        self.stale_cut = set()
        self.layout()
        self.find_code()

    # ---- the reset code's constants -------------------------------------------
    def expect(self, pc, mn, ops):
        _b, m, o = self.dec.at(pc)
        if (m, o) != (mn, ops):
            sys.exit(f"gen_ic18_s: expected `{mn} {ops}` at 0x{pc:08X}, found `{m} {o}`")

    def thunk_target(self, pc):
        """The reset code's thunk builder: mov 0x0000dccb, d0 (nop; jmp d32),
        then mov TARGET, d0; mov THUNK+1, d1; sub d1, d0 -- returns TARGET."""
        self.expect(pc, "mov", "0x0000dccb, d0")
        _b, _m, o = self.dec.at(pc + 10)
        return int(o.split(",")[0], 16)

    def layout(self):
        self.expect(0x40000000, "jmp", "0x40000594")
        self.reset = 0x40000594
        self.expect(0x40000728, "mov", "0x4000fa0c, a2")      # the copy descriptor
        self.expect(0x4000086A, "mov", "0x194, d1")            # .data: size, source, run address
        self.expect(0x40000871, "mov", "0x40000400, a0")
        self.expect(0x40000877, "mov", "0x50010000, a1")
        self.expect(0x400007E3, "mov", "0x0001bc0c, d1")       # .bss: size, start
        self.expect(0x400007ED, "mov", "0x50010194, a0")
        self.bss, self.bss_n = 0x50010194, 0x1BC0C
        self.irq_handler = self.thunk_target(0x4000093F)
        self.nmi_handler = self.thunk_target(0x40000967)
        self.expect(0x40000989, "mov", "0x50012468, a0")       # the stack top
        self.stack_top = 0x50012468
        _b, m, o = self.dec.at(0x40000A20)
        assert m == "jmp"
        self.main = first_target(o)

    # ---- code -------------------------------------------------------------------
    def check_indirect(self, site, kind, arg):
        if kind in ("switch", "ptrs"):
            self.expect(site - 8, "mov", f"0x{arg[0]:08x}, a0")
            self.expect(site - 2, "mov", "(d0, a0), a0")
        elif kind == "var":
            self.expect(site - 6, "mov", f"(0x{arg[0]:08x}), a0")
        elif kind == "hash":
            self.expect(site - 3, "mov", "(4, a0), a0")

    def indirect_targets(self, site):
        kind, *arg = INDIRECT[site]
        im = self.im
        self.check_indirect(site, kind, arg)
        if kind in ("switch", "ptrs"):
            o = im.file(arg[0])
            return kind, [u32(im.d, o + 4 * i) for i in range(arg[1])]
        if kind == "hash":
            o0, o1 = im.file(arg[0]), im.file(arg[1])
            return kind, [u32(im.d, o + 4) for o in range(o0, o1, 8)]
        if kind == "var":
            return kind, [u32(im.d, im.file(arg[0]))]
        return kind, []

    def discover(self, entries, stale=False):
        """Recursive descent. Returns ({pc: insn}, call targets, branch targets).
        In the old link's bytes (stale=True) every target outside them is the
        old link's address, not this image's."""
        code, calls, branches, work = {}, set(), set(), list(entries)
        dec, im = self.dec, self.im
        if stale:
            class Old:
                d = im.d

                def file(self, cpu):
                    o = cpu - ROM
                    return o if any(a <= o < b for a, b in STALE_CODE) else None
            im = Old()
        while work:
            pc = work.pop()
            while pc not in code:
                if stale and im.file(pc) is None:
                    self.stale_cut.add(pc)           # the old code ran on past what survives
                    break
                b, mn, ops = dec.at(pc)
                if mn == "?" or mn.startswith("udf"):
                    sys.exit(f"gen_ic18_s: undecodable byte at 0x{pc:08X} ({b.hex()}) on a code path")
                code[pc] = (b, mn, ops)
                t = first_target(ops)
                if mn in ("bra", "jmp", "call", "calls") and t is None:
                    if pc not in INDIRECT:
                        sys.exit(f"gen_ic18_s: indirect {mn} at 0x{pc:08X} is not in INDIRECT")
                    kind, ts = self.indirect_targets(pc)
                    ts = [x for x in ts if im.file(x) is not None]
                    (calls if kind in ("ptrs", "var") else branches).update(ts)
                    work += ts
                    if mn == "jmp":
                        break
                    pc += len(b)
                    continue
                if t is not None and mn in XFER and im.file(t) is None:
                    if mn in ("bra", "jmp"):         # out of the image
                        break
                    pc += len(b)
                    continue
                if mn in ("bra", "jmp"):
                    branches.add(t)
                    work.append(t)
                    break
                if mn in RETS:
                    break
                if mn in ("call", "calls"):
                    calls.add(t)
                    work.append(t)
                elif mn in COND_B:
                    branches.add(t)
                    work.append(t)
                pc += len(b)
        return code, calls, branches

    def data_refs(self, code):
        refs = collections.Counter()
        for _pc, (_b, mn, ops) in code.items():
            if mn in XFER:
                continue
            for h in re.findall(r"0x([0-9a-f]{5,8})", ops):
                refs[int(h, 16)] += 1
        return refs

    def fill_gaps(self, entries, ranges, stale=False):
        """Descent from `entries`, then every gap in `ranges` (file offsets)
        decoded as unreferenced code, until none is left."""
        im = self.im
        dead = []
        while True:
            code, calls, branches = self.discover(entries + dead, stale)
            cov = set()
            for pc, (b, _m, _o) in code.items():
                o = im.file(pc) if not stale else pc - ROM
                cov.update(range(o, o + len(b)))
            gaps = [im.cpu(o) for a, b in ranges for o in range(a, b)
                    if o not in cov and (o == a or o - 1 in cov) and im.cpu(o) not in dead]
            if not gaps:
                break
            dead += gaps
        for a, b in ranges:
            if any(o not in cov for o in range(a, b)):
                sys.exit(f"gen_ic18_s: code range 0x{a:05X}-0x{b:05X} is not all code")
        return code, calls, branches, dead

    def find_code(self):
        im = self.im
        self.entries = [ENTRY_RESET, self.reset, ENTRY_NMI, self.irq_handler, self.nmi_handler, self.main]
        code, _c, _b = self.discover(self.entries)
        # the program image's code ends where its constant data starts: the
        # lowest image address that the code, or a pointer word after the code,
        # names above the last reached instruction (it is newlib's ctype table,
        # named only by the word that points to it)
        hi = max(im.file(pc) + len(b) for pc, (b, _m, _o) in code.items() if im.space(im.file(pc)) == "img")
        names = set(self.data_refs(code))
        names |= {u32(im.d, o) for o in range(hi + (-hi) % 4, im.img1, 4)}
        self.rodata0 = min(im.file(v) for v in names
                           if im.file(v) is not None and im.space(im.file(v)) == "img"
                           and im.file(v) >= hi)
        pad0 = self.rodata0
        while im.d[pad0 - 1] == 0 and self.rodata0 - pad0 < 3:
            pad0 -= 1
        self.pad0 = pad0
        # (the five `nop`s between the reset vector's jmp and the NMI vector pad
        # it to its fixed place, +8)
        self.code_ranges = [(0x03, 0x08), (0x594, im.img0), (im.img0, pad0)]
        code, calls, branches, dead = self.fill_gaps(self.entries, self.code_ranges)
        # the old link's code
        scode, scalls, sbranches, sdead = self.fill_gaps([ROM + a for a, _b in STALE_CODE],
                                                          STALE_CODE, stale=True)
        self.stale = set(scode)
        code.update(scode)
        self.code, self.calls, self.branches = code, calls | scalls, branches | sbranches
        self.dead = dead + sdead
        self.starts = set(code)
        # A routine compiled with a prologue (movm [regs], (sp) / add -N, sp) is
        # entered by `call` just past it -- the call instruction saves the
        # registers and allocates the frame itself -- and by `calls` at the
        # prologue. The prologue then has no reference of its own.
        self.entry_of = {}
        call_t = {first_target(o) for _pc, (_b, m, o) in code.items() if m == "call"}
        for p in self.dead:
            pc, seen = p, []
            while pc in code and code[pc][1] in ("movm", "add") and len(seen) < 2:
                b, m, o = code[pc]
                if m == "movm" and not o.endswith("(sp)"):
                    break
                if m == "add" and not o.endswith(", sp"):
                    break
                seen.append(m)
                pc += len(b)
            if seen and pc in call_t:
                self.entry_of[p] = pc
        self.dead = [p for p in self.dead if p not in self.entry_of]


# ---- names ----------------------------------------------------------------------

# On-chip registers of the MN103002A and the board's devices, as named by MAME's
# mn10300 core and the repo's earlier work (tools/cnv_romdump, kn7000_manual.sym)
HW = {
    0x20000000: ("IVAR0", "low 16 bits of the level-0 interrupt entry"),
    0x20000004: ("IVAR1", ""), 0x20000008: ("IVAR2", ""), 0x2000000C: ("IVAR3", ""),
    0x20000010: ("IVAR4", ""), 0x20000014: ("IVAR5", ""), 0x20000018: ("IVAR6", ""),
    0x20000070: ("CHCTR", "cache control: bits 0/1 enable I/D, 2/3 busy, 4/5 invalidate"),
    0x28400000: ("DCACHE_WAY0", "reading 0x80 lines of 16 bytes here flushes one data-cache way"),
    0x28401000: ("DCACHE_WAY1", "the other way"),
    0x32000020: ("MEMCTR0", "memory controller (chip-select timing), 0..7"),
    0x32000022: ("MEMCTR1", ""), 0x32000024: ("MEMCTR2", ""), 0x32000026: ("MEMCTR3", ""),
    0x32000028: ("MEMCTR4", ""), 0x3200002A: ("MEMCTR5", ""), 0x3200002C: ("MEMCTR6", ""),
    0x3200002E: ("MEMCTR7", ""),
    0x32000800: ("DMAC0_CTR", "DMA channel 0: control/start"),
    0x32000804: ("DMAC0_SRC", "DMA channel 0: source address"),
    0x32000808: ("DMAC0_DST", "DMA channel 0: destination address"),
    0x3200080C: ("DMAC0_CNT", "DMA channel 0: byte count"),
    0x34000100: ("IAGR", "interrupt accepted group"),
    0x34000200: ("INTC_GROUP_VECTOR", "read by the dispatcher as a byte offset into the handler table"),
    0x34000280: ("EXTMD", "external interrupt pin modes, 2 bits per pin"),
    0x34000800: ("SC0CTR", "serial 0: configuration"), 0x34000804: ("SC0ICR", "serial 0: control"),
    0x34000808: ("SC0TXB", "serial 0: transmit byte"), 0x34000809: ("SC0RXB", "serial 0: receive byte"),
    0x3400080C: ("SC0STR", "serial 0: status"),
    0x34000810: ("SC1CTR", "serial 1: configuration"), 0x34000814: ("SC1ICR", "serial 1: control"),
    0x34000818: ("SC1TXB", "serial 1: transmit byte"), 0x34000819: ("SC1RXB", "serial 1: receive byte"),
    0x3400081C: ("SC1STR", "serial 1: status"),
    0x34000820: ("SC2CTR", "serial 2: configuration"), 0x34000824: ("SC2ICR", "serial 2: control"),
    0x34000828: ("SC2TXB", "serial 2: transmit byte"), 0x34000829: ("SC2RXB", "serial 2: receive byte"),
    0x3400082C: ("SC2STR", "serial 2: status"),
    0x34001080: ("TM4MD", "timer 4 mode"), 0x34001082: ("TM5MD", "timer 5 mode"),
    0x34001090: ("TM4BR", "timer 4 base (reload) value"), 0x34001092: ("TM5BR", "timer 5 base value"),
    0x340010A0: ("TM4BC", "timer 4 count"), 0x340010A2: ("TM5BC", "timer 5 count"),
    0x98070000: ("BOARD_STRAP", "board-revision strap, read only"),
    0x36008004: ("P04", "I/O port at 0x36008004: bit 5 strobed all through the boot, bit 1 SD card select"),
    0x36008005: ("P05", "I/O port at 0x36008005"),
    0x36008024: ("P24", "I/O port at 0x36008024"),
    0x36008025: ("P25", "I/O port at 0x36008025"),
    0x36008044: ("P44", "I/O port at 0x36008044"),
    0x36008064: ("P64", "I/O port at 0x36008064"),
    0x36008065: ("P65", "I/O port at 0x36008065"),
    0x36008084: ("P84", "I/O port at 0x36008084"),
    0x48400000: ("FirmwareReset", "the program flash's reset entry: the KN7000 firmware"),
    # the two interrupt thunks Reset writes in work RAM (nop; jmp d32), through the
    # uncached view; a jmp's d32 counts from the jmp, one byte into its thunk
    0x50000000: ("IrqThunk", "the maskable interrupt enters here once CHCTR bit 7 is set"),
    0x50000001: ("IRQ_THUNK_JMP", "IrqThunk's jmp"),
    0x50000006: ("NmiThunk", "the second thunk (the ROM vector table has the NMI at +8)"),
    0x50000007: ("NMI_THUNK_JMP", "NmiThunk's jmp"),
    0x90000000: ("IRQ_THUNK_UNCACHED", "IrqThunk through the uncached view"),
    0x90000006: ("NMI_THUNK_UNCACHED", "NmiThunk through the uncached view"),
}
# ROM addresses of the two images' load copies and of the copy descriptor
LOAD_NAMES = {0x40000400: "__data_load", 0x40000B00: "__image_load", 0x4000FA0C: "ImageCopyDescriptor"}
for _g in range(2, 31):
    HW.setdefault(0x34000100 + 4 * _g, (f"G{_g}ICR", f"interrupt group {_g} control" if _g == 2 else ""))


def norm_body(insns, start, callee=lambda t: "C"):
    """The instructions of a routine from `start` to its first return, with the
    addresses masked: absolute operands become A, a branch inside the body its
    offset from the start, a call the callee's name if `callee` knows it, else C
    (with its register list and frame). Two routines with the same normalised
    body are the same source code linked at different addresses."""
    seq, pc, n = [], start, 0
    while pc in insns and n < 0x400:
        b, mn, ops = insns[pc]
        t = first_target(ops) if mn in XFER else None
        if mn in ("call", "calls"):
            seq.append((mn, callee(t) if t is not None else "C",
                        ops.split(",", 1)[1].strip() if "," in ops else ""))
        elif t is not None:
            seq.append((mn, "B", t - start))
        else:
            seq.append((mn, re.sub(r"0x[0-9a-f]{5,8}", "A", ops)))
        pc += len(b)
        n += len(b)
        if mn in RETS:
            break
    else:
        return None
    return tuple(seq)


def fw_index(unidasm, rom, base_pc, skip, count):
    """{pc: (bytes, mnemonic, operands)} from one linear unidasm pass of the firmware."""
    out = subprocess.run([unidasm, rom, "-arch", "mn10300", "-basepc", hex(base_pc),
                          "-skip", hex(skip), "-count", str(count)],
                         capture_output=True, text=True, check=True).stdout
    ix = {}
    for m in map(INSN.match, out.splitlines()):
        if m:
            ix[int(m.group(1), 16)] = (bytes.fromhex(m.group(2).replace(" ", "")), m.group(3), m.group(4).strip())
    return ix


def load_names(path):
    """{cpu: (name, note)} from `0xADDR NAME ; note` lines; `;` lines are comments."""
    out = {}
    if not path:
        return out
    for line in open(path):
        if line.lstrip().startswith(";") or not line.strip():
            continue
        m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)\s*(?:;\s*(.*))?$", line.rstrip("\n"))
        if not m:
            sys.exit(f"gen_ic18_s: {path}: bad line {line!r}")
        v = int(m.group(1), 16)
        if v in out:
            sys.exit(f"gen_ic18_s: {path}: 0x{v:08X} named twice")
        out[v] = (m.group(2), (m.group(3) or "").strip())
    return out


def esc(bs):
    return "".join({0x5C: "\\\\", 0x22: '\\"', 9: "\\t", 10: "\\n", 13: "\\r"}.get(c, chr(c))
                   if printable(c) else f"\\x{c:02X}" for c in bs)


def text_name(text):
    """Str_<CamelCase words of the text>, or None if it has too little text."""
    words = re.findall(r"[A-Za-z0-9]+", text)
    if sum(map(len, words)) < 3:
        return None
    out = ""
    for w in words:
        w = w[0].upper() + (w[1:].lower() if w.isupper() and len(w) > 3 else w[1:])
        if out and len(out) + len(w) > 40:
            break
        out += w
    return "Str_" + out


def wrap(text, width=96, prefix="# "):
    out, line = [], ""
    for w in text.split():
        if line and len(line) + 1 + len(w) > width - len(prefix):
            out.append(prefix + line)
            line = w
        else:
            line = f"{line} {w}" if line else w
    if line:
        out.append(prefix + line)
    return out


def covered(p):
    cov = set()
    for pc, (b, _m, _o) in p.code.items():
        o = p.im.file(pc)
        cov.update(range(o, o + len(b)))
    return cov


def report(p):
    im = p.im
    cov = covered(p)
    runs, cur = [], None
    for o in range(len(im.d)):
        c = o in cov
        if cur is None or cur[0] != c:
            cur = [c, o, o]
            runs.append(cur)
        cur[2] = o + 1
    for c, a, b in runs:
        print(f"{'CODE' if c else '----'} 0x{a:05X}-0x{b:05X} ({b - a:6d})  {im.space(a)}")
    print(f"{len(p.code)} insns, {len(cov)} code bytes, {len(p.calls)} calls, "
          f"{len(p.branches)} branch targets")


# ---- data -----------------------------------------------------------------------

class Data:
    """Labels, strings, pointer words and access widths in the data areas."""

    def __init__(self, p):
        self.p = p
        im = p.im
        self.areas = [STALE_DATA, (im.dat0, im.dat1), (p.rodata0, im.img1), (im.img1, len(im.d))]
        live = {pc: v for pc, v in p.code.items() if pc not in p.stale}
        self.live = live
        self.refs = p.data_refs(live)
        self.find_widths()
        self.find_tables()

    def in_area(self, o, stale_ok=False):
        return any(a <= o < b for a, b in self.areas[(0 if stale_ok else 1):])

    def valid_target(self, v):
        """An address a pointer word may name: a live instruction start, or a
        place in the live data areas."""
        p = self.p
        if v in p.starts:
            # code: a routine, a place `call` enters, or a branch target -- not
            # any instruction start, which a constant can hit by chance
            return v not in p.stale and (v in p.calls or v in p.branches or v in p.entry_of
                                         or v in p.dead or v in p.entries)
        o = p.im.file(v)
        return o is not None and self.in_area(o) and o < p.im.img1

    def find_widths(self):
        p, live = self.p, self.live
        widths = collections.defaultdict(set)
        for pc in sorted(live):
            _b, mn, ops = live[pc]
            m = re.search(r"\(0x([0-9a-f]{5,8})\)", ops)
            if m and mn in WIDTH:
                widths[int(m.group(1), 16)].add(WIDTH[mn])
        # `mov LABEL, rN` / `mov rN, rM`, then accesses through rN in the same run
        track, prev_end = {}, None
        targets = p.calls | p.branches
        for pc in sorted(live):
            b, mn, ops = live[pc]
            if pc != prev_end or pc in targets:
                track = {}
            prev_end = pc + len(b)
            o = ASM.split_ops(ops) if ops else []
            if mn in XFER or mn in LOOP or mn in RETS:
                track = {}
                continue
            for op in o:
                mm = re.fullmatch(r"\((?:(?:d[0-3]|0x[0-9a-f]+|\d+),\s*)?(a[0-3])\)", op)
                if mm and mm.group(1) in track and mn in WIDTH:
                    widths[track[mm.group(1)]].add(WIDTH[mn])
            dst = o[-1] if o else None
            if dst in REGS:
                src = o[0] if len(o) == 2 else None
                v = int(src, 16) if src and re.fullmatch(r"0x[0-9a-f]{5,8}", src) else None
                if mn == "mov" and v is not None and p.im.file(v) is not None:
                    track[dst] = v
                elif mn == "mov" and src in track:
                    track[dst] = track[src]
                else:
                    track.pop(dst, None)
        self.widths = widths

    def find_tables(self):
        p, im, d = self.p, self.p.im, self.p.im.d
        labels = {v for v in self.refs if im.file(v) is not None and self.in_area(im.file(v))}
        for site, (kind, *arg) in INDIRECT.items():
            if kind in ("switch", "ptrs", "hash", "var"):
                labels.add(arg[0])
        self.special = {}            # file offset -> (kind, length)
        for o0, o1, kind in SPECIAL_DATA:
            self.special[o0] = (kind, o1 - o0)
            labels.add(im.cpu(o0))
        base = set(labels)
        for _ in range(4):           # until the pointer targets stop changing the strings
            strings, pointers = self.scan(labels)
            new = base | set(pointers.values())
            if new == labels:
                break
            labels = new
        self.labels, self.strings, self.pointers = labels, strings, pointers

    def scan(self, labels):
        im, d = self.p.im, self.p.im.d
        strings, pointers = {}, {}
        for r0, r1 in self.areas[1:3]:
            o = r0
            lab_offs = sorted(x for x in range(r0, r1) if im.cpu(x) in labels) + [r1]
            while o < r1:
                if o in self.special:
                    o += self.special[o][1]
                    continue
                cpu = im.cpu(o)
                boundary = o == r0 or not printable(d[o - 1]) or cpu in labels
                lim = min([x for x in lab_offs if x > o] + [x for x in self.special if x > o] + [r1])
                n, nul = self.string_at(o, lim, cpu in labels) if boundary else (0, True)
                ptr = o % 4 == 0 and o + 4 <= r1 and self.valid_target(u32(d, o))
                if n and not ptr:
                    strings[o] = (n, nul)
                    o += n
                    continue
                if ptr:
                    pointers[o] = u32(d, o)
                    o += 4
                    continue
                o += 1
        return strings, pointers

    def string_at(self, o, lim, labelled):
        d = self.p.im.d
        e = o
        while e < lim and printable(d[e]):
            e += 1
        n = e - o
        if not n:
            return 0, True
        if e < lim and d[e] == 0:
            return (n + 1, True) if n >= 4 or (labelled and n >= 1) else (0, True)
        letters = sum(chr(c).isalpha() for c in d[o:e])
        if (n >= 6 and 2 * letters >= n) or (e == lim and (labelled or n >= 3)):
            return n, False
        return 0, True


# Data whose type the generic pass cannot see (file offsets): emitted by emit_special()
SPECIAL_DATA = []

# Operand constants of the reset code that are not addresses: (pc, value) -> name
OPERAND_NAMES = {
    (0x4000086A, 0x194): "DATA_SIZE",
    (0x400007E3, 0x1BC0C): "BSS_SIZE",
    (0x4000093F, 0xDCCB): "THUNK_NOP_JMP",
    (0x40000967, 0xDCCB): "THUNK_NOP_JMP",
    (0x4000076A, 0x40000000): "UNCACHED_VIEW",
    (0x400001E9, 0x40000000): "UNCACHED_VIEW",
}

BSS_END = 0x50010194 + 0x1BC0C


# ---- emission -------------------------------------------------------------------

class Emitter:
    def __init__(self, p, dat, a):
        self.p, self.dat, self.a = p, dat, a
        self.im = p.im
        self.name_all()

    # ---- routines and names ------------------------------------------------------
    def name_all(self):
        p, im, a = self.p, self.im, self.a
        live_dead = [x for x in p.dead if x not in p.stale and x != 0x40000003]
        stale_dead = [x for x in p.dead if x in p.stale]
        T = set(p.entry_of.values())
        funcs = (set(p.entries) | {c for c in p.calls if c in p.code and c not in p.stale}
                 | set(live_dead) | set(p.entry_of)) - T
        sfuncs = {ROM + a0 for a0, _b in STALE_CODE} | {c for c in p.calls if c in p.stale} | set(stale_dead)
        self.funcs = sorted(funcs | sfuncs)
        self.dead = set(live_dead) | set(stale_dead)
        self.T = T
        manual = load_names(a.names)
        names, notes = {}, {}
        self.names, self.notes = names, notes
        self.fwcall = {}
        for v, (nm, note) in manual.items():
            names[v] = nm
            if note:
                notes[v] = note
        fixed = {
            ENTRY_RESET: ("ResetVector", "the CPU starts here: on to the reset code"),
            ENTRY_NMI: ("NmiVector", "the nonmaskable interrupt's fixed entry, +8: through the work-RAM thunk "
                                     "the reset code builds at 0x50000006"),
            0x40000594: ("Reset", ""),
            p.main: ("BootMain", ""),
        }
        for v, (nm, note) in fixed.items():
            names.setdefault(v, nm)
            if note:
                notes.setdefault(v, note)
        # routines byte-identical (to their first return) to named firmware routines
        self.fwcopy, self.fwsame = {}, {}
        if a.fw_rom:
            import gen_xap_s
            fw = gen_xap_s.firmware_routines(a.fw_rom, a.fw_r1_end, a.fw_lib_file, a.fw_sym, a.unidasm)
            for f in self.funcs:
                if f in p.stale:
                    continue
                b = self.body(f)
                if b and b in fw:
                    self.fwcopy[f] = fw[b]
                    names.setdefault(f, fw[b])
            self.fwsame = self.firmware_same(a)
            for f, (nm, cpu) in self.fwsame.items():
                names.setdefault(f, nm)
            for f, (nm, cpu, parent) in self.fwcall.items():
                names.setdefault(f, nm)
        for f in self.funcs:
            names.setdefault(f, (f"Old_func_{f:08X}" if f in p.stale else f"func_{f:08X}"))
        for t, pp in ((t, pp) for pp, t in p.entry_of.items()):
            names.setdefault(t, names[pp] + "_entry")
        for t in sorted(p.branches):
            if t in p.code:
                names.setdefault(t, (f"old_loc_{t:08X}" if t in p.stale else f"loc_{t:08X}"))
        # data
        dat = self.dat
        str_cpu = {im.cpu(o): o for o in dat.strings}
        taken = set(names.values())
        for v in sorted(dat.labels):
            if v in names:
                continue
            o = im.file(v)
            if v in str_cpu:
                so = str_cpu[v]
                n, nul = dat.strings[so]
                nm = text_name(im.d[so:so + n - nul].decode("latin1")) or f"str_{v:08X}"
            elif im.space(o) == "data":
                nm = f"data_{v:08X}"
            else:
                nm = f"rodata_{v:08X}"
            base_nm, k = nm, 2
            while nm in taken:
                nm = f"{base_nm}_{k}"
                k += 1
            taken.add(nm)
            names[v] = nm
        self.names, self.notes = names, notes
        self.ext = {}            # externals: value -> (name, note)

    def firmware_same(self, a):
        """{routine: (firmware name, firmware address)} for the routines whose
        normalised body (norm_body) equals that of exactly one named routine of
        the firmware, and of no other routine here; at least 8 instructions."""
        import gen_table_s
        p = self.p
        rom = a.fw_rom
        d = open(rom, "rb").read()
        end = len(d.rstrip(b"\xff"))
        ix = fw_index(a.unidasm, rom, 0x48400080, 0x80, a.fw_r1_end - 0x80)
        ix.update(fw_index(a.unidasm, rom, 0x4C000000, a.fw_lib_file, end - a.fw_lib_file))
        fsyms = gen_table_s.load_syms(a.fw_sym)
        fwname = {}
        for cpu, (nm, _n) in fsyms.items():
            fwname[cpu] = nm[:-6] if nm.endswith("_entry") else nm
        named = {f: n for f, n in self.fwcopy.items()}         # mine -> firmware name
        live = {pc: v for pc, v in p.code.items() if pc not in p.stale}
        prologue = {t: pp for pp, t in p.entry_of.items()}
        out = {}
        # Callees are compared by name once both sides have one; each round may
        # name more routines, which may make more bodies comparable.
        for _round in range(10):
            new = 0
            for by_name in (True, False):
                fw = collections.defaultdict(set)
                for cpu, (nm, _n) in fsyms.items():
                    if nm.endswith("_entry"):
                        continue
                    s = norm_body(ix, cpu, (lambda t: fwname.get(t, "C")) if by_name else (lambda t: "C"))
                    if s and len(s) >= FW_MIN:
                        fw[s].add((nm, cpu))
                mine = collections.defaultdict(list)
                for f in self.funcs:
                    if f in p.stale or f in named:
                        continue
                    s = norm_body(live, f, (lambda t: named.get(prologue.get(t, t), "C"))
                                  if by_name else (lambda t: "C"))
                    if s and len(s) >= FW_MIN:
                        mine[s].append(f)
                taken = set(named.values())
                for s, fs in mine.items():
                    if len(fs) == 1 and len(fw.get(s, ())) == 1:
                        nm, cpu = next(iter(fw[s]))
                        if nm not in taken and fs[0] not in named:
                            out[fs[0]] = (nm, cpu)
                            named[fs[0]] = nm
                            taken.add(nm)
                            new += 1
            if not new:
                break
        self.fwcall = self.firmware_callees(ix, fsyms, fwname, named, out)
        return out

    def firmware_callees(self, ix, fsyms, fwname, named, same):
        """{routine: (firmware name, firmware address, caller)}: a routine called
        at the same place of a routine both programs have (same name) as a named
        firmware routine is called there. Only where the two callers make the same
        number of calls and every pair already named agrees; repeated until no
        new name appears."""
        p = self.p
        base_of = {}
        byname = {}
        for cpu, (nm, _n) in fsyms.items():
            if not nm.endswith("_entry"):
                byname[nm] = cpu
        for cpu, (nm, _n) in fsyms.items():
            base_of[cpu] = byname.get(fwname[cpu], cpu)
        fstarts = sorted(byname.values())
        prologue = {t: pp for pp, t in p.entry_of.items()}
        funcs = sorted(f for f in self.funcs if f not in p.stale)
        nxt = {f: (funcs[i + 1] if i + 1 < len(funcs) else f + 0x10000) for i, f in enumerate(funcs)}

        def my_calls(f):
            out, pc = [], f
            while pc in p.code and pc < nxt[f]:
                b, mn, ops = p.code[pc]
                if mn in ("call", "calls") and first_target(ops) is not None:
                    t = first_target(ops)
                    out.append(prologue.get(t, t))
                pc += len(b)
            return out

        def fw_calls(cpu):
            import bisect
            i = bisect.bisect_right(fstarts, cpu)
            stop = fstarts[i] if i < len(fstarts) else cpu + 0x4000
            out, pc = [], cpu
            while pc in ix and pc < stop:
                b, mn, ops = ix[pc]
                if mn in ("call", "calls") and first_target(ops) is not None:
                    t = first_target(ops)
                    out.append(base_of.get(t, t))
                pc += len(b)
            return out

        mine = dict(named)                          # routine -> firmware name
        for f, nm in self.names.items():
            if f in self.funcs and nm in byname:
                mine.setdefault(f, nm)
        result = {}
        for _round in range(10):
            cand = collections.defaultdict(set)
            for f, nm in list(mine.items()):
                if nm not in byname:
                    continue
                a, b = my_calls(f), fw_calls(byname[nm])
                if not a or not b:
                    continue
                # align the two call lists on the callees both sides have named;
                # an unnamed callee of ours facing a named one of the firmware's,
                # in a stretch of equal length (at most 3) between two agreeing
                # calls, takes its name
                ta = [mine.get(x, "?") for x in a]
                tb = [fwname.get(y, "?") for y in b]
                sm = difflib.SequenceMatcher(None, ta, tb, autojunk=False)
                for op, i1, i2, j1, j2 in sm.get_opcodes():
                    if op != "replace" or i2 - i1 != j2 - j1 or i2 - i1 > 3:
                        continue
                    for x, y, xn, yn in zip(a[i1:i2], b[j1:j2], ta[i1:i2], tb[j1:j2]):
                        if xn == "?" and yn != "?" and x in self.funcs:
                            cand[x].add((yn, y, nm))
            taken = set(mine.values())
            new = 0
            for x, cs in cand.items():
                names = {c[0] for c in cs}
                if len(names) == 1:
                    yn, y, parent = sorted(cs)[0]
                    if yn not in taken:
                        mine[x] = yn
                        result[x] = (yn, byname.get(yn, y), parent)
                        taken.add(yn)
                        new += 1
            if not new:
                break
        return result

    def body(self, f):
        """bytes of the routine at f up to and including its first return."""
        out, pc = b"", f
        while pc in self.p.code and len(out) <= 0x400:
            b, mn, _o = self.p.code[pc]
            out += b
            pc += len(b)
            if mn in RETS:
                return out
        return None

    # ---- operands -------------------------------------------------------------------
    def ext_name(self, v, stale):
        """The .equ name for an address outside the image, or None to keep it numeric."""
        if v in self.ext:
            return self.ext[v][0]
        manual = self.names.get(v)
        if v in HW:
            nm, note = HW[v]
        elif stale and (0x40000000 <= v < 0x60000000):
            nm, note = f"OldLink_{v:08X}", "an address of the older link"
        elif 0x50010194 <= v < BSS_END or self.im.img_run + self.im.img1 - self.im.img0 <= v < 0x50010000:
            nm, note = manual or f"bss_{v:08X}", self.notes.get(v, "")
        else:
            return None
        self.ext[v] = (nm, note)
        return nm

    def label_of(self, v, stale):
        """name for an operand address, or None."""
        im = self.im
        if stale:
            o = v - ROM
            if (v in self.p.code and v in self.p.stale) or (STALE_DATA[0] <= o < STALE_DATA[1]):
                return self.stale_label(v)
            return self.ext_name(v, True)
        if v in LOAD_NAMES:
            return LOAD_NAMES[v]
        o = im.file(v)
        if o is not None and (v in self.names) and (v in self.dat.labels or v in self.p.code):
            return self.names[v]
        if o is None:
            return self.ext_name(v, False)
        return None

    def stale_label(self, v):
        if v not in self.names:
            self.names[v] = f"old_data_{v:08X}"
        self.values.setdefault(self.names[v], v)
        self.stale_data_labels.add(v)
        return self.names[v]

    def symbolise(self, pc, mn, ops, stale):
        o = ASM.split_ops(ops) if ops else []
        if mn in XFER and o and first_target(o[0]) is not None:
            t = first_target(o[0])
            nm = self.names.get(t) if (t in self.p.code and (t in self.p.stale) == stale) else None
            nm = nm or self.label_of(t, stale)
            if nm is None:
                sys.exit(f"gen_ic18_s: no name for the target 0x{t:08X} of 0x{pc:08X}")
            o[0] = nm
        else:
            def rep(m):
                v = int(m.group(1), 16)
                if (pc, v) in OPERAND_NAMES:
                    return OPERAND_NAMES[(pc, v)]
                if len(m.group(1)) < 5:
                    return m.group(0)
                return self.label_of(v, stale) or m.group(0)
            o = [re.sub(r"\b0x([0-9a-f]+)\b", rep, x) for x in o]
        return o

    def value_of(self, tok):
        if tok in self.values:
            return self.values[tok]
        return None

    def resolve(self, ops):
        for a0, (nm, _n) in self.ext.items():
            self.values.setdefault(nm, a0)
        return re.sub(r"\b([A-Za-z_]\w*)\b",
                      lambda m: hex(self.values[m.group(1)])
                      if m.group(1) in self.values and m.group(1) not in REGS else m.group(0), ops)

    def insn_line(self, pc, b, mn, ops, stale):
        o = self.symbolise(pc, mn, ops, stale)
        sops = ", ".join(o)
        try:
            enc = ASM.encode(mn, self.resolve(sops), pc)
        except ASM.EncError as e:
            sys.exit(f"gen_ic18_s: cannot re-encode 0x{pc:08X} {mn} {sops}: {e}")
        if enc != b:
            # a longer form than the assembler would choose: force the width
            for k in range(len(o)):
                if o[k] in REGS or o[k].startswith(("(", "[")) or re.fullmatch(r"-?\d+", o[k] or "x") and mn in XFER:
                    continue
                for w in ("16", "32"):
                    t = list(o)
                    t[k] = f"{o[k]}:{w}"
                    try:
                        e2 = ASM.encode(mn, self.resolve(", ".join(t)), pc)
                    except ASM.EncError:
                        continue
                    if e2 == b:
                        o, enc = t, e2
                        self.nwide += 1
                        break
                if enc == b:
                    break
            sops = ", ".join(o)
        if enc != b:
            sys.exit(f"gen_ic18_s: 0x{pc:08X} {mn} {sops} re-encodes as {enc.hex()}, not {b.hex()}")
        return f"    {mn:8s}{sops}".rstrip()

    # ---- the source ---------------------------------------------------------------
    def build_values(self):
        v = {}
        for a, nm in self.names.items():
            v.setdefault(nm, a)
        for a, (nm, _n) in self.ext.items():
            v.setdefault(nm, a)
        v.update({"DATA_SIZE": 0x194, "BSS_SIZE": 0x1BC0C, "THUNK_NOP_JMP": 0xDCCB, "UNCACHED_VIEW": 0x40000000})
        v.update({nm: a for a, nm in LOAD_NAMES.items()})
        self.values = v

    def code_lines(self, o0, o1):
        p, im, names, notes = self.p, self.im, self.names, self.notes
        L = []
        funcs = set(self.funcs)
        o = o0
        while o < o1:
            pc = im.cpu(o)
            if pc not in p.code:
                sys.exit(f"gen_ic18_s: no instruction at 0x{pc:08X} in a code range")
            b, mn, ops = p.code[pc]
            stale = pc in p.stale
            if pc in funcs:
                L.append("")
                L.append(f"# ---- {names[pc]} " + "-" * max(4, 72 - len(names[pc])))
                if pc in notes:
                    L += wrap(notes[pc])
                if pc in self.fwcopy:
                    fwn = self.fwcopy[pc]
                    L.append("# byte-identical (to its first return) to the firmware's "
                             + (fwn if fwn != names[pc] else "routine of this name"))
                if pc in self.fwsame:
                    fwn, fcpu = self.fwsame[pc]
                    L.append(f"# the same code as the firmware's {fwn} (941 0x{fcpu:08X}), linked elsewhere"
                             if fwn != names[pc] else
                             f"# the same code as the firmware's routine of this name (941 0x{fcpu:08X}),"
                             " linked elsewhere")
                if pc in self.fwcall and pc not in self.fwsame and pc not in self.fwcopy:
                    fwn, fcpu, parent = self.fwcall[pc]
                    L.append(f"# called where the firmware's {parent} calls its {fwn} (941 0x{fcpu:08X})")
                if stale and pc in self.dead:
                    L.append("# older link: not reachable from what survives of it")
                elif stale:
                    L.append("# older link: not reachable from this ROM's code")
                elif pc in self.dead and (pc in self.dat.refs or pc in self.dat.pointers.values()):
                    L.append("# nothing calls it directly: its address is taken (a handler or a method)")
                elif pc in self.dead:
                    L.append("# no caller: unreferenced code")
                if pc in p.entry_of:
                    L.append(f"# `call` enters at {names[p.entry_of[pc]]}, past the prologue")
                L.append(f"{names[pc]}:")
            elif pc in names and (pc in p.branches or pc in self.T or pc in self.dat.labels):
                L.append(f"{names[pc]}:")
            elif pc in names and pc in p.stale and pc in self.stale_data_labels:
                L.append(f"{names[pc]}:")
            L.append(self.insn_line(pc, b, mn, ops, stale))
            o += len(b)
        if o != o1:
            sys.exit(f"gen_ic18_s: code range 0x{o0:05X}-0x{o1:05X} ends inside an instruction")
        return L

    def data_lines(self, r0, r1, stale=False):
        im, d, dat, names, notes = self.im, self.im.d, self.dat, self.names, self.notes
        labels = (self.stale_data_labels if stale else dat.labels)
        L = []
        offs = sorted(o for o in range(r0, r1) if im.cpu(o) in labels)
        o, cur_w = r0, 1
        while o < r1:
            cpu = im.cpu(o)
            if cpu in labels:
                L.append(f"{names[cpu]}:" + (f"{' ' * max(1, 32 - len(names[cpu]))}# {notes[cpu]}"
                                             if cpu in notes else ""))
                ws = dat.widths.get(cpu, set())
                cur_w = min(ws) if len(ws) == 1 else 1
            nxt = next((x for x in offs if x > o), r1)
            if not stale and o in dat.special:
                kind, n = dat.special[o]
                L += self.emit_special(kind, o, n)
                o += n
                continue
            if not stale and o in dat.strings:
                n, nul = dat.strings[o]
                L.append(f"    {'.asciz' if nul else '.ascii'}  \"{esc(d[o:o + n - nul])}\"")
                o += n
                cur_w = 1
                continue
            if not stale and o in dat.pointers:
                row = []
                while o in dat.pointers and (not row or im.cpu(o) not in labels) and len(row) < 4:
                    row.append(names[dat.pointers[o]])
                    o += 4
                L.append(f"    .long   {', '.join(row)}")
                continue
            stops = [nxt]
            if not stale:
                stops += [x for x in dat.strings if x > o][:1] + [x for x in dat.pointers if x > o][:1]
                stops += [x for x in dat.special if x > o][:1]
            stop = min(min(stops), r1)
            run = d[o:stop]
            if len(run) >= 16 and len(set(run)) == 1 and run[0] in (0, 0xFF):
                L.append(f"    .space  {len(run)}" + (", 0xFF" if run[0] == 0xFF else ""))
                o = stop
                continue
            w = cur_w
            if w > 1 and (o % w or len(run) % w):
                w = 1
            per = {1: 16, 2: 8, 4: 4}[w]
            dr = {1: ".byte", 2: ".word", 4: ".long"}[w]
            for k in range(0, len(run), per * w):
                chunk = run[k:k + per * w]
                vals = [f"0x{int.from_bytes(chunk[i:i + w], 'little'):0{2 * w}X}"
                        for i in range(0, len(chunk), w)]
                L.append(f"    {dr:7s} {', '.join(vals)}")
            o = stop
        return L

    def emit_special(self, kind, o, n):
        sys.exit(f"gen_ic18_s: no emitter for {kind}")

    def body_lines(self):
        p, im = self.p, self.im
        self.nwide = 0
        self.stale_data_labels = getattr(self, "stale_data_labels", set())
        B = []
        sec = lambda t: ["", "# " + "=" * 30 + f" {t} " + "=" * max(4, 60 - len(t))]
        B += sec("ROM at 0x40000000: the vectors")
        B += [".mnbase 0x40000000            # CPU address of file offset 0"]
        B += self.code_lines(0x00, 0x11)
        B += sec("ROM: what survives of an older link")
        B += ["# The older link's reset code (from 0x64) and the end of its NMI handler",
              "# (0x11) are still here; nothing in this ROM reaches them. Their targets",
              "# outside these bytes are the older link's addresses (OldLink_*), not this",
              "# image's. Between them is the older link's .data image (0x24 bytes that its",
              "# reset code copies to 0x50180000)."]
        B += self.code_lines(0x11, STALE_DATA[0])
        B += self.data_lines(*STALE_DATA, stale=True)
        B += self.code_lines(STALE_DATA[1], im.dat0)
        B += sec(".data: the initialised-data image")
        B += ["# Reset copies it to __data_start (0x50010000). It is assembled under",
              "# .mnbase RUN - FILE, so its labels are the run addresses the code uses.",
              "__data_load:",
              f".mnbase 0x{im.dat_run - im.dat0:08X}            # __data_start - 0x{im.dat0:05X}",
              "__data_start:"]
        B += self.data_lines(im.dat0, im.dat1)
        B += ["__data_end:", ".mnbase 0x40000000"]
        B += sec("ROM: the reset code and the NMI handler, run in place")
        B += self.code_lines(im.dat1, im.img0)
        B += sec("the program image, run in work RAM at 0x50000010")
        B += ["# Reset copies it there (ImageCopyDescriptor, at the end of the ROM) and",
              "# jumps to BootMain. Assembled under .mnbase RUN - FILE.",
              "__image_load:",
              f".mnbase 0x{im.img_run - im.img0:08X}            # __image_start - 0x{im.img0:05X}",
              "__image_start:"]
        B += self.code_lines(im.img0, p.pad0)
        if p.pad0 < p.rodata0:
            B += ["    .align  4"]
        B += sec("the program image: constant and initialised data")
        B += self.data_lines(p.rodata0, im.img1)
        B += ["__image_end:", ".mnbase 0x40000000"]
        B += sec("ROM: the copy descriptor, then erased flash")
        B += ["# Read by Reset: the byte count at +2, the source at +4, the run address at",
              "# +8 (written through the uncached view, run address + 0x40000000).",
              "ImageCopyDescriptor:",
              f"    .word   0x{struct.unpack_from('<H', im.d, im.desc)[0]:04X}"
              "                    # TODO: not read by the reset code",
              "    .word   IMAGE_SIZE",
              "    .long   __image_load",
              "    .long   __image_start"]
        if set(im.d[im.desc + 12:]) != {0xFF}:
            sys.exit("gen_ic18_s: the ROM is not erased after the descriptor")
        B += [f"    .space  0x{len(im.d) - im.desc - 12:X}, 0xFF", f"    .org    0x{len(im.d):X}"]
        return B

    def source(self):
        self.names.setdefault(0x50010194, "__bss_start")
        self.notes.setdefault(0x50010194, ".bss follows .data in RAM: = __data_end")
        self.build_values()
        self.body_lines()                  # a first pass finds the externals and stale labels
        self.build_values()
        B = self.body_lines()
        im, p = self.im, self.p
        H = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
             "# Licensed under the terms of the GNU General Public License v3 or later",
             "#",
             "# The KN7000 boot ROM: the first 64 KB of IC18 (C3CBND000046), byte-exact.",
             "# GENERATED by tools/gen_ic18_s.py (`make ic18-src`); put names in",
             "# kn7000_ic18.sym, not here. notes/ic18-boot-rom.md describes the program.",
             f"#   {len(im.d)} bytes, SHA-1 {hashlib.sha1(im.d).hexdigest()}",
             "#",
             "# The CPU starts at 0x40000000. Reset (run in place) sets up the bus and the",
             "# caches, copies the program image to work RAM at 0x50000010 and the .data",
             "# image to 0x50010000, clears .bss, builds the two interrupt thunks at",
             "# 0x50000000 and jumps to BootMain in RAM.",
             f"#   {len(p.code)} instructions in {len(self.funcs)} routines "
             f"({len(self.dead)} with no caller, {len(p.stale)} instructions of an older link),",
             f"#   {len(self.fwcopy)} byte-identical to named firmware routines;",
             f"#   data: {len(self.dat.strings)} strings, {len(self.dat.pointers)} pointer words",
             "",
             "# addresses outside this image: RAM past it, the older link's, the hardware"]
        for v, (nm, note) in sorted(self.ext.items()):
            H.append(f".equ {nm}, 0x{v:08X}" + (f"{' ' * max(1, 30 - len(nm))}# {note}" if note else ""))
        H += ["",
              "# constants of the reset code",
              ".equ DATA_SIZE, __data_end - __data_start",
              ".equ BSS_SIZE, 0x1BC0C                # .bss: from __bss_start, past the image",
              ".equ IMAGE_SIZE, __image_end - __image_start",
              ".equ THUNK_NOP_JMP, 0xDCCB            # the bytes cb dc: nop, then jmp d32's opcode",
              ".equ UNCACHED_VIEW, 0x40000000        # 0x8xxxxxxx-0xBxxxxxxx: memory again, uncached"]
        return "\n".join(H + B) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", required=True)
    ap.add_argument("--out")
    ap.add_argument("--names")
    ap.add_argument("--fw-rom")
    ap.add_argument("--fw-r1-end", type=lambda v: int(v, 0))
    ap.add_argument("--fw-lib-file", type=lambda v: int(v, 0))
    ap.add_argument("--fw-sym", nargs="*", default=[])
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../mame-sony-video/unidasm"))
    a = ap.parse_args()
    im = Image(a.rom)
    p = Program(im, a.unidasm)
    if a.report:
        report(p)
    if a.out:
        e = Emitter(p, Data(p), a)
        src = e.source()
        open(a.out, "w").write(src)
        print(f"wrote {a.out}: {len(p.code)} insns, {len(e.funcs)} routines ({len(e.dead)} unreferenced, "
              f"{len(e.fwcopy)} firmware copies), {len(p.branches)} branch targets, {e.nwide} wide forms; "
              f"data: {len(e.dat.strings)} strings, {len(e.dat.pointers)} pointers, {len(e.dat.labels)} labels")


if __name__ == "__main__":
    main()
