#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""wave_root_rates.py -- each KN7000 wave recording's real playback rate at a root key.

QUESTION ANSWERED: at what sample rate does the tone generator read a recording when the keyboard plays
its root key, and which key is that?  Neither wave ROM stores a rate; the firmware never sends one.  The
rate follows from three things, all read here from the reference images:

  1. the TG's pitch law (kn7000_mame notes/g13-waves-2026-10-20, an INFERENCE fitted in emulation: with
     it 478 of 556 traced voices sound at the firmware's own note):
         source samples per second = 2093.0045 * 2^((pitch18 - 0x1E200) / 0x3000 + E - 9)
     where E is the directory entry's pitch exponent (P bits 11:4) and pitch18 = (pitch16 + 0x1800) << 2
     is what the firmware writes to the pitch register (lib 0x4C02D5B1, TgPitchNoteOnEmit's packing).
     The output clock cancels out: the law is fitted against absolute pitch, not against a step size.
  2. the firmware's pitch16 for a key (program 941's library, kn7000/src/program/library_01.s):
         TgPitchInitCalc 0x4C030FB4   pitch16 = ((note16 - (centre << 8 | 0x80)) >> exp) + 0x4280,
                                      note16 = note << 8 | 0x80 (+ part transpose, master tune),
                                      centre = param record +0x0B (66 in 851 of 864; param+8 bit 1
                                      set: 66), then folded by octaves into [param+9, param+0x0A]
         TgPitchNoteResolve 0x4C02FB79  + the zone's s16 correction at +6 when param+8 bit 7 is set
     With exp = 0 (key follow), no tone coarse tune and no transpose, key P of a centre-66 record gives
     pitch16 = P << 8 | 0x80 + corr, and the law reduces to
         rate(P) = f(P) * 2^(E - 9 + corr / 3072),   f(P) = 440 * 2^((P - 69) / 12)
     i.e. a waveform period of 2^(E - 9 + corr/3072) samples sounds at the key's equal-tempered pitch.
  3. the tone database's key mapping: which keys select which recording.  TgVoiceRoutePtrCalc 0x4C02BE45:
     group = keymap[pitch16 >> 8], zone = zones + header[4 + group] * (8 or 6); select = zone page << 12
     | entry; TgVoiceSideSelect 0x4C02BECB: zone halfword +0 & 0x0C00 = 0x400 / 0x800, which is the MAIN /
     SUB tone generator (measured here: of the zones whose entry exists on one TG only, 242 of 242 with
     0x400 name a MAIN entry and 416 of 416 with 0x800 a SUB one; notes/sound-probes/).

THE ROOT KEY of a recording is the lower median of the keys (pitch notes in the record's fold window)
whose zone selects it, over every parameter record that does, taking the (E, corr) that most keys use
(2,632 of the 2,662 recordings reached this way have one; the others differ by a cent or by a deliberate
transposition).  A recording no parameter record's zone selects (drum-kit zones, unused entries) gets
corr = 0 and the root 66, the key at which pitch16 = 0x4280, "the zone at its native rate"; its rate is
then E's alone, and the basis column says so.  A single-cycle wave read at f(key) x its length can exceed
192 kHz at that key; its root is then moved down by whole octaves (the rate halves with each) until the
rate is at most 192 kHz, which the law makes an exactly equivalent (root, rate) pair, and the basis says so.

OUTPUT  kn7000/src/wave/root_rates.tsv (committed; no sample data), one row per recording:
  label  E  corr (the zone's correction, plus (66 - centre) x 256 for the 13 records whose centre is not
  66, so that rate(n) = f(n) * 2^(E - 9 + corr/3072) holds for MIDI key n)  root  rate_hz (exact)  rate (the WAV header's, rounded)  unity (smpl unity note: root
  plus the rounding, 12 log2(rate / rate_hz))  keys (how many keys select it)  basis
gen_wave_s.py writes `rate` and `unity` into the WAV manifests; ../scripts/generators/gen_ic307_wav_manifest.py
gives a KN5000 IC307 half recording half its KN7000 counterpart's rate.

    python3 tools/wave_root_rates.py [--table baserom/kn7000_table.rom] [--out src/wave/root_rates.tsv]
"""
import argparse
import array
import collections
import math
import struct
from pathlib import Path

HERE = Path(__file__).resolve().parents[1]          # kn7000/
PAGE = 0x100000                                     # words
C7_HZ = 2093.0045                                   # 440 * 2^(27/12); pitch18 0x1E200 = note 96
MAX_RATE = 192000                                   # the highest header rate common players accept


def u32(c, o):
    return struct.unpack_from("<I", c, o)[0]


def u16(c, o):
    return struct.unpack_from("<H", c, o)[0]


def archive(table):
    """table segment 6, the 'JK' internal voice archive (tools/gen_table_voices.py types it as source)"""
    d = Path(table).read_bytes()
    first = u32(d, 0)
    ents = [first]
    for i in range(1, first // 4):
        v = u32(d, 4 * i)
        if v <= ents[-1] or v > len(d):
            break
        ents.append(v)
    c = d[ents[6]:ents[7]]
    if c[:2] != b"JK":
        raise SystemExit(f"{table}: segment 6 is not the 'JK' voice archive")
    return c


def params(c):
    """the 864 parameter records (descriptor +0x1C), each with its key map, group -> zone bytes and zones"""
    T = u32(c, 0x14)
    pr = u32(c, T + 0x28)
    out = []
    for i in range((u32(c, T + 0x3C) - pr) // 16):
        r = pr + 16 * i
        a, b, fl = u32(c, r), u32(c, r + 4), c[r + 8]
        km = u32(c, a)
        keymap = list(c[km:km + 128])
        g2z = list(c[a + 4:a + 4 + max(keymap) + 1])
        zs = 8 if fl & 0x80 else 6
        zones = []
        for k in range(max(g2z) + 1):
            z = b + zs * k
            zones.append(dict(page=c[z], fb=c[z + 1], ent=u16(c, z + 2) & 0xFFF,
                              corr=struct.unpack_from("<h", c, z + 6)[0] if zs == 8 else 0))
        out.append(dict(i=i, fl=fl, lo=c[r + 9], hi=c[r + 10], centre=c[r + 11], keymap=keymap, g2z=g2z,
                        zones=zones))
    return out


def zone_keys(p):
    """{zone index: [pitch notes]}: the pitch16 high bytes inside the fold window that select each zone"""
    out = {}
    for P in range(p["lo"], min(p["hi"], 127) + 1):
        out.setdefault(p["g2z"][p["keymap"][P]], []).append(P)
    return out


def stream_dir(path, prefix):
    """{(page, entry): (recording label, P word)}; labels as gen_wave_s.py names them"""
    s = array.array("H")
    s.frombytes(Path(path).read_bytes())
    out = {}
    for p in range(16):
        base = p * PAGE
        n = s[base] // 4
        ents = [tuple(s[base + 4 * j: base + 4 * j + 4]) for j in range(n)]
        first = {}
        for j, (A, P, B, Q) in enumerate(ents):
            if not P & 0x0200:
                first.setdefault(B, j)
        starts = sorted(first)
        for j, (A, P, B, Q) in enumerate(ents):
            if P & 0x0200:          # PREV: plays the recording holding unit -B backwards (wave_reverse_entry.py)
                B = max(x for x in starts if x <= -B & 0xFFFF)
            out[(p, j)] = (f"{prefix}_P{p:02X}_W{first[B]:03X}", P)
    return out


def side_tg(fb):
    return "Main" if fb & 0x0C == 0x04 else "Sub"


def rate_at(P, E, corr):
    return 440.0 * 2 ** ((P - 69) / 12 + E - 9 + corr / 3072)


def refs(table, streams):
    """{recording label: [(param, zone, E, corr, keys)]} and {label: set of E} for every recording"""
    c = archive(table)
    D = {tg: stream_dir(streams[tg], tg) for tg in ("Main", "Sub")}
    Es = collections.defaultdict(set)
    for d in D.values():
        for lab, P in d.values():
            Es[lab].add((P >> 4) & 0x1F)
    out = collections.defaultdict(list)
    for p in params(c):
        zk = zone_keys(p)
        for zi, z in enumerate(p["zones"]):
            lab, P = D[side_tg(z["fb"])][(z["page"], z["ent"])]
            keys, corr = zk.get(zi, []), z["corr"]
            if p["centre"] != 66 and not p["fl"] & 0x02:
                # MIDI key n reaches pitch note n - centre + 66: fold the shift into the correction
                sh = p["centre"] - 66
                keys = [k + sh for k in keys if 0 <= k + sh < 128]
                corr -= 256 * sh
            out[lab].append((p["i"], zi, (P >> 4) & 0x1F, corr, keys))
    return out, Es


def root_rates(table, streams):
    R, Es = refs(table, streams)
    rows = []
    for lab in sorted(Es):
        E_all = Es[lab]
        if len(E_all) != 1 or not 8 <= min(E_all) <= 24:
            rows.append([lab, ",".join(map(str, sorted(E_all))), "-", "-", "-", "-", "-", "0",
                         "no rate: its P word does not read as one pitch exponent"])
            continue
        E = min(E_all)
        rs = R.get(lab, [])
        if rs:
            w = collections.Counter()
            for _, _, e, corr, keys in rs:
                w[(e, corr)] += max(len(keys), 1) if e == E else 0
            (e, corr), _ = w.most_common(1)[0]
            keys = sorted({k for _, _, e2, c2, ks in rs if (e2, c2) == (e, corr) for k in ks})
            root = keys[(len(keys) - 1) // 2] if keys else 66
            others = sorted({c2 for _, _, _, c2, _ in rs} - {corr})
            basis = (f"{len(rs)} zone(s) of {len({r[0] for r in rs})} parameter record(s)"
                     + (f"; other corrections {', '.join(map(str, others))}" if others else ""))
        else:
            corr, root, keys, basis = 0, 66, [], "no parameter record selects it: corr taken as 0, root 66"
        hz = rate_at(root, E, corr)
        down = 0
        while hz > MAX_RATE and root >= 12:     # single-cycle waves: keep the header rate playable
            root, hz, down = root - 12, hz / 2, down + 1
        if down:
            basis += f"; root {down} octave(s) below the median key, so that the rate stays at most {MAX_RATE} Hz"
        rate = int(round(hz))
        unity = root + 12 * math.log2(rate / hz)
        rows.append([lab, str(E), str(corr), str(root), f"{hz:.3f}", str(rate), f"{unity:.4f}", str(len(keys)),
                     basis])
    return rows


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--table", default=str(HERE / "baserom/kn7000_table.rom"))
    ap.add_argument("--main", default=str(HERE / "baserom/kn7000_wave_main.bin"))
    ap.add_argument("--sub", default=str(HERE / "baserom/kn7000_wave_sub.bin"))
    ap.add_argument("--out", default=str(HERE / "src/wave/root_rates.tsv"))
    o = ap.parse_args()
    rows = root_rates(o.table, {"Main": o.main, "Sub": o.sub})
    with open(o.out, "w", encoding="utf-8") as f:
        f.write("# Written by tools/wave_root_rates.py from the table flash (segment 6) and the two wave streams;\n"
                "# rate_hz = 440 * 2^((root - 69)/12 + E - 9 + corr/3072), the TG's read rate at the root key.\n"
                "label\tE\tcorr\troot\trate_hz\trate\tunity\tkeys\tbasis\n")
        for r in rows:
            f.write("\t".join(r) + "\n")
    n = collections.Counter("zone" if "zone(s)" in r[8] else "E only" if "corr taken" in r[8] else "none"
                            for r in rows)
    print(f"wrote {o.out}: {len(rows)} recordings; from zones {n['zone']}, E only {n['E only']}, no rate {n['none']}")


if __name__ == "__main__":
    main()
