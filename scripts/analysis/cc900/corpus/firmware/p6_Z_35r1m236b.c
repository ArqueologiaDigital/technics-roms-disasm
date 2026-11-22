/* Probe round 35r1, helper Z, form b: sequencer/seq_step_routines.s (module 236).  As form a, the range test as
   an if / else around the whole rebuild (no early return), and the counter loop as a while. */

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

    if (start <= 0x4d8) {
        SEQ_FREE_LIST_HEAD = start;
        SEQ_FREE_BLOCKS = 0;
        PartCtrl_SetClearBit7(start, 0);
        PartCtrl_WriteWord_Off1(start, 0);
        PartCtrl_WriteWord(start, start + 1);
        PartCtrl_WriteByteToBuf(start, 5, 0x82);
        SEQ_FREE_BLOCKS++;
        i = start + 1;
        while (i < 0x4d8) {
            PartCtrl_SetClearBit7(i, 0);
            PartCtrl_WriteWord_Off1(i, i - 1);
            PartCtrl_WriteWord(i, i + 1);
            PartCtrl_WriteByteToBuf(start, 5, 0x82);
            SEQ_FREE_BLOCKS++;
            i++;
        }
        PartCtrl_SetClearBit7(0x4d8, 0);
        if (start != 0x4d8)
            PartCtrl_WriteWord_Off1(0x4d8, 0x4d7);
        PartCtrl_WriteWord(0x4d8, 0xffff);
        PartCtrl_WriteByteToBuf(start, 5, 0x82);
        SEQ_FREE_BLOCKS++;
    } else {
        SEQ_FREE_BLOCKS = 0;
        SEQ_FREE_LIST_HEAD = 0xffff;
    }
}
