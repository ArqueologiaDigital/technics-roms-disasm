/* Probe round 35r1, helper Z, form a: sequencer/seq_step_routines.s (module 236), the xr_screen.py shape at -O3 -Xr.
   SeqStep_RebuildPartChain(start): rebuild the free-block list from block start to the last block (0x4d8): each
   block unmarked, linked back to the one before and forward to the one after, the last one ending the list; the
   free count counts them.  A start past the last block empties the list.  (Each block's buffer byte 5 write uses
   start, not the block: that is what the ROM does.)  start stays on the frame, the block counter is a `register`
   local (IZ). */

extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int);

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
