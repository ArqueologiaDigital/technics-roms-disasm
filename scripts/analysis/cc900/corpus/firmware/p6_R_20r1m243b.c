/* Helper R, round 1 of 2026-11-20: modules 243 / 245 / 261, form b (a local for the pointer step, volatile on the
   destination cell instead of the source, a for loop for the clear). */

extern unsigned long __near ram_3293;
extern unsigned char __near ram_3391;
extern volatile unsigned char __near ram_3392;

unsigned long AccSeq_AdvancePointer(void)
{
  unsigned long p = ram_3293;
  p++;
  ram_3293 = p;
  return p;
}

void AccTuning_SaveState(void)
{
  ram_3392 = ram_3391;
}

void SoundMem_ClearRegion(void)
{
  unsigned char *p;
  for (p = (unsigned char *)0xffc00L; p < (unsigned char *)0x100000L; p++)
    *p = 0;
}
