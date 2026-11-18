/* FORM B of p6_I_1m307a.c: the two later size sums written `x->size += y->size + 6`.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 1, module 307 (the runtime library in audio/note_voice_mapping.s), form a.  New.
   Free(p) (__cdecl: the pointer on the stack): returns a Malloc block to the address-ordered free list whose head is
   at 0x3d52c, under kernel event 1, coalescing with the next and the previous free block.  A block is a 6-byte
   header {next, size} followed by size bytes.  Every exit signals event 1 as a tail jump.
   Read from the hand assembly: the block in XBC, the walk pointer in XIX, the previous one in XDE (both start at the
   head), the walk's test copied to the loop entry (-O3).  The size sums: the head's case adds `head->size + 6` to
   b->size in memory; the other two load the absorbed block's size first (`q->size + b->size + 6`), which form a
   writes as that sum and form b as `+=`. */

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

    if (p == 0)
        return;
    TaskEvent_Wait(1);
    b = (struct blk *)((char *)p - 6);
    if (ram_3d52c == 0) {
        b->next = 0;
        ram_3d52c = b;
        TaskEvent_Signal(1);
        return;
    }
    for (prev = q = ram_3d52c; q != 0 && b > q; q = q->next)
        prev = q;
    if (b == q) {
        TaskEvent_Signal(1);
        return;
    }
    if (q == ram_3d52c) {
        if ((char *)(b + 1) + b->size == (char *)ram_3d52c) {
            b->next = ram_3d52c->next;
            b->size += ram_3d52c->size + 6;
        } else
            b->next = ram_3d52c;
        ram_3d52c = b;
        TaskEvent_Signal(1);
        return;
    }
    if (q != 0 && (char *)(b + 1) + b->size == (char *)q) {
        b->next = q->next;
        b->size += q->size + 6;
    } else
        b->next = q;
    if ((char *)(prev + 1) + prev->size == (char *)b) {
        prev->next = b->next;
        prev->size += b->size + 6;
    } else
        prev->next = b;
    TaskEvent_Signal(1);
}
