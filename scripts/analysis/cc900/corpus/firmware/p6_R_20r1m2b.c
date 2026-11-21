/* Helper R, round 1 of 2026-11-20: modules 0 / 2 / 3, form b (returns instead of if/else stores, a while loop for
   the fill, the ready test inverted). */

extern volatile unsigned char __tiny P7;
extern volatile unsigned char __tiny PH;
extern unsigned char __near REGION_CODE_VAR;

int Flash_CheckReady(void)
{
  if (!(P7 & 0x20)) return -1;
  return 0;
}

void Flash_FillBuffer(unsigned int *p, unsigned int n)
{
  unsigned int i = 0;
  while (i < n) {
    *p++ = i;
    i++;
  }
}

void Detect_Region_Code(void)
{
  if (PH & 0x04) {
    if (PH & 0x02) {
      REGION_CODE_VAR = 1;
      return;
    }
    REGION_CODE_VAR = 2;
    return;
  }
  if (PH & 0x02) {
    REGION_CODE_VAR = 3;
    return;
  }
  REGION_CODE_VAR = 4;
}
