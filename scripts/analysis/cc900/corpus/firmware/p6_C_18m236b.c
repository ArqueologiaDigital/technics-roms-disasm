/* Phase 6, lane_p6 helper C, round 18, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s, form b
   (form a, p6_C_18m236a.c, explains the changes):
   - SeqStep_EventAdvance: the restore inside the first error branch as in form a, the copy loop as a while that
     tests the 0x81 mark at its top, followed by a jump to the restore;
   - SeqStep_DeleteShiftEvents: the entry goto as in form a; the routine ends in the writing loop, reached by
     leaving the search loop (break) when the remembered position is met, its error test written as
     `continue` / `return`. */
/* no module-local callee (module_calls.py) */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned int __near ram_2648;
extern unsigned int __near ram_264a;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_WriteByte_Indexed(int);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void SeqPart_WriteByte_Primary(unsigned int);
extern void PartCtrl_AdvanceReadPos(void);
extern void PartCtrl_NavigateBackward(void);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_NavigateBackwardAlt(void);

void SeqStep_EventAdvance(void)
{
    unsigned char c, d;
    unsigned int blk, off;
    blk = SEQ_DATA_BLOCK;
    off = SEQ_DATA_OFFSET;
    if (!(SEQ_EDIT_FLAGS & 1)) return;
    SEQ_DATA_BLOCK = ram_273c;
    SEQ_DATA_OFFSET = ram_273e;
    for (;;) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) {
restore:
            SEQ_DATA_BLOCK = blk;
            SEQ_DATA_OFFSET = off;
            return;
        }
        if (SeqData_ReadNextByte() == 0x7f) break;
        do {
            SeqData_AdvancePosition();
            if (SEQ_ERROR_CODE != 0) goto restore;
        } while (!(SeqData_ReadNextByte() & 0x80));
        ram_273c = SEQ_DATA_BLOCK;
        ram_273e = SEQ_DATA_OFFSET;
    }
    SEQ_DATA_OFFSET = ram_273e;
    SEQ_DATA_BLOCK = ram_273c;
    c = SeqData_ReadNextByte();
    PartCtrl_WriteByte_Indexed(0x81);
    while (c != 0x81) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) break;
        d = c;
        c = SeqData_ReadNextByte();
        PartCtrl_WriteByte_Indexed(d);
        if (d & 0x80) c = 0;
    }
    goto restore;
}

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
    if (SEQ_ERROR_CODE == 0) goto body;
    return;
    for (;;) {
        PartCtrl_AdvanceReadPos();
        if (SEQ_ERROR_CODE != 0) return;
body:
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
        if (SEQOP_SECONDARY_BLOCK == ram_2646 && SEQOP_SECONDARY_OFFSET == ram_2644) break;
        SeqPart_WriteByte_Primary(r);
        PartCtrl_NavigateBackward();
        if (SEQ_ERROR_CODE != 0) return;
        PartCtrl_NavigateBackwardAlt();
        if (SEQ_ERROR_CODE != 0) return;
    }
    SeqPart_WriteByte_Primary(r);
    SEQOP_PRIMARY_BLOCK = ram_2646;
    SEQOP_PRIMARY_OFFSET = ram_2644;
    for (j = 0; j < i; j++) {
        SeqPart_WriteByte_Primary(buf[j]);
        PartCtrl_AdvanceToNextEntry();
        if (SEQ_ERROR_CODE == 0) continue;
        return;
    }
}
