# Validation corpus (scores only)

`random6/` .. `random8/` (gen_random.py --seed 6 / 7 / 8, the same parameters as random .. random4) and `rstmt6.c` ..
`rstmt8.c` (research-scratch gen_rstmt.py over each: 1,196 + 1,188 + 1,196 statements), for the oracle run
micro-validation678 at none, -O3 -XS, -Xr and -O3 -XS -Xr.  Adopted from the strategy observer's P10 / P11
(research-scratch sessions/2026-11-10_cc900-refusals/strategy/report-02.md): rule lanes may **score** it -- totals and
counts of statements / functions gained and lost per rule, with an aggregate-only scorer -- but never read its listings
or per-function status, so that it stays a signal they cannot fit.  Acceptance (P11): no statement and no function lost
on validation.  The blind test set stays `corpus/holdout/` (random5), which only the coordinator scores.

Oracle run: ~/compartilhado/cc900-oracle/runs/2026-11-15-3-micro-validation678 (val_agg.py's default).  Totals
(`python3 -I -B val_agg.py model`):

| batch | functions exact none / O3XS / Xr / O3XSXr of 600 | statements exact none / O3XS / Xr / O3XSXr of 3,580 |
|-------|--------------------------------------------------|-----------------------------------------------------|
| 340   | 93 / 46 / 77 / 40                                | 2,730 / 2,538 / 2,610 / 2,493                       |
