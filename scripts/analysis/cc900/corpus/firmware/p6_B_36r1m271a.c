/* Probe round 36r1, helper B, form a: ui/ui_window_procs.s (module 271), the xr_screen.py shape at -O3 -Xr.
   The pooled stretch "DrawDesignFrame" (536 B) holds two functions:
   DrawDesignFrame(r, style, thick, color): style 1 only: thick passes of DrawFrame on a copy of the rectangle,
   shrinking it by a pixel per side after each (the pass counter is a `register` long: XIZ).
   EditSw_ByteData(obj): the edit switch's label: its marker string ("~7f" left column, "~80" right column, "~81"
   bottom row) is copied into a local buffer and into the instance's string (reallocated when the old one is
   shorter), and the instance's rectangle is placed against the switch's point by the string's width and the
   font height.  A twin of the built DrawEditSw (ui_window_procs_m271.c) with the instance's string and font;
   the instance pointer is held twice on the frame (+8 and a copy at +2, which gives the switch id and takes the
   last coordinate).  Frame order: the rectangle declared first (highest, +22), then the point, the buffer, the
   instance pointer, the width, the copy (+2). */
/* cc900-module: GetEditSwPoint */

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct esvi { unsigned char pad[14]; struct rect r; char *str; long font; int i30; unsigned int id; };

extern void DrawFrame(struct rect *r, int n);
extern void DrawDesignFrame(struct rect *, int, int, int);
extern void *GetViewInstance(long);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern char *__cdecl Strcpy(char *, char *);
extern unsigned int __cdecl Strlen(char *);
extern void *__cdecl Malloc(unsigned int);
extern char EditSw_ByteData_Str_N7f[];
extern char EditSw_ByteData_Str_N80[];
extern char EditSw_ByteData_Str_N81[];
extern void EditSw_ByteData(long);

void DrawDesignFrame(struct rect *r, int style, int thick, int color)
{
    struct rect b;
    register long i;

    b = *r;
    if (style == 1)
        for (i = 0; i < thick; i++) {
            DrawFrame(&b, color);
            b.y1++;
            b.y2--;
            b.x1++;
            b.x2--;
        }
}

void EditSw_ByteData(long obj)
{
    struct rect r;
    struct pt pt;
    char s[6];
    struct esvi *h;
    int w;
    struct esvi *e;
    int hg;

    h = GetViewInstance(obj);
    e = h;
    GetEditSwPoint(e->id, &pt);
    Strcpy(s, pt.y != 0xef ? (pt.x == 0 ? EditSw_ByteData_Str_N7f : EditSw_ByteData_Str_N80) : EditSw_ByteData_Str_N81);
    if (Strlen(s) < Strlen(h->str))
        h->str = Malloc(Strlen(s) + 1);
    Strcpy(h->str, s);
    w = CalcTotalWidth(h->str, h->font);
    hg = GetCharHeight(h->font);
    if (pt.x == 0) {
        r.x1 = -2;
        r.y1 = pt.y - hg / 2;
    }
    if (pt.x == 0x13f) {
        r.x1 = 0x13e - w;
        r.y1 = pt.y - hg / 2;
    }
    if (pt.y == 0xef) {
        r.x1 = pt.x - w / 2 - 1;
        r.y1 = 0xf5 - hg;
    }
    r.x2 = w + r.x1 + 1;
    r.y2 = hg + r.y1;
    h->r.y1 = r.y1;
    h->r.y2 = r.y2;
    h->r.x1 = r.x1;
    e->r.x2 = r.x2;
}
