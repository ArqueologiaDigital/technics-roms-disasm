/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_4m273a.c (2026-11-16-87-p6-r15)
   sha256 22f6f4722d25e48e7b81c727bf036c1bddbbeec853a9d279cbc7ae26cf55c291 (tar-sha256); compiled at -O3 -XS -Xr */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
void DeleteSpecificEvent(long obj, long evt, long par)
{
    int i, tail;
    struct ev *e;

    TaskEvent_Wait(4);
    tail = ram_2ec36;
    if (ram_2ec34 == tail) {
        TaskEvent_Signal(4);
        return;
    }
    for (i = ram_2ec34; i != tail; ) {
        e = (struct ev *)((char *)EVENT_QUEUE + i * 12);
        if (e->evt == evt && e->obj == obj && e->par == par)
            e->evt = 0x1c00000L;
        if (i == tail)
            break;
        if (i == 0x3ff)
            i = 0;
        else
            i++;
    }
    TaskEvent_Signal(4);
}
