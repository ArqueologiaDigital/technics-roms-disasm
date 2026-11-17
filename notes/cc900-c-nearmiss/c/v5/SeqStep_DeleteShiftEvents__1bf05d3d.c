/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/seq_step_routines_m236.c (2026-11-17-6-p6-r30-staged)
   sha256 1bf05d3d48d60d6a953577431ff89b2bef67fae74c2ba7d22447ca075776cd3e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_262a;
extern unsigned int __near ram_262c;
extern unsigned int __near ram_262e;
extern unsigned int __near ram_2630;
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
void SeqStep_DeleteShiftEvents(void)
{
    unsigned char buf[8];
    unsigned int i, j;
    unsigned char r;
    SEQOP_SECONDARY_BLOCK = ram_2630;
    SEQOP_SECONDARY_OFFSET = ram_262e;
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
    SEQOP_SECONDARY_BLOCK = ram_2630;
    SEQOP_SECONDARY_OFFSET = ram_262e;
    PartCtrl_NavigateBackward();
    for (;;) {
        r = SeqPart_ReadByte_Secondary();
        if (SEQOP_SECONDARY_BLOCK == ram_262c && SEQOP_SECONDARY_OFFSET == ram_262a) {
            SeqPart_WriteByte_Primary((unsigned int)r);
            SEQOP_PRIMARY_BLOCK = ram_262c;
            SEQOP_PRIMARY_OFFSET = ram_262a;
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
