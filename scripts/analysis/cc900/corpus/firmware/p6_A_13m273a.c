/* cc900-module: DrawRing_TryPost GetCurrentTarget */
/* Phase 6, lane_p6 helper A, round 13, form a: module 273 of modules_v10.tsv (ui/ui_widget_defs.s): GetEvent (the
   application queue's reader, MainGetEvent's twin, which already matches) and DrawRing_Post. */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_SetTaskLevel(int level, int how);
extern long GetCurrentTarget(void);
extern void *DrawRing_TryPost(void *cmd);
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
    ram_2f840--;
    r = ram_2ec34;
    if ((*obj = EVQ(r)->obj) == -1)
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

void *DrawRing_Post(void *cmd)
{
    void *s;
    do {
        TaskEvent_Wait(3);
        s = DrawRing_TryPost(cmd);
        TaskEvent_Signal(3);
        if (s == 0)
            Kernel_SetTaskLevel(5, 2);
    } while (s == 0);
    return s;
}
