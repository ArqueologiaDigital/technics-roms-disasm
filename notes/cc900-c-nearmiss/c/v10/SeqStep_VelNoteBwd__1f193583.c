/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/seq_step_routines_m236.c (2026-11-16-103-p6-r20-staged)
   sha256 1f1935834ffc6c38a49d342aca78b4ad2842b8b466a562245d478a47da9d4c8f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern void SeqVoice_SeekToBar(int, int);
extern void SeqStep_MeasureRead(void);
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
