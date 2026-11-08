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
| `idiom_census.py`       | how often does each candidate rule's pattern occur in the firmware?  `python3 -I -B scripts/analysis/cc900/idiom_census.py [TREE ...]` from the repository root                                                                       |
| `compiler_diff.py`      | where do two dev-kit compilers differ on the same C?  `python3 -I -B compiler_diff.py RUN/out v423 ide2003 O3XSXr [--md]`                                                                                                             |

The VM's setup is in `notes/toshiba-runtime-xref-2026-11-08/vm-compile/README.md`; the VM lives in
`~/compartilhado/cc900-oracle/vm/`.  `pairs.py` and `pairs_check.py` need the linked ELFs (`make all`) and the
Toshiba library trees in `upstream_repos` (paths in `notes/toshiba-runtime-xref-2026-11-08/xref_runtime.py`).

## Results

| file                                    | what                                                                                                                       | made by                                                                                                        |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `results/pairs.tsv`                     | 291 pairs over 14 images: 263 exact hits, 14 found through calls, 9 near matches, 5 by label (`__doprnt` = `Sprintf_Core`) | `pairs.py`                                                                                                     |
| `results/pairs_v423_O3XS.tsv`           | the baseline: plain V4.23 at `-O3 -XS -DFLOAT` reproduces 226 of the 291 pairs                                             | `pairs_check.py results/pairs.tsv ~/compartilhado/cc900-oracle/runs/2026-11-08-3-v423-xs/out/O3XS --tag '...'` |
| `results/pairs_libsrc97_*.tsv`          | each dev-kit compiler on the 1997 sources (oracle run `2026-11-08-5`): V4.23 235, 2003 208, v1.10 191 of 291               | `pairs_check.py` on `runs/2026-11-08-5-libsrc97-O3XS/out/<compiler>/O3XS/libsrc`                               |
| `results/pairs_libsrc97_groups.md`      | which compilers reproduce which pairs                                                                                      | `pairs_compare.py ... --md`                                                                                    |
| `results/idiom_census.md`               | the reload-after-store and djnz-loop detectors over main CPU v10, sub-CPU v142, HD-AE5000                                  | `idiom_census.py`, then `align_md_tables.py`                                                                   |
| `results/compiler_diff_v423_ide2003.md` | V4.23 against the 2003 compiler on the micro corpora at `-O3 -XS` (with and without `-Xr`): 3 of 749 functions differ      | `compiler_diff.py` per run and option set                                                                      |

Of the baseline's 65 other pairs, 18 are `_ctype` (its compile failed under Wine in that run) and 3 are `_sbrk`, a
near match whose name the compiled object does not define as a piece of its own.  The 44 that differ come from eight
routines, repeated across image versions: `_ldiv` (4), `_ultoa` (9), `_ldexp` (3), `__doprnt` (9), `__facnv` (4),
`_vsprintf` (2), `__doform`'s data (9) and TRAP's 4-byte `__FloatErrorHandle` (4).  Those are what the `kn5000`
rules have to explain.
