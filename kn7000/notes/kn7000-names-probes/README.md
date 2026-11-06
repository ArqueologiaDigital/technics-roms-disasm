# Probes of lane kn7000-names (2026-11-06)

Read-only scripts behind the figures in `../kn7000-names/README.md` and the notes it names.  Each
script's docstring says what question it answers, which signal it reads, what it printed on
2026-11-06 and how to run it.  They read only the git-ignored reference images (`baserom/`), the
generated sources and the symbol files.

| probe                        | question it answers                                                                               | run from  | answer in                        |
|------------------------------|---------------------------------------------------------------------------------------------------|-----------|----------------------------------|
| `names_reset_sp_check.py`    | does each build's INITIAL_SP / BootStack equal the stack top its reset code loads (exit 1 if not) | `kn7000/` | `../kn7000-names/README.md`      |
| `names_sd_frames.py`         | are 941's .data bytes at 0x50007E94 IC18's SdFrameR2Cmd* frames, and how do they split            | `kn7000/` | `../kn7000-names/README.md`      |
| `names_choice_func_lists.py` | KN2400 FilePriorityFunc = KN7000 SdcPanelSwAsFunc by body: what choice list does each one show    | repo root | `../sibling-name-port/README.md` |
| `names_kn2400_titles.py`     | which KN2400 title ids TitleNameTable names that gui_ids.inc does not                             | repo root | `../kn7000-names/README.md`      |

`names_choice_func_lists.py` needs `UNIDASM=/path/to/unidasm` (MAME's; default
`/home/fsanches/compartilhado/mame-sony-video/unidasm`).  All run with `python3 -I`.
