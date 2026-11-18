/* Phase 6, lane_p6 helper I, round 3, module 307, form a.  Refines Free (p6_I_1m307a/b.c; run 2026-11-18-12-p6-r35:
   +15 at Xr).  Against the ROM, round 1's Xr listing (1) formed the block address with lda from XWA where the ROM
   loads the argument into XBC and decrements it by 6: here `b = p; b--;`; (2) jumped to a bottom loop test where
   the ROM tests the walk pointer at the entry and at the bottom, with `b <= q` as the first statement of the body:
   here `if (q != 0) do { ... } while (q != 0)`; (3) computed the block's end inside each branch where the ROM
   computes it once before the head test: here a variable end.  Form b: end as an unsigned long sum. */

struct blk { struct blk *next; unsigned int size; };

extern struct blk *ram_3d52c;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void __cdecl Free(void *p);

void __cdecl Free(void *p)
{
    struct blk *b;
    struct blk *q;
    struct blk *prev;
    char *end;

    if (p == 0)
        return;
    TaskEvent_Wait(1);
    b = p;
    b--;
    if (ram_3d52c == 0) {
        b->next = 0;
        ram_3d52c = b;
        TaskEvent_Signal(1);
        return;
    }
    prev = q = ram_3d52c;
    if (q != 0)
        do {
            if (b <= q)
                break;
            prev = q;
            q = q->next;
        } while (q != 0);
    if (b == q) {
        TaskEvent_Signal(1);
        return;
    }
    end = (char *)(b + 1) + b->size;
    if (q == ram_3d52c) {
        if (end == (char *)ram_3d52c) {
            b->next = ram_3d52c->next;
            b->size += ram_3d52c->size + 6;
        } else
            b->next = ram_3d52c;
        ram_3d52c = b;
        TaskEvent_Signal(1);
        return;
    }
    if (q != 0 && end == (char *)q) {
        b->next = q->next;
        b->size = q->size + b->size + 6;
    } else
        b->next = q;
    if ((char *)(prev + 1) + prev->size == (char *)b) {
        prev->next = b->next;
        prev->size = b->size + prev->size + 6;
    } else
        prev->next = b;
    TaskEvent_Signal(1);
}
