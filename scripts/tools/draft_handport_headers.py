#!/usr/bin/env python3
r"""Draft hand-port entries for v10 headers whose v7 body differs (a person finishes them).

QUESTION ANSWERED / JOB IT DOES
    For each label given, prints an entry in the format scripts/tools/apply_handported_headers.py
    reads (`@@ v7 Label`, `# note: TODO`, the header) with a FIRST GUESS at the v7 text:
      * every 3-5-digit hex number in RAM range is rewritten by the measured v10 -> v7 RAM map
        (analysis/header-propagation/v7-ram-shift-2026-10-24.txt) -- including numbers that
        are NOT RAM addresses (parameter ids, lengths, signatures, offsets into the sound-RAM
        image), which the person must put back: the draft lists every change in `# changes:`;
      * a callee whose name differs between the two bodies, on a line that pairs up, is renamed
        to v7's label -- check it with scripts/analysis/v7_routine_equivalence.py first;
      * `# at:` gives the v7 location and why propagate_v10_headers.adapt still refuses the text
        (e.g. a symbol v7 lacks), `# diff -/+` the first body differences.
    Nothing is written to the tree; the person copies the entries into the handport file,
    replaces each TODO note with the evidence, fixes or drops the text, and applies it.

RUN
    make all
    python3 scripts/tools/draft_handport_headers.py LABEL [LABEL ...] > draft.txt
"""
import difflib
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
sys.path.insert(0, os.path.join(REPO, "scripts", "analysis"))
import propagate_v10_headers as P  # noqa: E402
from v7_routine_equivalence import delta, load_runs  # noqa: E402


def main():
    runs = load_runs()
    src, dst = P.Tree("v10"), P.Tree("v7")
    src.load_elf()
    dst.load_elf()
    for name in sys.argv[1:]:
        rel, i = src.labels[name]
        r2, i2 = dst.labels[name]
        sb, _, _ = src.body(name)
        db, _, _ = dst.body(name)
        hdr = src.files[rel][src.header(rel, i):i]
        labs, diff = {}, []
        sm = difflib.SequenceMatcher(None, [x[1] for x in sb], [x[1] for x in db], autojunk=False)
        for t, a1, a2, b1, b2 in sm.get_opcodes():
            if t == "equal":
                continue
            diff.append((" / ".join(x[1] for x in sb[a1:a2])[:150],
                         " / ".join(x[1] for x in db[b1:b2])[:150]))
            if t == "replace" and a2 - a1 == b2 - b1:
                for k in range(a2 - a1):
                    ts, td = P.TOKEN.findall(sb[a1 + k][1]), P.TOKEN.findall(db[b1 + k][1])
                    if len(ts) == len(td):
                        for x, y in zip(ts, td):
                            if x != y and x in src.addr and y in dst.addr:
                                labs[x] = y
        changes = []

        def sub(m):
            tok = m.group(0)
            v = int(tok, 16)
            if v < 0x100 or v >= P.RAM_TOP:
                return tok
            d = delta(runs, v)
            if d is None:
                changes.append("%s ?unmapped" % tok)
                return tok
            if d == 0:
                return tok
            w = len(tok) - 2
            new = tok[:2] + (("%0*X" if tok[2:].upper() == tok[2:] else "%0*x") % (w, v + d))
            changes.append("%s->%s" % (tok, new))
            return new

        text = P.HEXNUM.sub(sub, "\n".join(hdr))
        for x, y in labs.items():
            if re.search(r"\b%s\b" % re.escape(x), text):
                changes.append("%s->%s" % (x, y))
                text = re.sub(r"\b%s\b" % re.escape(x), y, text)
        out, why, what = P.adapt(text, src, dst)
        print("@@ v7 %s" % name)
        print("# note: TODO")
        print("# at: %s:%d   adapt: %s %s" % (r2, i2 + 1, why, what))
        print("# changes: %s" % ", ".join(changes))
        for a, b in diff[:5]:
            print("# diff - %s" % a)
            print("# diff + %s" % b)
        print(out)
        print()


if __name__ == "__main__":
    main()
