/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m274c.c (2026-11-19-9-p6-r40)
   sha256 23b8683e6034d39edb9027d3e1e0c61f255b28677a497092940fb602fee07488 (tar-sha256); compiled at -O3 -Xr */
struct glyph { unsigned char w; unsigned char f1; unsigned char f2; unsigned char f3; };
struct font { int width; int f2; long f4; long f8; struct glyph *glyphs; };
#define FONTS ((struct font *)0x945c00L)
extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void ConvertStrings(char *src, char *dst);
int CalcTotalWidth(char *s, long font)
{
    char *p;
    char *buf;
    struct font *f;
    struct glyph *q;
    struct glyph *g;
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
