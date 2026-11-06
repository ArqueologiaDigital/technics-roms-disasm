#!/usr/bin/env python3
"""picload_key_gate: is there a work-RAM variable that the PICTURE LOAD screens write and that the
keyboard's note path reads?  (N-44e56012: what keeps the keys silent while PICTURE LOAD is shown.)

Signal: build 941's byte-exact source (src/program/region1_*.s, library_*.s).  The script splits it
into functions (column-0 labels other than loc_ / <fn>_L<hex>, X_entry folded into X), builds the
static call graph (`call` / `calls` with a named target; indirect calls are not followed), and
collects each function's absolute work-RAM operands 0x50000000..0x503FFFFF, numeric or spelled by a
data label of src/program/data/labels.sym:
  read  = `(ADDR)` as the first operand of mov / movbu / movhu / btst / cmp, or `(ADDR)` anywhere in
          a cmp;  write = `(ADDR)` as the last operand of mov* / bset / bclr.
KEY PATH = the functions reachable (depth <= KEY_DEPTH) from func_4C014E41, the tick task's key-bed
poll (TickJobsTask 0x4C02BD80), with TgcBufWrite as the end (the TG command stream; its interpreter
SndCmdStreamInterpret -> TgPartKeyEvent runs in the library and is listed separately).
PICLOAD = the functions reachable (depth <= PIC_DEPTH) from the two PICTURE LOAD window procedures
FmmPictureLoadFunc (floppy) and SdcFmmPictureLoadFunc (SD).
Prints: the key path (the shortest call chain to TgcBufWrite), each set's size, and every RAM address
both written by PICLOAD and read by the KEY PATH, with the functions on each side.

Expected (2026-11-06, build 941, depths 8 / 3): "key path: func_4C014E41 -> func_4C01B6DA ->
func_48451AA7 -> M3SendProcess -> M3SendProcessTgc -> func_4C024DD8 -> func_4C0298E9 -> TgcBufWrite"
(the shortest chain; the played note goes func_48451AA7 -> func_484524EB -> func_4844FAF1 ->
func_4C024DD8 -> func_4C029793 -> TgcBufWrite, and "func_4C029793 on the key path: True"),
878 / 193 functions, 336 / 104 addresses, 19 in both: 0x500006E0..E8 (Malloc), 0x50000B0F..B3C
(the chord detector), 0x50000C10, 0x50000CE8, 0x50021FD8..E0 (index switches), 0x50149662..96
(sequencer / tempo).  None of them is a key gate.

usage (from kn7000/):
  python3 -I notes/work-ram-map-probes/picload_key_gate.py [KEY_DEPTH [PIC_DEPTH]]
"""
import collections
import glob
import re
import sys

KEY_DEPTH = int(sys.argv[1]) if len(sys.argv) > 1 else 8
PIC_DEPTH = int(sys.argv[2]) if len(sys.argv) > 2 else 3
LAB = re.compile(rb"^([A-Za-z_]\w*):")

data_lab = {}
for ln in open("src/program/data/labels.sym"):
    p = ln.split()
    if len(p) >= 2 and p[0].startswith("0x"):
        a = int(p[0], 16)
        if 0x50000000 <= a < 0x50400000:
            data_lab[p[1]] = a

body, cur = collections.defaultdict(list), None
for f in sorted(glob.glob("src/program/region1_*.s")) + sorted(glob.glob("src/program/library_*.s")):
    for ln in open(f, "rb").read().split(b"\n"):          # .s files hold raw bytes
        m = LAB.match(ln)
        if m:
            n = m.group(1).decode()
            if not n.startswith("loc_") and not re.search(r"_L[0-9A-F]+$", n):
                cur = n[:-6] if n.endswith("_entry") else n
            continue
        if cur:
            body[cur].append(ln.decode("latin-1").split("#")[0])

def callees(f):
    out = []
    for l in body.get(f, ()):
        m = re.match(r"\s+calls?\s+(\w+)", l)
        if m:
            c = m.group(1)
            out.append(c[:-6] if c.endswith("_entry") else c)
    return out

def addr(tok):
    tok = tok.strip()
    m = re.fullmatch(r"\((0x[0-9a-fA-F]{8}|\w+)(\+(\d+))?\)", tok)
    if not m:
        return None
    a = int(m.group(1), 16) if m.group(1).startswith("0x") else data_lab.get(m.group(1))
    if a is None or not 0x50000000 <= a < 0x50400000:
        return None
    return a + int(m.group(3) or 0)

def refs(f):
    rd, wr = set(), set()
    for l in body.get(f, ()):
        m = re.match(r"\s+(\w+)\s+(.*)", l)
        if not m:
            continue
        mn, ops = m.group(1), [o.strip() for o in re.split(r",\s*(?![^()]*\))", m.group(2))]
        if not ops:
            continue
        if mn.startswith("mov") or mn in ("btst", "bset", "bclr", "cmp"):
            a0, a1 = addr(ops[0]), addr(ops[-1]) if len(ops) > 1 else None
            if mn in ("bset", "bclr"):
                if a1 is not None: wr.add(a1)
                if a0 is not None: wr.add(a0)
            elif mn in ("btst", "cmp"):
                for a in (a0, a1):
                    if a is not None: rd.add(a)
            else:
                if a0 is not None: rd.add(a0)
                if a1 is not None and len(ops) > 1: wr.add(a1)
    return rd, wr

def reach(roots, depth, stop=()):
    seen, prev, q = {r: 0 for r in roots}, {r: None for r in roots}, collections.deque(roots)
    while q:
        f = q.popleft()
        if seen[f] >= depth or f in stop:
            continue
        for c in callees(f):
            if c not in seen:
                seen[c], prev[c] = seen[f] + 1, f
                q.append(c)
    return seen, prev

key, kprev = reach(["func_4C014E41"], KEY_DEPTH, stop={"TgcBufWrite"})
chain, f = [], "TgcBufWrite"
while f:
    chain.append(f)
    f = kprev.get(f)
print("key path:", " -> ".join(reversed(chain)) if "TgcBufWrite" in key else "TgcBufWrite not reached")
print("note sender: func_4C029793 on the key path:", "func_4C029793" in key)
pic, _ = reach(["FmmPictureLoadFunc", "SdcFmmPictureLoadFunc"], PIC_DEPTH)
print(f"KEY PATH {len(key)} functions (depth {KEY_DEPTH}); PICLOAD {len(pic)} functions (depth {PIC_DEPTH})")
kr, pw = collections.defaultdict(set), collections.defaultdict(set)
for f in key:
    for a in refs(f)[0]:
        kr[a].add(f)
for f in pic:
    for a in refs(f)[1]:
        pw[a].add(f)
both = sorted(set(kr) & set(pw))
print(f"RAM read on the key path: {len(kr)}; written under PICLOAD: {len(pw)}; both: {len(both)}")
for a in both:
    print(f"  0x{a:08X}  read by {', '.join(sorted(kr[a])[:4])}{' ...' if len(kr[a]) > 4 else ''}"
          f"  | written by {', '.join(sorted(pw[a])[:4])}{' ...' if len(pw[a]) > 4 else ''}")
# the service test-mode setters func_484A3A2A's diversion depends on (state byte 0x5006BA20+0x1F9 / +0x1F8)
deep, _ = reach(["FmmPictureLoadFunc", "SdcFmmPictureLoadFunc"], 6)
print("test-mode setters reachable from PICTURE LOAD (depth 6):",
      [f for f in ("func_4849FBC3", "func_4849FBF6") if f in deep] or "none")
