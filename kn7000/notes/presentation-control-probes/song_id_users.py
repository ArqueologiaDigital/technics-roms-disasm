#!/usr/bin/env python3
"""song_id_users.py -- question: which routines of PROGRAM 941 read, write or subscribe to each song-record
event id that song-records.md section 3 listed as unknown (N-c6900716), counting every M3 accessor, not
only the eight `notes/kn67-field-names-probes/m3em_callers.py` knows?

Signal: in the converted source (src/program/*.s, read as bytes), a `call X` / `call X_entry` where X is
one of ACCESSORS (the M3 get / set entry points and their Main* / Add / Force / Non / Delay wrappers,
plus SetMmmFilter, the GUI subscription), with `mov <imm>, d0` in the 10 lines before it; the id is
imm & 0xFFFFFF (the top byte is a source / part index).  Also a `cmp <imm>, d0` / `cmp <imm>, d1` of an id
inside a routine (a dispatch on the id an accessor returned or an EV_MMMDATA handler compares).  The
routine is the nearest column-0 label above that is not loc_ / _entry.  A `cmp` hit is only a hint: for
0x200000 most are the custom-style flag of a 24-bit style id (CustomStyleIndexFromParam), not the part id.
Expected (2026-11-06): 0x0000A1 is read by MSAModeBoxProc (MainGetM3Em) -- the "MUSIC STYLE ARRANGER
MODE" screen -- and by func_4C029CF5 together with 0x0000A0; 0x0000A0 is compared by MSA-related code.

usage (from kn7000/):  python3 -I notes/presentation-control-probes/song_id_users.py [ID_HEX ...]
"""
import collections
import pathlib
import re
import sys

ACCESSORS = ["PutM3Em", "PutM3EmDelay", "PutM3Force", "PutM3Non", "AddM3Em", "GetM3EmVal", "GetM3Em",
             "PutM3Sqf", "GetM3SqfVal", "GetM3Sqf", "GetM3InitVal", "GetM3Init", "MainGetM3Em",
             "MainPutM3Em", "MainAddM3Em", "MainCOMP_PutM3Em", "SetMmmFilter", "M3SendProcess",
             "M3SetByKind"]
DEFAULT = ["0000a0", "0000a1", "008002", "008006", "008008", "008009", "008031", "008032", "00c081",
           "00e000", "00e001", "00e002", "200000", "200081", "200088", "2000b0", "204080", "204081"]
ids = {int(x, 16) for x in (sys.argv[1:] or DEFAULT)}
call_re = re.compile(r"^\s+call\s+(%s)(?:_entry)?\b" % "|".join(ACCESSORS))
mov_re = re.compile(r"^\s+mov\s+(0x[0-9a-fA-F]+|\d+),\s*d0$")
cmp_re = re.compile(r"^\s+cmp\s+(0x[0-9a-fA-F]+),\s*d[01]$")
lab_re = re.compile(r"^([A-Za-z_]\w*):")
uses = collections.defaultdict(set)
for f in sorted(pathlib.Path("src/program").glob("*.s")):
    L = f.read_bytes().decode("latin-1").splitlines()
    func = "?"
    for i, l in enumerate(L):
        m = lab_re.match(l)
        if m and not m.group(1).startswith("loc_") and not m.group(1).endswith("_entry"):
            func = m.group(1)
        m = call_re.match(l)
        if m:
            for k in range(i - 1, max(-1, i - 11), -1):
                mm = mov_re.match(L[k])
                if mm:
                    v = int(mm.group(1), 0) & 0xFFFFFF
                    if v in ids:
                        uses[v].add(f"{m.group(1)}:{func}")
                    break
                if call_re.match(L[k]) or lab_re.match(L[k]):
                    break
        m = cmp_re.match(l)
        if m and int(m.group(1), 16) in ids and int(m.group(1), 16) >= 0x80:
            uses[int(m.group(1), 16)].add(f"cmp:{func}")
for v in sorted(ids):
    us = sorted(uses[v])
    named = [u for u in us if not u.split(":")[1].startswith("func_")]
    print(f"{v:06x}  {len(us):3d} uses  named: {', '.join(named) or '-'}")
    print(f"        all: {', '.join(us) or '-'}")
