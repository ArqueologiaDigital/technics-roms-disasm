#!/usr/bin/env python3
"""sm_pd0_net.py -- which board signal does the main CPU's Port D bit 0 drive?

QUESTION IT ANSWERS (open item T-kn5000-tabledata-todo-identify-what)
  table_data's FDC_PulseResetLine (was Boot_PulsePD0) and the main CPU's twin pulse Port D bit 0 for 10 ticks.
  The service manual's CPU SECTION (A) P.C. diagram (page 32 of technics_sx-kn5000.pdf, a scan with no text
  layer) shows the net.  This script renders the page at 400 dpi with pdftoppm and writes three crops to OUTDIR:
    pd0_pins.png    IC5 TMP94C241F, left pins 1-40: pin 12 is PD0, 13 INT4, 14 INT5, 17 PD6/TI7/INT7
    pd0_cross.png   the nested L-shaped traces: pin 12's trace is the outermost one, pin 13's the next, pin 14's
    pd0_labels.png  the sheet-edge labels the traces come from: FDCTC, FDCRST, FDCINT, FDCDRQ, FD.H/D, FD.I/O
SIGNAL (read by eye, 2026-10-31)
  The traces leave the label column in the order FDCTC (page y ~1328), FDCRST (~1353), FDCINT (~1378), FDCDRQ
  (~1402) and reach the pins in nesting order: the outermost, at y ~1350, ends on pin 12 PD0, the next on pin 13
  INT4, the next on pin 14 INT5.  So PD0 = FDCRST (the FDC's hardware reset), INT4 = FDCINT, INT5 = FDCDRQ;
  and PD6 = FD.I/O, which the firmware already samples as the disk-change input.
  The crops are not committed (the manual is not ours to publish); this recipe regenerates them.
RUN
  python3 notes/kn5000-a-2026-10-31/probes/sm_pd0_net.py [PDF] [OUTDIR]
  defaults: ~/compartilhado/kn5000-docs/service_manual/technics_sx-kn5000.pdf, $TMPDIR/sm_pd0_net
"""
import os
import subprocess
import sys

from PIL import Image

pdf = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
    "~/compartilhado/kn5000-docs/service_manual/technics_sx-kn5000.pdf")
out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.environ.get("TMPDIR", os.path.expanduser(
    "~/compartilhado/tmp")), "sm_pd0_net")
os.makedirs(out, exist_ok=True)
base = os.path.join(out, "p32")
subprocess.run(["pdftoppm", "-f", "32", "-l", "32", "-r", "400", "-png", pdf, base], check=True)
im = Image.open(base + "-32.png")
for name, box in (("pd0_pins", (2500, 1500, 3100, 2700)), ("pd0_cross", (2450, 1280, 2950, 1900)),
                  ("pd0_labels", (1550, 1250, 2750, 1900))):
    im.crop(box).save(os.path.join(out, name + ".png"))
    print(os.path.join(out, name + ".png"))
