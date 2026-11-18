# Probes of the near-miss index tool

Checks of `scripts/analysis/cc900/nearmiss.py` itself (no VM).  Run from the repository root.

| script            | question it answers                                                                                       | command                                                                       |
|-------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `selftest.py`     | do `pair_rows`, `untranslated_shapes` and `tool_error` do what their docstrings say (made-up inputs)?     | `python3 -B notes/cc900-c-nearmiss/probes/selftest.py` (exit 0 = all ok)      |
| `status_moves.py` | which index rows changed status between two committed index versions, and how many of each move?          | `python3 -B notes/cc900-c-nearmiss/probes/status_moves.py OLD_REV NEW_REV`    |
| `first_occ.py`    | does a tool change leave the first row of each (listing, function) of one run as a committed index has it? | `python3 -B notes/cc900-c-nearmiss/probes/first_occ.py REV INDEX.tsv RUN`     |

The `--jobs` fix (2026-11-18) was checked without a script: the same three runs indexed into three scratch output
directories, with `--jobs 1`, with the old `multiprocessing.Pool` at `--jobs 2` and with the new executor at
`--jobs 2`, then `cmp` of `index.tsv` and `README.md` and `diff -r` of `c/`: all identical.

    python3 -B scripts/analysis/cc900/nearmiss.py --runs \
        2026-11-17-22-hd-r49-ports,2026-11-17-7-sub-r18,2026-11-17-6-p6-r30-staged --out DIR_N --jobs N
