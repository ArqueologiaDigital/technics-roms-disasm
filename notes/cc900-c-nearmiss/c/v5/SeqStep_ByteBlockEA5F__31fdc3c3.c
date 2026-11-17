/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/seq_step_routines_m236.c (2026-11-16-122-p6-r24-staged)
   sha256 31fdc3c356af02b573e844fcff55985a7695a42f9941a0d45c90346f3a1e3dda (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_f247;
extern unsigned int __near ram_f248;
extern unsigned int __near ram_f1ce;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void SeqData_CopyBlockToBuffer(int);
extern void VoicePreset_LoadAndInitPan(int);
extern void SeqStep_FindAndCompact(void);
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
