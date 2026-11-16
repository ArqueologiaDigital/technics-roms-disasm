# semcheck: does the model's code compute what the oracle's code computes?

`score.py` asks whether the model's listing is *textually* the oracle's.  When it is not, nothing so far asked
whether the model's code is at least *correct*.  Several wrong-code bugs were found by eye: an address register
overwritten before use, a value loaded over a live index register.  `semcheck.py` asks the behavioural question
automatically.  For every function it runs the model's code and the oracle's code in an interpreter, on the same
random inputs, and compares everything a caller could observe.

| file                     | what it is                                                                                           |
|--------------------------|------------------------------------------------------------------------------------------------------|
| `interp.py`              | interpreter for TLCS-900/H2 assembly in cc900's listing syntax (MAME's flag semantics); no encodings |
| `semcheck.py`            | the harness: ABI set-up, inputs, call stubs, runtime helpers, comparison, the ledger driver          |
| `test_interp.py`         | hand checks: the oracle's code for simple functions must give the C-level answer (no model involved) |
| `semcheck_review.tsv`    | what reading both listings showed for each DIFFERENT (wrong code, UB only, oracle narrows); no code  |
| `../results/semcheck.md` | the latest ledger run: counts per oracle row, the DIFFERENT list, the not-checked reasons            |

## Commands

From `scripts/analysis/cc900` (all need the private oracle runs under `~/compartilhado/cc900-oracle/runs`):

    python3 -I -B model/test_interp.py                       # interpreter hand checks, all four option sets
    python3 -I -B model/semcheck.py ORACLE_DIR FILE.c ...    # same arguments as score.py; --why lists not-checked
    python3 -I -B model/semcheck.py --ledger --results results/semcheck.md    # every micro/ and probes/ row
    python3 -I -B model/semcheck.py --ledger --library --results results/semcheck.md   # and the 1997 library row

For example, `python3 -I -B model/semcheck.py ~/compartilhado/cc900-oracle/runs/2026-11-09-24-micro-arrindex/out/v423/none
corpus/micro/arr_index.c`.  Further options: `--trials N` (default 48), `--limit STEPS` (default 10000 instructions
per run), `--only f,g` (C function names), `--verbose` (one line per function), `--all-compilers` (with
`--ledger`, also the ide2003 and v1.10 rows; by default only V4.23's), and `--model-dir DIR`.  `--model-dir` imports
`codegen`, `frontend`, `listing` and `score` from DIR, so an older revision of the model can be checked:

    git archive <rev> scripts/analysis/cc900/model | tar -x -C "$TMPDIR/cc900-semcheck/old"
    python3 -I -B model/semcheck.py ORACLE_DIR FILE.c --model-dir "$TMPDIR/cc900-semcheck/old/scripts/analysis/cc900/model"

Checked that way: at `8f4e06762^` (the revision before the fix of the `arr_index.c` `ai_i_g_sh` wrong code), the
checker reports `_ai_i_g_sh` under `none` as DIFFERENT ("memory: _gca+1022: model unchanged"); at HEAD it is equal.

The exit status is 1 when any function is DIFFERENT.  Verdicts per function:

- **equal**: every trial that ran to completion on both sides gave the same observable outputs.
- **DIFFERENT**: some trial did not, or the model's code jumps to a local label it never defines (it would not
  assemble).  The reason names the first output that differs, the trial's input mode and
  arguments, and how many trials differ in which modes.  A difference only in `edge` / `full` trials can be C
  undefined behaviour (signed overflow) that the two compilers resolve differently, or the oracle narrowing int
  arithmetic to a byte.  Such a function does not compute what the oracle computes, but it may not be wrong C.  A
  difference in `small` trials is almost always wrong code.
  After a ledger run, read each new DIFFERENT side by side with the oracle's listing and add a line to
  `semcheck_review.tsv`; the results file shows the note, or "not reviewed".
- **not checked**: the function calls a runtime helper semcheck does not implement (an FP conversion to or from
  `long double` other than the copy `._fld_xx`, a `C9H_*` helper other than the six below), the model could not
  compile it (`; unsupported` / `; model error`), the interpreter does not implement something in it, or every trial
  hit the step limit on both sides.

## What is run, and what is compared

**Calling convention** (`notes/cc900-compat-plan-2026-11-08/abi.md`).  Without `-Xr` (sets `none`, `O3XS`), the
arguments are on the stack above a 4-byte return address, the first at `(XSP+4)`.  A `char`/`short`/`int` takes 2
bytes (char extended as its type says), a `long`/pointer/`float` 4, a `double` 8, a struct its even size.  A result
of `double` or of a struct over 4 bytes goes through a hidden first argument pointing to a result buffer.  With
`-Xr` (`Xr`, `O3XSXr`), the first three arguments are in A/WA/XWA, C/BC/XBC, E/DE/XDE by size.  The rest (and any
`double` or struct, which still uses up its position: stc `.st_pq_4`) are on the stack, pushed left to right, and the callee pops them.  The
result is read from L, HL or XHL by the return type.  All other register bits start as a fixed junk pattern.
(`codegen.compile_unit` adds the hidden result pointer to the function's parameters as `__sret`; semcheck skips it.
Until 2026-11-09 it did not, so every argument of a function returning a double or a struct sat 4 bytes too high, on
both sides alike: those functions were compared on garbage arguments.)

**Memory.**  Memory is sparse, byte-addressed and 24-bit.  Each global of the unit gets its own address, in name
order, so the model's run and the oracle's agree.  It is filled with a value of its type.  Globals the listing
defines with an initialiser take the oracle listing's data at run time.  Pointers, as arguments or in globals, point
into separate buffers.  Every other byte reads as a hash of its address and the trial seed.  Constants inside the
function's lines (strings, switch tables, `fdatad`) are laid out from 0x600000.  Code addresses are 0xC00000 + 4 *
instruction index, which keeps `dw L2-L50000` and `j XIX+WA` consistent.

**Inputs.**  Trials cycle through four input modes: `small`, `edge`, `full`, `small`.  `small` uses values -2..9
and memory bytes 0..5 at even addresses, 0 at odd ones, so loops end and strings are short.  `edge` uses 0, ±1,
ints at the limits of their type, 0x7f, 0x80, 0xff, 0x8000 and so on.  `full` uses random bits.  A `float` or
`double` takes a multiple of 0.5 in -3..9 (`small`); one of ±0, ±1, 0.5, -2.5, 1.5, 3, a denormal, 1e-40, 3.4e38,
3.5e38 (beyond float), ±1e308, 2147483647.5, -2147483648, 4294967295, 4294967296, ±inf, NaN (`edge`); random bits
(`full`).  A `long double` (10 bytes) is random bytes in every mode.

**Calls out of the function.**  Every call or tail jump to a symbol outside the function goes to a stub:
- The stub records the callee's name, its arguments and the memory state at the call.  The arguments are read as
  the ABI says, from the argument types at the C call site (`.name` = adecl, `_name` = cdecl).  The memory state is
  every non-stack byte that differs from its initial value.  A pointer into the stack, such as `&local`, is
  recorded as the bytes it points to, not as its address; a byte not written since entry is recorded as unknown
  (`None`), since uninitialised stack bytes are garbage that differs with the frame layout.
- It returns a value derived from the name, the arguments and the call index (a buffer pointer for a pointer
  result; written through the hidden pointer for a memory result).
- It sets XWA, XBC, XDE, XHL (except the result), XIX, XIY and the flags to junk, so a caller that keeps a value in
  a caller-saved register across a call is caught.
- It pops its stack arguments under adecl.
- It writes bytes derived from the name, the arguments, the call index and the argument's position through every
  pointer into the stack it is given (the callee may write there, as `frexp` writes its exponent), the same on both
  sides.
- It gives every non-const global a new value, so a caller that keeps a global in a register across a call is
  caught.

`C9H_mulls`, `mullu`, `divls`, `divlu`, `remls`, `remlu` are computed (XWA op XBC -> XHL, truncating division; by
zero: quotient all ones, remainder the dividend) and clobber the same registers, but are not recorded.  The FP
helpers are computed too (next section), and are not recorded either.

## FP helpers

Every FP operation is a call that takes addresses.  The conventions are the ones `fpgen.py` documents and the
oracle listings set up (read at run time; no Toshiba code was disassembled or run):

| helper                                      | what semcheck computes                                                            |
|---------------------------------------------|-----------------------------------------------------------------------------------|
| `._fadd_d`, `_fsub_d`, `_fmul_d`, `_fdiv_d` | (XWA) = (XBC) op (XDE), doubles                                                   |
| `._fadd_f` ... `._fdiv_f`                   | the same on floats (computed in double, rounded once to float: exact for + - * /) |
| `._fneg_d`, `._fneg_f`                      | (XWA) = -(XBC)                                                                    |
| `._fcmp_d`, `._fcmp_f`                      | HL = 1 when (XWA) REL (XBC) holds, else 0; REL = DE                               |
| `._fcmp_zd`, `._fcmp_zf`                    | HL = 1 when (XWA) REL 0 holds, else 0; REL = BC                                   |
| `._fld_<to><from>`                          | (XWA) = (XBC) converted; d double, f float, l long, ul unsigned long              |
| `._fld_dd`, `_fld_ff`, `_fld_xx`            | a copy of 8, 4 or 10 bytes                                                        |

Relation codes: `<=` 0, `<` 1, `>=` 2, `>` 3, `==` 4, `!=` 5.  Arithmetic and conversions between FP types are
IEEE 754, round to nearest even (Python floats; `ctypes.c_float` for the rounding to float, which gives ±inf on
overflow); x / 0 is ±inf, 0 / 0 NaN.  Every helper then sets XWA, XBC, XDE, XHL (HL is the answer of a compare),
XIX, XIY and the flags to junk, like a call stub; XIZ survives.  In the oracle listings no register but HL and XIZ
is read after an FP call before being written (research-scratch `sessions/2026-11-09_cc900-semcheck-fp/
live_after_fpcall.py`), so the oracle's own code is not affected by that.

What the real library does is known only where C pins it down.  Where it does not, semcheck fixes one answer; both
sides call the same helper, so the choice cannot make a difference unless the two compute differently:
- a NaN result is always the default quiet NaN (0x7ff8000000000000 / 0x7fc00000), whatever the operands' payloads;
- a compare orders numbers as IEEE does (-0 == +0) and places a NaN beyond the infinity of its sign, by its bits.  So
  every relation and its negation are complementary, and `a < b` agrees with `b > a`, also for a NaN (IEEE
  answers false to both `a < b` and `a >= b`; cc900 branches on the negated relation, so IEEE's answer could tell a
  branch from a value and report a difference that is only an unordered compare);
- a double or float converted to long or unsigned long truncates toward zero, modulo 2^32; NaN, ±inf and values
  outside -2^31 .. 2^32-1 give 0x80000000 (undefined in C);
- a compare called with a relation code above 5 (BC / DE not set for it) crashes that side's run, so it is reported.
- `long double` is opaque (10 bytes): only the copy `._fld_xx` is implemented; a conversion to or from it is "not
  checked".

**Comparison of FP results.**  Results are compared bit for bit, like every other byte.  The helper calls are not
recorded, so the model may call them in another order than the oracle (`a + b` as `b + a`, temporaries in other
places): only what reaches memory outside the stack, the return value and the arguments of real calls count.  Two
evaluations that IEEE arithmetic says are equal give equal bits here (commutativity of + and *, a compare with its
operands swapped and the relation mirrored), because the helpers are correctly rounded and NaN results canonical.
Two that differ in IEEE (a different association, `x - y` against `-(y - x)` for x == y, which gives -0) are
reported, as they should be.

Validation: `test_interp.py` runs the oracle's code for fp.c (none, `-O3 -XS`) and probes/adfp.c (all four sets) on
chosen values and checks the C answer: every helper the corpora call except `._fld_xx` is exercised (536 FP hand
checks).  And two deliberate model bugs in a scratch copy (research-scratch `sessions/2026-11-09_cc900-semcheck-fp/
mutation_check.sh`): `<` coded as `<=` makes `_d_clt_gg`, `_d_clt_z` and `_d_bge_gg` DIFFERENT, subtraction with its
operands swapped makes the six `*_sub_*` functions and `_d_four` DIFFERENT; unchanged, fp.c is 108 / 108 equal.

**Compared, in this order:** whether the run finished (`ok`, `steps` = step limit, or `crash: ...`, such as a
return to a bad address); the call sequence (callee, arguments, memory at the call); the return value; the final
value of every byte written outside the stack (0x0E0000-0x0F0FFF, whose frame layout differs legitimately); XSP
after the return (+4, or +4 + stack arguments under adecl); XIZ (callee-saved).  A trial that hits the step limit
on both sides counts for neither.  When only one side hits it, both are re-run with four times the limit before the
difference counts.

## Limitations

- The interpreter implements what cc900 emits for the micro and probe corpora.  It does not implement `link`,
  `unlk`, the bank-register forms, `mdec`, `bs1f`, `cpir`, the BCD and carry-flag (`ldcf` ...) instructions, `swi`,
  `halt`, `ei`/`di` or `ldc`; they raise Unsupported, and the function is "not checked".
- FP helpers are modelled as IEEE arithmetic with the fixed choices above, not as the Toshiba library: a
  difference in rounding or in NaN handling between the real library and IEEE cannot be seen, and a model that
  replaces a helper call by inline code would be compared against IEEE, not against the library.
- Stubs write only through pointers into the stack and to globals, not through other pointer arguments, and a call
  through a pointer records its arguments only when every indirect call in the function has the same argument sizes.
- Inputs are random, not exhaustive: "equal" means that no trial differed.  The step limit can hide a difference
  that only shows on long loops.
- Signed overflow is undefined in C, but the comparison treats the oracle's behaviour as the reference.  Read the
  modes in the reason before calling a DIFFERENT a bug.

## Verdict cache (`SEMCHECK_CACHE`)

With the environment variable `SEMCHECK_CACHE` naming a JSON-lines file, a verdict is stored under a key made of the C
source (with its defines, include paths, option set and personality), the oracle's listing file, the function's name,
the model's listing of that function, the calling convention, the trial count, step limit and seed, and the checker's
own code (`semcheck.py`, `interp.py`, `listing.py`).  A function whose key is in the file is not simulated again.  The
file is scratch: delete it to check everything from nothing.  Measured on 2026-11-12 over `--ledger --library` (235
rows, 48,915 keys): 12 min 19 s with an empty file, 1 min 58 s with a full one, the same 73 DIFFERENT verdicts and the
same results table both times.  Without the variable nothing is cached.

The compiles themselves are shared with `score.py` and `pairs_model.py` through `model/cache.py` (`CC900_CACHE`, README
"One compile per round"): with both caches warm the same run took 14 s on 2026-11-13, 1 min 14 s with the verdict cache
alone.
