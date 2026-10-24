#!/usr/bin/env python3
"""Run census.py over a subset of the images.

QUESTION IT ANSWERS
  "What does the dispatch census say for THESE images?" when the maps of the others are not built.
  census.py loops over all eleven images and needs every map; a lane that only touched WSA1 (or works
  in a worktree where the KN5000 trees' generated inputs are missing) can still measure its own images.
  The report has the same columns as `census.py --report`, restricted to the keys given.  It never
  writes a snapshot: snapshots stay whole-repository (`make dispatch-census`).

RUN (repository root; the maps come from build_maps.py with the same keys and DISPATCH_CENSUS_DIR)
  DISPATCH_CENSUS_DIR=<scratch> python3 scripts/analysis/dispatch_table_census/build_maps.py prom_a prom_b prom_c
  DISPATCH_CENSUS_DIR=<scratch> python3 scripts/analysis/dispatch_table_census/census_keys.py prom_a,prom_b,prom_c --report
  (any census.py argument except --snapshot / --compare may follow the key list)
"""
import importlib.util
import os
import sys

if len(sys.argv) < 2 or sys.argv[1].startswith("-"):
    sys.exit(__doc__)
keys = sys.argv[1].split(",")
if {"--snapshot", "--compare"} & set(sys.argv[2:]):
    sys.exit("census_keys.py: snapshots and comparisons cover every image -- use `make dispatch-census`")
spec = importlib.util.spec_from_file_location("census", os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                                                      "census.py"))
census = importlib.util.module_from_spec(spec)
spec.loader.exec_module(census)
bad = [k for k in keys if k not in census.KEYS]
if bad:
    sys.exit("census_keys.py: unknown image key(s) %s; known: %s" % (bad, ", ".join(census.KEYS)))
census.KEYS[:] = keys
sys.argv = [sys.argv[0]] + sys.argv[2:]
census.main()
