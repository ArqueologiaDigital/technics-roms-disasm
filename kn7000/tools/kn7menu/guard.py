#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# guard.py -- the program menu's build-time guards (the Makefile runs them before it writes KN7APP.BIN).
# Questions they answer, for menu.s and tramp.s:
#   1. Does any constant, label or operand name an address in IC23 (chip select CS1, 0x44000000-0x47FFFFFF,
#      and its uncached view 0x84000000-0x87FFFFFF: the battery-backed panel memories, repeating every
#      256 KB), in the user-memory pools 0x50180000-0x50297FFF (and 0x90180000-...), or in the loader's
#      resident area 0x502B8000-0x502B9FFF (and 0x902B8000-...)? In the loader's area only a load
#      `mov (SVC + SV_x), REG` from the service table is allowed, and only of the services the menu needs:
#      SV_MAGIC, SV_ABI, SV_FOUND, SV_MSCOUNT and SV_RAWREAD. So the menu cannot even name a routine that
#      writes the card (SV_WRITE, SV_RAWWRITE, SV_MKDIR) or changes its folder (SV_SETPATH), nor write the
#      loader's variables or table. (As kn5000-anotherworld tools/ic23_guard.py, from which this is
#      adapted: it assembles with the toolchain's own xapasm and records every value an expression gives.)
#   2. Does any routine entered with `call X, 0, 0` call another before it has made a frame? (The return
#      address sits at (sp): a nested call would overwrite it. kn5000-anotherworld tools/leafcheck.py.)
#   3. Does the memory map (menu.inc) keep to the RAM a converter may use, 0x502BA000-0x50379FFF, off the
#      firmware's mailbox page and the loader's area, without overlaps? Does the menu's image end below
#      IMAGE_MAX, the trampoline's below T_CODE_MAX, the menu's variables and buffers below the launch
#      block (kn7cnv.inc LB_ADDR), STAGE below the mailbox page?
#   python3 -I guard.py TOOLS_DIR LOADER_DIR BUILD_DIR [--selftest test/guard_selftest.s]
# (TOOLS_DIR holds xapasm.py; BUILD_DIR the generated includes, menu.bin and tramp.bin.) Prints each finding
# and a last line "guard: clean" or "guard: N problem(s)"; exit status 0 only when clean.
import os
import re
import sys

tools, loader_dir, build = sys.argv[1:4]   # (--selftest FILE: scan FILE alone, which must hold references)
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, tools)
import xapasm  # noqa: E402

FORBIDDEN = [(0x44000000, 0x48000000, "CS1: IC23, the backup SRAM (panel memories)"),
             (0x84000000, 0x88000000, "CS1 uncached view: IC23"),
             (0x50180000, 0x50298000, "user-memory pool (kept across power-off)"),
             (0x90180000, 0x90298000, "user-memory pool, uncached view"),
             (0x502B8000, 0x502BA000, "the loader's resident area"),
             (0x902B8000, 0x902BA000, "the loader's resident area, uncached view")]
ALLOWED_SVC = ("SV_MAGIC", "SV_ABI", "SV_FOUND", "SV_MSCOUNT", "SV_RAWREAD")
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


C = consts([os.path.join(loader_dir, "kn7cnv.inc"), os.path.join(here, "menu.inc")])
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


if "--selftest" in sys.argv:          # test/guard_selftest.s: every planted reference must be found
    st = sys.argv[sys.argv.index("--selftest") + 1]
    scan(st)
    for p in problems:
        print("guard: " + p)
    print(f"guard: {st}: {len(problems)} reference(s) found")
    sys.exit(1 if problems else 0)
n_menu = scan(os.path.join(here, "menu.s"))
n_tramp = scan(os.path.join(here, "tramp.s"))
n_leaf = leafcheck(["menu.s", "menu_card.s", "menu_draw.s", "tramp.s"])

# 3. the memory map
lo, hi = C["APP_BASE"], 0x5037A000          # the converter's RAM (kn5000-anotherworld README-CNV.md, "Memory")
mb, mbe = 0x5031B000, 0x5031C000             # the firmware's mailbox page (MAILBOX = 0x5031BC00)
size = os.path.getsize(os.path.join(build, "menu.bin"))
tsize = os.path.getsize(os.path.join(build, "tramp.bin"))
regions = [
    ("menu image", C["APP_BASE"], C["APP_BASE"] + size),
    ("M_VARS", C["M_VARS"], C["M_VARS"] + 0x400),
    ("PROG_TAB", C["PROG_TAB"], C["PROG_TAB"] + C["MAX_PROG"] * C["PR_LEN"]),
    ("ORDER", C["ORDER"], C["ORDER"] + 4 * C["MAX_PROG"]),
    ("WORKBUF", C["WORKBUF"], C["WORKBUF"] + 512 * C["WORK_SECS"]),
    ("FATBUF", C["FATBUF"], C["FATBUF"] + 512),
    ("SECBUF", C["SECBUF"], C["SECBUF"] + 512),
    ("TEXTBUF", C["TEXTBUF"], C["TEXTBUF"] + C["MAN_MAX"] + 1),
    ("LINEBUF", C["LINEBUF"], C["LINEBUF"] + 0x100),
    ("LFNBUF", C["LFNBUF"], C["LFNBUF"] + 0x100),
    ("BMPBUF", C["BMPBUF"], C["BMPBUF"] + C["BMP_MAX"]),
    ("CRCTAB", C["CRCTAB"], C["CRCTAB"] + 0x400),
    ("launch block", C["LB_ADDR"], C["LB_ADDR"] + C["LB_LEN"]),
    ("STAGE", C["STAGE"], C["STAGE"] + C["STAGE_MAX"]),
    ("ICONS", C["ICONS"], C["ICONS"] + C["MAX_PROG"] * C["ICON_BYTES"]),
    ("T_SLED", C["T_SLED"], C["T_SLED"] + C["SLED_LEN"]),
    ("T_CODE", C["T_CODE"], C["T_CODE"] + tsize),
    ("T_DATA", C["T_DATA"], C["T_DATA"] + C["TD_LEN"]),
]
for name, a, b in regions:
    if a < lo or b > hi:
        problems.append(f"map: {name} 0x{a:08X}-0x{b - 1:08X} is outside 0x{lo:08X}-0x{hi - 1:08X}")
    if a < mbe and b > mb:
        problems.append(f"map: {name} 0x{a:08X}-0x{b - 1:08X} overlaps the mailbox page")
srt = sorted(regions, key=lambda r: r[1])
for (n1, a1, b1), (n2, a2, b2) in zip(srt, srt[1:]):
    if a2 < b1:
        problems.append(f"map: {n1} and {n2} overlap")
if C["APP_BASE"] + size > C["IMAGE_MAX"]:
    problems.append(f"map: the menu's image ({size} bytes) reaches IMAGE_MAX")
if tsize > C["T_CODE_MAX"] or C["T_CODE"] + C["T_CODE_MAX"] > C["T_DATA"]:
    problems.append(f"map: the trampoline ({tsize} bytes) does not fit before T_DATA")
if C["AREA_END"] > C["LB_ADDR"] or C["LB_ADDR"] + C["LB_LEN"] != C["CNV_END"]:
    problems.append("map: the menu's buffers reach the launch block, or the block is not the area's last 256 bytes")
if C["STAGE_MAX"] != C["LB_ADDR"] - C["APP_BASE"]:
    problems.append("map: STAGE_MAX is not what fits below the launch block")
if C["TD_MSG"] + 96 > C["TD_LEN"] or C["TD_LB"] + C["LB_LEN"] > C["TD_MSG"]:
    problems.append("map: the trampoline's data block fields overlap")
for p in problems:
    print("guard: " + p)
print(f"guard: menu.s {n_menu} and tramp.s {n_tramp} service-table load(s) allowed ({', '.join(ALLOWED_SVC)}); "
      f"{n_leaf} call targets checked; {len(regions)} regions in 0x{lo:08X}-0x{hi - 1:08X}")
print(f"guard: {len(problems)} problem(s)" if problems else "guard: clean")
sys.exit(1 if problems else 0)
