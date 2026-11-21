/* helper U, round 21r1, module 243, form b: AccTuning_SaveState through a byte local (cells not volatile);
   MspSave_InitAndCalcSize with the pointer local and the value in an unsigned long local. */

extern unsigned char __near ram_3391;
extern unsigned char __near ram_3392;
extern void Voice_RefreshBankData(void);

void AccTuning_SaveState(void)
{
  unsigned char t;
  t = ram_3391;
  ram_3392 = t;
}

unsigned long MspSave_InitAndCalcSize(void)
{
  unsigned int *p;
  unsigned long r;
  Voice_RefreshBankData();
  p = (unsigned int *)0x1e881cL;
  r = *p;
  return r << 4;
}
