/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m273a.c (2026-11-16-123-p6-r25)
   sha256 7dee50614152ac5df716b240cd7a5735da457df92f9f61ca8d3417f3ac6bd717 (tar-sha256); compiled at -Xr */
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
typedef long (*procfn)(unsigned long, long, long);
extern struct objent OBJECT_REGISTRY[];
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
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
