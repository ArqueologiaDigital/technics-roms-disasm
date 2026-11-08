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
| `corpus/abi/*.c`        | ABI probes, one question per file (the question is the file's first comment); `corpus/abi-sources.txt`, `corpus/options-abi.txt`                                                                                                      |
| `pairs.py`              | which runtime routines compiled from C have a known copy in our images?  `python3 -I -B pairs.py > results/pairs.tsv`                                                                                                                 |
| `pairs_check.py`        | does a set of objects reproduce the firmware at those pairs?  `python3 -I -B pairs_check.py results/pairs.tsv OBJDIR [--tag T] [--md]`                                                                                                |

The VM's setup is in `notes/toshiba-runtime-xref-2026-11-08/vm-compile/README.md`; the VM lives in
`~/compartilhado/cc900-oracle/vm/`.  `pairs.py` and `pairs_check.py` need the linked ELFs (`make all`) and the
Toshiba library trees in `upstream_repos` (paths in `notes/toshiba-runtime-xref-2026-11-08/xref_runtime.py`).

## Results

| file                          | what                                                                                                                       | made by                                                                                                        |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `results/pairs.tsv`           | 291 pairs over 14 images: 263 exact hits, 14 found through calls, 9 near matches, 5 by label (`__doprnt` = `Sprintf_Core`) | `pairs.py`                                                                                                     |
| `results/pairs_v423_O3XS.tsv` | the baseline: plain V4.23 at `-O3 -XS -DFLOAT` reproduces 226 of the 291 pairs                                             | `pairs_check.py results/pairs.tsv ~/compartilhado/cc900-oracle/runs/2026-11-08-3-v423-xs/out/O3XS --tag '...'` |

Of the baseline's 65 other pairs, 18 are `_ctype` (its compile failed under Wine in that run) and 3 are `_sbrk`, a
near match whose name the compiled object does not define as a piece of its own.  The 44 that differ come from eight
routines, repeated across image versions: `_ldiv` (4), `_ultoa` (9), `_ldexp` (3), `__doprnt` (9), `__facnv` (4),
`_vsprintf` (2), `__doform`'s data (9) and TRAP's 4-byte `__FloatErrorHandle` (4).  Those are what the `kn5000`
rules have to explain.
