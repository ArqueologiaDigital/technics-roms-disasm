#!/usr/bin/env python3
"""
tcmp_build.py -- build and verify Technics "TCMP" style containers.

WHAT THIS DOES
--------------
  * Builds a structurally valid "TCMP" MEMORY style container from scratch
    (the same bytes MemStyleAreaLoadFactory 0x4843B15B produces on the "no
    factory container present" path: MemStyleAreaHeaderInit 0x4843531A +
    MemStyleRecInitAll 0x484353E9 + MemStyleAreaVarStreamsInit 0x484354DE +
    MemStyleAreaChecksumInit 0x48435705).
  * Builds the N=1 CUSTOM-export shape as well (MemStyleExportToCustom
    0x4843DEC7).
  * Re-implements the firmware's three verifiers in Python, transcribed
    instruction-by-instruction from the converted MN10300 assembly in
    src/program.s:
        MemStyleAreaSignatureVerify  0x48435749
        MemStyleAreaChecksumVerify   0x484356BD  (+ SumU16BE 0x484403A5)
        MemStyleAreaStreamsVerify    0x4843579E  (+ MemStyleVarBarCount
                                                  0x4843C445, RhySysexLen
                                                  0x484403CD,
                                                  RhyEventLenByStatus
                                                  0x484403D5)
    and the two composites that call them:
        MemStyleAreaValidate         0x4843B1B5  (sig + checksum + streams)
        MemStyleAreaValidateOrInit   0x4843B1F6  (sig + streams)
  * `--self-test` runs those verifiers against the REAL factory container in
    table ROM segment 2 (FactoryMemStyleContainer 0x48035D08, 0xA96C bytes)
    as an oracle, then against the freshly built synthetic one.

WHAT THIS DOES *NOT* DO
-----------------------
  * It does NOT fix the "8 Beat 1" rhythm-name bug, and it cannot.  The
    built-in style-name source is a DIFFERENT FILE FORMAT: a "Technics
    Rhythms" name resource (16-byte ASCII signature + a directory of u24BE
    offsets at +0x18/+0x1B/+0x1E/+0x21/+0x24), opened by
    StyleBuiltinNameTableInit 0x484332F9 and located by
    StyleResourceWindowProbe 0x4843D6D7.  That code never looks at a "TCMP"
    signature, never reads a 0x70 record block, an allocator top or a
    checksum descriptor, and no code path converts one format into the
    other.  A synthetic TCMP container therefore cannot stand in for the
    missing built-in style resource.  See notes/tcmp-container-synthesis.md.
  * The streams it emits are EMPTY patterns (bar markers only, from the ROM
    prototypes 0x487314B8 / 0x487314C5).  It makes no music; it makes a
    container that the firmware's own validators accept.

Layout reference: kn7000_manual.sym, section '"TCMP" STYLE CONTAINER'.
"""

import argparse
import os
import sys

PROGRAM_ROM_BASE = 0x48400000
TABLE_ROM_BASE = 0x48000000

MEM_STYLE_AREA_SIZE = 0x25800  # MemStyleAllocFits 0x484355B3
FACTORY_CONTAINER_ADDR = 0x48035D08  # FactoryMemStyleContainer
FACTORY_CONTAINER_LEN = 0xA96C  # TableRomSeg02PtrSize 0x4843D7EF

# ---------------------------------------------------------------------------
# ROM templates, embedded verbatim.  --verify-templates re-checks them against
# baserom/kn7000_program.rom.
# ---------------------------------------------------------------------------

# 0x487312E8, 0x70 bytes -- copied wholesale by MemStyleAreaHeaderInit.
HEADER_TEMPLATE = bytes.fromhex(
    ("54434d50"      # +0x00 "TCMP"
     "0000"          # +0x04 sub-signature
     "0000"          # +0x06 checksum        (left zero by the template)
     "000000"        # +0x08 checksum start  (left zero by the template)
     "000000"        # +0x0B checksum length (left zero by the template)
     "0000"          # +0x0E
     "025800"        # +0x10 container length = the 0x25800 MEM_STYLE_AREA
     "003670"        # +0x13 allocator top   = end of the N=3 record block
     "0003"          # +0x16 style count N   = 3
     "00600d0804020201020f"          # +0x18 fixed tail
     "0000000000000000000000000000")  # +0x22 .. 0x2F zero
) + b"\x20" * 0x40                    # +0x30 .. 0x6F ASCII-space padding
assert len(HEADER_TEMPLATE) == 0x70, len(HEADER_TEMPLATE)

# 0x48731358, 0x80 bytes -- MemStyleRecInit.  Name field reads "    clear    ".
STYLE_REC_TEMPLATE = (
    b"    clear    \x00\x00\x00"
    + (b"             \x00\x00\x00" * 4)
    + bytes(range(0x14))         # +0x50 the 20 variation indices
    + bytes(12)                  # +0x64 .. 0x6F
    + bytes.fromhex("10002300")  # +0x70 two u16 fields (0x0044 0x0044 in the
                                 #       factory container -- note: the sym file
                                 #       said +0x68, corrected to +0x70 here)
    + bytes(12)                  # +0x74 .. 0x7F
)
assert len(STYLE_REC_TEMPLATE) == 0x80, len(STYLE_REC_TEMPLATE)

# 0x487313D8, 0xE0 bytes -- MemStyleVarRecInit.
VAR_REC_TEMPLATE = bytes.fromhex(
    "000000000010111111111100000000000003000000000000ffff0000"
    "00000000067f00002640280040021c406c4000000000000000000000"
    "067f21002040000040021c406c4000000000000000000000067f0000"
    "204028000c021c406c4000000000000000000000067f300020402800"
    "74021c406c4000000000000000000000067f49002040280040021c40"
    "6c4000000000000000000000067f58002040280026021c406c400000"
    "0000000000000000067f1900204028005a021c406c40000000000000"
    "00000000067f00002640280040021c406c4000000000000000000000"
)
assert len(VAR_REC_TEMPLATE) == 0xE0, hex(len(VAR_REC_TEMPLATE))

# 0x487314B8 / 0x487314C5 -- the two empty-stream prototypes.
PROTO_4BAR = bytes.fromhex("00000005" + "f4f4f4f4" + "f5")
PROTO_8BAR = bytes.fromhex("00000009" + "f4" * 8 + "f5")

# 0x485B6D74 -- the "paired variation" table read by MemStyleVarRecInit.
PAIR_TABLE = bytes.fromhex("0000000000000000000000000001000100010001")
assert len(PAIR_TABLE) == 20

TEMPLATE_ADDRS = {
    "HEADER_TEMPLATE": (0x487312E8, HEADER_TEMPLATE),
    "STYLE_REC_TEMPLATE": (0x48731358, STYLE_REC_TEMPLATE),
    "VAR_REC_TEMPLATE": (0x487313D8, VAR_REC_TEMPLATE),
    "PROTO_4BAR": (0x487314B8, PROTO_4BAR),
    "PROTO_8BAR": (0x487314C5, PROTO_8BAR),
    "PAIR_TABLE": (0x485B6D74, PAIR_TABLE),
}

# ---------------------------------------------------------------------------
# byte-order helpers -- LoadU16BE/LoadU24BE/StoreU16BE/StoreU24BE
# ---------------------------------------------------------------------------


def u16be(buf, off):
    return (buf[off] << 8) | buf[off + 1]


def u24be(buf, off):
    return (buf[off] << 16) | (buf[off + 1] << 8) | buf[off + 2]


def put_u16be(buf, off, val):
    buf[off] = (val >> 8) & 0xFF
    buf[off + 1] = val & 0xFF


def put_u24be(buf, off, val):
    buf[off] = (val >> 16) & 0xFF
    buf[off + 1] = (val >> 8) & 0xFF
    buf[off + 2] = val & 0xFF


def sum_u16be(buf, off, count):
    """SumU16BE 0x484403A5: u16 sum of `count` big-endian halfwords."""
    total = 0
    for i in range(count):
        total = (total + u16be(buf, off + i * 2)) & 0xFFFF
    return total


# ---------------------------------------------------------------------------
# container geometry
# ---------------------------------------------------------------------------

STYLE_REC_OFF = 0x70
STYLE_REC_STRIDE = 0x80
VAR_REC_STRIDE = 0xE0
VARS_PER_STYLE = 20

# MemStyleAreaChecksumInit stamps these two CONSTANTS unconditionally.
CHECKSUM_START = 0x70
CHECKSUM_HALFWORDS = 0x1B00  # 0x3600 bytes = exactly the N=3 record block


def var_rec_off(n_styles, var):
    return STYLE_REC_OFF + n_styles * STYLE_REC_STRIDE + var * VAR_REC_STRIDE


def heap_off(n_styles):
    return var_rec_off(n_styles, n_styles * VARS_PER_STYLE)


# ---------------------------------------------------------------------------
# THE BUILDER
# ---------------------------------------------------------------------------


def mem_style_rec_init(buf, n_styles, style):
    """MemStyleRecInit 0x484353AF."""
    off = STYLE_REC_OFF + style * STYLE_REC_STRIDE
    buf[off:off + STYLE_REC_STRIDE] = STYLE_REC_TEMPLATE
    for i in range(VARS_PER_STYLE):
        buf[off + 0x50 + i] = (STYLE_REC_TEMPLATE[0x50 + i] + style * VARS_PER_STYLE) & 0xFF


def mem_style_var_rec_init(buf, n_styles, var):
    """MemStyleVarRecInit 0x484353FE.

    Copies the 0xE0 template over the record while PRESERVING rec[0x10],
    rec[0x11] and the u24BE stream offset at rec+0x15, then applies the slot
    rules.
    """
    off = var_rec_off(n_styles, var)
    keep_10 = buf[off + 0x10]
    keep_11 = buf[off + 0x11]
    keep_off = u24be(buf, off + 0x15)

    buf[off:off + VAR_REC_STRIDE] = VAR_REC_TEMPLATE
    buf[off + 0x11] = keep_11
    buf[off + 0x10] = keep_10
    put_u24be(buf, off + 0x15, keep_off)

    slot = var % VARS_PER_STYLE
    if PAIR_TABLE[slot] != 0:
        buf[off + 3] |= 0x10

    if slot < 0x0C:
        # rec[0x10] = 1 on multiples of 3, 0 otherwise
        buf[off + 0x10] = 1 if slot % 3 == 0 else 0
    else:
        # clamp every non-zero byte of rec[4..0x0B] to 1
        for i in range(4, 0x0C):
            if buf[off + i] != 0:
                buf[off + i] = 1


def mem_style_area_var_streams_init(buf, n_styles):
    """MemStyleAreaVarStreamsInit 0x484354DE, generalised over N."""
    n_vars = n_styles * VARS_PER_STYLE
    for var in range(n_vars):
        off = var_rec_off(n_styles, var)
        buf[off + 0x11] = 3
        buf[off + 0x10] = 1
        mem_style_var_rec_init(buf, n_styles, var)

        proto = PROTO_4BAR if buf[off + 0x10] == 0 else PROTO_8BAR
        size = u24be(proto, 1) + 4

        top = u24be(buf, 0x13)
        if top + size > len(buf):
            buf.extend(bytes(top + size - len(buf)))
        buf[top:top + size] = proto
        put_u24be(buf, 0x13, top + size)

        put_u24be(buf, off + 0x15, top)
        buf[top] = var & 0xFF  # THE VARIATION INDEX, not a zero kind byte


def mem_style_area_checksum_init(buf):
    """MemStyleAreaChecksumInit 0x48435705."""
    put_u24be(buf, 0x08, CHECKSUM_START)
    put_u24be(buf, 0x0B, CHECKSUM_HALFWORDS)
    put_u16be(buf, 0x06, sum_u16be(buf, CHECKSUM_START, CHECKSUM_HALFWORDS))


def build_container(n_styles=3, pad_to_area=False):
    """The 'no factory container' arm of MemStyleAreaLoadFactory 0x4843B15B."""
    buf = bytearray(HEADER_TEMPLATE)  # MemStyleAreaHeaderInit
    buf.extend(bytes(heap_off(n_styles) - len(buf)))

    put_u16be(buf, 0x16, n_styles)
    put_u24be(buf, 0x13, heap_off(n_styles))  # allocator top = end of records

    for style in range(n_styles):  # MemStyleRecInitAll
        mem_style_rec_init(buf, n_styles, style)
    mem_style_area_var_streams_init(buf, n_styles)

    if n_styles == 3:
        # MEMORY container: capacity in +0x10, full checksum descriptor.
        put_u24be(buf, 0x10, MEM_STYLE_AREA_SIZE)
        mem_style_area_checksum_init(buf)
        if pad_to_area:
            buf.extend(bytes(MEM_STYLE_AREA_SIZE - len(buf)))
    else:
        # CUSTOM shape per MemStyleExportToCustom 0x4843DEC7: the checksum
        # descriptor [0x06,0x10) is zeroed and +0x10 carries the USED size.
        buf[0x06:0x10] = bytes(10)
        put_u24be(buf, 0x10, u24be(buf, 0x13))
    return bytes(buf)


# ---------------------------------------------------------------------------
# THE VERIFIERS, transcribed from the converted assembly
# ---------------------------------------------------------------------------


def rhy_sysex_len(buf, off):
    """RhySysexLen 0x484403CD:  movbu (1,a0),d0 / add 2,d0."""
    return buf[off + 1] + 2


def rhy_event_len_by_status(buf, off):
    """RhyEventLenByStatus 0x484403D5: status nibble -> event length."""
    status = buf[off] & 0xF0
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(status, 1)


def mem_style_var_bar_count(buf, n_styles, var):
    """MemStyleVarBarCount 0x4843C445: (rec[0x10]+1) * ((rec[0x11]&7)+1)."""
    off = var_rec_off(n_styles, var)
    return ((buf[off + 0x10] + 1) & 0xFFFF) * (((buf[off + 0x11] & 7) + 1) & 0xFFFF)


def var_rec_data_off(buf, n_styles, var):
    """MemStyleVarRecData 0x48435628 -> u24BE(rec+0x15), container-relative."""
    return u24be(buf, var_rec_off(n_styles, var) + 0x15)


def verify_signature(buf, n_styles=3):
    """MemStyleAreaSignatureVerify 0x48435749 -> 1 or -3."""
    if buf[0:4] != b"TCMP":
        return -3, 'signature != "TCMP"'
    if buf[4:6] != b"\x00\x00":
        return -3, "sub-signature != 00 00"
    top = u24be(buf, 0x13)
    if top < 1 or top > len(buf):
        return -3, "allocator top 0x%X out of range" % top
    if buf[top - 1] != 0xF5:
        return -3, "byte below allocator top is 0x%02X, not 0xF5" % buf[top - 1]
    return 1, "ok"


def verify_checksum(buf, n_styles=3):
    """MemStyleAreaChecksumVerify 0x484356BD -> 1 or -1."""
    start = u24be(buf, 0x08)
    count = u24be(buf, 0x0B)
    stored = u16be(buf, 0x06)
    if start + count * 2 > len(buf):
        return -1, "checksum range 0x%X+0x%X halfwords past end" % (start, count)
    got = sum_u16be(buf, start, count)
    if got != stored:
        return -1, "checksum 0x%04X != stored 0x%04X" % (got, stored)
    return 1, "ok (0x%04X over 0x%X..0x%X)" % (stored, start, start + count * 2)


def verify_streams(buf, n_styles=3):
    """MemStyleAreaStreamsVerify 0x4843579E -> 1 or -3.

    The firmware hard-codes 0x3C variations and the N=3 record offsets
    (MemStyleVarRecPtr 0x484355F8), so this check only ever applies to a
    MEMORY container.  n_styles is parameterised here for symmetry.
    """
    for var in range(n_styles * VARS_PER_STYLE):
        s = var_rec_data_off(buf, n_styles, var)
        if s == 0 or s + 4 > len(buf):
            return -3, "var %d: stream offset 0x%X out of range" % (var, s)
        if buf[s + 4] != 0xF4:
            return -3, "var %d: stream[4] = 0x%02X, not 0xF4" % (var, buf[s + 4])
        length = u24be(buf, s + 1)
        end = s + 4 + length - 1
        if end >= len(buf):
            return -3, "var %d: stream length 0x%X past end" % (var, length)
        if buf[end] != 0xF5:
            return -3, "var %d: last byte 0x%02X, not 0xF5" % (var, buf[end])
        if buf[s] != (var & 0xFF):
            return -3, "var %d: stream[0] = %d, not the variation index" % (var, buf[s])

        want = mem_style_var_bar_count(buf, n_styles, var)
        markers = 0
        p = s + 4
        while True:
            if p >= len(buf):
                return -3, "var %d: ran off the end without a 0xF5" % var
            c = buf[p]
            if c == 0xF5:
                break
            if c == 0xF4:
                markers = (markers + 1) & 0xFFFF
                p += 1
            elif c == 0xF0:
                p += rhy_sysex_len(buf, p)
            elif c <= 0x7F:
                p += 1  # running-status data byte
            else:
                p += rhy_event_len_by_status(buf, p)
        if markers != want:
            return -3, "var %d: %d bar markers, MemStyleVarBarCount says %d" % (
                var, markers, want)
    return 1, "ok (%d streams)" % (n_styles * VARS_PER_STYLE)


def mem_style_area_validate(buf, n_styles=3):
    """MemStyleAreaValidate 0x4843B1B5: signature, checksum, streams."""
    for name, fn in (("signature", verify_signature),
                     ("checksum", verify_checksum),
                     ("streams", verify_streams)):
        rc, msg = fn(buf, n_styles)
        if rc < 0:
            return -1, "%s: %s" % (name, msg)
    return 1, "ok"


def mem_style_area_validate_or_init(buf, n_styles=3):
    """MemStyleAreaValidateOrInit 0x4843B1F6: signature and streams only."""
    for name, fn in (("signature", verify_signature), ("streams", verify_streams)):
        rc, msg = fn(buf, n_styles)
        if rc < 0:
            return -3, "%s: %s" % (name, msg)
    return 1, "ok"


# ---------------------------------------------------------------------------
# reporting
# ---------------------------------------------------------------------------


def describe(buf, n_styles=3):
    lines = [
        "  signature            %r %r" % (bytes(buf[0:4]), bytes(buf[4:6])),
        "  checksum      +0x06  0x%04X" % u16be(buf, 0x06),
        "  cksum start   +0x08  0x%06X" % u24be(buf, 0x08),
        "  cksum len     +0x0B  0x%06X halfwords" % u24be(buf, 0x0B),
        "  +0x0E                0x%04X" % u16be(buf, 0x0E),
        "  container len +0x10  0x%06X" % u24be(buf, 0x10),
        "  alloc top     +0x13  0x%06X" % u24be(buf, 0x13),
        "  style count   +0x16  %d" % u16be(buf, 0x16),
        "  image size           0x%X bytes" % len(buf),
    ]
    for s in range(u16be(buf, 0x16)):
        off = STYLE_REC_OFF + s * STYLE_REC_STRIDE
        lines.append("  style %d name         %r  vars %d..%d" % (
            s, bytes(buf[off:off + 13]), buf[off + 0x50], buf[off + 0x63]))
    return "\n".join(lines)


def run_verifiers(label, buf, n_styles=3):
    print("== %s ==" % label)
    print(describe(buf, n_styles))
    ok = True
    for name, fn in (("MemStyleAreaSignatureVerify", verify_signature),
                     ("MemStyleAreaChecksumVerify ", verify_checksum),
                     ("MemStyleAreaStreamsVerify  ", verify_streams),
                     ("MemStyleAreaValidate       ", mem_style_area_validate),
                     ("MemStyleAreaValidateOrInit ", mem_style_area_validate_or_init)):
        rc, msg = fn(buf, n_styles)
        print("  %s -> %+d  %s" % (name, rc, msg))
        ok = ok and rc > 0
    print()
    return ok


# ---------------------------------------------------------------------------
# ROM access
# ---------------------------------------------------------------------------


def repo_root():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_rom(name):
    path = os.path.join(repo_root(), "baserom", name)
    with open(path, "rb") as f:
        return f.read()


def factory_container():
    table = load_rom("kn7000_table.rom")
    off = FACTORY_CONTAINER_ADDR - TABLE_ROM_BASE
    return table[off:off + FACTORY_CONTAINER_LEN]


def verify_templates():
    prog = load_rom("kn7000_program.rom")
    bad = 0
    for name, (addr, blob) in sorted(TEMPLATE_ADDRS.items()):
        off = addr - PROGRAM_ROM_BASE
        got = prog[off:off + len(blob)]
        status = "OK " if got == blob else "BAD"
        if got != blob:
            bad += 1
        print("  %s %-20s 0x%08X (%d bytes)" % (status, name, addr, len(blob)))
    return bad == 0


def structural_diff(synth, factory):
    print("== structural diff: synthetic vs FactoryMemStyleContainer 0x48035D08 ==")
    for label, off, size in (("signature", 0x00, 6), ("checksum", 0x06, 2),
                             ("cksum start", 0x08, 3), ("cksum len", 0x0B, 3),
                             ("+0x0E", 0x0E, 2), ("container len", 0x10, 3),
                             ("alloc top", 0x13, 3), ("style count", 0x16, 2),
                             ("fixed tail", 0x18, 0x18), ("padding", 0x30, 0x40)):
        a = bytes(synth[off:off + size])
        b = bytes(factory[off:off + size])
        print("  %-14s +0x%02X  synth %-24s factory %-24s %s" % (
            label, off, a.hex(), b.hex(), "same" if a == b else "DIFFER"))
    print("  header [0x00,0x70) identical except checksum/alloc-top: %s" % (
        all(synth[i] == factory[i] for i in range(0x70)
            if not (0x06 <= i < 0x08 or 0x13 <= i < 0x16))))
    print()
    print("  style records: synth = the 'clear' template, factory = real names")
    for s in range(3):
        off = STYLE_REC_OFF + s * STYLE_REC_STRIDE
        print("    style %d  synth %r  factory %r  var-index tables %s" % (
            s, bytes(synth[off:off + 13]), bytes(factory[off:off + 13]),
            "same" if synth[off + 0x50:off + 0x64] == factory[off + 0x50:off + 0x64]
            else "DIFFER"))
    same_10 = sum(1 for v in range(60)
                  if synth[var_rec_off(3, v) + 0x10] == factory[var_rec_off(3, v) + 0x10])
    same_b3 = sum(1 for v in range(60)
                  if (synth[var_rec_off(3, v) + 3] & 0x10)
                  == (factory[var_rec_off(3, v) + 3] & 0x10))
    same_parts = sum(1 for v in range(60)
                     if synth[var_rec_off(3, v) + 4:var_rec_off(3, v) + 0xC]
                     == factory[var_rec_off(3, v) + 4:var_rec_off(3, v) + 0xC])
    print()
    print("  variation records (60):")
    print("    pair bit rec[3]&0x10 agrees:      %d/60" % same_b3)
    print("    per-part bytes rec[4..0x0B] agree: %d/60" % same_parts)
    print("    bar field rec[0x10] agrees:        %d/60  (factory holds real "
          "bar counts, synth holds the empty-pattern 0/1)" % same_10)
    print()
    print("  heap: synth 0x%X bytes of empty streams, factory 0x%X bytes of "
          "real patterns" % (len(synth) - heap_off(3), u24be(factory, 0x13) - heap_off(3)))
    print()


# ---------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-o", "--out", help="write the built container here")
    ap.add_argument("-n", "--styles", type=int, default=3,
                    help="style count N (3 = MEMORY, 1 = CUSTOM export shape)")
    ap.add_argument("--pad", action="store_true",
                    help="pad an N=3 container out to the full 0x25800 area")
    ap.add_argument("--self-test", action="store_true",
                    help="run the verifiers against the real factory container "
                         "(the oracle) and then against the synthetic one")
    ap.add_argument("--verify-templates", action="store_true",
                    help="check the embedded ROM templates against baserom/")
    args = ap.parse_args()

    rc = 0
    if args.verify_templates:
        print("== embedded templates vs baserom/kn7000_program.rom ==")
        if not verify_templates():
            rc = 1
        print()

    if args.self_test:
        print("== embedded templates vs baserom/kn7000_program.rom ==")
        if not verify_templates():
            rc = 1
        print()
        fac = factory_container()
        if not run_verifiers("ORACLE: FactoryMemStyleContainer 0x48035D08 "
                             "(table ROM segment 2)", fac, 3):
            print("!! the oracle FAILED -- the verifier port is wrong")
            rc = 1
        synth = build_container(3)
        if not run_verifiers("SYNTHETIC: build_container(n_styles=3)", synth, 3):
            rc = 1
        structural_diff(synth, fac)

        cust = build_container(1)
        print("== SYNTHETIC CUSTOM shape: build_container(n_styles=1) ==")
        print(describe(cust, 1))
        s_rc, s_msg = verify_signature(cust, 1)
        print("  MemStyleAreaSignatureVerify -> %+d  %s" % (s_rc, s_msg))
        st_rc, st_msg = verify_streams(cust, 1)
        print("  streams grammar (N=1 geometry) -> %+d  %s" % (st_rc, st_msg))
        print("  (MemStyleAreaChecksumVerify does not apply: MemStyleExportToCustom")
        print("   zeroes [0x06,0x10), and the firmware verifiers are hard-wired to")
        print("   the N=3 MEMORY geometry at 0x50180000.)")
        print()
        if s_rc < 0 or st_rc < 0:
            rc = 1

    if args.out:
        blob = build_container(args.styles, pad_to_area=args.pad)
        with open(args.out, "wb") as f:
            f.write(blob)
        print("wrote %s (0x%X bytes, N=%d)" % (args.out, len(blob), args.styles))

    if not (args.out or args.self_test or args.verify_templates):
        ap.print_help()
    return rc


if __name__ == "__main__":
    sys.exit(main())
