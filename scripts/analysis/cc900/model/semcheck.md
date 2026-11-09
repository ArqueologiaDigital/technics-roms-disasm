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
- **not checked**: the function calls an FP helper (`._f*`) or another runtime helper, the model could not compile
  it (`; unsupported` / `; model error`), the interpreter does not implement something in it, or every trial hit the
  step limit on both sides.

## What is run, and what is compared

**Calling convention** (`notes/cc900-compat-plan-2026-11-08/abi.md`).  Without `-Xr` (sets `none`, `O3XS`), the
arguments are on the stack above a 4-byte return address, the first at `(XSP+4)`.  A `char`/`short`/`int` takes 2
bytes (char extended as its type says), a `long`/pointer/`float` 4, a `double` 8, a struct its even size.  A result
of `double` or of a struct over 4 bytes goes through a hidden first argument pointing to a result buffer.  With
`-Xr` (`Xr`, `O3XSXr`), the first three arguments are in A/WA/XWA, C/BC/XBC, E/DE/XDE by size.  The rest (and any
`double`, which still uses up its position) are on the stack, pushed left to right, and the callee pops them.  The
result is read from L, HL or XHL by the return type.  All other register bits start as a fixed junk pattern.

**Memory.**  Memory is sparse, byte-addressed and 24-bit.  Each global of the unit gets its own address, in name
order, so the model's run and the oracle's agree.  It is filled with a value of its type.  Globals the listing
defines with an initialiser take the oracle listing's data at run time.  Pointers, as arguments or in globals, point
into separate buffers.  Every other byte reads as a hash of its address and the trial seed.  Constants inside the
function's lines (strings, switch tables, `fdatad`) are laid out from 0x600000.  Code addresses are 0xC00000 + 4 *
instruction index, which keeps `dw L2-L50000` and `j XIX+WA` consistent.

**Inputs.**  Trials cycle through four input modes: `small`, `edge`, `full`, `small`.  `small` uses values -2..9
and memory bytes 0..5 at even addresses, 0 at odd ones, so loops end and strings are short.  `edge` uses 0, ±1,
ints at the limits of their type, 0x7f, 0x80, 0xff, 0x8000 and so on.  `full` uses random bits.

**Calls out of the function.**  Every call or tail jump to a symbol outside the function goes to a stub:
- The stub records the callee's name, its arguments and the memory state at the call.  The arguments are read as
  the ABI says, from the argument types at the C call site (`.name` = adecl, `_name` = cdecl).  The memory state is
  every non-stack byte that differs from its initial value.  A pointer into the stack, such as `&local`, is
  recorded as the bytes it points to, not as its address.
- It returns a value derived from the name, the arguments and the call index (a buffer pointer for a pointer
  result; written through the hidden pointer for a memory result).
- It sets XWA, XBC, XDE, XHL (except the result), XIX, XIY and the flags to junk, so a caller that keeps a value in
  a caller-saved register across a call is caught.
- It pops its stack arguments under adecl.
- It gives every non-const global a new value, so a caller that keeps a global in a register across a call is
  caught.

`C9H_mulls`, `mullu`, `divls`, `divlu`, `remls`, `remlu` are computed (XWA op XBC -> XHL, truncating division; by
zero: quotient all ones, remainder the dividend) and clobber the same registers, but are not recorded.

**Compared, in this order:** whether the run finished (`ok`, `steps` = step limit, or `crash: ...`, such as a
return to a bad address); the call sequence (callee, arguments, memory at the call); the return value; the final
value of every byte written outside the stack (0x0E0000-0x0F0FFF, whose frame layout differs legitimately); XSP
after the return (+4, or +4 + stack arguments under adecl); XIZ (callee-saved).  A trial that hits the step limit
on both sides counts for neither.  When only one side hits it, both are re-run with four times the limit before the
difference counts.

## Limitations

- The interpreter implements what cc900 emits for the micro and probe corpora.  It does not implement `link`,
  `unlk`, the bank-register forms, `mdec`, `bs1f`, the BCD and carry-flag (`ldcf` ...) instructions, `swi`, `halt`,
  `ei`/`di` or `ldc`; they raise Unsupported, and the function is "not checked".
- FP is not modelled: a function calling `._f*` is not checked.  Arguments of type `float`/`double` are passed as
  opaque bytes.
- Stubs do not write through pointer arguments (they only change globals), and a call through a pointer records
  its arguments only when every indirect call in the function has the same argument sizes.
- Inputs are random, not exhaustive: "equal" means that no trial differed.  The step limit can hide a difference
  that only shows on long loops.
- Signed overflow is undefined in C, but the comparison treats the oracle's behaviour as the reference.  Read the
  modes in the reason before calling a DIFFERENT a bug.
