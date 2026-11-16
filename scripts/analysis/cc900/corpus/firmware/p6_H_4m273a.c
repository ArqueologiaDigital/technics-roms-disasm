/* lane_p6 helper H, round 4, module 273, form a.  ui_widget_defs.s (KillApTimer, MainDeleteEvent,
   DeleteSpecificEvent) and kn5000_v10_program.s (DrawRect_Impl).  SetChangeRect / DrawLineWithMode_Impl are
   module callees, declared only. */
/* cc900-module: DrawLineWithMode_Impl SetChangeRect */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;
    long *po;
    int *pn;
    int *q;
    int n;

    i = ram_30448;
    while (i != -1) {
        t = APTIMER(i);
        po = &t->obj;
        pn = &t->next;
        if (*po == obj && t->target == target && t->event == event && t->param == param) {
            q = pn;
            n = *q;
            if (n != -1)
                APTIMER(n)->prev = t->prev;
            if (t->prev != -1)
                APTIMER(t->prev)->next = *q;
            if (i == ram_30448)
                ram_30448 = *q;
            *po = -1;
            *q = -1;
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
    int i, tail;
    struct ev *e;

    TaskEvent_Wait(7);
    tail = ram_2f83a;
    if (ram_2f838 == tail) {
        TaskEvent_Signal(7);
        return;
    }
    for (i = ram_2f838; i != tail; ) {
        e = (struct ev *)((char *)ram_2ec38 + i * 12);
        if (e->evt == evt && e->obj == obj)
            e->evt = 0x1c00000L;
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

struct point { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void SetChangeRect(struct rect *);
extern void DrawLineWithMode_Impl(struct point *, struct point *, int);

void DrawRect_Impl(struct rect *r, int mode)
{
    struct point a, b;
    int *p;

    if (r->y0 < 0)
        r->y0 = 0;
    if (r->x0 < 0)
        r->x0 = 0;
    if (r->x1 >= 320)
        r->x1 = 319;
    if (r->y1 >= 240)
        r->y1 = 239;
    if (r->y0 == r->y1) {
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x1;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
    } else {
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x1;
        b.y = r->y0;
        DrawLineWithMode_Impl(&a, &b, mode);
        p = &r->y1;
        a.y = *p;
        b.y = *p;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x0;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        p = &r->x1;
        a.x = *p;
        b.x = *p;
        DrawLineWithMode_Impl(&a, &b, mode);
    }
    SetChangeRect(r);
}
