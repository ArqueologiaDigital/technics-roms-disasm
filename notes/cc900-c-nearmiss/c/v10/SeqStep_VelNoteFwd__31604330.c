/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/seq_step_routines_m236.c (2026-11-16-122-p6-r24-staged)
   sha256 31604330ada1c61ada31f551f49e471e33a491742808ff38e3f7a7495b5acef1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern void SeqData_AdvancePosition(void);
extern int __near SEQ_OP_FROM;
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned int __near ram_28bf;
extern unsigned int __near ram_28c1;
extern void SeqVoice_SeekToBar(int, int);
extern int SeqStep_WalkWithCallback(void);
extern void SeqStep_MeasureRead(void);
void SeqStep_VelNoteFwd(void)
{
    unsigned char m;
    int v = SEQ_OP_FROM;
    int t, a;
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
