#!/usr/bin/env python3
"""align_aligned_string_blocks.py FILE.s... -- the Label+Include Compaction & Visual Alignment rule for runs of
`aligned_string` lines: a label alone on its line joins the aligned_string after it, and every line of a run
that has at least one label gets its directive at the next tab stop after the run's longest `Label:`.
Emits no byte differently (only whitespace and line joins).  Used 2026-11-02 (lane open6/kn5000-c) on the
class-string blocks of ui_widgets/naka_widget_desc_dispatch.s and naka_effects_eq_dispatch.s.

RUN:  python3 scripts/tools/align_aligned_string_blocks.py v10/maincpu/ui_widgets/naka_effects_eq_dispatch.s
"""
import re, sys
for p in sys.argv[1:]:
    L = open(p, 'rb').read().split(b'\n')
    out, i = [], 0
    while i < len(L):
        # a block: consecutive lines that are aligned_string / .byte, labelled or not
        j, blk = i, []
        while j < len(L):
            ln = L[j]
            m = re.match(rb'^([A-Za-z_]\w*):\s*$', ln)
            if m and j + 1 < len(L) and re.match(rb'^\s+aligned_string\b', L[j + 1]):
                blk.append((m.group(1), L[j + 1].strip())); j += 2; continue
            m = re.match(rb'^([A-Za-z_]\w*):\t+(aligned_string\b.*)$', ln)
            if m:
                blk.append((m.group(1), m.group(2).strip())); j += 1; continue
            if re.match(rb'^\s+aligned_string\b', ln):
                blk.append((None, ln.strip())); j += 1; continue
            break
        if len(blk) >= 2 and any(l for l, _ in blk):
            w = max(len(l) + 1 for l, _ in blk if l)
            col = (w // 8 + 1) * 8
            for l, d in blk:
                lab = (l + b':') if l else b''
                tabs = (col - len(lab) + 7) // 8
                out.append(lab + b'\t' * tabs + d)
            i = j
            continue
        out.append(L[i]); i += 1
    open(p, 'wb').write(b'\n'.join(out))
