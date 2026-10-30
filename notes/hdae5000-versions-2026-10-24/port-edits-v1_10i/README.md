# Hand edits of `hdae5000_v1_10i/`

`replay.sh` rebuilds `hdae5000_v1_10i/*.s` from the finished v1.15i tree:

    notes/hdae5000-versions-2026-10-24/port-edits-v1_10i/replay.sh      # about 10 minutes

| step | what runs                                                                   | why                                                                  |
|------|-----------------------------------------------------------------------------|----------------------------------------------------------------------|
| 1    | `init --from v1_15i`, `00`                                                  | `00` empties the zero tail, so the image may grow during the port    |
| 2    | `strings`, `uitables`, `03`                                                 | v1.10i's GUI (755 objects); `03` marks object ids v1.10i lacks       |
| 3    | `04`                                                                        | language message 62 (the evaluation date) is not in v1.10i           |
| 4    | `afix`, `code --anchored`, `strings`, three rounds                          | the anchored passes                                                  |
| 5    | `../port-edits-v1_15i/` `92`, `93`, `96`-`98` with `PORT_TREE`, then `95`   | the shared clean-ups, then this tree's banner and version label      |
| 6    | `../port-edits-v1_15i/99_tail_fill.py` with `PORT_TREE`                     | the zero tail to 0x300000                                            |

`_edit.py` here loads `../port-edits-v1_15i/_edit.py` with `PORT_TREE=hdae5000_v1_10i`.
`../README.md` ("v1.10i against v1.15i") lists what differs.
