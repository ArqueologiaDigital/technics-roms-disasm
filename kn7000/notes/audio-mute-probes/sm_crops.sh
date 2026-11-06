#!/bin/sh
# sm_crops.sh (N-44e56012) -- question: what do the KN7000 service manual's schematics show for the
# audio mute / switch lines?  Renders, from the service manual PDF, the exact crops the README's
# trace was read from, one PNG per step, into OUTDIR (default $TMPDIR/sm-crops).  Needs pdftoppm
# (poppler) and pdftotext for the word positions.  Page numbers are the PDF's (1-based); each
# schematic diagram is printed twice (pages n and n+1 are the same sheet).
#
#   sh notes/audio-mute-probes/sm_crops.sh [PDF] [OUTDIR]
#
# PDF default: ~/compartilhado/KN7000/service_manual/technics_sx-kn7000_keyboard.pdf (ORDER NO.
# EMID0207013C0, 160 pages).  Coordinates are PDF points (1/72 inch) of the 1191 x 842 page.
set -eu
PDF=${1:-$HOME/compartilhado/KN7000/service_manual/technics_sx-kn7000_keyboard.pdf}
OUT=${2:-${TMPDIR:-$HOME/compartilhado/tmp}/sm-crops}
mkdir -p "$OUT"
crop() {   # name page dpi x y w h   (x, y, w, h in points)
  pdftoppm -r "$3" -f "$2" -l "$2" -x $(($4 * $3 / 72)) -y $(($5 * $3 / 72)) \
    -W $(($6 * $3 / 72)) -H $(($7 * $3 / 72)) -png -singlefile "$PDF" "$OUT/$1"
  echo "$OUT/$1.png  (page $2)"
}
# 1. FAJ 2/2 (diagram 12): CN506 pin 1 MUTE = the +15PM rail (to ASUB CN821)
crop 1_faj_cn506_mute        122 300 850 420 341 280
# 2. FAJ 2/2: +15PM switched by Q514 (PNP) from +15A; Q516's base through R636 47K = the PMUT net (1)
crop 2_faj_pmut_switch       122 500 420 150 200 170
# 3. FAJ 1/2 (diagram 11): PMUT = CN502 pin 11, from MAIN CN301; SPSW = CN501 pin 13 (MAIN CN302)
crop 3_faj_cn502_pmut        120 300  60 270 340 170
# 4. MAIN 3/5 (diagram 6): CN301 pin 11 PMUT, CN302 pin 13 SPSW (named nets, no wire to the left)
crop 4_main_cn301_cn302      110 300 840   0 120 420
# 5. MAIN 1/5 (diagram 1): the PMUT net is bus line c; IC4 MN103002A pin labels
crop 5_main_bus_labels       100 300 100 170 320 130
# 6. MAIN 1/5: bus lines to IC4's top pins; line c -> R1 100 ohm -> pin 148 (TW210/P22), C3 0.1 uF to
#    ground; l (SD.CS) -> pin 149 P21, b (FDC.TC) -> R16 -> pin 145 P24, a (SELE.LED) -> pin 144 P25,
#    m (DSP.RST) -> pin 142 P27
crop 6_main_ic4_top_pins     100 600 460 180 200 130
crop 7_main_ic4_pin_names    100 600 540 290 120  40
# 8. MAIN 1/5 (diagram 2): IC25 74AHC174 latch, D16..D21 -> USB.WAITM, SPSW, SDMODE, DAC.ML, DAC.MC,
#    DAC.MDI (Q6..Q1), clocked through IC26 (OR)
crop 8_main_ic25_latch       102 150 600 380 591 180
# 9. MAIN 3/5 (diagram 5): bus legend k / l / m = DAC.MDI / DAC.MC / DAC.ML
crop 9_main_dac_bus_legend   108 250   0 140 260 110
# 10. MAIN 3/5 (diagram 6): IC311 D/A converter, pin 15 MUTE tied to ground; pins 12 / 13 / 14 on k / l / m
crop 10_main_ic311_dac       110 400  60 200 300 160
# 11. FAJ 1/2: SPSW -> Q511 -> gates of Q502 / Q503 (series switches between SUML / SUMR and IC506,
#     whose outputs feed the headphone amplifier IC509 and the speaker equaliser IC502 / IC503)
crop 11_faj_spsw_switch      120 150 100 380 1091 360
# 12. ASUB (diagram 14): the power-amplifier input stages biased from MUTE (+15PM) through R835 / R859 / R846
crop 12_asub_mute_bias       126 120  40 130 860 430
# 13. MAIN 5/5 (diagram 9): SDMODE (bus C) -> the SD I/F analog switches IC404 / IC412
crop 13_main_sdmode          116 150 100 520 600 280
