/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m129b.c (2026-11-22-15-p6-r82)
   sha256 86f0a13255c41befd44e942e51bad3b11935e0bc97271c7a01a750fb07645f05 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_LoadRawAddr(unsigned char *);
extern unsigned int SeMenu_InterpolateEdgeX(unsigned int a, unsigned int b, unsigned int d);
extern void __cdecl SeGfx_DrawLine(unsigned int, unsigned int, unsigned int, unsigned int);
void SeMenu_DrawEnvGraphLine(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1)
{
    char p;
    unsigned char r;
    int d;

    SeMenu_LoadPartParam(1, (unsigned char *)&p);
    SeMenu_LoadRawAddr(&r);
    if (r == 55) {
        d = p * 43 / 50;
        y0 -= d;
        y1 -= d;
        if (x0 == x1) {
            if (y0 < 59) y0 = 59;
            else if (y0 > 146) y0 = 146;
            if (y1 < 59) y1 = 59;
            else if (y1 > 146) y1 = 146;
        } else if (y0 < 59 || y0 > 146 || y1 < 59 || y1 > 146) {
            if (y0 < 59 && y1 < 59) return;
            if (y0 > 146 && y1 > 146) return;
            if (y0 < y1) {
                if (y1 > 146) {
                    x1 = x0 + SeMenu_InterpolateEdgeX(x1 - x0, 146 - y0, y1 - y0);
                    y1 = 146;
                }
                if (y0 < 59) {
                    x0 += SeMenu_InterpolateEdgeX(x1 - x0, 59 - y0, y1 - y0);
                    y0 = 59;
                }
            } else {
                if (y1 < 59) {
                    x1 = x0 + SeMenu_InterpolateEdgeX(x1 - x0, y0 - 59, y0 - y1);
                    y1 = 59;
                }
                if (y0 > 146) {
                    x0 += SeMenu_InterpolateEdgeX(x1 - x0, y0 - 146, y0 - y1);
                    y0 = 146;
                }
            }
        }
    }
    SeGfx_DrawLine(x0, y0, x1, y1);
}
