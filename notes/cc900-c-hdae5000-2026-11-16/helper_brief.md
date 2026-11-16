# Brief for lane_hd's C-drafting helpers (HD-AE5000, cc900 phase 6)

You draft C that Toshiba cc900 V4.23 should compile to the exact ROM bytes of HD-AE5000 v2.06i functions.
Worktree: /home/fsanches/compartilhado/disasm-lanes/chd (branch cc900/c-hdae5000).  You do NOT run the oracle VM,
do NOT commit, do NOT edit any file except the probe files your prompt names.  lane_hd checks and runs your C.

## Tools
- Hand source of a function, as the survey delimits it:
  `python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py --body LABEL --comments`
- ROM: original_ROMs/hd-ae5000_v2_06i.ic4 (base 0x280000); addresses: symbols/hdae5000_symbols_reference.txt;
  RAM names: `.equ HDAE5000_RAM_*` in hdae5000/hd-ae5000_v2_06i.s; MAME unidasm: ../tools/unidasm.
- How V4.23 compiled earlier C, for learning only (never copy its output into any file):
  `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --show ~/compartilhado/cc900-oracle/runs/2026-11-16-49-hd-r3 FUNC 2>/dev/null`
  (runs 44, 46, 48, 49 hold rounds 1-3; the C is notes/cc900-c-hdae5000-2026-11-16/probes/hd_r*.c).
- Syntax check: `gcc -fsyntax-only -std=c89 -w -D__cdecl= -D__near= -D__tiny= -I hdae5000/cc900-staged FILE.c`

## What is known (runs 44-49)
- Options `-Xr` WITHOUT -O.  Statements compile one by one, no CSE: the hand source recomputes an index for every
  statement because the C wrote the expression again.  Register arguments XWA, XBC, XDE in order (A / WA / XWA by
  width: char / int = 16-bit / long and pointers); more arguments on the stack, popped by the callee.  Results in
  L / HL / XHL.  In leaf functions locals go into free registers (XHL, XBC, DE seen); a value live across a call goes
  to XIZ/IZ (pushed) or a stack slot.  A char parameter used after a call is stored to the stack (`dec 2,xsp;
  ld (xsp),a`).
- Main-CPU calls: `#include "hdae_ws.h"` (hdae5000/cc900-staged/).  The tables are structs of `void *` members, and
  EVERY call goes through a cast: `CALLV(ROOT->SendEvent)(obj, ev, arg);` and `x = CALLR(int, HAMA->ref_sem_X)(1);`.
  A direct member call gives lda+ld where the ROM has one ld (run 48).  V4.23 evaluates the non-constant arguments
  first, then loads the function pointer, then the constant arguments: that matches the ROM.
  Pass 32-bit values (`-1L`, `0x01c00014L`, ids from hdae_ids.h) where the ROM loads XWA/XBC/XDE, ints where it
  loads WA/BC/DE.
- `#include "hdae_ids.h"`: EVT_*/NAKA_*/TITLE_* event codes and UI object ids as OBJ_<name> (the tree's
  HDAE5000_OBJ_<name>); ids missing there (names over 31 characters) are written as numbers.
- `switch` compares the cases in REVERSE SOURCE order (not by value) and lays out the bodies in source order; the
  first source case is the one whose compare is inverted to fall into its body (AttenCpToHDSwCatch, run 49;
  HD_GetBlockInfo matched).
- Loops: `for (i = 0; i < n; i++)` keeps its entry test (`ld ix,0; cp ix,4; jr nc,...` even with constants), and
  the test is repeated at the bottom.  `while (cond) body;` with a call in cond compiles to `jr` to the test at the
  bottom (YieldUntilSem1Zero matched).  A do-while has only the bottom test.  Unsigned compares give c/nc/ugt/ule,
  signed lt/ge/gt/le: pick the types from the branch conditions.
- RAM objects: an `extern` gives `lda xR,(sym:24)` / `ld (sym:24),..` operands; use the tree's name
  (`extern unsigned char HDAE5000_RAM_FlsSeqStopPending;`), or `ram_<hex>` for a cell with no name.  A ROM label
  (strings, tables) is an `extern` too, by its tree name; a name over 31 characters is fine (cc900 cuts it, and the
  checker maps it back) as long as its first 31 characters are unique.
- Library routines (HDAE5000_StrCpy, _StrLen, _StrCat, _StrNCpy, _MemCopy, _MemFill, _SPrintf, _LToA ...) take
  STACK arguments and the caller pops: declare `__cdecl`, e.g. `extern void *__cdecl HDAE5000_MemCopy(void *,
  const void *, unsigned int);`.  A long multiply is the library's `call HDAE5000_Multiply` (C9H_mullu), emitted
  by V4.23 itself: just multiply in C.  A constant address pushed as an argument shows as `pushw X@hi16 / pushw
  X@lo16`: that is how V4.23 pushes a 32-bit constant.
- Calls: `calr` = a function in the SAME C file (asm900 shortens `cal` to calr there); `call` = another file or the
  library.  So your file holds exactly the functions of one calr group (your prompt lists it); declare everything
  else `extern` with a prototype from its register use (read its header comment).  Order the functions in the file
  in ROM address order.
- SOLVED (run 52): the ROM's `lda xR,(sym+N:24)` after an index comes from an INTEGER address:
  `*(T *)((unsigned long)&sym[N] + index)`.  Every pointer spelling folds N into the index instead.
- `ld xR, sym` (immediate) after an index: `&arr[i]` (unsigned index) passed as a call ARGUMENT gives it; the same
  address returned or assigned gives `lda` (helper h_small, runs 49 and micro tests).  A returned base with `ld` is
  still unsolved (DirName_Address).
- A function whose calr targets are in your file matches only with them there: the checker models asm900's
  shortening (`--calr`), and asm900's own object shows the calr (run 56).
- A CONVERSION on an argument (a cast, a `const` qualifier, `unsigned char *` to `const void *`, an unsigned field
  to an `int` parameter) makes V4.23 evaluate it early (`lda xwa,(sym); ld xde,xwa`, or a stack temporary) and
  reload/convert (`ld wa,hl; cp wa,..`); without one it is loaded late or pushed as a constant (helper h_near,
  runs 57-66: LoadSong_Md, SaveSong_*, AttenCp* matched that way).
- Module-local calls: a C file lists the labels its functions call RELATIVELY in the ROM (calr / jr to another
  routine) in a comment `cc900-module: Label1 Label2 ...` (the build's rule, lane_vmb); only those become calr.
  Put that comment in your file's header for every calr target the hand source shows.
- V4.23 puts switch jump tables and initialised local arrays into its own data (S50000, S1); the checker masks
  those operands and reports `MATCH sdata:<n>`, so write such C naturally.
- Old-style (K&R) definitions take char parameters in A / C where the caller loads WA / BC (helper h_lyr).
- Code that is plainly hand assembly (nop padding, `ei`, `push sr`, register juggling no compiler does, data
  between instructions) is left out: list it with the reason.
- Names: the C function name is the tree label exactly; over 31 characters, write a short C name and a comment
  `cc900-name: CNAME=LABEL`.

## Your output
The probe files your prompt names, each self-contained apart from the two headers, starting with a comment saying
what it holds.  A second form (`..b.c`, same function names) only for functions where you have a real alternative.
Report: the files, the functions in each, the ones left out and why, and per function one line on what you were
unsure of.

Rules: temp files only under /home/fsanches/compartilhado/tmp/cc900-tab/lane_hd/<your helper name>/ (never /tmp);
no rm with variables or globs; `command grep` for recursive search (the .s files hold high bytes); never run the
VM; never commit; never copy Toshiba listing text into any file.
