#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# gen_wave_s.py -- write src/wave/<tg>.s, the source of one tone generator's wave ROM stream.
#
# The stream (tools/wave_pair.py join Y X) is 16 pages of 0x100000 words.  Each page is a directory of
# 8-byte entries, the entries' parameter records, and the recordings (PCM).  This tool reads a stream,
# checks every layout rule the source relies on (and stops if one does not hold), and writes:
#   - every directory entry as `.word` fields with symbolic pointers to its record and its recording;
#   - every record as `.word` parameter words spelled with the constants of src/wave/wave_format.inc;
#   - every recording as one labelled `.incbin_range` of the git-ignored reference stream, declared
#     `census: opaque -- pcm`, with its format, size and the entries that play it;
#   - the erased fill that ends a page as `.space N, 0xff`.
# The committed .s files are the result; the build does not run this.  Format: notes/wave-roms-2026-10-29.md.
#
#   gen_wave_s.py main baserom/kn7000_wave_main.bin src/wave/main.s
#   gen_wave_s.py sub  baserom/kn7000_wave_sub.bin  src/wave/sub.s
import array
import sys

PAGE = 0x100000                     # words
NPAGES = 16
GRAN = ["GRAN_16", "GRAN_32", "GRAN_64", "GRAN_128", "GRAN_256", "GRAN_512", "GRAN_1024", "GRAN_2048"]
WORDS_PER_LINE = 12

TG = {
    "main": dict(prefix="Main", ref="baserom/kn7000_wave_main.bin",
                 title="the MAIN tone generator (0x98050000): IC203 (Y) + IC204 (X)"),
    "sub":  dict(prefix="Sub", ref="baserom/kn7000_wave_sub.bin",
                 title="the SUB tone generator (0x98040000): IC207 (Y) + IC208 (X)"),
}


class LayoutError(Exception):
    pass


def param(v):
    """one record parameter word, spelled with wave_format.inc's constants"""
    fl, code, val = v >> 14, (v >> 8) & 0x3F, v & 0xFF
    parts = []
    if fl:
        parts.append(("", "LOOP_START", "LOOP_END", "REC_END")[fl])
    if code:
        parts.append(f"0x{code:02x}<<8")
    if val >= 0x80:
        parts.append(f"256-{256 - val}")
    elif val or not parts:
        parts.append(str(val))
    return " | ".join(parts)


def pfield(P):
    if P & 0xF000 != 0x1000:
        raise LayoutError(f"P {P:#06x}: bit 12 alone expected in bits 15:12")
    e, f, k = (P >> 4) & 0xFF, P & 8, P & 7
    return f"PFMT | {e}<<4 | " + ("PCM8 | " if f else "") + GRAN[k]


def page_source(s, p, pre, ref):
    base = p * PAGE
    pg = f"{pre}_P{p:02X}"
    n = s[base] // 4
    if n == 0 or s[base] % 4:
        raise LayoutError(f"page {p}: entry 0's A = {s[base]:#x} is not 4 x a count")
    ents = [tuple(s[base + 4 * j: base + 4 * j + 4]) for j in range(n)]
    # recordings: one per distinct B, named after the lowest entry that plays it
    users = {}
    for j, (A, P, B, Q) in enumerate(ents):
        users.setdefault(B, []).append(j)
    starts = sorted(users)
    wname = {B: f"{pg}_W{users[B][0]:03X}" for B in starts}
    # records: in entry order, contiguous, 32-bit aligned, zero padded
    pos = 4 * n
    recs = []
    for j, (A, P, B, Q) in enumerate(ents):
        if A != pos + (pos & 1):
            raise LayoutError(f"page {p} entry {j}: record at word {A:#x}, expected {pos + (pos & 1):#x}")
        if pos & 1 and s[base + pos] != 0:
            raise LayoutError(f"page {p} entry {j}: non-zero record pad")
        if s[base + A] != B:
            raise LayoutError(f"page {p} entry {j}: record word 0 {s[base + A]:#x} != B {B:#x}")
        k = A + 1
        words = []
        while True:
            v = s[base + k]
            words.append(v)
            k += 1
            if v & 0x8000:
                break
        if words[0] != Q:
            raise LayoutError(f"page {p} entry {j}: Q {Q:#x} != the record's first parameter {words[0]:#x}")
        recs.append(words)
        pos = k
    pcm0 = (pos + 15) // 16 * 16
    if any(s[base + pos: base + pcm0]):
        raise LayoutError(f"page {p}: non-zero words between the records and the first recording")
    if starts[0] * 16 != pcm0:
        raise LayoutError(f"page {p}: first recording at word {starts[0] * 16:#x}, records end at {pos:#x}")
    # the erased fill that ends the page: the run of 0xFFFF words at the end, from its first
    # 16-word boundary (a recording's own last samples may be -1 too)
    t = PAGE
    while t > 0 and s[base + t - 1] == 0xFFFF:
        t -= 1
    t = (t + 15) // 16 * 16
    fill = PAGE - t if t <= PAGE - 16 else 0
    if fill and t <= starts[-1] * 16:
        raise LayoutError(f"page {p}: fill reaches into the last recording")
    end = PAGE - fill

    n8 = sum(1 for e in ents if e[1] & 8)
    out = []
    w = out.append
    w("")
    w(f"# ==== page 0x{p:02X} (selects 0x{p:02X}000-0x{p:02X}{n - 1:03X}): {n} entries ({n - n8} 16-bit, {n8} 8-bit), "
      f"{len(starts)} recordings ====")
    w(f"\t.org\t{2 * base:#x}")
    w(f"{pg}:")
    w(f"# directory: A record (words from the page), P format, B first sample (16-word units), Q = record word 1")
    for j, (A, P, B, Q) in enumerate(ents):
        w(f"{pg}_E{j:03X}:\t.word\t({pg}_R{j:03X} - {pg}) / 2, {pfield(P)}, ({wname[B]} - {pg}) / 32, {param(Q)}")
    w(f"# records: B again, then the parameter words")
    for j, words in enumerate(recs):
        fields = [f"({wname[ents[j][2]]} - {pg}) / 32"] + [param(v) for v in words]
        for i in range(0, len(fields), WORDS_PER_LINE):
            lead = f"{pg}_R{j:03X}:" if i == 0 else ""
            w(f"{lead}\t.word\t" + ", ".join(fields[i:i + WORDS_PER_LINE]))
        w("\t.align\t4")
    w("\t.align\t32")
    w(f"# recordings")
    for i, B in enumerate(starts):
        a = B * 16
        b = starts[i + 1] * 16 if i + 1 < len(starts) else end
        fmts = {ents[j][1] & 8 for j in users[B]}
        if len(fmts) != 1:
            raise LayoutError(f"page {p}: recording at {a:#x} is played as 8-bit and as 16-bit")
        nsamp = (b - a) * (2 if fmts.pop() else 1)
        kind = "8-bit" if ents[users[B][0]][1] & 8 else "16-bit"
        who = " ".join(f"{j:03X}" for j in users[B])
        w(f"{wname[B]}:\t.incbin_range \"{ref}\", {2 * (base + a):#x}, {2 * (base + b):#x}"
          f"\t; census: opaque -- pcm: {nsamp} {kind} samples, entr{'y' if len(users[B]) == 1 else 'ies'} {who}")
    if fill:
        w(f"{pg}_Fill:\t.space\t{2 * fill}, 0xff\t; erased fill to the page end")
    return out, dict(n=n, n8=n8, recs=len(starts), recwords=pos - 4 * n, fill=2 * fill)


def main():
    if len(sys.argv) != 4 or sys.argv[1] not in TG:
        sys.exit("usage: gen_wave_s.py main|sub STREAM.bin OUT.s")
    tg = TG[sys.argv[1]]
    s = array.array("H")
    with open(sys.argv[2], "rb") as f:
        s.frombytes(f.read())
    if sys.byteorder != "little":
        s.byteswap()
    if len(s) != NPAGES * PAGE:
        sys.exit(f"{sys.argv[2]}: {2 * len(s):#x} bytes, expected {2 * NPAGES * PAGE:#x}")
    body, stats = [], []
    for p in range(NPAGES):
        lines, st = page_source(s, p, tg["prefix"], tg["ref"])
        body += lines
        stats.append(st)
    head = [
        "# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
        "# Licensed under the terms of the GNU General Public License v3 or later",
        "#",
        f"# KN7000 wave ROM stream of {tg['title']}.",
        "# Generated by tools/gen_wave_s.py from the stream; byte-exact (make verify-wave).",
        "#",
        "# The two chips are one stream of 16-bit words, word i of Y then word i of X; tools/wave_pair.py",
        "# splits the image this file assembles into the two chips.  The stream is 16 pages of 2 MiB (1 MiB",
        "# of each chip).  The firmware names a recording by a 20-bit select: bits 19:12 the page, bits",
        "# 11:0 the directory entry (TgVoiceRouteFieldSet 0x4C037C16 and TgElemNoteOnStd 0x4C030A98 build it",
        "# in the voice's shadow word +0x40), so `<TG>_P0A_E00F` below is select 0x0A00F.  The tone",
        "# generator reads the directory and the records itself; no CPU reads these ROMs except the",
        "# service-mode checksum (notes/wave-rom-port.md).  Fields: src/wave/wave_format.inc.",
        "# Format, evidence and open questions: notes/wave-roms-2026-10-29.md.",
        "#",
        "# The recordings come from the reference stream (git-ignored, made by the Makefile from the",
        "# private romset with SHA-1 checks): one labelled .incbin_range each.",
        "#",
        "# page  entries  8-bit  recordings  record words  fill bytes",
    ]
    for p, st in enumerate(stats):
        head.append(f"# 0x{p:02X}  {st['n']:7d}  {st['n8']:5d}  {st['recs']:10d}  {st['recwords']:12d}  {st['fill']:10d}")
    head += ["", '.include "src/wave/wave_format.inc"']
    with open(sys.argv[3], "w") as f:
        f.write("\n".join(head + body) + "\n")
    print(f"wrote {sys.argv[3]}: {sum(st['n'] for st in stats)} entries, {sum(st['recs'] for st in stats)} recordings")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except LayoutError as e:
        sys.exit(f"gen_wave_s.py: layout rule broken: {e}")
