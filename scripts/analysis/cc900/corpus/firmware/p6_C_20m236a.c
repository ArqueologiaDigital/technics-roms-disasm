/* Phase 6, lane_p6 helper C, round 20, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s, form a:
   SeqStep_DeleteShiftEvents.  Run 128 (round 19, -O3 -Xr, +45): the layout is the ROM's now (the writing loop's
   increment at the end).  One spot is left: V4.23 widens the byte read at the search loop's top once, right after
   the read (extz HL), because both branches begin by passing it to the writer, and so compares in BC; the ROM
   compares in WA and widens the byte in each branch.  Here the two branches pass it with different casts so they
   no longer share that first step; the writing loop's entry is an early return when there is nothing to write.
   Form b (p6_C_20m236b.c): the writer declared without a prototype, round 19's loop. */
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
