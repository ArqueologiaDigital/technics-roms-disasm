/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/graphics_text_vga_m274.c (2026-11-19-29-p6-r46)
   sha256 4ec8cd96368bfb5f4c097dc7c4b6373a98e73ffbdddea8a0e06a0b6d98200450 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct glyph { unsigned char w; unsigned char f1; unsigned char f2; unsigned char f3; };
struct font { int width; int f2; long f4; long f8; struct glyph *glyphs; };
#define FONTS ((struct font *)0x945c00L)
extern int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void ConvertStrings(char *src, char *dst);
int CalcTotalWidth(char *s, long font)
{
    struct glyph *q;
    int i;
    char *p;
    char *buf;
    struct font *f;
    struct glyph *g;
    int w;
    int n;

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
