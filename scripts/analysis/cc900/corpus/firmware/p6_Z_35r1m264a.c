/* Probe round 35r1, helper Z, form a: ui/drawbar_panel_ui.s (module 264), the xr_screen.py shape at -O3 -Xr.
   PsMixer_CalcSwitchPointInFrame(r, out, v): the frame box r lowered by the frame's height (as the built
   PsMixer_DrawFrameBoxWithDividers does), its centre into out, then out->x moved to switch v % 8's point.
   r is a `register` parameter (XIZ), the column v % 8 a `register` local (IZ, the remainder of divs). */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern void PsMixer_CalcSwitchPointInFrame(struct rect *, struct pt *, int);

void PsMixer_CalcSwitchPointInFrame(register struct rect *r, struct pt *out, int v)
{
    struct rect rr;
    struct pt pt;
    unsigned int w;
    unsigned int h;
    register int k;

    GetFrameSPSize(52, &w, &h);
    rr = *r;
    rr.y0 += h - 2;
    k = v % 8;
    GetEditSwPoint(k, &pt);
    GetBoxCenter(&rr, out);
    out->x = pt.x - (k * 2 - 8) - 2;
}
