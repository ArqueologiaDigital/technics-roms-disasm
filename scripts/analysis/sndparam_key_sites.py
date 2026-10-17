#!/usr/bin/env python3
"""sndparam_key_sites.py -- where does the code use each sound-parameter key?

QUESTION IT ANSWERS
  A sound-parameter key (sndparam_types.h; README-lsw-param-namespace-map.md) is named best from the code that
  loads it: `ld xwa, 0x2886 / call SndParam_LookupReadOnly` inside FSWAssGrid_EventDispatch says the key is a FOOT
  CONTROLLERS value.  For every descriptor reachable from the 972-pointer registry of v10 this prints the key, its
  current label, its record / byte / mask / clamp range, and every v10 instruction that loads the key as an
  immediate (ld / cp / add / sub / push / pushw / ldw), with the enclosing routine (the nearest label above that
  is not a local _Skip/_Join/...) and the next call within 8 lines.  It is the worklist for naming the descriptors
  that gen_sndparam_desc_names_r2.py leaves with their address-bucketed aliases.

  Small keys (0x00C0, 0x0100, 0x0300, ...) collide with ordinary constants, so their site lists contain noise:
  read the call that follows (SndParam_LookupReadOnly, SoundParam_NotifyChange, MainLsw*) before trusting a site.
  Keys below 0x80 are not searched at all.

RUN (repository root, built tree)
  python3 scripts/analysis/sndparam_key_sites.py                 # every descriptor
  python3 scripts/analysis/sndparam_key_sites.py --generic       # only those still carrying an _Entry_NNN alias
  python3 scripts/analysis/sndparam_key_sites.py --keys 2886,2c00   # selected keys, hex
"""
import collections
import glob
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "renaming"))
import gen_sndparam_desc_names_r2 as g  # noqa: E402  (registry(), descriptor(), elf_symbols())

ROOT = g.REPO
CONT = re.compile(r'_(Skip|Join|Loop|Return|Epilogue|Done|Next|Exit|Cont|End|Default|Resume|Nop)\d*$'
                  r'|__[0-9A-Fa-f]{4,6}$|__[a-z]\w*$')
IMM = re.compile(r'^\s+(ld|cp|add|sub|push|pushw|ldw)\s+[^;]*?(0x[0-9a-fA-F]+)\s*(;.*)?$')


def main():
    a = sys.argv[1:]
    only = None
    if "--keys" in a:
        only = {int(x, 16) for x in a[a.index("--keys") + 1].split(",")}
    rom = open(os.path.join(ROOT, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
    syms = g.elf_symbols("v10")
    by_addr = collections.defaultdict(list)
    for n, ad in syms.items():
        by_addr[ad].append(n)
    descs = {}
    for p in g.registry(rom, syms):
        key, bank, off, mask, lo, hi = g.descriptor(rom, p)
        names = [n for n in by_addr.get(p, []) if not n.startswith("SndParamRun_")]
        descs.setdefault(key, (names, bank, off, mask, lo, hi))
    sites = collections.defaultdict(list)
    for f in sorted(glob.glob(os.path.join(ROOT, "v10/maincpu/**/*.s"), recursive=True)):
        L = open(f, "rb").read().decode("latin-1").split("\n")
        routine = "?"
        for i, line in enumerate(L):
            m = re.match(r'^([A-Za-z_]\w*):', line)
            if m and not CONT.search(m.group(1)):
                routine = m.group(1)
            m = IMM.match(line)
            if not m:
                continue
            v = int(m.group(2), 16)
            if v < 0x80 or v not in descs:
                continue
            nxt = ""
            for j in range(i + 1, min(i + 8, len(L))):
                mm = re.match(r'^\s+(call|calr)\s+(\w+)', L[j])
                if mm:
                    nxt = mm.group(2)
                    break
            sites[v].append((os.path.relpath(f, ROOT), i + 1, routine, m.group(1), nxt))
    for key in sorted(descs):
        names, bank, off, mask, lo, hi = descs[key]
        if only is not None and key not in only:
            continue
        if "--generic" in a and not any(g.ALIAS.match(n) for n in names):
            continue
        s = sites.get(key, [])
        print("%06X %-36s record %02X +%-2d mask %02X [%d..%d]  %d sites" % (
            key, ",".join(names) or "-", bank, off, mask, lo, hi, len(s)))
        for x in s[:8]:
            print("      %s:%d  %-44s %-5s -> %s" % x)


if __name__ == "__main__":
    main()
