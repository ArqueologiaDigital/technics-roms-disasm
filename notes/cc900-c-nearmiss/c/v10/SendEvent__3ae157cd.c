/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m273b.c (2026-11-16-118-p6-r23)
   sha256 3ae157cd74ad1c569cc6e845daa973804ea82f686969c6f3f0a3ab8ba345d94d (tar-sha256); compiled at -O3 -Xr */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern unsigned long FOCUS_OBJECT, ROOT_OBJECT;
extern long FOCUS_EVENT, FOCUS_PARAM, ROOT_EVENT, ROOT_PARAM;
extern unsigned long GetCurrentTarget(void);
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
