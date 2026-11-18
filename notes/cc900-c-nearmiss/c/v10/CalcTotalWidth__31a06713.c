/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m274a.c (2026-11-18-28-p6-r36)
   sha256 31a0671339afdd7cc1d69148971d54f3fcb471acb497c47ba82fe2d435ed69f0 (tar-sha256); compiled at -O3 -Xr */
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
        for (q = g, i = 0; i < n; q = g, i++) {
            q += (unsigned char)(p[i] - 0x20);
            w += q->w;
        }
    }
    Free(buf);
    return w;
}
