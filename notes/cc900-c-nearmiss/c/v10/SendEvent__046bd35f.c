/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m273.c (2026-11-16-125-p6-r26-staged)
   sha256 046bd35fd743440d6d57231259b8db45068962d6455d1cc8129a72ce85cf1694 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
typedef unsigned long (*clsfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern unsigned long FOCUS_OBJECT, ROOT_OBJECT;
extern long FOCUS_EVENT, FOCUS_PARAM, ROOT_EVENT, ROOT_PARAM;
extern void Kernel_YieldRotate(int);
#define EVT_GET_CLASS_SP 0x1e00000L
extern unsigned long GetCurrentTarget(void);
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
    if (ram_3ef4e != 0)
        Kernel_YieldRotate(3);
    return r;
}
