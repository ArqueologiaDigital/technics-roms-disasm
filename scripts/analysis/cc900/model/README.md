# cc900 reference model (phase 3a)

An executable specification of cc900's code generation, in Python, checked line by line against the oracle's
listings (`notes/cc900-compat-plan-2026-11-08/phase0.md`, section 4).  The LLVM implementation (phase 3b) is
written from it and tested against it.

| module        | what it does                                                                                                         |
|---------------|----------------------------------------------------------------------------------------------------------------------|
| `frontend.py` | clang's AST (`-ast-dump=json`) to a small tree with cc900's types (16-bit `int`, alignment 2, even struct sizes)     |
| `listing.py`  | splits a Toshiba `.asm` listing into normalised per-function lines; compares two                                     |
| `codegen.py`  | the code generator; each rule cites the oracle listing it comes from                                                 |
| `score.py`    | model against oracle, per function: `python3 -I -B score.py ORACLE_DIR FILE.c ... [--opt O3XS] [--adecl] [--show N]` |

`../results/model_ledger.md` records the scores (regenerate with the loop in its commit message).  The oracle
directories are `~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/<compiler>/<options>`.
