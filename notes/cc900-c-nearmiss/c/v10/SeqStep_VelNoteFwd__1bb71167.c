/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_17m236a.c (2026-11-16-118-p6-r23)
   sha256 1bb71167958e2844f2c7cb58de5a64ee319b1a4b8c75e09ec003eec5b5fd3dd3 (tar-sha256); compiled at -O3 -Xr */
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
