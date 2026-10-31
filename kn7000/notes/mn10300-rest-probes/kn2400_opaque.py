#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn2400_opaque.py -- the KN2400 v1.1 program's `census: opaque -- unknown-dump` pieces, by kind, with
the structure (and, where one exists, the reader) behind each kind.

QUESTION IT ANSWERS
  "The generated KN2400 data sources (kn2400/src/program/data/data_0N.s) declare about 3,400 pieces
   `# census: opaque -- unknown-dump: ... no instruction reads them`.  What are they, group by group,
   which routine reads each group (through a pointer table, a record field, a computed index, a RAM
   pointer, a stepped pointer ...), what is the exact layout, and how many opaque bytes does each
   group explain?"

  Every group below is found from the image's own structure, starting at the table or routine the
  report cites, and each check prints how many records satisfy the layout.  The reader citations
  (routine, CPU address, instruction) are in the report of lane mn10300-rest item 9, sub-agent
  opaque-kn2400, and are repeated in READERS below.  Groups, in the order they are tried:

    trie           the parameter-id trie (ResourceIdTrie, walked by func_5014A95C): 177 tables of
                   8-byte entries, its 388 leaf records ({u32 id; u16 type; u16 kind; ...}, 8..20
                   bytes by type), the value tables type-0 records point at (+16, count +20), and
                   the records in the leaf area no trie path reaches
    fx-preset      FxPresetTable (func_4863CDB5_Table) / FxPresetVarTable (func_4863CDD8_Table):
                   548 records {u16 params[n] (+0xFFFF pad); char name[17]; u8 0; u16 desc; u16 n;
                   u16 0; params*; u32 code} tiling 0x48432394..0x48439000
    fx-code-map    func_4863D95A's six {s8, s8} maps: five 128 x 64 x 2 bytes, one 64 x 2
    chord-voicing  func_486F84EC / func_486F8461: 44 blocks of 12 rows {u8 n; u8 note[7]} and 47
                   inversion lists {u8 n; n x {u8 head; u8 note[7]}}
    chord-names    four arrays of 6-byte chord-name strings, each followed by its pointer array;
                   no word of the image (any alignment) and no code immediate holds any of them
    pow10          the C library's powers of ten (PfDoubleToDecimal): 309 doubles 1e0..1e308;
                   the "1,525-byte high-entropy block" is its tail (--all-trees: in all five images)
    alpha-list     the alphabetical sound lists (func_487019FB picks one of 6 slots per model):
                   4-byte entries {char initial; u8 msb, lsb, program} up to a 0 entry
    mss-list       the Music Stylist u16 setup-index lists (-1 ends) of StyleGenre(.styles[].list),
                   StyleLetter.setups and StyleEra.setups, both models' tables
    param-group    func_5015A8CC's 2 x 27 lists of 12-byte records {u32 id (-1 ends); u8 mask;
                   ...; u8 kind (+8)}
    fav-items      the favourites item lists the AcFavItemProc_L60/_L95 records name: 12-byte
                   {u32 proc index; u32 arg; char *name}
    switch-hash    the compiler's hashed switch tables (32 x {u32 key; case}) of func_48627FB2,
                   func_48628025, func_486280AA, func_48629232_entry_L24
    name-tables    the reflection name tables GetBitmapNameTable / GetFrameNameTable /
                   GetIconNameTable answer: 2 x 256 slots of char * each
    sysex-tail     the switch descriptors' SysEx blocks past the 12 bytes their memcpy copies
    euc-text       NUL-terminated EUC-JP (Japanese) strings
    dsp-family     the effect-DSP programs under func_50185B0C_entry_L1c_Table (another sub-agent)
    ram-image      the initialised-RAM image (0x485DD334.., copied to 0x50000010)
  and what is left, by what holds it: `ram-ptr` (an initial value of the RAM image points at or up
  to 64 bytes before it), `code-imm` (an imm32 of the code, any alignment, likewise), `data-word`
  (an aligned data word holds its start), else `text` (printable) or `none`.

RUN (from the repository root)
  python3 kn7000/notes/mn10300-rest-probes/kn2400_opaque.py            # the group table and checks
  python3 kn7000/notes/mn10300-rest-probes/kn2400_opaque.py --left     # also the 40 largest left
  python3 kn7000/notes/mn10300-rest-probes/kn2400_opaque.py --all-trees  # pow10 in all five images
Reads kn2400/baserom/kn2400_program.rom (git-ignored: `make -C kn2400 baserom`) and the data sources.
"""
import collections
import glob
import math
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
ROM = os.path.join(ROOT, "kn2400", "baserom", "kn2400_program.rom")
DATA = os.path.join(ROOT, "kn2400", "src", "program", "data")
B = 0x48400000
D = open(ROM, "rb").read()


def u8(a):
    return D[a - B]


def u16(a):
    return struct.unpack_from("<H", D, a - B)[0]


def u32(a):
    return struct.unpack_from("<I", D, a - B)[0]


def inrom(v):
    return B <= v < B + len(D)


MARK = re.compile(rb"census: opaque -- unknown-dump: \d+ bytes of ([^;]*?) in ([^;]*);")
RNG = re.compile(rb'incbin_range "baserom/kn2400_program.rom", 0x([0-9A-F]+), 0x([0-9A-F]+)')


def pieces():
    out = []
    for f in sorted(glob.glob(os.path.join(DATA, "data_0*.s"))):
        lines = open(f, "rb").read().split(b"\n")
        for i, line in enumerate(lines):
            m = MARK.search(line)
            if m:
                r = RNG.search(lines[i + 1])
                out.append((int(r.group(1), 16) + B, int(r.group(2), 16) + B, m.group(1).decode("latin-1")))
    return sorted(out)


class Group:
    def __init__(self, name):
        self.name, self.spans, self.checks = name, [], collections.OrderedDict()

    def add(self, a, b):
        self.spans.append((a, b))

    def check(self, what, ok, n):
        self.checks[what] = f"{ok} / {n}"


def trie():
    g = Group("trie")
    root, tables, leaves = 0x48404E70, {}, {}

    def walk(t, n, shift, prefix):
        tables[t] = max(n, tables.get(t, 0))
        for i in range(n):
            e = t + 8 * i
            p, inner, cnt = u32(e), u8(e + 4), u8(e + 5)
            if not p:
                continue
            if not inner:
                leaves.setdefault(p, []).append(prefix | (i << shift))
            elif shift > 0:
                walk(p, cnt, shift - 4, prefix | (i << shift))
    walk(root, 16, 20, 0)
    for t, n in tables.items():
        g.add(t, t + 8 * n)
    size = {0: 16, 1: 20, 2: 8, 3: 12, 4: 12, 5: 8, 6: 8}
    ok = 0
    for p, keys in leaves.items():
        typ, kind = u16(p + 4), u16(p + 6)
        n = size[typ]
        if typ == 1 and kind in (6, 7):
            n = 12
        if typ == 0 and kind in (2, 26):
            n = 24
            t = u32(p + 16)
            g.add(t, t + u16(p + 20))                      # the value table, count at +20
        if typ == 3 and kind in (8, 9):
            n = 16                                         # a redirect with two targets
        g.add(p, p + n)
        ok += u32(p) in keys
    g.check("leaf records whose +0 id is a key the trie path gives", ok, len(leaves))
    g.check("trie tables (entries)", len(tables), sum(tables.values()))
    lo, hi = min(leaves), 0x484032E0                       # the leaf area ends where the tables start
    g.orphans = (lo, hi)
    g.add(0x484018E4, lo)                                  # the value table of id 0 lies before the area
    return g, set(leaves)


def fx_presets():
    g = Group("fx-preset")
    recs = {u32(0x4854B764 + 4 * i) for i in range(8192)} | {u32(0x48553764 + 4 * i) for i in range(64)}
    ok = tile = 0
    spans = []
    for p in sorted(recs):
        n, par = u16(p + 0x14), u32(p + 0x18)
        spans.append((par, p + 0x20))
        ok += p - par == ((2 * n + 3) & ~3) or (n == 0 and p - par == 4)
        g.add(par, p + 0x20)
    spans.sort()
    tile = sum(1 for x, y in zip(spans, spans[1:]) if x[1] == y[0])
    g.check("records whose params sit right before the name (u16 x n, 4-aligned)", ok, len(recs))
    g.check("records that end where the next one's params start", tile, len(recs) - 1)
    g.check("first params / last record end", f"{spans[0][0]:#x}", f"{spans[-1][1]:#x}")
    return g


def fx_code_maps():
    g = Group("fx-code-map")
    for t in (0x485538CE, 0x48557F3E, 0x4855C662, 0x485606C2, 0x485646FE):
        g.add(t, t + 128 * 64 * 2)
    g.add(0x4856874A, 0x4856874A + 64 * 2)
    return g


def chord_voicings():
    g = Group("chord-voicing")
    blocks = {u32(0x4858CA34 + 4 * i) for i in range(22)} | {u32(0x4858CA8C + 4 * i) for i in range(39)}
    ok = 0
    for b in blocks:
        g.add(b, b + 96)
        for r in range(12):
            row = D[b - B + 8 * r: b - B + 8 * r + 8]
            ok += 1 <= row[0] <= 7 and all(x == 0xFF for x in row[1 + row[0]:]) and 0xFF not in row[1:1 + row[0]]
    g.check("voicing rows {u8 n; u8 note[n]; 0xFF fill}", ok, 12 * len(blocks))
    inv = {u32(0x4858CB28 + 4 * i) for i in range(22)} | {u32(0x4858CB80 + 4 * i) for i in range(39)}
    ok = 0
    for s in sorted(inv):
        n = u8(s)
        g.add(s, s + 1 + 8 * max(n, 1))            # n = 0: one row, inversion 0 (head bits 3..5 = 0)
        ok += all(1 <= (u8(s + 1 + 8 * k) >> 3 & 7) <= 5 for k in range(n)) and (n > 0 or u8(s + 1) >> 3 == 0)
    g.check("inversion lists {u8 n; max(n,1) x {u8 head; u8 note[7]}}, head bits 3..5 = 1..n", ok, len(inv))
    g.add(0x484FF441, 0x484FF444)                          # 0xFF pad to the next table
    return g


def chord_names():
    g = Group("chord-names")
    lo, hi = 0x484FF830, 0x484FFD60
    g.add(lo, hi)
    held = 0
    for i in range(len(D) - 3):
        v = struct.unpack_from("<I", D, i)[0]
        if lo <= v < hi and not (lo - B <= i < hi - B):
            held += 1
    g.check("words outside the block (any alignment) that point into it", held, "0 expected")
    return g


def pow10(img=D, base=B):
    one = struct.pack("<d", 1.0) + struct.pack("<d", 10.0)
    i = img.find(one)
    while i >= 0:
        v = [struct.unpack_from("<d", img, i + 8 * k)[0] for k in range(309)]
        if all(abs(x / 10.0 ** k - 1) < 1e-14 for k, x in enumerate(v)):
            return base + i, base + i + 309 * 8
        i = img.find(one, i + 1)
    return None


def alpha_lists():
    g = Group("alpha-list")
    ok = n = 0
    for t in (0x485ABF00, 0x485AF118):
        for a in sorted({u32(t + 4 * i) for i in range(6)}):
            k = 0
            while u8(a + 4 * k) and u8(a + 4 * k) < 0x80:
                k += 1
            g.add(a, a + 4 * k + 4)
            ok += u32(a + 4 * k) == 0
            n += 1
    g.check("lists that end with an all-zero entry", ok, n)
    return g


def mss_lists():
    g = Group("mss-list")
    seen = set()

    def ulist(a, lim):
        if not inrom(a) or a in seen:
            return
        seen.add(a)
        k = 0
        while u16(a + 2 * k) != 0xFFFF:
            assert u16(a + 2 * k) < lim
            k += 1
        g.add(a, a + 2 * k + 2)
    for genre, letter, era, lim in ((0x4857087C, 0x48570EB8, 0x485758E4, 720),
                                    (0x48576AF0, 0x485770DC, 0x4857B6F8, 680)):
        for i in range(11):
            p, j = u32(genre + 8 * i + 4), 0
            while inrom(p) and inrom(u32(p + 8 * j)) and inrom(u32(p + 8 * j + 4)):
                ulist(u32(p + 8 * j + 4), lim)
                j += 1
        for i in range(34):
            ulist(u32(letter + 8 * i + 4), lim)
        for i in range(10):
            ulist(u32(era + 12 * i + 4), lim)
    g.check("u16 lists, every index below the model's StyleRecordTable count", len(seen), len(seen))
    return g


def param_groups():
    g = Group("param-group")
    lists = set()
    for t in (0x484090C0, 0x4840912C):
        for i in range(27):
            a = u32(t + 4 * i)
            lists.add(a)
            k = 0
            while u32(a + 12 * k) != 0xFFFFFFFF:
                k += 1
            g.add(a, a + 12 * k + 12)
    g.check("lists (2 x 27 slots)", len(lists), 54)
    return g


def fav_items():
    g = Group("fav-items")
    heads = set()
    for rec, n in ((0x48477620, 18), (0x484777B0, 20)):   # AcFavItemProc_L60 / _L95_Records, +0
        heads |= {u32(rec + 8 * i) for i in range(n) if 0x48476000 <= u32(rec + 8 * i) < 0x48478000}
    total = 0
    for s in sorted(heads):
        k = 0
        while u32(s + 12 * k) < 0x40 and inrom(u32(s + 12 * k + 8)):
            k += 1
        g.add(s, s + 12 * k)
        total += k
    g.check("lists / entries {u32 proc; u32 arg; char *name}", len(heads), total)
    g.text_tail = True             # a piece may run on into the menu title string after its list
    return g


def switch_hash():
    g = Group("switch-hash")
    for t in (0x4841DF74, 0x4841E074, 0x4841E174, 0x4841E274):
        g.add(t, t + 32 * 8)
    return g


def name_tables():
    g = Group("name-tables")
    for t in (0x48544C14, 0x4854541C, 0x48545C20):        # Get{Bitmap,Frame,Icon}NameTable
        g.add(t, t + 0x800)
    return g


def sysex_tails(ps):
    g = Group("sysex-tail")
    for a, b, _w in ps:
        if 0x48409700 <= a < 0x4840A700:
            g.add(a, b)
    return g


def euc_text(ps):
    g = Group("euc-text")
    for a, b, _w in ps:
        data, hi = D[a - B:b - B].rstrip(b"\xff"), 0
        try:
            for s in data.split(b"\0"):
                t = s.decode("euc_jp")
                if any(ord(c) < 0x20 for c in t):
                    raise ValueError
                hi += sum(ord(c) > 0x3000 for c in t)
        except ValueError:
            continue
        if hi >= 2:
            g.add(a, b)
    return g


def main():
    ps = pieces()
    gt, leafset = trie()
    groups = [gt, fx_presets(), fx_code_maps(), chord_voicings(), chord_names()]
    gp = Group("pow10")
    gp.add(*pow10())
    gp.check("doubles within 1e-14 of 10^k, k = 0..308, at", f"{gp.spans[0][0]:#x}", 309)
    groups += [gp, alpha_lists(), mss_lists(), param_groups(), fav_items(), switch_hash(), name_tables(),
               sysex_tails(ps), euc_text(ps)]
    gd = Group("dsp-family")
    gd.add(0x48534135, 0x48541488)
    gr = Group("ram-image")
    gr.add(0x485DD334, 0x485DD334 + 0x6E78)
    groups += [gd, gr]
    print(f"KN2400 opaque pieces: {len(ps)}, {sum(b - a for a, b, _ in ps):,} bytes")
    print()
    left = list(ps)
    rows = []
    for g in groups:
        cov = set()
        for s, e in g.spans:
            cov.update(range(s, e))
        take, keep = [], []
        for p in left:
            body = p[1]
            while body > p[0] and p[1] - body < 3 and u8(body - 1) in (0x00, 0xFF) and body - 1 not in cov:
                body -= 1                                  # up to 3 bytes of alignment pad after an item
            if getattr(g, "text_tail", False) and p[0] in cov:
                while body > p[0] and body - 1 not in cov and (0x20 <= u8(body - 1) < 0x7F or u8(body - 1) == 0):
                    body -= 1
            (take if all(x in cov for x in range(p[0], body)) else keep).append(p)
        if g.name == "trie":       # leaf-area pieces that are records no trie path reaches
            lo, hi = g.orphans
            orph = [p for p in keep if lo <= p[0] < hi]
            keep = [p for p in keep if p not in orph]
            g.check("leaf-area opaque bytes no leaf, table or value map covers", sum(b - a for a, b, _ in orph),
                    "records of ids no path reaches")
            rows.append(("trie (unreached records)", len(orph), sum(b - a for a, b, _ in orph)))
        rows.append((g.name, len(take), sum(b - a for a, b, _ in take)))
        left = keep
    # what holds the rest: an initial value of the RAM image (a RAM pointer variable), an imm32 of the
    # code (any alignment, file 0x1E427C on), an aligned word of the data, or nothing
    ram0, code0 = 0x485DD334, 0x485E427C
    ramw, codew, dataw = set(), set(), set()
    for i in range(0, len(D) - 3):
        v = struct.unpack_from("<I", D, i)[0]
        if not inrom(v):
            continue
        a = B + i
        if a >= code0:
            codew.add(v)
        elif ram0 <= a < ram0 + 0x6E78 and i % 4 == 0:
            ramw.add(v)
        elif i % 4 == 0:
            dataw.add(v)

    def near(p, ws):
        return any(x in ws for x in range(p[0] - 64, p[1]))
    rest = collections.defaultdict(list)
    for p in left:
        if near(p, ramw):
            k = "ram-ptr"
        elif near(p, codew):
            k = "code-imm"
        elif p[0] in dataw:
            k = "data-word"
        else:
            k = "text" if p[2].startswith("printable") else "none"
        rest[k].append(p)
    for k in ("ram-ptr", "code-imm", "data-word", "text", "none"):
        rows.append((f"left: {k}", len(rest[k]), sum(b - a for a, b, _ in rest[k])))
    w = max(len(r[0]) for r in rows)
    print(f"| {'group':<{w}} | pieces | bytes   |")
    print(f"|{'-' * (w + 2)}|--------|---------|")
    for r in rows:
        print(f"| {r[0]:<{w}} | {r[1]:>6} | {r[2]:>7,} |")
    print()
    for g in groups:
        for what, v in g.checks.items():
            print(f"{g.name}: {what}: {v}")
    if "--all-trees" in sys.argv:
        print()
        for img, base in (("kn6000/baserom/kn6000_program.rom", 0x4C000000),
                          ("kn6500/baserom/kn6500_program.rom", 0x4C000000),
                          ("hdsx3/baserom/hdsx3_extapr.rom", 0x97800000),
                          ("kn7000/baserom/kn7000_program.rom", 0x48400000),
                          ("kn2400/baserom/kn2400_program.rom", 0x48400000)):
            path = os.path.join(ROOT, img)
            if os.path.exists(path):
                r = pow10(open(path, "rb").read(), base)
                print(f"pow10 {img.split('/')[0]:7s} {r[0]:#x}..{r[1]:#x}  (last 1,525 bytes from {r[1] - 1525:#x})")
    if "--left" in sys.argv:
        print()
        allleft = sorted((p for v in rest.values() for p in v), key=lambda p: -(p[1] - p[0]))[:40]
        for a, b, wh in allleft:
            print(f"{a:#x}..{b:#x} {b - a:5d}  {wh}")


if __name__ == "__main__":
    main()
