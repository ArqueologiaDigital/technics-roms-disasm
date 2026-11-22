/* helper U, round 21r1, module 243, form a: one-spot retries of run r59.
   AccTuning_SaveState: volatile on one cell left the memory-to-memory move; both cells volatile here.
   MspSave_InitAndCalcSize: the ROM loads the cell's address into XHL as an immediate and reads through it:
   the pointer in a local. */

extern volatile unsigned char __near ram_3391;
extern volatile unsigned char __near ram_3392;
extern void Voice_RefreshBankData(void);

void AccTuning_SaveState(void)
{
  ram_3392 = ram_3391;
}

unsigned long MspSave_InitAndCalcSize(void)
{
  unsigned int *p;
  Voice_RefreshBankData();
  p = (unsigned int *)0x1e881cL;
  return (unsigned long)*p << 4;
}
