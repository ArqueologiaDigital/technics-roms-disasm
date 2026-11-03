#!/usr/bin/env python3
"""gen_ic307_wav_manifest.py -- write the WAV manifest of KN5000 IC307's recordings, and name the KN7000's.

QUESTION ANSWERED: for each of IC307's 1,413 PCM items, where is it, how is it encoded, and what WAV file
holds it?  scripts/build/pcm_wav.py reads the manifest to extract the WAVs from the reference image and
to turn them back into the raw items the source includes.

WHAT IT READS
  waveform/ic307_page0.s .. page3.s   every PCM item: label, ROM offset, size (from its `.incbin` with an
                                      explicit file offset, or, once respelled, from the manifest it wrote)
                                      and the comment block above it (wave index, entries, sources)
  the IC307 reference image           the bytes, to find each item in the KN7000 chips
  the KN7000 wave ROM chips           IC203 / IC207 (Y) and IC204 / IC208 (X), and kn7000/src/wave/*_wav.tsv
                                      or *.s for where each KN7000 recording is and its format

THE FORMAT OF AN ITEM (notes/media-files-2026-10-30/README.md; probes notes/media-files-probes/)
  IC307 is the Y chip of a word-interleaved pair, like the KN7000's: 1,342 of its items occur verbatim in
  the KN7000's Y chips (ic307_kn7000_match.py).  The format flag is in each directory entry's P word,
  which is on the undumped partner chip, so it is taken from the KN7000 recording that holds the same
  audio, where there is one (evidence `kn7000 <label>`); otherwise from the low/high byte correlation,
  > 0.5 = two 8-bit samples per word (calibrated on the matched items: 0 of 1,170 16-bit ones exceed it),
  for items of 64 B or more (evidence `byte correlation`); otherwise 16-bit (evidence `default`).
  Either reading maps the bytes losslessly; the format only decides how a player sounds them.

  rate  No rate is stored in the ROM.  An item that holds the even words of a KN7000 recording from its
        first sample (evidence `kn7000 <label>`, no offset, Y chip) gets half that recording's rate and
        the same root key, from kn7000/src/wave/root_rates.tsv (kn7000/tools/wave_root_rates.py): the
        recording is the same, and the KN5000 table data gives 355 of the 390 IC307 selectors it can
        compare exactly the KN7000's pitch correction for that recording (notes/sound-probes/
        kn5000_kn7000_correction.py), so the two instruments tune it alike.  Half, because the item
        holds every other word.  The other items keep 22050 Hz, nominal: their pitch exponent is in the
        directory's P word, on the undumped partner chip IC306 (notes/sound-2026-10-31/README.md).

OUTPUT
  waveform/wav_manifest.tsv            the manifest (no sample data)
  kn7000/src/wave/ic307_names.tsv      KN7000 recording -> the IC307 wave with the same audio, and its
                                       instrument name (gen_wave_s.py names the KN7000 WAVs from it)

    python3 scripts/generators/gen_ic307_wav_manifest.py [--ic307 PATH] [--kn7000-dir DIR]
"""
import argparse
import bisect
import math
import re
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
H = Path.home() / "compartilhado"
RATE = 22050
CHIPS = {"c3cbqd000002.ic203": ("main", "Y"), "c3cbqd000004.ic207": ("sub", "Y"),
         "c3cbqd000001.ic204": ("main", "X"), "c3cbqd000003.ic208": ("sub", "X")}
OLD = re.compile(rb'^(\w+):\s*\.incbin\s+"kn5000_waveform_rom\.ic307",\s*(0x[0-9a-f]+),\s*(\d+)')
NEW = re.compile(rb'^(\w+):\s*\.incbin\s+"pcm/(\w+)\.pcm",\s*0,\s*(\d+)')
K7 = re.compile(rb'^(\w+):\s*\.incbin(?:_range)?\s+"[^"]+",\s*(0x[0-9a-f]+),\s*(0x[0-9a-f]+).*?(\d+) (8|16)-bit')
NAME = re.compile(r'^P\d_W\d{4}_(\w+)$')


def ic307_items(manifest):
    """[(label, offset, size, page, comment lines)]"""
    known = {}
    if manifest.exists():
        for line in manifest.read_text(encoding="utf-8").splitlines()[1:]:
            f = line.split("\t")
            known[f[0]] = int(f[1], 0)
    out = []
    for p in range(4):
        cmt = []
        for line in (ROOT / f"waveform/ic307_page{p}.s").read_bytes().split(b"\n"):
            m = OLD.match(line)
            if m:
                out.append((m.group(1).decode(), int(m.group(2), 16), int(m.group(3)), p, cmt))
            else:
                m = NEW.match(line)
                if m:
                    lab = m.group(1).decode()
                    out.append((lab, known[lab], int(m.group(3)), p, cmt))
            if line.startswith(b";"):
                cmt = cmt + [line[1:].strip().decode("latin-1")]
            elif line.strip():
                cmt = []
    return out


K7_PAGE = 0x200000                  # bytes of a KN7000 stream page


def kn7000_items(tg):
    """[(start, end, label, bits)] of every KN7000 directory start in stream bytes, in order.  Since
    2026-11-03 the manifest holds one row per recording, its alternate starts as cue points (`cues`,
    `pos:label:text|...`, pos in samples), and the row ends where the recording ends; so each start is taken
    to run to the next start (or its page's end), the item the source and the WAV files had before."""
    tsv = ROOT / f"kn7000/src/wave/{tg}_wav.tsv"
    out = []
    if tsv.exists():
        lines = tsv.read_text(encoding="utf-8").splitlines()
        head = lines[0].split("\t")
        st = []
        for line in lines[1:]:
            r = dict(zip(head, line.split("\t")))
            a, bits = int(r["start"], 0), int(r["bits"])
            st.append((a, r["label"], bits))
            if r.get("cues", "-") not in ("", "-"):
                for c in r["cues"].split("|"):
                    pos, lab, _ = c.split(":", 2)
                    st.append((a + int(pos) * bits // 8, lab, bits))
        st.sort()
        for i, (a, lab, bits) in enumerate(st):
            e = (a // K7_PAGE + 1) * K7_PAGE
            if i + 1 < len(st):
                e = min(e, st[i + 1][0])
            out.append((a, e, lab, bits))
    else:
        for line in (ROOT / f"kn7000/src/wave/{tg}.s").read_bytes().split(b"\n"):
            m = K7.match(line)
            if m:
                out.append((int(m.group(2), 16), int(m.group(3), 16), m.group(1).decode(), int(m.group(5))))
    return out


def kn7000_rates():
    """{KN7000 label: (rate_hz, root)} from kn7000/src/wave/root_rates.tsv, or {} without it"""
    out = {}
    p = ROOT / "kn7000/src/wave/root_rates.tsv"
    if p.exists():
        for line in p.read_text(encoding="utf-8").splitlines():
            r = line.split("\t")
            if line.startswith("#") or r[0] == "label" or r[4] == "-":
                continue
            out[r[0]] = (float(r[4]), int(r[3]))
    return out


def corr(b):
    a = np.frombuffer(b, dtype=np.int8).astype(np.float64)
    lo, hi = a[0::2], a[1::2]
    if len(lo) < 2 or lo.std() == 0 or hi.std() == 0:
        return None
    return float(np.corrcoef(lo, hi)[0, 1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ic307", default=str(H / "technics_romsets/kn5000/kn5000_waveform_rom.ic307"))
    ap.add_argument("--kn7000-dir", default=str(H / "technics_romsets/kn7000"))
    o = ap.parse_args()
    rom = Path(o.ic307).read_bytes()
    chips = {c: (Path(o.kn7000_dir) / c).read_bytes() for c in CHIPS}
    k7 = {tg: kn7000_items(tg) for tg in ("main", "sub")}
    k7s = {tg: [r[0] for r in k7[tg]] for tg in k7}
    man = ROOT / "waveform/wav_manifest.tsv"
    rows, names, stats = [], {}, {}
    k7rate = kn7000_rates()
    for lab, a, n, p, cmt in ic307_items(man):
        body = rom[a:a + n]
        rec = None
        if n >= 64:
            for c, (tg, half) in CHIPS.items():
                y = chips[c].find(body[:64])
                if y >= 0 and y % 2 == 0:
                    sb = 2 * y if half == "Y" else 2 * y + 2
                    i = bisect.bisect_right(k7s[tg], sb) - 1
                    if i >= 0 and k7[tg][i][0] <= sb < k7[tg][i][1]:
                        rec = (k7[tg][i], sb, half)
                    break
        if rec:
            bits, ev = rec[0][3], f"kn7000 {rec[0][2]}"
            if rec[1] != rec[0][0]:
                ev += f" +{(rec[1] - rec[0][0]) // 2} words"
            if rec[2] != "Y":
                ev += " (X chip)"
            m = NAME.match(lab)
            if rec[1] == rec[0][0] and rec[2] == "Y" and rec[0][2] not in names:
                names[rec[0][2]] = (lab, m.group(1) if m else "")
            elif m and rec[1] == rec[0][0] and rec[2] == "Y" and not names[rec[0][2]][1]:
                names[rec[0][2]] = (lab, m.group(1))
        else:
            c = corr(body) if n >= 64 else None
            if c is not None and c > 0.5:
                bits, ev = 8, f"byte correlation {c:+.2f}"
            else:
                bits, ev = 16, "default"
        stats[ev.split()[0]] = stats.get(ev.split()[0], 0) + 1
        heads = [x for x in cmt if x.startswith("wave ")]
        head = re.sub(r"[0-9,]+ (?:16-bit |8-bit )?samples \(([0-9,]+) B\)", r"\1 B", heads[-1]) if heads else ""
        srcs = [x for x in cmt if x.startswith("source")]
        text = f"KN5000 IC307 page {p}, {head}"
        if srcs:
            text += f"; {srcs[0]}"
        text += (f"; {bits}-bit ({ev}); every other word of the recording: IC307 is the Y chip of a "
                 f"word-interleaved pair whose X chip (IC306) is undumped")
        rate, unity = str(RATE), "-"
        if rec and rec[1] == rec[0][0] and rec[2] == "Y" and rec[0][2] in k7rate:
            hz, root = k7rate[rec[0][2]]
            hz /= 2
            rate = str(int(round(hz)))
            unity = f"{root + 12 * math.log2(int(rate) / hz):.4f}"
            text += (f"; {hz:.3f} Hz at root key {root}: half the KN7000 recording's read rate"
                     + (" (8-bit: the item holds sample pairs 4i, 4i+1, so the rate is an average)" if bits == 8 else ""))
        else:
            text += "; 22050 Hz nominal (the pitch exponent is on IC306)"
        rows.append([lab, f"{a:#x}", f"{a + n:#x}", str(bits), rate, f"{lab}.wav", unity, "-", text])
    with open(man, "w", encoding="utf-8") as f:
        f.write("label\tstart\tend\tbits\trate\twav\tunity\tloops\tcomment\n")
        for r in rows:
            f.write("\t".join(r) + "\n")
    nm = ROOT / "kn7000/src/wave/ic307_names.tsv"
    with open(nm, "w", encoding="utf-8") as f:
        f.write("# KN7000 recording\tthe KN5000 IC307 wave holding its even words\tinstrument "
                "(from the IC307 label; written by scripts/generators/gen_ic307_wav_manifest.py)\n")
        for k in sorted(names):
            f.write(f"{k}\t{names[k][0]}\t{names[k][1]}\n")
    print(f"wrote {man.relative_to(ROOT)}: {len(rows)} items, format from " +
          ", ".join(f"{k} {v}" for k, v in sorted(stats.items())) + f"; {nm.relative_to(ROOT)}: {len(names)} names")


if __name__ == "__main__":
    main()
