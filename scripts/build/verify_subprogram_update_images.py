#!/usr/bin/env python3
"""Do the Sub-CPU firmware-update images decompress to the tracked payload ROMs?

QUESTION ANSWERED
    original_ROMs/ tracks the v1.40, v1.41 and v1.42 Sub-CPU payloads twice: as
    the plain 196,608-byte image (kn5000_subprogram_v14N.rom) and as the
    whole-file SLIDE4K image shipped on the update disks
    (kn5000_subprogram_v14N_compressed.rom, File Type 007).  Since 2026-10-24
    all three have a source build (v142/, v141/, v140/subcpu) and the Makefile
    proves each compressed image by recompressing the build output.  Before
    that, only v1.42 had one, and nothing checked that the two v1.40 and v1.41
    files were the same firmware.  This still does, independently of any
    source build: each compressed image must
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
    scripts/build/decompress_lzss.py used + 2 until 2026-10-24: on the v1.40
    stream that yielded 177,007 bytes, 172,469 of them wrong
    (`--legacy-decoder` reproduces that figure by passing length_bias=2).
    It is fixed now, and --selftest checks that it agrees.

SELFTEST (--selftest, run by `make verify-subprogram-update-images`)
    Shows the check can fail, and checks the two other LZSS scripts:
    - for each version, eight copies of the compressed image, each with ONE
      byte of the stream XORed with 0x01 (spread evenly through the stream),
      and one copy whose header declares a size one byte larger: check_bytes()
      must report a problem for every one of them;
    - decompress_lzss.py's decoder must give the plain v1.40 image with its
      default length bias (3) and must not with the old bias (2);
    - lzss_compress.py must round-trip the first 3,000 bytes of the v1.40
      payload through its own decoder and through compress_lzss.py's.

RUN
    python3 scripts/build/verify_subprogram_update_images.py
    make verify-subprogram-update-images        (part of `make gate`)
    python3 scripts/build/verify_subprogram_update_images.py --selftest
    python3 scripts/build/verify_subprogram_update_images.py --legacy-decoder
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


def load(ver):
    comp_path = os.path.join(ROOT, "original_ROMs", f"kn5000_subprogram_{ver}_compressed.rom")
    plain_path = os.path.join(ROOT, "original_ROMs", f"kn5000_subprogram_{ver}.rom")
    return comp_path, open(comp_path, "rb").read(), open(plain_path, "rb").read()


def check(ver):
    comp_path, comp, plain = load(ver)
    return check_bytes(comp, plain, comp_path)


def check_bytes(comp, plain, label):
    declared = lz.parse_header(comp, label)
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


def legacy_decoder():
    """What decompress_lzss.py's decoder (length = nibble + 2) makes of v1.40."""
    import decompress_lzss
    comp = open(os.path.join(ROOT, "original_ROMs", "kn5000_subprogram_v140_compressed.rom"), "rb").read()
    plain = open(os.path.join(ROOT, "original_ROMs", "kn5000_subprogram_v140.rom"), "rb").read()
    out = decompress_lzss.decompress_slide4k(comp[lz.HEADER_LEN:], length_bias=2)
    wrong = sum(1 for x, y in zip(out, plain) if x != y)
    print(f"  decompress_lzss.py on v140: {len(out):,} B out (plain image {len(plain):,} B), "
          f"{wrong:,} of the first {min(len(out), len(plain)):,} differ")
    return 0


def selftest():
    failures = []
    for ver in VERSIONS:
        comp_path, comp, plain = load(ver)
        stream_len = len(comp) - lz.HEADER_LEN
        mutants = []
        for k in range(8):
            at = lz.HEADER_LEN + (2 * k + 1) * stream_len // 16
            m = bytearray(comp)
            m[at] ^= 0x01
            mutants.append((f"stream byte 0x{at:x} ^ 0x01", bytes(m)))
        m = lz.make_header(len(plain) + 1) + comp[lz.HEADER_LEN:]
        mutants.append(("declared size + 1", m))
        for what, m in mutants:
            try:
                problems, _ = check_bytes(m, plain, f"{ver} mutant ({what})")
            except SystemExit:
                problems = ["header rejected"]
            except Exception as e:  # a corrupt stream may also crash the decoder
                problems = [f"decoder raised {type(e).__name__}"]
            if not problems:
                failures.append(f"{ver}: mutant '{what}' was NOT detected")
        missed = any(f.startswith(ver + ":") for f in failures)
        print(f"  selftest  subprogram {ver}: {len(mutants)} mutants, "
              + ("SOME MISSED" if missed else "all detected"))
    import decompress_lzss
    _, comp, plain = load("v140")
    stream = comp[lz.HEADER_LEN:]
    if decompress_lzss.decompress_slide4k(stream) != plain:
        failures.append("decompress_lzss.py (length + 3) does not give the plain v1.40 image")
    if decompress_lzss.decompress_slide4k(stream, length_bias=2) == plain:
        failures.append("decompress_lzss.py with the old bias gives the plain image: the check is blind")
    print("  selftest  decompress_lzss.py: + 3 decodes v140 exactly, + 2 does not"
          if not any("decompress_lzss" in f for f in failures) else "  selftest  decompress_lzss.py: FAIL")
    import lzss_compress
    src = plain[:3000]
    z = lzss_compress.compress_lzss(src, None)
    own = lzss_compress.decompress_lzss(z) == src
    fw = expand(lz.decode_compressed(z)) == src
    if not (own and fw):
        failures.append(f"lzss_compress.py round trip: own decoder {own}, compress_lzss.py decoder {fw}")
    print(f"  selftest  lzss_compress.py: 3,000 B -> {len(z):,} B, round-trips "
          f"(own decoder {own}, compress_lzss.py decoder {fw})")
    for f in failures:
        print(f"          {f}")
    print("\nSELFTEST PASS" if not failures else f"\nSELFTEST FAIL: {len(failures)} problem(s)")
    return 1 if failures else 0


def main():
    if "--legacy-decoder" in sys.argv:
        return legacy_decoder()
    if "--selftest" in sys.argv:
        return selftest()
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
