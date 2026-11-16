/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 83e57315c375c1c940336c1fd470f4631a66d0a489ca456b1c516c63985f9806 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
