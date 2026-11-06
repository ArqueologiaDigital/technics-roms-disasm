# Probes of lane open12/sibling-names2 (2026-11-06)

Read-only scripts behind the figures in `../sibling-names2/README.md`.  Run them from the repo
root.  The ones that decode code need the git-ignored reference images (`make -C <model> baserom`,
`make -C kn7000 baserom`) and MAME's unidasm (`UNIDASM`, default
`/home/fsanches/compartilhado/mame-sony-video/unidasm`).  Nothing tracked is written: the
scripts that produce files take a scratch directory first.  The census itself is wave 11's
`../sibling-names-probes/sibling_name_census.py`.

| probe                       | question it answers                                                                                                                                                | command                                                                                        |
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `name_source_trial.sh`      | how many names would `port_names_by_alignment.py` carry onto sibling B from KN7000 941, build 893 or another sibling, and how often is it wrong where both name it | `kn7000/notes/sibling-names2-probes/name_source_trial.sh SCRATCH kn6000 kn2400 [tool options]` |
| `ram_run_premise.py`        | is the RAM-runs premise true: does a voted RAM pair whose two neighbours share one delta have that delta too (by neighbour distance)                               | `python3 -I kn7000/notes/sibling-names2-probes/ram_run_premise.py kn6000 kn6500 kn2400`        |
| `ram_writer_potential.py`   | would a third RAM rule, "every store lies in one named routine", name many of the RAM addresses still spelled as numbers                                           | `python3 -I kn7000/notes/sibling-names2-probes/ram_writer_potential.py kn6000 kn6500 kn2400`   |
| `kn7000_ram_names_reach.sh` | if 941's RAM were named the way `name_ram_by_use.py` names the siblings', how many sibling RAM addresses would the RAM map name that are unnamed today             | `kn7000/notes/sibling-names2-probes/kn7000_ram_names_reach.sh SCRATCH kn6000 kn6500 kn2400`    |
| `kernel_errorhook_codes.py` | which function code (d0) and uITRON error code (d1) each MILK kernel service hands KernelErrorHook / KernelErrorHook2, and which services are still func_<ADDR>    | `python3 -I kn7000/notes/sibling-names2-probes/kernel_errorhook_codes.py kn6000 kn6500 kn2400` |
| `func_pairing.py`           | of a sibling's func_ starts, how many pair by call sites with a 941 routine 941 leaves unnamed too, and where the unpaired ones are                                | `python3 -I kn7000/notes/sibling-names2-probes/func_pairing.py kn6000 kn6500 kn2400`           |

`name_source_trial.sh`'s SOURCE is `kn7000` (exactly B's `make aligned-names`, its output seeded
with B's committed `<B>_aligned.sym`), `b893` (KN7000 v1.3 with `kn7000_b893*.sym`), or a sibling
(`kn6000` / `kn6500` / `kn2400`, with its reflection, hand, ported, aligned and MILK-function names;
B's own aligned names are then B names).  Extra arguments go to the tool: `--table-agree -1` uses
every paired table unchecked, which is how the check's need was measured.

Outputs kept here, measured on the tree of commit e5127d07d (the lane's regeneration):

| file                            | what                                                                                                                      |
|---------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `census-e53dc9b3a.txt`          | `sibling_name_census.py` at the lane's base, e53dc9b3a                                                                    |
| `census-after.txt`              | the same after the regeneration                                                                                           |
| `name-source-trials.txt`        | the reports of `name_source_trial.sh` for kn6000 / kn2400 from kn2400 / kn6000 / kn6500 / b893, and from kn7000 unchecked |
| `ram-run-premise.txt`           | `ram_run_premise.py kn6000 kn6500 kn2400`, with the exceptions                                                            |
| `ram-writer-potential.txt`      | `ram_writer_potential.py kn6000 kn6500 kn2400`                                                                            |
| `kn7000-ram-names-reach.txt`    | `kn7000_ram_names_reach.sh` (its report, then the per-model counts)                                                       |
| `kernel-errorhook-codes.txt`    | `kernel_errorhook_codes.py kn6000 kn6500 kn2400`                                                                          |
| `missed-kn2400-tglib-after.txt` | `../sibling-names-probes/kn7000_names_missed.py kn2400 --a-range 0x4C000000:0x4C03DF30 --b-range 0x50120000:0x5018E000`   |
| `func-pairing.txt`              | `func_pairing.py kn6000 kn6500 kn2400`                                                                                    |

The signals: the trial reports' lines are the tool's own (`port_names_by_alignment.py`, header
POINTERS / RUNS); a "voted" RAM pair is a row of `<model>/notes/ram-map-kn7000.tsv` whose third
column (aligned operands) is above 0, a run pair has 0 there; a numeric RAM operand is an 8-digit
hex literal with top byte 0x50 / 0x90 / 0x84 in `<model>/src/program.s`.
