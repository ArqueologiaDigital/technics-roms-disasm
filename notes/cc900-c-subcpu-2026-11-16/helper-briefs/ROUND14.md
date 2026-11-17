# Round 14 for lane_sub's helpers: apply the three idioms to near misses (read BRIEF.md first; it still holds)

Updates to BRIEF.md: `calr` callees are checkable now: name them in a comment line `/* cc900-module: Label */` (one
per line) and declare them; see v142/subcpu/cc900/*.c for many examples.  The best existing C of each function is
the file named in the "attempt" column below (scripts/analysis/cc900/corpus/firmware/<stem>.c); START FROM IT and
change only what the idiom needs, so the verdict tells what the idiom did.

OWNER'S RULE (strict): `rm` only as its own standalone Bash call, with a literal absolute path, after looking at the
target, one path per call; never rm / rmdir / find -delete / os.remove / shutil.rmtree inside a heredoc, `bash -c`,
`python -c`, a loop, a `&&` / `;` chain or any inline code; avoid inline `python3 -c` / heredoc scripts generally
(write a script file under your scratch dir and run it).  If anything is denied: stop and report the exact command.

## The idioms (run 2026-11-16-99-sub-r13-idioms, all at -Xr; none of them is an -O effect)

(a) RELOAD AFTER STORE.  The ROM stores a value into a stack local and goes on using the register; V4.23 reloads it
    from the stack.  Matching C: a SECOND plain local receives the value, the kept local is assigned FROM it, and
    the next uses read the second local:  `u = P(v, 23); t = u; r = f(v, u[17]);`  (TVF_Build_Short matched this way;
    see scripts/analysis/cc900/corpus/firmware/sub_A_ia06.c).
(b) CONSTANT ARGUMENT LOADED IN ARGUMENT ORDER.  The ROM loads a constant argument early (e.g. `ld bc,0x79` before
    the other arguments are set up); V4.23 with a literal loads it last.  Matching C: pass the constant through a
    local, `unsigned int k = 0x79; ... f(tbl, k, mode, &st)` (sub_E_ib06.c).  Caveat: when a register is free the
    local may get its own register (an extra `ld de,0x78` + `ld bc,de`); then try other spellings.
(c) CHAR ARGUMENT NOT EXTENDED.  The ROM passes a byte (`ld c,(xbc+wa)`) with no `extz`; V4.23 extends it when the
    callee's parameter is unsigned char or int.  Matching C: declare the callee's parameter plain `char` (or
    `signed char`) in its prototype, pass the unsigned char expression with NO cast (sub_B_ic03.c).
(d) RETURNED POINTER COPIED (being probed in round 14, sub_F_ra*): the ROM does `ld xde,xhl; ld a,(xde)` after a
    call: the result kept in a pointer local, `p = f(...); v = *p;`.

## Your functions (notes/cc900-c-subcpu-2026-11-16/idiom_scan.tsv: bytes, first difference, idiom, run, attempt)

See the first difference: from the worktree root,
    python3 -B notes/cc900-c-subcpu-2026-11-16/first_diff.py ~/compartilhado/cc900-oracle/runs/<run>/out/v423/<set>/sub/<stem>.asm FUNCTION --cfile scripts/analysis/cc900/corpus/firmware/<stem>.c
(<set> is the part after @ in the attempt column: Xr).  It prints our bytes, the ROM's bytes and the ROM's
instructions there.  The scan's idiom guess comes from bytes only: confirm it, and if the difference is something
else, say so and try what fits.

Write 2-4 spellings per function across files sub_<TAG>_14a.c, _14b.c, _14c.c (one spelling of each function per
file; same function names in every file; a function's callees declared in every file that holds it).  Check each
file with  gcc -fsyntax-only -std=c89 -D__near= -D__tiny= -D'__asm(x)=' FILE.c
