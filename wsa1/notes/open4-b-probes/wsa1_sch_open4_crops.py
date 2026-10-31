#!/usr/bin/env python3
"""Re-render the SX-WSA1R service-manual crops behind the open4/wsa1-b board readings.

QUESTION IT ANSWERS: "what does the MAIN board drawing say about CPU 1's INT6 and
INT7 pins (gap N), CPU 2's P8 bit 2 (gap K), the FDC's address pins (gap W), the
0x7F0000 / 0x00E00000 decoder outputs, CPU 1's AN0-AN3, and the hard-disk nets?"
Each crop is what a sentence in WSA1-EMULATION-DISASM-GAPS.md was read from.

Source (image-only PDF, never committed; ORDER NO. EMiD951604, (c) 1995 Matsushita):
    ~/compartilhado/KN7000/service_manual/SX-WSA1R Service Manual.pdf
Needs poppler's pdftoppm and python3-pil (+numpy for the one pixel test).

    python3 notes/open4-b-probes/wsa1_sch_open4_crops.py [outdir]
        outdir defaults to $TMPDIR/wsa1-sch-open4 (TMPDIR is ~/compartilhado/tmp here).
        Exit 2 if the PDF is missing, 1 if the INT6 pixel test fails.

All coordinates are pixels of the page rendered at -r 400 (6617 x 4678).

THE ONE AUTOMATED TEST (gap N).  On page 19 the horizontal from IC9 pin 4 (TC7S14F
Schmitt inverter) turns up into IC1 pin 40 (INT6), and the +5D net leaves IC1 pin
44 (VCC) to the right on the SAME drawn row.  A coarse look reads the two as one
line, which is how "pin 40 INT6 tied to +5D" got into
kn7000_mame notes/wsa1-probes/wsa1_sch_cpu_ports.sh and wsa1.cpp.  The test scans
rows 2355..2384 between x = 4500 and 5400 for dark pixels and requires a gap of
more than 60 px between the run that ends at pin 40's corner and the run that
starts at pin 44's dot, with only the three thin pin-41/42/43 verticals inside it.
"""
import glob
import os
import subprocess
import sys

PDF = os.path.expanduser("~/compartilhado/KN7000/service_manual/SX-WSA1R Service Manual.pdf")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.environ.get("TMPDIR", os.path.expanduser("~/compartilhado/tmp")), "wsa1-sch-open4")

# name: (page, x0, y0, x1, y1, scale, what to read off it)
CROPS = {
    "int6_ic9_ic1.png": (19, 4450, 2050, 5450, 2650, 1.0,
        "IC9 pin 4 -> IC1 pin 40 (INT6); pin 41 (INT7) = FDDRQ; pin 36 (INT4) "
        "HDINT tied to ground by R301 0R; pin 44 VCC -> +5D on its own segment"),
    "cn3_sck_to_ic9.png": (19, 3600, 1480, 4650, 2420, 1.0,
        "CN3 (CP1 CN1) pin 3 SCK -> R31 220 -> IC1 pin 16 SCLK1, pulled up by "
        "R40 4.7K, and down the same wire -> R22 10K / C70 0.01u -> R23 -> IC9 "
        "pin 2.  CN3 pin 4 DATA -> R29 220 (TXD1 pin 14) and R30 1K (RXD1 pin 15). "
        "IC1 AN0-AN3 (pins 20-23) each to ground through a 0R part placed at "
        "C66-C69"),
    "midi2_out_sense.png": (19, 1300, 1900, 2800, 2950, 1.0,
        "MIDI2SNS leaves L2 and lands on Q11's emitter (2SD601AQ, R73 220K to "
        "ground); Q11 is driven by Q12 (2SB709AR), whose base-emitter sits "
        "across R71 150 in the +5MI feed to JK3 (MIDI 2 OUT) pin 5: current "
        "drawn by a receiver on MIDI 2 OUT turns Q12/Q11 on, C91 0.1u holds it"),
    "ic2_midi_nets.png": (20, 0, 2760, 1323, 3040, 1.3,
        "IC2 pin 11 TXD0 = MIDI2OUT, 12 RXD0 = MIDI2IN, 13 P82 = MIDI2SNS"),
    "ic8_address_pins.png": (20, 2646, 3087, 3308, 3742, 2.0,
        "IC8 D72070GF3BE pins 1 RD, 2 WR, 3 FDCS, 4 A0, 5 A1, 6 A2: three "
        "register-select lines, so 0x7B0004/0x7B0005 are its registers 4 and 5"),
    "ic18_outputs.png": (20, 198, 1870, 1323, 3087, 1.6,
        "IC18 D74HC138GS: Y7 (pin 7, 0x7F0000), Y5 (pin 10) and Y0 (pin 15) "
        "end in stubs, no net; Y6 (pin 9) HDCS"),
    "ic27_outputs.png": (21, 2800, 3150, 3400, 3550, 2.0,
        "IC27 D74HC139GS: 2Y0 (pin 12, CPU 2's 0xE00000) ends in a stub, no net"),
}


def main():
    if not os.path.isfile(PDF):
        print("not found: %s" % PDF, file=sys.stderr)
        return 2
    from PIL import Image
    os.makedirs(OUT, exist_ok=True)
    for p in sorted({v[0] for v in CROPS.values()}):
        if not glob.glob(os.path.join(OUT, "p%d-*.png" % p)):
            subprocess.run(["pdftoppm", "-f", str(p), "-l", str(p), "-r", "400",
                            "-png", PDF, os.path.join(OUT, "p%d" % p)],
                           check=True, stderr=subprocess.DEVNULL)
    pages = {}
    for name, (p, x0, y0, x1, y1, sc, what) in CROPS.items():
        if p not in pages:
            pages[p] = Image.open(glob.glob(os.path.join(OUT, "p%d-*.png" % p))[0])
        cimg = pages[p].crop((x0, y0, x1, y1))
        if sc != 1.0:
            cimg = cimg.resize((int(cimg.width * sc), int(cimg.height * sc)))
        cimg.save(os.path.join(OUT, name))
        print("%-22s p%d  %s" % (name, p, what))

    import numpy as np
    row = np.array(pages[19].convert("L").crop((4500, 2355, 5400, 2385)))
    dark = (row < 128).any(axis=0)
    runs, start = [], None
    for i, d in enumerate(dark):
        if d and start is None:
            start = i
        if not d and start is not None:
            runs.append((4500 + start, 4500 + i))
            start = None
    if start is not None:
        runs.append((4500 + start, 4500 + len(dark)))
    long_runs = [r for r in runs if r[1] - r[0] > 60]
    ok = (len(long_runs) == 2 and long_runs[0][0] == 4500 and
          long_runs[1][0] - long_runs[0][1] > 60 and
          len([r for r in runs if long_runs[0][1] <= r[0] < long_runs[1][0]]) == 3)
    print("\nINT6 row runs (x ranges of dark pixels):", runs)
    print("INT6 test:", "PASS -- IC9's output ends at pin 40; +5D is a separate segment"
          if ok else "FAIL")
    return 0 if ok else 1


sys.exit(main())
