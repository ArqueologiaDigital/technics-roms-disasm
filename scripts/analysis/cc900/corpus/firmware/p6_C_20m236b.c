/* Phase 6, lane_p6 helper C, round 20, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s, form b of
   SeqStep_DeleteShiftEvents (form a, p6_C_20m236a.c, explains the one spot left): the writer declared without a
   prototype (the byte widened by the default promotion at each call), round 19's writing loop. */
/* no module-local callee (module_calls.py) */

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
extern void SeqPart_WriteByte_Primary();
extern void PartCtrl_AdvanceReadPos(void);
extern void PartCtrl_NavigateBackward(void);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_NavigateBackwardAlt(void);

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
            SeqPart_WriteByte_Primary(r);
            SEQOP_PRIMARY_BLOCK = ram_2646;
            SEQOP_PRIMARY_OFFSET = ram_2644;
            for (j = 0; j < i; j++) {
write:
                SeqPart_WriteByte_Primary(buf[j]);
                PartCtrl_AdvanceToNextEntry();
                if (SEQ_ERROR_CODE == 0) goto next;
                return;
            }
            return;
        }
        SeqPart_WriteByte_Primary(r);
        PartCtrl_NavigateBackward();
        if (SEQ_ERROR_CODE != 0) return;
        PartCtrl_NavigateBackwardAlt();
        if (SEQ_ERROR_CODE != 0) return;
    }
next:
    j++;
    if (j < i) goto write;
}
