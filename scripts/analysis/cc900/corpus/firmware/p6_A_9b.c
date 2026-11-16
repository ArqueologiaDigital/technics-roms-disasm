/* Phase 6, lane_p6 helper A, round 9, form b: refinements of rounds 7-8.  The event queues are indexed by a 16-bit
   byte offset (index * 12, `muls` + (base+offset) in the ROM), written here as a char-array subscript. */
struct ev { long obj; long evt; long par; };
extern struct ev EVENT_QUEUE[];
extern struct ev ram_2ec38[];
extern int ram_2ec34;
extern int ram_2ec36;
extern unsigned int ram_2f840;
extern int ram_2f838;
extern int ram_2f83a;
extern unsigned int ram_2f842;
extern unsigned char DRAW_QUEUE[];
extern unsigned char *DRAW_QUEUE_WRITE_PTR;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_SemaWait(int);
extern void Kernel_SemaSignal(int);
extern void Kernel_YieldRotate(int);
extern int Boot_CheckConfigFlag7(void);
extern unsigned char SoundRam_Id_KN5000[], SoundRam_Id_KN1500[], SoundRam_Id_KN3000[];
extern unsigned char SoundRam_Id_KN2000[], SoundRam_Id_MKA[], SoundRam_Id_MKB[];
#define EVQ(i) ((struct ev *)&((char *)EVENT_QUEUE)[(i) * 12])
#define MEVQ(i) ((struct ev *)&((char *)ram_2ec38)[(i) * 12])

void ApPostEvent(long obj, long evt, long par)
{
    int w;
    for (;;) {
        TaskEvent_Wait(4);
        w = ram_2ec36;
        if (w + 1 != ram_2ec34 && w - 0x3ff != ram_2ec34)
            break;
        TaskEvent_Signal(4);
        if (Boot_CheckConfigFlag7() == 0)
            return;
        Kernel_YieldRotate(3);
    }
    ram_2f840++;
    EVQ(ram_2ec36)->obj = obj;
    EVQ(ram_2ec36)->evt = evt;
    EVQ(ram_2ec36)->par = par;
    w = ram_2ec36;
    if (w == 0x3ff)
        ram_2ec36 = 0;
    else
        ram_2ec36 = w + 1;
    TaskEvent_Signal(4);
    TaskEvent_Signal(2);
}

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
    e = (struct ev *)((char *)EVENT_QUEUE + (int)(w * 12));
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
    ram_2f842--;
    r = ram_2f838;
    e = MEVQ(r);
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
        while (i != w) {
            e = EVQ(i);
            pe = &e->evt;
            if (*pe == evt && e->obj == obj)
                *pe = 0x1c00000L;
            if (i == w)
                break;
            if (i == 0x3ff)
                i = 0;
            else
                i++;
        }
    }
    TaskEvent_Signal(4);
}

unsigned char *DrawQueue_Alloc(unsigned int n)
{
    unsigned char *p;
    Kernel_SemaWait(4);
    if (DRAW_QUEUE_WRITE_PTR - DRAW_QUEUE + (long)n < 0x2000) {
        p = DRAW_QUEUE_WRITE_PTR;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE_WRITE_PTR + n;
    } else {
        p = DRAW_QUEUE;
        DRAW_QUEUE_WRITE_PTR = DRAW_QUEUE + n;
    }
    Kernel_SemaSignal(4);
    return p;
}

unsigned char SoundRam_IdentifyImage(unsigned char *p)
{
    unsigned int i;
    unsigned char *q;
    i = 0;
    q = SoundRam_Id_KN5000;
    do { if (*(q + i) != *(p + i)) break; i++; } while (i < 16);
    if (i == 16)
        return 6;
    i = 0;
    q = SoundRam_Id_KN1500;
    do { if (*(q + i) != *(p + i)) break; i++; } while (i < 16);
    if (i == 16)
        return 5;
    i = 0;
    q = SoundRam_Id_KN3000;
    do { if (*(q + i) != *(p + i)) break; i++; } while (i < 16);
    if (i == 16)
        return 4;
    i = 0;
    q = SoundRam_Id_KN2000;
    do { if (*(q + i) != *(p + i + 5)) break; i++; } while (i < 6);
    if (i == 6)
        return 1;
    i = 0;
    q = SoundRam_Id_MKA;
    do { if (*(q + i) != *(p + i + 5)) break; i++; } while (i < 3);
    if (i == 3)
        return 2;
    i = 0;
    q = SoundRam_Id_MKB;
    do { if (*(q + i) != *(p + i + 5)) break; i++; } while (i < 3);
    if (i == 3)
        return 3;
    return 0;
}
