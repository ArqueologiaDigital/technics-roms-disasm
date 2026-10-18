#!/usr/bin/env python3
"""Question answered: which parts of KN7000 work RAM 0x50000000..0x502B7FFF does
the firmware touch, from where, and how (reference sweep).

Inputs : decode.tsv from decode_all.py (linear unidasm decode of program-ROM code
         region 1 0x48400080..0x48586000 and the library window 0x4C000000..),
         baserom/kn7000_program.rom, kn7000.sym, kn7000_manual.sym,
         kn7000_exports_from_942.sym, $TMPDIR/kn7000-drawbitmap/entries.txt
         (call targets discovered by dump_range.py).
Outputs (into OUTDIR):
  refs.tsv          every instruction whose operand is a RAM constant in
                    0x50000000..0x503FFFFF: insn cpu, containing function,
                    value, kind (lea / imm_d / load / store / bit / add_base /
                    cmp / sub), width, text
  lea_extents.tsv   for each `mov imm32,aN`: max (disp+width) reached via (dN,aN)
                    in the following straight-line code, indexed/walked flags,
                    memset/memcpy length if a0 is passed to one
  pages4k.txt / pages64k.txt   histograms (refs, distinct addresses, functions)
  clusters.txt      distinct addresses grouped where the gap < GAP, with owners
  data_image_ptrs.tsv  words of the .data image (ROM 0x487B0B78 -> RAM 0x50000010,
                    0x7F34 bytes) whose value is a RAM address in range
  raw_hits.tsv      every 4-byte LE value in range anywhere in the program ROM
                    that is NOT an operand of a decoded instruction (data tables,
                    or desync), with region tag and alignment
usage (from the kn7000_disassembly root):
  python3 scan_ramrefs.py DECODE.tsv OUTDIR
"""
import bisect, collections, os, re, sys
sys.path.insert(0, "tools")
import gen_program_s as G

LO, HI, SCOPE_HI = 0x50000000, 0x50400000, 0x502B8000
GAP = 0x200
dec, outdir = sys.argv[1], sys.argv[2]
os.makedirs(outdir, exist_ok=True)
rom = open(G.ROM, "rb").read()

# ---- names ---------------------------------------------------------------
names = {}
for o, n in G.load_syms(rom):
    names[G.BASE + o] = n
for a, n in G.load_manual_syms():
    names.setdefault(a, n)
ent_cache = os.path.join(os.environ.get("TMPDIR", "."), "kn7000-drawbitmap", "entries.txt")
if os.path.exists(ent_cache):
    for x in open(ent_cache).read().split():
        names.setdefault(int(x, 16), f"func_{int(x, 16):08X}")
# lib call targets: discovered from the decode below
code_names = {a: n for a, n in names.items() if 0x48400000 <= a < 0x48586000 or 0x4C000000 <= a < 0x4C100000}

insns = []
for ln in open(dec):
    a, b, m, o = ln.rstrip("\n").split("\t")
    insns.append((int(a, 16), bytes.fromhex(b), m, o))
for a, b, m, o in insns:
    if m in ("call", "calls"):
        mm = re.match(r"0x([0-9a-f]+)", o)
        if mm:
            t = int(mm.group(1), 16)
            if 0x4C000000 <= t < 0x4C100000 and t not in code_names:
                code_names[t] = f"lib_{t:08X}"
starts = sorted(a for a, n in code_names.items() if not n.endswith("_entry"))
def owner(a):
    i = bisect.bisect_right(starts, a) - 1
    return code_names[starts[i]] if i >= 0 else "?"

MEMSET = {0x4C003024, 0x4C003022}
MEMCPY = {0x4C003039, 0x4C003037, 0x4C0039B3}
CTRL = re.compile(r"^(b[a-z]{1,3}|bra|jmp|call|calls|ret|retf|rets|rti|trap|l[a-z]{2,3})$")

def width(m):
    return 1 if m.startswith("movbu") or m.startswith("movb") else 2 if m.startswith("movh") else 4

def classify(b, m, ops, v):
    h = f"0x{v:08x}"
    if m in ("bset", "bclr", "btst"):
        return "bit", 1
    if m == "mov" and re.match(re.escape(h) + r", a\d$", ops):
        return "lea", 0
    if m == "mov" and re.match(re.escape(h) + r", d\d$", ops):
        return "imm_d", 0
    if m.startswith("mov"):
        i = ops.find("(" + h + ")")
        if i == 0:
            return "load", width(m)
        if i > 0:
            return "store", width(m)
    if m == "add":
        return "add_base", 0
    if m == "cmp":
        return "cmp", 0
    if m == "sub":
        return "sub", 0
    return m, 0

refs = []           # (insn, func, value, kind, width, text, idx)
covered = set()     # file offsets of covered operand bytes
def foff(a):
    return a - G.BASE if a < 0x4C000000 else a - G.LIB_DELTA
for idx, (a, b, m, o) in enumerate(insns):
    for mm in re.finditer(r"0x([0-9a-f]{8})", o):
        v = int(mm.group(1), 16)
        if LO <= v < HI:
            k, w = classify(b, m, o, v)
            refs.append((a, owner(a), v, k, w, f"{m} {o}", idx))
            vb = v.to_bytes(4, "little")
            p = b.find(vb)
            if p >= 0:
                covered.add(foff(a) + p)

with open(os.path.join(outdir, "refs.tsv"), "w") as f:
    f.write("insn\tfunction\tvalue\tkind\twidth\ttext\n")
    for a, fn, v, k, w, t, _ in sorted(refs, key=lambda r: (r[2], r[0])):
        f.write(f"{a:08X}\t{fn}\t{v:08X}\t{k}\t{w}\t{t}\n")

# ---- lea extents ----------------------------------------------------------
lea = []
for a, fn, v, k, w, t, idx in refs:
    if k not in ("lea", "imm_d"):
        continue
    reg = t.split(", ")[-1]
    maxd, indexed, walked, setlen, cpylen, uses = 0, False, False, None, None, 0
    regd = {}
    for j in range(idx + 1, min(idx + 40, len(insns))):
        a2, b2, m2, o2 = insns[j]
        ops = [x.strip() for x in re.split(r",(?![^(]*\))", o2)]
        # track immediates into d0/d1 for memset/memcpy lengths
        mi = re.match(r"(-?0x[0-9a-f]+|-?\d+), (d\d)$", o2)
        if m2 == "mov" and mi:
            regd[mi.group(2)] = int(mi.group(1), 0)
        for mm in re.finditer(r"\((-?0x[0-9a-f]+|-?\d+), " + reg + r"\)", o2):
            dd = int(mm.group(1), 0)
            maxd = max(maxd, dd + width(m2)); uses += 1
        if re.search(r"\(" + reg + r"\)", o2):
            maxd = max(maxd, width(m2)); uses += 1
        if m2 == "add" and ops and ops[-1] == reg and re.match(r"[ad]\d", ops[0]):
            indexed = True
        if m2 in ("inc4", "inc") and ops == [reg]:
            walked = True
        if m2 == "add" and ops[-1] == reg and re.match(r"-?(0x)?[0-9a-f]+$", ops[0]):
            walked = True
        if m2 in ("call", "calls"):
            mm = re.match(r"0x([0-9a-f]+)", o2)
            tgt = int(mm.group(1), 16) if mm else None
            if reg == "a0" and tgt in MEMSET:
                setlen = regd.get("d1")
            if reg in ("a0", "a1") and tgt in MEMCPY:
                cpylen = (reg, regd.get("d0"))
            break
        if CTRL.match(m2):
            break
        # register redefined?
        if ops and ops[-1] == reg and m2.startswith("mov") and not o2.startswith("("):
            break
    lea.append((v, a, fn, reg, maxd, uses, indexed, walked, setlen, cpylen))
with open(os.path.join(outdir, "lea_extents.tsv"), "w") as f:
    f.write("value\tinsn\tfunction\treg\tmax_disp_end\tdisp_uses\tindexed\twalked\tmemset_len\tmemcpy(reg,len)\n")
    for r in sorted(lea):
        v, a, fn, reg, maxd, uses, ix, wk, sl, cl = r
        f.write(f"{v:08X}\t{a:08X}\t{fn}\t{reg}\t0x{maxd:X}\t{uses}\t{int(ix)}\t{int(wk)}\t"
                f"{'' if sl is None else hex(sl)}\t{'' if cl is None else cl[0] + ',' + ('?' if cl[1] is None else hex(cl[1]))}\n")

# ---- .data image pointers -------------------------------------------------
DI_ROM, DI_RAM, DI_LEN = 0x3B0B78, 0x50000010, 0x7F34
dip = []
for o in range(0, DI_LEN, 4):
    v = int.from_bytes(rom[DI_ROM + o:DI_ROM + o + 4], "little")
    if LO <= v < HI:
        dip.append((DI_RAM + o, v))
with open(os.path.join(outdir, "data_image_ptrs.tsv"), "w") as f:
    f.write("ram_word\tvalue\n")
    for r, v in dip:
        f.write(f"{r:08X}\t{v:08X}\n")

# ---- raw hits not covered by a decoded operand ----------------------------
def region(o):
    if o < 0x186000: return "R1code"
    if DI_ROM <= o < DI_ROM + DI_LEN: return "dataimg"
    if o < 0x3B8FD1: return "data"
    return "LIB"
raw = []
for o in range(0, len(rom) - 3):
    if rom[o + 3] == 0x50 and rom[o + 2] < 0x40:
        v = int.from_bytes(rom[o:o + 4], "little")
        if LO <= v < HI and o not in covered:
            raw.append((o, v))
with open(os.path.join(outdir, "raw_hits.tsv"), "w") as f:
    f.write("file_off\tcpu\tregion\taligned\tvalue\tctx16\n")
    for o, v in raw:
        cpu = G.BASE + o if o < G.LIB_FILE_BASE else o + G.LIB_DELTA
        f.write(f"{o:06X}\t{cpu:08X}\t{region(o)}\t{int(o % 4 == 0)}\t{v:08X}\t{rom[max(0,o-6):o+6].hex()}\n")

# ---- histograms -------------------------------------------------------------
allv = collections.defaultdict(lambda: {"refs": 0, "funcs": collections.Counter(), "kinds": collections.Counter(), "src": set()})
for a, fn, v, k, w, t, _ in refs:
    e = allv[v]; e["refs"] += 1; e["funcs"][fn] += 1; e["kinds"][k] += 1; e["src"].add("code")
for r, v in dip:
    e = allv[v]; e["refs"] += 1; e["funcs"][f"data@{r:08X}"] += 1; e["kinds"]["dataptr"] += 1; e["src"].add("dataimg")
def w32(o):
    return int.from_bytes(rom[o:o + 4], "little")
def isptr(v):
    return 0x48000000 <= v < 0x487C0000 or LO <= v < HI or 0x4C000000 <= v < 0x4C040000
romtbl = []   # aligned data-region words in range with an aligned pointer-like neighbour
for o, v in raw:
    if region(o) == "data" and o % 4 == 0 and (isptr(w32(o - 4)) or isptr(w32(o + 4))):
        romtbl.append((o, v))
        e = allv[v]; e["refs"] += 1; e["funcs"][f"romtbl@{G.BASE + o:08X}"] += 1; e["kinds"]["romptr"] += 1; e["src"].add("romdata")
with open(os.path.join(outdir, "romtbl_ptrs.tsv"), "w") as f:
    f.write("rom_word\tvalue\tctx(-8..+12)\n")
    for o, v in romtbl:
        f.write(f"{G.BASE + o:08X}\t{v:08X}\t{rom[o-8:o+12].hex()}\n")

def hist(shift, fname):
    pg = collections.defaultdict(lambda: [0, 0, collections.Counter(), collections.Counter()])
    for v, e in allv.items():
        p = pg[v >> shift]; p[0] += e["refs"]; p[1] += 1; p[2].update(e["funcs"])
        for fn, c in e["funcs"].items():
            p[3]["romtbl" if fn.startswith("romtbl@") else "dataimg" if fn.startswith("data@") else "code"] += c
    with open(os.path.join(outdir, fname), "w") as f:
        f.write(f"{'page':10s} {'refs':>6s} {'code':>6s} {'dimg':>5s} {'romtb':>5s} {'addrs':>6s}  top functions\n")
        for k in sorted(pg):
            r, n, fc, sc = pg[k]
            top = ", ".join(f"{x}({c})" for x, c in fc.most_common(4))
            f.write(f"{k << shift:08X}   {r:6d} {sc['code']:6d} {sc['dataimg']:5d} {sc['romtbl']:5d} {n:6d}  {top}\n")
hist(12, "pages4k.txt")
hist(16, "pages64k.txt")

# ---- clusters ---------------------------------------------------------------
vs = sorted(allv)
clusters = []
cur = [vs[0]]
for v in vs[1:]:
    if v - cur[-1] < GAP:
        cur.append(v)
    else:
        clusters.append(cur); cur = [v]
clusters.append(cur)
with open(os.path.join(outdir, "clusters.txt"), "w") as f:
    for c in clusters:
        fc = collections.Counter(); kc = collections.Counter(); refs_n = 0
        for v in c:
            fc.update(allv[v]["funcs"]); kc.update(allv[v]["kinds"]); refs_n += allv[v]["refs"]
        f.write(f"{c[0]:08X}..{c[-1]:08X} span 0x{c[-1]-c[0]+1:X} addrs {len(c)} refs {refs_n} "
                f"kinds {dict(kc)}\n    funcs: {', '.join(f'{x}({n})' for x, n in fc.most_common(8))}\n")
print("refs", len(refs), "distinct", len(allv), "dataimg ptrs", len(dip), "raw uncovered", len(raw),
      "clusters", len(clusters))
