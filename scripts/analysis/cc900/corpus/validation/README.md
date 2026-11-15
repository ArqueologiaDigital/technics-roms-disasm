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

Wrong code on validation (`sh val_sem.sh`, semcheck DIFFERENT, counts only; compiled = not refused):

| batch | random6-8 none / O3XS / Xr / O3XSXr | of compiled (approx.)  | rstmt6-8 none / O3XS / Xr / O3XSXr |
|-------|-------------------------------------|------------------------|------------------------------------|
| 342   | 16 / 14 / 8 / 8                     | 319 / 309 / 244 / 259  | 26 / 27 / 15 / 15                  |

Caveat (2026-11-15): a semcheck DIFFERENT is not always model wrong code.  The 9 verdicts left on the committed corpora
at batch 344 are all reviewed non-bugs (model/semcheck_review.tsv): reads before assignment and out-of-range indices
(undefined behaviour), functions that fall off the end without a return (semcheck compares the leftover HL), an
out-parameter slot written before it is read, and one V4.23 miscompile (rstmt2 rs_2_04_03_3 at -O3 -XS -Xr: two
equal switch arms merged so that case 2 makes no call) that the model, correct by C, does not copy.  The generated
validation programs contain the same kinds, so val_sem.sh's counts are an upper bound on wrong code.
