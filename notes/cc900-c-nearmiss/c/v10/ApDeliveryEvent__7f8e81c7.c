/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m273b.c (2026-11-18-12-p6-r35)
   sha256 7f8e81c7bedc4873cb87f6773f3d257b5a79699bfa5a806c85e5a7a33630b2a5 (tar-sha256); compiled at -O3 -Xr */
#define EVT_DELIVERY_EVENT 0x1c00037L
#define EVT_AUTO_FREE 0x1e00023L
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void *__cdecl Malloc(unsigned int);
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern int Boot_CheckConfigFlag7(void);
extern void Kernel_YieldRotate(int);
extern long ApPostEvent(long, long, long);
void ApDeliveryEvent(long obj, long evt, long par)
{
    struct ev *m;
    int w;
    int r;

    for (;;) {
        TaskEvent_Wait(4);
        w = ram_2ec36;
        r = ram_2ec34;
        if (w + 1 != r && w - 0x3ff != r)
            break;
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    if (obj != -1) {
        m = (struct ev *)Malloc(12);
        m->obj = obj;
        m->evt = evt;
        m->par = par;
        obj = -1;
        evt = EVT_DELIVERY_EVENT;
        par = (long)m;
    } else
        m = 0;
    ram_2f840++;
    EVENT_QUEUE[ram_2ec36].obj = obj;
    EVENT_QUEUE[ram_2ec36].evt = evt;
    EVENT_QUEUE[ram_2ec36].par = par;
    if (ram_2ec36 == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36++;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
    if (m != 0)
        ApPostEvent(-1, EVT_AUTO_FREE, (long)m);
}
