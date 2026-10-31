# Hand edits of `hdae5000_v1_15i/`

`replay.sh` rebuilds `hdae5000_v1_15i/*.s` from scratch: it copies `hdae5000_v2_01i/`
(`port_hdae5000_version.py init v1_15i --from v2_01i`), then runs the scripts here and the
porting tool's passes in a fixed order.  Unlike the v2.01i port (`../port-edits/`), whose
scripts are a record that no longer applies, these are kept replayable: each matches the
text the tree has at its step of `replay.sh`, so the whole port can be re-run after a change
to `hdae5000_v2_01i/` or to the tool.  `_edit.py` holds the shared helpers (exact, counted
replacements; deleting a routine, a data block or a record by its label).


The order, and why it is that order:

| step | what runs                                                     | why here                                                                    |
|------|---------------------------------------------------------------|-----------------------------------------------------------------------------|
| 1    | `init --from v2_01i`, `00`, `01`, `02`                        | `01` turns string aliases into labels while their offsets still hold        |
| 2    | `strings`, `uitables`, `03`                                   | the GUI section from the v1.15i ROM; `03` marks object ids v1.15i lacks     |
| 3    | `04` .. `04k`, `05` .. `05f`, `06` .. `09`                    | removals before any pass, so no alignment ever pairs code v1.15i lacks      |
| 4    | `afix`, `code --anchored`, `strings`, three rounds            | the anchored passes (the tool's docstring: anchors, afix)                   |
| 5    | `10` .. `89` (now `11`, `13`), then the passes twice          | edits written against the tree the passes leave                             |
| 6    | `90` .. `99`                                                  | byte-neutral clean-ups (comments, labels, constants) and the zero tail      |

`98b_label_review.py` (2026-10-31) is the label review: it runs
`scripts/renaming/rename_hdae5000_v1_label_review.sed` and fixes the comments around the renamed
blocks.  It is not idempotent (it renames `.Lts925_1` to `.Lts925_loop`), so it runs once per tree:
here after `98`, and on v1.10i once by hand (`PORT_TREE=hdae5000_v1_10i`), never in
`../port-edits-v1_10i/replay.sh`, which starts from the fixed v1.15i tree.

What each script changes, and the evidence, is in its docstring.  `_edit.py` takes the tree
from `PORT_TREE` (default `hdae5000_v1_15i`), so `../port-edits-v1_10i/replay.sh` runs the
clean-ups 92-99 on v1.10i too.

    notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/replay.sh      # about 12 minutes
