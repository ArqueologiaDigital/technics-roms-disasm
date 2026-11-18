#!/usr/bin/env python3
"""Write probes/hd_r46_n2.c from head.txt + body.tpl: the label's function and four variants of
HDAE5000_SelectListProc that differ only in the two unsettled items (the view pointer copy, the register locals).
Usage (from the worktree root): python3 -B gen.py OUTFILE
       python3 -B gen.py --round 50 OUTFILE     (probes/hd_r50_sl.c: round 50's six forms, item 4 only)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
T_PAINT = ("                t = client.x0 + cw * i - 1;\n"
           "                p1.x = t;\n"
           "                p2.x = t;")

FORMS = [
    dict(NAME="HDAE5000_SelectListProc", VDECL="unsigned char *v;",
         REGS=["int t;", "unsigned int col;", "unsigned int a;", "int n;", "int d;", "long u;"],
         GET="u = GETVIEWL(obj);\n        v = (unsigned char *)u;", U="(unsigned char *)u", V="v", END="",
         PAINTX=T_PAINT, CELLDECL="", COL="col", COLUSE="col"),
    dict(NAME="SelList_d", VDECL="long v;",
         REGS=["int n;", "unsigned int a;", "int t;", "int d;", "long u;"],
         GET="u = GETVIEWL(obj);\n        v = u;", U="(unsigned char *)u", V="(unsigned char *)v", END="",
         PAINTX="                p2.x = p1.x = client.x0 + cw * i - 1;", CELLDECL="", COL="n",
         COLUSE="(unsigned int)n"),
    dict(NAME="SelList_e", VDECL="unsigned char *v;",
         REGS=["int n;", "int d;", "void *u;"],
         GET="u = GETVIEWV(obj);\n        v = u;", U="(unsigned char *)u", V="v", END="",
         PAINTX="                int t;\n\n" + T_PAINT,
         CELLDECL="                unsigned int a;\n                unsigned int col;\n                int t;\n",
         COL="col", COLUSE="col"),
    dict(NAME="SelList_f", VDECL="unsigned char *v;",
         REGS=["int t;", "unsigned int a;", "unsigned int col;", "int n;", "int d;"],
         GET="{\n        long u;\n\n        u = GETVIEWL(obj);\n        v = (unsigned char *)u;",
         U="(unsigned char *)u", V="v", END="}",
         PAINTX=T_PAINT, CELLDECL="", COL="col", COLUSE="col"),
    dict(NAME="SelList_g", VDECL="unsigned char *v;",
         REGS=["int t;", "unsigned int col;", "unsigned int a;", "int n;", "int d;", "unsigned char *u;"],
         GET="u = GETVIEW(obj);\n        v = u;", U="(unsigned char *)(unsigned long)u", V="v", END="",
         PAINTX=T_PAINT, CELLDECL="", COL="col", COLUSE="col"),
]


# Round 50 (lane_hd, 2026-11-18), from the read-out of run 2026-11-17-20-hd-r47: item 3 is settled by f's (and e's)
# order t, a, col (the remainder a in HL, the column in DE, as the ROM); item 4 is all that differs, at the nine
# GetViewInstance calls whose pointer is used at once.  These forms keep f's order and vary item 4 only.  @GETI@ is
# the INDEXSW case's call, whose pointer is not used at once (the ROM has no copy there).
R50_REGS = ["int t;", "unsigned int a;", "unsigned int col;", "int n;", "int d;"]
R50_BASE = dict(VDECL="unsigned char *v;", V="v", END="", PAINTX=T_PAINT, CELLDECL="", COL="col", COLUSE="col")
FORMS50 = [
    dict(R50_BASE, NAME="SelList_h", REGS=R50_REGS + ["unsigned char *u;"],
         GET="u = v = GETVIEW(obj);", GETI="v = GETVIEW(obj);", U="u"),
    dict(R50_BASE, NAME="SelList_i", REGS=["unsigned char *u;"] + R50_REGS,
         GET="u = v = GETVIEW(obj);", GETI="v = GETVIEW(obj);", U="u"),
    dict(R50_BASE, NAME="SelList_j", REGS=R50_REGS + ["unsigned char *u;"],
         GET="v = GETVIEW(obj);\n        u = v;", GETI="v = GETVIEW(obj);", U="u"),
    dict(R50_BASE, NAME="SelList_k", REGS=R50_REGS + ["long u;"],
         GET="u = GETVIEWL(obj);\n        v = (unsigned char *)u;", GETI="u = GETVIEWL(obj);\n        v = (unsigned char *)u;",
         U="(unsigned char *)u"),
    dict(R50_BASE, NAME="SelList_m", REGS=R50_REGS,
         GET="v = GETVIEW(obj);", GETI="v = GETVIEW(obj);", U="v"),
    dict(R50_BASE, NAME="SelList_n", REGS=R50_REGS + ["long u;"],
         GET="u = (long)(v = GETVIEW(obj));", GETI="v = GETVIEW(obj);", U="(unsigned char *)u"),
]
HEAD50 = """/* hd_r50_sl.c (lane_hd round 50): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), six forms written by
   selectlist/gen.py --round 50.  It calls nothing relatively.
   cc900-options: -Xr
%s
   Read-out of run 2026-11-17-20-hd-r47 (probes/hd_r46_n2.c, selectlist/cmp.py against the ROM):
   - item 3 (registers of the cell arithmetic) is SETTLED by SelList_e and SelList_f: declared t, a, col (the
     label's t, col, a put the remainder a in DE and the column in HL, the ROM the reverse);
   - item 4 (the view pointer copied to XWA, `ld xwa,xhl` before the first use) is the only difference left in e
     and f: nine places, the same in all five forms.  g's (unsigned long) cast changed nothing.
   These forms keep f's order (not in a block) and vary item 4:
     SelList_h  `u = v = GETVIEW(obj);`, u an `unsigned char *` declared last: v stored first, then u (XWA?);
     SelList_i  the same, u declared first;
     SelList_j  `v = GETVIEW(obj); u = v;`;
     SelList_k  the label's spelling (`u = GETVIEWL(obj); v = (unsigned char *)u;`), a control for item 3;
     SelList_m  no u: `v = GETVIEW(obj);` and every use through v;
     SelList_n  `u = (long)(v = GETVIEW(obj));`, used as `(unsigned char *)u`.
   In the INDEXSW case the pointer is not used at once and the ROM has no copy: there h, i, j, m and n write only
   `v = GETVIEW(obj);`.
*/
"""


def main():
    out = sys.argv[-1]
    head = open(os.path.join(HERE, "head.txt")).read()
    tpl = open(os.path.join(HERE, "body.tpl")).read()
    forms = FORMS
    if "--round" in sys.argv and sys.argv[sys.argv.index("--round") + 1] == "50":
        forms = FORMS50
        names = "\n".join("   cc900-name: %s=HDAE5000_SelectListProc" % f["NAME"] for f in forms)
        head = HEAD50 % names + head.split("*/\n", 1)[1]
    parts = [head]
    for f in forms:
        f = dict(f)
        f.setdefault("GETI", f["GET"])
        f["REGS"] = "\n".join("    " + r for r in f["REGS"])
        res = []
        for l in tpl.split("\n"):
            # drop the lines left empty by an empty @END@ / @CELLDECL@
            if l.strip() in ("@END@", "@CELLDECL@") and f[l.strip().strip("@")] == "":
                continue
            if l.strip() == "@CELLDECL@" or l.strip() == "@PAINTX@":
                l = l.strip()
            for k, v in f.items():
                l = l.replace("@%s@" % k, v)
            assert "@" not in l, l
            res.extend(x.rstrip() for x in l.split("\n"))
        parts.append("\n".join(res))
    open(out, "w").write("\n".join(parts))


main()
