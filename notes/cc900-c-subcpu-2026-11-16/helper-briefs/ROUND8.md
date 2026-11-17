# Round 8 for lane_sub's helpers (read after BRIEF.md and ROUND3-7.md)

Round 7 ran as oracle run 2026-11-16-79-sub-r7 (listings .../runs/2026-11-16-79-sub-r7/out/v423/Xr/sub/).  Verdicts:
~/compartilhado/tmp/cc900-tab/lane_sub/r7_<TAG>.tsv.  24 of 90 matched, 2,478 B; rounds 6 and 7 are staged.

THE PAYLOAD NOW BUILDS FROM C: 239 functions per tree are in v142/v141/v140 subcpu/cc900/*.c and `make` compiles them
with V4.23; about 80 more are staged.  About 320 of the payload's routines (20 KB) have C; about 88 KB of C-like code
remains.  Your new pool: notes/cc900-c-subcpu-2026-11-16/pools/pool_<TAG>_remaining.txt (every routine of your files,
any kind, not yet in C; last column: its calr targets for the cc900-module: comment).  Helper D also takes the
core/10_dsp_voice_params.s rows of pool_C_remaining.txt (helper C keeps core/08); C, leave core/10 to D.

New facts:
- THE V4.23 CRASH IS ISOLATED: V4.23 dies when the __IZ pseudo-register is used in a function that keeps a pointer in
  memory (a one-element local array, a one-member local struct, or a parameter whose address is taken).  The same
  spellings without __IZ compile, and so does a `register` pointer local; __XIZ crashes on its own.  So: no __XIZ, and
  never __IZ together with an address-taken or array/struct local.  The tone-generator writers that keep the record
  pointer on the stack AND a register number in IZ are blocked until another spelling is found; skip them.
- Bigger functions are welcome now: the small ones are done.  Prefer routines up to ~400 B with few loops; split a
  large routine's guesses across forms rather than files.
- Unchanged: -Xr only; one __near / __tiny per declaration; 31-character names (cc900-name for a clash); cc900-module:
  lists only the ROM's calr / jr / jrl targets; long `*` / `/` / `%` calls Math_Multiply32 / Long_SignedDiv /
  Long_SignedRem; a switch that compiles to a jump table cannot be checked yet; no float / double return; no escapes in
  __ASM strings.

Round 8: files sub_<TAG>_8a.c / _8b.c (/_8c.c).  Same rules; report as before.

## Owner's rule (strict, effective now)
1. `rm` only as its own standalone Bash call, with a literal absolute path, after looking at the target; one path per call.
2. Never rm / rmdir / find -delete / rsync --delete / shutil.rmtree / os.remove inside a heredoc, a `bash -c` / `sh -c` /
   `python -c` / `python3 - <<EOF` script, a loop, a `&&` / `;` chain, or any inline code.
3. Edits to scripts or files that contain rm lines go through the Edit tool, never through an inline script.
4. Prefer `git rm -- <explicit paths>` for tracked files (you do not run git anyway).
5. Avoid inline `python3 -c` / heredoc scripts generally: write a script file with the Write tool and run it.
If anything is denied: stop, report the exact command, never retry it another way.
