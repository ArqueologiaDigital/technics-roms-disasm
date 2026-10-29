#!/usr/bin/env python3
"""tonedb_selector_users.py -- which tone-database paths reach each IC307 recording selector.

QUESTION IT ANSWERS
  "For a recording selector (class << 12) + entry, which wave sources (catalogue names), which tone
   records, which drum instruments and which multisample SETs lead to it?"  It walks the Sub CPU's
   wave-selection chain over the tracked table-data image (original_ROMs/kn5000_table_data.rom), the same
   chain v142/subcpu/kn5000_subprogram_v142.s runs:

     tone record partial block +0x02 (wave) / +0x03 (family)          WaveSel_StageA1_FromPatchBlock
     drum instrument (PercInst) layer block +0x01 / +0x02             WaveSel_StageA1_FromToneSlot
       -> StageA1 map (family bits 7:6: 0x00/0xC0 dir +0x0C, 0x80 +0x10, 0x40 +0x14),
          index (family & 0x0F) * 128 + (wave & 0x7F)                  WaveSel_StageA1_IndexLookup
       -> 11-byte velocity-split record (dir +0x18 / +0x1C / +0x20, stride +0xEA / +0xF0);
          bands reachable for velocity 1..127                          Velocity_Select_Split_Zone
       -> band z's pair (+3+2z, +4+2z), StageA2 map (0x00/0xC0 +0x24, 0x80 +0x28, 0x40 +0x2C)
                                                                       WaveSel_StageA2_FromVelZone / _FindSetDesc
       -> 15-byte SET descriptor (dir +0x30 / +0x34 / +0x38), +5 = zone chunk, flags bit 7 = stride 6
       -> zone record +0 LE16 = recording selector                    WaveSel_StageB_Build_Reg040
     plus the drawbar zone blocks (DrawbarPreset_EnvDescTable, dir +0x70), whose selectors
     WaveSel_StageB_Build_Reg040_Footage reads.

  A wave source's name is the catalogue row the firmware's own name maps give for the StageA1 pair:
  catalogue A (dir +0x50) through map +0x44 (families 0x00 / 0xC0) or +0x48 (0x80), and the percussion
  catalogue (dir +0x8C) through map +0x4C (family 0x40) -- the inverse property is proved in
  ../technics-docs tone-database.md (333/333, 141/141 rows).

  Not walked: the global mode word's alternate StageA2 maps (+0x9C/+0xA0/+0xA4, which alias the standard
  ones in the factory data), the RAM user-tone banks (family & 0x30 == 0x10), Voice_Init_Type1's
  (tick & 7) offset and WaveSel_StageB_Store_Reg040's class doubling under mode bit 2.

RUN
  python3 notes/waveform-ic307-2026-10-29/probes/tonedb_selector_users.py            # class census
  python3 notes/waveform-ic307-2026-10-29/probes/tonedb_selector_users.py 0x4000 0x50a6
                                                                                     # users of selectors
  Imported by scripts/generators/gen_waveform_ic307_s.py (function users()).
"""
import collections
import pathlib
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
TD = ROOT / "original_ROMs" / "kn5000_table_data.rom"
B, DB = 0x800000, 0x830000


class ToneDB:
    def __init__(self, path=TD):
        self.r = pathlib.Path(path).read_bytes()

    def u8(self, a):
        return self.r[a - B]

    def u16(self, a):
        return struct.unpack_from("<H", self.r, a - B)[0]

    def u32(self, a):
        return struct.unpack_from("<I", self.r, a - B)[0]

    def slot(self, s):
        return DB + self.u32(DB + s)

    def text(self, a, n):
        return self.r[a - B:a - B + n].decode("latin-1").strip()


def users(path=TD):
    """{selector: {"src": set(names), "tone": set(names), "perc": set(names), "set": set(ints),
    "drawbar": set((block, record))}} plus a dict of SET numbers -> selectors.  block 0..2 is
    DrawbarPreset_EnvData_0.._2 in address order; record z is the 6-byte zone record's index."""
    t = ToneDB(path)
    out = collections.defaultdict(lambda: {"src": set(), "tone": set(), "perc": set(), "set": set(),
                                           "drawbar": set()})

    # SET descriptors and their zone chunks (record count = chunk length / stride, as the
    # tonedb_selector_coverage.py probe measures it: the 974 chunks tile 0x85B09D-0x863078).
    sets = t.slot(0x30)
    nset = 487
    desc = [(t.u8(sets + 15 * i), t.u32(sets + 15 * i + 1), t.u32(sets + 15 * i + 5)) for i in range(nset)]
    offs = sorted({a for _, a, _ in desc} | {b for _, _, b in desc})
    end = 0x863079 - DB
    nxt = {o: (offs[k + 1] if k + 1 < len(offs) else end) for k, o in enumerate(offs)}
    set_sel = {}
    for i, (fl, _a, b) in enumerate(desc):
        st = 6 if fl & 0x80 else 4
        set_sel[i] = [t.u16(DB + b + z * st) for z in range((nxt[b] - b) // st)]

    # StageA2: pair -> SET number
    a2 = {0x00: 0x24, 0xC0: 0x24, 0x80: 0x28, 0x40: 0x2C}
    a2set = {0x00: 0x30, 0xC0: 0x30, 0x80: 0x34, 0x40: 0x38}

    def stage_a2(w, f):
        m = t.slot(a2[f & 0xC0])
        n = t.u16(m + 2 * ((f & 0x0F) * 128 + (w & 0x7F)))
        if a2set[f & 0xC0] != 0x30 and t.slot(a2set[f & 0xC0]) != sets:
            raise SystemExit("SET array slot differs from +0x30: walk needs extending")
        return n

    # StageA1: pair -> velocity-split record -> reachable bands' pairs
    a1 = {0x00: (0x0C, 0x18, 0xEA), 0xC0: (0x0C, 0x18, 0xEA), 0x80: (0x10, 0x1C, 0xEA),
          0x40: (0x14, 0x20, 0xF0)}

    def stage_a1(w, f):
        ms, vs, ss = a1[f & 0xC0]
        idx = t.u16(t.slot(ms) + 2 * ((f & 0x0F) * 128 + (w & 0x7F)))
        rec = t.slot(vs) + idx * t.u16(DB + ss)
        th = [t.u8(rec + k) for k in range(3)]
        bands = set()
        for v in range(1, 128):
            bands.add(0 if v <= th[0] else 1 if v <= th[1] else 2 if v <= th[2] else 3)
        return [(t.u8(rec + 3 + 2 * z), t.u8(rec + 4 + 2 * z)) for z in sorted(bands)]

    # catalogue names of StageA1 pairs
    def cat_name(w, f):
        if f & 0xC0 == 0x40:
            m, lst = t.slot(0x4C), t.slot(0x8C)
        else:
            m, lst = t.slot(0x48 if f & 0xC0 == 0x80 else 0x44), t.slot(0x50)
        row = t.u16(m + 2 * ((f & 0x0F) * 128 + (w & 0x7F)))
        return t.text(lst + 16 * row, 13)

    def walk(w, f, tag, name):
        if f & 0x30 == 0x10:          # user-tone RAM bank: not factory data
            return
        src = cat_name(w, f)
        for w2, f2 in stage_a1(w, f):
            sn = stage_a2(w2, f2)
            for s in set_sel[sn]:
                u = out[s]
                u["src"].add(src)
                u["set"].add(sn)
                if tag:
                    u[tag].add(name)

    # tone records (0x8324D4-0x855A47): name +0x00, N-1 partial blocks of 81 B from +0x66
    tab = t.slot(0x08)
    toffs = sorted({t.u32(tab + 4 * i) for i in range(629)})
    recs = [DB + o for o in toffs if 0x8324D4 <= DB + o < 0x855A48]
    for k, a in enumerate(recs):
        e = recs[k + 1] if k + 1 < len(recs) else 0x855A48
        n = (e - a - 21) // 81
        name = t.text(a, 16)
        for p in range(n - 1):
            blk = a + 0x66 + 81 * p
            walk(t.u8(blk + 2), t.u8(blk + 3), "tone", name)

    # drum instruments: 610 x 58 B, layers at +0x10 / +0x25 (mask +0x0D bits 0 / 2)
    pi, st = t.slot(0x78), t.u16(DB + 0xEE)
    for k in range(610):
        a = pi + st * k
        name = t.text(a, 13)
        mask = t.u8(a + 0x0D)
        for bit, lay in ((0x01, 0x10), (0x04, 0x25)):
            if mask & bit:
                walk(t.u8(a + lay + 1), t.u8(a + lay + 2), "perc", name)

    # every catalogued source, so that a source no tone uses is still named
    for lst_slot, n, maps in ((0x50, 333, None), (0x8C, 141, None)):
        lst = t.slot(lst_slot)
        for row in range(n):
            w, f = t.u8(lst + 16 * row + 14), t.u8(lst + 16 * row + 15)
            walk(w, f, None, None)

    # drawbar zone blocks (DrawbarPreset_EnvDescTable, 4 x 15 B, stride 6)
    dd = t.slot(0x70)
    bs = sorted({DB + t.u32(dd + 15 * i + 5) for i in range(4)})
    ends = bs[1:] + [0x872C91]
    for k, (b0, b1) in enumerate(zip(bs, ends)):
        for z in range((b1 - b0) // 6):
            out[t.u16(b0 + 6 * z)]["drawbar"].add((k, z))
    return out, set_sel


def main():
    u, set_sel = users()
    if len(sys.argv) > 1:
        for s in sys.argv[1:]:
            s = int(s, 0)
            x = u.get(s)
            print("0x%04x" % s, "unused" if x is None else
                  {k: (sorted(v) if isinstance(v, set) else v) for k, v in x.items()})
        return
    allsel = set()
    for v in set_sel.values():
        allsel |= set(v)
    by = collections.defaultdict(set)
    for s in u:
        by[s >> 12].add(s & 0xFFF)
    print("distinct selectors in the 487 SETs' zone records: %d" % len(allsel))
    print("distinct selectors reached by the walk (tones + drums + catalogue + drawbar): %d" % len(u))
    for c in range(8):
        e = by[c]
        print("class %d: %4d distinct entries, max entry %s" % (c, len(e), max(e) if e else "-"))


if __name__ == "__main__":
    main()
