#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Fabricate SYNTHETIC placeholder wave ROMs for the KN7000 tone generators
# (IC203/IC204 on the master TG, IC207/IC208 on the sub TG). The real 128-Mbit
# mask ROMs are undumped; these stand-ins let the tone-generator emulation and
# the wave-ROM readback path be exercised before real dumps exist.
#
# THESE ARE NOT DUMPS. Every bank embeds an ASCII provenance marker, the files
# are named *_placeholder.bin, and the manifest records "synthetic": true. When
# real dumps arrive, delete these from the ROM set — never present them under the
# bare mask-ROM part numbers.
#
# Design (see kn7000_mame/notes/placeholder-wave-rom-spec.md): the wave space is
# tiled with single-cycle waveforms so the TG produces a clean tone from ANY
# start/loop address (we do not yet know the real waveform descriptors). Bank 0
# is a full-amplitude sine (the service SOUND SYSTEM test's target); later banks
# carry distinct timbres so any captured-but-unmapped address is identifiable.
#
# Each real chip is 128 Mbit = 16 MiB = 8,388,608 16-bit words. A tone generator
# reads a pair of chips (AWAX/AWAY) that together form one 16 M-word master; the
# two chips hold the even / odd words. So we build a 16 M-word master per TG and
# split it by parity into two 16 MiB files.

import argparse
import array
import hashlib
import json
import math
import os
import struct
import sys

WORDS_PER_CHIP = 8 * 1024 * 1024        # 128 Mbit / 16
MASTER_WORDS = WORDS_PER_CHIP * 2       # a TG's two chips interleaved
NBANKS = 16
AMP = 30000                             # "full amplitude" with ~10% headroom


def cycle_sine(n=256):
    return [int(AMP * math.sin(2 * math.pi * i / n)) for i in range(n)]


def cycle_saw(n=256):
    return [int(AMP * (2.0 * i / n - 1.0)) for i in range(n)]


def cycle_triangle(n=256):
    return [int(AMP * (4 * abs(i / n - 0.5) - 1)) for i in range(n)]


def cycle_pulse(n=256, duty=0.5):
    return [AMP if (i / n) < duty else -AMP for i in range(n)]


def cycle_harm(n=256, harms=((1, 1.0), (3, 0.33), (5, 0.2))):
    out = []
    for i in range(n):
        s = sum(w * math.sin(2 * math.pi * h * i / n) for h, w in harms)
        out.append(int(AMP * 0.7 * s))
    return out


def cycle_noise(n=4096, seed=1):
    # deterministic LCG "noise" with an exponential decay envelope (drum-ish)
    v, out = seed & 0xFFFFFFFF, []
    for i in range(n):
        v = (v * 1103515245 + 12345) & 0xFFFFFFFF
        env = math.exp(-4.0 * i / n)
        out.append(int(AMP * env * ((v >> 16) / 32768.0 - 1.0)))
    return out


# One distinct timbre per bank (bank 0 = the diagnostic sine).
BANK_CYCLES = [
    cycle_sine(256),                 # 0  sine (diagnostic target)
    cycle_saw(256),                  # 1  sawtooth
    cycle_triangle(256),             # 2  triangle
    cycle_pulse(256, 0.5),           # 3  square
    cycle_pulse(256, 0.25),          # 4  25% pulse
    cycle_harm(256, ((1, 1), (3, .5))),          # 5  odd-harmonic
    cycle_harm(256, ((1, 1), (2, .5), (3, .3))), # 6  full-harmonic
    cycle_harm(256, ((1, 1), (5, .4))),          # 7
    cycle_sine(128),                 # 8  higher sine
    cycle_sine(512),                 # 9  lower sine
    cycle_saw(128),                  # 10
    cycle_triangle(512),             # 11
    cycle_pulse(256, 0.12),          # 12  narrow pulse
    cycle_harm(256, ((2, 1), (3, .5), (7, .2))), # 13
    cycle_noise(4096),               # 14  one-shot noise burst (drum stand-in)
    cycle_sine(256),                 # 15  quiet sine (see AMP scale below)
]


def tiled_bank(cycle, nwords, quiet=False):
    """Return an array('h') of nwords filled by repeating `cycle`."""
    scale = 0.15 if quiet else 1.0
    pat = array.array('h', [max(-32767, min(32767, int(v * scale))) for v in cycle])
    reps = nwords // len(pat) + 1
    buf = array.array('h')
    for _ in range(reps):
        buf.extend(pat)
    del buf[nwords:]
    return buf


def stamp_ascii(buf, word_off, text):
    """Write an ASCII marker into the int16 buffer at a word offset."""
    b = text.encode('ascii', 'replace')
    if len(b) % 2:
        b += b'\x00'
    words = array.array('h')
    words.frombytes(b)
    for i, w in enumerate(words):
        if word_off + i < len(buf):
            buf[word_off + i] = w


def build_master(tg_label):
    bank_words = MASTER_WORDS // NBANKS
    master = array.array('h')
    for bi in range(NBANKS):
        master.extend(tiled_bank(BANK_CYCLES[bi], bank_words, quiet=(bi == 15)))
    return master


def stamp_provenance(buf, tg_label, ic_label, gitrev):
    """Stamp readable ASCII into a per-chip buffer (after the parity split, so
    the text is intact within each individual file)."""
    bank_words = len(buf) // NBANKS
    stamp_ascii(buf, 0x0400,
                "KN7000 SYNTHETIC PLACEHOLDER WAVE ROM - NOT A HARDWARE DUMP - "
                "TG=%s %s - gen by kn7000_disassembly/tools/"
                "make_placeholder_waveroms.py - rev %s" % (tg_label, ic_label, gitrev))
    for bi in range(NBANKS):
        stamp_ascii(buf, bi * bank_words + 0x40,
                    "SYNTHETIC %s BANK %02d - NOT A DUMP" % (ic_label, bi))


def split_parity(master):
    ev = master[0::2]
    od = master[1::2]
    return ev, od


def main():
    ap = argparse.ArgumentParser(description="Generate SYNTHETIC KN7000 placeholder wave ROMs.")
    ap.add_argument("--out", default=".", help="output directory for the .bin files + manifest.json")
    ap.add_argument("--gitrev", default="unknown", help="a git rev string to embed for provenance")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)

    # Provisional chip <-> parity <-> TG mapping (see the spec; a MAME WAVE ROM
    # test run disambiguates it empirically). master TG = 0x98040000.
    files = {}
    for tg_label, even_ic, odd_ic in [("MASTER", "ic204", "ic203"),
                                      ("SUB", "ic208", "ic207")]:
        master = build_master(tg_label)
        ev, od = split_parity(master)
        for ic, buf in ((even_ic, ev), (odd_ic, od)):
            stamp_provenance(buf, tg_label, ic.upper(), args.gitrev)
            name = "kn7000_wave_%s_placeholder.bin" % ic
            path = os.path.join(args.out, name)
            data = buf.tobytes()
            assert len(data) == WORDS_PER_CHIP * 2, len(data)
            open(path, "wb").write(data)
            files[name] = {
                "ic": ic.upper(),
                "tg": tg_label,
                "parity": "even" if ic in (even_ic,) else "odd",
                "bytes": len(data),
                "sha1": hashlib.sha1(data).hexdigest(),
                "synthetic": True,
            }
            sys.stderr.write("wrote %s (%d bytes, sha1 %s)\n"
                             % (name, len(data), files[name]["sha1"][:12]))

    manifest = {
        "synthetic": True,
        "description": "SYNTHETIC placeholder wave ROMs for the KN7000 tone "
                       "generators — NOT hardware dumps. Delete when real "
                       "IC203/204/207/208 dumps exist.",
        "generator": "kn7000_disassembly/tools/make_placeholder_waveroms.py",
        "gitrev": args.gitrev,
        "chip_size_bytes": WORDS_PER_CHIP * 2,
        "mapping_note": "even/odd<->AWAX/AWAY and IC<->TG-port are PROVISIONAL; "
                        "a MAME WAVE ROM test run disambiguates them.",
        "files": files,
    }
    json.dump(manifest, open(os.path.join(args.out, "manifest.json"), "w"), indent=2)
    sys.stderr.write("wrote manifest.json (%d files)\n" % len(files))
    return 0


if __name__ == "__main__":
    sys.exit(main())
