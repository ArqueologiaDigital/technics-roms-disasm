#!/usr/bin/env python3
"""ic307_record_words.py -- what do IC307's record "sequence words" encode?  (open item N-52dcf02a)

IC307 is the Y chip of a word-interleaved pair (notes/media-files-2026-10-30): a KN7000-style record
[B, p0, p1, p2, ...] lies in the stream as B (Y), p0 (X), p1 (Y), p2 (X) ..., so IC307 holds B, p1, p3, ...
and the undumped partner IC306 holds p0, p2, ....  The KN7000 dumps hold both halves of their records.
This probe pairs every IC307 entry with the KN7000 entries that play the same recording and asks:

  A. field map: does each IC307 word kind (key split / sequence, `end` bit 7, `mark` bit 6) line up
     with a KN7000 word kind (split-list value / segment, LOOP_END-or-REC_END 0x8000, LOOP_START 0x4000)?
  B. the two 3-bit fields (a = bits 13:11, b = bits 10:8, i.e. the KN7000 6-bit "code"):
     B1. on the KN5000 pairs: is the code non-zero only where the partner recording is 8-bit (KN7000 R8)?
     B2. on all KN7000 records (both halves): is a the b of the segment that plays next (the next one in
         the record, or after LOOP_END the first segment of the loop)?  Controls: a == b of the previous
         segment, a == its own b.
     B3. on the KN7000 8-bit recordings: how does the stored level jump across a segment boundary as b
         changes?  Signal: log2 of the RMS of the 8 bytes before over the 8 bytes after the boundary,
         regressed on (b_prev - b) and (a_prev - a); per-step medians; and the median |jump| left after
         decoding with gain 2^(-s b) for s = 0.5, 0.75, 1.
  C. how a word maps to samples: for each IC307 entry j whose record is entry i's minus its first m
     visible words (j starts inside i's audio), both with KN7000 twins: does j start inside i's segment 2m
     (the X word before the first word they share) so that j's own first, X-chip, segment ends exactly
     where i's segment 2m ends?  Segment lengths: (256 - value) granules of L = 2^(K+4) samples (K = P
     bits 2:0 of the twin; 8-bit segments count bytes, 32 per 16-word unit).

Inputs (private, read-only, nothing written):
  IC307:  $KN5000_IC307, default original_ROMs/kn5000_waveform_rom.ic307, else
          ~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307
  KN7000: $KN7000_WAVE_DIR (four chips), default ~/compartilhado/technics_romsets/kn7000

Run:  python3 ic307_record_words.py        (about 1 minute)
"""
import math
import os
import struct
import sys
from collections import Counter, defaultdict
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve()
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / "kn7000" / "notes" / "wave-roms-probes"))
from wavestream import stream, entries, PAGE, NPAGES, CHIPS, WAVE_DIR  # noqa: E402

PAGE5 = 0x100000
_ic = os.environ.get("KN5000_IC307")
IC307 = Path(_ic) if _ic else (ROOT / "original_ROMs" / "kn5000_waveform_rom.ic307")
if not IC307.exists():
    IC307 = Path.home() / "compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307"


def u16s(b):
    return list(struct.unpack("<%dH" % (len(b) // 2), b))


def ic307_entries(rom):
    """(page, entry, wave start in 16-byte units, record words after the head)"""
    for p in range(4):
        base = p * PAGE5
        n = struct.unpack_from("<H", rom, base)[0] // 4
        dirs = [struct.unpack_from("<HH", rom, base + 4 * i) for i in range(n)]
        for i, (r, w) in enumerate(dirs):
            if i + 1 < n:
                end = dirs[i + 1][0]
            else:
                end = r + 2
                while struct.unpack_from("<H", rom, base + end)[0] != 0:
                    end += 2
            rec = u16s(rom[base + r:base + end])
            assert rec[0] == w
            body = rec[1:]
            while body and body[-1] == 0:
                body.pop()
            yield p, i, w, body


def kn7000_records(tg):
    s = stream(tg)
    out = {}                                   # (page, B) -> [(P, params)]
    for p in range(NPAGES):
        b = p * PAGE
        for (A, P, B, Q) in entries(s, p):
            k, params = b + A + 1, []
            while True:
                v = int(s[k])
                params.append(v)
                k += 1
                if v & 0x8000:
                    break
            out.setdefault((p, B), []).append((P, params))
    return s, out


def kind5(v):
    """IC307 word kind, as notes/waveform-ic307-2026-10-29 classifies it"""
    fl, val = v >> 8, v & 0xFF
    if (fl & 0x3F) == 0 and val % 8 == 0 and val <= 0x80:
        return "split"
    return "seq"


def kind7(v):
    val = v & 0xFF
    if val >= 0x80:
        return "segment"
    if val == 0:
        return "zero"
    return "split"


def main():
    rom = IC307.read_bytes()
    ks = {tg: kn7000_records(tg) for tg in CHIPS}
    ybytes = {tg: (Path(WAVE_DIR) / CHIPS[tg][0]).read_bytes() for tg in CHIPS}

    # ---- pairing
    pairs = {}                                 # (p, i) -> (tg, kpage, P, params)  (first exact odd match)
    ic = {}
    st = Counter()
    for p, i, w, body in ic307_entries(rom):
        ic[(p, i)] = (w, body)
        key = rom[p * PAGE5 + 16 * w:p * PAGE5 + 16 * w + 64]
        found = None
        for tg in CHIPS:
            yo = ybytes[tg].find(key)
            if yo >= 0 and yo % 2 == 0:
                kp, off = divmod(yo, PAGE)    # Y byte yo = stream word yo
                if off % 16 == 0 and (kp, off // 16) in ks[tg][1]:
                    found = (tg, kp, ks[tg][1][(kp, off // 16)])
                break
        st["IC307 entries"] += 1
        if not found:
            st["no KN7000 recording starts with this wave"] += 1
            continue
        tg, kp, cands = found
        hit = [(P, q) for P, q in cands if q[1::2][:len(body)] == body]
        if not body:
            st["head-only IC307 record (no words to compare)"] += 1
            if hit:
                pairs[(p, i)] = (tg, kp) + hit[0]
            continue
        if hit:
            st["record == the twin's p1, p3, p5, ... (exact)"] += 1
            pairs[(p, i)] = (tg, kp) + hit[0]
        elif any(q[0::2][:len(body)] == body for P, q in cands):
            st["record == the twin's p0, p2, ... (control)"] += 1
        else:
            st["twin found, records differ"] += 1
    print("PAIRING")
    for k, v in st.items():
        print("  %-48s %5d" % (k, v))

    # ---- A. field map over the exact pairs
    fm = Counter()
    for (p, i), (tg, kp, P, q) in pairs.items():
        body = ic[(p, i)][1]
        for m, v in enumerate(body):
            t = q[2 * m + 1]
            assert t == v
            fm[(kind5(v), kind7(v), "end" if v & 0x8000 else "-", "mark" if v & 0x4000 else "-")] += 1
    print("\nA. IC307 word kind vs KN7000 meaning of the same word (exact pairs)")
    print("  %-6s %-8s %-4s %-5s %6s" % ("IC307", "KN7000", "b7", "b6", "words"))
    for k, v in sorted(fm.items(), key=lambda x: -x[1]):
        print("  %-6s %-8s %-4s %-5s %6d" % (k + (v,)))
    # bit 7 / bit 6 in KN7000 terms: where in the full record do they sit?
    endpos = Counter()
    for (p, i), (tg, kp, P, q) in pairs.items():
        for k, v in enumerate(q):
            if v & 0x8000:
                endpos["0x8000 on the record's last word" if k == len(q) - 1 else "0x8000 not last"] += 1
            if v & 0x4000 and not v & 0x8000:
                endpos["0x4000 alone (LOOP_START)"] += 1
            if v & 0xC000 == 0xC000:
                endpos["0xC000 (REC_END)"] += 1
    for k, v in sorted(endpos.items()):
        print("  %-40s %6d" % (k, v))

    # ---- B1. code vs the twin's 8-bit flag
    b1 = Counter()
    for (p, i), (tg, kp, P, q) in pairs.items():
        is8 = bool(P & 8)
        for v in ic[(p, i)][1]:
            if kind7(v) == "segment":
                b1[("8-bit" if is8 else "16-bit", "code != 0" if (v >> 8) & 0x3F else "code == 0")] += 1
    print("\nB1. segment words of the exact pairs: code field vs the twin recording's format (P bit 3)")
    for k, v in sorted(b1.items()):
        print("  %-7s %-10s %6d" % (k + (v,)))
    # and over all IC307 words: which entries carry codes at all
    allc = Counter()
    for (p, i), (w, body) in ic.items():
        tw = pairs.get((p, i))
        fmt = "unpaired" if tw is None else ("8-bit" if tw[2] & 8 else "16-bit")
        for v in body:
            if kind7(v) == "segment":
                allc[(fmt, "code != 0" if (v >> 8) & 0x3F else "code == 0")] += 1
    print("  all IC307 segment words, by the twin's format:")
    for k, v in sorted(allc.items()):
        print("    %-9s %-10s %6d" % (k + (v,)))

    # ---- B2 / B3 on the KN7000's own records (both halves)
    rel = Counter()
    inner, midj = [], []                        # within-segment level splits; mid-segment control jumps
    jumps = []                                  # (log2 RMS jump at a boundary, a_prev, b_prev, a, b)
    for tg in CHIPS:
        s = ks[tg][0]
        for p in range(NPAGES):
            base = p * PAGE
            for (A, P, B, Q) in entries(s, p):
                k, params = base + A + 1, []
                while True:
                    v = int(s[k])
                    params.append(v)
                    k += 1
                    if v & 0x8000:
                        break
                segs = [v for v in params if (v & 0xFF) >= 0x80]
                if not segs:
                    continue
                fmt = "8-bit" if P & 8 else "16-bit"
                fa = lambda v: (v >> 11) & 7       # noqa: E731
                fb = lambda v: (v >> 8) & 7        # noqa: E731
                for x, y in zip(segs, segs[1:]):
                    rel[(fmt, "a(this) == b(next segment)", "")] += fa(x) == fb(y)
                    rel[(fmt, "a(this) == b(next segment)", "n")] += 1
                    rel[(fmt, "a(next) == b(this)  (control)", "")] += fa(y) == fb(x)
                    rel[(fmt, "a(next) == b(this)  (control)", "n")] += 1
                    rel[(fmt, "a(this) == b(this)  (control)", "")] += fa(x) == fb(x)
                    rel[(fmt, "a(this) == b(this)  (control)", "n")] += 1
                last = segs[-1]
                ls = [i for i, v in enumerate(segs) if v & 0x4000 and not v & 0x8000]
                if last & 0x8000 and ls and ls[0] + 1 < len(segs):
                    rel[(fmt, "LOOP_END segment: a == b(first segment of the loop)", "")] += fa(last) == fb(segs[ls[0] + 1])
                    rel[(fmt, "LOOP_END segment: a == b(first segment of the loop)", "n")] += 1
                else:
                    rel[(fmt, "last segment, no loop: a == b(itself)", "")] += fa(last) == fb(last)
                    rel[(fmt, "last segment, no loop: a == b(itself)", "n")] += 1
                if not P & 8:
                    continue
                L = 1 << ((P & 7) + 4)
                data = s[base + B * 16: base + PAGE].view(np.int8).astype(np.float64)
                pos, prev = 0, None
                for v in segs:
                    n = (256 - (v & 0xFF)) * L
                    if pos + n <= data.size and n >= 32:
                        seg = data[pos:pos + n]
                        ix = np.arange(n)
                        rms = lambda z: math.sqrt(np.mean(z ** 2)) + 1e-9   # noqa: E731
                        if rms(seg) > 2.0:
                            inner.append((fa(v) - fb(v),
                                          math.log2(rms(seg[ix % 2 == 0]) / rms(seg[ix % 2 == 1])),
                                          math.log2(rms(seg[(ix // 2) % 2 == 0]) / rms(seg[(ix // 2) % 2 == 1])),
                                          math.log2(rms(seg[:n // 4]) / rms(seg[3 * n // 4:]))))
                        if n >= 32:
                            mid = pos + n // 2
                            r0 = math.sqrt(np.mean(data[mid - 8:mid] ** 2))
                            r1 = math.sqrt(np.mean(data[mid:mid + 8] ** 2))
                            if min(r0, r1) > 2.0:
                                midj.append(abs(math.log2(r0 / r1)))
                    if prev is not None and pos >= 8 and pos + 8 <= data.size:
                        r0 = math.sqrt(np.mean(data[pos - 8:pos] ** 2))
                        r1 = math.sqrt(np.mean(data[pos:pos + 8] ** 2))
                        if min(r0, r1) > 2.0:          # skip near-silent boundaries
                            jumps.append((math.log2(r0 / r1), fa(prev), fb(prev), fa(v), fb(v)))
                    prev = v
                    pos += n
    print("\nB2. KN7000 records (both halves): what the 3-bit field a is")
    for (fmt, what, t) in sorted(k for k in rel if k[2] == ""):
        n = rel[(fmt, what, "n")]
        print("  %-6s %-52s %6d of %6d  (%.1f %%)" % (fmt, what, rel[(fmt, what, "")], n, 100.0 * rel[(fmt, what, "")] / max(n, 1)))
    J = np.array(jumps)
    d, pa, pb, a, b = J[:, 0], J[:, 1], J[:, 2], J[:, 3], J[:, 4]
    print("\nB3. KN7000 8-bit recordings: the stored level across %d segment boundaries" % len(d))
    print("    (log2 of RMS(8 bytes before) / RMS(8 bytes after); boundaries with RMS <= 2 on a side skipped)")
    coef = np.linalg.lstsq(np.vstack([pb - b, pa - a]).T, d, rcond=None)[0]
    print("  least squares: jump = %.3f x (b_prev - b) + %.3f x (a_prev - a)" % (coef[0], coef[1]))
    for x0, x1 in ((0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (1, 0), (2, 1), (3, 2), (4, 3), (5, 4)):
        sel = (pb == x0) & (b == x1)
        if sel.sum() > 30:
            print("  b %d -> %d: %5d boundaries, median jump %+.3f" % (x0, x1, int(sel.sum()), float(np.median(d[sel]))))
    for st in (0.5, 0.75, 1.0):
        print("  decoded = raw x 2^(-%.2f b): median |jump| %.3f   (raw: %.3f)"
              % (st, float(np.median(np.abs(d - st * (pb - b)))), float(np.median(np.abs(d)))))
    print("  control: the same 8-byte jump measured mid-segment (no boundary), raw: median %.3f over %d segments"
          % (float(np.median(midj)), len(midj)))
    I = np.array(inner)
    print("  does a change the stored level inside a segment?  median log2 ratio by (a - b), %d segments:" % len(I))
    for col, what in ((1, "even / odd bytes"), (2, "Y-chip / X-chip words"), (3, "first / last quarter")):
        med = {k: float(np.median(I[I[:, 0] == k, col])) for k in (-1, 0, 1) if (I[:, 0] == k).sum() > 50}
        print("    %-22s %s" % (what, "  ".join("a-b=%+d: %+.3f" % (k, v) for k, v in med.items())))

    # ---- C. entries that start inside another's audio
    print("\nC. an IC307 entry j whose record is entry i's minus its first m visible words (both with twins)")
    res = Counter()
    for p in range(4):
        ids = sorted(i for (pp, i) in ic if pp == p)
        for j in ids:
            wj, bj = ic[(p, j)]
            if len(bj) < 1 or (p, j) not in pairs:
                continue
            for i in ids:
                wi, bi = ic[(p, i)]
                if i == j or len(bi) <= len(bj) or bi[len(bi) - len(bj):] != bj or wj <= wi:
                    continue
                if (p, i) not in pairs:
                    continue
                m = len(bi) - len(bj)
                Pi, qi = pairs[(p, i)][2], pairs[(p, i)][3]
                Pj, qj = pairs[(p, j)][2], pairs[(p, j)][3]
                L = 1 << ((Pi & 7) + 4)
                unit = 32 if Pi & 8 else 16      # samples per 16-word unit
                cum = [0]
                for v in qi:
                    cum.append(cum[-1] + ((256 - (v & 0xFF)) * L / unit if (v & 0xFF) >= 0x80 else 0))
                if 2 * m + 1 >= len(cum) or (qj[0] & 0xFF) < 0x80:
                    continue
                first = (256 - (qj[0] & 0xFF)) * L / unit
                inside = wj - wi < cum[-1]
                if not inside:
                    res["j's audio is not inside i's (a coincidental record match)"] += 1
                    break
                ok_end = wj - wi + first == cum[2 * m + 1]
                ok_rest = qj[1:] == qi[2 * m + 1:2 * m + 1 + len(qj) - 1]
                res["start + j's first (X) segment == end of i's segment 2m"] += ok_end
                res["j's twin record == i's twin record from word 2m+1 on"] += ok_rest
                res["checked"] += 1
                print("  page %d: %4d inside %4d: starts %4d units in; i's segment 2m ends at %g; j's first segment %g"
                      % (p, j, i, wj - wi, cum[2 * m + 1], first))
                break
    for k, v in res.items():
        print("  %-60s %4d" % (k, v))


if __name__ == "__main__":
    main()
