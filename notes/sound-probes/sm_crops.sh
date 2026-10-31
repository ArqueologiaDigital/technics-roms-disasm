#!/bin/sh
# sm_crops.sh -- cut the KN5000 service-manual regions that decide IC307's partner chip and IC303's clock.
#
# QUESTION: which wave ROM is IC307's partner, and what clocks the tone generator?  The service manual
#   (EMID971655, a scan with no text layer, 59 pages) answers both; this cuts the five regions out of it so
#   anyone can read them again.  No OCR: the crops are for eyes.
# RUN   sh notes/sound-probes/sm_crops.sh [SM.pdf] [OUTDIR]
#   SM.pdf  default ~/compartilhado/kn5000-docs/service_manual/technics_sx-kn5000.pdf (also published in
#           technics-docs/service_manual/); OUTDIR default $TMPDIR/sm-crops.  Needs poppler and ImageMagick.
# WHAT EACH CROP SHOWS (read 2026-10-31):
#   wave_rom_check.png  page I-20 (PDF page 19), test 6 "Wave ROM (IC304-307) check": "The key number
#                       indicates the Wave ROM number. (1: IC304/305, 2: IC306/307)"
#   tg_roms.png         page II-15/16 (PDF page 34), TONE GENERATOR SECTION (A): IC304 and IC306 hang on
#                       IC303's ADY bus (AY0-AY20), IC305 and IC307 on its ADX bus (AX0-AX20); all four share
#                       data RD0-RD15; CE is grounded, each chip has its own OE (pin 14)
#   noex.png            IC303's right side: NOEX0 (pin 141) -> R319 -> IC305 OE; NOEX1 (pin 143) -> R318 ->
#                       IC307 OE; NOEX2/3 (144/145) unconnected
#   noey.png            IC303's top pins: R315 on NOEY1 (pin 173), R316 on NOEY0 (pin 172); NOEY2/3 open
#   noey_route.png      their routes: R316's line drops to IC304's OE, R315's runs on to IC306's OE
#   x301.png            the crystal X301 at XI/XO (pins 45/44); the drawing prints "36.8688MHz"
#   parts_x301.png      the replacement parts list (PDF page 50), OSCILLATORS: X301 QSXG1I3386A, "33.8688MHz, CRYSTAL
#                       OSCILLATOR" = 768 x 44,100 Hz
set -e
SM=${1:-$HOME/compartilhado/kn5000-docs/service_manual/technics_sx-kn5000.pdf}
OUT=${2:-${TMPDIR:-$HOME/compartilhado/tmp}/sm-crops}
mkdir -p "$OUT"
pdftoppm -r 200 -png -f 19 -l 19 "$SM" "$OUT/p"
convert "$OUT/p-19.png" -crop 1653x700+0+150 +repage "$OUT/wave_rom_check.png"
pdfimages -f 34 -l 34 "$SM" "$OUT/raw34"            # the page is one 9921x7008 1-bit scan at 600 dpi
convert "$OUT/raw34-000.pbm" -crop 2900x3700+6700+1250 +repage -resize 1300x "$OUT/tg_roms.png"
convert "$OUT/raw34-000.pbm" -crop 1500x2400+6700+2300 +repage -resize 1000x "$OUT/noex.png"
convert "$OUT/raw34-000.pbm" -crop 700x900+6050+1700 +repage "$OUT/noey.png"
convert "$OUT/raw34-000.pbm" -crop 4600x500+4900+1500 +repage -resize 2300x "$OUT/noey_route.png"
convert "$OUT/raw34-000.pbm" -crop 900x700+3900+4100 +repage "$OUT/x301.png"
pdftoppm -r 250 -png -f 50 -l 50 "$SM" "$OUT/q"
convert "$OUT/q-50.png" -crop 1044x450+0+1150 +repage "$OUT/parts_x301.png"
echo "crops in $OUT"
