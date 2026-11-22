/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m236a.c (2026-11-22-23-p6-r90)
   sha256 800226df2bebd591886ad3e897fd7ab799da5c4d7dca0332c7cfd034d229b5ec (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
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
