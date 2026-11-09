# Hand-written probe corpora

Probe files that `gen_micro.py` does not generate. Each one is our own C89, written for a research-scratch fit and
copied here so the ledger (`model/ledger.sh`) can score the model against its oracle run.

| file     | question it answers                                                                                                                      | oracle run                       | fit (research-scratch)                 |
|----------|------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|----------------------------------------|
| `fpp1.c` | where V4.23 puts double temporaries when calls, arguments and operations compete for frame slots (E2); which free op slot it reuses (E3) | `2026-11-09-18-micro-fpprepass`  | `sessions/2026-11-09_cc900-fp-prepass` |
| `fpp2.c` | the same, second round (statement order, parity, long temporaries)                                                                       | `2026-11-09-19-micro-fpprepass2` | `sessions/2026-11-09_cc900-fp-prepass` |

Score one with (from `scripts/analysis/cc900`; the listing directory and `--opt` are given explicitly):

    python3 -I -B model/score.py ~/compartilhado/cc900-oracle/runs/2026-11-09-18-micro-fpprepass/out/v423/O3XS/micro corpus/probes/fpp1.c --opt O3XS
