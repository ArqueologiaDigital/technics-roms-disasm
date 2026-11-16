/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_11m273a.c (2026-11-16-118-p6-r23)
   sha256 30179e586311011c4c4a8293d935a4716ee67d6168190b95cf50c406e7056c8c (tar-sha256); compiled at -O3 -XS -Xr */
struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))
int KillApTimer(long time, long obj, long target, long event, long param)
{
    int i;
    int n;

    i = ram_30448;
    while (i != -1) {
        if (APTIMER(i)->obj == obj && APTIMER(i)->target == target && APTIMER(i)->event == event &&
            APTIMER(i)->param == param) {
            n = APTIMER(i)->next;
            if (n != -1)
                APTIMER(n)->prev = APTIMER(i)->prev;
            if (APTIMER(i)->prev != -1)
                APTIMER(APTIMER(i)->prev)->next = APTIMER(i)->next;
            if (i == ram_30448)
                ram_30448 = APTIMER(i)->next;
            APTIMER(i)->obj = -1;
            APTIMER(i)->next = -1;
            APTIMER(i)->prev = -1;
            return 1;
        }
        i = APTIMER(i)->next;
    }
    return 0;
}
