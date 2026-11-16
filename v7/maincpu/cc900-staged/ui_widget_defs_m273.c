/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct aptimer { int prev; int next; long time; long obj; long target; long event; long param; };
extern struct aptimer ram_2f844[];
extern int ram_30448;
#define APTIMER(n) ((struct aptimer *)((char *)ram_2f844 + (n) * 24))
extern int KillApTimer(long time, long obj, long target, long event, long param);

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
