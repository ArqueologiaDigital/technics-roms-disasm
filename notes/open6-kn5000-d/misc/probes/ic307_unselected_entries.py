#!/usr/bin/env python3
"""ic307_unselected_entries.py -- why do some IC307 directory entries have no recording selector?
(open item N-d352b868)

notes/waveform-ic307-2026-10-29 lists the IC307 entries that no factory selector names: page 0 entries 0,
152, 159; page 1 entries 77, 80, 83, 85; page 2 entries 0, 24 and 63 of 41-111.  This probe checks the
paths that walk did not follow:

  1. Every one of the 487 SET descriptors' zone records (not only the SETs the walk reaches) and the drawbar
     zone records: does any name an unselected entry?  RAM user tones (VoiceParam_Update's bit-0 path,
     ToneDB_RamBankA / B) hold velocity-split records whose band pairs index the same StageA2 maps and
     SETs, so a SET that names no such entry is a dead end for user tones and disk sounds as well.
  2. Voice_Init_Type1 calls Voice_Slot_ApplyPitchJitter, which adds (tick & 7) to the staged recording
     selector (0x0451CE = TG register +0x040, ToneGen_StagingBlock banner).  Voice_Init_Type1 runs only from
     Voice_SetPitch / Voice_NoteOff, whose guard is (patch record +0x10 & 0xC0) == 0x40.  Which patch records
     (the dir +0x08 table, ToneDB_Find_ToneRecord / ToneDB_Find_PatchRecord) pass that guard, and which
     unselected entries lie 1..7 above a used entry that is a multiple of 8 (what selector + (tick & 7)
     would reach)?  (Which selector the guarded parts' layers actually stage is not walked here: their
     layer goes through Voice_Allocate_1of4, partial block +0x0B..+0x0D -> ToneDB_Find_ToneRecord /
     ToneDB_Find_SubToneRecord, which this probe does not model.)
  3. For whatever is left: what the entry is (record, wave start, whether it shares a wave or starts inside
     another entry's audio).

Inputs: original_ROMs/kn5000_table_data.rom (tracked) and the IC307 image (as ic307_record_words.py).
Run:    python3 ic307_unselected_entries.py      (about 10 s)
"""
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve()
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / "notes" / "waveform-ic307-2026-10-29" / "probes"))
import tonedb_selector_users as T  # noqa: E402

sys.path.insert(0, str(HERE.parent))
from ic307_record_words import IC307, ic307_entries, kn7000_records, CHIPS, WAVE_DIR, PAGE5  # noqa: E402

N = {4: 198, 5: 168, 6: 1072, 7: 57}          # IC307 page = class & 3, entries per page


def main():
    users, set_sel = T.users()
    t = T.ToneDB()
    DB = T.DB
    used = {c: {s & 0xFFF for s in users if s >> 12 == c} for c in N}
    unsel = {c: [e for e in range(N[c]) if e not in used[c]] for c in N}
    print("1. entries no factory selector names (walk of notes/waveform-ic307-2026-10-29):")
    for c in N:
        print("   class %d (page %d): %d entries: %s" % (c, c & 3, len(unsel[c]), unsel[c]))

    any_set = set()
    for v in set_sel.values():
        any_set |= set(v)
    drawbar = {s for s, u in users.items() if u["drawbar"]}
    reached = set().union(*[u["set"] for u in users.values()])
    hits = [(c, e) for c in N for e in unsel[c] if ((c << 12) | e) in any_set or ((c << 12) | e) in drawbar]
    print("   SETs whose zone records the walk does not reach: %s" % sorted(set(set_sel) - reached))
    print("   unselected entries named by ANY of the %d SETs' zone records or the drawbar records: %d %s"
          % (len(set_sel), len(hits), hits))

    # 2. the (tick & 7) path
    tab = t.slot(0x08)
    offs = sorted({t.u32(tab + 4 * i) for i in range(629)})
    rhythm = [DB + o for o in offs if t.u8(DB + o + 0x10) & 0xC0 == 0x40]
    print("\n2. patch records (dir +0x08 table, %d distinct) with (+0x10 & 0xC0) == 0x40, the guard of"
          " Voice_SetPitch / Voice_NoteOff, the only callers of Voice_Init_Type1:" % len(offs))
    for a in rhythm:
        print("   0x%06X %-18s +0x10 = 0x%02X" % (a, repr(t.text(a, 16)), t.u8(a + 0x10)))
    print("   unselected entries e with a used entry s = 8k, s < e <= s + 7 (so s + (tick & 7) reaches e):")
    jitter = set()
    for c in N:
        groups = {}
        for e in unsel[c]:
            below = [x for x in used[c] if x < e]
            s0 = max(below) if below else None
            if s0 is not None and s0 % 8 == 0 and e - s0 <= 7:
                groups.setdefault(s0, []).append(e)
                jitter.add((c << 12) | e)
        for s0, es in sorted(groups.items()):
            u = users[(c << 12) | s0]
            print("     class %d: s = %4d (0x%04X: sources %s; tones %s; drum instruments %s): %s"
                  % (c, s0, (c << 12) | s0, sorted(u["src"]), sorted(u["tone"]), sorted(u["perc"]), es))
        if groups:
            print("     class %d total: %d entries" % (c, sum(len(v) for v in groups.values())))

    # 3. what is left
    rom = IC307.read_bytes()
    ic = {(p, i): (w, b) for p, i, w, b in ic307_entries(rom)}
    ks = {tg: kn7000_records(tg)[1] for tg in CHIPS}
    yb = {tg: (Path(WAVE_DIR) / CHIPS[tg][0]).read_bytes() for tg in CHIPS}
    print("\n3. the rest (KN7000 twin: the KN7000 recording that starts with the same Y-chip bytes, and how many"
          " KN7000 directory entries play it):")
    for c in N:
        p = c & 3
        starts = sorted({w for (pp, i), (w, b) in ic.items() if pp == p})
        for e in unsel[c]:
            if ((c << 12) | e) in jitter:
                continue
            w, body = ic[(p, e)]
            same = [i for (pp, i), (ww, bb) in ic.items() if pp == p and ww == w and i != e]
            nxt = [s for s in starts if s > w]
            ln = (nxt[0] - w) * 16 if nxt else None
            prev = ic.get((p, e - 1))
            key = rom[p * PAGE5 + 16 * w:p * PAGE5 + 16 * w + min(64, ln or 64)]
            twin = "none"
            for tg in CHIPS:
                yo = yb[tg].find(key)
                while yo >= 0 and (yo % 32):
                    yo = yb[tg].find(key, yo + 1)
                if yo >= 0:
                    kp, off = divmod(yo, 0x100000)
                    n7 = len(ks[tg].get((kp, off // 16), []))
                    twin = "%s page 0x%02X B %d (%d entries)" % (tg, kp, off // 16, n7)
                    break
            print("   page %d entry %4d: wave %5d (%s B), %2d record words %s; shares its wave with %s; entry %d's wave %s;"
                  " KN7000 twin: %s"
                  % (p, e, w, ln, len(body), " ".join("%04x" % v for v in body[:4]) + (" ..." if len(body) > 4 else ""),
                     same or "none", e - 1, "-" if prev is None else prev[0], twin))


if __name__ == "__main__":
    main()
