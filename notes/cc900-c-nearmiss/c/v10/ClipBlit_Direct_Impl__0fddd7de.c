/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m273a.c (2026-11-18-28-p6-r36)
   sha256 0fddd7de1d2cb147c838a03c65155543e5aa373f0b8490e8e5f072ca07505f5d (tar-sha256); compiled at -O3 -Xr */
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
    unsigned char *dst;
    struct rect rc;
    int y0;
    long ly;
    unsigned long row;
    int ye;
    struct rect *rp;

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
    ly = y0;
    row = (unsigned long)ly * 320;
    dst = &OFFSCREEN_BUFFER_1[0][0] + (row + x0);
    src = 0x69800L;
    src += row + x0;
    for (y = ly; y < (ye = y0 + h); y++) {
        Mem_Copy(dst, (void *)src, w);
        src += 320;
        dst += 320;
    }
    rp = &rc;
    rp->y0 = y0;
    rp->x0 = x0;
    rp->x1 = x0 + w;
    rp->y1 = ye;
    SetChangeRect(rp);
}
