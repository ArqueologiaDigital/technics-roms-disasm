/* Phase 6, helper B, round 20, form e (other C shape of p6_B_20d.c): SeqPos_AdvanceWithWrap with the offset updated
   in memory (`+=`) and the wrap written as one expression. */
/* cc900-module: PartCtrl_ReadWord */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);

void SeqPos_AdvanceWithWrap(unsigned char a)
{
  SEQ_DATA_OFFSET += a;
  if (SEQ_DATA_OFFSET > 0xff) {
    SEQ_DATA_OFFSET = SEQ_DATA_OFFSET - 0x100 + 5;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
