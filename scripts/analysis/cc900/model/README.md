# cc900 reference model (phase 3a)

An executable specification of cc900's code generation, in Python, checked line by line against the oracle's
listings (`notes/cc900-compat-plan-2026-11-08/phase0.md`, section 4).  The LLVM implementation (phase 3b) is
written from it and tested against it.

| module           | what it does                                                                                                            |
|------------------|-------------------------------------------------------------------------------------------------------------------------|
| `frontend.py`    | clang's AST (`-ast-dump=json`) to a small tree with cc900's types (16-bit `int`, alignment 2, even struct sizes)        |
| `listing.py`     | splits a Toshiba `.asm` listing into normalised per-function lines; compares two                                        |
| `codegen.py`     | the code generator; each rule cites the oracle listing it comes from                                                    |
| `homes.py`       | which values live across a call get IZ / QIZ / XIZ: rules R3-set and R4 (`codegen.plan_homes`)                          |
| `homes2.py`      | the same question by the fitted homes2 rule (a Chow-style priority colouring), behind `codegen.HOMES2` / `CC900_HOMES2` |
| `score.py`       | model against oracle, per function: `python3 -I -B score.py ORACLE_DIR FILE.c ... [--opt O3XS] [--adecl] [--show N]`    |
| `to_llvm.py`     | the model's listing rewritten in our llvm-mc syntax, with asm900's encodings and the 8/16/24-bit address choice         |
| `check_bytes.py` | assembles `to_llvm.py` output with llvm-mc and compares each function's bytes with a ROM image                          |
| `pairs_model.py` | the firmware's library pairs rebuilt by the model + `to_llvm.py` + llvm-mc / ld.lld, compared with each image           |

**From C to ROM bytes without Toshiba's tools** (phase 6 preview; prints `6 of 6 functions byte-identical`):

    python3 -I -B to_llvm.py ../corpus/firmware/tiny.c ../corpus/firmware/tiny.syms --adecl > "$TMPDIR/tiny.s"
    python3 -I -B check_bytes.py "$TMPDIR/tiny.s" ../../../../original_ROMs/kn5000_v10_program.rom \
        ../../../../symbols/maincpu_v10_symbols_reference.txt 0xe00000

**The firmware's library pairs without Toshiba's tools** (`../results/pairs_model_kn5000.tsv`):

    python3 -I -B pairs_model.py ../results/pairs.tsv ~/compartilhado/tmp/cc900-corpus-libsrc97 > ../results/pairs_model_kn5000.tsv

`../results/model_ledger.md` records the scores; `sh model/ledger.sh` (from `scripts/analysis/cc900`) regenerates them.  The oracle
directories are `~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/<compiler>/<options>`.
