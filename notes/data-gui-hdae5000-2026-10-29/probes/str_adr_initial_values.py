#!/usr/bin/env python3
"""What are the 0x0070xxxx words in the HD-AE5000's UI state block?

QUESTION: 29 of the 31 SelectList objects' str_adr variables (HdaeUiVar_<list>_str_adr) start
with a value 0x006Fxxxx-0x0070xxxx; the other two start at 0.  Are they pointers the firmware
uses?  This prints, per version:
  * each SelectList's initial str_adr and en_paradraw;
  * how str_adr changes between v2.01i and v2.06i, list by list.
The code that reads them is HDAE5000_SelectListProc (hd-ae5000_v2_06i.s):
  - EVT_HDAE_SET_STR_ADR (MT_SetStrAdr) stores XDE into *(instance + 0x26), the str_adr
    variable: that is how a screen gives a list its row strings;
  - EVT_PARA_DRAW reads *(instance + 0x26) (0 -> the default table
    HDAE5000_TextPtrs_01Selectlist0203040506070809), then draws only if
    *(instance + 0x36), the en_paradraw variable, is 1.
So a list whose en_paradraw starts at 0 never draws its initial str_adr; a screen first
enables it and gives it its strings.

RUN (repo root, built tree):
    python3 notes/data-gui-hdae5000-2026-10-29/probes/str_adr_initial_values.py
Measured 2026-10-29, both versions: all 31 lists start with en_paradraw = 0; the str_adr
deltas v2.06i - v2.01i are 0 for 15 lists (the two zero ones among them) and 680 / 682 /
684 for the other 16, so the
values are link-time addresses of some build, not data of this image.  (No consistent base
maps them onto the labels of this ROM, onto its HDAE5000_RAM_* symbols, or onto string
starts in any of the four HD-AE5000 dumps at 0x700000.)
"""
import collections
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import hdae5000_ui_tree as T  # noqa: E402

host = T.HostClasses()
init = {}
for ver in T.VERSIONS:
    v = T.Version(ver, host)
    d = {}
    for o in v.objs:
        if o["cname"] != "SelectList":
            continue
        f = {fn: off for off, fn, ch in o["fields"]}
        sa = v.u32(v.ram2rom(v.u32(o["a"] + f["str_adr"])))
        en = v.u16(v.ram2rom(v.u32(o["a"] + f["en_paradraw"])))
        d[o["name"]] = (sa, en)
    init[ver] = d
    c = collections.Counter(("0x%04xxxxx" % (sa >> 16) if sa else "0", en) for sa, en in d.values())
    print("%s: %d SelectLists; (str_adr high half, en_paradraw): %s" % (ver, len(d), dict(c)))
a, b = init["v2_06i"], init["v2_01i"]
print("str_adr v2.06i - v2.01i, per list:", dict(collections.Counter(a[k][0] - b[k][0] for k in a if k in b)))
