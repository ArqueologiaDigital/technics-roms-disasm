#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""code_in_data.py -- is any code of an MN10300 tree emitted as data?

QUESTION ANSWERED
-----------------
"In each MN10300 tree of this repository (the four KN7000 program builds, the
KN6000, KN6500, KN2400 and the HD-SX3 plug-in), does any instruction, label or
code pointer say that bytes the source emits as DATA (an opaque or generic
`.incbin_range`, reader rows, typed records) are really code?"

It assembles each tree with tools/kn7asm.py's own Assembler (no output file is
written) and records, for the final pass, which output bytes come from an
instruction line and which from a data directive, with the CPU address each
byte has (`.mnbase`).  Then it reports, per tree:

  T     a `call` / `calls` / `jmp` / `bra` / `bCC` whose target is a data byte;
  T-mid the same, landing inside an instruction (not on its first byte);
  F     an instruction that can fall through (not ret / retf / rets / rti / jmp /
        bra / `jmp (aN)`) followed directly by data: code running on into bytes
        the source calls data;
  L     a label named like code (func_*, loc_*, *_entry) that the source defines
        on a data byte;
  P     a `.long` whose operand is a symbol of that kind (or any symbol) and whose
        value lands on a data byte that a T / L case already shows is code, or in
        the middle of an instruction.

Targets and pointers outside the image (RAM, the host program, other chips)
are ignored.  Each case names the data piece (the label before it, its file and
line, and its census marker: `opaque -- <kind>`, `generic` for an unmarked
`.incbin_range`, or `typed`).

Exit status 1 when any tree has a T, T-mid, F or L case, so a gate can use it.

RUN (from the repository root; a tree whose sources or reference image are
missing is skipped with a note)
    python3 kn7000/notes/code-island-probes/code_in_data.py            # all trees
    python3 kn7000/notes/code-island-probes/code_in_data.py kn7000-941 kn6000
    python3 kn7000/notes/code-island-probes/code_in_data.py --list     # tree names

Takes about a minute per KN7000 build (it is a full assembly).
"""

import argparse
import bisect
import os
import re
import sys
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
import kn7asm  # noqa: E402

# name -> (tree directory, top-level source, kn7asm --labels seed or None)
TREES = {
    "kn7000-941":    ("kn7000", "src/program.s", "build/kn7000_program.labels"),
    "kn7000-sp7001": ("kn7000", "src/sp7001/program.s", "build/kn7000_program_sp7001.labels"),
    "kn7000-b935":   ("kn7000", "src/b935/program.s", "build/kn7000_program_b935.labels"),
    "kn7000-b893":   ("kn7000", "src/b893/program.s", "build/kn7000_program_b893.labels"),
    "kn6000":        ("kn6000", "src/program.s", None),
    "kn6500":        ("kn6500", "src/program.s", None),
    "kn2400":        ("kn2400", "src/program.s", None),
    "hdsx3":         ("hdsx3", "src/program.s", None),
}

BRANCH = re.compile(r"^(call|calls|jmp|bra|b(?:eq|ne|gt|ge|le|lt|hi|cc|cs|ls|vc|vs|nc|ns))$")
NOFALL = {"ret", "retf", "rets", "rti", "jmp", "bra"}
# the generators' names for code: func_<ADDR>, loc_<ADDR>, <function>_entry, <entry>_L<hex>
# (gen_image_s.py); not the data generator's func_<ADDR>_Table / _Var / _Records
CODE_NAME = re.compile(r"^(?:func|loc)_[0-9A-F]{8}$|_entry$|_entry_L[0-9a-f]+$|^func_[0-9A-F]{8}_L[0-9a-f]+$")
DATA_OPS = {".byte", ".word", ".long", ".be16", ".be24", ".be32", ".ascii", ".asciz",
            ".space", ".align", ".incbin", ".incbin_range"}


class Recorder(kn7asm.Assembler):
    """kn7asm's Assembler, noting where each instruction and data line put its bytes."""

    def start_pass(self):
        super().start_pass()
        self.insns = []          # (off, end, cpu, mnemonic, resolved operands, file, line)
        self.data = []           # (off, end, cpu, op, file, line)
        self.longs = []          # (off, value, operand text, file, line)
        self.zstart = []

    def do_line(self, label, op, rest, args, depth=0):
        if op is None or self.zlib_stack and op != ".endzlib":
            return super().do_line(label, op, rest, args, depth)
        start, base = len(self.out), self.mn_base
        if op == ".zlib":
            self.zstart.append((start, base))
        mnemonic = not op.startswith(".") and op not in self.macros
        super().do_line(label, op, rest, args, depth)
        ops = self.resolve_operands(rest) if mnemonic else None
        end = len(self.out)
        where = (self.cur_file, self.cur_line)
        if mnemonic:
            self.insns.append((start, end, base + start, op, ops) + where)
        elif op == ".endzlib":
            zs, zb = self.zstart.pop()
            self.data.append((zs, end, zb + zs, op) + where)
        elif op in self.macros:
            if end > start:
                self.data.append((start, end, base + start, op) + where)
        elif op in DATA_OPS and end > start:
            self.data.append((start, end, base + start, op) + where)
            if op == ".long":
                for i, a in enumerate(args):
                    if re.search(r"[A-Za-z_]", a.replace("0x", "")):
                        self.longs.append((start + 4 * i, self.evaluate(a), a.strip()) + where)


class Census:
    def __init__(self, asm, base_dir):
        self.asm, self.base_dir = asm, base_dir
        n = len(asm.out)
        self.kind = bytearray(n)              # 0 none, 1 data, 2 insn start, 3 insn body
        for off, end, *_ in asm.data:
            self.kind[off:end] = b"\1" * (end - off)
        self.insn_at = {}
        for rec in asm.insns:
            off, end = rec[0], rec[1]
            if end > off:
                self.kind[off] = 2
                self.kind[off + 1:end] = b"\3" * (end - off - 1)
                self.insn_at[off] = rec
        # CPU -> offset: runs of bytes with one delta (cpu - off)
        segs = sorted((rec[0], rec[1], rec[2] - rec[0]) for rec in asm.insns + asm.data if rec[1] > rec[0])
        merged = []
        for off, end, delta in segs:
            if merged and merged[-1][2] == delta and off <= merged[-1][1]:
                merged[-1][1] = max(merged[-1][1], end)
            else:
                merged.append([off, end, delta])
        self.by_cpu = sorted((off + delta, end + delta, off) for off, end, delta in merged)
        self.cpu_lo = [s[0] for s in self.by_cpu]
        self.data_sorted = sorted(asm.data)
        self.data_lo = [r[0] for r in self.data_sorted]
        self.lines = {}
        self.label_at = {}
        for nm, a in asm.labels.items():
            self.label_at.setdefault(a, []).append(nm)
        self.label_cpus = sorted(self.label_at)

    def off_of(self, cpu):
        i = bisect.bisect_right(self.cpu_lo, cpu) - 1
        if i >= 0 and cpu < self.by_cpu[i][1]:
            return cpu - self.by_cpu[i][0] + self.by_cpu[i][2]
        return None

    def cpu_of(self, off):
        for lo, hi, o in self.by_cpu:
            if o <= off < o + hi - lo:
                return lo + off - o
        return None

    def raw(self, path, line):
        path = path if os.path.isabs(path) else os.path.join(self.base_dir, path)
        if path not in self.lines:
            with open(path, "rb") as f:
                self.lines[path] = f.read().split(b"\n")
        L = self.lines[path]
        return L[line - 1].decode("latin-1") if 0 < line <= len(L) else ""

    def piece(self, off):
        """The data line holding offset off: (label before it, file:line, marker)."""
        i = bisect.bisect_right(self.data_lo, off) - 1
        while i >= 0 and not (self.data_sorted[i][0] <= off < self.data_sorted[i][1]):
            i -= 1
        if i < 0:
            return ("?", "?", "?")
        o, e, cpu, op, path, line = self.data_sorted[i]
        marker = "typed"
        for k in (0, 1, 2):
            t = self.raw(path, line - k)
            m = re.search(r"census: (opaque -- [\w-]+|generated|generic)", t)
            if m:
                marker = m.group(1)
                break
            if k and not t.lstrip().startswith("#"):
                break
        if marker == "typed" and op == ".incbin_range":
            marker = "generic"
        j = bisect.bisect_right(self.label_cpus, self.cpu_of(off) or 0) - 1
        lab = self.label_at[self.label_cpus[j]][0] if j >= 0 else "?"
        lab_cpu = self.label_cpus[j] if j >= 0 else 0
        return (f"{lab}+{(self.cpu_of(off) or 0) - lab_cpu:#x}", f"{self.rel(path)}:{line}", marker)

    def rel(self, path):
        return os.path.relpath(path if os.path.isabs(path) else os.path.join(self.base_dir, path), ROOT)

    def run(self):
        cases = []
        asm = self.asm
        for off, end, cpu, mn, ops, path, line in asm.insns:
            if BRANCH.match(mn) and ops and not ops.startswith("("):
                m = re.match(r"\s*(0x[0-9a-fA-F]+|\d+)", ops)
                if not m:
                    continue
                t = int(m.group(1), 0)
                to = self.off_of(t)
                if to is None:
                    continue
                if self.kind[to] == 1:
                    cases.append(("T", t, f"{mn} at {cpu:#010x}", self.piece(to)))
                elif self.kind[to] == 3:
                    cases.append(("T-mid", t, f"{mn} at {cpu:#010x}", ("", "", "")))
            if mn not in NOFALL and end < len(self.kind) and self.kind[end] == 1:
                cases.append(("F", cpu + end - off, f"{mn} {ops} at {cpu:#010x} runs on", self.piece(end)))
        for nm, a in asm.labels.items():
            o = self.off_of(a)
            if o is not None and o < len(self.kind) and self.kind[o] == 1 and CODE_NAME.search(nm):
                cases.append(("L", a, f"label {nm}", self.piece(o)))
        code_data = {c[1] for c in cases if c[0] in ("T", "L", "F")}
        for off, v, txt, path, line in asm.longs:
            o = self.off_of(v)
            if o is None or o >= len(self.kind):
                continue
            if self.kind[o] == 3:
                cases.append(("P", v, f".long {txt} (mid-instruction) at {self.rel(path)}:{line}", ("", "", "")))
            elif self.kind[o] == 1 and (v in code_data or CODE_NAME.search(txt)):
                cases.append(("P", v, f".long {txt} at {self.rel(path)}:{line}", self.piece(o)))
        # one line per (kind, address): the first source and how many there are
        grouped = {}
        for c in cases:
            g = grouped.setdefault((c[0], c[1]), [c, 0])
            g[1] += 1
        out = [(k, a, what + (f" (+{n - 1} more)" if n > 1 else ""), pc)
               for (k, a), ((_k, _a, what, pc), n) in grouped.items()]
        out.sort(key=lambda c: (c[1], c[0]))
        return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("trees", nargs="*", help="tree names (default: all)")
    ap.add_argument("--list", action="store_true", help="print the tree names")
    a = ap.parse_args()
    if a.list:
        print("\n".join(TREES))
        return 0
    bad = 0
    for name in a.trees or TREES:
        tdir, src, seed = TREES[name]
        base = os.path.join(ROOT, tdir)
        if not os.path.exists(os.path.join(base, src)):
            print(f"== {name}: {src} missing, skipped")
            continue
        t0 = time.time()
        asm = Recorder(base)
        if seed and os.path.exists(os.path.join(base, seed)):
            asm.seed(os.path.join(base, seed))
        cwd = os.getcwd()
        os.chdir(base)
        try:
            asm.assemble(src)
        except kn7asm.AsmError as e:
            print(f"== {name}: does not assemble: {asm.cur_file}:{asm.cur_line}: {e}")
            bad = 1
            continue
        except OSError as e:
            print(f"== {name}: skipped ({e})")
            continue
        finally:
            os.chdir(cwd)
        c = Census(asm, base)
        cases = c.run()
        n_code = sum(1 for k in c.kind if k in (2, 3))
        n_data = sum(1 for k in c.kind if k == 1)
        counts = {k: sum(1 for x in cases if x[0] == k) for k in ("T", "T-mid", "F", "L", "P")}
        # (counts are distinct addresses)
        print(f"== {name}: {len(asm.insns)} instructions ({n_code} B), {n_data} B data; "
              + ", ".join(f"{k} {v}" for k, v in counts.items()) + f"  [{time.time() - t0:.0f} s]")
        for kind, addr, what, (lab, where, marker) in cases:
            print(f"  {kind:5s} {addr:#010x}  {what}" + (f"  -> {lab} ({marker}, {where})" if where else ""))
        if counts["T"] or counts["T-mid"] or counts["F"] or counts["L"]:
            bad = 1
    return bad


if __name__ == "__main__":
    sys.exit(main())
