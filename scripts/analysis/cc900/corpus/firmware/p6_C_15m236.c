/* Phase 6, lane_p6 helper C, round 15, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s: the two
   velocity-edit steps that seek a bar, save the data position (ldmm16: the cells are __near) and end in a jump to
   SeqStep_MeasureRead (same module).  The bar byte is read before the store, as the ROM does. */
/* cc900-module: SeqStep_MeasureRead SeqStep_WalkWithCallback */

extern int __near SEQ_OP_FROM;
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned int __near ram_28bf;
extern unsigned int __near ram_28c1;

extern void SeqVoice_SeekToBar(int, int);
extern void SeqData_AdvancePosition(void);
extern int SeqStep_WalkWithCallback(void);
extern void SeqStep_MeasureRead(void);

void SeqStep_VelNoteFwd(void)
{
    int v = SEQ_OP_FROM;
    unsigned char m;
    if (v == 1) return;
    m = ram_2634;
    ram_287f = v;
    SeqVoice_SeekToBar(m, 0);
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

void SeqStep_VelNoteBwd(int v)
{
    unsigned char m = ram_2634;
    ram_287f = v + 1;
    SeqVoice_SeekToBar(m, 0);
    if (SEQ_ERROR_CODE != 0) return;
    ram_273c = SEQ_DATA_BLOCK;
    ram_273e = SEQ_DATA_OFFSET;
    SeqStep_MeasureRead();
}
