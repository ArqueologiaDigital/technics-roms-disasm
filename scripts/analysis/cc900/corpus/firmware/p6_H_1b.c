/* lane_p6 helper H, round 1, form b: field accesses without pointer temporaries, the queue scans nested in one
   `if`, and FDemoText_ParseControlMessage with if/else chains over a char array. */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;

    for (i = ram_30448; i != -1; i = t->next) {
        t = &ram_2f844[i];
        if (t->obj == obj && t->target == target && t->event == event && t->param == param) {
            if (t->next != -1)
                ram_2f844[t->next].prev = t->prev;
            if (t->prev != -1)
                ram_2f844[t->prev].next = t->next;
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
    int tail, i;
    struct ev *e;

    TaskEvent_Wait(7);
    tail = ram_2f83a;
    i = ram_2f838;
    if (i != tail) {
        while (i != tail) {
            e = &ram_2ec38[i];
            if (e->evt == evt && e->obj == obj)
                e->evt = 0x1c00000L;
            if (i == tail)
                break;
            if (i == 0x3ff)
                i = 0;
            else
                i++;
        }
    }
    TaskEvent_Signal(7);
}

void DeleteSpecificEvent(long obj, long evt, long par)
{
    int tail, i;
    struct ev *e;

    TaskEvent_Wait(4);
    tail = ram_2ec36;
    i = ram_2ec34;
    if (i != tail) {
        while (i != tail) {
            e = &EVENT_QUEUE[i];
            if (e->evt == evt && e->obj == obj && e->par == par)
                e->evt = 0x1c00000L;
            if (i == tail)
                break;
            if (i == 0x3ff)
                i = 0;
            else
                i++;
        }
    }
    TaskEvent_Signal(4);
}

extern unsigned char ram_20c33[];
extern unsigned char __near PART_SELECT;
extern unsigned char __near ACTIVE_TITLE;
extern void DemoMenu_BuildItemWorkspace(int, int);

void FDemoText_ParseControlMessage(void)
{
    unsigned char t;
    int ch;

    if (ram_20c33[1] != PART_SELECT)
        return;
    if (ACTIVE_TITLE != 234)
        return;
    if (ram_20c33[0] != 0x83) {
        if (ram_20c33[0] != 0x82)
            return;
        t = ram_20c33[2];
        ch = ram_20c33[7] & 0xf;
        if (t == 0x82) {
            DemoMenu_BuildItemWorkspace(8, ch);
            DemoMenu_BuildItemWorkspace(5, (ram_20c33[6] >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(3, ram_20c33[6] & 0xf);
        } else if (t == 2) {
            DemoMenu_BuildItemWorkspace(6, ch);
            DemoMenu_BuildItemWorkspace(2, (ram_20c33[6] >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(0, ram_20c33[6] & 0xf);
        }
    }
    t = ram_20c33[2];
    if (t == 0x82) {
        DemoMenu_BuildItemWorkspace(10, ram_20c33[6] & 1);
        DemoMenu_BuildItemWorkspace(9, (ram_20c33[6] >> 1) & 1);
    } else if (t == 2) {
        DemoMenu_BuildItemWorkspace(7, ram_20c33[7] & 0xf);
        DemoMenu_BuildItemWorkspace(4, (ram_20c33[6] >> 4) & 0xf);
        DemoMenu_BuildItemWorkspace(1, ram_20c33[6] & 0xf);
    }
}
