/* Phase 6, lane_p6 helper I, round 1, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a.  All new.
   - DrawBox_Impl (ui/drawing_primitives.s): clips the box to 320x240, then fills it row by row with Memset, or, for
     colour 0xf5, copies the wallpaper's rows (Mem_Copy).  The ROM scales y by 320 with sll (array index scaling,
     helper G's finding) and shares that product between the screen and wallpaper addresses (CSE, so -O3 -Xr);
     the screen is a constant row pointer (ld immediate), the wallpaper source steps with `ld xwa,0x140; add (m),xwa`
     where the screen pointer steps with lda +320: here the source is an unsigned long, the screen an unsigned char *.
   - ClipBlit_Replace_Impl / ClipBlit_Direct_Impl (ui/ui_window_procs.s): clip a 2r x 2r square around the point,
     then copy it row by row into OFFSCREEN_BUFFER_1 from OFFSCREEN_BUFFER_2 (Replace: only the disc's span, widths
     from ClipBlit_DiscHalfWidth) or from 0x69800 (Direct: the whole row), and mark the rectangle changed.
     The row counter is an unsigned long (exts + unsigned jr c); both buffer pointers step by `add (m),xwa` with one
     0x140 constant: here the destination is a 320-byte row pointer, the source an unsigned long.
   - ApDeliveryEvent (ui/ui_widget_defs.s): PostEvent's twin that wraps a targeted event in a 12-byte Malloc block
     posted as EVT_DELIVERY_EVENT to -1, waits (yielding) while the queue is full, and posts EVT_AUTO_FREE for the
     block after the signal.  The wait loop is entered at its test (goto). */
/* cc900-module: ApPostEvent SetChangeRect */

#define VRAM ((unsigned char (*)[320])0x43c00L)
#define VRAM2 ((unsigned char (*)[320])0x56800L)
#define VRAM5 ((unsigned char (*)[320])0x69800L)
#define EVT_DELIVERY_EVENT 0x1c00037L
#define EVT_AUTO_FREE 0x1e00023L

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct ev { long obj; long evt; long par; };

extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern int ClipBlit_DiscHalfWidth[];
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern int __cdecl Math_AbsInt16(int);
extern void *__cdecl Malloc(unsigned int);
extern void SetChangeRect(struct rect *r);
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern int Boot_CheckConfigFlag7(void);
extern void Kernel_YieldRotate(int);
extern long ApPostEvent(long, long, long);
extern void DrawBox_Impl(struct rect *r, int color);
extern void ClipBlit_Replace_Impl(struct pt *c, int r);
extern void ClipBlit_Direct_Impl(struct pt *c, int r);
extern void ApDeliveryEvent(long obj, long evt, long par);

void DrawBox_Impl(struct rect *r, int color)
{
    unsigned char *dst;
    unsigned long src;
    int w;
    int y;

    if (r->x0 > r->x1)
        return;
    if (r->y0 > r->y1)
        return;
    if (r->y0 < 0)
        r->y0 = 0;
    if (r->x0 < 0)
        r->x0 = 0;
    if (r->x1 >= 320)
        r->x1 = 319;
    if (r->y1 >= 240)
        r->y1 = 239;
    if (color == 0xf7)
        return;
    dst = &VRAM[r->y0][r->x0];
    w = r->x1 - r->x0 + 1;
    if (color == 0xf5) {
        src = (unsigned long)&((unsigned char (*)[320])WALLPAPER_BITMAP)[r->y0][r->x0];
        for (y = r->y0; y <= r->y1; y++) {
            Mem_Copy(dst, (void *)src, w);
            src += 320;
            dst += 320;
        }
    } else {
        for (y = r->y0; y <= r->y1; y++) {
            Memset(dst, color, w);
            dst += 320;
        }
    }
    SetChangeRect(r);
}

void ClipBlit_Replace_Impl(struct pt *c, int r)
{
    int x0;
    int w;
    int h;
    unsigned long y;
    unsigned long src;
    unsigned char (*dst)[320];
    struct rect rc;
    int y0;
    int k;

    h = r;
    h += r;
    w = h;
    x0 = c->x - r;
    if (x0 < 0) {
        w += x0;
        x0 = 0;
    } else if (x0 + h >= 320)
        w = 319 - x0;
    y0 = c->y - r;
    if (y0 < 0) {
        h += y0;
        y0 = 0;
    } else if (y0 + h >= 240)
        h = 239 - y0;
    dst = (unsigned char (*)[320])&OFFSCREEN_BUFFER_1[y0][x0];
    src = (unsigned long)&VRAM2[y0][x0];
    for (y = y0; y < y0 + h; y++) {
        k = ClipBlit_DiscHalfWidth[Math_AbsInt16((int)(y - c->y))];
        Mem_Copy(&(*dst)[30 - k], (void *)(src + (30 - k)), k * 2);
        src += 320;
        dst++;
    }
    rc.y0 = y0;
    rc.x0 = x0;
    rc.x1 = x0 + w;
    rc.y1 = y0 + h;
    SetChangeRect(&rc);
}

void ClipBlit_Direct_Impl(struct pt *c, int r)
{
    int x0;
    int w;
    int h;
    unsigned long y;
    unsigned long src;
    unsigned char (*dst)[320];
    struct rect rc;
    int y0;

    h = r;
    h += r;
    w = h;
    x0 = c->x - r;
    if (x0 < 0) {
        w += x0;
        x0 = 0;
    } else if (x0 + h >= 320)
        w = 319 - x0;
    y0 = c->y - r;
    if (y0 < 0) {
        h += y0;
        y0 = 0;
    } else if (y0 + h >= 240)
        h = 239 - y0;
    dst = (unsigned char (*)[320])&OFFSCREEN_BUFFER_1[y0][x0];
    src = (unsigned long)&VRAM5[y0][x0];
    for (y = y0; y < y0 + h; y++) {
        Mem_Copy(dst, (void *)src, w);
        src += 320;
        dst++;
    }
    rc.y0 = y0;
    rc.x0 = x0;
    rc.x1 = x0 + w;
    rc.y1 = y0 + h;
    SetChangeRect(&rc);
}

void ApDeliveryEvent(long obj, long evt, long par)
{
    struct ev *m;
    int w;
    int r;

    goto test;
    do {
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
test:
        TaskEvent_Wait(4);
        w = ram_2ec36;
        r = ram_2ec34;
    } while (w + 1 == r || w - 0x3ff == r);
    if (obj != -1) {
        m = (struct ev *)Malloc(12);
        m->obj = obj;
        m->evt = evt;
        m->par = par;
        obj = -1;
        evt = EVT_DELIVERY_EVENT;
        par = (long)m;
    } else
        m = 0;
    ram_2f840++;
    EVENT_QUEUE[ram_2ec36].obj = obj;
    EVENT_QUEUE[ram_2ec36].evt = evt;
    EVENT_QUEUE[ram_2ec36].par = par;
    if (ram_2ec36 == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36++;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
    if (m != 0)
        ApPostEvent(-1, EVT_AUTO_FREE, (long)m);
}
