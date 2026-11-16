/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_13m234.c (2026-11-16-100-p6-r19)
   sha256 91539ed5360517e84c84fac2b0eb29125fab53d38ca79cc8db5cad673c965da5 (tar-sha256); compiled at -Xr */
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern int Part_DecrementVoicePos(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
void Part_UnlinkVoiceFromChain(void)
{
  unsigned int p, n;
  if (PartCtrl_TestBit7(1) == 0) {
    PartCtrl_SetClearBit7(1, 1);
    Part_DecrementVoicePos();
    p = PartCtrl_ReadWord_Off1(1);
    n = PartCtrl_ReadWord(1);
    if (p == 0) {
      if (n != 0xffff) { Part_WriteWordBlock_OffsetAF(n); PartCtrl_WriteWord_Off1(n, 0); }
    } else if (n == 0xffff) PartCtrl_WriteWord(p, 0xffff);
    else { PartCtrl_WriteWord(p, n); PartCtrl_WriteWord_Off1(n, p); }
    PartCtrl_WriteWord_Off1(1, 0);
    PartCtrl_WriteWord(1, 0xffff);
  }
  if (PartCtrl_TestBit7(2) == 0) {
    PartCtrl_SetClearBit7(2, 1);
    Part_DecrementVoicePos();
    p = PartCtrl_ReadWord_Off1(2);
    n = PartCtrl_ReadWord(2);
    if (p == 0) {
      if (n != 0xffff) { Part_WriteWordBlock_OffsetAF(n); PartCtrl_WriteWord_Off1(n, 0); }
    } else if (n == 0xffff) PartCtrl_WriteWord(p, 0xffff);
    else { PartCtrl_WriteWord(p, n); PartCtrl_WriteWord_Off1(n, p); }
    PartCtrl_WriteWord_Off1(2, 0);
    PartCtrl_WriteWord(2, 0xffff);
  }
}
