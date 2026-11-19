/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m265d.c (2026-11-19-9-p6-r40)
   sha256 bed9383170d8e7000046aeda3a60e4066da869ac975df0163a5f58c802fae9b5 (tar-sha256); compiled at -O3 -Xr */
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
    struct fdlay pt;
    int found;
    int x;
    int row;

    FDemoText_ScaleDownCoords(&ram_25b3a, &pt);
    x = GetCenteredDelta(ram_25b40[ram_25b3e]);
    pt.y += (GetCharHeight(ram_25b40[ram_25b3e]) + x) / 4 + 1;
    if (pt.y >= 60)
        return 0;
    found = -1;
    x = pt.x;
    row = pt.y * 40;
    while (x > 0) {
        if (ram_251da[row + --x] != 84)
            break;
        found = x;
    }
    if (found == -1)
        for (; x < 40; x++)
            if (ram_251da[row + x] == 84) {
                found = x;
                break;
            }
    if (found == -1)
        return 0;
    pt.x = found;
    FDemoText_ScaleUpCoords(&pt, &ram_25b3a);
    return 1;
}
