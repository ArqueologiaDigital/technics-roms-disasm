/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m273.c (2026-11-16-91-p6-r17)
   sha256 7fd41bf461b57ac8dffe3de4e22e5dc70b38a0bb1df3752f985c31092466a8dc (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct ev { long obj; long evt; long par; };
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern struct ev EVENT_QUEUE[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
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
    e = (struct ev *)((char *)EVENT_QUEUE + w * 12);
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
