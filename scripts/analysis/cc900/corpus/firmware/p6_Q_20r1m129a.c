/* helper Q, round 20r1, module 129 (audio/semenu_routines.s): sound-editor parameter cells and dial posts. */

extern unsigned char __near ram_660[];
extern unsigned char __near ram_6be[];
extern unsigned int __near ram_6b0;
extern unsigned char ram_e3e2;
extern unsigned char PART_SELECT;
extern void UI_PostDialValueEvent(unsigned int);
extern void UI_PostDialRangeEvent(unsigned int);

void SeMenu_PostEditUpDownSet(unsigned char down, unsigned char c, unsigned char e)
{
  unsigned int v;
  v = (unsigned char)((c - 1) | e);
  if (down == 0)
    UI_PostDialValueEvent(v);
  else
    UI_PostDialRangeEvent(v);
}

unsigned char SeMenu_BitShiftMask(unsigned char m, unsigned char n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    m += m;
  return m;
}

void SeMenu_LoadPartParam(unsigned char i, unsigned char *dst)
{
  *dst = ram_660[i];
}

void SeMenu_StorePartParam(unsigned char i, unsigned char v)
{
  ram_660[i] = v;
}

void SeMenu_StoreEffectParam_Data(unsigned char i, unsigned char *dst)
{
  *dst = ram_6be[i];
}

void SeMenu_SetMode_Data_0x5(unsigned int *p)
{
  *p = ram_6b0;
}

unsigned char SeMenu_GetPartConfigBit3(void)
{
  return ram_e3e2 & 0x08;
}

void SeMenu_SetPartConfigBit3(void)
{
  ram_e3e2 |= 0x08;
}

void SeMenu_LoadMasterPtr(unsigned char *p)
{
  *p = PART_SELECT;
}
