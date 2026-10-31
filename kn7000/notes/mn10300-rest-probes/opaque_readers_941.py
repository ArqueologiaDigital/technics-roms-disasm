#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_readers_941.py -- which of build 941's opaque pieces does a reader the walk misses explain?

QUESTION IT ANSWERS
  "For each reader lane mn10300-rest item 9 found for KN7000 program 941's `census: opaque` pieces
   (opaque_groups.py lists them), does the structure the reader implies really hold in the image
   (every pointer of the table lands on a record start, the list ends on the terminator the loop
   tests, the table's extent is the bound the code tests ...), and how many opaque pieces and bytes
   does it cover?  What is left?"

  Each finding is a set of CPU ranges built from the image and the labels only, never from a list of
  addresses typed in here; the check it prints is what makes the range trustworthy:

    widget-var     a RAM variable a widget record's field points at: the class chain's procedure
                   reads the field and dereferences it (`mov (OFF, aR), aS` or `add OFF, aR` + `mov
                   (aR), aS`, then a load / store through aS); printed per (class, field) with the
                   instruction pair and the load width; the Ad* classes whose class record names
                   AdMovableProc read their last two fields (dx, dy) through instance + size - 8
                   (0x48493E41 `mov (a1), a0` / `movhu (a0), d1`, `mov (4, a1), a0` / `movhu (a0), d0`)
    lang6-euc      EUC-JP text that is entry 6 of a 7-entry language pointer table (AcLanguageTextProc
                   0x484208BA: `movhu (0x500d3584), d0` / `cmp 6, d0` / `asl2 d0` / `mov (d0, a3), a0`
                   at 0x48420930, then LibStrlen and u2d_entry)
    dsp-entries    func_484061F9_Table's (RAM image) record lists: 13-byte {op u8, v1 be32, v2 be32,
                   a be16, b be16} entries closed by an 0xFF byte (func_484061F9: skip loop `cmp 0xff`
                   / `add 0xd`; func_48406D8F reads the entries)
    pow10          PfDoubleToDecimal_Table_4: 309 little-endian doubles 1e0..1e308, indexed by the
                   decimal exponent in PfDoubleToDecimal (a2 = the table; `mov (-8, a0), d0` at
                   loc_4C002E41, `mov (8, a0), d0` after loc_4C002E05)
    pads           the program flash's own "Technics Pads" resource (Str_Technics_Pads; stored by
                   TechnicsPadsResourceInit when the table flash's copy does not check), its extent
                   from tools/gen_table_styles.py's reading of the header
    chordrecog2    ChordRecogTable2: 2048 x {u8, u8}, index = func_4844D680's 11-bit interval mask
    a2a17-rows     func_48412A17_Records{,_2.._5}: 128 rows x 64 x {u8, u8}; row = arg & 0xFF checked
                   `cmp 0x7f`, column = (arg >> 8) & 0x3F (func_48412A17 loc_48412AEC..loc_48412B46)
    panel-desc     PanelButtonDescPtrTable / PanelButtonDispatch_Table lists: 12-byte descriptors until
                   the u32 0xFFFFFFFF (PanelButtonDispatch loc_484ADBBB `mov (a2), d0` / `cmp -1, d0`,
                   `add 0xc, a2`)
    chord-voicing  func_4856DBDB_Table (22) / _3 (39): 12 x {u8 n, u8 note[7]} (96 bytes, key x 8,
                   func_4856DC66 memcpy 8); _4 (22) / _2 (39): u8 count + count x 8-byte rows
    mixer-items    AcMixerScreenProc_Table's 4 pages: 16-byte records (func_4848DF79: `asl 4, d0` /
                   `add d0, a0`), +12 a name pointer; and the names they point at
    key-lists      func_4C021761_Selected_N / func_4C0216A3_Selected_N: 12-byte {mask, value, proc}
                   records until proc == 0 (loc_4C021803 `mov (a3), d0` / `cmp 0, d0`, `add 0xc`)
    hash32         func_48466F2F / _48466FA2 / _48467027 / _484681AF _Records: 32 slots x 8 bytes
                   (`and 0x1f, d1` / `asl 3, d1`)
    hp-defaults    HpFlashWriteDefaults_Table: 99 words (HpFlashWriteDefaults `mov -0x63, d1` / setlb
                   ... `inc d1` / `lne`) copied to the 'JK' record at RAM 0x5006B5F8
    eg-ramp        TgPartEgRampBuild_Table_3: 8 rows x 0x66 bytes (`mov 0x66, d1` / `mulu`); and
                   TgPartEgRampBuild_Records: (part byte & 0x0F) x 6, 14 records before Table_3
    crc7           Str_empty_307 + 2: the 256-byte CRC-7 table of func_484C3517 / func_484C356A (SysEx
                   checksum over the message up to 0xF7)
    clamp101       func_4C00AF99_Table: 101 x u16 (the index is clamped to 0..0x64)
    style-lists    StyleAlphabetTable (34 x 8, list at +4) and PostEvent_Records (10 x 12, list at +4):
                   u16 style indices up to and including 0xFFFF (func_4847D083 loc_4847D0E5
                   `movhu (a2), d0` / `cmp 0xffff, d0`)

RUN (from the repository root; needs kn7000/build/kn7000_program.labels, i.e. one build)
  python3 kn7000/notes/mn10300-rest-probes/opaque_readers_941.py
  python3 kn7000/notes/mn10300-rest-probes/opaque_readers_941.py --left 40     # what stays, biggest first
  python3 kn7000/notes/mn10300-rest-probes/opaque_readers_941.py --widget      # the per-field readers
"""
import argparse
import collections
import glob
import math
import os
import re
import struct
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import opaque_groups as OG  # noqa: E402

K = os.path.join(OG.REPO, "kn7000")
sys.path.insert(0, os.path.join(K, "tools"))
B = 0x48400000


class Img:
    def __init__(self):
        self.rom = open(os.path.join(K, "baserom/kn7000_program.rom"), "rb").read()
        self.lab = {}
        for ln in open(os.path.join(K, "build/kn7000_program.labels")):
            n, a = ln.split()
            self.lab[n] = int(a, 16)
        self.ram_base = None
        for f in glob.glob(os.path.join(K, "src/program/data/data_*.s")):
            for ln in open(f, encoding="latin-1"):
                m = re.match(r"\.mnbase (0x[0-9A-Fa-f]+)\s+# the initialised-RAM", ln)
                if m:
                    self.ram_base = int(m.group(1), 16)

    def off(self, a):
        return a - (self.ram_base if a >= 0x50000000 else B)

    def u8(self, a):
        return self.rom[self.off(a)]

    def u16(self, a):
        return struct.unpack_from("<H", self.rom, self.off(a))[0]

    def u32(self, a):
        return struct.unpack_from("<I", self.rom, self.off(a))[0]

    def f64(self, a):
        return struct.unpack_from("<d", self.rom, self.off(a))[0]

    def labels(self, pat):
        return sorted((a, n) for n, a in self.lab.items() if re.fullmatch(pat, n))


def findings(im):
    """{finding: (list of (lo, hi) CPU ranges, list of check lines)}"""
    F = collections.OrderedDict()
    L = im.lab

    # dsp-entries
    t = L["func_484061F9_Table"]
    ptrs = [im.u32(t + 4 * i) for i in range(208)]
    starts = sorted({p for p in ptrs if p})
    # the records past the last pointer are reached by a record number n > 0 from it: walk on while
    # the next record is not empty (an 0xFF at its start ends the run: the 0xFF fill before the next item)
    a, recs = starts[0], []
    while a <= starts[-1] or im.u8(a) != 0xFF:
        s = a
        while im.u8(a) != 0xFF:
            a += 13
        a += 1
        recs.append(s)
    on = sum(1 for p in starts if p in set(recs))
    F["dsp-entries"] = ([(starts[0], a)], [f"{len(starts)} distinct pointers of 208, {on} on a record start; "
                                            f"{len(recs)} records 0x{starts[0]:08X}..0x{a:08X}"])

    # pow10
    t = L["PfDoubleToDecimal_Table_4"]
    bad = [k for k in range(309) if not math.isclose(im.f64(t + 8 * k), 10.0 ** k, rel_tol=1e-15)]
    F["pow10"] = ([(t, t + 309 * 8)], [f"309 doubles at 0x{t:08X}: {309 - len(bad)} equal 10^k (k = 0..308)"])

    # pads
    import gen_table_styles as GTS
    s = L["Str_Technics_Pads"] - B
    o_tab, cnt = GTS.u24be(im.rom, s + 0x1E), GTS.u16be(im.rom, s + GTS.u24be(im.rom, s + 0x18) + 2)
    last = s + GTS.u24be(im.rom, s + o_tab + 3 * (cnt - 1))
    end = last + 0x37 + GTS.u24be(im.rom, last + 0x34)
    lines = GTS.technics_pads(im.rom, s, end, "TechnicsPadsResource", None, None, inline=True)
    F["pads"] = ([(s + B, end + B)], [f"\"Technics Pads\" header checks; {cnt} pads, 0x{s + B:08X}..0x{end + B:08X}, "
                                      f"{len(lines)} source lines from gen_table_styles.technics_pads(inline)"])

    # chordrecog2
    t = L["ChordRecogTable2"]
    nxt = min(a for a in L.values() if a > t and a < 0x50000000)
    F["chordrecog2"] = ([(t, t + 4096)], [f"0x{t:08X} + 2048 x 2 = 0x{t + 4096:08X}; next label 0x{nxt:08X}"])

    # a2a17-rows
    rr = []
    for n in ("func_48412A17_Records", "func_48412A17_Records_2", "func_48412A17_Records_3",
              "func_48412A17_Records_4", "func_48412A17_Records_5"):
        rr.append((L[n], L[n] + 128 * 128))
    F["a2a17-rows"] = (rr, ["5 tables x 128 rows x 128 bytes: " + ", ".join(f"0x{lo:08X}" for lo, _ in rr)])

    # panel-desc
    rr, chk = [], []
    for n in ("PanelButtonDescPtrTable", "PanelButtonDispatch_Table"):
        t = L[n]
        cnt = (min(a for a in L.values() if a > t) - t) // 4
        ends = 0
        for i in range(cnt):
            p = im.u32(t + 4 * i)
            q = p
            while im.u32(q) != 0xFFFFFFFF:
                q += 12
            rr.append((p, q + 12))
            ends += 1
        chk.append(f"{n}: {cnt} lists, each ends on 0xFFFFFFFF")
    F["panel-desc"] = (rr, chk)

    # chord-voicing
    rr = []
    for n, c in (("func_4856DBDB_Table", 22), ("func_4856DBDB_Table_3", 39)):
        for i in range(c):
            p = im.u32(L[n] + 4 * i)
            rr.append((p, p + 96))
    for n, c in (("func_4856DBDB_Table_4", 22), ("func_4856DBDB_Table_2", 39)):
        for i in range(c):
            p = im.u32(L[n] + 4 * i)
            rr.append((p, p + 1 + 8 * im.u8(p)))
    F["chord-voicing"] = (rr, ["96-byte key blocks (22 + 39 pointers) and count + 8n inversion lists (22 + 39)"])

    # mixer-items
    rr, chk = [], []
    t = L["AcMixerScreenProc_Table"]
    for i in range(4):
        p = im.u32(t + 4 * i)
        n = 0
        while 0x485E0000 <= im.u32(p + 16 * n + 12) < 0x485F0000:
            q = im.u32(p + 16 * n + 12)
            z = q
            while im.u8(z):
                z += 1
            rr.append((q, z + 1))
            n += 1
        rr.append((p, p + 16 * n))
        chk.append(f"page {i}: {n} records at 0x{p:08X}")
    F["mixer-items"] = (rr, chk)

    # key-lists
    rr = []
    for a, n in im.labels(r"func_4C02(1761|16A3)_Selected_\d+"):
        q = a
        while im.u32(q + 8) != 0:
            q += 12
        rr.append((a, q + 12))
    F["key-lists"] = (rr, [f"{len(rr)} lists, each up to the record whose proc (+8) is 0"])

    # hash32
    rr = [(L[n], L[n] + 256) for n in ("func_48466F2F_Records", "func_48466FA2_Records",
                                       "func_48467027_Records", "func_484681AF_Records")]
    F["hash32"] = (rr, ["4 tables x 32 slots x 8 bytes"])

    # hp-defaults
    t = L["HpFlashWriteDefaults_Table"]
    F["hp-defaults"] = ([(t, t + 99 * 4)], [f"99 words 0x{t:08X}..0x{t + 396:08X} (0x18C, the 'JK' record)"])

    # eg-ramp
    t3, tr = L["TgPartEgRampBuild_Table_3"], L["TgPartEgRampBuild_Records"]
    F["eg-ramp"] = ([(t3, t3 + 8 * 0x66), (tr, t3)],
                    [f"Table_3 8 x 0x66 ends 0x{t3 + 8 * 0x66:08X} (next label "
                     f"0x{L['TgPartEgRampBuild_Records_2']:08X}); Records {(t3 - tr) // 6} x 6 before Table_3"])

    # crc7: func_484C3517 / func_484C356A, `xor` the message byte into the running value, then
    # `mov Str_empty_307+2, a0` / `movbu (d2, a0), d0`: a 256-byte table indexed by a u8
    t = L["Str_empty_307"] + 2
    tab = []
    for i in range(256):
        c = i
        for _ in range(8):
            c = ((c << 1) ^ 0x12) & 0xFF if c & 0x80 else (c << 1) & 0xFF
        tab.append(c)
    same = sum(1 for i in range(256) if im.u8(t + i) == tab[i])
    F["crc7"] = ([(t, t + 256)], [f"0x{t:08X}: {same} of 256 bytes equal the CRC-7 (x^7 + x^3 + 1) table "
                                  "kept shifted left by one (polynomial 0x12)"])

    # clamp101: func_4C00AF99 clamps the index to 0..0x64 before `movhu (d0, a0), d0`
    t = L["func_4C00AF99_Table"]
    F["clamp101"] = ([(t, t + 101 * 2)], [f"func_4C00AF99_Table: 101 x u16, 0x{t:08X}..0x{t + 202:08X} "
                                          f"(next label 0x{min(a for a in L.values() if a > t):08X})"])

    # style-lists
    rr = []
    for n, c, st in (("StyleAlphabetTable", 34, 8), ("PostEvent_Records", 10, 12)):
        for i in range(c):
            p = im.u32(L[n] + st * i + 4)
            if not B <= p < B + len(im.rom):
                continue
            q = p
            while im.u16(q) != 0xFFFF:
                q += 2
            rr.append((p, q + 2))
    F["style-lists"] = (rr, [f"{len(rr)} lists of u16 (entries pointing into the flash), each up to and including 0xFFFF"])
    return F


def widget_readers():
    """(class, field, offset) -> (class whose proc reads it, proc CPU, field instr, deref instr)"""
    D = os.path.join(K, "src/program/data/")
    lay, chain, cur = {}, {}, None
    for ln in open(D + "gui_classes.inc", encoding="latin-1"):
        m = re.match(r"# (\w+): (\w+(?: < \w+)*);", ln)
        if m:
            chain[m.group(1)] = m.group(2).split(" < ")
        m = re.match(r"\.macro (\w+) this", ln)
        if m:
            cur, off = m.group(1), 0
            lay[cur] = {}
            continue
        if ln.startswith(".endm"):
            cur = None
            continue
        if cur:
            t = ln.split()
            if not t:
                continue
            if t[0] == ".space":
                off += int(t[1].rstrip(","), 0)
                continue
            w = {".long": 4, ".word": 2, ".byte": 1}.get(t[0])
            if w:
                for x in " ".join(t[1:]).split(","):
                    mm = re.match(r"\s*\\(\w+)", x)
                    if mm and mm.group(1) not in lay[cur]:
                        lay[cur][mm.group(1)] = off
                    off += w
    uses = {}
    for f in sorted(glob.glob(D + "data_0*.s")):
        for ln in open(f, encoding="latin-1"):
            m = re.match(r"\s+(\w+)\t(\w+), (.*)", ln)
            if m and m.group(1) in lay:
                for kv in re.finditer(r"(\w+)=(\w+)", m.group(3).split("\t#")[0]):
                    if kv.group(1) in lay[m.group(1)]:
                        uses.setdefault(kv.group(2), (m.group(1), kv.group(1), lay[m.group(1)][kv.group(1)]))
    body, cur = {}, None
    for f in sorted(glob.glob(os.path.join(K, "src/program/region1_*.s"))):
        for ln in open(f, encoding="latin-1"):
            m = re.match(r"# (\w+)\s+\(CPU (0x[0-9a-f]+)\)", ln)
            if m:
                cur = m.group(1)
                body[cur] = (int(m.group(2), 16), [])
                continue
            if cur and ln.startswith("    "):
                body[cur][1].append(ln.strip())

    def reads(proc, off):
        if proc not in body:
            return None
        L = body[proc][1]
        for i, ins in enumerate(L):
            m = re.match(r"mov\s+\((0x[0-9a-f]+|\d+), (a\d)\), (a\d)$", ins)
            m2 = re.match(r"add\s+(0x[0-9a-f]+|\d+), (a\d)$", ins)
            tgt, at = None, i
            if m and int(m.group(1), 0) == off:
                tgt = m.group(3)
            elif m2 and int(m2.group(1), 0) == off:
                for j in range(i + 1, min(i + 3, len(L))):
                    mm = re.match(r"mov\s+\(%s\), (a\d)$" % m2.group(2), L[j])
                    if mm:
                        tgt, at = mm.group(1), j
                        break
            if not tgt:
                continue
            for j in range(at + 1, min(at + 8, len(L))):
                if re.match(r"(mov|movhu|movbu)\s+(\((?:\S+, )?%s\), \w+|\w+, \((?:\S+, )?%s\))$" % (tgt, tgt), L[j]):
                    return body[proc][0], ins if at == i else ins + " / " + L[at], L[j]
        return None

    # classes whose class record names AdMovableProc as the procedure: it reads the instance's LAST
    # two fields (dx, dy) through instance + MT_GetInstanceSize - 8 (0x48493E3B `mov 8, d1` / `sub`)
    movable = set()
    for f in sorted(glob.glob(D + "data_0*.s")):
        for ln in open(f, encoding="latin-1"):
            m = re.match(r"\s+CLASS\s+Class_(\w+), .*proc=AdMovableProc\b", ln)
            if m:
                movable.add(m.group(1))
    size = {c: (max(v.values()) + 4 if v else 0) for c, v in lay.items()}

    def chain_reads(cls, off):
        for c in chain.get(cls, [cls]):
            r = reads(c + "Proc", off)
            if r:
                return (c + "Proc",) + r
        if cls in movable and off in (size[cls] - 8, size[cls] - 4):
            return ("AdMovableProc", 0x48493DC9, "mov (a1), a0 (+0) / mov (4, a1), a0 (+4), a1 = instance + size - 8",
                    "movhu (a0), d1 at 0x48493E43 / movhu (a0), d0 at 0x48493E49")
        return None
    return uses, chain_reads


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--left", type=int, default=0, help="list the N biggest pieces no finding covers")
    ap.add_argument("--widget", action="store_true", help="print the reader of each (class, field)")
    a = ap.parse_args()
    im = Img()
    ps = OG.pieces("941")
    F = findings(im)
    covered = {}            # piece index -> (finding, bytes of the piece the finding's ranges cover)
    rows = []
    for name, (rr, chk) in F.items():
        merged = []         # the ranges' union; a gap of up to 3 bytes of 0x00 / 0xFF (pad) is bridged
        for lo, hi in sorted(rr):
            if merged and lo <= merged[-1][1] + 3 and \
                    all(im.u8(x) in (0, 0xFF) for x in range(merged[-1][1], max(lo, merged[-1][1]))):
                merged[-1][1] = max(merged[-1][1], hi)
            else:
                merged.append([lo, hi])
        n = b = 0
        for i, p in enumerate(ps):
            if i in covered or p.ram:
                continue
            ov = sum(max(0, min(hi, p.cpu + p.size) - max(lo, p.cpu)) for lo, hi in merged)
            if ov:
                covered[i] = (name, ov)
                n += ov == p.size
                b += ov
        rows.append([name, n, b, "; ".join(chk)])
    # lang6-euc: entry 6 of a 7-entry pointer table
    src = []
    for f in OG.data_files(os.path.join(K, "src/program/data"), "kn7000"):
        src += open(f, encoding="latin-1").read().split("\n")
    slot = {}
    i = 0
    while i < len(src):
        if OG.LABEL_ONLY.match(src[i]) and i + 1 < len(src) and src[i + 1].startswith("\t.long\t"):
            j, ent = i + 1, []
            while j < len(src) and src[j].startswith("\t.long\t"):
                ent.append(src[j].split()[1])
                j += 1
            for k, e in enumerate(ent):
                slot.setdefault(e, set()).add((k, len(ent)))
            i = j
        else:
            i += 1
    n = b = odd = 0
    for i, p in enumerate(ps):
        if p.group == "euc-text" and i not in covered:
            if (6, 7) in slot.get(p.own, set()):
                covered[i] = ("lang6-euc", p.size)
                n += 1
                b += p.size
            else:
                odd += 1
    rows.insert(0, ["lang6-euc", n, b, f"{odd} EUC-JP pieces are not entry 6 of a 7-entry table"])
    # widget-var
    uses, chain_reads = widget_readers()
    n = b = 0
    per = collections.OrderedDict()
    for i, p in enumerate(ps):
        if p.group != "ram-widget-var":
            continue
        u = uses.get(p.own)
        r = chain_reads(u[0], u[2]) if u else None
        key = (u[0], u[1], u[2]) if u else ("?", p.own, 0)
        per.setdefault(key, [0, 0, r])
        per[key][0] += 1
        per[key][1] += p.size
        if r:
            covered[i] = ("widget-var", p.size)
            n += 1
            b += p.size
    rows.insert(0, ["widget-var", n, b, f"{sum(1 for v in per.values() if v[2])} of {len(per)} (class, field) "
                    "pairs: a class procedure dereferences the field"])
    tot_n = sum(1 for _ in ps)
    tot_b = sum(p.size for p in ps)
    cb = sum(v[1] for v in covered.values())
    print(OG.table([r[:3] for r in rows] + [["total explained", sum(1 for i, v in covered.items() if v[1] == ps[i].size), cb],
                                           ["left", sum(1 for i, p in enumerate(ps) if covered.get(i, ("", 0))[1] < p.size),
                                            tot_b - cb]],
                   ["finding", "pieces (whole)", "bytes"]))
    print()
    for r in rows:
        print(f"{r[0]}: {r[3]}")
    by = collections.OrderedDict((g, [0, 0, 0, 0]) for g in OG.GROUPS)
    for i, p in enumerate(ps):
        by[p.group][0] += 1
        by[p.group][1] += p.size
        if i in covered:
            by[p.group][2] += 1
            by[p.group][3] += covered[i][1]
    print()
    print(OG.table([[g, v[0], v[1], v[3], v[1] - v[3]] for g, v in by.items()],
                   ["group (opaque_groups.py)", "pieces", "bytes", "explained", "left"]))
    if a.widget:
        print()
        print(OG.table([[f"{k[0]}.{k[1]}", f"+0x{k[2]:X}", v[0], v[1],
                         (f"{v[2][0]} 0x{v[2][1]:08X} `{v[2][2]}` -> `{v[2][3]}`" if v[2] else "not found")]
                        for k, v in per.items()],
                       ["class.field", "offset", "pieces", "bytes", "reader (proc, CPU, field load -> access)"]))
    if a.left:
        left = sorted((p._replace(size=p.size - covered.get(i, ("", 0))[1]) for i, p in enumerate(ps)
                       if covered.get(i, ("", 0))[1] < p.size), key=lambda p: (-p.size, p.cpu))
        print(f"\nleft, biggest {a.left}")
        for p in left[:a.left]:
            print(f"0x{p.cpu:08X} {p.size:5d} {p.group:13s} {p.own or p.table or p.prev_label:36s} {p.data[:12].hex()}")


if __name__ == "__main__":
    main()
