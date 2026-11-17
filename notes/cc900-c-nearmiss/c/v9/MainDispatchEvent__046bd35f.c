/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m273.c (2026-11-16-125-p6-r26-staged)
   sha256 046bd35fd743440d6d57231259b8db45068962d6455d1cc8129a72ce85cf1694 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
