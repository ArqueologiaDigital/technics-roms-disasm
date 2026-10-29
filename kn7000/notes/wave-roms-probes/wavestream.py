#!/usr/bin/env python3
"""wavestream.py -- the shared reader for the probes in this folder (library, no output of its own).

A tone generator's two wave ROMs are one stream of 16-bit words: stream word 2i = word i of the Y chip,
2i+1 = word i of the X chip (real_dump_v1.3_b893/wave-analysis/xy.py, kn7000/notes/wave-rom-port.md).
`stream(tg)` builds it from the chip images; `entries(s, page)` and `record(s, page, A)` read the
directory and the parameter records as kn7000/src/wave/*.s describes them.

Chip images: $KN7000_WAVE_DIR, default ~/compartilhado/technics_romsets/kn7000 (private, read-only).
"""
import os
import numpy as np

WAVE_DIR = os.environ.get("KN7000_WAVE_DIR", os.path.expanduser("~/compartilhado/technics_romsets/kn7000"))
CHIPS = {"main": ("c3cbqd000002.ic203", "c3cbqd000001.ic204"),   # MAIN TG 0x98050000: Y, X
         "sub":  ("c3cbqd000004.ic207", "c3cbqd000003.ic208")}   # SUB TG 0x98040000: Y, X
PAGE = 0x100000           # words per page (2 MiB of stream, 1 MiB of each chip)
NPAGES = 16


def stream(tg):
    y = np.fromfile(os.path.join(WAVE_DIR, CHIPS[tg][0]), dtype="<u2")
    x = np.fromfile(os.path.join(WAVE_DIR, CHIPS[tg][1]), dtype="<u2")
    s = np.empty(y.size * 2, dtype="<u2")
    s[0::2] = y
    s[1::2] = x
    return s


def entries(s, page):
    """[(A, P, B, Q)] of the page's directory; entry 0's A is 4 x the entry count"""
    b = page * PAGE
    n = int(s[b]) // 4
    return [tuple(int(v) for v in s[b + 4 * j: b + 4 * j + 4]) for j in range(n)]


def record(s, page, A):
    """the record at word A of the page: [B, param, ...], up to the first word with bit 15 set"""
    b = page * PAGE + A
    out = [int(s[b])]
    k = 1
    while True:
        v = int(s[b + k])
        out.append(v)
        k += 1
        if v & 0x8000:
            return out


def granule(P):
    """K = P bits 2:0: the loop granule L = 2^(K+4) samples"""
    return 1 << ((P & 7) + 4)


def segments(params, L):
    """(loop_start, loop_end, [segment ends]) in samples from the sample start, or None for an absent mark.
    A param word is [flags:2][code:6][value:8]; value >= 0x80 is a segment of (256 - value) granules;
    flag bit 14 marks the loop start at the segment's end, bit 15 the loop end (and the record's end)."""
    pos, ls, le, ends = 0, None, None, []
    for v in params:
        fl, val = v >> 14, v & 0xFF
        if val >= 0x80:
            pos += (256 - val) * L
            ends.append(pos)
            if fl & 1 and ls is None:
                ls = pos
            if fl & 2:
                le = pos
        if fl & 2:
            break
    return ls, le, ends
