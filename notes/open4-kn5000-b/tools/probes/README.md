# Probes of sub-lane `tools` (wave 4, lane kn5000-b)

| script                    | question it answers                                                                                   | command                                                                                                    |
|---------------------------|-------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| `make_synthetic_type6.py` | does `parse_update_disc.py` identify a type-6 (HD-AE5000) disc and its payload? (no original on disk) | `python3 notes/open4-kn5000-b/tools/probes/make_synthetic_type6.py V10_DISK.img OUT.img` then `python3 scripts/analysis/parse_update_disc.py OUT.img` |

The two tools themselves are the main evidence of this sub-lane and live where tools belong:
`scripts/generators/render_ftdemo_slides.py` (kn5000-waa) and `scripts/analysis/parse_update_disc.py`
(kn5000-87m); their docstrings say what each answers and how to run it.  Expected outputs are in
`../README.md` sections 2 and 3.
