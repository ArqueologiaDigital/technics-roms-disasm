/* Phase 6, lane_p6, round 3 (2026-11-19), module 273, form a: the DrawString call setup of three close misses.
   DrawStringCentered (+122, p6_I_2m273b), DrawStringRightJustify (+121, p6_J_3m273a) and DrawStringReverse (+311,
   p6_I_2m273b) all differ at the DrawString call only: the ROM computes the frame-address arguments (the buffer,
   &box, &pt: `lda`) BEFORE pushing the stack arguments and loads the plain ones (clip, s) after; V4.23, given a
   prototype, does every register argument after the pushes.  Here DrawString has NO prototype (K&R call). */
/* cc900-module: DrawBox DrawString */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString();
extern void DrawBox(struct rect *, int);
extern void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg);
extern void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b);
extern void DrawStringReverse(struct rect *clip, struct pt *pos, char *s, long font, int fill, int fg,
                              unsigned char align, int hilite);

void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg)
{
    struct pt pt;
    char buf[256];
    int h;
    int w;
    int d;

    ConvertStrings(s, buf);
    w = CalcTotalWidth(buf, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    pt = *pos;
    pt.x -= w / 2;
    pt.y -= (h - d) / 2;
    pt.y += GetCenteredDelta(font);
    DrawString(clip, &pt, buf, font, fg, bg);
}

void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
    int w;
    int h;
    int d;
    struct pt at;
    char buf[256];

    ConvertStrings(s, buf);
    w = CalcTotalWidth(buf, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    at = *p;
    at.x = r->x1 - 4 - w;
    at.y -= (h - d) / 2;
    at.y += GetCenteredDelta(font);
    DrawString(r, &at, buf, font, a, b);
}

void DrawStringReverse(struct rect *clip, struct pt *pos, char *s, long font, int fill, int fg,
                       unsigned char align, int hilite)
{
    struct rect box;
    struct pt pt;
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
        DrawString(&box, &pt, s, font, fill, 0xf7);
    }
}
