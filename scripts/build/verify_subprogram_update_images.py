#!/usr/bin/env python3
"""Do the Sub-CPU firmware-update images decompress to the tracked payload ROMs?

QUESTION ANSWERED
    original_ROMs/ tracks the v1.40, v1.41 and v1.42 Sub-CPU payloads twice: as
    the plain 196,608-byte image (kn5000_subprogram_v14N.rom) and as the
    whole-file SLIDE4K image shipped on the update disks
    (kn5000_subprogram_v14N_compressed.rom, File Type 007).  Only v1.42 has a
    source build, and the Makefile already proves its compressed image by
    recompressing the build output.  Nothing checked that the two v1.40 and
    v1.41 files are the same firmware.  This does: each compressed image must
    carry a valid header, and decompressing it must yield EXACTLY the plain
    image (no byte short, no byte different, no stray output past the size the
    header declares).  v1.42 is checked too, because it costs nothing.

    A second check re-encodes the decoded decision list and requires the
    stream bytes back unchanged, so the decoder has consumed every byte and
    read every flag bit the way the encoder in compress_lzss.py writes it.

DECODER
    The decoder is scripts/build/compress_lzss.py's (parse_header,
    decode_compressed, encode_decisions) -- the one the v1.42 update-image
    build rule uses -- not a copy.  Back-reference length = low nibble + 3.
    scripts/build/decompress_lzss.py uses + 2 and is NOT used here: on the
    v1.40 stream it yields 177,007 bytes, 172,469 of the first 177,007 wrong
    (checked 2026-10-24 by calling its decompress_slide4k on the stream).

RUN
    python3 scripts/build/verify_subprogram_update_images.py
    make verify-subprogram-update-images        (part of `make gate`)
Exits non-zero on any mismatch.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import compress_lzss as lz  # noqa: E402

VERSIONS = ("v140", "v141", "v142")


def expand(decisions):
    """Replay ('lit', b) / ('ref', offset, length) decisions into output bytes."""
    window = bytearray(lz.WINDOW_SIZE)
    pos = lz.PREFILL_SIZE
    out = bytearray()
    for d in decisions:
        if d[0] == "lit":
            src = None
            length = 1
        else:
            src, length = d[1], d[2]
        for i in range(length):
            b = d[1] if src is None else window[(src + i) & lz.WINDOW_MASK]
            out.append(b)
            window[pos] = b
            pos = (pos + 1) & lz.WINDOW_MASK
    return bytes(out)


def check(ver):
    comp_path = os.path.join(ROOT, "original_ROMs", f"kn5000_subprogram_{ver}_compressed.rom")
    plain_path = os.path.join(ROOT, "original_ROMs", f"kn5000_subprogram_{ver}.rom")
    comp = open(comp_path, "rb").read()
    plain = open(plain_path, "rb").read()
    declared = lz.parse_header(comp, comp_path)
    stream = comp[lz.HEADER_LEN:]
    decisions = lz.decode_compressed(stream)
    out = expand(decisions)
    problems = []
    if declared != len(plain):
        problems.append(f"header declares {declared:,} B, plain image is {len(plain):,} B")
    if len(out) != len(plain):
        problems.append(f"decompressed {len(out):,} B, plain image is {len(plain):,} B")
    ndiff = sum(1 for a, b in zip(out, plain) if a != b)
    if ndiff:
        problems.append(f"{ndiff:,} bytes differ")
    if lz.encode_decisions(decisions) != stream:
        problems.append("re-encoding the decoded decisions does not give the stream back")
    nlit = sum(1 for d in decisions if d[0] == "lit")
    summary = (f"{len(comp):>7,} B -> {len(out):>7,} B  "
               f"({nlit:,} literals, {len(decisions) - nlit:,} back-references)")
    return problems, summary


def main():
    bad = 0
    for ver in VERSIONS:
        problems, summary = check(ver)
        verdict = "OK  " if not problems else "FAIL"
        print(f"  {verdict}  subprogram {ver}: {summary}")
        for p in problems:
            print(f"          {p}")
        bad += bool(problems)
    print("\nPASS: every update image decompresses to its tracked payload ROM."
          if not bad else f"\nFAIL: {bad} update image(s) do not match.")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
