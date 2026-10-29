#!/usr/bin/env python3
# Write a dispatch-census snapshot for the WSA1 images only into a SCRATCH directory (argv[2]); prints its summary.
import importlib.util, os, sys
REPO, OUTD = sys.argv[1], sys.argv[2]
spec = importlib.util.spec_from_file_location("census", os.path.join(REPO, "scripts/analysis/dispatch_table_census/census.py"))
c = importlib.util.module_from_spec(spec); sys.argv = ["census.py"]; spec.loader.exec_module(c)
c.KEYS[:] = ["prom_a", "prom_b", "prom_c"]
os.makedirs(OUTD, exist_ok=True)
sys.argv = ["census.py", "--snapshot", OUTD]
c.main()
