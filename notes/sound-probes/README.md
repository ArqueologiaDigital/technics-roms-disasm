# Sound probes (lane open3/sound, 2026-10-31)

The scripts behind `../sound-2026-10-31/README.md`. Run each from the repository root. The KN7000 ones read
the git-ignored reference images `kn7000/baserom/kn7000_table.rom` and `kn7000/baserom/kn7000_wave_{main,sub}.bin`
(`make -C kn7000` copies and joins them with SHA-1 checks); they print numbers only. The generator they lean
on, `kn7000/tools/wave_root_rates.py`, is the committed tool that writes `kn7000/src/wave/root_rates.tsv`.

| script                        | question it answers                                                                                                                            | run                                                     |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| `kn7000_zone_side.py`         | which TG (MAIN / SUB) a melodic zone's side bit 0x400 / 0x800 names; do all zones that play a recording agree on its tuning K                  | `python3 notes/sound-probes/kn7000_zone_side.py`        |
| `loop_period_check.py`        | does the derived period T = 2^(E - 9 + corr/3072) fit each looped recording: whole periods per loop, and the audio's autocorrelation at T      | `python3 notes/sound-probes/loop_period_check.py`       |
| `kn5000_kn7000_correction.py` | does the KN5000 table data give an IC307 recording the same pitch correction as the KN7000 gives the same recording                           | `python3 notes/sound-probes/kn5000_kn7000_correction.py` |
| `gain_law_duplicates.py`      | is any 8-bit KN7000 recording also stored as 16-bit (which would measure the 8-bit segment gain law)                                            | `python3 notes/sound-probes/gain_law_duplicates.py`     |
| `sm_crops.sh`                 | cuts the KN5000 service-manual regions that decide IC307's partner (Wave ROM check, IC303's ROM wiring and OE lines) and IC303's crystal        | `sh notes/sound-probes/sm_crops.sh [SM.pdf] [OUTDIR]`   |

## What each one read on 2026-10-31

| script                        | signal                                                                                    | result                                                                                                  |
|-------------------------------|-------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `kn7000_zone_side.py`         | zone halfword +0 & 0x0C00 against the TG whose directory has the zone's (page, entry)     | 0x400: 242 MAIN-only, 0 SUB-only; 0x800: 416 SUB-only, 0 MAIN-only. 2,662 recordings reached, 2,632 with one K |
| `loop_period_check.py`        | loop length / T within 5 % of an integer; circular autocorrelation at T vs at 2^(E - 9)    | 728 of 821 loops (wrong-pitch-class null 82); corr not whole semitones: 611 of 702 (null 74); audio 682 of 702 |
| `kn5000_kn7000_correction.py` | D = C (KN5000 SET zone, s16 at +4) - corr (KN7000 zone, s16 at +6) per IC307 selector    | 355 of 390 selectors D = 0; the 35 others are 33 drum-kit (class 5) and 2 page-0 selectors              |
| `gain_law_duplicates.py`      | 64-sample sign pattern of an 8-bit recording found in a 16-bit one, correlation > 0.8     | 548 searchable of 959; 0 copies                                                                         |
| `sm_crops.sh`                 | the crops, read by eye (the scan has no text layer)                                       | see the script's header and `../sound-2026-10-31/README.md`, "IC307's partner"                          |
