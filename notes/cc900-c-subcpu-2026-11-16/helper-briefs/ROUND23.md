# Round 23 for lane_sub's helpers (2026-11-19, the C work resumed again)

Read first, in this order, all in the worktree /home/fsanches/compartilhado/disasm-lanes/csub unless absolute:
1. notes/cc900-compat-plan-2026-11-08/c-lanes-brief-2026-11-18.txt -- the owner's rules for every lane and helper,
   in full.  They are STRICT and override anything older: no heredocs, no inline scripts (`python -c`, `bash -c`),
   `rm` only as its own call with one literal absolute path (better: delete nothing), $TMPDIR is
   /home/fsanches/compartilhado/tmp, never /tmp, `command grep` for recursive searches.  As a helper you do NOT run
   the VM, `make`, or any git command that changes state; you write probe C and report.  If a tool call is denied,
   stop that step and report the exact command; never route around it.
2. notes/cc900-c-subcpu-2026-11-16/helper-briefs/BRIEF.md, then ROUND14.md, ROUND16.md .. ROUND21.md in that
   directory (the idioms and the floating-point rules; all still hold).  ROUND20.md's tool list holds too.
3. notes/cc900-c-subcpu-2026-11-16/HANDOFF-2026-11-18.md and HANDOFF-2026-11-17.md (per open function: the best
   attempt and what differs), and README.md's "Round 21's lessons".

State: 525 functions per tree are built from C (v142/subcpu/cc900/*.c are all matching examples).
`python3 -B notes/cc900-c-subcpu-2026-11-16/open_list.py` names each open function's best run and probe stem; that
listing is ~/compartilhado/cc900-oracle/runs/<run>/out/v423/Xr/sub/<stem>.asm and its C
scripts/analysis/cc900/corpus/firmware/<stem>.c.  Listings are Toshiba output: never copy their text into a
repository file or your report; describe in prose.

Rules learnt that are easy to miss:
- A function whose ROM calls a callee with `calr` needs that callee on a `/* cc900-module: A B C */` line in the
  file (the function itself and every same-module callee, also ones defined in the same file or already built);
  absolute `call`s must NOT be on it.
- `__IZ` / `__XIZ` can crash V4.23 (bug candidate 12) and lose the whole file: never use them.
- A switch that spans several labels is one C function; check a candidate's inner labels first with
  `python3 -B notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END [TABLE]`; a label that is only an inner
  case of an already built switch is not a function: skip it and say so.
- Odd-size record copies (71, 11, 295 bytes: words plus one `ldi`) are blocked; skip functions that need one.

Files: scripts/analysis/cc900/corpus/firmware/sub_<TAG>_23a.c, _23b.c, _23c.c (one spelling of each function per
file, the same function names in every file; a function's callees declared in every file that holds it).  Check each
with `bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c`.  For a function attempted before, start from its
best earlier file and change only what the next spelling needs.  Your scratch: ~/compartilhado/tmp/cc900-tab/lane_sub/<TAG>/.

Report (final message, short): files written, functions per file, per function the spelling of each form and
anything lane_sub should know; mark items with the markers in the owner's brief.
