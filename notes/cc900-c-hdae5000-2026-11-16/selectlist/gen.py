#!/usr/bin/env python3
"""Write probes/hd_r46_n2.c from head.txt + body.tpl: the label's function and four variants of
HDAE5000_SelectListProc that differ only in the two unsettled items (the view pointer copy, the register locals).
Usage (from the worktree root): python3 -B gen.py OUTFILE
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


def main():
    out = sys.argv[1]
    head = open(os.path.join(HERE, "head.txt")).read()
    tpl = open(os.path.join(HERE, "body.tpl")).read()
    parts = [head]
    for f in FORMS:
        f = dict(f)
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
