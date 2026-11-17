/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m273.c (2026-11-16-111-p6-r22-staged)
   sha256 18c72af2a06bbe52370ab72d0ae129075a380c637c106ce9ec4771ad5c5579aa (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern long GetCurrentTarget(void);
#define EVQ(i) ((struct ev *)&((char *)EVENT_QUEUE)[(i) * 12])
int GetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(4);
    if (ram_2ec34 == ram_2ec36) {
        TaskEvent_Signal(4);
        return 0;
    }
    --ram_2f840;
    r = ram_2ec34;
    *obj = EVQ(r)->obj;
    if (*obj == -1L)
        *obj = GetCurrentTarget();
    e = EVQ(r);
    *evt = e->evt;
    *par = e->par;
    if (r == 0x3ff)
        ram_2ec34 = 0;
    else
        ram_2ec34++;
    TaskEvent_Signal(4);
    return 1;
}
