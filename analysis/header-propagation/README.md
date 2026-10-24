# v10 header comments in v9 and v7

The KN5000 documentation passes mostly worked in `v10/maincpu`. CLAUDE.md's multi-version sync
policy wants the same comment on the same code in every version. This folder holds the evidence
of carrying v10's header blocks to `v9/maincpu` and `v7/maincpu`.

The tool is `scripts/tools/propagate_v10_headers.py`. Its docstring gives the rules a comment
must pass before it is copied: equal body text, equal ROM bytes except for relocated addresses,
and header text that holds for the target build.

## Commands

| question                                                      | command                                                         |
|---------------------------------------------------------------|-----------------------------------------------------------------|
| How many v10 labels with a header have one in v9 / v7?        | `python3 scripts/tools/propagate_v10_headers.py --count`        |
| What would be copied, and what goes to review? (dry run)      | `python3 scripts/tools/propagate_v10_headers.py`                |
| Copy, then write the review list                              | `python3 scripts/tools/propagate_v10_headers.py --apply`        |
| Did the edit only add comments? (code lines and old comments) | `python3 scripts/tools/propagate_v10_headers.py --verify HEAD`  |
| Did any byte move?                                            | `make -j3 gate`                                                 |
| Calibrate address translation (dry run)                       | `python3 scripts/tools/propagate_v10_headers.py --no-translate` |

The dry run and `--apply` read the linked ELFs in `rebuilt_ROMs/`, so run `make all` first.

## Measured 2026-10-24

`--count`. A label is counted when the line directly above it is a `;` comment line.

| tree | v10 labels with a header | label present | with header, before | with header, after | without, after |
|------|--------------------------|---------------|---------------------|--------------------|----------------|
| v9   | 9,610                    | 9,607         | 8,381               | 9,585              | 22             |
| v7   | 9,610                    | 9,254         | 8,101               | 8,765              | 489            |

The automatic pass (`--apply`) made these changes:

| tree | headers inserted | headers extended | addresses translated | trailing comments | in-body comment runs |
|------|------------------|------------------|----------------------|-------------------|----------------------|
| v9   | 1,204            | 85               | 0                    | 10                | 4                    |
| v7   | 664              | 62               | 17                   | 25                | 20                   |

- **Headers extended** means the target's header was a subsequence of v10's (v10 had added to it)
  and was replaced by v10's. Nothing was removed.
- **Addresses translated** counts headers that quote a v10 ROM address and were copied with the
  target build's address. A translation is accepted only when the bytes from the nearest label
  the two builds share up to that address are the same code.
- **Calibration of the translation rule.** Before this pass, 299 v7 headers that an earlier hand
  port had adapted to v7 addresses came out identical to what the rule produces. To reproduce on
  the committed tree, run the v7 dry run with and without `--no-translate` and subtract the
  `header-already` figures: 7,812 - 7,496 = 316, which is those 299 plus this pass's 17.

## review-2026-10-24.tsv

These are the labels the tool would not copy. There is one row per (target, label). The columns:

| column     | meaning                                                                                                                   |
|------------|---------------------------------------------------------------------------------------------------------------------------|
| `target`   | `v9` or `v7`                                                                                                              |
| `label`    | the label, defined in both trees unless `reason` is `label-absent`                                                        |
| `reason`   | why it was not copied (see below)                                                                                         |
| `detail`   | the first difference, or the offending token                                                                              |
| `src_line` | v10 file:line of the label, at the time of the run                                                                        |
| `dst_line` | target file:line of the label, at the time of the run                                                                     |
| `ndiff`    | `body-differs` only: normalized code lines that differ                                                                    |
| `nlines`   | `body-differs` only: normalized code lines in the longer body                                                             |
| `handport` | filled in by hand. Records a port, or a decision not to port, and why. Rows with it are kept when the list is regenerated |

| reason                    | meaning                                                                                  |
|---------------------------|------------------------------------------------------------------------------------------|
| `body-differs`            | the code from the label to the next unrelated label differs                              |
| `bytes-differ`            | same text but different ROM bytes, e.g. an `.incbin` of a different file                 |
| `existing-header-differs` | the target already has a different header. It is kept and not duplicated                 |
| `quotes-rom-address`      | quotes a v10 ROM address whose target address could not be proved, or a literal constant |
| `quotes-source-line`      | quotes `file.s:NNNN`. Line numbers move with every edit and are never translated         |
| `mentions-version`        | names v7, v9, v10 or a version                                                           |
| `names-absent-symbol`     | names a symbol that v10 defines and the target does not                                  |
| `header-text-elsewhere`   | a long header line already occurs elsewhere in the target file                           |
| `dump-of-differing-bytes` | contains a `; \|....\|` byte dump, and the bytes differ                                  |
| `label-absent`            | the target has no label of that name; a job for `harmonize_version_labels.py`            |
