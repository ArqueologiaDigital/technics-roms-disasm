/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_660[];
extern unsigned char __near ram_6be[];
extern unsigned int __near ram_6b0;
extern unsigned char ram_e3e2;
extern unsigned char PART_SELECT;
extern void UI_PostDialValueEvent(unsigned int);
extern void UI_PostDialRangeEvent(unsigned int);

unsigned char SeMenu_BitShiftMask(unsigned char m, unsigned char n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    m += m;
  return m;
}

unsigned char SeMenu_GetPartConfigBit3(void)
{
  return ram_e3e2 & 0x08;
}

void SeMenu_LoadMasterPtr(unsigned char *p)
{
  *p = PART_SELECT;
}

void SeMenu_LoadPartParam(unsigned char i, unsigned char *dst)
{
  *dst = ram_660[i];
}

void SeMenu_PostEditUpDownSet(unsigned char down, unsigned char c, unsigned char e)
{
  unsigned int v;
  v = (unsigned char)((c - 1) | e);
  if (down == 0)
    UI_PostDialValueEvent(v);
  else
    UI_PostDialRangeEvent(v);
}

void SeMenu_SetMode_Data_0x5(unsigned int *p)
{
  *p = ram_6b0;
}

void SeMenu_SetPartConfigBit3(void)
{
  ram_e3e2 |= 0x08;
}

void SeMenu_StoreEffectParam_Data(unsigned char i, unsigned char *dst)
{
  *dst = ram_6be[i];
}

void SeMenu_StorePartParam(unsigned char i, unsigned char v)
{
  ram_660[i] = v;
}

extern unsigned char __near ram_65d;
extern unsigned char __near ram_694;
extern unsigned int __near ram_6aa;
extern unsigned char __near ram_6ba[];
extern void UI_PostDialEnable(unsigned int);

unsigned char SeMenu_AdvanceSubIndex(void)
{
  unsigned char v = ram_694;
  v++;
  ram_694 = v;
  return v;
}

void SeMenu_GetWordEntryCount(unsigned int *p)
{
  *p = ram_6aa;
}

void SeMenu_PostDialEnable(unsigned char a)
{
  UI_PostDialEnable(a);
}

void SeMenu_ReadObjParam_Data(unsigned char a)
{
  ram_694 = a;
}

void SeMenu_SetCurrentPart(unsigned char a)
{
  if (a >= 1 && a <= 4)
    ram_65d = a;
  else
    ram_65d = 1;
}

void SeMenu_StoreEffectParam(unsigned char a, unsigned char c)
{
  ram_6be[a] = c;
}

void SeMenu_StoreParamByte(unsigned char a, unsigned char c)
{
  ram_6ba[a - 1] = c;
}
