/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m273c.c (2026-11-19-9-p6-r40)
   sha256 a488f89f2b5fd7a0a800d06397c14f10c0b6eb8f0637ff2c3e5ce36d2c0c40ff (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString();
extern void DrawBox(struct rect *, int);
void DrawStringReverse(struct rect *clip, struct pt *pos, char *s, long font, int fill, int fg,
                       unsigned char align, int hilite)
{
    struct rect box;
    struct pt pt;
    struct rect *bp;
    struct pt *pp;
    int w;
    int h;
    int d;
    int c;

    pt = *pos;
    w = CalcTotalWidth(s, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    c = GetCenteredDelta(font);
    pt.y -= (h - d) / 2;
    pt.y += c;
    switch (align) {
    case 0:
        pt.x -= w / 2;
        break;
    case 1:
        pt.x = clip->x0 + 4;
        break;
    case 2:
        pt.x = clip->x1 - 4 - w;
        break;
    }
    box.y0 = pt.y - 2 - c * 2;
    box.x0 = pt.x - 3;
    box.x1 = pt.x + w + 3;
    box.y1 = pt.y + h + c;
    if (box.y0 < clip->y0)
        box.y0 = clip->y0;
    if (box.x0 < clip->x0)
        box.x0 = clip->x0;
    if (box.x1 > clip->x1)
        box.x1 = clip->x1;
    if (box.y1 > clip->y1)
        box.y1 = clip->y1;
    if (box.y0 > box.y1)
        return;
    if (box.x0 > box.x1)
        return;
    if (hilite != 0) {
        DrawBox(&box, fill);
        if (fg == 0xf5)
            DrawString(&box, &pt, s, font, 0, 0xf7);
        else
            DrawString(&box, &pt, s, font, fg, 0xf7);
    } else {
        DrawBox(&box, fg);
        bp = &box;
        pp = &pt;
        DrawString(bp, pp, s, font, fill, 0xf7);
    }
}
