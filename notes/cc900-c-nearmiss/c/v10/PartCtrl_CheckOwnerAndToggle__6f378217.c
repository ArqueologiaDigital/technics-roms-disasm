/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
unsigned int PartCtrl_CheckOwnerAndToggle(unsigned int n, unsigned int o, unsigned int m)
{
  unsigned int r = 0;
  if (PartCtrl_ReadWord_Off1(n) != o) r |= 0x10;
  else if (m == 0 && PartCtrl_TestBit7(n) != 0) { PartCtrl_SetClearBit7(n, 0); r |= 0x02; }
  else if (m == 1 && PartCtrl_TestBit7(n) == 0) { PartCtrl_SetClearBit7(n, 1); r |= 0x04; }
  return r;
}
