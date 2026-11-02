#!/usr/bin/env python3
"""wave_page_order.py -- QUESTION: are the 16 pages of each wave stream in their true order, or could a
permutation of whole pages hide in the dump?  (wave-roms-2026-10-29.md, "The page order"; item N-564dcd72)

Each page is self-contained, so the wave data alone cannot tell.  The firmware's tone database can: every
zone of the 'JK' voice archive (table segment 6, src/table/voices/internal_archive.s: the 3,753 zones of the
864 zone lists and the 1,462 of JkKitZones) names a (page, entry) on one TG (flags 0x04 MAIN, 0x08 SUB;
TgVoiceSideSelect 0x4C02BECB, notes/mn10300-rest-probes/tg_side_bits.py).  Two signals:

  1. Entry existence.  A permutation s of the pages is possible only if every zone's entry exists in the
     page s(page): N[s(p)] > the highest entry any zone names in page p.  The probe counts the
     permutations that pass (the permanent of that 16 x 16 0/1 matrix, Ryser's formula).
  2. Pitch order, for permutations that pass 1.  A multisampled sound's zones rise in key, so the period of
     the recording each one plays, in samples, falls: log2(period) = E - 9 + corr/3072 (E = the entry's
     pitch exponent, P bits 8:4; corr = the 8-byte zone's s16 at +6; tools/wave_root_rates.py).  For the
     neighbouring zone pairs (same parameter record, same TG, ordered by their lowest key) that touch a page
     the permutation moves, it counts the pairs where log2(period) RISES by more than half an octave going
     up the keyboard: a deliberate detune moves it by less, a recording from the wrong page by whole
     octaves.  The same count is printed for the dump's own order over the same pairs.

Signal: "permutations consistent with entry existence: 1" (identity only), or for those that remain, few
rising pairs as dumped and many with the pages swapped.

RUN (from kn7000/, after `make` has made baserom/kn7000_table.rom):
    python3 -I notes/wave-roms-probes/wave_page_order.py
Reads the four chip images (wavestream.py: $KN7000_WAVE_DIR) and the table image; prints numbers only.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
K = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(K, "tools"))
from wavestream import stream, entries, NPAGES          # noqa: E402
import wave_root_rates as W                              # noqa: E402

TG = {"Main": "main", "Sub": "sub"}


def zones_from_source():
    """[(tg, page, entry)] for every jk_zone6 / jk_zone8 line of the archive source"""
    out = []
    with open(os.path.join(K, "src/table/voices/internal_archive.s"), "rb") as f:
        for ln in f:
            m = re.match(rb"\s+jk_zone[68]\s+([^#]+)", ln)
            if m:
                a = [int(x, 0) for x in m.group(1).decode().split(",")]
                out.append(("Main" if a[1] & 0x0C == 0x04 else "Sub", a[0], a[2] & 0xFFF))
    return out


def permanent(M):
    n, tot = len(M), 0
    for S in range(1, 1 << n):
        prod = 1
        for row in M:
            prod *= sum(row[j] for j in range(n) if S >> j & 1)
            if not prod:
                break
        tot += (-1) ** bin(S).count("1") * prod
    return (-1) ** n * tot


def perms(M):
    """the permutations themselves (only called when the permanent is small)"""
    n = len(M)
    out = []

    def rec(i, used, acc):
        if i == n:
            out.append(tuple(acc))
            return
        for j in range(n):
            if M[i][j] and j not in used:
                rec(i + 1, used | {j}, acc + [j])
    rec(0, frozenset(), [])
    return out


def main():
    dirs = {t: [entries(s, p) for p in range(NPAGES)] for t, s in ((t, stream(TG[t])) for t in TG)}
    Z = zones_from_source()
    params = W.params(W.archive(os.path.join(K, "baserom/kn7000_table.rom")))
    print(f"{len(Z)} zones read from src/table/voices/internal_archive.s; {len(params)} parameter records")
    for t in TG:
        N = [len(d) for d in dirs[t]]
        mx = [-1] * NPAGES
        for tg, p, e in Z:
            if tg == t:
                mx[p] = max(mx[p], e)
        M = [[int(N[q] > mx[p]) for q in range(NPAGES)] for p in range(NPAGES)]
        n = permanent(M)
        print(f"\n{t}: entries per page      {N}")
        print(f"{t}: highest entry named    {mx}")
        print(f"{t}: permutations consistent with entry existence: {n}")
        if n > 24:
            continue
        ident = tuple(range(NPAGES))

        def pairs(sg, pr):
            """[(rise of log2(period) from one zone to the next higher, pages of the two zones)]"""
            zk = W.zone_keys(pr)
            rows = []
            for zi, z in enumerate(pr["zones"]):
                if W.side_tg(z["fb"]) == t and zk.get(zi):
                    P = dirs[t][sg[z["page"]]][z["ent"]][1]
                    rows.append((min(zk[zi]), ((P >> 4) & 0x1F) - 9 + z["corr"] / 3072, z["page"]))
            rows.sort()
            return [(b[1] - a[1], {a[2], b[2]}) for a, b in zip(rows, rows[1:])]

        allp = [x for pr in params for x in pairs(ident, pr)]
        print(f"{t}:   as dumped, all pages: {sum(r > 0.5 for r, _ in allp)} of {len(allp)} neighbouring zone pairs"
              f" rise by more than half an octave")
        for sg in perms(M):
            moved = {p for p in range(NPAGES) if sg[p] != p}
            if not moved:
                continue
            n_id = n_alt = tot = 0
            for pr in params:
                for (ri, pg), (ra, _) in zip(pairs(ident, pr), pairs(sg, pr)):
                    if pg & moved:
                        tot += 1
                        n_id += ri > 0.5
                        n_alt += ra > 0.5
            what = ", ".join(f"0x{p:02X}->0x{sg[p]:02X}" for p in sorted(moved))
            print(f"{t}:   the alternative {what}: of the {tot} neighbouring zone pairs that touch those pages,"
                  f" {n_id} rise by more than half an octave as dumped, {n_alt} with the pages swapped")

if __name__ == "__main__":
    main()
