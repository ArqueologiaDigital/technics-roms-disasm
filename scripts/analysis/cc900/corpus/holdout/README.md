# Held-out corpus (blind)

`random5/` (gen_random.py --seed 5, 10 files x 20 functions, the same parameters as random .. random4) and
`rstmt5.c` (research-scratch gen_rstmt.py over random5: 1,182 functions, one statement each), compiled by the oracle
in run 2026-11-15-1-micro-holdout5 at none, -O3 -XS, -Xr and -O3 -XS -Xr.  Adopted from the strategy observer's
proposal P1 (research-scratch sessions/2026-11-10_cc900-refusals/strategy/): an honest score for programs nobody tuned
the model for.  **Blind**: no rule lane reads these listings or their per-function status; only the coordinator prints
the totals, every ~10 batches.  It is deliberately outside model/ledger.sh.

| batch | random5 none / O3XS / Xr / O3XSXr | rstmt5 none / O3XS / Xr / O3XSXr | random1-4 for comparison     |
|-------|-----------------------------------|----------------------------------|------------------------------|
| 340   | 22 / 14 / 21 / 14 of 200          | 884 / 831 / 846 / 805 of 1,182   | 221 / 137 / 181 / 124 of 800 |

## Transfer curve (P9, 2026-11-15)

The same aggregates for the model of older trees (`holdout_transfer.sh OUT '<run>/out/v423/SET/holdout/random5'
'<run>/out/v423/SET/holdout' 'corpus/holdout/random5/*.c' corpus/holdout/rstmt5.c COMMIT...`, scorer `holdout_agg.py`;
run = ~/compartilhado/cc900-oracle/runs/2026-11-15-1-micro-holdout5).  fn = exact random5 functions of 200; p = exact
rstmt5 statements of 1,182; c = of the random5 functions whose rstmt5 statements are all exact, the share that is exact.
Training p (rstmt1-4) from strategy report-02 for comparison.

| batch | tree      | fn none / O3XS / Xr / O3XSXr | p none / O3XS / Xr / O3XSXr   | c none / O3XS / Xr / O3XSXr | training p (rstmt1-4)         |
|-------|-----------|------------------------------|-------------------------------|-----------------------------|-------------------------------|
| 127   | 607ab3e1d | 16 / 6 / 12 / 5              | 0.708 / 0.602 / 0.637 / 0.574 | 0.60 / 0.56 / 0.65 / 0.57   |                               |
| 161   | 6a9a3920d | 18 / 8 / 12 / 5              | 0.713 / 0.607 / 0.638 / 0.576 | 0.63 / 0.56 / 0.65 / 0.57   | 0.761 / 0.647 / 0.648 / 0.614 |
| 228   | d9ab94e67 | 19 / 11 / 18 / 10            | 0.722 / 0.663 / 0.693 / 0.640 | 0.62 / 0.50 / 0.65 / 0.50   | 0.769 / 0.705 / 0.723 / 0.681 |
| 288   | 21dd24fa0 | 19 / 14 / 18 / 11            | 0.733 / 0.679 / 0.702 / 0.654 | 0.55 / 0.54 / 0.59 / 0.50   | 0.781 / 0.723 / 0.737 / 0.698 |
| 312   | ffd181e78 | 20 / 14 / 19 / 11            | 0.734 / 0.684 / 0.705 / 0.659 | 0.56 / 0.54 / 0.60 / 0.50   |                               |
| 339   | ca856ce52 | 22 / 14 / 21 / 14            | 0.748 / 0.703 / 0.716 / 0.681 | 0.55 / 0.50 / 0.56 / 0.57   | 0.798 / 0.754 / 0.759 / 0.728 |
| 340   | 15141555f | 22 / 14 / 21 / 14            | 0.748 / 0.703 / 0.716 / 0.681 | 0.55 / 0.50 / 0.56 / 0.57   |                               |

Reading: from batch 161 on, statement rules transferred 70-95 % (161-339: none +3.5 points held out against
+3.7 in training, O3XS +9.6 / +10.7, Xr +7.8 / +11.1, O3XSXr +10.5 / +11.4); the held-out statement gap of about 5
points was already there at batch 127-161.  What did not transfer is function context: held-out c falls (none 0.63 ->
0.55, Xr 0.65 -> 0.56) while the training c stays at 0.69-0.81.  Part of that fall can be selection (harder functions
join the all-statements-exact pool as statements improve).
