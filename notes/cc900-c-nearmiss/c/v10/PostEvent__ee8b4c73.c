/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_9b.c (2026-11-16-53-p6-r11)
   sha256 ee8b4c7393c5a6bcf4611c14717845b7f382f2907363504ba611af44ba40e2c3 (tar-sha256); compiled at -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
void PostEvent(long obj, long evt, long par)
{
    int r, w;
    struct ev *e;
    TaskEvent_Wait(4);
    r = ram_2ec34;
    w = ram_2ec36;
    if (w + 1 == r || w - 0x3ff == r) {
        TaskEvent_Signal(4);
        for (;;)
            ;
    }
    ram_2f840++;
    e = (struct ev *)((char *)EVENT_QUEUE + (int)(w * 12));
    e->obj = obj;
    e->evt = evt;
    e->par = par;
    if (w == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36++;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
}
