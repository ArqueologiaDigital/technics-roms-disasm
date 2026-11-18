/* FORM B of p6_I_2m273a.c: DrawStringReverse's two empty-box tests are separate returns;
   DrawText_PopAndReturn_Code passes the record fields directly.
   Form a's notes follow.
   Phase 6, lane_p6 helper I, round 2, module 273, form a.  All new.
   - DrawStringCentered(clip, pos, s, font, fg, bg) (ui/drawing_primitives.s): converts s into a 256-byte frame buffer,
     centres a copy of *pos on the text (x - width/2, y - (height - descent)/2 + GetCenteredDelta) and draws it.
     Frame: the height at +2, the buffer at +4, the point at +260 (an address-taken local above the buffer: declared
     first), the parameters above.  The point is copied with two ldiw (a struct copy).
   - DrawStringReverse(clip, pos, s, font, fill, fg, align, hilite) (same file): aligns the point (align 0 centre,
     1 left, 2 right of clip; a switch compared last case first), builds the text box around it, clips the box to
     clip, fills it (DrawBox) and draws the string in 0xf7 on it.  Stack parameters are pushed left to right (the
     last at the lowest offset), so the C order is font, fill, fg, align, hilite.
   - DrawText_QueueOrDirect(r, p, s, font, a, b) and its deferred half DrawText_PopAndReturn_Code(q): on the draw
     task's stack draw at once (TextRender_BeginDraw, when DRAW_ENABLED); else copy s into the draw queue and post a
     30-byte command {thunk, *r, *p, copy, font, a, b, COLORBLIT_MODE}.  The thunk loads every argument from the
     record before it stores the mode and tests DRAW_ENABLED: here locals assigned up front. */
/* cc900-module: DrawBox DrawFunc_Return DrawQueue_Alloc DrawRing_Post DrawString IS_XSP_INSIDE_4K_REGION_AT_1C032 TextRender_BeginDraw */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct dq { void *fn; struct rect r; struct pt p; char *s; long font; int a; int b; unsigned char mode; };

extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int DRAW_ENABLED;
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawBox(struct rect *, int);
extern int __cdecl Strlen(char *);
extern char *__cdecl Strcpy(char *, char *);
extern int IS_XSP_INSIDE_4K_REGION_AT_1C032(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void DrawFunc_Return(void *p);
extern void TextRender_BeginDraw(struct rect *, struct pt *, char *, long, int, int);
extern void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg);
extern void DrawStringReverse(struct rect *clip, struct pt *pos, char *s, long font, int fill, int fg,
                              unsigned char align, int hilite);
extern void DrawText_QueueOrDirect(struct rect *r, struct pt *p, char *s, long font, int a, int b);
extern void DrawText_PopAndReturn_Code(struct dq *q);

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

void DrawText_QueueOrDirect(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
    char *buf;
    struct dq *q;

    if (IS_XSP_INSIDE_4K_REGION_AT_1C032() != 0) {
        COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
        if (DRAW_ENABLED != 0)
            TextRender_BeginDraw(r, p, s, font, a, b);
    } else {
        buf = (char *)DrawQueue_Alloc(Strlen(s) + 1);
        q = (struct dq *)DrawQueue_Alloc(30);
        q->fn = (void *)DrawText_PopAndReturn_Code;
        q->r = *r;
        q->p = *p;
        q->s = buf;
        Strcpy(buf, s);
        q->font = font;
        q->a = a;
        q->b = b;
        q->mode = COLORBLIT_MODE;
        DrawRing_Post(q);
    }
}

void DrawText_PopAndReturn_Code(struct dq *q)
{
    COLORBLIT_MODE_ACTIVE = q->mode;
    if (DRAW_ENABLED != 0)
        TextRender_BeginDraw(&q->r, &q->p, q->s, q->font, q->a, q->b);
    DrawFunc_Return(q->s);
}
