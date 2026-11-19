/* lane_p6 round 5 (2026-11-19): p6_P_4m265c.c (r40: +87; x now in the ROM's IZ, found in IX where the ROM has IY)
   with x declared before found.
   lane_p6 round 4 (2026-11-19): p6_P_3m265b.c (r39: +87, the declaration order now gives found the ROM's IY) with
   one variable for the centring delta and the column: the ROM keeps both in IZ.  Form c keeps the grid pointer.
   FORM B of p6_P_3m265a.c: the grid pointer declared first, found before x.  Original notes follow.
   FORM B of p6_I_4m265a.c (the left walk's decrement inside the index, row + --x).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 4, module 265 (demo/fdemotext_routines.s, -O3 -Xr), form a.  New.
   FDemoText_UpdateCursorPosition(): takes the text cursor (ram_25b3a) into grid units, moves it down by a quarter
   of the font's height + centring delta (+1), and if still inside the 60-row grid at 0x251da looks for the nearest
   'T' cell (84) to the left of the column (walking left while the cells are 'T'), else to the right; stores the
   column found and scales the cursor back.  1 when found, else 0.  Declarations as in the staged
   FDemoText_RenderTextLine (fdemotext_routines_m265.c).
   Read from the hand assembly: the grid point in the frame, the column in IZ, the found column in IY, the row
   offset y * 40 in HL (muls), the leftward cell index strength-reduced (-O3); both searches test at entry.
   Form b: the left walk as a for loop with the break test first. */
/* cc900-module: FDemoText_ScaleDownCoords FDemoText_ScaleUpCoords */

struct fdlay { int x, y; };

extern struct fdlay ram_25b3a;
extern long ram_25b40[8];
extern int ram_25b3e;
extern unsigned char ram_251da[2400];
extern int GetCharHeight(long);
extern int GetCenteredDelta(long);
extern void FDemoText_ScaleDownCoords(struct fdlay *s, struct fdlay *d);
extern void FDemoText_ScaleUpCoords(struct fdlay *s, struct fdlay *d);
extern int FDemoText_UpdateCursorPosition(void);

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
