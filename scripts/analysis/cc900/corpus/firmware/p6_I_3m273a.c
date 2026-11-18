/* Phase 6, lane_p6 helper I, round 3, module 273, form a.  Refines four round-1 functions (run 2026-11-18-12-p6-r35;
   the ClipBlit pair's notes are above their definitions at the end).
   - ApDeliveryEvent (+14 at O3Xr; round 1's form a was +12): V4.23 loaded both queue indices before the compare
     (w in DE, r in BC, w + 1 in WA); the ROM loads w into WA, forms w + 1 in DE, and only then loads the read index.
     Here the read index is no variable: `w + 1 == ram_2ec34 || w - 0x3ff == ram_2ec34`.  The ROM also loads the
     Wait argument in both predecessors of the loop's test (entry: `ld wa,4; jr`), where V4.23 put it in the test
     block; form b tries the wait inside a comma-expression while condition (test copied by -O3, then merged?).
   - DrawBox_Impl (+21 at O3Xr; the jrl displacement, so the code differs further on): V4.23 formed the screen
     address in the frame and added the base 0x43c00 to memory; the ROM computes the offset, loads the base as an
     immediate into XIY and adds (lane_hd's converted pointer): `dst = (void *)&OFFSCREEN_BUFFER_1[y][x]` with the
     buffer an extern array of 320-byte rows.  The wallpaper source stays round 1's form b row pointer (its src++
     gave the ROM's `ld xwa,0x140; add (m),xwa`). */
/* cc900-module: ApPostEvent SetChangeRect */

#define EVT_DELIVERY_EVENT 0x1c00037L
#define EVT_AUTO_FREE 0x1e00023L

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int ClipBlit_DiscHalfWidth[32];
extern int __cdecl Math_AbsInt16(int);
extern void ClipBlit_Replace_Impl(struct pt *c, int r);
extern void ClipBlit_Direct_Impl(struct pt *c, int r);
struct ev { long obj; long evt; long par; };

extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[][320];
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void *__cdecl Malloc(unsigned int);
extern void SetChangeRect(struct rect *r);
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern int Boot_CheckConfigFlag7(void);
extern void Kernel_YieldRotate(int);
extern long ApPostEvent(long, long, long);
extern void DrawBox_Impl(struct rect *r, int color);
extern void ApDeliveryEvent(long obj, long evt, long par);

void DrawBox_Impl(struct rect *r, int color)
{
    unsigned char *dst;
    unsigned char (*src)[320];
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
    dst = (void *)&OFFSCREEN_BUFFER_1[r->y0][r->x0];
    w = r->x1 - r->x0 + 1;
    if (color == 0xf5) {
        src = (unsigned char (*)[320])&((unsigned char (*)[320])WALLPAPER_BITMAP)[r->y0][r->x0];
        for (y = r->y0; y <= r->y1; y++) {
            Mem_Copy(dst, src, w);
            src++;
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

void ApDeliveryEvent(long obj, long evt, long par)
{
    struct ev *m;
    int w;

    goto test;
    do {
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
test:
        TaskEvent_Wait(4);
        w = ram_2ec36;
    } while (w + 1 == ram_2ec34 || w - 0x3ff == ram_2ec34);
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

/* ClipBlit_Replace_Impl / ClipBlit_Direct_Impl, refined (round 1: Replace +108 at Xr, everything up to the row
   address matched; Direct +120 at O3Xr / +1 at Xr).  The ROM shares only y0 * 320 (exts, sll-scaled) between the
   two buffer addresses, re-extends x0 for the source, keeps (long)y0 for the row counter, computes 30 - k once and
   both copy addresses before pushing, keeps y0 + h from the last loop test for the rectangle, and fills the
   rectangle through a pointer.  At -Xr those come from explicit locals (V4.23 does no CSE there): ly, row, o, d,
   s, ye, rp.  The half-width table is a sized array (16-bit index, lda base).  The source starts as the constant
   and gets the offset added in memory, as two statements. */
void ClipBlit_Replace_Impl(struct pt *c, int r)
{
    int x0;
    int w;
    int h;
    unsigned long y;
    unsigned long src;
    unsigned char *dst;
    struct rect rc;
    int y0;
    long ly;
    unsigned long row;
    int k;
    int o;
    unsigned char *d;
    unsigned long s;
    int ye;
    struct rect *rp;

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
    ly = y0;
    row = (unsigned long)ly * 320;
    dst = &OFFSCREEN_BUFFER_1[0][0] + (row + x0);
    src = 0x56800L;
    src += row + x0;
    for (y = ly; y < (ye = y0 + h); y++) {
        k = ClipBlit_DiscHalfWidth[Math_AbsInt16((int)(y - c->y))];
        o = 30 - k;
        d = dst + o;
        s = src + o;
        Mem_Copy(d, (void *)s, k * 2);
        src += 320;
        dst += 320;
    }
    rp = &rc;
    rp->y0 = y0;
    rp->x0 = x0;
    rp->x1 = x0 + w;
    rp->y1 = ye;
    SetChangeRect(rp);
}

void ClipBlit_Direct_Impl(struct pt *c, int r)
{
    int x0;
    int w;
    int h;
    unsigned long y;
    unsigned long src;
    unsigned char *dst;
    struct rect rc;
    int y0;
    long ly;
    unsigned long row;
    int ye;
    struct rect *rp;

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
    ly = y0;
    row = (unsigned long)ly * 320;
    dst = &OFFSCREEN_BUFFER_1[0][0] + (row + x0);
    src = 0x69800L;
    src += row + x0;
    for (y = ly; y < (ye = y0 + h); y++) {
        Mem_Copy(dst, (void *)src, w);
        src += 320;
        dst += 320;
    }
    rp = &rc;
    rp->y0 = y0;
    rp->x0 = x0;
    rp->x1 = x0 + w;
    rp->y1 = ye;
    SetChangeRect(rp);
}
