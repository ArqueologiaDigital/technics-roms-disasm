/* Phase 6, lane_p6 helper C, round 17, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s, form a.
   Refinements (run 107) and four new routines of the module:
   - SeqStep_VelNoteFwd (+16; round 16 form b at -Xr differed only where the ROM widens the bar byte in BC, extz BC,
     and moves it to WA; V4.23 copied it to A and widened WA): the widened local declared before the byte.
   - SeqStep_SkipToHighBit (+56) and its twin SeqStep_AdvanceHelper1 (new, other cells): after `ret z` for 0x82 the
     ROM jumps over a lone `ret` for 0x81, the shape of a two-case switch whose shared body (return) follows the
     compare chain, the rest being the default.
   - SeqStep_ByteBlockEA5F (+7): V4.23 padded the struct's 119-byte field to 120, so the song byte and mask word
     landed one byte high; here the three song-record cells are separate __near cells (the ROM moves into them
     memory to memory), the saved words declared a, b, c.
   - SeqStep_EventAdvance (new): from the saved position, skip events to the 0x7f end mark, then copy the bytes from
     there back through PartCtrl_WriteByte_Indexed up to the 0x81 mark; restores the cursor on error or end.
   - SeqStep_DeleteShiftEvents (new): collect one event's bytes (up to a status byte) into a local buffer, step
     back, and either write them at the remembered position or shift the following bytes down.
   - SeqStep_DecrementPos (new): step the remembered position back one byte, or to the previous block.
   Form b (p6_C_17m236b.c) has the alternatives. */
/* cc900-module: SeqStep_FindAndCompact SeqStep_MeasureRead SeqStep_WalkWithCallback */

extern int __near SEQ_OP_FROM;
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned int __near ram_28bf;
extern unsigned int __near ram_28c1;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned int __near ram_2648;
extern unsigned int __near ram_264a;
extern unsigned char __near ram_264c;
extern unsigned char __near ram_264e;
extern unsigned char __near ram_2720;
extern unsigned int __near ram_2726;
extern unsigned char __near ram_2662;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned char __near ram_f247;
extern unsigned int __near ram_f248;
extern unsigned int __near ram_f1ce;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;

extern void SeqVoice_SeekToBar(int, int);
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_WriteByte_Indexed(int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void SeqPart_WriteByte_Primary(unsigned int);
extern void PartCtrl_AdvanceReadPos(void);
extern void PartCtrl_NavigateBackward(void);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_NavigateBackwardAlt(void);
extern void SeqData_CopyBlockToBuffer(int);
extern void VoicePreset_LoadAndInitPan(int);
extern int SeqStep_WalkWithCallback(void);
extern void SeqStep_MeasureRead(void);
extern void SeqStep_FindAndCompact(void);

void SeqStep_VelNoteFwd(void)
{
    int v = SEQ_OP_FROM;
    int a, t;
    unsigned char m;
    if (v == 1) return;
    m = ram_2634;
    t = v;
    ram_287f = t;
    a = m;
    SeqVoice_SeekToBar(a, 0);
    if (SEQ_ERROR_CODE != 0) return;
    if (SeqStep_WalkWithCallback() == 0) {
        SEQ_DATA_BLOCK = ram_28bf;
        SEQ_DATA_OFFSET = ram_28c1;
        SeqData_AdvancePosition();
    }
    ram_273e = SEQ_DATA_OFFSET;
    ram_273c = SEQ_DATA_BLOCK;
    SeqStep_MeasureRead();
}

void SeqStep_SkipToHighBit(void)
{
    SEQ_DATA_OFFSET = ram_2644;
    SEQ_DATA_BLOCK = ram_2646;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    switch (SeqData_ReadNextByte()) {
    case 0x81:
    case 0x82:
        return;
    default:
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}

void SeqStep_AdvanceHelper1(void)
{
    SEQ_DATA_OFFSET = ram_2648;
    SEQ_DATA_BLOCK = ram_264a;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    switch (SeqData_ReadNextByte()) {
    case 0x81:
    case 0x82:
        return;
    default:
        ram_2648 = SEQ_DATA_OFFSET;
        ram_264a = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264e = SeqData_ReadNextByte();
    }
}

void SeqStep_ByteBlockEA5F(void)
{
    unsigned int a, b, c;
    ram_f247 = SEQ_CURRENT_SONG;
    ram_f248 = SEQ_TRACK_MASK_COPY;
    SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
    SeqStep_FindAndCompact();
    a = ram_f1ce;
    b = SEQ_FREE_BLOCKS;
    c = SEQ_FREE_LIST_HEAD;
    VoicePreset_LoadAndInitPan(SEQ_CURRENT_SONG);
    ram_f1ce = a;
    SEQ_FREE_BLOCKS = b;
    SEQ_FREE_LIST_HEAD = c;
}

void SeqStep_EventAdvance(void)
{
    unsigned int blk, off;
    unsigned char c, d;
    blk = SEQ_DATA_BLOCK;
    off = SEQ_DATA_OFFSET;
    if (!(SEQ_EDIT_FLAGS & 1)) return;
    SEQ_DATA_BLOCK = ram_273c;
    SEQ_DATA_OFFSET = ram_273e;
    for (;;) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) goto restore;
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
restore:
    SEQ_DATA_BLOCK = blk;
    SEQ_DATA_OFFSET = off;
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
    while (PartCtrl_AdvanceReadPos(), SEQ_ERROR_CODE == 0) {
        r = SeqPart_ReadByte_Secondary();
        buf[i++] = r;
        if (r & 0x80) goto found;
    }
    return;
found:
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
                SeqPart_WriteByte_Primary(buf[j]);
                PartCtrl_AdvanceToNextEntry();
                if (SEQ_ERROR_CODE != 0) return;
            }
            return;
        }
        SeqPart_WriteByte_Primary(r);
        PartCtrl_NavigateBackward();
        if (SEQ_ERROR_CODE != 0) return;
        PartCtrl_NavigateBackwardAlt();
        if (SEQ_ERROR_CODE != 0) return;
    }
}

void SeqStep_DecrementPos(void)
{
    unsigned int w, r;
    w = ram_273e;
    if (w != 5) {
        ram_2720 = w - 1;
        ram_2726 = ram_273c;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_273c);
        if (r == 0) return;
        ram_2726 = r;
        ram_2720 = 0xff;
    }
    ram_2662 = 1;
}
