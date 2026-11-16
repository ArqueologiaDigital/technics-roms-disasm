/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: GetCurrentTarget GetEvent InitGraphics_SetupVRAM_Loop LcdOn_Return MainGetEvent */   /* scripts/analysis/cc900/module_calls.py v10 */

struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
typedef unsigned long (*clsfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4a;
extern unsigned long FOCUS_OBJECT, ROOT_OBJECT;
extern long FOCUS_EVENT, FOCUS_PARAM, ROOT_EVENT, ROOT_PARAM;
extern int GetEvent(unsigned long *obj, long *evt, long *par);
extern void Kernel_YieldRotate(int);
#define EVT_GET_CLASS_SP 0x1e00000L
extern void DispatchEvent(void);
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
extern void MainDispatchEvent(void);
extern unsigned long GetCurrentTarget(void);
extern long SendEvent(unsigned long obj, long evt, long par);

void DispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    unsigned long x, t;
    unsigned int i;
    struct clsrec *c;
    procfn fp;
    while (GetEvent(&obj, &evt, &par) != 0) {
        if (obj == 0xffffffffUL)
            continue;
        x = (unsigned long)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].proc;
        if (x == 0)
            continue;
        ROOT_OBJECT = FOCUS_OBJECT = obj;
        ROOT_EVENT = FOCUS_EVENT = evt;
        ROOT_PARAM = FOCUS_PARAM = par;
        x = ((clsfn)x)(obj, EVT_GET_CLASS_SP, 0);
        ram_2bc14 = x;
        t = (x >> 16) & 0xfff;
        i = (unsigned int)(x & 0xffff);
        c = (struct clsrec *)OBJECT_REGISTRY[(unsigned int)t].data;
        fp = c[i].proc;
        fp(obj, evt, par);
        if (ram_3ef4a != 0)
            Kernel_YieldRotate(3);
    }
}

void MainDispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    unsigned int t, i;
    procfn *tab;
    procfn fp;
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            t = (unsigned int)((obj >> 16) & 0xfff);
            i = (unsigned int)(obj & 0xffff);
            tab = (procfn *)OBJECT_REGISTRY[t].data;
            fp = tab[i];
            fp(obj, evt, par);
        }
    }
}

long SendEvent(unsigned long obj, long evt, long par)
{
    unsigned long scls;
    long spar;
    unsigned long sobj;
    long sevt;
    unsigned long x, t;
    unsigned int i;
    struct clsrec *c;
    procfn fp;
    long r;
    if (obj == 0xffffffffUL)
        obj = GetCurrentTarget();
    x = (unsigned long)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].proc;
    sobj = FOCUS_OBJECT;
    sevt = FOCUS_EVENT;
    spar = FOCUS_PARAM;
    FOCUS_OBJECT = obj;
    FOCUS_EVENT = evt;
    FOCUS_PARAM = par;
    scls = ram_2bc14;
    x = ((clsfn)x)(obj, EVT_GET_CLASS_SP, 0);
    ram_2bc14 = x;
    t = (x >> 16) & 0xfff;
    i = (unsigned int)(x & 0xffff);
    c = (struct clsrec *)OBJECT_REGISTRY[(unsigned int)t].data;
    fp = c[i].proc;
    r = fp(obj, evt, par);
    ram_2bc14 = scls;
    FOCUS_OBJECT = sobj;
    FOCUS_EVENT = sevt;
    FOCUS_PARAM = spar;
    if (ram_3ef4a != 0)
        Kernel_YieldRotate(3);
    return r;
}
