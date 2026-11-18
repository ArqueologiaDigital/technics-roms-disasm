/* FORM B of p6_I_3m274a.c: the glyph pointer reset as the body's last statement.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 3, module 274, form a.  Refines CalcTotalWidth (p6_I_1m274a/b.c; run
   2026-11-18-12-p6-r35: +64 at O3Xr, everything before the glyph loop matched).  In the loop the ROM keeps the
   glyph table in XBC and a second glyph pointer in XIX that is set from it before the loop and again after each
   addition (`ld xix,xbc` just before the index increment), stepped with lda (xix+wa) and read through; V4.23
   indexed the table register directly.  Here that pointer is reset in the for's increment:
   `for (q = g, i = 0; i < n; q = g, i++) { q += c; w += q->w; }`.  Form b: the reset as the body's last statement. */
/* cc900-module: ConvertStrings */

struct glyph { unsigned char w; unsigned char f1; unsigned char f2; unsigned char f3; };
struct font { int width; int f2; long f4; long f8; struct glyph *glyphs; };

#define FONTS ((struct font *)0x945c00L)

extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);

int CalcTotalWidth(char *s, long font)
{
    char *p;
    char *buf;
    struct font *f;
    struct glyph *g;
    struct glyph *q;
    int w;
    int n;
    int i;

    buf = (char *)Malloc(Strlen(s) + 1);
    p = buf;
    ConvertStrings(s, buf);
    f = &FONTS[font];
    n = Strlen(buf);
    if ((g = f->glyphs) == 0)
        w = n * f->width;
    else {
        w = 0;
        q = g;
        for (i = 0; i < n; i++) {
            q += (unsigned char)(p[i] - 0x20);
            w += q->w;
            q = g;
        }
    }
    Free(buf);
    return w;
}
