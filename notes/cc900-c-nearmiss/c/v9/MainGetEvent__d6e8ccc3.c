/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m273.c (2026-11-16-91-p6-r17)
   sha256 d6e8ccc31017ee1c73049de8e8224ce0c21d45f7bdf56869afe3eaabe8b32393 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev ram_2ec38[];
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
#define MEVQ(i) ((struct ev *)&((char *)ram_2ec38)[(i) * 12])
int MainGetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(7);
    if (ram_2f838 == ram_2f83a) {
        TaskEvent_Signal(7);
        return 0;
    }
    ram_2f842--;
    r = ram_2f838;
    e = MEVQ(r);
    *obj = e->obj;
    *evt = e->evt;
    *par = e->par;
    if (r == 0xff)
        ram_2f838 = 0;
    else
        ram_2f838++;
    TaskEvent_Signal(7);
    return 1;
}
