# cc900-compat evidence tools

Tools for the plan in `notes/cc900-compat-plan-2026-11-08/PLAN.md`: imitating, in our TLCS-900 LLVM backend, the
cc900 that Technics used (personality `kn5000`), and the three dev-kit compilers as by-products.  Toshiba's programs
run only in the oracle VM.  Their outputs live only in the private repository `~/compartilhado/cc900-oracle`, never
here; this directory holds our scripts, our own C test files and results that contain no Toshiba output.

| path                    | what question it answers / how to run                                                                                                                                                                                                 |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `oracle/run_oracle.sh`  | what does cc900 version X produce for this C, at these options?  `oracle/run_oracle.sh NAME CORPUS_DIR SOURCES OPTIONS v423 [ide2003] [v110]`; files the run under `~/compartilhado/cc900-oracle/runs/` and prints the commit command |
| `oracle/job.sh`         | the guest side (runs only in the VM): Wine, `cc900 -S`, then `asm900`                                                                                                                                                                 |
| `oracle/httpd.py`       | the guest's only channel to the host                                                                                                                                                                                                  |
| `oracle/compilers.conf` | the compiler names and their install trees in `upstream_repos`                                                                                                                                                                        |
| `corpus/abi/*.c`        | ABI probes, one question per file (the question is the file's first comment); `corpus/abi-sources.txt`, `corpus/options-abi.txt` (cdecl), `corpus/options-adecl.txt` (`-Xr`)                                                          |
| `pairs.py`              | which runtime routines compiled from C have a known copy in our images?  `python3 -I -B pairs.py > results/pairs.tsv`                                                                                                                 |
| `pairs_check.py`        | does a set of objects reproduce the firmware at those pairs?  `python3 -I -B pairs_check.py results/pairs.tsv OBJDIR [--tag T] [--md]`                                                                                                |
| `pairs_compare.py`      | which compilers reproduce which pairs?  `python3 -I -B pairs_compare.py v423=A.tsv ide2003=B.tsv v110=C.tsv [--md]` (A, B, C from `pairs_check.py`)                                                                                   |
| `pairs_crosscheck.py`   | does the listing path (`model/pairs_model.py --listings`) agree with `pairs_check.py` on one run?  `python3 -I -B pairs_crosscheck.py CHECK.tsv MODEL.tsv`                                                                            |
| `idiom_census.py`       | how often does each candidate rule's pattern occur in the firmware?  `python3 -I -B scripts/analysis/cc900/idiom_census.py [TREE ...]` from the repository root                                                                       |
| `compiler_diff.py`      | where do two dev-kit compilers differ on the same C?  `python3 -I -B compiler_diff.py RUN/out v423 ide2003 O3XSXr [--md]`                                                                                                             |
| `rule_on_listings.py`   | does the reload rule alone turn V4.23's library code into the 2003 / firmware code?  `python3 -I -B rule_on_listings.py RUN/out results/pairs_libsrc97_groups.md`                                                                     |
| `rule_transform.py`     | V4.23 listings with the rule applied, every other line kept, for asm900 in the VM: `python3 -I -B rule_transform.py IN_DIR OUT_DIR` (output is Toshiba-derived: scratch or cc900-oracle only)                                         |

The VM's setup is in `notes/toshiba-runtime-xref-2026-11-08/vm-compile/README.md`; the VM lives in
`~/compartilhado/cc900-oracle/vm/`.  `pairs.py` and `pairs_check.py` need the linked ELFs (`make all`) and the
Toshiba library trees in `upstream_repos` (paths in `notes/toshiba-runtime-xref-2026-11-08/xref_runtime.py`).

## Results

| file                                                          | what                                                                                                                                                                                                                      | made by                                                                                                        |
|---------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `results/pairs.tsv`                                           | 291 pairs over 14 images: 263 exact hits, 14 found through calls, 9 near matches, 5 by label (`__doprnt` = `Sprintf_Core`)                                                                                                | `pairs.py`                                                                                                     |
| `results/pairs_v423_O3XS.tsv`                                 | the baseline: plain V4.23 at `-O3 -XS -DFLOAT` reproduces 226 of the 291 pairs                                                                                                                                            | `pairs_check.py results/pairs.tsv ~/compartilhado/cc900-oracle/runs/2026-11-08-3-v423-xs/out/O3XS --tag '...'` |
| `results/pairs_libsrc97_*.tsv`                                | each dev-kit compiler on the 1997 sources (oracle run `2026-11-08-5`): V4.23 235, 2003 208, v1.10 191 of 291                                                                                                              | `pairs_check.py` on `runs/2026-11-08-5-libsrc97-O3XS/out/<compiler>/O3XS/libsrc`                               |
| `results/pairs_libsrc97_groups.md`                            | which compilers reproduce which pairs                                                                                                                                                                                     | `pairs_compare.py ... --md`                                                                                    |
| `results/idiom_census.md`                                     | the reload-after-store and djnz-loop detectors over main CPU v10, sub-CPU v142, HD-AE5000                                                                                                                                 | `idiom_census.py`, then `align_md_tables.py`                                                                   |
| `results/compiler_diff_v423_ide2003.md`                       | V4.23 against the 2003 compiler on the micro corpora at `-O3 -XS` (with and without `-Xr`): 3 of 749 functions differ                                                                                                     | `compiler_diff.py` per run and option set                                                                      |
| `results/rule_on_listings.md`                                 | the reload rule applied to every V4.23 library function (run `2026-11-08-5`): it leaves every routine the firmware shares with V4.23 unchanged and turns `_ldexp`, `_ldiv`, `_fmod`, `_strtol` into the 2003 code         | `rule_on_listings.py`                                                                                          |
| `results/pairs_v423_rule.tsv`, `results/pairs_rule_groups.md` | V4.23's library listings with the reload rule applied and assembled by asm900 (oracle run `2026-11-09-2`): 242 of the 291 pairs, everything V4.23 reproduces plus `_ldexp` and `_ldiv`; with `_ultoa` from the model, 251 | `rule_transform.py`, `oracle/run_oracle.sh`, `pairs_check.py`, `pairs_compare.py`                              |
| `results/pairs_v423_llvm_kn5000.tsv`                          | V4.23's library listings (run `2026-11-08-5`, `-O3 -XS`) through `to_llvm.py` and llvm-mc at each pair: MATCH 212 of 291                                                                                                  | `model/pairs_model.py --listings`, `make cc900-c-coverage`                                                     |
| `results/c_build_coverage.md`                                 | ROM bytes built from C per image and toolchain (V4.23, reference model, LLVM backend), firmware C and library C                                                                                                           | `c_build_coverage.py`, `make cc900-c-coverage`                                                                 |
| `results/c_build_v423_runs.tsv`                               | which V4.23 run compiled which text (SHA-256) of each firmware C file                                                                                                                                                     | `c_build_coverage.py --record-v423-run`                                                                        |

Of the baseline's 65 other pairs, 18 are `_ctype` (its compile failed under Wine in that run) and 3 are `_sbrk`, a
near match whose name the compiled object does not define as a piece of its own.  The 44 that differ come from eight
routines, repeated across image versions: `_ldiv` (4), `_ultoa` (9), `_ldexp` (3), `__doprnt` (9), `__facnv` (4),
`_vsprintf` (2), `__doform`'s data (9) and TRAP's 4-byte `__FloatErrorHandle` (4).  Those are what the `kn5000`
rules have to explain.

## One compile per round: `model/cache.py` (`CC900_CACHE`)

`score.py` (and so `ledger.sh`), `semcheck.py` and `pairs_model.py` each compile the same sources with the same options.
With the environment variable `CC900_CACHE` naming a scratch directory, `model/cache.py` keeps two things there:

- the front end's result for a C file (clang's AST built into a unit), keyed by the file, its defines and include
  directories, the convention, the clang binary and `frontend.py`: it survives edits to the model;
- the model's listings for a C file at one option set, keyed also by the code of every model module, so the working
  tree and a scratch copy with the same code share entries and any edit to the model misses.

Without the variable nothing is cached.  Delete the directory to start cold.  `cache.compile` also restarts the model's
`S<n>` constant labels at 50000 for every file, so a listing no longer depends on the files compiled before it in the
same process (`results/pairs_model_kn5000.tsv` names `_ldexp`'s constant `S50001` since then; it was `S50020`).

Measured on 2026-11-13 at c34efcf4d, 8 ledger jobs, each output compared with the one made without the cache:

| step                                                   | no cache   | cold       | warm |
|--------------------------------------------------------|------------|------------|------|
| `sh model/ledger.sh` (247 rows)                        | 2 min 48 s | 1 min 42 s | 31 s |
| `semcheck.py --ledger --library`, verdict cache full   | 1 min 14 s | not timed  | 14 s |
| `pairs_model.py` (assembling and comparing dominate)   | 40 s       | not timed  | 40 s |

The ledger's rows are identical in the three runs; the semantic check gives the same 73 DIFFERENT verdicts and the same
results table from an empty verdict cache through a warm compile cache; the pairs table differs only by that label.
The directory held 65 MB after one round.

`ledger.sh` runs `score.py` with `${CC900_PY:-python3 -I -B}`: with
`CC900_PY="python3 -I -X pycache_prefix=$TMPDIR/cc900-pyc"` the model's bytecode is kept between the rows, outside the
repository, instead of being compiled again by every process (the import takes 0.27 s without it and 0.06 s with it).
`CC900_SCORE` names another copy's `score.py`, which is how a scratch copy of the model is scored with the same rows.
Measured on 2026-11-13 at 1573202a7 with both caches warm: the 251 rows in 12 to 15 s (31 s before).

## Scores over time: `dashboard.py`

`python3 scripts/analysis/cc900/dashboard.py --serve` writes a single page to
`~/compartilhado/tmp/cc900-dashboard/index.html` and serves it on <http://localhost:8765/>: the random corpora, the
1997 library, the micro corpus, the probes and the semantic check's DIFFERENT count, one point per round -- every commit
that changed `model/` or `results/`, whether or not a score moved (a switch puts them on a real-time axis).  It reads those files out of git history (`git show <commit>:<file>`), measures nothing
itself, and its output is not committed.  Without `--serve` it only writes the file.
`.githooks/post-commit` rebuilds the page in the background after every commit that changes `model/` or `results/`, and the page reloads itself every two minutes.

## ROM bytes built from C: `c_build_coverage.py`

How many bytes of each Technics image (the twenty of data_range_census.py: sixteen KN5000, four SX-WSA1R) C gives exactly,
per toolchain: Toshiba V4.23 (its listing through `model/to_llvm.py` and our llvm-mc), the reference model, and our
LLVM backend with `-mcc900-compat` (0 until phase 3b; `llvm_backend_results()` is the hook).  It counts the phase-6
firmware C (`<tree>/cc900/*.c`, built into the image) and Toshiba's library routines (`results/pairs.tsv`, checked, not
built from C), and gives each image's size and census CODE bytes for the percentage.  The docstring defines every
column.  Run it with each phase-6 merge and each model batch, then commit the three results files:

    make cc900-c-coverage      # pairs_model.py twice (model; V4.23 listings with --listings), then c_build_coverage.py

It writes `results/c_build_coverage.md`, which the dashboard charts over commits ("ROM bytes built from C").  A
firmware C file counts for V4.23 only when `results/c_build_v423_runs.tsv` records a V4.23 listing of its exact text
(SHA-256); until then its functions are "not yet checked" and the results file lists the run needed.  To make it:

    python3 -B scripts/analysis/cc900/c_build_coverage.py --v423-corpus ~/compartilhado/tmp/<lane>/v423corpus
    # then the two commands it prints: flock .../vm/.runlock bash oracle/run_oracle.sh ..., and
    # --record-v423-run <run> <dir> once the run is filed (the oracle repo is committed by the coordinator)
