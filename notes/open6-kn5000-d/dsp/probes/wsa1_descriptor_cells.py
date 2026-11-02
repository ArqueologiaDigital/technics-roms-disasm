#!/usr/bin/env python3
"""wsa1_descriptor_cells.py -- do the SX-WSA1R's DSP records carry tag-0x4C descriptor pokes?

QUESTION IT ANSWERS
    The KN5000's delay-DRAM descriptor cells come from tag-0x4C value groups in its parameter
    streams (dsp/tools/dram_cursor.py desc_cells), and the k-th delay consumer of a body takes the
    k-th cell.  To check, across products, whether a fused `880.1.30.8BC' consumes a descriptor
    slot (dsp/analysis/bit11-xprod-2026-11-02.md sect. 2), the WSA1R's descriptor cells are needed.
    This de-frames each record's coefficient streams (PoolDir_Records fields +0/+4/+8, opcode 0)
    with wsa1/dsp/analysis/dsp_cram_map.deframe_stateful and prints, per record with a program
    body, the descriptor cell count against the body's consumer count (hi12 bit 11 and class4 1).

MEASURED 2026-11-02: 0 descriptor cells in all 48 records with a body -- the record streams hold
D-RAM fills (tag 0x15) and parameter maps, not descriptor pokes, so the WSA1R descriptor values
come from a writer this tree has not parsed.  The cross-product descriptor test stays undone.

RUN (from the repo root):
    python3 notes/open6-kn5000-d/dsp/probes/wsa1_descriptor_cells.py
"""
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "dsp", "tools"))
sys.path.insert(0, os.path.join(ROOT, "wsa1", "dsp", "analysis"))
import dsp_disasm as D                                                    # noqa: E402
import gen_wsa1_dsp_disasm as G                                           # noqa: E402
import dsp_cram_map as M                                                  # noqa: E402

X = G.X


def stream(addr):
    d = X.POOL.D
    b0 = d[addr - X.POOL.BASE]
    ln = ((b0 & 0xF) << 8) | d[addr - X.POOL.BASE + 1]
    return b0 >> 4, bytes(d[addr + 2 - X.POOL.BASE: addr + ln - X.POOL.BASE])


def main():
    zero = n = 0
    for e in G.build():
        if not e["body"]:
            continue
        dsc = {}
        for off in (0, 4, 8):
            op, b = stream(G.record_field(e["rec"], off))
            if op == 0:
                dsc.update(M.deframe_stateful(b[3:])[1])
        ws = e["body"][1]
        cons = sum(1 for w in ws if (D.hi12(w) & 0x800) and D.class4(w) == 1)
        n += 1
        zero += not dsc
        print("%-28s load %3d  descriptor cells %2d  consumers %2d"
              % (e["name"][:28], e["body"][0], len(dsc), cons))
    print("\n%d records with a body; %d carry no descriptor cell in fields +0/+4/+8" % (n, zero))
    return 0


if __name__ == "__main__":
    sys.exit(main())
