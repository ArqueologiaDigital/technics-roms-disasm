/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: DrawRing_TryPost GetCurrentTarget */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_SetTaskLevel(int level, int how);
extern void *DrawRing_TryPost(void *cmd);
extern void *DrawRing_Post(void *cmd);

void *DrawRing_Post(void *cmd)
{
    void *s;
    do {
        TaskEvent_Wait(3);
        s = DrawRing_TryPost(cmd);
        TaskEvent_Signal(3);
        if (s == 0)
            Kernel_SetTaskLevel(5, 2);
    } while (s == 0);
    return s;
}
