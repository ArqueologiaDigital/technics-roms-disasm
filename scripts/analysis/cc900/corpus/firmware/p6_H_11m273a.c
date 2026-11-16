/* lane_p6 helper H, round 11, module 273 (ui/ui_widget_defs.s), form a: KillApTimer from round 8 form a.
   Two changes from run 100 (r19): the last two parameters swapped, since the ROM compares the record's +16 field with
   the 4th argument (pushed first, the higher stack slot) and +20 with the 5th; and no pointer local for the record:
   every access is spelt through the index, so the record address is a CSE'd address temporary (allocated before the
   hoisted table base) rather than a declared local (allocated after it), aiming at the ROM's order: index IX, table
   base XIY, record XHL, &obj XDE, &next XIZ. */

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
