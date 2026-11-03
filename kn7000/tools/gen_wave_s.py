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
#   - every recording as a labelled `.incbin` of its raw item build/wav_pcm/<tg>/<label>.pcm, which
#     ../scripts/build/pcm_wav.py makes from the recording's WAV file wav/<tg>/<name>.wav (committed
#     since 2026-10-31; `make wave-wav` re-extracts a missing one from the reference stream), with its
#     format, size and the entries that play it.  ONE WAV PER RECORDING, ending where the record grammar
#     says the recording ends (notes/wave-roms-probes/wave_record_extent.py; the owner's decision of
#     2026-11-03): an ALTERNATE START (a directory start inside an earlier recording) is a slice of that
#     recording's item under its own label, and a cue point in its WAV (the manifest's `cues` column);
#     an explicit loop's 32-sample run-out is its own line, `<recording>_RunOut`, read from the loop's
#     first 32 samples (the 9 that are not a copy: their first half from the loop, their second half from
#     an earlier recording's loop start, wave_runout_halves.py), and zero words after the recording are
#     `.space`.  Neither is in the WAV;
#   - a reversed entry (P bit 9, PREV; notes/wave-roms-probes/wave_reverse_entry.py) has no recording of
#     its own: its B is spelled as the negated unit address of the recording it plays backwards;
#   - the erased fill that ends a page as `.space N, 0xff`;
#   - beside the source, src/wave/<tg>_wav.tsv: the WAV manifest pcm_wav.py reads, one row per recording
#     (where it is in the stream, its bit depth, the WAV's name, sample rate, loops, unity note and the
#     alternate starts' cue points; no sample data).
# The committed .s files are the result; the build does not run this.  Format: notes/wave-roms-2026-10-29.md;
# the WAV files: notes/media-files-2026-10-30/README.md.
#
#   gen_wave_s.py main baserom/kn7000_wave_main.bin src/wave/main.s
#   gen_wave_s.py sub  baserom/kn7000_wave_sub.bin  src/wave/sub.s
#
# src/wave/root_rates.tsv, when present, gives each recording's header rate and unity note
# (tools/wave_root_rates.py writes it).
# src/wave/ic307_names.tsv, when present, names recordings after the KN5000 IC307 wave that holds the
# same audio (written by ../scripts/generators/gen_ic307_wav_manifest.py); the name goes into the WAV's
# file name and comment only, not into the source labels.
import array
import math
import os
import sys

PAGE = 0x100000                     # words
NPAGES = 16
GRAN = ["GRAN_16", "GRAN_32", "GRAN_64", "GRAN_128", "GRAN_256", "GRAN_512", "GRAN_1024", "GRAN_2048"]
WORDS_PER_LINE = 12
PREV = 0x0200                       # directory word P bit 9: the entry plays a recording backwards
RUNOUT = 32                         # samples after an explicit loop's end that repeat its start (loop_probe.py)

TG = {
    "main": dict(prefix="Main", ref="baserom/kn7000_wave_main.bin", tg="main", tgname="MAIN",
                 title="the MAIN tone generator (0x98050000): IC203 (Y) + IC204 (X)"),
    "sub":  dict(prefix="Sub", ref="baserom/kn7000_wave_sub.bin", tg="sub", tgname="SUB",
                 title="the SUB tone generator (0x98040000): IC207 (Y) + IC208 (X)"),
}
# the WAV header's sample rate and smpl unity note: the tone generator's read rate at the recording's
# root key, from src/wave/root_rates.tsv (tools/wave_root_rates.py: the pitch law, the entry's pitch
# exponent E and the tone database's key mapping; notes/sound-2026-10-31/README.md).  Without that file,
# the nominal rate below and the note at which the pitch law reads one source sample per output sample.
WAV_RATE = 44100
C7_HZ = 2093.0045                   # pitch18 0x1E200 = note 96 (kn7000_mame notes/g13-waves-2026-10-20)


def unity_note(E):
    """the MIDI note at which the TG plays a recording at one source sample per output sample.
    The TG's pitch law (kn7000_mame g13, fitted in emulation: 478 of 556 traced voices) is
    rate = 2^((pitch18 - 0x1E200) / 0x3000 + E - 9) * C7 / 44100; rate = 1 at this note."""
    return 96 + 12 * (math.log2(WAV_RATE / C7_HZ) - (E - 9))


def load_rates(path):
    """{label: (rate, unity, root, rate_hz, basis)} from root_rates.tsv, or {} without it"""
    out = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                if line.startswith("#") or line.startswith("label\t"):
                    continue
                r = line.rstrip("\n").split("\t")
                if r[5] != "-":
                    out[r[0]] = (r[5], r[6], r[3], r[4], r[8])
    return out


def loop_of(words, P):
    """(start, end) of the record's explicit loop, in samples from the recording's start, or None:
    segments of (256 - value) granules of 2^(K+4) samples; LOOP_START / LOOP_END at a segment's end.
    A LOOP_END with no LOOP_START before it loops from the first sample (wave_record_extent.py: the
    run-out repeats the recording's first 32 samples in 20 of 20; since 2026-11-03 the WAV's smpl
    chunk carries that loop too)"""
    L = 1 << ((P & 7) + 4)
    pos, ls, le = 0, None, None
    for v in words:
        fl, val = v >> 14, v & 0xFF
        if val >= 0x80:
            pos += (256 - val) * L
            if fl & 1 and ls is None:
                ls = pos
            if fl & 2:
                le = pos
                if fl == 2 and ls is None:
                    ls = 0
        if fl & 2:
            break
    return (ls, le) if ls is not None and le is not None and le > ls else None


def extent_of(words, P):
    """(samples from the first sample to the recording's end, (loop start, loop end) or None).  Every
    record word is a run of granules: value >= 0x80 is (256 - value) granules, a value below 0x80 (the
    split list, the REC_END word's 0) one granule (notes/wave-roms-probes/wave_record_extent.py).  With
    LOOP_END the recording ends RUNOUT samples after the loop end; without, after its last granule.  A
    LOOP_END with no LOOP_START before it loops from the first sample (wave_record_extent.py)."""
    L = 1 << ((P & 7) + 4)
    pos, ls = 0, None
    for v in words:
        fl, val = v >> 14, v & 0xFF
        pos += (256 - val) * L if val >= 0x80 else L
        if val >= 0x80 and fl & 1 and ls is None:
            ls = pos
        if fl == 2 and val >= 0x80:     # no LOOP_START: the loop starts at the first sample (20 of 20 run-outs)
            return pos + RUNOUT, (ls if ls is not None else 0, pos)
        if fl & 2:
            break
    return pos, None


def load_names(path):
    names = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                if line.startswith("#") or not line.strip():
                    continue
                k7, k5, nm = (line.rstrip("\n").split("\t") + ["", ""])[:3]
                names[k7] = (k5, nm)
    return names


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
    if P & 0x0C00:
        raise LayoutError(f"P {P:#06x}: bits 11:10 expected clear (E is bits 8:4, bit 9 is PREV)")
    e, f, k = (P >> 4) & 0x1F, P & 8, P & 7
    return "PFMT | " + ("PREV | " if P & PREV else "") + f"{e}<<4 | " + ("PCM8 | " if f else "") + GRAN[k]


def page_source(s, p, pre, ref, tg, names, rates):
    base = p * PAGE
    pg = f"{pre}_P{p:02X}"
    n = s[base] // 4
    if n == 0 or s[base] % 4:
        raise LayoutError(f"page {p}: entry 0's A = {s[base]:#x} is not 4 x a count")
    ents = [tuple(s[base + 4 * j: base + 4 * j + 4]) for j in range(n)]
    # recordings: one per distinct B, named after the lowest entry that plays it
    users = {}
    rev = set()
    for j, (A, P, B, Q) in enumerate(ents):
        if P & PREV:
            rev.add(j)
        else:
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

    # where each recording ends (notes/wave-roms-probes/wave_record_extent.py): per start, the furthest
    # extent of its entries and the explicit loop behind it, in words from the page; a start inside an
    # earlier recording's extent is an ALTERNATE START into it (its entries play on to that recording's end)
    reach = {}
    for B in starts:
        best = None
        for j in users[B]:
            P = ents[j][1]
            m = 2 if P & 8 else 1
            ns, lp = extent_of(recs[j], P)
            e = B * 16 + (ns + m - 1) // m
            lw = (B * 16 + lp[0] // m if lp[0] is not None else None, B * 16 + lp[1] // m, m) if lp else None
            if best is None or e > best[0] or (e == best[0] and lw and not best[1]):
                best = (e, lw)
        reach[B] = best
    home, cur = {}, None
    for B in starts:
        if cur is not None and B * 16 < reach[cur][0]:
            if reach[B][0] != reach[cur][0]:
                raise LayoutError(f"page {p}: alternate start {B * 16:#x} ends at {reach[B][0]:#x}, "
                                  f"its recording at {reach[cur][0]:#x}")
            if reach[cur][1] is None:
                reach[cur] = reach[B]
            home[B] = cur
        else:
            cur = home[B] = B
    if reach[starts[-1]][0] > end or reach[home[starts[-1]]][0] > end:
        raise LayoutError(f"page {p}: the last recording runs into the 0xFFFF fill")
    # a reversed entry (P bit 9) reads 16-word units -(B + n) mod 2^16, n = 0, 1, ...: B is the negated unit
    # of the last unit it plays, inside another entry's recording (wave_reverse_entry.py)
    bexpr, backwards = {}, {}
    for j, (A, P, B, Q) in enumerate(ents):
        if j not in rev:
            bexpr[j] = f"({wname[B]} - {pg}) / 32"
            continue
        u = -B & 0xFFFF
        t = max((x for x in starts if x <= u), default=None)
        if t is None:
            raise LayoutError(f"page {p} entry {j}: reversed, unit {u:#x} is before every recording")
        bexpr[j] = f"0x10000 - (({wname[t]} - {pg}) / 32 + {u - t})"
        backwards.setdefault(t, []).append(j)

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
        w(f"{pg}_E{j:03X}:\t.word\t({pg}_R{j:03X} - {pg}) / 2, {pfield(P)}, {bexpr[j]}, {param(Q)}"
          + (f"\t; PREV: plays {wname[max(x for x in starts if x <= -B & 0xFFFF)]} backwards, from its last unit"
             if j in rev else ""))
    w(f"# records: B again, then the parameter words")
    for j, words in enumerate(recs):
        fields = [bexpr[j]] + [param(v) for v in words]
        for i in range(0, len(fields), WORDS_PER_LINE):
            lead = f"{pg}_R{j:03X}:" if i == 0 else ""
            w(f"{lead}\t.word\t" + ", ".join(fields[i:i + WORDS_PER_LINE]))
        w("\t.align\t4")
    w("\t.align\t32")
    w(f"# recordings: one WAV file each, wav/{tg['tg']}/ (make wave-wav), through ../scripts/build/pcm_wav.py;")
    w(f"# an alternate start is a slice of its recording's raw item and a cue point in its WAV")
    rows = []
    recs_h = [B for B in starts if home[B] == B]
    m_of, body_of, lab_of = {}, {}, {}
    for B in recs_h:                            # format and WAV extent of every recording, for the run-out search
        grp = [x for x in starts if home[x] == B]
        fmts = {ents[j][1] & 8 for x in grp for j in users[x]}
        if len(fmts) != 1:
            raise LayoutError(f"page {p}: recording at {B * 16:#x} is played as 8-bit and as 16-bit")
        m_of[B] = 2 if fmts.pop() else 1
        R, lw = reach[B]
        body_of[B] = lw[1] if lw else R
    for hi, H in enumerate(recs_h):
        grp = [x for x in starts if home[x] == H]
        a = H * 16
        b = recs_h[hi + 1] * 16 if hi + 1 < len(recs_h) else end
        m = m_of[H]
        kind = "16-bit" if m == 1 else "8-bit"
        R, lw = reach[H]
        body = body_of[H]
        if R > b:
            raise LayoutError(f"page {p}: recording {a:#x} ends at {R:#x}, past the next one at {b:#x}")
        if R <= a:
            raise LayoutError(f"page {p}: recording {a:#x} has no extent")
        nsamp = (body - a) * m
        lab = wname[H]
        k5, nm = names.get(lab, ("", ""))
        wav = f"{lab}_{nm}.wav" if nm else f"{lab}.wav"
        pcm = f"build/wav_pcm/{tg['tg']}/{lab}.pcm"
        src_note = f"../scripts/build/pcm_wav.py, from wav/{tg['tg']}/{wav}"
        cues = []
        for k, B in enumerate(grp):
            p0 = B * 16
            p1 = grp[k + 1] * 16 if k + 1 < len(grp) else body
            if p1 <= p0:
                raise LayoutError(f"page {p}: alternate start {p0:#x} lies past its recording's samples ({body:#x})")
            who = " ".join(f"{j:03X}" for j in users[B])
            ent = f"entr{'y' if len(users[B]) == 1 else 'ies'} {who}"
            if B == H:
                why = f"census: generated -- {src_note}: {nsamp} {kind} samples, {ent}"
                if len(grp) > 1:
                    why += f"; this line is samples 0-{(p1 - a) * m - 1}, up to the alternate start {wname[grp[1]]}"
            else:
                cpos = (p0 - a) * m
                why = (f"census: generated -- {src_note}: samples {cpos}-{(p1 - a) * m - 1} of {lab}'s recording, {ent}: "
                       f"an alternate start into it (cue point {wname[B]} in the WAV), which plays on to its end")
                Es = sorted({(ents[j][1] >> 4) & 0x1F for j in users[B]})
                text = (f"{ent} (select 0x{p:02X}{users[B][0]:03X}), pitch exponent E {', '.join(map(str, Es))}: "
                        f"an alternate start {cpos} samples into the recording; it plays on to the recording's end")
                if wname[B] in rates:
                    rr = rates[wname[B]]
                    text += (f"; on its own {rr[3]} Hz at root key {rr[2]} (TG read rate; "
                             f"{'from the tone database' if 'zone(s)' in rr[4] else 'pitch exponent only'})")
                if wname[B] in names:
                    text += f"; the same audio as KN5000 IC307 {names[wname[B]][0]} (which holds every other word)"
                cues.append((cpos, wname[B], text))
            for j in backwards.get(B, []):
                why += f"; entry {j:03X} plays it backwards (PREV)"
            w(f"{wname[B]}:\t.incbin\t\"{pcm}\", {2 * (p0 - a)}, {2 * (p1 - p0)}\t; {why}")
        if lw:                                  # an explicit loop: its run-out on a line of its own
            ls, le, _m = lw
            r = RUNOUT // m
            h = r // 2
            if le + r != R or le != body:
                raise LayoutError(f"page {p}: loop end {le:#x} + run-out != recording end {R:#x}")
            if not a <= ls < le:
                raise LayoutError(f"page {p}: loop start {ls:#x} outside its recording {a:#x}..{le:#x}")
            if ls + r > le:
                raise LayoutError(f"page {p}: loop {ls:#x}..{le:#x} is shorter than its run-out")
            ro = list(s[base + le: base + le + r])
            if list(s[base + ls: base + ls + r]) == ro:
                w(f"{lab}_RunOut:\t.incbin\t\"{pcm}\", {2 * (ls - a)}, {2 * r}"
                  f"\t; census: generated -- {src_note}: the run-out, the loop's first {RUNOUT} samples again "
                  f"(from sample {(ls - a) * m}; loop_probe.py)")
            else:
                # loop_probe.py: 9 run-outs are not a copy.  Their first half is the loop's first half; their
                # second half is the second half of an EARLIER recording's loop start, the same in every
                # recording of a run (notes/wave-roms-probes/wave_runout_halves.py)
                donor = None
                if list(s[base + ls: base + ls + h]) == ro[:h]:
                    for D in reversed(recs_h[:hi]):
                        ld = reach[D][1]
                        if (ld and ld[0] + r <= body_of[D]
                                and list(s[base + ld[0] + h: base + ld[0] + r]) == ro[h:]):
                            donor = (D, ld[0])
                            break
                if donor is None:
                    raise LayoutError(f"page {p}: run-out of {lab} is neither a copy of its loop start nor "
                                      f"explained by an earlier recording's (wave_runout_halves.py)")
                D, ld = donor
                w(f"{lab}_RunOut:\t.incbin\t\"{pcm}\", {2 * (ls - a)}, {2 * h}"
                  f"\t; census: generated -- {src_note}: the run-out, NOT a copy of the loop's first {RUNOUT} samples: "
                  f"its first {h} words are the loop's first {h} again (from sample {(ls - a) * m}; loop_probe.py)")
                w(f"\t.incbin\t\"build/wav_pcm/{tg['tg']}/{wname[D]}.pcm\", {2 * (ld + h - D * 16)}, {2 * h}"
                  f"\t; census: generated -- ../scripts/build/pcm_wav.py, from wav/{tg['tg']}/"
                  f"{(wname[D] + '_' + names[wname[D]][1]) if names.get(wname[D], ('', ''))[1] else wname[D]}.wav: "
                  f"and its last {h} words are words {h}-{r - 1} from the loop start of {wname[D]}, an earlier "
                  + ("8-bit " if m_of[D] == 2 else "") + f"recording (wave_runout_halves.py: every run-out of "
                  f"this kind takes its second half from one such loop; an authoring artefact [INFERENCE])")
        if R < b:
            if any(s[base + R: base + b]):
                raise LayoutError(f"page {p}: non-zero words between the recording's end {R:#x} and {b:#x}")
            w(f"\t.space\t{2 * (b - R)}, 0\t; zero words to the next recording")
        Es = sorted({(ents[j][1] >> 4) & 0x1F for j in users[H]})
        # one E for all its entries, and a MIDI note
        unity = f"{unity_note(Es[0]):.4f}" if len(Es) == 1 and 0 <= unity_note(Es[0]) < 128 else "-"
        rate = str(WAV_RATE)
        if lab in rates:
            rate, unity, root, hz, basis = rates[lab]
        loops, seen = [], set()
        for B in grp:
            off = (B * 16 - a) * m
            for j in users[B]:
                lp = loop_of(recs[j], ents[j][1])
                if lp is None:
                    continue
                lp = (lp[0] + off, lp[1] + off)
                if lp[1] > nsamp:
                    raise LayoutError(f"page {p}: entry {j:03X}'s loop ends at {lp[1]}, past its recording's {nsamp} samples")
                if lp not in seen:
                    seen.add(lp)
                    loops.append(f"{j}:{lp[0]}:{lp[1] - 1}")
        who = " ".join(f"{j:03X}" for j in users[H])
        cmt = (f"KN7000 {tg['tgname']} tone generator, page 0x{p:02X}, entr{'y' if len(users[H]) == 1 else 'ies'} {who} "
               f"(select 0x{p:02X}{users[H][0]:03X}); {kind}; pitch exponent E {', '.join(map(str, Es))}")
        if lab in rates:
            cmt += (f"; {rates[lab][3]} Hz at root key {rates[lab][2]} (TG read rate; "
                    f"{'from the tone database' if 'zone(s)' in rates[lab][4] else 'pitch exponent only'})")
        if k5:
            cmt += f"; the same audio as KN5000 IC307 {k5} (which holds every other word)"
        if cues:
            cmt += (f"; alternate start{'s' if len(cues) > 1 else ''} (cue points): "
                    + ", ".join(f"{c[1]} at sample {c[0]}" for c in cues))
        if lw:
            cmt += f"; ends at its loop end (the {RUNOUT}-sample run-out is in the source only)"
        for c in cues:
            if "|" in c[2] or "\t" in c[2]:
                raise LayoutError(f"{c[1]}: cue text holds a separator")
        rows.append([lab, f"{2 * (base + a):#x}", f"{2 * (base + body):#x}", "8" if m == 2 else "16",
                     rate, wav, unity, ",".join(loops) or "-", cmt,
                     "|".join(f"{c[0]}:{c[1]}:{c[2]}" for c in cues) or "-"])
    if fill:
        w(f"{pg}_Fill:\t.space\t{2 * fill}, 0xff\t; erased fill to the page end")
    return out, dict(n=n, n8=n8, recs=len(starts), recwords=pos - 4 * n, fill=2 * fill), rows


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
    names = load_names(os.path.join(os.path.dirname(sys.argv[3]), "ic307_names.tsv"))
    rates = load_rates(os.path.join(os.path.dirname(sys.argv[3]), "root_rates.tsv"))
    body, stats, rows = [], [], []
    for p in range(NPAGES):
        lines, st, rr = page_source(s, p, tg["prefix"], tg["ref"], tg, names, rates)
        body += lines
        stats.append(st)
        rows += rr
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
        "# The recordings are WAV files, one each, in wav/<tg>/ (committed since 2026-10-31; `make wave-wav`",
        "# re-extracts a missing one from the reference stream).  A WAV ends where its recording ends",
        "# (notes/wave-roms-probes/wave_record_extent.py): `<recording>_RunOut` is an explicit loop's 32-sample",
        "# run-out, read from the loop's first samples, and `.space N, 0` the zero words before the next",
        "# recording; neither is in the WAV.  An alternate start into a recording is a slice of the",
        "# recording's raw item and a cue point in its WAV.",
        "# ../scripts/build/pcm_wav.py turns each back into the raw item build/wav_pcm/<tg>/<label>.pcm that",
        "# its .incbin below reads: 16-bit = signed little-endian, the WAV data as it is; 8-bit = two signed",
        f"# samples per word, low byte first, WAV byte = ROM byte ^ 0x80.  Manifest: src/wave/{sys.argv[1]}_wav.tsv.",
        "#",
        "# page  entries  8-bit  recordings  record words  fill bytes",
    ]
    for p, st in enumerate(stats):
        head.append(f"# 0x{p:02X}  {st['n']:7d}  {st['n8']:5d}  {st['recs']:10d}  {st['recwords']:12d}  {st['fill']:10d}")
    head += ["", '.include "src/wave/wave_format.inc"']
    with open(sys.argv[3], "w") as f:
        f.write("\n".join(head + body) + "\n")
    man = os.path.join(os.path.dirname(sys.argv[3]), f"{sys.argv[1]}_wav.tsv")
    with open(man, "w", encoding="utf-8") as f:
        f.write("label\tstart\tend\tbits\trate\twav\tunity\tloops\tcomment\tcues\n")
        for r in rows:
            f.write("\t".join(r) + "\n")
    print(f"wrote {sys.argv[3]}: {sum(st['n'] for st in stats)} entries, {sum(st['recs'] for st in stats)} starts; "
          f"{man}: {len(rows)} recordings, one WAV each, {sum(len(r[9].split('|')) for r in rows if r[9] != '-')} "
          f"alternate starts as cue points")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except LayoutError as e:
        sys.exit(f"gen_wave_s.py: layout rule broken: {e}")
