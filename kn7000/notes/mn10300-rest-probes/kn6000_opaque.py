#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn6000_opaque.py -- what are the KN6000 / KN6500 data pieces declared `census: opaque`, and who reads them?

QUESTION IT ANSWERS
  "Of the pieces of the SX-KN6000 v7.1 and SX-KN6500 v1.3 data regions that gen_data_s.py declares
   `# census: opaque -- unknown-dump: ...` (followed by an `.incbin_range`), how many bytes belong to a
   structure whose reader is now known, group by group, and what is left?"  Each group is measured
   from the reference image with the rule its reader implies (the routine and the instruction are in
   the group's description below and in lane mn10300-rest's report, item 9):

   fxcmd      the lists the RAM table at func_4C155072_Table (KN6500 func_4C15562E_Table, 208 u32)
              points at: groups of 13-byte records {u8 op, be32, be32, be16, be16}, each group ended
              by one 0xFF byte.  func_4C155072 skips n groups (`add 0xd, d0` per record, `cmp 0xff`);
              func_4C155C08 decodes the fields byte by byte and calls the op switch func_4C157DE2.
   trie       the parameter-id trie under the root func_4C02CA6A_Records (KN6500
              func_4C02CBDA_Records): 8-byte nodes {target, u8 inner, u8 count, u16 0} and the leaf
              records they name ({u32 id, u16 type, u16 kind, ...}), walked by func_4C02CA6A.
   chordmap   five 128 x 64 tables of u16 (16 KB each), func_4C15F0D9 (KN6500 func_4C15F695):
              row = low byte (<= 0x7F) * 128, column = (high byte & 0x3F) * 2.
   voicing    the chord-voicing blocks of func_4C0FE816 / func_4C0FE8A1 (KN6500 func_4C0FE5BC ...):
              22 + 39 pointers to 12 rows of 8 bytes {u8 n, u8 note[7]}, and 22 + 39 pointers to
              {u8 nrows, max(nrows, 1) rows of 8 bytes}.
   stylelist  the u16 style lists ended by 0xFFFF that StyleGenreTable's subcategories,
              StyleAlphabetTable and StyleEraTable point at (func_4C164F0F counts them).
   pow10      the 309 doubles 1e0 .. 1e308 at func_4C002A49_entry_L3d_Table (func_4C002A49 indexes
              them by the decimal exponent, bounded by `cmp -0x134`).
   chordrec   the 2048 x 2-byte table func_4C09D886_entry_L6e_Table (KN6500 func_4C09D607_...),
              indexed by the 11-bit interval mask func_4C09DC6F builds.
   hash32     four 32-slot {u32 key, handler} hash tables (func_4C129B80 and its three twins probe
              them by (key - 3) & 0x1F and wrap at the next table).
   disp12     12-byte dispatch lists: func_4C03CD2C's (until handler == 0) and func_4C04D371's
              (KN6500 func_4C04D4E1; per event type, until key == -1).
   idlist     the u32 id lists ended by -1 of func_4C11B347 (KN6500 func_4C11B237).
   mixer      the 16-byte mixer item records of AcMixerScreenProc_La6_Table (func_4C0745A1 returns
              base + 16 * i) and the caption strings their +12 points at.
   names2     the second half (+0x400, slots 256..) of the bitmap / frame / icon name tables: one
              pointer per resource to its source file name ("music1.bmp"); and the slot after the
              last name (a pointer to "") that IconIDProc's name search reads.  No reader of the
              second half was found: layout only.
   ramvar     initialised-RAM variables a widget record names in a pointer field; the class proc
              (or an ancestor's) reads the variable through that field (`mov (OFF, aN), aM` then
              `mov / movhu / movbu (aM)`), which gives its width.
   strings    pieces that are whole NUL-terminated strings (ASCII or EUC-JP) whose every start is
              held by a word of the image (a pointer).
   rntail     the 4-byte word after a V_*_ResNames table that points at an empty string.
   flashsect  the sector tables {u32 offset, u32 size} of the two flash-chip records func_4C172252
              (KN6500 func_4C172A54) matches the chip id against (MBM29LV160B 35, AT49BV16X4 40).
   bounded    tables the code indexes with a clamped index: func_4C08A2A3's u16 curve
              (`cmp 0x64, d0` -> 101 entries); on the KN6500 also the 1000 u16 at "Str_P" that
              func_4C16FA2B reads below `cmp 0x3e8`.
   genrelist  the u32 lists of GetGenreName_entry_L14_Records (+0x14, count at +0x11; read by
              func_4C057A38 `mov (d0, a0), d0`).
   copies     blocks copied with a constant length (memcpy & co. with `mov Label, a1` and `mov N, d0`,
              or a `setlb` loop of N reads), e.g. HpFlashWriteDefaults' 99 words, MemStyleRecInit's
              128 bytes, func_4C02F9BB's 1984 bytes.
   pad        pieces of at most 3 bytes, all 0x00 / 0xFF, and 0x00 / 0xFF bytes beside a structure.

  A byte counts for the first group whose extent holds it.  `--left N` lists the N largest
  remaining runs.

RUN (from the repository root, with the git-ignored reference images in place)
  python3 kn7000/notes/mn10300-rest-probes/kn6000_opaque.py [--model kn6000|kn6500|both] [--left 20]
"""
import argparse, bisect, collections, glob, os, re, struct

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
B = 0x4C000000
# RAM-init image (flash offset, length) -> 0x50000010, as kn7000/tools/memmap.find_raminit reads it
RAMINIT = {"kn6000": (0x3ED870, 0x6F7C), "kn6500": (0x377524, 0x6F28)}
NAMES = {
    "kn6000": dict(fx="func_4C155072_Table", trie="func_4C02CA6A_Records", cm="func_4C15F0D9_entry_Lc4_Records",
                   vo="func_4C0FE816_entry", cr="func_4C09D886_entry_L6e_Table",
                   hash=["func_4C129B80_Records", "func_4C129BF3_Records", "func_4C129C78_Records",
                         "func_4C12ADC6_entry_L24_Records"],
                   d12n="func_4C03CD2C_entry_L9d_Selected", d12m="func_4C04D371_entry_L26_Table",
                   idl="func_4C11B347_entry_L4a_Selected", flash="func_4C172252_Table",
                   bounded=[("func_4C08A2A3_entry_L91_Table", 101, 2)]),
    "kn6500": dict(fx="func_4C15562E_Table", trie="func_4C02CBDA_Records", cm="func_4C15F695_entry_Lc4_Records",
                   vo="func_4C0FE5BC_entry", cr="func_4C09D607_entry_L6e_Table",
                   hash=["func_4C129EC4_Records", "func_4C129F37_Records", "func_4C129FBC_Records",
                         "func_4C12B144_entry_L24_Records"],
                   d12n="func_4C03CE9C_entry_L9d_Selected", d12m="func_4C04D4E1_entry_L26_Table",
                   idl="func_4C11B237_entry_L4a_Selected", flash="func_4C172A54_Table",
                   bounded=[("func_4C08A16D_entry_L91_Table", 101, 2), ("Str_P", 1000, 2)]),
}
LAB = re.compile(rb"^([A-Za-z_.$][\w.$]*):")
OPQ = re.compile(rb"census: opaque -- unknown-dump: \d+ bytes of .*? in the (program flash|initialised-RAM image)")
INC = re.compile(rb'\.incbin_range "baserom/\w+\.rom", 0x([0-9A-Fa-f]+), 0x([0-9A-Fa-f]+)')


class Tree:
    def __init__(self, m):
        self.m, self.d = m, os.path.join(ROOT, m)
        self.rom = open(os.path.join(self.d, "baserom", f"{m}_program.rom"), "rb").read()
        self.ri = RAMINIT[m]
        self.addr = {}
        for line in open(os.path.join(self.d, "src/program/data/labels.sym"), encoding="latin-1"):
            if not line.startswith(";"):
                a, n = line.split()[:2]
                self.addr[n] = int(a, 16)
        self.pieces = []           # (flash offset lo, hi, ram?, label just before or None, file:line)
        for f in sorted(glob.glob(os.path.join(self.d, "src/program/data/data_0*.s"))):
            lines = open(f, "rb").read().split(b"\n")
            last = None
            for i, l in enumerate(lines):
                mm = LAB.match(l)
                if mm:
                    last = (mm.group(1).decode(), i)
                o = OPQ.search(l)
                if o:
                    inc = INC.search(lines[i + 1])
                    lab = last[0] if last and last[1] == i - 1 else None
                    self.pieces.append((int(inc.group(1), 16), int(inc.group(2), 16),
                                        o.group(1) == b"initialised-RAM image", lab, f"{os.path.basename(f)}:{i + 1}"))

    def off(self, a):              # CPU address -> flash offset
        if 0x50000010 <= a < 0x50000010 + self.ri[1]:
            return a - 0x50000010 + self.ri[0]
        return a - B

    def u8(self, a): return self.rom[self.off(a)]
    def u16(self, a): return struct.unpack_from("<H", self.rom, self.off(a))[0]
    def u32(self, a): return struct.unpack_from("<I", self.rom, self.off(a))[0]
    def f64(self, a): return struct.unpack_from("<d", self.rom, self.off(a))[0]
    def inrom(self, a): return B <= a < B + len(self.rom)

    def cstr_end(self, a):         # address after the NUL
        return B + self.rom.index(b"\0", a - B) + 1


def groups(t):
    """yield (group, [(lo, hi) CPU ranges])"""
    N, A = NAMES[t.m], t.addr
    # fxcmd
    tab = A[N["fx"]]
    starts = sorted({t.u32(tab + 4 * i) for i in range(208)} - {0})
    rs, labs = [], sorted(a for a in A.values() if B <= a < B + len(t.rom))
    for k, s in enumerate(starts):
        # a list ends where the next one starts; the last one at the next label after it
        end = starts[k + 1] if k + 1 < len(starts) else labs[bisect.bisect_right(labs, s)]
        p = s
        while p < end:
            p += 1 if t.u8(p) == 0xFF else 13
        assert p == end, (hex(s), hex(p), hex(end))
        rs.append((s, p))
    yield "fxcmd", rs
    # trie
    nodes, leaves, seen = [], set(), set()

    def walk(n, cnt):
        if n in seen:
            return
        seen.add(n)
        nodes.append((n, n + 8 * cnt))
        for i in range(cnt):
            e = n + 8 * i
            p, inner, c = t.u32(e), t.u8(e + 4), t.u8(e + 5)
            if p and inner:
                walk(p, c)
            elif p:
                leaves.add(p)
    walk(A[N["trie"]], 16)
    L = sorted(leaves)
    yield "trie", nodes + [(a, L[i + 1] if i + 1 < len(L) else a + 20) for i, a in enumerate(L)]
    # chordmap
    yield "chordmap", [(A[N["cm"] + sfx], A[N["cm"] + sfx] + 0x4000) for sfx in ("", "_2", "_3", "_4", "_5")]
    # voicing
    rs = []
    for nm, n, kind in (("L18_Table", 22, 1), ("L36_Table", 39, 1), ("L18_Table_2", 22, 2), ("L36_Table_2", 39, 2)):
        for i in range(n):
            p = t.u32(A[N["vo"] + "_" + nm] + 4 * i)
            rs.append((p, p + (96 if kind == 1 else 1 + 8 * max(t.u8(p), 1))))
    yield "voicing", rs
    # stylelist
    lists = []
    g = A["StyleGenreTable"]
    for i in range(10):
        s, j = t.u32(g + 8 * i + 4), 0
        while t.u32(s + 8 * j):
            lists.append(t.u32(s + 8 * j + 4))
            j += 1
    a, j = A["StyleAlphabetTable"], 0
    while t.u32(a + 8 * j):
        lists.append(t.u32(a + 8 * j + 4))
        j += 1
    lists += [t.u32(A["StyleEraTable"] + 12 * i + 4) for i in range(10)]
    rs = []
    for p in lists:
        if t.inrom(p):
            q = p
            while t.u16(q) != 0xFFFF:
                q += 2
            rs.append((p, q + 2))
    yield "stylelist", rs
    # pow10
    p0 = A["func_4C002A49_entry_L3d_Table"]
    assert all(abs(t.f64(p0 + 8 * k) / 10.0 ** k - 1) < 1e-12 for k in range(309))
    yield "pow10", [(p0, p0 + 309 * 8)]
    yield "chordrec", [(A[N["cr"]], A[N["cr"]] + 0x1000)]
    yield "hash32", [(A[n], A[n] + 256) for n in N["hash"]]
    # disp12: until handler == 0 (L9d_Selected_0..8), until key == -1 (L26_Table entries)
    rs = []
    for k in range(9):
        p = A[f"{N['d12n']}_{k}"]
        while t.u32(p + 8):
            p += 12
        rs.append((A[f"{N['d12n']}_{k}"], p + 12))
    d = A[N["d12m"]]
    for i in range(30):
        p = s = t.u32(d + 4 * i)
        if not t.inrom(p):
            continue
        while t.u32(p) != 0xFFFFFFFF:
            p += 12
        rs.append((s, p + 4))
    yield "disp12", rs
    rs = []
    for k in range(5):
        s = p = A[f"{N['idl']}_{k}"]
        while t.u32(p) != 0xFFFFFFFF:
            p += 4
        rs.append((s, p + 4))
    yield "idlist", rs
    # mixer
    rs, mt = [], A["AcMixerScreenProc_La6_Table"]
    for i in range(4):
        s = p = t.u32(mt + 4 * i)
        while t.inrom(t.u32(p + 12)) and t.u16(p) < 0x100:
            q = t.u32(p + 12)
            rs.append((q, t.cstr_end(q)))
            p += 16
        rs.append((s, p))
    yield "mixer", rs
    # names2: the three name tables GetBitmapNameTable / GetFrameNameTable / GetIconNameTable return
    rs = []
    for base in sorted(a for n, a in A.items() if re.fullmatch(r"names_4C[0-9A-F]{6}", n)):
        if t.u32(base + 0x400) and all(t.inrom(t.u32(base + 0x400 + 4 * i)) for i in range(2)) \
                and t.rom[t.off(t.u32(base + 0x400)):].split(b"\0")[0].lower().endswith(b".bmp"):
            n = 0
            while t.u32(base + 4 * n):
                n += 1
            rs.append((base + 4 * (n - 1), base + 4 * n))           # the "" slot IconIDProc reads
            m = 0
            while t.u32(base + 0x400 + 4 * m):
                m += 1
            rs.append((base + 0x400, base + 0x400 + 4 * m))
    yield "names2", rs
    # flashsect: the flash-chip records {u16 maker, u16 device, u32 nsect, sector table, char name[20]}
    rs, f = [], A[N["flash"]]
    for i in range(2):
        n, tb = t.u32(f + 32 * i + 4), t.u32(f + 32 * i + 8)
        assert sum(t.u32(tb + 8 * k + 4) for k in range(n)) == 0x200000      # {offset, size}: 2 MB
        rs.append((tb, tb + 8 * n))
    yield "flashsect", rs
    yield "bounded", [(A[n], A[n] + c * w) for n, c, w in N["bounded"]]
    # genrelist: GetGenreName_entry_L14_Records, 24-byte records, list +0x14 of (+0x11) u32
    rs, g = [], A["GetGenreName_entry_L14_Records"]
    for i in range(t.u16(A["GetGenreName_Var"])):
        lst, n = t.u32(g + 24 * i + 0x14), t.u8(g + 24 * i + 0x11)
        rs.append((lst, lst + 4 * n))
    yield "genrelist", rs
    yield "copies", copy_extents(t)


def copy_extents(t):
    """blocks the code copies with a constant length: memcpy / memcmp / strncpy / strncmp / memmove
    with `mov Label, a1` and `mov N, d0` before the call, and `mov Label, aX; mov -N, dY; setlb`
    loops that read (aX) N times (u8 / u16 / u32)"""
    code = open(os.path.join(t.d, "src/program.s"), encoding="latin-1").read().split("\n")

    def val(x):
        mm = re.fullmatch(r"(\w+)(?:\+(\w+))?", x)
        if not mm or mm.group(1) not in t.addr:
            return None
        return t.addr[mm.group(1)] + (int(mm.group(2), 0) if mm.group(2) else 0)
    rs = []
    for i, l in enumerate(code):
        if re.match(r"\tcall\t(memcpy|memcmp|strncpy|strncmp|memmove)_entry", l):
            src = n = None
            for j in range(i - 1, max(i - 12, 0), -1):
                if re.match(r"\w+:", code[j]):
                    break
                mm = re.match(r"\tmov\t([\w+]+), a1$", code[j])
                if mm and src is None:
                    src = val(mm.group(1))
                mm = re.match(r"\tmov\t(-?0x[0-9a-f]+|-?\d+), d0$", code[j])
                if mm and n is None:
                    n = int(mm.group(1), 0)
            if src and n and n > 0 and t.inrom(src):
                rs.append((src, src + n))
        mm = re.match(r"\tmov\t([\w+]+), (a\d)$", l)
        if mm and val(mm.group(1)) and t.inrom(val(mm.group(1))):
            for j in range(i + 1, min(i + 6, len(code))):
                c = re.match(r"\tmov\t(-0x[0-9a-f]+|-\d+), d\d$", code[j])
                if c:
                    if code[j + 1].strip() == "setlb":
                        r, body = mm.group(2), code[j + 2:j + 8]
                        w = next((w for w, pat in ((1, "movbu"), (2, "movhu"), (4, "mov"))
                                  if any(re.match(rf"\t{pat}\t\({r}\), d\d", b) for b in body)), 0)
                        if w:
                            rs.append((val(mm.group(1)), val(mm.group(1)) - w * int(c.group(1), 0)))
                    break
    return rs


def held_words(t):
    s = set()
    for o in range(len(t.rom) - 3):
        v = struct.unpack_from("<I", t.rom, o)[0]
        if B <= v < B + len(t.rom):
            s.add(v)
    return s


def ram_readers(t):
    """var label -> (class, field, proc, the field load, the dereference)"""
    D = os.path.join(t.d, "src/program/data")
    cls, anc, i = {}, {}, 0
    L = open(os.path.join(D, "gui_classes.inc"), encoding="latin-1").read().split("\n")
    while i < len(L):
        mm = re.match(r"# (\w+): (.*?); \d+ bytes", L[i])
        if mm:
            anc[mm.group(1)] = [x.strip() for x in mm.group(2).split("<")]
        mm = re.match(r"\.macro (\w+) ", L[i])
        if mm:
            name, o, f = mm.group(1), 0, {}
            i += 1
            while not L[i].startswith(".endm"):
                d = re.match(r"\.(long|word|byte|space)\s+(.*)", L[i].strip())
                if d:
                    if d.group(1) == "space":
                        o += int(d.group(2).split(",")[0], 0)
                    else:
                        w = {"long": 4, "word": 2, "byte": 1}[d.group(1)]
                        for arg in d.group(2).split(","):
                            for pn in re.findall(r"\\(\w+)", arg):
                                f.setdefault(pn, o)
                            o += w
                i += 1
            cls[name] = f
        i += 1
    var = {}
    for fn in sorted(glob.glob(os.path.join(D, "data_0*.s"))):
        for line in open(fn, encoding="latin-1"):
            mm = re.match(r"\t+(\w+)\t(\w+), (.*)", line)
            if mm and mm.group(1) in cls:
                for k, v in re.findall(r"(\w+)=([A-Za-z_]\w*)", mm.group(3).split("#")[0]):
                    if k in cls[mm.group(1)] and k not in ("super", "sub", "next", "prev", "this"):
                        var.setdefault(v, (mm.group(1), k, cls[mm.group(1)][k]))
    code = open(os.path.join(t.d, "src/program.s"), encoding="latin-1").read().split("\n")
    idx = {mm.group(1): n for n, l in enumerate(code) for mm in [re.match(r"(\w+):", l)] if mm}
    cache = {}

    def reads(c, off):
        if (c, off) in cache:
            return cache[(c, off)]
        res = None
        for a in anc.get(c, [c]):
            n = idx.get(a + "Proc")
            if n is None:
                continue
            e = n + 1
            while e < len(code) and not (re.match(r"\w+:", code[e]) and not code[e].startswith(a + "Proc")
                                         and not code[e].startswith("loc_")):
                e += 1
            for k in range(n, e):
                mm = re.match(rf"\tmov\t\({hex(off) if off > 9 else off}, (a\d)\), (a\d)", code[k])
                if mm:
                    for j in range(k + 1, min(k + 5, e)):
                        d = re.match(rf"\t(mov|movhu|movbu)\t\({mm.group(2)}\), [ad]\d", code[j])
                        if d:
                            res = (a + "Proc", code[k].strip(), code[j].strip())
                            break
                        if code[j].rstrip().endswith(", " + mm.group(2)):
                            break
                if res:
                    break
            if res:
                break
        cache[(c, off)] = res
        return res
    out = {}
    for v, (c, f, off) in var.items():
        r = reads(c, off)
        if r:
            out[v] = (c, f) + r
    return out


def measure(m, nleft):
    t = Tree(m)
    G = list(groups(t))
    owner = {}
    for g, rs in G:
        for lo, hi in rs:
            for a in range(t.off(lo), t.off(hi)):
                owner.setdefault(a, g)
    held = held_words(t)
    rv = ram_readers(t)
    acc = collections.OrderedDict((g, [0, 0]) for g in [g for g, _ in G] +
                                  ["ramvar", "strings", "rntail", "pad", "LEFT-ram", "LEFT-flash"])
    left, widths = [], collections.Counter()
    for lo, hi, ram, lab, where in t.pieces:
        b = t.rom[lo:hi]
        own = collections.Counter(owner.get(a) for a in range(lo, hi)) if not ram else {None: hi - lo}
        for g, n in own.items():
            if g:
                acc[g][0] += 1
                acc[g][1] += n
        rest = own.get(None, 0)
        if not rest:
            continue
        g = None
        if rest < hi - lo:                                   # bytes beside a structure
            fill = all(t.rom[a] in (0, 0xFF) for a in range(lo, hi) if a not in owner)
            g = "pad" if fill else "LEFT-flash"
        elif ram and lab in rv:
            g = "ramvar"
            widths[(rv[lab][4].split()[0], hi - lo)] += 1
        elif not ram and b.rstrip(b"\xff").endswith(b"\0") and len(b) > 3:
            s_ = b.rstrip(b"\xff")
            st0 = lo                                         # a tail of a string: back to its start
            while st0 > 0 and (32 <= t.rom[st0 - 1] < 127 or t.rom[st0 - 1] >= 0xA1):
                st0 -= 1
            st0 = next((a for a in range(st0, lo + 1) if B + a in held), lo)
            starts = [st0 - lo] + [i + 1 for i, x in enumerate(s_[:-1]) if x == 0]
            text = all(32 <= c < 127 or c >= 0xA1 or c in (9, 10, 13) for c in s_.replace(b"\0", b""))
            if text and all(B + lo + st in held for st in starts):
                g = "strings"
        if g is None and not ram and len(b) == 4 and lo >= 4:
            v, prev = struct.unpack_from("<I", b)[0], struct.unpack_from("<I", t.rom, lo - 4)[0]
            if t.inrom(v) and t.rom[v - B] == 0 and t.inrom(prev) and t.cstr_end(prev) == v:
                g = "rntail"        # the slot after a name table: "" right after the last name
        if g is None and len(b) <= 3 and set(b) <= {0, 0xFF}:
            g = "pad"
        if g is None:
            g = "LEFT-ram" if ram else "LEFT-flash"
        if g.startswith("LEFT"):
            left.append((rest, lo, ram, lab, where, b[:12].hex(" ")))
        acc[g][0] += 1
        acc[g][1] += rest
    tot = sum(hi - lo for lo, hi, *_ in t.pieces)
    print(f"== {m}: {len(t.pieces)} opaque pieces, {tot} bytes")
    print("| group      | pieces | bytes  |")
    print("|------------|--------|--------|")
    for g, (n, b) in acc.items():
        print(f"| {g:10s} | {n:6d} | {b:6d} |")
    expl = tot - acc["LEFT-ram"][1] - acc["LEFT-flash"][1]
    print(f"explained {expl} / {tot} bytes; ramvar reader width vs piece size: {sorted(widths.items())}")
    for g, rs in G:
        print(f"  {g}: {len(rs)} extents, {hex(min(lo for lo, _ in rs))}..{hex(max(hi for _, hi in rs))}")
    for n, lo, ram, lab, where, h in sorted(left, reverse=True)[:nleft]:
        cpu = lo - t.ri[0] + 0x50000010 if ram else B + lo
        print(f"  left {n:5d} {cpu:08X} {where} label={lab} | {h}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="both")
    ap.add_argument("--left", type=int, default=20)
    a = ap.parse_args()
    for m in (("kn6000", "kn6500") if a.model == "both" else (a.model,)):
        measure(m, a.left)


if __name__ == "__main__":
    main()
