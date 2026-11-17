/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_16m236c.c (2026-11-16-107-p6-r21)
   sha256 47e6dbc416b79d2bb1ccc13f0cabcd33b099e9dfb3d5683022b0fd31d27e3602 (tar-sha256); compiled at -O3 -Xr */
struct songrec {
    unsigned char p0[78];
    unsigned int blocks78;
    unsigned char p80[119];
    unsigned char song199;
    unsigned int mask200;
};
extern struct songrec __near SEQ_SONG_RECORD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void SeqData_CopyBlockToBuffer(int);
extern void SeqStep_FindAndCompact(void);
extern void VoicePreset_LoadAndInitPan(int);
void SeqStep_ByteBlockEA5F(void)
{
    unsigned int b, a, c;
    SEQ_SONG_RECORD.song199 = SEQ_CURRENT_SONG;
    SEQ_SONG_RECORD.mask200 = SEQ_TRACK_MASK_COPY;
    SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
    SeqStep_FindAndCompact();
    a = SEQ_SONG_RECORD.blocks78;
    b = SEQ_FREE_BLOCKS;
    c = SEQ_FREE_LIST_HEAD;
    VoicePreset_LoadAndInitPan(SEQ_CURRENT_SONG);
    SEQ_SONG_RECORD.blocks78 = a;
    SEQ_FREE_BLOCKS = b;
    SEQ_FREE_LIST_HEAD = c;
}
