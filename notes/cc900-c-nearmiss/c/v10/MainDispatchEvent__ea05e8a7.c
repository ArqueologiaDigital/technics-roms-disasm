/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m273b.c (2026-11-16-123-p6-r25)
   sha256 ea05e8a70bca47fe6742e26036b0d36e2da780795680896d460e61aeec9b5e42 (tar-sha256); compiled at -O3 -Xr */
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
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
