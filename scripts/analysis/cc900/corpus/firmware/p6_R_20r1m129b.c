/* Helper R, round 1 of 2026-11-20: module 129, form b (early return, pre-increment on the cell, an int index). */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;
extern unsigned char __near ram_65d;
extern unsigned char __near ram_694;
extern unsigned char __near ram_6ba[];

void SeMenu_SMD_Sec3End(unsigned char a)
{
  unsigned char f = a != 0;
  ram_65c = f;
}

void SeMenu_SetCurrentPart(unsigned char a)
{
  if (a < 1 || a > 4) {
    ram_65d = 1;
    return;
  }
  ram_65d = a;
}

unsigned char SeMenu_AdvanceSubIndex(void)
{
  return ++ram_694;
}

void SeMenu_StoreParamByte(unsigned char a, unsigned char c)
{
  unsigned int i = a - 1;
  ram_6ba[i] = c;
}
