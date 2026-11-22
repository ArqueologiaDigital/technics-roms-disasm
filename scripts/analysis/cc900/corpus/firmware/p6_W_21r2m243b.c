/* helper W, round 21r2, module 243, form b: MspSave_InitAndCalcSize with the address in a long local and the value
   read and shifted in the return expression (form a stores the value back into the same local). */

extern void Voice_RefreshBankData(void);

unsigned long MspSave_InitAndCalcSize(void)
{
  unsigned long r;
  Voice_RefreshBankData();
  r = 0x1e881cL;
  return (unsigned long)*(unsigned int *)r << 4;
}
