/* lane_p6 helper H, round 6, module 273, form b: register-choice probes for KillApTimer (no &t->next local),
   MainDeleteEvent and DeleteSpecificEvent (unsigned indexes, the event pointer declared before the indexes). */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;
    long *po;
    int n;

    i = ram_30448;
    while (i != -1) {
        t = APTIMER(i);
        po = &t->obj;
        if (*po == obj && t->target == target && t->event == event && t->param == param) {
            n = t->next;
            if (n != -1)
                APTIMER(n)->prev = t->prev;
            if (t->prev != -1)
                APTIMER(t->prev)->next = t->next;
            if (i == ram_30448)
                ram_30448 = t->next;
            *po = -1;
            t->next = -1;
            t->prev = -1;
            return 1;
        }
        i = t->next;
    }
    return 0;
}

struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern struct ev ram_2ec38[];
extern unsigned int ram_2ec34;
extern unsigned int ram_2ec36;
extern unsigned int ram_2f838;
extern unsigned int ram_2f83a;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);

void MainDeleteEvent(long obj, long evt)
{
    long *pe;
    struct ev *e;
    unsigned int tail, i;

    TaskEvent_Wait(7);
    tail = ram_2f83a;
    if (ram_2f838 == tail) {
        TaskEvent_Signal(7);
        return;
    }
    for (i = ram_2f838; i != tail; ) {
        e = (struct ev *)((char *)ram_2ec38 + (int)i * 12);
        pe = &e->evt;
        if (*pe == evt && e->obj == obj)
            *pe = 0x1c00000L;
        if (i == tail)
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
    long *pe;
    struct ev *e;
    unsigned int tail, i;

    TaskEvent_Wait(4);
    tail = ram_2ec36;
    if (ram_2ec34 == tail) {
        TaskEvent_Signal(4);
        return;
    }
    for (i = ram_2ec34; i != tail; ) {
        e = (struct ev *)((char *)EVENT_QUEUE + (int)i * 12);
        pe = &e->evt;
        if (*pe == evt && e->obj == obj && e->par == par)
            *pe = 0x1c00000L;
        if (i == tail)
            break;
        if (i == 0x3ff)
            i = 0;
        else
            i++;
    }
    TaskEvent_Signal(4);
}
