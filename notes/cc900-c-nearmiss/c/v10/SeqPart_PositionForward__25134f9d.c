/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_T_32r1m236a.c (2026-11-22-17-p6-r84)
   sha256 25134f9d686aebce966cfffd5a3e93730033a7733df5f468d0f30d8cba19b3b5 (tar-sha256); compiled at -O3 -Xr */
/* Probe round 32r1, helper T, form a: sequencer/sequencer_engine.s (module 236).
   SeqPart_PositionForward (twin of the built SeqPart_PositionEqual, cc900/sequencer_engine_m236.c; written with
   early returns and the flag byte in a local), SeqPart_RestoreState (chained table copies), and
   SeqPart_CheckBothCompatible (written like the built SeqPart_SetupLeftPos: int result 0 / -1). */
/* cc900-module: SeqPart_RestoreState SeqPart_SetupWithDispatch SeqPart_UndoAllocOnError */

struct bo { unsigned int block; unsigned int offset; };

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_282a;
extern unsigned char __near ram_2652;
extern unsigned char __near ram_ce5;
extern unsigned char __near ram_2873;
extern unsigned char __near ram_287c;
extern unsigned int __near ram_287d;
extern unsigned int __near ram_cef[];
extern unsigned int __near ram_d0f[];
extern unsigned long __near ram_25da;
extern unsigned long __near ram_27e4;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern unsigned int __near ram_269c;
extern unsigned int __near ram_26a2;
extern unsigned int __near ram_26a8;
extern unsigned int __near ram_26aa;
extern unsigned int __near ram_26ac;
extern unsigned int __near ram_26ae;
extern unsigned int __near ram_26b8;
extern unsigned long __near ram_26ba;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern struct bo __near ram_282c;
extern struct bo __near ram_2830;
extern struct bo __near ram_2834;
extern unsigned char SeqStep_ParseRhythm_ByteMap[];

extern void SeqBuf_ComputePageLayout(void);
extern void SeqPart_CopyDataSecondary(void);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqPart_UndoAllocOnError(void);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteByte_Indexed(int);
extern void Part_CheckAndReallocVoices(unsigned int);
extern void SeqPart_SetupWithDispatch(void);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
extern void SeqPart_RestoreState(void);
extern void SeqPart_PositionForward(void);
extern int SeqPart_CheckBothCompatible(void);

int SeqPart_CheckBothCompatible(void)
{
    if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)] == SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)])
        return 0;
    ram_ce5 = SEQ_OP_DEST_TRACK - 1;
    ram_2873 = SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)];
    ram_287c = SeqStep_ParseRhythm_ByteMap[SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)]];
    SeqPart_SetupWithDispatch();
    if (SEQ_ERROR_CODE != 0) {
        SeqError_MapViaTableA();
        SeqVoice_InitReturnZero();
        return -1;
    }
    return 0;
}

void SeqPart_PositionForward(void)
{
    unsigned int n;
    unsigned char f;

    ram_25da -= ram_27e4;
    ram_269c = ram_265c;
    ram_26a2 = ram_265e;
    if ((SEQ_EDIT_FLAGS & 0x10) && !(SEQ_EDIT_FLAGS & 0x08))
        ram_25da++;
    SeqBuf_ComputePageLayout();
    if (SEQ_ERROR_CODE != 0) {
        if (ram_282a & 0x01)
            SeqPart_RestoreState();
        goto fail;
    }
    ram_26ac = ram_26b8;
    ram_26ae = ram_26ba;
    Part_WriteWordAndByte(ram_26ac, (unsigned char)ram_26ae);
    ram_282c.block = ram_265c;
    ram_282c.offset = ram_265e;
    ram_2830.block = ram_26ac;
    ram_2830.offset = ram_26ae;
    ram_2834.block = ram_27e8;
    ram_2834.offset = ram_27ea;
    SeqPart_CopyDataSecondary();
    if (SEQ_ERROR_CODE != 0)
        goto fail;
    ram_27ec = ram_2834.block;
    ram_27ee = n = ram_2834.offset;
    f = SEQ_EDIT_FLAGS;
    if (!(f & 0x10))
        return;
    if (!(f & 0x08)) {
        ram_27ee = --n;
        if (n > 4)
            return;
        ram_27ec = PartCtrl_ReadWord_Off1(ram_27ec);
        if (ram_27ec == 0)
            goto err11;
        ram_27ee = 0xff;
        return;
    }
    if (SEQ_TRACK != 0x7f && SEQ_TRACK != SEQ_OP_DEST_TRACK)
        return;
    if (!(ram_282a & 0x01))
        return;
    if (!(f & 0x08))
        return;
    ram_27ee = --n;
    if (n <= 4) {
        ram_27ec = PartCtrl_ReadWord_Off1(ram_27ec);
        if (ram_27ec == 0)
            goto err11;
        ram_27ee = 0xff;
    }
    if (--ram_26aa > 4)
        return;
    ram_26a8 = PartCtrl_ReadWord_Off1(ram_26a8);
    if (ram_26a8 == 0) {
err11:
        SEQ_ERROR_CODE = 11;
fail:
        SeqPart_UndoAllocOnError();
        return;
    }
    ram_26aa = 0xff;
}

void SeqPart_RestoreState(void)
{
    if (Part_ReadVoiceBit7(0, ram_2652) == 0)
        return;
    ram_265c = SEQ_DATA_BLOCK = ram_cef[(unsigned char)(ram_2652 - 1)];
    ram_265e = SEQ_DATA_OFFSET = ram_d0f[(unsigned char)(ram_2652 - 1)];
    PartCtrl_WriteByte_Indexed(0x82);
    ram_287d = ram_2652;
    Part_WriteWordAndByte(ram_265c, (unsigned char)ram_265e);
    Part_CheckAndReallocVoices(ram_265c);
}
