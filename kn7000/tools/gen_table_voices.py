#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""gen_table_voices.py -- table segment 6, the INTERNAL 'JK' voice archive, as source.

Used by tools/gen_table_s.py.  The archive is the class-0 voice-resource source
(kn7000_mame notes/sound-bank-classes.md; kn7000_manual.sym, the five sources and the
voice-list index layer).  Every pointer inside it is a u32 offset from its first byte
(little-endian).  What the firmware reads, and so what this types:

  +0x14  -> the bank block T.  VoiceArchiveScanBoot (0x48449EF4) caches the archive
            base in 0x5003A554/68, T in 0x5003A57C/90 and the bank descriptor
            T + 0x0C in 0x5003A5A4.  VoiceRecDefaultPtr reads T + 4 (the default
            voice record); the descriptor's +0x04 is the tone-record directory,
            +0x14 the voice-record directory (VoiceRecFetchBanked 0x484496C9),
            +0x18 the element table, stride 0x23 (VoiceElemRecFetch 0x4844987C),
            +0x1C the 0x10-byte parameter records (VoiceParamRecFetchBanked
            0x48449925).
  +0x18  -> the sound directory D: six (bucket table, descriptor) pairs of
            multiplicative-hash tables; a descriptor is {u16 mult, u16 nbuckets,
            u16 countA, u16 countB}; a chain entry is {u32 next, key, payload}
            (the Voice*Lookup* routines).

Typed here: the header, T, D, the six hash tables' buckets and chain entries (every
link symbolic), both record directories, the voice records (name and 0x1C-byte
sub-records, VoiceSubRecFetch 0x4844978B), the names of the tone records, the
parameter records, the six 128-key maps.  The bodies of the tone records (0x54-byte
head + n x 0x7A elements; VoiceModRecFetch 0x4844982A), the multisample headers and
zone lists, the first data block and the other T tables stay labelled passthroughs:
their fields are not traced yet (notes/table-semantics-2026-10-29.md).
"""
import glob
import os
import re
import struct

# The wave-ROM sources' directory entries (src/wave/main.s, sub.s): Main_Ppp_Eeee / Sub_...
WAVE = set()
for _f in glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src", "wave", "*.s")):
    for _ln in open(_f, "rb"):
        _m = re.match(rb"((?:Main|Sub)_P[0-9A-F]{2}_E[0-9A-F]{3}):", _ln)
        if _m:
            WAVE.add(_m.group(1).decode())

HASHES = [  # (D offset of buckets, D offset of descriptor, label, key bytes, payload bytes, reader)
    (0x00, 0x18, "Tone", 4, 12, "func_4856FC51 / func_48570078 (dir + 0x18): key (MSB<<16 | LSB<<8 | program); "
                               "the u16 at entry+8 is the tone-record index func_48449525 looks up through "
                               "the descriptor's +0x04; the other 10 payload bytes are not traced"),
    (0x04, 0x1C, "Dir1", 4, 4, "a seventh table of the same shape; its reader is not traced"),
    (0x08, 0x20, "ParamBank", 4, 4, "VoiceParamBankLookupInternal 0x48570DF8: key (MSB<<16 | LSB<<8 | program), "
                                    "payload u16 = parameter record index (bit 15 = invalid)"),
    (0x0C, 0x24, "VoiceBank", 4, 4, "VoiceBankLookupInternal 0x4857150D: key (MSB<<16 | LSB<<8 | program), "
                                    "payload u16 = voice record index"),
    (0x28, 0x2C, "ListIndex", 2, 18, "VoiceListIndexLookupInternal 0x485719D5: u16 key (LSB<<8 | program), "
                                     "the record at entry+6"),
    (0x30, 0x34, "ListEntry", 2, 2, "VoiceListEntryLookupInternal 0x48571E0C: u16 key = local index B, "
                                    "the record at entry+6"),
    (0x38, 0x3C, "ListMap", 2, 2, "VoiceListMapLookupInternal 0x485723A0: u16 key = index A, the record at entry+6"),
    (0x40, 0x44, "Attr", 4, 4, "VoiceAttrLookupInternal 0x48571178: key (MSB<<16 | LSB<<8 | program), "
                               "payload u8 at entry+8"),
]


def u32(c, o):
    return struct.unpack_from("<I", c, o)[0]


def u16(c, o):
    return struct.unpack_from("<H", c, o)[0]


def hexrow(bs):
    return ", ".join(f"0x{b:02x}" for b in bs)


def ident(name, used, prefix):
    base = re.sub(r"[^A-Za-z0-9]", "", name.replace("&", "And").replace("+", "Plus")) or "Unnamed"
    lab, n = f"{prefix}{base}", 2
    while lab in used:
        lab = f"{prefix}{base}_{n}"
        n += 1
    used.add(lab)
    return lab


def asc(bs):
    return '"' + "".join(chr(b) if 0x20 <= b < 0x7F and b not in b'"\\' else f"\\x{b:02x}" for b in bs) + '"'


def internal_voice_archive(d, s, e, label, ref):
    c = d[s:e]
    L = len(c)
    if c[:2] != b"JK" or c[2:0x10] != bytes(14) or u32(c, 0x10) != 1 or u32(c, 0x1C) != 0:
        raise SystemExit(f"{label}: unexpected 'JK' header")
    T, D = u32(c, 0x14), u32(c, 0x18)
    items = {}              # offset -> (size, lines)
    labels = {}             # offset -> label

    def ref_(o):
        return f"{labels[o]} - {label}" if o in labels else f"0x{o:06x}"

    # ---- the hash tables ----
    chains = []
    for bo, do, nm, kb, pb, why in HASHES:
        b, ds = u32(c, D + bo), u32(c, D + do)
        mult, nb, ca, cb = (u16(c, ds + 2 * i) for i in range(4))
        ents = []
        for i in range(nb):
            p = u32(c, b + 4 * i)
            while p:
                ents.append(p)
                p = u32(c, p)
        ents.sort()
        size = 4 + kb + pb
        if any(ents[i + 1] - ents[i] != size for i in range(len(ents) - 1)):
            raise SystemExit(f"{label}: {nm} chain entries are not contiguous")
        for k, p in enumerate(ents):
            labels[p] = f"Jk{nm}Ent{k:04d}"
        labels[b], labels[ds] = f"Jk{nm}Buckets", f"Jk{nm}Desc"
        chains.append((nm, b, ds, mult, nb, ca, cb, ents, kb, pb, size, why))
    labels[T], labels[D] = "JkBankBlock", "JkSoundDirectory"

    # ---- the record directories ----
    td, vd, vend = u32(c, T + 0x10), u32(c, T + 0x20), u32(c, T + 0x48)
    tone = [u32(c, td + 4 * i) for i in range((vd - td) // 4)]
    voice = [u32(c, vd + 4 * i) for i in range((vend - vd) // 4)]
    used = set()
    for k, o in enumerate(tone):
        labels[o] = ident(c[o:o + 16].decode("latin-1").strip(), used, "Tone_")
    for k, o in enumerate(voice):
        labels[o] = ident(c[o:o + 13].decode("latin-1").strip(), used, "Voice_")
    labels[td], labels[vd] = "JkToneDirectory", "JkVoiceDirectory"
    pr = u32(c, T + 0x28)
    np_ = (u32(c, T + 0x3C) - pr) // 16
    labels[pr] = "JkParamRecords"
    keymaps = sorted({u32(c, u32(c, pr + 16 * i)) for i in range(np_)})
    for k, o in enumerate(keymaps):
        labels[o] = f"JkKeyMap{k}"

    # ---- items ----
    def put(o, size, lines):
        if o in items:
            raise SystemExit(f"{label}: two items at 0x{o:x}")
        items[o] = (size, lines)

    put(0, 0x20, ['    .ascii\t"JK"', "    .space\t14, 0x00",
                  "    .long\t1\t\t# no reader traced",
                  f"    .long\tJkBankBlock - {label}\t# -> 0x5003A57C (VoiceArchiveScanBoot)",
                  f"    .long\tJkSoundDirectory - {label}\t# the six hash directories",
                  "    .long\t0"])
    Tl = [f"    .long\t{ref_(u32(c, T))}\t# +0x00",
          f"    .long\t{ref_(u32(c, T + 4))}\t# +0x04 the default voice record (VoiceRecDefaultPtr)",
          f"    .long\t{ref_(u32(c, T + 8))}\t# +0x08",
          "JkBankDescriptor:\t\t# T + 0x0C -> 0x5003A5A4",
          f"    .long\t{u32(c, T + 0xC)}\t\t# +0x00 of the descriptor"]
    names = {0x10: "+0x04 the tone-record directory", 0x20: "+0x14 the voice-record directory (VoiceRecFetchBanked)",
             0x24: "+0x18 the element table, stride 0x23 (VoiceElemRecFetch)",
             0x28: "+0x1C the parameter records, 0x10 each (VoiceParamRecFetchBanked)"}
    for o in range(0x10, 0x54, 4):
        v = u32(c, T + o)
        Tl.append(f"    .long\t{ref_(v) if v else 0}\t# descriptor {names.get(o, f'+0x{o - 0xC:02x}')}")
    put(T, 0x54, Tl)
    Dl = []
    for o in range(0, 0x48, 4):
        Dl.append(f"    .long\t{ref_(u32(c, D + o))}")
    put(D, 0x48, Dl)
    for nm, b, ds, mult, nb, ca, cb, ents, kb, pb, size, why in chains:
        if b - ds == 8:   # the ListMap descriptor also carries the two counts (VoiceArchiveCountA/B)
            put(ds, 8, [f"    .word\t{mult}, {nb}, {ca}, {cb}\t# mult, nbuckets, countA, countB"])
        else:
            put(ds, 4, [f"    .word\t{mult}, {nb}\t# mult, nbuckets"])
        rows = []
        for i in range(nb):
            v = u32(c, b + 4 * i)
            rows.append(f"    .long\t{ref_(v) if v else 0}")
        put(b, 4 * nb, rows)
        el = [f"# {why}"]
        for k, p in enumerate(ents):
            nx = u32(c, p)
            key = u32(c, p + 4) if kb == 4 else u16(c, p + 4)
            pay = c[p + 4 + kb:p + size]
            el.append(f"{labels[p]}:")
            el.append(f"    .long\t{ref_(nx) if nx else 0}\t# next in the bucket chain")
            if kb == 4:
                el.append(f"    .long\t0x{key:06x}\t# key: MSB 0x{key >> 16:02x}, LSB 0x{(key >> 8) & 0xFF:02x}, "
                          f"program {key & 0xFF}")
            else:
                el.append(f"    .word\t0x{key:04x}\t# key")
            if nm == "ListIndex":
                el.append(f"    .byte\t{hexrow(pay[:2])}")
                el.append(f"    .ascii\t{asc(pay[2:14])}")
                el.append(f"    .byte\t{hexrow(pay[14:])}")
            else:
                el.append(f"    .byte\t{hexrow(pay)}")
        put(ents[0], size * len(ents), el)
    put(td, 4 * len(tone), [f"    .long\t{ref_(o)}" for o in tone])
    put(vd, 4 * len(voice), [f"    .long\t{ref_(o)}" for o in voice])
    vs = sorted(voice)
    for i, o in enumerate(vs):
        size = (vs[i + 1] - o) if i + 1 < len(vs) else 0x10 + 0x1C
        if (size - 0x10) % 0x1C or size > 0x10 + 0x1C * 4:
            raise SystemExit(f"{label}: voice record 0x{o:x} size {size}")
        vl = [f"{labels[o]}:", f"    .ascii\t{asc(c[o:o + 13])}",
              f"    .byte\t{hexrow(c[o + 13:o + 16])}\t# +0x0D: VoiceSubRecFetch's selector byte"]
        for k in range((size - 0x10) // 0x1C):
            r = o + 0x10 + 0x1C * k
            vl.append(f"    .byte\t{hexrow(c[r:r + 0x1C])}\t# sub-record {k}")
        put(o, size, vl)
    tone_sorted = sorted(tone)
    tone_next = {o: tone_sorted[i + 1] for i, o in enumerate(tone_sorted[:-1])}
    # ---- parameter records, multisample headers, zone lists ----
    # TgVoiceRoutePtrCalc 0x4C02BE45: key map = base + *(base + param+0) (func_48449DF8),
    # group = keymap[note], zone = (base + param+4) + (param+0 + 4)[group] * (8 if param+8
    # bit 7 else 6).  TgPitchNoteResolve adds the zone's s16 +6 only when param+8 bit 7 is set.
    recs = []
    for i in range(np_):
        r = pr + 16 * i
        a, b, fl = u32(c, r), u32(c, r + 4), c[r + 8]
        km = u32(c, a)
        ng = max(c[km:km + 128]) + 1
        nz = max(c[a + 4:a + 4 + ng]) + 1
        recs.append((i, r, a, b, fl, km, ng, nz, 8 if fl & 0x80 else 6))
        labels[a], labels[b] = f"JkMsHeader{i:03d}", f"JkZones{i:03d}"
    pl = []
    for i, r, a, b, fl, km, ng, nz, zs in recs:
        pl += [f"    jk_param\t{labels[a]} - {label}, {labels[b]} - {label}, 0x{fl:02x}, {c[r + 9]}, {c[r + 10]}, "
               f"{c[r + 11]}, 0x{u16(c, r + 12):04x}, {c[r + 14]}, {c[r + 15]}\t# record {i}"]
    put(pr, 16 * np_, pl)
    for k, o in enumerate(keymaps):
        put(o, 128, [f"{labels[o]}:\t\t# key 0..127 -> key group (a multisample header's first word)"] +
            [f"    .byte\t{', '.join(str(x) for x in c[o + i:o + i + 16])}\t# keys {i}-{i + 15}" for i in range(0, 128, 16)])
    for i, r, a, b, fl, km, ng, nz, zs in recs:
        put(a, 4 + ng, [f"    .long\t{labels[km]} - {label}",
                        f"    .byte\t{', '.join(str(x) for x in c[a + 4:a + 4 + ng])}\t# key group -> zone"])
        zl = []
        for k in range(nz):
            z = b + zs * k
            page, fb, ent, b4, b5 = c[z], c[z + 1], u16(c, z + 2), c[z + 4], c[z + 5]
            names = [f"{tg}_P{page:02X}_E{ent:03X}" for tg in ("Main", "Sub") if f"{tg}_P{page:02X}_E{ent:03X}" in WAVE]
            rec = " / ".join(names) if names else f"page 0x{page:02x} entry 0x{ent:03x}: no such wave entry"
            if zs == 8:
                zl.append(f"    jk_zone8\t0x{page:02x}, 0x{fb:02x}, 0x{ent:03x}, {b4}, {b5}, "
                          f"{struct.unpack_from('<h', c, z + 6)[0]}\t# zone {k}: {rec}")
            else:
                zl.append(f"    jk_zone6\t0x{page:02x}, 0x{fb:02x}, 0x{ent:03x}, {b4}, {b5}\t# zone {k}: {rec}")
        put(b, zs * nz, zl)
    # the alignment between them, and a key map nothing points at
    zone_items = sorted(o for o in items if keymaps[0] <= o)
    end_zone = max(o + items[o][0] for o in zone_items)
    pos_ = keymaps[0]
    for o in zone_items + [end_zone]:
        if o > pos_ and pos_ < end_zone:
            gap = c[pos_:o]
            if gap == bytes(len(gap)) and len(gap) < 4:
                put(pos_, len(gap), [f"    .space\t{len(gap)}, 0x00\t# alignment"])
            elif gap == b"\xff" * len(gap) and len(gap) < 4:
                put(pos_, len(gap), [f"    .space\t{len(gap)}, 0xff\t# alignment"])
            elif len(gap) == 128 and list(gap) == sorted(gap):
                labels[pos_] = "JkKeyMapUnreferenced"
                put(pos_, 128, ["JkKeyMapUnreferenced:\t\t# a key map no multisample header points at"] +
                    [f"    .byte\t{', '.join(str(x) for x in gap[i:i + 16])}\t# keys {i}-{i + 15}"
                     for i in range(0, 128, 16)])
        if o in items:
            pos_ = max(pos_, o + items[o][0])

    # ---- tone records (the part tone block's descriptor, TgPartProgramApply 0x4C03893D stores
    # the func_48449525 result at 0x500CE404 + part * 0x130) ----
    starts = sorted(items)
    for o in tone:
        nxt = min([x for x in starts if x > o] + [tone_next.get(o, L)])
        size = nxt - o
        cls = c[o + 0x10]
        tl = [f"{labels[o]}:", f"    .ascii\t{asc(c[o:o + 16])}"]
        if cls & 0xC0 == 0x40 and size >= 0x1A7:       # a TABLE tone (TgNoteOnTableTone 0x4C03600D)
            size = 0x1A7
            tl.append(f"    tone_head_table\t0x{cls:02x}, {hexrow(c[o + 0x11:o + 0x27])}")
            for k in range(128):
                q = o + 0x27 + 3 * k
                tl.append(f"    tone_note\t0x{c[q]:02x}, 0x{c[q + 1]:02x}, 0x{c[q + 2]:02x}\t# note {k}")
        elif size >= 0x54 and ((size - 0x54) % 0x7A == 0 or size < 0x54 + 0x7A):
            h = c[o:o + 0x54]
            tl.append(f"    tone_head\t0x{h[0x10]:02x}, 0x{h[0x11]:02x}, 0x{h[0x12]:02x}")
            tl.append(f"    .byte\t{hexrow(h[0x13:0x23])}\t# +0x13")
            tl.append(f"    .byte\t{hexrow(h[0x23:0x33])}\t# +0x23")
            tl.append(f"    .byte\t{hexrow(h[0x33:0x44])}\t# +0x33")
            tl.append(f"    tone_type\t0x{h[0x44]:02x}, 0x{h[0x45]:02x}")
            tl.append(f"    .byte\t{hexrow(h[0x46:0x54])}\t# +0x46")
            for k in range((size - 0x54) // 0x7A):
                q = o + 0x54 + 0x7A * k
                tl.append(f"{labels[o]}_Unit{k}:\t\t# +0x54 + {k} x 0x7A (VoiceModRecFetch 0x4844982A)")
                for j in range(0, 0x7A, 16):
                    tl.append(f"    .byte\t{hexrow(c[q + j:q + min(j + 16, 0x7A)])}\t# +0x{j:02x}")
            if (size - 0x54) % 0x7A:
                q = o + 0x54
                tl.append(f"    .byte\t{hexrow(c[q:o + size])}\t# after the head: no unit (reader not traced)")
        else:
            size = 16
        put(o, size, tl)

    # ---- the remaining tables the bank block points at ----
    def rows(o, size, stride, lab, head, name_len=0, row_label=None):
        out_ = [f"{lab}:\t\t# {head}"]
        n = size // stride
        for k in range(n):
            q = o + stride * k
            if row_label:
                out_.append(f"{row_label}{k:02d}:")
            j = 0
            if name_len:
                out_.append(f"    .ascii\t{asc(c[q:q + name_len])}")
                j = name_len
            while j < stride:
                out_.append(f"    .byte\t{hexrow(c[q + j:q + min(j + 16, stride)])}\t# +0x{j:02x}")
                j += 16
        rest = size - n * stride
        if rest:
            out_.append(f"    .byte\t{hexrow(c[o + n * stride:o + size])}\t# after the last row")
        put(o, size, out_)

    t = lambda k: u32(c, T + k)                                        # noqa: E731
    # T + 0x00: a tone record outside the directory, "Initial" (0x54 + 4 x 0x7A)
    o = t(0x00)
    tl = [f"    .ascii\t{asc(c[o:o + 16])}", f"    tone_head\t0x{c[o + 0x10]:02x}, 0x{c[o + 0x11]:02x}, 0x{c[o + 0x12]:02x}"]
    for a_, b_ in ((0x13, 0x23), (0x23, 0x33), (0x33, 0x44)):
        tl.append(f"    .byte\t{hexrow(c[o + a_:o + b_])}\t# +0x{a_:02x}")
    tl.append(f"    tone_type\t0x{c[o + 0x44]:02x}, 0x{c[o + 0x45]:02x}")
    tl.append(f"    .byte\t{hexrow(c[o + 0x46:o + 0x54])}\t# +0x46")
    nu = (t(0x04) - o - 0x54) // 0x7A
    for k in range(nu):
        q = o + 0x54 + 0x7A * k
        tl.append(f"JkInitialTone_Unit{k}:")
        for j in range(0, 0x7A, 16):
            tl.append(f"    .byte\t{hexrow(c[q + j:q + min(j + 16, 0x7A)])}\t# +0x{j:02x}")
    labels[o] = "JkInitialTone"
    put(o, 0x54 + 0x7A * nu, ["JkInitialTone:\t\t# bank block +0x00: a tone record outside the directory"] + tl)
    # T + 0x04: the default voice record (VoiceRecDefaultPtr), 0x10 + one 0x1C sub-record
    o = t(0x04)
    labels[o] = "JkDefaultVoice"
    put(o, 0x2C, ["JkDefaultVoice:\t\t# bank block +0x04 (VoiceRecDefaultPtr 0x484497E0)",
                  f"    .ascii\t{asc(c[o:o + 13])}", f"    .byte\t{hexrow(c[o + 13:o + 16])}",
                  f"    .byte\t{hexrow(c[o + 16:o + 0x2C])}\t# sub-record 0"])
    # the sound directory's +0x10 / +0x14: 128 sixteen-character names and a 128-byte table
    o = u32(c, D + 0x10)
    labels[o] = "JkGroupNames"
    put(o, 0x800, ["JkGroupNames:\t\t# sound directory +0x10: 128 names of 16 characters (PIANO, GUITAR ...)"] +
        [f"    .ascii\t{asc(c[o + 16 * k:o + 16 * k + 16])}\t# {k}" for k in range(128)])
    o = u32(c, D + 0x14)
    labels[o] = "JkGroupTable"
    rows(o, 0x80, 16, "JkGroupTable", "sound directory +0x14: 128 bytes, reader not traced")
    # descriptor +0x30 .. +0x44 (T + 0x3C .. 0x50) and T + 0x08
    o = t(0x3C)
    labels[o] = "JkDesc30Records"
    rows(o, t(0x40) - o, 0x10, "JkDesc30Records", "descriptor +0x30: 0x10-byte records (func_484499E9 indexes them by a byte)")
    o = t(0x40)
    labels[o] = "JkDesc34Rows"
    rows(o, t(0x44) - o, 0x14, "JkDesc34Rows", "descriptor +0x34: 20-byte rows, reader not traced")
    o = t(0x44)
    labels[o] = "JkDesc38Table"
    rows(o, t(0x24) - o, 0x10, "JkDesc38Table", "descriptor +0x38: reader not traced")
    o = t(0x24)
    labels[o] = "JkElementTable"
    rows(o, t(0x50) - o, 0x23, "JkElementTable", "descriptor +0x18: elements of 0x23 bytes (VoiceElemRecFetch 0x4844987C); "
         "TgVoiceZoneVeloResolve reads 5-byte entries from +5 by velocity layer")
    o = t(0x50)
    labels[o] = "JkTuningTable"
    rows(o, t(0x4C) - o, 0x1C, "JkTuningTable", "descriptor +0x44: [INFERENCE] scale tunings, a 16-byte name and 12 "
         "values (0x80 = 0) per scale (FLAT, DUMMY ...)", name_len=16)
    o = t(0x4C)
    labels[o] = "JkCurveTable"
    rows(o, t(0x08) - o, 0x90, "JkCurveTable", "descriptor +0x40: a 16-byte name and 128 values per curve (PIANO ...)",
         name_len=16)
    o = t(0x08)
    labels[o] = "JkKeyTables"
    rows(o, u32(c, D + 0x44) - o, 0x80, "JkKeyTables", "bank block +0x08: 128-byte key tables, reader not traced")
    # descriptor +0x3C (T + 0x48): 40 named records of 0x2C8 bytes
    o = t(0x48)
    labels[o] = "JkDesc3CRecords"
    rows(o, t(0x00) - o, 0x2C8, "JkDesc3CRecords", "descriptor +0x3C: 40 named records of 0x2C8 bytes (the size of a "
         "SOUND EDIT record, 0x500C0784 + n x 0x2C8)", name_len=16)
    # the zones the tone-key table's entries point at (entry +14), 8 bytes each

    # an array of 8-byte zones after the multisample data (labels only where an aligned offset to it exists)
    ms_end = max(max(b + zs * nz, a + 4 + ng) for i, r, a, b, fl, km, ng, nz, zs in recs)
    zone_hi = min(x for x in items if x > ms_end)
    tz = sorted({u32(c, p_ + 14) for p_ in chains[0][7] if ms_end <= u32(c, p_ + 14) < zone_hi})
    z0 = ms_end + (2 if c[ms_end:ms_end + 2] == b"\xff\xff" else 0)
    tz = [x for x in tz if (x - z0) % 8 == 0]
    if (zone_hi - z0) % 8 == 0:
        zend = zone_hi
        if z0 > ms_end:
            put(ms_end, 2, ["    .space\t2, 0xff\t# alignment"])
        zl = ["JkKitZones:\t\t# 8-byte zones after the multisample data; no offset to them was found in the",
              "\t\t\t# archive (the drum-kit path, TgDrumStageStd 0x4C035879, is the candidate reader)"]
        for k in range((zend - z0) // 8):
            z = z0 + 8 * k
            page, fb, ent, b4, b5 = c[z], c[z + 1], u16(c, z + 2), c[z + 4], c[z + 5]
            names = [f"{tg}_P{page:02X}_E{ent:03X}" for tg in ("Main", "Sub") if f"{tg}_P{page:02X}_E{ent:03X}" in WAVE]
            rec = " / ".join(names) if names else f"page 0x{page:02x} entry 0x{ent:03x}: no such wave entry"
            if z in tz:
                zl.append(f"JkKitZone{z:06x}:")
            zl.append(f"    jk_zone8\t0x{page:02x}, 0x{fb:02x}, 0x{ent:03x}, {b4}, {b5}, "
                      f"{struct.unpack_from('<h', c, z + 6)[0]}\t# {rec}")
        for x in tz:
            labels[x] = f"JkKitZone{x:06x}"
        put(z0, 8 * ((zend - z0) // 8), zl)
    if c[0x20:0x24] == bytes(4) and 0x20 not in items:
        put(0x20, 4, ["    .space\t4, 0x00\t# before the first hash chain"])

    # ---- assemble, passthroughs for the gaps ----
    out = []
    pos = 0
    for o in sorted(items):
        size, lines = items[o]
        if o < pos:
            raise SystemExit(f"{label}: item at 0x{o:x} overlaps (pos 0x{pos:x})")
        if o > pos:
            what = "the body of the tone record above (0x54-byte head after its name + n x 0x7A elements)" \
                if out and out[-1].startswith("    .ascii") and any(out[-2].startswith(p) for p in ("Tone_",)) \
                else "not decoded yet"
            out.append(f'    .incbin_range\t"{ref}", 0x{s + pos:06x}, 0x{s + o:06x}\t# {what}')
        if o in labels and not any(ln.startswith(labels[o] + ":") for ln in lines):
            out.append(f"{labels[o]}:")
        out += lines
        pos = o + size
    if pos < L:
        out.append(f'    .incbin_range\t"{ref}", 0x{s + pos:06x}, 0x{s + L:06x}\t# not decoded yet')
    return out
