/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m307b.c (2026-11-18-28-p6-r36)
   sha256 866472c6236d01421e7947c3d748b5908ff8f3d7c51c8ae79a7b3bb5e7ddb7ed (tar-sha256); compiled at -Xr */
struct blk { struct blk *next; unsigned int size; };
extern struct blk *ram_3d52c;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
void __cdecl Free(void *p)
{
    struct blk *b;
    struct blk *q;
    struct blk *prev;
    unsigned long end;

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
    end = (unsigned long)b + 6 + b->size;
    if (q == ram_3d52c) {
        if (end == (unsigned long)ram_3d52c) {
            b->next = ram_3d52c->next;
            b->size += ram_3d52c->size + 6;
        } else
            b->next = ram_3d52c;
        ram_3d52c = b;
        TaskEvent_Signal(1);
        return;
    }
    if (q != 0 && end == (unsigned long)q) {
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
