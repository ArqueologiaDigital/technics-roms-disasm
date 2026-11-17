/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m273c.c (2026-11-16-123-p6-r25)
   sha256 188d645285abc26c31df8f5f13c66fb7d6fb6b3ac065fb816753b8ed66c97b2e (tar-sha256); compiled at -O3 -Xr */
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
void MainDispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    procfn fp;
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            fp = ((procfn *)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff)].data)
                [(unsigned int)(obj & 0xffff)];
            fp(obj, evt, par);
        }
    }
}
