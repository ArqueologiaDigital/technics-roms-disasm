/* helper W, round 21r2, module 243 (sequencer/accompaniment_engine.s), form a: MspSave_InitAndCalcSize.  Run r62's
   best (p6_U_21r1m243b@Xr) put the pointer local in XWA (`ld xwa, imm; ld hl, (xwa)`); the ROM loads the address
   into XHL, the register of the returned long.  Here one long local holds the address and then the value, so the
   address lives in the result's register. */

extern void Voice_RefreshBankData(void);

unsigned long MspSave_InitAndCalcSize(void)
{
  unsigned long r;
  Voice_RefreshBankData();
  r = 0x1e881cL;
  r = *(unsigned int *)r;
  return r << 4;
}
