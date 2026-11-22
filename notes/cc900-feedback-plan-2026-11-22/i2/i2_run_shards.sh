#!/bin/bash
# Feedback plan step I2: run every shard i2_dataset.py prepared, one oracle-VM slot each, in parallel.
# usage, from technics-roms-disasm's root:  notes/cc900-feedback-plan-2026-11-22/i2/i2_run_shards.sh OUTDIR
# Each shard becomes a run of the private cc900-oracle named i2-fw-<k> (commit them there afterwards).
set -euo pipefail
OUT=${1:?OUTDIR}
HERE=notes/cc900-feedback-plan-2026-11-22/i2
for sd in "$OUT"/shard-*; do
    k=${sd##*-}
    JOB=$HERE/job_i2.sh ASMFLAGS=$HERE/dataset.txt VM_POOL_SLOTS=${VM_POOL_SLOTS:-4} \
        bash scripts/analysis/cc900/oracle/run_oracle.sh "i2-fw-$k" "$sd/corpus" "$sd/sources.txt" "$sd/options.txt" v423 \
        > "$OUT/shard-$k.log" 2>&1 &
done
wait
grep -h 'run filed' "$OUT"/shard-*.log
