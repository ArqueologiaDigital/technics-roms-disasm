/* FORM D of p6_P_4m273c.c: the same with DrawString's prototype.  Form c's notes follow.
   lane_p6 round 4 (2026-11-19), module 273: DrawStringReverse after r39 (p6_P_3m273a: +311, O3Xr).  The highlight
   branch now matches (V4.23 hoists the two calls' &box / &pt above the 0xf5 test, as the ROM does); the plain branch
   still pushes before the `lda`s.  Form c: DrawString without a prototype (as 3m273a), the plain branch passes &box
   and &pt through two locals of its own assigned just before the call (the `s = buf` spelling that made
   DrawStringCentered / RightJustify match in r39). */
/* cc900-module: DrawBox DrawString */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawBox(struct rect *, int);
extern void DrawStringReverse(struct rect *clip, struct pt *pos, char *s, long font, int fill, int fg,
                              unsigned char align, int hilite);

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
