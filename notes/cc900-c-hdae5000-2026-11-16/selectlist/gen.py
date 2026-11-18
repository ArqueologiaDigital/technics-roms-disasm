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
# Round 52, from the read-out of run 2026-11-18-4-hd-r50: only a register local u keeps the call's result in XHL
# (so that the function pointer goes to XIX, as the ROM); without u (m) the pointer is called through XHL and v is
# reloaded from the stack; `u = v = ..` (h, i, j) the same as m.  k (the label's spelling with f's order) differs
# only in item 4.  So u stays, in XHL, and its USE must copy it to XWA: an integer address, u + 54 computed on a long
# (the integer-address idiom of DeleteSongPart_Sqt), instead of the pointer cast that folds into (xhl+54).
FORMS52 = [
    dict(R50_BASE, NAME="SelList_p", REGS=R50_REGS + ["long u;"],
         GET="u = GETVIEWL(obj);\n        v = (unsigned char *)u;", U="u"),
    dict(R50_BASE, NAME="SelList_q", REGS=R50_REGS + ["unsigned long u;"],
         GET="u = CALLR(unsigned long, ROOT->GetViewInstance)(obj);\n        v = (unsigned char *)u;", U="u"),
    dict(R50_BASE, NAME="SelList_r", REGS=R50_REGS + ["long u;"],
         GET="v = (unsigned char *)(u = GETVIEWL(obj));", U="u"),
    dict(R50_BASE, NAME="SelList_s", REGS=R50_REGS + ["long u;"],
         GET="u = GETVIEWL(obj);\n        v = (unsigned char *)u;", U="(long)u"),
]
HEAD52 = """/* hd_r52_sl.c (lane_hd round 52): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), four forms written by
   selectlist/gen.py --round 52.  It calls nothing relatively.
   cc900-options: -Xr
%s
   Read-out of run 2026-11-18-4-hd-r50 (hd_r50_sl.c): only a register local u keeps the call's result in XHL, so
   that the function pointer is loaded into XIX as in the ROM (forms k and the label's); without one (m), or with
   `u = v = ..` / `v = ..; u = v;` (h, i, j), the pointer goes through XHL and v is reloaded from the stack.  Form k
   (f's order, the label's spelling) differs from the ROM only in item 4: at the nine first uses the ROM copies u
   to XWA and reads (xwa+N), V4.23 reads (xhl+N) straight.  These forms use u as an INTEGER at those nine places,
   V_xxx(u) = *(T *)(u + N) on a long (the integer-address idiom), instead of the cast (unsigned char *)u:
     SelList_p  long u;  u = GETVIEWL(obj); v = (unsigned char *)u;  first use V_xxx(u)
     SelList_q  unsigned long u (the call's result as unsigned long)
     SelList_r  v = (unsigned char *)(u = GETVIEWL(obj));
     SelList_s  first use V_xxx((long)u)
   The INDEXSW case keeps k's spelling there.
*/
"""
# Round 55, from run 2026-11-18-13-hd-r52: u as an integer address (p, r) adds in XHL (`add xhl,N; ld xwa,(xhl)`);
# q and s are k again.  The ROM's `ld xwa,xhl` reads like the reload of v from the register that still holds it
# (it was just stored from XHL), which V4.23 did not do in m (no u: the function pointer was called through XHL).
# So: u present (the pointer in XIX), and the first use through v.
FORMS55 = [
    dict(R50_BASE, NAME="SelList_t", REGS=R50_REGS + ["long u;"],
         GET="u = GETVIEWL(obj);\n        v = (unsigned char *)u;", U="v"),
    dict(R50_BASE, NAME="SelList_v", REGS=R50_REGS + ["unsigned char *u;"],
         GET="u = GETVIEW(obj);\n        v = u;", U="v"),
    dict(R50_BASE, NAME="SelList_w", REGS=R50_REGS + ["long u;"],
         GET="v = (unsigned char *)(u = GETVIEWL(obj));", U="v"),
]
HEAD55 = """/* hd_r55_sl.c (lane_hd round 55): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), three forms written by
   selectlist/gen.py --round 55.  It calls nothing relatively.
   cc900-options: -Xr
%s
   Run 2026-11-18-13-hd-r52 (hd_r52_sl.c): u used as an integer address (p, r) is added to in place
   (`add xhl,N; ld xwa,(xhl)`); q and s gave k's code again ((xhl+N) straight).  The ROM's `ld (xsp+4),xhl;
   ld xwa,xhl; ld xwa,(xwa+N)` reads like v reloaded from the register that still holds it.  Run hd-r50's m (no u)
   reloaded v from the stack instead, but there the function pointer had been called through XHL.  These keep a
   register local u (the pointer then in XIX) and make the first use through v:
     SelList_t  long u; u = GETVIEWL(obj); v = (unsigned char *)u;  first use V_xxx(v)
     SelList_v  unsigned char *u; u = GETVIEW(obj); v = u;
     SelList_w  v = (unsigned char *)(u = GETVIEWL(obj));
*/
"""
# Round 57, from run 2026-11-18-20-hd-r55: t, v and w give everything but one instruction at the nine places: v is
# reloaded from the stack (`ld xwa,(xsp+4)`) where the ROM copies the register (`ld xwa,xhl`).  So the store of v is
# made the first use's operand, an assignment expression whose value V4.23 takes again from the right-hand register.
K_GET = "u = GETVIEWL(obj);\n        v = (unsigned char *)u;"
FORMS57 = [
    dict(R50_BASE, NAME="SelList_x", REGS=R50_REGS + ["long u;"], GET="u = GETVIEWL(obj);", GETI=K_GET,
         U="(v = (unsigned char *)u)"),
    dict(R50_BASE, NAME="SelList_y", REGS=R50_REGS + ["unsigned char *u;"], GET="u = GETVIEW(obj);",
         GETI="u = GETVIEW(obj);\n        v = u;", U="(v = u)"),
    dict(R50_BASE, NAME="SelList_z", REGS=R50_REGS + ["unsigned char *u;"], GET="u = GETVIEW(obj);",
         GETI="u = GETVIEW(obj);\n        v = u;", U="(unsigned char *)(v = u)"),
]
HEAD57 = """/* hd_r57_sl.c (lane_hd round 57): HDAE5000_SelectListProc (hd-ae5000_v2_06i.s, 2641 B), three forms written by
   selectlist/gen.py --round 57.  It calls nothing relatively.
   cc900-options: -Xr
%s
   Run 2026-11-18-20-hd-r55 (hd_r55_sl.c): forms t, v and w are the ROM's code but for one instruction at each of
   the nine first uses: v is reloaded from the stack, `ld xwa,(xsp+4)`, where the ROM copies the register that
   was just stored, `ld xwa,xhl`.  So the store to v becomes the operand of the first use, an assignment
   expression, whose value V4.23 takes again from the right-hand register (Lyrics_FindEvent's `pos += (n = ..)`):
     SelList_x  long u; u = GETVIEWL(obj);  first use V_xxx((v = (unsigned char *)u))
     SelList_y  unsigned char *u; u = GETVIEW(obj);  first use V_xxx((v = u))
     SelList_z  as y, the operand cast: V_xxx((unsigned char *)(v = u))
   The INDEXSW case (no first use) keeps `v = ..` as a statement.
*/
"""
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
    rnd = sys.argv[sys.argv.index("--round") + 1] if "--round" in sys.argv else None
    if rnd in ("50", "52", "55", "57"):
        forms, hd = {"50": (FORMS50, HEAD50), "52": (FORMS52, HEAD52), "55": (FORMS55, HEAD55),
                     "57": (FORMS57, HEAD57)}[rnd]
        names = "\n".join("   cc900-name: %s=HDAE5000_SelectListProc" % f["NAME"] for f in forms)
        head = hd % names + head.split("*/\n", 1)[1]
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
