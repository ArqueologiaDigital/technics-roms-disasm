/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m236a.c (2026-11-21-7-p6-r62)
   sha256 741d54fea396fd24fe6bf87f68eef64a868ef729903472f509682c97cdf53392 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchB_PtrTable[])(void);
void SeqStep_TimerDispatchB(void)
{
  void (**t)(void);
  t = SeqStep_TimerDispatchB_PtrTable;
  t[ram_22fc]();
}
