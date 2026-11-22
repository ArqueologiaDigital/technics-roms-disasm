/* Probe round 31r1, helper R, form b (the track byte read into a local before the store to ram_287f): sequencer/sequencer_engine.s SeqPart_CountEventsInRange (module 236).
   Seek the drum part to its bar, then count bars (0x82 ends) and the steps of the last bar (0x81 events).
   Also SeqPart_PositionBackward (same in forms a and b). */
/* cc900-module: SeqPart_UndoAllocOnError */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_2652;
extern unsigned int __near ram_287f;
extern unsigned int __near ram_288b;
extern unsigned int __near ram_2889;
extern unsigned char __near ram_288e;
extern unsigned char SeqVoice_FindDrumPartIndex(void);
extern void SeqVoice_SeekToBar(int, int);
extern void SeqTrack_ProcessControlBytes(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void PartCtrl_AdvanceReadPos(void);
extern void SeqPart_CountEventsInRange(unsigned int *bars, unsigned int *steps);

void SeqPart_CountEventsInRange(unsigned int *bars, unsigned int *steps)
{
    unsigned char n;
    unsigned char c;

    SEQ_ERROR_CODE = 0;
    n = SeqVoice_FindDrumPartIndex();
    c = ram_2652;
    ram_287f = 1;
    SeqVoice_SeekToBar(c, n);
    if (SEQ_ERROR_CODE != 0) return;
    ram_288b = SEQ_DATA_BLOCK;
    ram_2889 = SEQ_DATA_OFFSET;
    *bars = 0;
    for (;;) {
        *steps = 0;
        for (;;) {
            if (ram_288e == *steps) {
                SeqTrack_ProcessControlBytes();
                if (SEQ_ERROR_CODE != 0) return;
                break;
            }
            c = SeqPart_ReadByte_Secondary();
            if (c == 0x82) {
                (*bars)++;
                return;
            }
            if (c == 0x81) {
                (*steps)++;
                PartCtrl_AdvanceReadPos();
                if (SEQ_ERROR_CODE != 0) return;
            } else {
                PartCtrl_AdvanceReadPos();
                if (SEQ_ERROR_CODE != 0) return;
            }
        }
        (*bars)++;
    }
}
/* SeqPart_PositionBackward, written in the style of the built SeqPart_PositionEqual (cc900/sequencer_engine_m236.c) */
struct bo { unsigned int block; unsigned int offset; };
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned long __near ram_25da;
extern unsigned long __near ram_27e4;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern struct bo __near ram_282c;
extern struct bo __near ram_2830;
extern struct bo __near ram_2834;
extern void PartCtrl_FindActiveByLimit(unsigned int *, unsigned int *);
extern void SeqPart_CopyDataPrimary(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern void Part_CheckAndReallocVoices(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void SeqPart_UndoAllocOnError(void);
extern void SeqPart_PositionBackward(void);

void SeqPart_PositionBackward(void)
{
    unsigned long d;
    unsigned int n;

    d = ram_27e4 - ram_25da;
    if ((SEQ_EDIT_FLAGS & 0x10) && !(SEQ_EDIT_FLAGS & 0x08))
        d--;
    ram_25da = d;
    ram_27ec = ram_27e8;
    ram_27ee = ram_27ea;
    PartCtrl_FindActiveByLimit(&ram_27ec, &ram_27ee);
    if (SEQ_ERROR_CODE != 0) goto fail;
    ram_282c.block = ram_27e8;
    ram_282c.offset = ram_27ea;
    ram_2830.block = ram_27ec;
    ram_2830.offset = ram_27ee;
    ram_2834.block = ram_265c;
    ram_2834.offset = ram_265e;
    SeqPart_CopyDataPrimary();
    if (SEQ_ERROR_CODE != 0) goto fail;
    n = ram_2834.offset;
    if (n == 5) {
        ram_2834.block = PartCtrl_ReadWord_Off1(ram_2834.block);
        if (ram_2834.block == 0) goto fail;
        ram_2834.offset = 0xff;
    } else
        ram_2834.offset = n - 1;
    if (SEQ_EDIT_FLAGS & 0x08) {
        ram_265e = ram_27ee;
        ram_265c = ram_27ec;
    }
    Part_WriteWordAndByte(ram_265c, (unsigned char)ram_265e);
    Part_CheckAndReallocVoices(ram_265c);
    if (SEQ_ERROR_CODE != 0) goto fail;
    if ((SEQ_EDIT_FLAGS & 0x10) && !(SEQ_EDIT_FLAGS & 0x08)) {
        if (--ram_27ee < 5) {
            ram_27ec = PartCtrl_ReadWord_Off1(ram_27ec);
            if (ram_27ec == 0) {
                SEQ_ERROR_CODE = 10;
                goto fail;
            }
            if (PartCtrl_TestBit7(ram_27ec) == 0) {
                SEQ_ERROR_CODE = 11;
fail:
                SeqPart_UndoAllocOnError();
            }
        }
    }
}
