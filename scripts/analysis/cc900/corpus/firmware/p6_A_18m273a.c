/* cc900-module: GetCurrentTarget GetEvent InitGraphics_SetupVRAM_Loop LcdOn_Return MainGetEvent */
/* Phase 6, lane_p6 helper A, round 18, form a: module 273 (ui/ui_widget_defs.s), the synchronous event dispatchers
   SendEvent, DispatchEvent and MainDispatchEvent (new).  The object table entry is {class, table proc, count, data};
   a class table's data is an array of 24-byte class records {proc, parent, ...}, a main-function table's data an
   array of procs.  Form a: separate assignments, the FOCUS saves declared highest slot first. */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern long FOCUS_OBJECT, FOCUS_EVENT, FOCUS_PARAM;
extern long ROOT_OBJECT, ROOT_EVENT, ROOT_PARAM;
extern unsigned long GetCurrentTarget(void);
extern int GetEvent(long *obj, long *evt, long *par);
extern int MainGetEvent(long *obj, long *evt, long *par);
extern void Kernel_YieldRotate(int);
#define EVT_GET_CLASS_SP 0x1e00000L

long SendEvent(unsigned long obj, long evt, long par)
{
    long sevt, sobj, spar;
    unsigned long scls;
    long (*proc)(unsigned long, long, long);
    unsigned long cls;
    long r;
    if (obj == 0xffffffffUL)
        obj = GetCurrentTarget();
    proc = OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].proc;
    sobj = FOCUS_OBJECT;
    sevt = FOCUS_EVENT;
    spar = FOCUS_PARAM;
    FOCUS_OBJECT = obj;
    FOCUS_EVENT = evt;
    FOCUS_PARAM = par;
    scls = ram_2bc14;
    cls = proc(obj, EVT_GET_CLASS_SP, 0);
    ram_2bc14 = cls;
    r = ((struct clsrec *)OBJECT_REGISTRY[(unsigned int)((cls >> 16) & 0xfff)].data)
            [(unsigned int)(cls & 0xffff)].proc(obj, evt, par);
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
    long obj, evt, par;
    long (*proc)(unsigned long, long, long);
    unsigned long cls;
    while (GetEvent(&obj, &evt, &par) != 0) {
        if (obj == -1L)
            continue;
        proc = OBJECT_REGISTRY[(unsigned int)(((unsigned long)obj >> 16) & 0xfff)].proc;
        if (proc == 0)
            continue;
        FOCUS_OBJECT = obj;
        ROOT_OBJECT = obj;
        FOCUS_EVENT = evt;
        ROOT_EVENT = evt;
        FOCUS_PARAM = par;
        ROOT_PARAM = par;
        cls = proc(obj, EVT_GET_CLASS_SP, 0);
        ram_2bc14 = cls;
        ((struct clsrec *)OBJECT_REGISTRY[(unsigned int)((cls >> 16) & 0xfff)].data)
            [(unsigned int)(cls & 0xffff)].proc(obj, evt, par);
        if (ram_3ef4e != 0)
            Kernel_YieldRotate(3);
    }
}

void MainDispatchEvent(void)
{
    long obj, evt, par;
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != -1L)
            ((long (**)(unsigned long, long, long))
                OBJECT_REGISTRY[(unsigned int)(((unsigned long)obj >> 16) & 0xfff)].data)
                [(unsigned int)((unsigned long)obj & 0xffff)](obj, evt, par);
    }
}

/* The screen update: reloads the palette (all 256 entries when the palette index changed to or from 4, else entries
   0xe0..0xef when 0x30462 asks for it), sends the dirty rectangle (the whole screen at once when it is 320 x 240),
   then resets the flags and the rectangle. */
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
    unsigned long ent;
    unsigned int i;
    if (ram_3ef92 != 0 && DISPLAY_UPDATE_FLAG != 0) {
        if (PALETTE_UPDATE_FLAG != 0) {
            if (PALETTE_INDEX_CACHED != 4 || PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4) {
                LcdOn_Return();
                for (i = 0; i < 0x100; i++) {
                    ent = Table_LookupDword(i);
                    VGA_WritePaletteEntry(i, &ent);
                }
            }
        } else if (ram_30462 != 0) {
            for (i = 0xe0; i < 0xf0; i++) {
                ent = Table_LookupDword(i);
                VGA_WritePaletteEntry(i, &ent);
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
