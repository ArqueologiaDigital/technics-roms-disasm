# Brief for lane_sub's C-drafting helpers (cc900 C for the KN5000 sub-CPU payload v1.42)

OWNER'S RULE, STRICT (every violation is rejected).  Simplest: DO NOT DELETE ANYTHING; leave cleanup to lane_sub.
- `rm` only as its own standalone Bash call with one literal absolute path, after looking at the target;
- never rm / rmdir / find -delete / shutil.rmtree / os.remove inside a heredoc, bash -c, python -c, a loop, or an
  `&&` / `;` chain;
- no inline scripts; edits through the Edit tool; `git rm -- <explicit paths>` as its own command.
- NO heredocs at all (`<<EOF`), for any purpose: write the text to a file with the Write tool and pass the file.
  No `sed -i` that deletes lines: use the Edit tool.
- NO nested command substitution or arithmetic in commands (`$(...)`, `$((...))`, backticks), e.g.
  `unidasm ... -skip $((0x$(grep ...) - 0xf000))`.  Look the value up in one plain command, read it, and type the
  literal number into the next; or use the committed scripts (first_diff.py, bin/show.py), which look it up inside.
If a command is denied: stop, report the exact command to lane_sub, never retry it another way.

GOAL. Write C for functions of the KN5000 sub-CPU payload (TLCS-900, tree v142/subcpu) such that Toshiba's cc900
V4.23, run by lane_sub in a VM, gives exactly the ROM's bytes.  You write guesses; lane_sub batches all helpers'
files into one V4.23 run and sends you the verdicts (MATCH / DIFF at +N per function, file and option set).  Then
you refine the misses and take new functions.

WHERE.  Worktree /home/fsanches/compartilhado/disasm-lanes/csub (branch cc900/c-subcpu-hdae).  You may only CREATE
files scripts/analysis/cc900/corpus/firmware/sub_<TAG>_<r><form>.c (TAG given in your prompt, r = round number,
form = a / b / c: e.g. sub_A_2a.c, sub_A_2b.c).  Same function names in every form of a round.  Do not edit any
other repo file; never run git commands that change state (no add, commit, stash, checkout, reset); never run
`make`; never start the VM or run_oracle.sh.  lane_sub commits your files.
Scratch: ~/compartilhado/tmp/cc900-tab/lane_sub/<TAG>/ (TMPDIR is ~/compartilhado/tmp; never /tmp).  Deletions:
one literal absolute path per rm, never a variable or a glob.  Use `command grep` for recursive searches (the
plain grep wrapper skips files with high bytes).

INPUT.  notes/cc900-c-subcpu-2026-11-16/pools/pool_<TAG>.txt in the worktree: bytes, instructions, label, hand
source (under v142/subcpu/), kind (leaf / abs = calls only through absolute `call`), erp / nop counts, runtime
routines called.  Largest first.  To see one routine's source and ROM bytes:
    python3 ~/compartilhado/tmp/cc900-tab/lane_sub/bin/show.py LABEL [LABEL ...]
The ROM is original_ROMs/kn5000_subprogram_v142.rom: ROM offset = address - 0xf000 + 0x100.  Addresses of labels:
symbols/subcpu_symbols_reference.txt.  MAME's disassembler: ~/compartilhado/tools/unidasm (-arch tlcs900).

WHAT IS KNOWN (lane_sub round 1, run 2026-11-16-43-sub-r1: 24 of 31 small leaf functions matched):
- The payload was compiled with `-Xr` and WITHOUT -O (unoptimised: jumps to a common `ld hl,wa; ret` tail,
  values reloaded from memory, loop tests copied to the loop entry).  Every probe is still compiled at -Xr,
  -O3 -Xr and -O3 -XS -Xr; a function counts when the -Xr listing matches.
- ABI (-Xr): 1st argument in A / WA / XWA by size, 2nd in C / BC / XBC, 3rd in E / DE / XDE, further ones on the
  stack (the callee pops with `retd N`); result in L / HL / XHL.  int is 16 bits, long and pointers 32, plain
  char SIGNED.  `extz wa` after entry = an unsigned char argument promoted; `exts wa` = a signed char.
- Operand widths come from declarations, never from the address: a plain `extern` gives a 24-bit absolute operand
  (`(...:24)`), `__near` 16-bit (`(N:16)`), `__tiny` 8-bit (`(N:8)`).  __near / __tiny apply to the FIRST
  declarator only: one declaration per name.  Example: `ld (10215:16), wa` -> `extern int __near ram_27e7;`.
- Names: a label of the symbols reference may be used by its name (`extern unsigned char Detune_Scale_Curve[];`).
  A RAM cell is `ram_<lower-case hex address>`.  The source spells many cells `Payload_Bss_Start+0xNNNN`:
  Payload_Bss_Start is 0x3ee76, so `(Payload_Bss_Start+0x24d7:24)` is `extern unsigned char ram_4134d;`.  Named
  `.equ`s that are expressions (Part_Record_Base 0x41368, Part_PresentWord 0x4136a, Part_PatchRecord_Ptr 0x4136e,
  Voice_GlobalFlags 0x41343, ToneGen_StagingBlock 0x451cc, ToneGen_RegAddrLatch 0x100000, ToneGen_RegDataPort
  0x100002) must be written as ram_<hex>; SFRs like P6 (0x18) as `extern unsigned char __tiny ram_18;` (check the
  value in v142/subcpu/shared/sfr_tmp94c241.s).  Constant addresses may also be written as casts
  (`*(struct st *)0x45ca`).  cc900 keeps 31 characters of a name; a function whose label is longer may get a
  shorter C name with a comment `/* cc900-name: SHORT=FullLabel */` right before it.
- Idioms that matched: `if (b > a) a = b; return a;` (max through the parameter); clamps written
  `if (a > hi) a = hi; else if (a < lo) a = lo; return a;`; `if (a & 1) return 1; return 0;`; struct members at
  fixed offsets via `struct s { char pad[66]; int a; int b; };`; `ram_41376[part * 0x11f] = v;` (the 287-byte part
  records are indexed as a char array: base register + index); `for (i = 0; i < n; i++) *d++ = *s++;`;
  `return ((v * v) >> 2) + 0x3f;` with unsigned v.  Struct assignment compiles to `ldirw`.
- Misses still open (do not repeat blindly): an int field of a 287-byte record OR-ed in place (`orw (xbc+wa)`):
  V4.23 put the base in XWA, the ROM has it in XBC; `ld a,(xbc+wa); extz wa; ld hl,wa` (the ROM loads the table byte
  into the PARAMETER's register: try `a = T[a]; return a;`); an index computed as `extz wa; add wa,12` (V4.23 did the
  add in 8 bits before extending: try an int/unsigned int local or cast).
- SKIP for now: routines that call through `calr` (same-module calls; not checkable yet), routines whose "runtime"
  column names FP_* / Math_* / Int_* routines (long multiply / divide and float helpers: the name map is not ready),
  memory-to-memory moves, ei / di / ldc / swi / reti, computed jumps through code tables you cannot express.
  `nop` runs inside tone-generator writers may be inline assembly: try `__asm("nop");` in ONE form only.
- ANSI C89 only: /* */ comments, declarations at block start.  A file that fails to compile loses all its
  functions, so keep each file clean; check it with
      gcc -fsyntax-only -std=c89 -D__near= -D__tiny= -D'__asm(x)=' FILE.c
- Prefer functions of 15..200 bytes; do a handful of larger ones too.  Aim at 25-40 functions per round.
  Signedness, char vs int, the order of tests, early `return`, temporaries and parameter reuse change V4.23's
  register choice: when unsure, put alternatives in forms b / c.
- Look at what matched: scripts/analysis/cc900/corpus/firmware/sub_1a.c / sub_1b.c and the main CPU's
  v10/maincpu/cc900/*.c, v10/maincpu/cc900-staged/*.c.  notes/cc900-phase6-2026-11-16/README.md (in
  /home/fsanches/compartilhado/disasm-lanes/phase6) holds the main CPU's lessons (read-only).

AFTER A RUN lane_sub tells you the run directory ~/compartilhado/cc900-oracle/runs/<run>/ and your verdict file.
You may read V4.23's listing there (out/v423/Xr/sub/sub_<TAG>_<r><form>.asm) to see why a function differs, and
re-check one file yourself (from the worktree root):
    python3 -B notes/cc900-c-subcpu-2026-11-16/sub_v423.py one <listing.asm> --cfile <your C>
The listings are Toshiba output: NEVER copy their text into a repo file or into your report; describe in prose.

REPORT (your final message, short): the files you wrote, the number of functions per file, and per function
anything lane_sub should know (e.g. "skipped: calr").  If you see what an address-named label does, propose a
name.  No code dumps.  If a tool call is denied, stop and report the exact command.
