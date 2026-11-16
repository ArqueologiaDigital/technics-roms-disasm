/* lane_p6 helper H, round 8, module 273, form a: KillApTimer from run 92 form b (which put t / the next
   pointer / the moved copy in the ROM's XHL / XIZ / XBC), now with no &t->obj local either. */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long param, long event)
{
    int i;
    struct aptimer *t;
    int n;

    i = ram_30448;
    while (i != -1) {
        t = APTIMER(i);
        if (t->obj == obj && t->target == target && t->event == event && t->param == param) {
            n = t->next;
            if (n != -1)
                APTIMER(n)->prev = t->prev;
            if (t->prev != -1)
                APTIMER(t->prev)->next = t->next;
            if (i == ram_30448)
                ram_30448 = t->next;
            t->obj = -1;
            t->next = -1;
            t->prev = -1;
            return 1;
        }
        i = t->next;
    }
    return 0;
}
