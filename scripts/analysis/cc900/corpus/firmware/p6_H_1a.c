/* lane_p6 helper H, round 1, form a.  Guesses for ui/ui_widget_defs.s (KillApTimer, MainDeleteEvent,
   DeleteSpecificEvent) and demo/fdemotext_routines.s (FDemoText_ParseControlMessage), under their firmware names. */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;
    long *po;
    int *pn;

    i = ram_30448;
    while (i != -1) {
        t = &ram_2f844[i];
        po = &t->obj;
        pn = &t->next;
        if (*po == obj && t->target == target && t->event == event && t->param == param) {
            if (*pn != -1)
                ram_2f844[*pn].prev = t->prev;
            if (t->prev != -1)
                ram_2f844[t->prev].next = *pn;
            if (i == ram_30448)
                ram_30448 = *pn;
            *po = -1;
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
    int tail, i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(7);
    tail = ram_2f83a;
    i = ram_2f838;
    if (i == tail) {
        TaskEvent_Signal(7);
        return;
    }
    while (i != tail) {
        e = &ram_2ec38[i];
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
    int tail, i;
    struct ev *e;
    long *pe;

    TaskEvent_Wait(4);
    tail = ram_2ec36;
    i = ram_2ec34;
    if (i == tail) {
        TaskEvent_Signal(4);
        return;
    }
    while (i != tail) {
        e = &EVENT_QUEUE[i];
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

struct dmsg { unsigned char st, part, type, b3, b4, b5, b6, b7; };
extern struct dmsg ram_20c33;
extern unsigned char __near PART_SELECT;
extern unsigned char __near ACTIVE_TITLE;
extern void DemoMenu_BuildItemWorkspace(int, int);

void FDemoText_ParseControlMessage(void)
{
    int ch;

    if (ram_20c33.part != PART_SELECT)
        return;
    if (ACTIVE_TITLE != 234)
        return;
    if (ram_20c33.st != 0x83) {
        if (ram_20c33.st != 0x82)
            return;
        ch = ram_20c33.b7 & 0xf;
        switch (ram_20c33.type) {
        case 2:
            DemoMenu_BuildItemWorkspace(6, ch);
            DemoMenu_BuildItemWorkspace(2, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(0, ram_20c33.b6 & 0xf);
            break;
        case 0x82:
            DemoMenu_BuildItemWorkspace(8, ch);
            DemoMenu_BuildItemWorkspace(5, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(3, ram_20c33.b6 & 0xf);
            break;
        }
    }
    switch (ram_20c33.type) {
    case 2:
        DemoMenu_BuildItemWorkspace(7, ram_20c33.b7 & 0xf);
        DemoMenu_BuildItemWorkspace(4, (ram_20c33.b6 >> 4) & 0xf);
        DemoMenu_BuildItemWorkspace(1, ram_20c33.b6 & 0xf);
        break;
    case 0x82:
        DemoMenu_BuildItemWorkspace(10, ram_20c33.b6 & 1);
        DemoMenu_BuildItemWorkspace(9, (ram_20c33.b6 >> 1) & 1);
        break;
    }
}
