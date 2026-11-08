# cc900 reference model (phase 3a)

An executable specification of cc900's code generation, in Python, checked line by line against the oracle's
listings (`notes/cc900-compat-plan-2026-11-08/phase0.md`, section 4).  The LLVM implementation (phase 3b) is
written from it and tested against it.

| module        | what it does                                                                                                    |
|---------------|-----------------------------------------------------------------------------------------------------------------|
| `frontend.py` | clang's AST (`-ast-dump=json`) to a small tree with cc900's types (16-bit `int`, alignment 2, even struct sizes) |
| `listing.py`  | splits a Toshiba `.asm` listing into normalised per-function lines; compares two                                |

Work in progress: the code generator and the scoring tool come next.
