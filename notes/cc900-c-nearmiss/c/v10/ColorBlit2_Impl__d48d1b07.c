/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m273b.c (2026-11-22-15-p6-r82)
   sha256 d48d1b0778c519d5569c44382cbe612b10dacafcbe61dff66a3b513cc941e213 (tar-sha256); compiled at -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern unsigned char (*WALLPAPER_BITMAP)[320];
extern void SetChangeRect(struct rect *r);
void ColorBlit2_Impl(struct rect *r, int c)
{
    int y0;
    int y;
    int x;
    unsigned char *p;
    unsigned char *q;
    unsigned long i;

    if (r->y0 < 0) r->y0 = 0;
    if (r->x0 < 0) r->x0 = 0;
    if (r->x1 >= 320) r->x1 = 319;
    if (r->y1 >= 240) r->y1 = 239;
    y0 = r->y0;
    if (c == 0xf7) return;
    switch (COLORBLIT_MODE_ACTIVE) {
    case 0:
        if (c != 0xf5) {
            for (y = y0; y <= r->y1; y++) {
                p = &OFFSCREEN_BUFFER_1[y][r->x0];
                for (x = r->x0; x <= r->x1; x++) {
                    *p &= 0x60;
                    *p += c & 0x9f;
                    if ((c & 0x80) != (*p & 0x80)) *p ^= 0x60;
                    p++;
                }
            }
        } else {
            for (y = y0; y <= r->y1; y++) {
                p = &OFFSCREEN_BUFFER_1[y][r->x0];
                q = &WALLPAPER_BITMAP[y][r->x0];
                for (x = r->x0; x <= r->x1; x++) {
                    *p &= 0x60;
                    *p += *q & 0x9f;
                    if ((*q & 0x80) != (*p & 0x80)) *p ^= 0x60;
                    p++;
                    q++;
                }
            }
        }
        break;
    case 1:
        for (y = y0; y <= r->y1; y++) {
            p = OFFSCREEN_BUFFER_1[y] + r->x0;
            for (x = r->x0; x <= r->x1; x++) {
                if (*p & 0x80) *p |= 0x20;
                else *p &= ~0x20;
                p++;
            }
        }
        break;
    case 2:
        if (r->y1 - y0 == 0xef && r->x1 - r->x0 == 0x13f) {
            p = OFFSCREEN_BUFFER_1[0];
            for (i = 0; i < 0x12c00; i++) {
                if (*p & 0x80) *p |= 0x40;
                else *p &= ~0x40;
                p++;
            }
        } else {
            for (y = y0; y <= r->y1; y++) {
                p = &OFFSCREEN_BUFFER_1[y][r->x0];
                for (x = r->x0; x <= r->x1; x++) {
                    if (*p & 0x80) *p |= 0x40;
                    else *p &= ~0x40;
                    p++;
                }
            }
        }
        break;
    }
    SetChangeRect(r);
}
