/* Phase 6, helper B, round 13, module 234 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   Part_UnlinkVoiceFromChain.  Part control blocks 1 and 2 are the heads of the two block chains: when a head is
   in use (bit 7 clear) it is marked, the free count is decremented, the block is taken out of its chain (word +1 =
   previous, word +3 = next) and reset to an empty end block.  Every callee is in the same module (calr). */
/* cc900-module: PartCtrl_ReadWord PartCtrl_ReadWord_Off1 PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_DecrementVoicePos Part_WriteWordBlock_OffsetAF */

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
