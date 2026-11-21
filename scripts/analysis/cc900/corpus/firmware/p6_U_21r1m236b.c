/* helper U, round 21r1, module 236, form b: SeqStep_TimerDispatchB with an unsigned int index local (form a: the
   byte cell as the index) and the table in a pointer local. */

extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchB_PtrTable[])(void);

void SeqStep_TimerDispatchB(void)
{
  void (**t)(void);
  unsigned int i;
  i = ram_22fc;
  t = SeqStep_TimerDispatchB_PtrTable;
  t[i]();
}
