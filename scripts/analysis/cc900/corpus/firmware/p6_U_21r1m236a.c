/* helper U, round 21r1, module 236, form a: SeqStep_TimerDispatchB.  The ROM indexes with a 16-bit register
   ((xbc+wa) after extz / sla of the byte) from a table address taken with lda: the table in a pointer local and
   the byte cell as the index (run r59's int local gave exts xwa). */

extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchB_PtrTable[])(void);

void SeqStep_TimerDispatchB(void)
{
  void (**t)(void);
  t = SeqStep_TimerDispatchB_PtrTable;
  t[ram_22fc]();
}
