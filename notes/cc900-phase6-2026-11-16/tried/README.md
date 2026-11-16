# Drafts of the C helpers (cc900 phase 6)

C that lane_p6's helpers wrote while preparing probe files, kept so that every attempted C is in git (lane_nmx's
near-miss index matches oracle runs to sources by SHA-256).  The probe files that went into runs are
`scripts/analysis/cc900/corpus/firmware/p6_<helper>_<round><form>.c`; these drafts are their ingredients
(`gen_*.c`: bitfield copiers generated from the hand assembly by helper D's scratch script `bfgen.py`; `*.before.c`:
helper B's round-1 files before the one-declaration-per-`__near` split).  None is built.
