/* Probe round 33r1, helper W, form b (form a with two spots changed: the first part compare reads ram_2652
   directly, and ram_265c / ram_265e are volatile, for the ROM's load + store of the first cursor copy).
   sequencer/sequencer_engine.s (module 236).
   SeqPart_Exchange: clear the working flags, allocate the source part when it is new (the built
   SeqPart_AllocNewEntry's calls with ram_2652), seek both measures, splice when the destination is past the end,
   then the built SeqPart_Position* trio by comparing the two step counts, and copy the three cursors.
   The flag byte goes through a local (res on A, as the built CancelOperationCleanup); the SeqVoice_SeekToBar part
   number is read into a local before the measure store (the built SeqStep_VelNoteBwd); the per-part tables are
   SIZED __near arrays (16-bit index); the cursor triple is stored through a struct pointer local (lda, then
   memory-to-memory moves). */
/* cc900-module: SeqPart_PositionBackward SeqPart_PositionEqual SeqPart_PositionForward SeqPart_RestoreState SeqPart_Splice SeqPart_UndoAllocOnError */

struct bo { unsigned int block; unsigned int offset; };

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned char __near ram_2652;
extern unsigned char __near ram_2634;
extern unsigned char __near ram_1d68;
extern unsigned char __near ram_282a;
extern unsigned char __near ram_288d;
extern volatile unsigned int __near ram_265c;
extern volatile unsigned int __near ram_265e;
extern unsigned int __near ram_287d;
extern unsigned int __near ram_287f;
extern unsigned int __near ram_cef[16];
extern unsigned int __near ram_d0f[16];
extern unsigned int __near ram_26a8;
extern unsigned int __near ram_26aa;
extern unsigned int __near ram_26b0;
extern unsigned int __near ram_26b2;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern unsigned long __near ram_25da;
extern unsigned long __near ram_27e0;
extern unsigned long __near ram_27e4;
extern struct bo __near ram_282c;
extern struct bo __near ram_2830;
extern struct bo __near ram_2834;

extern void Part_ValidateVoiceChannel(unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void Part_ValidateVoiceAndSetupSeq(unsigned int);
extern unsigned char SeqVoice_FindDrumPartIndex(void);
extern void SeqVoice_SeekToBar(int, int);
extern void SeqData_ScanAllTracks(void);
extern void SeqPart_Splice(void);
extern void SeqPart_RestoreState(void);
extern unsigned int Part_ReadByte_Indexed(unsigned int, unsigned int);
extern unsigned int Part_ReadWord_Indexed(unsigned int, unsigned int);
extern void SeqPart_PositionForward(void);
extern void SeqPart_PositionBackward(void);
extern void SeqPart_PositionEqual(void);
extern void SeqPart_CopyDataSecondary(void);
extern void SeqPart_UndoAllocOnError(void);
extern void SeqPart_Exchange(void);

void SeqPart_Exchange(void)
{
    unsigned int b;
    unsigned char f;
    unsigned char e;
    unsigned char n;
    unsigned char m;
    unsigned long x;
    unsigned long y;
    struct bo *p;

    f = SEQ_EDIT_FLAGS;
    f &= ~0x08;
    f &= ~0x10;
    f &= ~0x80;
    SEQ_EDIT_FLAGS = f;
    SEQ_ERROR_CODE = 0;
    if (ram_2652 != ram_2634) {
        Part_ValidateVoiceChannel(ram_2652);
        e = SEQ_ERROR_CODE;
        if (e != 0) {
            if (e != 1)
                goto cleanup;
            SEQ_ERROR_CODE = 0;
            if (ram_1d68 < 1) {
                SEQ_ERROR_CODE = 5;
                goto cleanup;
            }
            b = Part_ProcessAndDecrementVoice();
            Part_WriteWord_Indexed(0, ram_2652, b);
            Part_WriteByte_Indexed(0, ram_2652, 5);
            Part_SetClearVoiceBit7(0, ram_2652, 1);
            Part_WriteVoiceWord(0, ram_2652, b);
            PartCtrl_WriteWord_Off1(b, 0);
            PartCtrl_WriteWord(b, 0xffff);
            SEQ_EDIT_FLAGS |= 0x80;
        }
    }
    ram_287d = ram_2652;
    Part_ValidateVoiceAndSetupSeq(ram_2652);
    if (SEQ_ERROR_CODE != 0)
        goto cleanup;
    ram_265e = SEQ_DATA_OFFSET;
    ram_265c = SEQ_DATA_BLOCK;
    ram_d0f[(unsigned char)(ram_2652 - 1)] = SEQ_DATA_OFFSET;
    ram_cef[(unsigned char)(ram_2652 - 1)] = SEQ_DATA_BLOCK;
    n = SeqVoice_FindDrumPartIndex();
    m = ram_2634;
    ram_287f = SEQ_OP_FROM;
    SeqVoice_SeekToBar(m, n);
    if (SEQ_ERROR_CODE != 0)
        goto cleanup;
    ram_26b2 = SEQ_DATA_OFFSET;
    ram_26b0 = SEQ_DATA_BLOCK;
    SeqData_ScanAllTracks();
    e = SEQ_ERROR_CODE;
    if (e != 0) {
        if (e != 7)
            goto cleanup;
        SEQ_EDIT_FLAGS |= 0x08;
        SEQ_ERROR_CODE = 0;
    }
    ram_26aa = SEQ_DATA_OFFSET;
    ram_26a8 = SEQ_DATA_BLOCK;
    ram_27e0 = ram_25da;
    ram_282a &= ~0x01;
    n = ram_288d;
    m = ram_2652;
    ram_287f = SEQ_OP_DEST_MEASURE;
    SeqVoice_SeekToBar(m, n);
    e = SEQ_ERROR_CODE;
    if (e != 0) {
        if (e != 8)
            goto cleanup;
        SeqPart_Splice();
        if (SEQ_ERROR_CODE != 0) {
            SeqPart_RestoreState();
            goto cleanup;
        }
        SEQ_DATA_BLOCK = SEQOP_SECONDARY_BLOCK;
        SEQ_DATA_OFFSET = SEQOP_SECONDARY_OFFSET;
        ram_282a |= 0x01;
        ram_265e = Part_ReadByte_Indexed(0, ram_2652);
        ram_265c = Part_ReadWord_Indexed(0, ram_2652);
    }
    SEQOP_PRIMARY_OFFSET = SEQ_DATA_OFFSET;
    SEQOP_PRIMARY_BLOCK = SEQ_DATA_BLOCK;
    SeqData_ScanAllTracks();
    e = SEQ_ERROR_CODE;
    if (e != 0) {
        if (e != 7)
            goto cleanup;
        SEQ_EDIT_FLAGS |= 0x10;
        SEQ_ERROR_CODE = 0;
    }
    ram_27ea = SEQ_DATA_OFFSET;
    ram_27e8 = SEQ_DATA_BLOCK;
    x = ram_25da;
    ram_27e4 = x;
    y = ram_27e0;
    ram_25da = y;
    if (x < y)
        SeqPart_PositionForward();
    else if (x > y)
        SeqPart_PositionBackward();
    else
        SeqPart_PositionEqual();
    if (SEQ_ERROR_CODE != 0)
        return;
    p = &ram_282c;
    p->block = ram_26a8;
    p->offset = ram_26aa;
    p = &ram_2830;
    p->block = ram_27ec;
    p->offset = ram_27ee;
    p = &ram_2834;
    p->block = ram_26b0;
    p->offset = ram_26b2;
    SeqPart_CopyDataSecondary();
cleanup:
    SeqPart_UndoAllocOnError();
}
