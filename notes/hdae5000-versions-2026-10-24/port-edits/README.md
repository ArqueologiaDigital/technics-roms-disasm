# Hand edits of `hdae5000_v2_01i/`

`scripts/tools/port_hdae5000_version.py` took the v2.06i tree most of the way to v2.01i. The
scripts here are the rest: each made one hand edit to `hdae5000_v2_01i/`, and each docstring
says what it changed and why. They are kept as the record of the port. They match the exact
text the tree had at the time, so they will not apply a second time and are not part of the
build.

The order they ran in, with the tool passes between them. The hunk counts are what
`port_hdae5000_version.py status v2_01i` printed after each step.

| step | what ran                                                            | hunks left / result                       |
|------|---------------------------------------------------------------------|-------------------------------------------|
| 1    | `port_hdae5000_version.py init`, then `fix / strings / code` rounds | 1,682                                     |
| 2    | `uitables`, a `code / strings / fix` round                          | 1,067                                     |
| 3    | `00_filepanel_picture.py`                                           | 165                                       |
| 4    | `01`                                                                | 104                                       |
| 5    | `02a`, `02`                                                         | 8                                         |
| 6    | `03`                                                                | 3                                         |
| 7    | `04`                                                                | 0: byte-identical (commit `112123c41`)    |
| 8    | `farptrs`, `05` to `12`                                             | names and comments fixed, still identical |
| 9    | `hdae5000_version_stale_comments.py --fix`, `13`, `14`              | comments fixed, still identical           |
| 10   | `15` to `17`                                                        | labels fixed, still identical             |
| 11   | `18`; `port_hdae5000_version.py fix` freezes OBJ ids after uitables | two OBJ values fixed, still identical     |
| 12   | `hdae5000_version_stale_comments.py --fix` (new checks), `19`       | comments fixed, still identical           |

These committed review tools found what steps 8 to 12 fix:

- `scripts/analysis/hdae5000_version_label_check.py` lists labels that may name different code
  than in v2.06i, and suggests renames.
- `scripts/analysis/hdae5000_version_stale_comments.py` lists comments that quote a number the
  code no longer holds.
- `scripts/analysis/hdae5000_version_routine_diff.py` compares the trees routine by routine; its
  output is `../routine-diff-v2_01i.txt`.
- `scripts/analysis/hdae5000_obj_constants_check.py` checks every `HDAE5000_OBJ_*` value
  against the name table (step 11; `make gate` runs it).
