/* Probe round 31r1, helper R, form a: audio/semenu_routines.s SeMenu_DrawEnvGraphLine (module 129).  Draw one
   segment of an envelope graph; in the clipped display mode (raw byte 55) shift it by the part's offset * 43 / 50
   and clip it to the graph's rows 59..146, cutting the x ends with the built SeMenu_InterpolateEdgeX. */
/* cc900-module: SeMenu_InterpolateEdgeX SeMenu_LoadPartParam SeMenu_LoadRawAddr */

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_LoadRawAddr(unsigned char *);
extern unsigned int SeMenu_InterpolateEdgeX(unsigned int a, unsigned int b, unsigned int d);
extern void __cdecl SeGfx_DrawLine(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeMenu_DrawEnvGraphLine(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1);

void SeMenu_DrawEnvGraphLine(unsigned int x0, unsigned int y0, unsigned int x1, unsigned int y1)
{
    char p;
    unsigned char r;
    int d;
    unsigned int w;

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
            w = x1 - x0;
            if (y0 < y1) {
                if (y1 > 146) {
                    x1 = x0 + SeMenu_InterpolateEdgeX(w, 146 - y0, y1 - y0);
                    y1 = 146;
                }
                if (y0 < 59) {
                    x0 += SeMenu_InterpolateEdgeX(x1 - x0, 59 - y0, y1 - y0);
                    y0 = 59;
                }
            } else {
                if (y1 < 59) {
                    x1 = x0 + SeMenu_InterpolateEdgeX(w, y0 - 59, y0 - y1);
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
