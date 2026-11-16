/* lane_p6 helper H, round 11, module 273 (ui/ui_widget_defs.s), form b: KillApTimer as form a (last two parameters
   swapped, no record pointer local), with the walk written as a for loop whose step reads the next index, in case
   the index then counts as a loop variable loaded from a global (allocated before the hoisted table base). */

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))

int KillApTimer(long time, long obj, long target, long event, long param)
{
    int i;
    int n;

    for (i = ram_30448; i != -1; i = APTIMER(i)->next) {
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
    }
    return 0;
}
