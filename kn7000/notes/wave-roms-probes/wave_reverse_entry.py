#!/usr/bin/env python3
"""wave_reverse_entry.py -- QUESTION: what is the odd directory entry Main_P00_E0AF (P = 0x12fa, bit 9 set,
"E = 47"), and what does its P bit 9 mean?  (wave-roms-2026-10-29.md, "The odd entry"; item N-44a0a9c3)

It prints, from the chip images (wavestream.py) and the 'JK' archive source:
  1. which entries set any of P bits 11:9 (bits 8:4 then hold E, 13..19, everywhere);
  2. what the stream holds at E0AF's B: the lag-1 correlation of those words read as 16-bit and as 8-bit
     samples (8-bit is what P bit 3 says), and whether they continue the 16-bit recording that starts at
     entry 0x65 (its LOOP_END + 32 samples must repeat its loop start, and lie past E0AF's B);
  3. the arithmetic that ties E0AF to entry 0x0AE: -B mod 2^16 against the last 16-word unit of the samples
     0x0AE's segments cover, and whether both records lay out the same segments;
  4. the sounds that play them: the parameter records whose zones select each entry (wave_root_rates.py),
     the bank key (MSB, LSB, program) of each (JkParamBankEnt: VoiceParamBankLookupInternal 0x48570DF8),
     and the names of the archive records whose layers use that key (SOUND_MOD +4..+6, VOICE_SUB +1..+3,
     VOICE_ELEM layers).
Signal: E0AF is the only entry with bits 11:9 set; its B words read as 16-bit audio inside entry 0x65's
recording; -B mod 2^16 is exactly 0x0AE's last unit, the segments match, and E0AF's one extra granule (its
REC_END word, wave_record_extent.py) lands on silence just below 0x0AE's first unit; E0AF's sound is
"Reverse Cymbal" and 0x0AE's a ride cymbal.

RUN (from kn7000/, after `make` has made baserom/kn7000_table.rom):
    python3 -I notes/wave-roms-probes/wave_reverse_entry.py
"""
import collections
import os
import re
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
K = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(K, "tools"))
from wavestream import stream, entries, record, granule, segments, NPAGES   # noqa: E402
import wave_root_rates as W                                                       # noqa: E402


def lag1(x):
    x = x.astype(float) - x.mean()
    return float((x[1:] * x[:-1]).sum() / ((x * x).sum() + 1e-9))


def names_by_param():
    """{parameter record index: {names}} from the archive source"""
    L = open(os.path.join(K, "src/table/voices/internal_archive.s"), "rb").read().split(b"\n")
    key2par = {}
    for i, ln in enumerate(L):
        if ln.startswith(b"JkParamBankEnt"):
            k = int(re.search(rb"\.long\s+(0x[0-9a-f]+)", L[i + 2]).group(1), 16)
            m = re.search(rb"\.byte\s+0x([0-9a-f]+), 0x([0-9a-f]+)", L[i + 3])
            key2par[k] = int(m.group(1), 16) | int(m.group(2), 16) << 8
    out, name = collections.defaultdict(set), None
    for ln in L:
        if b".ascii" in ln and b'"' in ln:
            name = ln.split(b'"')[1].decode("latin1").strip()
        m = re.match(rb"\s+(SOUND_MOD|VOICE_SUB|VOICE_ELEM)\t([^#]+)", ln)
        if not m:
            continue
        a = [int(x, 0) for x in m.group(2).decode().split(",")]
        trip = {b"SOUND_MOD": [a[4:7]], b"VOICE_SUB": [a[1:4]],
                b"VOICE_ELEM": [a[5 + 5 * k: 8 + 5 * k] for k in range(6)]}[m.group(1)]
        for pr, lsb, msb in trip:
            k = msb << 16 | lsb << 8 | (pr & 0x7F)
            if k in key2par:
                out[key2par[k]].add(name)
    return out, {v: k for k, v in key2par.items()}


def main():
    s = stream("main")
    ents = entries(s, 0)
    # 1
    for tg in ("main", "sub"):
        st = s if tg == "main" else stream("sub")
        odd = [(p, j, P) for p in range(NPAGES) for j, (A, P, B, Q) in enumerate(entries(st, p)) if P & 0x0E00]
        print(f"{tg}: entries with any of P bits 11:9 set: " + (", ".join(f"page 0x{p:02X} entry 0x{j:03X} P {P:#06x}"
                                                                      for p, j, P in odd) or "none"))
    A, P, B, Q = ents[0x0AF]
    A6, P6, B6, Q6 = ents[0x0AE]
    A5, P5, B5, Q5 = ents[0x065]
    print(f"\nE0AF: P {P:#06x} = PFMT | bit 9 | E {(P >> 4) & 0x1F} (bits 8:4) | PCM8 {bool(P & 8)} | K {P & 7};"
          f" B {B:#06x} (word {B * 16:#x})")
    print(f"E0AE: P {P6:#06x}, B {B6:#06x} (word {B6 * 16:#x}); E065: P {P5:#06x}, B {B5:#06x} (word {B5 * 16:#x})")
    # 2
    starts = sorted({e[2] for e in ents})
    nxt = starts[starts.index(B) + 1] * 16
    w = s[B * 16: nxt]
    print(f"\n2. the {w.size} words from E0AF's B to the next start: lag-1 correlation as 16-bit {lag1(w.view(np.int16)):.3f},"
          f" as 8-bit {lag1(w.view(np.int8)):.3f}")
    ls, le, _ = segments(record(s, 0, A5)[1:], granule(P5))
    d = s[B5 * 16:].view(np.int16)
    print(f"   entry 0x065 (16-bit): loop {ls}..{le} samples = words {B5 * 16 + ls:#x}..{B5 * 16 + le:#x};"
          f" samples [le, le+32) repeat [ls, ls+32): {np.array_equal(d[le:le + 32], d[ls:ls + 32])};"
          f" E0AF's B word {B * 16:#x} lies inside that loop: {B5 * 16 + ls <= B * 16 < B5 * 16 + le}")
    # 3
    r6, r7 = record(s, 0, A6)[1:], record(s, 0, A)[1:]
    L = granule(P6)
    _, _, ends6 = segments(r6, L)
    units = ends6[-1] // 32                     # 8-bit: 32 samples per 16-word unit
    print(f"\n3. E0AE's segments cover {ends6[-1]} 8-bit samples = {units} units of 16 words: units {B6:#06x}..{B6 + units - 1:#06x}")
    print(f"   -B mod 2^16 = {(-B) & 0xFFFF:#06x}; the last of those units = {B6 + units - 1:#06x}:"
          f" {'equal' if (-B) & 0xFFFF == B6 + units - 1 else 'NOT equal'}")
    print(f"   so units -(B + n) mod 2^16, n = 0 .. {units - 1}, are E0AE's units {B6 + units - 1:#06x} down to"
          f" {(-(B + units - 1)) & 0xFFFF:#06x}: E0AE's first unit is {B6:#06x}")
    g7 = sum(1 for v in r7 if v & 0xFF < 0x80)          # E0AF's words after its segments: one granule each
    lo = (-(B + units + g7 * L // 32 - 1)) & 0xFFFF
    print(f"   E0AF's record adds {g7} granule(s) of {L} samples after the segments (its REC_END word): units"
          f" {lo:#06x}..{B6 - 1:#06x}, words {lo * 16:#x}..{B6 * 16 - 1:#x}, all zero: {not s[lo * 16: B6 * 16].any()}")
    print(f"   segment values: E0AE {[v & 0xFF for v in r6]} flags {[v >> 14 for v in r6]};"
          f" E0AF {[v & 0xFF for v in r7]} flags {[v >> 14 for v in r7]}")
    # 4
    nm, par2key = names_by_param()
    R, _ = W.refs(os.path.join(K, "baserom/kn7000_table.rom"),
                  {"Main": os.path.join(K, "baserom/kn7000_wave_main.bin"), "Sub": os.path.join(K, "baserom/kn7000_wave_sub.bin")})
    params = W.params(W.archive(os.path.join(K, "baserom/kn7000_table.rom")))
    print()
    for j in (0x0AE, 0x0AF):
        sel = [(pr["i"], zi) for pr in params for zi, z in enumerate(pr["zones"])
               if W.side_tg(z["fb"]) == "Main" and z["page"] == 0 and z["ent"] == j]
        for i, zi in sel:
            k = par2key.get(i)
            ks = f"MSB {k >> 16:#04x} LSB {(k >> 8) & 0xFF:#04x} program {k & 0xFF}" if k is not None else "no bank key"
            print(f"4. Main_P00_E{j:03X}: parameter record {i} zone {zi} ({ks}); sounds: {sorted(nm.get(i, []))}")


if __name__ == "__main__":
    main()
