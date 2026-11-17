/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m273.c (2026-11-16-122-p6-r24-staged)
   sha256 aa785c918f3735c1be36816a32275fedcea3e20ffc194b7b350cf82848aae3d7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
