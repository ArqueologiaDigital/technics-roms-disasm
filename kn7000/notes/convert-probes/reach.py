#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""Question: is any of the code tools/gen_program_s.py converts really data?

Runs the generator (its output goes to SCRATCH, never to src/), takes every
instruction it decoded, and follows control flow from every known entry: each
converted block's start, every address a symbol file names, and every operand
that names a decoded instruction. It reports

  * how many bytes are never reached (most of it is the case bodies of switch
    statements whose jump tables live in the data region -- `jmp (a0)` -- so
    "unreached" alone does not mean data), and
  * every decoded run, reached or not, that holds a sign of data decoded as code:
    a `?` (an undecodable byte), a register list with an `other*` member outside
    a movm/rti context, or a call/branch whose target is outside the program and
    library images or lands inside an instruction.

Data typed in DATA_ISLANDS is not decoded, so it does not show up.

Run from kn7000/:
    UNIDASM=/path/to/unidasm python3 notes/convert-probes/reach.py SCRATCH_DIR
"""
import os
import re
import sys
sys.dont_write_bytecode = True
sys.path.insert(0, 'tools')
import gen_program_s as G   # noqa: E402

scratch = sys.argv[1]
os.makedirs(scratch, exist_ok=True)
G.OUT = os.path.join(scratch, 'program.s')
captured = {}
_dec = G.decode_blocks


def grab_dec(d, jobs):
    captured['dec'] = r = _dec(d, jobs)
    return r


_init = G.EmitCtx.__init__


def grab_ctx(self, names, label_of, A, data_names):
    captured['names'] = names
    _init(self, names, label_of, A, data_names)


G.decode_blocks = grab_dec
G.EmitCtx.__init__ = grab_ctx
G.main()

insn = {}
for (off, end, delta), ins in captured['dec'].items():
    for a, b, mn, ops in ins or ():
        insn[delta + a] = (b, mn, ops)
names = captured['names']
entries = set(names) & set(insn)
entries |= {delta + ins[0][0] for (o, e, delta), ins in captured['dec'].items() if ins}
for pc, (b, mn, ops) in insn.items():
    if mn not in G.BRANCH_MNEMS:
        entries.update(v for v in (int(h, 16) for h in re.findall(r"0x([0-9a-fA-F]{8})\b", ops))
                       if v in insn)
reached, work = set(), list(entries)
while work:
    pc = work.pop()
    while pc in insn and pc not in reached:
        reached.add(pc)
        b, mn, ops = insn[pc]
        if mn == G.FILL:
            break
        t = G.first_target(ops) if mn in G.BRANCH_MNEMS else None
        if t is not None and t in insn:
            work.append(t)
        if mn in G.UNCOND:
            break
        pc += len(b)
runs, cur = [], None
for pc in sorted(insn):
    b, mn, ops = insn[pc]
    if pc in reached or mn == G.FILL:
        continue
    if cur and cur[1] == pc:
        cur[1] = pc + len(b)
    else:
        cur = [pc, pc + len(b)]
        runs.append(cur)
print(f'{len(insn)} decoded instructions; {len(runs)} unreached runs, '
      f'{sum(e - s for s, e in runs)} bytes')

R1 = (G.BASE + 0x80, G.BASE + G.R1_END)
LIB = (G.LIB_CPU_BASE, G.LIB_DELTA + G.IMAGE_END)


def suspicious(pc):
    b, mn, ops = insn[pc]
    if mn == '?':
        return True
    if 'other' in ops and mn not in ('movm', 'call', 'ret', 'retf'):
        return True
    if mn in G.BRANCH_MNEMS:
        t = G.first_target(ops)
        if t is None:
            return False
        inside = R1[0] <= t < R1[1] or LIB[0] <= t < LIB[1]
        if not inside:
            return not (0x48400000 <= t < 0x48400000 + G.IMAGE_END)   # code before the library image
        return t not in insn and any(p in insn and t < p + len(insn[p][0]) for p in range(t - 6, t))
    return False


bad = [pc for pc in sorted(insn) if insn[pc][1] != G.FILL and suspicious(pc)]
print(f'{len(bad)} decoded instructions with a sign of data:')
for pc in bad:
    b, mn, ops = insn[pc]
    print(f'  {pc:#010x}  {b.hex():14s} {mn} {ops}  ({"reached" if pc in reached else "unreached"})')
