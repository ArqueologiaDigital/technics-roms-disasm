/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/task_scheduler_kernel.c (2026-11-16-73-sub-r6)
   sha256 41dbd79e332f9e1072b82fe689f046c8f1874fb9dad8e82308ddffa53977de69 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
void RingBuf_Reset_512(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0x1ff;
}
