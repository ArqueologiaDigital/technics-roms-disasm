/* lane_p6 helper H, round 2, module 273, form b: KillApTimer as a for loop; the event scans with a
   head local; SetChangeRect with the rectangle's field on the left; IsPointOnScreen and DrawRect_Impl with
   plain field reads.  ui_widget_defs.s (KillApTimer, MainDeleteEvent,
   DeleteSpecificEvent, SetChangeRect), kn5000_v10_program.s (DrawRect_Impl), ui_window_procs.s (IsPointOnScreen).
   DrawLineWithMode_Impl is a STUB here: present only so DrawRect_Impl's calls to it come out as calr. */
/* cc900-module: DrawLineWithMode_Impl SetChangeRect */   /* from scripts/analysis/cc900/module_calls.py v10 */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;

    for (i = ram_30448; i != -1; i = t->next) {
        t = APTIMER(i);
        if (t->obj == obj && t->target == target && t->event == event && t->param == param) {
            if (t->next != -1)
                APTIMER(t->next)->prev = t->prev;
            if (t->prev != -1)
                APTIMER(t->prev)->next = t->next;
            if (i == ram_30448)
                ram_30448 = t->next;
            t->obj = -1;
            t->next = -1;
            t->prev = -1;
            return 1;
        }
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
    int tail, h, i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(7);
    tail = ram_2f83a;
    h = ram_2f838;
    if (h == tail) {
        TaskEvent_Signal(7);
        return;
    }
    for (i = h; i != tail; ) {
        e = (struct ev *)((char *)ram_2ec38 + i * 12);
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
    int tail, h, i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(4);
    tail = ram_2ec36;
    h = ram_2ec34;
    if (h == tail) {
        TaskEvent_Signal(4);
        return;
    }
    for (i = h; i != tail; ) {
        e = (struct ev *)((char *)EVENT_QUEUE + i * 12);
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

struct point { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int ram_3ef4e;
extern int DISPLAY_UPDATE_FLAG;
extern struct rect DIRTY_BBOX;
extern void Kernel_SetTaskLevel(int, int);

void SetChangeRect(struct rect *r)
{
    if (ram_3ef4e != 0)
        Kernel_SetTaskLevel(5, 3);
    DISPLAY_UPDATE_FLAG = 1;
    if (r->y0 < DIRTY_BBOX.y0)
        DIRTY_BBOX.y0 = r->y0;
    if (r->x0 < DIRTY_BBOX.x0)
        DIRTY_BBOX.x0 = r->x0;
    if (r->x1 > DIRTY_BBOX.x1)
        DIRTY_BBOX.x1 = r->x1;
    if (r->y1 > DIRTY_BBOX.y1)
        DIRTY_BBOX.y1 = r->y1;
}

int IsPointOnScreen(struct point *p)
{
    int y;

    if (p->x >= 0 && p->x < 320) {
        y = p->y;
        if (y >= 0 && y < 240)
            return 1;
    }
    return 0;
}

void DrawLineWithMode_Impl(struct point *a, struct point *b, int mode)
{
}

void DrawRect_Impl(struct rect *r, int mode)
{
    struct point b, a;

    if (r->y0 < 0)
        r->y0 = 0;
    if (r->x0 < 0)
        r->x0 = 0;
    if (r->x1 >= 320)
        r->x1 = 319;
    if (r->y1 >= 240)
        r->y1 = 239;
    if (r->y1 == r->y0) {
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
        a.y = r->y1;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x0;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.x = r->x1;
        b.x = r->x1;
        DrawLineWithMode_Impl(&a, &b, mode);
    }
    SetChangeRect(r);
}
