/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_7b.c (2026-11-16-45-p6-r9)
   sha256 610dbaa80fee86b3fc7b51cb71c48d05736a0a61496faada5af95b573292fca3 (tar-sha256); compiled at -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev ram_2ec38[];
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
int MainGetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(7);
    if (ram_2f838 == ram_2f83a) {
        TaskEvent_Signal(7);
        return 0;
    }
    --ram_2f842;
    r = ram_2f838;
    e = ram_2ec38 + r;
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
