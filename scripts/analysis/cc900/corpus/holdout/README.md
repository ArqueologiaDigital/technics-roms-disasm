# Held-out corpus (blind)

`random5/` (gen_random.py --seed 5, 10 files x 20 functions, the same parameters as random .. random4) and
`rstmt5.c` (research-scratch gen_rstmt.py over random5: 1,182 functions, one statement each), compiled by the oracle
in run 2026-11-15-1-micro-holdout5 at none, -O3 -XS, -Xr and -O3 -XS -Xr.  Adopted from the strategy observer's
proposal P1 (research-scratch sessions/2026-11-10_cc900-refusals/strategy/): an honest score for programs nobody tuned
the model for.  **Blind**: no rule lane reads these listings or their per-function status; only the coordinator prints
the totals, every ~10 batches.  It is deliberately outside model/ledger.sh.

| batch | random5 none / O3XS / Xr / O3XSXr | rstmt5 none / O3XS / Xr / O3XSXr | random1-4 for comparison |
|-------|-----------------------------------|----------------------------------|--------------------------|
| 340   | 22 / 14 / 21 / 14 of 200          | 884 / 831 / 846 / 805 of 1,182   | 221 / 137 / 181 / 124 of 800 |
