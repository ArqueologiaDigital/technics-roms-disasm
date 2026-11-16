/* Phase 6, lane_p6 helper A, round 7, form b: routines with calls from poolc_A2 (ui/ui_widget_defs.s event queues,
   draw queue and LCD helpers; seq_audio_mode.s; midi_serial_routines.s) under their firmware names. */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern struct ev ram_2ec38[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern unsigned int ram_30464;
extern unsigned char DRAW_QUEUE[];
extern unsigned char *DRAW_QUEUE_WRITE_PTR;
extern unsigned char __near ram_33e2;
extern unsigned char __near ram_33e3;
extern unsigned char __near ram_33e4;
extern unsigned int __near ram_b7d4;
extern unsigned int __near ram_b7d6;
extern unsigned int __near ram_b7d8;
extern unsigned int __near ram_b7da;
extern unsigned char __near ram_b7dc;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_SemaWait(int);
extern void Kernel_SemaSignal(int);
extern void Kernel_YieldRotate(int);
extern int Boot_CheckConfigFlag7(void);
extern unsigned char Get_Region_Code(void);
extern void Rhythm_SendByte(unsigned char);
extern void VGA_ScreenBlank(void);
extern void VGA_ScreenUnblank(void);

void ApPostEvent(long obj, long evt, long par)
{
    int w, r;
    for (;;) {
        TaskEvent_Wait(4);
        w = ram_2ec36;
        r = ram_2ec34;
        if (w + 1 != r && w - 0x3ff != r)
            break;
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    ram_2f840++;
    EVENT_QUEUE[ram_2ec36].obj = obj;
    EVENT_QUEUE[ram_2ec36].evt = evt;
    EVENT_QUEUE[ram_2ec36].par = par;
    if (ram_2ec36 == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36++;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
}

void MainPostEvent(long obj, long evt, long par)
{
    int w, r;
    for (;;) {
        TaskEvent_Wait(7);
        w = ram_2f83a;
        r = ram_2f838;
        if (w + 1 != r && w - 0xff != r)
            break;
        TaskEvent_Signal(7);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    ram_2f842++;
    ram_2ec38[ram_2f83a].obj = obj;
    ram_2ec38[ram_2f83a].evt = evt;
    ram_2ec38[ram_2f83a].par = par;
    if (ram_2f83a == 0xff)
        ram_2f83a = 0;
    else
        ram_2f83a++;
    TaskEvent_Signal(7);
}

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
    e = (struct ev *)((char *)EVENT_QUEUE + (long)(w * 12));
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

int MainGetEvent(long *obj, long *evt, long *par)
{
    int r;
    struct ev *e;
    TaskEvent_Wait(7);
    if (ram_2f838 == ram_2f83a) {
        TaskEvent_Signal(7);
        return 0;
    }
    --ram_2f842;
    r = ram_2f838;
    e = ram_2ec38 + r;
    *obj = e->obj;
    *evt = e->evt;
    *par = e->par;
    if (r == 0xff)
        ram_2f838 = 0;
    else
        ram_2f838++;
    TaskEvent_Signal(7);
    return 1;
}

void DeleteEvent(long obj, long evt)
{
    int w, i;
    struct ev *e;
    long *pe;
    TaskEvent_Wait(4);
    w = ram_2ec36;
    i = ram_2ec34;
    if (i != w) {
        if (i != w) do {
            e = &EVENT_QUEUE[i];
            pe = &e->evt;
            if (*pe == evt && e->obj == obj)
                *pe = 0x1c00000L;
            if (i == w)
                break;
            if (i == 0x3ff)
                i = 0;
            else
                i++;
        } while (i != w);
    }
    TaskEvent_Signal(4);
}

unsigned char *DrawQueue_Alloc(unsigned int n)
{
    unsigned char *p;
    Kernel_SemaWait(4);
    if ((long)(DRAW_QUEUE_WRITE_PTR - DRAW_QUEUE) + n < 0x2000L) {
        p = DRAW_QUEUE_WRITE_PTR;
        DRAW_QUEUE_WRITE_PTR = p + n;
    } else {
        p = DRAW_QUEUE;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE + n;
    }
    Kernel_SemaSignal(4);
    return p;
}

void LcdOn_Return(void)
{
    VGA_ScreenBlank();
    ram_30464 = 0;
}

void LcdOff_Done(void)
{
    if (ram_30464 != 0)
        VGA_ScreenUnblank();
}

void LcdOff_Return(void)
{
    if (ram_30464 != 0)
        VGA_ScreenBlank();
}

void Rhythm_Send3ByteMsg(unsigned int ab, int unused, unsigned int c)
{
    ram_33e2 = ab;
    ram_33e3 = ab >> 8;
    ram_33e4 = c;
    Rhythm_SendByte(ram_33e2);
    Rhythm_SendByte(ram_33e3);
    Rhythm_SendByte(ram_33e4);
}

void SC0Init_StandardBaudTable(void)
{
    if (Get_Region_Code() == 4)
        goto alt;
    ram_b7d4 = 0x7a12;
    ram_b7d6 = 0x28b0;
    ram_b7d8 = 4166;
    ram_b7da = 1000;
    ram_b7dc = 8;
    goto done;
alt:
    ram_b7d4 = 0x5b8d;
    ram_b7d6 = 7812;
    ram_b7d8 = 3125;
    ram_b7da = 750;
    ram_b7dc = 6;
done:
    ;
}
