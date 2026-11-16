/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m273a.c (2026-11-16-118-p6-r23)
   sha256 c554f6611eefecda4c9115fb327dbfb3cf2d2e0f175648a070c9f84e0ea832f9 (tar-sha256); compiled at -O3 -Xr */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern long FOCUS_OBJECT, FOCUS_EVENT, FOCUS_PARAM;
extern unsigned long GetCurrentTarget(void);
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
