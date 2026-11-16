/* lane_p6 helper H, round 6, module 273, form a: register-choice probes for KillApTimer (no &t->obj local),
   MainDeleteEvent and DeleteSpecificEvent (no tail local: the loop tests the queue's write index itself). */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;
    int *pn;
    int n;

    i = ram_30448;
    while (i != -1) {
        t = APTIMER(i);
        pn = &t->next;
        if (t->obj == obj && t->target == target && t->event == event && t->param == param) {
            n = *pn;
            if (n != -1)
                APTIMER(n)->prev = t->prev;
            if (t->prev != -1)
                APTIMER(t->prev)->next = *pn;
            if (i == ram_30448)
                ram_30448 = *pn;
            t->obj = -1;
            *pn = -1;
            t->prev = -1;
            return 1;
        }
        i = *pn;
    }
    return 0;
}

struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern struct ev ram_2ec38[];
extern int ram_2ec34;
extern int ram_2ec36;
extern int ram_2f838;
extern int ram_2f83a;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);

void MainDeleteEvent(long obj, long evt)
{
    int i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(7);
    if (ram_2f838 == ram_2f83a) {
        TaskEvent_Signal(7);
        return;
    }
    for (i = ram_2f838; i != ram_2f83a; ) {
        e = (struct ev *)((char *)ram_2ec38 + i * 12);
        pe = &e->evt;
        if (*pe == evt && e->obj == obj)
            *pe = 0x1c00000L;
        if (i == ram_2f83a)
            break;
        if (i == 0x3ff)
            i = 0;
        else
            i++;
    }
    TaskEvent_Signal(7);
}

void DeleteSpecificEvent(long obj, long evt, long par)
{
    int i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(4);
    if (ram_2ec34 == ram_2ec36) {
        TaskEvent_Signal(4);
        return;
    }
    for (i = ram_2ec34; i != ram_2ec36; ) {
        e = (struct ev *)((char *)EVENT_QUEUE + i * 12);
        pe = &e->evt;
        if (*pe == evt && e->obj == obj && e->par == par)
            *pe = 0x1c00000L;
        if (i == ram_2ec36)
            break;
        if (i == 0x3ff)
            i = 0;
        else
            i++;
    }
    TaskEvent_Signal(4);
}
