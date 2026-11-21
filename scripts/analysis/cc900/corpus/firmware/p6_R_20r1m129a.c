/* Helper R, round 1 of 2026-11-20: module 129 (audio/semenu_routines.s), sound-editor menu setters.  Form a. */
/* cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */

extern unsigned char __near ram_65c;
extern unsigned char __near ram_65d;
extern unsigned char __near ram_694;
extern unsigned int __near ram_6aa;
extern unsigned char __near ram_6ba[];
extern unsigned char __near ram_6be[];
extern void UI_PostDialEnable(unsigned int);

void SeMenu_SMD_Sec3End(unsigned char a)
{
  ram_65c = a != 0;
}

void SeMenu_SetCurrentPart(unsigned char a)
{
  if (a >= 1 && a <= 4)
    ram_65d = a;
  else
    ram_65d = 1;
}

unsigned char SeMenu_AdvanceSubIndex(void)
{
  unsigned char v = ram_694;
  v++;
  ram_694 = v;
  return v;
}

void SeMenu_ReadObjParam_Data(unsigned char a)
{
  ram_694 = a;
}

void SeMenu_PostDialEnable(unsigned char a)
{
  UI_PostDialEnable(a);
}

void SeMenu_GetWordEntryCount(unsigned int *p)
{
  *p = ram_6aa;
}

void SeMenu_StoreParamByte(unsigned char a, unsigned char c)
{
  ram_6ba[a - 1] = c;
}

void SeMenu_StoreEffectParam(unsigned char a, unsigned char c)
{
  ram_6be[a] = c;
}
