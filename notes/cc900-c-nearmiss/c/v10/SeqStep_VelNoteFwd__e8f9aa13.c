/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15m236.c (2026-11-16-100-p6-r19)
   sha256 e8f9aa139f5b7767f8977999b37dbf8899bfe69c770ccd0c615965a4bf28862d (tar-sha256); compiled at -O3 -Xr */
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
