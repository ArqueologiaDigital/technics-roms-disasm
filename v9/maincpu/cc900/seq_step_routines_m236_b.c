/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int start);

void SeqStep_RebuildPartChain(unsigned int start)
{
    register unsigned int i;

    if (start > 0x4d8) {
        SEQ_FREE_BLOCKS = 0;
        SEQ_FREE_LIST_HEAD = 0xffff;
        return;
    }
    SEQ_FREE_LIST_HEAD = start;
    SEQ_FREE_BLOCKS = 0;
    PartCtrl_SetClearBit7(start, 0);
    PartCtrl_WriteWord_Off1(start, 0);
    PartCtrl_WriteWord(start, start + 1);
    PartCtrl_WriteByteToBuf(start, 5, 0x82);
    SEQ_FREE_BLOCKS++;
    for (i = start + 1; i < 0x4d8; i++) {
        PartCtrl_SetClearBit7(i, 0);
        PartCtrl_WriteWord_Off1(i, i - 1);
        PartCtrl_WriteWord(i, i + 1);
        PartCtrl_WriteByteToBuf(start, 5, 0x82);
        SEQ_FREE_BLOCKS++;
    }
    PartCtrl_SetClearBit7(0x4d8, 0);
    if (start != 0x4d8)
        PartCtrl_WriteWord_Off1(0x4d8, 0x4d7);
    PartCtrl_WriteWord(0x4d8, 0xffff);
    PartCtrl_WriteByteToBuf(start, 5, 0x82);
    SEQ_FREE_BLOCKS++;
}
