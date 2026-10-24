#!/usr/bin/env python3
r"""create_v141_subcpu_source.py -- derive the v1.41 sub-CPU payload source tree from v1.42.

QUESTION THIS ANSWERS
    What, exactly, is different between sub-CPU payload v1.41 and v1.42?  The raw byte diff
    of the two 196,608-byte images is 124,033 bytes in 2,875 runs, but almost all of that is
    address ripple.  This script is the complete SEMANTIC delta: it copies the v142 tree and
    applies EDITS below, and the result assembles byte-for-byte to
    original_ROMs/kn5000_subprogram_v141.rom (make gate, section "subcpu payload v141").
    Measured 2026-10-24 (notes/v141-subcpu-port/README.md has the alignment that found it):
      1. the payload version word at 0x00f000: 141 instead of 142;
      2. v1.42 added five stores (0x17 bytes) at the top of RESET -- v1.41 lacks them, so
         every later v1.41 address is 0x17 lower;
      3. the one 0xff alignment byte in front of the FP library (FP_dcmp_AlignPad in v1.42)
         is not needed in v1.41, so from FP_dcmp on the shift is 0x18;
      4. consequently the zero-initialised RAM linked after the image starts 0x18 lower
         (0x03ee5e instead of 0x03ee76).  No source edit is needed for that: both trees spell
         those operands Payload_Bss_Start+offset (scripts/converters/subcpu_bss_relative_refs.py).
    Nothing else differs.

    The v141 tree is maintained as "v142 + these edits" (multi-version sync policy): after any
    v142 change, run this script and commit both trees; `--check` reports drift.

RUN
    python3 scripts/generators/create_v141_subcpu_source.py           # (re)write v141/subcpu
    python3 scripts/generators/create_v141_subcpu_source.py --check   # exit 1 if v141 drifted
    make rebuilt_ROMs/kn5000_subprogram_v141.llvm.rom && cmp \
        rebuilt_ROMs/kn5000_subprogram_v141.llvm.rom original_ROMs/kn5000_subprogram_v141.rom
"""
import difflib
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, "v142/subcpu")
DST = os.path.join(ROOT, "v141/subcpu")
COPY = ["subcpu_data_tables.s", "subcpu_fp_math.s", "subcpu_vectors.s", "subcpu.ld",
        "shared/sfr_tmp94c241.s"]
MAIN_SRC, MAIN_DST = "kn5000_subprogram_v142.s", "kn5000_subprogram_v141.s"

BANNER = (b"; =============================================================================\n"
          b"; KN5000 Sub-CPU Payload ROM v1.41 (192KB)\n"
          b"; =============================================================================\n"
          b"; GENERATED from v142/subcpu by scripts/generators/create_v141_subcpu_source.py, whose\n"
          b"; EDITS list is the whole v1.41 / v1.42 difference.  Edit v142 and re-run that script\n"
          b"; rather than editing this tree by hand (it has --check).\n"
          b"; \xe2\x9a\xa0 ADDRESSES QUOTED IN COMMENTS ARE v1.42 ADDRESSES (the comments are v142's).\n"
          b";   v1.41 address = v1.42 address        for 0x000400-0x01f924 (vectors, tables, RESET)\n"
          b";                 = v1.42 address - 0x17 for 0x01f93b-0x03d2aa (after RESET's v1.42-only stores)\n"
          b";                 = v1.42 address - 0x18 for 0x03d2ac-0x03ee75 (FP_dcmp onward)\n"
          b";   and DRAM in the zero-initialised window (Payload_Bss_Start+offset) is 0x18 lower.\n"
          b"; Labels are what to trust: rebuilt_ROMs/kn5000_subprogram_v141.llvm.elf and\n"
          b"; symbols/subcpu_v141_symbols_reference.txt give the v1.41 address of every name.\n"
          b"; =============================================================================\n")

# (file, old, new): each `old` must occur exactly once in the v142 text.
EDITS = [
    ("subcpu_data_tables.s",
     b"\t.short 142\t\t; payload version 1.42 (0x008E); see the banner\n",
     b"\t.short 141\t\t; payload version 1.41 (0x008d); see the banner\n"),
    (MAIN_DST,
     b"; =============================================================================\n"
     b"; KN5000 Sub-CPU Payload ROM (192KB)\n"
     b"; =============================================================================\n",
     BANNER),
    (MAIN_DST,
     b"RESET:\n"
     b"; New in v1.42: these five stores (0x17 bytes) are absent from v1.41, whose RESET begins at the\n"
     b"; WDMOD store below -- the insertion that moves every later v1.41 address down by 0x17.  They\n"
     b"; zero the micro-DMA start vectors of channels 0 and 2, the DMA request and burst registers,\n"
     b"; and INTCLR, before the port and timer set-up.\n"
     b"\tld (DMA0V:16), 0\n\tld (DMA2V:16), 0\n\tld (DMAR:16), 0\n\tld (DMAB:16), 0\n"
     b"\tld (INTCLR:8), 0x00:io\n",
     b"RESET:\n"
     b"; v1.41 begins straight at the WDMOD store: v1.42 put five stores in front of it (DMA0V, DMA2V,\n"
     b"; DMAR, DMAB and INTCLR cleared to 0, 0x17 bytes), which is why every v1.41 address after this\n"
     b"; point is 0x17 lower than its v1.42 twin.\n"),
    (MAIN_DST,
     b"; --- 0x03D2AB-0x03D2AB  FP_dcmp_AlignPad -- one alignment byte 0xFF\n"
     b"; Already named.  Not executed.  It aligns FP_dcmp to an even address; v1.41, whose code above\n"
     b"; is 0x17 bytes shorter and ends on an even address, has no such byte.\n"
     b"; \xe2\x98\x85 Renamed 2026-09-25 from ToneGen_Voice_Padding (FP library compare; see the headers).\n"
     b"FP_dcmp_AlignPad:\n"
     b"\t.byte 0xff\n",
     b"; The FP library (FP_dcmp onward) starts on an even address.  In v1.42 the code above ends on\n"
     b"; an odd one and a 0xff pad byte (FP_dcmp_AlignPad there) fills the gap; in v1.41, 0x17 bytes\n"
     b"; shorter, it already ends on an even address and no pad byte exists.\n"
     b"\t.balign\t2, 0xff\n"),
]


def generate(dst):
    os.makedirs(os.path.join(dst, "shared"), exist_ok=True)
    texts = {}
    for f in COPY:
        texts[f] = open(os.path.join(SRC, f), "rb").read()
    texts[MAIN_DST] = open(os.path.join(SRC, MAIN_SRC), "rb").read()
    for f, old, new in EDITS:
        n = texts[f].count(old)
        if n != 1:
            sys.exit("EDIT for %s matches %d times (want 1): %r" % (f, n, old[:80]))
        texts[f] = texts[f].replace(old, new)
    for f, data in texts.items():
        open(os.path.join(dst, f), "wb").write(data)
    # idempotent on a tree that is already BSS-relative (v142 is, since 2026-10-24)
    subprocess.run([sys.executable, os.path.join(ROOT, "scripts/converters/subcpu_bss_relative_refs.py"), dst],
                   check=True, stdout=subprocess.DEVNULL)


def main():
    if sys.argv[1:] == ["--check"]:
        scratch = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
        d = tempfile.mkdtemp(prefix="v141gen_", dir=scratch)
        try:
            generate(d)
            drift = 0
            for f in COPY + [MAIN_DST]:
                a = open(os.path.join(DST, f), "rb").read()
                b = open(os.path.join(d, f), "rb").read()
                if a != b:
                    drift += 1
                    print("DRIFT %s" % f)
                    for ln in list(difflib.unified_diff(a.decode("latin-1").split("\n"),
                                                        b.decode("latin-1").split("\n"),
                                                        "v141/subcpu/" + f, "generated/" + f,
                                                        lineterm="", n=1))[:40]:
                        print(ln)
            print("v141 tree %s" % ("IN SYNC with v142 + EDITS" if not drift else "DRIFTED (%d files)" % drift))
            sys.exit(1 if drift else 0)
        finally:
            assert os.path.basename(d).startswith("v141gen_") and os.path.dirname(d) == scratch
            shutil.rmtree(d)
    elif sys.argv[1:]:
        sys.exit(__doc__)
    generate(DST)
    print("wrote %s" % os.path.relpath(DST, ROOT))


if __name__ == "__main__":
    main()
