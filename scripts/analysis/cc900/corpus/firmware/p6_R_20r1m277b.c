/* Helper R, round 1 of 2026-11-20: modules 277-288, form b (the delay as a while loop, the rule bytes through
   locals, the polyphony flag as a conditional expression). */

extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);

void DELAY_300_LOOPS(void)
{
  unsigned int i = 300;
  while (--i != 0)
    ;
}

int PanelTlv_Rule_KeepBits(unsigned char *base, unsigned char *rule)
{
  unsigned char *r = rule;
  base[r[1]] &= r[2];
  return 3;
}

int PanelTlv_Rule_StoreByte(unsigned char *base, unsigned char *rule)
{
  unsigned char *r = rule;
  base[r[1]] = r[2];
  return 3;
}

void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  SubCPU_SetPolyphonyModeAndResendVolumes((a & 0x04) ? 1 : 0);
}
