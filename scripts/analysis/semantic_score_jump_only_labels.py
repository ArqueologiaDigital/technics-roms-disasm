#!/usr/bin/env python3
"""Which rated routine names of the MN10300 images are reached only by bra / jmp?

Question it answers: THE GENERATED-SOURCE ROUTINE RULE in semantic_score.py leaves out local labels (never
called nor used as an address, and fallen into or named only by conditional branches), but it cannot tell a
branch target that follows an unconditional jump and is reached only by bra / jmp from a tail-called routine,
so such a label is still rated.  This lists those rated, non-positional names per image (no `call`/`calls`,
no address use, at least one bra / jmp), which is the limit the docstring quotes.

Run (repository root): python3 scripts/analysis/semantic_score_jump_only_labels.py [image ...]
       default images: every "generated" image of semantic_score.MN (program, program942, kn2400, ...)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import semantic_score as S  # noqa: E402


def jump_only(key):
    lines = []
    for p in S.mn_files(key, 1):
        lines += S.mn_text(p, S.MN[key][0]).split("\n")
    refs, _ = S.mn_label_context(lines)
    out = []
    for n, v in sorted(S.generated_routines(lines).items()):
        r = refs.get(n, {})
        if (v == "label" and not n.startswith("func_") and not any(pp.search(n) for pp in S.POSITIONAL)
                and r.get("jump") and not r.get("call") and not r.get("addr")):
            out.append(n)
    return out


def main():
    keys = sys.argv[1:] or [k for k, v in S.MN.items() if v[3] == "generated"]
    for k in keys:
        names = jump_only(k)
        print("%-11s %3d  %s" % (k, len(names), " ".join(names)))


if __name__ == "__main__":
    main()
