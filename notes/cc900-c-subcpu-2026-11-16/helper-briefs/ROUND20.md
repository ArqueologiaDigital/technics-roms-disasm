# Round 20 for lane_sub's helpers (2026-11-18, the C work resumed)

Read first, in this order, all in the worktree /home/fsanches/compartilhado/disasm-lanes/csub unless absolute:
1. /home/fsanches/compartilhado/tmp/c-lanes-brief-2026-11-18.txt -- the owner's rules for every lane and helper.
   They are STRICT and override anything older: no heredocs, no inline scripts (`python -c`, `bash -c`), `rm` only as
   its own call with one literal absolute path (better: delete nothing), $TMPDIR is ~/compartilhado/tmp, never /tmp.
   As a helper you do NOT run the VM, `make`, or any git command that changes state; you write probe C and report.
2. notes/cc900-c-subcpu-2026-11-16/helper-briefs/BRIEF.md, then ROUND14.md, ROUND16.md, ROUND17.md, ROUND18.md and
   ROUND19.md in that directory (the idioms (a) .. (y) and the floating-point rules; all still hold).
3. notes/cc900-c-subcpu-2026-11-16/HANDOFF-2026-11-17.md: the state at the stop and, per open function, the best
   attempt and the next spelling the round-19 helpers proposed.  Your prompt names your functions.

State: 477 functions per tree (v142, v141, v140) are built from C; v142/subcpu/cc900/*.c are all matching examples.
No nested command substitution or shell arithmetic in commands (`$(...)`, `$((...))`, backticks): look a value up in
one command and type the literal into the next, or use the committed tools, which look it up themselves:
- `python3 ~/compartilhado/tmp/cc900-tab/lane_sub/bin/show.py LABEL` (hand source and ROM bytes),
- `python3 -B notes/cc900-c-subcpu-2026-11-16/first_diff.py LISTING.asm FUNCTION --cfile C` (first difference),
- `notes/cc900-c-subcpu-2026-11-16/helper-generators/idiff.py` and `ctx.py` (every difference; read their heads),
- `python3 -B notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END [TABLE]` (one function across labels?).
A listing of an earlier attempt is ~/compartilhado/cc900-oracle/runs/<run>/out/v423/Xr/sub/<stem>.asm and its C is
scripts/analysis/cc900/corpus/firmware/<stem>.c (`open_list.py` names run and stem per function).  Listings are
Toshiba output: never copy their text into a repository file or your report; describe in prose.

Files: scripts/analysis/cc900/corpus/firmware/sub_<TAG>_20a.c, _20b.c, _20c.c (one spelling of each function per
file, the same function names in every file; a function's callees declared in every file that holds it).  Check each
with `bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c`.  Start each function from its best earlier file
and change only what the next spelling needs, so the verdict says what the change did.
Report (final message, short): files written, functions per file, per function the spelling of each form and
anything lane_sub should know.  Mark items with the markers in the owner's brief.
