/* FORM B of p6_I_1m274a.c: the glyph index through an unsigned char local.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 1, module 274 (display/graphics_text_vga.s), form a.  New.
   CalcTotalWidth(s, font): converts s into a Malloc'd copy (ConvertStrings), then measures it in the font record
   at 0x945c00 + font * 16: a fixed-pitch font (no glyph table at +12) is len * width (muls hl,(xiz)); otherwise the
   sum of the first byte of each glyph's 4-byte record, indexed by the character - 0x20 (a byte sub, then extz).
   Frees the copy and returns the width.
   Read from the hand assembly: the copy kept twice in the frame (+8 the Malloc result, +4 the pointer the loop
   reads), the font as a long in the frame, the font record in XIZ, the width in IZ, the index in DE, the length in
   HL; the loop test copied to its entry (-O3).  Form b: the glyph index through an unsigned char local. */
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
    int w;
    int n;
    int i;
    unsigned char c;

    buf =(char *)Malloc(Strlen(s) + 1);
    p = buf;
    ConvertStrings(s, buf);
    f = &FONTS[font];
    n = Strlen(buf);
    if ((g = f->glyphs) == 0)
        w = n * f->width;
    else {
        w = 0;
        for (i = 0; i < n; i++) {
            c = p[i] - 0x20;
            w += g[c].w;
        }
    }
    Free(buf);
    return w;
}
