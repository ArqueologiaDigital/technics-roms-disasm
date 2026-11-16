# Training pool random9-12 (readable)

`random9/` .. `random12/` (`gen_random.py --seed 9 .. 12`, the same parameters as random .. random4 and the validation /
holdout corpora) and `probes/rstmt9.c` .. `rstmt12.c` (research-scratch gen_rstmt.py over each: 1,185 + 1,174 + 1,174 +
1,133 statements), for the oracle run micro-pool9-12 at none, -O3 -XS, -Xr and -O3 -XS -Xr.  Adopted from strategy
report 04 (R4a, research-scratch sessions/2026-11-10_cc900-refusals/strategy/report-04.md): random1-4 are exhausted and
the probes are off the random distribution (gen_random writes no float and no struct copy), so this is fresh material
from the distribution the 760/800 target measures.  Rule lanes may read it fully (listings and per-function status),
as they do random1-4; validation stays aggregate-only and holdout test-only.  P11 now reads "evidence outside the corpus
the rule came from".
