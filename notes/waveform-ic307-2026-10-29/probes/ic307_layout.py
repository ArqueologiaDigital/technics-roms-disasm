#!/usr/bin/env python3
"""ic307_layout.py -- parse the KN5000 waveform ROM IC307 and re-derive every layout figure the notes quote.

QUESTION IT ANSWERS
  "What exactly is in each 1 MB page of IC307: how long is its directory, where does each parameter record
   start and end, how much zero padding precedes the PCM, which distinct waves are there and how long is
   each, how long is the 0xFF tail, and what shapes do the parameter words take?"

  No CPU reads IC307 (the tone generator IC303 fetches it itself), so nothing here can be checked against
  a firmware reader.  Every number is measured from the bytes; the format's only built-in self-check is that
  each record's head word repeats its directory entry's wave offset (1495 / 1495).

READS
  The reference image: argument 1, else original_ROMs/kn5000_waveform_rom.ic307 (copied by `make` from the
  private romset, git-ignored), else ~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307.

RUN
  python3 notes/waveform-ic307-2026-10-29/probes/ic307_layout.py [ic307]
  Imported by scripts/generators/gen_waveform_ic307_s.py (function parse()).
"""
import collections
import os
import pathlib
import re
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
PAGE = 0x100000
SHA1 = "4b511bff6625f4655cabd96a263bf548d2ef4bf7"


def default_path():
    for c in (ROOT / "original_ROMs" / "kn5000_waveform_rom.ic307",
              pathlib.Path(os.path.expanduser("~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307"))):
        if c.is_file():
            return c
    raise SystemExit("IC307 reference image not found; run `make original_ROMs/kn5000_waveform_rom.ic307`")


def is_split(v, f):
    """A key-split word: flag bits 5..0 clear and a value that is a multiple of 8 up to 0x80."""
    return f & 0x3F == 0 and v % 8 == 0 and v <= 0x80


def parse(data):
    """Return a list of four page dicts:
    n, entries [(param_off, wave_unit)], records [(param_off, end_off, words[(value, flags)])],
    pad (zero bytes between the last record and the first wave), waves [(off, size)] sorted by offset,
    tail (0xFF bytes at the page end)."""
    assert len(data) == 4 * PAGE
    pages = []
    for p in range(4):
        b = p * PAGE
        u16 = lambda o: struct.unpack_from("<H", data, b + o)[0]
        n = u16(0) // 4
        ent = [(u16(4 * i), u16(4 * i + 2)) for i in range(n)]
        pcm = min(w for _, w in ent) * 16
        assert all(ent[i][0] < ent[i + 1][0] for i in range(n - 1)), "param pointers ascend"
        assert ent[0][0] == 4 * n
        recs = []
        for i, (pp, wo) in enumerate(ent):
            end = ent[i + 1][0] if i + 1 < n else pcm
            assert u16(pp) == wo, "record head word = wave offset"
            words = [(data[b + j], data[b + j + 1]) for j in range(pp + 2, end, 2)]
            if i + 1 == n:
                while words and words[-1] == (0, 0):
                    words.pop()
                end = pp + 2 + 2 * len(words)
            recs.append((pp, end, words))
        pad = pcm - recs[-1][1]
        assert data[b + recs[-1][1]:b + pcm] == bytes(pad)
        e = PAGE
        while data[b + e - 1] == 0xFF:
            e -= 1
        tail = PAGE - e
        assert tail % 16 == 0
        ws = sorted({w * 16 for _, w in ent})
        assert ws[0] == pcm
        waves = [(o, (ws[k + 1] if k + 1 < len(ws) else e) - o) for k, o in enumerate(ws)]
        pages.append(dict(n=n, entries=ent, records=recs, pad=pad, waves=waves, tail=tail, pcm=pcm, end=e))
    return pages


def main():
    path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else default_path()
    data = path.read_bytes()
    import hashlib
    h = hashlib.sha1(data).hexdigest()
    print("image %s  SHA-1 %s %s" % (path, h, "(the audited dump)" if h == SHA1 else "(NOT the audited dump)"))
    pages = parse(data)
    tot = collections.Counter()
    for p, pg in enumerate(pages):
        ent = pg["entries"]
        back = [i for i in range(1, pg["n"]) if ent[i][1] < ent[i - 1][1]]
        sizes = [s for _, s in pg["waves"]]
        empty = sum(1 for r in pg["records"] if not r[2])
        print("page %d: N=%d  directory 0x0000-0x%04x  records 0x%04x-0x%04x (%d empty)  zero pad %d B"
              "  PCM 0x%05x-0x%05x  %d distinct waves (%d..%d B)  0xFF tail %d B  wave-offset back-steps at %s"
              % (p, pg["n"], 4 * pg["n"] - 1, ent[0][0], pg["records"][-1][1] - 1, empty, pg["pad"], pg["pcm"],
                 pg["end"] - 1, len(pg["waves"]), min(sizes), max(sizes), pg["tail"], back))
        tot["entries"] += pg["n"]
        tot["waves"] += len(pg["waves"])
    print("chip: %d directory entries, %d distinct waves" % (tot["entries"], tot["waves"]))

    # word shapes
    words = [(p, i, w) for p, pg in enumerate(pages) for i, r in enumerate(pg["records"]) for w in [r[2]]]
    allw = [x for _, _, w in words for x in w]
    print("parameter words: %d in %d non-empty records" % (len(allw), sum(1 for _, _, w in words if w)))
    end_last = sum(1 for _, _, w in words for k, (v, f) in enumerate(w) if f & 0x80 and k == len(w) - 1)
    end_mid = sum(1 for _, _, w in words for k, (v, f) in enumerate(w) if f & 0x80 and k != len(w) - 1)
    mark = sum(1 for v, f in allw if f & 0x40)
    print("  bit 7 (end): %d on a record's last word, %d elsewhere;  bit 6 (marker): %d" % (end_last, end_mid, mark))
    sp = [x for x in allw if is_split(*x)]
    print("  key-split words (bits 5..0 clear, value a multiple of 8 <= 0x80): %d" % len(sp))
    seq = [x for x in allw if not is_split(*x)]
    ab = collections.Counter(((f >> 3) & 7) - (f & 7) for v, f in seq)
    neg = sum(1 for v, f in seq if v >= 0x80)
    print("  sequence words: %d; bits 5..3 minus bits 2..0: %s; value >= 0x80 (negative as s8): %d"
          % (len(seq), dict(sorted(ab.items())), neg))
    print("  fields 5..3 / 2..0 never exceed 5: %s" % all(((f >> 3) & 7) <= 5 and f & 7 <= 5 for v, f in allw))
    shapes = collections.Counter()
    for _, _, w in words:
        s = "".join("K" if is_split(*x) else "S" for x in w)
        shapes[re.sub("S+", "S*", re.sub("K+", "K*", s)) or "(empty)"] += 1
    print("  record shapes (K = key split, S = sequence word): %s" % dict(shapes.most_common()))
    # suffix sharing: a record whose words are the tail of an earlier record of the same page
    suf = []
    for p, pg in enumerate(pages):
        rr = pg["records"]
        for i, r in enumerate(rr):
            w = r[2]
            if len(w) < 3 or all(is_split(*x) for x in w):
                continue
            for j, r2 in enumerate(rr):
                if j != i and len(r2[2]) > len(w) and r2[2][-len(w):] == w:
                    suf.append((p, i, j, len(r2[2]) - len(w), pg["entries"][i][1] - pg["entries"][j][1]))
                    break
    print("  sequence records that repeat the tail of another record of the page: %d" % len(suf))
    for x in suf:
        print("    page %d entry %d = entry %d minus its first %d words; wave starts %+d granules later" % x)


if __name__ == "__main__":
    main()
