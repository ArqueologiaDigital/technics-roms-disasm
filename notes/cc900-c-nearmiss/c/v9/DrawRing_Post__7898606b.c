/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m273_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 7898606b08dfd01a9962658eebb880e1dbd30df00ade9d2fb8cad7165360769e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern void Kernel_SetTaskLevel(int level, int how);
extern void *DrawRing_TryPost(void *cmd);
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
