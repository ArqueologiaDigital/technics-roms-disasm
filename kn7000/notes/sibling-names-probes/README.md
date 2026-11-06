# Probes of lane open11/sibling-names (2026-11-06)

Read-only scripts behind the figures in `../sibling-names/README.md`.  They read the committed
generated sources and symbol files (or, with `--rev`, those of a commit) and, where they decode
code, the git-ignored reference images (`make -C <model> baserom`, `make -C kn7000 baserom`) and
MAME's unidasm (`--unidasm`, default `/home/fsanches/compartilhado/mame-sony-video/unidasm`).
Run from the repo root.

| probe                    | question it answers                                                                                                                         | command                                                                                                         |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| `sibling_name_census.py` | how many entries of each sibling source are still `func_<ADDR>`, and how many RAM operands (work RAM, uncached view, backup SRAM) are numbers | `python3 -I kn7000/notes/sibling-names-probes/sibling_name_census.py`                                           |
| `kn7000_names_missed.py` | why a KN7000 941 routine name does not reach a sibling that has a routine with the same body (twins, short bodies, changed code)             | `python3 -I kn7000/notes/sibling-names-probes/kn7000_names_missed.py kn6000 [--rev REV] [--cache DIR]`          |

Outputs kept here, with the commit they measure:

| file                     | what                                                                                    |
|--------------------------|-----------------------------------------------------------------------------------------|
| `census-2bde950fa.txt`   | `sibling_name_census.py` at the lane's base, 2bde950fa                                   |
| `census-after.txt`       | the same after the lane's regeneration (the commit that adds it)                        |
| `missed-2bde950fa.txt`   | `kn7000_names_missed.py <model> --rev 2bde950fa` for KN6000, KN6500, KN2400 (+ TG library) |
| `missed-after.txt`       | the same on the regenerated tree                                                        |

The signal `sibling_name_census.py` reads: in `<model>/src/program.s`, every 8-digit hex literal
of an instruction line's operands (comment dropped) whose top byte is 0x50 (work RAM), 0x90 (its
uncached view) or 0x84 (battery SRAM) is one numeric RAM operand; a name or `name+N` is not.  The
KN2400's RAM-linked code (0x50120000..0x5018DFFA, 0x5018FFF0..2) is counted apart.  The entry
counts are gen_image_s.py's own (`notes/conversion-stats.txt`, line `entries`; its `func_` figure
counts routine starts and their `func_<ADDR>_entry` register-save entries) and the labels of
`program.s`.  The 2026-11-02 RAM figures of the READMEs (19,019 / 19,055 / 22,483) came from a
script nobody committed and are not reproduced by this one: the figures from 2026-11-06 on are
this probe's.
