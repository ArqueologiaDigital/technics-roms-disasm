/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m273b.c (2026-11-16-123-p6-r25)
   sha256 ea05e8a70bca47fe6742e26036b0d36e2da780795680896d460e61aeec9b5e42 (tar-sha256); compiled at -O3 -Xr */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
typedef unsigned long (*clsfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern unsigned long ram_2bc14;
extern int ram_3ef4e;
extern unsigned long FOCUS_OBJECT, ROOT_OBJECT;
extern long FOCUS_EVENT, FOCUS_PARAM, ROOT_EVENT, ROOT_PARAM;
extern int GetEvent(unsigned long *obj, long *evt, long *par);
extern void Kernel_YieldRotate(int);
#define EVT_GET_CLASS_SP 0x1e00000L
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
