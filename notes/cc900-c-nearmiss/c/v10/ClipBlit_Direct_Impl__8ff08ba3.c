/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m273a.c (2026-11-18-12-p6-r35)
   sha256 8ff08ba344df257eaec3d4336974ec41acde58d34c99e68c1f78679259ed12ce (tar-sha256); compiled at -O3 -Xr */
#define VRAM5 ((unsigned char (*)[320])0x69800L)
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SetChangeRect(struct rect *r);
void ClipBlit_Direct_Impl(struct pt *c, int r)
{
    int x0;
    int w;
    int h;
    unsigned long y;
    unsigned long src;
    unsigned char (*dst)[320];
    struct rect rc;
    int y0;

    h = r;
    h += r;
    w = h;
    x0 = c->x - r;
    if (x0 < 0) {
        w += x0;
        x0 = 0;
    } else if (x0 + h >= 320)
        w = 319 - x0;
    y0 = c->y - r;
    if (y0 < 0) {
        h += y0;
        y0 = 0;
    } else if (y0 + h >= 240)
        h = 239 - y0;
    dst = (unsigned char (*)[320])&OFFSCREEN_BUFFER_1[y0][x0];
    src = (unsigned long)&VRAM5[y0][x0];
    for (y = y0; y < y0 + h; y++) {
        Mem_Copy(dst, (void *)src, w);
        src += 320;
        dst++;
    }
    rc.y0 = y0;
    rc.x0 = x0;
    rc.x1 = x0 + w;
    rc.y1 = y0 + h;
    SetChangeRect(&rc);
}
