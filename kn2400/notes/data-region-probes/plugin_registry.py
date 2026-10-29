#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""plugin_registry.py -- how the XAPR plug-in (hdsx3/) registers its MILK GUI with its host.

QUESTION IT ANSWERS
  "Which host routines does the KN6000 / KN6500 expansion board's plug-in call, which tables does
   it register, and do its widget records check?"  The plug-in calls the SX-KN6000's routines
   through `mov (0x979126B4), aN / mov (0x100C, aN), aN / mov (OFF, aN), aM / calls (aM)`:
   0x979126B4 holds the registry base, +0x100C is the table pointer of registry slot 0x100 (16-byte
   records, +0xC the table), the KN6000's block-0 Function table (0x4C32923C, 422 entries), so
   OFF / 4 is the function index.  It prints:
     * the offsets the plug-in uses and the KN6000 routine at each (kn6000.sym names);
     * every registration milk_model finds through RegisterObjectTable (OFF 0xEC) and
       RegisterTitle (OFF 0x278): slot, kind, count, table;
     * the class / object totals and milk_model's link checks.
  2026-10-29: 41 offsets (0xA8 DrawBox 77 calls, 0x2D8 GetClientBox 55, 0x25C MainFuncCall 34,
  0x108 SendEvent 29, ...); 11 registrations (Class 0x168 x 55, Viewable 0x77 x 999, ResName 0x277,
  Function 0x108 / 0x308, ApFunction 0x128 / 0x328, MainFunction 0x148 / 0x348, ResEvent 0x188,
  ResMethod 0x1A8); title TT_HDDEXT (0x01F00077) opens object 0x00770000; 504 classes in all
  (449 the host's, 55 its own); 2 link-check failures, both in the plug-in's own data (object 11's
  next is its child 14; object 137's next is the orphan 138).

RUN (from kn7000/; ../kn6000 and ../hdsx3 reference images built):
  python3 ../kn2400/notes/data-region-probes/plugin_registry.py
"""
import collections
import os
import re
import sys

TOOLS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "kn7000", "tools")
sys.path.insert(0, TOOLS)
import gen_data_s as G  # noqa: E402

G.configure("hdsx3")
g = G.Gen()
m = g.m
src = open(os.path.join(G.KN7, "src", "program.s"), encoding="latin-1").read().split("\n")
use = collections.Counter()
for i, line in enumerate(src):
    if line.strip() == "calls\t(a1)":
        for j in range(i - 1, max(0, i - 12), -1):
            mo = re.match(r"\s+mov\s+\((0x[0-9a-f]+), a0\), a1$", src[j])
            if mo:
                use[int(mo.group(1), 16)] += 1
                break
print(f"{len(use)} host-table offsets called:")
for off, n in use.most_common():
    print(f"  {off:#06x} {g.host_calls.get(off, '?'):28s} {n:4d} calls")
print("registrations:")
for r in m.regs:
    print(f"  slot {r['slot']:#05x} {r.get('kind') or '?':13s} count {r['count']:4d} table "
          f"{r['table']:#010x}  ({r['func']}, line {r['line']})")
print("titles:", {f"{i:#010x}": (nm, c['stack'].get(0x10)) for i, (nm, _a, c) in m.titles.items()})
own = sum(1 for c in m.classes if c >> 16 == 0x168)
print(f"{len(m.classes)} classes ({own} the plug-in's own), "
      f"{sum(len(b['objects']) for b in m.blocks.values())} objects")
bad = m.check()
print(f"{len(bad)} check failures:", bad)
