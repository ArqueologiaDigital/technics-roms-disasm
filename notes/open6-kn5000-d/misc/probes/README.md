# Probes, lane open6 kn5000-d, sub-lane misc (2026-11-02)

Each script prints to stdout; the committed `.txt` beside it is the run quoted in `../README.md`.
Scratch (renders, intermediate files) goes to `$TMPDIR/open6-kn5000-d/misc/`, never into the repo.

| file                  | question it answers                                                                                                                                                                                                                         | run                                                        |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| `faj_eq_response.py`  | N-29e0f8b4: what do the FAJ board's speaker-path stages (IC4 mixing amp, IC7 "low pass filter", the four EQUALIZING gyrators IC8/IC10/IC11/IC12, IC14) do?  Exact nodal analysis from the service-manual values (in the script's `VALUES`). | `python3 faj_eq_response.py > faj_eq_response.txt` (~15 s) |
| `faj_eq_response.txt` | its output: poles / zeros (f0, Q) per stage, extrema, the 1/3-octave magnitude table                                                                                                                                                        |                                                            |
