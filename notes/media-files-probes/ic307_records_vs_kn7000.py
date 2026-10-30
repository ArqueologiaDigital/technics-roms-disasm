#!/usr/bin/env python3
"""ic307_records_vs_kn7000.py -- are IC307's parameter records the Y-chip half of KN7000-style records?

QUESTION IT ANSWERS
  "If IC307 is the Y chip of a word-interleaved pair (ic307_kn7000_match.py), its directory entry is the
   even words {A, B} of a KN7000-style entry {A, P, B, Q}, and its record is the even words of a KN7000
   record [B, p0, p1, p2, ...] -- that is [B, p1, p3, p5, ...].  Do IC307's records equal those words of
   the KN7000 records that play the same recording?"
  If they do, the "sequence words" of notes/waveform-ic307-2026-10-29 are KN7000 segment words seen from
  one chip, and the loop marks and format flag of every IC307 entry are on the undumped X chip.

METHOD
  For every IC307 directory entry whose wave occurs at the first sample of a KN7000 recording (found as
  in ic307_kn7000_match.py), every KN7000 entry that plays that recording is a candidate partner.  The
  IC307 record's words after its head (up to the next record) are compared with the candidate's
  parameter words p1, p3, p5, ... (and, as a control, with p0, p2, p4, ...).  The IC307 record of the
  page's last entry runs to its last non-zero word (as the source does).

INPUTS (private, read-only; nothing is written): as pcm_encoding_probe.py.

RUN
  python3 notes/media-files-probes/ic307_records_vs_kn7000.py         (about 10 s)
"""
import os
import struct
from collections import Counter
from pathlib import Path

H = Path.home() / "compartilhado"
WAVE_DIR = Path(os.environ.get("KN7000_WAVE_DIR", H / "technics_romsets/kn7000"))
IC307 = Path(os.environ.get("KN5000_IC307", H / "technics_romsets/kn5000/kn5000_waveform_rom.ic307"))
PAIRS = {"main": ("c3cbqd000002.ic203", "c3cbqd000001.ic204"), "sub": ("c3cbqd000004.ic207", "c3cbqd000003.ic208")}
PAGE7 = 0x100000          # KN7000 page, in stream words
PAGE5 = 0x100000          # IC307 page, in bytes


def words(b):
    return struct.unpack(f"<{len(b) // 2}H", b)


def kn7000(tg):
    y, x = (words((WAVE_DIR / c).read_bytes()) for c in PAIRS[tg])
    s = [0] * (2 * len(y))
    s[0::2], s[1::2] = y, x
    rec_of = {}                    # (page, B) -> [param lists of the entries that play it]
    for p in range(16):
        b = p * PAGE7
        n = s[b] // 4
        for j in range(n):
            A, P, B, Q = s[b + 4 * j:b + 4 * j + 4]
            k, params = b + A + 1, []
            while True:
                params.append(s[k])
                k += 1
                if s[k - 1] & 0x8000:
                    break
            rec_of.setdefault((p, B), []).append(params)
    return y, rec_of


def ic307_entries(rom):
    for p in range(4):
        base = p * PAGE5
        n = struct.unpack_from("<H", rom, base)[0] // 4
        dirs = [struct.unpack_from("<HH", rom, base + 4 * i) for i in range(n)]
        for i, (r, w) in enumerate(dirs):
            end = dirs[i + 1][0] if i + 1 < n else None
            if end is None:
                end = r + 2
                while struct.unpack_from("<H", rom, base + end)[0] != 0:
                    end += 2
                # the last record of a page runs to its last non-zero word
            rec = words(rom[base + r:base + end])
            yield p, i, w, rec


def main():
    rom = IC307.read_bytes()
    ks = {tg: kn7000(tg) for tg in PAIRS}
    stats = Counter()
    for p, i, w, rec in ic307_entries(rom):
        body = rom[p * PAGE5 + 16 * w:p * PAGE5 + 16 * w + 64]
        stats["entries"] += 1
        found = None
        for tg, (ychip, rec_of) in ks.items():
            data = YBYTES[tg]
            yo = data.find(body)
            if yo >= 0 and yo % 2 == 0:
                sw = yo                    # stream word index = 2 * (yo / 2)
                page, off = divmod(sw, PAGE7)
                if off % 16 == 0 and (page, off // 16) in rec_of:
                    found = rec_of[(page, off // 16)]
                break
        if not found:
            stats["wave not at a KN7000 recording start"] += 1
            continue
        stats["paired"] += 1
        mine = list(rec[1:])
        while mine and mine[-1] == 0:
            mine.pop()
        odd = any(list(q[1::2])[:len(mine)] == mine for q in found)
        even = any(list(q[0::2])[:len(mine)] == mine for q in found)
        if not mine:
            stats["IC307 record has no words after its head"] += 1
            stats["  ... and a KN7000 partner has at most one parameter word"] += any(len(q) <= 1 for q in found)
        elif odd:
            stats["IC307 words == the partner's p1, p3, p5, ..."] += 1
        elif even:
            stats["IC307 words == the partner's p0, p2, p4, ... (control)"] += 1
        else:
            stats["no partner matches"] += 1
    for k, v in stats.items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    YBYTES = {tg: (WAVE_DIR / PAIRS[tg][0]).read_bytes() for tg in PAIRS}
    main()
