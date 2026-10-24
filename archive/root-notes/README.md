# Root notes from the ASL era (archived 2026-10-24)

These four files sat at the top of the repository from January / February 2026, when the
disassembly was still built with ASL.  Nothing builds from them and nothing reads them: on
2026-10-24 `command grep -rl` found no reference to any of them in the Makefile, `scripts/`,
`docs/`, `CLAUDE.md`, `README.md` or the website checkout, only mentions inside the dated
audit records listed below.  They are kept for their history, not as current documentation.
`git log --follow archive/root-notes/<file>` reaches their full history.

| file                                   | last changed            | what it was                                                                                                                    | why archived                                                                                                                                                                                                                              |
|----------------------------------------|-------------------------|--------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `audio_subsystem_renaming_proposal.md` | 2026-01-30, `f2ed62e54` | proposed semantic names for `LABEL_*` symbols of the audio subsystem                                                           | most of its names were applied long ago; the rest were never applied.  Check the unapplied ones against the code before reusing them (the repository audit lists them, e.g. `DSP_CmdHandler`, `Voice_CC_95`)                              |
| `UI_SUBSYSTEM_TODO.md`                 | 2026-01-29, `b20e596a4` | a TODO list of undisassembled code found while naming the UI subsystem                                                         | an ASL-era work list, not maintained since it was written.  The names it records live on in the source (`DISPLAY_DIRTY_FLAGS` and `DISPLAY_ENABLE_FLAG`, for example, are `.equ` constants used by `v10/maincpu/display/scoop_display.s`) |
| `LZSS_PAYLOAD_ANALYSIS.md`             | 2026-01-30, `81e728b90` | the finding that the SLIDE4K block at table data 0x8E0000 is not the sub-CPU program                                           | superseded by the LZSS section of `CLAUDE.md` and by `technics-docs/lzss-compression.md`, which carry the same finding and its later resolution                                                                                           |
| `localization_strings.asm`             | 2026-02-01, `a4dde7a10` | ASL `db` listing of the main CPU's multilingual message strings, printed by `scripts/analysis/extract_localization_strings.py` | ASL syntax, never assembled; none of its `Localization_*` labels exists in the build.  The live strings are LLVM source under other names, e.g. `MSG_ATTENTION_EN` in `v10/maincpu/ui_widgets/naka_screen_dispatch.s`                     |

Measurements behind "most applied" and the missing names: `notes/repo-audit-2026-10-24/`
(the `cruft` entry for `audio_subsystem_renaming_proposal.md`).  ⚠ That entry also says
`DISPLAY_DIRTY_FLAGS` and `DISPLAY_ENABLE_FLAG` do not exist; they do, as absolute constants
(`command grep -rnw DISPLAY_DIRTY_FLAGS v10/maincpu`), which a symbol file of `.text` labels
does not list.  An older reference to
`localization_strings.asm` at the repository root is in
`analysis/binclude-audit-2026-08-07/findings.json`; that file is a dated record and was left as
it is.

Not moved, on purpose:

- `cruft_please_ignore/` is git-ignored and was never committed, so there is nothing to move in
  the repository; it exists only as untracked files in a working checkout.
- `CHANGELOG.md` is outside this archiving task; the same audit describes it as an ASL-era
  session log.
