/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_5m265e.c (2026-11-19-19-p6-r43)
   sha256 e2f22101f057195d41b3781f66b0664471a2232d4c0f253340878e7c5037bdba (tar-sha256); compiled at -O3 -Xr */
struct fdlay { int x, y; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[8];
extern int ram_25b3e;
extern unsigned char ram_251da[2400];
extern int GetCharHeight(long);
extern int GetCenteredDelta(long);
extern void FDemoText_ScaleDownCoords(struct fdlay *s, struct fdlay *d);
extern void FDemoText_ScaleUpCoords(struct fdlay *s, struct fdlay *d);
int FDemoText_UpdateCursorPosition(void)
{
    unsigned char *g;
    struct fdlay pt;
    int x;
    int found;
    int row;

    FDemoText_ScaleDownCoords(&ram_25b3a, &pt);
    x = GetCenteredDelta(ram_25b40[ram_25b3e]);
    pt.y += (GetCharHeight(ram_25b40[ram_25b3e]) + x) / 4 + 1;
    if (pt.y >= 60)
        return 0;
    found = -1;
    x = pt.x;
    g = ram_251da;
    row = pt.y * 40;
    while (x > 0) {
        if (g[row + --x] != 84)
            break;
        found = x;
    }
    if (found == -1)
        for (; x < 40; x++)
            if (g[row + x] == 84) {
                found = x;
                break;
            }
    if (found == -1)
        return 0;
    pt.x = found;
    FDemoText_ScaleUpCoords(&pt, &ram_25b3a);
    return 1;
}
