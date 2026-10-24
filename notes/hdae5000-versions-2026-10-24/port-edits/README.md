# Hand edits of `hdae5000_v2_01i/`

`scripts/tools/port_hdae5000_version.py` took the v2.06i tree most of the way to v2.01i. The
scripts here are the rest: each made one hand edit to `hdae5000_v2_01i/`, and each docstring
says what it changed and why. They are kept as the record of the port. They match the exact
text the tree had at the time, so they will not apply a second time and are not part of the
build.

The order they ran in, with the tool passes between them:

| step | what ran                                                        | result                                     |
|------|-----------------------------------------------------------------|--------------------------------------------|
| 1    | `port_hdae5000_version.py init / fix / strings / code` (rounds) | 165 hunks left                             |
| 2    | `uitables`, then `00_filepanel_picture.py`                      | 104 hunks left                             |
| 3    | `01`, `02a`, `02`, `03`, `04`                                   | byte-identical (commit `112123c41`)        |
| 4    | `farptrs`, `05`, `06`, `07`, `08`, `09`, `10`, `11`, `12`       | names and comments fixed, still identical  |
| 5    | `hdae5000_version_stale_comments.py --fix`, `13`, `14`           | comments fixed, still identical            |

The review tools that found what steps 4 and 5 fix are committed:

- `scripts/analysis/hdae5000_version_label_check.py` lists labels that may name different code
  than in v2.06i.
- `scripts/analysis/hdae5000_version_stale_comments.py` lists comments that quote a number the
  code no longer holds.
