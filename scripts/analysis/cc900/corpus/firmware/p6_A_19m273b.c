/* cc900-module: GetCurrentTarget GetEvent InitGraphics_SetupVRAM_Loop LcdOn_Return MainGetEvent */
/* Phase 6, lane_p6 helper A, round 19, form b: module 273 (ui/ui_widget_defs.s).
   SendEvent / DispatchEvent: a void * proc and a separate class id; class proc through a local fp; DispatchEvent as nested ifs.
   MainDispatchEvent: GetViewInstance-style t (long) / i / d and fp.
   Gfx_BlitDirtyRegions: pe = &ent before each loop, do-while loops.
   (Object table entry {class, table proc, count, data}; a class table's data is an array of 24-byte class records
   {proc, parent, ...}, a main-function table's data an array of procs.) */

struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
typedef unsigned long (*clsfn)(unsigned long, long, long);
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

long SendEvent(unsigned long obj, long evt, long par)
{
    unsigned long scls;
    long spar;
    unsigned long sobj;
    long sevt;
    void *p;
    unsigned long cls, t;
    unsigned int i;
    struct clsrec *c;
    procfn fp;
    long r;
    if (obj == 0xffffffffUL)
        obj = GetCurrentTarget();
    p = (void *)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].proc;
    sobj = FOCUS_OBJECT;
    sevt = FOCUS_EVENT;
    spar = FOCUS_PARAM;
    FOCUS_OBJECT = obj;
    FOCUS_EVENT = evt;
    FOCUS_PARAM = par;
    scls = ram_2bc14;
    cls = ((clsfn)p)(obj, EVT_GET_CLASS_SP, 0);
    ram_2bc14 = cls;
    t = (cls >> 16) & 0xfff;
    i = (unsigned int)(cls & 0xffff);
    c = (struct clsrec *)OBJECT_REGISTRY[(unsigned int)t].data;
    fp = c[i].proc;
    r = fp(obj, evt, par);
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
    void *p;
    unsigned long cls, t;
    unsigned int i;
    struct clsrec *c;
    procfn fp;
    while (GetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            p = (void *)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].proc;
            if (p != 0) {
                ROOT_OBJECT = FOCUS_OBJECT = obj;
                ROOT_EVENT = FOCUS_EVENT = evt;
                ROOT_PARAM = FOCUS_PARAM = par;
                cls = ((clsfn)p)(obj, EVT_GET_CLASS_SP, 0);
                ram_2bc14 = cls;
                t = (cls >> 16) & 0xfff;
                i = (unsigned int)(cls & 0xffff);
                c = (struct clsrec *)OBJECT_REGISTRY[(unsigned int)t].data;
                fp = c[i].proc;
                fp(obj, evt, par);
                if (ram_3ef4e != 0)
                    Kernel_YieldRotate(3);
            }
        }
    }
}

void MainDispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    unsigned long t;
    unsigned int i;
    procfn *d;
    procfn fp;
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            t = (obj >> 16) & 0xfff;
            i = (unsigned int)(obj & 0xffff);
            d = (procfn *)OBJECT_REGISTRY[(unsigned int)t].data;
            fp = d[i];
            fp(obj, evt, par);
        }
    }
}

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
    if (ram_3ef92 != 0 && DISPLAY_UPDATE_FLAG != 0) {
        if (PALETTE_UPDATE_FLAG != 0) {
            if (PALETTE_INDEX_CACHED != 4 || PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4) {
                LcdOn_Return();
                pe = &ent;
                i = 0;
                do {
                    ent = Table_LookupDword(i);
                    VGA_WritePaletteEntry(i, pe);
                } while (++i < 0x100);
            }
        } else if (ram_30462 != 0) {
            pe = &ent;
            i = 0xe0;
            do {
                ent = Table_LookupDword(i);
                VGA_WritePaletteEntry(i, pe);
            } while (++i < 0xf0);
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
