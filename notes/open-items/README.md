# Open-items register (set up 2026-10-31, lane open3/register)

The owner's goal for wave 3: *"work on all open items until nothing else is left open"*.  This directory is
where those items are tracked.

| file                    | what it is                                                                                    |
|-------------------------|-----------------------------------------------------------------------------------------------|
| `collect_open_items.py` | collects every open item from the four sources below and writes the register                  |
| `triage.json`           | the hand triage: one row per item id (status, plan or blocker, size, owner, evidence)         |
| `REGISTER.md`           | the generated register: summary counts, then one table per area                               |
| `opaque-groups.json`    | cache of the opaque-declaration groups, written by every run that does not pass `--no-census` |
| `probes/`               | the scripts behind the measurements the triage quotes (their README says what each answers)   |

## `collect_open_items.py`

**Question it answers:** what is still open in this repository, where is it written down, and what would
close it?

    python3 notes/open-items/collect_open_items.py --write      # regenerate REGISTER.md (about 70 s)
    python3 notes/open-items/collect_open_items.py --check      # exit 1 if any item has no triage row
    python3 notes/open-items/collect_open_items.py --no-census --check   # fast: reuse opaque-groups.json
    python3 notes/open-items/collect_open_items.py --dump items.json     # the collected items, for triage

It reads four sources:

| letter | source                                                      | one register row per                       |
|--------|-------------------------------------------------------------|--------------------------------------------|
| N      | open-items sections of the notes (list in the docstring)    | list item / table row / sub-heading        |
| I      | `.beads/issues.jsonl`, every issue not closed               | issue (id = the issue id)                  |
| T      | `; TODO` / `TODO(port)` comments in the git-tracked sources | (tree, first words of the marker) group    |
| O      | `census: opaque -- unknown-dump` / `-- code` declarations   | (census tree, reason with numbers removed) |

The N sections are the headings "Open", "Open questions", "Open items", "Open work", "Left open", "Still
open", "What remains", "Still unknown", "Follow-up(s)", "TODO" and their variants (the regular expression
`OPEN_HEADING`), plus the sections listed in `EXTRA_SECTIONS` (the WSA1R emulation-gap list and the
2026-10-17 "Pending work") and the repo-root CLAUDE.md "Known Disputed Interpretations".  A note item's id is
`N-` + 8 hex digits of the SHA-1 of its file and its text up to the first "resolved", so a note can mark an
item settled without changing its id.

## Statuses

| status     | meaning                                                                                       |
|------------|-----------------------------------------------------------------------------------------------|
| RESOLVED   | later work settled it; the row cites the commit or note.  The note that listed it now says so |
| ACTIONABLE | work in this repo could close it; the row gives the plan, a size and, if any, the owning lane |
| BLOCKED    | it needs what this repo cannot provide; the row names the exact blocker                       |

Sizes: S = one commit, under two hours; M = one session; L = a lane of its own.  BLOCKED blockers are one of:
an undumped chip (named), hardware access (what to measure on which instrument), a different repository
(upstream MAME, kn7000_mame, `../Mines`, `../llvm-project`) or an owner decision (the question quoted).

## Triage an item

1. `--check` lists the items with no row.  Look the item up at its `source` (file:line).
2. Add a row to `triage.json` under its id: `status`, a short `title`, and `evidence` (RESOLVED), `plan` +
   `size` (+ `owner`) (ACTIONABLE) or `blocker` (BLOCKED).  `area` overrides the default area.
3. If the item is RESOLVED and its note still lists it as open, append
   `(Resolved: <pointer>; open-items register <date>.)` to the item in the note.
4. A tracker issue is closed in `.beads/issues.jsonl` only under the repo-root CLAUDE.md "Issue Closure
   Requirements" (the website documents it; the closing comment has the summary, the pages and the caveats).
   Its close_reason names this register, so the register keeps listing it as RESOLVED.
5. `--write`, and commit `triage.json`, `REGISTER.md` and the notes together.

A note item whose text changes gets a new id: `--check` then reports it as untriaged and the old row as an
orphan; move the row to the new id.
