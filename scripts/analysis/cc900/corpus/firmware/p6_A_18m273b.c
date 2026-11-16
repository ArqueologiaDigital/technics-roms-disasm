/* cc900-module: GetCurrentTarget GetEvent InitGraphics_SetupVRAM_Loop LcdOn_Return MainGetEvent */
/* Phase 6, lane_p6 helper A, round 18, form b: module 273 (ui/ui_widget_defs.s), the synchronous event dispatchers
   SendEvent, DispatchEvent and MainDispatchEvent (new).  Form b: the saves declared in FOCUS order, chained
   FOCUS/ROOT assignments, one `if (a && b)` instead of two continues, the object ids unsigned, and the class
   record reached through a macro. */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern unsigned long FOCUS_OBJECT, ROOT_OBJECT;
extern long FOCUS_EVENT, FOCUS_PARAM, ROOT_EVENT, ROOT_PARAM;
extern unsigned long GetCurrentTarget(void);
extern int GetEvent(unsigned long *obj, long *evt, long *par);
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
extern void Kernel_YieldRotate(int);
#define EVT_GET_CLASS_SP 0x1e00000L
#define OBJENT(id) (&OBJECT_REGISTRY[(unsigned int)(((id) >> 16) & 0xfff)])
#define CLASSREC(id) (&((struct clsrec *)OBJENT(id)->data)[(unsigned int)((id) & 0xffff)])

long SendEvent(unsigned long obj, long evt, long par)
{
    unsigned long sobj;
    long sevt, spar;
    unsigned long scls;
    long (*proc)(unsigned long, long, long);
    unsigned long cls;
    long r;
    if (obj == 0xffffffffUL)
        obj = GetCurrentTarget();
    proc = OBJENT(obj)->proc;
    sobj = FOCUS_OBJECT;
    sevt = FOCUS_EVENT;
    spar = FOCUS_PARAM;
    FOCUS_OBJECT = obj;
    FOCUS_EVENT = evt;
    FOCUS_PARAM = par;
    scls = ram_2bc14;
    cls = proc(obj, EVT_GET_CLASS_SP, 0);
    ram_2bc14 = cls;
    r = CLASSREC(cls)->proc(obj, evt, par);
    ram_2bc14 = scls;
    FOCUS_OBJECT = sobj;
    FOCUS_EVENT = sevt;
    FOCUS_PARAM = spar;
    if (ram_3ef4e != 0)
        Kernel_YieldRotate(3);
    return r;
}

void DispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    long (*proc)(unsigned long, long, long);
    unsigned long cls;
    while (GetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL && (proc = OBJENT(obj)->proc) != 0) {
            ROOT_OBJECT = FOCUS_OBJECT = obj;
            ROOT_EVENT = FOCUS_EVENT = evt;
            ROOT_PARAM = FOCUS_PARAM = par;
            cls = proc(obj, EVT_GET_CLASS_SP, 0);
            ram_2bc14 = cls;
            CLASSREC(cls)->proc(obj, evt, par);
            if (ram_3ef4e != 0)
                Kernel_YieldRotate(3);
        }
    }
}

void MainDispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    unsigned int t, i;
    long (**tab)(unsigned long, long, long);
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            t = (unsigned int)((obj >> 16) & 0xfff);
            i = (unsigned int)(obj & 0xffff);
            tab = (long (**)(unsigned long, long, long))OBJECT_REGISTRY[t].data;
            tab[i](obj, evt, par);
        }
    }
}

/* The screen update (see form a).  Form b: an explicit pointer to the palette entry set before each loop, early
   return, the rectangle through a pointer, and the 0x30462 reset written once after the if. */
struct rect { int x0, y0, x1, y1; };
extern int ram_3ef92;
extern int ram_30462;
extern int DISPLAY_UPDATE_FLAG;
extern int PALETTE_UPDATE_FLAG;
extern int PALETTE_INDEX_CACHED;
extern int PALETTE_INDEX_PREVIOUS;
extern struct rect DIRTY_BBOX;
extern void LcdOn_Return(void);
extern void InitGraphics_SetupVRAM_Loop(void);
extern unsigned long Table_LookupDword(int i);
extern void VGA_WritePaletteEntry(unsigned char i, unsigned long *rgb);
extern void AllBOut(void);
extern void DisplayBuffer_Process(void);

void Gfx_BlitDirtyRegions(void)
{
    unsigned long *pe;
    unsigned long ent;
    unsigned int i;
    struct rect *r;
    if (ram_3ef92 == 0 || DISPLAY_UPDATE_FLAG == 0)
        return;
    if (PALETTE_UPDATE_FLAG != 0) {
        if (PALETTE_INDEX_CACHED != 4 || PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4) {
            LcdOn_Return();
            pe = &ent;
            for (i = 0; i < 0x100; i++) {
                *pe = Table_LookupDword(i);
                VGA_WritePaletteEntry(i, pe);
            }
        }
    } else if (ram_30462 != 0) {
        pe = &ent;
        for (i = 0xe0; i < 0xf0; i++) {
            *pe = Table_LookupDword(i);
            VGA_WritePaletteEntry(i, pe);
        }
    }
    r = &DIRTY_BBOX;
    if (r->y1 - r->y0 == 0xef && r->x1 - r->x0 == 0x13f)
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
    r = &DIRTY_BBOX;
    r->y0 = 0xf0;
    r->x0 = 0x140;
    r->x1 = -1;
    r->y1 = -1;
}
