/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m273b.c (2026-11-16-118-p6-r23)
   sha256 3ae157cd74ad1c569cc6e845daa973804ea82f686969c6f3f0a3ab8ba345d94d (tar-sha256); compiled at -O3 -Xr */
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
extern int MainGetEvent(unsigned long *obj, long *evt, long *par);
void MainDispatchEvent(void)
{
    unsigned long obj;
    long evt, par;
    unsigned int t, i;
    long (**tab)(unsigned long, long, long);
    while (MainGetEvent(&obj, &evt, &par) != 0) {
        if (obj != 0xffffffffUL) {
            t = (unsigned int)((obj >> 16) & 0xfff);
            i = (unsigned int)(obj & 0xffff);
            tab = (long (**)(unsigned long, long, long))OBJECT_REGISTRY[t].data;
            tab[i](obj, evt, par);
        }
    }
}
