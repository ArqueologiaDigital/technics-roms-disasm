#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# itron_stubs.py -- which of program 941's micro-ITRON entry stubs is which of program 942's
# exported kernel services?
#
# Question it answers: "is the address tools/port_symbols.py gave a kernel service in 941 the
# same service?" The library's entry stubs are near-identical runs of bytes, so the offset map
# can align a name with the wrong stub. On 2026-10-18 it had put ext_tsk on 941's sta_tsk, which
# a style converter starting a task depends on (technics-anotherworld kn7000/README-CNV.md).
#
# Every stub has one shape: `add -4, sp`, `mov d1, (0, sp)`, `movhu (0x50380d0c), d1`, ...,
# `mov N, d2` (N = 4 + 4 x the argument count), `mov RESUME, a2`, `jmp DISPATCH`; at RESUME a
# `call SERVICE` enters the routine that does the work. Two stubs are the same service when
# their SERVICE routines have the same instructions up to the first return, with absolute ROM
# and library addresses masked. Each library is disassembled with MAME's unidasm ($UNIDASM).
#
# Prints, per 942 stub: its exported name, argument count, the 941 stub(s) with the same
# service routine, and what the ported .sym says. --fix rewrites the ported .sym so each
# exported kernel name sits on its twin, or is commented out when 941 has no single twin.
#
#   python3 tools/itron_stubs.py baserom/kn7000_program_sp7001.rom 0x3BA785 \
#       baserom/kn7000_program.rom 0x3B8FD1 kn7000_sp7001_exports.sym \
#       kn7000_exports_from_942.sym [--fix]
import argparse
import collections
import os
import re
import subprocess

LIB = 0x4C000000
LIB_LEN = 0x40000
PAT = re.compile(r"^([0-9a-f]{8}):\s(?:[0-9a-f]{2} )+\s*(\S.*)$")
UNIDASM = os.environ.get("UNIDASM", "../../mame-sony-video/unidasm")


def listing(rom, base):
    data = open(rom, "rb").read()[base:base + LIB_LEN]
    tmp = os.path.join(os.environ.get("TMPDIR", "."), f"itron_stubs_{os.getpid()}.bin")
    try:
        open(tmp, "wb").write(data)
        txt = subprocess.run([UNIDASM, tmp, "-arch", "mn10300", "-basepc", hex(LIB)],
                             capture_output=True, text=True, check=True).stdout
    finally:
        os.remove(tmp)
    ins = [(int(m.group(1), 16), m.group(2).strip()) for l in txt.splitlines() if (m := PAT.match(l))]
    return ins, {a: i for i, (a, _) in enumerate(ins)}


def norm(t):
    return re.sub(r"0x4[8c][0-9a-f]{6}", "ADDR", re.sub(r"\s+", " ", t))


def stubs(ins, at):
    """{stub address: (argument count, service routine's normalised instructions)}"""
    out = {}
    for i, (a, t) in enumerate(ins):
        if not (t == "add     -4, sp" and i + 2 < len(ins)
                and ins[i + 2][1].startswith("movhu   (0x50380d0c), d1")):
            continue
        n = res = None
        for _, u in ins[i + 3:i + 30]:
            if (m := re.match(r"mov\s+(0x[0-9a-f]+|\d+), d2$", u)):
                n = int(m.group(1), 0)
            if (m := re.match(r"mov\s+(0x4c[0-9a-f]{6}), a2$", u)):
                res = int(m.group(1), 16)
                break
        if n is None or res not in at:
            continue
        svc = next((int(m.group(1), 16) for _, u in ins[at[res]:at[res] + 6]
                    if (m := re.match(r"call\s+(0x4c[0-9a-f]{6})", u))), None)
        if svc not in at:
            continue
        body = []
        for _, u in ins[at[svc]:at[svc] + 400]:
            body.append(norm(u))
            if re.match(r"(ret|retf|rets)\b", u):
                break
        out[a] = ((n - 4) // 4, tuple(body))
    return out


def names(path):
    return {int(m.group(1), 16): m.group(2) for l in open(path)
            if (m := re.match(r"^0x(4C[0-9A-F]{6})\s+(\w+)", l))}


ap = argparse.ArgumentParser(description="name 941 kernel entry stubs from 942 exports by service body")
ap.add_argument("old_rom")
ap.add_argument("old_lib", type=lambda v: int(v, 0))
ap.add_argument("new_rom")
ap.add_argument("new_lib", type=lambda v: int(v, 0))
ap.add_argument("old_exports")
ap.add_argument("ported")
ap.add_argument("--fix", action="store_true")
args = ap.parse_args()

ins_942, at_942 = listing(args.old_rom, args.old_lib)
ins_941, at_941 = listing(args.new_rom, args.new_lib)
s_old = stubs(ins_942, at_942)
s_new = stubs(ins_941, at_941)
twins = {}
for a, (_, body) in s_new.items():
    twins.setdefault(body, []).append(a)
exported = names(args.old_exports)
ported = names(args.ported)
want = {}                       # exported kernel name -> (942 address, 941 address or None)
print(f"{'942':10}  {'name':8}  args  {'941 twin':10}  ported .sym")
for a, (n, body) in sorted(s_old.items()):
    hit = twins.get(body, [])
    nm = exported.get(a)
    if nm:
        want[nm] = (a, hit[0] if len(hit) == 1 else None)
    said = " ".join(f"0x{k:08X}" for k, v in ported.items() if v == nm) if nm else ""
    print(f"0x{a:08X}  {nm or '-':8}  {n:4}  {', '.join(f'0x{h:08X}' for h in hit) or '-':10}  "
          f"{said or ('(unported)' if nm else '')}")
# The exported kernel services that are not entry stubs (ena_int, get_tid, ...)
# are called directly: the same check on their own bodies, to the first return.
# A name moves only to a 941 routine whose body equals its 942 routine's when no
# other 941 or 942 routine start has that body; a name whose 941 address is that
# twin of another name, and that has no twin of its own, is unported.


def starts_of(ins):
    out = {a for a, t in ins if t.startswith("movm")}
    for _, t in ins:
        if (m := re.match(r"calls?\s+(0x4c[0-9a-f]{6})", t)):
            out.add(int(m.group(1), 16))
    return out


def body_at(ins, at, a):
    body = []
    for _, u in ins[at[a]:at[a] + 400]:
        body.append(norm(u))
        if re.match(r"(ret|retf|rets)\b", u):
            return tuple(body)
    return None


bodies_941 = collections.defaultdict(list)
for a in starts_of(ins_941):
    if a in at_941 and (b := body_at(ins_941, at_941, a)) and len(b) >= 8:
        bodies_941[b].append(a)
bodies_942 = collections.defaultdict(list)
for a in starts_of(ins_942):
    if a in at_942 and (b := body_at(ins_942, at_942, a)):
        bodies_942[b].append(a)
direct = {}
for a, nm in sorted(exported.items()):
    if nm in want or a not in at_942:
        continue
    b = body_at(ins_942, at_942, a)
    hit = bodies_941.get(b, []) if b else []
    if len(hit) == 1 and len(bodies_942.get(b, [])) == 1:
        direct[nm] = (a, hit[0])
claimed = {new: nm for nm, (_, new) in direct.items()}
for a, nm in sorted(exported.items()):
    if nm in want or nm in direct:
        continue
    placed = [k for k, v in ported.items() if v == nm]
    if len(placed) == 1 and placed[0] in claimed:
        direct[nm] = (a, None)
for nm, (a, new) in sorted(direct.items()):
    was = [k for k, v in ported.items() if v == nm]
    if was != ([new] if new else []):
        print(f"direct service {nm}: 942 0x{a:08X}, 941 twin "
              f"{f'0x{new:08X}' if new else '- (its 941 address is the twin of ' + claimed[was[0]] + ')'}"
              f", ported .sym says {' '.join(f'0x{k:08X}' for k in was) or '(unported)'}")
        want[nm] = (a, new)

wrong = [nm for nm, (_, new) in want.items()
         if [k for k, v in ported.items() if v == nm] != ([new] if new else [])]
print(f"itron_stubs: {len(s_old)} stubs in 942, {len(s_new)} in 941; {len(want)} exported names, "
      f"{len(wrong)} placed differently by the ported .sym: {' '.join(wrong) or '-'}")

if args.fix and wrong:
    line = re.compile(r"^(?:; UNPORTED \([^)]*\): )?0x[0-9A-F]{8}  (\w+)(\t; exported to plug-ins \(lib\).*)$")
    out = []
    for l in open(args.ported).read().split("\n"):
        m = line.match(l)
        if m and m.group(1) in wrong:
            nm, (old, new) = m.group(1), want[m.group(1)]
            why = ("its 941 address is another export's routine and no 941 routine has its body"
                   if nm in direct else "no 941 kernel stub enters the same service routine")
            l = (f"0x{new:08X}  {nm}{m.group(2)}" if new else
                 f"; UNPORTED ({why}, tools/itron_stubs.py): 0x{old:08X}  {nm}{m.group(2)}")
        out.append(l)
    open(args.ported, "w").write("\n".join(out))
    print(f"itron_stubs: rewrote {args.ported}")
