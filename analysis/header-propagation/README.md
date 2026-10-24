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

| tree | v10 labels with a header | label present | with header, before | after pass 1 | after pass 2 | after pass 3 | without, now |
|------|--------------------------|---------------|---------------------|--------------|--------------|--------------|--------------|
| v9   | 9,610                    | 9,607         | 8,381               | 9,585        | 9,599        | 9,599        | 8            |
| v7   | 9,610                    | 9,254         | 8,101               | 8,765        | 8,929        | 8,970        | 284          |

Three automatic passes were made with `--apply`. Pass 1 compared bodies with whitespace and hex case
normalized. Pass 2 also normalized number bases and register case, split `Label: insn` lines, and
added the byte proof for spans the trees spell differently. Pass 3 worked on the review list. It
added the RAM-remap tier (below), dropped an explicit `t,` condition (`jr t, X` = `jr X`), and
matched pointers by a shared label name as well as by translate_addr.

| pass | tree | headers inserted | of them byte-proven | headers extended | addresses translated | trailing comments | in-body comment runs |
|------|------|------------------|---------------------|------------------|----------------------|-------------------|----------------------|
| 1    | v9   | 1,204            | 0                   | 85               | 0                    | 10                | 4                    |
| 1    | v7   | 664              | 0                   | 62               | 17                   | 25                | 20                   |
| 2    | v9   | 14               | 8                   | 0                | 0                    | 12                | 0                    |
| 2    | v7   | 164              | 108                 | 1                | 7                    | 161               | 9                    |
| 3    | v7   | 41               | 4                   | 0                | 0                    | 0                 | 4                    |

- **Headers extended** means the target's header was a subsequence of v10's (v10 had added to it)
  and was replaced by v10's. Nothing was removed.
- **Addresses translated** counts headers that quote a v10 ROM address and were copied with the
  target build's address. A translation is accepted only when the bytes from the nearest label
  the two builds share up to that address are the same code.
- **Byte-proven** headers sit on spans that the two trees spell differently, for example
  `.incbin` against record macros, `.long Sym` against `.byte`, or `pushw 0xff` against
  `pushw 255`. Each such span has the same length and the same bytes, and every differing pointer
  is the target's translation of v10's. Headers that talk about the source text (`.byte`,
  "spelled", "below") are refused there.
- **RAM-remap tier (pass 3, 37 of the 41 v7 headers).** A body passes when its lines pair up and
  differ only in RAM operands. Those are literal numbers below 0x40000 that are less than 0x400
  apart (v7 keeps one region 156 bytes lower), moved `.equ` values, or call targets that are the
  same routine under another name. The bytes must differ only there and in relocated pointers.
  The header is then copied with each such RAM number rewritten to v7's. Any other 3-5-digit
  hex number in it must be spelled in the body, or the header is refused. Each port is a
  `ported-ram-remap` row in the review list, with its mapping. Calibration: three v7 headers
  that an earlier session had ported by hand (`Rhythm_DispatchNoteFromFC5A`,
  `Rhythm_StoreDispatchHelperResult`, `AccChannel_ResetCurrentState`) are exactly what the tier
  produces.
- **Calibration of the translation rule.** 336 v7 headers match v10's only after address
  translation. This lane wrote 24 of them (17 + 7). The other 312 were adapted by earlier hand
  ports, and the rule reproduces each of them exactly. To reproduce the count, run the v7 dry run
  with and without `--no-translate` and subtract the `header-already` figures. After pass 2 that
  was 8,134 - 7,798 = 336. After pass 3 it is 8,153 - 7,816 = 337.

## review-2026-10-24.tsv

These are the labels the tool would not copy. There is one row per (target, label). The columns:

| column     | meaning                                                                                                                                                                         |
|------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `target`   | `v9` or `v7`                                                                                                                                                                    |
| `label`    | the label, defined in both trees unless `reason` is `label-absent`                                                                                                              |
| `reason`   | why it was not copied (see below)                                                                                                                                               |
| `detail`   | the first difference, or the offending token                                                                                                                                    |
| `src_line` | v10 file:line of the label, at the time of the run                                                                                                                              |
| `dst_line` | target file:line of the label, at the time of the run                                                                                                                           |
| `ndiff`    | `body-differs` only: normalized code lines that differ                                                                                                                          |
| `nlines`   | `body-differs` only: normalized code lines in the longer body                                                                                                                   |
| `handport` | filled in by hand, or `scripted (RAM remap tier)` for that tier's ports. Records a port, or a decision not to port, and why. Rows with it are kept when the list is regenerated |

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
| `spelling-differs`        | a byte-proven span whose header talks about the source text, which is what differs       |
| `ported-ram-remap`        | not a refusal: ported by the RAM-remap tier; `detail` is the v10 -> v7 RAM mapping       |
| `label-absent`            | the target has no label of that name; a job for `harmonize_version_labels.py`            |
