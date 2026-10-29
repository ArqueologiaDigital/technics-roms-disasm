#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates a byte-exact kn7asm source for a whole MN10300 "MILK" firmware image:
# the KN2400/KN2600 program flash (0x48400000, with a part linked for work RAM),
# the KN6000/KN6500 program flash (0x4C000000), the HD-SX3 XAPR card (0x97800000).
# Used by the sibling trees ../kn2400 ../kn6000 ../kn6500 ../hdsx3; the KN7000's
# own src/program.s keeps coming from gen_program_s.py.
#
# How the source is made:
#   * code ranges (--code LO:HI[:CPU]) are file-offset ranges that hold code; CPU
#     is the address the range is linked for (default: --base + LO). A range linked
#     elsewhere than --base (code the firmware copies to RAM) is emitted under its
#     own .mnbase, so its PC-relative encodings reproduce byte-exactly.
#   * entries: every name in the --sym files (the MILK reflection-table names
#     gen_symbols.py recovers, plus a hand-kept manual file) that lies in a code
#     range; every aligned pointer in the image that lands on a `movm` prologue in
#     a code range (procedures reached only through tables); then, iterating to a
#     fixed point, every `call`/`calls` target of the code reached so far, and the
#     function that starts right after an entry's reached code (see below).
#     Unnamed entries get the synthetic name func_<ADDR>, as in gen_program_s.py.
#   * each entry's bytes up to the next entry are decoded linearly (MAME unidasm,
#     with the two mn10300 decoder quirks gen_program_s.py documents corrected) and
#     walked by control flow from the entry, from any aligned pointer that lands on
#     one of its instruction starts (switch tables), and through branches. The
#     reached instructions form a prefix [entry, X) that is emitted as MN10300
#     assembly (re-encoded by mn10300_asm and compared with the ROM bytes; an
#     instruction the encoder spells differently is kept as a .byte escape with the
#     disassembly beside it). Bytes after X that were not reached -- literal data,
#     or code no traced path enters -- stay .incbin_range, so data is never spelled
#     as instructions. A run of 0xCB (`nop`) padding right after the reached code is
#     emitted as nop instructions.
#   * compiled functions sit back to back, so right after an entry's reached code
#     (and its nop padding) a prologue (`movm`, or `add -N, sp`) or the target of a
#     pointer somewhere in the image starts another entry -- when the code decoded
#     from it, on its own, ends every path in a return or a jump. A stray prologue
#     byte in data decodes into an invalid opcode or runs on, and is rejected.
#   * a `jmp` out of an entry's stretch into code no entry reaches (a boot vector,
#     a tail jump) starts another entry, under the same check.
#   * a call target right behind a movm [+ `add -N, sp`] prologue makes the
#     prologue's first byte an entry too.
#   * a call target that directly follows an entry made of nothing but its movm /
#     `add -N, sp` prologue is that function's register-save entry (`call` saves
#     the registers itself): it is named <function>_entry, as in kn7000_manual.sym.
#   * branch, jump and call targets that land on an emitted instruction print as
#     names: the entry name, or <entry>_L<offset> (a hex offset from the entry) for
#     a target inside it. Targets in .incbin_range bytes stay numeric.
#   * everything outside the code ranges is .incbin_range from the reference image,
#     except the typed data ranges (--long-table, --text, --reflection-tables); a
#     --sym name at the start of one labels it.
#   * --data-include LO:HI:PATH replaces the file range [LO, HI) by `.include PATH`:
#     a data region typed by tools/gen_data_s.py (--profile <model>), whose
#     labels.sym (--data-labels) also names the code's 8-digit immediates that are
#     data addresses (`Label`, or `Label+N` inside a typed item), as
#     gen_program_s.py does for the KN7000.  The two generators read each other's
#     output: tools/regen_sibling_data_and_code.sh runs them to a fixpoint.
#
# Usage:
#   gen_image_s.py --rom baserom/X.rom --base 0x48400000 --code LO:HI[:CPU] [--code ...]
#                  --sym X.sym [X_manual.sym ...] --inc src/symbols.inc --labels-inc src/labels.inc
#                  --out src/program.s
#                  --title "..." [--unidasm PATH] [--stats FILE]
import argparse
import bisect
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as ASM  # noqa: E402

INSN = re.compile(r"([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{2} )+)\s+(\S+)\s*(.*)")
CONDB = {"beq", "bne", "bgt", "bge", "ble", "blt", "bhi", "bcc", "bcs", "bls",
         "bvc", "bvs", "bnc", "bns"}
STOPS = {"ret", "retf", "rets", "rti", "lra"}
REGS = {"d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3", "sp", "pc", "mdr", "psw",
        "lir", "lar"}
MAX_FUNC = 0x10000         # longest stretch decoded from one entry


def load_syms(paths):
    """{cpu: name} from .sym files ('0xADDR  name ...'; ';' starts a comment line)."""
    out = {}
    for p in paths:
        for line in open(p):
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]+)\s+([A-Za-z_]\w*)", line)
            if m:
                out.setdefault(int(m.group(1), 16), m.group(2))
    return out


class Image:
    """The image, its code ranges [(lo, hi, delta)] with cpu = file offset + delta,
    and an index of unidasm's decode of them."""

    def __init__(self, rom, base, code, unidasm):
        self.rom, self.base, self.code, self.unidasm = rom, base, code, unidasm
        self.d = open(rom, "rb").read()
        self.ix = {}               # file offset -> (bytes, mnem, ops) as unidasm printed it
        for lo, hi, _delta in code:
            self._run(lo, hi - lo)

    def rng(self, off):
        for r in self.code:
            if r[0] <= off < r[1]:
                return r
        return None

    def in_code(self, off):
        return self.rng(off) is not None

    def code_end(self, off):
        r = self.rng(off)
        return r[1] if r else off

    def cpu(self, off):
        r = self.rng(off)
        return off + (r[2] if r else self.base)

    def off(self, cpu):
        """File offset of a CPU address in a code range, else None."""
        for lo, hi, delta in self.code:
            if lo <= cpu - delta < hi:
                return cpu - delta
        return None

    def _run(self, off, count):
        """One unidasm pass from `off` (not past its code range); its lines join the
        index, up to the first line the index already has."""
        count = min(count, self.code_end(off) - off)
        if count <= 0:
            return
        txt = subprocess.run(
            [self.unidasm, self.rom, "-arch", "mn10300", "-basepc", f"0x{self.cpu(off):x}",
             "-skip", f"0x{off:x}", "-count", str(count)],
            capture_output=True, text=True).stdout
        delta = self.cpu(off) - off
        for line in txt.splitlines():
            m = INSN.match(line)
            if m:
                o = int(m.group(1), 16) - delta
                if o in self.ix:
                    break
                self.ix[o] = (bytes.fromhex(m.group(2).replace(" ", "")), m.group(3),
                              m.group(4).strip())

    def at(self, off):
        if off not in self.ix:
            self._run(off, 0x100)
        return self.ix.get(off)

    def decode(self, off, end):
        """Linear decode of [off, end): [(off, bytes, mnem, ops)], stopping before
        an invalid opcode, an instruction that would cross `end`, or a misaligned
        line. unidasm quirks: a bare `f4` line is the 2-byte movbu (d,a) form
        whose length it gets wrong; FA 9x stores to (d16,sp) print a bogus
        register (rebuilt from the opcode)."""
        d = self.d
        out, cur = [], off
        while cur < end:
            got = self.at(cur)
            if got is None:
                return out
            b, mnem, ops = got
            if mnem == "?" or mnem.startswith("udfu"):
                return out
            if b == b"\xf4":
                b = d[cur:cur + 2]
            if cur + len(b) > end or d[cur:cur + len(b)] != b:
                return out
            if len(b) == 4 and b[0] == 0xFA and 0x90 <= b[1] <= 0x9F:
                k = b[1] & 3
                mnem = ("mov", "mov", "movbu", "movhu")[k]
                ops = re.sub(r"^d\d+", f"{'a' if k == 0 else 'd'}{(b[1] >> 2) & 3}", ops)
            out.append((cur, b, mnem, ops))
            cur += len(b)
        return out

    def walk(self, insns, roots):
        """Reached instruction offsets of one decoded stretch, by control flow from
        `roots` (file offsets). Returns (reached set, call target offsets, fell-off
        flag); the flag says some path ran past the last decoded instruction."""
        idx = {o: i for i, (o, *_r) in enumerate(insns)}
        reached, calls, work = set(), set(), list(roots)
        falloff = False
        while work:
            o = work.pop()
            if o not in idx or o in reached:
                continue
            i = idx[o]
            while i < len(insns):
                off, _b, mnem, ops = insns[i]
                if off in reached:
                    break
                reached.add(off)
                t = target_of(mnem, ops)
                t = self.off(t) if t is not None else None
                if mnem in ("call", "calls"):
                    if t is not None:
                        calls.add(t)
                elif target_of(mnem, ops) is not None:
                    if t is not None:
                        work.append(t)
                    if mnem in ("bra", "jmp"):
                        break
                elif mnem == "jmp" or mnem in STOPS:
                    break
                i += 1
            else:
                falloff = True
        return reached, calls, falloff

    def ends_cleanly(self, x):
        """Does the code decoded from x, on its own, end every path in a return or
        jump (no invalid opcode, no running off the decoded stretch)?"""
        ins = self.decode(x, min(self.code_end(x), x + MAX_FUNC))
        return bool(ins) and not self.walk(ins, [x])[2]


def idents_of(ops):
    """Identifier tokens of an operand string, tokenised as kn7asm does (so the
    x of 0x10 or the 0 of d0 is not taken apart)."""
    return {t for t in re.findall(r"0x[0-9A-Fa-f]+|\d+|[A-Za-z_]\w*", ops)
            if not t[0].isdigit()}


def prologue_before(d, t):
    """Start of a `movm [regs], (sp)` [+ `add -N, sp`] prologue that ends exactly
    at t, else None: `call` enters a function after its prologue, so a call target
    preceded by one is the register-save entry of the function that starts there."""
    for k, ok in ((5, lambda o: d[o] == 0xCF and d[o + 2] == 0xF8 and d[o + 3] == 0xFE
                   and d[o + 4] >= 0x80),
                  (6, lambda o: d[o] == 0xCF and d[o + 2] == 0xFA and d[o + 3] == 0xFE
                   and d[o + 5] >= 0x80),
                  (2, lambda o: d[o] == 0xCF)):
        o = t - k
        if o >= 0 and ok(o) and d[o + 1] and not d[o + 1] & 0x07:
            return o
    return None


def target_of(mnem, ops):
    """Absolute CPU target of a direct control transfer, else None."""
    if mnem in CONDB or mnem in ("bra", "jmp", "call", "calls"):
        m = re.match(r"0x([0-9a-fA-F]+)", ops)
        if m:
            return int(m.group(1), 16)
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", required=True)
    ap.add_argument("--base", type=lambda v: int(v, 0), required=True,
                    help="CPU address of file offset 0")
    ap.add_argument("--code", action="append", required=True, metavar="LO:HI[:CPU]",
                    help="file-offset range holding code, and the CPU address LO is linked "
                         "for (default --base + LO); repeatable")
    ap.add_argument("--sym", nargs="+", required=True)
    ap.add_argument("--inc", required=True, help="symbols include, as the source names it")
    ap.add_argument("--labels-inc", required=True,
                    help="include to write with an .equ for every label the source defines "
                         "that --inc does not, so every reference resolves in kn7asm's first "
                         "pass (and each label is checked against its .equ)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", action="append", default=[], help="header line (repeatable)")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../tools/unidasm"))
    ap.add_argument("--stats", help="also write the conversion figures to this file")
    ap.add_argument("--long-table", action="append", default=[], metavar="LO:HI",
                    help="data range of u32 words to emit as .long rows, by name where a word "
                         "is the address of an emitted label; its words that point into a code "
                         "range are entries (repeatable)")
    ap.add_argument("--text", action="append", default=[], metavar="LO:HI",
                    help="data range to emit as .byte rows with the text beside them")
    ap.add_argument("--data-include", action="append", default=[], metavar="LO:HI:PATH",
                    help="emit `.include PATH` for the file range [LO, HI) (a typed data region)")
    ap.add_argument("--data-labels", help="labels.sym of the typed data region "
                    "(`0xADDR name size` rows): the code names data addresses by them")
    ap.add_argument("--reflection-tables", action="store_true",
                    help="emit the code-pointer half of every MILK reflection table "
                         "gen_symbols.py finds as .long rows of names")
    a = ap.parse_args()

    base = a.base
    code = []
    for r in a.code:
        f = [int(x, 0) for x in r.split(":")]
        code.append((f[0], f[1], (f[2] - f[0]) if len(f) > 2 else base))
    code.sort()
    img = Image(a.rom, base, code, a.unidasm)
    d = img.d
    ROMQ = f'"{a.rom}"'

    names = load_syms(a.sym)
    inc_text = open(a.inc).read() if os.path.exists(a.inc) else ""
    inc_names = set(re.findall(r"^\.equ\s+([A-Za-z_]\w*)\s*,", inc_text, re.M))
    entries, entry_marks = set(), {}
    for cpu, nm in names.items():
        o = img.off(cpu)
        if o is None:
            continue
        if nm.endswith("_entry"):
            entry_marks[o] = nm
        else:
            entries.add(o)

    # aligned pointers into the code ranges
    ptr_targets = set()
    for o in range(0, len(d) - 3, 4):
        t = img.off(struct.unpack_from("<I", d, o)[0])
        if t is not None:
            ptr_targets.add(t)
    ptr_sorted = sorted(ptr_targets)
    n_ptr_rejected = 0
    for t in ptr_sorted:
        if d[t] != 0xCF or t in entries:
            continue
        if img.ends_cleanly(t):
            entries.add(t)
        else:
            n_ptr_rejected += 1

    # the words of an explicit pointer table that land in code are entries
    for r in a.long_table:
        lo, hi = (int(x, 0) for x in r.split(":"))
        for o in range(lo, hi, 4):
            t = img.off(struct.unpack_from("<I", d, o)[0])
            if t is not None and t not in entries and img.ends_cleanly(t):
                entries.add(t)

    decoded, result = {}, {}
    n_adjacent, n_jumped, n_prologue, rejected_adj = 0, 0, 0, set()
    while True:
        order = sorted(entries)
        new = set()
        for i, e in enumerate(order):
            end = min(order[i + 1] if i + 1 < len(order) else img.code_end(e),
                      img.code_end(e), e + MAX_FUNC)
            key = (e, end)
            if key not in decoded:
                insns = img.decode(e, end)
                starts = {o for o, *_r in insns}
                lo, hi = bisect.bisect_right(ptr_sorted, e), bisect.bisect_left(ptr_sorted, end)
                roots = [e] + [t for t in ptr_sorted[lo:hi] if t in starts]
                decoded[key] = (insns,) + img.walk(insns, roots)
            insns, reached, calls, fell = decoded[key]
            result[e] = (end, insns, reached, fell)
            for t in calls:
                if t not in entries:
                    new.add(t)
                    p = prologue_before(d, t)
                    if p is not None and img.in_code(p) and p not in entries:
                        new.add(p)
                        n_prologue += 1
        if not new:
            for e in order:
                end, insns, reached, _f = result[e]
                x = e
                for o, b, *_r in insns:
                    if o not in reached:
                        break
                    x = o + len(b)
                while x < end and d[x] == 0xCB:
                    x += 1
                if x < end and x not in rejected_adj and (
                        d[x] == 0xCF or x in ptr_targets
                        or (d[x] in (0xF8, 0xFA, 0xFC) and d[x + 1] == 0xFE)):
                    if img.ends_cleanly(x):
                        new.add(x)
                        n_adjacent += 1
                    else:
                        rejected_adj.add(x)
        if not new:
            # a `jmp` out of an entry's stretch that lands in no entry's reached
            # code (a vector, a tail jump) starts another entry
            everywhere = set()
            for e in order:
                everywhere |= result[e][2]
            for e in order:
                end, insns, reached, _f = result[e]
                for o, _b, mnem, ops in insns:
                    if o in reached and mnem == "jmp":
                        t = target_of(mnem, ops)
                        t = img.off(t) if t is not None else None
                        if (t is not None and not (e <= t < end) and t not in everywhere
                                and t not in entries and t not in rejected_adj):
                            if img.ends_cleanly(t):
                                new.add(t)
                                n_jumped += 1
                            else:
                                rejected_adj.add(t)
        if not new:
            break
        entries |= new

    order = sorted(entries)
    cpu_of = img.cpu
    for e in order:
        names.setdefault(cpu_of(e), f"func_{cpu_of(e):08X}")

    # per entry: the emitted prefix [e, x) and the nop padding after it
    blocks = {}
    for e in order:
        end, insns, reached, _fell = result[e]
        pre = []
        for ins in insns:
            if ins[0] not in reached:
                break
            pre.append(ins)
        x = pre[-1][0] + len(pre[-1][1]) if pre else e
        pad = x
        while pad < end and d[pad] == 0xCB:
            pad += 1
        blocks[e] = (end, pre, x, pad)

    # register-save entries
    for p, e in zip(order, order[1:]):
        if not names[cpu_of(e)].startswith("func_"):
            continue
        pre = blocks[p][1]
        if pre and blocks[p][2] == e and all(
                m == "movm" or (m == "add" and o.endswith(", sp") and o.startswith("-"))
                for _o, _b, m, o in pre):
            nm = names[cpu_of(p)] + "_entry"
            if nm not in names.values():
                names[cpu_of(e)] = nm

    # labels at every control-transfer target that is an emitted instruction start
    emitted = {}
    for e in order:
        for o, *_r in blocks[e][1]:
            emitted[o] = e
    taken = set(names.values()) | inc_names
    labels = {e: names[cpu_of(e)] for e in order}
    for o, nm in entry_marks.items():
        if o in emitted:
            labels[o] = nm
    for e in order:
        for o, b, mnem, ops in blocks[e][1]:
            t = target_of(mnem, ops)
            t = img.off(t) if t is not None else None
            if t is not None and t in emitted and t not in labels:
                owner = emitted[t]
                nm = f"{names[cpu_of(owner)]}_L{t - owner:x}"
                while nm in taken:
                    nm += "_"
                taken.add(nm)
                labels[t] = nm
    label_names = set(labels.values())

    def spell(o, b, mnem, ops):
        try:
            enc = ASM.encode(mnem, ops, cpu_of(o))
        except Exception:
            enc = None
        if enc == b:
            t = target_of(mnem, ops)
            t = img.off(t) if t is not None else None
            if t is not None and t in labels:
                ops = re.sub(r"^0x[0-9a-fA-F]+", labels[t], ops)
            elif dlab:
                def one(m):
                    v = int(m.group(1), 16)
                    nm = data_ref(v)
                    if nm is None:
                        return m.group(1)
                    used_data[nm.split("+")[0]] = v if "+" not in nm else v - int(nm.split("+")[1])
                    return nm
                ops = re.sub(r"\b(0x[0-9a-fA-F]{8})\b", one, ops)
            if all(n in taken or n in label_names for n in idents_of(ops) - REGS):
                return f"\t{mnem}\t{ops}" if ops else f"\t{mnem}"
        hexb = ", ".join(f"0x{x:02x}" for x in b)
        return f"\t.byte\t{hexb}\t# {mnem} {ops}".rstrip()

    L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#"] + [f"# {t}".rstrip() for t in a.title] + [
         "#",
         "# GENERATED by kn7000/tools/gen_image_s.py -- do not edit by hand; edit the",
         "# symbol files or the generator and regenerate (make program-src).",
         "",
         f".mnbase 0x{base:08x}",
         f'.include "{a.inc}"',
         f'.include "{a.labels_inc}"',
         ""]
    body = []
    cur, mnbase = 0, base
    n_insn = n_byte = conv_bytes = pad_bytes = 0
    defined = set()

    # typed data ranges: (lo, hi, kind)
    typed = [tuple(int(x, 0) for x in r.split(":")) + ("long",) for r in a.long_table]
    typed += [tuple(int(x, 0) for x in r.split(":")) + ("text",) for r in a.text]
    n_reflect = 0
    if a.reflection_tables:
        import gen_symbols as GS
        GS.PROGRAM_BASE = base
        GS._is_code = lambda v: img.off(v) is not None
        for co, _no, n in GS.find_tables(d, GS._ident_offsets(d)):
            if not img.in_code(co):
                typed.append((co, co + 4 * n, "long"))
                n_reflect += 1
    includes = []
    for r in a.data_include:
        lo, hi, path = r.split(":", 2)
        includes.append((int(lo, 0), int(hi, 0), path))
    typed = [t for t in typed if not any(lo <= t[0] < hi for lo, hi, _p in includes)]
    typed.sort()
    # the typed data region's labels: {cpu: name} and sorted (start, end, name) items
    dlab, ditems = {}, []
    if a.data_labels and os.path.exists(a.data_labels):
        for line in open(a.data_labels):
            if line.startswith(";"):
                continue
            ad, nm, sz = line.split()
            ad, sz = int(ad, 16), int(sz)
            dlab[ad] = nm
            if sz:
                ditems.append((ad, ad + sz, nm))
        ditems.sort()
    dstarts = [x[0] for x in ditems]
    taken |= set(dlab.values())

    def data_ref(v):
        if v in dlab:
            return dlab[v]
        i = bisect.bisect_right(dstarts, v) - 1
        if i >= 0 and ditems[i][0] < v < ditems[i][1]:
            return f"{ditems[i][2]}+{v - ditems[i][0]}"
        return None
    used_data = {}
    label_at = {cpu_of(o): nm for o, nm in labels.items()}
    # a --sym name outside the code ranges labels the typed data range it starts
    # (the .long rows that hold its address then print the name)
    data_labels = {}
    for lo, _hi, _k in typed:
        nm = names.get(base + lo)
        if nm is not None and not img.in_code(lo):
            data_labels[lo] = nm
            label_at[base + lo] = nm

    def emit_typed(lo, hi, kind):
        if kind == "long":
            for o in range(lo, hi, 4):
                w = struct.unpack_from("<I", d, o)[0]
                body.append(f"\t.long\t{label_at.get(w, f'0x{w:08x}')}")
        else:
            for o in range(lo, hi, 16):
                chunk = d[o:min(hi, o + 16)]
                txt = "".join(chr(c) if 32 <= c < 127 else "." for c in chunk)
                body.append("\t.byte\t" + ", ".join(f"0x{c:02x}" for c in chunk) + f'\t# "{txt}"')

    def fill(to):
        """.incbin_range from cur to `to`, switching .mnbase where a code range
        linked elsewhere starts or ends (labels after it need the right base),
        and emitting the typed data ranges."""
        nonlocal cur, mnbase
        while cur < to:
            inc = next((x for x in includes if x[0] <= cur < x[1]), None)
            if inc is not None:
                if cur != inc[0] or to < inc[1]:
                    sys.exit(f"gen_image_s: --data-include {inc[0]:#x}:{inc[1]:#x} cut at {cur:#x}..{to:#x}")
                if base != mnbase:
                    body.append(f".mnbase 0x{base:08x}")
                    mnbase = base
                body.append(f'.include "{inc[2]}"')
                cur = inc[1]
                continue
            r = img.rng(cur)
            t = next((t for t in typed if t[0] <= cur < t[1]), None)
            if r is None and t is not None:
                if base != mnbase:
                    body.append(f".mnbase 0x{base:08x}")
                    mnbase = base
                if cur in data_labels:
                    body.append(f"{data_labels[cur]}:")
                    defined.add(data_labels[cur])
                stop = min(to, t[1])
                emit_typed(cur, stop, t[2])
                cur = stop
                continue
            stop = to
            if r is None:
                nxt = [lo for lo, _h, _d in code if cur < lo < to] + \
                      [lo for lo, _h, _k in typed if cur < lo < to] + \
                      [lo for lo, _h, _p in includes if cur < lo < to]
                stop = min(nxt) if nxt else to
            else:
                stop = min(to, r[1])
            want = r[2] if r else base
            if want != mnbase:
                body.append(f".mnbase 0x{want:08x}"
                            + ("" if want == base else
                               f"   # this range is linked for 0x{cur + want:08x}"))
                mnbase = want
            prev = body[-1] if body else ""
            m = re.match(r'\.incbin_range .*, (0x[0-9a-f]+)$', prev)
            if m and int(m.group(1), 16) == cur:
                body[-1] = prev[:m.start(1)] + f"0x{stop:06x}"
            else:
                body.append(f".incbin_range {ROMQ}, 0x{cur:06x}, 0x{stop:06x}")
            cur = stop

    for e in order:
        end, pre, x, pad = blocks[e]
        fill(e)
        want = img.rng(e)[2]
        if want != mnbase:
            body.append(f".mnbase 0x{want:08x}"
                        + ("" if want == base else f"   # this range is linked for 0x{e + want:08x}"))
            mnbase = want
        body.append("")
        for o, b, mnem, ops in pre:
            if o in labels:
                body.append(f"{labels[o]}:")
                defined.add(labels[o])
            line = spell(o, b, mnem, ops)
            if line.startswith("\t.byte"):
                n_byte += 1
            else:
                n_insn += 1
            body.append(line)
        if not pre:
            body.append(f"{labels[e]}:")
            defined.add(labels[e])
        conv_bytes += x - e
        if pad > x:
            body.extend(["\tnop"] * (pad - x))
            pad_bytes += pad - x
        cur = pad
        fill(end)
    fill(len(d))
    body += ["", f".org 0x{len(d):06x}"]

    # names used as operands but not defined by a label here and not in the include
    used = set()
    for line in body:
        if line.startswith("\t") and not line.startswith("\t."):
            used |= idents_of(line.split("\t", 2)[-1])
    rev = {v: c for c, v in names.items()}
    rev.update({nm: cpu_of(o) for o, nm in labels.items()})
    rev.update(used_data)       # data labels the code uses: declared ahead too
    eq = sorted((n for n in (defined | used) - REGS - inc_names if n in rev), key=lambda n: (rev[n], n))
    LI = ["# Labels of " + a.out + " (generated by kn7000/tools/gen_image_s.py -- do not edit).",
          "# Entry names the generator made up (func_<ADDR>, <name>_entry) and local branch",
          "# targets (<entry>_L<offset>). Declaring them ahead lets kn7asm resolve every",
          "# reference in one pass; each label must land on its .equ.",
          ""] + [f".equ {n}, 0x{rev[n]:08x}" for n in eq]
    open(a.labels_inc, "w").write("\n".join(LI) + "\n")
    L.extend(body)
    open(a.out, "w").write("\n".join(L) + "\n")

    code_total = sum(hi - lo for lo, hi, _d in code)
    short = sum(1 for e in order if result[e][3] and (
        not result[e][1] or result[e][1][-1][0] + len(result[e][1][-1][1]) < result[e][0]))
    named = sum(1 for e in order if not names[cpu_of(e)].startswith("func_"))
    # <function>_entry register-save labels of named functions are derived from
    # their function's name (func_<ADDR>_entry ones count with the func_ entries)
    derived = sum(1 for e in order if names[cpu_of(e)].endswith("_entry")
                  and not names[cpu_of(e)].startswith("func_"))
    pieces = 0
    for line in body:
        m = re.match(r"\.incbin_range .*, (0x[0-9a-f]+), (0x[0-9a-f]+)$", line)
        if m and any(lo < int(m.group(2), 16) and int(m.group(1), 16) < hi for lo, hi, _d in code):
            pieces += 1
    stats = [f"image bytes                 {len(d)}",
             f"code-range bytes            {code_total}",
             f"entries                     {len(order)} ({named - derived} named, {derived} derived "
             f"<name>_entry, {len(order) - named} func_)",
             f"bytes emitted as code       {conv_bytes} ({100.0 * conv_bytes / len(d):.2f}% of image, "
             f"{100.0 * conv_bytes / code_total:.2f}% of code ranges)",
             f"instructions                {n_insn} (+{n_byte} .byte escapes)",
             f"nop padding bytes           {pad_bytes}",
             f"code-range bytes left binary {code_total - conv_bytes - pad_bytes} "
             f"(in {pieces} .incbin_range pieces)",
             f"local labels                {len(labels) - len(order)}",
             f"movm pointer targets rejected (paths do not end) {n_ptr_rejected}",
             f"entries found right after reached code          {n_adjacent} "
             f"({len(rejected_adj)} rejected, with jmp targets)",
             f"entries found as a jmp target                   {n_jumped}",
             f"prologues found in front of a call target       {n_prologue}",
             f"entries whose code runs into undecodable bytes   {short}",
             f"MILK reflection code tables typed as .long rows  {n_reflect}"]
    print(f"wrote {a.out}")
    print("\n".join(stats))
    if a.stats:
        open(a.stats, "w").write("\n".join(stats) + "\n")


if __name__ == "__main__":
    main()
