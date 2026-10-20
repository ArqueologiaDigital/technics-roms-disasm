#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# guard.py -- DSPTONE's build-time guards (the Makefile runs them before it writes KN7APP.BIN), adapted from
# ../kn7menu/guard.py. Questions they answer for dsptone.s:
#   1. Does any constant, label or operand name an address in IC23 (CS1, 0x44000000-0x47FFFFFF and its uncached
#      view 0x84000000-0x87FFFFFF: the battery-backed panel memories), in the user-memory pools
#      0x50180000-0x50297FFF (and 0x90180000-...), in the loader's resident area 0x502B8000-0x502B9FFF (and
#      0x902B8000-...), or the effects DSP's host port 0x98000000 / 0x9C000000 itself (DSPTONE talks to the DSP
#      only through the firmware's own routines)? In the loader's area only a load `mov (SVC + SV_x), REG` from
#      the service table is allowed, and only of SV_MAGIC, SV_ABI, SV_FOUND, SV_MSCOUNT and SV_BUILD: DSPTONE
#      cannot even name a routine that writes the card (SV_WRITE, SV_RAWWRITE, SV_MKDIR, SV_SETPATH) or opens a
#      file, nor write the loader's variables or table.
#   2. Does any routine entered with `call X, 0, 0` call another before it has made a frame? (The return
#      address sits at (sp): a nested call would overwrite it. kn5000-anotherworld tools/leafcheck.py.)
#   3. Does the memory map (dsptone.inc) keep to the application area 0x502BA000-0x502E7EFF, below the launch
#      block, without overlaps, and does the image end below IMAGE_MAX?
#   python3 -I guard.py TOOLS_DIR LOADER_DIR BUILD_DIR
# Prints each finding and a last line "guard: clean" or "guard: N problem(s)"; exit status 0 only when clean.
import os
import re
import sys

tools, loader_dir, build = sys.argv[1:4]
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, tools)
import xapasm  # noqa: E402

FORBIDDEN = [(0x44000000, 0x48000000, "CS1: IC23, the backup SRAM (panel memories)"),
             (0x84000000, 0x88000000, "CS1 uncached view: IC23"),
             (0x50180000, 0x50298000, "user-memory pool (kept across power-off)"),
             (0x90180000, 0x90298000, "user-memory pool, uncached view"),
             (0x502B8000, 0x502BA000, "the loader's resident area"),
             (0x902B8000, 0x902BA000, "the loader's resident area, uncached view"),
             (0x98000000, 0x98000004, "the DSP host port's index latch (only through the firmware's routines)"),
             (0x9C000000, 0x9C000004, "the DSP host port's data register (only through the firmware's routines)")]
ALLOWED_SVC = ("SV_MAGIC", "SV_ABI", "SV_FOUND", "SV_MSCOUNT", "SV_BUILD")
problems = []


def consts(paths):
    syms = {}
    for p in paths:
        for line in open(p):
            m = re.match(r"\s*\.equ\s+(\w+)\s*,\s*([^#]+)", line)
            if not m:
                continue
            expr = m.group(2).strip()
            try:
                py = re.sub(r"0x[0-9A-Fa-f]+|\d+|[A-Za-z_]\w*",
                            lambda t: t.group(0) if t.group(0)[0].isdigit() else str(syms[t.group(0)]), expr)
                syms[m.group(1)] = int(eval(py.replace("/", "//"), {"__builtins__": {}}))
            except (KeyError, SyntaxError):
                pass
    return syms


C = consts([os.path.join(loader_dir, "kn7cnv.inc"), os.path.join(here, "dsptone.inc")])
svc_ok = {C["SVC"] + C[k] for k in ALLOWED_SVC}


def bad(v):
    v &= 0xFFFFFFFF
    for lo, hi, what in FORBIDDEN:
        if lo <= v < hi:
            return what
    return None


def scan(src):
    class Guard(xapasm.XapAsm):
        def __init__(self, incdirs):
            super().__init__(incdirs)
            self.hits, self.where, self.raw, self.svc = [], "?", "", set()

        def _file(self, path):
            for n, raw in enumerate(open(path), 1):
                self.where, self.raw = f"{os.path.basename(path)}:{n}", raw
                try:
                    self._line(raw, os.path.dirname(os.path.abspath(path)))
                except (xapasm.AsmError, xapasm.enc.EncError) as e:
                    raise xapasm.AsmError(f"{path}:{n}: {e}") from None

        def eval(self, expr):
            v = super().eval(expr)
            what = bad(v) if self.final else None
            if what:
                code = self.raw.split("#")[0].strip()
                code = re.sub(r"^[A-Za-z_][\w.]*:", "", code).strip()
                op = code.split(None, 1)[0].lower() if code else ""
                load = re.fullmatch(r"mov\s+\(\s*" + re.escape(expr.strip()) + r"\s*\)\s*,\s*[ad][0-3]", code)
                if op == ".equ":
                    pass                                 # a name of the contract (SVC, LOADER_VARS, ...)
                elif load and (v & 0xFFFFFFFF) in svc_ok:
                    self.svc.add(self.where)
                else:
                    self.hits.append((self.where, expr.strip(), v, what))
            return v

    g = Guard([here, build, loader_dir])
    g.assemble(src)
    seen = set()
    for where, expr, v, what in g.hits:
        if (where, v) not in seen:
            seen.add((where, v))
            problems.append(f"{where}: {expr} = 0x{v & 0xFFFFFFFF:08X} -> {what}")
    for k, v in g.syms.items():
        if k in g.labels and bad(v):
            problems.append(f"{src}: label {k} = 0x{v:08X} -> {bad(v)}")
    return len(g.svc)


def leafcheck(files):
    label = re.compile(r"^([A-Za-z_][\w.]*):")
    call = re.compile(r"^\s*call\s+([A-Za-z_][\w.]*)\s*,\s*(?:0|\[\])\s*,\s*0\b")
    anycall = re.compile(r"^\s*calls?\s")
    frame = re.compile(r"^\s*(movm\s+\[[^\]]*\]\s*,\s*\(sp\)|add\s+-\w+\s*,\s*sp)")
    lines = [(f, n + 1, l.split("#")[0].rstrip()) for f in files for n, l in enumerate(open(os.path.join(here, f)))]
    targets = {m.group(1) for _, _, l in lines if (m := call.match(l))}
    routine, framed = None, False
    for f, n, l in lines:
        m = label.match(l)
        if m and m.group(1) in targets:
            routine, framed = m.group(1), False
            continue
        if routine is None:
            continue
        if frame.match(l):
            framed = True
        elif anycall.match(l) and not framed:
            problems.append(f"{f}:{n}: {routine} is entered with `call ..., 0, 0` and calls before a frame: {l.strip()}")
    return len(targets)


n_svc = scan(os.path.join(here, "dsptone.s"))
n_leaf = leafcheck(["dsptone.s"])

# 3. the memory map
lo, hi = C["APP_BASE"], C["LB_ADDR"]          # the application area, less the launch block (kn7cnv.inc)
size = os.path.getsize(os.path.join(build, "dsptone.bin"))
regions = [
    ("image", C["APP_BASE"], C["APP_BASE"] + size),
    ("M_VARS", C["M_VARS"], C["M_VARS"] + 0x400),
    ("LINES", C["LINES"], C["LINES"] + C["NLINES"] * C["LINE_LEN"]),
    ("DECBUF", C["DECBUF"], C["DECBUF"] + 0x20),
    ("RBBUF", C["RBBUF"], C["RBBUF"] + 0x400),
]
for name, a, b in regions:
    if a < lo or b > hi:
        problems.append(f"map: {name} 0x{a:08X}-0x{b - 1:08X} is outside 0x{lo:08X}-0x{hi - 1:08X}")
srt = sorted(regions, key=lambda r: r[1])
for (n1, a1, b1), (n2, a2, b2) in zip(srt, srt[1:]):
    if a2 < b1:
        problems.append(f"map: {n1} and {n2} overlap")
if C["APP_BASE"] + size > C["IMAGE_MAX"]:
    problems.append(f"map: the image ({size} bytes) reaches IMAGE_MAX")
if C["AREA_END"] > C["LB_ADDR"] or C["RBBUF"] + 0x400 > C["AREA_END"]:
    problems.append("map: the buffers reach the launch block, or RBBUF passes AREA_END")
# the readbacks: the largest is the sine table, 256 DM words of 4 bytes; the program, 6 bytes a word
equ = consts([os.path.join(build, "dsp_equ.inc")])
if max(256 * 4, equ["DSP_CODE_WORDS"] * 6) > 0x400:
    problems.append("map: a readback does not fit RBBUF")
for p in problems:
    print("guard: " + p)
print(f"guard: dsptone.s {n_svc} service-table load(s) allowed ({', '.join(ALLOWED_SVC)}); "
      f"{n_leaf} call targets checked; {len(regions)} regions in 0x{lo:08X}-0x{hi - 1:08X}; image {size} bytes")
print(f"guard: {len(problems)} problem(s)" if problems else "guard: clean")
sys.exit(1 if problems else 0)
