/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_9b.c (2026-11-16-53-p6-r11)
   sha256 ee8b4c7393c5a6bcf4611c14717845b7f382f2907363504ba611af44ba40e2c3 (tar-sha256); compiled at -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_YieldRotate(int);
extern int Boot_CheckConfigFlag7(void);
#define EVQ(i) ((struct ev *)&((char *)EVENT_QUEUE)[(i) * 12])
void ApPostEvent(long obj, long evt, long par)
{
    int w;
    for (;;) {
        TaskEvent_Wait(4);
        w = ram_2ec36;
        if (w + 1 != ram_2ec34 && w - 0x3ff != ram_2ec34)
            break;
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    ram_2f840++;
    EVQ(ram_2ec36)->obj = obj;
    EVQ(ram_2ec36)->evt = evt;
    EVQ(ram_2ec36)->par = par;
    w = ram_2ec36;
    if (w == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36 = w + 1;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
}
