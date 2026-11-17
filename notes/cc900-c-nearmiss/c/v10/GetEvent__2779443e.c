/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_13m273b.c (2026-11-16-92-p6-r18)
   sha256 2779443e6d154bf79f1fb9de4228b6592db817e394641089a1ae790b691f02e4 (tar-sha256); compiled at -Xr */
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
