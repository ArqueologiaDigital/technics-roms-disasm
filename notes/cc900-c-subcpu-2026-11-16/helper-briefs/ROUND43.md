# Round 43 for lane_sub's helpers (2026-11-20, the C work resumed)

RULES FIRST.  Read /home/fsanches/compartilhado/tmp/c-lanes-brief-2026-11-20.txt in full and follow it exactly: it
is the owner's binding brief for every lane and helper and replaces the 2026-11-18 brief that ROUND23.md names.  In
short: no heredocs, no inline scripts (`python3 -c`, `bash -c`, `python3 -`, not even no-op ones), `rm` only as its
own call with one literal absolute path (better: delete nothing), $TMPDIR is /home/fsanches/compartilhado/tmp, never
/tmp, `command grep` for recursive searches, no nested `$(...)` / `$((...))`.  As a helper you do NOT run the VM,
`make`, or any git command that changes state; you write probe C (and scratch generators) and report.  If a tool call
is denied, stop that step and report the exact command; never route around it.  Toshiba listings are read-only
reference: never copy their text into a repository file or your report; describe in prose.

Then read, in the worktree /home/fsanches/compartilhado/disasm-lanes/csub: `helper-briefs/BRIEF.md`, `ROUND23.md`
(reading list and rules), `ROUND39.md` (the 2026-11-19 lessons on one page), and `../HANDOFF-2026-11-19.md`.
`v142/subcpu/cc900/*.c` (592 functions per tree) are all matching examples: copy their declarations, prototypes,
cell names and `cc900-*` comment lines.

State: 592 functions per payload tree are built from C.  This round takes functions no probe has compiled yet
(`never_tried.py`) and the switches whose case bodies sit under labels of their own.

Tools (repository root):
- `python3 /home/fsanches/compartilhado/tmp/cc900-tab/lane_sub/bin/show.py LABEL` (a routine's code and bytes);
- `python3 -B notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END [TABLE]` (is a label range one function);
- `python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/idiff_full.py LISTING CFILE FUNC` (every instruction
  difference of an earlier attempt's listing; `open_list.py` names each open function's best run and stem, its
  listing is ~/compartilhado/cc900-oracle/runs/<run>/out/v423/Xr/sub/<stem>.asm);
- `helper-generators/fpconst.txt` (every FP constant of the payload with an exact C literal);
- `bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c` on every file you write.

Files: scripts/analysis/cc900/corpus/firmware/sub_<TAG>_43a.c, _43b.c, _43c.c: one spelling of each function per
file, the same function names in every file, each function's callees declared in every file that holds it.  A
scratch generator, if you write one, stays in ~/compartilhado/tmp/cc900-tab/lane_sub/<TAG>/; say its path.

Report (final message, short): files written, functions per file, per function what the three forms differ in, and
anything lane_sub should know; mark items with the markers of the owner's brief (✅ ❌ ⚠️ ⏳).
