/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned int __near ram_2648;
extern unsigned int __near ram_264a;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void SeqPart_WriteByte_Primary(int);
extern void PartCtrl_AdvanceReadPos(void);
extern void PartCtrl_NavigateBackward(void);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_NavigateBackwardAlt(void);
extern void SeqStep_DeleteShiftEvents(void);

void SeqStep_DeleteShiftEvents(void)
{
    unsigned char buf[8];
    unsigned int i, j;
    unsigned char r;
    SEQOP_SECONDARY_BLOCK = ram_264a;
    SEQOP_SECONDARY_OFFSET = ram_2648;
    i = 0;
    buf[i++] = SeqPart_ReadByte_Secondary();
    PartCtrl_AdvanceReadPos();
    if (SEQ_ERROR_CODE == 0) goto collect;
    return;
    for (;;) {
        PartCtrl_AdvanceReadPos();
        if (SEQ_ERROR_CODE != 0) return;
collect:
        r = SeqPart_ReadByte_Secondary();
        buf[i++] = r;
        if (r & 0x80) break;
    }
    i--;
    PartCtrl_NavigateBackward();
    SEQOP_PRIMARY_BLOCK = SEQOP_SECONDARY_BLOCK;
    SEQOP_PRIMARY_OFFSET = SEQOP_SECONDARY_OFFSET;
    SEQOP_SECONDARY_BLOCK = ram_264a;
    SEQOP_SECONDARY_OFFSET = ram_2648;
    PartCtrl_NavigateBackward();
    for (;;) {
        r = SeqPart_ReadByte_Secondary();
        if (SEQOP_SECONDARY_BLOCK == ram_2646 && SEQOP_SECONDARY_OFFSET == ram_2644) {
            SeqPart_WriteByte_Primary((unsigned int)r);
            SEQOP_PRIMARY_BLOCK = ram_2646;
            SEQOP_PRIMARY_OFFSET = ram_2644;
            j = 0;
            if (j >= i) return;
write:
            SeqPart_WriteByte_Primary(buf[j]);
            PartCtrl_AdvanceToNextEntry();
            if (SEQ_ERROR_CODE == 0) goto next;
            return;
        }
        SeqPart_WriteByte_Primary((int)r);
        PartCtrl_NavigateBackward();
        if (SEQ_ERROR_CODE != 0) return;
        PartCtrl_NavigateBackwardAlt();
        if (SEQ_ERROR_CODE != 0) return;
    }
next:
    j++;
    if (j < i) goto write;
}
