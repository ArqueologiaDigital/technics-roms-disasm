#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates complete, byte-exact sources for the Style Convert .CNV files (the
# loadable MN10300 programs behind DISK MENU > STYLE CONVERT,
# notes/style-converter.md), all of them in one run so that a routine the
# converters share gets one name in all of them.
#
# The firmware reads the whole file to 0x502B8000 and calls its first byte, so a
# .CNV is an absolute image linked there, laid out by its C start-up code (the
# routine at offset 2, called once by main):
#
#   code      from offset 0 (`bra main`), then zero padding to a word boundary
#   .rodata   strings and constant tables
#   .data     the initialised-data IMAGE, copied by the start-up code to its run
#             address, which is the file range right after it
#   zeros     the .data run area, .bss (zeroed by the start-up code) and a tail
#
# Every byte becomes source; nothing is .incbin'd:
#
#   * code: found by recursive descent from offset 0 (the converters make no
#     indirect call or jump), then every gap left below .rodata decoded as
#     unreferenced code, iterated until none is left. Mnemonics come from MAME's
#     unidasm and are kept only if tools/mn10300_asm.py re-encodes the exact
#     bytes (the long calls the linker did not relax are written `T:32`). Call
#     targets are func_<ADDR>, branch targets loc_<ADDR>, and every absolute
#     address an operand names is a label;
#   * data: labels at every address the code names and every pointer word's
#     target. Text is .asciz (or .ascii for an unterminated field), pointer words
#     .long <label>; other data takes the width the code reads it with (movbu /
#     movhu / mov at an absolute address, or through the register its address was
#     loaded into), else bytes;
#   * the .data image is assembled under `.mnbase RUN - FILE`, so its labels are
#     the run addresses the code uses; the zero areas are labelled .space.
#
# Names, in order of precedence: --names (cnv_manual.sym: `STEM 0xADDR NAME ; note`,
# applied to every converter holding the same routine); the firmware's name for a
# routine byte-identical to a named one of PROGRAM 941 (--fw-*: the converters link
# their own copy of its C runtime); Str_<text> for strings; func_/loc_/<area>_<ADDR>.
# Two routines are "the same" when their instructions match with data addresses
# masked and calls compared by the callee's group (refined until stable).
#
# The results assemble with tools/kn7asm.py; `make verify-cnv` checks each one is
# byte-identical to the file on the softlist disk.
#
# Usage:
#   gen_cnv_s.py --outdir src/cnv [--names cnv_manual.sym]
#                [--fw-rom P.rom --fw-r1-end N --fw-lib-file N --fw-sym S.sym ...]
#                STEM=FILE.CNV[:provenance] ...
import argparse
import collections
import hashlib
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as ASM          # noqa: E402

BASE = 0x502B8000
INSN = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")
COND_B = {"beq", "bne", "bgt", "bge", "ble", "blt", "bhi", "bcc", "bcs", "bls",
          "bnc", "bns", "bvc", "bvs"}
LOOP = {"leq", "lne", "lgt", "lge", "lle", "llt", "lhi", "lcc", "lcs", "lls", "lra"}
RETS = {"ret", "retf", "rets", "rti"}
XFER = {"bra", "jmp", "call", "calls"} | COND_B
WIDTH = {"movbu": 1, "movhu": 2, "mov": 4}
REGS = {"d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3", "sp"}
CRT_SHAPE = ["mov", "cmp", "ble", "mov", "clr", "mov", "inc4", "add", "bgt",
             "mov", "cmp", "ble", "mov", "mov", "mov", "inc4", "mov", "inc4",
             "add", "bgt", "rets"]

# The firmware's side of the interface (notes/style-converter.md)
EXTERNAL = {
    0x5031BBFE: ("CnvInitFlag", "the firmware clears it before each load; CnvMain runs CnvStartup while it is 0"),
    0x5031BC00: ("CnvMailbox", "byte 0: the request the converter returns with (0xFF once served)"),
    0x5031BC01: ("CnvMailboxArg", "byte 1 of the mailbox: a request's sub-code or first argument"),
    0x5031BFFF: ("CnvMailboxEnd", "the last mailbox byte; the firmware clears it before each load"),
}


def u32(d, o):
    return struct.unpack_from("<I", d, o)[0]


def first_target(ops):
    m = re.match(r"0x([0-9a-f]+)", ops)
    return int(m.group(1), 16) if m else None


def printable(c):
    return 0x20 <= c < 0x7F or c in (9, 10, 13)


class Decoder:
    """pc -> (bytes, mnemonic, operands), decoding with unidasm on demand. A
    decode depends only on the bytes at pc, so every line of every run is kept.
    Two unidasm quirks are corrected as in gen_program_s.disasm_function: F4
    (register-indexed movbu) is 2 bytes, and FA 9x stores print no register."""

    def __init__(self, unidasm, path, d):
        self.u, self.p, self.d, self.c = unidasm, path, d, {}

    def at(self, pc):
        if pc not in self.c:
            o = pc - BASE
            out = subprocess.run([self.u, self.p, "-arch", "mn10300", "-basepc", hex(pc),
                                  "-skip", hex(o), "-count", str(min(0x400, len(self.d) - o))],
                                 capture_output=True, text=True, check=True).stdout
            lines = [m for m in map(INSN.match, out.splitlines()) if m]
            if len(lines) > 1:
                lines = lines[:-1]                 # the last may be cut by -count
            for m in lines:
                a = int(m.group(1), 16)
                b = bytes.fromhex(m.group(2).replace(" ", ""))
                mn, ops = m.group(3), m.group(4).strip()
                if b == b"\xf4":
                    b = self.d[a - BASE:a - BASE + 2]
                if len(b) == 4 and b[0] == 0xFA and 0x90 <= b[1] <= 0x9F:
                    op = b[1] & 3
                    mn = ("mov", "mov", "movbu", "movhu")[op]
                    ops = re.sub(r"^d\d+", f"{'a' if op == 0 else 'd'}{(b[1] >> 2) & 3}", ops)
                self.c.setdefault(a, (b, mn, ops))
        return self.c[pc]


def discover(dec, entries):
    """Recursive descent. Returns ({pc: insn}, call targets, branch targets)."""
    code, calls, branches, work = {}, set(), set(), list(entries)
    while work:
        pc = work.pop()
        while pc not in code:
            b, mn, ops = dec.at(pc)
            if mn == "?" or mn.startswith("udf"):
                sys.exit(f"gen_cnv_s: undecodable byte at 0x{pc:08X} ({b.hex()}) on a code path")
            code[pc] = (b, mn, ops)
            t = first_target(ops)
            if mn in ("bra", "jmp", "call", "calls") and t is None:
                sys.exit(f"gen_cnv_s: indirect {mn} at 0x{pc:08X}: targets unknown")
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


def covered(code):
    s = set()
    for pc, (b, _m, _o) in code.items():
        s.update(range(pc, pc + len(b)))
    return s


class Cnv:
    """Everything about one converter that does not depend on naming."""

    def __init__(self, stem, path, source, unidasm):
        self.stem, self.path, self.source = stem, path, source
        self.d = open(path, "rb").read()
        self.END = BASE + len(self.d)
        self.dec = Decoder(unidasm, path, self.d)
        self.layout()
        self.find_code()
        self.find_data()

    # ---- the start-up code's layout ----------------------------------------
    def layout(self):
        dec, d = self.dec, self.d
        crt = [dec.at(BASE + 2)]
        while crt[-1][1] != "rets":
            crt.append(dec.at(BASE + 2 + sum(len(x[0]) for x in crt)))
        if [mn for _b, mn, _o in crt] != CRT_SHAPE:
            sys.exit(f"gen_cnv_s: {self.stem}: the start-up code at offset 2 is not the expected shape")
        pcs = [BASE + 2 + sum(len(x[0]) for x in crt[:i]) for i in range(len(crt))]

        def imm(i):
            return int(crt[i][2].split(",")[0], 16)
        self.bss_n, self.bss = imm(0), imm(3)
        self.dat_n, self.dat_src, self.dat_run = imm(9), imm(12), imm(13)
        self.size_insn = {pcs[0]: "BSS_SIZE", pcs[9]: "DATA_SIZE"}
        self.img0 = self.dat_src - BASE
        self.img1 = self.img0 + self.dat_n
        if not (self.dat_run == self.dat_src + self.dat_n and self.bss == self.dat_run + self.dat_n
                and self.bss + self.bss_n <= self.END):
            sys.exit(f"gen_cnv_s: {self.stem}: unexpected layout of image / run area / bss")
        if set(d[self.img1:]) != {0}:
            sys.exit(f"gen_cnv_s: {self.stem}: the file is not all zero after the .data image")
        self.main_pc = first_target(dec.at(BASE)[2])

    # ---- code ----------------------------------------------------------------
    def data_refs(self, code):
        refs = collections.Counter()
        for _pc, (_b, mn, ops) in code.items():
            if mn in XFER:
                continue
            for h in re.findall(r"0x([0-9a-f]{5,8})", ops):
                v = int(h, 16)
                if BASE <= v <= self.END:
                    refs[v] += 1
        return refs

    def find_code(self):
        dec, d = self.dec, self.d
        code, calls, branches = discover(dec, [BASE])
        hi = max(code) + len(code[max(code)][0])
        self.rodata0 = min(v for v in self.data_refs(code) if v >= hi) - BASE
        # every unreached byte below .rodata is unreferenced code, except the zero
        # padding that aligns .rodata
        pad0 = self.rodata0
        while d[pad0 - 1] == 0 and self.rodata0 - pad0 < 3:
            pad0 -= 1
        dead = []
        while True:
            cov = covered(code)
            gaps = [BASE + o for o in range(pad0) if BASE + o not in cov
                    and (o == 0 or BASE + o - 1 in cov) and BASE + o not in dead]
            if not gaps:
                break
            dead += gaps
            code, calls, branches = discover(dec, [BASE] + dead)
        cov = covered(code)
        if any(BASE + o not in cov for o in range(pad0)) or any(BASE + o in cov for o in range(pad0, len(d))):
            sys.exit(f"gen_cnv_s: {self.stem}: code does not end exactly at the .rodata padding")
        self.pad0, self.code, self.calls, self.branches = pad0, code, calls, branches
        self.dead = [f for f in dead if f not in calls]
        self.starts = set(code)

    # ---- data ----------------------------------------------------------------
    def valid_target(self, v):
        """An address a label may name: code instruction starts, .rodata, the .data
        run range, the zero areas -- not the image's own file range."""
        if v in self.starts:
            return True
        o = v - BASE
        return self.rodata0 <= o < self.img0 or self.img1 <= o <= len(self.d)

    def file_to_cpu(self, o):
        return BASE + o if not self.img0 <= o < self.img1 else self.dat_run + (o - self.img0)

    def find_data(self):
        d, code = self.d, self.code
        refs = self.data_refs(code)
        widths = collections.defaultdict(set)
        for pc in sorted(code):
            _b, mn, ops = code[pc]
            m = re.search(r"\(0x([0-9a-f]{5,8})\)", ops)
            if m and mn in WIDTH:
                widths[int(m.group(1), 16)].add(WIDTH[mn])
        # follow `mov LABEL, rN` / `add LABEL, rN` / `mov rN, rM` to the accesses
        # through rN in the same straight-line run
        track, prev_end = {}, None
        targets = self.calls | self.branches
        for pc in sorted(code):
            b, mn, ops = code[pc]
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
                if mn in ("mov", "add") and v is not None and BASE <= v < self.END:
                    track[dst] = v
                elif mn == "mov" and src in track:
                    track[dst] = track[src]
                else:
                    track.pop(dst, None)
        bad = sorted(v for v in refs if not (self.valid_target(v) or v == self.dat_src))
        if bad:
            sys.exit(f"gen_cnv_s: {self.stem}: code names addresses inside the .data image: "
                     + ", ".join(f"0x{v:08X}" for v in bad))
        labels = set(refs)

        # strings, then pointer words, in .rodata and the .data image
        strings, pointers = {}, {}
        for r0, r1 in ((self.rodata0, self.img0), (self.img0, self.img1)):
            lab_offs = sorted(o for o in range(r0, r1) if self.file_to_cpu(o) in labels) + [r1]
            o = r0
            while o < r1:
                cpu = self.file_to_cpu(o)
                boundary = o == r0 or not printable(d[o - 1]) or cpu in labels
                lim = next(x for x in lab_offs if x > o)
                n, nul = self.string_at(o, lim, cpu in labels) if boundary else (0, True)
                if n and not (o % 4 == 0 and o + 4 <= r1 and self.valid_target(u32(d, o))):
                    strings[o] = (n, nul)
                    o += n
                    continue
                if o % 4 == 0 and o + 4 <= r1 and self.valid_target(u32(d, o)):
                    pointers[o] = u32(d, o)
                    o += 4
                    continue
                o += 1
        labels |= set(pointers.values())
        labels |= {self.dat_run, self.dat_run + self.dat_n, self.bss, self.bss + self.bss_n}
        self.refs, self.widths, self.labels = refs, widths, labels
        self.strings, self.pointers = strings, pointers
        self.funcs = sorted({BASE, BASE + 2, self.main_pc} | self.calls | set(self.dead)
                            | {v for v in pointers.values() if v in self.starts})

    def string_at(self, o, lim, labelled):
        """(length, NUL-terminated?) of the text at file offset o, or (0, _). Text
        may not run past `lim`, the next label. NUL-terminated text is a string;
        text that stops without a NUL is an unterminated piece (.ascii): a
        fixed-width field, e.g. the space-padded names in record tables."""
        d = self.d
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

    # ---- routines ------------------------------------------------------------
    def chunks(self):
        """{routine start: [pcs]} -- each routine up to the next one."""
        bounds = self.funcs + [BASE + self.pad0]
        pcs = sorted(self.code)
        out, i = {}, 0
        for k, f in enumerate(self.funcs):
            while i < len(pcs) and pcs[i] < f:
                i += 1
            j = i
            while j < len(pcs) and pcs[j] < bounds[k + 1]:
                j += 1
            out[f] = (pcs[i:j], bounds[k + 1])
        return out

    def body(self, f):
        """bytes of the routine at f up to and including its first return."""
        out, pc = b"", f
        while pc in self.code and len(out) <= 0x400:
            b, mn, _o = self.code[pc]
            out += b
            pc += len(b)
            if mn in RETS:
                return out
        return None


def signatures(cnvs):
    """{(stem, routine): group id}: routines whose instructions match with data
    addresses masked and calls compared by the callee's group, refined to a
    fixed point."""
    norm = {}
    for c in cnvs:
        for f, (pcs, end) in c.chunks().items():
            seq = []
            for pc in pcs:
                _b, mn, ops = c.code[pc]
                t = first_target(ops) if mn in XFER else None
                if mn in ("call", "calls"):
                    seq.append((mn, "CALL", t, ops.split(",", 1)[1:]))
                elif t is not None:
                    seq.append((mn, f"@{t - f}" if f <= t < end else "X"))
                else:
                    seq.append((mn, re.sub(r"0x5[0-9a-f]{7}", "A", ops)))
            norm[(c.stem, f)] = seq
    group = {k: 0 for k in norm}
    for _ in range(30):
        keys, new = {}, {}
        for k, seq in norm.items():
            s = tuple((x[0], "CALL", group.get((k[0], x[2]), -1), tuple(x[3])) if x[1] == "CALL" else x
                      for x in seq)
            new[k] = keys.setdefault((group[k], s), len(keys))
        if len(set(new.values())) == len(set(group.values())):
            return new
        group = new
    return group


def load_manual(path):
    out = {}
    if not path:
        return out
    for line in open(path):
        if line.lstrip().startswith(";") or not line.strip():
            continue
        m = re.match(r"\s*(\S+)\s+0x([0-9A-Fa-f]{8})\s+(\S+)\s*(?:;\s*(.*))?$", line.rstrip("\n"))
        if not m:
            sys.exit(f"gen_cnv_s: {path}: bad line {line!r}")
        out[(m.group(1), int(m.group(2), 16))] = (m.group(3), (m.group(4) or "").strip())
    return out


def esc(bs):
    return "".join({0x5C: "\\\\", 0x22: '\\"', 9: "\\t", 10: "\\n", 13: "\\r"}.get(c, chr(c)) for c in bs)


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


def name_all(cnvs, a):
    groups = signatures(cnvs)
    members = collections.defaultdict(list)
    for (stem, f), g in groups.items():
        members[g].append(stem)
    manual = load_manual(a.names)
    fw = {}
    if a.fw_rom:
        import gen_xap_s
        fw = gen_xap_s.firmware_routines(a.fw_rom, a.fw_r1_end, a.fw_lib_file, a.fw_sym, a.unidasm)
    stems = {c.stem for c in cnvs}
    by_group = {}
    for (stem, v), (nm, note) in manual.items():
        if stem not in stems:
            sys.exit(f"gen_cnv_s: {a.names}: unknown converter {stem}")
        if (stem, v) in groups:
            by_group.setdefault(groups[(stem, v)], (nm, note))
    for c in cnvs:
        names, notes = {}, {}
        for (stem, v), (nm, note) in manual.items():   # data and in-routine names
            if stem == c.stem and (stem, v) not in groups:
                names[v] = nm
                if note:
                    notes[v] = note
        for f in c.funcs:
            g = groups[(c.stem, f)]
            if g in by_group:
                names.setdefault(f, by_group[g][0])
                if by_group[g][1]:
                    notes.setdefault(f, by_group[g][1])
        names.setdefault(BASE, "CnvEntry")
        notes.setdefault(BASE, "the firmware calls offset 0 on every turn: mov 0x502B8000, a0; calls (a0)")
        names.setdefault(BASE + 2, "CnvStartup")
        notes.setdefault(BASE + 2, "C start-up: zero .bss, copy the .data image to its run address")
        names.setdefault(c.main_pc, "CnvMain")
        notes.setdefault(c.main_pc, "one step of the converter's state machine per call, then back to the firmware")
        c.fwcopy = {}
        for f in c.funcs:
            b = c.body(f)
            if b and b in fw:
                c.fwcopy[f] = fw[b]
                names.setdefault(f, fw[b])
        for f in c.funcs:
            names.setdefault(f, f"func_{f:08X}")
        for t in sorted(c.branches):
            names.setdefault(t, f"loc_{t:08X}")
        for v, (nm, note) in EXTERNAL.items():
            names[v] = nm
        # data labels
        str_cpu = {c.file_to_cpu(o): o for o in c.strings}
        fixed = {c.dat_run: "__data_start", c.dat_run + c.dat_n: "__data_end",
                 c.bss: "__bss_start", c.bss + c.bss_n: "__bss_end", c.dat_src: "__data_load"}
        taken = set(names.values())
        for v in sorted(c.labels):
            if v in fixed:
                names[v] = fixed[v]
                continue
            if v in names:
                continue
            o = v - BASE
            if v in str_cpu:
                so = str_cpu[v]
                n, nul = c.strings[so]
                nm = text_name(c.d[so:so + n - nul].decode("latin1")) or f"str_{v:08X}"
            elif c.rodata0 <= o < c.img0:
                nm = f"rodata_{v:08X}"
            elif c.dat_run <= v < c.dat_run + c.dat_n:
                nm = f"data_{v:08X}"
            elif c.bss <= v < c.bss + c.bss_n:
                nm = f"bss_{v:08X}"
            else:
                nm = f"tail_{v:08X}"
            base_nm, k = nm, 2
            while nm in taken:
                nm = f"{base_nm}_{k}"
                k += 1
            taken.add(nm)
            names[v] = nm
        # one name per address, one address per name
        seen = {}
        for v in sorted(names):
            nm = names[v]
            if nm in seen and seen[nm] != v:
                names[v] = f"{nm}_at_{v:08X}"
            seen[names[v]] = v
        c.names, c.notes = names, notes
        c.shared = {f: sorted(s for s in members[groups[(c.stem, f)]] if s != c.stem) for f in c.funcs}


def emit(c, out_path, nconv):
    d, names, notes = c.d, c.names, c.notes
    labels = c.labels | set(c.branches) | set(c.funcs)

    def symbolise(mn, ops, pc):
        o = ASM.split_ops(ops) if ops else []
        if mn in XFER:
            o[0] = names[first_target(o[0])]
        else:
            def rep(m):
                v = int(m.group(1), 16)
                return names[v] if v in names and (v in labels or v in EXTERNAL) else m.group(0)
            o = [re.sub(r"0x([0-9a-f]{5,8})\b", rep, x) for x in o]
        if pc in c.size_insn:
            o[0] = c.size_insn[pc]
        return ", ".join(o)

    inv = {n: v for v, n in names.items()}
    inv.update({"BSS_SIZE": c.bss_n, "DATA_SIZE": c.dat_n})

    def resolve(ops):
        return re.sub(r"\b([A-Za-z_]\w*)\b", lambda m: hex(inv[m.group(1)])
                      if m.group(1) in inv and m.group(1) not in REGS else m.group(0), ops)

    C = ["", "# " + "=" * 32 + " code " + "=" * 32]
    nlong = 0
    funcs = set(c.funcs)
    for pc in sorted(c.code):
        b, mn, ops = c.code[pc]
        if pc in funcs:
            C.append("")
            C.append(f"# ---- {names[pc]} " + "-" * max(4, 66 - len(names[pc])))
            if pc in notes:
                C.append(f"# {notes[pc]}")
            if pc in c.fwcopy and c.fwcopy[pc] != names[pc]:
                C.append(f"# byte-identical (to its first return) to the firmware's {c.fwcopy[pc]}")
            elif pc in c.fwcopy:
                C.append("# byte-identical (to its first return) to the firmware's routine of this name")
            if pc in c.dead:
                C.append("# no caller: unreferenced code")
            sh = c.shared.get(pc, [])
            if sh:
                C.append("# the same code is in " + ("all the other converters" if len(sh) == nconv - 1
                                                    else ", ".join(f"{s}.CNV" for s in sh)))
            C.append(f"{names[pc]}:")
        elif pc in labels and pc in names:
            C.append(f"{names[pc]}:")
        sops = symbolise(mn, ops, pc)
        try:
            enc = ASM.encode(mn, resolve(sops), pc)
        except ASM.EncError as e:
            sys.exit(f"gen_cnv_s: {c.stem}: cannot re-encode 0x{pc:08X} {mn} {sops}: {e}")
        if enc != b and mn in ("call", "calls", "jmp"):
            parts = ASM.split_ops(sops)
            parts[0] += ":32"
            sops = ", ".join(parts)
            enc = ASM.encode(mn, resolve(sops), pc)
            nlong += 1
        if enc != b:
            sys.exit(f"gen_cnv_s: {c.stem}: 0x{pc:08X} {mn} {sops} re-encodes as {enc.hex()}, not {b.hex()}")
        C.append(f"    {mn:8s}{sops}".rstrip())
    if c.pad0 < c.rodata0:
        C += ["", "    .align  4                       # zero padding before .rodata"]

    def data_block(r0, r1, cpu_of):
        """Typed directives for file range [r0, r1)."""
        L = []
        offs = sorted(o for o in range(r0, r1) if cpu_of(o) in labels)
        o, cur_w = r0, 1
        while o < r1:
            prev_str = bool(L) and L[-1].lstrip().startswith((".asciz", ".ascii"))
            cpu = cpu_of(o)
            if cpu in labels:
                L.append(f"{names[cpu]}:")
                ws = c.widths.get(cpu, set())
                cur_w = min(ws) if len(ws) == 1 else 1
            nxt = next((x for x in offs if x > o), r1)
            if o in c.strings:
                n, nul = c.strings[o]
                L.append(f"    {'.asciz' if nul else '.ascii'}  \"{esc(d[o:o + n - nul])}\"")
                o += n
                cur_w = 1
                continue
            if o in c.pointers:
                row = []
                while o in c.pointers and (not row or cpu_of(o) not in labels) and len(row) < 4:
                    row.append(names[c.pointers[o]])
                    o += 4
                L.append(f"    .long   {', '.join(row)}")
                continue
            stop = min([x for x in c.strings if x > o] + [x for x in c.pointers if x > o] + [nxt])
            run = d[o:stop]
            if set(run) == {0} and len(run) < 4 and stop % 4 == 0 and o % 4 \
                    and (cpu_of(o) - o) % 4 == 0 and prev_str:
                L.append("    .align  4")
                o = stop
                continue
            if len(run) >= 16 and set(run) == {0}:
                L.append(f"    .space  {len(run)}")
                o = stop
                continue
            w = cur_w
            if w > 1 and (o % w or len(run) % w):
                w = 1
            per = {1: 16, 2: 8, 4: 4}[w]
            dr = {1: ".byte", 2: ".word", 4: ".long"}[w]
            for k in range(0, len(run), per * w):
                chunk = run[k:k + per * w]
                if w == 1:
                    vals = [f"0x{x:02X}" for x in chunk]
                else:
                    vals = [f"0x{int.from_bytes(chunk[i:i + w], 'little'):0{2 * w}X}"
                            for i in range(0, len(chunk), w)]
                L.append(f"    {dr:7s} {', '.join(vals)}")
            o = stop
        return L

    img0, img1, END = c.img0, c.img1, c.END
    R = ["", "# " + "=" * 30 + " .rodata " + "=" * 30, f"    .org    0x{c.rodata0:05X}"]
    R += data_block(c.rodata0, img0, lambda o: BASE + o)
    R += ["", "# " + "=" * 18 + " .data: the initialised-data image " + "=" * 18,
          "# CnvStartup copies it to __data_start, the file range right after it. It is",
          "# assembled under .mnbase RUN - FILE, so its labels are the run addresses the",
          "# code uses.",
          f"    .org    0x{img0:05X}",
          "__data_load:",
          f".mnbase 0x{c.dat_run - img0:08X}            # __data_start - 0x{img0:05X}"]
    R += data_block(img0, img1, lambda o: c.dat_run + (o - img0))
    R += ["__data_end:                             # = __bss_start",
          f".mnbase 0x{BASE:08X}",
          "",
          "# " + "=" * 14 + " zeros: the .data run area, .bss, the tail " + "=" * 14,
          "# The run area is zero in the file; CnvStartup fills it from __data_load.",
          "    .space  DATA_SIZE"]
    cur = c.bss
    for v in sorted(x for x in labels if c.bss <= x <= END):
        if v > cur:
            R.append(f"    .space  {v - cur}")
        R.append(f"{names[v]}:")
        cur = v
    if END > cur:
        R.append(f"    .space  {END - cur}")
    R.append(f"    .org    0x{len(d):05X}               # end of file")

    ndead, nfw = len(c.dead), len(c.fwcopy)
    nshared = sum(1 for f in c.funcs if len(c.shared[f]) == nconv - 1)
    H = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#",
         f"# {c.stem}.CNV -- a Style Convert Disk converter, byte-exact.",
         "# GENERATED by tools/gen_cnv_s.py (`make cnv-src`); put names in cnv_manual.sym, not here.",
         f"# Source: {c.source}" if c.source else "#",
         f"#   {len(d)} bytes, SHA-1 {hashlib.sha1(d).hexdigest()}",
         "#",
         f"# Linked for and loaded at 0x{BASE:08X}; the firmware calls CnvEntry (offset 0).",
         f"#   code     0x00000..0x{c.pad0:05X}  {len(c.code)} instructions in {len(c.funcs)} routines:",
         f"#                              {ndead} with no caller, {nfw} copies of named firmware routines,",
         f"#                              {nshared} the same in all {nconv} converters",
         f"#   .rodata  0x{c.rodata0:05X}..0x{img0:05X}  {len(c.strings)} strings and text fields, "
         f"{len(c.pointers)} pointer words",
         f"#   .data    0x{img0:05X}..0x{img1:05X}  image of 0x{c.dat_run:08X}..0x{c.dat_run + c.dat_n:08X}",
         f"#   zeros    0x{img1:05X}..0x{len(d):05X}  the .data run area, .bss "
         f"0x{c.bss:08X}..0x{c.bss + c.bss_n:08X}, a tail",
         "",
         f".mnbase 0x{BASE:08X}            # CPU address of file offset 0",
         "",
         "# the firmware's side of the interface (notes/style-converter.md)"]
    H += [f".equ {nm}, 0x{v:08X}       # {note}" for v, (nm, note) in sorted(EXTERNAL.items())]
    H += ["",
          "# the sizes CnvStartup loops over",
          ".equ BSS_SIZE, __bss_end - __bss_start",
          ".equ DATA_SIZE, __data_end - __data_start"]
    open(out_path, "w").write("\n".join(H + C + R) + "\n")
    print(f"wrote {out_path}: {len(c.code)} insns, {len(c.funcs)} routines ({ndead} unreferenced, "
          f"{nfw} firmware copies, {nshared} in all), {len(c.branches)} branch targets, {nlong} long calls; "
          f"data: {len(c.strings)} strings, {len(c.pointers)} pointers, {len(c.labels)} labels")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+", help="STEM=FILE.CNV[:provenance]")
    ap.add_argument("--outdir", required=True)
    ap.add_argument("--names", help="manual names: STEM 0xADDR NAME [; note]")
    ap.add_argument("--fw-rom", help="the firmware program image (PROGRAM 941)")
    ap.add_argument("--fw-r1-end", type=lambda v: int(v, 0))
    ap.add_argument("--fw-lib-file", type=lambda v: int(v, 0))
    ap.add_argument("--fw-sym", nargs="*", default=[])
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../mame-sony-video/unidasm"))
    a = ap.parse_args()

    cnvs = []
    for spec in a.files:
        stem, rest = spec.split("=", 1)
        path, _, source = rest.partition(":")
        cnvs.append(Cnv(stem, path, source, a.unidasm))
    name_all(cnvs, a)
    for c in cnvs:
        emit(c, os.path.join(a.outdir, c.stem.lower() + ".s"), len(cnvs))


if __name__ == "__main__":
    main()
