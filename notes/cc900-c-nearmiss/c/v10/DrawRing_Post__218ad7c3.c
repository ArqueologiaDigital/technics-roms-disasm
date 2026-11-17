/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_13m273a.c (2026-11-16-92-p6-r18)
   sha256 218ad7c393611482524a5f475799747a274cd4183907e8106f93e550e6d7bf60 (tar-sha256); compiled at -O3 -XS -Xr */
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
