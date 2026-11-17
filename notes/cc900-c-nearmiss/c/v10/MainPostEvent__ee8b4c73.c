/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_9b.c (2026-11-16-53-p6-r11)
   sha256 ee8b4c7393c5a6bcf4611c14717845b7f382f2907363504ba611af44ba40e2c3 (tar-sha256); compiled at -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev ram_2ec38[];
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_YieldRotate(int);
extern int Boot_CheckConfigFlag7(void);
#define MEVQ(i) ((struct ev *)&((char *)ram_2ec38)[(i) * 12])
void MainPostEvent(long obj, long evt, long par)
{
    int w;
    for (;;) {
        TaskEvent_Wait(7);
        w = ram_2f83a;
        if (w + 1 != ram_2f838 && w - 0xff != ram_2f838)
            break;
        TaskEvent_Signal(7);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    ram_2f842++;
    MEVQ(ram_2f83a)->obj = obj;
    MEVQ(ram_2f83a)->evt = evt;
    MEVQ(ram_2f83a)->par = par;
    w = ram_2f83a;
    if (w == 0xff)
        ram_2f83a = 0;
    else
        ram_2f83a = w + 1;
    TaskEvent_Signal(7);
}
