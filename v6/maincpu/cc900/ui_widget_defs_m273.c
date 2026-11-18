/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawLineWithMode_Impl SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char DRAW_QUEUE[];
extern unsigned char *DRAW_QUEUE_WRITE_PTR;
extern void Kernel_SemaWait(int);
extern void Kernel_SemaSignal(int);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
struct ev { long obj; long evt; long par; };
extern struct ev ram_2ec38[];
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
#define MEVQ(i) ((struct ev *)&((char *)ram_2ec38)[(i) * 12])
extern int MainGetEvent(long *obj, long *evt, long *par);
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void PostEvent(long obj, long evt, long par);
struct rect { int x0, y0, x1, y1; };
extern int ram_3ef4a;
extern int DISPLAY_UPDATE_FLAG;
extern struct rect DIRTY_BBOX;
extern void Kernel_SetTaskLevel(int, int);
extern void SetChangeRect(struct rect *r);

unsigned char *DrawQueue_Alloc(unsigned int n)
{
    unsigned char *p;
    Kernel_SemaWait(4);
    if (DRAW_QUEUE_WRITE_PTR - DRAW_QUEUE + (long)n < 0x2000) {
        p = DRAW_QUEUE_WRITE_PTR;
        DRAW_QUEUE_WRITE_PTR += n;
    } else {
        p = DRAW_QUEUE;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE + n;
    }
    Kernel_SemaSignal(4);
    return p;
}

int MainGetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(7);
    if (ram_2f838 == ram_2f83a) {
        TaskEvent_Signal(7);
        return 0;
    }
    ram_2f842--;
    r = ram_2f838;
    e = MEVQ(r);
    *obj = e->obj;
    *evt = e->evt;
    *par = e->par;
    if (r == 0xff)
        ram_2f838 = 0;
    else
        ram_2f838++;
    TaskEvent_Signal(7);
    return 1;
}

void PostEvent(long obj, long evt, long par)
{
    int r, w;
    struct ev *e;
    TaskEvent_Wait(4);
    r = ram_2ec34;
    w = ram_2ec36;
    if (w + 1 == r || w - 0x3ff == r) {
        TaskEvent_Signal(4);
        for (;;)
            ;
    }
    ram_2f840++;
    e = (struct ev *)((char *)EVENT_QUEUE + w * 12);
    e->obj = obj;
    e->evt = evt;
    e->par = par;
    if (w == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36++;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
}

void SetChangeRect(struct rect *r)
{
    if (ram_3ef4a != 0)
        Kernel_SetTaskLevel(5, 3);
    DISPLAY_UPDATE_FLAG = 1;
    if (DIRTY_BBOX.y0 > r->y0)
        DIRTY_BBOX.y0 = r->y0;
    if (DIRTY_BBOX.x0 > r->x0)
        DIRTY_BBOX.x0 = r->x0;
    if (DIRTY_BBOX.x1 < r->x1)
        DIRTY_BBOX.x1 = r->x1;
    if (DIRTY_BBOX.y1 < r->y1)
        DIRTY_BBOX.y1 = r->y1;
}

/* cc900-module: DrawRing_TryPost GetCurrentTarget */
extern long GetCurrentTarget(void);
#define EVQ(i) ((struct ev *)&((char *)EVENT_QUEUE)[(i) * 12])
extern int GetEvent(long *obj, long *evt, long *par);

int GetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(4);
    if (ram_2ec34 == ram_2ec36) {
        TaskEvent_Signal(4);
        return 0;
    }
    --ram_2f840;
    r = ram_2ec34;
    *obj = EVQ(r)->obj;
    if (*obj == -1L)
        *obj = GetCurrentTarget();
    e = EVQ(r);
    *evt = e->evt;
    *par = e->par;
    if (r == 0x3ff)
        ram_2ec34 = 0;
    else
        ram_2ec34++;
    TaskEvent_Signal(4);
    return 1;
}

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))
extern int KillApTimer(long time, long obj, long target, long event, long param);

int KillApTimer(long time, long obj, long target, long event, long param)
{
    int i;
    int n;

    i = ram_30448;
    while (i != -1) {
        if (APTIMER(i)->obj == obj && APTIMER(i)->target == target && APTIMER(i)->event == event &&
            APTIMER(i)->param == param) {
            n = APTIMER(i)->next;
            if (n != -1)
                APTIMER(n)->prev = APTIMER(i)->prev;
            if (APTIMER(i)->prev != -1)
                APTIMER(APTIMER(i)->prev)->next = APTIMER(i)->next;
            if (i == ram_30448)
                ram_30448 = APTIMER(i)->next;
            APTIMER(i)->obj = -1;
            APTIMER(i)->next = -1;
            APTIMER(i)->prev = -1;
            return 1;
        }
        i = APTIMER(i)->next;
    }
    return 0;
}

/* cc900-module: InitGraphics_SetupVRAM_Loop LcdOn_Return */
extern int ram_3ef8e;
extern int ram_30462;
extern int PALETTE_UPDATE_FLAG;
extern int PALETTE_INDEX_CACHED;
extern int PALETTE_INDEX_PREVIOUS;
extern void LcdOn_Return(void);
extern void InitGraphics_SetupVRAM_Loop(void);
extern unsigned long Table_LookupDword(int i);
extern void VGA_WritePaletteEntry(int i, unsigned long *rgb);
extern void AllBOut(void);
extern void DisplayBuffer_Process(void);
extern void Gfx_BlitDirtyRegions(void);

void Gfx_BlitDirtyRegions(void)
{
    unsigned long *pe;
    unsigned long ent;
    unsigned int i;
    if (ram_3ef8e != 0 && DISPLAY_UPDATE_FLAG != 0) {
        if (PALETTE_UPDATE_FLAG != 0) {
            if (PALETTE_INDEX_CACHED != 4 || (PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4)) {
                LcdOn_Return();
                pe = &ent;
                for (i = 0; i < 0x100; i++) {
                    ent = Table_LookupDword(i);
                    VGA_WritePaletteEntry((unsigned char)i, pe);
                }
            }
        } else if (ram_30462 != 0) {
            pe = &ent;
            for (i = 0xe0; i < 0xf0; i++) {
                ent = Table_LookupDword(i);
                VGA_WritePaletteEntry((unsigned char)i, pe);
            }
        }
        if (DIRTY_BBOX.y1 - DIRTY_BBOX.y0 == 0xef && DIRTY_BBOX.x1 - DIRTY_BBOX.x0 == 0x13f)
            AllBOut();
        else
            DisplayBuffer_Process();
        if (PALETTE_UPDATE_FLAG != 0) {
            InitGraphics_SetupVRAM_Loop();
            PALETTE_INDEX_PREVIOUS = PALETTE_INDEX_CACHED;
            PALETTE_UPDATE_FLAG = 0;
            ram_30462 = 0;
        } else if (ram_30462 != 0)
            ram_30462 = 0;
        DISPLAY_UPDATE_FLAG = 0;
        DIRTY_BBOX.y0 = 0xf0;
        DIRTY_BBOX.x0 = 0x140;
        DIRTY_BBOX.x1 = -1;
        DIRTY_BBOX.y1 = -1;
    }
}

/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl DrawBitmapSPFast_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrame_Impl DrawIcons_Impl DrawQueue_Alloc DrawRing_Post Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern int IsXspInDrawStack(void);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int ram_30450;
extern void UpdateScreen_CheckDirty(void *q);
extern void UpdateScreen(void);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void UpdateScreen(void)
{
	void **q;

	if (IsXspInDrawStack() != 0) {
		Gfx_BlitDirtyRegions();
		if (ram_30450 == 0)
			DRAW_ENABLED = ram_30450;
	} else {
		q = (void **)DrawQueue_Alloc(4);
		*q = (void *)UpdateScreen_CheckDirty;
		DrawRing_Post(q);
	}
}
